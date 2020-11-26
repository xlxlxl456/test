//
//  CommonModel.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/09/01.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation

struct Inspection: Codable {
    var inspectionId:               String?
    var facilitySpecId:             String?
    var businessId:                 String?
    var businessNumber:             String?
    var facilityType:               String?
    var areaOffice:                 String?
    var office:                     String?
    var branchOffice:               String?
    var serialNumber:               String?
    var stanchionSolve:             String?
    var stanchionHealth:            String?
    var crossbeamSolve:             String?
    var crossbeamHealth:            String?
    var signAttachmentSolve:        String?
    var signAttachmentHealth:       String?
    var baseSolve:                  String?
    var baseHealth:                 String?
    var bracketSolve:               String?
    var bracketHealth:              String?
    var otherSolve:                 String?
    var otherHealth:                String?
    var facilityHealth:             String?
    var note:                       String?
    var noInspectedParts:           String?
    var inspectionPlan:             String?
    var noInspectedCause:           String?
    var inspectionManner:           String?
    var inspectionNote:             String?
    var inspectionNote1:            String?
    var inspectionNote2:            String?
    var inspectionNote3:            String?
    var inspectionNote4:            String?
    var deviceId:                   String?
    var deviceIdStr:                String?
    var inspectionDeviceDateSt:     String?
    var inspectionDeviceDateEnd:    String?
    var isDeleted:                  Bool?
    var creatorId:                  String?
    var registered:                 String?
    var editorId:                   String?
    var lastUpdated:                String?
    
    private enum CodingKeys: String, CodingKey {
        case
        inspectionId               = "InspectionId",
        facilitySpecId             = "FacilitySpecId",
        businessId                 = "BusinessId",
        businessNumber             = "BusinessNumber",
        facilityType               = "FacilityType",
        areaOffice                 = "AreaOffice",
        office                     = "Office",
        branchOffice               = "BranchOffice",
        serialNumber               = "SerialNumber",
        stanchionSolve             = "StanchionSolve",
        stanchionHealth            = "StanchionHealth",
        crossbeamSolve             = "CrossbeamSolve",
        crossbeamHealth            = "CrossbeamHealth",
        signAttachmentSolve        = "SignAttachmentSolve",
        signAttachmentHealth       = "SignAttachmentHealth",
        baseSolve                  = "BaseSolve",
        baseHealth                 = "BaseHealth",
        bracketSolve               = "BracketSolve",
        bracketHealth              = "BracketHealth",
        otherSolve                 = "OtherSolve",
        otherHealth                = "OtherHealth",
        facilityHealth             = "FacilityHealth",
        note                       = "Note",
        noInspectedParts           = "NoInspectedParts",
        inspectionPlan             = "InspectionPlan",
        noInspectedCause           = "NoInspectedCause",
        inspectionManner           = "InspectionManner",
        inspectionNote             = "InspectionNote",
        inspectionNote1            = "InspectionNote1",
        inspectionNote2            = "InspectionNote2",
        inspectionNote3            = "InspectionNote3",
        inspectionNote4            = "InspectionNote4",
        deviceId                   = "DeviceId",
        deviceIdStr                = "DeviceIdStr",
        inspectionDeviceDateSt     = "InspectionDeviceDateSt",
        inspectionDeviceDateEnd    = "InspectionDeviceDateEnd",
        isDeleted                  = "IsDeleted",
        creatorId                  = "CreatorId",
        registered                 = "Registered",
        editorId                   = "EditorId",
        lastUpdated                = "LastUpdated"
    }
    
