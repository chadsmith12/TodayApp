//
//  EditNotesCell.swift
//  TodayApp
//
//  Created by Chad Smith on 2/7/22.
//

import UIKit

class EditNotesCell: UITableViewCell {
    @IBOutlet var notesTextView: UITextView!
    
    func configure(notes: String?) {
        self.notesTextView.text = notes
    }
}
