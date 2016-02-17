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
    func degreesToRadians(x: Double) -> Double {
      return M_PI * (x) / 180.0
    }
  
    func startJiggling(sender: UIGestureRecognizer) {
        if sender.isKindOfClass(UITapGestureRecognizer) {
            jigglingChanged()
            currentBaseButton.removeGestureRecognizer(jigglingLongPressGesture)
        }else if sender.isKindOfClass(UILongPressGestureRecognizer) {
            let tempSender = sender as! UILongPressGestureRecognizer
            if tempSender.state == .Began {
                jigglingChanged()
            }
            handleCurrentBaseButtonLongPress(tempSender)
        }
    }
    
    func jigglingChanged(){
        isJiggling = true
        let buttonWidth = 9 / 60 * trueHeight
        let center = currentBaseButton.center
        currentBaseButton.frame = CGRectMake(currentBaseButton.frame.origin.x, currentBaseButton.frame.origin.y, buttonWidth, buttonWidth)
        currentBaseButton.center = center
        currentBaseButton.layer.cornerRadius = 0.5 * buttonWidth
        let randomInt: UInt32  = arc4random_uniform(500)
        let r: Double = (Double(randomInt) / 500.0) + 5
        let leftWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( (kAnimationRotateDeg * -1.0) - r)))
        let rightWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( kAnimationRotateDeg + r)))
        let originalX = currentBaseButton.center.x
        currentBaseButton.center.x = originalX - 1
        currentBaseButton.transform = leftWobble;  // starting point
        currentBaseButton.layer.anchorPoint = CGPointMake(0.5, 0.5)
        let a: CGFloat = CGFloat((1 - sqrt(2.0)) / 2.0) * (currentBaseButton.frame.size.width / 2.0) + (2 / 3) * (currentBaseButton.frame.size.width / 4.0 - currentBaseButton.frame.size.width / 6.0)
        deleteView.frame = CGRectMake(a, a, currentBaseButton.frame.size.width / 3, currentBaseButton.frame.size.width / 3)
        let image = UIImage(named: "deleteX")
        deleteView.image = image
        currentBaseButton.addSubview(deleteView)
        UIView.animateWithDuration(0.1, delay: 0, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: {
            UIView.setAnimationRepeatCount(Float(NSNotFound))
            self.currentBaseButton.center.x = originalX+1
            self.currentBaseButton.transform = rightWobble
            
            }, completion: nil)
        currentBaseButton.removeGestureRecognizer(jigglingTapGesture)
        jigglingPanGesture.addTarget(self, action: "handleCurrentBaseButtonPan:")
        currentBaseButton.addGestureRecognizer(jigglingPanGesture)
    }
    
    func stopJiggling() {
        currentBaseButton.addGestureRecognizer(jigglingTapGesture)
        currentBaseButton.addGestureRecognizer(jigglingLongPressGesture)
        deleteView.removeFromSuperview()
        currentBaseButton.layer.removeAllAnimations()
        currentBaseButton.transform = CGAffineTransformIdentity
        let buttonWidth = 7 / 60 * trueHeight
        let center = currentBaseButton.center
        currentBaseButton.frame = CGRectMake(currentBaseButton.frame.origin.x, currentBaseButton.frame.origin.y, buttonWidth, buttonWidth)
        currentBaseButton.layer.cornerRadius = 0.5 * buttonWidth
        currentBaseButton.center = CGPoint(x: center.x - 1, y: center.y)
        isJiggling = false
    }
    
    func handleCurrentBaseButtonPan(sender: UIPanGestureRecognizer) {
        let transfer:CGPoint = sender.locationInView(completeStringView)
        if sender.state == .Began {
            currentBaseButton.removeGestureRecognizer(jigglingLongPressGesture)
            currentBaseButton.alpha = 0.5
            originalCenter = currentBaseButton.center
            longPressX = transfer.x - originalCenter.x
            longPressY = transfer.y - originalCenter.y
        } else if sender.state == .Changed {
            currentBaseButton.center = CGPointMake(transfer.x - longPressX, transfer.y - longPressY)
            if(currentBaseButton.center.x > completeStringView.contentOffset.x + trueWidth / 2){
                stopLeftEdgeTimer()
                startRightEdgeTimer()
            }else{
                stopRightEdgeTimer()
                startLeftEdgeTimer()
            }
        } else if sender.state == .Ended || sender.state == .Cancelled {
            stopLeftEdgeTimer()
            stopRightEdgeTimer()
            currentBaseButton.alpha = 0.8
            var indexFret: Int = Int()
            var indexString: Int = Int()
            let location = currentBaseButton.center
            for index in 0..<string6FretPosition.count {
                if location.x < string6FretPosition[string6FretPosition.count - 2] {
                    if location.x > string6FretPosition[index] && location.x < string6FretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for index in 0..<6 {
                if CGRectContainsPoint(string6View[index].frame, location) {
                    indexString = index
                }
            }
            PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
            if indexString >= 3 {
                let buttonFret = (string6FretPosition[indexFret] + string6FretPosition[indexFret + 1]) / 2
                let buttonString = string6Position[indexString]
                let buttonWidth = 9 / 60 * trueHeight
                currentBaseButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
                let noteButton = sender.view as! UIButton
                let oldNoteButtonTag = noteButton.tag
                noteButton.tag = (indexString + 1) * 100 + indexFret
                let tabName = TabsDataManager.fretsBoard[indexString][indexFret]
                noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
                tabNameTextField.text = ""
                fingerPoint[6 - (indexString + 1)].hidden = true
                currentNoteButton = noteButton
                currentBaseButton = noteButton
                noteButtonOnCompeteScrollView = noteButton
                if(oldNoteButtonTag != currentNoteButton.tag){
                    addSpecificTabButton(noteButton.tag)
                }
                checkTheFingerPoint(noteButton.tag, oldTag: oldNoteButtonTag, oldTagString4: oldTagString4, oldTagString5: oldTagString5)
            } else {
                currentBaseButton.center = originalCenter
            }
            currentBaseButton.addGestureRecognizer(jigglingTapGesture)
            currentBaseButton.addGestureRecognizer(jigglingLongPressGesture)
            stopJiggling()
            currentBaseButton.removeGestureRecognizer(sender)
        }
    }
    
    func handleCurrentBaseButtonLongPress(sender: UILongPressGestureRecognizer) {
        let transfer:CGPoint = sender.locationInView(completeStringView)
        if sender.state == .Began {
            currentBaseButton.removeGestureRecognizer(jigglingPanGesture)
            currentBaseButton.alpha = 0.5
            originalCenter = currentBaseButton.center
            longPressX = transfer.x - originalCenter.x
            longPressY = transfer.y - originalCenter.y
        } else if sender.state == .Changed {
            currentBaseButton.center = CGPointMake(transfer.x - longPressX, transfer.y - longPressY)
            if(currentBaseButton.center.x > completeStringView.contentOffset.x + trueWidth/2){
                stopLeftEdgeTimer()
                startRightEdgeTimer()
            }else{
                stopRightEdgeTimer()
                startLeftEdgeTimer()
            }
        } else if sender.state == .Ended || sender.state == .Cancelled {
            stopLeftEdgeTimer()
            stopRightEdgeTimer()
            currentBaseButton.alpha = 0.8
            var indexFret: Int = Int()
            var indexString: Int = Int()
            let location = currentBaseButton.center
            for index in 0..<string6FretPosition.count {
                if location.x < string6FretPosition[string6FretPosition.count - 2] {
                    if location.x > string6FretPosition[index] && location.x < string6FretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for index in 0..<6 {
                if CGRectContainsPoint(string6View[index].frame, location) {
                    indexString = index
                }
            }
            PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
            var oldNoteButtonTag:Int = 0
            if indexString >= 3 {
                stopJiggling()
                let buttonFret = (string6FretPosition[indexFret] + string6FretPosition[indexFret + 1]) / 2
                let buttonString = string6Position[indexString]
                let buttonWidth = 9 / 60 * trueHeight
                currentBaseButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
                currentBaseButton.layer.cornerRadius = buttonWidth/2
                let noteButton = currentBaseButton
                oldNoteButtonTag = noteButton.tag
                noteButton.tag = (indexString + 1) * 100 + indexFret
                let tabName = TabsDataManager.fretsBoard[indexString][indexFret]
                noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
                tabNameTextField.text = ""
                fingerPoint[6 - (indexString + 1)].hidden = true
                currentNoteButton = noteButton
                currentBaseButton = noteButton
                noteButtonOnCompeteScrollView = noteButton
                if(oldNoteButtonTag != currentNoteButton.tag){
                    addSpecificTabButton(noteButton.tag)
                }
                checkTheFingerPoint(noteButton.tag, oldTag: oldNoteButtonTag, oldTagString4: oldTagString4, oldTagString5: oldTagString5)
            } else {
                currentBaseButton.center = originalCenter
            }
            currentBaseButton.removeGestureRecognizer(jigglingLongPressGesture)
            jigglingChanged()
            if abs(location.x - currentBaseButton.center.x) > 1 || abs(location.y - currentBaseButton.center.y) > 1 || oldNoteButtonTag != currentBaseButton.tag {
                currentBaseButton.addGestureRecognizer(jigglingTapGesture)
                stopJiggling()
                currentBaseButton.removeGestureRecognizer(jigglingPanGesture)
            } else {
                currentBaseButton.addGestureRecognizer(jigglingPanGesture)
            }
        }
    }
    
    func startRightEdgeTimer(){
        if rightEdgeTimer == nil {
            stopEdgeStartTime = -1
            rightEdgeTimer = NSTimer()
            rightEdgeTimer = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("autoScrollingOnEdgeToRight"), userInfo: nil, repeats: true)
        }
    }
    
    func stopRightEdgeTimer(){
        if rightEdgeTimer == nil {
            return
        }
        rightEdgeTimer!.invalidate()
        rightEdgeTimer = nil
        stopEdgeStartTime = -1
    }
    
    func startLeftEdgeTimer(){
        if leftEdgeTimer == nil {
            stopEdgeStartTime = -1
            leftEdgeTimer = NSTimer()
            leftEdgeTimer = NSTimer.scheduledTimerWithTimeInterval( 0.01, target: self, selector: Selector("autoScrollingOnEdgeToLeft"), userInfo: nil, repeats: true)
        }
    }
    
    func stopLeftEdgeTimer(){
        if leftEdgeTimer == nil {
            return
        }
        leftEdgeTimer!.invalidate()
        leftEdgeTimer = nil
        stopEdgeStartTime = -1
    }
    
    func checkTheFingerPoint(newTag: Int, oldTag: Int, oldTagString4:Int, oldTagString5:Int) {
        let indexString = newTag / 100
        if indexString > oldTag / 100 {
            moveFingerPoint(newTag%100, indexString: indexString - 1)
            fingerPoint[6 - indexString].hidden = true
            fingerPoint[6 - indexString].accessibilityIdentifier = "grayButton"
            fingerPoint[6 - indexString].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            if fingerPoint[3].hidden {
                return
            }
            if fingerPoint[2].hidden {
                moveFingerPoint(oldTagString4, indexString: 3)
            }
            fingerPoint[2].hidden = false
            fingerPoint[2].accessibilityIdentifier = "grayButton"
            fingerPoint[2].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            if indexString == 6 {
                moveFingerPoint(oldTagString5, indexString: 4)
                fingerPoint[1].hidden = false
                fingerPoint[1].accessibilityIdentifier = "grayButton"
                fingerPoint[1].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            }
        } else {
            if indexString == 4 {
                if oldTag/100 != newTag/100 {
                    self.oldTagString4 = fingerPoint[2].tag
                    if(!fingerPoint[1].hidden){
                        self.oldTagString5 = fingerPoint[1].tag
                    }
                }
                moveFingerPoint(newTag%100, indexString: indexString-1)
                moveFingerPoint(0, indexString: 4)
                moveFingerPoint(0, indexString: 5)
                fingerPoint[0].hidden = true
                fingerPoint[1].hidden = true
                fingerPoint[2].hidden = true
                fingerPoint[0].accessibilityIdentifier = "blackX"
                fingerPoint[1].accessibilityIdentifier = "blackX"
                fingerPoint[2].accessibilityIdentifier = "grayButton"
                fingerPoint[0].setImage(UIImage(named: "blackX"), forState: UIControlState.Normal)
                fingerPoint[1].setImage(UIImage(named: "blackX"), forState: UIControlState.Normal)
                fingerPoint[2].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            } else if  indexString == 5 {
                if oldTag/100 != newTag/100 {
                    self.oldTagString4 = fingerPoint[2].tag
                    self.oldTagString5 = fingerPoint[1].tag
                }
                moveFingerPoint(newTag%100, indexString: indexString-1)
                moveFingerPoint(0, indexString: 5)
                fingerPoint[0].hidden = true
                fingerPoint[1].hidden = true
                fingerPoint[0].accessibilityIdentifier = "blackX"
                fingerPoint[1].accessibilityIdentifier = "grayButton"
                fingerPoint[0].setImage(UIImage(named: "blackX"), forState: UIControlState.Normal)
                fingerPoint[1].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            } else if indexString == 6 {
                if oldTag/100 != newTag/100 {
                    self.oldTagString5 = fingerPoint[1].tag
                }
                moveFingerPoint(newTag%100, indexString: indexString-1)
                fingerPoint[0].hidden = true
                fingerPoint[0].accessibilityIdentifier = "grayButton"
                fingerPoint[0].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            }
        }
    }
    
    func shakeAnimationTextField(){
        //remind and shake
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(tabNameTextField.center.x - 10, tabNameTextField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(tabNameTextField.center.x + 10, tabNameTextField.center.y))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        tabNameTextField.layer.addAnimation(animation, forKey: "position")
    }
    
    func shakeAnimationScrollView(){
        //remind and shake
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(specificTabsScrollView.center.x - 10, specificTabsScrollView.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(specificTabsScrollView.center.x + 10, specificTabsScrollView.center.y))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        specificTabsScrollView.layer.addAnimation(animation, forKey: "position")
    }
    
    func shakeAnimationStatusLabel(){
        //remind and shake
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(statusLabel.center.x - 10, statusLabel.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(statusLabel.center.x + 10, statusLabel.center.y))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        statusLabel.layer.addAnimation(animation, forKey: "position")
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
        let currentCenter:CGPoint = currentBaseButton.center
        let buttonWidth = 9 / 60 * trueHeight
        if currentCenter.x - buttonWidth/2 > completeStringView.contentOffset.x+trueWidth - 1.2*buttonWidth {
            if(completeStringView.contentOffset.x + trueWidth >= 5 * trueWidth - 10){
                stopEdgeStartTime = -1
                return
            }
            if stopEdgeStartTime == -1 {
                stopEdgeStartTime = CACurrentMediaTime()
            }
            let nowTime = CACurrentMediaTime()
            if nowTime - stopEdgeStartTime >= 0.8 {
                stopEdgeStartTime = -1
                UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
                    self.completeStringView.contentOffset.x = self.completeStringView.contentOffset.x + self.trueWidth
                    self.currentBaseButton.center.x = currentCenter.x + self.trueWidth
                    }, completion: {
                        completed in
                        self.stopEdgeStartTime = -1
                })
            }
        } else {
            self.stopEdgeStartTime = -1
        }
    }
    
    func autoScrollingOnEdgeToLeft() {
        let currentCenter:CGPoint = currentBaseButton.center
        let buttonWidth = 9 / 60 * trueHeight
        if currentCenter.x + buttonWidth / 2 < completeStringView.contentOffset.x + 1.2 * buttonWidth {
            if completeStringView.contentOffset.x < 10 {
                stopEdgeStartTime = -1
                return
            }
            if stopEdgeStartTime == -1 {
                stopEdgeStartTime = CACurrentMediaTime()
            }
            let nowTime = CACurrentMediaTime()
            if nowTime - stopEdgeStartTime >= 0.8 {
                stopEdgeStartTime = -1
                UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
                    self.completeStringView.contentOffset.x = self.completeStringView.contentOffset.x - self.trueWidth
                    self.currentBaseButton.center.x = currentCenter.x - self.trueWidth
                    }, completion: {
                        completed in
                        self.stopEdgeStartTime = -1
                })
            }
        }else{
            stopEdgeStartTime = -1
        }
        
    }
}

