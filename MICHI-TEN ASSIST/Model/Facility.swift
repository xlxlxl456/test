//
//  Facility.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/07/17.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation

struct Facility: JsonFile {
    
    static var current:  Self?
    
    static func load(serialNumber: String) -> Facility? {
        let url = URL(fileURLWithPath: DataManager.rootPath)
            .appendingPathComponent("Facilities")
            .appendingPathComponent(serialNumber)
            .appendingPathComponent("facility.json")
        return load(url: url)
    }
    
    static func loadCurrent(serialNumber: String) {
        current = load(serialNumber: serialNumber)
    }
    
    var url: URL?   //メモリ変数(JSONには存在しない)
    
    var businessId:     String?
    var businessName:   String?
    var businessNumber: String?
    var facilityItem:   Item?
    var threadId:       String?
    var versionInfoS:   String?
    var versionInfoT:   String?
    
    private enum CodingKeys: String, CodingKey {
        case
        businessId      = "BusinessId",
        businessName    = "BusinessName",
        businessNumber  = "BusinessNumber",
        facilityItem    = "FacilityItem",
        threadId        = "ThreadId",
        versionInfoS    = "VersionInfoS",
        versionInfoT    = "VersionInfoT"
    }
    
    func update() {
        Self.current = self
    }
    
    @discardableResult func synchronize() -> Bool {
        Self.current = self
        return save()
    }
}

extension Facility {
    
    struct Item: Codable {
        var damageLogs:         [DamageLog]?
        var facility:           Facility?
        var images:             [Image]?
        var inspection:         Inspection?
        var inspectionDetails:  [InspectionDetail]?
        var map:                Map?
        
        private enum CodingKeys: String, CodingKey {
            case
            damageLogs          = "DamageLogs",
            facility            = "Facility",
            images              = "Images",
            inspection          = "Inspection",
            inspectionDetails   = "InspectionDetails",
            map                 = "Map"
        }
        
        struct Facility: Codable {
            var facilitySpecId:             String?
            var businessId:                 String?
            var businessNumber:             String?
            var facilityType:               String?
            var areaOffice:                 String?
            var office:                     String?
            var serialNumber:               String?
            var roadType:                   String?
            var roadName:                   String?
            var roadBound:                  String?
            var roadAddress:                String?
            var roadAddress1:               String?
            var roadAddress2:               String?
            var roadAddress3:               String?
            var roadPointStr:               String?
            var roadPoint:                  Double?
            var latitude60:                 String?
            var latitudeStr:                String?
            var latitude:                   Double?
            var longitude60:                String?
            var longitudeStr:               String?
            var longitude:                  Double?
            var roadNote:                   String?
            var stanchionType:              String?
            var surfaceType:                String?
            var baseType:                   String?
            var stanchionLibType:           String?
            var roadEdgeCondition:          String?
            var lightningType:              String?
            var signCount:                  String?
            var signNumber:                 String?
            var signAttachmentType:         String?
            var signAttachmentParts1:       String?
            var signAttachmentParts2:       String?
            var signFallSolved:             String?
            var signFallSolvedPartsName:    String?
            var loosenSolved:               String?
            var loosenSolvedPartsName:      String?
            var matchedMarking:             String?
            var matchedMarkingPartsName:    String?
            var vibrationDumper:            String?
            var vibrationDumperPartsName:   String?
            var drainageImproved:           String?
            var drainageImprovedPartsName:  String?
            var constructionDate:           String?
            var constructionDateStr:        String?
            var constructionDateYearStr:    String?
            var constructionDateMonthStr:   String?
            var constructionNote:           String?
            var placeEnvironment:           String?
            var distanceFromSea:            String?
            var snowArea:                   String?
            var windArea:                   String?
            var snowRemoveArea:             String?
            var censusYear:                 String?
            var censusNumber:               String?
            var trafficVolumeStr:           String?
            var trafficVolume:              Int?
            var roadWidthStr:               String?
            var roadWidth:                  Double?
            var sideworkWidthStr:           String?
            var sideworkWidth:              Double?
            var emergencyRoad:              String?
            var schoolRoad:                 String?
            var inspectionType:             String?
            var inspectionManner:           String?
            var inspectionDate:             String?
            var inspectionDateStr:          String?
            var inspectionDateYearStr:      String?
            var inspectionDateMonthStr:     String?
            var inspectionDateDayStr:       String?
            var inspectionDatePrev:         String?
            var inspectionDatePrevStr:      String?
            var inspectionDatePrevYearStr:  String?
            var inspectionDatePrevMonthStr: String?
            var inspectionDatePrevDayStr:   String?
            var inspectorCompany:           String?
            var inspectorName:              String?
            var inspectionNote:             String?
            var renewalLog:                 String?
            var constructionDatePrev:       String?
            var constructionDatePrevStr:    String?
            var coverage:                   Int?
            var coverageType:               String?
            var inspectionDeviceDateSt:     String?
            var inspectionDeviceDateEnd:    String?
            var inspectionDeviceStatus:     InspectionDeviceStatus?
            var deviceId:                   String?
            var deviceIdStr:                String?
            var fileId:                     String?
            var fileName:                   String?
            
