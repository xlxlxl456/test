//
//  JavaScriptManager.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/18.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation

final class JavaScriptManager: NSObject {
    
    static var interfaceName: String { "iOSNative" }
    
    weak var webViewController: WebViewController?
    private var editMode = false
    private var currentLineNumber: Int?
    
    private var executorMap: [String: String] {
        ["setEditMode":                 "setEditMode:",
         "SaveEditFacility":            "saveEditFacility",
         "changeLocationFromFacility":  "changeLocationFromFacility",
         "goto_camera_mode_byFacility": "openCameraFromFacility:",
         "goto_camera_mode":            "openCamera:",
         "savetFacilityData":           "savetFacilityData:",
         "go_ar":                       "showAr",
         "go_InspectionFromFacility":   "showInspectionFromFacility",
         "StartEditFacility":           "startEditFacility",
         "EndEditFacility":             "endEditFacility",
         "fix_from_shogen":             "fixFromShogen",
         "appendDeviceLog":             "appendDeviceLog:",
         "savetInspectionPrimaryData":  "savetInspectionPrimaryData:",
         "savetInspectionDetailData":   "savetInspectionDetailData:",
         "go_Facirity":                 "showFacirity",
         "go_DamageLog":                "showDamageLog:",
         "EndInspectionDetail":         "endInspectionDetail:",
         "StartInspectionDetail":       "startInspectionDetail:",
         "saveDamageLogData":           "saveDamageLogData:",
         "log":                         "log:"
        ]
    }
    
    private var fetcherMap: [String: String] {
        ["IsEditMode":                  "isEditMode",
         "showCorrection":              "timeCorrection",
         "getDataFolder":               "dataFolder",
         "getFacilityData":             "facilityData",
         "getFacilityMap":              "facilityMap",
         "getFacilityImages":           "facilityImages",
         "getDamageLogData":            "damageLogData",
         "getSpecialNote":              "specialNote",
         "changeSelectedImgFacility":   "changeSelectedImgFacility:",
         "getInspectionData":           "inspectionData",
         "getDamageLogImages":          "damageLogImages",
         "changeSelectedImgDamageLof":  "changeSelectedImgDamageLof:"
        ]
    }
    
    // JSからの呼び出しを中継（戻り値なし）
    func execute(_ name: String, params: Any?) {
        if let selector = executorMap[name] {
            perform(NSSelectorFromString(selector), with: params)
        }
    }
    
    // JSからの呼び出しを中継（戻り値あり）
    func fetch(_ name: String, params: String?) -> String? {
        if let selector = fetcherMap[name] {
            return perform(NSSelectorFromString(selector), with: params).takeUnretainedValue() as? String
        }
        return nil
    }
    
    // Andoridソースを参考した処理
    func updateInspectionDeviceStatus(_ status: InspectionDeviceStatus, save: Bool, completed: Bool) {
        guard var facility = Facility.current,
            (facility.facilityItem?.facility?.inspectionDeviceStatus != status || save) else {
            return
        }
        
        facility.facilityItem?.facility?.inspectionDeviceStatus = status
        
        if status == .inspected {
            let now = Date()
            facility.facilityItem?.facility?.inspectionDeviceDateEnd = now.string(.dateTime(.hyphen))
            
            if completed {
                facility.facilityItem?.facility?.inspectionDate         = now.string(.date(.hyphen))
                facility.facilityItem?.facility?.inspectionDateStr      = now.string(.date(.ja))
                facility.facilityItem?.facility?.inspectionDateYearStr  = now.string(.year(.ja))
                facility.facilityItem?.facility?.inspectionDateMonthStr = now.string(.month(.ja))
                facility.facilityItem?.facility?.inspectionDateDayStr   = now.string(.day(.ja))
            }
        }
        
        if save {
            facility.synchronize()
            DataManager.updateIndex(item: facility.facilityItem)
        } else {
            facility.update()
        }
    }
    
    private func jsonString<T: Encodable>(from objct: T?) -> String {
        return objct.flatMap({
            if let data = try? JSONEncoder().encode($0) {
                return String(data: data, encoding: .utf8)
            }
            return nil
        }) ?? ""
    }
    
