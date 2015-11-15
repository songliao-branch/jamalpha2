//
//  BorderdCellView.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/15/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

@IBDesignable
class BorderdCellView: UIView {


    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        self.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1).CGColor
        self.layer.borderWidth = 0.3
    }

}
