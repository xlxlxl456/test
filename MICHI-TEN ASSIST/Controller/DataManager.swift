//
//  DataManager.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/15.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import CoreLocation

struct DataManager {
    static var rootPath:            String { NSHomeDirectory() + "/Documents/TABdata" }
    static var webPath:             String { NSHomeDirectory() + "/Library/WebPage" }
    static var webDataPath:         String { NSHomeDirectory() + "/Library/WebPage/TABdata" }
    static var dummyId:             String { "00000000-0000-0000-0000-000000000000" }
    static var keyChainExpiration:  String { "expiration" }
    static var keyChainAccount:     String { "MICHI-TEN ASSIST" }
    
    static var dataExsits: Bool {
        if Index.load() == nil { return false }
        if Setting.load() == nil { return false }
        return true
    }
    
    static func setup() {
        // ダミーフアィルを作っておく
        let dummyFilePath = NSHomeDirectory() + "/Documents/ここにデータを置いてください"
        if !FileManager.default.fileExists(atPath: rootPath) &&
            !FileManager.default.fileExists(atPath: dummyFilePath) {
            FileManager.default.createFile(atPath: dummyFilePath, contents: nil, attributes: nil)
        }
        copyWeb()
    }
    
    static func imageFor(facilitySn: String?, fileName: String?) -> UIImage? {
        let url = URL(fileURLWithPath: rootPath)
            .appendingPathComponent("Images")
        
        if let facilitySn = facilitySn, let fileName = fileName  {
            let imgUrl = url
                .appendingPathComponent(facilitySn)
                .appendingPathComponent(fileName)
            
            if let data = try? Data(contentsOf: imgUrl) {
                return UIImage(data: data)
            }
        }
        
        if let data = try? Data(contentsOf: url.appendingPathComponent("noimg.jpg")) {
            return UIImage(data: data)
        }
        return nil
    }
    
    static func add(imageInfo: [UIImagePickerController.InfoKey : Any]?, facilitySn: String, fileName: String) -> Bool {
        guard let info = imageInfo,
            let image = info[.originalImage] as? UIImage,
            let jpg = image.jpegData(compressionQuality: 0.8),
            let source = CGImageSourceCreateWithData(jpg as CFData, nil),
            let type = CGImageSourceGetType(source) else {
            return false
        }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else {
            return false
        }
        
        let timeCorrection = Setting.shared?.arInfo.timeCorrection ?? 0
        let timeStamp = Date().addingTimeInterval(TimeInterval(timeCorrection)).string(.dateTime(.colon))
        
        // exifにタイムスタンプを追記
        var metaData = (info[.mediaMetadata] as? [CFString: Any]) ?? [:]
        var exif = (metaData[kCGImagePropertyExifDictionary] as? [CFString: Any]) ?? [:]
        exif[kCGImagePropertyExifDateTimeOriginal] = timeStamp
        exif[kCGImagePropertyExifDateTimeDigitized] = timeStamp
        exif[kCGImagePropertyExifUserComment] = timeStamp
        metaData[kCGImagePropertyExifDictionary] = exif

        CGImageDestinationAddImageFromSource(destination, source, 0, metaData as CFDictionary)
        CGImageDestinationFinalize(destination)

         if data.write(toFile: "\(rootPath)/Images/\(facilitySn)/\(fileName)", atomically: true),
            linkImages(facilitySn: facilitySn) {
            return true
        }
        return false
    }
    