    private func load<T: Decodable>(_ type: T.Type, from string: String?) -> T? {
        return string?.data(using: .utf8).flatMap({
            try? JSONDecoder().decode(T.self, from: $0)
        })
    }
    
    @discardableResult
    private func creatDamageLog(lineNumber: Int) -> DamageLog? {
        guard var damageLog = Setting.shared?.newDamageLog,
            var log = damageLog.damageLog else {
            return nil
        }
        
        guard let item = Facility.current?.facilityItem else {
            return damageLog
        }

        if let inspection = item.inspection {
            log.inspectionId            = inspection.inspectionId
            log.facilitySpecId          = inspection.facilitySpecId
            log.businessId              = inspection.businessId
            log.businessNumber          = inspection.businessNumber
            log.facilityType            = inspection.facilityType
            log.areaOffice              = inspection.areaOffice
            log.office                  = inspection.office
            log.branchOffice            = inspection.branchOffice
            log.deviceId                = inspection.deviceId
            log.deviceIdStr             = inspection.deviceIdStr
            log.inspectionDeviceDateSt  = inspection.inspectionDeviceDateSt
            log.inspectionDeviceDateEnd = inspection.inspectionDeviceDateEnd
        }
        
        if let detail = item.inspectionDetails?.first(where: { $0.lineNumber == lineNumber}) {
            log.inspectionPoint         = detail.inspectionPoint
            log.inspectionPointMark     = detail.inspectionPointMark
            log.inspectionId            = detail.inspectionId
            log.facilitySpecId          = detail.facilitySpecId
            log.businessId              = detail.businessId
            log.lineNumber              = detail.lineNumber
            log.businessNumber          = detail.businessNumber
            log.facilityType            = detail.facilityType
            log.areaOffice              = detail.areaOffice
            log.office                  = detail.office
            log.branchOffice            = detail.branchOffice
            log.steelCrackBefore        = detail.steelCrackBefore
            log.steelCrackAfter         = detail.steelCrackAfter
            log.steelLooseBefore        = detail.steelLooseBefore
            log.steelLooseAfter         = detail.steelLooseAfter
            log.steelBreakBefore        = detail.steelBreakBefore
            log.steelBreakAfter         = detail.steelBreakAfter
            log.steelCorrosionBefore    = detail.steelCorrosionBefore
            log.steelCorrosionAfter     = detail.steelCorrosionAfter
            log.steelDeformationBefore  = detail.steelDeformationBefore
            log.steelDeformationAfter   = detail.steelDeformationAfter
            log.concreteCrackBefore     = detail.concreteCrackBefore
            log.concreteCrackAfter      = detail.concreteCrackAfter
            log.concretePeelingBefore   = detail.concretePeelingBefore
            log.concretePeelingAfter    = detail.concretePeelingAfter
            log.commonWaterBefore       = detail.commonWaterBefore
            log.commonWaterAfter        = detail.commonWaterAfter
            log.commonOtherBefore       = detail.commonOtherBefore
            log.commonOtherAfter        = detail.commonOtherAfter
            log.deviceId                = detail.deviceId
            log.deviceIdStr             = detail.deviceIdStr
        }
        
        log.damageLogId = UUID().uuidString
        log.serialNumber = item.facility?.serialNumber
        damageLog.damageLog = log
        
        if item.damageLogs?.contains(where: { $0.damageLog?.lineNumber == lineNumber }) == false {
            Facility.current?.facilityItem?.damageLogs?.append(damageLog)
            Facility.current?.save()
        }
        
        return damageLog
    }
}

// JSからの呼ばれる処理（戻り値なし）。JS、Androidソースを参照
extension JavaScriptManager {
    
    @objc func log(_ log: String?) {
        log.flatMap { print($0) }
    }
    
    @objc func setEditMode(_ mode: NSNumber?) {
        editMode = mode?.boolValue == true
    }
        
    @objc func showAr() {
        webViewController?.close()
    }
    
    @objc func startEditFacility() {
        updateInspectionDeviceStatus(.inspecting, save: true, completed: false)
    }
    
    @objc func saveEditFacility() {
        updateInspectionDeviceStatus(.inspecting, save: true, completed: false)
    }

    @objc func endEditFacility() {
        updateInspectionDeviceStatus(.inspected, save: true, completed: true)
    }

