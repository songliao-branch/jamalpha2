//
//  BrowseTabsCell.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/8/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class BrowseVersionsCell: UITableViewCell {

    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!

    @IBOutlet weak var votesLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //customize cell background view when this is selected. Since this cell looks like a box so when it is selected, the highlight color must be wrapped inside the box
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectedBackgroundView?.backgroundColor = UIColor.backgroundGray()
        //8 is origin x and origin y of the box, y is the border length
        let border: CGFloat = 8.3
        self.selectedBackgroundView?.frame = CGRectMake(border, border, self.frame.width-border*2, self.frame.height-border)
    }
}
