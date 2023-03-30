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

    @IBOutlet weak private var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = note?.title
        contentTextView.text = note?.content
    }
  
    @IBAction func cancelTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DoneTap(_ sender: UIBarButtonItem) {
        self.delegate?.updateNote(title ?? "", contentTextView.text ?? "")
        dismiss(animated: true, completion: nil)
    }
}
