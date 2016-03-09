//
//  SettingFBLikeCell.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/5/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class SettingFBCell: UITableViewCell {
    var titleLabel: UILabel = UILabel()
    var likeControl: FBSDKLikeControl = FBSDKLikeControl()
    
    func initialCell(width: CGFloat) {
        titleLabel.frame = CGRectMake(15, 0, width / 2, 44)
        self.contentView.addSubview(titleLabel)
    
        likeControl.objectType = FBSDKLikeObjectType.Page
        likeControl.likeControlStyle = FBSDKLikeControlStyle.BoxCount
        likeControl.objectID = FACEBOOK_PAGE_URL
        likeControl.frame = CGRectMake(width - 15 - 110, 7, 88, 33)
        self.contentView.addSubview(likeControl)
    }
}

func schemeAvailable(scheme: String) -> Bool {
  if let url = NSURL.init(string: scheme) {
    return UIApplication.sharedApplication().canOpenURL(url)
  }
  return false
}