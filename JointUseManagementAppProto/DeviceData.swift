//
//  DeviceData.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2019/12/31.
//  Copyright © 2019 Furukawa Electric Co., Ltd. All rights reserved.
//

import SwiftUI

class CompletionModel: Codable {
    var OfficeID: UUID?
    var OfficeName: String?
    var WorkID: UUID?
    var WorkNo: String?
    var WorkName: String?
    var WorkDate: String?
    var WorkState: Int?
    var WorkStateStr: String?
    var WorkBeforeDate: String?
    var WorkAfterDate: String?
    var JointUseModels: [JointUseModel]

    struct JointUseModel: Codable {
        var Number: Int?
        var PoleID: UUID?
        var PoleNumber: String?
        var TechReview: String?
        var BeforeModelItems: BeforeModelItems
        var AfterModelItems: AfterModelItems
        var TechReviewResult: TechReviewResult
        
        struct BeforeModelItems: Codable {
            // 1. 配電設備の施設状況
            var ObjectType: String?
            var ObjectLength: String?
            var ObjectStrength: String?
            var ObjectHighVoltLine: String?
            var ObjectLowVoltLine: String?
            var ObjectTransformer: String?
            var ObjectSwitch: String?
            // 2. 共架施設状況と希望位置
            var JointUseCompany1: String?
            var JointUseCompany2: String?
            var JointUseCompany3: String?
            var JointUseCompany4: String?
            var JointUseCompany5: String?
            var JointUseCompany6: String?
            var JointUseCompany7: String?
            var Single: String?
            var SingleTargetS: String?
            var SingleTargetE: String?
            var Bundling: String?
            var BudlingTarget: String?
            var BudlingCompany: String?
            // 3. 共架位置と測定結果
            var BeforeDistancePower: String?
            var BeforeDistanceLineH: String?
            var BeforeDistanceLineL: String?
            var BeforeGroundHeight: String?
            // 4. 施設形態
            var ComSrcBeforeItems: [ComSrcBeforeItem]
            // 5. 施設形態
            var MetalFitting: String?
            var MetalFittingText: String?
            // 6. 開閉器操作紐の移設
            var Switch: String?
            // 特記事項
            var Remark: String?
            // 表示する写真
            var PhotoDate: String?
            var PhotoNumber: Int?
            var PhotoSrc: String?
            var PhotoName: String?
            var Photos: [Photo]
        }
        struct ComSrcBeforeItem: Codable {
            // 4. 施設形態
            var SourceNumber: Int?
            var FacilityType: String?
            var FacilityNumber: String?
            var FacilitySpan: String?
            var FacilityStatus: String?
            var SourceAngleBefore: String?
            var OuterDiameterSuspension: String?
            var OuterDiameterLine: String?
            var OwnWeightSuspention: String?
            var OwnWeightLine: String?
        }
        struct AfterModelItems: Codable {
            // 3. 共架位置と測定結果
            var AfterDistancePower: String?
            var AfterDistanceLineH: String?
            var AfterDistanceLineL: String?
            var AfterGroundHeight: String?
            // 4. 施設形態
            var ComSrcAfterItems: [ComSrcAfterItem]
            // 表示する写真
            var PhotoDate: String?
            var PhotoNumber: Int?
            var PhotoSrc: String?
            var PhotoName: String?
            // 撮影した写真たち
            var Photos: [Photo]
        }
        struct ComSrcAfterItem: Codable {
            // 4. 施設形態
            var SourceNumber: Int?
            var LineLength: String?
            var SpanDistanceLineL: String?
            var SpanDistanceLinePower: String?
            var SourceAngleAfter: String?
        }
        struct TechReviewResult: Codable {
            // 技術検討結果  ------------------------------
            var OfficeDate: String?
            var OfficeJointPropriety: String?
            var OfficeRepairPropriety: String?
            var FieldData: String?
            var FieldJointPropriety: String?
            var FieldRepairPropriety: String?
            // 共架可の条件
            var JointTerms1: Bool
            var JointTerms2: Bool
            var JointTerms3: Bool
            var JointTerms4: Bool
            var JointTerms5: Bool
            var JointTerms6: Bool
            var JointTerms7: Bool
            var JointTermsWeight: String?
            var JointTermsExtention: String?
            var JointTermsRemark: String?
            var ImpossibleReason: String?
            // 改修工事内容
            var RepairContents1: Bool
            var RepairContents2: Bool
            var RepairContents3: Bool
            var RepairContents4: Bool
            var RepairContents5: Bool
            var RepairContents6: Bool
            var RepairContents7: Bool
            var RepairContents8: Bool
            var RepairRemark: String?
            var RepairDate: String?
            // 施設確認 ------------------------------
            var AfterCompletionDate: String?
            var AfterCheckResult: String?
            var AfterNote: String?
            var AfterDeadine: String?

            var InadequateDate: String?
            var InadequateResult: String?
            var InadequateNote: String?
            var InadequateDeadline: String?
        }
    }
    struct Photo: Codable {
        // 撮影日時
        var PhotoDate: String?
        // 写真番号（連番）
        var PhotoNumber: Int?
        // 写真のファイルパス
        var PhotoSrc: String?
        // 写真のファイル名
        var PhotoName: String?
    }
}