    @objc func changeLocationFromFacility() {
        guard let serialNumber = Facility.current?.facilityItem?.facility?.serialNumber,
            let webVC = webViewController else {
                return
        }
        
        UpdateLocationViewController.updateFacility(serialNumber: serialNumber, viewController: webVC) { [weak self] location in
            // ボタンを有効化
            let webView = self?.webViewController?.webView
            webView?.evaluateJavaScript("finishChangeLocationButton()")
            
            if location == nil {
                return
            }
            
            Facility.loadCurrent(serialNumber: serialNumber)
            
            if let latitudeStr = Facility.current?.facilityItem?.facility?.latitude60,
                let longitudeStr = Facility.current?.facilityItem?.facility?.longitude60 {
                let locationStr = "'\(latitudeStr),\(longitudeStr)'"
                webView?.evaluateJavaScript("finishChangeLocationLatLng(\(locationStr))")
            }
        }
    }

    @objc func openCameraFromFacility(_ selectedStatus: String?) {
        webViewController?.openCamera({ info in
            let fileName = UUID().uuidString + ".jpg"
            
            guard var facility = Facility.current,
                let serialNumber = facility.facilityItem?.facility?.serialNumber,
                DataManager.add(imageInfo: info, facilitySn: serialNumber, fileName: fileName),
                let selectedStatus = selectedStatus.flatMap({ Int($0) }) else {
                return
            }
            
            var caption = ""
            
            if let index = facility.facilityItem?.images?.firstIndex(where: {
                $0.selectedStatus == selectedStatus
               }) {
                caption = facility.facilityItem?.images?[index].caption ?? ""
                facility.facilityItem?.images?[index].selectedStatus = 0
            }
            
            let facilitySpecId = facility.facilityItem?.facility?.facilitySpecId
            
            facility.facilityItem?.images?.append(
                .init(imageFileId:      UUID().uuidString,
                      facilitySpecId:   facilitySpecId,
                      parentId:         facilitySpecId,
                      caption:          caption,
                      fileName:         fileName,
                      selectedStatus:   selectedStatus,
                      timeStamp:        Date().string(.dateTime(.hyphen)),
                      individualId:     UUID().uuidString,
                      origin:           2,
                      info:             "Tablet"
                )
            )
            facility.synchronize()
        })
    }
    
    @objc func showInspectionFromFacility() {
        //　処理なし
    }

    @objc func savetFacilityData(_ jsonStr: String?) {
        guard let jsItem = load(JSFacility.self, from: jsonStr),
            var item = Facility.current?.facilityItem else {
            return
        }
        
        if let facility = jsItem.facility {
            item.facility?.combine(facility)
            
            var inspection = item.inspection ?? .init()
            facility.facilityType.flatMap({ inspection.facilityType = $0 })
            facility.areaOffice.flatMap({ inspection.areaOffice = $0 })
            facility.office.flatMap({ inspection.office = $0 })
            facility.serialNumber.flatMap({ inspection.serialNumber = $0 })
            
            item.inspection = inspection
            
            item.inspectionDetails = item.inspectionDetails?.map({ detail in
                    var detail = detail
                    facility.facilityType.flatMap({ detail.facilityType = $0 })
                    facility.areaOffice.flatMap({ detail.areaOffice = $0 })
                    facility.office.flatMap({ detail.office = $0 })
                    facility.serialNumber.flatMap({ detail.serialNumber = $0 })
                    return detail
                }
            )
            
            item.damageLogs = item.damageLogs?.map({ log in
                    var log = log
                    facility.facilityType.flatMap({ log.damageLog?.facilityType = $0 })
                    facility.areaOffice.flatMap({ log.damageLog?.areaOffice = $0 })
                    facility.office.flatMap({ log.damageLog?.office = $0 })
                    facility.serialNumber.flatMap({ log.damageLog?.serialNumber = $0 })
                    return log
                }
            )
        }
        
        var images = item.images ?? []
        jsItem.images.forEach { image in
            
            if let index = images.firstIndex(where: {
                $0.selectedStatus == image.selectedStatus
            }) {
                image.caption.flatMap({ images[index].caption = $0 })
            } else {
                images.append(
                    .init(imageFileId: UUID().uuidString,
                          facilitySpecId:   DataManager.dummyId,
                          parentId:         DataManager.dummyId,
                          caption:          image.caption,
                          fileName:         "",
                          selectedStatus:   image.selectedStatus,
                          timeStamp:        nil,
                          individualId:     nil,
                          origin:           nil,
                          info:             nil
                    )
                )
            }
        }
        
        updateInspectionDeviceStatus(.inspecting, save: false, completed: false)
        Facility.current?.facilityItem = item
        Facility.current?.save()
        DataManager.updateIndex(item: item)
    }
    
