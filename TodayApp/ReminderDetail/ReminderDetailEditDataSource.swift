//
//  ReminderDetailEditDataSource.swift
//  TodayApp
//
//  Created by Chad Smith on 2/7/22.
//

import UIKit
import TodayAppShared

class ReminderDetailEditDataSource: NSObject  {
    typealias ReminderChangeAction = (Reminder) -> Void
    
    enum ReminderSection: Int, CaseIterable {
        case title
        case dueDate
        case notes
        
        var displayText: String {
            switch self {
            case .title:
                return "Title"
            case .dueDate:
                return "Date"
            case .notes:
                return "Notes"
            }
        }
        
        var numberRows: Int  {
            switch self {
            case .title, .notes:
                return 1
            case .dueDate:
                return 2
            }
        }
        
        func cellIdentifier(for row: Int) -> String {
            switch self {
            case .title:
                return "EditTitleCell"
            case .dueDate:
                return row == 0 ? "EditDateLabelCell" : "EditDateCell"
            case .notes:
                return "EditNotesCell"
            }
        }
    }
    
    static var dateLabelCellIdentifier: String {
        return  ReminderSection.dueDate.cellIdentifier(for: 0)
    }
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var reminderChangeAction: ReminderChangeAction?
    var reminder: Reminder
    
    init(reminder: Reminder, changeAction: @escaping ReminderChangeAction) {
        self.reminder = reminder
        self.reminderChangeAction = changeAction
    }
    
    private func dequeAndConfigureCell(for indexPath: IndexPath, from tableView: UITableView) -> UITableViewCell {
        guard let section = ReminderSection(rawValue: indexPath.section) else {
            fatalError("Reminder Section is out of range!")
        }
        
        let identifier = section.cellIdentifier(for: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch section {
        case .title:
            if let titleCell = cell as? EditTitleCell {
                titleCell.configure(title: reminder.title) { title in
                    self.reminder.title = title
                    self.reminderChangeAction?(self.reminder)
                }
            }
        case .dueDate:
            if indexPath.row == 0 {
                cell.textLabel?.text = formatter.string(from: reminder.dueDate)
            } else {
                if let dueDateCell = cell as? EditDateCell  {
                    dueDateCell.configure(date: reminder.dueDate) {dueDate in
                        self.reminder.dueDate = dueDate
                        self.reminderChangeAction?(self.reminder)
                        let indexPath = IndexPath(row: 0, section: section.rawValue)
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        case .notes:
            if let notesCell = cell as? EditNotesCell {
                notesCell.configure(notes: reminder.notes) { notes in
                    self.reminder.notes = notes
                    self.reminderChangeAction?(self.reminder)
                }
            }
        }
        
        return cell
    }
}

extension ReminderDetailEditDataSource: UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReminderSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReminderSection(rawValue: section)?.numberRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dequeAndConfigureCell(for: indexPath, from: tableView)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = ReminderSection(rawValue: section) else {
            fatalError("Section index out of range")
        }
        
        return section.displayText
    }
    
    func  tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
