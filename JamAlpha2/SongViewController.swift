import UIKit
import MediaPlayer
import AVFoundation
import Alamofire
import Haneke
import StoreKit
import SwiftyJSON

let stepPerSecond: Float = 100   //steps of chord move persecond
//Parameters to simulate the disappearing
let timeToDisappear: Float = 0.8
let timeDisappeared: Float = 0.4
let totalalpha: Int = Int((timeToDisappear - timeDisappeared) * stepPerSecond)

let progressContainerHeight:CGFloat = 80 //TODO: Change to percentange, used in LyricsSync
let progressWidthMultiplier:CGFloat = 2
let soundwaveHeight: CGFloat = 161


class SongViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, SKStoreProductViewControllerDelegate {
    
    var soundwaveUrl = "" //url retreieved from backend to download image from S3
    var musicViewController: MusicViewController!
    private var rwLock = pthread_rwlock_t()
    
    var searchAPI:SearchAPI! = SearchAPI()
    
    //for nsoperation
    var isGenerated:Bool = true
    
    //time for chords to fall from top to bottom of chordbase
    var freefallTime:Float = 3.0
    var minfont: CGFloat = 15
    
    var selectedFromTable = true
    
    var viewDidFullyDisappear = true
    
    var player: MPMusicPlayerController!
    var avPlayer:AVQueuePlayer!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    //MARK: tutorial-related
    var tutorialScrollView: UIScrollView!
    var numberOfTutorialPages = 5
    var tutorialIndicators = [UIView]()
    var indicatorOriginXPositions = [CGFloat]()
    
    var backgroundImageView: UIImageView!
    var backgroundScaleFactor: CGFloat = 0.4
    var backgroundImage: UIImage?
    var blurredImage: UIImage?
    
    var buttonDimension: CGFloat = 50
    var pulldownButton:UIButton!
    var tuningLabels = [UILabel]() //6 labels for each string
    var capoButton: UIButton!
    var capoLabel: UILabel!
    
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
    
    //buttons in center of chordbase/lyricsBase to prompt users to add tabs/lyrics
    var addTabsPrompt: UIButton!
    var addLyricsPrompt: UIButton!
    
    var chordBaseTapGesture: UITapGestureRecognizer!
    //MARK: progress Container
    var progressBlockViewWidth:CGFloat?
    var progressBlockContainer:UIView!
    var progressChangedOrigin:CGFloat!
    var panRecognizer:UIPanGestureRecognizer!
    var isPanning = false
    
    var progressContainerTapGesture: UITapGestureRecognizer!

    var currentTimeLabel:UILabel!
    var totalTimeLabel:UILabel!
    
    let minimumChordCount = 3 // there must be at least three chords in a tabs to work
    var chords = [Chord]()
    var start: Int = 0
    var startdisappearing: Int = 0
    var activelabels:[(labels: [UIView], ylocation: CGFloat, alpha: Int)] = []
    var startTime: TimeNumber = TimeNumber(second: 0, decimal: 0)
    var volume:Float = 0
    
    //time
    //var timer: NSTimer?
    var updateInterval: NSTimeInterval = 0 //used to calculate count down reduce
    var currentChordTime:Float = 0
   // var toChordTime:Float = 0
    
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
    let speedLabels = [0.7: "0.5x", 0.8: "0.65x" ,0.9: "0.8x",  1.0: "1.0x" ,1.1: "1.25x"  ,1.2 : "1.5x", 1.3: "2x"]
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
    var countDownStartSecond = 3 //count from 3 to 1
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
    var countdownOn = false
    var countdownOnKey = "countdownOn"
    
    var actionViewHeight: CGFloat = 44 * 6 + 5// a row height * number of rows + 5 lines of separator of height 1
    //var navigationOutActionViewHeight: CGFloat = 44 * 4 + 4 //4 rows of height + 4 lines
    var actionDismissLayerButton: UIButton!
    
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
    
    var nowPlayingMediaItem: MPMediaItem!
    var nowPlayingItemDuration:NSTimeInterval!
    var isRemoveProgressBlock = true
    var isBlurred:Bool = true
    
    var isSongNeedPurchase = false
    var songNeedPurchase: SearchResult!
    var playPreveiwButton:UIButton!
    var previewActionViewHeight: CGFloat = 54 * 4 + 3
    var previewView:UIView!
    var displayLink: CADisplayLink!
    var previewProgress: KDCircularProgress!
    var previewProgressCenterView: UIView!
    var isViewDidAppear:Bool = false
    
    var storeViewController:SKStoreProductViewController!
    
    var isDemoSong = false
    
    var demoItem:AVPlayerItem!
    var demoItemDuration:Float!
    var selectedRow:Int!

    var isChangedSpeed:Bool = true
    var selectedFromSearchTab = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pthread_rwlock_init(&rwLock, nil)
        
