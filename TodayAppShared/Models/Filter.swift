//
//  Filter.swift
//  TodayAppShared
//
//  Created by Chad Smith on 2/21/22.
//

import Foundation

public enum Filter: Int {
    case today
    case future
    case all
    
    public func shouldInclude(date: Date) -> Bool {
        let isInToday = Locale.current.calendar.isDateInToday(date)
        switch self {
        case .today:
            return isInToday
        case .future:
            return (date > Date()) && !isInToday
        case .all:
            return true
        }
    }
}
