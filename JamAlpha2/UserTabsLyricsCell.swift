//
//  UserTabsLyricsCell.swift
//  JamAlpha2
//
//  Created by Song Liao on 12/24/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit



class UserTabsLyricsCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var optionsButton: UIButton!
    
    
    @IBOutlet weak var searchIcon: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var titleRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subtitleRightConstraint: NSLayoutConstraint!
}