    mutating func combine(_ another: Self) {
        another.inspectionId.flatMap({ self.inspectionId = $0 })
        another.facilitySpecId.flatMap({ self.facilitySpecId = $0 })
        another.businessId.flatMap({ self.businessId = $0 })
        another.businessNumber.flatMap({ self.businessNumber = $0 })
        another.facilityType.flatMap({ self.facilityType = $0 })
        another.areaOffice.flatMap({ self.areaOffice = $0 })
        another.office.flatMap({ self.office = $0 })
        another.branchOffice.flatMap({ self.branchOffice = $0 })
        another.serialNumber.flatMap({ self.serialNumber = $0 })
        another.stanchionSolve.flatMap({ self.stanchionSolve = $0 })
        another.stanchionHealth.flatMap({ self.stanchionHealth = $0 })
        another.crossbeamSolve.flatMap({ self.crossbeamSolve = $0 })
        another.crossbeamHealth.flatMap({ self.crossbeamHealth = $0 })
        another.signAttachmentSolve.flatMap({ self.signAttachmentSolve = $0 })
        another.signAttachmentHealth.flatMap({ self.signAttachmentHealth = $0 })
        another.baseSolve.flatMap({ self.baseSolve = $0 })
        another.baseHealth.flatMap({ self.baseHealth = $0 })
        another.bracketSolve.flatMap({ self.bracketSolve = $0 })
        another.bracketHealth.flatMap({ self.bracketHealth = $0 })
        another.otherSolve.flatMap({ self.otherSolve = $0 })
        another.otherHealth.flatMap({ self.otherHealth = $0 })
        another.facilityHealth.flatMap({ self.facilityHealth = $0 })
        another.note.flatMap({ self.note = $0 })
        another.noInspectedParts.flatMap({ self.noInspectedParts = $0 })
        another.inspectionPlan.flatMap({ self.inspectionPlan = $0 })
        another.noInspectedCause.flatMap({ self.noInspectedCause = $0 })
        another.inspectionManner.flatMap({ self.inspectionManner = $0 })
        another.inspectionNote.flatMap({ self.inspectionNote = $0 })
        another.inspectionNote1.flatMap({ self.inspectionNote1 = $0 })
        another.inspectionNote2.flatMap({ self.inspectionNote2 = $0 })
        another.inspectionNote3.flatMap({ self.inspectionNote3 = $0 })
        another.inspectionNote4.flatMap({ self.inspectionNote4 = $0 })
        another.deviceId.flatMap({ self.deviceId = $0 })
        another.deviceIdStr.flatMap({ self.deviceIdStr = $0 })
        another.inspectionDeviceDateSt.flatMap({ self.inspectionDeviceDateSt = $0 })
        another.inspectionDeviceDateEnd.flatMap({ self.inspectionDeviceDateEnd = $0 })
        another.isDeleted.flatMap({ self.isDeleted = $0 })
        another.creatorId.flatMap({ self.creatorId = $0 })
        another.registered.flatMap({ self.registered = $0 })
        another.editorId.flatMap({ self.editorId = $0 })
        another.lastUpdated.flatMap({ self.lastUpdated = $0 })
    }
}

struct InspectionDetail: Codable {
    var applicable:                 String?
    var areaOffice:                 String?
    var branchOffice:               String?
    var businessId:                 String?
    var businessNumber:             String?
    var inspectionStatus:           String?
    var steelCrackBefore:           String?
    var steelCrackAfter:            String?
    var steelLooseBefore:           String?
    var steelLooseAfter:            String?
    var steelBreakBefore:           String?
    var steelBreakAfter:            String?
    var steelCorrosionBefore:       String?
    var steelCorrosionAfter:        String?
    var steelDeformationBefore:     String?
    var steelDeformationAfter:      String?
    var concreteCrackBefore:        String?
    var concreteCrackAfter:         String?
    var concretePeelingBefore:      String?
    var concretePeelingAfter:       String?
    var commonWaterBefore:          String?
    var commonWaterAfter:           String?
    var commonOtherBefore:          String?
    var commonOtherAfter:           String?
    var lineNumber:                 Int?
    var creatorId:                  String?
    var deviceId:                   String?
    var deviceIdStr:                String?
    var editorId:                   String?
    var facilitySpecId:             String?
    var facilityType:               String?
    var inspectionDetailId:         String?
    var inspectionId:               String?
    var inspectionPoint:            String?
    var inspectionPointMark:        String?
    var isDeleted:                  Bool?
    var lastUpdated:                String?
    var office:                     String?
    var registered:                 String?
    var serialNumber:               String?
    
