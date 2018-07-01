//
//  Date+Extension.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 2018/06/27.
//  Copyright © 2018 MuShare. All rights reserved.
//

import Foundation

extension Date {
    
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    
    func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
    
    func isInSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    
    var isInThisYea: Bool {
        return isInSameYear(date: Date())
    }
    
    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }
    
    var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isInTheFuture: Bool {
        return Date() < self
    }
    
    var isInThePast: Bool {
        return self < Date()
    }
    
}