extension TabsEditorViewController {
    func startMainViewJiggling(sender:UILongPressGestureRecognizer?=nil){
        if(sender == nil || sender!.state == .Began){
            for buttonWithTab in noteButtonWithTabArray {
                let button = buttonWithTab.noteButton
                let gesture = longPressMainViewNoteButton[button]
                startNormalJinggling(gesture!)
            }
            if tempTapView == nil {
                tempTapView = UIView(frame: CGRectMake(musicControlView.frame.origin.x, musicControlView.frame.origin.y, musicControlView.frame.size.width, musicControlView.frame.size.height))
                temptapOnEditView.addTarget(self, action: "tapOnEditView:")
                tempTapView!.addGestureRecognizer(temptapOnEditView)
                view.addSubview(tempTapView!)
            }
        }
    }
    
    func stopMainViewJiggling(){
        for buttonWithTab in noteButtonWithTabArray {
            let button = buttonWithTab.noteButton
            let gesture = longPressMainViewNoteButton[button]
            stopNormalJinggling(gesture!, button: button)
        }
        completeStringView.userInteractionEnabled = true
        musicControlView.userInteractionEnabled = true
        if(tempTapView != nil){
            tempTapView!.removeGestureRecognizer(temptapOnEditView)
            tempTapView!.removeFromSuperview()
            tempTapView = nil
        }
        isJiggling = false
    }
    
