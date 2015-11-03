//
//  CustomTransitionAnimation.swift
//  SlideViewController
//
//  Created by Anne Dong on 7/17/15.
//  Copyright (c) 2015 Anne Dong. All rights reserved.
//

import UIKit

enum CCAnimationType: Int {
    case CCAnimationTypePresent
    case CCAnimationTypeDismiss
}

class CustomTransitionAnimation: NSObject,UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {
    var  presentingVC:SongViewController = SongViewController()
    
    var  animationType:CCAnimationType!
    var  interacting:Bool!
    var interactiveTransition:UIPercentDrivenInteractiveTransition!
    
    var reverse: Bool = true
    
    func attachToViewController(viewController: SongViewController) {
        self.presentingVC = viewController
        setupGestureRecognizer(viewController.view)
    }
    
    private func setupGestureRecognizer(view: UIView) {
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePan:"))
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        //println("duration");
        return 0.5
    }
    
    //var rectStatusBarig
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //println("here")
        //获取containerView视图
        let containerView:UIView  = transitionContext.containerView()!
        
        if (self.animationType == CCAnimationType.CCAnimationTypePresent) {
            /*弹出动画*/
            //获取新的Present视图
            // println(self.animationType)
            let toVc:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            //对要Present出来的视图设置初始位置
            let boundsRect:CGRect = UIScreen.mainScreen().bounds
            let finalFrame:CGRect = transitionContext.finalFrameForViewController(toVc)
            toVc.view.frame = CGRectOffset(finalFrame, 0, boundsRect.size.height-20);
            //添加Present视图
            containerView.addSubview(toVc.view)
            //UIView动画切换,在这里用Spring动画做效果
            let interval:NSTimeInterval = self.transitionDuration(transitionContext)
            UIView .animateWithDuration(interval, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveLinear, animations: {
                toVc.view.frame = finalFrame
                }, completion: {
                    //通知动画已经完成
                    finished in transitionContext.completeTransition(true)
            })
            
            
        }else if (self.animationType == CCAnimationType.CCAnimationTypeDismiss) {
            /*消失动画*/
            //获取已经在最前的Present视图
            let fromVc:UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            //获取Dismiss完将要显示的VC
            let toVc:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            //在Present视图下面插入视图
            toVc.view.alpha = 0.2
            containerView.insertSubview(toVc.view, belowSubview: fromVc.view)
            //设置最终位置
            let boundsRect:CGRect = UIScreen.mainScreen().bounds
            let originFrame:CGRect = transitionContext.initialFrameForViewController(fromVc)
            let finalFrame:CGRect = CGRectOffset(originFrame, 0, boundsRect.size.height-20);
            //UIView动画切换
            let interval:NSTimeInterval = self.transitionDuration(transitionContext)
            
            UIView .animateWithDuration(interval, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                fromVc.view.frame = finalFrame;
                toVc.view.alpha = 1.0
                }, completion: {
                    //通知动画已经完成
                    finished in transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
    
    func handlePan(gesture:UIPanGestureRecognizer)
    {
        let tranlation:CGPoint = gesture.translationInView(presentingVC.view)
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            //设置交互标识为true
            self.interacting = true;
            //生成UIPercentDrivenInteractiveTransition对象
            self.interactiveTransition = UIPercentDrivenInteractiveTransition()
            //DismissViewController
            presentingVC.dismissViewControllerAnimated(true, completion: nil)
            break;
        case UIGestureRecognizerState.Changed:
            //计算当前百分比值
            var percent:CGFloat = tranlation.y / CGRectGetHeight(presentingVC.view.frame)
            percent = min(max(0.0, percent), 1.0)
            //用updateInteractiveTransition通知更新的百分比
            self.interactiveTransition.updateInteractiveTransition(percent)
            break;
        case UIGestureRecognizerState.Ended:
            //case UIGestureRecognizerState.Cancelled:
            //设置交互标识为false
            self.interacting = false
            //判断是否完成交互
            if tranlation.y > 200 && gesture.state != UIGestureRecognizerState.Cancelled {
                print("finish");
                self.interactiveTransition.finishInteractiveTransition()
                print("here:"+"\(presentingVC)")
                presentingVC.dismissViewControllerAnimated(true, completion: nil)
            }else{
                self.interactiveTransition.cancelInteractiveTransition()
            }
            //置空UIPercentDrivenInteractiveTransition对象
            self.interactiveTransition = nil;
            break;
        default:
            break;
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationType = CCAnimationType.CCAnimationTypeDismiss
        return self
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationType = CCAnimationType.CCAnimationTypePresent
        return self
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (self.interacting != nil) ? self.interactiveTransition :nil
    }
    
    
}
