//
//  ReminderDetailViewController.swift
//  TodayApp
//
//  Created by Chad Smith on 2/6/22.
//

import UIKit

class ReminderDetailViewController: UITableViewController {
    private var reminder: Reminder?
    private var dataSource: UITableViewDataSource?
    
    func configure(with reminder: Reminder) {
        self.reminder = reminder
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
            self.dataSource = ReminderDetailEditDataSource(reminder: reminder)
            navigationItem.title = NSLocalizedString("Edit Reminder", comment: "edit reminder nav item")
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTrigger))
        }
        else {
            self.dataSource = ReminderViewDetailDataSource(reminder: reminder)
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
