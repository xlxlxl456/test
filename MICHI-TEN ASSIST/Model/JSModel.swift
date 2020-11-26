//
//  JSModel.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/09/02.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation
// JavaScriptに使われるデータフォーマット
    
struct JSMap: Codable {
    var serialNumber:           String?
    var fileName:               String?
    
    private enum CodingKeys: String, CodingKey {
        case
        serialNumber            = "SerialNumber",
        fileName
    }
}

struct JSImages: Codable {
    var serialNumber:           String?
    var images:                 [Image]
    
    private enum CodingKeys: String, CodingKey {
        case
        serialNumber            = "SerialNumber",
        images                  = "Images"
    }
}

struct JSFacility: Codable {
    var facility:               Facility.Item.Facility?
    var images:                 [Image]
    
    private enum CodingKeys: String, CodingKey {
        case
        facility                = "Facility",
        images                  = "Images"
    }
    
    private enum ImagesKeys: String, CodingKey {
        case
        images                  = "Images"
    }
    
    struct Image: Codable {
        var caption:            String?
        var selectedStatus:     Int?
        
        private enum CodingKeys: String, CodingKey {
            case
            caption             = "ImgCaption",
            selectedStatus      = "SelectedStatus"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            caption =           try values.decodeIfPresent(String.self, forKey: .caption)
            selectedStatus =    try values.decodeIfPresent(String.self, forKey: .selectedStatus).flatMap({ Int($0) })
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        facility = try values.decodeIfPresent(Facility.Item.Facility.self, forKey: .facility)
        
        var imgs = [Image]()
        let container = try? values.nestedContainer(keyedBy: ImagesKeys.self, forKey: .images)
        if var imgContainer = try? container?.nestedUnkeyedContainer(forKey: .images) {
            while !imgContainer.isAtEnd {
                let img = try imgContainer.decode(Image.self)
                imgs.append(img)
            }
        }
        images = imgs
    }
}

struct JSInspectionDetails: Codable {
    var items: [InspectionDetail]
    
