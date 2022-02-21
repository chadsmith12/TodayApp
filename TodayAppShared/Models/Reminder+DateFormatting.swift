//
//  Reminder+DateFormatting.swift
//  TodayAppShared
//
//  Created by Chad Smith on 2/21/22.
//

import Foundation

extension Reminder {
    public static let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        return timeFormatter
    }()
    
    public static let futureDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    public static let todayDateFormatter: DateFormatter = {
        let format = NSLocalizedString("'Today at '%@", comment: "format string for dates occuring today")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = String(format: format, "hh:mm a")
        
        return dateFormatter
    }()
    
    public func dueDateTimeText(for filter: Filter) -> String {
        let isInToday = Locale.current.calendar.isDateInToday(self.dueDate)
        switch filter {
        case .today:
            return Self.timeFormatter.string(from: dueDate)
        case .future:
            return Self.futureDateFormatter.string(from: dueDate)
        case .all:
            if isInToday {
                return Self.todayDateFormatter.string(from: dueDate)
            }
            return Self.futureDateFormatter.string(from: dueDate)
        }
    }
}
