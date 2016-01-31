//
//  TabsEditorJinggling.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/25/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

//MARK: Jiggling button
extension TabsEditorViewController {
    func degreesToRadians(x: Double) -> Double { return M_PI * (x) / 180.0 }
    
    func startJiggling(sender: UIGestureRecognizer) {
        if sender.isKindOfClass(UITapGestureRecognizer) {
            self.jigglingChanged()
            self.currentBaseButton.removeGestureRecognizer(self.jigglingLongPressGesture)
        }else if sender.isKindOfClass(UILongPressGestureRecognizer) {
            let tempSender = sender as! UILongPressGestureRecognizer
            if tempSender.state == .Began {
                self.jigglingChanged()
            }
            
            handleCurrentBaseButtonLongPress(tempSender)
        }
    }
    
    func jigglingChanged(){
        self.isJiggling = true
        let buttonWidth = 9 / 60 * self.trueHeight
        let center = self.currentBaseButton.center
        
        self.currentBaseButton.frame = CGRectMake(self.currentBaseButton.frame.origin.x, self.currentBaseButton.frame.origin.y, buttonWidth, buttonWidth)
        self.currentBaseButton.center = center
        self.currentBaseButton.layer.cornerRadius = 0.5 * buttonWidth
        let randomInt: UInt32  = arc4random_uniform(500)
        let r:Double = (Double(randomInt) / 500.0) + 5
        
        let leftWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( (kAnimationRotateDeg * -1.0) - r)))
        let rightWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( kAnimationRotateDeg + r)))
        let originalX = self.currentBaseButton.center.x
        self.currentBaseButton.center.x = originalX - 1
        self.currentBaseButton.transform = leftWobble;  // starting point
        self.currentBaseButton.layer.anchorPoint = CGPointMake(0.5, 0.5)
        let a:CGFloat = CGFloat((1 - sqrt(2.0))/2.0) * (self.currentBaseButton.frame.size.width/2.0) + (2/3)*(self.currentBaseButton.frame.size.width/4.0 - self.currentBaseButton.frame.size.width/6.0)
        
        deleteView.frame = CGRectMake( a ,  a, self.currentBaseButton.frame.size.width/3, self.currentBaseButton.frame.size.width/3)
        
        let image =  UIImage(named: "deleteX")
        deleteView.image = image
        
        self.currentBaseButton.addSubview(deleteView)
        
        UIView.animateWithDuration(0.1, delay: 0, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: {
            UIView.setAnimationRepeatCount(Float(NSNotFound))
            self.currentBaseButton.center.x = originalX+1
            self.currentBaseButton.transform = rightWobble
            
            }, completion: nil)
        self.currentBaseButton.removeGestureRecognizer(self.jigglingTapGesture)
        self.jigglingPanGesture.addTarget(self, action: "handleCurrentBaseButtonPan:")
        self.currentBaseButton.addGestureRecognizer(self.jigglingPanGesture)
    }
    
    func stopJiggling() {
        self.currentBaseButton.addGestureRecognizer(self.jigglingTapGesture)
        self.currentBaseButton.addGestureRecognizer(self.jigglingLongPressGesture)
        deleteView.removeFromSuperview()
        self.currentBaseButton.layer.removeAllAnimations()
        self.currentBaseButton.transform = CGAffineTransformIdentity
        let buttonWidth = 7 / 60 * self.trueHeight
        let center = self.currentBaseButton.center
        self.currentBaseButton.frame = CGRectMake(self.currentBaseButton.frame.origin.x, self.currentBaseButton.frame.origin.y, buttonWidth, buttonWidth)
        self.currentBaseButton.layer.cornerRadius = 0.5 * buttonWidth
        self.currentBaseButton.center = CGPoint(x: center.x-1, y: center.y)
        self.isJiggling = false
        
        
    }
    
    
    func handleCurrentBaseButtonPan(sender: UIPanGestureRecognizer) {
        let transfer:CGPoint = sender.locationInView(self.completeStringView)
        if sender.state == .Began {
            self.currentBaseButton.removeGestureRecognizer(jigglingLongPressGesture)
            self.currentBaseButton.alpha = 0.5
            self.originalCenter = self.currentBaseButton.center
            self.longPressX = transfer.x - originalCenter.x
            self.longPressY = transfer.y - originalCenter.y
        } else if sender.state == .Changed {
            self.currentBaseButton.center = CGPointMake(transfer.x - longPressX, transfer.y - longPressY)
            if(self.currentBaseButton.center.x > self.completeStringView.contentOffset.x + self.trueWidth/2){
                stopLeftEdgeTimer()
                startRightEdgeTimer()
            }else{
                stopRightEdgeTimer()
                startLeftEdgeTimer()
            }
        } else if sender.state == .Ended || sender.state == .Cancelled {
            stopLeftEdgeTimer()
            stopRightEdgeTimer()
            self.currentBaseButton.alpha = 0.8
            var indexFret: Int = Int()
            var indexString: Int = Int()
            let location = self.currentBaseButton.center
            for var index = 0; index < self.string6FretPosition.count; index++ {
                if location.x < self.string6FretPosition[self.string6FretPosition.count - 2] {
                    if location.x > self.string6FretPosition[index] && location.x < self.string6FretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for var index = 0; index < 6; index++ {
                if CGRectContainsPoint(self.string6View[index].frame, location) {
                    indexString = index
                }
            }
            PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
            
            if indexString >= 3 {
                let buttonFret = (self.string6FretPosition[indexFret] + self.string6FretPosition[indexFret + 1]) / 2
                let buttonString = self.string6Position[indexString]
                let buttonWidth = 9 / 60 * self.trueHeight
                self.currentBaseButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
                let noteButton = sender.view as! UIButton
                let oldNoteButtonTag = noteButton.tag
                noteButton.tag = (indexString + 1) * 100 + indexFret
                let tabName = TabsDataManager.fretsBoard[indexString][indexFret]
                noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
                self.tabNameTextField.text = ""
                self.fingerPoint[6 - (indexString + 1)].hidden = true
                self.currentNoteButton = noteButton
                self.currentBaseButton = noteButton
                self.noteButtonOnCompeteScrollView = noteButton
                if(oldNoteButtonTag != currentNoteButton.tag){
                    self.addSpecificTabButton(noteButton.tag)
                }
                self.checkTheFingerPoint(noteButton.tag, oldTag: oldNoteButtonTag, oldTagString4: oldTagString4, oldTagString5: oldTagString5)
            } else {
                self.currentBaseButton.center = self.originalCenter
            }
            self.currentBaseButton.addGestureRecognizer(self.jigglingTapGesture)
            self.currentBaseButton.addGestureRecognizer(self.jigglingLongPressGesture)
            self.stopJiggling()
            self.currentBaseButton.removeGestureRecognizer(sender)
        }
    }
    
    func handleCurrentBaseButtonLongPress(sender: UILongPressGestureRecognizer) {
        let transfer:CGPoint = sender.locationInView(self.completeStringView)
        if sender.state == .Began {
            self.currentBaseButton.removeGestureRecognizer(jigglingPanGesture)
            self.currentBaseButton.alpha = 0.5
            self.originalCenter = self.currentBaseButton.center
            self.longPressX = transfer.x - originalCenter.x
            self.longPressY = transfer.y - originalCenter.y
            
        } else if sender.state == .Changed {
            self.currentBaseButton.center = CGPointMake(transfer.x - longPressX, transfer.y - longPressY)
            if(self.currentBaseButton.center.x > self.completeStringView.contentOffset.x + self.trueWidth/2){
                stopLeftEdgeTimer()
                startRightEdgeTimer()
            }else{
                stopRightEdgeTimer()
                startLeftEdgeTimer()
            }
        } else if sender.state == .Ended || sender.state == .Cancelled {
            stopLeftEdgeTimer()
            stopRightEdgeTimer()
            
            self.currentBaseButton.alpha = 0.8
            var indexFret: Int = Int()
            var indexString: Int = Int()
            let location = self.currentBaseButton.center
            for var index = 0; index < self.string6FretPosition.count; index++ {
                if location.x < self.string6FretPosition[self.string6FretPosition.count - 2] {
                    if location.x > self.string6FretPosition[index] && location.x < self.string6FretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for var index = 0; index < 6; index++ {
                if CGRectContainsPoint(self.string6View[index].frame, location) {
                    indexString = index
                }
            }
            PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
            var oldNoteButtonTag:Int = 0
            if indexString >= 3 {
                self.stopJiggling()
                let buttonFret = (self.string6FretPosition[indexFret] + self.string6FretPosition[indexFret + 1]) / 2
                let buttonString = self.string6Position[indexString]
                let buttonWidth = 9 / 60 * self.trueHeight
                self.currentBaseButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
                self.currentBaseButton.layer.cornerRadius = buttonWidth/2
                let noteButton = self.currentBaseButton
                oldNoteButtonTag = noteButton.tag
                noteButton.tag = (indexString + 1) * 100 + indexFret
                let tabName = TabsDataManager.fretsBoard[indexString][indexFret]
                noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
                self.tabNameTextField.text = ""
                self.fingerPoint[6 - (indexString + 1)].hidden = true
                
                self.currentNoteButton = noteButton
                self.currentBaseButton = noteButton
                self.noteButtonOnCompeteScrollView = noteButton
                if(oldNoteButtonTag != currentNoteButton.tag){
                    self.addSpecificTabButton(noteButton.tag)
                }
                self.checkTheFingerPoint(noteButton.tag, oldTag: oldNoteButtonTag, oldTagString4: oldTagString4, oldTagString5: oldTagString5)
            } else {
                self.currentBaseButton.center = self.originalCenter
            }
            self.currentBaseButton.removeGestureRecognizer(jigglingLongPressGesture)
            self.jigglingChanged()
            if abs(location.x - currentBaseButton.center.x) > 1 || abs(location.y - currentBaseButton.center.y) > 1 || oldNoteButtonTag != currentBaseButton.tag {
                self.currentBaseButton.addGestureRecognizer(self.jigglingTapGesture)
                self.stopJiggling()
                self.currentBaseButton.removeGestureRecognizer(jigglingPanGesture)
            }else{
                self.currentBaseButton.addGestureRecognizer(jigglingPanGesture)
            }
        }
    }
    
    func startRightEdgeTimer(){
        if rightEdgeTimer == nil {
            self.stopEdgeStartTime = -1
            rightEdgeTimer = NSTimer()
            rightEdgeTimer = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("autoScrollingOnEdgeToRight"), userInfo: nil, repeats: true)
        }
    }
    
    func stopRightEdgeTimer(){
        if(rightEdgeTimer != nil){
            rightEdgeTimer!.invalidate()
            rightEdgeTimer = nil
            self.stopEdgeStartTime = -1
        }
    }
    
    func startLeftEdgeTimer(){
        if leftEdgeTimer == nil {
            self.stopEdgeStartTime = -1
            leftEdgeTimer = NSTimer()
            leftEdgeTimer = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("autoScrollingOnEdgeToLeft"), userInfo: nil, repeats: true)
        }
    }
    
    func stopLeftEdgeTimer(){
        if(leftEdgeTimer != nil){
            leftEdgeTimer!.invalidate()
            leftEdgeTimer = nil
            self.stopEdgeStartTime = -1
        }
    }
    
    func checkTheFingerPoint(newTag: Int, oldTag: Int, oldTagString4:Int, oldTagString5:Int) {
        let indexString = newTag / 100
        if indexString > oldTag / 100 {
            self.moveFingerPoint(newTag%100, indexString: indexString-1)
            self.fingerPoint[6 - indexString].hidden = true
            self.fingerPoint[6 - indexString].accessibilityIdentifier = "grayButton"
            self.fingerPoint[6 - indexString].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            if(!self.fingerPoint[3].hidden){
                if(self.fingerPoint[2].hidden){
                    self.moveFingerPoint(oldTagString4, indexString: 3)
                }
                self.fingerPoint[2].hidden = false
                self.fingerPoint[2].accessibilityIdentifier = "grayButton"
                self.fingerPoint[2].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
                if indexString == 6 {
                    self.moveFingerPoint(oldTagString5, indexString: 4)
                    self.fingerPoint[1].hidden = false
                    self.fingerPoint[1].accessibilityIdentifier = "grayButton"
                    self.fingerPoint[1].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
                }
            }
        } else {
            if(indexString == 4){
                if(oldTag/100 != newTag/100){
                    self.oldTagString4 = fingerPoint[2].tag
                    if(!fingerPoint[1].hidden){
                        self.oldTagString5 = fingerPoint[1].tag
                    }
                }
                self.moveFingerPoint(newTag%100, indexString: indexString-1)
                self.moveFingerPoint(0, indexString: 4)
                self.moveFingerPoint(0, indexString: 5)
                self.fingerPoint[0].hidden = true
                self.fingerPoint[1].hidden = true
                self.fingerPoint[2].hidden = true
                self.fingerPoint[0].accessibilityIdentifier = "blackX"
                self.fingerPoint[1].accessibilityIdentifier = "blackX"
                self.fingerPoint[2].accessibilityIdentifier = "grayButton"
                self.fingerPoint[0].setImage(UIImage(named: "blackX"), forState: UIControlState.Normal)
                self.fingerPoint[1].setImage(UIImage(named: "blackX"), forState: UIControlState.Normal)
                self.fingerPoint[2].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            }else if (indexString == 5){
                if(oldTag/100 != newTag/100){
                    self.oldTagString4 = fingerPoint[2].tag
                    self.oldTagString5 = fingerPoint[1].tag
                }
                self.moveFingerPoint(newTag%100, indexString: indexString-1)
                self.moveFingerPoint(0, indexString: 5)
                self.fingerPoint[0].hidden = true
                self.fingerPoint[1].hidden = true
                self.fingerPoint[0].accessibilityIdentifier = "blackX"
                self.fingerPoint[1].accessibilityIdentifier = "grayButton"
                self.fingerPoint[0].setImage(UIImage(named: "blackX"), forState: UIControlState.Normal)
                self.fingerPoint[1].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            }else if(indexString == 6){
                if(oldTag/100 != newTag/100){
                    self.oldTagString5 = fingerPoint[1].tag
                }
                self.moveFingerPoint(newTag%100, indexString: indexString-1)
                self.fingerPoint[0].hidden = true
                self.fingerPoint[0].accessibilityIdentifier = "grayButton"
                self.fingerPoint[0].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
                
            }
        }
    }
    
    func shakeAnimationTextField(){
        //remind and shake
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.tabNameTextField.center.x - 10, self.tabNameTextField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.tabNameTextField.center.x + 10, self.tabNameTextField.center.y))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.tabNameTextField.layer.addAnimation(animation, forKey: "position")
    }
    
    func shakeAnimationScrollView(){
        //remind and shake
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.specificTabsScrollView.center.x - 10, self.specificTabsScrollView.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.specificTabsScrollView.center.x + 10, self.specificTabsScrollView.center.y))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.specificTabsScrollView.layer.addAnimation(animation, forKey: "position")
    }
    
    func shakeAnimationStatusLabel(){
        //remind and shake
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.statusLabel.center.x - 10, self.statusLabel.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.statusLabel.center.x + 10, self.statusLabel.center.y))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        self.statusLabel.layer.addAnimation(animation, forKey: "position")
    }
    
    func AnimationStatusLabel(text:String){
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.statusLabel.alpha = 0
            }, completion: {
                completed in
                self.statusLabel.text = text
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                    self.statusLabel.alpha = 1
                    }, completion: nil)
        })
    }
    
    func autoScrollingOnEdgeToRight() {
        let currentCenter:CGPoint = self.currentBaseButton.center
        let buttonWidth = 9 / 60 * self.trueHeight
        if currentCenter.x - buttonWidth/2 > self.completeStringView.contentOffset.x+self.trueWidth - 1.2*buttonWidth {
            if(self.completeStringView.contentOffset.x + self.trueWidth >= 5 * self.trueWidth - 10){
                self.stopEdgeStartTime = -1
                return
            }
            if(self.stopEdgeStartTime == -1){
                self.stopEdgeStartTime = CACurrentMediaTime()
            }
            let nowTime = CACurrentMediaTime()
            if(nowTime - self.stopEdgeStartTime >= 0.8){
                self.stopEdgeStartTime = -1
                UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
                    self.completeStringView.contentOffset.x = self.completeStringView.contentOffset.x + self.trueWidth
                    self.currentBaseButton.center.x = currentCenter.x + self.trueWidth
                    }, completion: {
                        completed in
                        self.stopEdgeStartTime = -1
                })
            }
        }else{
            self.stopEdgeStartTime = -1
        }
    }
    
    func autoScrollingOnEdgeToLeft() {
        let currentCenter:CGPoint = self.currentBaseButton.center
        let buttonWidth = 9 / 60 * self.trueHeight
        if currentCenter.x + buttonWidth/2 < self.completeStringView.contentOffset.x + 1.2*buttonWidth {
            if(self.completeStringView.contentOffset.x < 10){
                self.stopEdgeStartTime = -1
                return
            }
            if(self.stopEdgeStartTime == -1){
                self.stopEdgeStartTime = CACurrentMediaTime()
            }
            let nowTime = CACurrentMediaTime()
            if(nowTime - self.stopEdgeStartTime >= 0.8){
                self.stopEdgeStartTime = -1
                UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
                    self.completeStringView.contentOffset.x = self.completeStringView.contentOffset.x - self.trueWidth
                    self.currentBaseButton.center.x = currentCenter.x - self.trueWidth
                    }, completion: {
                        completed in
                        self.stopEdgeStartTime = -1
                })
            }
        }else{
            self.stopEdgeStartTime = -1
        }
        
    }
}

