//
//  ReminderListDataSource.swift
//  TodayApp
//
//  Created by Chad Smith on 2/6/22.
//

import UIKit

class ReminderListDataSource: NSObject {
    typealias ReminderCompleteAction = (Int) -> Void
    typealias ReminderDeletedAction = () -> Void
    
    enum Filter: Int {
        case today
        case future
        case all
        
        func shouldInclude(date: Date) -> Bool {
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

    private var reminderCompletedAction: ReminderCompleteAction?
    private var reminderDeletedAction: ReminderDeletedAction?
    var filter: Filter = .today
    
    var filteredReminders: [Reminder] {
        return Reminder.testData.filter { reminder in
            self.filter.shouldInclude(date: reminder.dueDate)
        }.sorted { reminder1, reminder2 in
            reminder1.dueDate < reminder2.dueDate
        }
    }
    
    var percentComplete: Double {
        guard filteredReminders.count > 1 else {
            return 1
        }
        
        let numComplete: Double = filteredReminders.reduce(0) {$0 + ($1.isComplete ? 1 : 0)}
        return numComplete / Double(filteredReminders.count)
    }
    
    init(reminderCompletedAction: @escaping ReminderCompleteAction, reminderDeletedAction: @escaping ReminderDeletedAction) {
        self.reminderCompletedAction = reminderCompletedAction
        self.reminderDeletedAction = reminderDeletedAction
        super.init()
    }
    
    func update(_ reminder: Reminder, at row: Int) {
        let index  = index(for: row)
        Reminder.testData[index] = reminder
    }
    
    func reminder(at row: Int) -> Reminder {
        return filteredReminders[row]
    }
    
    func add(_ reminder: Reminder) -> Int? {
        Reminder.testData.insert(reminder, at: 0)
        return filteredReminders.firstIndex(where: {$0.id == reminder.id})
    }
    
    func index(for filteredIndex: Int) -> Int {
        let filteredReminder = filteredReminders[filteredIndex]
        guard let index = Reminder.testData.firstIndex(where: {$0.id == filteredReminder.id}) else {
            fatalError("Couldn't retrieve index in source array")
        }
        
        return index
    }
    
    func delete(at row: Int) {
        let index = self.index(for: row)
        Reminder.testData.remove(at: index)
    }
}

extension ReminderListDataSource: UITableViewDataSource {
    private static let reminderListCellIdentifier = "ReminderListCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.reminderListCellIdentifier, for: indexPath) as? ReminderListCell else {
            fatalError("Unable to dequeue ReminderCell")
        }
        let reminder = reminder(at: indexPath.row)
        let dateText = reminder.dueDateTimeText(for: filter)
        cell.configure(title: reminder.title, dateText: dateText, isDone: reminder.isComplete) {
            var modifiedReminder = reminder
            modifiedReminder.isComplete.toggle()
            self.update(modifiedReminder, at: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
            self.reminderCompletedAction?(indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        delete(at: indexPath.row)
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }) { _ in
            tableView.reloadData()
        }
        reminderDeletedAction?()
    }
}

extension Reminder {
    static let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        return timeFormatter
    }()
    
    static let futureDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    static let todayDateFormatter: DateFormatter = {
        let format = NSLocalizedString("'Today at '%@", comment: "format string for dates occuring today")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = String(format: format, "hh:mm a")
        
        return dateFormatter
    }()
    
    func dueDateTimeText(for filter: ReminderListDataSource.Filter) -> String {
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