    @objc func fixFromShogen() {
        updateInspectionDeviceStatus(.inspected, save: true, completed: true)
        showAr()
    }
    
    @objc func openCamera(_ selectedStatus: String?) {
        webViewController?.openCamera({ [weak self] info in
            let fileName = UUID().uuidString + ".jpg"
            
            guard let selectedStatus = selectedStatus.flatMap({ Int($0) }),
                var facility = Facility.current,
                let serialNumber = facility.facilityItem?.facility?.serialNumber,
                DataManager.add(imageInfo: info, facilitySn: serialNumber, fileName: fileName),
                let lineNumber = self?.currentLineNumber,
                let logIndex = facility.facilityItem?.damageLogs?.firstIndex(where: {
                    $0.damageLog?.lineNumber == lineNumber
                }),
                var images = facility.facilityItem?.damageLogs?[logIndex].images else {
                return
            }
            
            var caption = ""
            if let imgIndex = images.firstIndex(where: {
                $0.selectedStatus == selectedStatus
            }) {
                caption = images[imgIndex].caption ?? ""
                images[imgIndex].selectedStatus = 0
            }
            
            let facilitySpecId = Facility.current?.facilityItem?.facility?.facilitySpecId
            
            images.append(
                .init(imageFileId:      UUID().uuidString,
                      facilitySpecId:   facilitySpecId,
                      parentId:         facility.facilityItem?.damageLogs?[logIndex].damageLog?.damageLogId,
                      caption:          caption,
                      fileName:         fileName,
                      selectedStatus:   selectedStatus,
                      timeStamp:        Date().string(.dateTime(.hyphen)),
                      individualId:     UUID().uuidString,
                      origin:           2,
                      info:             "Tablet"
                )
            )
            
            facility.facilityItem?.damageLogs?[logIndex].images = images
            facility.synchronize()
        })
    }
    
    @objc func savetInspectionPrimaryData(_ params: [String: Any]?) {
        updateInspectionDeviceStatus(.inspected, save: false, completed: false)
        
        guard let jsonStr = params?["s"] as? String,
            let inspection = load(Inspection.self, from: jsonStr) else {
            return
        }
        Facility.current?.facilityItem?.inspection?.combine(inspection)
        Facility.current?.save()
        DataManager.updateIndex(item: Facility.current?.facilityItem)
    }
    
    @objc func startInspectionDetail(_ lineNumber: NSNumber?) {
        if let lineNumber = lineNumber?.intValue,
            let index = Facility.current?.facilityItem?.damageLogs?.firstIndex(where: {
                $0.damageLog?.lineNumber == lineNumber
            }) {
            Facility.current?.facilityItem?.damageLogs?[index].damageLog?.isTemporary = false
            updateInspectionDeviceStatus(.inspecting, save: false, completed: false)
            Facility.current?.save()
        }
    }
    
    @objc func endInspectionDetail(_ lineNumber: NSNumber?) {
        updateInspectionDeviceStatus(.inspected, save: false, completed: false)
        
        guard let lineNumber = lineNumber?.intValue,
            var facility = Facility.current else {
                return
        }
        
        let dateEnd = Date().string(.dateTime(.hyphen))
        
        if facility.facilityItem?.damageLogs?.contains(where: {
            $0.damageLog?.lineNumber == lineNumber
        }) == false {
            creatDamageLog(lineNumber: lineNumber)
        }
        
        if let index = facility.facilityItem?.damageLogs?.firstIndex(where: {
            $0.damageLog?.lineNumber == lineNumber
        }) {
            facility.facilityItem?.damageLogs?[index].damageLog?.inspectionDeviceDateEnd = dateEnd
            facility.synchronize()
        }
        
        DataManager.updateIndex(item: facility.facilityItem)
    }
    