extension TabsEditorViewController {
    func startMainViewJiggling(sender:UILongPressGestureRecognizer?=nil){
        if(sender == nil || sender!.state == .Began){
            for buttonWithTab in self.noteButtonWithTabArray {
                let button = buttonWithTab.noteButton
                let gesture = self.longPressMainViewNoteButton[button]
                startNormalJinggling(gesture!)
            }
            self.tempTapView = UIView(frame: CGRectMake(musicControlView.frame.origin.x, musicControlView.frame.origin.y, musicControlView.frame.size.width, musicControlView.frame.size.height))
            temptapOnEditView.addTarget(self, action: "tapOnEditView:")
            self.tempTapView!.addGestureRecognizer(temptapOnEditView)
            self.view.addSubview(self.tempTapView!)
        }
    }
    
    func stopMainViewJiggling(){
        for buttonWithTab in self.noteButtonWithTabArray {
            let button = buttonWithTab.noteButton
            let gesture = self.longPressMainViewNoteButton[button]
            stopNormalJinggling(gesture!, button: button)
        }
        self.completeStringView.userInteractionEnabled = true
        self.musicControlView.userInteractionEnabled = true
        if(tempTapView != nil){
            tempTapView?.removeGestureRecognizer(temptapOnEditView)
            tempTapView!.removeFromSuperview()
            tempTapView = nil
        }
        self.isJiggling = false
    }
    
