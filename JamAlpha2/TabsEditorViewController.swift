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

class TabsEditorViewController: UIViewController {
  var isTapedOnButton: Bool = false
  var isCompleteStringViewScroll = false
  var originaloffset:CGFloat = -1
  var baseNoteLocation:CGFloat = -1
  // max, min pinch scale
  let maxScaleNumber: CGFloat = 20
  let minScaleNumber: CGFloat = 5
  var fretNumberOnFullStringView: UIView!
  var string3BackgroundImage = [String]()
  var playButtonImageView: UIImageView!
  var doubleArrowView: CustomizedView!
  var scrollTimer: NSTimer?
  //for doublearror adjust position
  var doubleViewPositionX:CGFloat = 0.0
  // delete jiggling gesture
  var deleteChordOnMainView: [UIButton: UITapGestureRecognizer] = [UIButton: UITapGestureRecognizer]()
  let deleteChordOnSpecificTabView: UITapGestureRecognizer = UITapGestureRecognizer()
  var longPressSpecificTabButton: [Int: UILongPressGestureRecognizer] = [Int: UILongPressGestureRecognizer]()
  var longPressMainViewNoteButton: [UIButton: UILongPressGestureRecognizer] = [UIButton: UILongPressGestureRecognizer]()
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
  let speedMatcher = [0.7: 0.50, 0.8: 0.67, 0.9: 0.79, 1.0: 1.00, 1.1: 1.25, 1.2: 1.50, 1.3: 2.00]
  let speedLabels = [0.7: "0.5x", 0.8: "0.65x" , 0.9: "0.8x", 1.0: "1.0x", 1.1: "1.25x", 1.2: "1.5x", 1.3: "2x"]
  
  // data array
  var specificTabSets: [NormalTabs] = [NormalTabs]()
  var currentSelectedSpecificTab: NormalTabs!
  var countDownNumber: Float = 3
  
  //MARK: tutorials
  var tutorialImage: UIImageView?
  var tutorialCloseButton: UIButton!
  var watchTutorialButton: UIButton!
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
  
  var backgroundImage: UIImageView = UIImageView()
  
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
  var isTextChanged = false
  //textfeild delege
  var tempTapView:UIView?
  
  var addedNoteButtonOnCompleteView: Bool = false
  
  var endScaleNumber: CGFloat = 10
  var beginScale:CGFloat!
  
  var topLineView: UIView!
  let backgroundView: UIView = UIView()
  let previousButton: UIButton = UIButton()
  
  var wrapper: UIView!
  var pinchWrapper: UIView!
  var currentScale: UILabel = UILabel()
  var originalScale: UILabel = UILabel()
  
  var isPanning: Bool = false
  var toTime: NSTimeInterval = 0

