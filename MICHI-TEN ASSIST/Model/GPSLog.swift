//
//  GPSLog.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/09/01.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation
import CoreLocation

struct GPSLog {
    
    private static var cache = [String]()
    private static let sessionQueue =  DispatchQueue(label: "GPSLog.sessionQueue")
    private static var logsCount = 0
    
    private static var fileDate: Date?
    private static var fileName: String? {
        guard let startDate = fileDate else {
            return nil
        }
        var fileName = startDate.string(.timestamp)
        fileName.insert("_", at: fileName.index(fileName.startIndex, offsetBy: 8))
        return fileName
    }
    private static var maxLogsPerFile:  Int { 10000 }
    private static var saveLot:         Int { 100 }
    private static var offsetX:         Double { 0.1 }  // 外付けGPSアンテナとiPadの位置偏位の補正（Androidソースを参照。現状、編集用UIは提供していない）
    private static var offsetY:         Double { 0.5 }  // 外付けGPSアンテナとiPadの位置偏位の補正（Androidソースを参照。現状、編集用UIは提供していない）
    private static var earthRadius:     Double { 6378137 }
    
    static func add(_ location: CLLocation, sum: CLLocationCoordinate2D, average: CLLocationCoordinate2D) {
        sessionQueue.async {
            addSync(location, sum: sum, average: average)
        }
    }
    
    static func save() {
        sessionQueue.async {
            saveSync()
        }
    }
    
    static private func addSync(_ location: CLLocation, sum: CLLocationCoordinate2D, average: CLLocationCoordinate2D) {
        guard Bool(truncating: (Setting.shared?.arInfo.gpsLog ?? 0) as NSNumber) else {
            if !cache.isEmpty {
                saveSync()
            }
            return
        }
        
        if let date = fileDate {
            // フアィル肥大化対策：日付を跨いだ、あるいは最大件数を超えた場合、新しいフアィルに出力
            if date.string(.day(.slash)) != Date().string(.day(.slash)) ||
                logsCount >= maxLogsPerFile {
                saveSync()
                createNewFile()
            }
        } else {
            createNewFile()
        }
        
        let offsetLocation = offset(location: location)
        
        let log = location.timestamp.string(.dateTime(.ja)) + ","
            + "\(location.coordinate.latitude),"
            + "\(location.coordinate.longitude),"
            + "\(location.horizontalAccuracy),"
            + "\(offsetLocation.latitude),"
            + "\(offsetLocation.longitude),"
            + "\(sum.latitude),"
            + "\(sum.longitude),"
            + "\(average.latitude),"
            + "\(average.longitude)"
        
        cache.append(log)
        logsCount += 1
        
        if cache.count >= saveLot {
            // 一定の件数を溜まったら一旦保存
            saveSync()
        }
    }
    
    // 新しいフアィル（ヘッダーのみ）を作成
    static private func createNewFile() {
        fileDate = Date()
        guard let fileName = fileName else {
            return
        }
        
        //　フォルダの確認・作成
        var path = DataManager.rootPath + "/log"
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                return
            }
        }
        
        path += "/gps_\(fileName).csv"
        
        let header = "時刻,location.latitude,location.longitude,location.accuracy,offsetLatLng.latitude,offsetLatLng.longitude,sumlatitude,sumlongitude,avelatitude,avelongitude"
        
        if let data = header.data(using: .shiftJIS) {
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        }
        logsCount = 0
    }
    
    // キャッシュをcsvフアィルに出力
    static private func saveSync() {
        guard !cache.isEmpty, let fileName = fileName else {
            return
        }
        
        let log = cache.reduce(into: "") { (result, log) in
            result += "\n" + log
        }

        let path = DataManager.rootPath + "/log/gps_\(fileName).csv"
        
        if let data = log.data(using: .shiftJIS),
            let fileHandle = FileHandle(forWritingAtPath: path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
            // キャッシュをクリア
            cache.removeAll()
        }
    }
    
    // 基準点からの距離と方位角から位置座標に変換するメソッド（Androidを参照）
    private static func offset(location: CLLocation) -> CLLocationCoordinate2D {
        
        let length = sqrt(pow(offsetX , 2) + pow(offsetY , 2))
        let angle = atan(offsetY / offsetX) * 180 / .pi
        
         // 距離ベクトルの算出
        let dY = length * sin(.pi * (90 - angle) / 180)
        let dX = length * cos(.pi * (90 - angle) / 180)
        // 位置座標に変換
        let lat = location.coordinate.latitude + 360 * dY / earthRadius / .pi / 2
        // 緯度を使った補正
        let lng = location.coordinate.longitude + 360 * dX / earthRadius / .pi / 2 / cos(lat / (180 * .pi))
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
