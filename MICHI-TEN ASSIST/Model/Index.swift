//
//  Index.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/15.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import UIKit
import CoreLocation

struct Index: MasterFile {
    static var shared: Index? = Index.load()
    static var fileName: String { return "index.json" }
    var url: URL?   //メモリ変数(JSONには存在しない)
    
    var businessId:     String?
    var businessName:   String?
    var businessNumber: String?
    var coverage:       Int?
    var facilities:     [Facility]?
    var threadId:       String?
    var versionInfoS:   String?
    var versionInfoT:   String?
    
    private enum CodingKeys: String, CodingKey {
        case
        businessId      = "BusinessId",
        businessName    = "BusinessName",
        businessNumber  = "BusinessNumber",
        coverage        = "Coverage",
        facilities      = "Facilities",
        threadId        = "ThreadId",
        versionInfoS    = "VersionInfoS",
        versionInfoT    = "VersionInfoT"
    }
}

extension Index {
    struct Facility: Codable {

        var facility:   Facility?
        var images:     [Image]?
        var inspection: Inspection?
        
        private enum CodingKeys: String, CodingKey {
            case
            facility = "Facility",
            images = "Images",
            inspection = "Inspection"
        }
        
        var distance: CLLocationDistance?   //メモリ変数(JSONには存在しない)
        
        var image: UIImage? {
            return DataManager.imageFor(facilitySn: facility?.serialNumber, fileName: images?.first?.fileName)
        }
        
        var location: CLLocation? {
            guard let lat = facility?.latitudeStr, let lon = facility?.longitudeStr,
                let latD = CLLocationDegrees(lat), let lonD = CLLocationDegrees(lon) else {
                    return nil
            }
            return .init(latitude: latD, longitude: lonD)
        }
        
        //ar処理にてlocationKeyをキーとする（latitudeStr、longitudeStrが必須のため）
        var locationKey: String? {
            guard let lat = facility?.latitudeStr, let lon = facility?.longitudeStr else {
                return nil
            }
            return "\(lat), \(lon)"
        }
        
        var markerColor: UIColor? {
            switch facility?.inspectionDeviceStatus {
            case .some(.inspected): return Setting.shared?.arInfo.markerColorAfter.color
            default:                return Setting.shared?.arInfo.markerColorBefore.color
            }
        }
        
        struct Facility: Codable {
            var facilitySpecId:         String?
            var serialNumber:           String?
            var roadPointStr:           String?
            var latitudeStr:            String?
            var longitudeStr:           String?
            var inspectionDateStr:      String?
            var inspectionDeviceStatus: InspectionDeviceStatus?
            
            private enum CodingKeys: String, CodingKey {
                case
                facilitySpecId         = "FacilitySpecId",
                serialNumber           = "SerialNumber",
                roadPointStr           = "RoadPointStr",
                latitudeStr            = "LatitudeStr",
                longitudeStr           = "LongitudeStr",
                inspectionDateStr      = "InspectionDateStr",
                inspectionDeviceStatus = "InspectionDeviceStatus"
            }
        }
        
        struct Inspection: Codable {
            var facilityHealth: String?
            
            private enum CodingKeys: String, CodingKey {
                case facilityHealth = "FacilityHealth"
            }
        }
    }
}