  var pressDoneButton:Bool = false
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
    if view.frame.height > view.frame.width {
      trueWidth = view.frame.height
      trueHeight = view.frame.width
    } else {
      trueWidth = view.frame.width
      trueHeight = view.frame.height
    }
    loadFretImage()
    checkConverToMPMediaItem()
    // create the sound wave
    createSoundWave()
    // add the background image with blur
    backgroundImage.frame = CGRectMake(0, 0, trueWidth, trueWidth)
    let size: CGSize = CGSizeMake(trueWidth, trueWidth)
    var image:UIImage!
    if let artwork = theSong.getArtWork() {
      image = artwork.imageWithSize(size)
    } else {
      image = UIImage(named: "liwengbg")
    }
    backgroundImage.image = image != nil ? image : songViewController?.backgroundImage
    let blurredImage:UIImage = backgroundImage.image!.applyLightEffect()!
    backgroundImage.image = blurredImage
    view.addSubview(backgroundImage)
    currentBaseButton.tag = 400
    // add the default tab data into coredata if it doesn't exist
    TabsDataManager.addDefaultData()
    // add objects on main view and edit view
    addObjectsOnMainView()
    createStringAndFretPosition()
    // initial main view tab data array
    initialMainViewDataArray(0)
    addObjectsOnEditView()
    addMusicControlView()
    setUpCountdownView()
    // initial collection view
    initCollectionView()
    setUpTuningControlMenu()
    PlayChordsManager.sharedInstance.fret0Midi = PlayChordsManager.sharedInstance.standardFret0Midi
    PlayChordsManager.sharedInstance.changeVolumn(1.0)
  }
  
  override func viewDidAppear(animated: Bool) {
    // MARK: add exist chord to tab editor view
    addChordToEditorView(theSong)
    if NSUserDefaults.standardUserDefaults().boolForKey(kShowTabsEditorTutorialA) {
      showTutorial(first: true)
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    PlayChordsManager.sharedInstance.deinitialSoundBank()
  }
  
  
  func loadFretImage() {
    if UIDevice.currentDevice().modelName == "iPhone 4s" {
      string3BackgroundImage = Array<String>(count: 25, repeatedValue: "iPhone4s_fret")
      string3BackgroundImage[0] = "iPhone4s_fret0"
    } else {
      string3BackgroundImage = Array<String>(count: 25, repeatedValue: "iPhone5_fret")
      string3BackgroundImage[0] = "iPhone5_fret0"
    }
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
      if !isPlaying {
        startTimer()
        isPlaying = true
      }
      playPauseButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
      if !intoEditView {
        progressBlock.alpha = 1
      }
    } else if musicPlayer.playbackState == .Paused {
      playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
      isPlaying = false
      timer.invalidate()
      timer = NSTimer()
    }
  }
  
  func currentSongChanged(sender: NSNotification){
    if musicPlayer.playbackState == .Playing && isPlaying{
      musicPlayer.pause()
      playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
    }
  }
  
  // MARK: check theSong can convert to MPMediaItem
  func checkConverToMPMediaItem() {
    if isDemoSong {
      avPlayer = AVAudioPlayer()
    } else {
      musicPlayer = MusicManager.sharedInstance.player
      registerNotification()
    }
  }
  
  // MARK: a slider menu that allow user to specify speed, capo number, and six string tuning
  func setUpTuningControlMenu() {
    // a gray button covers the entire background behind tuning menu, is to dismiss the tuning menus
    actionDismissLayerButton = UIButton(frame: CGRect(x: 0, y: 0, width: trueWidth, height: trueHeight))
    actionDismissLayerButton.backgroundColor = UIColor.clearColor()
    actionDismissLayerButton.addTarget(self, action: "dismissAction", forControlEvents: .TouchUpInside)
    view.addSubview(actionDismissLayerButton)
    actionDismissLayerButton.hidden = true
    tuningMenu = UIView(frame: CGRect(x: -250, y: 0, width: 250, height: trueHeight))
    tuningMenu.backgroundColor = UIColor.actionGray()
    view.addSubview(tuningMenu)
    //draw 7 lines to give rooms for eight rows
    let rowHeight = trueHeight/8
    for i in 0..<7 {
      let separator = UIView(frame: CGRect(x: 0, y: rowHeight * CGFloat(i + 1), width: tuningMenu.frame.width, height: 1))
      separator.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
      tuningMenu.addSubview(separator)
    }
    let sideMargin: CGFloat = 10
    //SECTION: add speed label, stepper
    speedLabel = UILabel(frame: CGRect(x: sideMargin, y: 0, width: 120, height: 25))
    speedLabel.textColor = UIColor.mainPinkColor()
    speedLabel.text = "Speed: 1.0x"
    speedLabel.center.y = rowHeight / 2
    tuningMenu.addSubview(speedLabel)
    
    speedStepper = UIStepper(frame: CGRect(x: tuningMenu.frame.width - 94 - sideMargin, y: 0, width: 94, height: 29))
    speedStepper.center.y = rowHeight / 2
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
    capoLabel.center.y = rowHeight * 3 / 2
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
      stringIndicatorLabel.center.y = rowHeight / 2 + rowHeight * CGFloat(i + 2)
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
    let speedKey = Double(round(10 * stepper.value) / 10)
    let adjustedSpeed = Float(speedMatcher[speedKey]!)
    speedLabel.text = "Speed: \(speedLabels[speedKey]!)"
    if isDemoSong {
      if avPlayer.playing {
        avPlayer.rate = adjustedSpeed
      }
    } else {
      if musicPlayer.playbackState == .Playing {
        musicPlayer.currentPlaybackRate = adjustedSpeed
      }
    }
    speed = adjustedSpeed
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
      mainViewDataArray.append(temp)
    }
  }
  
  
  func addObjectsOnMainView() {
    let musicView: UIView = UIView()
    menuView.frame = CGRectMake(-1, 0, trueWidth+1, 2 / 20 * trueHeight)
    menuView.backgroundColor = UIColor(patternImage: UIImage(named: "topMenuBar")!)
    view.addSubview(menuView)
    
    musicView.frame = CGRectMake(0, 2 / 20 * trueHeight, trueWidth, 6 / 20 * trueHeight)
    musicView.backgroundColor = UIColor.clearColor()
    view.addSubview(musicView)
    
    fretBoardView.frame = CGRectMake(0, 8 / 20 * trueHeight, trueWidth, 11 / 20 * trueHeight)
    fretBoardView.backgroundColor = UIColor.clearColor()
    view.addSubview(fretBoardView)
    
    let buttonWidth:CGFloat = 2.5 / 20 * trueHeight
    let buttonSpace = (0.5 * trueWidth - 3.5 * buttonWidth - 0.5 / 31.0 * trueWidth) / 3.0
    let buttonEdge: CGFloat = CGFloat(0.2 / 20) * trueHeight
    
    backButton.frame = CGRectMake(0.5 / 31 * trueWidth+1, 0, buttonWidth, buttonWidth)
    backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
    backButton.setImage(UIImage(named: "backButton"), forState: UIControlState.Normal)
    backButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * trueHeight, buttonEdge + 0.5 / 20 * trueHeight, buttonEdge + 0.25 / 20 * trueHeight)//CGFloat(0.6 / 20) * trueHeight
    menuView.addSubview(backButton)
    
    statusLabel.frame = CGRectMake(1 * buttonWidth + 1 * buttonSpace + 0.5 / 31 * trueWidth+1, 0, 4 * (buttonWidth + buttonSpace), 2 / 20 * trueHeight)
    statusLabel.text = "Tabs Editor"
    statusLabel.textColor = UIColor.whiteColor()
    statusLabel.hidden = true
    statusLabel.textAlignment = NSTextAlignment.Center
    menuView.addSubview(statusLabel)
    
    addButton.frame = CGRectMake(1 * buttonWidth + 1 * buttonSpace + 0.5 / 31 * trueWidth+1, 0, buttonWidth, buttonWidth)
    addButton.addTarget(self, action: "pressAddButton:", forControlEvents: UIControlEvents.TouchUpInside)
    addButton.setImage(UIImage(named: "addButton"), forState: UIControlState.Normal)
    addButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * trueHeight, buttonEdge + 0.5 / 20 * trueHeight, buttonEdge + 0.25 / 20 * trueHeight)
    menuView.addSubview(addButton)
    
    resetButton.frame = CGRectMake(2 * buttonWidth + 2 * buttonSpace + 0.5 / 31 * trueWidth+1, 0, buttonWidth, buttonWidth)
    resetButton.addTarget(self, action: "pressResetButton:", forControlEvents: UIControlEvents.TouchUpInside)
    resetButton.setImage(UIImage(named: "trashButton"), forState: UIControlState.Normal)
    resetButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * trueHeight, buttonEdge + 0.5 / 20 * trueHeight, buttonEdge + 0.25 / 20 * trueHeight)
    menuView.addSubview(resetButton)
    
    playPauseButton.frame = CGRectMake(3 * buttonWidth + 3 * buttonSpace + 0.5 / 31 * trueWidth+1, 0, buttonWidth, buttonWidth)
    playPauseButton.addTarget(self, action: "singleTapOnMusicControlView:", forControlEvents: UIControlEvents.TouchUpInside)
    playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
    playPauseButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * trueHeight, buttonEdge + 0.5 / 20 * trueHeight, buttonEdge + 0.25 / 20 * trueHeight)
    menuView.addSubview(playPauseButton)
    
    tuningButton.frame = CGRectMake(4 * buttonWidth + 4 * buttonSpace + 0.5 / 31 * trueWidth+1, 0, buttonWidth, buttonWidth)
    tuningButton.addTarget(self, action: "pressTuningButton:", forControlEvents: UIControlEvents.TouchUpInside)
    tuningButton.setImage(UIImage(named: "tuningButton"), forState: UIControlState.Normal)
    tuningButton.imageEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge + 0.25 / 20 * trueHeight, buttonEdge + 0.5 / 20 * trueHeight, buttonEdge + 0.25 / 20 * trueHeight)
    menuView.addSubview(tuningButton)
    
    let privacyDoneButtonContainer: UIImageView = UIImageView()
    privacyDoneButtonContainer.frame = CGRectMake(30.5 / 31 * trueWidth - 2.5 * 1.6 / 20 * trueHeight+1, 0.2 / 20 * trueHeight, 2.5 * 1.6 / 20 * trueHeight, 1.6 / 20 * trueHeight)
    privacyDoneButtonContainer.image = UIImage(named: "frame")
    privacyDoneButtonContainer.userInteractionEnabled = true
    menuView.addSubview(privacyDoneButtonContainer)
    
    //TODO: set button from the visible attribute itself
    privacyButton.frame = CGRectMake(30.5 / 31 * trueWidth - 3 * 1.6 / 20 * trueHeight+1, 0, buttonWidth, buttonWidth)
    privacyButton.backgroundColor = UIColor.clearColor()
    privacyButton.setImage(UIImage(named: "globeIcon"), forState: UIControlState.Normal)
    privacyButton.addTarget(self, action: "privacyButtonPressed:", forControlEvents: .TouchUpInside)
    privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.43 / 20 * trueHeight, 1.1 / 20 * trueHeight, 0.93 / 20 * trueHeight, 0.2 / 20 * trueHeight)
    menuView.addSubview(privacyButton)
    
    doneButton.frame = CGRectMake(30.5 / 31 * trueWidth - 1.5 * 1.6 / 20 * trueHeight+1, 0, 1.2 * buttonWidth, buttonWidth)
    doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
    doneButton.setImage(UIImage(named: "saveText"), forState: UIControlState.Normal)
    doneButton.imageEdgeInsets = UIEdgeInsetsMake(0.4 / 20 * trueHeight, 0.1 / 20 * trueHeight, 0.7 / 20 * trueHeight, 0.6 / 20 * trueHeight)
    menuView.addSubview(doneButton)
    
    let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
    tapOnEditView.addTarget(self, action: "tapOnEditView:")
    menuView.addGestureRecognizer(tapOnEditView)
    view.addSubview(progressBlock)
  }
  
  func addObjectsOnEditView() {
    editView.frame = CGRectMake(0, 2 / 20 * trueHeight, trueWidth, 18 / 20 * trueHeight)
    specificTabsScrollView.frame = CGRectMake(0.5 / 31 * trueWidth, 0.25 / 20 * trueHeight, 22 / 31 * trueWidth, 2.5 / 20 * trueHeight)
    specificTabsScrollView.contentSize = CGSizeMake(trueWidth / 2, 2.5 / 20 * trueHeight)
    specificTabsScrollView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
    specificTabsScrollView.layer.cornerRadius = 3
    editView.addSubview(specificTabsScrollView)
    
    tabNameTextField.frame = CGRectMake(23.5 / 31 * trueWidth, 0.25 / 20 * trueHeight, 7 / 31 * trueWidth, 2.5 / 20 * trueHeight)
    tabNameTextField.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
    tabNameTextField.textColor = UIColor.whiteColor()
    tabNameTextField.tintColor = UIColor.whiteColor()
    tabNameTextField.layer.cornerRadius = 3
    tabNameTextField.autocorrectionType = UITextAutocorrectionType.No
    tabNameTextField.delegate = self
    tabNameTextField.attributedPlaceholder = NSAttributedString(string:"Chord Name",
      attributes:[NSForegroundColorAttributeName: UIColor(white: 0.8, alpha: 1), NSFontAttributeName: UIFont.boldSystemFontOfSize(17)])
    tabNameTextField.returnKeyType = .Done
    tabNameTextField.textAlignment = .Center
    editView.addSubview(tabNameTextField)
    tabNameTextField.addTarget(self, action: "textFieldTextChanged:", forControlEvents: UIControlEvents.EditingChanged)
    
    completeStringView.frame = CGRectMake(0, 6 / 20 * trueHeight, trueWidth, 15 / 20 * trueHeight)
    completeStringView.contentSize = CGSizeMake(5 * trueWidth, 15 / 20 * trueHeight)
    completeStringView.backgroundColor = UIColor.clearColor()
    
    completeImageView.frame = CGRectMake(0, 0, 5 * trueWidth, 15 / 20 * trueHeight)
    completeImageView.image = UIImage(named: "iPhone5_fullFretboard")
    completeStringView.addSubview(completeImageView)
    editView.addSubview(completeStringView)
    
    let singleTapOnString6View: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnString6View:")
    completeStringView.addGestureRecognizer(singleTapOnString6View)
    
    let tapOnEditView: UITapGestureRecognizer = UITapGestureRecognizer()
    tapOnEditView.addTarget(self, action: "tapOnEditView:")
    editView.addGestureRecognizer(tapOnEditView)
    
    addString6View()
    specificTabsScrollView.alpha = 0
    tabNameTextField.alpha = 0
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  // hide the keyboard
  
  func tapOnEditView(sender: UITapGestureRecognizer) {
    tabNameTextField.resignFirstResponder()
    stopJiggling()
    stopSpecificJiggling()
    stopMainViewJiggling()
  }
  
  func stopSpecificJiggling(){
    if longPressSpecificTabButton.count == 0 {
      return
    }
    for button in buttonOnSpecificScrollView {
      if button.accessibilityIdentifier == "isNotOriginal" {
        if let temp = longPressSpecificTabButton[button.tag] {
          stopNormalJinggling(temp)
        }
      }
    }
  }
  
  // add note button to view
  func addNoteButton(indexFret: Int, indexString: Int, originalPosition:CGPoint?=nil) {
    let noteButton: UIButton = UIButton()
    let buttonFret = (string6FretPosition[indexFret] + string6FretPosition[indexFret + 1]) / 2
    let buttonString = string6Position[indexString]
    let buttonWidth = 7 / 60 * trueHeight
    var original:CGPoint = CGPointZero
    if let tempOriginalPosition = originalPosition {
      original.x = tempOriginalPosition.x
      original.y = 6 / 20 * trueHeight - tempOriginalPosition.y - buttonWidth / 2
    } else {
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
    currentNoteButton = noteButton
    currentBaseButton = noteButton
    noteButtonOnCompeteScrollView = noteButton
    completeStringView.addSubview(noteButton)
    noteButton.alpha = 1
    
    jigglingTapGesture.addTarget(self, action: "startJiggling:")
    noteButton.addGestureRecognizer(jigglingTapGesture)
    jigglingTapGesture.requireGestureRecognizerToFail(jigglingLongPressGesture)
    
    jigglingLongPressGesture.addTarget(self, action: "startJiggling:")
    noteButton.addGestureRecognizer(jigglingLongPressGesture)
    jigglingLongPressGesture.minimumPressDuration = 0.01
    
    if originalPosition != nil {
      let duration:NSTimeInterval = NSTimeInterval(sqrt(2.0 * (buttonString - original.y) / 9.8) / 3)
      UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: CGFloat(0.6/duration), initialSpringVelocity:CGFloat(0.6/duration), options: [.CurveEaseInOut,.AllowUserInteraction], animations: {
        noteButton.alpha = 1
        noteButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
        }, completion: nil)
    } else {
      UIView.animateWithDuration(0.3, animations: {
        noteButton.alpha = 1
        noteButton.frame = CGRectMake(buttonFret - buttonWidth / 2, buttonString - buttonWidth / 2, buttonWidth, buttonWidth)
      })
    }
    addSpecificTabButton(noteButton.tag)
    if addedNoteButtonOnCompleteView == true {
      createEditFingerPoint(noteButton.tag)
    }
    for i in(6 - indexString)...5 {
      fingerPoint[i].hidden = false
    }
    oldTagString4 = 0
    oldTagString5 = 0
  }
  
  
  // choose the base note, move finger point
  func singleTapOnString6View(sender: UITapGestureRecognizer) {
    view.userInteractionEnabled = false
    if isJiggling {
      stopJiggling()
      stopSpecificJiggling()
    } else {
      var indexFret: Int = Int()
      var indexString: Int = Int()
      let location = sender.locationInView(completeStringView)
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
      if (indexString + 1) >= currentBaseButton.tag / 100 && indexString >= 3 && indexString <= 5{
        if !(((indexString + 1) == currentBaseButton.tag / 100) && (indexFret == currentBaseButton.tag % 100)) || (!addedNoteButtonOnCompleteView && !addNewTab) {
          currentBaseButton.removeFromSuperview()
          addNoteButton(indexFret, indexString: indexString)
          moveFingerPoint(indexFret, indexString: indexString)
          tabNameTextField.text = ""
          completeStringView.addSubview(fingerPoint[6 - indexString])
          fingerPoint[6 - (indexString + 1)].hidden = true
          fingerPoint[6 - (indexString + 1)].accessibilityIdentifier = "grayButton"
          fingerPoint[6 - (indexString + 1)].setImage(UIImage(named: "grayButton"), forState: UIControlState.Normal)
          addedNoteButtonOnCompleteView = true
          addNewTab = true
        }
      }
      if (indexString + 1) < currentBaseButton.tag / 100 {
        moveFingerPoint(indexFret, indexString: indexString)
      }
      PlayChordsManager.sharedInstance.playSingleNoteSound((indexString + 1) * 100 + indexFret)
    }
    view.userInteractionEnabled = true
  }
  
  // move finger point when tap on 6 string view
  func moveFingerPoint(indexFret: Int, indexString: Int) {
    view.userInteractionEnabled = false
    let buttonWidth: CGFloat = 5 / 60 * trueHeight
    let buttonX = (string6FretPosition[indexFret] + string6FretPosition[indexFret + 1]) / 2 - buttonWidth / 2
    let buttonY = string6Position[indexString] - buttonWidth / 2
    fingerPoint[5 - indexString].frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonWidth)
    fingerPoint[5 - indexString].tag = indexFret
    fingerPoint[5 - indexString].hidden = false
    UIView.animateWithDuration(0.3, animations: {
      self.fingerPoint[5 - indexString].alpha = 1
    })
    view.userInteractionEnabled = true
    tabFingerPointChanged = true
  }
  
  // create 6 finger point for new tabs
  func createEditFingerPoint(sender: Int) {
    tabFingerPointChanged = true
    let stringNumber = sender / 100
    let fretNumber = sender - stringNumber * 100
    for item in fingerPoint {
      item.removeFromSuperview()
    }
    
    fingerPoint.removeAll(keepCapacity: false)
    for var i = 5; i >= 0; i-- {
      let fingerButton: UIButton = UIButton()
      let buttonWidth: CGFloat = 5 / 60 * trueHeight
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
      fingerPoint.append(fingerButton)
      completeStringView.addSubview(fingerButton)
    }
  }
  
  // add tabs on specific scrol view
  func addSpecificTabButton(sender: Int) {
    view.userInteractionEnabled = false
    let index: NSNumber = NSNumber(integer: sender)
    specificTabSets.removeAll()
    specificTabSets = TabsDataManager.getTabsSets(index)
    let buttonHeight: CGFloat = 2 / 20 * trueHeight
    let buttonWidth: CGFloat = 4 / 20 * trueHeight
    // change specific tab button scrollview content frame
    let scrollviewWidth = (buttonWidth + 0.5 / 20 * trueWidth) * CGFloat(5) + 0.5 / 20 * trueWidth
    specificTabsScrollView.contentSize = CGSizeMake(scrollviewWidth, 2.5 / 20 * trueHeight)
    if specificTabSets.count > 5 {
      let tempScrollviewWidth = (buttonWidth + 0.6/20 * trueWidth) * CGFloat(specificTabSets.count)
      specificTabsScrollView.contentSize = CGSizeMake(tempScrollviewWidth, 2.5 / 20 * trueHeight)
    }
    specificTabsScrollView.contentOffset = CGPointZero
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
            specificButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
            if self.specificTabSets[i].isOriginal == true {
              specificButton.accessibilityIdentifier = "isOriginal"
              specificButton.layer.shadowOpacity = 1
              specificButton.layer.shadowRadius = 4
              specificButton.layer.shadowOffset = CGSize(width: 0, height: 0)
              specificButton.layer.shadowColor = UIColor(red: 94 / 255, green: 38 / 255, blue: 18 / 255, alpha: 1).CGColor
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
          delay = delay + 0.05
          UIView.animateWithDuration(0.2, delay: delay, options: .CurveEaseInOut, animations: {
            if item.isMemberOfClass(UIButton) {
              item.transform = CGAffineTransformMakeScale(1,1)
              item.alpha = 1
            }
            }, completion: nil)
        }
        if self.specificTabsScrollView.subviews.count == 0 {
          self.statusLabel.text = "Create a custom chord"
        }else{
          self.statusLabel.text = "Choose a chord or customize one"
        }
      }
    )
    view.userInteractionEnabled = true
  }
  
  
  // choose specific tabs, and generate the finger point for this tab
  func pressSpecificTabButton(sender: UIButton) {
    tabNameTextField.resignFirstResponder()
    currentSelectedSpecificTab = specificTabSets[sender.tag]
    tabNameTextField.text = currentSelectedSpecificTab.name
    let index = sender.tag
    tabFingerPointChanged = false
    addSpecificFingerPoint = true
    currentNoteButton = sender
    view.userInteractionEnabled = false
    PlayChordsManager.sharedInstance.playChordArpeggio(currentSelectedSpecificTab.content, delay: 0.04, completion: {
      complete in
      self.view.userInteractionEnabled = true
    })
    for item in fingerPoint {
      item.removeFromSuperview()
    }
    fingerPoint.removeAll(keepCapacity: false)
    createFingerPoint(index)
  }
  
  // create finger point for specific tabs
  func createFingerPoint(sender: Int) {
    let content = specificTabSets[sender].content
    let buttonWidth: CGFloat = 5 / 60 * trueHeight
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
      fingerPoint.append(fingerButton)// store all the finger point for exist tabs
      view.userInteractionEnabled = false
      UIView.animateWithDuration(0.3, animations: {
        fingerButton.alpha = 1
      })
      
      if i / 2 < 6 {
        completeStringView.addSubview(fingerButton)
      }
      view.userInteractionEnabled = true
    }
    let stringNumber = Int(specificTabSets[sender].index) / 100
    for i in 0...(6 - stringNumber) {
      fingerPoint[i].hidden = true
    }
    var midButtonX:CGFloat = 0
    if(maxButtonX - miniButtonX <= trueWidth){
      midButtonX = (miniButtonX + maxButtonX)/2.0
      UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut , .AllowUserInteraction], animations: {
        self.completeStringView.contentOffset.x = (midButtonX - self.trueWidth / 2) > 1 ? midButtonX - self.trueWidth/2 : 0
        }, completion: nil)
    }
  }
  
  // change the finger point status from gray button to black X
  func pressEditFingerButton(sender: UIButton) {
    tabFingerPointChanged = true
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
    view.userInteractionEnabled = false
    isJiggling = false
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
    view.userInteractionEnabled = true
  }
  
  // remove all oebjects on 6 string View
  func removeObjectsOnCompleteStringView() {
    currentNoteButton.removeFromSuperview()
    for item in fingerPoint {
      item.removeFromSuperview()
    }
  }
  
  // remove all objects on specific tab scroll view
  func removeObjectsOnSpecificTabsScrollView() {
    for item in specificTabsScrollView.subviews {
      item.removeFromSuperview()
    }
  }
  
  // music control view, include progressblock, timelabel, previous button, pan gesture, update, count down
  func addMusicControlView() {
    musicControlView.frame = CGRectMake(0, 2 / 20 * trueHeight, trueWidth, 6 / 20 * trueHeight)
    view.addSubview(musicControlView)
    previousButton.frame = CGRectMake(28 / 31 * trueWidth, 20, 3 / 31 * trueWidth, 6 / 20 * trueHeight-20)
    previousButton.imageEdgeInsets = UIEdgeInsetsMake(3 / 20 * trueHeight - 3 / 31 * trueWidth - 10, 0, 3 / 20 * trueHeight - 3 / 31 * trueWidth - 10, 0)
    previousButton.userInteractionEnabled = true
    previousButton.addTarget(self, action: "pressPreviousButton:", forControlEvents: UIControlEvents.TouchUpInside)
    previousButton.setImage(UIImage(named: "backspace"), forState: UIControlState.Normal)
    musicControlView.addSubview(previousButton)
    let musicPinchRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchOnMusicControlView:")
    musicControlView.addGestureRecognizer(musicPinchRecognizer)
    let musicPanRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panOnMusicControlView:")
    musicControlView.addGestureRecognizer(musicPanRecognizer)
    setUpTimeLabels()
    setUpPinchLable()
    backgroundView.frame = CGRectMake(0, 2 / 20 * trueHeight, trueWidth, 20)
    backgroundView.backgroundColor = UIColor(red: 32 / 255, green: 32 / 255, blue: 32 / 255, alpha: 1)
    let indicatorView: UIView = UIView()
    indicatorView.frame = CGRectMake(0.5 * trueWidth - 10, 10, 20, 6 / 20 * trueHeight - 10)
    indicatorView.backgroundColor = UIColor.clearColor()
    let indicator: UIImageView = UIImageView()
    indicator.alpha = 0.9
    indicator.frame = CGRectMake(0, 0, 20, 20)
    indicator.image = UIImage(named: "pointer")
    indicatorView.addSubview(indicator)
    let line: UIView = UIView()
    line.frame = CGRectMake(9, 20, 2, 6 / 20 * trueHeight - 30)
    line.backgroundColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.9)
    indicatorView.insertSubview(line, belowSubview: indicator)
    view.insertSubview(backgroundView, belowSubview: progressBlock)
    topLineView = UIView()
    topLineView.backgroundColor = UIColor.clearColor()
    progressBlock.addSubview(topLineView)
    musicControlView.addSubview(indicatorView)
    setUpTopLine()
  }
  
  func pinchOnMusicControlView(sender: UIPinchGestureRecognizer) {
    if sender.numberOfTouches() == 2 {
      if sender.state == .Began {
        beginScale = sender.scale
        endScaleNumber = tabsEditorProgressWidthMultiplier
        currentScale.text = NSString(format: "%.1f", tabsEditorProgressWidthMultiplier) as String
        pinchWrapper.hidden = false
      } else if sender.state == .Changed {
        let scaleChange = sender.scale - beginScale
        tabsEditorProgressWidthMultiplier = endScaleNumber + (endScaleNumber*scaleChange)
        if(tabsEditorProgressWidthMultiplier > maxScaleNumber){
          tabsEditorProgressWidthMultiplier = maxScaleNumber
        }else if (tabsEditorProgressWidthMultiplier < minScaleNumber) {
          tabsEditorProgressWidthMultiplier = minScaleNumber
        }
        currentScale.text = NSString(format: "%.1f", tabsEditorProgressWidthMultiplier) as String
        updateFramePosition()
      }
    }
    if (sender.state == .Ended || sender.state == .Cancelled){
      endScaleNumber = tabsEditorProgressWidthMultiplier
      pinchWrapper.hidden = true
    }
  }
  
  func updateFramePosition() {
    for item in topLineView.subviews {
      item.removeFromSuperview()
    }
    for item in allTabsOnMusicLine {
      let presentPosition = CGFloat(Float(item.time) / Float(duration))
      item.tabView.frame.origin = CGPointMake(presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier), item.tabView.frame.origin.y)
    }
    setUpTopLine()
  }
  
  
  func setUpTopLine() {
    let presentPosition = CGFloat(Float(currentTime) / Float(duration))
    progressBlock.frame = CGRectMake((0.5) * trueWidth - presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier), progressBlock.frame.origin.y, tabsEditorProgressWidthMultiplier * CGFloat(theSong.getDuration()), progressBlock.frame.size.height)
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
    currentScale.text = NSString(format: "%.1f", tabsEditorProgressWidthMultiplier) as String
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
    originalScale.text = NSString(format: "%.1f", tabsEditorProgressWidthMultiplier) as String
    originalScale.textAlignment = .Center
    originalScale.backgroundColor = UIColor.clearColor()
    pinchWrapper.addSubview(originalScale)
  }
  
  func setUpCountdownView() {
    countdownView = CountdownView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    countdownView.center = musicControlView.center
    countdownView.backgroundColor = UIColor.clearColor()
    countdownView.hidden = true
    view.addSubview(countdownView)
  }
  
  
  // pan on music control view to change music time and progressblock time
  func panOnMusicControlView(sender: UIPanGestureRecognizer) {
    if sender.state == .Began {
      removeDoubleArrowView()
      isPanning = true
      timer.invalidate()
      timer = NSTimer()
      wrapper.hidden = false
      wrapper.alpha = 0.1
      UIView.animateWithDuration(0.25, animations: {
        animate in
        self.wrapper.alpha = 1
      })
    } else if sender.state == .Ended {
      isPanning = false
      startTime.setTime(Float(currentTime))
      wrapper.hidden = true
      if isDemoSong {
        avPlayer.currentTime = currentTime
        if avPlayer.playing {
          startTimer()
        }
      } else {
        musicPlayer.currentPlaybackTime = currentTime
        if musicPlayer.playbackState == .Playing {
          startTimer()
        }
      }
    } else if sender.state == .Changed {
      let translation = sender.translationInView(view)
      currentBaseButton.center = CGPointMake(currentBaseButton.center.x, currentBaseButton.center.y)
      sender.setTranslation(CGPointZero, inView: view)
      if currentTime >= -0.1 && currentTime <= duration + 0.1 {
        let timeChange = NSTimeInterval(-translation.x / tabsEditorProgressWidthMultiplier)
        toTime = currentTime + timeChange
        if toTime < 0 {
          toTime = 0
        } else if toTime > duration {
          toTime = duration
        }
        currentTime = toTime
        startTime.setTime(Float(currentTime))
        let persent = CGFloat(currentTime) / CGFloat(duration)
        progressBlock.frame.origin.x = 0.5 * trueWidth - persent * (CGFloat(theSong.getDuration() * Float(tabsEditorProgressWidthMultiplier)))
        currentTimeLabel.text = TimeNumber(time: Float(currentTime)).toDisplayString()
        // find the current tab according to the current time and make the current tab view to yellow
        findCurrentTabView()
      }
    }
  }
  
  func startTimer() {
    if timer.valid {
      return
    }
    if isDemoSong {
      avPlayer.rate = speed
    } else {
      musicPlayer.currentPlaybackRate = speed
    }
    playPauseButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
    removeDoubleArrowView()
    timer = NSTimer.scheduledTimerWithTimeInterval(1 / Double(stepPerSecond) / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
  }
  
  func startCountdown() {
    countDownStartSecond--
    countdownView.setNumber(countDownStartSecond)
    if countDownStartSecond <= 0 {
      countdownTimer.invalidate()
      countdownView.hidden = true
      countDownStartSecond = 3
      if isDemoSong {
        avPlayer.play()
      } else {
        musicPlayer.play()
      }
      view.userInteractionEnabled = true
      toTime = duration + 1
      startTimer()
      countdownTimer.invalidate()
      countdownTimer = NSTimer()
    }
  }
  
  // pause the music or restart it, and count down
  func singleTapOnMusicControlView(sender: UIButton) {
    removeDoubleArrowView()
    if isDemoSong ? avPlayer.playing : (musicPlayer.playbackState == .Playing) {
      playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
      isPlaying = false
      //animate down progress block
      view.userInteractionEnabled = false
      //pause music and stop timer
      if isDemoSong {
        avPlayer.pause()
      } else {
        musicPlayer.pause()
      }
      timer.invalidate()
      timer = NSTimer()
      view.userInteractionEnabled = true
    } else {
      playPauseButton.setImage(UIImage(named: "pauseButton"), forState: UIControlState.Normal)
      isPlaying = true
      //animate up progress block in 3 seconds, because of the the limited height we are not doing the jump animation
      view.userInteractionEnabled = false
      UIView.animateWithDuration(3.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.progressBlock!.alpha = 1.0
        }, completion: nil)
      //start counting down 3 seconds
      //disable tap gesture that inadvertly starts timer
      countdownView.hidden = false
      countdownView.setNumber(countDownStartSecond)
      countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
      NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
    }
  }
  
  // string and fret position
  func createStringAndFretPosition() {
    // the postion for 6 string view
    let string6Height: CGFloat = 7 / 60 * trueHeight
    let fret6Width = trueWidth / 5
    // the position for 3 string view
    let string3Height: CGFloat = 11 / 60 * trueHeight
    let fret3Width = trueWidth / 5
    for i in 0..<26 {
      string6FretPosition.append(CGFloat(i) * fret6Width)
      string3FretPosition.append(CGFloat(i) * fret3Width)
      string3FretChangeingPosition[i] = CGFloat(i) * fret3Width
      if i < 6 {
        if i == 0 {
          string6Position.append(string6Height / 2)
        } else {
          string6Position.append(string6Position[i - 1] + string6Height)
        }
      }
      if i < 3 {
        if i == 0 {
          string3Position.append(string3Height / 2)
        } else {
          string3Position.append(string3Position[i - 1] + string3Height)
        }
      }
    }
  }
  
  func addString6View() {
    let string6Height: CGFloat = 7 / 60 * trueHeight
    for i in 0..<6 {
      let tempStringView: UIView = UIView()
      tempStringView.frame = CGRectMake(0, CGFloat(i) * string6Height, trueWidth * 5, string6Height)
      if i == 5 {
        tempStringView.frame = CGRectMake(0, CGFloat(i) * string6Height, trueWidth * 5, string6Height + 1 / 20 * trueHeight)
      }
      tempStringView.backgroundColor = UIColor.clearColor()
      completeStringView.addSubview(tempStringView)
      string6View.append(tempStringView)
    }
  }
  
  func createSoundWave() {
    let frame = CGRectMake(0.5 * trueWidth, 2 / 20 * trueHeight, tabsEditorProgressWidthMultiplier * CGFloat(theSong.getDuration()), 6 / 20 * trueHeight)
    progressBlock = UIView(frame: frame)
    if isDemoSong {
      let url: NSURL = theSong.getURL() as! NSURL
      avPlayer = try! AVAudioPlayer(contentsOfURL: url)
      duration = avPlayer.duration
      avPlayer.enableRate = true
      avPlayer.rate = 1.0
      avPlayer.volume = 1
      return
    }
    recoverMode = MusicManager.sharedInstance.saveMusicPlayerState([theSong as! MPMediaItem])
    duration = ((theSong as! MPMediaItem).playbackDuration.isNaN ? 1500 : (theSong as! MPMediaItem).playbackDuration)
  }
  
  func update() {
    if startTime.toDecimalNumer() > Float(duration) - 0.15 {
      if isDemoSong {
        avPlayer.pause()
      } else {
        musicPlayer.pause()
        musicPlayer.skipToNextItem()
      }
      timer.invalidate()
      timer = NSTimer()
      startTime.setTime(0)
      currentTime = 0
      if isDemoSong {
        avPlayer.currentTime = currentTime
      }else{
        musicPlayer.currentPlaybackTime = currentTime
      }
      playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
    }
    if !isPanning {
      let tempPlaytime = !isDemoSong ? musicPlayer.currentPlaybackTime : avPlayer.currentTime
      if startTime.toDecimalNumer() - Float(toTime) < (1 * speed ) && startTime.toDecimalNumer() - Float(toTime) >= 0 {
        startTime.addTime(Int(100 / stepPerSecond))
        currentTime = NSTimeInterval(startTime.toDecimalNumer()) - 0.01
        if (tempPlaytime.isNaN || tempPlaytime == 0){
          startTime.setTime(0)
          currentTime = 0
        }
      } else {
        if !tempPlaytime.isNaN {
          startTime.setTime(Float(tempPlaytime))
          currentTime = NSTimeInterval(startTime.toDecimalNumer())
        } else {
          startTime.addTime(Int(100 / stepPerSecond))
          currentTime = NSTimeInterval(startTime.toDecimalNumer()) - 0.01
        }
      }
    }
    if !isDemoSong {
      if(duration >= 1499 && !(theSong as! MPMediaItem).playbackDuration.isNaN){
        duration = (theSong as! MPMediaItem).playbackDuration
      }
    }
    //
    //refresh current time label
    currentTimeLabel.text = TimeNumber(time: Float(currentTime)).toDisplayString()
    //refresh progress block
    let presentPosition = CGFloat(Float(currentTime) / Float(duration))
    //MARK: progessBlock width
    progressBlock.frame.origin.x = 0.5 * trueWidth - presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier)
    findCurrentTabView()
  }
  
  func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) {
    let name = fretsNumber[fromIndexPath.item]
    fretsNumber.removeAtIndex(fromIndexPath.item)
    fretsNumber.insert(name, atIndex: toIndexPath.item)
    let temp = mainViewDataArray[fromIndexPath.item]
    mainViewDataArray.removeAtIndex(fromIndexPath.item)
    mainViewDataArray.insert(temp, atIndex: toIndexPath.item)
    let tempImage = string3BackgroundImage[fromIndexPath.item]
    string3BackgroundImage.removeAtIndex(fromIndexPath.item)
    string3BackgroundImage.insert(tempImage, atIndex: toIndexPath.item)
  }
  
  
  func backToMainView() {
    view.userInteractionEnabled = false
    if isCompleteStringViewScroll {
      isCompleteStringViewScroll = false
    }
    if originaloffset != -1 {
      collectionView.contentOffset.x = originaloffset
    } else {
      collectionView.contentOffset.x = completeStringView.contentOffset.x
    }
    originaloffset = -1
    baseNoteLocation = -1
    changeMenuButtonStatus(false)
    specificTabsScrollView.alpha = 0
    tabNameTextField.alpha = 0
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
    backButtonRotation(isLeft: true)
    tabNameTextField.text = ""
    for item in fingerPoint {
      item.removeFromSuperview()
    }
    oldTagString4 = 0
    oldTagString5 = 0
    if(isJiggling == true){
      stopSpecificJiggling()
    }
    isJiggling = false
    addedNoteButtonOnCompleteView = false
    currentBaseButton.tag = 400
    noteButtonOnCompeteScrollView.removeFromSuperview()
    fingerPoint.removeAll(keepCapacity: false)
    statusLabel.text = "Tabs Editor"
    addNewTab = false
    intoEditView = false
    tabFingerPointChanged = false
    currentNoteButton = UIButton()
    currentTabViewIndex = Int()
    removeObjectsOnCompleteStringView()
    removeObjectsOnSpecificTabsScrollView()
    view.userInteractionEnabled = true
    //show second tutorial when there is a chord on the fretboard for the first time
    if !NSUserDefaults.standardUserDefaults().boolForKey(kShowTabsEditorTutorialA) && NSUserDefaults.standardUserDefaults().boolForKey(kShowTabsEditorTutorialB) && noteButtonWithTabArray.count > 0 {
      showTutorial(first: false)
    }
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
    let labelHeight = ( progressBlock.frame.height - 20 ) / CGFloat(labelHeightNumber)
    let width = trueWidth / 18
    var frame: CGRect = CGRect()
    for i in 0..<endIndex {
      if compareTabs(allTabsOnMusicLine[i].tab, tab2: tab) {
        let tempFrame = CGRectMake(0 + CGFloat(currentTime / duration) * (progressBlock.frame.width), allTabsOnMusicLine[i].tabView.frame.origin.y, allTabsOnMusicLine[i].tabView.frame.width, allTabsOnMusicLine[i].tabView.frame.height)
        return tempFrame
      }
    }
    let numberOfUnrepeatedTab: Int = numberOfUnrepeatedTabOnMainView(endIndex, allTabsOnMusicLine: allTabsOnMusicLine)
    let tempSender = CGFloat(numberOfUnrepeatedTab % labelHeightNumber)
    let dynamicHeight = labelHeight * tempSender + 20
    frame = CGRectMake(CGFloat(currentTime*Double(tabsEditorProgressWidthMultiplier)-1), dynamicHeight, width, labelHeight)
    return frame
  }
  
  // caluclate the tab on music line without repeat
  func numberOfUnrepeatedTabOnMainView(endIndex: Int, allTabsOnMusicLine: [tabOnMusicLine]) -> Int{
    var set = [String: Int]()
    for i in 0..<endIndex {
      if let val = set["\(allTabsOnMusicLine[i].tab.index) \(allTabsOnMusicLine[i].tab.name)"] {
        set["\(allTabsOnMusicLine[i].tab.index) \(allTabsOnMusicLine[i].tab.name)"] = val + 1
      } else {
        set["\(allTabsOnMusicLine[i].tab.index) \(allTabsOnMusicLine[i].tab.name)"] = 1
      }
    }
    return set.count
  }
  
  // press the note button to add the tab in music line
  func pressMainViewNoteButton(sender: UIButton) {
    if isJiggling {
      return
    }
    var inserted: Bool = false
    let index = sender.tag
    let content = noteButtonWithTabArray[index].tab.content
    PlayChordsManager.sharedInstance.playChordArpeggio(content, delay: 0.04, completion: {
      complete in
    })
    let returnValue = addTabViewOnMusicControlView(index)
    for var i = 0; i < allTabsOnMusicLine.count - 1; i++ {
      if currentTime <= allTabsOnMusicLine[0].time {
        if(returnValue.1.tab.content == allTabsOnMusicLine[0].tab.content && returnValue.1.time == allTabsOnMusicLine[0].time) {
          findCurrentTabView()
          return
        }
        allTabsOnMusicLine.insert(returnValue.1, atIndex: 0)
        isShowDiscardAlert = true
        inserted = true
        break
      } else if currentTime > allTabsOnMusicLine[i].time && currentTime <= allTabsOnMusicLine[i + 1].time {
        if(returnValue.1.tab.content == allTabsOnMusicLine[i+1].tab.content && returnValue.1.time == allTabsOnMusicLine[i+1].time) {
          findCurrentTabView()
          return
        }
        allTabsOnMusicLine.insert(returnValue.1, atIndex: i + 1)
        isShowDiscardAlert = true
        inserted = true
        break
      }
    }
    if !inserted {
      if allTabsOnMusicLine.count > 0 {
        if (returnValue.1.tab.content == allTabsOnMusicLine[0].tab.content && returnValue.1.time == allTabsOnMusicLine[0].time) {
          findCurrentTabView()
          return
        }
      }
      allTabsOnMusicLine.append(returnValue.1)
      isShowDiscardAlert = true
    }
    progressBlock.addSubview(returnValue.0)
    findCurrentTabView()
  }
  
  func addTabViewOnMusicControlView(sender: Int) -> (UIView, tabOnMusicLine) {
    let tempView: UIView = UIView()
    tempView.backgroundColor = UIColor.silverGray().colorWithAlphaComponent(0.6)
    tempView.layer.cornerRadius = 2
    var tempStruct: tabOnMusicLine = tabOnMusicLine()
    let name = noteButtonWithTabArray[sender].tab.name
    tempView.frame = setMainViewTabPositionInRange(noteButtonWithTabArray[sender].tab, endIndex: allTabsOnMusicLine.count, allTabsOnMusicLine: allTabsOnMusicLine)
    let tempLabelView: UILabel = UILabel()
    tempLabelView.frame = CGRectMake(0, 0, tempView.frame.width, tempView.frame.height)
    tempLabelView.layer.cornerRadius = 2
    tempLabelView.font = UIFont.systemFontOfSize(11)
    tempLabelView.textColor = UIColor.whiteColor()
    tempLabelView.textAlignment = NSTextAlignment.Center
    tempLabelView.numberOfLines = 1
    tempLabelView.text = name
    tempView.addSubview(tempLabelView)
    tempStruct.tabView = tempView
    tempStruct.time = currentTime
    tempStruct.tab = noteButtonWithTabArray[sender].tab
    return (tempView, tempStruct)
  }
  
  //Mark: press the button on the top functions
  // back to the main view or back to root view
  func pressBackButton(sender: UIButton) {
    if intoEditView == true {
      view.userInteractionEnabled = false
      backToMainView()
      view.userInteractionEnabled = true
    } else {
      if isShowDiscardAlert {
        let alertController = UIAlertController(title: nil, message: "Do you want to discard all changes?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: {
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
      } else {
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
    view.userInteractionEnabled = false
    UIView.animateWithDuration(0.3, animations: {
      self.tuningMenu.frame = CGRect(x: -self.tuningMenu.frame.width, y: 0, width: self.tuningMenu.frame.width, height: self.tuningMenu.frame.height)
      }, completion:
      {
        completed in
        self.actionDismissLayerButton.hidden = true
      }
    )
    view.userInteractionEnabled = true
  }
  
  func pressTuningButton(sender: UIButton) {
    let tempx = collectionView.contentOffset.x
    view.userInteractionEnabled = false
    backToMainView()
    view.userInteractionEnabled = true
    view.userInteractionEnabled = false
    actionDismissLayerButton.hidden = false // what is this button?
    collectionView.contentOffset.x = tempx
    removeDoubleArrowView()
    UIView.animateWithDuration(0.3, animations: {
      self.tuningMenu.frame = CGRect(x: 0, y: 0, width: self.tuningMenu.frame.width, height: self.trueHeight)
      self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
      self.actionDismissLayerButton.alpha = 0.3
    })
    
    view.userInteractionEnabled = true
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
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  func changeMenuButtonStatus(sender: Bool) {
    resetButton.hidden = sender
    tuningButton.hidden = sender
    playPauseButton.hidden = sender
    addButton.hidden = sender
    statusLabel.hidden = !sender
    if sender {
      backgroundView.alpha = 0
    } else {
      backgroundView.alpha = 1
    }
    if sender {
      //savebutton
      doneButton.setImage(UIImage(named: "saveButton"), forState: UIControlState.Normal)
      doneButton.imageEdgeInsets = UIEdgeInsetsMake(0.3 / 20 * trueHeight, 0.1 / 20 * trueHeight, 0.8 / 20 * trueHeight, 0.6 / 20 * trueHeight)
    }else{
      //savetext
      doneButton.setImage(UIImage(named: "saveText"), forState: UIControlState.Normal)
      doneButton.imageEdgeInsets = UIEdgeInsetsMake(0.4 / 20 * trueHeight, 0.1 / 20 * trueHeight, 0.7 / 20 * trueHeight, 0.6 / 20 * trueHeight)
    }
  }
  
  
  func pressAddButton(sender: UIButton) {
    if isJiggling {
      stopMainViewJiggling()
    }
    if doubleArrowView != nil {
      doubleArrowView.alpha = 0
    }
    cropFullStringImageView(Int(capoStepper.value))
    changeMenuButtonStatus(true)
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
    backgroundView.alpha = 0
    progressBlock.alpha = 0
    collectionView.alpha = 0
    statusLabel.text = "Add a new chord"
    intoEditView = true
    completeStringView.contentOffset = collectionView.contentOffset
    UIView.animateWithDuration(0.3, animations: {
      self.completeStringView.alpha = 1
      self.specificTabsScrollView.alpha = 1
      self.tabNameTextField.alpha = 1
      self.completeStringView.frame = CGRectMake(0, 3 / 20 * self.trueHeight, self.trueWidth, 15 / 20 * self.trueHeight)
    })
    backButtonRotation(isLeft: false)
    createEditFingerPoint(400)
    view.userInteractionEnabled = true
  }

  func pressDoneButton(sender: UIButton?=nil) {
    pressDoneButton = false
    if intoEditView == true {
      if addNewTab == true {
        var addSuccessed: Bool = true
        if tabFingerPointChanged == true {
          let index = currentBaseButton.tag
          let name: String = tabNameTextField.text!.replace(" ", replacement: "")
          tabNameTextField.text! = name
          var content: String = String()
          if name == "" || name.containsString(" ") {
            if specificTabsScrollView.subviews.count == 0 || (specificTabsScrollView.subviews.count == 1 && specificTabsScrollView.subviews[0].isKindOfClass(UILabel)) {
              removeObjectsOnSpecificTabsScrollView()
              let addBaseNoteLabel: UILabel = UILabel()
              addBaseNoteLabel.frame = CGRectMake(0, 0, specificTabsScrollView.frame.size.width, specificTabsScrollView.frame.size.height)
              addBaseNoteLabel.text = "Please input a valid chord name"
              addBaseNoteLabel.font = UIFont.systemFontOfSize(17)
              addBaseNoteLabel.backgroundColor = UIColor(white: 0.7, alpha: 0.3)
              addBaseNoteLabel.textAlignment = .Center
              addBaseNoteLabel.textColor = UIColor.whiteColor()
              specificTabsScrollView.addSubview(addBaseNoteLabel)
              shakeAnimationScrollView()
              tabNameTextField.text = currentBaseButton.titleLabel?.text
              tabNameTextField.becomeFirstResponder()
              AnimationStatusLabel("Input Chord Name")
            } else {
              tabNameTextField.text = currentBaseButton.titleLabel?.text
              shakeAnimationStatusLabel()
              shakeAnimationScrollView()
              AnimationStatusLabel("Choose a chord or customize one")
              tabNameTextField.becomeFirstResponder()
              pressDoneButton = true
            }
            addSuccessed = false
          } else {
            for i in 0..<6 {
              if fingerPoint[i].accessibilityIdentifier == "blackX" {
                content = content + "xx"
              } else {
                if fingerPoint[i].tag <= 9 {
                  content = content + "0\(fingerPoint[i].tag)"
                } else {
                  content = content + "\(fingerPoint[i].tag)"
                }
              }
            }
            currentSelectedSpecificTab = NormalTabs()
            if let compareExistTabs = TabsDataManager.getUniqueTab(index, name: name, content: content)?.tabs {
              currentSelectedSpecificTab.tabs = compareExistTabs
            } else {
              let tempTabs: Tabs = TabsDataManager.addNewTabs(index, name: name, content: content)
              currentSelectedSpecificTab.tabs = tempTabs
            }
            currentNoteButton.setTitle(name, forState: UIControlState.Normal)
            currentSelectedSpecificTab.index = index
            currentSelectedSpecificTab.name = name
            currentSelectedSpecificTab.content = content
            addSuccessed = true
            addSpecificFingerPoint = true
            backToMainView()
          }
        }
        if addSuccessed == true && addSpecificFingerPoint == true {
          var addNew: Bool = true
          if let _ = currentSelectedSpecificTab {
            let fretNumber = Int(currentSelectedSpecificTab.index) - Int(currentSelectedSpecificTab.index) / 100 * 100
            for i in 0..<mainViewDataArray.count {
              if mainViewDataArray[i].fretNumber == fretNumber {
                for j in 0..<mainViewDataArray[i].noteButtonsWithTab.count {
                  if compareTabs(mainViewDataArray[i].noteButtonsWithTab[j].tab, tab2: currentSelectedSpecificTab) {
                    let alertController = UIAlertController(title: "Warning", message: "This tab already exist on Main View", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: { action in
                      self.collectionView.reloadData()
                      self.statusLabel.text = "Tabs Editor"
                      self.backToMainView()
                    }))
                    presentViewController(alertController, animated: true, completion: nil)
                    addNew = false
                  }
                }
              }
            }
          }
          if addNew == true {
            addTabsToMainViewDataArray(currentSelectedSpecificTab)
            reorganizeMainViewDataArray()
            collectionView.reloadData()
            statusLabel.text = "Tabs Editor"
            backToMainView()
          }
        }
      } else {
        removeObjectsOnSpecificTabsScrollView()
        let addBaseNoteLabel: UILabel = UILabel()
        addBaseNoteLabel.frame = CGRectMake(0, 0, specificTabsScrollView.frame.size.width, specificTabsScrollView.frame.size.height)
        addBaseNoteLabel.text = "Please select a base note on the lower three strings"
        addBaseNoteLabel.font = UIFont.systemFontOfSize(15)
        addBaseNoteLabel.backgroundColor = UIColor(white: 0.7, alpha: 0.3)
        addBaseNoteLabel.textAlignment = .Center
        addBaseNoteLabel.textColor = UIColor.whiteColor()
        specificTabsScrollView.addSubview(addBaseNoteLabel)
        shakeAnimationScrollView()
        AnimationStatusLabel("Choose bass note")
      }
    } else {
      if isDemoSong {
        avPlayer.pause()
      } else {
        musicPlayer.pause()
      }
      timer.invalidate()
      timer = NSTimer()
      currentTime = 0
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
      if allChords.count < 3 {
        let alertController = UIAlertController(title: nil, message: "We need to sync at least 3 chords!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
        return
      }
      let savedTabsSetId = CoreDataManager.getTabs(theSong, fetchingUsers: true).3
      CoreDataManager.saveTabs(theSong, chords: allChords, tabs: allTabs, times: allTimes, tuning: tuningOfTheSong, capo: Int(capoStepper.value), userId:
        Int(CoreDataManager.getCurrentUser()!.id), tabsSetId:  savedTabsSetId > 0 ?savedTabsSetId : kLocalSetId, visible: isPublic, lastEditedDate: NSDate())
      if let songVC = songViewController {
        songVC.updateMusicData(theSong)
      }
      tuningMenu.hidden = true
      progressBlock.hidden = true
      removeNotification()
      if isDemoSong {
        avPlayer.pause()
      } else {
        musicPlayer.pause()
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
      dismissViewControllerAnimated(true, completion: {
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
    let buttonWidth = trueWidth / 5 / 3
    let stringPosition = string3Position[buttonY - 3] - buttonWidth / 2
    let fretPosition = trueWidth / 5 / 2 - buttonWidth / 2
    tempButton.setTitle(sender.name, forState: UIControlState.Normal)
    tempButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
    tempButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    tempButton.addTarget(self, action: "pressMainViewNoteButton:", forControlEvents: UIControlEvents.TouchUpInside)
    tempButton.layer.cornerRadius = 0.5 * buttonWidth
    tempButton.frame = CGRectMake(fretPosition, stringPosition, buttonWidth, buttonWidth)
    let longPress = UILongPressGestureRecognizer(target: self, action: "startMainViewJiggling:")
    longPressMainViewNoteButton[tempButton] = longPress
    tempButton.addGestureRecognizer(longPress)
    let tempTab: NormalTabs = NormalTabs()
    tempTab.index = sender.index
    tempTab.name = sender.name
    tempTab.content = sender.content
    tempTab.isOriginal = sender.isOriginal
    let tempNoteButtonWithTab: noteButtonWithTab = noteButtonWithTab()
    tempNoteButtonWithTab.noteButton = tempButton
    tempNoteButtonWithTab.tab = tempTab
    for item in mainViewDataArray {
      if item.fretNumber == Int(tempTab.index) - Int(tempTab.index) / 100 * 100 {
        item.noteButtonsWithTab.append(tempNoteButtonWithTab)
        let temp6offset = string6FretPosition[tempTab.index.integerValue % 100] - completeStringView.contentOffset.x
        let temp3offset = string3FretChangeingPosition[tempTab.index.integerValue % 100]! - temp6offset
        if temp3offset < 0 {
          originaloffset = 0
        } else if (temp3offset > string6FretPosition[string6FretPosition.count - 1 - Int(capoStepper.value)] - trueWidth) {
          originaloffset = string6FretPosition[string6FretPosition.count - 1 - Int(capoStepper.value)] - trueWidth
        } else {
          originaloffset = temp3offset
        }
      }
    }
    noteButtonWithTabArray.append(tempNoteButtonWithTab)
    isShowDiscardAlert = true
    tempNoteButtonWithTab.noteButton.tag = noteButtonWithTabArray.count - 1
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
    for item in mainViewDataArray {
      let buttonWidth: CGFloat = trueWidth / 5 / 3 * 1.5
      let buttonWidth2: CGFloat = trueWidth / 5 / 3 * 1.5
      let buttonWidth3: CGFloat = trueWidth / 5 / 3 * 1
      var buttonX2: [CGFloat] = [trueWidth / 5 / 2 - buttonWidth2, trueWidth / 5 / 2]
      var buttonX3: [CGFloat] = [0, trueWidth / 5 / 2 - buttonWidth3 / 2, trueWidth / 5 / 2 + buttonWidth3 / 2]
      for i in 4...6 {
        var tempButtonArray: [noteButtonWithTab] = [noteButtonWithTab]()
        for buttonWithTab in item.noteButtonsWithTab {
          if Int(buttonWithTab.tab.index) / 100 == i {
            tempButtonArray.append(buttonWithTab)
          }
        }
        if tempButtonArray.count == 1 {
          tempButtonArray[0].noteButton.frame = CGRectMake(trueWidth / 5 / 2 - buttonWidth / 2, string3Position[Int(tempButtonArray[0].tab.index) / 100 - 4] - buttonWidth / 2, buttonWidth, buttonWidth)
          tempButtonArray[0].noteButton.layer.cornerRadius = 0.5 * buttonWidth
          tempButtonArray[0].noteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
        }
        if tempButtonArray.count == 2 {
          for j in 0..<tempButtonArray.count {
            tempButtonArray[j].noteButton.frame = CGRectMake(buttonX2[j], string3Position[Int(tempButtonArray[j].tab.index) / 100 - 4] - buttonWidth2 / 2, buttonWidth2, buttonWidth2)
            tempButtonArray[j].noteButton.layer.cornerRadius = 0.5 * buttonWidth2
            tempButtonArray[j].noteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
          }
        } else if tempButtonArray.count == 3 {
          for j in 0..<tempButtonArray.count {
            tempButtonArray[j].noteButton.frame = CGRectMake(buttonX3[j], string3Position[Int(tempButtonArray[j].tab.index) / 100 - 4] - buttonWidth3 / 2, buttonWidth3, buttonWidth3)
            tempButtonArray[j].noteButton.layer.cornerRadius = 0.5 * buttonWidth3
            tempButtonArray[j].noteButton.titleLabel!.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
          }
        }
      }
    }
  }
  
  func pressPreviousButton(sender: UIButton) {
    removeDoubleArrowView()
    if currentTabViewIndex == -1 {
      return
    }
    let stepper = 10.0 / Double(tabsEditorProgressWidthMultiplier)
    if allTabsOnMusicLine.count > 1 {
      view.userInteractionEnabled = false
      if currentTabViewIndex == allTabsOnMusicLine.count - 1 {
        if currentTime > allTabsOnMusicLine[currentTabViewIndex].time + 3.2 * stepper {
          if isDemoSong {
            let temprate = avPlayer.rate
            avPlayer.currentTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
            currentTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
            toTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
            avPlayer.rate = 0
            timer.invalidate()
            timer = NSTimer()
            startTime.setTime(Float(allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper))
            previousButton.enabled = false
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
              self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - CGFloat(self.currentTime * Double(self.tabsEditorProgressWidthMultiplier))
              }, completion: {
                completed in
                self.findCurrentTabView()
                self.previousButton.enabled = true
                self.avPlayer.rate = temprate
                self.view.userInteractionEnabled = true
                if temprate > 0 {
                  self.startTimer()
                }
                
            })
          } else {
            let temprate = musicPlayer.currentPlaybackRate
            musicPlayer.currentPlaybackTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
            currentTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
            timer.invalidate()
            timer = NSTimer()
            startTime.setTime(Float(allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper))
            toTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
            previousButton.enabled = false
            musicPlayer.currentPlaybackRate = 0
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
              self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - CGFloat(self.currentTime * Double(self.tabsEditorProgressWidthMultiplier))
              }, completion: {
                completed in
                self.findCurrentTabView()
                self.previousButton.enabled = true
                self.musicPlayer.currentPlaybackRate = temprate
                self.view.userInteractionEnabled = true
                if temprate > 0 {
                  self.startTimer()
                }
            })
          }
          return
        }
      }
      allTabsOnMusicLine[currentTabViewIndex].tabView.removeFromSuperview()
      allTabsOnMusicLine.removeAtIndex(currentTabViewIndex)
      isShowDiscardAlert = true
      currentTabViewIndex = --currentTabViewIndex
      if (currentTabViewIndex < 0) {
        currentTabViewIndex = 0
      }
      if isDemoSong {
        let temprate = avPlayer.rate
        avPlayer.currentTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
        currentTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
        avPlayer.rate = 0
        toTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
        previousButton.enabled = false
        timer.invalidate()
        timer = NSTimer()
        startTime.setTime(Float(allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper))
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
        let temprate = musicPlayer.currentPlaybackRate
        musicPlayer.currentPlaybackTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
        currentTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
        previousButton.enabled = false
        musicPlayer.currentPlaybackRate = 0
        toTime = allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper
        timer.invalidate()
        timer = NSTimer()
        startTime.setTime(Float(allTabsOnMusicLine[currentTabViewIndex].time + 0.1 * stepper))
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
    } else if allTabsOnMusicLine.count == 1 && currentTabViewIndex  == 0{
      view.userInteractionEnabled = false
      allTabsOnMusicLine[currentTabViewIndex].tabView.removeFromSuperview()
      isShowDiscardAlert = true
      allTabsOnMusicLine.removeAtIndex(currentTabViewIndex)
      currentTabViewIndex = 0
      currentTime = 0
      if isDemoSong {
        let temprate = avPlayer.rate
        avPlayer.currentTime = 0
        avPlayer.rate = 0
        toTime = 0
        timer.invalidate()
        timer = NSTimer()
        startTime.setTime(0)
        previousButton.enabled = false
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
        let temprate = musicPlayer.currentPlaybackRate
        musicPlayer.currentPlaybackTime = 0
        musicPlayer.currentPlaybackRate = 0
        timer.invalidate()
        timer = NSTimer()
        startTime.setTime(0)
        toTime = 0
        previousButton.enabled = false
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
      view.userInteractionEnabled = false
      currentTime = 0
      currentTabViewIndex  == 0
      if isDemoSong {
        let temprate = avPlayer.rate
        avPlayer.currentTime = 0
        avPlayer.rate = 0
        timer.invalidate()
        timer = NSTimer()
        startTime.setTime(0)
        toTime = 0
        previousButton.enabled = false
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
        let temprate = musicPlayer.currentPlaybackRate
        musicPlayer.currentPlaybackTime = 0
        musicPlayer.currentPlaybackRate = 0
        timer.invalidate()
        timer = NSTimer()
        startTime.setTime(0)
        toTime = 0
        previousButton.enabled = false
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
      privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.3 / 20 * trueHeight, 1 / 20 * trueHeight, 0.8 / 20 * trueHeight, 0.1 / 20 * trueHeight)
    } else {
      isPublic = true
      privacyButton.setImage(UIImage(named: "globeIcon"), forState: .Normal)
      privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.43 / 20 * trueHeight, 1.1 / 20 * trueHeight, 0.93 / 20 * trueHeight, 0.2 / 20 * trueHeight)
    }
    isShowDiscardAlert = true
  }
  
  // find the current tab according to the current music time
  func findCurrentTabView() {
    let stepper: Double = 10.0 / Double(tabsEditorProgressWidthMultiplier)
    for i in 0..<allTabsOnMusicLine.count {
      allTabsOnMusicLine[i].tabView.backgroundColor = UIColor.silverGray().colorWithAlphaComponent(0.6)
    }
    if allTabsOnMusicLine.count == 1 {
      if currentTime >= (allTabsOnMusicLine[0].time - 0.1 * stepper) && currentTime <= (allTabsOnMusicLine[0].time + 3.2 * stepper) {
        allTabsOnMusicLine[0].tabView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        currentTabViewIndex = 0
      }
    } else {
      for i in 1..<(allTabsOnMusicLine.count + 1) {
        if i < allTabsOnMusicLine.count {
          if currentTime > (allTabsOnMusicLine[i - 1].time - 0.1 * stepper) && (currentTime <= allTabsOnMusicLine[i].time) && currentTime <= (allTabsOnMusicLine[i - 1].time + 3.2 * stepper) {
            allTabsOnMusicLine[i - 1].tabView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
            currentTabViewIndex = i - 1
            break
          }
        } else if i == allTabsOnMusicLine.count {
          if currentTime > (allTabsOnMusicLine[i - 1].time - 0.1 * stepper) && currentTime <= (allTabsOnMusicLine[i - 1].time + 3.2 * stepper)   {
            allTabsOnMusicLine[i - 1].tabView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
            currentTabViewIndex = i - 1
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

