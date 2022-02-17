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
    private var reminderEditAction: ReminderChangeAction?
    private var reminderAddAction: ReminderChangeAction?
    private var isNew = false
    
    private var navigationTitle: String {
        if isNew  {
            return NSLocalizedString("Add Reminder", comment: "add reminder nav title")
        }
        
        return NSLocalizedString("Edit Reminder", comment: "edit reminder nav title")
    }
    
    func configure(with reminder: Reminder, isNew: Bool = false, addAction: ReminderChangeAction? = nil, editAction: ReminderChangeAction? = nil) {
        self.reminder = reminder
        self.isNew = isNew
        self.reminderAddAction = addAction
        self.reminderEditAction = editAction
        
        if isViewLoaded {
            self.setEditing(isNew, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEditing(isNew, animated: false)
        navigationItem.setRightBarButton(editButtonItem, animated: false)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReminderDetailEditDataSource.dateLabelCellIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigationController = navigationController, !navigationController.isToolbarHidden {
            navigationController.setToolbarHidden(true, animated: animated)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        guard let reminder = reminder else {
            fatalError("No reminder found for detail view")
        }
        
        if editing  {
            self.transitionToEdit(reminder)
            tableView.backgroundColor = UIColor(named: "EDIT_Background")
        }
        else {
            self.transitionToView(reminder)
            tableView.backgroundColor = UIColor(named: "VIEW_Background")
        }
        
        tableView.dataSource = self.dataSource
        tableView.reloadData()
    }
    
    @objc
    func cancelButtonTrigger() {
        if isNew {
            dismiss(animated: true)
        } else {
            self.setEditing(false, animated: true)
        }
    }
    
    fileprivate func transitionToView(_ reminder: Reminder) {
        if isNew {
            let addReminder = tempReminder ?? reminder
                dismiss(animated: true) {
                self.reminderAddAction?(addReminder)
            }
            return
        }
        if let tempReminder = tempReminder {
            self.reminder = tempReminder
            self.tempReminder = nil
            reminderEditAction?(tempReminder)
            dataSource = ReminderViewDetailDataSource(reminder: tempReminder)
        } else {
            dataSource = ReminderViewDetailDataSource(reminder: reminder)
        }
        navigationItem.title = NSLocalizedString("View Reminder", comment: "view reminder nav title")
        navigationItem.leftBarButtonItem = nil
        editButtonItem.isEnabled = true
    }
    
    fileprivate func transitionToEdit(_ reminder: Reminder) {
        self.dataSource = ReminderDetailEditDataSource(reminder: reminder) { reminder in
            self.tempReminder = reminder
            self.editButtonItem.isEnabled = true
        }
        navigationItem.title = self.navigationTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTrigger))
    }
}

extension ReminderDetailViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isEditing {
            cell.backgroundColor = UIColor(named: "EDIT_TableRowBackground")
            guard let editSection = ReminderDetailEditDataSource.ReminderSection(rawValue: indexPath.section) else {
                return
            }
            if editSection == .dueDate, indexPath.row == 0 {
                cell.textLabel?.textColor = UIColor(named: "EDIT_DateLabelText")
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            }
        }
        else {
            cell.backgroundColor = .systemBackground
            guard let viewRow = ReminderViewDetailDataSource.ReminderRow(rawValue: indexPath.row) else {
                return
            }
            
            if viewRow == .title {
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            }
            else {
                cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            }
        }
    }
}