            private enum CodingKeys: String, CodingKey {
                case
                facilitySpecId             = "FacilitySpecId",
                businessId                 = "BusinessId",
                businessNumber             = "BusinessNumber",
                facilityType               = "FacilityType",
                areaOffice                 = "AreaOffice",
                office                     = "Office",
                serialNumber               = "SerialNumber",
                roadType                   = "RoadType",
                roadName                   = "RoadName",
                roadBound                  = "RoadBound",
                roadAddress                = "RoadAddress",
                roadAddress1               = "RoadAddress1",
                roadAddress2               = "RoadAddress2",
                roadAddress3               = "RoadAddress3",
                roadPointStr               = "RoadPointStr",
                roadPoint                  = "RoadPoint",
                latitude60                 = "Latitude60",
                latitudeStr                = "LatitudeStr",
                latitude                   = "Latitude",
                longitude60                = "Longitude60",
                longitudeStr               = "LongitudeStr",
                longitude                  = "Longitude",
                roadNote                   = "RoadNote",
                stanchionType              = "StanchionType",
                surfaceType                = "SurfaceType",
                baseType                   = "BaseType",
                stanchionLibType           = "StanchionLibType",
                roadEdgeCondition          = "RoadEdgeCondition",
                lightningType              = "LightningType",
                signCount                  = "SignCount",
                signNumber                 = "SignNumber",
                signAttachmentType         = "SignAttachmentType",
                signAttachmentParts1       = "SignAttachmentParts1",
                signAttachmentParts2       = "SignAttachmentParts2",
                signFallSolved             = "SignFallSolved",
                signFallSolvedPartsName    = "SignFallSolvedPartsName",
                loosenSolved               = "LoosenSolved",
                loosenSolvedPartsName      = "LoosenSolvedPartsName",
                matchedMarking             = "MatchedMarking",
                matchedMarkingPartsName    = "MatchedMarkingPartsName",
                vibrationDumper            = "VibrationDumper",
                vibrationDumperPartsName   = "VibrationDumperPartsName",
                drainageImproved           = "DrainageImproved",
                drainageImprovedPartsName  = "DrainageImprovedPartsName",
                constructionDate           = "ConstructionDate",
                constructionDateStr        = "ConstructionDateStr",
                constructionDateYearStr    = "ConstructionDateYearStr",
                constructionDateMonthStr   = "ConstructionDateMonthStr",
                constructionNote           = "ConstructionNote",
                placeEnvironment           = "PlaceEnvironment",
                distanceFromSea            = "DistanceFromSea",
                snowArea                   = "SnowArea",
                windArea                   = "WindArea",
                snowRemoveArea             = "SnowRemoveArea",
                censusYear                 = "CensusYear",
                censusNumber               = "CensusNumber",
                trafficVolumeStr           = "TrafficVolumeStr",
                trafficVolume              = "TrafficVolume",
                roadWidthStr               = "RoadWidthStr",
                roadWidth                  = "RoadWidth",
                sideworkWidthStr           = "SideworkWidthStr",
                sideworkWidth              = "SideworkWidth",
                emergencyRoad              = "EmergencyRoad",
                schoolRoad                 = "SchoolRoad",
                inspectionType             = "InspectionType",
                inspectionManner           = "InspectionManner",
                inspectionDate             = "InspectionDate",
                inspectionDateStr          = "InspectionDateStr",
                inspectionDateYearStr      = "InspectionDateYearStr",
                inspectionDateMonthStr     = "InspectionDateMonthStr",
                inspectionDateDayStr       = "InspectionDateDayStr",
                inspectionDatePrev         = "InspectionDatePrev",
                inspectionDatePrevStr      = "InspectionDatePrevStr",
                inspectionDatePrevYearStr  = "InspectionDatePrevYearStr",
                inspectionDatePrevMonthStr = "InspectionDatePrevMonthStr",
                inspectionDatePrevDayStr   = "InspectionDatePrevDayStr",
                inspectorCompany           = "InspectorCompany",
                inspectorName              = "InspectorName",
                inspectionNote             = "InspectionNote",
                renewalLog                 = "RenewalLog",
                constructionDatePrev       = "ConstructionDatePrev",
                constructionDatePrevStr    = "ConstructionDatePrevStr",
                coverage                   = "Coverage",
                coverageType               = "CoverageType",
                inspectionDeviceDateSt     = "InspectionDeviceDateSt",
                inspectionDeviceDateEnd    = "InspectionDeviceDateEnd",
                inspectionDeviceStatus     = "InspectionDeviceStatus",
                deviceId                   = "DeviceId",
                deviceIdStr                = "DeviceIdStr",
                fileId                     = "FileId",
                fileName                   = "FileName"
            }
            
