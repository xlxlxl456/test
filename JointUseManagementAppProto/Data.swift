//
//  Data.swift
//  JointUseManagementAppProto
//
//  Created by Core System Japan on 2019/12/31.
//  Copyright © 2019 Furukawa Electric Co., Ltd. All rights reserved.
//

import SwiftUI


let onDevice = true
var dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let fileName = "DeviceData/Completion.json"
var fileURL = dir.appendingPathComponent(fileName)

let timeStampFileName = "DeviceData/TimeStamp.json"
var timeStampFileURL = dir.appendingPathComponent(timeStampFileName)

var completionModel: CompletionModel = loadOnDevice(fileURL)
var timeStamp: TimeStamp = loadOnDevice(timeStampFileURL)

var dirs: [String] = []
var currentDir: String = ""
var poleNum: Int = -1
var state: Int = -1
var fromCamera: Bool = false

// 実機用のLoad関数
func loadOnDevice<T: Decodable>(_ fileURL: URL, as type: T.Type = T.self) -> T {
    
    let data: Data
    
    let isExist = FileManager.default.fileExists(atPath: fileURL.path)
    if isExist == false  {
        let tmpDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tmpFile = "ここにデータを置いてください"
        let tmpFIleURL = tmpDir.appendingPathComponent(tmpFile)
        FileManager.default.createFile(atPath: tmpFIleURL.path, contents: nil, attributes: nil)
        print("初期化を完了しました。: ", tmpFIleURL.path)

        fatalError("Couldn't find \(fileURL.path) in main bundle.")
    }
   
    
    do {
        data = try Data(contentsOf: fileURL)
    } catch {
        fatalError("Couldn't load \(fileURL.path) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(fileURL.path) as \(T.self):\n\(error)")
    }
}

