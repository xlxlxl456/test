//
//  Setting.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/14.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

struct Setting: MasterFile {
    static var shared: Setting? = Setting.load()
    static var fileName: String { return "setting.json" }
    var url: URL?   //メモリ変数(JSONには存在しない)
    
    var threadId:               String?
    var businessId:             String?
    var businessNumber:         String?
    var businessName:           String?
    var deviceId:               String?
    var deviceIdStr:            String?
    var versionInfoT:           String?
    var versionInfoS:           String?
    var specialNote:            SpecialNote?
    var arInfo:                 ARInfo = ARInfo()
    var users:                  [User]?
    var newFacility:            Facility.Item.Facility?
    var newInspection:          Inspection?
    var newDamageLog:           DamageLog?
    var newInspectionDetails:   [InspectionDetail]?
    var newImageFileInfo:       Image?
    
    private enum CodingKeys: String, CodingKey {
        case
        threadId                = "ThreadId",
        businessId              = "BusinessId",
        businessNumber          = "BusinessNumber",
        businessName            = "BusinessName",
        deviceId                = "DeviceId",
        deviceIdStr             = "DeviceIdStr",
        versionInfoT            = "VersionInfoT",
        versionInfoS            = "VersionInfoS",
        specialNote             = "SpecialNote",
        users                   = "Users",
        newFacility,
        newInspection,
        newDamageLog,
        newInspectionDetails,
        newImageFileInfo,
        arInfo                  = "ARInfo"
    }
}

extension Setting {
    
    struct SpecialNote: Codable {
        var categories:         [category]?
        var categoriesLight:    [category]?
        
        struct category: Codable {
            var categoryName:       String?
            var specialNoticeType:  Int?
            var items:              [Item]?
            
            private enum CodingKeys: String, CodingKey {
                case categoryName, specialNoticeType = "SpecialNoticeType", items
            }
            
            struct Item: Codable {
                var textValue:      String?
                var displayOrder:   Int?
            }
        }
    }
    
    struct ARInfo: Codable {
        var arId:               String?
        var sma:                Int = 10
        var guide:              Int = 0
        var gpsLog:             Int = 0
        var preview:            Int = 0
        var autoFocus:          Int = 0
        var gpsInfo:            Int = 0
        var markerSize:         Double = 0.8
        var markerColorBefore:  MarkerColor = .red
        var markerColorAfter:   MarkerColor = .cyan
        var alphaLevel:         Int = 5
        var dstAlpha:           Int = 0
        var markerType:         MarkerType = .rectangle
        var showFilter:         Int = 150
        var maskL:              Int = 75
        var maskR:              Int = 75
        var isDeleted:          Bool = false
        var creatorId:          String?
        var registered:         String?
        var editorId:           String?
        var lastUpdated:        String?
        
        private enum CodingKeys: String, CodingKey {
            case
            arId                = "ARId",
            sma                 = "SMA",
            guide               = "Guide",
            gpsLog              = "GPSLog",
            preview             = "Preview",
            autoFocus           = "AutoFocus",
            gpsInfo             = "GPSInfo",
            markerSize          = "MarkerSize",
            markerColorBefore   = "MarkerColorBefore",
            markerColorAfter    = "MarkerColorAfter",
            alphaLevel,
            dstAlpha,
            markerType          = "makerType",
            showFilter,
            maskL,
            maskR,
            isDeleted           = "IsDeleted",
            creatorId           = "CreatorId",
            registered          = "Registered",
            editorId            = "EditorId",
            lastUpdated         = "LastUpdated"
        }
        
