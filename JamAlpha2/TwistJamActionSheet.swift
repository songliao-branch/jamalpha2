//
//  TwistJamActionSheet.swift
//  ActionSheet
//
//  Created by Anne Dong on 8/25/15.
//  Copyright (c) 2015 Xin Fang. All rights reserved.
//

import UIKit
import MediaPlayer

 let kDefaultAnimationDuration:NSTimeInterval = 0.3
 let kBlurFadeRangeSize:CGFloat = 200.0
 let kCellIdentifier:String = "Cell"
 let kAutoDismissOffset:CGFloat = 80.0
 let kFlickDownHandlingOffset:CGFloat = 20.0
 let kFlickDownMinVelocity:CGFloat = 2000.0
 let kTopSpaceMarginFraction:CGFloat = 0.333
 let kCancelButtonShadowHeightRatio:CGFloat = 0.333

enum ActionSheetButtonType: Int {
    case ActionSheetButtonTypeDefault
    case ActionSheetButtonTypeDestructive
}
typealias ActionSheetHandler = ( actionSheet : TwistJamActionSheet) -> ()


class TwistJamActionSheet: UIView, UIAppearanceContainer, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{
    var blurRadius:CGFloat = 16.0
    var blurTintColor:UIColor = UIColor(white: 1.0, alpha: 0.5)
    var blurSaturationDeltaFactor:CGFloat = 1.8
    var buttonHeight:CGFloat = 60.0
    var cancelButtonHeight:CGFloat = 56.0
    var cancelButtonShadowColor:UIColor!
    var automaticallyTintButtonImages:NSNumber = true
    var buttonTextCenteringEnabled:NSNumber!
    var separatorColor:UIColor!
    var selectedBackgroundColor:UIColor = UIColor(white: 1.0, alpha: 0.2)
    var titleTextAttributes:NSDictionary = [NSFontAttributeName:UIFont.systemFontOfSize(14.0),NSForegroundColorAttributeName:UIColor.grayColor()]
    var buttonTextAttributes:NSDictionary = [NSFontAttributeName:UIFont.systemFontOfSize(17.0)]
    var destructiveButtonTextAttributes:NSDictionary = [NSFontAttributeName:UIFont.systemFontOfSize(17.0),NSForegroundColorAttributeName:UIColor.redColor()]
    var cancelButtonTextAttributes:NSDictionary = [NSFontAttributeName:UIFont.systemFontOfSize(17.0),NSForegroundColorAttributeName:UIColor.darkGrayColor()]
    var animationDuration:NSTimeInterval = kDefaultAnimationDuration
    var cancelHandler:ActionSheetHandler! = {
        finished in Void()
    }
    var cancelButtonTitle:NSString = NSString(string: "Cancel")
    var title:NSString!
    var headerView:UIView!
    var previousKeyWindow:UIWindow!
    
    var items:NSMutableArray = NSMutableArray()
    var windowNow:UIWindow!
    var tableView:UITableView!
    var blurredBackgroundView:UIImageView!
    var cancelButton:UIButton!
    var cancelButtonShadowView:UIView!
    
    var slider:PopOverSlider!
    var resetButton:UIButton!
    
    var tableViewScrollEnabled:Bool = false
    
    var needRunningManSlider:Bool = false
    var addedHeightForRunningMan:CGFloat = 20.0
  
    var songVC:SongViewController!
    
    var isTwistJamActionSheetShow:Bool!
    
    class TwistJamActionSheetItem : NSObject{
        var title:NSString!
        var image:UIImage!
        var type:ActionSheetButtonType!
        var handler:ActionSheetHandler!
    }
    
    
    
    func initWithTitle(title:NSString) {
        self.title = title.copy() as! NSString
    }
    
    //pragma mark - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) 
        let item:TwistJamActionSheetItem = self.items[indexPath.row] as! TwistJamActionSheet.TwistJamActionSheetItem
        
        
        let attributes:NSDictionary = self.buttonTextAttributes
        let attrTitle:NSAttributedString = NSAttributedString(string: item.title as String, attributes: attributes as [NSObject : AnyObject])
        cell.textLabel!.attributedText = attrTitle
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.backgroundColor = UIColor.clearColor()
        