    enum CodingKeys: String, CodingKey {
       case
        applicable                  = "Applicable",
        areaOffice                  = "AreaOffice",
        branchOffice                = "BranchOffice",
        businessId                  = "BusinessId",
        businessNumber              = "BusinessNumber",
        inspectionStatus            = "InspectionStatus",
        steelCrackBefore            = "SteelCrackBefore",
        steelCrackAfter             = "SteelCrackAfter",
        steelLooseBefore            = "SteelLooseBefore",
        steelLooseAfter             = "SteelLooseAfter",
        steelBreakBefore            = "SteelBreakBefore",
        steelBreakAfter             = "SteelBreakAfter",
        steelCorrosionBefore        = "SteelCorrosionBefore",
        steelCorrosionAfter         = "SteelCorrosionAfter",
        steelDeformationBefore      = "SteelDeformationBefore",
        steelDeformationAfter       = "SteelDeformationAfter",
        concreteCrackBefore         = "ConcreteCrackBefore",
        concreteCrackAfter          = "ConcreteCrackAfter",
        concretePeelingBefore       = "ConcretePeelingBefore",
        concretePeelingAfter        = "ConcretePeelingAfter",
        commonWaterBefore           = "CommonWaterBefore",
        commonWaterAfter            = "CommonWaterAfter",
        commonOtherBefore           = "CommonOtherBefore",
        commonOtherAfter            = "CommonOtherAfter",
        lineNumber                  = "LineNumber",
        creatorId                   = "CreatorId",
        deviceId                    = "DeviceId",
        deviceIdStr                 = "DeviceIdStr",
        editorId                    = "EditorId",
        facilitySpecId              = "FacilitySpecId",
        facilityType                = "FacilityType",
        inspectionDetailId          = "InspectionDetailId",
        inspectionId                = "InspectionId",
        inspectionPoint             = "InspectionPoint",
        inspectionPointMark         = "InspectionPointMark",
        isDeleted                   = "IsDeleted",
        lastUpdated                 = "LastUpdated",
        office                      = "Office",
        registered                  = "Registered",
        serialNumber                = "SerialNumber"
   }
    
    mutating func combine(_ another: Self) {
        another.applicable.flatMap({ self.applicable = $0 })
        another.areaOffice.flatMap({ self.areaOffice = $0 })
        another.branchOffice.flatMap({ self.branchOffice = $0 })
        another.businessId.flatMap({ self.businessId = $0 })
        another.businessNumber.flatMap({ self.businessNumber = $0 })
        another.inspectionStatus.flatMap({ self.inspectionStatus = $0 })
        another.steelCrackBefore.flatMap({ self.steelCrackBefore = $0 })
        another.steelCrackAfter.flatMap({ self.steelCrackAfter = $0 })
        another.steelLooseBefore.flatMap({ self.steelLooseBefore = $0 })
        another.steelLooseAfter.flatMap({ self.steelLooseAfter = $0 })
        another.steelBreakBefore.flatMap({ self.steelBreakBefore = $0 })
        another.steelBreakAfter.flatMap({ self.steelBreakAfter = $0 })
        another.steelCorrosionBefore.flatMap({ self.steelCorrosionBefore = $0 })
        another.steelCorrosionAfter.flatMap({ self.steelCorrosionAfter = $0 })
        another.steelDeformationBefore.flatMap({ self.steelDeformationBefore = $0 })
        another.steelDeformationAfter.flatMap({ self.steelDeformationAfter = $0 })
        another.concreteCrackBefore.flatMap({ self.concreteCrackBefore = $0 })
        another.concreteCrackAfter.flatMap({ self.concreteCrackAfter = $0 })
        another.concretePeelingBefore.flatMap({ self.concretePeelingBefore = $0 })
        another.concretePeelingAfter.flatMap({ self.concretePeelingAfter = $0 })
        another.commonWaterBefore.flatMap({ self.commonWaterBefore = $0 })
        another.commonWaterAfter.flatMap({ self.commonWaterAfter = $0 })
        another.commonOtherBefore.flatMap({ self.commonOtherBefore = $0 })
        another.commonOtherAfter.flatMap({ self.commonOtherAfter = $0 })
        another.lineNumber.flatMap({ self.lineNumber = $0 })
        another.creatorId.flatMap({ self.creatorId = $0 })
        another.deviceId.flatMap({ self.deviceId = $0 })
        another.deviceIdStr.flatMap({ self.deviceIdStr = $0 })
        another.editorId.flatMap({ self.editorId = $0 })
        another.facilitySpecId.flatMap({ self.facilitySpecId = $0 })
        another.facilityType.flatMap({ self.facilityType = $0 })
        another.inspectionDetailId.flatMap({ self.inspectionDetailId = $0 })
        another.inspectionId.flatMap({ self.inspectionId = $0 })
        another.inspectionPoint.flatMap({ self.inspectionPoint = $0 })
        another.inspectionPointMark.flatMap({ self.inspectionPointMark = $0 })
        another.isDeleted.flatMap({ self.isDeleted = $0 })
        another.lastUpdated.flatMap({ self.lastUpdated = $0 })
        another.office.flatMap({ self.office = $0 })
        another.registered.flatMap({ self.registered = $0 })
        another.serialNumber.flatMap({ self.serialNumber = $0 })
    }
    
