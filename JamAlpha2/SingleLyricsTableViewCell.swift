//
//  SingleLyricsTableViewCell.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/26/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

class SingleLyricsTableViewCell: UITableViewCell {
    var lyricsLabel: UILabel!
    
    func updateLyricsLabel(sender: String, labelAlpha: CGFloat) {
        lyricsLabel.text = sender
        lyricsLabel.alpha = labelAlpha
    }
    
    private func setUpTableViewCell(width: CGFloat, height: CGFloat) {
        lyricsLabel = UILabel()
        lyricsLabel.textColor = UIColor.whiteColor()
        lyricsLabel.font = UIFont.systemFontOfSize(16)
        lyricsLabel.textAlignment = NSTextAlignment.Center
        lyricsLabel.numberOfLines = 0
        lyricsLabel.lineBreakMode = .ByWordWrapping
        lyricsLabel.frame = CGRectMake(15, 11, width - 30, height - 22)
        lyricsLabel.backgroundColor = UIColor.clearColor()
        lyricsLabel.alpha = 1
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(lyricsLabel)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpTableViewCell(UIScreen.mainScreen().bounds.width - 40, height: 66)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}