    func startNormalJinggling(sender: UILongPressGestureRecognizer) {
        if isJiggling {
            stopJiggling()
        }
        if(!intoEditView){
            self.musicControlView.userInteractionEnabled = false
        }
        self.removeDoubleArrowView()
        let tempView = sender.view!
        
        let buttonWidth = tempView.frame.size.width
        
        let buttonHeight = tempView.frame.size.height
        let oldCornerRadius = tempView.layer.cornerRadius
        var delta: CGFloat = 0
        let originalX = tempView.center.x
        // circle
        if oldCornerRadius >= 0.5 * buttonWidth - 0.1 && oldCornerRadius <= 0.5 * buttonWidth + 0.1 {
            sender.enabled = false
            self.isJiggling = true
            delta = CGFloat((1 - sqrt(2.0))/2.0) * (tempView.frame.size.width/2.0) + (tempView.frame.size.width/4.0 - tempView.frame.size.width/6.0)
            tempView.center.x = originalX - 1
            
            let tempDeleteChordOnMainView = UITapGestureRecognizer(target: self, action: "deleteChordOnMainView:")
            self.deleteChordOnMainView[tempView as! UIButton] = tempDeleteChordOnMainView
            tempView.addGestureRecognizer(tempDeleteChordOnMainView)
            let randomInt: UInt32  = arc4random_uniform(500)
            let r:Double = (Double(randomInt) / 500.0) + 5
            
            let leftWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(self.degreesToRadians( (self.kAnimationRotateDeg * -1.0) - r)))
            let rightWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(self.degreesToRadians( self.kAnimationRotateDeg + r)))
            
