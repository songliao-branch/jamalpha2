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
import YouTubePlayer

let kmovingMainNoteSliderHeight:CGFloat = 26

class TabsEditorViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var isCompleteStringViewScroll = false
    var originaloffset:CGFloat = -1
    var baseNoteLocation:CGFloat = -1
    
    // max, min pinch scale
    let maxScaleNumber: CGFloat = 20
    let minScaleNumber: CGFloat = 5
    
    var fretNumberOnFullStringView: UIView!

    var string3BackgroundImage: [String] = ["iPhone5_fret0", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret", "iPhone5_fret"]
    
    var playButtonImageView: UIImageView!
    
    var doubleArrowView: CustomizedView!
    var scrollTimer: NSTimer?
    
    //for doublearror adjust position
    var doubleViewPositionX:CGFloat = 0.0
    

    // delete jiggling gesture 
    var deleteChordOnMainView: [UIButton:UITapGestureRecognizer] = [UIButton:UITapGestureRecognizer]()
    let deleteChordOnSpecificTabView: UITapGestureRecognizer = UITapGestureRecognizer()
    var longPressSpecificTabButton: [Int:UILongPressGestureRecognizer] = [Int:UILongPressGestureRecognizer]()
    var longPressMainViewNoteButton: [UIButton:UILongPressGestureRecognizer] = [UIButton:UILongPressGestureRecognizer]()
    let prepareMoveSwipeUpGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    let prepareMoveSwipeDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    let checkPanGesture:UIPanGestureRecognizer = UIPanGestureRecognizer()
    let temptapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
    
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
    var deleteViewArray:[UIButton:UIImageView] = [UIButton:UIImageView]()
    var scrollingTimer: NSTimer!
    var startScrolling: Bool = false
    var stopEdgeStartTime:Double = -1
    var rightEdgeTimer:NSTimer?
    var leftEdgeTimer:NSTimer?
    
    var stepPerSecond: Float = 100
    var startTime: TimeNumber = TimeNumber(second: 0, decimal: 0)
    var speed: Float = 1
    
    var songViewController: SongViewController?
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
    var tabsEditorProgressWidthMultiplier: CGFloat = 10
    var progressBlock: UIView!
    var theSong: Findable!
    var currentTime: NSTimeInterval = NSTimeInterval()
    var avPlayer: AVAudioPlayer!
    var musicPlayer: MPMusicPlayerController!
    var isDemoSong = false
    var duration: NSTimeInterval = NSTimeInterval()
    var musicControlView: UIView = UIView()
    
    // musicPlayer playing mode for recover queue
    var recoverMode: (MPMusicRepeatMode, MPMusicShuffleMode, NSTimeInterval)!
    
//    var musicSingleTapRecognizer: UITapGestureRecognizer!
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
    var string3FretChangeingPosition: [Int : CGFloat] = [Int : CGFloat]()
    
    // core data functions
    
    // objects on view which need to be changed in different places
    var statusLabel: UILabel = UILabel()
    var completeImageView: UIImageView = UIImageView()
    var noteButtonOnCompeteScrollView: UIButton = UIButton()
    var buttonOnSpecificScrollView: [UIButton] = [UIButton]()
    var fingerPoint: [UIButton] = [UIButton]()
    var currentNoteButton: UIButton = UIButton()
    var currentTimeLabel: UILabel = UILabel()
    var totalTimeLabel: UILabel = UILabel()

    var string6View: [UIView] = [UIView]()
    var currentTabViewIndex: Int = -1
    var currentBaseButton: UIButton = UIButton()
    
    // music timer
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
    
    //an attribtue corresponding to the visible attribute of tabsSet
    var isPublic = true
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
    
    //MARK: tutorials
    var tutorialOverlay: UIView!
    var videoPlayerView: YouTubePlayerView!
    
    var isShowDiscardAlert:Bool = false
    
    
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
    
    var backgroundImage: UIImageView = UIImageView()
    
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
        
        backgroundImage.frame = CGRectMake(0, 0, self.trueWidth, self.trueWidth)
        let size: CGSize = CGSizeMake(self.trueWidth, self.trueWidth)
        var image:UIImage!
        if let artwork = theSong.getArtWork() {
            image = artwork.imageWithSize(size)
        } else {
            //TODO: add a placeholder album cover
            image = UIImage(named: "liwengbg")
        }
        backgroundImage.image = image != nil ? image : songViewController?.backgroundImage
        
        let blurredImage:UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        self.view.addSubview(backgroundImage)

        self.currentBaseButton.tag = 400
        
        // add the default tab data into coredata if it doesn't exist
        TabsDataManager.addDefaultData()
        
        // initial the edit view
        self.editView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 18 / 20 * self.trueHeight)
        
        // add objects on main view and edit view
        self.addObjectsOnMainView()
        self.createStringAndFretPosition()
        // initial main view tab data array
        self.initialMainViewDataArray(0)
        self.addObjectsOnEditView()
        self.addMusicControlView()
        
        self.setUpCountdownView()

        // initial collection view
        self.initCollectionView()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        setUpTuningControlMenu()

        PlayChordsManager.sharedInstance.fret0Midi = PlayChordsManager.sharedInstance.standardFret0Midi
        PlayChordsManager.sharedInstance.changeVolumn(1.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        // MARK: add exist chord to tab editor view
        self.addChordToEditorView(theSong)
        
        if NSUserDefaults.standardUserDefaults().boolForKey(kShowTabsEditorTutorial) {
            setUpTutorial()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        PlayChordsManager.sharedInstance.deinitialSoundBank()
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
            //self.playButtonImageView.hidden = true
            playPauseButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
            if !self.intoEditView{
                self.progressBlock.alpha = 1
            }
        } else if musicPlayer.playbackState == .Paused {
            //self.playButtonImageView.hidden = false
            playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
            isPlaying = false
            timer.invalidate()
            timer = NSTimer()
        }
    }
    
    func currentSongChanged(sender: NSNotification){
        if musicPlayer.playbackState == .Playing && isPlaying{
            musicPlayer.pause()
            //self.playButtonImageView.hidden = false
            playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
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
        PlayChordsManager.sharedInstance.changeCapo(Int(stepper.value))
        updateCollectionView(Int(stepper.value))
        
    }
    
    func stepUpPressed(button: UIButton) {
        let currentNote = tunings[button.tag]
        if PlayChordsManager.sharedInstance.tuningString(button.tag + 1, up: true) {
            currentNote.stepUp()
            tuningValueLabels[button.tag].text = currentNote.toDisplayString()
            let center = tuningValueLabels[button.tag].center
            tuningValueLabels[button.tag].sizeToFit()
            tuningValueLabels[button.tag].center = center
        }
    }
    
    func stepDownPressed(button: UIButton) {
        let currentNote = tunings[button.tag]
        if PlayChordsManager.sharedInstance.tuningString(button.tag + 1, up: false) {
            currentNote.stepDown()
            tuningValueLabels[button.tag].text = currentNote.toDisplayString()
            let center = tuningValueLabels[button.tag].center
            tuningValueLabels[button.tag].sizeToFit()
             tuningValueLabels[button.tag].center = center
        }
    }
    
    // MARK: Main view data array, to store the tabs added on main view.
    func initialMainViewDataArray(sender: Int) {
        for i in sender..<25 {
            let temp: mainViewData = mainViewData()
            temp.fretNumber = i
            let tempButton: [noteButtonWithTab] = [noteButtonWithTab]()
            temp.noteButtonsWithTab = tempButton
            self.mainViewDataArray.append(temp)
        }
    }
    
    // MARK: collection view functions, include required functions and move cell functions
    var tapGesture:UITapGestureRecognizer!
    
    // buttons
    var tuningButton: UIButton = UIButton()
    var resetButton: UIButton = UIButton()
    var playPauseButton: UIButton = UIButton()
    var addButton: UIButton = UIButton()
    let backButton: UIButton = UIButton()
    var privacyButton: UIButton = UIButton()
    let doneButton: UIButton = UIButton()
    let menuView: UIView = UIView()
    
    func addObjectsOnMainView() {
        // view
        let musicView: UIView = UIView()

       
        menuView.frame = CGRectMake(-1, 0, self.trueWidth+1, 2 / 20 * self.trueHeight)
        //menuView.backgroundColor = UIColor.clearColor()//UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        menuView.backgroundColor = UIColor(patternImage: UIImage(named: "topMenuBar")!)

        self.view.addSubview(menuView)
        
        musicView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 6 / 20 * self.trueHeight)
        musicView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(musicView)
        
        self.fretBoardView.frame = CGRectMake(0, 8 / 20 * self.trueHeight, self.trueWidth, 11 / 20 * self.trueHeight)
        self.fretBoardView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(fretBoardView)
        
        let buttonWidth:CGFloat = 2.5 / 20 * self.trueHeight
        let buttonSpace = (0.5 * self.trueWidth - 3.5 * buttonWidth - 0.5 / 31.0 * self.trueWidth) / 3.0
        let buttonEdge: CGFloat = CGFloat(0.2 / 20) * self.trueHeight
        
        backButton.frame = CGRectMake(0.5 / 31 * self.trueWidth+1, 0, buttonWidth, buttonWidth)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setImage(UIImage(named: "backButton"), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * self.trueHeight, buttonEdge + 0.5 / 20 * self.trueHeight, buttonEdge + 0.25 / 20 * self.trueHeight)//CGFloat(0.6 / 20) * self.trueHeight
        menuView.addSubview(backButton)
        
        statusLabel.frame = CGRectMake(1 * buttonWidth + 1 * buttonSpace + 0.5 / 31 * self.trueWidth+1, 0, 4 * (buttonWidth + buttonSpace), 2 / 20 * self.trueHeight)
        self.statusLabel.text = "Tabs Editor"
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.hidden = true
        statusLabel.textAlignment = NSTextAlignment.Center
        menuView.addSubview(statusLabel)
        
        addButton.frame = CGRectMake(1 * buttonWidth + 1 * buttonSpace + 0.5 / 31 * self.trueWidth+1, 0, buttonWidth, buttonWidth)
        addButton.addTarget(self, action: "pressAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.setImage(UIImage(named: "addButton"), forState: UIControlState.Normal)
        addButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * self.trueHeight, buttonEdge + 0.5 / 20 * self.trueHeight, buttonEdge + 0.25 / 20 * self.trueHeight)
        menuView.addSubview(addButton)
        
        resetButton.frame = CGRectMake(2 * buttonWidth + 2 * buttonSpace + 0.5 / 31 * self.trueWidth+1, 0, buttonWidth, buttonWidth)
        resetButton.addTarget(self, action: "pressResetButton:", forControlEvents: UIControlEvents.TouchUpInside)
        resetButton.setImage(UIImage(named: "trashButton"), forState: UIControlState.Normal)
        resetButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * self.trueHeight, buttonEdge + 0.5 / 20 * self.trueHeight, buttonEdge + 0.25 / 20 * self.trueHeight)
        menuView.addSubview(resetButton)
        
        playPauseButton.frame = CGRectMake(3 * buttonWidth + 3 * buttonSpace + 0.5 / 31 * self.trueWidth+1, 0, buttonWidth, buttonWidth)
        playPauseButton.addTarget(self, action: "singleTapOnMusicControlView:", forControlEvents: UIControlEvents.TouchUpInside)
        playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
        playPauseButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * self.trueHeight, buttonEdge + 0.5 / 20 * self.trueHeight, buttonEdge + 0.25 / 20 * self.trueHeight)
        menuView.addSubview(playPauseButton)
        
        tuningButton.frame = CGRectMake(4 * buttonWidth + 4 * buttonSpace + 0.5 / 31 * self.trueWidth+1, 0, buttonWidth, buttonWidth)
        tuningButton.addTarget(self, action: "pressTuningButton:", forControlEvents: UIControlEvents.TouchUpInside)
        tuningButton.setImage(UIImage(named: "tuningButton"), forState: UIControlState.Normal)
        tuningButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * self.trueHeight, buttonEdge + 0.5 / 20 * self.trueHeight, buttonEdge + 0.25 / 20 * self.trueHeight)
        menuView.addSubview(tuningButton)
        
        
        let privacyDoneButtonContainer: UIImageView = UIImageView()
        privacyDoneButtonContainer.frame = CGRectMake(30.5 / 31 * self.trueWidth - 2.5 * 1.6 / 20 * self.trueHeight+1, 0.2 / 20 * self.trueHeight, 2.5 * 1.6 / 20 * self.trueHeight, 1.6 / 20 * self.trueHeight)
        privacyDoneButtonContainer.image = UIImage(named: "frame")
        privacyDoneButtonContainer.userInteractionEnabled = true
        
        menuView.addSubview(privacyDoneButtonContainer)
        
        //TODO: set button from the visible attribute itself
        privacyButton.frame = CGRectMake(30.5 / 31 * self.trueWidth - 3 * 1.6 / 20 * self.trueHeight+1, 0, buttonWidth, buttonWidth)
        privacyButton.backgroundColor = UIColor.clearColor()
        privacyButton.setImage(UIImage(named: "globeIcon"), forState: UIControlState.Normal)
        privacyButton.addTarget(self, action: "privacyButtonPressed:", forControlEvents: .TouchUpInside)
        privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.43 / 20 * self.trueHeight, 1.1 / 20 * self.trueHeight, 0.93 / 20 * self.trueHeight, 0.2 / 20 * self.trueHeight)
        menuView.addSubview(privacyButton)
        
        doneButton.frame = CGRectMake(30.5 / 31 * self.trueWidth - 1.5 * 1.6 / 20 * self.trueHeight+1, 0, 1.2 * buttonWidth, buttonWidth)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setImage(UIImage(named: "saveText"), forState: UIControlState.Normal)
        doneButton.imageEdgeInsets = UIEdgeInsetsMake(0.4 / 20 * self.trueHeight, 0.1 / 20 * self.trueHeight, 0.7 / 20 * self.trueHeight, 0.6 / 20 * self.trueHeight)
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
        self.tabNameTextField.returnKeyType = .Done
        self.tabNameTextField.textAlignment = .Center
        self.editView.addSubview(tabNameTextField)
        self.tabNameTextField.addTarget(self, action: "textFieldTextChanged:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.completeStringView.frame = CGRectMake(0, 6 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeStringView.contentSize = CGSizeMake(5 * self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeStringView.backgroundColor = UIColor.clearColor()
        
        self.completeImageView.frame = CGRectMake(0, 0, 5 * self.trueWidth, 15 / 20 * self.trueHeight)
        self.completeImageView.image = UIImage(named: "iPhone5_fullFretboard")
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // hide the keyboard
    var isTextChanged = false
    func tapOnEditView(sender: UITapGestureRecognizer) {
        self.tabNameTextField.resignFirstResponder()
        stopJiggling()
        stopSpecificJiggling()
        stopMainViewJiggling()
    }
    
    func stopSpecificJiggling(){
        if(longPressSpecificTabButton.count == 0){
            return
        }
        for button in buttonOnSpecificScrollView {
            if(button.accessibilityIdentifier == "isNotOriginal"){
                self.stopNormalJinggling(self.longPressSpecificTabButton[button.tag]!)
            }
        }
    }
    
    //textfeild delege
    var tempTapView:UIView?
    func textFieldDidBeginEditing(textField: UITextField) {
        self.tabFingerPointChanged = true
        tempTapView = UIView()
        tempTapView!.frame = self.completeStringView.frame
        tempTapView!.backgroundColor = UIColor.clearColor()
        self.editView.addSubview(self.tempTapView!)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tempTapView!.removeFromSuperview()
        tempTapView = nil
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
    func addNoteButton(indexFret: Int, indexString: Int, originalPosition:CGPoint?=nil) {
        
        let noteButton: UIButton = UIButton()
        let buttonFret = (self.string6FretPosition[indexFret] + self.string6FretPosition[indexFret + 1]) / 2
        let buttonString = self.string6Position[indexString]
        let buttonWidth = 7 / 60 * self.trueHeight
        
        var original:CGPoint = CGPointZero
        if(originalPosition != nil){
            original.x = originalPosition!.x
            original.y = 6 / 20 * self.trueHeight - originalPosition!.y - buttonWidth / 2
        }else{
            original.x = buttonFret
            original.y = buttonString
        }
        
        noteButton.frame = CGRectMake(original.x - buttonWidth / 2, original.y - buttonWidth / 2, buttonWidth, buttonWidth)
        noteButton.layer.cornerRadius = 0.5 * buttonWidth
        noteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        noteButton.backgroundColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.8)
        noteButton.tag = (indexString + 1) * 100 + indexFret
        noteButton.addTarget(self, action: "pressNoteButton:", forControlEvents: UIControlEvents.TouchUpInside)
        let tabName = TabsDataManager.fretsBoard[indexString][indexFret]
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
            let duration:NSTimeInterval = NSTimeInterval(sqrt(2.0*(buttonString - original.y)/9.8)/3)
            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: CGFloat(0.6/duration), initialSpringVelocity:CGFloat(0.6/duration), options: [.CurveEaseInOut,.AllowUserInteraction], animations: {
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
        for i in(6 - indexString)...5 {
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
            for index in 0..<self.string6FretPosition.count {
                if location.x < self.string6FretPosition[self.string6FretPosition.count - 2] {
                    if location.x > self.string6FretPosition[index] && location.x < self.string6FretPosition[index + 1] {
                        indexFret = index
                        break
                    }
                }
            }
            for index in 0..<6 {
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
            PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
        } else {
            self.stopJiggling()
            stopSpecificJiggling()
        }
        
        self.view.userInteractionEnabled = true
    }
    
    // move finger point when tap on 6 string view
    func moveFingerPoint(indexFret: Int, indexString: Int) {
        self.view.userInteractionEnabled = false
            let buttonWidth: CGFloat = 5 / 60 * self.trueHeight
            let buttonX = (string6FretPosition[indexFret] + string6FretPosition[indexFret + 1]) / 2 - buttonWidth / 2
            let buttonY = string6Position[indexString] - buttonWidth / 2
            self.fingerPoint[5 - indexString].frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            //self.fingerPoint[5 - indexString].alpha = 0
            self.fingerPoint[5 - indexString].tag = indexFret
            self.fingerPoint[5 - indexString].hidden = false
            UIView.animateWithDuration(0.3, animations: {
                self.fingerPoint[5 - indexString].alpha = 1
            })
            self.view.userInteractionEnabled = true
            self.tabFingerPointChanged = true
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
        self.specificTabSets = TabsDataManager.getTabsSets(index)
        let buttonHeight: CGFloat = 2 / 20 * self.trueHeight
        let buttonWidth: CGFloat = 4 / 20 * self.trueHeight
        // change specific tab button scrollview content frame
        let scrollviewWidth = (buttonWidth + 0.5 / 20 * self.trueWidth) * CGFloat(5) + 0.5 / 20 * self.trueWidth
        self.specificTabsScrollView.contentSize = CGSizeMake(scrollviewWidth, 2.5 / 20 * self.trueHeight)
        
        if self.specificTabSets.count > 5 {
            let tempScrollviewWidth = (buttonWidth + 0.6/20 * self.trueWidth) * CGFloat(self.specificTabSets.count)
            self.specificTabsScrollView.contentSize = CGSizeMake(tempScrollviewWidth, 2.5 / 20 * self.trueHeight)
        }
        
        self.specificTabsScrollView.contentOffset = CGPointZero
        UIView.animateWithDuration(0.1, animations: {
            for item in self.buttonOnSpecificScrollView {
                item.alpha = 0
            }
            }, completion:
            {   completed in
                self.buttonOnSpecificScrollView.removeAll()
                self.removeObjectsOnSpecificTabsScrollView()
                self.longPressSpecificTabButton.removeAll()
                for i in 0..<self.specificTabSets.count {
                    if self.specificTabSets[i].content != "" {
                        let specificButton: UIButton = UIButton()
                        specificButton.frame = CGRectMake(0.5 / 20 * self.trueWidth * CGFloat(i + 1) + buttonWidth * CGFloat(i), 0.25 / 20 * self.trueHeight, buttonWidth, buttonHeight)
                        specificButton.backgroundColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.8)
                        specificButton.layer.cornerRadius = 4
                        specificButton.addTarget(self, action: "pressSpecificTabButton:", forControlEvents:UIControlEvents.TouchUpInside)
                        specificButton.setTitle(self.specificTabSets[i].name, forState: UIControlState.Normal)
                        specificButton.tag = i
                        specificButton.alpha = 0
                        specificButton.transform = CGAffineTransformMakeScale(0.6,0.6)
                        if self.specificTabSets[i].isOriginal == true {
                            specificButton.accessibilityIdentifier = "isOriginal"
                            specificButton.layer.shadowOpacity = 1
                            specificButton.layer.shadowRadius = 4
                            specificButton.layer.shadowOffset = CGSize(width: 0, height: 0)
                            specificButton.layer.shadowColor = UIColor(red: 94/255, green: 38/255, blue: 18/255, alpha: 1).CGColor
                            specificButton.layer.shadowPath = UIBezierPath(rect: specificButton.layer.bounds).CGPath
                        } else {
                            specificButton.accessibilityIdentifier = "isNotOriginal"
                            let longPress = UILongPressGestureRecognizer(target: self, action: "startNormalJinggling:")
                            longPress.minimumPressDuration = 0.5
                            specificButton.addGestureRecognizer(longPress)
                            self.longPressSpecificTabButton[specificButton.tag] = longPress
                           
                            specificButton.backgroundColor = UIColor.silverGray().colorWithAlphaComponent(0.8)
                            specificButton.layer.shadowOpacity = 1
                            specificButton.layer.shadowRadius = 4
                            specificButton.layer.shadowOffset = CGSize(width: 0, height: 0)
                            specificButton.layer.shadowColor = UIColor.blackColor().CGColor
                            specificButton.layer.shadowPath = UIBezierPath(rect: specificButton.layer.bounds).CGPath
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
                    self.statusLabel.text = "Choose Chord Or Input Name"
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
        self.view.userInteractionEnabled = false
        PlayChordsManager.sharedInstance.playChordArpeggio(self.currentSelectedSpecificTab.content, delay: 0.04, completion: {
            complete in
            self.view.userInteractionEnabled = true
        })
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
            fingerButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
            fingerButton.setImage(image, forState: UIControlState.Normal)
            fingerButton.alpha = 0
            fingerButton.tag = temp
            self.fingerPoint.append(fingerButton)// store all the finger point for exist tabs
            self.view.userInteractionEnabled = false
            UIView.animateWithDuration(0.3, animations: {
                fingerButton.alpha = 1
            })
            
            if i / 2 < 6 {
                self.completeStringView.addSubview(fingerButton)
            }
            self.view.userInteractionEnabled = true
        }
        
        let stringNumber = Int(self.specificTabSets[sender].index) / 100
        for i in 0...(6 - stringNumber) {
            self.fingerPoint[i].hidden = true
        }
        
        var midButtonX:CGFloat = 0
        if(maxButtonX - miniButtonX <= trueWidth){
           midButtonX = (miniButtonX + maxButtonX)/2.0
            UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut , .AllowUserInteraction], animations: {
                self.completeStringView.contentOffset.x = midButtonX - self.trueWidth/2>1 ? midButtonX - self.trueWidth/2 : 0
                }, completion: nil)
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
    
    let previousButton: UIButton = UIButton()
    // music control view, include progressblock, timelabel, previous button, pan gesture, update, count down
    func addMusicControlView() {
        self.musicControlView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 6 / 20 * self.trueHeight)
        self.view.addSubview(musicControlView)
        
        
        
        previousButton.frame = CGRectMake(28 / 31 * self.trueWidth, 20, 3 / 31 * self.trueWidth, 6 / 20 * self.trueHeight-20)
        previousButton.imageEdgeInsets = UIEdgeInsetsMake(3 / 20 * self.trueHeight - 3 / 31 * self.trueWidth - 10, 0, 3 / 20 * self.trueHeight - 3 / 31 * self.trueWidth - 10, 0)
        previousButton.userInteractionEnabled = true
        previousButton.addTarget(self, action: "pressPreviousButton:", forControlEvents: UIControlEvents.TouchUpInside)
        previousButton.setImage(UIImage(named: "backspace"), forState: UIControlState.Normal)
        self.musicControlView.addSubview(previousButton)

        let musicPinchRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchOnMusicControlView:")
        self.musicControlView.addGestureRecognizer(musicPinchRecognizer)
        
        
        let musicPanRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panOnMusicControlView:")
        self.musicControlView.addGestureRecognizer(musicPanRecognizer)
        self.setUpTimeLabels()
        self.setUpPinchLable()
        
        backgroundView.frame = CGRectMake(0, 2 / 20 * self.trueHeight, self.trueWidth, 20)
        backgroundView.backgroundColor = UIColor(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
        
        let indicatorView: UIView = UIView()
        indicatorView.frame = CGRectMake(0.5 * self.trueWidth - 10, 10, 20, 6 / 20 * self.trueHeight - 10)
        indicatorView.backgroundColor = UIColor.clearColor()
        
        let indicator: UIImageView = UIImageView()
        indicator.alpha = 0.9
        indicator.frame = CGRectMake(0, 0, 20, 20)
        indicator.image = UIImage(named: "pointer")
        indicatorView.addSubview(indicator)
        let line: UIView = UIView()
        line.frame = CGRectMake(9, 20, 2, 6 / 20 * self.trueHeight - 30)
        line.backgroundColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.9)
        indicatorView.insertSubview(line, belowSubview: indicator)
        
        self.view.insertSubview(backgroundView, belowSubview: progressBlock)
        topLineView = UIView()
        topLineView.backgroundColor = UIColor.clearColor()
        self.progressBlock.addSubview(topLineView)
        self.musicControlView.addSubview(indicatorView)
        
        setUpTopLine()
    }
    
    var endScaleNumber: CGFloat = 10
    var beginScale:CGFloat!
    func pinchOnMusicControlView(sender: UIPinchGestureRecognizer) {
        if sender.numberOfTouches() == 2 {
            if sender.state == .Began {
                beginScale = sender.scale
                endScaleNumber = tabsEditorProgressWidthMultiplier
                currentScale.text = NSString(format: "%.1f", self.tabsEditorProgressWidthMultiplier) as String
                pinchWrapper.hidden = false
            } else if sender.state == .Changed {
                let scaleChange = sender.scale - beginScale
                
                tabsEditorProgressWidthMultiplier = endScaleNumber + (endScaleNumber*scaleChange)
                if(tabsEditorProgressWidthMultiplier > maxScaleNumber){
                    tabsEditorProgressWidthMultiplier = maxScaleNumber
                }else if (tabsEditorProgressWidthMultiplier < minScaleNumber) {
                    tabsEditorProgressWidthMultiplier = minScaleNumber
                }
                currentScale.text = NSString(format: "%.1f", self.tabsEditorProgressWidthMultiplier) as String
                updateFramePosition()
            }
        }
        if (sender.state == .Ended || sender.state == .Cancelled){
            endScaleNumber = tabsEditorProgressWidthMultiplier
            pinchWrapper.hidden = true
        }
    }
    
    // 1 second = 10 px
    func updateFramePosition() {
        for item in topLineView.subviews {
            item.removeFromSuperview()
        }
        for item in allTabsOnMusicLine {
            let presentPosition = CGFloat(Float(item.time) / Float(self.duration))
            item.tabView.frame.origin = CGPointMake(presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier), item.tabView.frame.origin.y)
        }
        setUpTopLine()
        
    }
    
    var topLineView: UIView!
    
    // 1 second = 10 px
    let backgroundView: UIView = UIView()
    
    func setUpTopLine() {
        let presentPosition = CGFloat(Float(currentTime) / Float(self.duration))
        progressBlock.frame = CGRectMake((0.5) * self.trueWidth - presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier), progressBlock.frame.origin.y, tabsEditorProgressWidthMultiplier * CGFloat(theSong.getDuration()), progressBlock.frame.size.height)
        
        topLineView.frame = CGRectMake(0, 0, tabsEditorProgressWidthMultiplier * CGFloat(theSong.getDuration()), 20)
        var numberOfLine: Int = Int(CGFloat(theSong.getDuration()) / 10 * 2)
        var lineSpace: CGFloat = 5
        if tabsEditorProgressWidthMultiplier >= 15 {
           numberOfLine = Int(CGFloat(theSong.getDuration()) / 10 * 4)
            lineSpace = 2.5
        }
        if numberOfLine % 2 == 0 {
            numberOfLine += 3
        } else {
            numberOfLine += 2
        }
        for i in 0..<numberOfLine {
            var frame: CGRect!
            if i % 2 == 0 {
                frame = CGRectMake(CGFloat(i) * lineSpace * tabsEditorProgressWidthMultiplier, 11, 2, 9)
                let timeLabel: UILabel = UILabel()
                timeLabel.frame = CGRectMake(CGFloat(i) * lineSpace * tabsEditorProgressWidthMultiplier - 15, 0, 30, 10)
                var min: Int = (i * 5) / 60
                var sec: Int = (i * 5) % 60
                if lineSpace >= 2.4 && lineSpace <= 2.6 {
                    min = (i * 5) / 2 / 60
                    sec = ((i * 5) / 2) % 60
                }
                if min < 10 {
                    if sec < 10 {
                        timeLabel.text = "0\(min):0\(sec)"
                    } else {
                        timeLabel.text = "0\(min):\(sec)"
                    }
                } else {
                    if sec < 10 {
                        timeLabel.text = "\(min):0\(sec)"
                    } else {
                        timeLabel.text = "\(min):\(sec)"
                    }
                }
                timeLabel.font = UIFont.systemFontOfSize(9)
                timeLabel.textColor = UIColor(red: 171 / 255, green: 171 / 255, blue: 171 / 255, alpha: 1)
                timeLabel.textAlignment = .Center
                topLineView.addSubview(timeLabel)
            } else {
                frame = CGRectMake(CGFloat(i) * lineSpace * tabsEditorProgressWidthMultiplier, 15, 1, 5)
            }
            let tempView: UIView = UIView(frame: frame)
            tempView.backgroundColor = UIColor(red: 171 / 255, green: 171 / 255, blue: 171 / 255, alpha: 1)
            topLineView.addSubview(tempView)
        }
    }
    
    var wrapper: UIView!
    func setUpTimeLabels() {
        let labelWidth: CGFloat = 40
        let wrapperHeight: CGFloat = 12
        let labelFontSize: CGFloat = 10
        let wrapperWidth: CGFloat = 90
        wrapper = UIView(frame: CGRect(x: 0.5 * trueWidth - 45, y: 20, width: wrapperWidth, height: wrapperHeight))
        wrapper.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.3)
        wrapper.layer.cornerRadius = wrapperHeight / 5
        musicControlView.addSubview(wrapper)
        
        wrapper.hidden = true
        
        currentTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: labelFontSize))
        currentTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        currentTimeLabel.text = "0:00.0"
        currentTimeLabel.textColor = UIColor.whiteColor()
        currentTimeLabel.textAlignment = .Center
        currentTimeLabel.backgroundColor = UIColor.clearColor()
        //i'm not wrapper i'm a singer with a cash flow-> ed sheeran :)
        //make it glow
        currentTimeLabel.layer.shadowColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        currentTimeLabel.layer.shadowRadius = 3.0
        currentTimeLabel.layer.shadowOpacity = 1.0
        currentTimeLabel.layer.shadowOffset = CGSizeZero
        currentTimeLabel.layer.masksToBounds = false
        wrapper.addSubview(currentTimeLabel)
        
        totalTimeLabel = UILabel(frame: CGRect(x: labelWidth + 10, y: 0, width: labelWidth, height: labelFontSize))
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        totalTimeLabel.text = TimeNumber(time: Float(theSong.getDuration())).toDisplayString()
        totalTimeLabel.textAlignment = .Center
        totalTimeLabel.backgroundColor = UIColor.clearColor()

        wrapper.addSubview(totalTimeLabel)
    }
    
    var pinchWrapper: UIView!
    var currentScale: UILabel = UILabel()
    var originalScale: UILabel = UILabel()
    func setUpPinchLable() {
        let labelWidth: CGFloat = 35
        let wrapperHeight: CGFloat = 10
        let labelFontSize: CGFloat = 10
        let wrapperWidth: CGFloat = 70
        pinchWrapper = UIView(frame: CGRect(x: 0.5 * trueWidth - 35, y: musicControlView.frame.height - wrapperHeight, width: wrapperWidth, height: wrapperHeight))
        pinchWrapper.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.3)
        pinchWrapper.layer.cornerRadius = wrapperHeight / 5
        musicControlView.addSubview(pinchWrapper)
        
        pinchWrapper.hidden = true
        
        currentScale = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: labelFontSize))
        currentScale.font = UIFont.systemFontOfSize(labelFontSize)
        currentScale.text = NSString(format: "%.1f", self.tabsEditorProgressWidthMultiplier) as String
        currentScale.textColor = UIColor.whiteColor()
        currentScale.textAlignment = .Center
        currentScale.backgroundColor = UIColor.clearColor()
        //i'm not wrapper i'm a singer with a cash flow-> ed sheeran :)
        //make it glow
        currentScale.layer.shadowColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        currentScale.layer.shadowRadius = 3.0
        currentScale.layer.shadowOpacity = 1.0
        currentScale.layer.shadowOffset = CGSizeZero
        currentScale.layer.masksToBounds = false
    
        pinchWrapper.addSubview(currentScale)
        
        originalScale = UILabel(frame: CGRect(x: labelWidth, y: 0, width: labelWidth, height: labelFontSize))
        originalScale.textColor = UIColor.whiteColor()
        originalScale.font = UIFont.systemFontOfSize(labelFontSize)
        originalScale.text = NSString(format: "%.1f", self.tabsEditorProgressWidthMultiplier) as String
        originalScale.textAlignment = .Center
        originalScale.backgroundColor = UIColor.clearColor()
        
        pinchWrapper.addSubview(originalScale)
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
            self.removeDoubleArrowView()
            self.isPanning = true
            self.timer.invalidate()
            self.timer = NSTimer()
            
            wrapper.hidden = false
            wrapper.alpha = 0.1
            UIView.animateWithDuration(0.25, animations: {
                animate in
                self.wrapper.alpha = 1
            })
        } else if sender.state == .Ended {
            self.isPanning = false
            startTime.setTime(Float(self.currentTime))
            wrapper.hidden = true
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
            if self.currentTime >= -0.1 && self.currentTime <= self.duration + 0.1 {
                let timeChange = NSTimeInterval(-translation.x / tabsEditorProgressWidthMultiplier)
                self.toTime = self.currentTime + timeChange
                if self.toTime < 0 {
                    self.toTime = 0
                } else if self.toTime > self.duration {
                    self.toTime = self.duration
                }
                self.currentTime = self.toTime
                startTime.setTime(Float(self.currentTime))
                let persent = CGFloat(self.currentTime) / CGFloat(self.duration)
            
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
            //self.playButtonImageView.hidden = true
            playPauseButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
            self.removeDoubleArrowView()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1 / Double(stepPerSecond) / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
             NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }

    func startCountdown() {
        countDownStartSecond--
        countdownView.setNumber(countDownStartSecond)

        if countDownStartSecond <= 0 {
//            musicControlView.addGestureRecognizer(musicSingleTapRecognizer)
            countdownTimer.invalidate()
            countdownView.hidden = true
            countDownStartSecond = 3
            if isDemoSong {
                self.avPlayer.play()
            } else {
                self.musicPlayer.play()
            }
            self.view.userInteractionEnabled = true
            toTime = self.duration + 1
            startTimer()
            countdownTimer.invalidate()
            countdownTimer = NSTimer()
        }
    }


    // pause the music or restart it, and count down
    func singleTapOnMusicControlView(sender: UIButton) {
        self.removeDoubleArrowView()
        if self.isDemoSong ? avPlayer.playing : (musicPlayer.playbackState == .Playing) {
            //self.playButtonImageView.hidden = false
            playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
            self.isPlaying = false
            //animate down progress block
            self.view.userInteractionEnabled = false
//            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
//                self.progressBlock!.alpha = 0.5
//                }, completion: nil)
            
            //pause music and stop timer
            if self.isDemoSong {
                avPlayer.pause()
            } else {
                musicPlayer.pause()
            }
            timer.invalidate()
            timer = NSTimer()
            self.view.userInteractionEnabled = true
        } else {
            //self.playButtonImageView.hidden = true
            playPauseButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
            self.isPlaying = true
            //animate up progress block in 3 seconds, because of the the limited height we are not doing the jump animation
            self.view.userInteractionEnabled = false
            UIView.animateWithDuration(3.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.progressBlock!.alpha = 1.0
            }, completion: nil)
            //start counting down 3 seconds
            //disable tap gesture that inadvertly starts timer
//            musicControlView.removeGestureRecognizer(musicSingleTapRecognizer)
            countdownView.hidden = false

            countdownView.setNumber(countDownStartSecond)
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    // string and fret position
    func createStringAndFretPosition() {
        // the postion for 6 string view
        let string6Height: CGFloat = 7 / 60 * self.trueHeight
        let fret6Width = self.trueWidth / 5
        // the position for 3 string view
        let string3Height: CGFloat = 11 / 60 * self.trueHeight
        let fret3Width = self.trueWidth / 5
        for i in 0..<26 {
            self.string6FretPosition.append(CGFloat(i) * fret6Width)
            self.string3FretPosition.append(CGFloat(i) * fret3Width)
            self.string3FretChangeingPosition[i] = CGFloat(i) * fret3Width
            if i < 6 {
                if i == 0 {
                    self.string6Position.append(string6Height / 2)
                } else {
                    self.string6Position.append(self.string6Position[i - 1] + string6Height)
                }
            }
            if i < 3 {
                if i == 0 {
                    self.string3Position.append(string3Height / 2)
                } else {
                    self.string3Position.append(self.string3Position[i - 1] + string3Height)
                }
            }
        }
        
        
    }
    
    func addString6View() {
        let string6Height: CGFloat = 7 / 60 * self.trueHeight
        for i in 0..<6 {
            let tempStringView: UIView = UIView()
            tempStringView.frame = CGRectMake(0, CGFloat(i) * string6Height, self.trueWidth * 5, string6Height)
            if i == 5 {
                tempStringView.frame = CGRectMake(0, CGFloat(i) * string6Height, self.trueWidth * 5, string6Height + 1 / 20 * self.trueHeight)
            }
            tempStringView.backgroundColor = UIColor.clearColor()
            self.completeStringView.addSubview(tempStringView)
            self.string6View.append(tempStringView)
        }
    }
    

    func createSoundWave() {
        let frame = CGRectMake(0.5 * self.trueWidth, 2 / 20 * self.trueHeight, tabsEditorProgressWidthMultiplier * CGFloat(theSong.getDuration()), 6 / 20 * self.trueHeight)
        self.progressBlock = UIView(frame: frame)
        if isDemoSong {
            let url: NSURL = theSong.getURL() as! NSURL
            self.avPlayer = try! AVAudioPlayer(contentsOfURL: url)
            self.duration = self.avPlayer.duration
            self.avPlayer.enableRate = true
            self.avPlayer.rate = 1.0
            self.avPlayer.volume = 1
        } else {
            self.recoverMode = MusicManager.sharedInstance.saveMusicPlayerState([theSong as! MPMediaItem])
            self.duration = ((theSong as! MPMediaItem).playbackDuration.isNaN ? 1500 : (theSong as! MPMediaItem).playbackDuration)
        }
        //self.progressBlock!.alpha = 0.5

    }
    
    func update() {
        if startTime.toDecimalNumer() > Float(self.duration)-0.15 {
            if isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
                self.musicPlayer.skipToNextItem()
            }
            timer.invalidate()
            timer = NSTimer()
            startTime.setTime(0)
            self.currentTime = 0
//            self.progressBlock.alpha = 0.5
            if isDemoSong {
                avPlayer.currentTime = currentTime
            }else{
                 musicPlayer.currentPlaybackTime = currentTime
            }
            //self.playButtonImageView.hidden = false
            playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
        }

        if !isPanning {
            let tempPlaytime = !isDemoSong ? self.musicPlayer.currentPlaybackTime : self.avPlayer.currentTime
            if startTime.toDecimalNumer() - Float(self.toTime) < (1 * speed ) && startTime.toDecimalNumer() - Float(self.toTime) >= 0 {
                startTime.addTime(Int(100 / stepPerSecond))
                self.currentTime = NSTimeInterval(startTime.toDecimalNumer()) - 0.01
                if (tempPlaytime.isNaN || tempPlaytime == 0){
                    startTime.setTime(0)
                    self.currentTime = 0
                }
            } else {
                if !tempPlaytime.isNaN {
                    startTime.setTime(Float(tempPlaytime))
                    self.currentTime = NSTimeInterval(startTime.toDecimalNumer())
                } else {
                    startTime.addTime(Int(100 / stepPerSecond))
                    self.currentTime = NSTimeInterval(startTime.toDecimalNumer()) - 0.01
                }
            }
        }
        
        if !isDemoSong {
            if(self.duration == 1500 && !(theSong as! MPMediaItem).playbackDuration.isNaN){
                self.duration = (theSong as! MPMediaItem).playbackDuration
            }
        }
        //
        //refresh current time label
        self.currentTimeLabel.text = TimeNumber(time: Float(currentTime)).toDisplayString()
        //refresh progress block
        let presentPosition = CGFloat(Float(currentTime) / Float(self.duration))
        
        //
        //self.progressBlock.setProgress(presentPosition)
        //
        
        //MARK: progessBlock width
        self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier)
        self.findCurrentTabView()
        
    }
    
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) {
        let name = self.fretsNumber[fromIndexPath.item]
        self.fretsNumber.removeAtIndex(fromIndexPath.item)
        self.fretsNumber.insert(name, atIndex: toIndexPath.item)
        let temp = self.mainViewDataArray[fromIndexPath.item]
        self.mainViewDataArray.removeAtIndex(fromIndexPath.item)
        self.mainViewDataArray.insert(temp, atIndex: toIndexPath.item)
        let tempImage = self.string3BackgroundImage[fromIndexPath.item]
        self.string3BackgroundImage.removeAtIndex(fromIndexPath.item)
        self.string3BackgroundImage.insert(tempImage, atIndex: toIndexPath.item)
    }
    

    func backToMainView() {
        self.view.userInteractionEnabled = false
        if(isCompleteStringViewScroll){
            isCompleteStringViewScroll = false
            
        }
        
        if(self.originaloffset != -1){
            self.collectionView.contentOffset.x = self.originaloffset
        }else{
            self.collectionView.contentOffset.x = self.completeStringView.contentOffset.x
        }
        
        
        self.originaloffset = -1
        self.baseNoteLocation = -1
        
        self.changeMenuButtonStatus(false)
        self.specificTabsScrollView.alpha = 0
        self.tabNameTextField.alpha = 0
        UIView.animateWithDuration(0.3, animations: {
            self.musicControlView.alpha = 1
            self.progressBlock.alpha = 1.0
            self.completeStringView.alpha = 0
            self.completeStringView.frame = CGRectMake(0, 6 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
            self.collectionView.alpha = 1
            }, completion:  {
                completed in
                self.editView.removeFromSuperview()
        })
        self.backButtonRotation(isLeft: true)
        self.tabNameTextField.text = ""
        for item in self.fingerPoint {
            item.removeFromSuperview()
        }
        self.oldTagString4 = 0
        self.oldTagString5 = 0
        if(isJiggling == true){
            stopSpecificJiggling()
        }
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
    func setMainViewTabPositionInRange(tab: NormalTabs, endIndex: Int, allTabsOnMusicLine: [tabOnMusicLine]) -> CGRect {
        
        var labelHeightNumber = 4
        if UIDevice.currentDevice().modelName == "iPhone 5" || UIDevice.currentDevice().modelName == "iPhone 5s" {
            labelHeightNumber = 6
        } else if UIDevice.currentDevice().modelName == "iPhone 6" || UIDevice.currentDevice().modelName == "iPhone 6s" {
            labelHeightNumber = 7
        } else if UIDevice.currentDevice().modelName == "iPhone 6 Plus" || UIDevice.currentDevice().modelName == "iPhone 6s Plus" {
            labelHeightNumber = 8
        }
        let labelHeight = ( self.progressBlock.frame.height - 20 ) / CGFloat(labelHeightNumber)
        let width = self.trueWidth / 18
        var frame: CGRect = CGRect()
        for i in 0..<endIndex {
            if self.compareTabs(allTabsOnMusicLine[i].tab, tab2: tab) {
                let tempFrame = CGRectMake(0 + CGFloat(self.currentTime / self.duration) * (self.progressBlock.frame.width), allTabsOnMusicLine[i].tabView.frame.origin.y, allTabsOnMusicLine[i].tabView.frame.width, allTabsOnMusicLine[i].tabView.frame.height)
                return tempFrame
            }
        }
        
        let numberOfUnrepeatedTab: Int = numberOfUnrepeatedTabOnMainView(endIndex, allTabsOnMusicLine: allTabsOnMusicLine)
        let tempSender = CGFloat(numberOfUnrepeatedTab % labelHeightNumber)
        
        let dynamicHeight = labelHeight * tempSender + 20
        frame = CGRectMake(CGFloat(self.currentTime*Double(tabsEditorProgressWidthMultiplier)-1), dynamicHeight, width, labelHeight)
        return frame
    }

    // caluclate the tab on music line without repeat
    func numberOfUnrepeatedTabOnMainView(endIndex: Int, allTabsOnMusicLine: [tabOnMusicLine]) -> Int{
        var set = [String: Int]()
        for i in 0..<endIndex {
            if let val = set["\(allTabsOnMusicLine[i].tab.index) \(allTabsOnMusicLine[i].tab.name)"] {
                set["\(allTabsOnMusicLine[i].tab.index) \(allTabsOnMusicLine[i].tab.name)"] = val + 1
            }
            else{
                set["\(allTabsOnMusicLine[i].tab.index) \(allTabsOnMusicLine[i].tab.name)"] = 1
            }
        }
        return set.count
    }
    
    // press the note button to add the tab in music line
    func pressMainViewNoteButton(sender: UIButton) {
        if !isJiggling{
            var inserted: Bool = false
            let index = sender.tag
            let content = self.noteButtonWithTabArray[index].tab.content
            PlayChordsManager.sharedInstance.playChordArpeggio(content, delay: 0.04, completion: {
                complete in
            })
            let returnValue = addTabViewOnMusicControlView(index)
            for var i = 0; i < self.allTabsOnMusicLine.count - 1; i++ {
                if self.currentTime <= self.allTabsOnMusicLine[0].time {
                    if(returnValue.1.tab.content == self.allTabsOnMusicLine[0].tab.content && returnValue.1.time == self.allTabsOnMusicLine[0].time){
                        self.findCurrentTabView()
                        return
                    }
                    self.allTabsOnMusicLine.insert(returnValue.1, atIndex: 0)
                    self.isShowDiscardAlert = true
                    inserted = true
                    break
                } else if self.currentTime > self.allTabsOnMusicLine[i].time && self.currentTime <= self.allTabsOnMusicLine[i + 1].time {
                    if(returnValue.1.tab.content == self.allTabsOnMusicLine[i+1].tab.content && returnValue.1.time == self.allTabsOnMusicLine[i+1].time){
                        self.findCurrentTabView()
                        return
                    }
                    self.allTabsOnMusicLine.insert(returnValue.1, atIndex: i + 1)
                    self.isShowDiscardAlert = true
                    inserted = true
                    break
                }
            }
            if !inserted {
                if(self.allTabsOnMusicLine.count > 0){
                    if(returnValue.1.tab.content == self.allTabsOnMusicLine[0].tab.content && returnValue.1.time == self.allTabsOnMusicLine[0].time){
                        self.findCurrentTabView()
                        return
                    }
                }
                
                self.allTabsOnMusicLine.append(returnValue.1)
                self.isShowDiscardAlert = true
            }
            self.progressBlock.addSubview(returnValue.0)
            self.findCurrentTabView()
        }
    }
    
    func addTabViewOnMusicControlView(sender: Int) -> (UIView, tabOnMusicLine) {
        let tempView: UIView = UIView()
        tempView.backgroundColor = UIColor.silverGray().colorWithAlphaComponent(0.6)//UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 0.6)
        tempView.layer.cornerRadius = 2
        var tempStruct: tabOnMusicLine = tabOnMusicLine()
        let name = self.noteButtonWithTabArray[sender].tab.name
        tempView.frame = setMainViewTabPositionInRange(self.noteButtonWithTabArray[sender].tab, endIndex: self.allTabsOnMusicLine.count, allTabsOnMusicLine: self.allTabsOnMusicLine)
        let tempLabelView: UILabel = UILabel()
        
        tempLabelView.frame = CGRectMake(0, 0, tempView.frame.width, tempView.frame.height)
        tempLabelView.layer.cornerRadius = 2
        tempLabelView.font = UIFont.systemFontOfSize(11)
        tempLabelView.textColor = UIColor.whiteColor()
        tempLabelView.textAlignment = NSTextAlignment.Center
        tempLabelView.numberOfLines = 1
        
//        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
//        let underlineAttributedString = NSAttributedString(string: name, attributes: underlineAttribute)
//        tempLabelView.attributedText = underlineAttributedString
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
            if self.isShowDiscardAlert {
                let alertController = UIAlertController(title: nil, message: "Do you want to discard all changes?", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
                alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler:{
                    handle in
                    self.tuningMenu.hidden = true
                    self.progressBlock.hidden = true
                    self.removeNotification()
                    if self.isDemoSong {
                        self.avPlayer.pause()
                    } else {
                        self.musicPlayer.pause()
                    }
                    if let songVC = self.songViewController {
                        if songVC.singleLyricsTableView != nil {
                            songVC.updateSingleLyricsAlpha()
                            songVC.updateSingleLyricsPosition(false)
                        }
                    }
                    self.dismissViewControllerAnimated(true, completion: {
                        completed in
                        if let songVC = self.songViewController {
                            if self.isDemoSong {
                                songVC.avPlayer.play()
                            } else {
                                MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                                songVC.player.play()
                            }
                        }
                    })
                }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }else{
                tuningMenu.hidden = true
                self.progressBlock.hidden = true
                removeNotification()
                if self.isDemoSong {
                    self.avPlayer.pause()
                } else {
                    self.musicPlayer.pause()
                }
                if let songVC = self.songViewController {
                    if songVC.singleLyricsTableView != nil {
                        songVC.updateSingleLyricsAlpha()
                        songVC.updateSingleLyricsPosition(false)
                    }
                }
                self.dismissViewControllerAnimated(true, completion: {
                    completed in
                    if let songVC = self.songViewController {
                        if self.isDemoSong {
                            songVC.avPlayer.play()
                        } else {
                            MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                            songVC.player.play()
                        }
                    }
                })
            }
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
        let tempx = self.collectionView.contentOffset.x
        self.view.userInteractionEnabled = false
        self.backToMainView()
        self.view.userInteractionEnabled = true
        self.view.userInteractionEnabled = false
        self.actionDismissLayerButton.hidden = false // what is this button?
        self.collectionView.contentOffset.x = tempx
        self.removeDoubleArrowView()
        UIView.animateWithDuration(0.3, animations: {
            self.tuningMenu.frame = CGRect(x: 0, y: 0, width: self.tuningMenu.frame.width, height: self.trueHeight)
            self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
            self.actionDismissLayerButton.alpha = 0.3
        })
    
        self.view.userInteractionEnabled = true
    }
    
    func pressResetButton(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Do you want to reset all added chords?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: {
            action in
            self.view.userInteractionEnabled = false
                UIView.animateWithDuration(0.3, animations: {
                    for i in 0..<self.allTabsOnMusicLine.count {
                        self.allTabsOnMusicLine[i].tabView.alpha = 0
                    }
                    }, completion: {
                        completed in
                        for i in 0..<self.allTabsOnMusicLine.count {
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
    
    func changeMenuButtonStatus(sender: Bool) {
        resetButton.hidden = sender
        tuningButton.hidden = sender
        playPauseButton.hidden = sender
        addButton.hidden = sender
        statusLabel.hidden = !sender
        if (sender) {
            self.backgroundView.alpha = 0
        }else{
            self.backgroundView.alpha = 1
        }
        
        if sender {
            //savebutton
            doneButton.setImage(UIImage(named: "saveButton"), forState: UIControlState.Normal)
            doneButton.imageEdgeInsets = UIEdgeInsetsMake(0.3 / 20 * self.trueHeight, 0.1 / 20 * self.trueHeight, 0.8 / 20 * self.trueHeight, 0.6 / 20 * self.trueHeight)
        }else{
            //savetext
            self.doneButton.setImage(UIImage(named: "saveText"), forState: UIControlState.Normal)
            self.doneButton.imageEdgeInsets = UIEdgeInsetsMake(0.4 / 20 * self.trueHeight, 0.1 / 20 * self.trueHeight, 0.7 / 20 * self.trueHeight, 0.6 / 20 * self.trueHeight)
        }
    }


    func pressAddButton(sender: UIButton) {
        if(isJiggling){
            self.stopMainViewJiggling()
        }
        if(self.doubleArrowView != nil){
            self.doubleArrowView.alpha = 0
        }
        cropFullStringImageView(Int(capoStepper.value))
    
        self.changeMenuButtonStatus(true)
        
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
        self.backgroundView.alpha = 0
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
        self.backButtonRotation(isLeft: false)
        self.createEditFingerPoint(400)
        self.view.userInteractionEnabled = true
    }
    
    var pressDoneButton:Bool = false
    func pressDoneButton(sender: UIButton?=nil) {
        pressDoneButton = false

        if self.intoEditView == true {
            
            if self.addNewTab == true {
                var addSuccessed: Bool = true
                if self.tabFingerPointChanged == true {
                    let index = self.currentBaseButton.tag
                    let name: String = self.tabNameTextField.text!.replace(" ", replacement: "")
                    self.tabNameTextField.text! = name
                    var content: String = String()
                    
                    if name == "" || name.containsString(" ") {
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
                            self.AnimationStatusLabel("Input Chord Name")
                            
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
                        for i in 0..<6 {
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
                        self.currentSelectedSpecificTab = NormalTabs()
                        if let compareExistTabs = TabsDataManager.getUniqueTab(index, name: name, content: content)?.tabs {
                            self.currentSelectedSpecificTab.tabs = compareExistTabs
                        } else {
                            let tempTabs: Tabs = TabsDataManager.addNewTabs(index, name: name, content: content)
                            self.currentSelectedSpecificTab.tabs = tempTabs
                        }
                        self.currentNoteButton.setTitle(name, forState: UIControlState.Normal)
                        self.currentSelectedSpecificTab.index = index
                        self.currentSelectedSpecificTab.name = name
                        self.currentSelectedSpecificTab.content = content
                        addSuccessed = true
                        self.addSpecificFingerPoint = true
                        self.backToMainView()
                    }
                }

                if addSuccessed == true && self.addSpecificFingerPoint == true {
                    var addNew: Bool = true
                    if let _ = self.currentSelectedSpecificTab {
                        let fretNumber = Int(self.currentSelectedSpecificTab.index) - Int(self.currentSelectedSpecificTab.index) / 100 * 100
                        for i in 0..<self.mainViewDataArray.count {
                            if self.mainViewDataArray[i].fretNumber == fretNumber {
                                for j in 0..<self.mainViewDataArray[i].noteButtonsWithTab.count {
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
                    
                    if addNew == true {
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
            var allTimes = [Float]()

            for oneline in allTabsOnMusicLine {
                allChords.append(oneline.tab.name)
                allTabs.append(oneline.tab.content)
                allTimes.append(Float(oneline.time))
            }
            
            var tuningOfTheSong = ""
            for label in tuningValueLabels {
                tuningOfTheSong += "\(label.text!)-"
            }
            
            //check if tabsSet id is bigger than 0, if so, means this tabs has been saved to the cloud, then we use same tabsSetid, otherwise if less than one, it means it's new
            if (allChords.count < 3) {
                let alertController = UIAlertController(title: nil, message: "Please add at least THREE chords into your tab", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }

            let savedTabsSetId = CoreDataManager.getTabs(theSong, fetchingUsers: true).3
            
            CoreDataManager.saveTabs(theSong, chords: allChords, tabs: allTabs, times: allTimes, tuning: tuningOfTheSong, capo: Int(capoStepper.value), userId:
                Int(CoreDataManager.getCurrentUser()!.id), tabsSetId:  savedTabsSetId > 0 ?savedTabsSetId : kLocalSetId, visible: isPublic, lastEditedDate: NSDate())
            
            if let songVC = songViewController {
                songVC.updateMusicData(theSong)
            }
            
            tuningMenu.hidden = true
            self.progressBlock.hidden = true
            removeNotification()
            if self.isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
            }
            
            let demoItem: Findable = MusicManager.sharedInstance.demoSongs[0]
            //automatically upload tabs
            APIManager.uploadTabs(isDemoSong ? demoItem : theSong , completion: {
                cloudId in
                
                CoreDataManager.saveCloudIdToTabs(self.isDemoSong ? demoItem : self.theSong, cloudId: cloudId)
            })
            
            if let songVC = self.songViewController {
                if songVC.singleLyricsTableView != nil {
                    songVC.updateSingleLyricsAlpha()
                    songVC.updateSingleLyricsPosition(false)
                }
            }
            
            self.dismissViewControllerAnimated(true, completion: {
                completed in
                
                if let songVC = self.songViewController {
                    if self.isDemoSong {
                        songVC.avPlayer.play()
                    } else {
                        MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                        songVC.player.play()
                    }
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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "startMainViewJiggling:")
        self.longPressMainViewNoteButton[tempButton] = longPress
        tempButton.addGestureRecognizer(longPress)
        
        
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
                let temp6offset = self.string6FretPosition[tempTab.index.integerValue%100] - self.completeStringView.contentOffset.x
                let temp3offset = self.string3FretChangeingPosition[tempTab.index.integerValue%100]! - temp6offset
                if (temp3offset < 0){
                    self.originaloffset = 0
                }else if (temp3offset > self.string6FretPosition[string6FretPosition.count-1-Int(self.capoStepper.value)]-self.trueWidth){
                    self.originaloffset = self.string6FretPosition[string6FretPosition.count-1-Int(self.capoStepper.value)]-self.trueWidth
                }else{
                    self.originaloffset = temp3offset
                }
            }
        }
        
        self.noteButtonWithTabArray.append(tempNoteButtonWithTab)
        self.isShowDiscardAlert = true
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
            
            for i in 4...6 {
                var tempButtonArray: [noteButtonWithTab] = [noteButtonWithTab]()
                for buttonWithTab in item.noteButtonsWithTab {
                    if Int(buttonWithTab.tab.index) / 100 == i {
                        tempButtonArray.append(buttonWithTab)
                    }
                }
                if tempButtonArray.count == 1 {
                    tempButtonArray[0].noteButton.frame = CGRectMake(self.trueWidth / 5 / 2 - buttonWidth / 2, self.string3Position[Int(tempButtonArray[0].tab.index) / 100 - 4] - buttonWidth / 2, buttonWidth, buttonWidth)
                    tempButtonArray[0].noteButton.layer.cornerRadius = 0.5 * buttonWidth
                    tempButtonArray[0].noteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
                }
                if tempButtonArray.count == 2 {
                    for j in 0..<tempButtonArray.count {
                        tempButtonArray[j].noteButton.frame = CGRectMake(buttonX2[j], self.string3Position[Int(tempButtonArray[j].tab.index) / 100 - 4] - buttonWidth2 / 2, buttonWidth2, buttonWidth2)
                        tempButtonArray[j].noteButton.layer.cornerRadius = 0.5 * buttonWidth2
                        tempButtonArray[j].noteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
                    }
                } else if tempButtonArray.count == 3 {
                    for j in 0..<tempButtonArray.count {
                        tempButtonArray[j].noteButton.frame = CGRectMake(buttonX3[j], self.string3Position[Int(tempButtonArray[j].tab.index) / 100 - 4] - buttonWidth3 / 2, buttonWidth3, buttonWidth3)
                        tempButtonArray[j].noteButton.layer.cornerRadius = 0.5 * buttonWidth3
                        tempButtonArray[j].noteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
                    }
                }
            }
        }
    }
    
    func pressPreviousButton(sender: UIButton) {
        self.removeDoubleArrowView()
        if(currentTabViewIndex == -1) {
            return
        }
        let stepper = 10.0 / Double(self.tabsEditorProgressWidthMultiplier)
        if self.allTabsOnMusicLine.count > 1 {
            self.view.userInteractionEnabled = false
            if (self.currentTabViewIndex == self.allTabsOnMusicLine.count-1) {
                if(self.currentTime > self.allTabsOnMusicLine[self.currentTabViewIndex].time + 3.2 * stepper){
                    if isDemoSong {
                        let temprate = self.avPlayer.rate
                        self.avPlayer.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                        self.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                        self.toTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                        self.avPlayer.rate = 0
                        self.timer.invalidate()
                        self.timer = NSTimer()
                        startTime.setTime(Float(self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper))
                        self.previousButton.enabled = false
                        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                            self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - CGFloat(self.currentTime * Double(self.tabsEditorProgressWidthMultiplier))
                            }, completion: {
                                completed in
                                self.findCurrentTabView()
                                self.previousButton.enabled = true
                                self.avPlayer.rate = temprate
                                self.view.userInteractionEnabled = true
                                if(temprate > 0) {
                                    self.startTimer()
                                }
                                
                        })
                    } else {
                        let temprate = self.musicPlayer.currentPlaybackRate
                        self.musicPlayer.currentPlaybackTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                        self.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                        self.timer.invalidate()
                        self.timer = NSTimer()
                        startTime.setTime(Float(self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper))
                        self.toTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                        self.previousButton.enabled = false
                        self.musicPlayer.currentPlaybackRate = 0
                        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                            self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - CGFloat(self.currentTime * Double(self.tabsEditorProgressWidthMultiplier))
                            }, completion: {
                                completed in
                                self.findCurrentTabView()
                                self.previousButton.enabled = true
                                self.musicPlayer.currentPlaybackRate = temprate
                                self.view.userInteractionEnabled = true
                                if(temprate > 0) {
                                    self.startTimer()
                                }
                        })
                        
                    }
                    return
                }
            }
            self.allTabsOnMusicLine[self.currentTabViewIndex].tabView.removeFromSuperview()
            self.allTabsOnMusicLine.removeAtIndex(self.currentTabViewIndex)
            self.isShowDiscardAlert = true
            self.currentTabViewIndex = --self.currentTabViewIndex
            
            if (self.currentTabViewIndex < 0) {
                self.currentTabViewIndex = 0
            }
            if isDemoSong {
                let temprate = self.avPlayer.rate
                self.avPlayer.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                self.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                self.avPlayer.rate = 0
                self.toTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                self.previousButton.enabled = false
                self.timer.invalidate()
                self.timer = NSTimer()
                startTime.setTime(Float(self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper))
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                    self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - CGFloat(self.currentTime * Double(self.tabsEditorProgressWidthMultiplier))
                    }, completion: {
                        completed in
                        self.findCurrentTabView()
                        self.previousButton.enabled = true
                        self.avPlayer.rate = temprate
                        self.view.userInteractionEnabled = true
                        if(temprate > 0) {
                            self.startTimer()
                        }
                })
            } else {
                let temprate = self.musicPlayer.currentPlaybackRate
                self.musicPlayer.currentPlaybackTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                self.currentTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                self.previousButton.enabled = false
                self.musicPlayer.currentPlaybackRate = 0
                self.toTime = self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper
                self.timer.invalidate()
                self.timer = NSTimer()
                startTime.setTime(Float(self.allTabsOnMusicLine[self.currentTabViewIndex].time + 0.1 * stepper))
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                    self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - CGFloat(self.currentTime * Double(self.tabsEditorProgressWidthMultiplier))
                    }, completion: {
                        completed in
                        self.findCurrentTabView()
                        self.previousButton.enabled = true
                        self.musicPlayer.currentPlaybackRate = temprate
                        self.view.userInteractionEnabled = true
                        if(temprate > 0) {
                            self.startTimer()
                        }
                })
               
            }
           
        } else if self.allTabsOnMusicLine.count == 1 && currentTabViewIndex  == 0{
            self.view.userInteractionEnabled = false
            self.allTabsOnMusicLine[self.currentTabViewIndex].tabView.removeFromSuperview()
            self.isShowDiscardAlert = true
            self.allTabsOnMusicLine.removeAtIndex(self.currentTabViewIndex)
            self.currentTabViewIndex = 0
            self.currentTime = 0
            if isDemoSong {
                let temprate = self.avPlayer.rate
                self.avPlayer.currentTime = 0
                self.avPlayer.rate = 0
                self.toTime = 0
                self.timer.invalidate()
                self.timer = NSTimer()
                startTime.setTime(0)
                    self.previousButton.enabled = false
                    UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                        self.progressBlock.frame.origin.x = 0.5 * self.trueWidth
                        }, completion: {
                            completed in
                            self.findCurrentTabView()
                            self.previousButton.enabled = true
                            self.avPlayer.rate = temprate
                            self.view.userInteractionEnabled = true
                            if(temprate > 0) {
                                self.startTimer()
                            }

                    })

            } else {
                let temprate = self.musicPlayer.currentPlaybackRate
                self.musicPlayer.currentPlaybackTime = 0
                self.musicPlayer.currentPlaybackRate = 0
                self.timer.invalidate()
                self.timer = NSTimer()
                startTime.setTime(0)
                self.toTime = 0
                self.previousButton.enabled = false
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                    self.progressBlock.frame.origin.x = 0.5 * self.trueWidth
                    }, completion: {
                        completed in
                        self.findCurrentTabView()
                        self.previousButton.enabled = true
                        self.musicPlayer.currentPlaybackRate = temprate
                        self.view.userInteractionEnabled = true
                        if(temprate > 0) {
                            self.startTimer()
                        }

                })
            }
            
        } else {
            self.view.userInteractionEnabled = false
            self.currentTime = 0
            currentTabViewIndex  == 0
            if isDemoSong {
                let temprate = self.avPlayer.rate
                self.avPlayer.currentTime = 0
                self.avPlayer.rate = 0
                self.timer.invalidate()
                self.timer = NSTimer()
                startTime.setTime(0)
                self.toTime = 0
                self.previousButton.enabled = false
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                    self.progressBlock.frame.origin.x = 0.5 * self.trueWidth
                    }, completion: {
                        completed in
                        self.findCurrentTabView()
                        self.previousButton.enabled = true
                        self.avPlayer.rate = temprate
                        self.view.userInteractionEnabled = true
                        if(temprate > 0) {
                            self.startTimer()
                        }
                })
            } else {
                let temprate = self.musicPlayer.currentPlaybackRate
                self.musicPlayer.currentPlaybackTime = 0
                self.musicPlayer.currentPlaybackRate = 0
                self.timer.invalidate()
                self.timer = NSTimer()
                startTime.setTime(0)
                self.toTime = 0
                self.previousButton.enabled = false
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                    self.progressBlock.frame.origin.x = 0.5 * self.trueWidth
                    }, completion: {
                        completed in
                        self.findCurrentTabView()
                        self.previousButton.enabled = true
                        self.musicPlayer.currentPlaybackRate = temprate
                        self.view.userInteractionEnabled = true
                        if(temprate > 0) {
                            self.startTimer()
                        }
                })
            }
        }

    }
    
    func privacyButtonPressed(button: UIButton) {
        if isPublic {
            isPublic = false
            privacyButton.setImage(UIImage(named: "privateButton"), forState: .Normal)
            privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.3 / 20 * self.trueHeight, 1 / 20 * self.trueHeight, 0.8 / 20 * self.trueHeight, 0.1 / 20 * self.trueHeight)
        } else {
            isPublic = true
            privacyButton.setImage(UIImage(named: "globeIcon"), forState: .Normal)
            privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.43 / 20 * self.trueHeight, 1.1 / 20 * self.trueHeight, 0.93 / 20 * self.trueHeight, 0.2 / 20 * self.trueHeight)
        }
        self.isShowDiscardAlert = true
    }
    
    // find the current tab according to the current music time
    func findCurrentTabView() {
        let stepper:Double = 10.0 / Double(self.tabsEditorProgressWidthMultiplier)
        for i in 0..<self.allTabsOnMusicLine.count {
            self.allTabsOnMusicLine[i].tabView.backgroundColor = UIColor.silverGray().colorWithAlphaComponent(0.6)
        }
        if self.allTabsOnMusicLine.count == 1 {
            if self.currentTime >= (self.allTabsOnMusicLine[0].time - 0.1 * stepper) && self.currentTime <= (self.allTabsOnMusicLine[0].time + 3.2 * stepper) {
                self.allTabsOnMusicLine[0].tabView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
                self.currentTabViewIndex = 0
            }
        } else {
            for i in 1..<(self.allTabsOnMusicLine.count + 1) {
                if i < self.allTabsOnMusicLine.count {
                    if self.currentTime > (self.allTabsOnMusicLine[i - 1].time - 0.1 * stepper) && (self.currentTime <= self.allTabsOnMusicLine[i].time) && self.currentTime <= (self.allTabsOnMusicLine[i - 1].time + 3.2 * stepper) {
                        self.allTabsOnMusicLine[i - 1].tabView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)//UIColor.brownColor()
                        self.currentTabViewIndex = i - 1
                        break
                    }
                } else if i == self.allTabsOnMusicLine.count {
                    if self.currentTime > (self.allTabsOnMusicLine[i - 1].time - 0.1 * stepper) && self.currentTime <= (self.allTabsOnMusicLine[i - 1].time + 3.2 * stepper)   {
                        self.allTabsOnMusicLine[i - 1].tabView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)//UIColor.brownColor()
                        self.currentTabViewIndex = i - 1
                        break
                    }
                }
            }
        }
    }
    
    let kAnimationRotateDeg: Double = 1.0
}

extension TabsEditorViewController {    
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer? {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer: AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    func playTheSound(urls: [NSString]) {
        var tempSoundArray: [AVAudioPlayer] = [AVAudioPlayer]()
        for item in urls {
            let tempSound = setupAudioPlayerWithFile(item, type: ".wav")
            tempSoundArray.append(tempSound!)
        }
        
    }
}

