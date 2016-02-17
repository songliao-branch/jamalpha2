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
        layout.itemSize = CGSize(width: trueWidth / 5, height: 12 / 20 * trueHeight)
        //var flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.scrollDirection = scrollDirection
        let frame = CGRectMake(0, trueHeight * 8 / 20, trueWidth, 12 / 20 * trueHeight)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.registerClass(FretCell.self, forCellWithReuseIdentifier: "fretcell")
        collectionView.bounces = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        calculateBorders()
        prepareMoveSwipeUpGesture.addTarget(self, action: "prepareMoveSwipeGesture:")
        prepareMoveSwipeUpGesture.direction = .Up
        prepareMoveSwipeUpGesture.delegate = self
        prepareMoveSwipeUpGesture.requireGestureRecognizerToFail(collectionView.panGestureRecognizer)
        collectionView.addGestureRecognizer(prepareMoveSwipeUpGesture)
        prepareMoveSwipeDownGesture.addTarget(self, action: "prepareMoveSwipeGesture:")
        prepareMoveSwipeDownGesture.direction = .Down
        prepareMoveSwipeDownGesture.delegate = self
        prepareMoveSwipeDownGesture.requireGestureRecognizerToFail(collectionView.panGestureRecognizer)
        collectionView.addGestureRecognizer(prepareMoveSwipeDownGesture)
        checkPanGesture.addTarget(self, action: "checkScrollview:")
        checkPanGesture.delegate = self
        collectionView.addGestureRecognizer(checkPanGesture)
        tapGesture = UITapGestureRecognizer(target: self, action: "singleTapOnCollectionView:")
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    func checkScrollview(sender:UIPanGestureRecognizer){
        let transfer = sender.velocityInView(collectionView)
        if(sender.state == .Began){
            if abs(transfer.x) >= abs(transfer.y) {
                collectionView.scrollEnabled = true
                return
            }
            collectionView.scrollEnabled = false
        } else if(sender.state == .Ended || sender.state == .Cancelled){
            collectionView.scrollEnabled = true
        }
    }
    
    func prepareMoveSwipeGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Up {
            startScrolling = false
            let location = sender.locationInView(collectionView)
            var positionX: CGFloat = 0
            for index in 0..<string3FretPosition.count {
                if location.x < string3FretPosition[string3FretPosition.count - 1] {
                    if location.x > string3FretPosition[index] && location.x < string3FretPosition[index + 1] {
                        positionX = string3FretPosition[index] - collectionView.contentOffset.x
                        doubleViewPositionX = string3FretPosition[index] + (trueWidth / 5 - 10)/2 + 5
                        break
                    }
                }
            }
            let imageWidth: CGFloat = trueWidth / 5 - 10
            let imageHeight: CGFloat = kmovingMainNoteSliderHeight
            doubleArrowView = CustomizedView(frame: CGRectMake(positionX + 5, collectionView.frame.origin.y, imageWidth, imageHeight))
            view.insertSubview(doubleArrowView, belowSubview: collectionView)
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
            prepareMoveSwipeUpGesture.enabled = false
            prepareMoveSwipeDownGesture.enabled = true
        } else if sender.direction == .Down {
            removeDoubleArrowView()
            prepareMoveSwipeUpGesture.enabled = true
            prepareMoveSwipeDownGesture.enabled = false
        }
    }
    
    func singleTapOnCollectionView(sender: UITapGestureRecognizer) {
        if isJiggling == false {
            changeMenuButtonStatus(true)
            var indexFret: Int = Int()
            var indexString: Int = Int()
            indexString = 5
            let string3Height: CGFloat = 11 / 60 * trueHeight / 2
            var original:CGPoint = CGPointMake(0,string3Height  - string3Position[2])
            let location = sender.locationInView(collectionView)
            // get the tap position for fret number and string number
            for index in 0..<string3FretPosition.count {
                if location.x < string3FretPosition[string3FretPosition.count - 1] {
                    if location.x > string3FretPosition[index] && location.x < string3FretPosition[index + 1] {
                        let tempIndex = fretsNumber[index]
                        indexFret = tempIndex
                        original.x = (string3FretPosition[index] + string3FretPosition[index + 1])/2.0
                        if(index != tempIndex){
                            isCompleteStringViewScroll = true
                        }
                        baseNoteLocation = original.x - collectionView.contentOffset.x
                        break
                    }
                }
            }
            for index in 0..<string3Position.count {
                if location.y >= string3Position[index] - string3Height && location.y <= string3Position[index] + string3Height {
                    indexString = index + 3
                    original.y = string3Height  - string3Position[index]
                }
            }
            PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
            // open the editor view and add note button
            addButtonPress3StringView(indexFret: indexFret, indexString: indexString, original: original)
        } else {
            stopMainViewJiggling()
        }
    }
    
    
    func addButtonPress3StringView(indexFret indexFret: Int, indexString: Int, original:CGPoint?=nil) {
        if doubleArrowView != nil {
            doubleArrowView.alpha = 0
        }
        removeDoubleArrowView()
        view.userInteractionEnabled = false
        view.addSubview(editView)
        if isDemoSong {
            avPlayer.pause()
        } else {
            musicPlayer.pause()
        }
        timer.invalidate()
        timer = NSTimer()
        countDownNumber = 3
        addSpecificFingerPoint = false
        musicControlView.alpha = 0
        progressBlock.alpha = 0
        collectionView.alpha = 0
        statusLabel.text = "Add a new chord"
        intoEditView = true
        addNewTab = true
        addedNoteButtonOnCompleteView = true
        addNoteButton(indexFret, indexString: indexString, originalPosition: original)
        let buttonFret = (string6FretPosition[indexFret] + string6FretPosition[indexFret + 1]) / 2
        completeStringView.contentOffset = collectionView.contentOffset
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
        backButtonRotation(isLeft: false)
        view.userInteractionEnabled = true
    }
    
    
    func calculateBorders() {
        if let collectionView = collectionView {
            collectionViewFrameInCanvas = collectionView.frame
            if view != collectionView.superview {
                collectionViewFrameInCanvas = view!.convertRect(collectionViewFrameInCanvas, fromView: collectionView)
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
      if scrollingTimer == nil {
          return
      }
      scrollingTimer!.invalidate()
      scrollingTimer = nil
    }
    
    func changDoubleArrowPosition(){
        if doubleArrowView == nil {
            return
        }
        doubleArrowView.center.x = doubleViewPositionX - collectionView.contentOffset.x
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("fretcell", forIndexPath: indexPath) as! FretCell
        cell.imageView.backgroundColor = UIColor.clearColor()
        cell.imageView.image = UIImage(named: string3BackgroundImage[indexPath.item])
        cell.imageView.contentMode = .ScaleAspectFill
        cell.fretNumberLabel.text = "\(fretsNumber[indexPath.item])"
        for subview in cell.contentView.subviews {
            if subview.isKindOfClass(UIButton){
                subview.removeFromSuperview()
            }
        }
        for item in mainViewDataArray[indexPath.item].noteButtonsWithTab {
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
        if let ca = view {
            if let cv = collectionView {
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
                        bundle = Bundle(offset: offset, sourceCell: cell, representationImageView:representationImage, currentIndexPath: indexPath, canvas: ca)
                        break
                    }
                }
            }
        }
        return bundle != nil
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func checkForDraggingAtTheEdgeAndAnimatePaging(gestureRecognizer: UIGestureRecognizer) {
        if animating == true {
            return
        }
        if let bundle = bundle {
            var nextPageRect : CGRect = collectionView!.bounds
            if layout.scrollDirection == UICollectionViewScrollDirection.Horizontal {
                if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["left"]!) {
                    nextPageRect.origin.x -= nextPageRect.size.width
                    if nextPageRect.origin.x < 0.0 {
                        nextPageRect.origin.x = 0.0
                    }
                }
                else if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["right"]!) {
                    nextPageRect.origin.x += nextPageRect.size.width
                    if nextPageRect.origin.x + nextPageRect.size.width > collectionView!.contentSize.width {
                        nextPageRect.origin.x = collectionView!.contentSize.width - nextPageRect.size.width
                    }
                }
            }
            else if layout.scrollDirection == UICollectionViewScrollDirection.Vertical {
                if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["top"]!) {
                    nextPageRect.origin.y -= nextPageRect.size.height
                    if nextPageRect.origin.y < 0.0 {
                        nextPageRect.origin.y = 0.0
                    }
                }
                else if CGRectIntersectsRect(bundle.representationImageView.frame, hitTestRectagles["bottom"]!) {
                    nextPageRect.origin.y += nextPageRect.size.height
                    if nextPageRect.origin.y + nextPageRect.size.height > collectionView!.contentSize.height {
                        nextPageRect.origin.y = collectionView!.contentSize.height - nextPageRect.size.height
                    }
                }
            }
            if !CGRectEqualToRect(nextPageRect, collectionView!.bounds){
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    self.animating = false
                    self.handleGesture(gestureRecognizer as! UIPanGestureRecognizer)
                })
                animating = true
                collectionView!.scrollRectToVisible(nextPageRect, animated: true)
            }
        }
    }
    
    func handleGesture(gesture: UIPanGestureRecognizer) -> Void {
        if let bundle = bundle {
            let dragPointOnCanvas = gesture.locationInView(view)
            if gesture.state == UIGestureRecognizerState.Began {
                collectionView.scrollEnabled = false
                tapGesture.enabled = false
                stopScrollTimer()
                startScrolling = false
                isPanning = true
                bundle.sourceCell.hidden = true
                view?.addSubview(bundle.representationImageView)
                view.userInteractionEnabled = false
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    bundle.representationImageView.alpha = 0.8
                })
                view.userInteractionEnabled = false
            }
            if gesture.state == UIGestureRecognizerState.Changed {
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y + kmovingMainNoteSliderHeight
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                let tempX = gesture.locationInView(collectionView).x
                let tempY = gesture.locationInView(collectionView).y + kmovingMainNoteSliderHeight + collectionView.frame.size.height / 2
                let dragPointOnCollectionView = CGPointMake(tempX, tempY)//gesture.locationInView(collectionView)
                if let toIndexPath : NSIndexPath = collectionView?.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                    if toIndexPath.isEqual(bundle.currentIndexPath) == false {
                        moveDataItem(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        collectionView!.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        self.bundle!.currentIndexPath = toIndexPath
                    }
                }                
                doubleArrowView.center = CGPointMake(bundle.representationImageView.center.x, bundle.representationImageView.frame.origin.y - kmovingMainNoteSliderHeight/2)
            }
            if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
                doubleArrowView.center.x = bundle.sourceCell.center.x - collectionView.contentOffset.x
                doubleArrowView.frame.origin.y = collectionView.frame.origin.y - kmovingMainNoteSliderHeight
                bundle.sourceCell.hidden = false
                bundle.representationImageView.removeFromSuperview()
                collectionView!.reloadData()
                self.bundle = nil
                
                doubleArrowView.removeGestureRecognizer(gesture)
                removeDoubleArrowView()
                tapGesture.enabled = true
                view.userInteractionEnabled = true
                isPanning = false
                collectionView.scrollEnabled = true
                for i in 0..<fretsNumber.count {
                    string3FretChangeingPosition[fretsNumber[i]] = string3FretPosition[i]
                }
            }
        }
    }
    
    func removeDoubleArrowView(){
        startScrolling = false
        if(doubleArrowView != nil){
            doubleArrowView.removeFromSuperview()
            view.insertSubview(doubleArrowView, belowSubview: collectionView)
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