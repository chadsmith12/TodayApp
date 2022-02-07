//
//  ViewController.swift
//  TodayApp
//
//  Created by Chad Smith on 2/5/22.
//

import UIKit

class ReminderListViewController: UITableViewController {
    private static let showReminderDetailSegueIdentifier = "ShowReminderDetailSegue"
    private var reminderListDataSource: ReminderListDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderListDataSource = ReminderListDataSource()
        tableView.dataSource =  reminderListDataSource
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.showReminderDetailSegueIdentifier,
           let destination = segue.destination as? ReminderDetailViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            let reminder = Reminder.testData[indexPath.row]
            destination.configure(with: reminder)
        }
    }
}
