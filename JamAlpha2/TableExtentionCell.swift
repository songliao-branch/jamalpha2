//
//  TableExtentionCell.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/10/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit

class TableExtensionCell: UITableViewCell {
    var uploadButton: UIButton = UIButton()
    var editButton: UIButton = UIButton()
    
    //var removeUploadButton: UIButton = UIButton()
    
    func initialCell(width: CGFloat) {
        let buttonNumber: CGFloat = 4
        let buttonWidth: CGFloat = (width - 20) / buttonNumber
        
        self.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        editButton.frame = CGRectMake(10 + buttonWidth * 0 + 5, 5, buttonWidth - 10, 50)
        editButton.layer.borderWidth = 1
        editButton.layer.cornerRadius = 5
        editButton.setTitle("Edit", forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor.mainPinkColor(), forState: UIControlState.Normal)
        
        uploadButton.frame = CGRectMake(10 + buttonWidth * 1 + 5, 5, buttonWidth - 10, 50)
        uploadButton.layer.borderWidth = 1
        uploadButton.layer.cornerRadius = 5
        uploadButton.setTitle("Upload", forState: UIControlState.Normal)
        uploadButton.setTitleColor(UIColor.mainPinkColor(), forState: UIControlState.Normal)
        
        //removeUploadButton.frame = CGRectMake(10 + buttonWidth * 2 + 5, 5, buttonWidth - 10, 50)
        //removeUploadButton.layer.borderWidth = 1
        //removeUploadButton.setTitle("Remove", forState: UIControlState.Normal)
        //removeUploadButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        
        self.contentView.addSubview(editButton)
        self.contentView.addSubview(uploadButton)
        //self.contentView.addSubview(removeUploadButton)
    }
}