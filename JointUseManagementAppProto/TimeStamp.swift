//
//  TimeStamp.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2019/12/31.
//  Copyright © 2019 Furukawa Electric Co., Ltd. All rights reserved.
//

import SwiftUI

class TimeStamp: Codable {
    var WorkID: UUID?
    var WorkNo: String?
    var WorkName: String?
    var WorkDate: String?
    var WorkState: Int32?
    var WorkStateStr: String?
    var Logs: [TimeStampModelItems]
    
    struct TimeStampModelItems: Codable {
        var PoleID: UUID?
        var PoleNum: Int?
        var PoleNumber: String?
        var Action: String?
        var TimeStampType: Int?
        var TimeStamp: String?
    }
}

