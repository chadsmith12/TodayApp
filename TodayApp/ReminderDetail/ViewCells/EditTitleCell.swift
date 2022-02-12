//
//  EditTitleCell.swift
//  TodayApp
//
//  Created by Chad Smith on 2/7/22.
//

import UIKit

class EditTitleCell: UITableViewCell {
    typealias TitleChangeAction = (String) -> Void
    
    @IBOutlet var titleTextField: UITextField!
    
    private var titleChangeAction: TitleChangeAction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.delegate = self
    }
    
    func configure(title: String, changeAction: @escaping TitleChangeAction) {
        self.titleTextField.text = title
    }
}

extension EditTitleCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            titleChangeAction?(title)
        }
        
        return true
    }
}
