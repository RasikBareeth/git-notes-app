//
//  AddNoteViewController.swift
//  LMANotes
//
//  Created by Rasik Bareeth on 29/03/23.
//  Copyright © 2023 Application. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
protocol AddNote: AnyObject {
    func addNote(_ note: Note)
}

class AddNoteViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    weak var delegate: AddNote?
    var dataValue: [[String: [String]]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDoneButton(_ sender: UIBarButtonItem) {
        guard let text = titleTextField.text else { return }
        guard let content = contentTextView.text else { return }
        
        if text == "" || content == "" {
            return
        }
        
        print(text)
        print(content)
        if let email = Auth.auth().currentUser?.email {
            let emailArrAtt = email.components(separatedBy: "@")
            if let emailArr = emailArrAtt.first?.components(separatedBy: ".") {
                if let value = dataValue {
                    var obj = value
                    obj.append([text: [content, NotesUtility.getDate()]])
                    Database.database().reference().child(emailArr[0]).setValue(obj)
                }else {
                    let obj: [[String: [String]]] = [[text: [content, NotesUtility.getDate()]]]
                    Database.database().reference().child(emailArr[0]).setValue(obj)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

class NotesUtility {
    static func getDate() -> String {
        let date = Date()
        let calendar = Calendar.current
        return "\(calendar.component(.year, from: date))-\(calendar.component(.month, from: date))-\(calendar.component(.day, from: date))"
    }
}
