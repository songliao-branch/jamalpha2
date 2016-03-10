//
//  TopSongsCell.swift
//  JamAlpha2
//
//  Created by Song Liao on 1/13/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit

class TopSongsCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var titleRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var speaker: UIImageView!
}
