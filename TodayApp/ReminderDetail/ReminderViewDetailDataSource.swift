//
//  ReminderViewDetailDataSource.swift
//  TodayApp
//
//  Created by Chad Smith on 2/6/22.
//

import UIKit

class ReminderViewDetailDataSource: NSObject {
    enum ReminderRow: Int, CaseIterable {
        case title
        case date
        case time
        case notes
        
        func displayText(for reminder: Reminder?) -> String? {
            switch self {
            case .title:
                return reminder?.title
            case .date:
                return reminder?.dueDate.description
            case .time:
                return reminder?.dueDate.description
            case .notes:
                return reminder?.notes
            }
        }
        
        var cellImage: UIImage? {
            switch self {
            case .title:
                return nil
            case .date:
                return UIImage(systemName: "calendar.circle")
            case .time:
                return UIImage(systemName: "clock")
            case .notes:
                return nil
            }
        }
    }
    
    private var reminder: Reminder?
    
    init(reminder: Reminder) {
        self.reminder = reminder
        super.init()
    }
}

extension ReminderViewDetailDataSource: UITableViewDataSource {
    private static let reminderDetailCellIdentifier = "ReminderDetailCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReminderRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.reminderDetailCellIdentifier, for: indexPath)
        let row = ReminderRow(rawValue: indexPath.row)
        
        cell.textLabel?.text = row?.displayText(for: reminder)
        cell.imageView?.image = row?.cellImage
        
        return cell
    }
}
