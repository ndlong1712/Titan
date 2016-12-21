//
//  Date+Conversion.swift
//  PartyPrint
//
//  Created by TrongNK on 10/16/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

extension Date {
    
    func gmtStringWithFormat(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.stringFromDate(self, timeZone: TimeZone(abbreviation: "GMT")!, format: format)
    }
    
    func gmtDate() -> Date {
        let dateFormatter = DateFormatter()
        let str = dateFormatter.stringFromDate(self, timeZone: TimeZone.current, format: Constant.dateTimeFormatForConverting)
        
        return dateFormatter.dateFromString(str, timeZone: TimeZone(abbreviation: "GMT")!, format: Constant.dateTimeFormatForConverting)
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult
            .orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }


}
