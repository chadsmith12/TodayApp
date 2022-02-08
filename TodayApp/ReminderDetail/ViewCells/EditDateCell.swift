//
//  EditDateCell.swift
//  TodayApp
//
//  Created by Chad Smith on 2/7/22.
//

import UIKit

class EditDateCell: UITableViewCell {
    @IBOutlet var datePicker: UIDatePicker!
    
    func configure(date: Date) {
        self.datePicker.date = date
    }
}