    private enum CodingKeys: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        var itms = [InspectionDetail]()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if var itemContainer = try? values.nestedUnkeyedContainer(forKey: .items) {
            while !itemContainer.isAtEnd {
                let item = try itemContainer.nestedContainer(keyedBy: InspectionDetail.CodingKeys.self)
                let itm = InspectionDetail(
                    applicable:             try item.decodeIfPresent(String.self, forKey: .applicable),
                    areaOffice:             try item.decodeIfPresent(String.self, forKey: .areaOffice),
                    branchOffice:           try item.decodeIfPresent(String.self, forKey: .branchOffice),
                    businessId:             try item.decodeIfPresent(String.self, forKey: .businessId),
                    businessNumber:         try item.decodeIfPresent(String.self, forKey: .businessNumber),
                    inspectionStatus:       try item.decodeIfPresent(String.self, forKey: .inspectionStatus),
                    steelCrackBefore:       try item.decodeIfPresent(String.self, forKey: .steelCrackBefore),
                    steelCrackAfter:        try item.decodeIfPresent(String.self, forKey: .steelCrackAfter),
                    steelLooseBefore:       try item.decodeIfPresent(String.self, forKey: .steelLooseBefore),
                    steelLooseAfter:        try item.decodeIfPresent(String.self, forKey: .steelLooseAfter),
                    steelBreakBefore:       try item.decodeIfPresent(String.self, forKey: .steelBreakBefore),
                    steelBreakAfter:        try item.decodeIfPresent(String.self, forKey: .steelBreakAfter),
                    steelCorrosionBefore:   try item.decodeIfPresent(String.self, forKey: .steelCorrosionBefore),
                    steelCorrosionAfter:    try item.decodeIfPresent(String.self, forKey: .steelCorrosionAfter),
                    steelDeformationBefore: try item.decodeIfPresent(String.self, forKey: .steelDeformationBefore),
                    steelDeformationAfter:  try item.decodeIfPresent(String.self, forKey: .steelDeformationAfter),
                    concreteCrackBefore:    try item.decodeIfPresent(String.self, forKey: .concreteCrackBefore),
                    concreteCrackAfter:     try item.decodeIfPresent(String.self, forKey: .concreteCrackAfter),
                    concretePeelingBefore:  try item.decodeIfPresent(String.self, forKey: .concretePeelingBefore),
                    concretePeelingAfter:   try item.decodeIfPresent(String.self, forKey: .concretePeelingAfter),
                    commonWaterBefore:      try item.decodeIfPresent(String.self, forKey: .commonWaterBefore),
                    commonWaterAfter:       try item.decodeIfPresent(String.self, forKey: .commonWaterAfter),
                    commonOtherBefore:      try item.decodeIfPresent(String.self, forKey: .commonOtherBefore),
                    commonOtherAfter:       try item.decodeIfPresent(String.self, forKey: .commonOtherAfter),
                    lineNumber:             (try item.decodeIfPresent(String.self, forKey: .lineNumber)).flatMap({ Int($0) }),
                    creatorId:              try item.decodeIfPresent(String.self, forKey: .creatorId),
                    deviceId:               try item.decodeIfPresent(String.self, forKey: .deviceId),
                    deviceIdStr:            try item.decodeIfPresent(String.self, forKey: .deviceIdStr),
                    editorId:               try item.decodeIfPresent(String.self, forKey: .editorId),
                    facilitySpecId:         try item.decodeIfPresent(String.self, forKey: .facilitySpecId),
                    facilityType:           try item.decodeIfPresent(String.self, forKey: .facilityType),
                    inspectionDetailId:     try item.decodeIfPresent(String.self, forKey: .inspectionDetailId),
                    inspectionId:           try item.decodeIfPresent(String.self, forKey: .inspectionId),
                    inspectionPoint:        try item.decodeIfPresent(String.self, forKey: .inspectionPoint),
                    inspectionPointMark:    try item.decodeIfPresent(String.self, forKey: .inspectionPointMark),
                    isDeleted:              try item.decodeIfPresent(Bool.self, forKey: .isDeleted),
                    lastUpdated:            try item.decodeIfPresent(String.self, forKey: .lastUpdated),
                    office:                 try item.decodeIfPresent(String.self, forKey: .office),
                    registered:             try item.decodeIfPresent(String.self, forKey: .registered),
                    serialNumber:           try item.decodeIfPresent(String.self, forKey: .serialNumber)
                )
                itms.append(itm)
            }
        }
        items = itms
    }
}

struct JSDamageLog: Codable {
    var damageLog:                  DamageLog.Log?
    var rawImages:                  RawImages?
    
    var images: [RawImages.Image]? {
        rawImages?.images
    }
     
    private enum CodingKeys: String, CodingKey {
        case
        damageLog                   = "DamageLog",
        rawImages                   = "Images"
    }
    
    struct RawImages: Codable {
        var images:                 [Image]?
        
        private enum CodingKeys: String, CodingKey {
            case
            images                  = "Images"
        }
        
        struct Image: Codable {
            var selectedStatusRaw:  String?
            var caption:            String?
            
            var selectedStatus: Int? {
                selectedStatusRaw.flatMap({ Int($0) })
            }
            
            private enum CodingKeys: String, CodingKey {
                case
                selectedStatusRaw      = "SelectedStatus",
                caption             = "DamageLogImgCaption"
            }
        }
    }
}


extension Facility {
    
    var jsMap: JSMap {
        return JSMap(serialNumber: facilityItem?.facility?.serialNumber,
                     fileName: facilityItem?.map?.fileName)
    }
    
    var jsFacilityImages: JSImages {
        return JSImages(serialNumber: facilityItem?.facility?.serialNumber,
                        images: facilityItem?.images ?? [])
    }
    
    
    func jsDamageLogImages(lineNumber: Int) -> JSImages {
        let images = facilityItem?.damageLogs?.first(where: {
            $0.damageLog?.lineNumber == lineNumber
            })?.images ?? []
        
        return JSImages(serialNumber: facilityItem?.facility?.serialNumber,
                        images: images)
    }
}
