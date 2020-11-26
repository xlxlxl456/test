//
//  DeviceLog.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/09/01.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation

struct DeviceLog: JsonFile {
    
    static var fileName: String { return "DeviceLog.json" }
    
    private static var logCache = [Log]()
    
    var url:                URL?    //メモリ変数(JSONには存在しない)
    
    var threadId:           String?
    var businessId:         String?
    var businessNumber:     String?
    var businessName:       String?
    var deviceId:           String?
    var deviceIdStr:        String?
    var logs:               [Log]?
    
    private enum CodingKeys: String, CodingKey {
        case
        threadId            = "ThreadId",
        businessId          = "BusinessId",
        businessName        = "BusinessName",
        businessNumber      = "BusinessNumber",
        deviceId            = "DeviceId",
        deviceIdStr         = "DeviceIdStr",
        logs                = "Logs"
    }
    
    static func add(_ log: Log) {
        logCache.append(log)
    }
    
    // キャッシュをjsonフアィルに出力
    static func save() {
        var deviceLog = DeviceLog.load(fileName: Self.fileName) ?? DeviceLog()
        
        var logs = deviceLog.logs ?? []
        logs.append(contentsOf: logCache)
        
        deviceLog.logs = logs
        
        if deviceLog.save() {
            // キャッシュをクリア
            logCache.removeAll()
        }
    }
}

extension DeviceLog {
    
    struct Log: Codable {
        var deviceLogId:    String?
        var facilitySpecId: String?
        var inspectionId:   String?
        var damageLogId:    String?
        var lineNumber:     Int?
        var action:         String?
        var timeStampType:  Int?
        var timeStamp:      String?
        
        private enum CodingKeys: String, CodingKey {
            case
            deviceLogId          = "DeviceLogId",
            facilitySpecId       = "FacilitySpecId",
            inspectionId         = "InspectionId",
            damageLogId          = "DamageLogId",
            lineNumber           = "LineNumber",
            action               = "Action",
            timeStampType        = "TimeStampType",
            timeStamp            = "TimeStamp"
        }
    }
}