            mutating func combine(_ another: Self) {
                another.facilitySpecId.flatMap({ self.facilitySpecId = $0 })
                another.businessId.flatMap({ self.businessId = $0 })
                another.businessNumber.flatMap({ self.businessNumber = $0 })
                another.facilityType.flatMap({ self.facilityType = $0 })
                another.areaOffice.flatMap({ self.areaOffice = $0 })
                another.office.flatMap({ self.office = $0 })
                another.serialNumber.flatMap({ self.serialNumber = $0 })
                another.roadType.flatMap({ self.roadType = $0 })
                another.roadName.flatMap({ self.roadName = $0 })
                another.roadBound.flatMap({ self.roadBound = $0 })
                another.roadAddress.flatMap({ self.roadAddress = $0 })
                another.roadAddress1.flatMap({ self.roadAddress1 = $0 })
                another.roadAddress2.flatMap({ self.roadAddress2 = $0 })
                another.roadAddress3.flatMap({ self.roadAddress3 = $0 })
                another.roadPointStr.flatMap({ self.roadPointStr = $0 })
                another.roadPoint.flatMap({ self.roadPoint = $0 })
                another.latitude60.flatMap({ self.latitude60 = $0 })
                another.latitudeStr.flatMap({ self.latitudeStr = $0 })
                another.latitude.flatMap({ self.latitude = $0 })
                another.longitude60.flatMap({ self.longitude60 = $0 })
                another.longitudeStr.flatMap({ self.longitudeStr = $0 })
                another.longitude.flatMap({ self.longitude = $0 })
                another.roadNote.flatMap({ self.roadNote = $0 })
                another.stanchionType.flatMap({ self.stanchionType = $0 })
                another.surfaceType.flatMap({ self.surfaceType = $0 })
                another.baseType.flatMap({ self.baseType = $0 })
                another.stanchionLibType.flatMap({ self.stanchionLibType = $0 })
                another.roadEdgeCondition.flatMap({ self.roadEdgeCondition = $0 })
                another.lightningType.flatMap({ self.lightningType = $0 })
                another.signCount.flatMap({ self.signCount = $0 })
                another.signNumber.flatMap({ self.signNumber = $0 })
                another.signAttachmentType.flatMap({ self.signAttachmentType = $0 })
                another.signAttachmentParts1.flatMap({ self.signAttachmentParts1 = $0 })
                another.signAttachmentParts2.flatMap({ self.signAttachmentParts2 = $0 })
                another.signFallSolved.flatMap({ self.signFallSolved = $0 })
                another.signFallSolvedPartsName.flatMap({ self.signFallSolvedPartsName = $0 })
                another.loosenSolved.flatMap({ self.loosenSolved = $0 })
                another.loosenSolvedPartsName.flatMap({ self.loosenSolvedPartsName = $0 })
                another.matchedMarking.flatMap({ self.matchedMarking = $0 })
                another.matchedMarkingPartsName.flatMap({ self.matchedMarkingPartsName = $0 })
                another.vibrationDumper.flatMap({ self.vibrationDumper = $0 })
                another.vibrationDumperPartsName.flatMap({ self.vibrationDumperPartsName = $0 })
                another.drainageImproved.flatMap({ self.drainageImproved = $0 })
                another.drainageImprovedPartsName.flatMap({ self.drainageImprovedPartsName = $0 })
                another.constructionDate.flatMap({ self.constructionDate = $0 })
                another.constructionDateStr.flatMap({ self.constructionDateStr = $0 })
                another.constructionDateYearStr.flatMap({ self.constructionDateYearStr = $0 })
                another.constructionDateMonthStr.flatMap({ self.constructionDateMonthStr = $0 })
                another.constructionNote.flatMap({ self.constructionNote = $0 })
                another.placeEnvironment.flatMap({ self.placeEnvironment = $0 })
                another.distanceFromSea.flatMap({ self.distanceFromSea = $0 })
                another.snowArea.flatMap({ self.snowArea = $0 })
                another.windArea.flatMap({ self.windArea = $0 })
                another.snowRemoveArea.flatMap({ self.snowRemoveArea = $0 })
                another.censusYear.flatMap({ self.censusYear = $0 })
                another.censusNumber.flatMap({ self.censusNumber = $0 })
                another.trafficVolumeStr.flatMap({ self.trafficVolumeStr = $0 })
                another.trafficVolume.flatMap({ self.trafficVolume = $0 })
                another.roadWidthStr.flatMap({ self.roadWidthStr = $0 })
                another.roadWidth.flatMap({ self.roadWidth = $0 })
                another.sideworkWidthStr.flatMap({ self.sideworkWidthStr = $0 })
                another.sideworkWidth.flatMap({ self.sideworkWidth = $0 })
                another.emergencyRoad.flatMap({ self.emergencyRoad = $0 })
                another.schoolRoad.flatMap({ self.schoolRoad = $0 })
                another.inspectionType.flatMap({ self.inspectionType = $0 })
                another.inspectionManner.flatMap({ self.inspectionManner = $0 })
                another.inspectionDate.flatMap({ self.inspectionDate = $0 })
                another.inspectionDateStr.flatMap({ self.inspectionDateStr = $0 })
                another.inspectionDateYearStr.flatMap({ self.inspectionDateYearStr = $0 })
                another.inspectionDateMonthStr.flatMap({ self.inspectionDateMonthStr = $0 })
                another.inspectionDateDayStr.flatMap({ self.inspectionDateDayStr = $0 })
                another.inspectionDatePrev.flatMap({ self.inspectionDatePrev = $0 })
                another.inspectionDatePrevStr.flatMap({ self.inspectionDatePrevStr = $0 })
                another.inspectionDatePrevYearStr.flatMap({ self.inspectionDatePrevYearStr = $0 })
                another.inspectionDatePrevMonthStr.flatMap({ self.inspectionDatePrevMonthStr = $0 })
                another.inspectionDatePrevDayStr.flatMap({ self.inspectionDatePrevDayStr = $0 })
                another.inspectorCompany.flatMap({ self.inspectorCompany = $0 })
                another.inspectorName.flatMap({ self.inspectorName = $0 })
                another.inspectionNote.flatMap({ self.inspectionNote = $0 })
                another.renewalLog.flatMap({ self.renewalLog = $0 })
                another.constructionDatePrev.flatMap({ self.constructionDatePrev = $0 })
                another.constructionDatePrevStr.flatMap({ self.constructionDatePrevStr = $0 })
                another.coverage.flatMap({ self.coverage = $0 })
                another.coverageType.flatMap({ self.coverageType = $0 })
                another.inspectionDeviceDateSt.flatMap({ self.inspectionDeviceDateSt = $0 })
                another.inspectionDeviceDateEnd.flatMap({ self.inspectionDeviceDateEnd = $0 })
                another.inspectionDeviceStatus.flatMap({ self.inspectionDeviceStatus = $0 })
                another.deviceId.flatMap({ self.deviceId = $0 })
                another.deviceIdStr.flatMap({ self.deviceIdStr = $0 })
                another.fileId.flatMap({ self.fileId = $0 })
                another.fileName.flatMap({ self.fileName = $0 })
            }
        }
        
        struct Map: Codable {
            var facilitySpecId:             String?
            var mapFileId:                  String?
            var fileName:                   String?
            var serialNumber:               String?
            
            private enum CodingKeys: String, CodingKey {
                case
                facilitySpecId              = "FacilitySpecId",
                mapFileId                   = "MapFileId",
                fileName,
                serialNumber                = "SerialNumber"
            }
        }
    }
}


