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
    
    // Musci Data Manager
    var musicDataManager = MusicDataManager()

    // collection view
    var collectionView: UICollectionView!
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var fretsNumber: [Int] = [Int]()
    var collectionViewFrameInCanvas : CGRect = CGRectZero
    var hitTestRectagles = [String:CGRect]()
    var animating : Bool = false
    
    // move collection view cell bundle and view
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
    let tabsEditorProgressWidthMultiplier: CGFloat = 6
    var progressBlock: SoundWaveView!
    var theSong: MPMediaItem!
    var currentTime: NSTimeInterval = NSTimeInterval()
    var player: AVAudioPlayer = AVAudioPlayer()
    var duration: NSTimeInterval = NSTimeInterval()
    var musicControlView: UIView = UIView()
    
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
    
    // core data functions
    var data: TabsDataManager = TabsDataManager()
    
    // objects on view which need to be changed in different places
    var removeButton: UIButton = UIButton()
    var statusLabel: UIImageView = UIImageView()
    var completeImageView: UIImageView = UIImageView()
    var noteButtonOnCompeteScrollView: UIButton = UIButton()
    var buttonOnSpecificScrollView: [UIButton] = [UIButton]()
    var fingerPoint: [UIButton] = [UIButton]()
    var currentNoteButton: UIButton = UIButton()
    var currentTimeLabel: UILabel = UILabel()
    var totalTimeLabel: UILabel = UILabel()
