//
//  EditDateCell.swift
//  TodayApp
//
//  Created by Chad Smith on 2/7/22.
//

import UIKit

class EditDateCell: UITableViewCell {
    typealias DateChangeAction = (Date) -> Void
    
    @IBOutlet var datePicker: UIDatePicker!
    private var dateChangeAction: DateChangeAction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    func configure(date: Date, changeAction: @escaping  DateChangeAction) {
        self.datePicker.date = date
        self.dateChangeAction = changeAction
    }
    
    @objc
    func dateChanged(_ sender: UIDatePicker) {
        self.dateChangeAction?(sender.date)
    }
}