    @objc func savetInspectionDetailData(_ params: [String: Any]?) {
        guard let jsonStr = params?["s"] as? String,
            let details = load(JSInspectionDetails.self, from: jsonStr)?.items,
            var inspectionDetails = Facility.current?.facilityItem?.inspectionDetails else {
            return
        }
        
        var damageLogs = Facility.current?.facilityItem?.damageLogs
        
        details.forEach { detail in
            if let index = inspectionDetails.firstIndex(where: {
                $0.lineNumber == detail.lineNumber
            }) {
                inspectionDetails[index].combine(detail) 
                
                if let logIndex = damageLogs?.firstIndex(where: {
                    $0.damageLog?.lineNumber == detail.lineNumber
                }) {
                    damageLogs?[logIndex].damageLog?.combine(detail)
                }
            }
        }
        
        Facility.current?.facilityItem?.inspectionDetails = inspectionDetails
        Facility.current?.facilityItem?.damageLogs = damageLogs
        Facility.current?.save()
        DataManager.updateIndex(item: Facility.current?.facilityItem)
    }

    @objc func showDamageLog(_ lineNumber: String?) {
        currentLineNumber = lineNumber.flatMap({ Int($0) })
    }

    @objc func saveDamageLogData(_ params: [String: Any]?) {
        guard let jsonStr = params?["s"] as? String,
            let editedLog = load(JSDamageLog.self, from: jsonStr),
            let save = (params?["save"] as? NSNumber)?.boolValue,
            let edited = (params?["edited"] as? NSNumber)?.boolValue,
            let lineNumber = currentLineNumber,
            var facility = Facility.current else {
            return
        }
        
        var damageLog = facility.facilityItem?.damageLogs?.first(where: {
            $0.damageLog?.lineNumber == lineNumber
        }) ?? creatDamageLog(lineNumber: lineNumber)
        
        var detail = facility.facilityItem?.inspectionDetails?.first(where: {
            $0.lineNumber == lineNumber
        })
        
        if edited {
            damageLog?.damageLog?.isTemporary = false
        }
        
        if let log = editedLog.damageLog {
            detail?.combine(log)
            damageLog?.damageLog?.combine(log)
        }
        
        let images: [Image] = editedLog.images?.compactMap({ damageImage in
            if var image = damageLog?.images?.first(where: {
                $0.selectedStatus == damageImage.selectedStatus
            }) {
                image.caption = damageImage.caption
                return image
            } else if let caption = damageImage.caption, !caption.isEmpty {
                return Image(imageFileId: UUID().uuidString,
                             facilitySpecId:    DataManager.dummyId,
                             parentId:          DataManager.dummyId,
                             caption:           caption,
                             fileName:          "",
                             selectedStatus:    damageImage.selectedStatus,
                             timeStamp:         nil,
                             individualId:      nil,
                             origin:            nil,
                             info:              nil
                )
            }
            return nil
        }) ?? []
        
        damageLog?.images = images
        
        if let damageLog = damageLog,
            let index = facility.facilityItem?.damageLogs?.firstIndex(where: {
            $0.damageLog?.lineNumber == lineNumber
        }) {
            facility.facilityItem?.damageLogs?[index] = damageLog
        }
        
        if let detail = detail,
            let index = facility.facilityItem?.inspectionDetails?.firstIndex(where: {
            $0.lineNumber == lineNumber
        }) {
            facility.facilityItem?.inspectionDetails?[index] = detail
        }

        if save {
            facility.synchronize()
        } else {
            facility.update()
        }
    }
    
    @objc func showFacirity() {
        //　処理なし
    }
    
    @objc func appendDeviceLog(_ params: Any?) {
        guard let params = params as? [String: Any] else {
            return
        }
        
        let timeStampType = (params["timeStampType"] as? NSNumber)?.intValue ??
            (params["timeStampType"] as? String).flatMap({ Int($0) })
        
        let timeCorrection = Setting.shared?.arInfo.timeCorrection ?? 0
        let timeStamp = Date().addingTimeInterval(TimeInterval(timeCorrection))
        
        DeviceLog.add(
            .init(deviceLogId:      UUID().uuidString,
                  facilitySpecId:   params["facilitySpecId"]    as? String,
                  inspectionId:     params["inspectionId"]      as? String,
                  damageLogId:      params["damageLogId"]       as? String,
                  lineNumber:       params["lineNumber"]        as? Int,
                  action:           params["action"]            as? String,
                  timeStampType:    timeStampType,
                  timeStamp:        timeStamp.string(.dateTime(.hyphen)))
        )
    }
}

