//
//  JsonFile.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/15.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation

protocol JsonFile: Codable {
    var url: URL? { get set }
}

extension JsonFile {
    
    static func load(fileName: String) -> Self? {
        return load(url: URL(fileURLWithPath: DataManager.rootPath).appendingPathComponent(fileName))
    }
    
    static func load(url: URL) -> Self? {
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            var decoded = try decoder.decode(Self.self, from: data)
            decoded.url = url
            return decoded
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func save() -> Bool {
        guard let url = url else {
            return false
        }
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url, options: [.atomic])
            return true
        } catch {
            return false
        }
    }
}


protocol MasterFile: JsonFile {
    static var shared: Self? { get set }
    static var fileName: String { get }
}

extension MasterFile {
    static func load() -> Self? {
        return load(fileName: fileName)
    }
    
    @discardableResult
    func synchronize() -> Bool {
        Self.shared = self
        return save()
    }
}

struct GenericKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

enum InspectionDeviceStatus: Int, Codable {
    case uninspected, inspecting, inspected
}
