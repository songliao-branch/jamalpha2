//
//  MyTabsCell.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/10/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit

class MyTabsCell: UITableViewCell {
    var numberLabel: UILabel = UILabel()
    var songNameLabel: UILabel = UILabel()
    var singerNameLabel: UILabel = UILabel()
    var uploadedImageView: UIImageView = UIImageView()
    var optionButton: UIButton = UIButton()
    
    func initialCell(width: CGFloat) {
        
        numberLabel.frame = CGRectMake(15, 19, 22, 22)
        self.contentView.addSubview(numberLabel)
        
        songNameLabel.frame = CGRectMake(42, 4, width / 2, 36)
        self.contentView.addSubview(songNameLabel)
        
        singerNameLabel.frame = CGRectMake(45, 36, width / 2, 20)
        self.contentView.addSubview(singerNameLabel)
        
        uploadedImageView.frame = CGRectMake(width - 5 - 55 - 10 - 30, 15, 30, 30)
        uploadedImageView.image = UIImage(named: "uploaded")
        uploadedImageView.alpha = 0
        self.contentView.addSubview(uploadedImageView)
        
        optionButton.frame = CGRectMake(width - 5 - 60, 2.5, 55, 55)
        optionButton.setImage(UIImage(named: "option"), forState: UIControlState.Normal)
        self.contentView.addSubview(optionButton)
    }
}