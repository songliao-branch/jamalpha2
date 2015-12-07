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
    var userImageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()

    
    func initialTableViewCell(width: CGFloat, height: CGFloat) {
        let imageWidth: CGFloat = 60
        userImageView.frame = CGRectMake(width - 30 - imageWidth, 12, imageWidth, imageWidth)
        userImageView.layer.cornerRadius = 0.5 * imageWidth
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor.backgroundGray().CGColor
        let imageLayer: CALayer = userImageView.layer
        imageLayer.cornerRadius = 0.5 * imageWidth
        imageLayer.masksToBounds = true
        self.contentView.addSubview(userImageView)
        
        titleLabel.frame = CGRectMake(20, 22, width / 2, 44)
        self.contentView.addSubview(titleLabel)

    }
}
