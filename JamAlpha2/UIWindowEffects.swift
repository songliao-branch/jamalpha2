//
//  UIWindowEffects.swift
//  ActionSheet
//
//  Created by Anne Dong on 8/26/15.
//  Copyright (c) 2015 Xin Fang. All rights reserved.
//

import UIKit
import Accelerate

public extension UIWindow {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    public func snapShot(itemCount:CGFloat, buttonHeight:CGFloat,cancelButtonHeight:CGFloat, addedHeightForRunningMan:CGFloat, needRunningManSlider:Bool) -> UIImage{
        var imageSize:CGSize = CGSizeZero
        var orientation:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if UIInterfaceOrientationIsPortrait(orientation) {
            imageSize = UIScreen.mainScreen().bounds.size
        }else{
            imageSize = CGSizeMake(UIScreen.mainScreen().bounds.size.height, UIScreen.mainScreen().bounds.size.width)
        }
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        var context:CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, self.center.x, self.center.y)
        CGContextConcatCTM(context, self.transform)
        CGContextTranslateCTM(context, -self.bounds.size.width*self.layer.anchorPoint.x, -self.bounds.size.height*self.layer.anchorPoint.y)
    
        if(orientation == UIInterfaceOrientation.LandscapeLeft){
            CGContextRotateCTM(context, CGFloat(M_PI_2))
            CGContextTranslateCTM(context, 0, -imageSize.width)
        }else if(orientation == UIInterfaceOrientation.LandscapeRight){
            CGContextRotateCTM(context, CGFloat(-M_PI_2))
            CGContextTranslateCTM(context, -imageSize.height, 0)
        }else if(orientation == UIInterfaceOrientation.PortraitUpsideDown){
            CGContextRotateCTM(context, CGFloat(M_PI))
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height)
        }
    
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        CGContextRestoreGState(context)
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var croprect:CGRect!
        if(needRunningManSlider){
             croprect = CGRectMake(0, (UIScreen.mainScreen().bounds.height - (buttonHeight*itemCount+cancelButtonHeight+addedHeightForRunningMan))*2, UIScreen.mainScreen().bounds.width*2,(buttonHeight*itemCount+cancelButtonHeight+addedHeightForRunningMan)*2)
        }else{
             croprect = CGRectMake(0, (UIScreen.mainScreen().bounds.height - (buttonHeight*itemCount+cancelButtonHeight))*2, UIScreen.mainScreen().bounds.width*2,(buttonHeight*itemCount+cancelButtonHeight)*2)
        }
        
        
        
        // Draw new image in current graphics context
        var imageRef:CGImageRef = CGImageCreateWithImageInRect(image.CGImage, croprect!)!;
        
        // Create new cropped UIImage
        var croppedImage:UIImage = UIImage(CGImage: imageRef)
        
        return croppedImage
    }
    
    public func currentViewController() -> UIViewController{
        var viewController:UIViewController = self.rootViewController!
        while(viewController.parentViewController != nil){
            viewController = viewController.presentedViewController!
        }
        return viewController
    }
}