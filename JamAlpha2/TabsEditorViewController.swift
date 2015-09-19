//
//  ViewController.swift
//  tabEditorV3
//
//  Created by Jun Zhou on 9/1/15.
//  Copyright (c) 2015 Jun Zhou. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class TabsEditorViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    // collection view
    var collectionView: UICollectionView!
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var fretsNumber: [Int] = [Int]()
    var collectionViewFrameInCanvas : CGRect = CGRectZero
    var hitTestRectagles = [String:CGRect]()
    var animating : Bool = false
    
    //var mianViewWithTab: [UIView] = [UIView]()
    
    struct Bundle {
        var offset : CGPoint = CGPointZero
        var sourceCell : UICollectionViewCell
        var representationImageView : UIView
        var currentIndexPath : NSIndexPath
        var canvas : UIView
    }
    
    var bundle : Bundle?
    var fretBoardView: UIView = UIView()
    // music section
    var progressBlock: SoundWaveView!
    var theSong: MPMediaItem!
    var currentTime: NSTimeInterval = NSTimeInterval()
    var player: AVAudioPlayer = AVAudioPlayer()
    var duration: NSTimeInterval = NSTimeInterval()
    var musicControlView: UIView = UIView()
    var timeLabel: UILabel = UILabel()
    
    // screen height and width
    var trueWidth: CGFloat = CGFloat()
    var trueHeight: CGFloat = CGFloat()
    
    // editView objects
    var editView: UIView = UIView()
    var tabNameTextField: UITextField = UITextField()
    var completeStringView: UIScrollView = UIScrollView()
    var specificTabsScrollView: UIScrollView = UIScrollView()

    // string position and fret position
    var string3Position: [CGFloat] = [CGFloat]()
    var string6Position: [CGFloat] = [CGFloat]()
    var fretPosition: [CGFloat] = [CGFloat]()
    
    // core data
    var data: TabsData = TabsData()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Fix orientation to landscape
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    //init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.view.frame.height > self.view.frame.width {
            trueWidth = self.view.frame.height
            trueHeight = self.view.frame.width
        } else {
            trueWidth = self.view.frame.width
            trueHeight = self.view.frame.height
        }
        createSoundWave()
        
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(0, 0, self.trueWidth, self.trueWidth)
        let size: CGSize = CGSizeMake(self.trueWidth, self.trueWidth)
        backgroundImage.image = theSong.artwork!.imageWithSize(size)
        
        var blurEffect: UIBlurEffect = UIBlurEffect()
        blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRectMake(0, 0, self.trueWidth, self.trueHeight)
        backgroundImage.addSubview(blurEffectView)
        self.view.addSubview(backgroundImage)

        
        self.data.addDefaultData()
        self.editView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 18 / 20 * self.trueHeight)
        addObjectsOnMainView()
        addObjectsOnEditView()
        createStringAndFretPosition()
        addMusicControlView()
        
        self.initCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
        self.initialMainViewDataArray()
    }
    
    func initialMainViewDataArray() {
        for var i = 0; i < 25; i++ {
            let temp: mainViewData = mainViewData()
            temp.fretNumber = i
            let tempButton: [UIButton] = [UIButton]()
            temp.noteButtons = tempButton
            self.mainViewDataArray.append(temp)
        }
    }
    
    func initCollectionView() {
        for var i = 0; i < 25; i++ {
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
        self.view.addSubview(collectionView)
        calculateBorders()
        let gesture = UILongPressGestureRecognizer(target: self,
            action: "handleGesture:")
        gesture.minimumPressDuration = 0.2
        gesture.delegate = self
        collectionView.addGestureRecognizer(gesture)
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
        return 25
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("fretcell", forIndexPath: indexPath) as! FretCell
        
        print(indexPath.item)
        
        cell.imageView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
        cell.fretNumberLabel.text = "\(self.fretsNumber[indexPath.item])"
        

        for subview in cell.contentView.subviews {
            if subview.isKindOfClass(UIButton){
                subview.removeFromSuperview()
            }
        }

        
        for item in self.mainViewDataArray[indexPath.item].noteButtons {
            cell.contentView.addSubview(item)
        }

        
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ca = self.view {
            if let cv = self.collectionView {
                let pointPressedInCanvas = gestureRecognizer.locationInView(ca)
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
    
    func checkForDraggingAtTheEdgeAndAnimatePaging(gestureRecognizer: UILongPressGestureRecognizer) {
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
                    self.handleGesture(gestureRecognizer)
                });
                self.animating = true
                self.collectionView!.scrollRectToVisible(nextPageRect, animated: true)
            }
        }
    }
    
    func handleGesture(gesture: UILongPressGestureRecognizer) -> Void {
        if let bundle = self.bundle {
            let dragPointOnCanvas = gesture.locationInView(self.view)
            //var originalIndexPath: NSIndexPath = self.collectionView.indexPathForItemAtPoint(dragPointOnCanvas)!
            if gesture.state == UIGestureRecognizerState.Began {
                bundle.sourceCell.hidden = true
                self.view?.addSubview(bundle.representationImageView)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    bundle.representationImageView.alpha = 0.8
                });
            }
            if gesture.state == UIGestureRecognizerState.Changed {
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                let dragPointOnCollectionView = gesture.locationInView(self.collectionView)
                if let toIndexPath : NSIndexPath = self.collectionView?.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    self.checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                    
                    
                    if toIndexPath.isEqual(bundle.currentIndexPath) == false {
                        moveDataItem(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        self.collectionView!.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        self.bundle!.currentIndexPath = toIndexPath
                    }
                }
            }
            if gesture.state == UIGestureRecognizerState.Ended {
                bundle.sourceCell.hidden = false
                bundle.representationImageView.removeFromSuperview()
                collectionView!.reloadData()
                self.bundle = nil
            }
        }
    }
    
    let removeButton: UIButton = UIButton()
    
    var statusLabel: UIImageView = UIImageView()
    func addObjectsOnMainView() {
        
        // views
        let menuView: UIView = UIView()
        let musicView: UIView = UIView()

        let blueLine: UIView = UIView()

        // buttons
        let backButton: UIButton = UIButton()
        
        let tuningButton: UIButton = UIButton()
        let resetButton: UIButton = UIButton()
        
        let addButton: UIButton = UIButton()
        let doneButton: UIButton = UIButton()

        
        menuView.frame = CGRectMake(0, 0, self.trueWidth, 2 / 20 * self.trueHeight)
        menuView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        menuView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(menuView)
        
        musicView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 6 / 20 * self.trueHeight)
        musicView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(musicView)
        
        self.fretBoardView.frame = CGRectMake(0, 8 / 20 * self.trueHeight, self.trueWidth, 11 / 20 * self.trueHeight)
        self.fretBoardView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(fretBoardView)
        
        let buttonWidth = 2 / 20 * self.trueHeight
        
        backButton.frame = CGRectMake(0.5 / 31 * self.trueWidth, 0, buttonWidth, buttonWidth)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setImage(UIImage(named: "icon-back"), forState: UIControlState.Normal)
        menuView.addSubview(backButton)
        
        statusLabel.frame = CGRectMake(6 / 31 * self.trueWidth, 0.25 / 20 * self.trueWidth, 6 / 31 * self.trueWidth, buttonWidth * 0.65)
        statusLabel.image = UIImage(named: "tabEditor")
        //statusLabel.textAlignment = NSTextAlignment.Center
        menuView.addSubview(statusLabel)
        
        tuningButton.frame = CGRectMake(16.5 / 31 * self.trueWidth, 0, buttonWidth, buttonWidth)
        tuningButton.addTarget(self, action: "pressTuningButton:", forControlEvents: UIControlEvents.TouchUpInside)
        tuningButton.setImage(UIImage(named: "icon-tuning"), forState: UIControlState.Normal)
        menuView.addSubview(tuningButton)
        
        resetButton.frame = CGRectMake(19.5 / 31 * self.trueWidth, 0, buttonWidth, buttonWidth)
        resetButton.addTarget(self, action: "pressResetButton:", forControlEvents: UIControlEvents.TouchUpInside)
        resetButton.setImage(UIImage(named: "icon-reset"), forState: UIControlState.Normal)
        menuView.addSubview(resetButton)
        
        removeButton.frame = CGRectMake(22.5 / 31 * self.trueWidth, 0, buttonWidth, buttonWidth)
        removeButton.addTarget(self, action: "pressRemoveButton:", forControlEvents: UIControlEvents.TouchUpInside)
        removeButton.setImage(UIImage(named: "icon-remove"), forState: UIControlState.Normal)
        removeButton.accessibilityIdentifier = "notRemove"
        menuView.addSubview(removeButton)
        
        addButton.frame = CGRectMake(25.5 / 31 * self.trueWidth, 0, buttonWidth, buttonWidth)
        addButton.addTarget(self, action: "pressAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.setImage(UIImage(named: "icon-add"), forState: UIControlState.Normal)
        menuView.addSubview(addButton)
        
        doneButton.frame = CGRectMake(28.5 / 31 * self.trueWidth, 0, buttonWidth, buttonWidth)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setImage(UIImage(named: "icon-done"), forState: UIControlState.Normal)
        menuView.addSubview(doneButton)
        
        blueLine.frame = CGRectMake(self.trueWidth / 2, 0.5 / 20 * self.trueHeight, 2, 5 / 20 * self.trueHeight)
        blueLine.backgroundColor = UIColor.blackColor()
        self.musicControlView.addSubview(blueLine)
        
        self.view.addSubview(self.progressBlock)
    }
    
    var completeImageView: UIImageView = UIImageView()
    
    func addObjectsOnEditView() {
        self.specificTabsScrollView.frame = CGRectMake(0.5 / 31 * self.trueWidth, 0.25 / 20 * self.trueHeight, 20 / 31 * self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.specificTabsScrollView.contentSize = CGSizeMake(self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.specificTabsScrollView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.specificTabsScrollView.layer.cornerRadius = 3
        self.editView.addSubview(specificTabsScrollView)
        
        self.tabNameTextField.frame = CGRectMake(23.5 / 31 * self.trueWidth, 0.25 / 20 * self.trueHeight, 7 / 31 * self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.tabNameTextField.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.tabNameTextField.layer.cornerRadius = 3
        self.editView.addSubview(tabNameTextField)
        
        self.completeStringView.frame = CGRectMake(0, 6 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeStringView.contentSize = CGSizeMake(4 * self.trueWidth + self.trueWidth / 6, 15 / 20 * self.trueHeight)
        self.completeStringView.backgroundColor = UIColor.clearColor()
        
        completeImageView.frame = CGRectMake(0, 0, 4 * self.trueWidth + self.trueWidth / 6, 15 / 20 * self.trueHeight)
        completeImageView.image = UIImage(named: "6-strings-new-with-numbers")
        self.completeStringView.addSubview(completeImageView)
        self.editView.addSubview(completeStringView)
        
        let singleTapOnString6View: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnString6View:")
        singleTapOnString6View.numberOfTapsRequired = 1
        singleTapOnString6View.numberOfTouchesRequired = 1
        self.completeStringView.addGestureRecognizer(singleTapOnString6View)
        
        addString6View()
        
        self.specificTabsScrollView.alpha = 0
        self.tabNameTextField.alpha = 0
    }
    
    var addNewTab: Bool = false
    var currentNoteButton: UIButton = UIButton()
    
    func singleTapOnString6View(sender: UITapGestureRecognizer) {
        var indexFret: Int = Int()
        var indexString: Int = Int()
        if self.addNewTab == false {
            let location = sender.locationInView(self.completeStringView)
            for var index = 0; index < self.fretPosition.count; index++ {
                if location.x < self.fretPosition[self.fretPosition.count - 2] {
                    if location.x > self.fretPosition[index] && location.x < self.fretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for var index = 3; index < 6; index++ {
                if CGRectContainsPoint(self.string6View[index].frame, location) {
                    self.addNewTab = true
                    indexString = index
                    let noteButton: UIButton = UIButton()
                    let buttonFret = (self.fretPosition[indexFret] + self.fretPosition[indexFret + 1]) / 2
                    let buttonString = self.string6Position[indexString]
                    let buttonWidth = 7 / 60 * self.trueHeight
                    noteButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
                    noteButton.layer.cornerRadius = 0.5 * buttonWidth
                    noteButton.layer.borderWidth = 1
                    noteButton.tag = (indexString + 1) * 100 + indexFret
                    noteButton.addTarget(self, action: "pressNoteButton:", forControlEvents: UIControlEvents.TouchUpInside)
                    let tabName = self.data.fretsBoard[indexString][indexFret]
                    noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
                    self.currentNoteButton = noteButton
                    self.completeStringView.addSubview(noteButton)
                    noteButton.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        noteButton.alpha = 1
                    })
                    let existTabCount = self.addExistSpecificTabButton(noteButton.tag)
                    self.addNewSpecificTabButton(noteButton.tag, count: existTabCount)
                    self.createEditFingerPoint()
                }
            }
        } else {
            let location = sender.locationInView(self.completeStringView)
            for var index = 0; index < self.fretPosition.count; index++ {
                if location.x < self.fretPosition[self.fretPosition.count - 2] {
                    if location.x > self.fretPosition[index] && location.x < self.fretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for var index = 0; index < 6; index++ {
                if CGRectContainsPoint(self.string6View[index].frame, location) {
                    indexString = index
                    moveFingerPoint(indexFret, indexString: indexString)
                }
            }
        }
    }
    var tabFingerPointChanged: Bool = false
    
    func moveFingerPoint(indexFret: Int, indexString: Int) {
        print("move finger point")
        let noteString = self.currentNoteButton.tag / 100 - 1
        if indexString != noteString {
            let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
            let buttonX = (fretPosition[indexFret] + fretPosition[indexFret + 1]) / 2 - buttonWidth / 2
            let buttonY = string6Position[indexString] - buttonWidth / 2
            self.fingerPoint[5 - indexString].frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            self.fingerPoint[5 - indexString].alpha = 0
            self.fingerPoint[5 - indexString].tag = indexFret
            UIView.animateWithDuration(0.5, animations: {
                self.fingerPoint[5 - indexString].alpha = 1
            })
            self.tabFingerPointChanged = true
        }
    }
    
    func createEditFingerPoint() {
        self.tabFingerPointChanged == true
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
        self.fingerPoint.removeAll(keepCapacity: false)
        for var i = 5; i >= 0; i-- {
            let fingerButton: UIButton = UIButton()
            let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
            let buttonX = (fretPosition[0] + fretPosition[1]) / 2 - buttonWidth / 2
            let buttonY = string6Position[i] - buttonWidth / 2
            fingerButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            fingerButton.layer.cornerRadius = 0.5 * buttonWidth
            fingerButton.setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            fingerButton.addTarget(self, action: "pressEditFingerButton:", forControlEvents: UIControlEvents.TouchUpInside)
            fingerButton.accessibilityIdentifier = "grayButton"
            self.fingerPoint.append(fingerButton)
            if i != self.currentNoteButton.tag / 100 - 1 {
                self.completeStringView.addSubview(fingerButton)
                
            }
            
        }
    }
    
    var buttonOnSpecificScrollView: [UIButton] = [UIButton]()
    func addExistSpecificTabButton(sender: Int) -> Int {
        let index: NSNumber = NSNumber(integer: sender)
        var dict: [NSDictionary] = self.data.getExistTab(index)
        let buttonHeight: CGFloat = 2 / 20 * self.trueHeight
        let buttonWidth: CGFloat = 3 / 20 * self.trueHeight
        for var i = 0; i < dict.count; i++ {
            if dict[i].objectForKey("content") as! String != "" {
                let specificButton: UIButton = UIButton()
                specificButton.frame = CGRectMake(0.5 / 20 * self.trueWidth * CGFloat(i + 1) + buttonWidth * CGFloat(i), 0.25 / 20 * self.trueHeight, buttonWidth, buttonHeight)
                specificButton.layer.borderWidth = 1
                specificButton.layer.cornerRadius = 4
                specificButton.addTarget(self, action: "pressExistSpecificButton:", forControlEvents: UIControlEvents.TouchUpInside)
                specificButton.setTitle(dict[i].objectForKey("name") as? String, forState: UIControlState.Normal)
                specificButton.alpha = 0
                specificButton.tag = sender
                self.specificTabsScrollView.addSubview(specificButton)
                self.buttonOnSpecificScrollView.append(specificButton)
            }
        }
        return dict.count
    }

    func addNewSpecificTabButton(sender: Int, count: Int) {
        let index: NSNumber = NSNumber(integer: sender)
        var dict: [NSDictionary] = self.data.getNewTab(index)
        let buttonHeight: CGFloat = 2 / 20 * self.trueHeight
        let buttonWidth: CGFloat = 3 / 20 * self.trueHeight
        for var i = count; i < dict.count + count; i++ {
            let specificButton: UIButton = UIButton()
            specificButton.frame = CGRectMake(0.5 / 20 * self.trueWidth * CGFloat(i + 1) + buttonWidth * CGFloat(i), 0.25 / 20 * self.trueHeight, buttonWidth, buttonHeight)
            specificButton.layer.borderWidth = 1
            specificButton.layer.cornerRadius = 4
            specificButton.addTarget(self, action: "pressNewSpecificButton:", forControlEvents: UIControlEvents.TouchUpInside)
            specificButton.setTitle(dict[i - count].objectForKey("name") as? String, forState: UIControlState.Normal)
            specificButton.alpha = 0
            specificButton.tag = sender
            self.specificTabsScrollView.addSubview(specificButton)
            self.buttonOnSpecificScrollView.append(specificButton)
        }
        UIView.animateWithDuration(0.5, animations: {
            for item in self.buttonOnSpecificScrollView {
                item.alpha = 1
            }
        })
    }
    
    var fingerPoint: [UIButton] = [UIButton]()
    var addSpecificFingerPoint: Bool = false
    
    
    func pressNewSpecificButton(sender: UIButton) {
        if self.removeAvaliable == false {
            var index = sender.tag
            var name = sender.titleLabel?.text
            self.tabFingerPointChanged = false
            self.addSpecificFingerPoint = true
            self.currentNoteButton = sender
            for item in self.fingerPoint {
                item.removeFromSuperview()
            }
            self.fingerPoint.removeAll(keepCapacity: false)
            createFingerPoint(index, name: name!, newTabs: true)
        } else {
            var index = NSNumber(integer: sender.tag)
            var name = sender.titleLabel?.text
            sender.removeFromSuperview()
            removeObjectsOnCompleteStringView()
            data.removeNewTab(index, name: name!)
            
            self.changeRemoveButtonStatus(self.removeButton)
        }
    }
    
    func pressExistSpecificButton(sender: UIButton) {
        if self.removeAvaliable == false {
            var index = sender.tag
            var name = sender.titleLabel?.text
            self.tabFingerPointChanged = false
            self.addSpecificFingerPoint = true
            self.currentNoteButton = sender
            for item in self.fingerPoint {
                item.removeFromSuperview()
            }
            self.fingerPoint.removeAll(keepCapacity: false)
            createFingerPoint(index, name: name!, newTabs: false)
        } else {
            let alertController = UIAlertController(title: "Warning", message: "Cannot delete build in tabs", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            self.changeRemoveButtonStatus(self.removeButton)
        }
    }
    
    func createFingerPoint(sender: Int, name: String, newTabs: Bool) {
        let index = NSNumber(integer: sender)
        var dict: NSDictionary = NSDictionary()
        if newTabs == false {
            dict = self.data.getExistTabWithName(index, name: name)
        } else {
            dict = self.data.getNewTabWithName(index, name: name)
        }
        let content: String = dict.objectForKey("content") as! String
        let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
        var buttonX = fretPosition[1] - buttonWidth / 2
        var buttonY = string6Position[5] - buttonWidth / 2
        for var i = 11; i >= 0; i = i - 2 {
            let index = content.startIndex.advancedBy(11 - i)
            let endIndex = content.startIndex.advancedBy(11 - i + 2)
            let charAtIndex = content[Range(start: index, end: endIndex)]
            let fingerButton: UIButton = UIButton()
            var image: UIImage = UIImage()
            var temp: Int = Int()
            if charAtIndex == "xx" {
                temp = 1
                buttonX = fretPosition[1] - buttonWidth / 2
                buttonY = string6Position[i / 2] - buttonWidth / 2
                image = UIImage(named: "blackX")!
                fingerButton.accessibilityIdentifier = "blackX"
            } else {
                temp = Int(String(charAtIndex))!
                image = UIImage(named: "grayButton")!
                buttonX = (fretPosition[temp] + fretPosition[temp + 1]) / 2 - buttonWidth / 2
                buttonY = string6Position[i / 2] - buttonWidth / 2
                fingerButton.accessibilityIdentifier = "grayButton"
            }
            fingerButton.addTarget(self, action: "pressEditFingerButton:", forControlEvents: UIControlEvents.TouchUpInside)
            let stringNumber = sender / 100
            fingerButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            fingerButton.setImage(image, forState: UIControlState.Normal)
            fingerButton.alpha = 0
            fingerButton.tag = temp
            self.fingerPoint.append(fingerButton)// store all the finger point for exist tabs
            UIView.animateWithDuration(0.5, animations: {
                fingerButton.alpha = 1
            })
            if i / 2 != stringNumber - 1 {
                self.completeStringView.addSubview(fingerButton)
            }
        }
    }
    
    func pressEditFingerButton(sender: UIButton) {
        self.tabFingerPointChanged = true
        if sender.accessibilityIdentifier == "blackX" {
            sender.setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            sender.accessibilityIdentifier = "grayButton"
        } else {
            sender.setImage(UIImage(named: "blackX"), forState: UIControlState.Normal)
            sender.accessibilityIdentifier = "blackX"
        }
    }
    
    func pressNoteButton(sender: UIButton) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            sender.removeFromSuperview()
            self.removeObjectsOnSpecificTabsScrollView()
            self.removeObjectsOnCompleteStringView()
        }
        UIView.animateWithDuration(0.5, animations: {
            for item in self.buttonOnSpecificScrollView {
                item.alpha = 0
            }
            for item in self.fingerPoint {
                item.alpha = 0
            }
            sender.alpha = 0
        })
        self.fingerPoint.removeAll(keepCapacity: false)
        self.addNewTab = false
    }
    
    func removeObjectsOnCompleteStringView() {
        self.currentNoteButton.removeFromSuperview()
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
    }
    
    func removeObjectsOnSpecificTabsScrollView() {
        for item in self.specificTabsScrollView.subviews {
            item.removeFromSuperview()
        }
    }
    
    func addMusicControlView() {
        let previousButton: UIButton = UIButton()
        previousButton.frame = CGRectMake(28 / 31 * self.trueWidth, 3 / 20 * self.trueHeight, 2.5 / 31 * self.trueWidth, 2.5 / 31 * trueWidth)
        previousButton.addTarget(self, action: "pressPreviousButton:", forControlEvents: UIControlEvents.TouchUpInside)
        previousButton.setImage(UIImage(named: "icon-previous"), forState: UIControlState.Normal)
        self.musicControlView.addSubview(previousButton)
        
        self.musicControlView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 6 / 20 * self.trueHeight)
        self.view.addSubview(musicControlView)
        
        self.timeLabel.frame = CGRectMake(0.5 * self.trueWidth, 3 / 20 * self.trueHeight, 4 / 31 * self.trueWidth, 1 / 20 * self.trueHeight)
        self.timeLabel.textAlignment = NSTextAlignment.Center
        let minutesD = floor(self.duration / 60)
        let secondsD = round(self.duration - minutesD * 60)
        self.timeLabel.text = "00:00 | \(minutesD):\(secondsD)"
        self.timeLabel.font = UIFont.systemFontOfSize(8)
        self.musicControlView.addSubview(self.timeLabel)
        
        
        let musicSingleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnMusicControlView:")
        musicSingleTapRecognizer.numberOfTapsRequired = 1
        musicSingleTapRecognizer.numberOfTouchesRequired = 1
        self.musicControlView.addGestureRecognizer(musicSingleTapRecognizer)
        
        let musicPanRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panOnMusicControlView:")
        musicPanRecognizer.maximumNumberOfTouches = 1
        musicPanRecognizer.minimumNumberOfTouches = 1
        self.musicControlView.addGestureRecognizer(musicPanRecognizer)
        
    }
    
    func panOnMusicControlView(sender: UIPanGestureRecognizer) {
        self.view.bringSubviewToFront(sender.view!)
        let translation = sender.translationInView(self.view)
        sender.view!.center = CGPointMake(sender.view!.center.x, sender.view!.center.y)
        sender.setTranslation(CGPointZero, inView: self.view)
        let timeChange = NSTimeInterval(-translation.x / 10)
        self.player.currentTime = self.currentTime + timeChange
        self.currentTime = self.player.currentTime
        let persent = CGFloat(self.currentTime) / CGFloat(self.duration)
        self.progressBlock.setProgress(persent)
        self.progressBlock.frame = CGRectMake(0.5 * self.trueWidth - persent * (4 * self.trueWidth), 2 / 20 * self.trueHeight, 4 * self.trueWidth, 6 / 20 * self.trueHeight)
        let minutesD = floor(self.duration / 60)
        let secondsD = round(self.duration - minutesD * 60)
        let minutesC = floor(self.currentTime / 60)
        let secondsC = round(self.currentTime - minutesC * 60)
        self.timeLabel.text = "\(minutesC):\(secondsC) | \(minutesD):\(secondsD)"
    }
    
    var countDownImageView: UIImageView = UIImageView()
    var countDownNumberImageView: UIImageView = UIImageView()
    var timer = NSTimer()
    
    func singleTapOnMusicControlView(sender: UITapGestureRecognizer) {
        if self.player.playing == false {
            let imageWidth: CGFloat = 5 / 20 * self.trueHeight
            self.countDownImageView.frame = CGRectMake(0.5 * self.trueWidth - imageWidth / 2, 0.5 / 20 * self.trueHeight, imageWidth, imageWidth)
            self.countDownImageView.image = UIImage(named: "countdown-timer")
            self.countDownNumberImageView.frame = CGRectMake(0, 0, imageWidth, imageWidth)
            self.countDownNumberImageView.image = UIImage(named: "countdown-timer-3")
            self.countDownImageView.addSubview(countDownNumberImageView)
            self.musicControlView.addSubview(countDownImageView)
            self.currentTime = player.currentTime
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        } else {
            self.player.pause()
            self.timer.invalidate()
            self.timer = NSTimer()
            self.countDownNumber = 0
        }
    }
    
    func createStringAndFretPosition() {
        let string6Height: CGFloat = 7 / 60 * self.trueHeight
        for var i = 0; i < 6; i++ {
            if i == 0 {
                self.string6Position.append(string6Height / 2)
            } else {
                self.string6Position.append(self.string6Position[i - 1] + string6Height)
            }
        }
        let fretWidth = self.trueWidth / 6
        for var i = 0; i < 26; i++ {
            self.fretPosition.append(CGFloat(i) * fretWidth)
        }
        let string3Height: CGFloat = 11 / 60 * self.trueHeight
        for var i = 0; i < 3; i++ {
            if i == 0 {
                self.string3Position.append(string3Height / 2)
            } else {
                self.string3Position.append(self.string3Position[i - 1] + string3Height)
            }
        }
    }
    
    var string6View: [UIView] = [UIView]()
    
    func addString6View() {
        let string6Height: CGFloat = 7 / 60 * self.trueHeight
        for var i = 0; i < 6; i++ {
            let tempStringView: UIView = UIView()
            tempStringView.frame = CGRectMake(0, CGFloat(i) * string6Height, self.trueWidth * 5, string6Height)
            if i % 2 == 0 {
                tempStringView.backgroundColor = UIColor.clearColor()
            } else {
                tempStringView.backgroundColor = UIColor.clearColor()
            }
            self.completeStringView.addSubview(tempStringView)
            string6View.append(tempStringView)
        }
    }
    
    func createSoundWave() {
        
        let frame = CGRectMake(0.5 * self.trueWidth, 2 / 20 * self.trueHeight, 4 * self.trueWidth, 6 / 20 * self.trueHeight)
        self.progressBlock = SoundWaveView(frame: frame)
        let url: NSURL = theSong.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        self.player = try! AVAudioPlayer(contentsOfURL: url)
        self.duration = self.player.duration
        self.player.volume = 1
        self.progressBlock.SetSoundURL(url)
    }
    
    var countDownNumber: Float = 0
    
    func update() {
        if self.countDownNumber > 3.0 {
            let minutesD = floor(self.duration / 60)
            let secondsD = round(self.duration - minutesD * 60)
            let minutesC = floor(self.currentTime / 60)
            let secondsC = round(self.currentTime - minutesC * 60)
            self.timeLabel.text = "\(minutesC):\(secondsC) | \(minutesD):\(secondsD)"
            self.currentTime = self.player.currentTime
            let persent = CGFloat(self.currentTime / self.duration)
            self.progressBlock.setProgress(persent)
            self.progressBlock.frame = CGRectMake(0.5 * self.trueWidth - persent * (4 * self.trueWidth), 2 / 20 * self.trueHeight, 4 * self.trueWidth, 6 / 20 * self.trueHeight)
            if self.player.playing == false {
                self.timer.invalidate()
                self.timer = NSTimer()
            }
        } else if self.countDownNumber <= 0.9 {
            self.countDownNumber = self.countDownNumber + 0.1
        } else if self.countDownNumber > 0.9 && self.countDownNumber <= 1.9 {
            self.countDownNumberImageView.image = UIImage(named: "countdown-timer-2")
            self.countDownNumber = self.countDownNumber + 0.1
        } else if self.countDownNumber > 1.9 && self.countDownNumber <= 2.9 {
            self.countDownNumberImageView.image = UIImage(named: "countdown-timer-1")
            self.countDownNumber = self.countDownNumber + 0.1
        } else if self.countDownNumber > 2.9 && self.countDownNumber <= 3.0 {
            self.countDownImageView.removeFromSuperview()
            self.countDownNumberImageView.removeFromSuperview()
            self.countDownNumber++
            self.player.play()
        }
        
    }
    
    class mainViewData {
        var fretNumber: Int = Int()
        var noteButtons:[UIButton] = []
    }
    
    var mainViewDataArray: [mainViewData] = [mainViewData]()
    
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) {
        print("move data item")
        let name = self.fretsNumber[fromIndexPath.item]
        self.fretsNumber.removeAtIndex(fromIndexPath.item)
        self.fretsNumber.insert(name, atIndex: toIndexPath.item)
        let temp = self.mainViewDataArray[fromIndexPath.item]
        self.mainViewDataArray.removeAtIndex(fromIndexPath.item)
        self.mainViewDataArray.insert(temp, atIndex: toIndexPath.item)
    }
    

    func backToMainView() {
        UIView.animateWithDuration(0.5, animations: {
            self.specificTabsScrollView.alpha = 0
            self.tabNameTextField.alpha = 0
            self.musicControlView.alpha = 1
            self.progressBlock.alpha = 1
            self.completeStringView.alpha = 0
            self.completeStringView.frame = CGRectMake(0, 6 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
            self.collectionView.alpha = 1
        })
        
        self.tabNameTextField.text = ""
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
        self.fingerPoint.removeAll(keepCapacity: false)
        self.statusLabel.image = UIImage(named: "tabEditor")
        self.addNewTab = false
        self.intoEditView = false
        self.tabFingerPointChanged = false
        self.addSpecificFingerPoint = false
        self.removeObjectsOnCompleteStringView()
        self.removeObjectsOnSpecificTabsScrollView()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.editView.removeFromSuperview()
        }
    }
    
    var removeAvaliable: Bool = false
    func changeRemoveButtonStatus(sender: UIButton) {
        if self.removeAvaliable == false {
            self.removeAvaliable = true
            self.statusLabel.image = UIImage(named: "deleteTab")
        } else {
            self.removeAvaliable = false
            self.statusLabel.image = UIImage(named: "tabEditor")
        }
    }
    
    struct tabOnMusicLine {
        var tab: UIView = UIView()
        var time: NSTimeInterval = NSTimeInterval()
    }
    var allTabsOnMusicLine: [tabOnMusicLine] = [tabOnMusicLine]()
    
    func pressMainViewNoteButton(sender: UIButton) {
        let tempView: UIView = UIView()
        tempView.frame = CGRectMake(0 + CGFloat(self.currentTime / self.duration) * (self.progressBlock.frame.width), self.progressBlock.frame.height / 2, 0.03 * self.trueHeight, 0.15 * self.trueHeight)
        tempView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 0.6)
        tempView.layer.cornerRadius = 2
        var tempStruct: tabOnMusicLine = tabOnMusicLine()
        var name = sender.titleLabel?.text
        let number = (name!).characters.count
        for var i = 0; i < number; i = i + 2 {
            let index = name!.startIndex.advancedBy(i + 1)
            name?.insert("\n", atIndex: index)
        }
        let tempLabelView: UILabel = UILabel()
        tempLabelView.frame = CGRectMake(0, 0, tempView.frame.width, tempView.frame.height)
        tempLabelView.layer.cornerRadius = 2
        tempLabelView.font = UIFont.systemFontOfSize(11)
        tempLabelView.textAlignment = NSTextAlignment.Center
        tempLabelView.numberOfLines = 3
        tempLabelView.text = name
        tempView.addSubview(tempLabelView)
        tempStruct.tab = tempView
        tempStruct.time = self.currentTime
        self.allTabsOnMusicLine.append(tempStruct)
        self.progressBlock.addSubview(tempView)
    }
    
    var intoEditView: Bool = false
    
    func pressBackButton(sender: UIButton) {
        if self.intoEditView == true {
            self.backToMainView()
        } else {
            self.progressBlock.hidden = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func pressTuningButton(sender: UIButton) {}

    func pressResetButton(sender: UIButton) {}
    
    func pressRemoveButton(sender: UIButton) {
        self.changeRemoveButtonStatus(sender)
    }
    
    func pressAddButton(sender: UIButton) {
        self.view.addSubview(self.editView)
        self.musicControlView.alpha = 0
        self.progressBlock.alpha = 0
        self.collectionView.alpha = 0
        self.statusLabel.image = UIImage(named: "addNewTab")
        self.intoEditView = true
        UIView.animateWithDuration(0.5, animations: {
            self.completeStringView.alpha = 1
            self.specificTabsScrollView.alpha = 1
            self.tabNameTextField.alpha = 1
            self.completeStringView.frame = CGRectMake(0, 3 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
        })
    }
    
    func pressDoneButton(sender: UIButton) {
        if self.addNewTab == true && self.tabFingerPointChanged == true {
            let index = self.currentNoteButton.tag
            let name: String = self.tabNameTextField.text!
            var content: String = String()
            if name == "" {
                let alertController = UIAlertController(title: "Warning", message: "Please input a tab name", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                for var i = 5; i >= 0; i-- {
                    if self.fingerPoint[i].accessibilityIdentifier == "blackX" {
                        content = content + "xx"
                    } else {
                        if self.fingerPoint[i].tag <= 9 {
                            content = content + "0\(self.fingerPoint[i].tag)"
                        } else {
                            content = content + "\(self.fingerPoint[i].tag)"
                        }
                    }
                }
                self.data.addNewTab(index, name: name, content: content)
                print("successfully add to database")
                self.backToMainView()
            }
        }
        let tempButton: UIButton = UIButton()
        let buttonY = self.currentNoteButton.tag / 100 - 1
        var buttonX = self.currentNoteButton.tag - self.currentNoteButton.tag / 100 * 100
        let buttonWidth = self.trueWidth / 5 / 3
        let stringPosition = self.string3Position[buttonY - 3] - buttonWidth / 2
        let fretPosition = self.trueWidth / 5 / 2 - buttonWidth / 2
        tempButton.tag = self.currentNoteButton.tag
        tempButton.setTitle(self.currentNoteButton.titleLabel!.text, forState: UIControlState.Normal)
        tempButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        tempButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        tempButton.addTarget(self, action: "pressMainViewNoteButton:", forControlEvents: UIControlEvents.TouchUpInside)
        tempButton.layer.cornerRadius = 0.5 * buttonWidth
        tempButton.frame = CGRectMake(fretPosition, stringPosition, buttonWidth, buttonWidth)
        var noteButtonAdded: Bool = false
        for item in self.mainViewDataArray {
            if item.fretNumber == tempButton.tag - tempButton.tag / 100 * 100 {
                item.noteButtons.append(tempButton)
            }
        }
        backToMainView()
        collectionView.reloadData()
        self.statusLabel.image = UIImage(named: "tabEditor")
    }
    
    func pressPreviousButton(sender: UIButton) {
        if self.allTabsOnMusicLine.count > 1 {
            self.allTabsOnMusicLine.last?.tab.removeFromSuperview()
            self.allTabsOnMusicLine.removeLast()
            let previousTime = self.allTabsOnMusicLine.last?.time
            self.player.currentTime = previousTime!
        } else if self.allTabsOnMusicLine.count == 1 {
            self.allTabsOnMusicLine.last?.tab.removeFromSuperview()
            self.allTabsOnMusicLine.removeLast()
            self.player.currentTime = 0
        }else {
            self.player.currentTime = 0
        }
    }

}