        if tableView.separatorStyle != UITableViewCellSeparatorStyle.None {
            
            if cell.respondsToSelector("setSeparatorInset:") {
                cell.separatorInset = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setLayoutMargins:") {
                cell.layoutMargins = UIEdgeInsetsZero
            }
            
            if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
                cell.preservesSuperviewLayoutMargins = false
                
            }
        }
        
        if(indexPath.row == 0 && needRunningManSlider){
                // Do any additional setup after loading the view, typically from a nib.
                resetButton = UIButton(frame: CGRectMake(cell.frame.width-70, 0, 70, cell.frame.height))
                resetButton.setTitle("Reset", forState: UIControlState.Normal)
                resetButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                resetButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
                resetButton.titleLabel!.font = UIFont.systemFontOfSize(14.0)
                resetButton.addTarget(self, action: "resetSlider", forControlEvents: UIControlEvents.TouchUpInside)
            
            
                slider = PopOverSlider(frame: CGRectMake(30, cell.frame.height/2-45, cell.frame.width-100, 100))
                slider.songVC = self.songVC
                slider.setMinimumTrackImage(UIImage(named: "sliderTexturePink"), forState: UIControlState.Normal)
                slider.setMaximumTrackImage(UIImage(named: "sliderTextureGray"), forState: UIControlState.Normal)
                slider.minimumValue = -0.5
                slider.maximumValue = 0.5
                self.updateSliderPopoverText()
                slider.setValue(songVC.speed - 1, animated: false)
                cell.addSubview(slider)
                cell.addSubview(slider.popOver)
                cell.addSubview(resetButton)
                self.slider.hidePopoverAnimated(false)
                self.slider.setThumbImage(UIImage(named:"running_man"), forState: UIControlState.Normal)
                self.slider.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            
        }
        
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView!.backgroundColor = self.selectedBackgroundColor
        
        
        return cell
    }
    
    //////////////////////////////////
    func sliderValueChanged(sender:PopOverSlider)
    {
        self.updateSliderPopoverText()
    }
    
    func updateSliderPopoverText()
    {
        self.slider.popOver.textLabel.text = String(format:"%.2f", self.slider.value)
        
    }
    
    func resetSlider(){
        print("reset")
        songVC!.speed = 1
        
        self.slider.setValue(0.0, animated: true)
        if songVC!.player.playbackState == MPMusicPlaybackState.Playing {
            songVC!.player.currentPlaybackRate = 1
            //songVC!.nowPlayingItemSpeed = 1
            songVC!.timer.invalidate()
            songVC!.startTimer()
        }else{
            songVC!.player.currentPlaybackRate = 0
           // songVC!.nowPlayingItemSpeed = 1
        }
    }
    
    

    //////////////////////////////////
    
    //pragma mark - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item:TwistJamActionSheetItem = self.items[indexPath.row] as! TwistJamActionSheetItem
        self.dismissAnimated(true, duration: self.animationDuration, completionHandler: item.handler)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0 && needRunningManSlider){
            return self.buttonHeight + self.addedHeightForRunningMan
        }else{
            return self.buttonHeight
        }
        
    }
    
    
    func fadeBlursOnScrollToTop() {
        if(self.tableView!.dragging || self.tableView!.decelerating){
            let alphaWithoutBounds:CGFloat = 1.0 - (-(self.tableView.contentInset.top + self.tableView.contentOffset.y)) / kBlurFadeRangeSize
            let alpha:CGFloat = CGFloat(fmax(fmin(alphaWithoutBounds, 1.0), 0.0))
            self.blurredBackgroundView.alpha = alpha
            self.cancelButtonShadowView.alpha = alpha
        }
    }
    // pragma mark - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.fadeBlursOnScrollToTop()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollVelocity:CGPoint = scrollView.panGestureRecognizer.velocityInView(self)
        
        let viewWasFlickedDown:Bool = scrollVelocity.y > kFlickDownMinVelocity && scrollView.contentOffset.y < -self.tableView.contentInset.top - kFlickDownHandlingOffset
        
        let shouldSlideDown = scrollView.contentOffset.y < -self.tableView.contentInset.top - kAutoDismissOffset
        
        if viewWasFlickedDown {
             let duration:NSTimeInterval = 0.2
            self.dismissAnimated(true, duration: duration, completionHandler: self.cancelHandler)
        }else if(shouldSlideDown){
            self.dismissAnimated(true, duration: self.animationDuration, completionHandler: self.cancelHandler)
        }
    }
    
    
    
    func cancelButtonTapped(sender:UIButton){
        self.dismissAnimated(true, duration: self.animationDuration, completionHandler: self.cancelHandler)
    }
  
    
    func addButtonWithTitle(title:NSString, type:ActionSheetButtonType, handler:ActionSheetHandler){
        self.addButtonWithTitle(title, image: UIImage(), type: type, handler: handler)
    }
    
    func addButtonWithTitle(title:NSString, image:UIImage, type:ActionSheetButtonType, handler:ActionSheetHandler){
        let item:TwistJamActionSheetItem = TwistJamActionSheetItem()
        item.title = title
        item.image = image
        item.type = type
        item.handler = handler
        self.items.addObject(item)
    }
    
    func show(){
        let actionSheetIsVisible:Bool = self.windowNow != nil
        if actionSheetIsVisible {
            return
        }
        isTwistJamActionSheetShow = true
        self.previousKeyWindow = UIApplication.sharedApplication().keyWindow
        let previousKeyWindowSnapshot:UIImage = self.previousKeyWindow.snapShot(CGFloat(self.items.count), buttonHeight: self.buttonHeight, cancelButtonHeight: self.cancelButtonHeight, addedHeightForRunningMan:self.addedHeightForRunningMan, needRunningManSlider:self.needRunningManSlider)
        self.setUpNewWindow()
        self.setUpBlurredBackgroundWithSnapshot(previousKeyWindowSnapshot)
        self.setUpCancelButton()
        self.setUpTableView()
        
        UIView.animateKeyframesWithDuration(self.animationDuration, delay: 0.0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: {
            self.blurredBackgroundView!.alpha = 1.0
            UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.6, animations: {
                self.blurredBackgroundView.frame = self.bounds
                self.cancelButton.frame = CGRectMake(0, CGRectGetMaxY(self.bounds)-self.cancelButtonHeight, CGRectGetWidth(self.bounds), self.cancelButtonHeight)
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            })
            }, completion: nil)
        
    }
    
    func dismissAnimated(animated:Bool){
        self.dismissAnimated(animated, duration: self.animationDuration, completionHandler: self.cancelHandler)
    }
    
    func dismissAnimated(animated:Bool, duration:NSTimeInterval, completionHandler:ActionSheetHandler){
        self.tableView.delegate = nil
        self.tableView.userInteractionEnabled = false
        self.tableView.contentInset = UIEdgeInsetsMake(-self.tableView.contentOffset.y, 0, 0, 0)
        
        if(animated){
            UIView.animateWithDuration(duration, animations: {
                self.blurredBackgroundView.frame = CGRectMake(0, self.bounds.height, self.bounds.width, self.bounds.height)
                self.cancelButtonShadowView.alpha = 0.0
                let slideDownMinOffset:CGFloat = CGFloat(fmin(CGRectGetHeight(self.frame)+self.tableView.contentOffset.y, CGRectGetHeight(self.frame)))
                self.tableView.transform = CGAffineTransformMakeTranslation(0, slideDownMinOffset)
                self.blurredBackgroundView!.alpha = 0.0
                if(self.needRunningManSlider){
                    self.slider.alpha = 0.0
                }
                self.cancelButton.transform = CGAffineTransformTranslate(self.cancelButton.transform, 0, self.cancelButtonHeight)
                }, completion:{
                    finished in self.tearDownView(completionHandler)
            })
        }else{
            self.tearDownView(completionHandler)
        }
        isTwistJamActionSheetShow = false
    }
    
    func tearDownView(completionHandler:ActionSheetHandler){
        var view:UIView!
        for view in [self.tableView, self.cancelButton, self.blurredBackgroundView, self.windowNow]{
            view.removeFromSuperview()
        }
        self.windowNow = nil
        self.previousKeyWindow.makeKeyAndVisible()
        
        completionHandler(actionSheet: self)
    }
    
    func setUpNewWindow(){
        let actionSheetVC:ActionSheetViewController = ActionSheetViewController()
        actionSheetVC.itemCount = self.items.count
        actionSheetVC.cancelButtonHeight = self.cancelButtonHeight
        actionSheetVC.buttonHeight = self.buttonHeight
        actionSheetVC.actionSheet = self
        actionSheetVC.needRunningManSlider = self.needRunningManSlider
        
        self.windowNow = UIWindow(frame: UIScreen .mainScreen().bounds)
        self.windowNow.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.windowNow.opaque = false
        self.windowNow.rootViewController = actionSheetVC
        self.windowNow.makeKeyAndVisible()
    }
    
    func setUpBlurredBackgroundWithSnapshot(previousKeyWindowSnapshot:UIImage){
        let blurredViewSnapshot = previousKeyWindowSnapshot.applyActionSheetEffect()
        let backgroundView:UIImageView = UIImageView(image: blurredViewSnapshot)
        backgroundView.frame = self.bounds
        backgroundView.alpha = 0.0
        backgroundView.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
        self.addSubview(backgroundView)
        self.blurredBackgroundView = backgroundView
    }
    
    func setUpCancelButton(){
        let cancelButton = UIButton(type: UIButtonType.System)
        let attrTitle:NSAttributedString = NSAttributedString(string: self.cancelButtonTitle as String, attributes: self.cancelButtonTextAttributes as [NSObject : AnyObject])
        cancelButton.setAttributedTitle(attrTitle, forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton.frame = CGRectMake(0, CGRectGetMaxY(self.bounds)-self.cancelButtonHeight, CGRectGetWidth(self.bounds), self.cancelButtonHeight)
        cancelButton.transform = CGAffineTransformMakeTranslation(0, self.cancelButtonHeight)
        self.addSubview(cancelButton)
        
        self.cancelButton = cancelButton
        
        if(self.cancelButtonShadowColor == nil){
            self.cancelButton.clipsToBounds = false
            let gradientHeight:CGFloat = CGFloat(round(self.cancelButtonHeight * kCancelButtonShadowHeightRatio))
            let view:UIView = UIView(frame: CGRectMake(0, -gradientHeight/4, CGRectGetWidth(self.bounds), gradientHeight/2.7))
            let gradient:CAGradientLayer = CAGradientLayer(layer: layer)
            gradient.frame = view.bounds
            gradient.colors = [UIColor(white: 0.0, alpha: 0.0).CGColor,self.blurTintColor.colorWithAlphaComponent(0.1).CGColor]
            view.layer.insertSublayer(gradient, atIndex: 0)
            self.cancelButton.addSubview(view)
            self.cancelButtonShadowView = view
        }
    }
    
    func setUpTableView(){
        let frame:CGRect = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - self.cancelButtonHeight)
    
        let tableView:UITableView = UITableView(frame: frame)
        self.tableView = tableView
        self.tableView.scrollEnabled = self.tableViewScrollEnabled
        tableView.backgroundColor = UIColor.clearColor()
        tableView.showsVerticalScrollIndicator = false
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.separatorInset =  UIEdgeInsetsZero
        if(self.separatorColor != nil){
            tableView.separatorColor = self.separatorColor
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: kCellIdentifier)
        tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.bounds), 0, 0, 0)
        self.insertSubview(tableView, aboveSubview: self.blurredBackgroundView)

        self.setUpTableViewHeader()
    }
    
    func setUpTableViewHeader(){
        if(self.title != nil){
            let leftRightPadding:CGFloat = 15.0
            let topBottomPadding:CGFloat = 8.0
            let labelWidth:CGFloat = CGRectGetWidth(self.bounds)
            
            let attrText:NSAttributedString = NSAttributedString(string: self.title as String, attributes: self.titleTextAttributes as [NSObject : AnyObject])
            
            let label:UILabel = UILabel()
            label.numberOfLines = 0
            label.attributedText = attrText
            let labelSize:CGSize = label.sizeThatFits(CGSizeMake(labelWidth, CGFloat(MAXFLOAT)))
            label.frame = CGRectMake( leftRightPadding, topBottomPadding, labelWidth, labelSize.height)
            let headerView:UIView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.bounds), labelSize.height + 2 * topBottomPadding))
            headerView.addSubview(label)
            self.tableView.tableHeaderView = headerView
        }else{
            self.tableView.tableHeaderView = self.headerView
        }
        
        if(self.tableView.tableHeaderView != nil && self.tableView.separatorStyle != UITableViewCellSeparatorStyle.None){
            let separatorHeight:CGFloat = 1.0 / UIScreen.mainScreen().scale
            let separatorFrame:CGRect = CGRectMake(0, CGRectGetHeight(self.tableView.tableHeaderView!.frame) - separatorHeight, CGRectGetWidth(self.tableView.tableHeaderView!.frame), separatorHeight)
            let separator:UIView = UIView(frame: separatorFrame)
            separator.backgroundColor = self.tableView.separatorColor
            self.tableView.tableHeaderView!.addSubview(separator)
        }
        
    }
}

