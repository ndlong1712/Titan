//
//  NSDate+Conversion.swift
//  PartyPrint
//
//  Created by TrongNK on 10/16/16.
//  Copyright © 2016 DNP. All rights reserved.
//

extension DateFormatter {
    
    static func staticUSLocale() -> Locale {
        let usLocale = Locale(identifier: "en_US_POSIX")
        return usLocale
    }
    
    func stringFromDate(_ date: Date, timeZone: TimeZone, format: String) -> String {
        var calendar = Calendar(identifier: .iso8601)
//        if calendar == nil {
//            calendar = Calendar(identifier: .gregorian)
//        }
        calendar.timeZone = timeZone
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = DateFormatter.staticUSLocale()
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: date)
        
        return str
    }
    
    func dateFromString(_ string: String, timeZone: TimeZone, format: String) -> Date {
        var calendar = Calendar(identifier: .iso8601)
//        if calendar == nil {
//            calendar = Calendar(identifier: .gregorian)
//        }
        calendar.timeZone = timeZone
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = DateFormatter.staticUSLocale()
        dateFormatter.timeZone = calendar.timeZone
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: string)
        
        return date!
    }
}
