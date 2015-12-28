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

class TabsEditorViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    var doubleArrow: UIImageView = UIImageView(image: UIImage(named: "doubleArrow"))
    
    // delete jiggling gesture 
    let deleteChordOnMainView: UITapGestureRecognizer = UITapGestureRecognizer()
    let deleteChordOnSpecificTabView: UITapGestureRecognizer = UITapGestureRecognizer()
    let longPressSpecificTabButton: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    let longPressMainViewNoteButton: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    // define jiggling gesture recognizer for base note button
    var isJiggling: Bool = false
    var longPressX:CGFloat = 0
    var longPressY:CGFloat = 0
    var oldTagString4:Int = 0
    var oldTagString5:Int = 0
    let jigglingPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    let jigglingTapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    let jigglingLongPressGesture : UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    var originalCenter: CGPoint!
    var deleteView:UIImageView = UIImageView()
    var scrollingTimer: NSTimer!
    var startScrolling: Bool = false
    var stopEdgeStartTime:Double = -1
    var rightEdgeTimer:NSTimer?
    var leftEdgeTimer:NSTimer?
    
    var stepPerSecond: Float = 100
    var startTime: TimeNumber = TimeNumber(second: 0, decimal: 0)
    var speed: Float = 1
    
    var songViewController: SongViewController!
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
    //MARK: decide the progress block width
    let tabsEditorProgressWidthMultiplier: CGFloat = 10
    var progressBlock: SoundWaveView!
    var theSong: Findable!
    var currentTime: NSTimeInterval = NSTimeInterval()
    var avPlayer: AVAudioPlayer!
    var musicPlayer: MPMusicPlayerController!
    var isDemoSong = false
    var duration: NSTimeInterval = NSTimeInterval()
    var musicControlView: UIView = UIView()
    
    // musicPlayer playing mode for recover queue
    var recoverMode: (MPMusicRepeatMode, MPMusicShuffleMode, NSTimeInterval)!
    
    var musicSingleTapRecognizer: UITapGestureRecognizer!
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
    var string6FretPosition: [CGFloat] = [CGFloat]()
    var string3FretPosition: [CGFloat] = [CGFloat]()
    
    // core data functions
    var tabsDataManager: TabsDataManager = TabsDataManager()
    
    // objects on view which need to be changed in different places
    var removeButton: UIButton = UIButton()
    var statusLabel: UILabel = UILabel()
    var completeImageView: UIImageView = UIImageView()
    var noteButtonOnCompeteScrollView: UIButton = UIButton()
    var buttonOnSpecificScrollView: [UIButton] = [UIButton]()
    var fingerPoint: [UIButton] = [UIButton]()
    var currentNoteButton: UIButton = UIButton()
    var currentTimeLabel: UILabel = UILabel()
    var totalTimeLabel: UILabel = UILabel()

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
    
    var isPlaying:Bool = false
    
    // count down section
    
    var countdownTimer = NSTimer()
    var countDownStartSecond = 3 //will countdown from 3 to 1

    var countdownView: CountdownView!
    
    // key is the stepper value ranging from 0.7 to 1.3 in step of 0.1
    // value is the real speed the song is playing
    let speedMatcher = [0.7: 0.50, 0.8:0.67 ,0.9: 0.79,  1.0:1.00 ,1.1: 1.25  ,1.2 :1.50, 1.3: 2.00]
    let speedLabels = [0.7: "0.5x", 0.8: "0.65x" ,0.9: "0.8x",  1.0: "1.0x" ,1.1: "1.25x"  ,1.2 : "1.5x", 1.3: "2x"]
    
    // data array
    var specificTabSets: [NormalTabs] = [NormalTabs]()
    var currentSelectedSpecificTab: NormalTabs!
    var countDownNumber: Float = 3
    
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
        
        //
        checkConverToMPMediaItem()
        
        // create the sound wave
        self.createSoundWave()
        
        // add the background image with blur
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(0, 0, self.trueWidth, self.trueWidth)
        let size: CGSize = CGSizeMake(self.trueWidth, self.trueWidth)
        var image:UIImage!
        if let artwork = theSong.getArtWork() {
            image = artwork.imageWithSize(size)
        } else {
            //TODO: add a placeholder album cover
            image = UIImage(named: "liwengbg")
        }
        backgroundImage.image = image
        
        let blurredImage:UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        self.view.addSubview(backgroundImage)

        self.currentBaseButton.tag = 400
        
        // add the default tab data into coredata if it doesn't exist
        self.tabsDataManager.addDefaultData()
        
        // initial the edit view
        self.editView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 18 / 20 * self.trueHeight)
        
        // add objects on main view and edit view
        self.addObjectsOnMainView()
        self.createStringAndFretPosition()
        self.addObjectsOnEditView()
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
        
        
        // MARK: add exist chord to tab editor view
        self.addChordToEditorView(theSong)
    }
    
    // MARK: Notification
    func registerNotification() {
        if musicPlayer != nil {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playbackStateChanged:"), name:MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentSongChanged:"), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: musicPlayer)
            musicPlayer.beginGeneratingPlaybackNotifications()
        }
    }
    
    func removeNotification() {
        if musicPlayer != nil {
            musicPlayer.endGeneratingPlaybackNotifications()
            NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer)
             NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: musicPlayer)
        }
    }
    
    func playbackStateChanged(sender: NSNotification) {
        if musicPlayer.playbackState == .Playing {
            if(!isPlaying){
                self.startTimer()
                isPlaying = true
            }
            self.progressBlock.alpha = 1
        } else if musicPlayer.playbackState == .Paused {
            isPlaying = false
            timer.invalidate()
            timer = NSTimer()
            self.progressBlock.alpha = 0.5
        }
    }
    
    func currentSongChanged(sender: NSNotification){
        if musicPlayer.playbackState == .Playing {
            musicPlayer.currentPlaybackRate = self.speed
        }
    }
    
    
    // MARK: check theSong can convert to MPMediaItem
    func checkConverToMPMediaItem() {
        if !self.isDemoSong {
            musicPlayer = MusicManager.sharedInstance.player
            registerNotification()
        } else {
            avPlayer = AVAudioPlayer()
        }
    }

    // MARK: a slider menu that allow user to specify speed, capo number, and six string tuning
    func setUpTuningControlMenu() {
        // a gray button covers the entire background behind tuning menu, is to dismiss the tuning menus
        actionDismissLayerButton = UIButton(frame: CGRect(x: 0, y: 0, width: trueWidth, height: trueHeight))
        actionDismissLayerButton.backgroundColor = UIColor.clearColor()
        actionDismissLayerButton.addTarget(self, action: "dismissAction", forControlEvents: .TouchUpInside)
        self.view.addSubview(actionDismissLayerButton)
        actionDismissLayerButton.hidden = true
        
        tuningMenu = UIView(frame: CGRect(x: -250, y: 0, width: 250, height: trueHeight))
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
        speedLabel = UILabel(frame: CGRect(x: sideMargin, y: 0, width: 120, height: 25))
        speedLabel.textColor = UIColor.mainPinkColor()
        speedLabel.text = "Speed: 1.0x"
        speedLabel.center.y = rowHeight/2
        tuningMenu.addSubview(speedLabel)

        speedStepper = UIStepper(frame: CGRect(x: tuningMenu.frame.width-94-sideMargin, y: 0, width: 94, height: 29))
        speedStepper.center.y = rowHeight/2
        speedStepper.tintColor = UIColor.mainPinkColor()
        speedStepper.minimumValue = 0.7 //these are arbitrary numbers just so that the stepper can go down 3 times and go up 3 times
        speedStepper.maximumValue = 1.3
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
        
        let buttonDimension: CGFloat = 20
        
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
            
            let stepUpButton = UIButton(frame: CGRect(x:0, y: 0, width: 30, height: 20))
            stepUpButton.setImage(UIImage(named: "vote_up_pink"), forState: .Normal)
            stepUpButton.contentMode = .ScaleToFill
            stepUpButton.tag = i
            stepUpButton.addTarget(self, action: "stepUpPressed:", forControlEvents: .TouchUpInside)
            stepUpButton.center = CGPoint(x: tuningValueLabel.center.x + buttonDimension + 10, y: tuningValueLabel.center.y)
            tuningMenu.addSubview(stepUpButton)
            stepUpButtons.append(stepUpButton)

            let stepDownButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
            
            stepDownButton.tag = i
            stepDownButton.addTarget(self, action: "stepDownPressed:", forControlEvents: .TouchUpInside)
            stepDownButton.setImage(UIImage(named: "vote_down_pink"), forState: .Normal)
            stepDownButton.contentMode = .ScaleToFill
            stepDownButton.center = CGPoint(x: tuningValueLabel.center.x - buttonDimension - 10, y: tuningValueLabel.center.y)
            tuningMenu.addSubview(stepDownButton)
            stepDownButtons.append(stepDownButton)
        }
    }
    
    func speedStepperValueChanged(stepper: UIStepper) {
        let speedKey = Double(round(10*stepper.value)/10)
        let adjustedSpeed = Float(speedMatcher[speedKey]!)
        self.speedLabel.text = "Speed: \(speedLabels[speedKey]!)"
        if isDemoSong {
            if self.avPlayer.playing {
                self.avPlayer.rate = adjustedSpeed
            }            
        } else {
            if self.musicPlayer.playbackState == .Playing {
                self.musicPlayer.currentPlaybackRate = adjustedSpeed
            }
        }
        self.speed = adjustedSpeed
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
    
    
    let prepareMoveLongPressGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
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

        prepareMoveLongPressGesture.addTarget(self, action: "prepareMoveLongPressGesture:")
        prepareMoveLongPressGesture.direction = .Up
        prepareMoveLongPressGesture.delegate = self
        collectionView.addGestureRecognizer(prepareMoveLongPressGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapOnCollectionView:")
        collectionView.addGestureRecognizer(tapGesture)

    }
    
    func prepareMoveLongPressGesture(sender: UISwipeGestureRecognizer) {
//        if sender.state == .Began {
            let location = sender.locationInView(collectionView)
            var positionX: CGFloat = 0
            var stringIndex: Int = 0
            for var index = 0; index < self.string3FretPosition.count; index++ {
                if location.x < self.string3FretPosition[self.string3FretPosition.count - 2] {
                    if location.x > self.string3FretPosition[index] && location.x < self.string3FretPosition[index + 1] {
                        stringIndex = index
                        positionX = self.string3FretPosition[index]
                        break
                    }
                }
            }
            
//            var isLongPressButton: Bool = false
//            for item in self.noteButtonWithTabArray {
//                let tempLocation: CGPoint = CGPointMake(location.x - CGFloat(stringIndex) * self.trueWidth / 5, location.y)
//                if CGRectContainsPoint(item.noteButton.frame, tempLocation) {
//                    isLongPressButton = true
//                    break
//                }
//            }
            //if isLongPressButton == false {
                
                
                let imageWidth: CGFloat = self.trueWidth / 5 - 10
                let imageHeight: CGFloat = 44
                self.doubleArrow.frame = CGRectMake(positionX + 5, collectionView.frame.origin.y - 44, imageWidth, imageHeight)
                self.doubleArrow.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
                self.view.addSubview(self.doubleArrow)
                let gesture = UIPanGestureRecognizer(target: self,
                    action: "handleGesture:")
                gesture.delegate = self
                self.doubleArrow.addGestureRecognizer(gesture)
                self.doubleArrow.userInteractionEnabled = true
                
                prepareMoveLongPressGesture.enabled = false
                musicControlView.userInteractionEnabled = false
           // }
       // }
    }
    
    func singleTapOnCollectionView(sender: UITapGestureRecognizer) {
        if isJiggling == false {
            var indexFret: Int = Int()
            var indexString: Int = Int()
            let string3Height: CGFloat = 11 / 60 * self.trueHeight / 2
            var original:CGFloat = 0
            let location = sender.locationInView(self.collectionView)
            // get the tap position for fret number and string number
            for var index = 0; index < self.string3FretPosition.count; index++ {
                if location.x < self.string3FretPosition[self.string3FretPosition.count - 2] {
                    if location.x > self.string3FretPosition[index] && location.x < self.string3FretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for var index = 0; index < self.string3Position.count; index++ {
                if location.y >= self.string3Position[index] - string3Height && location.y <= self.string3Position[index] + string3Height {
                    indexString = index + 3
                    original = string3Height  - self.string3Position[index]
                }
            }
            // open the editor view and add note button
            self.addButtonPress3StringView(indexFret: indexFret, indexString: indexString, original: original)
        } else {
            self.stopNormalJinggling(longPressMainViewNoteButton)
        }
    }
    
    
    func addButtonPress3StringView(indexFret indexFret: Int, indexString: Int, original:CGFloat?=nil) {
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
        self.completeStringView.contentOffset = self.collectionView.contentOffset
        UIView.animateWithDuration(0.2, animations: {
            self.completeStringView.alpha = 1
            self.specificTabsScrollView.alpha = 1
            self.tabNameTextField.alpha = 1
            self.completeStringView.frame = CGRectMake(0, 3 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
        })
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
        return 25
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("fretcell", forIndexPath: indexPath) as! FretCell
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
                let tempX = gestureRecognizer.locationInView(ca).x
                let tempY = gestureRecognizer.locationInView(ca).y + 44
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
            //var originalIndexPath: NSIndexPath = self.collectionView.indexPathForItemAtPoint(dragPointOnCanvas)!
            if gesture.state == UIGestureRecognizerState.Began {
                bundle.sourceCell.hidden = true
                self.view?.addSubview(bundle.representationImageView)
                self.view.userInteractionEnabled = false
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    bundle.representationImageView.alpha = 0.8
                })
                self.view.userInteractionEnabled = true
            }
            if gesture.state == UIGestureRecognizerState.Changed {
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCanvas.x - bundle.offset.x
                point.y = dragPointOnCanvas.y - bundle.offset.y + 44
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                let tempX = gesture.locationInView(self.collectionView).x
                let tempY = gesture.locationInView(self.collectionView).y + 44 + self.collectionView.frame.size.height / 2
                let dragPointOnCollectionView = CGPointMake(tempX, tempY)//gesture.locationInView(self.collectionView)
                if let toIndexPath : NSIndexPath = self.collectionView?.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    self.checkForDraggingAtTheEdgeAndAnimatePaging(gesture)
                    if toIndexPath.isEqual(bundle.currentIndexPath) == false {
                        moveDataItem(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        self.collectionView!.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: toIndexPath)
                        self.bundle!.currentIndexPath = toIndexPath
                    }
                }
                
                self.doubleArrow.center = CGPointMake(bundle.representationImageView.center.x, bundle.representationImageView.frame.origin.y - 22)
            }
            if gesture.state == UIGestureRecognizerState.Ended {
                bundle.sourceCell.hidden = false
                bundle.representationImageView.removeFromSuperview()
                collectionView!.reloadData()
                self.bundle = nil
                prepareMoveLongPressGesture.enabled = true
                doubleArrow.removeFromSuperview()
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
        
        statusLabel.frame = CGRectMake(2 / 31 * self.trueWidth, 0.25 / 20 * self.trueWidth, 14 / 31 * self.trueWidth, buttonWidth * 0.65)
        self.statusLabel.text = "Tabs Editor"
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.textAlignment = NSTextAlignment.Center
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
        removeButton.hidden = true
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
        self.specificTabsScrollView.frame = CGRectMake(0.5 / 31 * self.trueWidth, 0.25 / 20 * self.trueHeight, 22 / 31 * self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.specificTabsScrollView.contentSize = CGSizeMake(self.trueWidth / 2, 2.5 / 20 * self.trueHeight)
        self.specificTabsScrollView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.specificTabsScrollView.layer.cornerRadius = 3
        self.editView.addSubview(specificTabsScrollView)
        
        self.tabNameTextField.frame = CGRectMake(23.5 / 31 * self.trueWidth, 0.25 / 20 * self.trueHeight, 7 / 31 * self.trueWidth, 2.5 / 20 * self.trueHeight)
        self.tabNameTextField.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.tabNameTextField.textColor = UIColor.whiteColor()
        self.tabNameTextField.tintColor = UIColor.whiteColor()
        self.tabNameTextField.layer.cornerRadius = 3
        self.tabNameTextField.autocorrectionType = UITextAutocorrectionType.No
        self.tabNameTextField.delegate = self
        self.tabNameTextField.attributedPlaceholder = NSAttributedString(string:"Input Name",
            attributes:[NSForegroundColorAttributeName: UIColor(white: 0.8, alpha: 1), NSFontAttributeName: UIFont.boldSystemFontOfSize(17)])
        self.tabNameTextField.textAlignment = .Center
        self.editView.addSubview(tabNameTextField)
        self.tabNameTextField.addTarget(self, action: "textFieldTextChanged:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.completeStringView.frame = CGRectMake(0, 6 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeStringView.contentSize = CGSizeMake(5 * self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeStringView.backgroundColor = UIColor.clearColor()
        
        self.completeImageView.frame = CGRectMake(0, 0, 5 * self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeImageView.image = UIImage(named: "6-strings-new-with-numbers")
        self.completeStringView.addSubview(completeImageView)
        self.editView.addSubview(completeStringView)
        
        let singleTapOnString6View: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnString6View:")
        self.completeStringView.addGestureRecognizer(singleTapOnString6View)
        
        let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnEditView.addTarget(self, action: "tapOnEditView:")
        self.editView.addGestureRecognizer(tapOnEditView)
        
        self.addString6View()
        self.specificTabsScrollView.alpha = 0
        self.tabNameTextField.alpha = 0
    }
    
    // hide the keyboard
    var isTextChanged = false
    func tapOnEditView(sender: UITapGestureRecognizer) {
        self.tabNameTextField.resignFirstResponder()
        self.stopNormalJinggling(self.longPressSpecificTabButton)
    }
    
    //textfeild delege
    let tempTapView:UIView = UIView()
    func textFieldDidBeginEditing(textField: UITextField) {
        self.tabFingerPointChanged = true
        tempTapView.frame = self.completeStringView.frame
        tempTapView.backgroundColor = UIColor.clearColor()
        self.editView.addSubview(self.tempTapView)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tempTapView.removeFromSuperview()
        if (self.specificTabsScrollView.subviews.count == 1 && self.specificTabsScrollView.subviews[0].isKindOfClass(UILabel) && !isTextChanged){
            self.removeObjectsOnSpecificTabsScrollView()
            self.tabNameTextField.text = ""
        }else if pressDoneButton && !isTextChanged {
            self.tabNameTextField.text = ""
        }
        pressDoneButton = false
        isTextChanged = false
    }
    
    func textFieldTextChanged(textField : UITextField){
        let tempString = self.tabNameTextField.text?.replace(" ", replacement: "")
        if tempString != self.currentBaseButton.titleLabel!.text {
            isTextChanged = true
        }else{
            isTextChanged = false
        }
    }
    
    
    // add note button to view 
    func addNoteButton(indexFret: Int, indexString: Int, originalPosition:CGFloat?=nil) {
        
        let noteButton: UIButton = UIButton()
        let buttonFret = (self.string6FretPosition[indexFret] + self.string6FretPosition[indexFret + 1]) / 2
        let buttonString = self.string6Position[indexString]
        let buttonWidth = 7 / 60 * self.trueHeight
        
        var original:CGFloat = 0
        if(originalPosition != nil){
            original = 6 / 20 * self.trueHeight - originalPosition! - buttonWidth / 2
        }else{
            original = buttonString
        }
        
        noteButton.frame = CGRectMake(buttonFret - buttonWidth / 2, original - buttonWidth / 2, buttonWidth, buttonWidth)
        noteButton.layer.cornerRadius = 0.5 * buttonWidth
        noteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        noteButton.backgroundColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.8)
        noteButton.tag = (indexString + 1) * 100 + indexFret
        noteButton.addTarget(self, action: "pressNoteButton:", forControlEvents: UIControlEvents.TouchUpInside)
        let tabName = self.tabsDataManager.fretsBoard[indexString][indexFret]
        noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
        self.currentNoteButton = noteButton
        self.currentBaseButton = noteButton
        self.noteButtonOnCompeteScrollView = noteButton
        self.completeStringView.addSubview(noteButton)
        noteButton.alpha = 1
        

        jigglingTapGesture.addTarget(self, action: "startJiggling:")
        noteButton.addGestureRecognizer(jigglingTapGesture)
        self.jigglingTapGesture.requireGestureRecognizerToFail(self.jigglingLongPressGesture)
        
        jigglingLongPressGesture.addTarget(self, action: "startJiggling:")
        noteButton.addGestureRecognizer(jigglingLongPressGesture)
        jigglingLongPressGesture.minimumPressDuration = 0.01
        
        if(originalPosition != nil){
            let duration:NSTimeInterval = NSTimeInterval(sqrt(2.0*(buttonString-original)/9.8)/3)
            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: CGFloat(0.6/duration), initialSpringVelocity:CGFloat(0.6/duration), options: .CurveEaseInOut, animations: {
                    noteButton.alpha = 1
                    noteButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
                }, completion: nil)
            
        }else{
            UIView.animateWithDuration(0.3, animations: {
                noteButton.alpha = 1
                noteButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
            })
        }
        
        self.addSpecificTabButton(noteButton.tag)
        
        if addedNoteButtonOnCompleteView == true {
            self.createEditFingerPoint(noteButton.tag)
        }
        for var i = 6 - indexString; i <= 5; i++ {
            self.fingerPoint[i].hidden = false
        }
        
        self.oldTagString4 = 0
        self.oldTagString5 = 0
    }
    

    // choose the base note, move finger point
    func singleTapOnString6View(sender: UITapGestureRecognizer) {
        self.view.userInteractionEnabled = false
        if self.isJiggling == false {
            var indexFret: Int = Int()
            var indexString: Int = Int()
            let location = sender.locationInView(self.completeStringView)
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
            if (indexString + 1) >= self.currentBaseButton.tag / 100 && indexString >= 3 && indexString <= 5{
               if !(((indexString + 1) == self.currentBaseButton.tag / 100)&&(indexFret == self.currentBaseButton.tag%100)) || (!self.addedNoteButtonOnCompleteView && !self.addNewTab){
                    self.currentBaseButton.removeFromSuperview()
                    self.addNoteButton(indexFret, indexString: indexString)
                    self.moveFingerPoint(indexFret, indexString: indexString)
                    self.tabNameTextField.text = ""
                    self.completeStringView.addSubview(self.fingerPoint[6 - indexString])
                    self.fingerPoint[6 - (indexString + 1)].hidden = true
                    self.fingerPoint[6 - (indexString + 1)].accessibilityIdentifier = "grayButton"
                    self.fingerPoint[6 - (indexString + 1)].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
                    self.addedNoteButtonOnCompleteView = true
                    self.addNewTab = true
                }
            }
            if (indexString + 1) < self.currentBaseButton.tag / 100 {
                moveFingerPoint(indexFret, indexString: indexString)
            }
        } else {
            self.stopJiggling()
            self.stopNormalJinggling(longPressSpecificTabButton)
            
        }
        
        self.view.userInteractionEnabled = true
    }
    
    // move finger point when tap on 6 string view
    func moveFingerPoint(indexFret: Int, indexString: Int) {
        print("move finger point")
        self.view.userInteractionEnabled = false
        //let noteString = self.currentBaseButton.tag / 100 - 1
       // if indexString != noteString {
            let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
            let buttonX = (string6FretPosition[indexFret] + string6FretPosition[indexFret + 1]) / 2 - buttonWidth / 2
            let buttonY = string6Position[indexString] - buttonWidth / 2
            self.fingerPoint[5 - indexString].frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            self.fingerPoint[5 - indexString].alpha = 0
            self.fingerPoint[5 - indexString].tag = indexFret
            self.fingerPoint[5 - indexString].hidden = false
            UIView.animateWithDuration(0.3, animations: {
                self.fingerPoint[5 - indexString].alpha = 1
            })
            self.view.userInteractionEnabled = true
            self.tabFingerPointChanged = true
        //}
    }
    
    var addedNoteButtonOnCompleteView: Bool = false
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
            var buttonX = (string6FretPosition[0] + string6FretPosition[1]) / 2 - buttonWidth / 2
            let buttonY = string6Position[i] - buttonWidth / 2
            fingerButton.tag = 0
            if i + 1 == stringNumber {
                buttonX = (string6FretPosition[fretNumber] + string6FretPosition[fretNumber + 1]) / 2 - buttonWidth / 2
                fingerButton.tag = fretNumber
            }
            fingerButton.hidden = true
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
            self.completeStringView.addSubview(fingerButton)
        }
    }
    
    // add tabs on specific scrol view
    func addSpecificTabButton(sender: Int) {
        self.view.userInteractionEnabled = false
        let index: NSNumber = NSNumber(integer: sender)
        self.specificTabSets.removeAll()
        self.specificTabSets = self.tabsDataManager.getTabsSets(index)
        let buttonHeight: CGFloat = 2 / 20 * self.trueHeight
        let buttonWidth: CGFloat = 4 / 20 * self.trueHeight
        // change specific tab button scrollview content frame
        let scrollviewWidth = (buttonWidth + 0.5 / 20 * self.trueWidth) * CGFloat(5) + 0.5 / 20 * self.trueWidth
        
        self.specificTabsScrollView.contentSize = CGSizeMake(scrollviewWidth, 2.5 / 20 * self.trueHeight)
        
        self.specificTabsScrollView.contentOffset = CGPointZero
        UIView.animateWithDuration(0.1, animations: {
            for item in self.buttonOnSpecificScrollView {
                item.alpha = 0
            }
            }, completion:
            {   completed in
                self.removeObjectsOnSpecificTabsScrollView()
                for var i = 0; i < self.specificTabSets.count; i++ {
                    if self.specificTabSets[i].content != "" {
                        let specificButton: UIButton = UIButton()
                        specificButton.frame = CGRectMake(0.5 / 20 * self.trueWidth * CGFloat(i + 1) + buttonWidth * CGFloat(i), 0.25 / 20 * self.trueHeight, buttonWidth, buttonHeight)
                        specificButton.backgroundColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.8)
                        specificButton.layer.cornerRadius = 4
                        specificButton.addTarget(self, action: "pressSpecificTabButton:", forControlEvents: UIControlEvents.TouchUpInside)
                        specificButton.setTitle(self.specificTabSets[i].name, forState: UIControlState.Normal)
                        specificButton.tag = i
                        specificButton.alpha = 0
                        specificButton.transform = CGAffineTransformMakeScale(0.6,0.6)
                        if self.specificTabSets[i].isOriginal == true {
                            specificButton.accessibilityIdentifier = "isOriginal"
                        } else {
                            specificButton.accessibilityIdentifier = "isNotOriginal"
                            self.longPressSpecificTabButton.addTarget(self, action: "startNormalJinggling:")
                            self.longPressSpecificTabButton.minimumPressDuration = 0.5
                            specificButton.addGestureRecognizer(self.longPressSpecificTabButton)
                            specificButton.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.8)
                        }
                        self.specificTabsScrollView.addSubview(specificButton)
                        self.buttonOnSpecificScrollView.append(specificButton)
                    }
                }
                
                var delay:NSTimeInterval = -0.05
                    for item in self.specificTabsScrollView.subviews {
                        delay = delay+0.05
                        UIView.animateWithDuration(0.2, delay: delay, options: .CurveEaseInOut, animations: {
                            if item.isMemberOfClass(UIButton) {
                                item.transform = CGAffineTransformMakeScale(1,1)
                                item.alpha = 1
                            }
                            }, completion: nil)
                    }
                if (self.specificTabsScrollView.subviews.count == 0){
                    self.statusLabel.text = "Input Chord Name"
                }else{
                    self.statusLabel.text = "Choose Or input Chord Name"
                }
            }
        )
        
        self.view.userInteractionEnabled = true
    }
    
    // choose specific tabs, and generate the finger point for this tab
    func pressSpecificTabButton(sender: UIButton) {
        self.tabNameTextField.resignFirstResponder()
        self.currentSelectedSpecificTab = self.specificTabSets[sender.tag]
        self.tabNameTextField.text = self.currentSelectedSpecificTab.name
        let index = sender.tag
        self.tabFingerPointChanged = false
        self.addSpecificFingerPoint = true
        self.currentNoteButton = sender
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
        self.fingerPoint.removeAll(keepCapacity: false)
        self.createFingerPoint(index)
    }
    
    // create finger point for specific tabs
    func createFingerPoint(sender: Int) {
        let content = self.specificTabSets[sender].content
        let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
        var buttonX = string6FretPosition[1] - buttonWidth / 2
        var buttonY = string6Position[5] - buttonWidth / 2
        var miniButtonX:CGFloat = CGFloat.infinity
        var maxButtonX:CGFloat = -1
        for var i = 11; i >= 0; i = i - 2 {
            let startIndex = content.startIndex.advancedBy(11 - i)
            let endIndex = content.startIndex.advancedBy(11 - i + 2)
            let charAtIndex = content[Range(start: startIndex, end: endIndex)]
            let fingerButton: UIButton = UIButton()
            var image: UIImage = UIImage()
            var temp: Int = Int()
            if charAtIndex == "xx" {
                temp = 1
                buttonX = string6FretPosition[1] - buttonWidth / 2
                buttonY = string6Position[i / 2] - buttonWidth / 2
                image = UIImage(named: "blackX")!
                fingerButton.accessibilityIdentifier = "blackX"
            } else {
                temp = Int(String(charAtIndex))!
                image = UIImage(named: "grayButton")!
                buttonX = (string6FretPosition[temp] + string6FretPosition[temp + 1]) / 2 - buttonWidth / 2
                buttonY = string6Position[i / 2] - buttonWidth / 2
                fingerButton.accessibilityIdentifier = "grayButton"
                //find mini and max button x
                if(buttonX < miniButtonX){
                    miniButtonX = buttonX
                }
                if(buttonX > maxButtonX){
                    maxButtonX = buttonX + buttonWidth
                }
            }
            
            fingerButton.addTarget(self, action: "pressEditFingerButton:", forControlEvents: UIControlEvents.TouchUpInside)
            let stringNumber = Int(self.specificTabSets[sender].index) / 100
            fingerButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            fingerButton.setImage(image, forState: UIControlState.Normal)
            fingerButton.alpha = 0
            fingerButton.tag = temp
            self.fingerPoint.append(fingerButton)// store all the finger point for exist tabs
            self.view.userInteractionEnabled = false
            UIView.animateWithDuration(0.3, animations: {
                fingerButton.alpha = 1
            })
            
            if i / 2 < stringNumber - 1 {
                self.completeStringView.addSubview(fingerButton)
            }
            self.view.userInteractionEnabled = true
        }
        let midButtonX:CGFloat = (miniButtonX + maxButtonX)/2.0
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut , .AllowUserInteraction], animations: {
            self.completeStringView.contentOffset.x = midButtonX - self.trueWidth/2>1 ? midButtonX - self.trueWidth/2 : 0
            }, completion: nil)
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
        self.view.userInteractionEnabled = false
        self.isJiggling = false
        UIView.animateWithDuration(0.1, animations: {
            for item in self.buttonOnSpecificScrollView {
                item.alpha = 0
            }
            for item in self.fingerPoint {
                item.alpha = 0
            }
            sender.alpha = 0
            }, completion:
            {   completed in
                sender.removeFromSuperview()
                self.removeObjectsOnSpecificTabsScrollView()
                self.removeObjectsOnCompleteStringView()
                self.currentBaseButton.tag = 400
                self.fingerPoint.removeAll(keepCapacity: false)
                self.addedNoteButtonOnCompleteView = false
                self.createEditFingerPoint(400)
                self.specificTabSets.removeAll(keepCapacity: false)
                self.addNewTab = false
                self.oldTagString4 = 0
                self.oldTagString5 = 0
            }
        )

        self.view.userInteractionEnabled = true
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
        
        musicSingleTapRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnMusicControlView:")
        self.musicControlView.addGestureRecognizer(musicSingleTapRecognizer)
        
        let musicPanRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panOnMusicControlView:")
        self.musicControlView.addGestureRecognizer(musicPanRecognizer)
    }
    
    func setUpTimeLabels() {
        let labelWidth: CGFloat = 40
        let wrapperHeight: CGFloat = 12
        let labelFontSize: CGFloat = 10
        let wrapperWidth: CGFloat = 80
        let wrapper = UIView(frame: CGRect(x: 0, y: musicControlView.frame.height / 2 - wrapperHeight, width: wrapperWidth, height: wrapperHeight))
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
        totalTimeLabel.text = TimeNumber(time: Float(theSong.getDuration())).toDisplayString()
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
    
    var isPanning: Bool = false
    var toTime: NSTimeInterval = 0
    // pan on music control view to change music time and progressblock time
    func panOnMusicControlView(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            self.isPanning = true
            self.timer.invalidate()
            self.timer = NSTimer()
        } else if sender.state == .Ended {
            self.isPanning = false
            startTime.setTime(Float(self.currentTime))
            if isDemoSong {
                self.avPlayer.currentTime = self.currentTime
                if self.avPlayer.playing {
                    startTimer()
                }
            } else {
                self.musicPlayer.currentPlaybackTime = self.currentTime
                if self.musicPlayer.playbackState == .Playing {
                    startTimer()
                }
            }
            
        } else if sender.state == .Changed {
            let translation = sender.translationInView(self.view)
            self.currentBaseButton.center = CGPointMake(self.currentBaseButton.center.x, self.currentBaseButton.center.y)
            sender.setTranslation(CGPointZero, inView: self.view)
            if self.currentTime >= 0 && self.currentTime <= self.duration {
                let timeChange = NSTimeInterval(-translation.x / 10)
                self.toTime = self.currentTime + timeChange
                if self.toTime < 0 {
                    self.toTime = 0
                } else if self.toTime > self.duration {
                    self.toTime = self.duration
                }
                self.currentTime = self.toTime
                startTime.setTime(Float(self.currentTime))
                let persent = CGFloat(self.currentTime) / CGFloat(self.duration)
                self.progressBlock.setProgress(persent)
                self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - persent * (CGFloat(theSong.getDuration() * Float(tabsEditorProgressWidthMultiplier)))
                
                self.currentTimeLabel.text = TimeNumber(time: Float(self.currentTime)).toDisplayString()
                // find the current tab according to the current time and make the current tab view to yellow
                self.findCurrentTabView()
            }
        }
    }
    
    func startTimer() {
        if !timer.valid {
            if(isDemoSong){
                self.avPlayer.rate = speed
            }else{
                self.musicPlayer.currentPlaybackRate = speed
            }
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1 / Double(stepPerSecond) / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        }
    }

    func startCountdown() {
        countDownStartSecond--
        countdownView.setNumber(countDownStartSecond)

        if countDownStartSecond <= 0 {
            musicControlView.addGestureRecognizer(musicSingleTapRecognizer)
            countdownTimer.invalidate()
            countdownView.hidden = true
            countDownStartSecond = 3
            if isDemoSong {
                self.avPlayer.play()
            } else {
                self.musicPlayer.play()
            }
            toTime = self.duration + 1
            startTimer()
            countdownTimer.invalidate()
            countdownTimer = NSTimer()
        }
    }


    // pause the music or restart it, and count down
    func singleTapOnMusicControlView(sender: UITapGestureRecognizer?=nil) {
        
        if self.isDemoSong ? avPlayer.playing : (musicPlayer.playbackState == .Playing) {
            self.isPlaying = false
            //animate down progress block
            self.view.userInteractionEnabled = false
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.progressBlock!.alpha = 0.5
                }, completion: nil)
            
            //pause music and stop timer
            if self.isDemoSong {
                avPlayer.pause()
            } else {
                musicPlayer.pause()
            }
            timer.invalidate()
            self.view.userInteractionEnabled = true
        } else {
            self.isPlaying = true
            //animate up progress block in 3 seconds, because of the the limited height we are not doing the jump animation
            self.view.userInteractionEnabled = false
            UIView.animateWithDuration(3.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.progressBlock!.alpha = 1.0
            }, completion: nil)
            
            //start counting down 3 seconds
            //disable tap gesture that inadvertly starts timer
            musicControlView.removeGestureRecognizer(musicSingleTapRecognizer)
            countdownView.hidden = false

            countdownView.setNumber(countDownStartSecond)
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
            self.view.userInteractionEnabled = true
        }
    }
    
    // string and fret position
    func createStringAndFretPosition() {
        // the postion for 6 string view
        let string6Height: CGFloat = 7 / 60 * self.trueHeight
        for var i = 0; i < 6; i++ {
            if i == 0 {
                self.string6Position.append(string6Height / 2)
            } else {
                self.string6Position.append(self.string6Position[i - 1] + string6Height)
            }
        }
        let fret6Width = self.trueWidth / 5
        for var i = 0; i < 26; i++ {
            self.string6FretPosition.append(CGFloat(i) * fret6Width)
        }
        // the position for 3 string view
        let string3Height: CGFloat = 11 / 60 * self.trueHeight
        for var i = 0; i < 3; i++ {
            if i == 0 {
                self.string3Position.append(string3Height / 2)
            } else {
                self.string3Position.append(self.string3Position[i - 1] + string3Height)
            }
        }
        let fret3Width = self.trueWidth / 5
        for var i = 0; i < 26; i++ {
            self.string3FretPosition.append(CGFloat(i) * fret3Width)
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
        let frame = CGRectMake(0.5 * self.trueWidth, 2 / 20 * self.trueHeight, tabsEditorProgressWidthMultiplier * CGFloat(theSong.getDuration()), 6 / 20 * self.trueHeight)
        self.progressBlock = SoundWaveView(frame: frame)
        if(theSong == nil){
            print("the song is empty")
        }
        if isDemoSong {
            let url: NSURL = theSong.getURL() as! NSURL
            self.avPlayer = try! AVAudioPlayer(contentsOfURL: url)
            self.duration = self.avPlayer.duration
            self.avPlayer.enableRate = true
            self.avPlayer.rate = 1.0
            self.avPlayer.volume = 1
        } else {
            self.recoverMode = MusicManager.sharedInstance.saveMusicPlayerState([theSong as! MPMediaItem])
            self.duration = (theSong as! MPMediaItem).playbackDuration
        }
        progressBlock.averageSampleBuffer = CoreDataManager.getSongWaveFormData(theSong)
        self.progressBlock.isForTabsEditor = true
        self.progressBlock.generateWaveforms()
        self.progressBlock!.alpha = 0.5

    }
    
    func update() {
        if startTime.toDecimalNumer() > Float(self.duration)-0.15 {
            if isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
            }
            timer.invalidate()
            timer = NSTimer()
            startTime.setTime(0)
            self.currentTime = 0
            self.progressBlock.alpha = 0.5
            if isDemoSong {
                avPlayer.currentTime = currentTime
            }else{
                 musicPlayer.currentPlaybackTime = currentTime
            }
        }

        if !isPanning {
            if startTime.toDecimalNumer() - Float(self.toTime) < (1 * speed ) && startTime.toDecimalNumer() - Float(self.toTime) >= 0 {
                startTime.addTime(Int(100 / stepPerSecond))
                self.currentTime = NSTimeInterval(startTime.toDecimalNumer()) - 0.01
            } else {
                let tempPlaytime = !isDemoSong ? self.musicPlayer.currentPlaybackTime : self.avPlayer.currentTime
                if !tempPlaytime.isNaN {
                    startTime.setTime(Float(tempPlaytime))
                    self.currentTime = NSTimeInterval(startTime.toDecimalNumer())
                } else {
                    startTime.addTime(Int(100 / stepPerSecond))
                    self.currentTime = NSTimeInterval(startTime.toDecimalNumer()) - 0.01
                }
            }
        }
        //
        //refresh current time label
        self.currentTimeLabel.text = TimeNumber(time: Float(currentTime)).toDisplayString()
        //refresh progress block
        let presentPosition = CGFloat(Float(currentTime) / Float(self.duration))
        self.progressBlock.setProgress(presentPosition)
        
        
        //MARK: progessBlock width
        self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier)
        
        self.findCurrentTabView()
        
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
        self.view.userInteractionEnabled = false
        self.collectionView.contentOffset = self.completeStringView.contentOffset
        UIView.animateWithDuration(0.3, animations: {
            self.specificTabsScrollView.alpha = 0
            self.tabNameTextField.alpha = 0
            self.musicControlView.alpha = 1
            self.progressBlock.alpha = 1
            self.completeStringView.alpha = 0
            self.completeStringView.frame = CGRectMake(0, 6 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
            self.collectionView.alpha = 1
            }, completion:  {
                completed in
                self.editView.removeFromSuperview()
        })
        
        self.tabNameTextField.text = ""
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
        self.oldTagString4 = 0
        self.oldTagString5 = 0
        self.isJiggling = false
        self.addedNoteButtonOnCompleteView = false
        self.currentBaseButton.tag = 400
        self.noteButtonOnCompeteScrollView.removeFromSuperview()
        self.fingerPoint.removeAll(keepCapacity: false)
        self.statusLabel.text = "Tabs Editor"
        self.addNewTab = false
        self.intoEditView = false
        self.tabFingerPointChanged = false
        self.currentNoteButton = UIButton()
        self.currentTabViewIndex = Int()
        self.removeObjectsOnCompleteStringView()
        self.removeObjectsOnSpecificTabsScrollView()

        self.view.userInteractionEnabled = true
    }
    
    // correctly put the tabs on music line
    func setMainViewTabPositionInRange(tab: NormalTabs, endIndex: Int) -> CGRect {
        let labelHeight = self.progressBlock.frame.height / 2 / 4
        let width = self.trueWidth / 20
        var frame: CGRect = CGRect()
        for var i = 0; i < endIndex; i++ {
            if self.compareTabs(self.allTabsOnMusicLine[i].tab, tab2: tab) {
                let tempFrame = CGRectMake(0 + CGFloat(self.currentTime / self.duration) * (self.progressBlock.frame.width), self.allTabsOnMusicLine[i].tabView.frame.origin.y, self.allTabsOnMusicLine[i].tabView.frame.width, self.allTabsOnMusicLine[i].tabView.frame.height)
                return tempFrame
            }
        }
        
        let numberOfUnrepeatedTab: Int = numberOfUnrepeatedTabOnMainView(endIndex)
        let tempSender = CGFloat(numberOfUnrepeatedTab % 4)
        
        let dynamicHeight = 0.5 * self.progressBlock.frame.height + labelHeight * tempSender
        frame = CGRectMake(0 + CGFloat(self.currentTime / self.duration) * (self.progressBlock.frame.width), dynamicHeight, width, labelHeight)
        return frame
    }

    // caluclate the tab on music line without repeat
    func numberOfUnrepeatedTabOnMainView(endIndex: Int) -> Int{
        var set = [String: Int]()
        for var i = 0; i < endIndex; i++ {
            if let val = set["\(self.allTabsOnMusicLine[i].tab.index) \(self.allTabsOnMusicLine[i].tab.name)"] {
                set["\(self.allTabsOnMusicLine[i].tab.index) \(self.allTabsOnMusicLine[i].tab.name)"] = val + 1
            }
            else{
                set["\(self.allTabsOnMusicLine[i].tab.index) \(self.allTabsOnMusicLine[i].tab.name)"] = 1
            }
        }
        return set.count
    }
    
    // press the note button to add the tab in music line
    func pressMainViewNoteButton(sender: UIButton) {
        var inserted: Bool = false
        let index = sender.tag
        let returnValue = addTabViewOnMusicControlView(index)
        for var i = 0; i < self.allTabsOnMusicLine.count - 1; i++ {
            if self.currentTime <= self.allTabsOnMusicLine[0].time {
                print("insert")
                self.allTabsOnMusicLine.insert(returnValue.1, atIndex: 0)
                inserted = true
                break
            } else if self.currentTime > self.allTabsOnMusicLine[i].time && self.currentTime <= self.allTabsOnMusicLine[i + 1].time {
                self.allTabsOnMusicLine.insert(returnValue.1, atIndex: i + 1)
                inserted = true
                break
            }
        }
        if !inserted {
            self.allTabsOnMusicLine.append(returnValue.1)
        }
        self.progressBlock.addSubview(returnValue.0)
//         else {
//            let fretNumber = Int(noteButtonWithTabArray[sender.tag].tab.index) - Int(noteButtonWithTabArray[sender.tag].tab.index) / 100 * 100
//            for var i = 0; i < self.mainViewDataArray.count; i++ {
//                if self.mainViewDataArray[i].fretNumber == fretNumber {
//                    for var j = 0; j < self.mainViewDataArray[i].noteButtonsWithTab.count; j++ {
//                        if self.compareTabs(self.mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: self.noteButtonWithTabArray[sender.tag].tab)  {
//                            self.mainViewDataArray[i].noteButtonsWithTab[j].noteButton.removeFromSuperview()
//                            self.mainViewDataArray[i].noteButtonsWithTab.removeAtIndex(j)
//                        }
//                    }
//                }
//            }
//            self.noteButtonWithTabArray.removeAtIndex(sender.tag)
//            for var i = 0; i < self.noteButtonWithTabArray.count; i++ {
//                self.noteButtonWithTabArray[i].noteButton.tag = i
//            }
//            self.changeRemoveButtonStatus(self.removeButton)
//        }
    }
    
    func addTabViewOnMusicControlView(sender: Int) -> (UIView, tabOnMusicLine) {
        let tempView: UIView = UIView()
        tempView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 0.6)
        tempView.layer.cornerRadius = 2
        var tempStruct: tabOnMusicLine = tabOnMusicLine()
        let name = self.noteButtonWithTabArray[sender].tab.name
        tempView.frame = setMainViewTabPositionInRange(self.noteButtonWithTabArray[sender].tab, endIndex: self.allTabsOnMusicLine.count)
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
        tempStruct.tab = self.noteButtonWithTabArray[sender].tab
        
        return (tempView, tempStruct)
    }
    
    //Mark: press the button on the top functions
    // back to the main view or back to root view
    func pressBackButton(sender: UIButton) {
        if self.intoEditView == true {
            self.view.userInteractionEnabled = false
            self.backToMainView()
            self.view.userInteractionEnabled = true
        } else {
            print("back to song view controller")
            tuningMenu.hidden = true
            self.progressBlock.hidden = true
            removeNotification()
            if self.isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
            }
            self.dismissViewControllerAnimated(true, completion: {
                completed in
                if self.isDemoSong {
                    self.songViewController.avPlayer.play()
                } else {
                    MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                    self.songViewController.player.play()
                }
            })
        }
    }
    
    func dismissAction() {
        self.view.userInteractionEnabled = false
        UIView.animateWithDuration(0.3, animations: {
            self.tuningMenu.frame = CGRect(x: -self.tuningMenu.frame.width, y: 0, width: self.tuningMenu.frame.width, height: self.tuningMenu.frame.height)
            
            }, completion:
            {
                completed in
                self.actionDismissLayerButton.hidden = true
            }
        )
        self.view.userInteractionEnabled = true
    }
    func pressTuningButton(sender: UIButton) {
        print("press tuning button")
        self.view.userInteractionEnabled = false
        self.backToMainView()
        self.view.userInteractionEnabled = true
        self.view.userInteractionEnabled = false
        self.actionDismissLayerButton.hidden = false // what is this button?
        UIView.animateWithDuration(0.3, animations: {
            self.tuningMenu.frame = CGRect(x: 0, y: 0, width: self.tuningMenu.frame.width, height: self.trueHeight)
            self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
            self.actionDismissLayerButton.alpha = 0.3
        })
    
        self.view.userInteractionEnabled = true
    }
    
    func pressResetButton(sender: UIButton) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to reset all tabs?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: {
            action in
            self.view.userInteractionEnabled = false
                UIView.animateWithDuration(0.3, animations: {
                    for var i = 0; i < self.allTabsOnMusicLine.count; i++ {
                        self.allTabsOnMusicLine[i].tabView.alpha = 0
                    }
                    }, completion: {
                        completed in
                        for var i = 0; i < self.allTabsOnMusicLine.count; i++ {
                            self.allTabsOnMusicLine[i].tabView.removeFromSuperview()
                        }
                        self.allTabsOnMusicLine.removeAll()
                })
            self.view.userInteractionEnabled = true
            if self.isDemoSong {
                self.avPlayer.currentTime = 0
            } else {
                self.musicPlayer.currentPlaybackTime = 0
            }
        }))

        self.presentViewController(alertController, animated: true, completion: nil)
    }


    func pressAddButton(sender: UIButton) {
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
        self.completeStringView.contentOffset = self.collectionView.contentOffset
        
        UIView.animateWithDuration(0.3, animations: {
            self.completeStringView.alpha = 1
            self.specificTabsScrollView.alpha = 1
            self.tabNameTextField.alpha = 1
            self.completeStringView.frame = CGRectMake(0, 3 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
            
            
        })
        self.createEditFingerPoint(400)
        self.view.userInteractionEnabled = true
    }

    var pressDoneButton:Bool = false
    func pressDoneButton(sender: UIButton) {
        pressDoneButton = false

        if self.intoEditView == true {
            
            if self.addNewTab == true {
                var addSuccessed: Bool = true
                if self.tabFingerPointChanged == true {
                    print("\(self.currentNoteButton.titleLabel?.text)")
                    let index = self.currentBaseButton.tag
                    let name: String = self.tabNameTextField.text!.replace(" ", replacement: "")
                    self.tabNameTextField.text! = name
                    var content: String = String()
                    let nameString = NSString(string: name)
                    let finallength = NSString(string: self.currentBaseButton.titleLabel!.text!).length
                    var tempCompareName:String = ""
                    if(nameString.length>=finallength){
                        tempCompareName = nameString.substringToIndex(finallength)
                    }else{
                        tempCompareName = name
                    }
                    
                    if name == "" || name.containsString(" ") || tempCompareName != self.currentBaseButton.titleLabel!.text! {
                        if self.specificTabsScrollView.subviews.count == 0 || (self.specificTabsScrollView.subviews.count == 1 && self.specificTabsScrollView.subviews[0].isKindOfClass(UILabel)) {
                            self.removeObjectsOnSpecificTabsScrollView()
                            let addBaseNoteLabel: UILabel = UILabel()
                            addBaseNoteLabel.frame = CGRectMake(0, 0, self.specificTabsScrollView.frame.size.width, self.specificTabsScrollView.frame.size.height)
                            addBaseNoteLabel.text = "Please input a valid chord name"
                            addBaseNoteLabel.font = UIFont.systemFontOfSize(17)
                            addBaseNoteLabel.backgroundColor = UIColor(white: 0.7, alpha: 0.3)
                            addBaseNoteLabel.textAlignment = .Center
                            addBaseNoteLabel.textColor = UIColor.whiteColor()
                            self.specificTabsScrollView.addSubview(addBaseNoteLabel)
                            self.shakeAnimationScrollView()
                            self.tabNameTextField.text = self.currentBaseButton.titleLabel?.text
                            self.tabNameTextField.becomeFirstResponder()
                            if(tempCompareName != self.currentBaseButton.titleLabel!.text! && !name.isEmpty){
                                self.AnimationStatusLabel("Not Contain BaseNote Name")
                            }else{
                                self.AnimationStatusLabel("Input Chord Name")
                            }
                            
                        }else if(tempCompareName != self.currentBaseButton.titleLabel!.text! && !name.isEmpty){
                            self.tabNameTextField.text = self.currentBaseButton.titleLabel?.text
                            shakeAnimationStatusLabel()
                            self.AnimationStatusLabel("Not Contain BaseNote Name")
                            self.tabNameTextField.becomeFirstResponder()
                        }else{
                            self.tabNameTextField.text = self.currentBaseButton.titleLabel?.text
                            shakeAnimationStatusLabel()
                            self.shakeAnimationScrollView()
                            self.AnimationStatusLabel("Choose Or Input Chord Name")
                            self.tabNameTextField.becomeFirstResponder()
                            pressDoneButton = true
                        }
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
                        print("This is the new tab's content: \(content)")
                        self.currentSelectedSpecificTab = NormalTabs()
                        if let compareExistTabs = self.tabsDataManager.getUniqueTab(index, name: name, content: content)?.tabs {
                            self.currentSelectedSpecificTab.tabs = compareExistTabs
                        } else {
                            let tempTabs: Tabs = self.tabsDataManager.addNewTabs(index, name: name, content: content)
                            self.currentSelectedSpecificTab.tabs = tempTabs
                        }
                        self.currentNoteButton.setTitle(name, forState: UIControlState.Normal)
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
                    if let _ = self.currentSelectedSpecificTab {
                        let fretNumber = Int(self.currentSelectedSpecificTab.index) - Int(self.currentSelectedSpecificTab.index) / 100 * 100
                        for var i = 0; i < self.mainViewDataArray.count; i++ {
                            if self.mainViewDataArray[i].fretNumber == fretNumber {
                                for var j = 0; j < self.mainViewDataArray[i].noteButtonsWithTab.count; j++ {
                                    if self.compareTabs(self.mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: self.currentSelectedSpecificTab) {
                                        let alertController = UIAlertController(title: "Warning", message: "This tab already exist on Main View", preferredStyle: UIAlertControllerStyle.Alert)
                                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: { action in
                                            self.collectionView.reloadData()
                                            self.statusLabel.text = "Tabs Editor"
                                            self.backToMainView()
                                        }))
                                        self.presentViewController(alertController, animated: true, completion: nil)
                                        addNew = false
                                    }
                                }
                            }
                        }
                    }
                    
                    if addNew == true{
                        self.addTabsToMainViewDataArray(self.currentSelectedSpecificTab)
                        self.reorganizeMainViewDataArray()
                        self.collectionView.reloadData()
                        
                        self.statusLabel.text = "Tabs Editor"
                        self.backToMainView()
                    }
                }

            } else {
                self.removeObjectsOnSpecificTabsScrollView()
                let addBaseNoteLabel: UILabel = UILabel()
                addBaseNoteLabel.frame = CGRectMake(0, 0, self.specificTabsScrollView.frame.size.width, self.specificTabsScrollView.frame.size.height)
                addBaseNoteLabel.text = "Please select a base note on the bottom three strings"
                addBaseNoteLabel.font = UIFont.systemFontOfSize(15)
                addBaseNoteLabel.backgroundColor = UIColor(white: 0.7, alpha: 0.3)
                addBaseNoteLabel.textAlignment = .Center
                addBaseNoteLabel.textColor = UIColor.whiteColor()
                self.specificTabsScrollView.addSubview(addBaseNoteLabel)
                self.shakeAnimationScrollView()
                self.AnimationStatusLabel("Choose Base Note")
            }
        } else {
            if isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
            }
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
            
            CoreDataManager.saveTabs(theSong, chords: allChords, tabs: allTabs, times: allTimes, tuning: tuningOfTheSong, capo: Int(capoStepper.value))
            
            self.songViewController.updateMusicData(theSong)
            
            tuningMenu.hidden = true
            self.progressBlock.hidden = true
            removeNotification()
            if self.isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
            }
            
            self.dismissViewControllerAnimated(true, completion: {
                completed in
                if self.isDemoSong {
                    self.songViewController.avPlayer.play()
                } else {
                    MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                    self.songViewController.player.play()
                }
            })
        }
        self.currentSelectedSpecificTab = nil
    }
    
    // add noteButtonWithTab to mainViewDataArray
    func addTabsToMainViewDataArray(sender: NormalTabs) {
        let tempButton: UIButton = UIButton()
        let buttonY = Int(sender.index) / 100 - 1
        let buttonWidth = self.trueWidth / 5 / 3
        let stringPosition = self.string3Position[buttonY - 3] - buttonWidth / 2
        let fretPosition = self.trueWidth / 5 / 2 - buttonWidth / 2
        tempButton.setTitle(sender.name, forState: UIControlState.Normal)
        tempButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        tempButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        tempButton.addTarget(self, action: "pressMainViewNoteButton:", forControlEvents: UIControlEvents.TouchUpInside)
        tempButton.layer.cornerRadius = 0.5 * buttonWidth
        tempButton.frame = CGRectMake(fretPosition, stringPosition, buttonWidth, buttonWidth)
        tempButton.addGestureRecognizer(self.longPressMainViewNoteButton)
        self.longPressMainViewNoteButton.addTarget(self, action: "startNormalJinggling:")
        let tempTab: NormalTabs = NormalTabs()
        tempTab.index = sender.index
        tempTab.name = sender.name
        tempTab.content = sender.content
        tempTab.isOriginal = sender.isOriginal
        
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
            if isDemoSong {
                self.avPlayer.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1
                 self.currentTime = self.avPlayer.currentTime
            } else {
                self.musicPlayer.currentPlaybackTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1
                self.currentTime = self.musicPlayer.currentPlaybackTime
            }
           
        } else if self.allTabsOnMusicLine.count == 1 {
            self.allTabsOnMusicLine[self.currentTabViewIndex].tabView.removeFromSuperview()
            self.allTabsOnMusicLine.removeAtIndex(self.currentTabViewIndex)
            self.currentTabViewIndex = 0
            if isDemoSong {
                self.avPlayer.currentTime = 0
            } else {
                self.musicPlayer.currentPlaybackTime = 0
            }
            self.currentTime = 0
        } else {
            if isDemoSong {
                self.avPlayer.currentTime = 0
            } else {
                self.musicPlayer.currentPlaybackTime = 0
            }
            self.currentTime = 0
        }
        update()

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
    
    let kAnimationRotateDeg: Double = 1.0
}


