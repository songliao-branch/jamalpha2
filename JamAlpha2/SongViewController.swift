import UIKit
import MediaPlayer

let stepPerSecond: Float = 100   //steps of chord move persecond
//Parameters to simulate the disappearing
let timeToDisappear: Float = 0.8
let timeDisappeared: Float = 0.4
let totalalpha: Int = Int((timeToDisappear - timeDisappeared) * stepPerSecond)

let progressContainerHeight:CGFloat = 80 //TODO: Change to percentange, used in LyricsSync
let progressWidthMultiplier:CGFloat = 2

class SongViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    var musicViewController: MusicViewController!
    var animator: CustomTransitionAnimation?
    
    let customView:UIView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
    
    private var rwLock = pthread_rwlock_t()
    
    //for nsoperation
    var isGenerated:Bool = false
    
    var musicDataManager = MusicDataManager()
    //time for chords to fall from top to bottom of chordbase
    var freefallTime:Float = 4
    var minfont: CGFloat = 15
    
    var nowView: VisualizerView!

    var selectedFromTable = true
    
    var viewDidFullyDisappear = true
    
    var player: MPMusicPlayerController!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    // the previous song time
    var firstLoadSongTime: NSTimeInterval!
    var firstloadSongTitle: String!
    
    var backgroundImageView: UIImageView!
    
    var buttonDimension: CGFloat = 50
    var pulldownButton:UIButton!
    var tuningButton:UIButton!
    var tuningLabels = [UILabel]() //6 labels for each string
    var capoButton: UIButton!
    
    var songNameLabel: MarqueeLabel!
    var artistNameLabel: UILabel!
    var topViewHeight: CGFloat = 44
    let statusBarHeight: CGFloat = 20
    
    var previousButton: UIButton!
    var nextButton: UIButton!

    // MARK: Custom views
    var chordBase: ChordBase!
    var basesHeight: CGFloat!
    let marginBetweenBases: CGFloat = 15
    
    var chordBaseTapGesture: UITapGestureRecognizer!
    //MARK: progress Container
    //var progressBlock: SoundWaveView!
    
    var progressBlockViewWidth:CGFloat?
    var progressBlockContainer:UIView!
    var progressChangedOrigin:CGFloat!
    var panRecognizer:UIPanGestureRecognizer!
    var isPanning = false
    
    var progressContainerTapGesture: UITapGestureRecognizer!

    var currentTimeLabel:UILabel!
    var totalTimeLabel:UILabel!
    
    var chords = [Chord]()
    var start: Int = 0
    var startdisappearing: Int = 0
    var activelabels:[(labels: [UIView], ylocation: CGFloat, alpha: Int)] = []
    var startTime: TimeNumber = TimeNumber(second: 0, decimal: 0)
    
    //tuning of capo 
    var tuningOfTheTabsSet = "E-B-G-D-A-E"//standard tuning, from high E to low E
    // we reverse the order when present above the chordBase
    var capoOfTheTabsSet = 0
    
    //time
    var timer: NSTimer = NSTimer()
    var updateInterval: NSTimeInterval = 0 //used to calculate count down reduce
    var currentChordTime:Float = 0
    var toChordTime:Float = 0
    
    var topPoints = [CGFloat]()
    var bottomPoints = [CGFloat]()
    
    var labelHeight:CGSize!
    //speed to control playback speed and
    //corresponding playback speed
    var speed: Float = 1
    //as a recorder to write down the current rate
    
    // key is the stepper value ranging from 0.7 to 1.3 in step of 0.1
    // value is the real speed the song is playing
    let speedMatcher = [0.7: 0.50, 0.8:0.67 ,0.9: 0.79,  1.0:1.00 ,1.1: 1.25  ,1.2 :1.50, 1.3: 2.00]
    
    //Lyric
    var lyricbase: UIView!
    
    var topLyricLabel: UILabel = UILabel()
    var bottomLyricLabel: UILabel = UILabel()
    
    var currentLyricsIndex: Int = 0    //current line of lyric
    var lyric: Lyric = Lyric()
    
    //for displaying 4 buttons, Favorite, Shuffle state, Changed chord version, dots
    var topView:UIView!
    var bottomView:UIView!
    
    var favoriateButton:UIButton!
    var shuffleButton:UIButton!
    var guitarButton:UIButton!
    var othersButton:UIButton!
    
    
    // count down section
    var countdownTimer = NSTimer()
    var countDownStartSecond = 0 //will increments to 3
    var countdownView: CountdownView!
    
    // Guitar actions views
    var guitarActionView: UIView!
    var volumeView: MPVolumeView!
    var speedStepper: UIStepper!
    var speedLabel: UILabel!
    var chordsSwitch: UISwitch!
    var tabsSwitch: UISwitch!
    var lyricsSwitch: UISwitch!
    var countdownSwitch: UISwitch!

    // for actions used inside this class
    // includes volume change ,speed change, show/hide chords, tabs, lyrics, countdown
    var navigationOutActionView: UIView!
    var browseTabsButton: UIButton!
    var addTabsButton: UIButton!
    var browseLyricsButton: UIButton!
    var addLyricsButton: UIButton!
    var goToArtistButton: UIButton!
    var goToAlbumButton: UIButton!
    
    // used to toggle should display chord name or tabs
    var isChordShown = true
    var isTabsShown = true
    var isLyricsShown = true
    let isChordShownKey = "isChordShown"
    let isTabsShownKey = "isTabsShown"
    let isLyricsShownKey = "isLyricsShown"
    var artWorkUnblurred = false // a variable kept to restore blur image from unblurred state (when changed from everything is hidden to show chords or lyrics), to avoid unnecessary blurring
    var countdownOn = false
    var countdownOnKey = "countdownOn"
    
    var actionViewHeight: CGFloat = 44 * 6 + 5// a row height * number of rows + 5 lines of separator of height 1
    //var navigationOutActionViewHeight: CGFloat = 44 * 4 + 4 //4 rows of height + 4 lines
    var actionDismissLayerButton: UIButton!
    
    var textColor:UIColor!

    //background images
    var currentImage:UIImage?
    
    //default is 0
    //0-repeat all, 1-repeat song, 2-shuffle all
    var shuffleButtonImageNames = ["loop_playlist","loop_song","shuffle"]
    
    //The labels move distance of each step in the base UIView
    var movePerstep: CGFloat = 0
    
    //the max y location of labels in the base view
    var maxylocation: CGFloat = 0
    
    //the width of base UIView
    var widthofbasetop: CGFloat!
    var tan: Float!
    
    //constant
    let bottomViewHeight:CGFloat = 40 //this is fixed
    
    class var sharedInstance: SongViewController {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SongViewController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SongViewController()
        }
        return Static.instance!
    }
    
    
    func setUpSubLayout(){
        //hide tab bar
        self.tabBarController?.tabBar.hidden = true
        setUpTopButtons()
        setUpNameAndArtistButtons()
        setUpBackgroundImage()
        //set up views from top to bottom
        setUpChordBase()
        setUpTuningLabels()
        setUpLyricsBase()
        setUpControlButtons()
        setUpProgressContainer()
        setUpTimeLabels()
        setUpBottomViewWithButtons()
        setUpActionViews()
        setUpCountdownView()
        movePerstep = maxylocation / CGFloat(stepPerSecond * freefallTime)
        createTransitionAnimation()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
            self.transitioningDelegate = self.animator
            self.animator!.attachToViewController()
        }
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        pthread_rwlock_init(&rwLock, nil)
        //self.setUpSubLayout() ///////////////////////////delete
        player = MusicManager.sharedInstance.player
    }

    
    deinit{
        pthread_rwlock_destroy(&rwLock)
    }
    
    
    func removeAllObserver(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerVolumeDidChangeNotification, object: player)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // viewWillAppear is called everytime the view is dragged down
        // to prevent resumeSong() everytime, we make sure resumeSong()
        // is ONLY called when the view is fully dragged down or disappeared
        if viewDidFullyDisappear {
            //println("resume song when Fully Disapper")
            loadDisplayMode()
            resumeSong()
            viewDidFullyDisappear = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.registerMediaPlayerNotification()
        if(!isGenerated){
            let nowPlayingItem = player.nowPlayingItem!
            generateSoundWave(nowPlayingItem)
        }
    }
    
    func setUpBackgroundImage(){
        //create an UIImageView
        let imageDimension = self.customView.frame.height-CGRectGetMaxY(topView.frame)
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: CGRectGetMaxY(topView.frame), width: imageDimension, height: imageDimension))
        
        backgroundImageView.center.x = self.customView.center.x
        
