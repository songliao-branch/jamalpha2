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
    var uploadButton: UIButton = UIButton(type: UIButtonType.Custom)
    var editButton: UIButton = UIButton()
    
    //var removeUploadButton: UIButton = UIButton()
    
    func initialCell(width: CGFloat) {
        let buttonNumber: CGFloat = 4
        let buttonWidth: CGFloat = (width - 20) / buttonNumber
        
        self.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        

        
        editButton.frame = CGRectMake(10 + buttonWidth * 0 + 5, 5, buttonWidth - 10, 50)
        editButton.layer.borderWidth = 1
        editButton.layer.cornerRadius = 5
        editButton.setTitleColor(UIColor.mainPinkColor(), forState: UIControlState.Normal)
        editButton.imageView?.frame = CGRectMake(buttonWidth / 2 - 10, 15, 20, 20)
        editButton.titleLabel?.frame = CGRectMake(buttonWidth / 2 - 10, 15, 20, 20)
        let editImageView: UIImageView = UIImageView(frame: CGRectMake((buttonWidth - 10) / 2 - 10, 2, 20, 20))
        editImageView.image = UIImage(named: "edit")
        editButton.addSubview(editImageView)
        editButton.setTitle("Edit", forState: UIControlState.Normal)
        editButton.titleEdgeInsets = UIEdgeInsetsMake(26, 0, -2, 0)

        uploadButton.frame = CGRectMake(10 + buttonWidth * 1 + 5, 5, buttonWidth - 10, 50)
        uploadButton.layer.borderWidth = 1
        uploadButton.layer.cornerRadius = 5
        uploadButton.setTitle("Upload", forState: UIControlState.Normal)
        uploadButton.titleLabel?.numberOfLines = 0
        uploadButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        uploadButton.titleEdgeInsets = UIEdgeInsetsMake(26, 0, -2, 0)
        let uploadImageView: UIImageView = UIImageView(frame: CGRectMake((buttonWidth - 10) / 2 - 10, 2, 20, 20))
        uploadImageView.image = UIImage(named: "upload")
        uploadButton.addSubview(uploadImageView)
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