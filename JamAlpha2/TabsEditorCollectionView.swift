//
//  TabsEditorCollectionView.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/25/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension TabsEditorViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    func initCollectionView() {
        for i in 0..<25 {
            fretsNumber.append(i)
        }
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.trueWidth / 5, height: 12 / 20 * self.trueHeight)
        //var flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.scrollDirection = scrollDirection
        let frame = CGRectMake(0, self.trueHeight * 8 / 20, self.trueWidth, 12 / 20 * self.trueHeight)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.registerClass(FretCell.self, forCellWithReuseIdentifier: "fretcell")
        collectionView.bounces = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.bounces = false
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        calculateBorders()
        
        prepareMoveSwipeUpGesture.addTarget(self, action: "prepareMoveSwipeGesture:")
        prepareMoveSwipeUpGesture.direction = .Up
        prepareMoveSwipeUpGesture.delegate = self
        prepareMoveSwipeUpGesture.requireGestureRecognizerToFail(self.collectionView.panGestureRecognizer)
        collectionView.addGestureRecognizer(prepareMoveSwipeUpGesture)
        
        
        prepareMoveSwipeDownGesture.addTarget(self, action: "prepareMoveSwipeGesture:")
        prepareMoveSwipeDownGesture.direction = .Down
        prepareMoveSwipeDownGesture.delegate = self
        prepareMoveSwipeDownGesture.requireGestureRecognizerToFail(self.collectionView.panGestureRecognizer)
        collectionView.addGestureRecognizer(prepareMoveSwipeDownGesture)
        
        checkPanGesture.addTarget(self, action: "checkScrollview:")
        checkPanGesture.delegate = self
        collectionView.addGestureRecognizer(checkPanGesture)
        
        
        tapGesture = UITapGestureRecognizer(target: self, action: "singleTapOnCollectionView:")
        collectionView.addGestureRecognizer(tapGesture)
        
    }
    
    func checkScrollview(sender:UIPanGestureRecognizer){
        let transfer = sender.velocityInView(self.collectionView)
        if(sender.state == .Began){
            if(abs(transfer.x) >= abs(transfer.y)){
                self.collectionView.scrollEnabled = true
            }else{
                self.collectionView.scrollEnabled = false
            }
        }
        
        if(sender.state == .Ended || sender.state == .Cancelled){
            self.collectionView.scrollEnabled = true
        }
    }
    
    func prepareMoveSwipeGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Up {
            self.startScrolling = false
            let location = sender.locationInView(collectionView)
            var positionX: CGFloat = 0
            for index in 0..<self.string3FretPosition.count {
                if location.x < self.string3FretPosition[self.string3FretPosition.count - 1] {
                    if location.x > self.string3FretPosition[index] && location.x < self.string3FretPosition[index + 1] {
                        positionX = self.string3FretPosition[index] - self.collectionView.contentOffset.x
                        self.doubleViewPositionX = self.string3FretPosition[index] + (self.trueWidth / 5 - 10)/2 + 5
                        break
                    }
                }
            }
            let imageWidth: CGFloat = self.trueWidth / 5 - 10
            let imageHeight: CGFloat = kmovingMainNoteSliderHeight
            self.doubleArrowView = CustomizedView(frame: CGRectMake(positionX + 5, collectionView.frame.origin.y, imageWidth, imageHeight))
            self.view.insertSubview(self.doubleArrowView, belowSubview: self.collectionView)
            UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn,.AllowUserInteraction], animations: {
                self.doubleArrowView.center.y = self.doubleArrowView.center.y - kmovingMainNoteSliderHeight
                }, completion: {
                    completed in
                    self.doubleArrowView.removeFromSuperview()
                    self.view.insertSubview(self.doubleArrowView, aboveSubview: self.collectionView)
                    let gesture = UIPanGestureRecognizer(target: self,
                        action: "handleGesture:")
                    
                    gesture.delegate = self
                    self.doubleArrowView.addGestureRecognizer(gesture)
                    self.doubleArrowView.userInteractionEnabled = true
                    self.startScrollTimer()
            })
            self.prepareMoveSwipeUpGesture.enabled = false
            self.prepareMoveSwipeDownGesture.enabled = true
            
            
        } else if sender.direction == .Down {
            self.removeDoubleArrowView()
            self.prepareMoveSwipeUpGesture.enabled = true
            self.prepareMoveSwipeDownGesture.enabled = false
        }
    }
    
    func singleTapOnCollectionView(sender: UITapGestureRecognizer) {
        if isJiggling == false {
            self.changeMenuButtonStatus(true)
            var indexFret: Int = Int()
            var indexString: Int = Int()
            indexString = 5
            let string3Height: CGFloat = 11 / 60 * self.trueHeight / 2
            var original:CGPoint = CGPointMake(0,string3Height  - self.string3Position[2])
            let location = sender.locationInView(self.collectionView)
            // get the tap position for fret number and string number
            for index in 0..<self.string3FretPosition.count {
                if location.x < self.string3FretPosition[self.string3FretPosition.count - 1] {
                    if location.x > self.string3FretPosition[index] && location.x < self.string3FretPosition[index + 1] {
                        let tempIndex = fretsNumber[index]
                        indexFret = tempIndex
                        original.x = (self.string3FretPosition[index] + self.string3FretPosition[index + 1])/2.0
                        if(index != tempIndex){
                            self.isCompleteStringViewScroll = true
                        }
                        baseNoteLocation = original.x - collectionView.contentOffset.x
                        
                        break
                    }
                }
            }
            for index in 0..<self.string3Position.count {
                if location.y >= self.string3Position[index] - string3Height && location.y <= self.string3Position[index] + string3Height {
                    indexString = index + 3
                    original.y = string3Height  - self.string3Position[index]
                }
            }
            PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
            // open the editor view and add note button
            self.addButtonPress3StringView(indexFret: indexFret, indexString: indexString, original: original)
        } else {
            self.stopMainViewJiggling()
        }
    }
    
    
    func addButtonPress3StringView(indexFret indexFret: Int, indexString: Int, original:CGPoint?=nil) {
        if(self.doubleArrowView != nil){
            self.doubleArrowView.alpha = 0
        }
        self.removeDoubleArrowView()
        self.view.userInteractionEnabled = false
        self.view.addSubview(self.editView)
        if isDemoSong {
            self.avPlayer.pause()
        } else {
            self.musicPlayer.pause()
        }
        self.timer.invalidate()
        self.timer = NSTimer()
        self.countDownNumber = 3
        
        self.addSpecificFingerPoint = false
        self.musicControlView.alpha = 0
        self.progressBlock.alpha = 0
        self.collectionView.alpha = 0
        self.statusLabel.text = "Add New Chords"
        self.intoEditView = true
        
        self.addNewTab = true
        self.addedNoteButtonOnCompleteView = true
        self.addNoteButton(indexFret, indexString: indexString, originalPosition: original)
        let buttonFret = (self.string6FretPosition[indexFret] + self.string6FretPosition[indexFret + 1]) / 2
        self.completeStringView.contentOffset = self.collectionView.contentOffset
        UIView.animateWithDuration(0.2, animations: {
            self.completeStringView.alpha = 1
            self.specificTabsScrollView.alpha = 1
            self.tabNameTextField.alpha = 1
            self.completeStringView.frame = CGRectMake(0, 3 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
            },completion: {
                completed in
                UIView.animateWithDuration(0.5, animations: {
                    if(self.isCompleteStringViewScroll){
                        if (buttonFret - self.baseNoteLocation < 0 ){
                            self.completeStringView.contentOffset.x = 0
                        }else if (buttonFret - self.baseNoteLocation > self.string6FretPosition[self.string6FretPosition.count-1-Int(self.capoStepper.value)]-self.trueWidth){
                            self.completeStringView.contentOffset.x = self.string6FretPosition[self.string6FretPosition.count-1-Int(self.capoStepper.value)]-self.trueWidth
                        }else{
                            self.completeStringView.contentOffset.x = buttonFret - self.baseNoteLocation
                        }
                    }
                })
        })
        self.backButtonRotation(isLeft: false)
        self.view.userInteractionEnabled = true
        
    }
    
    
    func calculateBorders() {
        if let collectionView = self.collectionView {
            collectionViewFrameInCanvas = collectionView.frame
            if self.view != collectionView.superview {
                collectionViewFrameInCanvas = self.view!.convertRect(collectionViewFrameInCanvas, fromView: collectionView)
            }
            var leftRect : CGRect = collectionViewFrameInCanvas
            leftRect.size.width = 20.0
            hitTestRectagles["left"] = leftRect
            var topRect : CGRect = collectionViewFrameInCanvas
            topRect.size.height = 20.0
            hitTestRectagles["top"] = topRect
            var rightRect : CGRect = collectionViewFrameInCanvas
            rightRect.origin.x = rightRect.size.width - 20.0
            rightRect.size.width = 20.0
            hitTestRectagles["right"] = rightRect
            var bottomRect : CGRect = collectionViewFrameInCanvas
            bottomRect.origin.y = bottomRect.origin.y + rightRect.size.height - 20.0
            bottomRect.size.height = 20.0
            hitTestRectagles["bottom"] = bottomRect
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainViewDataArray.count
    }
    
    
    func startScrollTimer(){
        if scrollingTimer == nil {
            scrollingTimer = NSTimer()
            scrollingTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("changDoubleArrowPosition"), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(scrollingTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func stopScrollTimer(){
        if(scrollingTimer != nil){
            scrollingTimer!.invalidate()
            scrollingTimer = nil
        }
    }
    
    func changDoubleArrowPosition(){
        if(self.doubleArrowView == nil){
            return
        }else{
            self.doubleArrowView.center.x = doubleViewPositionX - self.collectionView.contentOffset.x
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("fretcell", forIndexPath: indexPath) as! FretCell
        cell.imageView.backgroundColor = UIColor.clearColor()
        cell.imageView.image = UIImage(named: string3BackgroundImage[indexPath.item])
        cell.imageView.contentMode = .ScaleAspectFill
        cell.fretNumberLabel.text = "\(self.fretsNumber[indexPath.item])"
        
        
        for subview in cell.contentView.subviews {
            if subview.isKindOfClass(UIButton){
                subview.removeFromSuperview()
            }
        }
        for item in self.mainViewDataArray[indexPath.item].noteButtonsWithTab {
            cell.contentView.addSubview(item.noteButton)
        }
        
        if isJiggling {
            stopMainViewJiggling()
            startMainViewJiggling()
        }
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ca = self.view {
            if let cv = self.collectionView {
                let tempX = gestureRecognizer.locationInView(ca).x
                let tempY = gestureRecognizer.locationInView(ca).y + kmovingMainNoteSliderHeight
                let pointPressedInCanvas = CGPointMake(tempX, tempY)
                //let pointPressedInCanvas = gestureRecognizer.locationInView(ca)
                for cell in cv.visibleCells() {
                    let cellInCanvasFrame = ca.convertRect(cell.frame, fromView: cv)
                    if CGRectContainsPoint(cellInCanvasFrame, pointPressedInCanvas ) {
                        let representationImage = cell.snapshotViewAfterScreenUpdates(true)
                        representationImage.frame = cellInCanvasFrame
                        let offset = CGPointMake(pointPressedInCanvas.x - cellInCanvasFrame.origin.x, pointPressedInCanvas.y - cellInCanvasFrame.origin.y)
                        let indexPath : NSIndexPath = cv.indexPathForCell(cell as UICollectionViewCell)!
                        self.bundle = Bundle(offset: offset, sourceCell: cell, representationImageView:representationImage, currentIndexPath: indexPath, canvas: ca)
                        break
                    }
                }
            }
        }
        return (self.bundle != nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func checkForDraggingAtTheEdgeAndAnimatePaging(gestureRecognizer: UIGestureRecognizer) {
        if self.animating == true {
            return
        }
        if let bundle = self.bundle {
            
            var nextPageRect : CGRect = self.collectionView!.bounds
            if self.layout.scrollDirection == UICollectionViewScrollDirection.Horizontal {
                if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["left"]!) {
                    nextPageRect.origin.x -= nextPageRect.size.width
                    if nextPageRect.origin.x < 0.0 {
                        nextPageRect.origin.x = 0.0
                    }
                }
                else if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["right"]!) {
                    nextPageRect.origin.x += nextPageRect.size.width
                    if nextPageRect.origin.x + nextPageRect.size.width > self.collectionView!.contentSize.width {
                        nextPageRect.origin.x = self.collectionView!.contentSize.width - nextPageRect.size.width
                    }
                }
            }
            else if self.layout.scrollDirection == UICollectionViewScrollDirection.Vertical {
                
                if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["top"]!) {
                    nextPageRect.origin.y -= nextPageRect.size.height
                    if nextPageRect.origin.y < 0.0 {
                        nextPageRect.origin.y = 0.0
                    }
                }
                else if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["bottom"]!) {
                    nextPageRect.origin.y += nextPageRect.size.height
                    if nextPageRect.origin.y + nextPageRect.size.height > self.collectionView!.contentSize.height {
                        nextPageRect.origin.y = self.collectionView!.contentSize.height - nextPageRect.size.height
                    }
                }
            }
            if !CGRectEqualToRect(nextPageRect, self.collectionView!.bounds){
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    self.animating = false
                    self.handleGesture(gestureRecognizer as! UIPanGestureRecognizer)
                });
                self.animating = true
                self.collectionView!.scrollRectToVisible(nextPageRect, animated: true)
            }
        }
    }
    
    func handleGesture(gesture: UIPanGestureRecognizer) -> Void {
        if let bundle = self.bundle {
            let dragPointOnCanvas = gesture.locationInView(self.view)
            if gesture.state == UIGestureRecognizerState.Began {
                self.collectionView.scrollEnabled = false
                self.tapGesture.enabled = false
                self.stopScrollTimer()
                self.startScrolling = false
                self.isPanning = true
                bundle.sourceCell.hidden = true
                self.view?.addSubview(bundle.representationImageView)
                self.view.userInteractionEnabled = false
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    bundle.representationImageView.alpha = 0.8
                })
                self.view.userInteractionEnabled = false
            }
            if gesture.state == UIGestureRecognizerState.Changed {
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y + kmovingMainNoteSliderHeight
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                let tempX = gesture.locationInView(self.collectionView).x
                let tempY = gesture.locationInView(self.collectionView).y + kmovingMainNoteSliderHeight + self.collectionView.frame.size.height / 2
                let dragPointOnCollectionView = CGPointMake(tempX, tempY)//gesture.locationInView(self.collectionView)
                if let toIndexPath : NSIndexPath = self.collectionView?.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    self.checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                    if toIndexPath.isEqual(bundle.currentIndexPath) == false {
                        moveDataItem(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        self.collectionView!.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        self.bundle!.currentIndexPath = toIndexPath
                    }
                }
                
                self.doubleArrowView.center = CGPointMake(bundle.representationImageView.center.x, bundle.representationImageView.frame.origin.y - kmovingMainNoteSliderHeight/2)
            }
            if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
                self.doubleArrowView.center.x = bundle.sourceCell.center.x - self.collectionView.contentOffset.x
                self.doubleArrowView.frame.origin.y = self.collectionView.frame.origin.y - kmovingMainNoteSliderHeight
                bundle.sourceCell.hidden = false
                bundle.representationImageView.removeFromSuperview()
                collectionView!.reloadData()
                self.bundle = nil
                
                self.doubleArrowView.removeGestureRecognizer(gesture)
                self.removeDoubleArrowView()
                self.tapGesture.enabled = true
                self.view.userInteractionEnabled = true
                self.isPanning = false
                self.collectionView.scrollEnabled = true
                for i in 0..<fretsNumber.count {
                    self.string3FretChangeingPosition[fretsNumber[i]] = string3FretPosition[i]
                }
            }
        }
    }
    
    func removeDoubleArrowView(){
        self.startScrolling = false
        if(self.doubleArrowView != nil){
            self.doubleArrowView.removeFromSuperview()
            self.view.insertSubview(self.doubleArrowView, belowSubview: self.collectionView)
            UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseOut,.AllowUserInteraction], animations: {
                self.doubleArrowView.center.y = self.doubleArrowView.center.y + kmovingMainNoteSliderHeight
                }, completion: {
                    completed in
                    if(self.doubleArrowView != nil){
                        self.doubleArrowView.removeFromSuperview()
                        self.doubleArrowView = nil
                        self.prepareMoveSwipeUpGesture.enabled = true
                        self.stopScrollTimer()
                    }
            })
        }
        
    }
}