//        //get the image from MPMediaItem
//        print(player.nowPlayingItem!.title)
//        if let artwork = player.nowPlayingItem!.artwork {
//            currentImage = artwork.imageWithSize(CGSize(width: self.customView.frame.height/8, height: self.customView.frame.height/8))
//        }
//        //create blurred image
//        let blurredImage:UIImage = currentImage!.applyLightEffect()!
//       
//        backgroundImageView.image = blurredImage
//        textColor = blurredImage.averageColor()
        
        self.customView.addSubview(backgroundImageView)
    }
    
    func setUpTopButtons() {
        let statusBarLayer = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: statusBarHeight))
        statusBarLayer.backgroundColor = UIColor.mainPinkColor()
        self.customView.addSubview(statusBarLayer)
        
        topView = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: SCREEN_WIDTH, height: topViewHeight))
        topView.backgroundColor = UIColor.mainPinkColor()
        self.customView.addSubview(topView)
        
        let buttonCenterY: CGFloat = topViewHeight/2
        pulldownButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
        
        pulldownButton.setImage(UIImage(named: "pullDown"), forState: UIControlState.Normal)
        pulldownButton.center = CGPoint(x: SCREEN_WIDTH / 12, y: buttonCenterY)
        pulldownButton.addTarget(self, action: "dismissController:", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(pulldownButton)
        
        tuningButton = UIButton(frame: CGRect(x: 0 , y: 0, width: buttonDimension, height: buttonDimension))
        tuningButton.setImage(UIImage(named: "tuning"), forState: UIControlState.Normal)
        tuningButton.center = CGPoint(x: SCREEN_WIDTH * 11 / 12, y: buttonCenterY)
        tuningButton.addTarget(self, action: "tuningPressed:", forControlEvents: .TouchUpInside)
        topView.addSubview(tuningButton)
        
        let capoCircleDimension: CGFloat = 16
        capoButton = UIButton(frame: CGRect(x: 0, y: 0, width: capoCircleDimension, height: capoCircleDimension))
        capoButton.backgroundColor = UIColor.whiteColor()
        capoButton.layer.cornerRadius = capoButton.frame.height/2
        capoButton.center = CGPoint(x: tuningButton.center.x+capoCircleDimension/2, y: tuningButton.center.y+capoCircleDimension/2)
        capoButton.hidden = true
        //its touch event is same as tuningButton because this view blocks part of tuning button,
        //so I set the same touch event
        capoButton.addTarget(self, action: "tuningPressed:", forControlEvents: .TouchUpInside)
        capoButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        capoButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.customView.addSubview(capoButton)
    }

    func updateTuning(tuning: String) {
        print("current tuning is \(tuning)")
        let tuningArray = tuning.characters.split{$0 == "-"}.map(String.init)
        let tuningToShow = Array(tuningArray.reverse())
        for i in 0..<tuningLabels.count {
            tuningLabels[i].text = tuningToShow[i]
            tuningLabels[i].sizeToFit()
            tuningLabels[i].center = CGPoint(x: topPoints[i+1]+chordBase.frame.origin.x, y: chordBase.frame.origin.y-10)
        }
    }
    
    func updateCapo(capo: Int) {
        if capo < 1 {
            capoButton.hidden = true
            return
        }
        capoButton.hidden = false
        capoButton.setTitle(String(capo), forState: .Normal)
        capoButton.titleLabel?.sizeToFit()
    }

    
    func setUpTuningLabels() {
        for i in 1..<topPoints.count{
            let tuningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 15))
            tuningLabel.textColor = UIColor.whiteColor()
            tuningLabel.font = UIFont.systemFontOfSize(minfont-5)
            tuningLabel.textAlignment = .Center
            tuningLabel.center = CGPoint(x: topPoints[i]+chordBase.frame.origin.x, y: chordBase.frame.origin.y-10)
            tuningLabel.hidden = true
            self.customView.addSubview(tuningLabel)
            tuningLabels.append(tuningLabel)
        }
    }
    
    func tuningPressed(button: UIButton) {
        if tuningLabels[0].hidden {
            for label in tuningLabels {
                label.hidden = false
            }
        } else {
            
            for label in tuningLabels {
                label.hidden = true
            }
        }
    }
    func setUpNameAndArtistButtons(){
       
        songNameLabel = MarqueeLabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 20)))
        songNameLabel.type = .Continuous
        songNameLabel.scrollDuration = 15.0
        songNameLabel.fadeLength = 5.0
        songNameLabel.trailingBuffer = 30.0
        
        artistNameLabel = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 10)))
        artistNameLabel.textAlignment = NSTextAlignment.Center
        
