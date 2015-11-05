//
//  ProfileTableViewCell.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/4/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit

class ProfileTableViewCell: UITableViewCell {
    var titleLabel: UILabel = UILabel()
    var arrowButton: UIButton = UIButton()
    var footView: UIView = UIView()
    
    func initialTableViewCell(width: CGFloat, height: CGFloat) {
        titleLabel.frame = CGRectMake(0.1 * width, 0.1 * height, 0.4 * width, 0.7 * height)
        titleLabel.layer.borderWidth = 1
        self.contentView.addSubview(titleLabel)
        
        arrowButton.frame = CGRectMake(0.9 * width - 0.7 * height, 0.1 * height, 0.7 * height, 0.7 * height)
        arrowButton.setTitle("Go", forState: UIControlState.Normal)
        arrowButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        arrowButton.layer.borderWidth = 1
        self.contentView.addSubview(arrowButton)
        
        footView.frame = CGRectMake(0, 0.9 * height, width, 0.1 * height)
        footView.backgroundColor = UIColor.grayColor()
        self.contentView.addSubview(footView)
    }

}