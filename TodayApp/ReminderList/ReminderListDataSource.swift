//
//  ReminderListDataSource.swift
//  TodayApp
//
//  Created by Chad Smith on 2/6/22.
//

import UIKit

class ReminderListDataSource: NSObject {
    private lazy var dateFormatter = RelativeDateTimeFormatter()
    
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
    
    var filter: Filter = .today
    
    var filteredReminders: [Reminder] {
        return Reminder.testData.filter { reminder in
            self.filter.shouldInclude(date: reminder.dueDate)
        }.sorted { reminder1, reminder2 in
            reminder1.dueDate < reminder2.dueDate
        }
    }
    
    func update(_ reminder: Reminder, at row: Int) {
        Reminder.testData[row] = reminder
    }
    
    func reminder(at row: Int) -> Reminder {
        return filteredReminders[row]
    }
    
    func add(_ reminder: Reminder) {
        Reminder.testData.insert(reminder, at: 0)
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
        let dateText = dateFormatter.localizedString(for: reminder.dueDate, relativeTo: Date())
        cell.configure(title: reminder.title, dateText: dateText, isDone: reminder.isComplete) {
            var modifiedReminder = reminder
            modifiedReminder.isComplete.toggle()
            self.update(modifiedReminder, at: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
}
