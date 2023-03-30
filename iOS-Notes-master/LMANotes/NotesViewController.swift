//
//  NotesViewController.swift
//  LMANotes
//
//  Created by Rasik Bareeth on 29/03/23.
//  Copyright © 2023 Application. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseAuth

struct Note: Codable {
    let title: String
    let content: String
}
protocol UpdateNote: AnyObject {
    func updateNote(_ forKey: String, _ forvalue: String)
}
class NotesViewController: UIViewController, AddNote, UpdateNote {
    @IBOutlet weak var tableView: UITableView!
    var rightBarButton = UIBarButtonItem()
    var data = DataSnapshot()
    var email = ""
    var count = UInt()
    var selectedIndex = 0
    var notes: [Note] = [
        Note(title: "Basic Programming thing", content: "variables, contants, data types, array, loop, fuctions, etc..")
    ]
    var FirebaseNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email = Auth.auth().currentUser?.email ?? ""
        setupTableView()
        rightBarButton = UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addButtonPressingAction))
        rightBarButton.isAccessibilityElement = true
        self.navigationItem.rightBarButtonItem = rightBarButton
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let emailArrAtt = email.components(separatedBy: "@")
        if let emailArr = emailArrAtt.first?.components(separatedBy: ".") {
            Database.database().reference().child(emailArr[0]).observe(.value) { snapshot in
                self.data = snapshot
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    func updateData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notes)
            UserDefaults.standard.set(data, forKey: "note")
        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }
    
    @objc func addButtonPressingAction() {
        performSegue(withIdentifier: "addNotes", sender: self)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        setupCell()
    }
    
    func setupCell() {
        let nib = UINib(nibName: "NoteCell", bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: NoteCell.cellId)
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SEGUE_NOTE_DETAIL" {
            if let navigationController = segue.destination as? UINavigationController, let vc = navigationController.viewControllers.first as? NoteDetailViewController {
                if let senderArray = sender as? [Any], let note = senderArray[0] as? Note, let delegate = senderArray[1] as? NotesViewController {
                    vc.note = note
                    vc.delegate = delegate
                }
            }
        }else if segue.identifier == "addNotes" {
            if let navigationController = segue.destination as? UINavigationController, let vc = navigationController.viewControllers.first as? AddNoteViewController{
                if let value = self.data.value as? [[String: String]] {
                    vc.dataValue = value
                }
                vc.delegate = self
            }
        }
    }
    
    func updateNote(_ forKey: String, _ forvalue: String) {
        if let note = self.data.value as? [[String: String]] {
            var updatedNote = note
            updatedNote[selectedIndex][forKey] = forvalue
            if let email = Auth.auth().currentUser?.email {
                let emailArrAtt = email.components(separatedBy: "@")
                if let emailArr = emailArrAtt.first?.components(separatedBy: ".") {
                    Database.database().reference().child(emailArr[0]).setValue(updatedNote)
                }
            }
        }
    }
    
    func getData() {
        if let data = UserDefaults.standard.data(forKey: "notes") {
            do {
                let decoder = JSONDecoder()
                _ = try decoder.decode([Note].self, from: data)
                
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let note = self.data.value as? [[String: String]] {
            return note.count
        }
        return 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.cellId, for: indexPath) as! NoteCell
        if let note = self.data.value as? [[String: String]] {
            if note.indices.contains(indexPath.row) {
                let keysArray = Array(note[indexPath.row].keys)
                cell.titleLabel.text = keysArray[0]
                cell.contentLabel.text = note[indexPath.row][keysArray[0]]
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NoteCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let note = self.data.value as? [[String: String]] {
            let keysArray = Array(note[indexPath.row].keys)
            FirebaseNote = Note.init(title: keysArray[0], content: note[indexPath.row][keysArray[0]] ?? "")
            if let FirebaseNote = FirebaseNote {
                performSegue(withIdentifier: "SEGUE_NOTE_DETAIL", sender: [FirebaseNote, self])
            }
        }
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let note = self.data.value as? [[String: String]] {
                var updatedNote = note
                let keysArray = Array(note[indexPath.row].keys)
                updatedNote[indexPath.row][keysArray[0]] = nil
                if let email = Auth.auth().currentUser?.email {
                    let emailArrAtt = email.components(separatedBy: "@")
                    if let emailArr = emailArrAtt.first?.components(separatedBy: ".") {
                        Database.database().reference().child(emailArr[0]).setValue(updatedNote)
                    }
                }
            }
            tableView.reloadData()
            
        }
    }
    
}
protocol LoginDelegate: NSObject {
  func loginDidOccur()
}

extension UIViewController {
  public func displayError(_ error: Error?, from function: StaticString = #function) {
    guard let error = error else { return }
    print("ⓧ Error in \(function): \(error.localizedDescription)")
    let message = "\(error.localizedDescription)\n\n Ocurred in \(function)"
    let errorAlertController = UIAlertController(
      title: "Error",
      message: message,
      preferredStyle: .alert
    )
    errorAlertController.addAction(UIAlertAction(title: "OK", style: .default))
    present(errorAlertController, animated: true, completion: nil)
  }
}

extension UIColor {
  static let highlightedLabel = UIColor.label.withAlphaComponent(0.8)

  var highlighted: UIColor { withAlphaComponent(0.8) }

  var image: UIImage {
    let pixel = CGSize(width: 1, height: 1)
    return UIGraphicsImageRenderer(size: pixel).image { context in
      self.setFill()
      context.fill(CGRect(origin: .zero, size: pixel))
    }
  }
}

extension UINavigationController {
  func configureTabBar(title: String, systemImageName: String) {
    let tabBarItemImage = UIImage(systemName: systemImageName)
    tabBarItem = UITabBarItem(title: title,
                              image: tabBarItemImage?.withRenderingMode(.alwaysTemplate),
                              selectedImage: tabBarItemImage)
  }

  enum titleType: CaseIterable {
    case regular, large
  }

  func setTitleColor(_ color: UIColor, _ types: [titleType] = titleType.allCases) {
    if types.contains(.regular) {
      navigationBar.titleTextAttributes = [.foregroundColor: color]
    }
    if types.contains(.large) {
      navigationBar.largeTitleTextAttributes = [.foregroundColor: color]
    }
  }
}
extension UIImageView {
  convenience init(systemImageName: String, tintColor: UIColor? = nil) {
    var systemImage = UIImage(systemName: systemImageName)
    if let tintColor = tintColor {
      systemImage = systemImage?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
    }
    self.init(image: systemImage)
  }

  func setImage(from url: URL?) {
    guard let url = url else { return }
    DispatchQueue.global(qos: .background).async {
      guard let data = try? Data(contentsOf: url) else { return }

      let image = UIImage(data: data)
      DispatchQueue.main.async {
        self.image = image
        self.contentMode = .scaleAspectFit
      }
    }
  }
}
extension UITextField {
  func setImage(_ image: UIImage?) {
    guard let image = image else { return }
    let imageView = UIImageView(image: image)
    imageView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
    imageView.contentMode = .scaleAspectFit

    let containerView = UIView()
    containerView.frame = CGRect(x: 20, y: 0, width: 40, height: 40)
    containerView.addSubview(imageView)
    leftView = containerView
    leftViewMode = .always
  }
}
