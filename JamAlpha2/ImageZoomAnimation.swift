//
//  ImageZoomAnimation.swift
//  TestImage
//
//  Created by FangXin on 12/8/15.
//  Copyright © 2015 FangXin. All rights reserved.
//

import Foundation
import UIKit

class ImageZoomAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    var referenceImageView: UIImageView!
    var navigationBarHeight:CGFloat = 0
    var screenshot:UIImage!
    var screenshotFrame:CGRect!
    
    init(referenceImageView:UIImageView){
        assert(referenceImageView.contentMode == UIViewContentMode.ScaleAspectFill, "*** referenceImageView must have a UIViewContentModeScaleAspectFill contentMode!")
        self.referenceImageView = referenceImageView
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        let viewController:UIViewController = transitionContext!.viewControllerForKey(UITransitionContextToViewControllerKey)!
        return viewController.isBeingPresented() ? 0.5 : 0.2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let viewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        if(viewController.isBeingPresented()){
            self.animateZoomInTransition(transitionContext)
        }else{
            self.animateZoomOutTransition(transitionContext)
        }
    }
    
    func animateZoomInTransition(transitionContext: UIViewControllerContextTransitioning){
        let fromViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController:PhotoViewerViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as! PhotoViewerViewController
        assert(toViewController.isKindOfClass(PhotoViewerViewController), "*** toViewController must be a TGRImageViewController!")
        // Create a temporary view for the zoom in transition and set the initial frame based
        // on the reference image view
        let transitionView = UIImageView(image: self.referenceImageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = transitionContext.containerView()!.convertRect(self.referenceImageView.bounds, fromCoordinateSpace: self.referenceImageView)
        transitionContext.containerView()?.addSubview(transitionView)
        
        // Compute the final frame for the temporary view
        let finalFrame:CGRect = transitionContext.finalFrameForViewController(toViewController)
        let transitionViewFinalFrame:CGRect = self.referenceImageView.image!.tgr_aspectFitRectForSize(finalFrame.size)
        
        
        //perform the transition using a spring motion effect
        let duration:NSTimeInterval = self.transitionDuration(transitionContext)
        let tempVC = (((fromViewController as! TabBarController).viewControllers![2] as! UINavigationController).viewControllers[1] as! UserProfileEditViewController)
        tempVC.userProfile.hidden = true
        
        UIView.animateWithDuration(duration, animations: {
            fromViewController.view.alpha = 0.01
            }, completion: {
                finished in
                transitionView.removeFromSuperview()
                fromViewController.view.alpha = 1
                transitionContext.containerView()!.addSubview(toViewController.view)
                transitionContext.completeTransition(true)
        })
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                transitionView.frame = transitionViewFinalFrame
                transitionView.center = fromViewController.view.center
            }, completion: nil)
    }
    
    func animateZoomOutTransition(transitionContext: UIViewControllerContextTransitioning){
        let toViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromViewController:PhotoViewerViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as! PhotoViewerViewController
        assert(fromViewController.isKindOfClass(PhotoViewerViewController), "*** fromViewController must be a TGRImageViewController!")
        
        //The toViewController view will fade in during the transition
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.view.alpha = 0
        transitionContext.containerView()!.addSubview(toViewController.view)
        transitionContext.containerView()?.sendSubviewToBack(toViewController.view)
        
        // Compute the initial frame for the temporary view based on the image view
        // of the TGRImageViewController
        //let transitionViewInitialFrame:CGRect = fromViewController.imageView.frame
        var transitionViewInitialFrame:CGRect = fromViewController.imageView.image!.tgr_aspectFitRectForSize(fromViewController.imageView.bounds.size)
        transitionViewInitialFrame = transitionContext.containerView()!.convertRect(transitionViewInitialFrame, fromCoordinateSpace: fromViewController.imageView)
        
        // Compute the final frame for the temporary view based on the reference
        // image view
        var transitionViewFinalFrame:CGRect = CGRectMake(self.referenceImageView.frame.origin.x, self.referenceImageView.frame.origin.y + 40 + UIApplication.sharedApplication().statusBarFrame.height + self.navigationBarHeight, self.referenceImageView.frame.size.width, self.referenceImageView.frame.size.height)
        
        
        
        if(UIApplication.sharedApplication().statusBarHidden == true && !toViewController.prefersStatusBarHidden()){
            transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20)
        }
        
        // Create a temporary view for the zoom out transition based on the image
        // view controller contents
        let transitionView = UIImageView(image: fromViewController.imageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = false
        transitionView.frame = transitionViewInitialFrame
        transitionContext.containerView()?.addSubview(transitionView)
        
        let duration:NSTimeInterval = self.transitionDuration(transitionContext)
        fromViewController.imageView.removeFromSuperview()
        let tempImageView = UIImageView(frame: fromViewController.view.bounds)
        tempImageView.image = self.screenshot
        tempImageView.frame = self.screenshotFrame
        fromViewController.view.addSubview(tempImageView)
        tempImageView.alpha = 0
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: {
            tempImageView.alpha = 1
            }, completion: {
                finished in
                transitionView.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: {
                toViewController.view.alpha = 1
                transitionView.frame = transitionViewFinalFrame
                //transitionView.center = self.referenceImageView.center
            }, completion: nil)
    }
    
}


