//        let title:String = player.nowPlayingItem!.title!
//        let attributedString = NSMutableAttributedString(string:title)
//        songNameLabel.attributedText = attributedString
//        songNameLabel.textAlignment = NSTextAlignment.Center
//            
//        artistNameLabel.text = player.nowPlayingItem!.artist
        
        
        songNameLabel!.font = UIFont.systemFontOfSize(18)
        artistNameLabel!.font = UIFont.systemFontOfSize(12)
        
        //increase edge width
        //TODO: set a max of width to avoid clashing with pulldown and tuning button
        songNameLabel.frame.size = CGSize(width: songNameLabel.frame.width + 20, height: 30)
        artistNameLabel.frame.size = CGSize(width: artistNameLabel.frame.width + 20, height: 30)
        songNameLabel.center.x = self.customView.frame.width / 2
        songNameLabel.center.y = pulldownButton.center.y - 7
        
        artistNameLabel.center.x = self.customView.frame.width / 2
        artistNameLabel.center.y = CGRectGetMaxY(songNameLabel.frame) + 3
        
        songNameLabel.textColor = UIColor.whiteColor()
        artistNameLabel.textColor =  UIColor.whiteColor()
        
        artistNameLabel.backgroundColor = UIColor.clearColor()
        
        topView.addSubview(songNameLabel)
        topView.addSubview(artistNameLabel)
    }

    
    func setUpControlButtons(){
        previousButton = UIButton(frame: CGRect(x: 0, y: chordBase.frame.origin.y, width: buttonDimension, height: buttonDimension))
        previousButton.setImage(UIImage(named: "previous"), forState: .Normal)
        previousButton.addTarget(self, action: "previousPressed:", forControlEvents: .TouchUpInside)
        previousButton.contentHorizontalAlignment = .Left
        
        nextButton = UIButton(frame: CGRect(x: 0, y: chordBase.frame.origin.y, width: buttonDimension, height: buttonDimension))
        nextButton.setImage(UIImage(named: "next"), forState: .Normal)
        nextButton.addTarget(self, action: "nextPressed:", forControlEvents: .TouchUpInside)
        nextButton.frame.origin.x = self.customView.frame.width - nextButton.frame.width
        nextButton.contentHorizontalAlignment = .Right
        self.customView.addSubview(previousButton)
        self.customView.addSubview(nextButton)
    }
    
    func previousPressed(button: UIButton){
        player.skipToPreviousItem()
    }
    
    func nextPressed(button: UIButton){
        player.skipToNextItem()
    }
    
    func dismissController(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateMusicData(song: MPMediaItem) {
        self.setUpMusicData(song)
        //TODO: because before add the tuning to the data some songs don't have tuning
        // so temporary we add default tuing and capo
        if self.tuningOfTheTabsSet == "" {
            tuningOfTheTabsSet = "E-B-G-D-A-E"
            capoOfTheTabsSet = 0
        }
        self.updateTuning(self.tuningOfTheTabsSet)
        self.updateCapo(self.capoOfTheTabsSet)
    }
    
    func setUpMusicData(song: MPMediaItem){
         if song.title == "Rolling In The Deep" {
            chords = Chord.getRollingChords()
            lyric = Lyric.getRollingLyrics()
        } else if song.title == "I'm Yours"{
            chords = Chord.getJasonMrazChords()
            lyric = Lyric.getJasonMrazLyrics()
         }else if song.title == "Daughters" {
            chords = Chord.getDaughters()
            lyric = Lyric.getDaughters()
            
         } else { // use more than words for everything else for now
            chords = Chord.getExtremeChords()
            lyric = Lyric.getExtremeLyrics()
        }
        
        self.tuningOfTheTabsSet = "E-B-G-D-A-E"
        self.capoOfTheTabsSet = 0
        
        //return a tuple of ([Chord],tuning, capo)
        let tabsFromCoreData = musicDataManager.getTabs(song)
        if tabsFromCoreData.0.count > 0 {
            print("chords length: \(tabsFromCoreData.0.count)")
            if tabsFromCoreData.0.count > 2 { //TODO: needs better validation of tabs
                self.chords = tabsFromCoreData.0
                self.tuningOfTheTabsSet = tabsFromCoreData.1
                print("tuning from data: \(tabsFromCoreData.1) capo: \(tabsFromCoreData.2)")
                self.capoOfTheTabsSet = tabsFromCoreData.2
            } else {
                self.chords = Chord.getRainbowChords()
            }
        }
        

        let lyricsFromCoreData = musicDataManager.getLyrics(song)
        
        if lyricsFromCoreData.count > 0 {
            self.lyric = Lyric(lyricsTimesTuple: lyricsFromCoreData)
        }
    }
    
    func setUpLyricsBase(){
        //Lyric labels
        currentLyricsIndex = -1
        let sideMargin: CGFloat = 20
        
        lyricbase = UIView(frame: CGRect(x: sideMargin, y: CGRectGetMaxY(chordBase.frame) + marginBetweenBases, width: self.customView.frame.width - 2 * sideMargin, height: basesHeight * 0.4))
        lyricbase.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        lyricbase.alpha = 0.8
        
        self.customView.addSubview(lyricbase)
        
        let contentMargin: CGFloat = 5
        
        lyricbase.layer.cornerRadius = 20
        
        topLyricLabel.frame = CGRectMake(contentMargin, 0, lyricbase.frame.width - 2 * contentMargin, 2 * lyricbase.frame.height / 3)
        topLyricLabel.center.y = lyricbase.frame.height / 3
        topLyricLabel.numberOfLines = 2
        topLyricLabel.textAlignment = NSTextAlignment.Center
        topLyricLabel.font = UIFont.systemFontOfSize(23)
        topLyricLabel.lineBreakMode = .ByWordWrapping
        topLyricLabel.textColor = UIColor.silverGray()
        lyricbase.addSubview(topLyricLabel)
        
        bottomLyricLabel.frame = CGRectMake(contentMargin, 0, lyricbase.frame.width - 2 * contentMargin, lyricbase.frame.height / 3)
        bottomLyricLabel.center.y =  2 * lyricbase.frame.height / 3 + 10
        bottomLyricLabel.numberOfLines = 2
        bottomLyricLabel.textAlignment = NSTextAlignment.Center
        bottomLyricLabel.font = UIFont.systemFontOfSize(16)
        bottomLyricLabel.lineBreakMode = .ByWordWrapping
        bottomLyricLabel.textColor = UIColor.silverGray()
        lyricbase.addSubview(bottomLyricLabel)
    }
    

    func setUpChordBase(){
        let marginToTopView: CGFloat = 20
        let marginToProgressContainer: CGFloat = 10
        
        basesHeight = self.customView.frame.height - topViewHeight - marginToTopView - bottomViewHeight - progressContainerHeight - marginBetweenBases - marginToProgressContainer
        
        chordBase = ChordBase(frame: CGRect(x: 0, y: CGRectGetMaxY(topView.frame) + marginToTopView, width: self.customView.frame.width * 0.62, height: basesHeight * 0.55))
        chordBase.center.x = self.customView.center.x
        chordBase.backgroundColor = UIColor.clearColor()
        chordBase.alpha = 0.8
        
        panRecognizer = UIPanGestureRecognizer(target: self, action:Selector("handleChordBasePan:"))
        panRecognizer.delaysTouchesEnded = true
        
        panRecognizer.delegate = self
        chordBase.addGestureRecognizer(panRecognizer)
        
        self.customView.addSubview(chordBase)
        
        //add tap gesture to chordbase too
        chordBaseTapGesture = UITapGestureRecognizer(target: self, action: "playPause:")
        chordBase.addGestureRecognizer(chordBaseTapGesture)
        
        calculateXPoints()
    }
    
    func loadDisplayMode() {
        // zero means never been set before, 1 means true, 2 means false
        if NSUserDefaults.standardUserDefaults().integerForKey(isChordShownKey) == 0 || NSUserDefaults.standardUserDefaults().integerForKey(isChordShownKey) == 1 {
            isChordShown = true
        } else {
            isChordShown = false
        }
        
        if NSUserDefaults.standardUserDefaults().integerForKey(isTabsShownKey) == 0||NSUserDefaults.standardUserDefaults().integerForKey(isTabsShownKey) == 1 {
            isTabsShown = true
        } else {
            isTabsShown = false
        }
        
        if NSUserDefaults.standardUserDefaults().integerForKey(isLyricsShownKey) == 0 || NSUserDefaults.standardUserDefaults().integerForKey(isLyricsShownKey) == 1 {
            isLyricsShown = true
        } else {
            isLyricsShown = false
        }
        
        // if countdown has never been set before, default is false
        if NSUserDefaults.standardUserDefaults().integerForKey(countdownOnKey) == 0 || NSUserDefaults.standardUserDefaults().integerForKey(countdownOnKey) == 2 {
            countdownOn = false
        } else {
            countdownOn = true
        }
        
        chordsSwitch.on = isChordShown
        tabsSwitch.on = isTabsShown
        lyricsSwitch.on = isLyricsShown
        countdownSwitch.on = countdownOn
        
        toggleChordsDisplayMode()
        toggleLyrics()
    }
    
    func registerMediaPlayerNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentSongChanged:"), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playbackStateChanged:"), name:MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerVolumeChanged:"), name:MPMusicPlayerControllerVolumeDidChangeNotification, object: player)
        player.beginGeneratingPlaybackNotifications()
    }
    
//    func synced(lock: AnyObject, closure: () -> ()) {
//        objc_sync_enter(lock)
//        closure()
//        objc_sync_exit(lock)
//    }
    
    func currentSongChanged(notification: NSNotification){
        pthread_rwlock_wrlock(&self.rwLock)
            for label in self.tuningLabels {
                label.hidden = true
            }
            if self.player.repeatMode == .One {
                print("\(self.player.nowPlayingItem!.title) is repeating")
                self.updateAll(0)
                return
            }
            
            let nowPlayingItem = self.player.nowPlayingItem
            
            // use current item's playbackduration to validate nowPlayingItem duration
            // if they are not equal, i.e. not the same song
            if self.firstloadSongTitle != nowPlayingItem!.title && self.firstLoadSongTime != nowPlayingItem!.playbackDuration {
                self.musicDataManager.initializeSongToDatabase(self.player.nowPlayingItem!)
                self.firstloadSongTitle = nowPlayingItem!.title
                self.firstLoadSongTime = nowPlayingItem!.playbackDuration
                
                self.updateMusicData(nowPlayingItem!)
                
                // The following won't run when selected from table
                // update the progressblockWidth
                
                self.progressBlockViewWidth = nil
        
                let nowPlayingItemDuration = nowPlayingItem!.playbackDuration
                //////////////////////////////
                //remove from superView
                if(KGLOBAL_progressBlock != nil ){
                    KGLOBAL_progressBlock.removeFromSuperview()
                }
                
                // get a new progressBlock
                var progressBarWidth:CGFloat!
                progressBarWidth = CGFloat(nowPlayingItemDuration) * progressWidthMultiplier
                KGLOBAL_progressBlock = SoundWaveView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: 161))
                KGLOBAL_progressBlock.center.y = progressContainerHeight
                self.progressBlockContainer.addSubview(KGLOBAL_progressBlock)
                
                if let soundWaveData = self.musicDataManager.getSongWaveFormImage(nowPlayingItem!) {
                    KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
                     self.progressBlockContainer.addSubview(KGLOBAL_progressBlock)
                    print("sound wave data found")
                    KGLOBAL_init_queue.suspended = false
                } else {
                    self.generateSoundWave(nowPlayingItem!)
                }
 
                ////////////////////////////
                
                    KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 1.0)
                
                if self.player.playbackState == MPMusicPlaybackState.Paused{
                    KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 0.5)
                    print("changeScale")
                    //self.progressBlock!.alpha = 0.5
                }
                
                // if we are NOT repeating song
                if self.player.repeatMode != .One {
                    
                    self.songNameLabel.attributedText = NSMutableAttributedString(string: nowPlayingItem!.title!)
                    self.songNameLabel.textAlignment = NSTextAlignment.Center
                    self.artistNameLabel.text = nowPlayingItem!.artist
        
                    if let artwork = self.player.nowPlayingItem!.artwork {
                        let image = artwork.imageWithSize(CGSize(width: self.customView.frame.height/8, height: self.customView.frame.height/8))
                        let blurredImage = image!.applyLightEffect()!
                        self.textColor = blurredImage.averageColor()
                        
                        self.backgroundImageView.center.x = self.customView.center.x
                        self.backgroundImageView.image = blurredImage
                    }

       
                    self.totalTimeLabel.text = TimeNumber(time: Float(nowPlayingItemDuration)).toDisplayString()
                }
            }
            self.speed = 1
            //self.nowPlayingItemSpeed = 1
            if self.player.playbackState == MPMusicPlaybackState.Playing{
                self.timer.invalidate()
                self.startTimer()
            }
            
            self.updateAll(0)
        pthread_rwlock_unlock(&self.rwLock)
    }
    
    func playbackStateChanged(notification: NSNotification){
        let playbackState = player.playbackState
        
        if playbackState == .Paused {
            timer.invalidate()
            
            //fade down the soundwave
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveLinear, animations: {
                KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                KGLOBAL_progressBlock!.alpha = 0.5
                }, completion: nil)
            
        }
        else if playbackState == .Playing {
            startTimer()
            
            //bring up the soundwave, give it a little jump animation
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.2)
                KGLOBAL_progressBlock!.alpha = 1.0
                }, completion: { finished in
                    
                    UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        }, completion: nil)
                    
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        print("memory warning")
        removeMusicPlayerObserver()
        player.endGeneratingPlaybackNotifications()
    }
    func removeMusicPlayerObserver(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerVolumeDidChangeNotification, object: player)
    }
    
    func playerVolumeChanged(notification: NSNotification){
        print("volume changed")
    }
    
    func resumeSong(){
        
        //musicViewController!.nowView!.stop()
        // if we are pressing the now button this is false, or coming from background
        if selectedFromTable {
            if nowView != nil {
                self.nowView.start()
            }
            //TODO: BUG: when soundwave is generating, the volume is somehow lowered 
            // until the player.currentPlaybacktime is set, as move the progress block would 
            // restore the normal volume
            player.play()
            
            if player.playbackState != MPMusicPlaybackState.Playing{
                KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 1.0)
                startTimer()
            }
            
        } else { // selected from now view button
            if player.playbackState == MPMusicPlaybackState.Playing {
                startTimer()
            }
            else if player.playbackState == MPMusicPlaybackState.Paused {
                if nowView != nil {
                    self.nowView.stop()
                }
                
                timer.invalidate()
                // progress bar should be lowered
                KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                KGLOBAL_progressBlock!.alpha = 0.5
                self.speed = 1  //restore to original speed
            }
        }

        startTime =  TimeNumber(time: Float(player.currentPlaybackTime))
        updateAll(startTime.toDecimalNumer())
    }
    
    func setUpProgressContainer(){
        progressChangedOrigin = self.customView.frame.width / 2
        progressBlockContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.customView.frame.width, height: progressContainerHeight))
        progressBlockContainer.center.y = self.customView.frame.height - bottomViewHeight - progressContainerHeight / 2
        progressBlockContainer.backgroundColor = UIColor.clearColor()
        self.customView.addSubview(progressBlockContainer)
        