//MARK: ADD exist chord to tab editor view
extension TabsEditorViewController {
    // get tabs from coredata and show it on tab editor
    func getBasicNoteIndex(sender: [String]) -> Int {
        for var i = 0; i < 6; i++ {
            if sender[i] != "x" {
                let stringIndex = 6 - i
                let fretIndex = Int(sender[i])
                return stringIndex * 100 + fretIndex!
            }
        }
        return 0
    }
    
    func getUnrepeatTabs(sender: [Chord]) -> [NormalTabs] {
        var tabs: [NormalTabs] = [NormalTabs]()
        for item in sender {
            let tempNormalTabs = getNormalTabFromChord(item)
            var unrepeat: Bool = false
            for tab in tabs {
                if tab.tabs == tempNormalTabs.tabs {
                    unrepeat = true
                }
            }
            if unrepeat == false {
                tabs.append(tempNormalTabs)
            }
        }
        return tabs
    }
    
    func getNormalTabFromChord(sender: Chord) -> NormalTabs {
        let index = getBasicNoteIndex(sender.tab.contentArray)
        let name = sender.tab.name
        let content = sender.tab.content
        let tempNormalTabs = tabsDataManager.getUniqueTab(index, name: name, content: content)
        return tempNormalTabs!
    }
    
    func addTabsFromCoreDataToMainViewDataArray(sender: [Chord]) {
        let unrepeatTabs = self.getUnrepeatTabs(sender)
        //noteButtonWithTabArray.removeAll()
        for item in unrepeatTabs {
            self.addTabsToMainViewDataArray(item)
        }
        reorganizeMainViewDataArray()
        collectionView.reloadData()
    }
    