    mutating func combine(_ damageLog: DamageLog.Log) {
        damageLog.areaOffice.flatMap({ self.areaOffice = $0 })
        damageLog.branchOffice.flatMap({ self.branchOffice = $0 })
        damageLog.businessId.flatMap({ self.businessId = $0 })
        damageLog.businessNumber.flatMap({ self.businessNumber = $0 })
        damageLog.steelCrackBefore.flatMap({ self.steelCrackBefore = $0 })
        damageLog.steelCrackAfter.flatMap({ self.steelCrackAfter = $0 })
        damageLog.steelLooseBefore.flatMap({ self.steelLooseBefore = $0 })
        damageLog.steelLooseAfter.flatMap({ self.steelLooseAfter = $0 })
        damageLog.steelBreakBefore.flatMap({ self.steelBreakBefore = $0 })
        damageLog.steelBreakAfter.flatMap({ self.steelBreakAfter = $0 })
        damageLog.steelCorrosionBefore.flatMap({ self.steelCorrosionBefore = $0 })
        damageLog.steelCorrosionAfter.flatMap({ self.steelCorrosionAfter = $0 })
        damageLog.steelDeformationBefore.flatMap({ self.steelDeformationBefore = $0 })
        damageLog.steelDeformationAfter.flatMap({ self.steelDeformationAfter = $0 })
        damageLog.concreteCrackBefore.flatMap({ self.concreteCrackBefore = $0 })
        damageLog.concreteCrackAfter.flatMap({ self.concreteCrackAfter = $0 })
        damageLog.concretePeelingBefore.flatMap({ self.concretePeelingBefore = $0 })
        damageLog.concretePeelingAfter.flatMap({ self.concretePeelingAfter = $0 })
        damageLog.commonWaterBefore.flatMap({ self.commonWaterBefore = $0 })
        damageLog.commonWaterAfter.flatMap({ self.commonWaterAfter = $0 })
        damageLog.commonOtherBefore.flatMap({ self.commonOtherBefore = $0 })
        damageLog.commonOtherAfter.flatMap({ self.commonOtherAfter = $0 })
        damageLog.lineNumber.flatMap({ self.lineNumber = $0 })
        damageLog.creatorId.flatMap({ self.creatorId = $0 })
        damageLog.deviceId.flatMap({ self.deviceId = $0 })
        damageLog.deviceIdStr.flatMap({ self.deviceIdStr = $0 })
        damageLog.editorId.flatMap({ self.editorId = $0 })
        damageLog.facilitySpecId.flatMap({ self.facilitySpecId = $0 })
        damageLog.facilityType.flatMap({ self.facilityType = $0 })
        damageLog.inspectionId.flatMap({ self.inspectionId = $0 })
        damageLog.inspectionPoint.flatMap({ self.inspectionPoint = $0 })
        damageLog.inspectionPointMark.flatMap({ self.inspectionPointMark = $0 })
        damageLog.isDeleted.flatMap({ self.isDeleted = $0 })
        damageLog.lastUpdated.flatMap({ self.lastUpdated = $0 })
        damageLog.office.flatMap({ self.office = $0 })
        damageLog.registered.flatMap({ self.registered = $0 })
        damageLog.serialNumber.flatMap({ self.serialNumber = $0 })
    }
}

