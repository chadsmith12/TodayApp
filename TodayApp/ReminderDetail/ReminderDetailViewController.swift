//
//  ReminderDetailViewController.swift
//  TodayApp
//
//  Created by Chad Smith on 2/6/22.
//

import UIKit

class ReminderDetailViewController: UITableViewController {
    typealias ReminderChangeAction = (Reminder) -> Void
    
    private var reminder: Reminder?
    private var tempReminder: Reminder?
    private var dataSource: UITableViewDataSource?
    private var reminderChangeAction: ReminderChangeAction?
    
    func configure(with reminder: Reminder, changeAction: @escaping ReminderChangeAction) {
        self.reminder = reminder
        self.reminderChangeAction = changeAction
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEditing(false, animated: false)
        navigationItem.setRightBarButton(editButtonItem, animated: false)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReminderDetailEditDataSource.dateLabelCellIdentifier)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        guard let reminder = reminder else {
            fatalError("No reminder found for detail view")
        }
        
        if editing  {
            self.dataSource = ReminderDetailEditDataSource(reminder: reminder) { reminder in
                self.tempReminder = reminder
                self.editButtonItem.isEnabled = true
            }
            navigationItem.title = NSLocalizedString("Edit Reminder", comment: "edit reminder nav item")
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTrigger))
        }
        else {
            if let tempReminder = tempReminder {
                self.reminder = tempReminder
                self.tempReminder = nil
                self.reminderChangeAction?(tempReminder)
                self.dataSource = ReminderViewDetailDataSource(reminder: tempReminder)
            } else {
                self.dataSource = ReminderViewDetailDataSource(reminder: reminder)
            }
            navigationItem.title = NSLocalizedString("View Reminder", comment: "view reminder nav item")
            navigationItem.leftBarButtonItem = nil
            editButtonItem.isEnabled = true
        }
        
        tableView.dataSource = self.dataSource
        tableView.reloadData()
    }
    
    @objc
    func cancelButtonTrigger() {
        self.setEditing(false, animated: true)
    }
}
