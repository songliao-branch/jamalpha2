//
//  PopOver.swift
//  PopOverSlider
//
//  Created by Anne Dong on 8/27/15.
//  Copyright (c) 2015 Xin Fang. All rights reserved.
//

import UIKit

class PopOver: UIView {

    var textLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textLabel = UILabel(frame: CGRectZero)
        self.textLabel.backgroundColor = UIColor.clearColor()
        self.textLabel.textColor = UIColor.whiteColor()
        self.textLabel.font = UIFont.boldSystemFontOfSize(13)
        self.textLabel.textAlignment = NSTextAlignment.Center
        self.textLabel.adjustsFontSizeToFitWidth = true
        self.opaque = false
        
        var y:CGFloat = ( frame.size.height - 26 ) / 3
        if(frame.size.height < 38 ){
            y = 0
        }
        
        self.textLabel.frame = CGRectMake(0, y, frame.size.width, 26)
        self.addSubview(self.textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect:CGRect){
        //// General Declarations
        var colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        var context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        //// Color Declarations
        var gradientColor:UIColor = UIColor(red: 0.267, green: 0.303, blue: 0.335, alpha: 1)
        var gradientColor2:UIColor = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1)
        var shadowColor2:UIColor = UIColor(red: 0.524, green: 0.553, blue: 0.581, alpha: 0.3)
        
        //// Gradient Declarations
        var gradientColors:CFArray = [gradientColor.CGColor,gradientColor2.CGColor]
        
        var gradientLocations:[CGFloat] = [0, 1]
        var gradient:CGGradientRef = CGGradientCreateWithColors(colorSpace, gradientColors, gradientLocations)!
        
        //// Shadow Declarations
        var innerShadow:UIColor = shadowColor2
        var innerShadowOffset:CGSize = CGSizeMake(0, 1.5)
        var innerShadowBlurRadius:CGFloat = 0.5
        
        //// Frames
        var frame:CGRect = self.bounds
        
        //// Subframes
        var frame2:CGRect = CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 11) * 0.51724 + 0.5), CGRectGetMinY(frame) + CGRectGetHeight(frame) - 9, 11, 9)
        
        
        //// Bezier Drawing
        var bezierPath:UIBezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(CGRectGetMaxX(frame) - 0.5, CGRectGetMinY(frame) + 4.5))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMaxX(frame) - 0.5, CGRectGetMaxY(frame) - 11.5))
        bezierPath.addCurveToPoint(CGPointMake(CGRectGetMaxX(frame) - 4.5, CGRectGetMaxY(frame) - 7.5), controlPoint1: CGPointMake(CGRectGetMaxX(frame) - 0.5, CGRectGetMaxY(frame) - 9.29), controlPoint2: CGPointMake(CGRectGetMaxX(frame) - 2.29, CGRectGetMaxY(frame) - 7.5))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame2) + 10.64, CGRectGetMinY(frame2) + 1.5))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame2) + 5.5, CGRectGetMinY(frame2) + 8))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame2) + 0.36, CGRectGetMinY(frame2) + 1.5))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 4.5, CGRectGetMaxY(frame) - 7.5))
        bezierPath.addCurveToPoint(CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 11.5), controlPoint1: CGPointMake(CGRectGetMinX(frame) + 2.29, CGRectGetMaxY(frame) - 7.5), controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMaxY(frame) - 9.29))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 4.5))
        bezierPath.addCurveToPoint(CGPointMake(CGRectGetMinX(frame) + 4.5, CGRectGetMinY(frame) + 0.5), controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 2.29), controlPoint2: CGPointMake(CGRectGetMinX(frame) + 2.29, CGRectGetMinY(frame) + 0.5))
        bezierPath.addLineToPoint(CGPointMake(CGRectGetMaxX(frame) - 4.5, CGRectGetMinY(frame) + 0.5))
        bezierPath.addCurveToPoint(CGPointMake(CGRectGetMaxX(frame) - 0.5, CGRectGetMinY(frame) + 4.5), controlPoint1: CGPointMake(CGRectGetMaxX(frame) - 2.29, CGRectGetMinY(frame) + 0.5), controlPoint2: CGPointMake(CGRectGetMaxX(frame) - 0.5, CGRectGetMinY(frame) + 2.29))
        bezierPath.closePath()
        CGContextSaveGState(context)
        bezierPath.addClip()
        var bezierBounds:CGRect = bezierPath.bounds
        
//        CGContextDrawLinearGradient(context, gradient,
//            CGPointMake(CGRectGetMidX(bezierBounds), CGRectGetMinY(bezierBounds)),
//            CGPointMake(CGRectGetMidX(bezierBounds), CGRectGetMaxY(bezierBounds)),
//            CGGradientDrawingOptions)
//        CGContextRestoreGState(context);
//        
        ////// Bezier Inner Shadow
        var bezierBorderRect:CGRect = CGRectInset(bezierPath.bounds, -innerShadowBlurRadius, -innerShadowBlurRadius)
        bezierBorderRect = CGRectOffset(bezierBorderRect, -innerShadowOffset.width, -innerShadowOffset.height);
        bezierBorderRect = CGRectInset(CGRectUnion(bezierBorderRect, bezierPath.bounds), -1, -1);
        
        var bezierNegativePath:UIBezierPath = UIBezierPath(rect: bezierBorderRect)
        bezierNegativePath.appendPath(bezierPath)
        bezierNegativePath.usesEvenOddFillRule = true
        
        CGContextSaveGState(context)
        
            var xOffset:CGFloat = innerShadowOffset.width + round(bezierBorderRect.size.width)
            var yOffset:CGFloat = innerShadowOffset.height
            CGContextSetShadowWithColor(context,
                CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                innerShadowBlurRadius,
                innerShadow.CGColor)
            
            bezierPath.addClip()
            var transform:CGAffineTransform = CGAffineTransformMakeTranslation(-round(bezierBorderRect.size.width), 0)
            bezierNegativePath.applyTransform(transform)
            UIColor.grayColor().setFill()
            bezierNegativePath.fill()
        
        CGContextRestoreGState(context)
        
        UIColor.blackColor().setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        
    }

}
