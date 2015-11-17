//
//  ProfileTableViewCell.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/4/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit

class MeContentProfileTableViewCell: UITableViewCell {
    var titleImage: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    var arrowImage: UIImageView = UIImageView()
    var footView: UIView = UIView()
    
    func initialTableViewCell(width: CGFloat, height: CGFloat) {
        titleImage.frame = CGRectMake(0.05 * width, 0.15 * height, 0.7 * height, 0.7 * height)
        titleImage.layer.borderWidth = 1
        self.contentView.addSubview(titleImage)
        
        titleLabel.frame = CGRectMake(0.2 * width, 0.15 * height, 0.4 * width, 0.7 * height)
        titleLabel.layer.borderWidth = 1
        self.contentView.addSubview(titleLabel)
        
        arrowImage.frame = CGRectMake( 0.95 * width - 0.7 * height, 0.15 * height, 0.7 * height, 0.7 * height)
        arrowImage.image = UIImage(named: "right_arrow")
        arrowImage.layer.borderWidth = 1
        self.contentView.addSubview(arrowImage)
    }
    
}