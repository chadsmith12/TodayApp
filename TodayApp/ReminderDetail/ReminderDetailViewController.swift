//
//  ReminderDetailViewController.swift
//  TodayApp
//
//  Created by Chad Smith on 2/6/22.
//

import UIKit

class ReminderDetailViewController: UITableViewController {    
    private var reminder: Reminder?
    private var detailViewDataSource: ReminderViewDetailDataSource?
    
    func configure(with reminder: Reminder) {
        self.reminder = reminder
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let reminder = reminder else {
            fatalError("No reminder found for detail view")
        }
        
        self.detailViewDataSource = ReminderViewDetailDataSource(reminder: reminder)
        tableView.dataSource =  self.detailViewDataSource
    }
}