    static func copyWeb() {
        // WebViewで開くHTML、JSは、同フォルダ配下のリソースしかアクセスできないため、
        // ネイティブ画像をHTMLに表示させるために、BundleからWebフォルダを/Libraryへ展開しておく
        // （後で撮った写真も/Libraryにリンクを追加する）
        guard !FileManager.default.fileExists(atPath: webPath),
            let path = Bundle.main.resourcePath.flatMap({ $0 + "/WebPage" }) else {
            return
        }
        do {
            try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: URL(fileURLWithPath: webPath))
        } catch {}
    }
    
    @discardableResult
    static func linkImages(facilitySn: String) -> Bool {
        // HTMLに表示させるために、通常/Documents/TABdataに保存した画像を、/Library/WebPage/TABdataにリンクを置く
        // 注意：既存のWebPage配下に「images」が既に存在するため、リンクを/Library/WebPage/Imagesにすると正しく動作しない
        
        delinkImages() //クリアしておく
        let imgsPath = "/Images/\(facilitySn)"
        let path = webDataPath + imgsPath
        let url = URL(fileURLWithPath: path)
        do {
            try FileManager.default.createDirectory(atPath: webDataPath + "/Images", withIntermediateDirectories: true)
            try FileManager.default.linkItem(at: URL(fileURLWithPath: rootPath + imgsPath), to: url)
            return true
        } catch {
            return false
        }
    }
    
    static func delinkImages() {
        // /Documents/TABdata配下のリリースがリンクされている状態では、TABdataフォルダをPCにコピーできないため、
        // 適宜なタイミングでリンクを解除しておく
        let path = webDataPath + "/Images"
        let url = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {}
    }
    
    static func update(serialNumber: String, location: CLLocation) {
        // 更新した位置情報をFacility、Indexへ反映
        guard var facility = Facility.load(serialNumber: serialNumber),
            var index = Index.shared,
            let facilityIndex = Index.shared?.facilities?.firstIndex(where: {
                $0.facility?.serialNumber == serialNumber
            }) else {
            return
        }
        
        func convert(degree: CLLocationDegrees) -> String {
            var seconds = degree * 3600
            let degrees = Int(seconds) / 3600
            seconds = abs(seconds.truncatingRemainder(dividingBy: 3600))
            let minutes = Int(seconds) / 60
            seconds = seconds.truncatingRemainder(dividingBy: 60)
            return String(format:"%d°%d′%0.3f″", degrees, minutes, seconds)
        }
        
        index.facilities?[facilityIndex].facility?.latitudeStr = "\(location.coordinate.latitude)"
        index.facilities?[facilityIndex].facility?.longitudeStr = "\(location.coordinate.longitude)"
        index.synchronize()
        
        facility.facilityItem?.facility?.latitudeStr = "\(location.coordinate.latitude)"
        facility.facilityItem?.facility?.latitude = location.coordinate.latitude
        facility.facilityItem?.facility?.latitude60 = convert(degree: location.coordinate.latitude)
        
        facility.facilityItem?.facility?.longitudeStr = "\(location.coordinate.longitude)"
        facility.facilityItem?.facility?.longitude = location.coordinate.longitude
        facility.facilityItem?.facility?.longitude60 = convert(degree: location.coordinate.longitude)
        facility.save()
    }
    
    static func creatNewFacility(facilityType: String, stanchionType: String, serialNumber: String, location: CLLocation) -> Bool {
        guard let setting = Setting.shared,
            var facility = setting.newFacility,
            var inspection = setting.newInspection
        else {
            return false
        }
        var item = Facility.Item()
        let facilitySpecId = UUID().uuidString
        
        facility.facilitySpecId     = facilitySpecId
        facility.businessId         = setting.businessId
        facility.businessNumber     = setting.businessNumber
        facility.deviceId           = setting.deviceId
        facility.deviceIdStr        = setting.deviceIdStr
        facility.serialNumber       = serialNumber
        facility.facilityType       = facilityType
        facility.stanchionType      = stanchionType
        item.facility = facility
        
        let inspectionId = UUID().uuidString
        inspection.inspectionId     = inspectionId
        inspection.facilitySpecId   = facilitySpecId
        inspection.businessId       = setting.businessId
        inspection.businessNumber   = setting.businessNumber
        inspection.deviceId         = setting.deviceId
        inspection.deviceIdStr      = setting.deviceIdStr
        inspection.serialNumber     = serialNumber
        inspection.facilityType     = facilityType
        item.inspection = inspection
        
        item.images = []
        
        let details: [InspectionDetail]? = setting.newInspectionDetails?.map { detail in
            var detail = detail
            detail.inspectionId         = inspectionId
            detail.inspectionDetailId   = UUID().uuidString
            detail.facilitySpecId       = facilitySpecId
            detail.serialNumber         = serialNumber
            detail.facilityType         = facilityType
            detail.businessId           = setting.businessId
            detail.businessNumber       = setting.businessNumber
            detail.deviceId             = setting.deviceId
            detail.deviceIdStr          = setting.deviceIdStr
            detail.applicable           = detail.inspectionPoint?.isEmpty != false ? "無" : "有"
            return detail
        }
        item.inspectionDetails = details
        
        let map = Facility.Item.Map (
            facilitySpecId: facilitySpecId,
            mapFileId: DataManager.dummyId,
            fileName: "",
            serialNumber: serialNumber
        )
        item.map = map
        
        item.damageLogs = []

        var f = Facility()
        f.facilityItem = item
        f.url = URL(fileURLWithPath: rootPath)
            .appendingPathComponent("Facilities")
            .appendingPathComponent(serialNumber)
            .appendingPathComponent("facility.json")
        
        do {
            let facilityPath = rootPath + "/Facilities/\(serialNumber)"
            if !FileManager.default.fileExists(atPath: facilityPath) {
                try FileManager.default.createDirectory(atPath: facilityPath, withIntermediateDirectories: true)
            }
            
            let imagePath = rootPath + "/Images/\(serialNumber)"
            if !FileManager.default.fileExists(atPath: imagePath) {
                try FileManager.default.createDirectory(atPath: imagePath, withIntermediateDirectories: true)
            }
        } catch {
            return false
        }
        if !f.save() { return false }
        updateIndex(item: item)
        update(serialNumber: serialNumber, location: location)
        return true
    }
    
    static func updateIndex(item: Facility.Item?) {
        // Facility情報に基づきIndex.Facilityを再編
        guard var index = Index.shared, let item = item else {
            return
        }
        
        let facility = Index.Facility.Facility(
            facilitySpecId:         item.facility?.facilitySpecId,
            serialNumber:           item.facility?.serialNumber,
            roadPointStr:           item.facility?.roadPointStr,
            latitudeStr:            item.facility?.latitudeStr,
            longitudeStr:           item.facility?.longitudeStr,
            inspectionDateStr:      item.facility?.inspectionDateStr,
            inspectionDeviceStatus: item.facility?.inspectionDeviceStatus
        )
        
        let images = item.images?.filter({
            $0.selectedStatus == 1
        })
        
        let inspection = Index.Facility.Inspection(facilityHealth: item.inspection?.facilityHealth)
        
        let indexFacility = Index.Facility(facility: facility,
                                           images: images,
                                           inspection: inspection,
                                           distance: nil)
        
        if let i = index.facilities?.firstIndex(where: {
            $0.facility?.serialNumber == item.facility?.serialNumber
        }) {
            index.facilities?[i] = indexFacility
        } else {
            index.facilities?.append(indexFacility)
        }
        index.synchronize()
    }
}

