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
    
    func initialCell(frame frame: CGRect) {
        
        numberLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 30, height: 18))
        numberLabel.textColor = UIColor.grayColor()
        numberLabel.font = UIFont.systemFontOfSize(15)
        numberLabel.center.y = frame.height/2
        self.contentView.addSubview(numberLabel)
        
        let labelHeight: CGFloat = 25
        songNameLabel.frame = CGRectMake(CGRectGetMaxX(numberLabel.frame), 0, frame.width - CGRectGetMaxX(numberLabel.frame) - 50, 25)
        songNameLabel.font = UIFont.systemFontOfSize(17)
        songNameLabel.center.y = frame.height/2 - labelHeight
        self.contentView.addSubview(songNameLabel)
        
        singerNameLabel.frame = CGRectMake(45, 36, width / 2, 20)
        singerNameLabel.textColor = UIColor.darkGrayColor()
        singerNameLabel.font = UIFont.systemFontOfSize(15)
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