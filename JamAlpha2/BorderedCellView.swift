//
//  BorderdCellView.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/15/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedCellView: UIView {

    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        self.layer.borderColor = UIColor.borderCellColor().CGColor
        self.layer.borderWidth = 0.3
    }
}
