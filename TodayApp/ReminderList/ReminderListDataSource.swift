//
//  ReminderListDataSource.swift
//  TodayApp
//
//  Created by Chad Smith on 2/6/22.
//

import UIKit
import EventKit

class ReminderListDataSource: NSObject {
    typealias ReminderCompleteAction = (Int) -> Void
    typealias ReminderDeletedAction = () -> Void
    typealias RemindersChangedAction = () -> Void
    
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
    
    private let eventStore = EKEventStore()
    private var reminders: [Reminder] = []
    private var reminderCompletedAction: ReminderCompleteAction?
    private var reminderDeletedAction: ReminderDeletedAction?
    private var remindersChangedAction: RemindersChangedAction?
    var filter: Filter = .today
    
    var filteredReminders: [Reminder] {
        return reminders.filter { reminder in
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
    
    init(reminderCompletedAction: @escaping ReminderCompleteAction, reminderDeletedAction: @escaping ReminderDeletedAction, remindersChangedAction: @escaping RemindersChangedAction) {
        self.reminderCompletedAction = reminderCompletedAction
        self.reminderDeletedAction = reminderDeletedAction
        self.remindersChangedAction = remindersChangedAction
        super.init()
        
        requestAccess { authorized in
            if authorized {
                self.readAllReminders()
                NotificationCenter.default.addObserver(self, selector: #selector(self.storeChanged(_:)), name: .EKEventStoreChanged, object: self.eventStore)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .EKEventStoreChanged, object: self.eventStore)
    }
    
    @objc
    func storeChanged(_ notification: NSNotification) {
        requestAccess { authorized in
            if authorized {
                self.readAllReminders()
            }
        }
    }
    
    func update(_ reminder: Reminder, at row: Int, completion: (Bool) -> Void) {
        saveReminder(reminder) { success in
            if success {
                let index  = index(for: row)
                reminders[index] = reminder
            }
            completion(success)
        }
    }
    
    func reminder(at row: Int) -> Reminder {
        return filteredReminders[row]
    }
    
    func add(_ reminder: Reminder) -> Int? {
        reminders.insert(reminder, at: 0)
        return filteredReminders.firstIndex(where: {$0.id == reminder.id})
    }
    
    func index(for filteredIndex: Int) -> Int {
        let filteredReminder = filteredReminders[filteredIndex]
        guard let index = reminders.firstIndex(where: {$0.id == filteredReminder.id}) else {
            fatalError("Couldn't retrieve index in source array")
        }
        
        return index
    }
    
    func delete(at row: Int) {
        let index = self.index(for: row)
        reminders.remove(at: index)
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
            self.update(modifiedReminder, at: indexPath.row) { success in
                if success {
                    self.reminderCompletedAction?(indexPath.row)
                }
            }
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

extension ReminderListDataSource {
    private var isAvailable: Bool {
        return EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    private func requestAccess(completion: @escaping (Bool) -> Void) {
        let currentStatus = EKEventStore.authorizationStatus(for: .reminder)
        guard currentStatus == .notDetermined else {
            completion(currentStatus == .authorized)
            return
        }
        
        eventStore.requestAccess(to: .reminder) { success, error in
            completion(success)
        }
    }
    
    private func readAllReminders() {
        guard isAvailable else { return }
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { ekReminders in
            guard let ekReminders = ekReminders else {
                self.reminders = []
                return
            }
            
            self.reminders = ekReminders.compactMap({ ekReminder in
                guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
                    return nil
                }
                let reminder = Reminder(id: ekReminder.calendarItemIdentifier, title: ekReminder.title, dueDate: dueDate, notes: ekReminder.notes, isComplete: ekReminder.isCompleted)
                
                return reminder
            })
            
            self.remindersChangedAction?()
        }
    }
    
    private func saveReminder(_ reminder: Reminder, completion: (Bool) -> Void) {
        guard isAvailable else {
            completion(false)
            return
        }
        
        readReminder(with: reminder.id) { ekReminder in
            let ekReminder = ekReminder ?? EKReminder(eventStore: self.eventStore)
            ekReminder.title = reminder.title
            ekReminder.notes = reminder.notes
            ekReminder.isCompleted = reminder.isComplete
            ekReminder.calendar = self.eventStore.defaultCalendarForNewReminders()
            ekReminder.alarms?.forEach { alarm in
                if let absoluteDate = alarm.absoluteDate {
                    let comparison = Locale.current.calendar.compare(reminder.dueDate, to: absoluteDate, toGranularity: .minute)
                    if comparison != .orderedSame {
                        ekReminder.removeAlarm(alarm)
                    }
                }
            }
            if !ekReminder.hasAlarms {
                ekReminder.addAlarm(EKAlarm(absoluteDate: reminder.dueDate))
            }
            
            do {
                try self.eventStore.save(ekReminder, commit: true)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    private func readReminder(with id: String, completion: (EKReminder?) -> Void) {
        guard isAvailable else {
            completion(nil)
            return
        }
        
        guard let calendarItem = eventStore.calendarItem(withIdentifier: id),
              let ekReminder = calendarItem as? EKReminder else {
                  completion(nil)
                  return
              }
        
        completion(ekReminder)
    }
}
