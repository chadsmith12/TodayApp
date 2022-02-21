//
//  ViewController.swift
//  TodayApp
//
//  Created by Chad Smith on 2/5/22.
//

import UIKit
import TodayAppShared

class ReminderListViewController: UITableViewController {
    private static let showReminderDetailSegueIdentifier = "ShowReminderDetailSegue"
    private static let mainStoryboardIdentifier = "Main"
    private static let detailViewControllerIdentifier = "ReminderDetailViewController"
    
    private var reminderListDataSource: ReminderListDataSource?
    private var filter: Filter {
        return Filter(rawValue: filterSegmentedControl.selectedSegmentIndex) ?? .today
    }
    
    @IBOutlet var filterSegmentedControl: UISegmentedControl!
    @IBOutlet var progressContainerView: UIView!
    @IBOutlet var percentCompleteView: UIView!
    @IBOutlet var percentIncompleteView: UIView!
    @IBOutlet var percentCompleteHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderListDataSource = ReminderListDataSource(reminderCompletedAction: onReminderComplete, reminderDeletedAction: onReminderDeleted, remindersChangedAction: onRemindersChanged)
        tableView.dataSource =  reminderListDataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let radius = view.bounds.width * 0.5 * 0.7
        progressContainerView.layer.cornerRadius = radius
        progressContainerView.layer.masksToBounds = true
        self.refreshProgressView()
        self.refreshBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navigationController = navigationController, navigationController.isToolbarHidden {
            navigationController.setToolbarHidden(false, animated: animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.showReminderDetailSegueIdentifier,
           let destination = segue.destination as? ReminderDetailViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            let rowIndex = indexPath.row
            guard let reminder = reminderListDataSource?.reminder(at: rowIndex) else {
                fatalError("Couldn't find datasource for reminder list")
            }
            destination.configure(with: reminder, editAction: { reminder in
                self.reminderListDataSource?.update(reminder, at: rowIndex) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshProgressView()
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alertTitle = NSLocalizedString("Can't Update Reminder", comment: "error updating reminder title")
                            let alertMessage = NSLocalizedString("An error occured while attempting to update the reminder", comment: "error updating reminder message")
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                            let actionTitle = NSLocalizedString("OK", comment: "ok action title")
                            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func addButtonTriggered(_ sender: UIBarButtonItem) {
        addReminder()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        reminderListDataSource?.filter = filter
        tableView.reloadData()
        self.refreshProgressView()
        self.refreshBackground()
    }
    
    private func addReminder() {
        let storyboard = UIStoryboard(name: Self.mainStoryboardIdentifier, bundle: nil)
        let detailViewControler = storyboard.instantiateViewController(withIdentifier: Self.detailViewControllerIdentifier) as! ReminderDetailViewController
        let reminder = Reminder(id: UUID().uuidString, title: "New Reminder", dueDate: Date())
        detailViewControler.configure(with: reminder, isNew: true, addAction: { reminder in
            self.reminderListDataSource?.add(reminder, completion: { index in
                if let index = index {
                    DispatchQueue.main.async {
                        self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        self.refreshProgressView()
                    }
                }
            })
        })
        let navigationController = UINavigationController(rootViewController: detailViewControler)
        present(navigationController, animated: true, completion: nil)
    }
    
    private func refreshProgressView() {
        guard let percentComplete = reminderListDataSource?.percentComplete else {
            return
        }
        
        let totalHeight = progressContainerView.bounds.size.height
        percentCompleteHeightConstraint.constant = totalHeight * CGFloat(percentComplete)
        UIView.animate(withDuration: 0.2) {
            self.progressContainerView.layoutSubviews()
        }
    }
    
    private func onReminderComplete(for at: Int) {
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: at, section: 0)], with: .automatic)
            self.refreshProgressView()
        }
    }
    
    private func onReminderDeleted() {
        DispatchQueue.main.async {
            self.refreshProgressView()
        }
    }
    
    private func onRemindersChanged() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshProgressView()
        }
    }
    
    private func refreshBackground() {
        tableView.backgroundView = nil
        let backgroundView = UIView()
        if let backgroundColors = filter.backgroundColors {
            let gradientBackgroundLayer = CAGradientLayer()
            gradientBackgroundLayer.colors = backgroundColors
            gradientBackgroundLayer.frame = tableView.frame
            backgroundView.layer.addSublayer(gradientBackgroundLayer)
        } else {
            backgroundView.backgroundColor = filter.substitudeBackgroundColor
        }
        tableView.backgroundView = backgroundView
    }
}

fileprivate extension Filter {
    private var gradientBeginColor: UIColor? {
        switch self {
        case .today:
            return UIColor(named: "LIST_GradientTodayBegin")
        case .future:
            return UIColor(named: "LIST_GradientFutureBegin")
        case .all:
            return UIColor(named: "LIST_GradientAllBegin")
        }
    }
    
    private var gradientEndColor: UIColor? {
        switch self {
        case .today:
            return UIColor(named: "LIST_GradientTodayEnd")
        case .future:
            return UIColor(named: "LIST_GradientFutureEnd")
        case .all:
            return UIColor(named: "LIST_GradientAllEnd")
        }
    }
    
    var backgroundColors: [CGColor]? {
        guard let beginColor = gradientBeginColor, let endColor = gradientEndColor else {
            return nil
        }
        
        return [beginColor.cgColor, endColor.cgColor]
    }
    
    var substitudeBackgroundColor: UIColor {
        return gradientBeginColor ?? .tertiarySystemBackground
    }
}
