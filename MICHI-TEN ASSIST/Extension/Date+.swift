//
//  Date+.swift
//  MICHI-TEN ASSIST
//
//  Created by Cho on 2020/06/18.
//  Copyright © 2020 Furukawa Electric Co., Ltd. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var defualt: DateFormatter {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return df
    }
    
    enum Format{
        enum DateFormat {
            case ja, slash, hyphen, colon
        }
        
        case date(DateFormat), dateTime(DateFormat), year(DateFormat), month(DateFormat), day(DateFormat), time, timeJa, timestamp
        
        var format: String {
            switch self {
            case .date(let dateFormat):
                switch dateFormat {
                case .ja:       return "yyyy年M月d日"
                case .slash:    return "yyyy/MM/dd"
                case .hyphen:   return "yyyy-MM-dd"
                case .colon:    return "yyyy:MM:dd"
                }
                
            case .dateTime(let dateFormat):
                switch dateFormat {
                case .ja:   return Format.date(dateFormat).format + " "  + Format.timeJa.format
                default:    return Format.date(dateFormat).format + " "  + Format.time.format
                }
                
            case .year(let dateFormat):
                if case .ja = dateFormat {
                    return "yyyy年"
                }
                return "yyyy"
                
            case .month(let dateFormat):
                if case .ja = dateFormat {
                    return "M月"
                }
                return "M"
                
            case .day(let dateFormat):
                if case .ja = dateFormat {
                    return "d日"
                }
                return "d"
                
            case .time:
                return "HH:mm:ss"
                
            case .timeJa:
                return "H時m分s秒"
                
            case .timestamp:
                return "yyyyMMddHHmmss"
            }
        }
    }
}

extension Date {
    func string(_ format: DateFormatter.Format) -> String {
        let df = DateFormatter.defualt
        df.dateFormat = format.format
        return df.string(from: self)
    }
}

extension String {
    func date(_ format: DateFormatter.Format) -> Date? {
        let df = DateFormatter.defualt
        df.dateFormat = format.format
        return df.date(from: self)
    }
}
