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
    var titleLabel: UILabel = UILabel()
    var contentLabel: UILabel = UILabel()
    
    func initialTableViewCell(width: CGFloat, height: CGFloat) {
        titleLabel.frame = CGRectMake(20, 0, width / 2, 44)
        self.contentView.addSubview(titleLabel)
        
        contentLabel.frame = CGRectMake(width - 30 - 100, 0, 100, 44)
        self.contentView.addSubview(contentLabel)
    }
    
    
}