struct DamageLog: Codable {
    var damageLog:                  Log?
    var images:                     [Image]?
    
    private enum CodingKeys: String, CodingKey {
        case
        damageLog                   = "DamageLog",
        images                      = "Images"
    }
    
    struct Log: Codable {
        var damageLogId:                String?
        var inspectionPoint:            String?
        var inspectionPointMark:        String?
        var inspectionId:               String?
        var facilitySpecId:             String?
        var businessId:                 String?
        var lineNumber:                 Int?
        var businessNumber:             String?
        var facilityType:               String?
        var areaOffice:                 String?
        var office:                     String?
        var branchOffice:               String?
        var serialNumber:               String?
        var steelCrackBefore:           String?
        var steelCrackAfter:            String?
        var steelLooseBefore:           String?
        var steelLooseAfter:            String?
        var steelBreakBefore:           String?
        var steelBreakAfter:            String?
        var steelCorrosionBefore:       String?
        var steelCorrosionAfter:        String?
        var steelDeformationBefore:     String?
        var steelDeformationAfter:      String?
        var concreteCrackBefore:        String?
        var concreteCrackAfter:         String?
        var concretePeelingBefore:      String?
        var concretePeelingAfter:       String?
        var commonWaterBefore:          String?
        var commonWaterAfter:           String?
        var commonOtherBefore:          String?
        var commonOtherAfter:           String?
        var inspectionNote:             String?
        var inspectionPlan:             String?
        var noInspectedCause:           String?
        var inspectionManner:           String?
        var note:                       String?
        var note1:                      String?
        var note2:                      String?
        var note3:                      String?
        var note4:                      String?
        var deviceId:                   String?
        var deviceIdStr:                String?
        var inspectionDeviceDateSt:     String?
        var inspectionDeviceDateEnd:    String?
        var pattern:                    Int?
        var isTemporary:                Bool?
        var isDeleted:                  Bool?
        var creatorId:                  String?
        var registered:                 String?
        var editorId:                   String?
        var lastUpdated:                String?
        
        private enum CodingKeys: String, CodingKey {
            case
            damageLogId                = "DamageLogId",
            inspectionPoint            = "InspectionPoint",
            inspectionPointMark        = "InspectionPointMark",
            inspectionId               = "InspectionId",
            facilitySpecId             = "FacilitySpecId",
            businessId                 = "BusinessId",
            lineNumber                 = "LineNumber",
            businessNumber             = "BusinessNumber",
            facilityType               = "FacilityType",
            areaOffice                 = "AreaOffice",
            office                     = "Office",
            branchOffice               = "BranchOffice",
            serialNumber               = "SerialNumber",
            steelCrackBefore           = "SteelCrackBefore",
            steelCrackAfter            = "SteelCrackAfter",
            steelLooseBefore           = "SteelLooseBefore",
            steelLooseAfter            = "SteelLooseAfter",
            steelBreakBefore           = "SteelBreakBefore",
            steelBreakAfter            = "SteelBreakAfter",
            steelCorrosionBefore       = "SteelCorrosionBefore",
            steelCorrosionAfter        = "SteelCorrosionAfter",
            steelDeformationBefore     = "SteelDeformationBefore",
            steelDeformationAfter      = "SteelDeformationAfter",
            concreteCrackBefore        = "ConcreteCrackBefore",
            concreteCrackAfter         = "ConcreteCrackAfter",
            concretePeelingBefore      = "ConcretePeelingBefore",
            concretePeelingAfter       = "ConcretePeelingAfter",
            commonWaterBefore          = "CommonWaterBefore",
            commonWaterAfter           = "CommonWaterAfter",
            commonOtherBefore          = "CommonOtherBefore",
            commonOtherAfter           = "CommonOtherAfter",
            inspectionNote             = "InspectionNote",
            inspectionPlan             = "InspectionPlan",
            noInspectedCause           = "NoInspectedCause",
            inspectionManner           = "InspectionManner",
            note                       = "Note",
            note1                      = "Note1",
            note2                      = "Note2",
            note3                      = "Note3",
            note4                      = "Note4",
            deviceId                   = "DeviceId",
            deviceIdStr                = "DeviceIdStr",
            inspectionDeviceDateSt     = "InspectionDeviceDateSt",
            inspectionDeviceDateEnd    = "InspectionDeviceDateEnd",
            pattern                    = "Pattern",
            isTemporary                = "IsTemporary",
            isDeleted                  = "IsDeleted",
            creatorId                  = "CreatorId",
            registered                 = "Registered",
            editorId                   = "EditorId",
            lastUpdated                = "LastUpdated"
        }
        
