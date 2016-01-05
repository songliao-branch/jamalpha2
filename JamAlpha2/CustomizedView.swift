//
//  customizedView.swift
//  JamAlpha2
//
//  Created by FangXin on 12/27/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit


class CustomizedView: UIView {
    var cornerRadius:CGFloat = 5
    var doubleArrowImage = UIImageView(image: UIImage(named: "doubleArrow"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        setUpDoubleArrow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpDoubleArrow(){
        let width = self.frame.size.width
        let height = self.frame.size.height
        self.doubleArrowImage.frame = CGRectMake(width*2/7, height/5, width*3/7, height*3/5)
        self.doubleArrowImage.image = self.doubleArrowImage.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.doubleArrowImage.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        self.addSubview(self.doubleArrowImage)
    }
    
    
    func insertBlurView (style: UIBlurEffectStyle) {
        self.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.layer.bounds
        blurEffectView.layer.cornerRadius = self.cornerRadius
        self.insertSubview(blurEffectView, atIndex: 0)
    }
    
    
    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath()
        path.lineWidth = 1
        
        let margin:Float = 0
        
        let initialPoint:CGFloat = CGFloat(Float(width) * margin)
        let rightTopPoint:CGFloat = CGFloat(Float(width) * (1 - margin))
        
        
        //calculate radius and position for the four corners
        let tempYposition = cornerRadius * height / ( sqrt( pow(height,2) + pow(width - rightTopPoint, 2)))
        let tempXposition =  cornerRadius * ( width - rightTopPoint ) / ( sqrt( pow(height,2) + pow(width - rightTopPoint, 2)))
        
        let lineTop = sqrt(pow(tempYposition,2) + pow(tempXposition + cornerRadius, 2))
        let radiusTop = ((lineTop/2)/(sqrt(pow(cornerRadius,2)-pow(lineTop/2,2)))) * cornerRadius
        
        
        path.moveToPoint(CGPoint(x: initialPoint + cornerRadius , y: 0))
        path.addLineToPoint(CGPoint(x: rightTopPoint - cornerRadius, y: 0))
        
        
        path.addCurveToPoint(CGPoint(x: tempXposition + rightTopPoint, y: tempYposition), controlPoint1: CGPoint(x: rightTopPoint-cornerRadius+(cornerRadius+tempXposition)/2, y: radiusTop - sqrt(pow(radiusTop,2) - pow((cornerRadius+tempXposition)/2 ,2 ))), controlPoint2: CGPoint(x:  rightTopPoint - cornerRadius + sqrt(pow(radiusTop,2) - pow(radiusTop-tempYposition/2 ,2 )), y: tempYposition/2))
        
        
        path.addLineToPoint(CGPoint(x: width, y: height))
        
        path.addLineToPoint(CGPoint(x: 0, y: height))
        
        path.addLineToPoint(CGPoint(x: initialPoint-tempXposition, y: tempYposition))
        
        path.addCurveToPoint(CGPoint(x: initialPoint+cornerRadius, y: 0), controlPoint1: CGPoint(x: initialPoint+cornerRadius-(cornerRadius+tempXposition)/2, y: radiusTop - sqrt(pow(radiusTop,2) - pow((cornerRadius+tempXposition)/2 ,2 ))), controlPoint2: CGPoint(x:  initialPoint + cornerRadius - sqrt(pow(radiusTop,2) - pow(radiusTop-tempYposition/2 ,2 )), y: tempYposition/2))
        UIColor.grayColor().colorWithAlphaComponent(0.5).setFill()
        path.fill()
    }
}