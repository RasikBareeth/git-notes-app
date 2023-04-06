//
//  NoteCell.swift
//  LMANotes
//
//  Created by Rasik Bareeth on 29/03/23.
//  Copyright © 2023 Application. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    static let cellId = "NoteCell"
    static let cellHeight: CGFloat = 84

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