//        var progressBarWidth:CGFloat!
//
//        progressBarWidth = CGFloat(player.nowPlayingItem!.playbackDuration) * progressWidthMultiplier
//        
//        KGLOBAL_progressBlock = SoundWaveView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: 161))
//        KGLOBAL_progressBlock.center.y = progressContainerHeight
//        self.progressBlockContainer.addSubview(KGLOBAL_progressBlock)
//        
//        //if there is soundwave in the coredata then we load the image in viewdidload
//        if let soundWaveData = musicDataManager.getSongWaveFormImage(player.nowPlayingItem!) {
//            KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
//            print("sound wave data found")
//            KGLOBAL_init_queue.suspended = false
//            isGenerated = true
//        }else{
//            //if didn't find it then we will generate then waveform later, in the viewdidappear method
//            // this is a flag to determine if the generateSoundWave function will be called
//            isGenerated = false
//        }
    
        panRecognizer = UIPanGestureRecognizer(target: self, action:Selector("handleProgressPan:"))
        panRecognizer.delegate = self
        progressBlockContainer.addGestureRecognizer(panRecognizer)
        
        progressContainerTapGesture = UITapGestureRecognizer(target: self, action: Selector("playPause:"))
        progressBlockContainer.addGestureRecognizer(progressContainerTapGesture)
    }
    
    // to generate sound wave in a nsoperation thread
    func generateSoundWave(nowPlayingItem:MPMediaItem){
        dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))) {
            guard let assetURL = self.player.nowPlayingItem!.valueForProperty(MPMediaItemPropertyAssetURL) else {
                print("sound url not available")
                return
            }
            
            var op:NSBlockOperation?
            op = KGLOBAL_operationCache[assetURL as! NSURL]
            if(op == nil){
                // have to use the temp value to do the nsoperation, cannot use (self.) do that.
                let tempNowPlayingItem = nowPlayingItem
                let tempProgressBlock = KGLOBAL_progressBlock
                let tempMusicDataManager = self.musicDataManager
                op = NSBlockOperation(block: {
                    
                    tempProgressBlock.SetSoundURL(assetURL as! NSURL, isForTabsEditor: false)
                    let data = UIImagePNGRepresentation(tempProgressBlock.generatedNormalImage)
                    
                    tempMusicDataManager.saveSoundWave(tempNowPlayingItem, soundwaveData: tempProgressBlock.averageSampleBuffer!, soundwaveImage: data!)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        KGLOBAL_operationCache.removeValueForKey(assetURL as! NSURL)
                        if(tempNowPlayingItem == self.player.nowPlayingItem){
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                KGLOBAL_progressBlock.setWaveFormFromData(data!)
                                KGLOBAL_init_queue.suspended = false
                            })
                        }
                    }
                })
                KGLOBAL_operationCache[assetURL as! NSURL] = op
                KGLOBAL_queue.addOperation(op!)
            }
        }
    }
    
    func handleProgressPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.customView)
        for childview in recognizer.view!.subviews {
            let child = childview
            self.isPanning = true
            
            var newPosition = progressChangedOrigin + translation.x
            
            // leftmost point of inner bar cannot be more than half of the view
            if newPosition > self.customView.frame.width / 2 {
                newPosition = self.customView.frame.width / 2
            }
            
            // the end of inner bar cannot be smaller left half of view
            if newPosition + child.frame.width < self.customView.frame.width / 2 {
                newPosition = self.customView.frame.width / 2 - child.frame.width
            }
            
            //update all chords, lyrics
            timer.invalidate()
            
            //new Position from 160 to -357
            //-self.customView.frame.width /2
            //= from 0 ot -517
            //divide by -2: from 0 to 258
            let toTime = Float(newPosition - self.customView.frame.width / 2) / -(Float(progressWidthMultiplier))
            KGLOBAL_progressBlock.setProgress(CGFloat(toTime)/CGFloat(player.nowPlayingItem!.playbackDuration))
            //258  517
            updateAll(toTime)
            
            //child.frame.origin.x = newPosition
            
            //when finger is lifted
            if recognizer.state == UIGestureRecognizerState.Ended {
                progressChangedOrigin = newPosition
                isPanning = false
                player.currentPlaybackTime = NSTimeInterval(toTime)
                if player.playbackState == .Playing {
                    startTimer()
                }
            }
        }
    }
    
    
    
    func handleChordBasePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.customView)
        
        switch recognizer.state {
            
        case UIGestureRecognizerState.Began:
            isPanning = true
            currentChordTime = startTime.toDecimalNumer()+0.01
            timer.invalidate()
            updateAll(currentChordTime)
            
            break;
        case UIGestureRecognizerState.Changed:
            let tempNowPlayingItem = player.nowPlayingItem
            let deltaTime = Float(translation.y)*(freefallTime/Float(chordBase.frame.size.height))
            toChordTime = currentChordTime + deltaTime
            
            if toChordTime < 0 {
                toChordTime = 0
            } else if (toChordTime > Float(tempNowPlayingItem!.playbackDuration)){
                toChordTime = Float(tempNowPlayingItem!.playbackDuration)
            }
            
            //update soundwave progress
            KGLOBAL_progressBlock.setProgress(CGFloat(toChordTime)/CGFloat(tempNowPlayingItem!.playbackDuration))
            
            updateAll(toChordTime)
            
            break;
        case UIGestureRecognizerState.Ended:
            isPanning = false
            player.currentPlaybackTime = NSTimeInterval(toChordTime)
            if player.playbackState == MPMusicPlaybackState.Playing {
                startTimer()
            }
            currentChordTime = 0
            toChordTime = 0
            break;
        default:
            break;
        }
    }

    
    
    func setUpTimeLabels(){
        
        let labelWidth: CGFloat = 40
        let labelHeight: CGFloat = 15
        let labelFontSize: CGFloat = 12
        let timeLabelOriginY = CGRectGetMaxY(progressBlockContainer.frame)-labelHeight
        
        let wrapper = UIView(frame: CGRect(x: 0, y: timeLabelOriginY, width: 85, height: labelHeight))
        wrapper.center.x = self.customView.center.x
        wrapper.backgroundColor = UIColor.darkGrayColor()
        wrapper.alpha = 0.7
        wrapper.layer.cornerRadius = labelHeight/5
        self.customView.addSubview(wrapper)
        
        currentTimeLabel = UILabel(frame: CGRect(x: self.customView.center.x-labelWidth, y: timeLabelOriginY , width: labelWidth, height: labelHeight))
        currentTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        currentTimeLabel.text = "0:00.0"
        currentTimeLabel.textAlignment = .Left
        currentTimeLabel.textColor = UIColor.whiteColor()
        
        //make it glow
        currentTimeLabel.layer.shadowColor = UIColor.whiteColor().CGColor
        currentTimeLabel.layer.shadowRadius = 3.0
        currentTimeLabel.layer.shadowOpacity = 1.0
        currentTimeLabel.layer.shadowOffset = CGSizeZero
        currentTimeLabel.layer.masksToBounds = false
        self.customView.addSubview(currentTimeLabel)
        
        totalTimeLabel = UILabel(frame: CGRect(x: self.customView.center.x+1, y:timeLabelOriginY, width: labelWidth, height: labelHeight))
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        //totalTimeLabel.text = TimeNumber(time: Float(player.nowPlayingItem!.playbackDuration)).toDisplayString()
        totalTimeLabel.textAlignment = .Right
        self.customView.addSubview(totalTimeLabel)
        
    }
    
    //from left to right: share, favoriate, shuffle, others
    func setUpBottomViewWithButtons(){

        bottomView = UIView(frame: CGRect(x: 0, y: self.customView.frame.height - bottomViewHeight, width: self.customView.frame.width, height: bottomViewHeight))
        bottomView.backgroundColor = UIColor.darkGrayColor()
        bottomView.alpha = 0.7
        self.customView.addSubview(bottomView)
        
        let bottomButtonSize: CGSize = CGSizeMake(bottomView.frame.width / 4, bottomView.frame.height)
        
        //TODO: Add glowing effect when pressed
        //divide view width into eigth to distribute center x for each of four buttons
        favoriateButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        favoriateButton.setImage(UIImage(named: "notfavorited"), forState: UIControlState.Normal)
        favoriateButton.sizeToFit()
        
        shuffleButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
//        if player.repeatMode == .All && player.shuffleMode == .Off {
//             shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
//        } else if player.repeatMode == .One && player.shuffleMode == .Off {
//             shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[1]), forState: UIControlState.Normal)
//        } else if player.repeatMode == .All && player.shuffleMode == .Songs {
//            shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[2]), forState: UIControlState.Normal)
//        }
        
        shuffleButton.addTarget(self, action: "toggleShuffle:", forControlEvents: .TouchUpInside)
        
        guitarButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        guitarButton.setImage((UIImage(named: "guitar_settings")), forState: UIControlState.Normal)
        guitarButton.addTarget(self, action: "showGuitarActions", forControlEvents: UIControlEvents.TouchUpInside)

        othersButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        othersButton.setImage(UIImage(named: "more_options"), forState: UIControlState.Normal)
        othersButton.center.y = bottomViewHeight / 2
        othersButton.addTarget(self, action: "showNavigationOutActions", forControlEvents: UIControlEvents.TouchUpInside)
        
        var bottomButtons = [favoriateButton, shuffleButton, guitarButton, othersButton]
        var orderIndex: [CGFloat] = [1, 3, 5 , 7]//1/8, 3/8, 5/8, 7/8 of the width
        let eigthOfWidth = self.bottomView.frame.width / 8
        favoriateButton.center.x = eigthOfWidth
        favoriateButton.center.y = bottomViewHeight / 2
        bottomView.addSubview(favoriateButton)
        
        for i in 0...3{
            bottomButtons[i].center.x = orderIndex[i] * eigthOfWidth
            bottomButtons[i].center.y = bottomViewHeight / 2
            bottomView.addSubview(bottomButtons[i])
        }
    }
    
    func setShuffleButtonImage(){
        if player.repeatMode == .All && player.shuffleMode == .Off {
            shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
        } else if player.repeatMode == .One && player.shuffleMode == .Off {
            shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[1]), forState: UIControlState.Normal)
        } else if player.repeatMode == .All && player.shuffleMode == .Songs {
            shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[2]), forState: UIControlState.Normal)
        }
    }
    
    func setUpActionViews() {
        // add this layer first before adding two action views to prevent view blocking
        actionDismissLayerButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.customView.frame.width, height: self.customView.frame.height))
        actionDismissLayerButton.backgroundColor = UIColor.clearColor()
        actionDismissLayerButton.addTarget(self, action: "dismissAction", forControlEvents: .TouchUpInside)
        self.customView.addSubview(actionDismissLayerButton)
        actionDismissLayerButton.hidden = true

        // NOTE: we have to call all the embedded action events from the custom views, not in this class.
        guitarActionView = UIView(frame: CGRect(x: 0, y: self.customView.frame.height, width: self.customView.frame.width, height: actionViewHeight))
        guitarActionView.backgroundColor = UIColor.actionGray()
        self.customView.addSubview(guitarActionView)
        let width = guitarActionView.frame.width
        
        var rowWrappers = [UIView]()
        let rowHeight: CGFloat = 44+1
        for i in 0..<6 {
            let row = UIView(frame: CGRect(x: 0, y: rowHeight*CGFloat(i), width: width, height: rowHeight))
            rowWrappers.append(row)
            if i < 5 { // give a separator at the the bottom of each row except last line
                let line = UIView(frame: CGRect(x: 0, y: rowHeight-1, width: width, height: 1))
                line.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
                row.addSubview(line)
            }
            guitarActionView.addSubview(row)
        }
        let childCenterY = (rowHeight-1)/2
        let sliderMargin: CGFloat = 35
        //(rowHeight-1)/2 is the center y without the extra separator line
        volumeView = MPVolumeView(frame: CGRect(x: sliderMargin, y: 14, width: width-sliderMargin*2, height: rowHeight))
        rowWrappers[0].addSubview(volumeView)
        
        for subview in volumeView.subviews {
            if subview.isKindOfClass(UISlider) {
                let slider = subview as! UISlider
                slider.minimumTrackTintColor = UIColor.mainPinkColor()
            }
        }
        let names = ["Chords", "Tabs", "Lyrics", "Countdown"]
        
        let sideMargin: CGFloat = 15
        var switchHolders = [UISwitch]()
        
        for i in 1..<5 {
            let switchNameLabel = UILabel(frame: CGRect(x: sideMargin, y: 0, width: 200, height: 22))
            switchNameLabel.text = names[i-1]
            switchNameLabel.textColor = UIColor.mainPinkColor()
            switchNameLabel.center.y = childCenterY
            rowWrappers[i].addSubview(switchNameLabel)
            
            //use UISwitch default frame (51,31)
            let actionSwitch = UISwitch(frame: CGRect(x: width-CGFloat(sideMargin)-51, y: 0, width: 51, height: 31))
            
            actionSwitch.tintColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            actionSwitch.onTintColor = UIColor.mainPinkColor()
            actionSwitch.center.y = childCenterY
            rowWrappers[i].addSubview(actionSwitch)
            switchHolders.append(actionSwitch)
        }
        
        chordsSwitch = switchHolders[0]
        chordsSwitch.addTarget(self, action: "chordsSwitchChanged:", forControlEvents: .ValueChanged)
        
        tabsSwitch = switchHolders[1]
        tabsSwitch.addTarget(self, action: "tabsSwitchChanged:", forControlEvents: .ValueChanged)
        
        lyricsSwitch = switchHolders[2]
        lyricsSwitch.addTarget(self, action: "lyricsSwitchChanged:", forControlEvents: .ValueChanged)
        countdownSwitch = switchHolders[3]
        countdownSwitch.addTarget(self, action: "countDownChanged:", forControlEvents: .ValueChanged)
        
        speedStepper = UIStepper(frame: CGRect(x: self.customView.frame.width-94-sideMargin, y: 0, width: 94, height: 29))
        speedStepper.center.y = childCenterY
        speedStepper.tintColor = UIColor.mainPinkColor()
        speedStepper.minimumValue = 0.7 //these are arbitrary numbers just so that the stepper can go down 3 times and go up 3 times
        speedStepper.maximumValue = 1.3
        speedStepper.stepValue = 0.1
        speedStepper.value = 1.0 //default
        speedStepper.addTarget(self, action: "speedStepperValueChanged:", forControlEvents: .ValueChanged)
        
        speedLabel = UILabel(frame: CGRect(x: sideMargin, y: 0, width: 120, height: 22))
        speedLabel.text = "Speed: 1.0x"
        speedLabel.textColor = UIColor.mainPinkColor()
        speedLabel.center.y = childCenterY
        
        rowWrappers[5].addSubview(speedStepper)
        rowWrappers[5].addSubview(speedLabel)
        
        // Add navigation out view, all actions are navigated to other viewControllers
        navigationOutActionView = UIView(frame: CGRect(x: 0, y: self.customView.frame.height, width: self.customView.frame.width, height: actionViewHeight))
        navigationOutActionView.backgroundColor = UIColor.actionGray()
        self.customView.addSubview(navigationOutActionView)

        // position 1
        addTabsButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: rowHeight))
        addTabsButton.setTitle("Add your tabs", forState: .Normal)
        addTabsButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        addTabsButton.addTarget(self, action: "goToTabsEditor:", forControlEvents: .TouchUpInside)
        navigationOutActionView.addSubview(addTabsButton)
        
        //position 2
        addLyricsButton = UIButton(frame: CGRect(x: 0, y: rowHeight, width: width, height: rowHeight))
        addLyricsButton.setTitle("Add your lyrics", forState: .Normal)
        addLyricsButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        addLyricsButton.addTarget(self, action: "goToLyricsEditor:", forControlEvents: .TouchUpInside)
        navigationOutActionView.addSubview(addLyricsButton)
        
        //position 3
        goToArtistButton = UIButton(frame: CGRect(x: 0, y: rowHeight*2, width: width, height: rowHeight))
        goToArtistButton.setTitle("Go to artist", forState: .Normal)
        goToArtistButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        goToArtistButton.addTarget(self, action: "goToArtist:", forControlEvents: .TouchUpInside)
        navigationOutActionView.addSubview(goToArtistButton)
        
        //position 4
        goToAlbumButton = UIButton(frame: CGRect(x: 0, y: rowHeight*3, width: width, height: rowHeight))
        goToAlbumButton.setTitle("Go to album", forState: .Normal)
        goToAlbumButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        goToAlbumButton.addTarget(self, action: "goToAlbum:", forControlEvents: .TouchUpInside)
        navigationOutActionView.addSubview(goToAlbumButton)
        
        //position 5
        browseTabsButton = UIButton(frame: CGRect(x: 0, y: rowHeight*4, width: width, height: rowHeight))
        browseTabsButton.setTitle("Browse all tabs", forState: .Normal)
        browseTabsButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        browseTabsButton.addTarget(self, action: "browseTabs:", forControlEvents: .TouchUpInside)
        navigationOutActionView.addSubview(browseTabsButton)
        
        //position 6
        browseLyricsButton = UIButton(frame: CGRect(x: 0, y: rowHeight*5, width: width, height: rowHeight))
        browseLyricsButton.setTitle("Browse lyrics", forState: .Normal)
        browseLyricsButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        browseLyricsButton.addTarget(self, action: "browseLyrics:", forControlEvents: .TouchUpInside)
        navigationOutActionView.addSubview(browseLyricsButton)
        for i in 0..<5 {
            // draw gray separator between buttons
            let line = UIView(frame: CGRect(x: 0, y: rowHeight*CGFloat(i+1)-1, width: width, height: 1))
            line.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            navigationOutActionView.addSubview(line)
        }
    }
    
    func toggleShuffle(button: UIButton){
        if player.repeatMode == .All && player.shuffleMode == .Off { //is repeat all
            player.repeatMode = .One
            player.shuffleMode = .Off
            button.setImage(UIImage(named: shuffleButtonImageNames[1]), forState: UIControlState.Normal)
        } else if player.repeatMode == .One && player.shuffleMode == .Off { //is repeat one
            player.repeatMode = MPMusicRepeatMode.All
            player.shuffleMode = MPMusicShuffleMode.Songs
            button.setImage(UIImage(named: shuffleButtonImageNames[2]), forState: UIControlState.Normal)
            
        } else if player.shuffleMode == .Songs && player.repeatMode == .All { // is shuffle songs
            player.repeatMode = MPMusicRepeatMode.All
            player.shuffleMode = MPMusicShuffleMode.Off
            button.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
        }
    }
    
    // MARK: guitar buttons
    func dismissAction() {
        UIView.animateWithDuration(0.3, animations: {
            
            if self.guitarActionView.frame.origin.y < self.customView.frame.height - 10 {
                self.guitarActionView.frame = CGRectMake(0, self.customView.frame.height, self.customView.frame.height, self.actionViewHeight)
            }
            
            if self.navigationOutActionView.frame.origin.y < self.customView.frame.height - 10 {
                print("dismiss navigation action")
                self.navigationOutActionView.frame = CGRectMake(0, self.customView.frame.height, self.customView.frame.width, self.actionViewHeight)
            }

            self.actionDismissLayerButton.backgroundColor = UIColor.clearColor()
            
            }, completion: {
                completed in
                self.actionDismissLayerButton.hidden = true
        })
        
    }
    
    func showGuitarActions(){
        actionDismissLayerButton.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.guitarActionView.frame = CGRectMake(0, self.customView.frame.height-self.actionViewHeight, self.customView.frame.width, self.actionViewHeight)
                self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
                self.actionDismissLayerButton.alpha = 0.3
            }, completion: nil)
    }
    
    func showNavigationOutActions() {
        
        actionDismissLayerButton.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.navigationOutActionView.frame = CGRectMake(0, self.customView.frame.height-self.actionViewHeight, self.customView.frame.width, self.actionViewHeight)
            self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
            self.actionDismissLayerButton.alpha = 0.3
            }, completion: nil)
    }

    
    //MARK: functions called from guitar action views
    func chordsSwitchChanged(uiswitch: UISwitch) {
        isChordShown = uiswitch.on
        toggleChordsDisplayMode()
    }
    
    func tabsSwitchChanged(uiswitch: UISwitch) {
        isTabsShown = uiswitch.on
        toggleChordsDisplayMode()
    }
    
    func toggleChordsDisplayMode() {
        if isChordShown {
          NSUserDefaults.standardUserDefaults().setInteger(1, forKey: isChordShownKey)
        } else {
          NSUserDefaults.standardUserDefaults().setInteger(2, forKey: isChordShownKey)
        }
        
        if isTabsShown {
          NSUserDefaults.standardUserDefaults().setInteger(1, forKey: isTabsShownKey)
        } else {
          NSUserDefaults.standardUserDefaults().setInteger(2, forKey: isTabsShownKey)
        }
        if !isChordShown && !isTabsShown { //hide the chordbase if we are showing chords and tabs
            chordBase.hidden = true
        } else {
            chordBase.hidden = false
        }
        
        startTime =  TimeNumber(time: Float(player.currentPlaybackTime))
        updateAll(startTime.toDecimalNumer())
        
        unblurImageIfAllIsHidden()
    }
    
    func lyricsSwitchChanged(uiswitch: UISwitch) {
        isLyricsShown = uiswitch.on
         toggleLyrics()
    }
    
    func toggleLyrics() {
        // show lyrics if the boolean is not hidden
        if isLyricsShown {
            lyricbase.hidden = false
        } else {
            lyricbase.hidden = true
        }
        // set to user defaults
        if isLyricsShown {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: isLyricsShownKey)
        } else {
            NSUserDefaults.standardUserDefaults().setInteger(2, forKey: isLyricsShownKey)
        }
        // if the chords base and lyrics base are all hiden, do not blur the image
        unblurImageIfAllIsHidden()
    }
    
    func unblurImageIfAllIsHidden() {
        if !isChordShown && !isTabsShown && !isLyricsShown {
            let image = player.nowPlayingItem!.artwork!.imageWithSize(CGSize(width: self.customView.frame.height/8, height: self.customView.frame.height/8))
            self.backgroundImageView.center.x = self.customView.center.x
            self.backgroundImageView.image = image
            artWorkUnblurred = true
        } else if artWorkUnblurred { //if only we have unblurred it before, we blur the image
            
            let image = player.nowPlayingItem!.artwork!.imageWithSize(CGSize(width: self.customView.frame.height/8, height: self.customView.frame.height/8))
            let blurredImage = image!.applyLightEffect()!
            self.backgroundImageView.center.x = self.customView.center.x
            self.backgroundImageView.image = blurredImage
            
            artWorkUnblurred = false
        }
    }

    func countDownChanged(uiswitch: UISwitch) {
        countdownOn = uiswitch.on
        if countdownOn {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: countdownOnKey)
        } else {
            NSUserDefaults.standardUserDefaults().setInteger(2, forKey: countdownOnKey)
        }
        
    }
    
    func setUpCountdownView() {
        countdownView = CountdownView(frame: CGRect(x: 0, y: CGRectGetMaxY(chordBase.frame)-35, width: 70, height: 70))
        countdownView.center.x = self.customView.center.x
        countdownView.backgroundColor = UIColor.clearColor()
        countdownView.hidden = true
        self.customView.addSubview(countdownView)
    }
    
    func startCountdown() {
        countDownStartSecond++
        countdownView.setNumber(countDownStartSecond+1)

        if countDownStartSecond >= 3 {
            //add tap gesture back
            chordBase.addGestureRecognizer(chordBaseTapGesture)
            progressBlockContainer.addGestureRecognizer(progressContainerTapGesture)
            
            countdownTimer.invalidate()
            countdownView.hidden = true
            countDownStartSecond = 0
            player.play()
        }

    }
    

    // MARK: functions in guitarActionView
    func speedStepperValueChanged(stepper: UIStepper) {
        timer.invalidate()
        let roundedValue = Double(round(10*stepper.value)/10)
        let adjustedSpeed = Float(speedMatcher[roundedValue]!)
        self.speed = adjustedSpeed
        self.player.currentPlaybackRate = adjustedSpeed
        self.startTimer()
        self.speedLabel.text = "Speed: \(adjustedSpeed)x"
        print("stepper value:\(stepper.value) and value \(speedMatcher[roundedValue])")
    }
    
    
    // MARK: functions used in NavigationOutView
    func browseTabs(button: UIButton) {
        
    }
    
    func goToTabsEditor(button: UIButton) {
        let tabsEditorVC = self.storyboard?.instantiateViewControllerWithIdentifier("tabseditorviewcontroller") as! TabsEditorViewController
        tabsEditorVC.theSong = self.player.nowPlayingItem!
        self.player.pause()
        self.dismissAction()
        self.presentViewController(tabsEditorVC, animated: true, completion: nil)
    }
    
    func browseLyrics(button: UIButton) {
        
    }
    func goToLyricsEditor(button: UIButton) {
        let lyricsEditor = self.storyboard?.instantiateViewControllerWithIdentifier("lyricstextviewcontroller")
        as! LyricsTextViewController
        lyricsEditor.songViewController = self
        lyricsEditor.theSong = self.player.nowPlayingItem
        self.player.pause()
        self.dismissAction()
        self.presentViewController(lyricsEditor, animated: true, completion: nil)
    }
    
    func goToArtist(button: UIButton) {
        self.dismissAction()
        self.dismissViewControllerAnimated(false, completion: {
            completed in
            if(self.musicViewController != nil){
                self.musicViewController.goToArtist(self.player.nowPlayingItem!.artist!)
            }
        })
    }

    func goToAlbum(button: UIButton) {
        self.dismissAction()
        self.dismissViewControllerAnimated(false, completion: {
            completed in
            if(self.musicViewController != nil){
                self.musicViewController.goToAlbum(self.player.nowPlayingItem!.albumTitle!)
            }
            
        })
    }
    
    // ISSUE: when app goes to background this is not called
    //stop timer,stop refreshing UIs after view is completely gone of sight
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("view will disappear")
        timer.invalidate()
        viewDidFullyDisappear = true
        if player.playbackState == MPMusicPlaybackState.Playing {
            player.currentPlaybackRate = 1
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
    }
    
    func calculateXPoints(){
        let width = chordBase.frame.width
        
        let margin:Float = 0.25
        let initialPoint:CGFloat = CGFloat(Float(width) * margin)
        let rightTopPoint:CGFloat = CGFloat(Float(width) * (1 - margin))
        
        let scale: CGFloat = 1 / 12
        let topWidth = rightTopPoint - initialPoint
        widthofbasetop = topWidth
        tan = Float(chordBase.frame.height) / Float(initialPoint)
        let topLeft = initialPoint + topWidth * scale
        
        topPoints = [CGFloat](count: 6, repeatedValue: 0)
        topPoints[0] = CGFloat(topLeft)
        for i in 1..<6 {
            topPoints[i] = topPoints[i - 1] + topWidth * scale * 2
        }
        
        bottomPoints = [CGFloat](count: 6, repeatedValue: 0)
        bottomPoints[0] = width * scale
        for i in 1..<6 {
            bottomPoints[i] = bottomPoints[i - 1] + width * scale * 2
        }
        
        //add things
        let top0: CGFloat = CGFloat(margin * Float(chordBase.frame.width) - 25)
        let buttom0: CGFloat = CGFloat(-25)
        
        topPoints.insert(top0, atIndex: 0)
        bottomPoints.insert(buttom0, atIndex: 0)
        
        let labelExample = UILabel()
        labelExample.text = "1"
        labelExample.font = UIFont.systemFontOfSize(minfont * chordBase.frame.width / widthofbasetop)
        labelExample.sizeToFit()
        let lenGoup = labelExample.frame.width / 2;
        
        maxylocation = chordBase.frame.height - lenGoup - chordBase.frame.height / 40
    }
    
    

    func refreshChordLabel(){
    
        if !isChordShown && !isTabsShown { //return both to avoid unnecessary computations
            return
        }
        
        if activelabels.count > 0 && start+1 < chords.count && (TimeNumber( time: startTime.toDecimalNumer() + timeToDisappear)).isLongerThan(chords[start+1].time)
        {
            activelabels[start-startdisappearing].alpha--
            start++
        }
        
        // Add new chord
        let end = start + activelabels.count
        if end < chords.count && (TimeNumber(time: freefallTime + startTime.toDecimalNumer())).isLongerThan(chords[end].time) {
            self.activelabelAppend(end)
        }
        
        var index: Int = 0
        while index < start - startdisappearing {
            let currentalpha: CGFloat = CGFloat(Float(activelabels[index].alpha) / Float(totalalpha))
            activelabels[index].alpha = activelabels[index].alpha - 1
            for label in activelabels[index].labels {
                label.alpha = currentalpha
            }
            index++
        }
        
        //remove chords at the bottom?
        if startdisappearing < start && (activelabels[0].alpha == 0 || TimeNumber(time: startTime.toDecimalNumer() + timeDisappeared).isLongerThan(chords[startdisappearing+1].time)) {
            for label in activelabels[0].labels{
                label.removeFromSuperview()
            }
            activelabels.removeAtIndex(0)
            startdisappearing++
        }
        
        // Change the location of each label
        for var i = 0; i < activelabels.count; ++i {
            let activelabel = activelabels[i]
            let yPosition = activelabel.ylocation
            let labels: [UIView] = activelabel.labels
            
            let scale = 2 * Float(yPosition) / tan / Float(widthofbasetop) + 1
            
            let transformsize = CGAffineTransformMakeScale(CGFloat(scale), CGFloat(scale))
            
            let xPosition = topPoints[0] - yPosition * (topPoints[0] - bottomPoints[0]) / chordBase.frame.height
            
            if isChordShown && isTabsShown { //show both chord name and tabs
                labels[0].hidden = false
                labels[0].center = CGPointMake(xPosition, CGFloat(yPosition))
                labels[1].center.y = CGFloat(yPosition)
                labels[1].transform = transformsize
            } else if isChordShown && !isTabsShown { //show only chord name
                 labels[0].hidden = false
                labels[0].center = CGPointMake(chordBase.frame.width / 2, CGFloat(yPosition))
            
            } else if !isChordShown && isTabsShown { // show only tabs name
                //TODO: remove chords labels and only show tabs
                // now it is just hidden, need to cease the compuation as well
                labels[0].hidden = true
                labels[1].center.y = CGFloat(yPosition)
                labels[1].transform = transformsize
            }
            
            activelabels[i].ylocation = activelabel.ylocation + movePerstep
            
            if( activelabels[i].ylocation > maxylocation){
                activelabels[i].ylocation = maxylocation
            }
        }
    }
    
    func refreshProgressBlock(){

        let newProgressPosition = (CGFloat(startTime.toDecimalNumer()) * progressWidthMultiplier) / KGLOBAL_progressBlock.frame.size.width
        
        let newOriginX = self.customView.center.x - CGFloat(startTime.toDecimalNumer()) * progressWidthMultiplier
        
        if !isPanning {
            self.progressChangedOrigin = newOriginX
            KGLOBAL_progressBlock.setProgress(newProgressPosition)
        }
        KGLOBAL_progressBlock.frame.origin.x = newOriginX
    }
    
    func refreshTimeLabel(){
        // update current time label
        currentTimeLabel.text = startTime.toDisplayString()
    }
    
    func refreshLyrics() {
        if !isLyricsShown { // avoid unnecessary computation if lyrics is hidden
            return
        }
        
        if currentLyricsIndex + 1 < lyric.lyric.count && startTime.isLongerThan(lyric.get(currentLyricsIndex+1).time) {
            currentLyricsIndex++
            topLyricLabel.text = lyric.get(currentLyricsIndex).str
            
            if currentLyricsIndex + 1 < lyric.lyric.count {
                bottomLyricLabel.text = lyric.get(currentLyricsIndex+1).str
            }
        }
        
        currentLyricsIndex = -1
        while(currentLyricsIndex + 1 < lyric.lyric.count){
            if lyric.get(currentLyricsIndex + 1).time.toDecimalNumer() > startTime.toDecimalNumer() {
                break
            }
            currentLyricsIndex++
        }
        
        if currentLyricsIndex == -1{
            topLyricLabel.text = "..."
        }
        else {
            topLyricLabel.text = lyric.get(currentLyricsIndex).str
        }
        if currentLyricsIndex + 1 < lyric.lyric.count {
            bottomLyricLabel.text = lyric.get(currentLyricsIndex+1).str
        }
        else {
            bottomLyricLabel.text = "--"
        }
    }
    
    func updateAll(time: Float){
        ///Set the start time
        startTime = TimeNumber(time: time)
        
        ///Remove all label in current screen
        for labels in activelabels{
            for label in labels.labels{
                label.removeFromSuperview()
            }
        }
        activelabels.removeAll(keepCapacity: true)
        
        //find the start of the chord whose time is larger than current time
        start = 0
        var last: Int = 0 //the end index of the chord that would show on the screen
        
        var begin: Int = 0
        var end: Int = chords.count - 1
        
        while true {
            let mid: Int = (begin + end) / 2
            if startTime.isLongerThan(chords[mid].time) {
                begin = mid
            } else {
                end = mid
            }
            if begin == (end - 1) {
                start = begin
                if startTime.isLongerThan(chords[end].time) {
                    start = end
                }
                break
            }
        }
        
        begin = 0
        end = chords.count - 1
        let tn = TimeNumber(time: startTime.toDecimalNumer() + freefallTime)
        while true {
            let mid: Int = (begin + end) / 2
            if tn.isLongerThan(chords[mid].time) {
                begin = mid
            } else {
                end = mid
            }
            if begin == (end - 1) {
                last = begin
                if tn.isLongerThan( chords[end].time ) {
                    last = end
                }
                break
            }
        }
        
        if start == last {
            self.activelabelAppend(start)
        }
        
        if start < last {
            if startTime.isLongerThan(chords[start].time) && (TimeNumber(time: startTime.toDecimalNumer() + timeToDisappear)).isLongerThan(chords[start+1].time) {
                self.start++
            }
            
            for i in start...last {
                self.activelabelAppend(i)
            }
        }
        
        startdisappearing = start
        
        //set the location of labels
        for var i = 0; i < activelabels.count; i++ {
            activelabels[i].ylocation = movePerstep * CGFloat((startTime.toDecimalNumer() + freefallTime - chords[start+i].time.toDecimalNumer()) * stepPerSecond)
            if activelabels[i].ylocation > maxylocation {
                activelabels[i].ylocation = maxylocation
            }
        }
        
        update()
        //Update the content of the lyric
    }
    
    func playPause(recognizer: UITapGestureRecognizer) {
        if player.playbackState == MPMusicPlaybackState.Paused {
            if countdownOn {
                //temporarily disable tap gesture to avoid accidental start count down again
                chordBase.removeGestureRecognizer(chordBaseTapGesture)
                progressBlockContainer.removeGestureRecognizer(progressContainerTapGesture)
                
                countdownView.hidden = false
                countdownView.setNumber(1)
                countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
                NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
                
            } else {
                player.play()
            }
            
        } else {
            //nowPlayingItemSpeed = player.currentPlaybackRate
            player.pause()
        }
    }
    
    func startTimer(){
        //NOTE: To prevent startTimer() to be called consecutively
        //which would double the update speed. We only
        //start the timer when it is not valid
        //In case of receiving song changed and playback state 
        //notifications, notifications are triggered twice somehow
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval( 1 / Double(stepPerSecond) / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            // make sure the timer is not interfered by scrollview scrolling
        }
    }
    
    func update(){
        startTime.addTime(Int(100 / stepPerSecond))
        refreshChordLabel()
        refreshLyrics()
        refreshProgressBlock()
        refreshTimeLabel()
    }
    
    
    func createLabels(name: String, fretPositions: [String]) -> (labels: [UIView], ylocation: CGFloat, alpha: Int){
        var res = [UIView]()
        
        let chordNameLabel = UILabel(frame: CGRectMake(0, 0, 40, 0))
        
        chordNameLabel.text = name
        chordNameLabel.textColor = UIColor.blackColor()
        chordNameLabel.sizeToFit()
        chordNameLabel.textAlignment = NSTextAlignment.Center
        chordNameLabel.font = UIFont.systemFontOfSize(minfont)
        res.append(chordNameLabel)
        self.chordBase.addSubview(chordNameLabel)
        
        let view = UIView(frame: CGRectMake(0, 0, CGFloat(topPoints[6] - topPoints[1]), CGFloat(minfont)))
        
        
        if isTabsShown {
            for i in 0..<fretPositions.count {
                let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
                label.font = UIFont.systemFontOfSize(CGFloat(minfont))
                label.text = fretPositions[i]
                label.sizeToFit()
                label.textColor = UIColor.silverGray()
                label.textAlignment = NSTextAlignment.Center
                label.center = CGPointMake(topPoints[i+1] - topPoints[1], view.frame.height / 2)
                view.addSubview(label)
            }
            chordBase.addSubview(view)
            view.center.x = chordBase.frame.width / 2
            res.append(view)
        }
        
        return (res, 0, totalalpha)
    }
    
    //////////////////////////////////

    func activelabelAppend(index: Int){
        activelabels.append(createLabels(chords[index].tab.name, fretPositions: chords[index].tab.contentArray))
        dealWithLabelofChordName(activelabels.last!.labels.first! as! UILabel)
    }

    private func dealWithLabelofChordName(chordLabel:UILabel){
        //make the text glow
        chordLabel.textColor = UIColor.blackColor()
        let color:UIColor = chordLabel.textColor
        chordLabel.layer.shadowColor = color.CGColor
        chordLabel.layer.shadowRadius = 4.0
        chordLabel.layer.shadowOpacity = 1.0
        chordLabel.layer.shadowOffset = CGSizeZero
        chordLabel.layer.masksToBounds = false
        
        chordLabel.alpha = 0.9
        
        //make the frame of the label fit to the text
        let chordNSString:NSString = NSString(string: chordLabel.text!)
        if(chordNSString.length >= 2 && chordNSString.length <= 3){
            
            let fontSize:CGFloat = 18.0
            
            let textFont = UIFont.systemFontOfSize(fontSize)
            
            
            chordLabel.font = textFont
       
            chordLabel.sizeToFit()
            
        } else if(chordNSString.length >= 4 ){
            
            let fontSize:CGFloat = 16.0
            
            let textFont = UIFont.systemFontOfSize(fontSize)
            
            chordLabel.font = textFont
            chordLabel.sizeToFit()
        }
    }
    
    // MARK: Fix to portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}