        if(!isSongNeedPurchase){
            if (KAVplayer != nil && KAVplayer.rate > 0){
                KAVplayer.rate = 0
                KAVplayer = nil
            }
            if isDemoSong {
                avPlayer = MusicManager.sharedInstance.avPlayer
                self.demoItem = avPlayer.currentItem
                self.demoItemDuration = self.demoItem.getDuration()
                self.getSongIdAndSoundwaveUrlFromCloud(demoItem,completion: {succeed in Void()})
                removeAllObserver()
            } else {
                player = MusicManager.sharedInstance.player
                print("VIEWDIDLOAD: \(player.nowPlayingItem!.title!)")
                self.nowPlayingMediaItem = player.nowPlayingItem
                self.nowPlayingItemDuration = self.nowPlayingMediaItem.playbackDuration
                self.getSongIdAndSoundwaveUrlFromCloud(nowPlayingMediaItem,completion: {succeed in Void()})
                removeAllObserver()
            }
        } else {
            MusicManager.sharedInstance.player.stop()
            if(MusicManager.sharedInstance.avPlayer.currentItem != nil){
                MusicManager.sharedInstance.avPlayer.pause()
                MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
                MusicManager.sharedInstance.avPlayer.removeAllItems()
            }
            self.selectedFromSearchTab = true
           let baseVC = ((UIApplication.sharedApplication().delegate as! AppDelegate).rootViewController().childViewControllers[0].childViewControllers[0] as! BaseViewController)
            for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                self.musicViewController = musicVC
            }
            KGLOBAL_nowView.stop()
            CoreDataManager.initializeSongToDatabase(songNeedPurchase)
        }
        
        //hide tab bar
        self.tabBarController?.tabBar.hidden = true
        setUpBackgroundImage()
        setUpTopButtons()
        setUpNameAndArtistButtons()
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
        
        if(!isSongNeedPurchase){
            updateMusicData(isDemoSong ? demoItem : nowPlayingMediaItem )
            updateFavoriteStatus(isDemoSong ? demoItem : nowPlayingMediaItem)
        }else{
            updateMusicData(songNeedPurchase)
            updateFavoriteStatus(songNeedPurchase)
        }
        
        movePerstep = maxylocation / CGFloat(stepPerSecond * freefallTime)
        loadDisplayMode()
    }

    deinit{
        pthread_rwlock_destroy(&rwLock)
    }
    
    func removeAllObserver(){
        if(!isSongNeedPurchase){
            NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
            if(player != nil){
               player.endGeneratingPlaybackNotifications()
            }
        }
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
            viewDidFullyDisappear = false
            if !isSongNeedPurchase {
                resumeSong()
            }
            if(isDemoSong){
                self.avPlayer.addObserver(self, forKeyPath: "rate", options: [.New, .Initial], context: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(!isRemoveProgressBlock){
            isRemoveProgressBlock = true
        }else{
            if(!isSongNeedPurchase){
                self.registerMediaPlayerNotification()
            }
        }
        if(!isGenerated && !isSongNeedPurchase){
            generateSoundWave(isDemoSong ? demoItem : nowPlayingMediaItem )
        }else if (!isGenerated && isSongNeedPurchase) {
                self.getSongIdAndSoundwaveUrlFromCloud(songNeedPurchase,completion: {
                    succeed in
                    if !self.soundwaveUrl.isEmpty {
                        AWSS3Manager.downloadImage(self.soundwaveUrl, isProfileBucket: false, completion: {
                            image in
                            dispatch_async(dispatch_get_main_queue()) {
                                let data = UIImagePNGRepresentation(image)
                                KGLOBAL_progressBlock.setWaveFormFromData(data!)
                                CoreDataManager.saveSoundWave(self.songNeedPurchase, soundwaveImage: data!)
                                self.isGenerated = true
                                self.soundwaveUrl = ""
                                return
                            }
                        })
                    }
                })
        }
        isViewDidAppear = true
    }
    

    func showTutorial() {
        if isDemoSong {
            avPlayer.pause()
        } else {
            player.pause()
        }
        
        tutorialScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        tutorialScrollView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(tutorialScrollView)

        tutorialScrollView.bounces = false
        tutorialScrollView.pagingEnabled = true
        tutorialScrollView.delegate = self
        for i in 0..<numberOfTutorialPages{
            let tutorialImage = UIImageView(frame: CGRect(x: CGFloat(i) * view.frame.width, y: 0, width: view.frame.width, height: view.frame.height))
            tutorialImage.image = UIImage(named: "tutorial_\(i+1)_iPhone6")
            
            tutorialScrollView.addSubview(tutorialImage)
            
            if i == 4 {
                let startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 101, height: 43))
                startButton.center = CGPoint(x: 4.5 * self.view.frame.width, y: self.view.center.y-100)
                startButton.setImage(UIImage(named: "start_button"), forState: .Normal)
                startButton.addTarget(self, action: "hideTutorial", forControlEvents: .TouchUpInside)
                tutorialScrollView.addSubview(startButton)
            }
        }
        tutorialScrollView.contentSize = CGSize(width: 5 * tutorialScrollView.frame.width, height: tutorialScrollView.frame.height)
        
        var originX = 0
        if numberOfTutorialPages % 2 == 0 {//even
            originX = (numberOfTutorialPages/2) * 10 + (numberOfTutorialPages/2)*5
        } else {
            originX = (numberOfTutorialPages/2) * 10 + (numberOfTutorialPages/2)*5 + 5
        }
        
        for i in 0..<numberOfTutorialPages {
            let circle = UIView(frame: CGRect(x: self.view.center.x - CGFloat(originX) + CGFloat(i * 15), y: self.view.frame.height - 20, width: 10, height: 10))
            circle.backgroundColor = UIColor.whiteColor()
            
            if i == 0 {
                circle.backgroundColor = UIColor.mainPinkColor()
            }
            circle.layer.cornerRadius = 5
            tutorialScrollView.addSubview(circle)
            tutorialIndicators.append(circle)
            indicatorOriginXPositions.append(circle.frame.origin.x)
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if  tutorialScrollView.hidden {
            return
        }
        
        for i in 0..<numberOfTutorialPages {
            tutorialIndicators[i].frame.origin.x = scrollView.contentOffset.x + indicatorOriginXPositions[i]
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if  tutorialScrollView.hidden {
            return
        }
        
        let currentPage = scrollView.contentOffset.x / self.view.frame.width
        for i in 0..<numberOfTutorialPages {
            if i == Int(currentPage) {
                tutorialIndicators[i].backgroundColor = UIColor.mainPinkColor()
            } else {
                tutorialIndicators[i].backgroundColor = UIColor.whiteColor()
            }
        }
    }

    
    func hideTutorial() {
        tutorialScrollView.hidden = true
        if isDemoSong {
            avPlayer.play()
        } else {
            player.play()
        }
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowTutorial)
    }
    
    func setUpBackgroundImage(){
        //create an UIImageView
        self.view.backgroundColor = UIColor.grayColor()
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.height))
        self.view.addSubview(backgroundImageView)
        //get the image from MPMediaItem
        if !isSongNeedPurchase{
            loadBackgroundImageFromMediaItem(isDemoSong ? demoItem : nowPlayingMediaItem )
        } else if self.backgroundImage  == nil { //make sure album cover downloaded from iTunes is not blank
            currentImage = UIImage(named: "liwengbg")
            blurredImage = currentImage?.applyLightEffect()!
            currentImage = nil
        }
        
        backgroundImageView.center.x = self.view.center.x
        backgroundImageView.image = blurredImage
    }
    
    func loadBackgroundImageFromMediaItem(item: Findable) {
        
        if let artwork = item.getArtWork() {
            currentImage = artwork.imageWithSize(CGSize(width: self.view.frame.height/8, height: self.view.frame.height/8))
            if currentImage == nil {
                self.currentImage = nil
                CoreDataManager.initializeSongToDatabase(item)
                dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))) {
                   self.reloadBackgroundImageAfterSearch(item)
                }
            }else{
                self.backgroundImage = currentImage
                self.blurredImage = currentImage!.applyLightEffect()!
            }
        } else {
            //TODO: add a placeholder album cover
            self.currentImage = UIImage(named: "liwengbg")
            self.backgroundImage = currentImage
            self.blurredImage = currentImage!.applyLightEffect()!
            dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))) {
               self.reloadBackgroundImageAfterSearch(item)
            }
        }
       
    }

    
    func reloadBackgroundImageAfterSearch(item:Findable){
        let searchText = item.getArtist() + " " + item.getTitle()
        
        SearchAPI.getBackgroundImageForSong(searchText, imageSize: SearchAPI.ImageSize.Large, completion: {
            image in
            self.currentImage = image
            self.backgroundImage = image
            self.blurredImage = image.applyLightEffect()!
            self.isBlurred = !self.isBlurred
            if (self.isChordShown || self.isTabsShown || self.isLyricsShown) && !self.isBlurred {
                dispatch_async(dispatch_get_main_queue()) {
                    self.backgroundImageView.image = self.blurredImage
                }
                self.isBlurred = true
            } else if (!self.isChordShown && !self.isTabsShown && !self.isLyricsShown && self.isBlurred) { //
                    dispatch_async(dispatch_get_main_queue()) {
                        self.backgroundImageView.image = self.backgroundImage
                    }
                    self.isBlurred = false
                }
            }
        )
    }
    
    
    func setUpTopButtons() {

        topView = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: self.view.frame.width, height: topViewHeight))
        self.view.addSubview(topView)
        
     
        let buttonCenterY: CGFloat = topViewHeight/2
        let buttonMargin: CGFloat = self.view.frame.width / 12
        pulldownButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
        pulldownButton.setImage(UIImage(named: "pullDown"), forState: UIControlState.Normal)
        pulldownButton.center = CGPoint(x: buttonMargin, y: buttonCenterY)
        pulldownButton.addTarget(self, action: "dismissController:", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(pulldownButton)
        
        capoButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
        capoButton.setImage(UIImage(named: "blankCircle"), forState: .Normal)
        capoButton.addTarget(self, action: "tuningPressed:", forControlEvents: .TouchUpInside)
        capoButton.center = CGPoint(x: buttonMargin * 11, y: buttonCenterY)
        topView.addSubview(capoButton)
        
        capoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        capoLabel.textColor = UIColor.whiteColor()
        capoLabel.font = UIFont.systemFontOfSize(16)
        capoLabel.center = capoButton.center
        capoLabel.userInteractionEnabled = false
        capoLabel.textAlignment = .Center
        capoLabel.text = "0"
        topView.addSubview(capoLabel)
        
        let topViewSeparator = UIView(frame: CGRect(x: 11, y: CGRectGetMaxY(topView.frame), width: self.view.frame.width-11*2, height: 0.5 ))
        topViewSeparator.backgroundColor = UIColor.baseColor()
        self.view.addSubview(topViewSeparator)
    }

    private func updateTuning(tuning: String) {
        print("current tuning is \(tuning)")
        let tuningArray = Tuning.toArray(tuning)
        let tuningToShow = Array(tuningArray.reverse())
        for i in 0..<tuningLabels.count {
            tuningLabels[i].text = tuningToShow[i]
            tuningLabels[i].sizeToFit()
            tuningLabels[i].center = CGPoint(x: topPoints[i+1]+chordBase.frame.origin.x, y: chordBase.frame.origin.y-10)
        }
    }

    private func updateCapo(capo: Int) {
        capoLabel.text = "\(capo)"
    }
    
    func setUpTuningLabels() {
        for i in 1..<topPoints.count{
            let tuningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 15))
            tuningLabel.textColor = UIColor.whiteColor()
            tuningLabel.font = UIFont.systemFontOfSize(minfont-5)
            tuningLabel.textAlignment = .Center
            tuningLabel.center = CGPoint(x: topPoints[i]+chordBase.frame.origin.x, y: chordBase.frame.origin.y-10)
            self.view.addSubview(tuningLabel)
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
        
        var title:String!
        if(!isSongNeedPurchase){
            title = isDemoSong ? demoItem.getTitle() : nowPlayingMediaItem.title!
            artistNameLabel.text = isDemoSong ? demoItem .getArtist() : nowPlayingMediaItem.artist
        } else {
            if let track = songNeedPurchase.trackName {
                title = track
            }
            if let artist = songNeedPurchase.artistName {
                artistNameLabel.text = artist
            }

        }
        
        let attributedString = NSMutableAttributedString(string:title)
        songNameLabel.attributedText = attributedString
        songNameLabel.textAlignment = NSTextAlignment.Center
        
        songNameLabel!.font = UIFont.systemFontOfSize(18)
        artistNameLabel!.font = UIFont.systemFontOfSize(12)
        
        //increase edge width
        //TODO: set a max of width to avoid clashing with pulldown and tuning button
        songNameLabel.frame.size = CGSize(width: songNameLabel.frame.width + 20, height: 30)
        artistNameLabel.frame.size = CGSize(width: artistNameLabel.frame.width + 20, height: 30)
        songNameLabel.center.x = self.view.frame.width / 2
        songNameLabel.center.y = pulldownButton.center.y - 7
        
        artistNameLabel.center.x = self.view.frame.width / 2
        artistNameLabel.center.y = CGRectGetMaxY(songNameLabel.frame) + 3
        
        songNameLabel.textColor = UIColor.whiteColor()
        artistNameLabel.textColor =  UIColor.whiteColor()
        
        artistNameLabel.backgroundColor = UIColor.clearColor()
        
        topView.addSubview(songNameLabel)
        topView.addSubview(artistNameLabel)
    }

    
    func setUpControlButtons(){
        let marginToCenterAlbumImage = (self.view.frame.width - backgroundScaleFactor * self.view.frame.height)/2
        previousButton = UIButton(frame: CGRect(x: 5, y: 0, width: buttonDimension, height: buttonDimension))
        previousButton.setImage(UIImage(named: "previousplay"), forState: .Normal)
        previousButton.addTarget(self, action: "previousPressed:", forControlEvents: .TouchUpInside)
        
        previousButton.center = CGPoint(x: marginToCenterAlbumImage/2, y: self.chordBase.frame.origin.y + self.previousButton.frame.size.height/2)
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
        nextButton.setImage(UIImage(named: "nextplay"), forState: .Normal)
        nextButton.addTarget(self, action: "nextPressed:", forControlEvents: .TouchUpInside)
        nextButton.center = CGPoint(x: self.view.frame.width - marginToCenterAlbumImage/2, y: self.chordBase.frame.origin.y + self.nextButton.frame.size.height/2)
        self.view.addSubview(previousButton)
        self.view.addSubview(nextButton)
        
        if(isSongNeedPurchase || isDemoSong){
            previousButton.hidden = true
            nextButton.hidden = true
        }
    }
    
    var isNext = true
    
    func previousPressed(button: UIButton){
        stopTimer()
        if isDemoSong {
            isNext = false
            changeDemoSong()
          
        }else{
           player.skipToPreviousItem()
        }
    }
    
    func nextPressed(button: UIButton){
        stopTimer()
        if isDemoSong {
            isNext = true
            changeDemoSong()
        } else {
            player.skipToNextItem()
        }
    }
    
    func changeDemoSong(){
        avPlayer.seekToTime(kCMTimeZero)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayer.currentItem)
        if(!viewDidFullyDisappear){
            avPlayer.removeObserver(self, forKeyPath: "rate")
        }
        let rate = avPlayer.rate
        if(isNext){
            self.selectedRow = self.selectedRow + 1
            if(self.selectedRow == self.musicViewController.demoSongs.count){
                self.selectedRow = 0
            }
        }else{
            self.selectedRow = self.selectedRow - 1
            if(self.selectedRow == -1){
                self.selectedRow = self.musicViewController.demoSongs.count - 1
            }
        }
        
        MusicManager.sharedInstance.setDemoSongQueue(self.musicViewController.demoSongs, selectedIndex:selectedRow)
        avPlayer.seekToTime(kCMTimeZero)
        if(!viewDidFullyDisappear){
            self.currentLocalSongChanged(rate)
            self.avPlayer.addObserver(self, forKeyPath: "rate", options: [.New, .Initial], context: nil)
        }
        if(isDemoSong){
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeDemoSong"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayer.currentItem)
        }
    }
    
    
    func dismissController(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func canFindTabsFromCoreData(song: Findable) -> Bool {
        self.chords = [Chord]()
        
        var chords = [Chord]()
        var tuning = ""
        var capo = 0
        (chords, tuning, capo, _, _) = CoreDataManager.getTabs(song, fetchingUsers: false)
        if chords.count > 2 {
            self.chords = chords
            updateTuning(tuning)
            updateCapo(capo)
            self.addTabsPrompt.hidden = true
            return true
        }
        updateCapo(capo)
        return false
    }
    
    private func canFindLyricsFromCoreData(song: Findable) -> Bool {
        self.lyric = Lyric()
        self.topLyricLabel.text = ""
        self.bottomLyricLabel.text = ""
        
        var lyric = Lyric()
        (lyric, _) = CoreDataManager.getLyrics(song, fetchingUsers: false)
        
        if lyric.lyric.count > 1 {
            self.lyric = lyric
            self.addLyricsPrompt.hidden = true
            return true
        }
        return false
    }
    
    func updateMusicData(song: Findable) {
        //if nothing in core data, we look up the cloud
        if !canFindTabsFromCoreData(song) {
            APIManager.downloadMostLikedTabs(song, completion: {
                found, download in
                
                 //if still not found, we show a prompt
                if !found {
                    if !self.isSongNeedPurchase {
                        self.addTabsPrompt.hidden = false
                    }
                    return
                }
                self.addTabsPrompt.hidden = true
                
                CoreDataManager.saveTabs(song, chords: download.chords, tabs: download.tabs, times: download.times, tuning: download.tuning, capo: download.capo, userId: download.editor.userId, tabsSetId: download.id, visible: true)
                
                if self.canFindTabsFromCoreData(song) {
                    if(!self.isSongNeedPurchase){
                        let tempPlaytime = self.isDemoSong ?  self.avPlayer.currentTime().seconds
                            : self.player.currentPlaybackTime
                        if !tempPlaytime.isNaN {
                            self.updateAll(Float(tempPlaytime))
                        } else {
                            self.updateAll(0)
                        }
                    }else{
                        self.updateAll(0)
                    }
                }
            })
        }
        
        if !canFindLyricsFromCoreData(song) {
            APIManager.downloadMostLikedLyrics(song, completion: {
                found, download in
                //if still not found, we show a prompt
                if !found {
                    if !self.isSongNeedPurchase{
                        self.addLyricsPrompt.hidden = false
                    }
                    return
                }
                self.addLyricsPrompt.hidden = true
                
                var times = [Float]()
                for t in download.times {
                    times.append(Float(t))
                }
                CoreDataManager.saveLyrics(song, lyrics: download.lyrics, times: times, userId: download.editor.userId, lyricsSetId: download.id)
                
                if self.canFindLyricsFromCoreData(song) {
                    if(!self.isSongNeedPurchase){
                        let tempPlaytime = self.isDemoSong ? self.avPlayer.currentTime().seconds : self.player.currentPlaybackTime
                        if !tempPlaytime.isNaN {
                            self.updateAll(Float(tempPlaytime))
                        } else {
                            self.updateAll(0)
                        }
                    }else{
                        self.updateAll(0)
                    }
                }
            })
        }
    }
    
    //for testing
    func setUpTestData(song: MPMediaItem){
         if song.title == "Rolling In The Deep" {
            chords = Chord.getRollingChords()
            lyric = Lyric.getRollingLyrics()
        } else if song.title == "I'm Yours"{
            chords = Chord.getJasonMrazChords()
            lyric = Lyric.getJasonMrazLyrics()
         }else if song.title == "Daughters" {
            chords = Chord.getDaughters()
            lyric = Lyric.getDaughters()
            
         } else if song.title == "More Than Words"{ // use more than words for everything else for now
            chords = Chord.getExtremeChords()
            lyric = Lyric.getExtremeLyrics()
        }
        updateTuning("E-B-G-D-A-E")
        updateCapo(0)
    }
    
    
    func setUpChordBase(){
        let marginToTopView: CGFloat = 20
        let marginToProgressContainer: CGFloat = 10
        
        basesHeight = self.view.frame.height - topViewHeight - marginToTopView - bottomViewHeight - progressContainerHeight - marginBetweenBases - marginToProgressContainer
        
        chordBase = ChordBase(frame: CGRect(x: 0, y: CGRectGetMaxY(topView.frame) + marginToTopView, width: self.view.frame.width * 0.62, height: basesHeight * 0.55))
        chordBase.center.x = self.view.center.x
        chordBase.backgroundColor = UIColor.clearColor()
        
        panRecognizer = UIPanGestureRecognizer(target: self, action:Selector("handleChordBasePan:"))
        panRecognizer.delaysTouchesEnded = true
        
        panRecognizer.delegate = self
        chordBase.addGestureRecognizer(panRecognizer)
        
        self.view.addSubview(chordBase)
        
        //add tap gesture to chordbase too
        chordBaseTapGesture = UITapGestureRecognizer(target: self, action: "playPause:")
        chordBase.addGestureRecognizer(chordBaseTapGesture)
        
        addTabsPrompt = UIButton(frame: CGRect(x: 0, y: chordBase.frame.height-30, width: 200, height: 25))
        addTabsPrompt.setTitle("Add tabs here", forState: .Normal)
        addTabsPrompt.titleLabel?.font = UIFont.systemFontOfSize(20)
        addTabsPrompt.center.x = chordBase.frame.width/2
        addTabsPrompt.setTitleColor(UIColor.silverGray(), forState: .Normal)
        addTabsPrompt.addTarget(self, action: "goToTabsEditor", forControlEvents: .TouchUpInside)
        addTabsPrompt.hidden = true
        chordBase.addSubview(addTabsPrompt)
        
        calculateXPoints()
    }
    
    func setUpLyricsBase(){
        //Lyric labels
        currentLyricsIndex = -1
        let sideMargin: CGFloat = 20
        
        lyricbase = UIView(frame: CGRect(x: sideMargin, y: CGRectGetMaxY(chordBase.frame) + marginBetweenBases, width: self.view.frame.width - 2 * sideMargin, height: basesHeight * 0.4))
        lyricbase.backgroundColor = UIColor.baseColor()
        
        self.view.addSubview(lyricbase)
        
        let contentMargin: CGFloat = 5
        
        lyricbase.layer.cornerRadius = 20
        
        topLyricLabel.frame = CGRectMake(contentMargin, 0, lyricbase.frame.width - 2 * contentMargin, 2 * lyricbase.frame.height / 3)
        topLyricLabel.center.y = lyricbase.frame.height / 3
        topLyricLabel.numberOfLines = 3
        topLyricLabel.textAlignment = NSTextAlignment.Center
        topLyricLabel.font = UIFont.systemFontOfSize(23)
        topLyricLabel.lineBreakMode = .ByWordWrapping
        topLyricLabel.textColor = UIColor.silverGray()
        lyricbase.addSubview(topLyricLabel)
        
        bottomLyricLabel.frame = CGRectMake(contentMargin, 0, lyricbase.frame.width - 2 * contentMargin, lyricbase.frame.height / 3)
        bottomLyricLabel.center.y =  2 * lyricbase.frame.height / 3 + 10
        bottomLyricLabel.numberOfLines = 3
        bottomLyricLabel.textAlignment = NSTextAlignment.Center
        bottomLyricLabel.font = UIFont.systemFontOfSize(16)
        bottomLyricLabel.lineBreakMode = .ByWordWrapping
        bottomLyricLabel.textColor = UIColor.silverGray()
        lyricbase.addSubview(bottomLyricLabel)
        
        addLyricsPrompt = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        addLyricsPrompt.setTitle("Add lyrics here", forState: .Normal)
        addLyricsPrompt.titleLabel?.font = UIFont.systemFontOfSize(20)
        addLyricsPrompt.center = CGPoint(x: lyricbase.frame.width/2, y: lyricbase.frame.height/2)
        addLyricsPrompt.setTitleColor(UIColor.silverGray(), forState: .Normal)
        addLyricsPrompt.addTarget(self, action: "goToLyricsEditor", forControlEvents: .TouchUpInside)
        addLyricsPrompt.hidden = true
        lyricbase.addSubview(addLyricsPrompt)
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
        if(!isSongNeedPurchase){
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentSongChanged"), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playbackStateChanged:"), name:MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
            if(player != nil){
                 player.beginGeneratingPlaybackNotifications()
            }
            if(isDemoSong){
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayer.currentItem)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeDemoSong"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayer.currentItem)
            }
        }
    }

    func currentSongChanged(){
        if(viewDidFullyDisappear){
            return
        }
        if(self.player == nil || (self.player.currentPlaybackTime.isNaN && KGLOBAL_queue.suspended
            && KGLOBAL_init_queue.suspended)){
            return
        }
        pthread_rwlock_wrlock(&self.rwLock)
            self.stopTimer()
            self.newPosition = 0
            self.toTime = 0
            for label in self.tuningLabels {
                label.hidden = true
            }
        
            if self.player.repeatMode == .One {
                print("\(self.player.nowPlayingItem!.title) is repeating")
                self.updateAll(0)
                if self.player.playbackState == MPMusicPlaybackState.Playing{
                    self.startTimer()
                }
                return
            }
            
            self.nowPlayingMediaItem = self.player.nowPlayingItem
            // if come back from Music app then this block will be called
            if(nowPlayingMediaItem == nil){
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            self.nowPlayingItemDuration = nowPlayingMediaItem!.playbackDuration
            self.getSongIdAndSoundwaveUrlFromCloud(nowPlayingMediaItem,completion: {succeed in Void()})
        
            // if we are NOT repeating song
            if self.player.repeatMode != .One {
                
                self.songNameLabel.attributedText = NSMutableAttributedString(string: nowPlayingMediaItem!.title!)
                self.songNameLabel.textAlignment = NSTextAlignment.Center
                self.artistNameLabel.text = nowPlayingMediaItem!.artist
                isBlurred = !isBlurred
                applyEffectsToBackgroundImage(changeSong: true)
                
                self.totalTimeLabel.text = TimeNumber(time: Float(nowPlayingItemDuration)).toDisplayString()
            }

        
            // use current item's playbackduration to validate nowPlayingItem duration
            // if they are not equal, i.e. not the same song

                self.updateMusicData(nowPlayingMediaItem!)
                self.updateFavoriteStatus(nowPlayingMediaItem!)
                // The following won't run when selected from table
                // update the progressblockWidth
                
                self.progressBlockViewWidth = 0
        
                //////////////////////////////
                //remove from superView
                if(KGLOBAL_progressBlock != nil ){
                    KGLOBAL_progressBlock.removeFromSuperview()
                    KGLOBAL_progressBlock = nil
                }
                
                // get a new progressBlock
                var progressBarWidth:CGFloat!
                progressBarWidth = CGFloat(nowPlayingItemDuration) * progressWidthMultiplier
        
                //如果是在线从来没有听过的queue切歌很快的时候duration是读不出来的
                if progressBarWidth <= 0.1 {
                    nowPlayingItemDuration = 2000
                }
                KGLOBAL_progressBlock = SoundWaveView(frame: CGRect(x: self.view.center.x, y: 0, width: progressBarWidth >= 0.1 ? progressBarWidth : 401, height: soundwaveHeight))
        
                KGLOBAL_progressBlock.center.y = progressContainerHeight
                self.progressBlockContainer.addSubview(KGLOBAL_progressBlock)
                
                if let soundWaveData = CoreDataManager.getSongWaveFormImage(nowPlayingMediaItem!) {
                    KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
                    print("sound wave data found")
                    KGLOBAL_init_queue.suspended = false
                } else {
                    self.generateSoundWave(nowPlayingMediaItem!)
                }
 
                ////////////////////////////
                
                KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 1.0)
                
                if self.player.playbackState == MPMusicPlaybackState.Paused{
                    KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 0.5)
                    print("changeScale")
                    //self.progressBlock!.alpha = 0.5
                }
        if(player.currentPlaybackRate == 1){
            resumeNormalSpeed()
        }
        let currentTime = player.currentPlaybackTime
        self.updateAll(Float(currentTime.isNaN ? 0 : currentTime))
            if self.player.playbackState == MPMusicPlaybackState.Playing{
                self.startTimer()
            }
        
        pthread_rwlock_unlock(&self.rwLock)
    }
    
    func currentLocalSongChanged(rate:Float){
        if(viewDidFullyDisappear){
            return
        }
        if(self.avPlayer == nil ){
                return
        }
        pthread_rwlock_wrlock(&self.rwLock)
        self.stopTimer()
        if rate == 0{
            avPlayer.pause()
        }
        self.newPosition = 0
        self.toTime = 0
        for label in self.tuningLabels {
            label.hidden = true
        }
        
        self.demoItem = self.avPlayer.currentItem
    
        self.demoItemDuration = demoItem!.getDuration()
    
        self.songNameLabel.attributedText = NSMutableAttributedString(string: demoItem!.getTitle())
        self.songNameLabel.textAlignment = NSTextAlignment.Center
        self.artistNameLabel.text = demoItem.getArtist()
        isBlurred = !isBlurred
        applyEffectsToBackgroundImage(changeSong: true)
        
        self.totalTimeLabel.text = TimeNumber(time: Float(demoItemDuration)).toDisplayString()
        
        // use current item's playbackduration to validate nowPlayingItem duration
        // if they are not equal, i.e. not the same song
        self.updateMusicData(demoItem!)
        
        // The following won't run when selected from table
        // update the progressblockWidth
        
        self.progressBlockViewWidth = nil
        
        //////////////////////////////
        //remove from superView
        if(KGLOBAL_progressBlock != nil ){
            KGLOBAL_progressBlock.removeFromSuperview()
            KGLOBAL_progressBlock = nil
        }
        
        // get a new progressBlock
        var progressBarWidth:CGFloat!
        progressBarWidth = CGFloat(demoItemDuration) * progressWidthMultiplier
        KGLOBAL_progressBlock = SoundWaveView(frame: CGRect(x: self.view.center.x, y: 0, width: progressBarWidth >= 0.1 ? progressBarWidth : 401, height: soundwaveHeight))
        KGLOBAL_progressBlock.center.y = progressContainerHeight
        self.progressBlockContainer.addSubview(KGLOBAL_progressBlock)
        
        if let soundWaveData = CoreDataManager.getSongWaveFormImage(demoItem!) {
            KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
            print("sound wave data found")
            KGLOBAL_init_queue.suspended = false
        } else {
            self.generateSoundWave(demoItem!)
        }
        
        ////////////////////////////
        
        KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 1.0)
        
        if rate == 0{
            KGLOBAL_progressBlock.transform = CGAffineTransformMakeScale(1.0, 0.5)
        }
        
        resumeNormalSpeed()
        self.updateAll(0)
        if rate > 0{
            self.startTimer()
        }
        
        pthread_rwlock_unlock(&self.rwLock)
    }

    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(viewDidFullyDisappear){
            return
        }
        if(KGLOBAL_progressBlock == nil){
            return
        }
        if keyPath == "rate"{
            if self.avPlayer.rate == 0 {
                stopTimer()
                //fade down the soundwave
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveLinear, animations: {
                    KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                    KGLOBAL_progressBlock!.alpha = 0.5
                    }, completion: nil)
            }else{
                updateAll(Float(avPlayer.currentTime().seconds))
                startTimer()
                //bring up the soundwave, give it a little jump animation
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.2)
                    KGLOBAL_progressBlock!.alpha = 1.0
                    }, completion: { finished in
                        if(KGLOBAL_progressBlock == nil){
                            return
                        }
                        UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                            KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                            }, completion: nil)
                        
                })

            }
        }
    }
    
    func playbackStateChanged(notification: NSNotification){
        if(viewDidFullyDisappear){
            return
        }
        if(self.player == nil || (self.player.currentPlaybackTime.isNaN && KGLOBAL_queue.suspended
            && KGLOBAL_init_queue.suspended)){
            return
        }
        let playbackState = player.playbackState
        if playbackState == .Paused {
            stopTimer()
            //fade down the soundwave
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveLinear, animations: {
                    KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                    KGLOBAL_progressBlock!.alpha = 0.5
                }, completion: nil)
            
        }
        else if playbackState == .Playing {
            updateAll(Float(player.currentPlaybackTime))
            startTimer()
            //bring up the soundwave, give it a little jump animation
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
                KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                KGLOBAL_progressBlock!.alpha = 1.0
                }, completion: nil
            )
        }
    }

    func resumeSong() {
        if selectedFromTable {
            if isDemoSong && NSUserDefaults.standardUserDefaults().boolForKey(kShowTutorial) {
                showTutorial()
            } else {
                if isDemoSong {
                    avPlayer.play()
                }else{
                    player.play()
                }
                startTimer()
            }
        } else { // selected from now view button
            if isDemoSong {
                if avPlayer.rate > 0 {
                    startTimer()
                    startTime.setTime(Float(avPlayer.currentTime().seconds))
                    updateAll(startTime.toDecimalNumer())
                }
                else if avPlayer.rate == 0 {
                    stopTimer()
                    // progress bar should be lowered
                    KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                    KGLOBAL_progressBlock!.alpha = 0.5
                    self.speed = 1  //restore to original speed
                }
            } else {
                if player.playbackState == MPMusicPlaybackState.Playing {
                    startTimer()
                    startTime.setTime(Float(player.currentPlaybackTime))
                    updateAll(startTime.toDecimalNumer())
                }
                else if player.playbackState == MPMusicPlaybackState.Paused {
                    stopTimer()
                    // progress bar should be lowered
                    KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                    KGLOBAL_progressBlock!.alpha = 0.5
                    self.speed = 1  //restore to original speed
                }
                
            }
        }
    }
    
    func setUpProgressContainer(){
        progressChangedOrigin = self.view.frame.width / 2
        progressBlockContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: progressContainerHeight))
        progressBlockContainer.center.y = self.view.frame.height - bottomViewHeight - progressContainerHeight / 2
        progressBlockContainer.backgroundColor = UIColor.clearColor()
        self.view.addSubview(progressBlockContainer)
        
        var progressBarWidth:CGFloat!

        if(!isSongNeedPurchase){
            progressBarWidth = CGFloat(isDemoSong ? self.demoItemDuration :  self.nowPlayingItemDuration) * progressWidthMultiplier
        }else{
           progressBarWidth = CGFloat(songNeedPurchase.getDuration()) * progressWidthMultiplier
        }
        
        
        if(KGLOBAL_progressBlock != nil ){
                    KGLOBAL_progressBlock.removeFromSuperview()
                    KGLOBAL_progressBlock = nil
        }
        if (progressBarWidth <= 0.1){
            nowPlayingItemDuration = 2000
        }
        KGLOBAL_progressBlock = SoundWaveView(frame: CGRect(x: self.view.center.x, y: 0, width: progressBarWidth >= 0.1 ? progressBarWidth : 401, height: soundwaveHeight))
        KGLOBAL_progressBlock.center.y = progressContainerHeight
        self.progressBlockContainer.addSubview(KGLOBAL_progressBlock)
        
        //if there is soundwave in the coredata then we load the image in viewdidload
        if(!isSongNeedPurchase){
            if let soundWaveData = CoreDataManager.getSongWaveFormImage(isDemoSong ? demoItem : nowPlayingMediaItem ) {
                KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
                print("sound wave data found")
                KGLOBAL_init_queue.suspended = false
                isGenerated = true
                self.soundwaveUrl = ""
                
            }else{
                //if didn't find it then we will generate then waveform later, in the viewdidappear method
                // this is a flag to determine if the generateSoundWave function will be called
                isGenerated = false
            }
        } else{
            if let soundWaveData = CoreDataManager.getSongWaveFormImage(songNeedPurchase) {
                KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
                print("sound wave data found")
                KGLOBAL_init_queue.suspended = false
                isGenerated = true
                self.soundwaveUrl = ""
            }else{
                //if didn't find it then we will generate then waveform later, in the viewdidappear method
                // this is a flag to determine if the generateSoundWave function will be called
                isGenerated = false
            }
        }
        
    
        panRecognizer = UIPanGestureRecognizer(target: self, action:Selector("handleProgressPan:"))
        panRecognizer.delegate = self
        progressBlockContainer.addGestureRecognizer(panRecognizer)
        progressContainerTapGesture = UITapGestureRecognizer(target: self, action: Selector("playPause:"))
        progressBlockContainer.addGestureRecognizer(progressContainerTapGesture)
    }
    
    
    // to generate sound wave in a nsoperation thread
    func generateSoundWave(nowPlayingItem: Findable){
        dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))) {
            var op:NSBlockOperation?
            let keyString:String = nowPlayingItem.getArtist()+nowPlayingItem.getTitle()
            op = KGLOBAL_operationCache[keyString]
            if(op == nil){
                KGLOBAL_init_queue.suspended = true
                let tempNowPlayingItem = nowPlayingItem
                let tempProgressBlock = KGLOBAL_progressBlock
                let tempkeyString = tempNowPlayingItem.getArtist()+tempNowPlayingItem.getTitle()
                op = NSBlockOperation(block: {
                    if !self.soundwaveUrl.isEmpty {
                        AWSS3Manager.downloadImage(self.soundwaveUrl, isProfileBucket: false, completion: {
                            
                            image in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let data = UIImagePNGRepresentation(image)
                                    KGLOBAL_operationCache.removeValueForKey(tempkeyString)
                                    KGLOBAL_progressBlock.setWaveFormFromData(data!)
                                   CoreDataManager.saveSoundWave(tempNowPlayingItem, soundwaveImage: data!)
                                    self.isGenerated = true
                                    self.soundwaveUrl = ""
                                    return
                                }
                        })
                        
                    }else{
                        guard let assetURL = nowPlayingItem.getURL() else {
                            print("sound url not available")
                            KGLOBAL_init_queue.suspended = false
                            return
                        }
                    
                    
                    // have to use the temp value to do the nsoperation, cannot use (self.) do that.
                    
                        
                        tempProgressBlock.SetSoundURL(assetURL as! NSURL)
                        self.isGenerated = true
                        self.soundwaveUrl = ""
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            KGLOBAL_operationCache.removeValueForKey(tempkeyString)
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                tempProgressBlock.generateWaveforms()
                                let data = UIImagePNGRepresentation(tempProgressBlock.generatedNormalImage)
                                CoreDataManager.saveSoundWave(tempNowPlayingItem, soundwaveImage: data!)
                                //when we get the soundwave we will upload it to the cloud
                                let soundwaveName = AWSS3Manager.concatenateFileNameForSoundwave(tempNowPlayingItem)
                                AWSS3Manager.uploadImage(tempProgressBlock.generatedNormalImage, fileName: soundwaveName, isProfileBucket: false, completion: {
                                    succeeded in
                                    if succeeded {
                                        APIManager.updateSoundwaveUrl(CoreDataManager.getSongId(tempNowPlayingItem), url: soundwaveName)
                                    }
                                })
                                
                                
                                if self.isDemoSong {
                                    if((tempNowPlayingItem as! AVPlayerItem) == self.avPlayer.currentItem){
                                        if(KGLOBAL_progressBlock != nil ){
                                            KGLOBAL_progressBlock.setWaveFormFromData(data!)
                                        }
                                        if(!KGLOBAL_queue.suspended){
                                            KGLOBAL_init_queue.suspended = false
                                        }
                                    }
                                }else{
                                    if((tempNowPlayingItem as! MPMediaItem) == self.player.nowPlayingItem){
                                        if(KGLOBAL_progressBlock != nil ){
                                            KGLOBAL_progressBlock.setWaveFormFromData(data!)
                                        }
                                        if(!KGLOBAL_queue.suspended){
                                            KGLOBAL_init_queue.suspended = false
                                        }
                                    }
                                }
                                
                            })
                            
                        }
                    }
                })
                KGLOBAL_operationCache[keyString] = op
                KGLOBAL_queue.addOperation(op!)

            }
        }
    }
    
    var newPosition:CGFloat! = 0
    var toTime:Float! = 0
    
    func handleProgressPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        switch recognizer.state {
        case UIGestureRecognizerState.Began:
            //update all chords, lyrics
            stopTimer()
            isPanning = true
            break;
        case UIGestureRecognizerState.Changed:
            newPosition = progressChangedOrigin + translation.x
            
            // leftmost point of inner bar cannot be more than half of the view
            if newPosition > self.view.frame.width / 2 {
                newPosition = self.view.frame.width / 2
            }
            
            // the end of inner bar cannot be smaller left half of view
            if newPosition + KGLOBAL_progressBlock.frame.width < self.view.frame.width / 2 {
                
                newPosition = self.view.frame.width / 2 - KGLOBAL_progressBlock.frame.width
            }
            
            //new Position from 160 to -357
            //-self.view.frame.width /2
            //= from 0 ot -517
            //divide by -2: from 0 to 258
            toTime = Float(newPosition - self.view.frame.width / 2) / -(Float(progressWidthMultiplier))
            if(!isSongNeedPurchase){
                KGLOBAL_progressBlock.setProgress(CGFloat(toTime)/CGFloat(isDemoSong ? demoItemDuration : nowPlayingItemDuration))
            }else{
                KGLOBAL_progressBlock.setProgress(CGFloat(toTime)/CGFloat(songNeedPurchase.getDuration()))
            }
            
            //258  517
            updateAll(toTime)
            break
        case UIGestureRecognizerState.Ended:
            //child.frame.origin.x = newPosition
            //when finger is lifted
            progressChangedOrigin = newPosition
            isPanning = false
            if(!isSongNeedPurchase){
                if isDemoSong {
                    avPlayer.seekToTime(CMTimeMakeWithSeconds(Float64(toTime), 1))
                    if avPlayer.rate > 0 {
                        startTimer()
                    }
                } else {
                    player.currentPlaybackTime = NSTimeInterval(toTime)
                    if player.playbackState == .Playing {
                        startTimer()
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    
    
    func handleChordBasePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        
        switch recognizer.state {
            
        case UIGestureRecognizerState.Began:
            isPanning = true
            currentChordTime = startTime.toDecimalNumer()
            stopTimer()
            updateAll(currentChordTime)
            
            break;
        case UIGestureRecognizerState.Changed:
            var tempNowPlayingItemDuration:Float!
            if(!isSongNeedPurchase){
                tempNowPlayingItemDuration = Float(isDemoSong ? demoItemDuration : nowPlayingItemDuration)
            }else{
                tempNowPlayingItemDuration = songNeedPurchase.getDuration()
            }
            
            let deltaTime = Float(translation.y)*(freefallTime/Float(chordBase.frame.size.height))
            toTime = currentChordTime + deltaTime
            
            if toTime < 0 {
                toTime = 0
            } else if (toTime > tempNowPlayingItemDuration){
                toTime = tempNowPlayingItemDuration
            }
            
            //update soundwave progress
            KGLOBAL_progressBlock.setProgress(CGFloat(toTime)/CGFloat(tempNowPlayingItemDuration))
            
            updateAll(toTime)
            
            break;
        case UIGestureRecognizerState.Ended:
            isPanning = false
            if(!isSongNeedPurchase){
                if isDemoSong {
                    avPlayer.seekToTime(CMTimeMakeWithSeconds(Float64(toTime), 1))
                    if avPlayer.rate > 0 {
                        startTimer()
                    }
                } else {
                    player.currentPlaybackTime = NSTimeInterval(toTime)
                    if player.playbackState == .Playing {
                        startTimer()
                    }
                    
                }
            }
            currentChordTime = 0
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
        wrapper.center.x = self.view.center.x
        wrapper.backgroundColor = UIColor.darkGrayColor()
        wrapper.alpha = 0.7
        wrapper.layer.cornerRadius = labelHeight/5
        self.view.addSubview(wrapper)
        
        currentTimeLabel = UILabel(frame: CGRect(x: self.view.center.x-labelWidth, y: timeLabelOriginY , width: labelWidth, height: labelHeight))
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
        self.view.addSubview(currentTimeLabel)
        
        totalTimeLabel = UILabel(frame: CGRect(x: self.view.center.x+1, y:timeLabelOriginY, width: labelWidth, height: labelHeight))
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        if(isSongNeedPurchase){
            totalTimeLabel.text = TimeNumber(time: songNeedPurchase.getDuration()).toDisplayString()
        }else{
            totalTimeLabel.text = TimeNumber(time: Float(isDemoSong ? self.demoItemDuration : self.nowPlayingItemDuration )).toDisplayString()
        }
       
        totalTimeLabel.textAlignment = .Right
        self.view.addSubview(totalTimeLabel)
        
    }
    
    //from left to right: share, favoriate, shuffle, others
    func setUpBottomViewWithButtons(){

        bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - bottomViewHeight, width: self.view.frame.width, height: bottomViewHeight))
        bottomView.backgroundColor = UIColor.darkGrayColor()
        bottomView.alpha = 0.7
        self.view.addSubview(bottomView)
        
        let bottomButtonSize: CGSize = CGSizeMake(bottomView.frame.width / 4, bottomView.frame.height)
        
        //TODO: Add glowing effect when pressed
        //divide view width into eigth to distribute center x for each of four buttons
        favoriateButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        //default is not favorited
        favoriateButton.setImage(UIImage(named: "notfavorited"), forState: UIControlState.Normal)
        favoriateButton.addTarget(self, action: "favoriteButtonPressed", forControlEvents: .TouchUpInside)
        
        shuffleButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        if(!isSongNeedPurchase){
            if isDemoSong {
                 shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
            } else {
                
                if player.repeatMode == .All && player.shuffleMode == .Off {
                    shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
                } else if player.repeatMode == .One && player.shuffleMode == .Off {
                    shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[1]), forState: UIControlState.Normal)
                } else if player.repeatMode == .All && player.shuffleMode == .Songs {
                    shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[2]), forState: UIControlState.Normal)
                }else{
                    player.repeatMode = .All
                    player.shuffleMode = .Off
                    shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
                }
            }
            
        }else{
            if MusicManager.sharedInstance.player.repeatMode == .All && MusicManager.sharedInstance.player.shuffleMode == .Off {
                shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
            } else if MusicManager.sharedInstance.player.repeatMode == .One && MusicManager.sharedInstance.player.shuffleMode == .Off {
                shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[1]), forState: UIControlState.Normal)
            } else if MusicManager.sharedInstance.player.repeatMode == .All && MusicManager.sharedInstance.player.shuffleMode == .Songs {
                shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[2]), forState: UIControlState.Normal)
            }else{
                MusicManager.sharedInstance.player.repeatMode = .All
                MusicManager.sharedInstance.player.shuffleMode = .Off
                shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
            }
        }
       
        if(!isDemoSong){
            shuffleButton.addTarget(self, action: "toggleShuffle:", forControlEvents: .TouchUpInside)
        }
        
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
        
        if(isSongNeedPurchase){
           shuffleButton.enabled = false
            othersButton.enabled = false
        }
    }
    
    func setUpActionViews() {
        // add this layer first before adding two action views to prevent view blocking
        actionDismissLayerButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        actionDismissLayerButton.backgroundColor = UIColor.clearColor()
        actionDismissLayerButton.addTarget(self, action: "dismissAction", forControlEvents: .TouchUpInside)
        self.view.addSubview(actionDismissLayerButton)
        actionDismissLayerButton.hidden = true
        
        if(isSongNeedPurchase){
            initPurchaseItunsSongItem()
        }

        // NOTE: we have to call all the embedded action events from the custom views, not in this class.
        guitarActionView = UIView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: actionViewHeight))
        guitarActionView.backgroundColor = UIColor.actionGray()
        self.view.addSubview(guitarActionView)
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
        volumeView.setVolumeThumbImage(UIImage(named: "knob"), forState: .Normal)
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
        
        speedStepper = UIStepper(frame: CGRect(x: self.view.frame.width-94-sideMargin, y: 0, width: 94, height: 29))
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
        
        if(isSongNeedPurchase){
            speedStepper.enabled = false
            speedStepper.tintColor = UIColor.lightGrayColor()
            speedLabel.enabled = false
        }
        
        // Add navigation out view, all actions are navigated to other viewControllers
        navigationOutActionView = UIView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: actionViewHeight))
        navigationOutActionView.backgroundColor = UIColor.actionGray()
        self.view.addSubview(navigationOutActionView)

        // position 1
        addTabsButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: rowHeight))
        addTabsButton.setTitle("Add your tabs", forState: .Normal)
        addTabsButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        addTabsButton.addTarget(self, action: "goToTabsEditor", forControlEvents: .TouchUpInside)
        navigationOutActionView.addSubview(addTabsButton)
        
        //position 2
        addLyricsButton = UIButton(frame: CGRect(x: 0, y: rowHeight, width: width, height: rowHeight))
        addLyricsButton.setTitle("Add your lyrics", forState: .Normal)
        addLyricsButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        addLyricsButton.addTarget(self, action: "goToLyricsEditor", forControlEvents: .TouchUpInside)
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
        browseLyricsButton.setTitle("Browse all lyrics", forState: .Normal)
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
    
    
    func favoriteButtonPressed() {
        
        if shouldShowSignUpPage("") {
            self.isRemoveProgressBlock = false
            self.selectedFromTable = false
            return
        }
     
        var findable: Findable!
        
        if isDemoSong {
            findable = demoItem
        } else if isSongNeedPurchase {
            findable = songNeedPurchase
        } else {
            findable = player.nowPlayingItem
        }
        
        
        APIManager.favoriteTheSong(findable, completion: {
            result in
            if result == "liked" {
                CoreDataManager.favoriteTheSong(findable, shouldFavorite: true)
                self.favoriateButton.setImage(UIImage(named: "favorited"), forState: UIControlState.Normal)
            } else  {
                CoreDataManager.favoriteTheSong(findable, shouldFavorite: false)
                self.favoriateButton.setImage(UIImage(named: "notfavorited"), forState: UIControlState.Normal)
            }
        })
    }
    
    func toggleShuffle(button: UIButton){
        if player.repeatMode == .All && player.shuffleMode == .Off { //is repeat all
            button.setImage(UIImage(named: shuffleButtonImageNames[1]), forState: UIControlState.Normal)
            player.repeatMode = .One
            player.shuffleMode = .Off
        } else if player.repeatMode == .One && player.shuffleMode == .Off { //is repeat one
            button.setImage(UIImage(named: shuffleButtonImageNames[2]), forState: UIControlState.Normal)
            player.repeatMode = MPMusicRepeatMode.All
            player.shuffleMode = MPMusicShuffleMode.Songs
            
        } else if player.shuffleMode == .Songs && player.repeatMode == .All { // is shuffle songs
            button.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
            player.repeatMode = MPMusicRepeatMode.All
            player.shuffleMode = MPMusicShuffleMode.Off
        }
    }
    
    // MARK: guitar buttons
    func dismissAction() {
        UIView.animateWithDuration(0.3, animations: {
            
            if self.guitarActionView.frame.origin.y < self.view.frame.height - 10 {
                self.guitarActionView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.height, self.actionViewHeight)
            }
            
            if self.navigationOutActionView.frame.origin.y < self.view.frame.height - 10 {
                print("dismiss navigation action")
                self.navigationOutActionView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.actionViewHeight)
            }
            if(self.previewView != nil){
                if self.previewView.frame.origin.y < self.view.frame.height - 10 {
                    print("dismiss navigation action")
                    self.previewView.frame.origin.y = self.view.frame.height
                }
            }

            self.actionDismissLayerButton.backgroundColor = UIColor.clearColor()
            
            }, completion: {
                completed in
                self.actionDismissLayerButton.hidden = true
        })
        
    }
    
    //for actions that go out from SongViewController
    func clearActions() {
        self.guitarActionView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.height, self.actionViewHeight)
        self.navigationOutActionView.frame = CGRectMake(0, self.view.frame.height, self.view.frame.width, self.actionViewHeight)
        if(self.previewView != nil){
            self.previewView.frame.origin.y = self.view.frame.height
        }
        self.actionDismissLayerButton.backgroundColor = UIColor.clearColor()
        self.actionDismissLayerButton.hidden = true
    }
    
    func showGuitarActions(){
        actionDismissLayerButton.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.guitarActionView.frame = CGRectMake(0, self.view.frame.height-self.actionViewHeight, self.view.frame.width, self.actionViewHeight)
                self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
                self.actionDismissLayerButton.alpha = 0.3
            }, completion: nil)
    }
    
    func showNavigationOutActions() {
        
        actionDismissLayerButton.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.navigationOutActionView.frame = CGRectMake(0, self.view.frame.height-self.actionViewHeight, self.view.frame.width, self.actionViewHeight)
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
        
        if(!isSongNeedPurchase){
            let tempPlaytime = isDemoSong ? self.avPlayer.currentTime().seconds : self.player.currentPlaybackTime
            if !tempPlaytime.isNaN {
                self.updateAll(Float(tempPlaytime))
            } else {
                self.updateAll(0)
            }
        }else{
            updateAll(0)
        }
        
        applyEffectsToBackgroundImage(changeSong: false)
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
        applyEffectsToBackgroundImage(changeSong: false)
    }
    
    func applyEffectsToBackgroundImage(changeSong changeSong: Bool) {
        if changeSong {
            loadBackgroundImageFromMediaItem(isDemoSong ? avPlayer.currentItem! : player.nowPlayingItem! )
        }
        
        //we blur the image if one of the chord, tabs or lyrics is shown
        if (isChordShown || isTabsShown || isLyricsShown) && !isBlurred {
        
            dispatch_async(dispatch_get_main_queue()) {
                self.backgroundImageView.image = self.blurredImage
            }
            self.isBlurred = true
            
            // we dont' need animation when changing song
            if !changeSong {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut , animations: {
                    
                    self.backgroundImageView.transform = CGAffineTransformMakeScale(1,1)
                    }, completion: {
                        finished in UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.previousButton.frame.origin.y = self.chordBase.frame.origin.y
                            self.nextButton.frame.origin.y = self.chordBase.frame.origin.y
                            }, completion: nil)
                })
            }
        } else if (!isChordShown && !isTabsShown && !isLyricsShown && isBlurred) { // center the image
            dispatch_async(dispatch_get_main_queue()) {
                self.backgroundImageView.image = self.backgroundImage
            }
           
            self.isBlurred = false
            
            // we dont' need animation when changing song
            if !changeSong {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    
                    self.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundScaleFactor, self.backgroundScaleFactor)
                    self.backgroundImageView.layer.shadowOpacity = 0.9
                    self.backgroundImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
                    self.backgroundImageView.layer.shadowColor = UIColor.blackColor().CGColor
                    
                    }, completion: {
                        finished in UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.previousButton.center.y = self.view.center.y
                            self.nextButton.center.y = self.view.center.y
                            }, completion: nil)
                })
            }
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
        countdownView.center.x = self.view.center.x
        countdownView.backgroundColor = UIColor.clearColor()
        countdownView.hidden = true
        self.view.addSubview(countdownView)
    }
    
    func startCountdown() {
        countDownStartSecond--
        countdownView.setNumber(countDownStartSecond)
        
        if countDownStartSecond <= 0 {
            //add tap gesture back
            chordBase.addGestureRecognizer(chordBaseTapGesture)
            progressBlockContainer.addGestureRecognizer(progressContainerTapGesture)
            
            countdownTimer.invalidate()
            countdownView.hidden = true
            countDownStartSecond = 3
            if isDemoSong {
                avPlayer.play()
            }else{
                player.play()
            }
        }
    }

    // MARK: functions in guitarActionView
    func speedStepperValueChanged(stepper: UIStepper) {
        stopTimer()
        let speedKey = Double(round(10*stepper.value)/10)
        let adjustedSpeed = Float(speedMatcher[speedKey]!)
        self.speed = adjustedSpeed
        if isDemoSong {
            self.avPlayer.rate = adjustedSpeed
        } else {
            self.player.currentPlaybackRate = adjustedSpeed
        }
       
        self.startTimer()
        
        self.speedLabel.text = "Speed: \(speedLabels[speedKey]!)"
        print("stepper value:\(stepper.value) and value \(speedMatcher[speedKey])")
    }
    
    func resumeNormalSpeed() {
        self.speed = 1
        self.speedLabel.text = "Speed: 1.0x"
        self.speedStepper.value = 1.0
    }
    
    // MARK: functions used in NavigationOutView
    func browseTabs(button: UIButton) {
        self.isRemoveProgressBlock = false
        self.selectedFromTable = false
        self.isChangedSpeed = false
        
        let browseAllTabsVC = self.storyboard?.instantiateViewControllerWithIdentifier("browseversionsviewcontroller") as! BrowseVersionsViewController
        browseAllTabsVC.songViewController = self
        browseAllTabsVC.isPullingTabs = true
        
        if isSongNeedPurchase {
            browseAllTabsVC.findable = self.songNeedPurchase
        } else {
            browseAllTabsVC.findable = isDemoSong ? demoItem : nowPlayingMediaItem 
        }
  
        self.presentViewController(browseAllTabsVC, animated: true, completion: {
            completed in
            self.clearActions()
        })
    }
    
    func goToTabsEditor() {
        self.isRemoveProgressBlock = false
        self.selectedFromTable = false
        
        if shouldShowSignUpPage("goToTabsEditor") {
            return
        }

        self.showTabsEditor()
    }

    func showTabsEditor(){
        self.isRemoveProgressBlock = false
        self.selectedFromTable = false
        viewDidFullyDisappear = true
        if isDemoSong{
            self.avPlayer.pause()
            stopTimer()
            KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
            KGLOBAL_progressBlock!.alpha = 0.5
        } else {
            self.player.pause()
            stopTimer()
            KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
            KGLOBAL_progressBlock!.alpha = 0.5
        }
        let tabsEditorVC = self.storyboard?.instantiateViewControllerWithIdentifier("tabseditorviewcontroller") as! TabsEditorViewController
        tabsEditorVC.theSong = isDemoSong ? demoItem : nowPlayingMediaItem
        tabsEditorVC.songViewController = self
        tabsEditorVC.isDemoSong = self.isDemoSong
        self.presentViewController(tabsEditorVC, animated: true, completion: nil)
        
    }
    
    func browseLyrics(button: UIButton) {
        self.isRemoveProgressBlock = false
        self.selectedFromTable = false
        self.isChangedSpeed = false
        let browseAllTabsVC = self.storyboard?.instantiateViewControllerWithIdentifier("browseversionsviewcontroller") as! BrowseVersionsViewController
        browseAllTabsVC.songViewController = self
        browseAllTabsVC.isPullingTabs = false
        
        if isSongNeedPurchase {
            browseAllTabsVC.findable = self.songNeedPurchase
        } else {
            browseAllTabsVC.findable = isDemoSong ? demoItem : nowPlayingMediaItem 
        }
  
        
        self.presentViewController(browseAllTabsVC, animated: true, completion: {
            completed in
            self.clearActions()
        })
        
    }
    
    func goToLyricsEditor() {
        //show sign up screen if no user found
        self.isRemoveProgressBlock = false
        self.selectedFromTable = false
        
        if shouldShowSignUpPage("goToLyricsEditor") {
            return
        }
        self.showLyricsEditor()
    }
    
    func showLyricsEditor(){
        self.isRemoveProgressBlock = false
        self.selectedFromTable = false
        viewDidFullyDisappear = true

        if isDemoSong{
            self.avPlayer.pause()
            stopTimer()
            KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
            KGLOBAL_progressBlock!.alpha = 0.5
        } else {
            self.player.pause()
            stopTimer()
            KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
            KGLOBAL_progressBlock!.alpha = 0.5
        }
        self.clearActions()
        let lyricsEditor = self.storyboard?.instantiateViewControllerWithIdentifier("lyricstextviewcontroller")
            as! LyricsTextViewController
        lyricsEditor.songViewController = self
        lyricsEditor.theSong = isDemoSong ? demoItem : nowPlayingMediaItem
        lyricsEditor.isDemoSong = isDemoSong
        self.presentViewController(lyricsEditor, animated: true, completion: nil)
    }
    
    func goToArtist(button: UIButton) {
        self.dismissViewControllerAnimated(false, completion: {
            completed in
            if(self.musicViewController != nil){
                if(!self.isDemoSong){
                    self.musicViewController.goToArtist(self.player.nowPlayingItem!.artist!)
                }
            }
        })
    }

    func goToAlbum(button: UIButton) {
        self.dismissViewControllerAnimated(false, completion: {
            completed in
            if(self.musicViewController != nil){
                if(!self.isDemoSong){
                    self.musicViewController.goToAlbum(self.player.nowPlayingItem!.albumTitle!)
                }
            }
            
        })
    }
    
    func shouldShowSignUpPage(key:String) -> Bool {
        //show sign up screen if no user found
        if CoreDataManager.getCurrentUser() == nil {
            self.isChangedSpeed = false
            let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("meloginVC") as! MeLoginOrSignupViewController
            signUpVC.showCloseButton = true
            signUpVC.songViewController = self
            
            if !key.isEmpty && key == "goToLyricsEditor" {
                signUpVC.isGoToLyricEditor = true
            } else if !key.isEmpty && key == "goToTabsEditor" {
                signUpVC.isGoToTabEditor = true
            }
            
            self.presentViewController(signUpVC, animated: true, completion: {
                completet in  self.clearActions()
            })
            return true
        }
        self.clearActions()
        return false
    }
    
    // ISSUE: when app goes to background this is not called
    //stop timer,stop refreshing UIs after view is completely gone of sight
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("view will disappear")
        stopTimer()
        viewDidFullyDisappear = true
        
        if(isRemoveProgressBlock){
            if(KGLOBAL_progressBlock != nil ){
                KGLOBAL_progressBlock.removeFromSuperview()
                KGLOBAL_progressBlock = nil
            }
            if isSongNeedPurchase{
                self.displayLink.paused = true
                self.displayLink.invalidate()
                self.displayLink = nil
                return
            }
        }
        
        if isSongNeedPurchase{
            return
        }
        if isDemoSong {
            if avPlayer.rate > 0 {
                KGLOBAL_nowView.start()

            } else {
                KGLOBAL_nowView.stop()
            }
            
            if avPlayer.rate > 0 {
                if(isChangedSpeed){
                     avPlayer.rate = 1
                }
            }
            
        }else{
            if player.playbackState == .Playing {
               KGLOBAL_nowView.start()
            } else {
               KGLOBAL_nowView.stop()
            }
            
            if player.playbackState == MPMusicPlaybackState.Playing {
                if(isChangedSpeed){
                     player.currentPlaybackRate = 1
                }
            }
        }
        if(isChangedSpeed){
            resumeNormalSpeed()
        }else{
            isChangedSpeed = true
        }
        
        
        if(isRemoveProgressBlock){
            NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        }
        
        if(isDemoSong){
            avPlayer.removeObserver(self, forKeyPath: "rate")
        }
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
        if chords.count < minimumChordCount {
            return
        }
        
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
            
            let newOriginX = self.view.center.x - CGFloat(startTime.toDecimalNumer()) * progressWidthMultiplier
            
            if !isPanning {
                self.progressChangedOrigin = newOriginX
                KGLOBAL_progressBlock.setProgress(newProgressPosition)
            }
            KGLOBAL_progressBlock.frame.origin.x = newOriginX
           // print("\(startTime) = \(startTime.toDecimalNumer())")
    }
    
    func refreshTimeLabel(){
        // update current time label
        self.currentTimeLabel.text = startTime.toDisplayString()
    }
    
    func refreshLyrics() {
        if lyric.lyric.count < 2 {
            return
        }
        
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
    
    
    
    func updateAll(time: Float) {
 
        startTime.setTime(time)
        
        //remove all existing labels
        for labels in activelabels{
            for label in labels.labels{
                label.removeFromSuperview()
            }
        }
        activelabels.removeAll(keepCapacity: true)
        
        //if no chords we are not updating
        if chords.count >= minimumChordCount {
            ///Remove all label in current screen

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
        }

        update()
        
    }
    
    func playPause(recognizer: UITapGestureRecognizer) {
        if(!isSongNeedPurchase){
            if isDemoSong ? avPlayer.rate == 0 : player.playbackState == MPMusicPlaybackState.Paused  {
                if countdownOn {
                    //temporarily disable tap gesture to avoid accidental start count down again
                    chordBase.removeGestureRecognizer(chordBaseTapGesture)
                    progressBlockContainer.removeGestureRecognizer(progressContainerTapGesture)
                    countdownView.setNumber(countDownStartSecond)
                    countdownView.hidden = false
                    countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
                    NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
                    
                } else {
                    if isDemoSong {
                        avPlayer.rate = self.speed
                       
                    } else {
                        player.currentPlaybackRate = self.speed
                    }
                    
                }
                
            } else {
               
                if isDemoSong {
                    avPlayer.pause()
                    
                }else{
                    player.pause()
                }
            }
        }
    }
    
    func startTimer(){
        //NOTE: To prevent startTimer() to be called consecutively
        //which would double the update speed. We only
        //start the timer when it is not valid
        //In case of receiving song changed and playback state
        //notifications, notifications are triggered twice somehow
        
        if KGLOBAL_timer == nil {
            KGLOBAL_timer = NSTimer()
            KGLOBAL_timer = NSTimer.scheduledTimerWithTimeInterval( 1 / Double(stepPerSecond) / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            // make sure the timer is not interfered by scrollview scrolling
            //NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func stopTimer(){
        if(KGLOBAL_timer != nil){
            KGLOBAL_timer!.invalidate()
            KGLOBAL_timer = nil
        }
    }
    
    func update(){
        if KGLOBAL_progressBlock == nil {
            return
        }
        
        if !isPanning && !isSongNeedPurchase {
            if !self.selectedFromSearchTab && (!isViewDidAppear || startTime.toDecimalNumer() < 2 || startTime.toDecimalNumer() > Float(isDemoSong ? demoItemDuration : nowPlayingItemDuration) - 2 || startTime.toDecimalNumer() - toTime < (1 * speed)) {
                startTime.addTime(Int(100 / stepPerSecond))
            } else {
                let tempPlaytime = isDemoSong ? self.avPlayer.currentTime().seconds : self.player.currentPlaybackTime
                if !tempPlaytime.isNaN {
                    startTime.setTime(Float(tempPlaytime))
                    if(!isDemoSong && nowPlayingItemDuration == 2000){
                        if(player.nowPlayingItem!.playbackDuration > 1){
                            if(KGLOBAL_progressBlock.frame.size.width > CGFloat(400)){
                                nowPlayingMediaItem = player.nowPlayingItem
                                nowPlayingItemDuration = nowPlayingMediaItem.playbackDuration
                                let progressBarWidth = CGFloat(nowPlayingItemDuration) * progressWidthMultiplier
                                KGLOBAL_progressBlock.frame = CGRect(x: KGLOBAL_progressBlock.frame.origin.x, y: KGLOBAL_progressBlock.frame.origin.y, width: progressBarWidth, height: soundwaveHeight)
                                if let soundWaveData = CoreDataManager.getSongWaveFormImage(nowPlayingMediaItem) {
                                    KGLOBAL_progressBlock.setWaveFormFromData(soundWaveData)
                                    KGLOBAL_init_queue.suspended = false
                                    isGenerated = true
                                    self.soundwaveUrl = ""
                                }else{
                                    self.getSongIdAndSoundwaveUrlFromCloud(self.nowPlayingMediaItem, completion: {
                                        successed in
                                        if successed {
                                            self.generateSoundWave(self.nowPlayingMediaItem)
                                        }
                                    })
                                }
                                if self.player.repeatMode != .One {
                                    self.songNameLabel.attributedText = NSMutableAttributedString(string: nowPlayingMediaItem!.title!)
                                    self.songNameLabel.textAlignment = NSTextAlignment.Center
                                    self.artistNameLabel.text = nowPlayingMediaItem!.artist
                                    if(currentImage == nil){
                                        isBlurred = !isBlurred
                                        applyEffectsToBackgroundImage(changeSong: true)
                                    }
                                    self.totalTimeLabel.text = TimeNumber(time: Float(nowPlayingItemDuration)).toDisplayString()
                                }
                            }
                        }
                    }
                } else {
                    startTime.addTime(Int(100 / stepPerSecond))
                }
            }
        }

        refreshChordLabel()
        refreshLyrics()
        refreshProgressBlock()
        refreshTimeLabel()
    }
    
    
    func createLabels(name: String, fretPositions: [String]) -> (labels: [UIView], ylocation: CGFloat, alpha: Int){
        var res = [UIView]()
        
        let chordNameLabel = UILabel(frame: CGRectMake(0, 0, 40, 0))
        
        chordNameLabel.text = name
        chordNameLabel.textColor = UIColor.whiteColor()
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

    private func dealWithLabelofChordName(chordLabel:UILabel) {
        //both chord and tab is shown
        if isChordShown && isTabsShown {
            //make the text glow
            chordLabel.textColor = UIColor.whiteColor()
            chordLabel.font = UIFont.systemFontOfSize(17)

        //showing only chord in the center
        } else if isChordShown && !isTabsShown {
          
            chordLabel.textColor = UIColor.silverGray()
            chordLabel.font = UIFont.systemFontOfSize(20)
            chordLabel.sizeToFit()
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func initPurchaseItunsSongItem(){
        setUpPreviewButton()
        setUpPreviewActionView()
    }
    
    func setUpPreviewButton(){
        playPreveiwButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width/2-35,UIScreen.mainScreen().bounds.size.height-bottomViewHeight-90,70,70))
        playPreveiwButton.setImage((UIImage(named: "playbutton")), forState: UIControlState.Normal)
        playPreveiwButton.addTarget(self, action: "showPreviewActionView", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(playPreveiwButton)
        let url: NSURL = NSURL(string: songNeedPurchase.previewUrl!)!
        let playerItem = AVPlayerItem( URL:url)
        KAVplayer = AVPlayer(playerItem:playerItem)
        displayLink = CADisplayLink(target: self, selector: ("updateSliderProgress"))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink.paused = true

    }
    
    func setUpPreviewActionView(){
        // NOTE: we have to call all the embedded action events from the custom views, not in this class.
        self.previewView = UIView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: previewActionViewHeight))
        previewView.backgroundColor = UIColor.actionGray()
        self.view.addSubview(previewView)
        let width = previewView.frame.width
        
        var rowWrappers = [UIView]()
        let rowHeight: CGFloat = 54+1
        for i in 0..<4 {
            let row = UIView(frame: CGRect(x: 0, y: rowHeight*CGFloat(i), width: width, height: rowHeight))
            rowWrappers.append(row)
            if i < 3 { // give a separator at the the bottom of each row except last line
                let line = UIView(frame: CGRect(x: 0, y: rowHeight-1, width: width, height: 1))
                line.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
                row.addSubview(line)
            }
            previewView.addSubview(row)
        }
        
        let childCenterY = (rowHeight-1)/2

        let names = ["Listen Preview", "Buy from iTunes",  "Apple Music", "Browse other tabs"]

        let functionName = ["previewPlay", "goToiTunes", "goToAppleMusic", "browseTabs:"]

        let sideMargin: CGFloat = 35
        
        for i in 0..<4 {
            let button = UIButton(frame: CGRect(x: sideMargin, y: 0, width: self.view.frame.width - sideMargin, height: 54))
            button.setTitle(names[i], forState: .Normal)
            button.contentHorizontalAlignment = .Left
            button.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
            button.center.y = childCenterY
            button.addTarget(self, action: Selector(functionName[i]) , forControlEvents: UIControlEvents.TouchUpInside)
            if i == 0{
                previewProgress = KDCircularProgress(frame: CGRect(x: self.view.frame.width - 66 - 25, y: 7, width: 42, height: 42))
                previewProgress.startAngle = -90
                previewProgress.angle = 360
                previewProgress.progressThickness = 0.3
                previewProgress.trackThickness = 0.7
                previewProgress.clockwise = true
                previewProgress.gradientRotateSpeed = 2
                previewProgress.roundedCorners = true
                previewProgress.glowMode = .Forward
                previewProgress.setColors(UIColor.mainPinkColor())
                
                previewProgressCenterView = UIView(frame: CGRect(x: 15, y: 15, width: 12, height: 12))
                previewProgressCenterView.layer.cornerRadius = 0
                previewProgressCenterView.backgroundColor = UIColor.mainPinkColor()
                previewProgressCenterView.layer.borderColor = UIColor.blackColor().CGColor
                previewProgressCenterView.layer.borderWidth = 2.0
                previewProgress.addSubview(previewProgressCenterView)
                rowWrappers[i].addSubview(previewProgress)
                
            }else if i == 1 {
                let itunesBadge = UIButton(frame: CGRect(x: self.view.frame.width - 90 - 25, y: 0, width: 90, height: 33))
                itunesBadge.setImage(UIImage(named: "itunes_badge"), forState: .Normal)
                itunesBadge.addTarget(self, action: Selector(functionName[i]), forControlEvents: .TouchUpInside)
                itunesBadge.center.y = childCenterY
                rowWrappers[i].addSubview(itunesBadge)
            } else if i == 2 {
                let appleMusicBadge = UIButton(frame: CGRect(x: self.view.frame.width - 90 - 25, y: 0, width: 90, height: 33))
                appleMusicBadge.setImage(UIImage(named: "apple_music_badge"), forState: .Normal)
                appleMusicBadge.addTarget(self, action: Selector(functionName[i]), forControlEvents: .TouchUpInside)
                appleMusicBadge.center.y = childCenterY
                rowWrappers[i].addSubview(appleMusicBadge)
            } else if i == 3 {
                button.center.x = self.view.center.x
                button.contentHorizontalAlignment = .Center
            }
            rowWrappers[i].addSubview(button)
        }
        
    }
    
    func showPreviewActionView(){
        actionDismissLayerButton.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.previewView.frame.origin.y = self.view.frame.height-self.previewActionViewHeight
            self.actionDismissLayerButton.backgroundColor = UIColor.darkGrayColor()
            self.actionDismissLayerButton.alpha = 0.3
            }, completion: nil)
    }
    
    
    func previewPlay(){
        if(KAVplayer.rate == 0.0){
            previewProgress.setColors(UIColor.mainPinkColor())
            KAVplayer.rate = 1.0;
            UIView.animateWithDuration(0.2, delay: 0.0,
                options: .CurveEaseOut,
                animations: {
                    self.previewProgressCenterView.layer.cornerRadius = CGRectGetHeight(self.previewProgressCenterView.bounds)/2
                }, completion: {
                    finished in
                    self.displayLink.paused = false
                    KAVplayer.play()
            })
        }else{
            UIView.animateWithDuration(0.2, delay: 0.0,
                options: .CurveEaseOut,
                animations: {
                    self.previewProgressCenterView.layer.cornerRadius = 0
                }, completion: {
                    finished in
                    self.displayLink.paused = true
                    KAVplayer.pause()
            })
        }
    }
    
    func goToiTunes(){
        storeViewController = nil
        UINavigationBar.appearance().tintColor = UIColor.mainPinkColor()
        storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self

        let parameters = [SKStoreProductParameterITunesItemIdentifier :
            NSNumber(integer: songNeedPurchase.trackId!)]
        storeViewController.loadProductWithParameters(parameters,
            completionBlock: {result, error in
                if error != nil {
                    print(error)
                }
        })
        self.presentViewController(storeViewController,
            animated: true, completion: {
                self.dismissAction()
        })
    }
    
    func goToAppleMusic(){
        self.dismissAction()
        UIApplication.sharedApplication().openURL(NSURL(string: songNeedPurchase.trackViewUrl!)!)
    }
    
    func updateSliderProgress(){
        let angle = KAVplayer.currentTime().seconds * 360/KAVplayer.currentItem!.duration.seconds
        if(angle.isFinite && !angle.isNaN){
            previewProgress.angle = Int(angle)
        }else{
            previewProgress.angle = 0
        }
        
        if(KAVplayer.currentTime() == KAVplayer.currentItem!.duration){
            KAVplayer.seekToTime(kCMTimeZero)
            UIView.animateWithDuration(0.2, delay: 0.0,
                options: .CurveEaseOut,
                animations: {
                    self.previewProgressCenterView.layer.cornerRadius = 0
                }, completion: {
                    finished in
                    self.previewProgress.setColors(UIColor.mainPinkColor())
                    self.previewProgress.angle = 360
                    self.displayLink.paused = true
            })
        }
    }
    
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        if let purchasedItem = MusicManager.sharedInstance.itemFoundInCollection(songNeedPurchase){
                MusicManager.sharedInstance.setPlayerQueue([purchasedItem])
                MusicManager.sharedInstance.setIndexInTheQueue(0)

            self.recoverToNormalSongVC(purchasedItem)
            
        }else{
              print("didn't purchase the song")
        }
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        viewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func recoverToNormalSongVC(PlayingItem:MPMediaItem){
        //delete
        self.displayLink.paused = true
        self.displayLink.invalidate()
        self.displayLink = nil
        self.previewView = nil
        self.playPreveiwButton.removeFromSuperview()
        self.playPreveiwButton = nil
        KAVplayer = nil
        //recover
        player = MusicManager.sharedInstance.player
        self.nowPlayingMediaItem = PlayingItem
        self.nowPlayingItemDuration = nowPlayingMediaItem.playbackDuration
        self.isSongNeedPurchase = false
        self.selectedFromTable = true
        self.removeAllObserver()
        CoreDataManager.initializeSongToDatabase(PlayingItem)
        self.registerMediaPlayerNotification()
        startTime.setTime(3)
        self.resumeSong()
        if(!isGenerated){
            generateSoundWave(nowPlayingMediaItem)
        }
        self.updateMusicData(nowPlayingMediaItem)
        shuffleButton.enabled = true
        othersButton.enabled = true
        speedStepper.enabled = true
        speedLabel.enabled = true
        speedStepper.tintColor = UIColor.mainPinkColor()
        previousButton.hidden = false
        nextButton.hidden = false
    }
    
    func updateFavoriteStatus(item: Findable) {
        //check core data only
        if CoreDataManager.isFavorited(item) && CoreDataManager.getCurrentUser() != nil {
            favoriateButton.setImage(UIImage(named: "favorited"), forState: UIControlState.Normal)
        } else {
            favoriateButton.setImage(UIImage(named: "notfavorited"), forState: UIControlState.Normal)
        }
    }
    
    func getSongIdAndSoundwaveUrlFromCloud(item: Findable, completion: ((successed:Bool) -> Void)) {
        self.soundwaveUrl = ""
        APIManager.getSongInformation(item, completion: {
            id, soundwave_url in
            CoreDataManager.setSongId(item, id: id)
            self.soundwaveUrl = soundwave_url
            completion(successed: true)
        })
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: Fix to portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
}