// アクティベーション
extension DataManager {
    
    static var expiration: Date? {
        let dic: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                  kSecAttrGeneric as String: keyChainExpiration,
                                  kSecReturnData as String: kCFBooleanTrue!]

        var data: AnyObject?
        let matchingStatus = withUnsafeMutablePointer(to: &data){
            SecItemCopyMatching(dic as CFDictionary, UnsafeMutablePointer($0))
        }

        if matchingStatus == errSecSuccess {
            if let string = (data as? Data).flatMap({ String(data: $0, encoding: .utf8) }),
                let timeStamp = string.components(separatedBy: ".").first,
                let expiration = timeStamp.date(.timestamp) {
                return expiration
            }
            return nil
        } else {
            return nil
        }
    }
    
    static func save(expiration: Date, id: String) -> Bool {
        guard let data = (expiration.string(.timestamp) + "." + id)
            .data(using: .utf8) else {
            return false
        }
        
        let dic: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                  kSecAttrGeneric as String: keyChainExpiration,
                                  kSecAttrAccount as String: keyChainAccount,
                                  kSecValueData as String: data]
        
        var itemAddStatus: OSStatus?
        let matchingStatus = SecItemCopyMatching(dic as CFDictionary, nil)
        if matchingStatus == errSecItemNotFound {
            // 保存
            itemAddStatus = SecItemAdd(dic as CFDictionary, nil)
        } else if matchingStatus == errSecSuccess {
            // 更新
            itemAddStatus = SecItemUpdate(dic as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        } else {
            return false
        }
        return itemAddStatus == errSecSuccess
    }
    
    @discardableResult
    static func deleteExpiration() -> Bool {
        let dic: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                  kSecAttrGeneric as String: keyChainExpiration,
                                  kSecAttrAccount as String: keyChainAccount]

        if SecItemDelete(dic as CFDictionary) == errSecSuccess {
            return true
        } else {
            return false
        }
    }
}
