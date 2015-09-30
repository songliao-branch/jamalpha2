//
//  LyricsSyncTableViewCell.swift
//  lyricsEditorV2
//
//  Created by Jun Zhou on 9/16/15.
//  Copyright (c) 2015 TwistJam. All rights reserved.
//

import Foundation
import UIKit

class LyricsSyncTimeTableViewCell: UITableViewCell {
    
    var lyricsSentenceLabel: UILabel = UILabel()
    var timeView: UIView = UIView()
    var currentTimeLabel: UILabel = UILabel()
    var totalTimeLabel: UILabel = UILabel()
    
    func initialTableViewCell(viewWidth: CGFloat, viewHeight: CGFloat) {
        self.lyricsSentenceLabel.frame = CGRectMake(0.25 / 20 * viewWidth, 0.25 / 31 * viewHeight, 16.75 / 20 * viewWidth, 3.5 / 31 * viewHeight)
        self.lyricsSentenceLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.lyricsSentenceLabel.numberOfLines = 0
        self.lyricsSentenceLabel.textAlignment = NSTextAlignment.Center
        self.lyricsSentenceLabel.textColor = UIColor.whiteColor()
        self.contentView.addSubview(self.lyricsSentenceLabel)
        
        self.timeView.frame = CGRectMake(17 / 20 * viewWidth, 1 / 31 * viewHeight, 2.75 / 20 * viewWidth, 2 / 31 * viewHeight)
        self.timeView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.timeView.layer.cornerRadius = 2
        self.contentView.addSubview(self.timeView)
        
        self.currentTimeLabel.frame = CGRectMake(0, 0, self.timeView.frame.width, self.timeView.frame.height)
        self.currentTimeLabel.font = UIFont.systemFontOfSize(10)
        self.currentTimeLabel.textAlignment = NSTextAlignment.Center
        self.timeView.addSubview(self.currentTimeLabel)
    }
    
    
}