// JSからの呼ばれる処理（戻り値あり）。JS、Androidソースを参照
extension JavaScriptManager {
    
    @objc func isEditMode() -> String {
        return NSNumber(value: editMode).stringValue
    }
    
    @objc func timeCorrection() -> String {
        if let timeCorrection = Setting.shared?.arInfo.timeCorrection {
            return "\(timeCorrection)"
        }
        return ""
    }

    @objc func dataFolder() -> String {
        return String(URL(fileURLWithPath: DataManager.webDataPath).absoluteString
        .replacingOccurrences(of: "file:///", with: "").dropLast())
    }

    @objc func facilityData() -> String {
        return jsonString(from: Facility.current?.facilityItem?.facility)
    }

    @objc func facilityMap() -> String {
        return jsonString(from: Facility.current?.jsMap)
    }

    @objc func facilityImages() -> String {
        return jsonString(from: Facility.current?.jsFacilityImages)
    }
    
    @objc func changeSelectedImgFacility(_ params: String?) -> String {
        let params = (params ?? "").components(separatedBy: ",")
        let imageFileId = params.first
        guard var facility = Facility.current,
            let selectedStatus = params.last.flatMap({ Int($0) }) else {
            return ""
        }
        
        if let index = facility.facilityItem?.images?.firstIndex(where: {
            $0.selectedStatus == selectedStatus
           }) {
            facility.facilityItem?.images?[index].selectedStatus = 0
        }
        
        if imageFileId != DataManager.dummyId,
            let index = facility.facilityItem?.images?.firstIndex(where: {
                $0.imageFileId == imageFileId
            }) {
                facility.facilityItem?.images?[index].selectedStatus = selectedStatus
        }
        facility.synchronize()
        return ""
    }
    
    @objc func inspectionData() -> String {
        return jsonString(from: Facility.current?.facilityItem)
    }
    
    @objc func damageLogData() -> String {
        guard let lineNumber = currentLineNumber else {
            return ""
        }
        
        let damageLog = Facility.current?.facilityItem?.damageLogs?.first(where: {
            $0.damageLog?.lineNumber == lineNumber
        }) ?? creatDamageLog(lineNumber: lineNumber)
        
        updateInspectionDeviceStatus(.inspecting, save: false, completed: false)
        
        return jsonString(from: damageLog)
    }

    @objc func specialNote() -> String {
        return jsonString(from: Setting.shared?.specialNote)
    }

    @objc func damageLogImages() -> String {
        if let lineNumber = currentLineNumber {
            return jsonString(from: Facility.current?.jsDamageLogImages(lineNumber: lineNumber))
        }
        return ""
    }

    @objc func changeSelectedImgDamageLof(_ params: String?) -> String {
        let params = (params ?? "").components(separatedBy: ",")
        let imageFileId = params.first
        guard let lineNumber = currentLineNumber,
            var damageLogs = Facility.current?.facilityItem?.damageLogs,
            let selectedStatus = params.last.flatMap({ Int($0) }) else {
            return ""
        }
        
        if let logIndex = damageLogs.firstIndex(where: {
            $0.damageLog?.lineNumber == lineNumber
        }), let imgIndex = damageLogs[logIndex].images?.firstIndex(where: {
            $0.selectedStatus == selectedStatus
        }) {
            damageLogs[logIndex].images?[imgIndex].selectedStatus = 0
        }
        
        if imageFileId != DataManager.dummyId,
        let logIndex = damageLogs.firstIndex(where: {
            $0.damageLog?.lineNumber == lineNumber
        }), let imgIndex = damageLogs[logIndex].images?.firstIndex(where: {
            $0.imageFileId == imageFileId
        }) {
            damageLogs[logIndex].images?[imgIndex].selectedStatus = selectedStatus
        }
        
        Facility.current?.facilityItem?.damageLogs = damageLogs
        Facility.current?.save()
        
        return ""
    }
}