    func addTabsFromCoreDataToMusicControlView(sender: [Chord]) {
        for item in sender {
            print("\(item.time.toDecimalNumer())")
        }
        for item in sender {
            for var i = 0; i < noteButtonWithTabArray.count; i++ {
                let normalTab = getNormalTabFromChord(item)
                if normalTab.name == noteButtonWithTabArray[i].tab.name && normalTab.index == noteButtonWithTabArray[i].tab.index && normalTab.content == noteButtonWithTabArray[i].tab.content {
                    
                    self.currentTime = Double(item.time.toDecimalNumer())
                    print("\(currentTime)")
                    print("\(normalTab.name)")
                    //refresh progress block
                    let presentPosition = CGFloat(self.currentTime / self.duration)
                    self.progressBlock.setProgress(presentPosition)
                    self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier)
                    
                    let returnValue = addTabViewOnMusicControlView(i)
                    
                    self.allTabsOnMusicLine.append(returnValue.1)
                    self.progressBlock.addSubview(returnValue.0)
                }
            }
            
        }
        let current = NSTimeInterval(sender[sender.count - 1].time.toDecimalNumer()) + 0.1
        if isDemoSong {
            self.avPlayer.currentTime = current
        } else {
            self.musicPlayer.currentPlaybackTime = current
        }
        update()
    }

    
    // This is the main function to add the chord into editor view, I used this function in ViewDidLoad at line 203
    func addChordToEditorView(sender: Findable) {
        let tabs = CoreDataManager.getTabs(sender, fetchingLocalOnly: true)
        let chord: [Chord] = tabs.0
        let tuning: String = tabs.1
        let capo: Int = tabs.2
        
        if chord.count > 0 {
            addTabsFromCoreDataToMainViewDataArray(chord)
            addTabsFromCoreDataToMusicControlView(chord)
        }
    }
    

}

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
            if indexString >= 3 {
                let buttonFret = (self.string6FretPosition[indexFret] + self.string6FretPosition[indexFret + 1]) / 2
                let buttonString = self.string6Position[indexString]
                let buttonWidth = 9 / 60 * self.trueHeight
                self.currentBaseButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
                let noteButton = sender.view as! UIButton
                let oldNoteButtonTag = noteButton.tag
                noteButton.tag = (indexString + 1) * 100 + indexFret
                let tabName = self.tabsDataManager.fretsBoard[indexString][indexFret]
                noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
                self.tabNameTextField.text = ""
                self.fingerPoint[6 - (indexString + 1)].hidden = true
                self.currentNoteButton = noteButton
                self.currentBaseButton = noteButton
                self.noteButtonOnCompeteScrollView = noteButton
                self.addSpecificTabButton(noteButton.tag)
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
                let tabName = self.tabsDataManager.fretsBoard[indexString][indexFret]
                noteButton.setTitle("\(tabName)", forState: UIControlState.Normal)
                self.tabNameTextField.text = ""
                self.fingerPoint[6 - (indexString + 1)].hidden = true
                
                self.currentNoteButton = noteButton
                self.currentBaseButton = noteButton
                self.noteButtonOnCompeteScrollView = noteButton
                self.addSpecificTabButton(noteButton.tag)
                self.checkTheFingerPoint(noteButton.tag, oldTag: oldNoteButtonTag, oldTagString4: oldTagString4, oldTagString5: oldTagString5)
            } else {
                self.currentBaseButton.center = self.originalCenter
            }
            self.currentBaseButton.removeGestureRecognizer(jigglingLongPressGesture)
            self.jigglingChanged()
            if abs(location.x - currentBaseButton.center.x) > 0 || abs(location.y - currentBaseButton.center.y) > 0 || oldNoteButtonTag != currentBaseButton.tag {
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
                    self.fingerPoint[1].hidden = false
                    self.moveFingerPoint(oldTagString5, indexString: 4)
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
                    print(oldTagString4)
                    print(oldTagString5)
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
        for item in self.fingerPoint {
            print(item.tag)
            print(item.accessibilityIdentifier)
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
    func startNormalJinggling(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            self.isJiggling = true
            let tempView = sender.view!
            self.currentSelectedSpecificTab = self.specificTabSets[tempView.tag]
            var buttonWidth = tempView.frame.size.width
            let buttonHeight = tempView.frame.size.height
            let oldCornerRadius = tempView.layer.cornerRadius
            let center = sender.view?.center
            var originalX: CGFloat = 0
            var delta: CGFloat = 0
            // circle
            if oldCornerRadius == 0.5 * buttonWidth {
                buttonWidth = buttonWidth * 1.2
                tempView.frame = CGRectMake(tempView.frame.origin.x, tempView.frame.origin.y, buttonWidth, buttonWidth)
                tempView.layer.cornerRadius = 0.5 * buttonWidth
                delta = CGFloat((1 - sqrt(2.0))/2.0) * (tempView.frame.size.width/2.0) + (2/3)*(tempView.frame.size.width/4.0 - tempView.frame.size.width/6.0)
                tempView.center = center!
                originalX = tempView.center.x
                tempView.center.x = originalX - 1
                self.deleteChordOnMainView.addTarget(self, action: "deleteChordOnMainView:")
                tempView.addGestureRecognizer(self.deleteChordOnMainView)
            } else {
                delta = -(buttonHeight / 3 / 2 - buttonHeight / 15)
                self.deleteChordOnSpecificTabView.addTarget(self, action: "deleteChordOnSpecificTabView:")
                tempView.addGestureRecognizer(deleteChordOnSpecificTabView)
            }
            
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
                if oldCornerRadius == 0.5 * buttonWidth {
                    tempView.center.x = originalX + 1
                }
                tempView.transform = rightWobble
                }, completion: nil
            )
            

            self.longPressSpecificTabButton.enabled = false
            self.completeStringView.userInteractionEnabled = false
        }
    }
    
    func stopNormalJinggling(sender: UILongPressGestureRecognizer) {
        if self.isJiggling {
            self.completeStringView.userInteractionEnabled = true
            self.longPressSpecificTabButton.enabled = true
            let tempView = sender.view!
            tempView.removeGestureRecognizer(deleteChordOnSpecificTabView)
            deleteView.removeFromSuperview()
            tempView.layer.removeAllAnimations()
            tempView.transform = CGAffineTransformIdentity
            var buttonWidth = tempView.frame.size.width
            let buttonHeight = tempView.frame.size.height
            let oldCornerRadius = tempView.layer.cornerRadius
            let center = sender.view?.center
   
            // circle
            if oldCornerRadius == 0.5 * buttonWidth {
                buttonWidth = buttonWidth / 1.2
                tempView.center = CGPoint(x: center!.x - 1, y: center!.y)
                tempView.frame = CGRectMake(tempView.frame.origin.x, tempView.frame.origin.y, buttonWidth, buttonWidth)
                tempView.center = center!
                tempView.layer.cornerRadius = 0.5 * buttonWidth
            }
            self.isJiggling = false
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
            let alertController = UIAlertController(title: "Notice", message: "This operation will delete this chord you have already added to the song.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: {
                action in
                self.stopNormalJinggling(self.longPressSpecificTabButton)
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
        self.deleteChordOnMainViewWhenDeleteOnEditView(Int(self.currentSelectedSpecificTab.index), name: self.currentSelectedSpecificTab.name, content: self.currentSelectedSpecificTab.content)
        self.removeObjectsOnSpecificTabsScrollView()
        self.tabsDataManager.removeTabs(self.currentSelectedSpecificTab.tabs)
        self.tabNameTextField.text = self.currentNoteButton.titleLabel?.text
        self.stopNormalJinggling(self.longPressSpecificTabButton)
        self.addSpecificTabButton(self.currentBaseButton.tag)
    }
    
    func deleteChordOnMainView(sender: UITapGestureRecognizer) {
        self.stopNormalJinggling(longPressMainViewNoteButton)
        let index: Int = (sender.view?.tag)!
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
    
    // need to fix the reorganize function
    func reorganizeAllTabsOnMusicLine() {
        for var j = 0; j < self.allTabsOnMusicLine.count; j++ {
            for var i = 0; i < self.noteButtonWithTabArray.count; i++ {
                if self.noteButtonWithTabArray[i].tab.index == self.allTabsOnMusicLine[j].tab.index && self.noteButtonWithTabArray[i].tab.name == self.allTabsOnMusicLine[j].tab.name && self.noteButtonWithTabArray[i].tab.content == self.allTabsOnMusicLine[j].tab.content {
                    self.currentTime = self.allTabsOnMusicLine[j].time
                    self.allTabsOnMusicLine[j].tabView.frame = self.setMainViewTabPositionInRange(self.noteButtonWithTabArray[i].tab, endIndex: j + 1)
                }
                
            }
        }
    }
    

}