        mutating func combine(_ another: Self) {
            another.damageLogId.flatMap({ self.damageLogId = $0 })
            another.inspectionPoint.flatMap({ self.inspectionPoint = $0 })
            another.inspectionPointMark.flatMap({ self.inspectionPointMark = $0 })
            another.inspectionId.flatMap({ self.inspectionId = $0 })
            another.facilitySpecId.flatMap({ self.facilitySpecId = $0 })
            another.businessId.flatMap({ self.businessId = $0 })
            another.lineNumber.flatMap({ self.lineNumber = $0 })
            another.businessNumber.flatMap({ self.businessNumber = $0 })
            another.facilityType.flatMap({ self.facilityType = $0 })
            another.areaOffice.flatMap({ self.areaOffice = $0 })
            another.office.flatMap({ self.office = $0 })
            another.branchOffice.flatMap({ self.branchOffice = $0 })
            another.serialNumber.flatMap({ self.serialNumber = $0 })
            another.steelCrackBefore.flatMap({ self.steelCrackBefore = $0 })
            another.steelCrackAfter.flatMap({ self.steelCrackAfter = $0 })
            another.steelLooseBefore.flatMap({ self.steelLooseBefore = $0 })
            another.steelLooseAfter.flatMap({ self.steelLooseAfter = $0 })
            another.steelBreakBefore.flatMap({ self.steelBreakBefore = $0 })
            another.steelBreakAfter.flatMap({ self.steelBreakAfter = $0 })
            another.steelCorrosionBefore.flatMap({ self.steelCorrosionBefore = $0 })
            another.steelCorrosionAfter.flatMap({ self.steelCorrosionAfter = $0 })
            another.steelDeformationBefore.flatMap({ self.steelDeformationBefore = $0 })
            another.steelDeformationAfter.flatMap({ self.steelDeformationAfter = $0 })
            another.concreteCrackBefore.flatMap({ self.concreteCrackBefore = $0 })
            another.concreteCrackAfter.flatMap({ self.concreteCrackAfter = $0 })
            another.concretePeelingBefore.flatMap({ self.concretePeelingBefore = $0 })
            another.concretePeelingAfter.flatMap({ self.concretePeelingAfter = $0 })
            another.commonWaterBefore.flatMap({ self.commonWaterBefore = $0 })
            another.commonWaterAfter.flatMap({ self.commonWaterAfter = $0 })
            another.commonOtherBefore.flatMap({ self.commonOtherBefore = $0 })
            another.commonOtherAfter.flatMap({ self.commonOtherAfter = $0 })
            another.inspectionNote.flatMap({ self.inspectionNote = $0 })
            another.inspectionPlan.flatMap({ self.inspectionPlan = $0 })
            another.noInspectedCause.flatMap({ self.noInspectedCause = $0 })
            another.inspectionManner.flatMap({ self.inspectionManner = $0 })
            another.note.flatMap({ self.note = $0 })
            another.note1.flatMap({ self.note1 = $0 })
            another.note2.flatMap({ self.note2 = $0 })
            another.note3.flatMap({ self.note3 = $0 })
            another.note4.flatMap({ self.note4 = $0 })
            another.deviceId.flatMap({ self.deviceId = $0 })
            another.deviceIdStr.flatMap({ self.deviceIdStr = $0 })
            another.inspectionDeviceDateSt.flatMap({ self.inspectionDeviceDateSt = $0 })
            another.inspectionDeviceDateEnd.flatMap({ self.inspectionDeviceDateEnd = $0 })
            another.pattern.flatMap({ self.pattern = $0 })
            another.isTemporary.flatMap({ self.isTemporary = $0 })
            another.isDeleted.flatMap({ self.isDeleted = $0 })
            another.creatorId.flatMap({ self.creatorId = $0 })
            another.registered.flatMap({ self.registered = $0 })
            another.editorId.flatMap({ self.editorId = $0 })
            another.lastUpdated.flatMap({ self.lastUpdated = $0 })
        }
        