    func startNormalJinggling(sender: UILongPressGestureRecognizer) {
        if isJiggling {
            stopJiggling()
        }
        if !intoEditView {
            musicControlView.userInteractionEnabled = false
        }
        removeDoubleArrowView()
        let tempView = sender.view!
        let buttonWidth = tempView.frame.size.width
        let buttonHeight = tempView.frame.size.height
        let oldCornerRadius = tempView.layer.cornerRadius
        var delta: CGFloat = 0
        let originalX = tempView.center.x
        // circle
        if oldCornerRadius >= 0.5 * buttonWidth - 0.1 && oldCornerRadius <= 0.5 * buttonWidth + 0.1 {
            sender.enabled = false
            isJiggling = true
            delta = CGFloat((1 - sqrt(2.0))/2.0) * (tempView.frame.size.width/2.0) + (tempView.frame.size.width/4.0 - tempView.frame.size.width/6.0)
            tempView.center.x = originalX - 1
            let tempDeleteChordOnMainView = UITapGestureRecognizer(target: self, action: "deleteChordOnMainView:")
            tempDeleteChordOnMainView.delegate = self
            deleteChordOnMainView[tempView as! UIButton] = tempDeleteChordOnMainView
            tempView.addGestureRecognizer(tempDeleteChordOnMainView)
            let randomInt: UInt32  = arc4random_uniform(500)
            let r:Double = (Double(randomInt) / 500.0) + 5
            let leftWobble: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( (kAnimationRotateDeg * -1.0) - r)))
            let rightWobble: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(degreesToRadians( kAnimationRotateDeg + r)))
            tempView.transform = leftWobble;  // starting point
            tempView.layer.anchorPoint = CGPointMake(0.5, 0.5)
            let tempDeleteView = UIImageView(image: UIImage(named: "deleteX"))
            tempDeleteView.frame = CGRectMake(delta, delta, buttonHeight / 3, buttonHeight / 3)
            deleteViewArray[tempView as! UIButton] = tempDeleteView
            tempView.addSubview(tempDeleteView)
            UIView.animateWithDuration(0.1, delay: 0, options: [.AllowUserInteraction, .Repeat, .Autoreverse], animations: {
                UIView.setAnimationRepeatCount(Float(NSNotFound))
                if oldCornerRadius == 0.5 * buttonWidth {
                    tempView.center.x = originalX + 1
                }
                tempView.transform = rightWobble
                }, completion: nil
            )
            completeStringView.userInteractionEnabled = false
        } else if sender.state == .Began {
            sender.enabled = false
            stopSpecificJiggling()
            sender.enabled = false
            isJiggling = true
            delta = -(buttonHeight / 3 / 2 - buttonHeight / 15)
            deleteChordOnSpecificTabView.addTarget(self, action: "deleteChordOnSpecificTabView:")
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
            completeStringView.userInteractionEnabled = false
        }
    }
    
    func stopNormalJinggling(sender: UILongPressGestureRecognizer, button:UIButton?=nil) {
        if sender.enabled {
            return
        }
        if button == nil {
            completeStringView.userInteractionEnabled = true
            isJiggling = false
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
        for i in 0..<noteButtonWithTabArray.count{
            if noteButtonWithTabArray[i].tab.index == Int(currentSelectedSpecificTab.index) && noteButtonWithTabArray[i].tab.name == currentSelectedSpecificTab.name && noteButtonWithTabArray[i].tab.content == currentSelectedSpecificTab.content {
                needAlert = true
                break
            }
        }
        if needAlert == false {
            for i in 0..<allTabsOnMusicLine.count {
                if allTabsOnMusicLine[i].tab.index == Int(currentSelectedSpecificTab.index) && allTabsOnMusicLine[i].tab.name == currentSelectedSpecificTab.name && allTabsOnMusicLine[i].tab.content == currentSelectedSpecificTab.content {
                    needAlert = true
                    break
                }
            }
        }
        if needAlert {
            let alertController = UIAlertController(title: nil, message: "This operation will delete all '\(currentSelectedSpecificTab.name)' you have already added to the song.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: {
                action in
                self.stopSpecificJiggling()
            }))
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: {
                action in
                self.deleteActionOnSpecificTabView()
                
            }))
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            deleteActionOnSpecificTabView()
        }
    }
    
    func deleteActionOnSpecificTabView() {
        isShowDiscardAlert = true
        deleteChordOnMainViewWhenDeleteOnEditView(Int(currentSelectedSpecificTab.index), name: currentSelectedSpecificTab.name, content: currentSelectedSpecificTab.content)
        removeObjectsOnSpecificTabsScrollView()
        TabsDataManager.removeTabs(currentSelectedSpecificTab.tabs)
        tabNameTextField.text = currentNoteButton.titleLabel?.text
        stopSpecificJiggling()
        addSpecificTabButton(currentBaseButton.tag)
    }
    
    func deleteChordOnMainView(sender: UITapGestureRecognizer) {
        if isTapedOnButton {
            return
        }
        isShowDiscardAlert = true
        let index: Int = (sender.view?.tag)!
        stopNormalJinggling(longPressMainViewNoteButton[noteButtonWithTabArray[index].noteButton]!, button: noteButtonWithTabArray[index].noteButton)
        let fretNumber = Int(noteButtonWithTabArray[index].tab.index) - Int(noteButtonWithTabArray[index].tab.index) / 100 * 100
        for i in 0..<mainViewDataArray.count {
            if mainViewDataArray[i].fretNumber == fretNumber {
                for j in 0..<mainViewDataArray[i].noteButtonsWithTab.count {
                    if compareTabs(mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: noteButtonWithTabArray[index].tab) {
                        mainViewDataArray[i].noteButtonsWithTab[j].noteButton.removeFromSuperview()
                        mainViewDataArray[i].noteButtonsWithTab.removeAtIndex(j)
                        break
                    }
                }
            }
        }
        noteButtonWithTabArray.removeAtIndex(index)
        for i in 0..<noteButtonWithTabArray.count {
            noteButtonWithTabArray[i].noteButton.tag = i
        }
        stopMainViewJiggling()
        reorganizeMainViewDataArray()
        startMainViewJiggling()
        if(noteButtonWithTabArray.count == 0){
            completeStringView.userInteractionEnabled = true
            if(tempTapView != nil){
                tempTapView?.removeGestureRecognizer(temptapOnEditView)
                tempTapView!.removeFromSuperview()
                tempTapView = nil
            }
            musicControlView.userInteractionEnabled = true
            isJiggling = false
        }
    }
    
    // need to check whether the main view contain the delete tab
    func deleteChordOnMainViewWhenDeleteOnEditView(index: Int, name: String, content: String) {
        for i in 0..<noteButtonWithTabArray.count {
            if noteButtonWithTabArray[i].tab.index == index && noteButtonWithTabArray[i].tab.name == name && noteButtonWithTabArray[i].tab.content == content {
                deleteChordOnString3View(i)
                break
            }
        }
        deleteChordOnMusicLine(index, name: name, content: content)
    }
    
    func deleteChordOnString3View(sender: Int) {
        let fretNumber = Int(noteButtonWithTabArray[sender].tab.index) - Int(noteButtonWithTabArray[sender].tab.index) / 100 * 100
        for i in 0..<mainViewDataArray.count {
            if mainViewDataArray[i].fretNumber == fretNumber {
                for j in 0..<mainViewDataArray[i].noteButtonsWithTab.count {
                    if compareTabs(mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: noteButtonWithTabArray[sender].tab)  {
                        mainViewDataArray[i].noteButtonsWithTab[j].noteButton.removeFromSuperview()
                        mainViewDataArray[i].noteButtonsWithTab.removeAtIndex(j)
                        break
                    }
                }
            }
        }
        noteButtonWithTabArray.removeAtIndex(sender)
        for i in 0..<noteButtonWithTabArray.count {
            noteButtonWithTabArray[i].noteButton.tag = i
        }
        reorganizeMainViewDataArray()
    }
    
    func deleteChordOnMusicLine(index: Int, name: String, content: String) {
        for var i = 0; i < allTabsOnMusicLine.count; i++ {
            if allTabsOnMusicLine[i].tab.index == index && allTabsOnMusicLine[i].tab.name == name && allTabsOnMusicLine[i].tab.content == content {
                allTabsOnMusicLine[i].tabView.removeFromSuperview()
                allTabsOnMusicLine.removeAtIndex(i)
                i--
            }
        }
        reorganizeAllTabsOnMusicLine()
    }
    
    func reorganizeAllTabsOnMusicLine() {
        var tempAllTabsOnMusicLine: [tabOnMusicLine] = [tabOnMusicLine]()
        for j in 0..<allTabsOnMusicLine.count {
            currentTime = allTabsOnMusicLine[j].time
            allTabsOnMusicLine[j].tabView.frame = setMainViewTabPositionInRange(allTabsOnMusicLine[j].tab, endIndex: tempAllTabsOnMusicLine.count, allTabsOnMusicLine: tempAllTabsOnMusicLine)
            
            tempAllTabsOnMusicLine.append(allTabsOnMusicLine[j])
            
        }
        tempAllTabsOnMusicLine.removeAll()
    }
    
    func backButtonRotation(isLeft isLeft:Bool){
        let leftWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians(0)))
        let rightWobble: CGAffineTransform  = CGAffineTransformMakeRotation(CGFloat(degreesToRadians(-90)))
        
        backButton.userInteractionEnabled = false
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