class ActionSheetViewController: UIViewController {
    var actionSheet:TwistJamActionSheet!
    var itemCount:Int!
    var buttonHeight:CGFloat!
    var cancelButtonHeight:CGFloat!
    var needRunningManSlider:Bool = false
    var addedHeightForRunningMan:CGFloat = 20.0
    var tapView:UIView!
    var tapGestureRecognizer:UITapGestureRecognizer!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.actionSheet)
        if(!needRunningManSlider){
            addedHeightForRunningMan = 0.0
        }
        
        self.actionSheet.frame = CGRectMake(0, self.view.frame.height - (buttonHeight!*CGFloat(itemCount)+cancelButtonHeight!+addedHeightForRunningMan), self.view.frame.width,(buttonHeight!*CGFloat(itemCount)+cancelButtonHeight!+addedHeightForRunningMan))
        
        tapView = UIView(frame: CGRectMake(0, 0, self.view.frame.width,self.view.frame.height - (buttonHeight!*CGFloat(itemCount)+cancelButtonHeight!+addedHeightForRunningMan)))
        tapView.backgroundColor = UIColor.clearColor()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:Selector("tapToDisappear:"))
        tapView.addGestureRecognizer(tapGestureRecognizer)
        self.view.addSubview(tapView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapToDisappear(recognizer: UIPanGestureRecognizer) {
        actionSheet.dismissAnimated(true)
        actionSheet = nil
    }
}

