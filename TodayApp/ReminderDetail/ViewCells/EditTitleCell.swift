//
//  EditTitleCell.swift
//  TodayApp
//
//  Created by Chad Smith on 2/7/22.
//

import UIKit

class EditTitleCell: UITableViewCell {
    @IBOutlet var titleTextField: UITextField!
    
    func configure(title: String) {
        self.titleTextField.text = title
    }
}