        // 手動でデコード
        // ・Androidで入力制限のない項目に対して、値を入力制限範囲内に調整
        // ・キャストできないenumが存在する場合、デフォルト値で設定
        init(from decoder: Decoder) throws {
            guard let values = try? decoder.container(keyedBy: CodingKeys.self) else {
                return
            }
            
            arId = try? values.decode(String.self, forKey: .arId)
            
            if let sma = try? values.decode(Int.self, forKey: .sma) {
                self.sma = InputLimit.sma.limit(sma)
            }
            
            if let guide = try? values.decode(Int.self, forKey: .guide) {
                self.guide = guide
            }
            
            if let gpsLog = try? values.decode(Int.self, forKey: .gpsLog) {
                self.gpsLog = gpsLog
            }
            
            if let preview = try? values.decode(Int.self, forKey: .preview) {
                self.preview = preview
            }
            
            if let autoFocus = try? values.decode(Int.self, forKey: .autoFocus) {
                self.autoFocus = autoFocus
            }
            
            if let gpsInfo = try? values.decode(Int.self, forKey: .gpsInfo) {
                self.gpsInfo = gpsInfo
            }
            
            if let markerSize = try? values.decode(Double.self, forKey: .markerSize) {
                self.markerSize = InputLimit.markerSize.limit(markerSize)
            }
            
            if let markerColorBefore = try? values.decode(MarkerColor.self, forKey: .markerColorBefore) {
                self.markerColorBefore = markerColorBefore
            }
            
            if let markerColorAfter = try? values.decode(MarkerColor.self, forKey: .markerColorAfter) {
                self.markerColorAfter = markerColorAfter
            }
            
            if let alphaLevel = try? values.decode(Int.self, forKey: .alphaLevel) {
                self.alphaLevel = InputLimit.alphaLevel.limit(alphaLevel)
            }
            
            if let dstAlpha = try? values.decode(Int.self, forKey: .dstAlpha) {
                self.dstAlpha = dstAlpha
            }
            
            if let markerType = try? values.decode(MarkerType.self, forKey: .markerType) {
                self.markerType = markerType
            }
            
            if let showFilter = try? values.decode(Int.self, forKey: .showFilter) {
                self.showFilter = InputLimit.showFilter.limit(showFilter)
            }
            
            if let maskL = try? values.decode(Int.self, forKey: .maskL) {
                self.maskL = InputLimit.maskL.limit(maskL)
            }
            
            if let maskR = try? values.decode(Int.self, forKey: .maskR) {
                self.maskR = InputLimit.maskR.limit(maskR)
            }
            
            if let isDeleted = try? values.decode(Bool.self, forKey: .isDeleted) {
                self.isDeleted = isDeleted
            }
            
            if let creatorId = try? values.decode(String.self, forKey: .creatorId) {
                self.creatorId = creatorId
            }
            
            if let registered = try? values.decode(String.self, forKey: .registered) {
                self.registered = registered
            }
            
            if let editorId = try? values.decode(String.self, forKey: .editorId) {
                self.editorId = editorId
            }
            
            if let lastUpdated = try? values.decode(String.self, forKey: .lastUpdated) {
                self.lastUpdated = lastUpdated
            }
        }
        
        init() {}
        
        enum MarkerType: Int, Codable {
            case none, cricle, rectangle
        }
        
        enum MarkerColor: String, Codable {
            case red = "0", green = "1", cyan = "2"
            
            var color: UIColor {
                switch self {
                case .red:      return .red
                case .green:    return .green
                case .cyan:     return .cyan
                }
            }
        }
        
        enum InputLimit {
            case timeCorrection, sma, markerSize, alphaLevel, showFilter, maskL, maskR

            var range: ClosedRange<Double> {
                switch self {
                case .timeCorrection:   return -59...59
                case .sma:              return 1...10
                case .markerSize:       return 0.1...2
                case .alphaLevel:       return 0...10
                case .showFilter:       return 10...5000
                case .maskL, .maskR:    return 0...90
                }
            }
            
            func limit(_ input: Double) -> Double {
                return min(range.upperBound, max(range.lowerBound, input))
            }
            
            func limit(_ input: Int) -> Int {
                return Int(limit(Double(input)))
            }
        }
        
        var timeCorrection = 0  //メモリ変数(JSONには存在しない)
    }
    
    struct User: Codable {
        //未使用
    }
}
