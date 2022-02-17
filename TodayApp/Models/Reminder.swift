//
//  Reminder.swift
//  TodayApp
//
//  Created by Chad Smith on 2/5/22.
//

import Foundation

struct Reminder {
    var id: String
    var title: String
    var dueDate: Date
    var notes: String? = nil
    var isComplete: Bool = false
}
