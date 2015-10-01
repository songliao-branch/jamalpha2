//
//  CountdownView.swift
//  JamAlpha2
//
//  Created by Song Liao on 10/1/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

@IBDesignable
class CountdownView: UIView {

    override func drawRect(rect: CGRect) {
        // paint code
        let context = UIGraphicsGetCurrentContext()
        self.backgroundColor = UIColor.clearColor()
        //// Color Declarations
        let color = UIColor.mainPinkColor().colorWithAlphaComponent(0.5)
        
        //// Shadow Declarations
        let shadow2 = NSShadow()
        shadow2.shadowColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.5)
        shadow2.shadowOffset = CGSizeMake(1.1, 3.1)
        shadow2.shadowBlurRadius = 5
        
        //// Oval Drawing
        let margin: CGFloat = 5
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(margin, margin, rect.width-margin*2, rect.height-margin*2))
        color.setFill()
        ovalPath.fill()
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2.shadowOffset, shadow2.shadowBlurRadius, (shadow2.shadowColor as! UIColor).CGColor)
        color.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()
        CGContextRestoreGState(context)
        
        //add label
        numberLabel = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 35, height: 35)))
        numberLabel.textColor = UIColor.whiteColor()
        numberLabel.font = UIFont.systemFontOfSize(35)
        numberLabel.sizeToFit()
        numberLabel.center = CGPoint(x: rect.width/2, y: rect.height/2)
        self.addSubview(numberLabel)
    }
    
    var numberLabel: UILabel!
    
    func setNumber(number: Int) {
        numberLabel.text = String(number)
        numberLabel.sizeToFit()
        numberLabel.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
    }
}