        mutating func combine(_ detail: InspectionDetail) {
            detail.inspectionPoint.flatMap({ self.inspectionPoint = $0 })
            detail.inspectionPointMark.flatMap({ self.inspectionPointMark = $0 })
            detail.inspectionId.flatMap({ self.inspectionId = $0 })
            detail.facilitySpecId.flatMap({ self.facilitySpecId = $0 })
            detail.businessId.flatMap({ self.businessId = $0 })
            detail.lineNumber.flatMap({ self.lineNumber = $0 })
            detail.businessNumber.flatMap({ self.businessNumber = $0 })
            detail.facilityType.flatMap({ self.facilityType = $0 })
            detail.areaOffice.flatMap({ self.areaOffice = $0 })
            detail.office.flatMap({ self.office = $0 })
            detail.branchOffice.flatMap({ self.branchOffice = $0 })
            detail.serialNumber.flatMap({ self.serialNumber = $0 })
            detail.steelCrackBefore.flatMap({ self.steelCrackBefore = $0 })
            detail.steelCrackAfter.flatMap({ self.steelCrackAfter = $0 })
            detail.steelLooseBefore.flatMap({ self.steelLooseBefore = $0 })
            detail.steelLooseAfter.flatMap({ self.steelLooseAfter = $0 })
            detail.steelBreakBefore.flatMap({ self.steelBreakBefore = $0 })
            detail.steelBreakAfter.flatMap({ self.steelBreakAfter = $0 })
            detail.steelCorrosionBefore.flatMap({ self.steelCorrosionBefore = $0 })
            detail.steelCorrosionAfter.flatMap({ self.steelCorrosionAfter = $0 })
            detail.steelDeformationBefore.flatMap({ self.steelDeformationBefore = $0 })
            detail.steelDeformationAfter.flatMap({ self.steelDeformationAfter = $0 })
            detail.concreteCrackBefore.flatMap({ self.concreteCrackBefore = $0 })
            detail.concreteCrackAfter.flatMap({ self.concreteCrackAfter = $0 })
            detail.concretePeelingBefore.flatMap({ self.concretePeelingBefore = $0 })
            detail.concretePeelingAfter.flatMap({ self.concretePeelingAfter = $0 })
            detail.commonWaterBefore.flatMap({ self.commonWaterBefore = $0 })
            detail.commonWaterAfter.flatMap({ self.commonWaterAfter = $0 })
            detail.commonOtherBefore.flatMap({ self.commonOtherBefore = $0 })
            detail.commonOtherAfter.flatMap({ self.commonOtherAfter = $0 })
            detail.deviceId.flatMap({ self.deviceId = $0 })
            detail.deviceIdStr.flatMap({ self.deviceIdStr = $0 })
            detail.isDeleted.flatMap({ self.isDeleted = $0 })
            detail.creatorId.flatMap({ self.creatorId = $0 })
            detail.registered.flatMap({ self.registered = $0 })
            detail.editorId.flatMap({ self.editorId = $0 })
            detail.lastUpdated.flatMap({ self.lastUpdated = $0 })
        }
    }
}

struct Image: Codable {
    var imageFileId:    String?
    var facilitySpecId: String?
    var parentId:       String?
    var caption:        String?
    var fileName:       String?
    var selectedStatus: Int?
    var timeStamp:      String?
    var individualId:   String?
    var origin:         Int?
    var info:           String?
    
    private enum CodingKeys: String, CodingKey {
        case
        imageFileId                = "ImageFileId",
        facilitySpecId             = "FacilitySpecId",
        parentId                   = "ParentId",
        caption                    = "Caption",
        fileName,
        selectedStatus             = "SelectedStatus",
        timeStamp                  = "TimeStamp",
        individualId               = "IndividualId",
        origin                     = "Origin",
        info                       = "Info"
    }
}
