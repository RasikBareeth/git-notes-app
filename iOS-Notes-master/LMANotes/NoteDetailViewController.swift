//
//  NoteDetailViewController.swift
//  LMANotes
//
//  Created by Rasik Bareeth on 29/03/23.
//  Copyright © 2023 Application. All rights reserved.
//

import UIKit
import FirebaseAuth

class NoteDetailViewController: UIViewController {
    var note: Note?
    weak var delegate: UpdateNote?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    @IBAction func cancelTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DoneTap(_ sender: UIBarButtonItem) {
        self.delegate?.updateNote(titleTextField.text ?? "", [contentTextView.text ?? "", NotesUtility.getDate()])
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.text = note?.title ?? ""
        contentTextView.text = note?.content ?? ""
    }
}
