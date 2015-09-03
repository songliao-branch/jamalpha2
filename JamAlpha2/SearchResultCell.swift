//
//  InAppSearchResultCell.swift
//  JamAlpha2
//
//  Created by Song Liao on 7/21/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit
import Alamofire

class SearchResultCell: UITableViewCell {

    var request: Alamofire.Request?
    @IBOutlet weak var albumCover: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
