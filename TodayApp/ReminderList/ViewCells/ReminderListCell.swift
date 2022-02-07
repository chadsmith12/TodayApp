//
//  ReminderListCell.swift
//  TodayApp
//
//  Created by Chad Smith on 2/5/22.
//

import UIKit

class ReminderListCell: UITableViewCell {
    typealias DoneButtonAction = () -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    private var doneButtonAction: DoneButtonAction?
    
    @IBAction func doneButtonTriggered(_ sender: UIButton) {
        doneButtonAction?()
    }
    
    func configure(title: String, dateText: String, isDone: Bool, doneActionButton: @escaping DoneButtonAction) {
        titleLabel.text = title
        dateLabel.text = dateText
        let image = isDone ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
        doneButton.setBackgroundImage(image, for: .normal)
        self.doneButtonAction = doneActionButton
    }
}
