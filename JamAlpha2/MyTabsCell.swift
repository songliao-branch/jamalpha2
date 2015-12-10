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
        
        uploadedImageView.frame = CGRectMake(width - 5 - 60 - 10 - 20, 20, 20, 20)
        uploadedImageView.image = UIImage(named: "uploaded")
        uploadedImageView.alpha = 0
        self.contentView.addSubview(uploadedImageView)
        
        optionButton.frame = CGRectMake(width - 5 - 60, 0, 60, 60)
        optionButton.layer.cornerRadius = 0.5 * 60
        optionButton.layer.borderWidth = 1
        self.contentView.addSubview(optionButton)
    }
}