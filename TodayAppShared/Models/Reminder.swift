//
//  Person.swift
//  TodayAppShared
//
//  Created by Chad Smith on 2/20/22.
//

import Foundation

public struct Reminder {
    public var id: String
    public var title: String
    public var dueDate: Date
    public var notes: String? = nil
    public var isComplete: Bool = false
    
    public init (id: String, title: String, dueDate: Date, notes: String? = nil, isComplete: Bool = false) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.notes = notes
        self.isComplete = isComplete
    }
}