            tempView.transform = leftWobble;  // starting point
            tempView.layer.anchorPoint = CGPointMake(0.5, 0.5)
            
            let tempDeleteView = UIImageView(image: UIImage(named: "deleteX"))
            
            tempDeleteView.frame = CGRectMake(delta, delta, buttonHeight / 3, buttonHeight / 3)
            
            self.deleteViewArray[tempView as! UIButton] = tempDeleteView
            
            tempView.addSubview(tempDeleteView)
            
            UIView.animateWithDuration(0.1, delay: 0, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: {
                UIView.setAnimationRepeatCount(Float(NSNotFound))
                if oldCornerRadius == 0.5 * buttonWidth {
                    tempView.center.x = originalX + 1
                }
                tempView.transform = rightWobble
                }, completion: nil
            )
            
            self.completeStringView.userInteractionEnabled = false
            
        } else if sender.state == .Began {
            sender.enabled = false
            self.stopSpecificJiggling()
            sender.enabled = false
            self.isJiggling = true
            delta = -(buttonHeight / 3 / 2 - buttonHeight / 15)
            self.deleteChordOnSpecificTabView.addTarget(self, action: "deleteChordOnSpecificTabView:")
            tempView.addGestureRecognizer(deleteChordOnSpecificTabView)
            let randomInt: UInt32  = arc4random_uniform(500)
            let r:Double = (Double(randomInt) / 500.0) + 2
            
            let leftWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( (kAnimationRotateDeg * -1.0) - r)))
            let rightWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( kAnimationRotateDeg + r)))
            
            tempView.transform = leftWobble;  // starting point
            tempView.layer.anchorPoint = CGPointMake(0.5, 0.5)
            
            deleteView.frame = CGRectMake(delta, delta, buttonHeight / 3, buttonHeight / 3)
            
            
            let image =  UIImage(named: "deleteX")
            deleteView.image = image
            
            tempView.addSubview(deleteView)
            
            
            UIView.animateWithDuration(0.1, delay: 0, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: {
                UIView.setAnimationRepeatCount(Float(NSNotFound))
                tempView.transform = rightWobble
                }, completion: nil
            )
            self.completeStringView.userInteractionEnabled = false
        }
    }
    
    func stopNormalJinggling(sender: UILongPressGestureRecognizer, button:UIButton?=nil) {
        if(sender.enabled){
            return
        }
        if(button == nil){
            self.completeStringView.userInteractionEnabled = true
            self.isJiggling = false
        }
        sender.enabled = true
        let tempView = sender.view!
        tempView.removeGestureRecognizer(deleteChordOnSpecificTabView)
        deleteView.removeFromSuperview()
        tempView.layer.removeAllAnimations()
        tempView.transform = CGAffineTransformIdentity
        let buttonWidth = tempView.frame.size.width
        let oldCornerRadius = tempView.layer.cornerRadius
        let center = sender.view?.center
        // circle
        if oldCornerRadius >= 0.5 * buttonWidth - 0.1 && oldCornerRadius <= 0.5 * buttonWidth + 0.1 {
            deleteViewArray[button!]!.removeFromSuperview()
            deleteViewArray.removeValueForKey(button!)
            tempView.center = CGPoint(x: center!.x - 1, y: center!.y)
            tempView.removeGestureRecognizer(deleteChordOnMainView[button!]!)
            deleteChordOnMainView.removeValueForKey(button!)
        }
    }
    
    func deleteChordOnSpecificTabView(sender: UITapGestureRecognizer) {
        var needAlert: Bool = false
        for var i = 0; i < self.noteButtonWithTabArray.count; i++ {
            if self.noteButtonWithTabArray[i].tab.index == Int(self.currentSelectedSpecificTab.index) && self.noteButtonWithTabArray[i].tab.name == self.currentSelectedSpecificTab.name && self.noteButtonWithTabArray[i].tab.content == self.currentSelectedSpecificTab.content {
                needAlert = true
                break
            }
        }
        if needAlert == false {
            for var i = 0; i < self.allTabsOnMusicLine.count; i++ {
                if self.allTabsOnMusicLine[i].tab.index == Int(self.currentSelectedSpecificTab.index) && self.allTabsOnMusicLine[i].tab.name == self.currentSelectedSpecificTab.name && self.allTabsOnMusicLine[i].tab.content == self.currentSelectedSpecificTab.content {
                    needAlert = true
                    break
                }
            }
        }
        if needAlert {
            let alertController = UIAlertController(title: nil, message: "This operation will delete all '\(self.currentSelectedSpecificTab.name)' you have already added to the song.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: {
                action in
                self.stopSpecificJiggling()
            }))
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: {
                action in
                self.deleteActionOnSpecificTabView()
                
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.deleteActionOnSpecificTabView()
        }
    }
    
    func deleteActionOnSpecificTabView() {
        self.isShowDiscardAlert = true
        self.deleteChordOnMainViewWhenDeleteOnEditView(Int(self.currentSelectedSpecificTab.index), name: self.currentSelectedSpecificTab.name, content: self.currentSelectedSpecificTab.content)
        self.removeObjectsOnSpecificTabsScrollView()
        TabsDataManager.removeTabs(self.currentSelectedSpecificTab.tabs)
        self.tabNameTextField.text = self.currentNoteButton.titleLabel?.text
        stopSpecificJiggling()
        self.addSpecificTabButton(self.currentBaseButton.tag)
    }
    
    func deleteChordOnMainView(sender: UITapGestureRecognizer) {
        self.isShowDiscardAlert = true
        let index: Int = (sender.view?.tag)!
        self.stopNormalJinggling(longPressMainViewNoteButton[self.noteButtonWithTabArray[index].noteButton]!, button: self.noteButtonWithTabArray[index].noteButton)
        let fretNumber = Int(self.noteButtonWithTabArray[index].tab.index) - Int(self.noteButtonWithTabArray[index].tab.index) / 100 * 100
        for var i = 0; i < self.mainViewDataArray.count; i++ {
            if self.mainViewDataArray[i].fretNumber == fretNumber {
                for var j = 0; j < self.mainViewDataArray[i].noteButtonsWithTab.count; j++ {
                    if self.compareTabs(self.mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: self.noteButtonWithTabArray[index].tab) {
                        self.mainViewDataArray[i].noteButtonsWithTab[j].noteButton.removeFromSuperview()
                        self.mainViewDataArray[i].noteButtonsWithTab.removeAtIndex(j)
                    }
                }
            }
        }
        self.noteButtonWithTabArray.removeAtIndex(index)
        for var i = 0; i < noteButtonWithTabArray.count; i++ {
            noteButtonWithTabArray[i].noteButton.tag = i
        }
        if(self.noteButtonWithTabArray.count == 0){
            self.completeStringView.userInteractionEnabled = true
            if(tempTapView != nil){
                tempTapView?.removeGestureRecognizer(temptapOnEditView)
                tempTapView!.removeFromSuperview()
                tempTapView = nil
            }
            self.musicControlView.userInteractionEnabled = true
            self.isJiggling = false
        }
        stopMainViewJiggling()
        reorganizeMainViewDataArray()
        startMainViewJiggling()
    }
    
    // need to check whether the main view contain the delete tab
    func deleteChordOnMainViewWhenDeleteOnEditView(index: Int, name: String, content: String) {
        for var i = 0; i < self.noteButtonWithTabArray.count; i++ {
            if self.noteButtonWithTabArray[i].tab.index == index && self.noteButtonWithTabArray[i].tab.name == name && self.noteButtonWithTabArray[i].tab.content == content {
                self.deleteChordOnString3View(i)
            }
        }
        self.deleteChordOnMusicLine(index, name: name, content: content)
    }
    
    func deleteChordOnString3View(sender: Int) {
        let fretNumber = Int(noteButtonWithTabArray[sender].tab.index) - Int(noteButtonWithTabArray[sender].tab.index) / 100 * 100
        for var i = 0; i < self.mainViewDataArray.count; i++ {
            if self.mainViewDataArray[i].fretNumber == fretNumber {
                for var j = 0; j < self.mainViewDataArray[i].noteButtonsWithTab.count; j++ {
                    if self.compareTabs(self.mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: self.noteButtonWithTabArray[sender].tab)  {
                        self.mainViewDataArray[i].noteButtonsWithTab[j].noteButton.removeFromSuperview()
                        self.mainViewDataArray[i].noteButtonsWithTab.removeAtIndex(j)
                    }
                }
            }
        }
        self.noteButtonWithTabArray.removeAtIndex(sender)
        for var i = 0; i < self.noteButtonWithTabArray.count; i++ {
            self.noteButtonWithTabArray[i].noteButton.tag = i
        }
        reorganizeMainViewDataArray()
    }
    
    func deleteChordOnMusicLine(index: Int, name: String, content: String) {
        for var i = 0; i < self.allTabsOnMusicLine.count; i++ {
            if self.allTabsOnMusicLine[i].tab.index == index && self.allTabsOnMusicLine[i].tab.name == name && self.allTabsOnMusicLine[i].tab.content == content {
                self.allTabsOnMusicLine[i].tabView.removeFromSuperview()
                self.allTabsOnMusicLine.removeAtIndex(i)
                i--
            }
        }
        reorganizeAllTabsOnMusicLine()
    }
    
    func reorganizeAllTabsOnMusicLine() {
        var tempAllTabsOnMusicLine: [tabOnMusicLine] = [tabOnMusicLine]()
        for var j = 0; j < self.allTabsOnMusicLine.count; j++ {
            self.currentTime = self.allTabsOnMusicLine[j].time
            self.allTabsOnMusicLine[j].tabView.frame = self.setMainViewTabPositionInRange(self.allTabsOnMusicLine[j].tab, endIndex: tempAllTabsOnMusicLine.count, allTabsOnMusicLine: tempAllTabsOnMusicLine)
            
            tempAllTabsOnMusicLine.append(self.allTabsOnMusicLine[j])
            
        }
        tempAllTabsOnMusicLine.removeAll()
    }
    
    func backButtonRotation(isLeft isLeft:Bool){
        let leftWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians(0)))
        let rightWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians(-90)))
        
        self.backButton.userInteractionEnabled = false
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
            if(isLeft){
                self.backButton.imageView!.transform = leftWobble
                self.backButton.imageView
            }else{
                self.backButton.imageView!.transform = rightWobble
            }
            
            }, completion: {
                completed in
                self.backButton.userInteractionEnabled = true
        })
    }
}