//    var countDownImageView: UIImageView = UIImageView()
//    var countDownNumberImageView: UIImageView = UIImageView()
    var string6View: [UIView] = [UIView]()
    var currentTabViewIndex: Int = Int()
    var currentBaseButton: UIButton = UIButton()
    
    // timer
    var timer = NSTimer()
    
    var tuningMenu: UIView!
    var actionDismissLayerButton: UIButton!
    
    var speedLabel: UILabel!
    var speedStepper: UIStepper!
    
    var capoLabel: UILabel!
    var capoStepper: UIStepper!
    // capo and 6 string
    var defaultTunings =  ["E","B","G","D","A","E"]
    var stepDownButtons = [UIButton]()
    var stepUpButtons = [UIButton]()
    var tuningValueLabels = [UILabel]()
    var tunings = [Tuning]()
    
    
    // count down section
    
    var countdownTimer = NSTimer()
    var countDownStartSecond = 0 //will increments to 3
    var countdownView: CountdownView!
    
    // data array
    var specificTabSets: [NormalTabs] = [NormalTabs]()
    var currentSelectedSpecificTab: NormalTabs!
    var countDownNumber: Float = 0
    
    // Mark: Main view data array structure
    class mainViewData {
        var fretNumber: Int = Int()
        var noteButtonsWithTab: [noteButtonWithTab] = [noteButtonWithTab]()
    }
    class noteButtonWithTab {
        var noteButton: UIButton = UIButton()
        var tab: NormalTabs = NormalTabs()
    }
    var mainViewDataArray: [mainViewData] = [mainViewData]()
    
    // Mark: After edited the tabs, all useful information are stored in this array: allTabsOnMusicLine, which includ the time and tab information
    struct tabOnMusicLine {
        var tabView: UIView = UIView()
        var time: NSTimeInterval = NSTimeInterval()
        var tab: NormalTabs = NormalTabs()
    }
    var allTabsOnMusicLine: [tabOnMusicLine] = [tabOnMusicLine]()
    
    // Mark: store the tabs with adding orders
    var noteButtonWithTabArray: [noteButtonWithTab] = [noteButtonWithTab]()
    
    // status variables
    var addNewTab: Bool = false
    var tabFingerPointChanged: Bool = false
    var addSpecificFingerPoint: Bool = false
    var removeAvaliable: Bool = false
    var intoEditView: Bool = false
    
    // Hide the status bar
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // get the correct screen height and width
        if self.view.frame.height > self.view.frame.width {
            trueWidth = self.view.frame.height
            trueHeight = self.view.frame.width
        } else {
            trueWidth = self.view.frame.width
            trueHeight = self.view.frame.height
        }
        // create the sound wave
        self.createSoundWave()
        
        // add the background image with blur
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(0, 0, self.trueWidth, self.trueWidth)
        let size: CGSize = CGSizeMake(self.trueWidth, self.trueWidth)
        backgroundImage.image = theSong.artwork!.imageWithSize(size)
        
        let blurredImage:UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        self.view.addSubview(backgroundImage)

        // add the default tab data into coredata if it doesn't exist
        self.data.addDefaultData()
        
        // initial the edit view
        self.editView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 18 / 20 * self.trueHeight)
        
        // add objects on main view and edit view
        self.addObjectsOnMainView()
        self.addObjectsOnEditView()
        self.createStringAndFretPosition()
        self.addMusicControlView()
        self.setUpTimeLabels()
        self.setUpCountdownView()

        // initial collection view
        self.initCollectionView()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        setUpTuningControlMenu()

        // initial main view tab data array
        self.initialMainViewDataArray()
    }

    // MARK: a slider menu that allow user to specify speed, capo number, and six string tuning
    func setUpTuningControlMenu() {
        // a gray button covers the entire background behind tuning menu, is to dismiss the tuning menus
        actionDismissLayerButton = UIButton(frame: CGRect(x: 0, y: 0, width: trueWidth, height: trueHeight))
        actionDismissLayerButton.backgroundColor = UIColor.clearColor()
        actionDismissLayerButton.addTarget(self, action: "dismissAction", forControlEvents: .TouchUpInside)
        self.view.addSubview(actionDismissLayerButton)
        actionDismissLayerButton.hidden = true
        
        tuningMenu = UIView(frame: CGRect(x: -trueWidth/3, y: 0, width: trueWidth/3, height: trueHeight))
        tuningMenu.backgroundColor = UIColor.actionGray()
        self.view.addSubview(tuningMenu)
        
        //draw 7 lines to give rooms for eight rows
        let rowHeight = trueHeight/8
        for i in 0..<7 {
            let separator = UIView(frame: CGRect(x: 0, y: rowHeight*CGFloat(i+1), width: tuningMenu.frame.width, height: 1))
            separator.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            tuningMenu.addSubview(separator)
        }
        
        let sideMargin: CGFloat = 10
        
        //SECTION: add speed label, stepper
        speedLabel = UILabel(frame: CGRect(x: sideMargin, y: 0, width: 100, height: 25))
        speedLabel.textColor = UIColor.mainPinkColor()
        speedLabel.text = "Speed: 1.0x"
        speedLabel.center.y = rowHeight/2
        tuningMenu.addSubview(speedLabel)

        speedStepper = UIStepper(frame: CGRect(x: tuningMenu.frame.width-94-sideMargin, y: 0, width: 94, height: 29))
        speedStepper.center.y = rowHeight/2
        speedStepper.tintColor = UIColor.mainPinkColor()
        speedStepper.minimumValue = 0.2 //these are arbitrary numbers just so that the stepper can go down 3 times and go up 3 times
        speedStepper.maximumValue = 2.0
        speedStepper.stepValue = 0.1
        speedStepper.value = 1.0 //default
        speedStepper.addTarget(self, action: "speedStepperValueChanged:", forControlEvents: .ValueChanged)
        tuningMenu.addSubview(speedStepper)
        
        
        //SECTION: add capo label, stepper
        capoLabel = UILabel(frame: CGRect(x: sideMargin, y: 0, width: 100, height: 25))
        capoLabel.textColor = UIColor.mainPinkColor()
        capoLabel.text = "Capo: 0"
        capoLabel.center.y = rowHeight*3/2
        tuningMenu.addSubview(capoLabel)
        
        capoStepper = UIStepper(frame: CGRect(x: 0, y: 0, width: 94, height: 29))
        capoStepper.center = CGPoint(x: speedStepper.center.x, y: speedStepper.center.y+rowHeight)
        capoStepper.tintColor = UIColor.mainPinkColor()
        capoStepper.minimumValue = 0
        capoStepper.maximumValue = 12
        capoStepper.stepValue = 1
        capoStepper.value = 0 //default
        capoStepper.addTarget(self, action: "capoStepperValueChanged:", forControlEvents: .ValueChanged)
        tuningMenu.addSubview(capoStepper)
        
        let buttonDimension: CGFloat = 30
        
        //SECTION: Tunings
        var tuningTexts = ["1st:", "2nd:", "3rd:", "4th:", "5th:", "6th:"]
        //add tunings labels and buttons
        for i in 0..<6 {
            let stringIndicatorLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 25))
            stringIndicatorLabel.textColor = UIColor.mainPinkColor()
            stringIndicatorLabel.text = tuningTexts[i]
            stringIndicatorLabel.sizeToFit()
            stringIndicatorLabel.center.y = rowHeight/2 + rowHeight * CGFloat(i+2)
            tuningMenu.addSubview(stringIndicatorLabel)
            
            //initialize tuning with our custom class Tuning
            let originalTuning = Tuning(originalNote: defaultTunings[i])
            tunings.append(originalTuning)
            
            let tuningValueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
            tuningValueLabel.text = defaultTunings[i]
            tuningValueLabel.textColor = UIColor.mainPinkColor()
            tuningValueLabel.center = CGPoint(x: speedStepper.center.x, y: stringIndicatorLabel.center.y)
            tuningValueLabel.textAlignment = .Center
            tuningMenu.addSubview(tuningValueLabel)
            tuningValueLabels.append(tuningValueLabel)
            
            let stepUpButton = UIButton(frame: CGRect(x:0, y: 0, width: buttonDimension, height: buttonDimension))
            stepUpButton.setImage(UIImage(named: "up_arrow"), forState: .Normal)
            stepUpButton.tag = i
            stepUpButton.addTarget(self, action: "stepUpPressed:", forControlEvents: .TouchUpInside)
            stepUpButton.center = CGPoint(x: tuningValueLabel.center.x + buttonDimension, y: tuningValueLabel.center.y)
            tuningMenu.addSubview(stepUpButton)
            stepUpButtons.append(stepUpButton)

            let stepDownButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
            stepDownButton.tag = i
            stepDownButton.addTarget(self, action: "stepDownPressed:", forControlEvents: .TouchUpInside)
            stepDownButton.setImage(UIImage(named: "down_arrow"), forState: .Normal)
            stepDownButton.center = CGPoint(x: tuningValueLabel.center.x - buttonDimension, y: tuningValueLabel.center.y)
            tuningMenu.addSubview(stepDownButton)
            stepDownButtons.append(stepDownButton)
        }
    }
    
    func speedStepperValueChanged(stepper: UIStepper) {
        self.speedLabel.text = "Speed: \(stepper.value)x"
        self.player.rate = Float(stepper.value)
    }
    
    func capoStepperValueChanged(stepper: UIStepper) {
        capoLabel.text = "Capo: \(Int(stepper.value))"
    }
    
    func stepUpPressed(button: UIButton) {
        let currentNote = tunings[button.tag]
        currentNote.stepUp()
        tuningValueLabels[button.tag].text = currentNote.toDisplayString()
        let center = tuningValueLabels[button.tag].center
        tuningValueLabels[button.tag].sizeToFit()
        tuningValueLabels[button.tag].center = center
    }
    
    func stepDownPressed(button: UIButton) {
        let currentNote = tunings[button.tag]
        currentNote.stepDown()
        tuningValueLabels[button.tag].text = currentNote.toDisplayString()
        let center = tuningValueLabels[button.tag].center

        tuningValueLabels[button.tag].sizeToFit()
         tuningValueLabels[button.tag].center = center
    }
    
    // MARK: Main view data array, to store the tabs added on main view.
    func initialMainViewDataArray() {
        for var i = 0; i < 25; i++ {
            let temp: mainViewData = mainViewData()
            temp.fretNumber = i
            let tempButton: [noteButtonWithTab] = [noteButtonWithTab]()
            temp.noteButtonsWithTab = tempButton
            self.mainViewDataArray.append(temp)
        }
    }
    
    // MARK: collection view functions, include required functions and move cell functions
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
        for item in self.mainViewDataArray[indexPath.item].noteButtonsWithTab {
            cell.contentView.addSubview(item.noteButton)
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

    func addObjectsOnMainView() {
        // views
        let menuView: UIView = UIView()
        let musicView: UIView = UIView()

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
        
        let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnEditView.addTarget(self, action: "tapOnEditView:")
        menuView.addGestureRecognizer(tapOnEditView)
        
        self.view.addSubview(self.progressBlock)
    }
    
    func addObjectsOnEditView() {
        self.specificTabsScrollView.frame = CGRectMake(0.5 / 31 * self.trueWidth, 0.25 / 20 * self.trueHeight, 20 / 31 * self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.specificTabsScrollView.contentSize = CGSizeMake(self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.specificTabsScrollView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.specificTabsScrollView.layer.cornerRadius = 3
        self.editView.addSubview(specificTabsScrollView)
        
        self.tabNameTextField.frame = CGRectMake(23.5 / 31 * self.trueWidth, 0.25 / 20 * self.trueHeight, 7 / 31 * self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.tabNameTextField.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.tabNameTextField.layer.cornerRadius = 3
        self.tabNameTextField.autocorrectionType = UITextAutocorrectionType.No
        self.editView.addSubview(tabNameTextField)
        
        self.completeStringView.frame = CGRectMake(0, 6 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeStringView.contentSize = CGSizeMake(4 * self.trueWidth + self.trueWidth / 6, 15 / 20 * self.trueHeight)
        self.completeStringView.backgroundColor = UIColor.clearColor()
        
        self.completeImageView.frame = CGRectMake(0, 0, 4 * self.trueWidth + self.trueWidth / 6, 15 / 20 * self.trueHeight)
        self.completeImageView.image = UIImage(named: "6-strings-new-with-numbers")
        self.completeStringView.addSubview(completeImageView)
        self.editView.addSubview(completeStringView)
        
        let singleTapOnString6View: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnString6View:")
        singleTapOnString6View.numberOfTapsRequired = 1
        singleTapOnString6View.numberOfTouchesRequired = 1
        self.completeStringView.addGestureRecognizer(singleTapOnString6View)
        
        let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnEditView.addTarget(self, action: "tapOnEditView:")
        self.editView.addGestureRecognizer(tapOnEditView)
        
        self.addString6View()
        
        self.specificTabsScrollView.alpha = 0
        self.tabNameTextField.alpha = 0
    }
    
    // hide the keyboard
    func tapOnEditView(sender: UITapGestureRecognizer) {
        self.tabNameTextField.resignFirstResponder()
    }
    
    // choose the base note, move finger point
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
                    self.currentBaseButton = noteButton
                    self.noteButtonOnCompeteScrollView = noteButton
                    self.completeStringView.addSubview(noteButton)
                    noteButton.alpha = 0
                    UIView.animateWithDuration(0.5, animations: {
                        noteButton.alpha = 1
                    })
                    self.addSpecificTabButton(noteButton.tag)
                    self.createEditFingerPoint(noteButton.tag)
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
    
    // move finger point when tap on 6 string view
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
    
    // create 6 finger point for new tabs
    func createEditFingerPoint(sender: Int) {
        self.tabFingerPointChanged = true
        let stringNumber = sender / 100
        let fretNumber = sender - stringNumber * 100
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
        self.fingerPoint.removeAll(keepCapacity: false)
        for var i = 5; i >= 0; i-- {
            let fingerButton: UIButton = UIButton()
            let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
            var buttonX = (fretPosition[0] + fretPosition[1]) / 2 - buttonWidth / 2
            let buttonY = string6Position[i] - buttonWidth / 2
            fingerButton.tag = 0
            if i + 1 == stringNumber {
                buttonX = (fretPosition[fretNumber] + fretPosition[fretNumber + 1]) / 2 - buttonWidth / 2
                fingerButton.tag = fretNumber
            }
            fingerButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            fingerButton.layer.cornerRadius = 0.5 * buttonWidth
            fingerButton.setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
            fingerButton.addTarget(self, action: "pressEditFingerButton:", forControlEvents: UIControlEvents.TouchUpInside)
            if i + 1 > stringNumber {
                fingerButton.accessibilityIdentifier = "blackX"
            } else {
                fingerButton.accessibilityIdentifier = "grayButton"
            }
            self.fingerPoint.append(fingerButton)
            if i < self.currentNoteButton.tag / 100 - 1 {
                self.completeStringView.addSubview(fingerButton)
                
            }
            
        }
    }
    
    // add tabs on specific scrol view
    func addSpecificTabButton(sender: Int) {
        let index: NSNumber = NSNumber(integer: sender)
        self.specificTabSets.removeAll()
        self.specificTabSets = self.data.getTabsSets(index)
        let buttonHeight: CGFloat = 2 / 20 * self.trueHeight
        let buttonWidth: CGFloat = 3 / 20 * self.trueHeight
        for var i = 0; i < self.specificTabSets.count; i++ {
            if self.specificTabSets[i].content != "" {
                let specificButton: UIButton = UIButton()
                specificButton.frame = CGRectMake(0.5 / 20 * self.trueWidth * CGFloat(i + 1) + buttonWidth * CGFloat(i), 0.25 / 20 * self.trueHeight, buttonWidth, buttonHeight)
                specificButton.layer.borderWidth = 1
                specificButton.layer.cornerRadius = 4
                specificButton.addTarget(self, action: "pressSpecificTabButton:", forControlEvents: UIControlEvents.TouchUpInside)
                specificButton.setTitle(self.specificTabSets[i].name, forState: UIControlState.Normal)
                specificButton.tag = i
                specificButton.alpha = 0.1
                if self.specificTabSets[i].isOriginal == true {
                    specificButton.accessibilityIdentifier = "isOriginal"
                } else {
                    specificButton.accessibilityIdentifier = "isNotOriginal"
                }
                self.specificTabsScrollView.addSubview(specificButton)
                self.buttonOnSpecificScrollView.append(specificButton)
            }
        }
        UIView.animateWithDuration(0.2, animations: {
            for item in self.specificTabsScrollView.subviews {
                if item.isMemberOfClass(UIButton) {
                    item.alpha = 1
                }
            }
        })
    }
    
    // choose specific tabs, and generate the finger point for this tab
    func pressSpecificTabButton(sender: UIButton) {
        self.currentSelectedSpecificTab = self.specificTabSets[sender.tag]
        self.tabNameTextField.text = self.currentSelectedSpecificTab.name
        if self.removeAvaliable == false {
            let index = sender.tag
            self.tabFingerPointChanged = false
            self.addSpecificFingerPoint = true
            self.currentNoteButton = sender
            for item in self.fingerPoint {
                item.removeFromSuperview()
            }
            self.fingerPoint.removeAll(keepCapacity: false)
            self.createFingerPoint(index)
        } else {
            if self.currentSelectedSpecificTab.isOriginal == true {
                let alertController = UIAlertController(title: "Warning", message: "Cannot delete build in tabs", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                self.changeRemoveButtonStatus(self.removeButton)
            } else {

                //sender.removeFromSuperview()
                //self.removeObjectsOnCompleteStringView()
                self.removeObjectsOnSpecificTabsScrollView()
                data.removeTabs(self.currentSelectedSpecificTab.tabs)
                self.tabNameTextField.text = self.currentNoteButton.titleLabel?.text
                self.changeRemoveButtonStatus(self.removeButton)
                self.addSpecificTabButton(self.currentNoteButton.tag)
            }
        }
    }
    
    // create finger point for specific tabs
    func createFingerPoint(sender: Int) {
        let content = self.specificTabSets[sender].content
        let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
        var buttonX = fretPosition[1] - buttonWidth / 2
        var buttonY = string6Position[5] - buttonWidth / 2
        for var i = 11; i >= 0; i = i - 2 {
            let startIndex = content.startIndex.advancedBy(11 - i)
            let endIndex = content.startIndex.advancedBy(11 - i + 2)
            let charAtIndex = content[Range(start: startIndex, end: endIndex)]
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
            let stringNumber = Int(self.specificTabSets[sender].index) / 100
            fingerButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            fingerButton.setImage(image, forState: UIControlState.Normal)
            fingerButton.alpha = 0
            fingerButton.tag = temp
            self.fingerPoint.append(fingerButton)// store all the finger point for exist tabs
            UIView.animateWithDuration(0.5, animations: {
                fingerButton.alpha = 1
            })
            if i / 2 < stringNumber - 1 {
                self.completeStringView.addSubview(fingerButton)
            }
        }
    }
    
    // change the finger point status from gray button to black X
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
    
    // press base note button to cancel it or delete it
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
        self.specificTabSets.removeAll(keepCapacity: false)
        self.addNewTab = false
        self.removeAvaliable = false
    }
    
    // remove all oebjects on 6 string View
    func removeObjectsOnCompleteStringView() {
        self.currentNoteButton.removeFromSuperview()
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
    }
    
    // remove all objects on specific tab scroll view
    func removeObjectsOnSpecificTabsScrollView() {
        for item in self.specificTabsScrollView.subviews {
            item.removeFromSuperview()
        }
    }
    
    // music control view, include progressblock, timelabel, previous button, pan gesture, update, count down
    func addMusicControlView() {
        let previousButton: UIButton = UIButton()
        previousButton.frame = CGRectMake(28 / 31 * self.trueWidth, 3 / 20 * self.trueHeight, 2.5 / 31 * self.trueWidth, 2.5 / 31 * trueWidth)
        previousButton.addTarget(self, action: "pressPreviousButton:", forControlEvents: UIControlEvents.TouchUpInside)
        previousButton.setImage(UIImage(named: "icon-previous"), forState: UIControlState.Normal)
        self.musicControlView.addSubview(previousButton)
        
        self.musicControlView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 6 / 20 * self.trueHeight)
        self.view.addSubview(musicControlView)
        
        let musicSingleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnMusicControlView:")
        self.musicControlView.addGestureRecognizer(musicSingleTapRecognizer)
        
        let musicPanRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panOnMusicControlView:")
        self.musicControlView.addGestureRecognizer(musicPanRecognizer)
    }
    
    func setUpTimeLabels() {
        let labelWidth: CGFloat = 40
        let wrapperHeight: CGFloat = 12
        let labelFontSize: CGFloat = 10
        let wrapperWidth: CGFloat = 80
        let wrapper = UIView(frame: CGRect(x: 0, y: musicControlView.frame.height/2-wrapperHeight, width: wrapperWidth, height: wrapperHeight))
        wrapper.center.x = trueWidth/2
        wrapper.backgroundColor = UIColor.darkGrayColor()
        wrapper.alpha = 0.7
        wrapper.layer.cornerRadius = wrapperHeight/5
        musicControlView.addSubview(wrapper)
        
        currentTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: labelFontSize))
        currentTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        currentTimeLabel.text = "0:00.0"
        currentTimeLabel.sizeToFit()
        
        currentTimeLabel.center = CGPoint(x: wrapper.center.x-currentTimeLabel.frame.width/2-2, y: wrapper.center.y)
        currentTimeLabel.textColor = UIColor.whiteColor()
        //i'm not wrapper i'm a singer with a cash flow-> ed sheeran :)
        //make it glow
        currentTimeLabel.layer.shadowColor = UIColor.whiteColor().CGColor
        currentTimeLabel.layer.shadowRadius = 3.0
        currentTimeLabel.layer.shadowOpacity = 1.0
        currentTimeLabel.layer.shadowOffset = CGSizeZero
        currentTimeLabel.layer.masksToBounds = false
        musicControlView.addSubview(currentTimeLabel)
        
        totalTimeLabel = UILabel(frame: CGRect(x: 0, y:0, width: labelWidth, height: labelFontSize))
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        totalTimeLabel.center.y = wrapper.center.y
        totalTimeLabel.text = TimeNumber(time: Float(theSong.playbackDuration)).toDisplayString()
        totalTimeLabel.sizeToFit()
        totalTimeLabel.center = CGPoint(x: wrapper.center.x+totalTimeLabel.frame.width/2+2, y: wrapper.center.y)
        musicControlView.addSubview(totalTimeLabel)
    }
    
    func setUpCountdownView() {
        countdownView = CountdownView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        countdownView.center = self.musicControlView.center
        countdownView.backgroundColor = UIColor.clearColor()
        countdownView.hidden = true
        self.view.addSubview(countdownView)
    }
    
    // pan on music control view to change music time and progressblock time
    func panOnMusicControlView(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        sender.view!.center = CGPointMake(sender.view!.center.x, sender.view!.center.y)
        sender.setTranslation(CGPointZero, inView: self.view)
        let timeChange = NSTimeInterval(-translation.x / 10)
        self.player.currentTime = self.currentTime + timeChange
        self.currentTime = self.player.currentTime
        let persent = CGFloat(self.currentTime) / CGFloat(self.duration)
        self.progressBlock.setProgress(persent)
        self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - persent * (CGFloat(theSong.playbackDuration * 6))

        self.currentTimeLabel.text = TimeNumber(time: Float(self.currentTime)).toDisplayString()
        // find the current tab according to the current time and make the current tab view to yellow
        self.findCurrentTabView()
        
    }
    
    func startTimer() {
        if !timer.valid {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        }
    }

    func startCountdown() {
        countDownStartSecond++
        countdownView.setNumber(countDownStartSecond+1)
        print("count down second \(countDownStartSecond+1)")
        if countDownStartSecond >= 3 {
            
            countdownTimer.invalidate()
            countdownView.hidden = true
            countDownStartSecond = 0
            player.play()
            startTimer()
            self.currentTime = player.currentTime
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        }
    }


    // pause the music or restart it, and count down
    func singleTapOnMusicControlView(sender: UITapGestureRecognizer) {
        if player.playing {
            
            //animate down progress block
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                self.progressBlock!.alpha = 0.5
                }, completion: nil)
            
            //pause music and stop timer
            player.pause()
            timer.invalidate()
        
        } else {
            
            //animate up progress block in 3 seconds, because of the the limited height we are not doing the jump animation
            UIView.animateWithDuration(3.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.progressBlock!.alpha = 1.0
            }, completion: nil)
            
            //start counting down 3 seconds
            countdownView.hidden = false
            countdownView.setNumber(1)
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    // string and fret position
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
            self.string6View.append(tempStringView)
        }
    }
    

    func createSoundWave() {
        let frame = CGRectMake(0.5 * self.trueWidth, 2 / 20 * self.trueHeight, tabsEditorProgressWidthMultiplier * CGFloat(theSong.playbackDuration), 6 / 20 * self.trueHeight)
        self.progressBlock = SoundWaveView(frame: frame)
        if(theSong == nil){
            print("the song is empty")
        }
        let url: NSURL = theSong.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        self.player = try! AVAudioPlayer(contentsOfURL: url)
        self.duration = self.player.duration
        self.player.enableRate = true
        self.player.rate = 1.0
        self.player.volume = 1
        progressBlock.averageSampleBuffer = musicDataManager.getSongWaveFormData(theSong)
        self.progressBlock.SetSoundURL(url)
        self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
        self.progressBlock!.alpha = 0.5

    }
    
    func update() {
        
        self.currentTime = self.player.currentTime
        
        //refresh current time label
        self.currentTimeLabel.text = TimeNumber(time: Float(self.currentTime)).toDisplayString()
        
        //refresh progress block
        let presentPosition = CGFloat(self.currentTime / self.duration)
        self.progressBlock.setProgress(presentPosition)
        
        self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - presentPosition * (CGFloat(theSong.playbackDuration * 6))

    }
    
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
        self.noteButtonOnCompeteScrollView.removeFromSuperview()
        self.fingerPoint.removeAll(keepCapacity: false)
        self.statusLabel.image = UIImage(named: "tabEditor")
        self.addNewTab = false
        self.intoEditView = false
        self.tabFingerPointChanged = false
        self.currentNoteButton = UIButton()
        self.currentTabViewIndex = Int()
        self.removeObjectsOnCompleteStringView()
        self.removeObjectsOnSpecificTabsScrollView()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.editView.removeFromSuperview()
        }
    }
    
    // change remove button when tap on it to show the remove status
    func changeRemoveButtonStatus(sender: UIButton) {
        if self.removeAvaliable == false {
            self.removeAvaliable = true
            self.statusLabel.image = UIImage(named: "deleteTab")
            for item in self.specificTabsScrollView.subviews {
                if item.isMemberOfClass(UIButton) {
                    let tempItem: UIButton = item as! UIButton
                    if tempItem.accessibilityIdentifier == "isNotOriginal" {
                        tempItem.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                    }
                }
            }
            for item in self.mainViewDataArray {
                for item2 in item.noteButtonsWithTab {
                    item2.noteButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                }
            }
            self.currentBaseButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            self.collectionView.reloadData()
        } else {
            self.removeAvaliable = false
            self.statusLabel.image = UIImage(named: "tabEditor")
            for item in self.specificTabsScrollView.subviews {
                if item.isMemberOfClass(UIButton) {
                    let tempItem: UIButton = item as! UIButton
                    tempItem.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                }
            }
            for item in self.mainViewDataArray {
                for item2 in item.noteButtonsWithTab {
                    item2.noteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                }
            }
            self.currentBaseButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.collectionView.reloadData()
        }
    }
    
    // correctly put the tabs on music line
    func setMainViewTabPosition(sender: Int, tab: NormalTabs) -> CGRect {
        let labelHeight = self.progressBlock.frame.height / 2 / 4
        let width = self.trueWidth / 20
        var frame: CGRect = CGRect()
        for item in self.allTabsOnMusicLine {
            if self.compareTabs(item.tab, tab2: tab) {
                let tempFrame = CGRectMake(0 + CGFloat(self.currentTime / self.duration) * (self.progressBlock.frame.width), item.tabView.frame.origin.y, item.tabView.frame.width, item.tabView.frame.height)
                return tempFrame
            }
        }
        
        let numberOfUnrepeatedTab: Int = numberOfUnrepeatedTabOnMainView()
        let tempSender = CGFloat(numberOfUnrepeatedTab % 4)
        
        let dynamicHeight = 0.5 * self.progressBlock.frame.height + labelHeight * tempSender
        frame = CGRectMake(0 + CGFloat(self.currentTime / self.duration) * (self.progressBlock.frame.width), dynamicHeight, width, labelHeight)
        return frame
    }

    // caluclate the tab on music line without repeat
    func numberOfUnrepeatedTabOnMainView() -> Int{
        var set = [String: Int]()
        for tab in self.allTabsOnMusicLine {
            if let val = set["\(tab.tab.index) \(tab.tab.name)"] {
                set["\(tab.tab.index) \(tab.tab.name)"] = val + 1
            }
            else{
                set["\(tab.tab.index) \(tab.tab.name)"] = 1
            }
        }
        return set.count
    }
    
    // press the note button to add the tab in music line
    func pressMainViewNoteButton(sender: UIButton) {
        if self.removeAvaliable == false {
            let tempView: UIView = UIView()
            tempView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 0.6)
            tempView.layer.cornerRadius = 2
            var tempStruct: tabOnMusicLine = tabOnMusicLine()
            let name = self.noteButtonWithTabArray[sender.tag].tab.name
            tempView.frame = setMainViewTabPosition(allTabsOnMusicLine.count, tab: self.noteButtonWithTabArray[sender.tag].tab)
            let tempLabelView: UILabel = UILabel()
            
            tempLabelView.frame = CGRectMake(0, 0, tempView.frame.width, tempView.frame.height)
            tempLabelView.layer.cornerRadius = 2
            tempLabelView.font = UIFont.systemFontOfSize(11)
            tempLabelView.textAlignment = NSTextAlignment.Center
            tempLabelView.numberOfLines = 3
            tempLabelView.text = name
            tempView.addSubview(tempLabelView)
            
            tempStruct.tabView = tempView
            tempStruct.time = self.currentTime
            tempStruct.tab = self.noteButtonWithTabArray[sender.tag].tab
            
            self.allTabsOnMusicLine.append(tempStruct)
            self.progressBlock.addSubview(tempView)
        } else {
            let fretNumber = Int(noteButtonWithTabArray[sender.tag].tab.index) - Int(noteButtonWithTabArray[sender.tag].tab.index) / 100 * 100
            for var i = 0; i < self.mainViewDataArray.count; i++ {
                if self.mainViewDataArray[i].fretNumber == fretNumber {
                    for var j = 0; j < self.mainViewDataArray[i].noteButtonsWithTab.count; j++ {
                        if self.compareTabs(self.mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: self.noteButtonWithTabArray[sender.tag].tab)  {
                            self.mainViewDataArray[i].noteButtonsWithTab[j].noteButton.removeFromSuperview()
                            self.mainViewDataArray[i].noteButtonsWithTab.removeAtIndex(j)
                        }
                    }
                }
            }
            self.noteButtonWithTabArray.removeAtIndex(sender.tag)
            for var i = 0; i < self.noteButtonWithTabArray.count; i++ {
                self.noteButtonWithTabArray[i].noteButton.tag = i
            }
            self.changeRemoveButtonStatus(self.removeButton)
        }
    }
    
    //Mark: press the button on the top functions
    // back to the main view or back to root view
    func pressBackButton(sender: UIButton) {
        if self.intoEditView == true {
            self.backToMainView()
        } else {
            print("back to song view controller")
            
            //hide these two views first because they still appear until this viewcontroller is fully dismissed
            tuningMenu.hidden = true
            musicControlView.hidden = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func dismissAction() {
        UIView.animateWithDuration(0.3, animations: {
            self.tuningMenu.frame = CGRect(x: -self.tuningMenu.frame.width, y: 0, width: self.tuningMenu.frame.width, height: self.tuningMenu.frame.height)
            
            }, completion:
            {
                completed in
                self.actionDismissLayerButton.hidden = true
            }
        )
    }
    func pressTuningButton(sender: UIButton) {
        print("press tuning button")
        self.actionDismissLayerButton.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.tuningMenu.frame = CGRect(x: 0, y: 0, width: self.tuningMenu.frame.width, height: self.trueHeight)
            self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
            self.actionDismissLayerButton.alpha = 0.3
        })
    }
    
    func pressResetButton(sender: UIButton) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to reset all tabs?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: {
            action in
            for var i = 0; i < self.allTabsOnMusicLine.count; i++ {
                UIView.animateWithDuration(0.5, animations: {
                    self.allTabsOnMusicLine[i].tabView.alpha = 0
                })
            }
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                for var i = 0; i < self.allTabsOnMusicLine.count; i++ {
                    self.allTabsOnMusicLine[i].tabView.removeFromSuperview()
                }
                self.allTabsOnMusicLine.removeAll()
            }
            self.player.currentTime = 0
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func pressRemoveButton(sender: UIButton) {
        self.changeRemoveButtonStatus(sender)
    }
    
    func pressAddButton(sender: UIButton) {
        self.view.addSubview(self.editView)
        
        self.player.pause()
        self.timer.invalidate()
        self.timer = NSTimer()
        self.countDownNumber = 0
        
        self.addSpecificFingerPoint = false
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
        if self.intoEditView == true {
            if self.addNewTab == true {
                var addSuccessed: Bool = true
                if self.tabFingerPointChanged == true {
                    print("\(self.currentNoteButton.titleLabel?.text)")
                    let index = self.currentNoteButton.tag
                    let name: String = self.tabNameTextField.text!
                    var content: String = String()
                    if name == "" || name.containsString(" ") {
                        let alertController = UIAlertController(title: "Warning", message: "Please input a  valid tab name (without space)", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        addSuccessed = false
                    } else {
                        for var i = 0; i < 6; i++ {
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
                        let tempTabs: Tabs = self.data.addNewTabs(index, name: name, content: content)
                        self.currentNoteButton.setTitle(name, forState: UIControlState.Normal)
                        self.currentSelectedSpecificTab = NormalTabs()
                        self.currentSelectedSpecificTab.tabs = tempTabs
                        self.currentSelectedSpecificTab.index = index
                        self.currentSelectedSpecificTab.name = name
                        self.currentSelectedSpecificTab.content = content
                        print("successfully add to database")
                        addSuccessed = true
                        self.addSpecificFingerPoint = true
                        self.backToMainView()
                    }
                }

                if addSuccessed == true && self.addSpecificFingerPoint == true {
                    var addNew: Bool = true
                    if let temp = self.currentSelectedSpecificTab {
                    
                    let fretNumber = Int(self.currentSelectedSpecificTab.index) - Int(self.currentSelectedSpecificTab.index) / 100 * 100
                    for var i = 0; i < self.mainViewDataArray.count; i++ {
                        if self.mainViewDataArray[i].fretNumber == fretNumber {
                            for var j = 0; j < self.mainViewDataArray[i].noteButtonsWithTab.count; j++ {
                                if self.compareTabs(self.mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: self.currentSelectedSpecificTab) {
                                    let alertController = UIAlertController(title: "Warning", message: "This tab already exist on Main View", preferredStyle: UIAlertControllerStyle.Alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: { action in
                                        self.collectionView.reloadData()
                                        self.statusLabel.image = UIImage(named: "tabEditor")
                                        self.backToMainView()
                                    }))
                                    self.presentViewController(alertController, animated: true, completion: nil)
                                    addNew = false
                                }
                            }
                        }
                    }
                    }
                    
                    if addNew == true {
                        let tempButton: UIButton = UIButton()
                        let buttonY = Int(self.currentSelectedSpecificTab.index) / 100 - 1
                        let buttonWidth = self.trueWidth / 5 / 3
                        let stringPosition = self.string3Position[buttonY - 3] - buttonWidth / 2
                        let fretPosition = self.trueWidth / 5 / 2 - buttonWidth / 2
                        tempButton.setTitle(self.currentSelectedSpecificTab.name, forState: UIControlState.Normal)
                        tempButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
                        tempButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                        tempButton.addTarget(self, action: "pressMainViewNoteButton:", forControlEvents: UIControlEvents.TouchUpInside)
                        tempButton.layer.cornerRadius = 0.5 * buttonWidth
                        tempButton.frame = CGRectMake(fretPosition, stringPosition, buttonWidth, buttonWidth)
                        
                        let tempTab: NormalTabs = NormalTabs()
                        tempTab.index = self.currentSelectedSpecificTab.index
                        tempTab.name = self.currentSelectedSpecificTab.name
                        tempTab.content = self.currentSelectedSpecificTab.content
                        tempTab.isOriginal = self.currentSelectedSpecificTab.isOriginal
                        
                        let tempNoteButtonWithTab: noteButtonWithTab = noteButtonWithTab()
                        tempNoteButtonWithTab.noteButton = tempButton
                        tempNoteButtonWithTab.tab = tempTab
                        
                        for item in self.mainViewDataArray {
                            if item.fretNumber == Int(tempTab.index) - Int(tempTab.index) / 100 * 100 {
                                item.noteButtonsWithTab.append(tempNoteButtonWithTab)
                            }
                        }
                        self.noteButtonWithTabArray.append(tempNoteButtonWithTab)
                        tempNoteButtonWithTab.noteButton.tag = self.noteButtonWithTabArray.count - 1
                        reorganizeMainViewDataArray()
                        collectionView.reloadData()
                        self.statusLabel.image = UIImage(named: "tabEditor")
                        backToMainView()
                    }
                }

            }
        } else {
            self.player.stop()
            self.timer.invalidate()
            self.timer = NSTimer()
            self.currentTime = 0
            var allChords = [String]()
            var allTabs = [String]()
            var allTimes = [NSTimeInterval]()

            for oneline in allTabsOnMusicLine {
                allChords.append(oneline.tab.name)
                allTabs.append(oneline.tab.content)
                allTimes.append(oneline.time)
                
                print("TABS:\(oneline.tab.name) |Time:\(oneline.time)")
            }
            
            var tuningOfTheSong = ""
            for label in tuningValueLabels {
                tuningOfTheSong += "\(label.text!)-"
            }
            self.musicDataManager.saveTabs(theSong, chords: allChords, tabs: allTabs, times: allTimes, tuning: tuningOfTheSong, capo: Int(capoStepper.value))
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.currentSelectedSpecificTab = nil
    }
    
    // compare the tab whether equals
    func compareTabs(tab1: NormalTabs, tab2: NormalTabs) -> Bool {
        if tab1.index == tab2.index && tab1.name == tab2.name && tab1.content == tab2.content {
            return true
        } else {
            return false
        }
    }
    
    // organize the note button position and size accroding the the numbers.
    func reorganizeMainViewDataArray() {
        for item in self.mainViewDataArray {
            let buttonWidth: CGFloat = self.trueWidth / 5 / 3 * 1.5
            let buttonWidth2: CGFloat = self.trueWidth / 5 / 3 * 1.5
            let buttonWidth3: CGFloat = self.trueWidth / 5 / 3 * 1
            var buttonX2: [CGFloat] = [self.trueWidth / 5 / 2 - buttonWidth2, self.trueWidth / 5 / 2]
            var buttonX3: [CGFloat] = [0, self.trueWidth / 5 / 2 - buttonWidth3 / 2, self.trueWidth / 5 / 2 + buttonWidth3 / 2]
            
            for var i = 4; i <= 6; i++ {
                var tempButtonArray: [noteButtonWithTab] = [noteButtonWithTab]()
                for buttonWithTab in item.noteButtonsWithTab {
                    if Int(buttonWithTab.tab.index) / 100 == i {
                        tempButtonArray.append(buttonWithTab)
                    }
                }
                if tempButtonArray.count == 1 {
                    print(tempButtonArray[0].noteButton.titleLabel!.text)
                    tempButtonArray[0].noteButton.frame = CGRectMake(self.trueWidth / 5 / 2 - buttonWidth / 2, self.string3Position[Int(tempButtonArray[0].tab.index) / 100 - 4] - buttonWidth / 2, buttonWidth, buttonWidth)
                    tempButtonArray[0].noteButton.layer.cornerRadius = 0.5 * buttonWidth
                    tempButtonArray[0].noteButton.titleLabel!.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                }
                if tempButtonArray.count == 2 {
                    for var j = 0; j < tempButtonArray.count; j++ {
                        print(tempButtonArray[j].noteButton.titleLabel!.text)
                        tempButtonArray[j].noteButton.frame = CGRectMake(buttonX2[j], self.string3Position[Int(tempButtonArray[j].tab.index) / 100 - 4] - buttonWidth2 / 2, buttonWidth2, buttonWidth2)
                        tempButtonArray[j].noteButton.layer.cornerRadius = 0.5 * buttonWidth2
                        tempButtonArray[j].noteButton.titleLabel!.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                    }
                } else if tempButtonArray.count == 3 {
                    for var j = 0; j < tempButtonArray.count; j++ {
                        print(tempButtonArray[j].noteButton.titleLabel!.text)
                        tempButtonArray[j].noteButton.frame = CGRectMake(buttonX3[j], self.string3Position[Int(tempButtonArray[j].tab.index) / 100 - 4] - buttonWidth3 / 2, buttonWidth3, buttonWidth3)
                        tempButtonArray[j].noteButton.layer.cornerRadius = 0.5 * buttonWidth3
                        tempButtonArray[j].noteButton.titleLabel!.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                    }
                }
            }
        }
    }
    
    func pressPreviousButton(sender: UIButton) {
        if self.allTabsOnMusicLine.count > 1 {
            self.allTabsOnMusicLine[self.currentTabViewIndex].tabView.removeFromSuperview()
            self.allTabsOnMusicLine.removeAtIndex(self.currentTabViewIndex)
            self.currentTabViewIndex = self.currentTabViewIndex--
            findCurrentTabView()
            self.player.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time
            self.currentTime = self.player.currentTime
        } else if self.allTabsOnMusicLine.count == 1 {
            self.allTabsOnMusicLine[self.currentTabViewIndex].tabView.removeFromSuperview()
            self.allTabsOnMusicLine.removeAtIndex(self.currentTabViewIndex)
            self.currentTabViewIndex = 0
            self.player.currentTime = 0
            self.currentTime = 0
        } else {
            self.player.currentTime = 0
            self.currentTime = 0
        }
    }
    
    
    // find the current tab according to the current music time
    func findCurrentTabView() {
        for var i = 0; i < self.allTabsOnMusicLine.count; i++ {
            self.allTabsOnMusicLine[i].tabView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        }
        if self.allTabsOnMusicLine.count == 1 {
            if self.currentTime >= self.allTabsOnMusicLine[0].time {
                self.allTabsOnMusicLine[0].tabView.backgroundColor = UIColor.yellowColor()
                self.currentTabViewIndex = 0
            }
        } else {
            for var i = 1; i < self.allTabsOnMusicLine.count + 1; i++ {
                if i < self.allTabsOnMusicLine.count {
                    if self.currentTime > self.allTabsOnMusicLine[i - 1].time && self.currentTime <= self.allTabsOnMusicLine[i].time {
                        self.allTabsOnMusicLine[i - 1].tabView.backgroundColor = UIColor.yellowColor()
                        self.currentTabViewIndex = i - 1
                        break
                    }
                } else if i == self.allTabsOnMusicLine.count {
                    if self.currentTime > self.allTabsOnMusicLine[i - 1].time {
                        self.allTabsOnMusicLine[i - 1].tabView.backgroundColor = UIColor.yellowColor()
                        self.currentTabViewIndex = i - 1
                        break
                    }
                }
            }
        }
    }
    

}