extension SongViewController{
    func reloadSongVC(selectedFromTable selectedFromTable:Bool){
        
        pthread_rwlock_wrlock(&self.rwLock)
        
        self.selectedFromTable = selectedFromTable
        
        removeAllObserver()
        
        let nowPlayingItem = self.player.nowPlayingItem
        let nowPlayingItemDuration = nowPlayingItem!.playbackDuration
        
            
        self.musicDataManager.initializeSongToDatabase(nowPlayingItem!)
        self.firstloadSongTitle = nowPlayingItem!.title
        self.firstLoadSongTime = nowPlayingItemDuration
        
        
        updateMusicData(nowPlayingItem!)
        setShuffleButtonImage()
        
        self.customView.removeFromSuperview()
        self.view.addSubview(self.customView)
        
        //self.updateMusicData(nowPlayingItem!)
        
        // The following won't run when selected from table
        // update the progressblockWidth
        
        self.progressBlockViewWidth = nil
        
     
    
        //remove from superView
        if(KGLOBAL_progressBlock != nil ){
            KGLOBAL_progressBlock.removeFromSuperview()
        }
        
        // get a new progressBlock
        var progressBarWidth:CGFloat!
        progressBarWidth = CGFloat(nowPlayingItemDuration) * progressWidthMultiplier
        KGLOBAL_progressBlock = SoundWaveView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: 161))
        KGLOBAL_progressBlock.center.y = progressContainerHeight
        self.progressBlockContainer.addSubview(KGLOBAL_progressBlock)
        
        //if there is soundwave in the coredata then we load the image in viewdidload
        if let soundWaveData = musicDataManager.getSongWaveFormImage(nowPlayingItem!) {
            KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
            print("sound wave data found")
            KGLOBAL_init_queue.suspended = false
            isGenerated = true
        }else{
            //if didn't find it then we will generate then waveform later, in the viewdidappear method
            // this is a flag to determine if the generateSoundWave function will be called
            isGenerated = false
        }
        
        
        KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 1.0)
        
        if self.player.playbackState == MPMusicPlaybackState.Paused{
            KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 0.5)
        }
        
        // if we are NOT repeating song
   
            
        self.songNameLabel.attributedText = NSMutableAttributedString(string: nowPlayingItem!.title!)
        self.songNameLabel.textAlignment = NSTextAlignment.Center
        self.artistNameLabel.text = nowPlayingItem!.artist
        print(self.artistNameLabel.text)
        
        if let artwork = self.player.nowPlayingItem!.artwork {
            let image = artwork.imageWithSize(CGSize(width: self.customView.frame.height/10, height: self.customView.frame.height/10))
            let blurredImage = image!.applyLightEffect()!
            self.textColor = blurredImage.averageColor()
            
            self.backgroundImageView.center.x = self.customView.center.x
            self.backgroundImageView.image = blurredImage
        }
   
        self.totalTimeLabel.text = TimeNumber(time: Float(nowPlayingItemDuration)).toDisplayString()
 
        self.speed = 1
        //self.nowPlayingItemSpeed = 1
        if self.player.playbackState == MPMusicPlaybackState.Playing{
            self.timer.invalidate()
            self.startTimer()
        }
        
        self.updateAll(0)
        pthread_rwlock_unlock(&self.rwLock)
    }

}

