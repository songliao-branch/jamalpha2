//
//  MeProfile1TableViewCell.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/16/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit
class MeUserProfileTableViewCell: UITableViewCell {
    var userImage: UIImageView = UIImageView()
    var userNameLabel: UILabel = UILabel()
    
    func initialTableViewCell(width: CGFloat, height: CGFloat) {
        let imageWidth: CGFloat = 0.8 * height
        userImage.frame = CGRectMake(0.1 * width, 0.1 * height, imageWidth, imageWidth)
        userImage.layer.cornerRadius = 0.5 * imageWidth
        userImage.layer.borderWidth = 1
        self.contentView.addSubview(userImage)
        
        userNameLabel.frame = CGRectMake(0.35 * width, 0.2 * height, 0.4 * width, 0.6 * height)
        userNameLabel.layer.borderWidth = 1
        self.contentView.addSubview(userNameLabel)
    }
}
