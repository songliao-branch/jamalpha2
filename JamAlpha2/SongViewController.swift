import UIKit
import MediaPlayer

let chordwithname:Int = 1
let fullchord:Int = 0

class SongViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    var musicViewController: MusicViewController?

    var selectedFromTable = true
    
    var viewDidFullyDisappear = true
    
    var player:MPMusicPlayerController!
    

    @IBOutlet weak var playPauseButton: UIButton!
    
    // the previous song time
    var firstLoadSongTime: NSTimeInterval!
    var firstloadSongTitle: String!
    
    var backgroundImageView: UIImageView!
    
    var buttonDimension: CGFloat = 50
    var pulldownButton:UIButton!
    var tuningButton:UIButton!
    
    var songNameLabel: MarqueeLabel!
    var artistNameLabel: UILabel!
    var topViewHeight: CGFloat = 50
    
    var previousButton: UIButton!
    var nextButton: UIButton!

    // MARK: Custom views
    var base: ChordBase!
    var basesHeight: CGFloat!
    let marginBetweenBases: CGFloat = 15
    
    //MARK: progress Container
    var progressBlock: SoundWaveView!
    
    var progressBlockViewWidth:CGFloat?
    var progressChangedPosition: CGFloat!
    var progressBlockContainer:UIView!
    var progressChangedOrigin:CGFloat!
    let progressWidthMultiplier:CGFloat = 2
    var panRecognizer:UIPanGestureRecognizer!
    var isPanning = false
    
    var tapRecognizer: UITapGestureRecognizer!

    var currentTimeLabel:UILabel!
    var totalTimeLabel:UILabel!
    
    var chords = [Chord]()
    var start: Int = 0
    var activelabels = [[UILabel]]()
    var startTime: TimeNumber = TimeNumber(second: 0, decimal: 0)
    
    //time
    var timer: NSTimer = NSTimer()
    var currentChordTime:Float = 0
    var toChordTime:Float = 0
    
    var topPoints = [CGFloat]()
    var bottomPoints = [CGFloat]()
    
    var topPointModes = [Int: [CGFloat]]()
    var bottomPointModes = [Int: [CGFloat]]()
    
    var labelHeight:CGSize!
    //speed to control playback speed and
    //corresponding playback speed
    var speed:Float = 1
    //as a recorder to write down the current rate
    var nowPlayingItemSpeed:Float = 1
    
    //time for chords to fall from top to bottom of chordbase
    var freefallTime:Float = 3
    
    //Lyric
    var lyricbase: UIView!
    
    var topLyricLabel: UILabel = UILabel()
    var bottomLyricLabel: UILabel = UILabel()
    
    var current: Int = 0    //current line of lyric
    var lyric: Lyric = Lyric()
    
    var mode:Int = 0
    //for displaying 4 buttons, Favorite, Shuffle state, Changed chord version, dots
    var topView:UIView!
    var bottomView:UIView!
    
    //Simulate the process of animation for disappearing labels
    let timeToDisappear:Float = 0.8
    var disappearingLabels: [UILabel] = [UILabel]()
    var disapperingLabelAlpha: Int = 0
    
    var favoriateButton:UIButton!
    var shuffleButton:UIButton!
    var guitarButton:UIButton!
    var othersButton:UIButton!
    
    var textColor:UIColor!
    
    var actionSheet:TwistJamActionSheet!
    
    //background images
    var currentImage:UIImage?
    
    //default is 0
    //0-repeat all, 1-repeat song, 2-shuffle all
    var shuffleButtonImageNames = ["loop_playlist","loop_song","shuffle"]
    
    //constant
    let bottomViewHeight:CGFloat = 40 //this is fixed
    let progressContainerHeight:CGFloat = 80 //TODO: Change to percentange

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        player = MusicManager.sharedInstance.player
        
        firstLoadSongTime = player.nowPlayingItem.playbackDuration
        firstloadSongTitle = player.nowPlayingItem.title
        removeAllObserver()
        //hide tab bar
        self.tabBarController?.tabBar.hidden = true
        setUpMusicData(player.nowPlayingItem)
        setUpBackgroundImage()
        setUpTopButtons()
        
        setUpNameAndArtistButtons()
        //set up views from top to bottom
        setUpChordBase()
        setUpLyricsBase()
        setUpControlButtons()
        setUpProgressContainer()
        setUpTimeLabels()
        setUpBottomViewWithButtons()
        //get top and bottom points of six lines
        calculateXPoints()
        
    }
    
    func removeAllObserver(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerVolumeDidChangeNotification, object: player)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // viewWillAppear is called everytime the view is dragged down
        // to prevent resumeSong() everytime, we make sure resumeSong()
        // is ONLY called when the view is fully dragged down or disappeared
        if viewDidFullyDisappear {
            //println("resume song when Fully Disapper")
            resumeSong()
            viewDidFullyDisappear = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.registerMediaPlayerNotification()
    }
    
    func setUpRainbowData(){
        chords = Chord.getRainbowChords()
        lyric = Lyric.getRainbowLyrics()
    }
    
    func setUpBackgroundImage(){
        //create an UIImageView
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.height))
        //get the image from MPMediaItem
        println(player.nowPlayingItem.title)
        currentImage = player.nowPlayingItem.artwork.imageWithSize(CGSize(width: self.view.frame.height/8, height: self.view.frame.height/8))
        
        //create blurred image
        var blurredImage:UIImage = currentImage!.applyLightEffect()!
        
        backgroundImageView.center.x = self.view.center.x
        backgroundImageView.image = blurredImage
        textColor = blurredImage.averageColor()
        
        self.view.addSubview(backgroundImageView)
    }
    
    func setUpTopButtons() {
        
        topView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: topViewHeight ))
        
        topView.backgroundColor = UIColor.mainPinkColor()
        topView.alpha = 1
        self.view.addSubview(topView)
        
        let buttonCenterY: CGFloat = 25
        pulldownButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
        //TODO: change image source
        pulldownButton.setImage(UIImage(named: "pullDown"), forState: UIControlState.Normal)
        pulldownButton.center = CGPoint(x: self.view.frame.width / 12, y: buttonCenterY)
        pulldownButton.addTarget(self, action: "dismissController:", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(pulldownButton)
        
        tuningButton = UIButton(frame: CGRect(x: 0 , y: 0, width: buttonDimension, height: buttonDimension))
        tuningButton.setImage(UIImage(named: "tuning"), forState: UIControlState.Normal)
        tuningButton.center = CGPoint(x: self.view.frame.width * 11 / 12, y: buttonCenterY)
        topView.addSubview(tuningButton)
    }
    
    func setUpNameAndArtistButtons(){
       
        
        songNameLabel = MarqueeLabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 20)))
        songNameLabel.type = .Continuous
        songNameLabel.scrollDuration = 15.0
        songNameLabel.fadeLength = 5.0
        songNameLabel.trailingBuffer = 30.0
        
        artistNameLabel = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 10)))
        artistNameLabel.textAlignment = NSTextAlignment.Center
        
        var title:String = player.nowPlayingItem.title
        let attributedString = NSMutableAttributedString(string:title)
        songNameLabel.attributedText = attributedString
        songNameLabel.textAlignment = NSTextAlignment.Center
            
        artistNameLabel.text = player.nowPlayingItem.artist
        
        
        songNameLabel!.font = UIFont.systemFontOfSize(18)
        artistNameLabel!.font = UIFont.systemFontOfSize(12)
        
        //increase edge width
        //TODO: set a max of width to avoid clashing with pulldown and tuning button
        songNameLabel.frame.size = CGSize(width: songNameLabel.frame.width + 20, height: 30)
        artistNameLabel.frame.size = CGSize(width: artistNameLabel.frame.width + 20, height: 30)
        songNameLabel.center.x = self.view.frame.width / 2
        songNameLabel.center.y = pulldownButton.center.y - 7
        
        artistNameLabel.center.x = self.view.frame.width / 2
        artistNameLabel.center.y = CGRectGetMaxY(songNameLabel.frame) + 5
        
        songNameLabel.textColor = UIColor.whiteColor()
        artistNameLabel.textColor =  UIColor.whiteColor()
        
        artistNameLabel.backgroundColor = UIColor.clearColor()
        
        topView.addSubview(songNameLabel)
        topView.addSubview(artistNameLabel)
    }

    
    func setUpControlButtons(){
        previousButton = UIButton(frame: CGRect(x: 0, y: base.frame.origin.y, width: buttonDimension, height: buttonDimension))
        previousButton.setImage(UIImage(named: "previous"), forState: .Normal)
        previousButton.addTarget(self, action: "previousPressed:", forControlEvents: .TouchUpInside)
        previousButton.contentHorizontalAlignment = .Left
        
        nextButton = UIButton(frame: CGRect(x: 0, y: base.frame.origin.y, width: buttonDimension, height: buttonDimension))
        nextButton.setImage(UIImage(named: "next"), forState: .Normal)
        nextButton.addTarget(self, action: "nextPressed:", forControlEvents: .TouchUpInside)
        nextButton.frame.origin.x = self.view.frame.width - nextButton.frame.width
        nextButton.contentHorizontalAlignment = .Right
        self.view.addSubview(previousButton)
        self.view.addSubview(nextButton)
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
    
    func setUpMusicData(song: MPMediaItem){
         if song.title == "Rolling In The Deep" {
            chords = Chord.getRollingChords()
            lyric = Lyric.getRollingLyrics()
        } else if song.title == "彩虹" {
            chords = Chord.getRainbowChords()
            lyric = Lyric.getRainbowLyrics()
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
    }
    
    func setUpLyricsBase(){
        //Lyric labels
        current = -1
        let sideMargin: CGFloat = 20
        
        lyricbase = UIView(frame: CGRect(x: sideMargin, y: CGRectGetMaxY(base.frame) + marginBetweenBases, width: self.view.frame.width - 2 * sideMargin, height: basesHeight * 0.4))
        lyricbase.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        lyricbase.alpha = 0.8
        
        self.view.addSubview(lyricbase)
        
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
        let marginToArtistButton: CGFloat = 20
        let marginToProgressContainer: CGFloat = 10
        basesHeight = self.view.frame.height - topViewHeight - marginToArtistButton - bottomViewHeight - progressContainerHeight - marginBetweenBases - marginToProgressContainer
        
        base = ChordBase(frame: CGRect(x: 0, y: topViewHeight + marginToArtistButton, width: self.view.frame.width * 0.62, height: basesHeight * 0.6))
        base.center.x = self.view.center.x
        base.backgroundColor = UIColor.clearColor()
        base.alpha = 0.8
        
        panRecognizer = UIPanGestureRecognizer(target: self, action:Selector("handleChordBasePan:"))
        panRecognizer.delaysTouchesEnded = true
        
        panRecognizer.delegate = self
        base.addGestureRecognizer(panRecognizer)
        
        
        self.view.addSubview(base)
    }
    
    
    func registerMediaPlayerNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentSongChanged:"), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playbackStateChanged:"), name:MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerVolumeChanged:"), name:MPMusicPlayerControllerVolumeDidChangeNotification, object: player)
        player.beginGeneratingPlaybackNotifications()
    }
    
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func currentSongChanged(notification: NSNotification){
        synced(self) {
            
            if self.player.repeatMode == .One {
                println("\(self.player.nowPlayingItem.title) is repeating")
                self.updateAll(0)
                return
            }
 
            let nowPlayingItem = self.player.nowPlayingItem
            
            // use current item's playbackduration to validate nowPlayingItem duration
            // if they are not equal, i.e. not the same song
            if self.firstloadSongTitle != nowPlayingItem.title && self.firstLoadSongTime != nowPlayingItem.playbackDuration {
                
                if(self.actionSheet != nil && self.actionSheet.isTwistJamActionSheetShow == true){
 
                    self.actionSheet!.dismissAnimated(true)
                }
                self.firstLoadSongTime = nowPlayingItem.playbackDuration
                
                self.setUpMusicData(nowPlayingItem)
                // The following won't run when selected from table
                // update the progressblockWidth
                
                self.progressBlockViewWidth = nil
        
                let nowPlayingItemDuration = nowPlayingItem.playbackDuration

                self.progressBlock.frame = CGRectMake(self.view.frame.width / 2, 0, CGFloat(nowPlayingItemDuration) * self.progressWidthMultiplier, 161)
                self.progressBlock.center.y = self.progressContainerHeight
        
                // if we are NOT repeating song
                if self.player.repeatMode != .One {
                    
                    self.songNameLabel.attributedText = NSMutableAttributedString(string: nowPlayingItem.title)
                    self.songNameLabel.textAlignment = NSTextAlignment.Center
                    self.artistNameLabel.text = nowPlayingItem.artist
        
                    let image = self.player.nowPlayingItem.artwork.imageWithSize(CGSize(width: self.view.frame.height/8, height: self.view.frame.height/8))
                    let blurredImage = image.applyLightEffect()!
                    self.textColor = blurredImage.averageColor()
            
                    self.backgroundImageView.center.x = self.view.center.x
                    self.backgroundImageView.image = blurredImage
       
                    self.totalTimeLabel.text = TimeNumber(time: Float(nowPlayingItemDuration)).toDisplayString()
                }
            }
            self.speed = 1
            self.nowPlayingItemSpeed = 1
            self.timer.invalidate()
            self.startTimer()

            self.updateAll(0)
        }
    }
    
    func playbackStateChanged(notification: NSNotification){
        let playbackState = player.playbackState
        if playbackState == .Paused {
            timer.invalidate()
            musicViewController!.nowView.stop()
        }
        else if playbackState == .Playing {
            startTimer()
            musicViewController!.nowView.start()
        }
    }
    
    override func didReceiveMemoryWarning() {
        println("memory warning")
        removeMusicPlayerObserver()
        player.endGeneratingPlaybackNotifications()
    }
    func removeMusicPlayerObserver(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerVolumeDidChangeNotification, object: player)
    }
    
    func playerVolumeChanged(notification: NSNotification){
        println("volume changed")
    }

    
    func resumeSong(){
        
        musicViewController!.nowView!.stop()
        if selectedFromTable {
            player.play()
            startTimer()
        }else{ // selected from now view button
            if player.playbackState == MPMusicPlaybackState.Playing {
                startTimer()
            }
            else if player.playbackState == MPMusicPlaybackState.Paused {
                timer.invalidate()
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                self.progressBlock!.alpha = 0.5
                self.speed = player.currentPlaybackRate
            }
        }

        startTime =  TimeNumber(time: Float(player.currentPlaybackTime))
        updateAll(startTime.toDecimalNumer())
    }
    
    
    
    func setUpProgressContainer(){
        
        progressChangedOrigin = self.view.frame.width / 2
        progressBlockContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: progressContainerHeight))
        
        progressBlockContainer.center.y = self.view.frame.height - bottomViewHeight - progressContainerHeight / 2
        
        progressBlockContainer.backgroundColor = UIColor.clearColor()
        self.view.addSubview(progressBlockContainer)
        
        var progressBarWidth:CGFloat!

        progressBarWidth = CGFloat(player.nowPlayingItem.playbackDuration) * progressWidthMultiplier

        progressBlock = SoundWaveView(frame: CGRect(x: 0, y: 0, width: progressBarWidth, height: 161))
        progressBlock.center.y = progressContainerHeight
        let assetURL = player.nowPlayingItem.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
        self.progressBlock.SetSoundURL(assetURL!)
        
        self.progressBlockContainer.addSubview(self.progressBlock)
        
        progressBlockContainer.addSubview(progressBlock)
        panRecognizer = UIPanGestureRecognizer(target: self, action:Selector("handleProgressPan:"))
        panRecognizer.delegate = self
        progressBlockContainer.addGestureRecognizer(panRecognizer)
        tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("playPause:"))
        progressBlockContainer.addGestureRecognizer(tapRecognizer)
        
    }
    
    func handleProgressPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        for childview in recognizer.view!.subviews {
            let child = childview as! UIView
            self.isPanning = true
            
            var newPosition = progressChangedOrigin + translation.x
            
            // leftmost point of inner bar cannot be more than half of the view
            if newPosition > self.view.frame.width / 2 {
                newPosition = self.view.frame.width / 2
            }
            
            // the end of inner bar cannot be smaller left half of view
            if newPosition + child.frame.width < self.view.frame.width / 2 {
                newPosition = self.view.frame.width / 2 - child.frame.width
            }
            
            //update all chords, lyrics
            timer.invalidate()
            
            //new Position from 160 to -357
            //-self.view.frame.width /2
            //= from 0 ot -517
            //divide by -2: from 0 to 258
            let toTime = Float(newPosition - self.view.frame.width / 2) / -(Float(self.progressWidthMultiplier))
            self.progressBlock.setProgress(CGFloat(toTime)/CGFloat(player.nowPlayingItem.playbackDuration))
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
        let translation = recognizer.translationInView(self.view)
        
        switch recognizer.state {
            
        case UIGestureRecognizerState.Began:
            isPanning = true
            currentChordTime = startTime.toDecimalNumer()+0.01
            timer.invalidate()
            updateAll(currentChordTime)
            
            break;
        case UIGestureRecognizerState.Changed:
            let tempNowPlayingItem = player.nowPlayingItem
            var deltaTime = Float(translation.y)*(freefallTime/Float(base.frame.size.height))
            toChordTime = currentChordTime + deltaTime
            
            if toChordTime < 0 {
                toChordTime = 0
            } else if (toChordTime > Float(tempNowPlayingItem.playbackDuration)){
                toChordTime = Float(tempNowPlayingItem.playbackDuration)
            }
            
            //update soundwave progress
            progressBlock.setProgress(CGFloat(toChordTime)/CGFloat(tempNowPlayingItem.playbackDuration))
            
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
        wrapper.center.x = self.view.center.x
        wrapper.backgroundColor = UIColor.darkGrayColor()
        wrapper.alpha = 0.7
        wrapper.layer.cornerRadius = labelHeight/5
        self.view.addSubview(wrapper)
        
        currentTimeLabel = UILabel(frame: CGRect(x: self.view.center.x-labelWidth, y: timeLabelOriginY , width: labelWidth, height: labelHeight))
        currentTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        currentTimeLabel.text = "0:00.0"
        currentTimeLabel.textAlignment = .Center
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
        totalTimeLabel.text = TimeNumber(time: Float(player.nowPlayingItem.playbackDuration)).toDisplayString()
        totalTimeLabel.textAlignment = .Center
        self.view.addSubview(totalTimeLabel)
        
    }
    
    //from left to right: share, favoriate, shuffle, others
    func setUpBottomViewWithButtons(){
        let edgeButtonSideMargin:CGFloat = 50
        
        
        bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - bottomViewHeight, width: self.view.frame.width, height: bottomViewHeight))
        bottomView.backgroundColor = UIColor.darkGrayColor()
        bottomView.alpha = 0.7
        self.view.addSubview(bottomView)
        
        let bottomButtonSize: CGSize = CGSizeMake(bottomView.frame.width / 4, bottomView.frame.height)

        //TODO: Add glowing effect when pressed
        //divide view width into eigth to distribute center x for each of four buttons
        favoriateButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        favoriateButton.setImage(UIImage(named: "notfavorited"), forState: UIControlState.Normal)
        favoriateButton.sizeToFit()
        
        shuffleButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        
        if player.repeatMode == .All && player.shuffleMode == .Off {
             shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[0]), forState: UIControlState.Normal)
        } else if player.repeatMode == .One && player.shuffleMode == .Off {
             shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[1]), forState: UIControlState.Normal)
        } else if player.repeatMode == .All && player.shuffleMode == .Songs {
            shuffleButton.setImage(UIImage(named: shuffleButtonImageNames[2]), forState: UIControlState.Normal)
        }
        
        shuffleButton.addTarget(self, action: "toggleShuffle:", forControlEvents: .TouchUpInside)
        
        guitarButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        guitarButton.setImage((UIImage(named: "guitar_settings")), forState: UIControlState.Normal)

        guitarButton.addTarget(self, action: "showGuitarActions", forControlEvents: UIControlEvents.TouchUpInside)
        othersButton = UIButton(frame: CGRect(origin: CGPointZero, size: bottomButtonSize))
        othersButton.setImage(UIImage(named: "more_options"), forState: UIControlState.Normal)
        othersButton.center.y = bottomViewHeight / 2
        othersButton.addTarget(self, action: "showActionSheet", forControlEvents: UIControlEvents.TouchUpInside)
        
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
    
    func showGuitarActions(){
        actionSheet = TwistJamActionSheet()
        actionSheet.needRunningManSlider = true
        actionSheet.songVC = self
        var handler:TwistJamActionSheet = TwistJamActionSheet()

        actionSheet.addButtonWithTitle(NSString(string:""), image: UIImage(), type: ActionSheetButtonType.ActionSheetButtonTypeDefault, handler:{(alert:TwistJamActionSheet) -> Void in
            println("here")
        })
        actionSheet.addButtonWithTitle(NSString(string:"Change Tab Mode"), image: UIImage(), type: ActionSheetButtonType.ActionSheetButtonTypeDefault, handler:{(alert:TwistJamActionSheet) -> Void in
            self.changeChordMode()
        })
        actionSheet.show()
    }
    
    func showActionSheet(){

        actionSheet = TwistJamActionSheet()

        var handler:TwistJamActionSheet = TwistJamActionSheet()
    
        actionSheet.addButtonWithTitle(NSString(string:"Add your tabs"), image: UIImage(), type: ActionSheetButtonType.ActionSheetButtonTypeDefault, handler:{(alert:TwistJamActionSheet) -> Void in
            let editTabsVC = EditTabsViewController()
            self.presentViewController(editTabsVC, animated: true, completion: nil)
        })
        actionSheet.addButtonWithTitle(NSString(string:"Add your lyrics"), image: UIImage(), type: ActionSheetButtonType.ActionSheetButtonTypeDefault, handler:{(alert:TwistJamActionSheet) -> Void in
            
        })
        actionSheet.show()
    }
    
    // ISSUE: when app goes to background this is not called
    //stop timer,stop refreshing UIs after view is completely gone of sight
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        println("view will disappear")
        timer.invalidate()
        viewDidFullyDisappear = true
        if player.playbackState == MPMusicPlaybackState.Playing {
            player.currentPlaybackRate = 1
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.mainPinkColor()
        self.tabBarController?.tabBar.hidden = false
        if player.playbackState == MPMusicPlaybackState.Playing {
            musicViewController!.nowView!.start()
        }
        else if player.playbackState == MPMusicPlaybackState.Paused {
            musicViewController!.nowView!.stop()
        }
    }
    
    func calculateXPoints(){
        let width = base.frame.width
        
        let margin:Float = 0.25
        let initialPoint:CGFloat = CGFloat(Float(width) * margin)
        let rightTopPoint:CGFloat = CGFloat(Float(width) * (1 - margin))
        
        let scale:Float = 1 / 12
        let topWidth = Float(rightTopPoint) - Float(initialPoint)
        let topLeft = Float(initialPoint) + Float(topWidth) * scale
        
        topPoints = [CGFloat](count: 7, repeatedValue: 0)
        topPoints[0] = CGFloat(topLeft)
        for i in 1..<6 {
            topPoints[i] = CGFloat(Float(topPoints[i - 1]) + Float(topWidth * scale * 2))
        }
        
        bottomPoints = [CGFloat](count: 7, repeatedValue: 0)
        bottomPoints[0] = CGFloat(Float(width) * scale)
        for i in 1..<6 {
            bottomPoints[i] = CGFloat(Float(bottomPoints[i - 1]) + Float(width) * scale * 2)
        }
        
        //add things
        let top0: CGFloat = CGFloat(margin * Float(base.frame.width) - 20)
        let buttom0: CGFloat = CGFloat(-20)
        
        topPoints.insert(top0, atIndex: 0)
        bottomPoints.insert(buttom0, atIndex: 0)
        
        //Mode 0
        topPointModes[0] = topPoints
        bottomPointModes[0] = bottomPoints
        
        //Mode 1
        topPoints = [width / 2]
        bottomPoints = [width / 2]
        
        topPointModes[1] = topPoints
        bottomPointModes[1] = bottomPoints
        
        topPoints = topPointModes[mode]!
        bottomPoints = bottomPointModes[mode]!
        
    }
    
    
    func update(){
        
        startTime.addMinimal()
        //println("update:\(startTime.toDecimalNumer())")
        if activelabels.count > 0 && start+1 < chords.count && chords[start+1].mTime.isEqual(TimeNumber( time: startTime.toDecimalNumer() + timeToDisappear))
        {
            for label in disappearingLabels {
                label.removeFromSuperview()
            }
            
            disappearingLabels = activelabels.removeAtIndex(0)
            disapperingLabelAlpha = Int(timeToDisappear / 0.01)
            
            start++
        }
        
        // Add new chord
        let end = start + activelabels.count
        if end < chords.count && chords[end].mTime.isEqual(TimeNumber(time: freefallTime + startTime.toDecimalNumer())) {
            self.activelabelAppend(end)
        }
        
        if current + 1 < lyric.lyric.count && lyric.get(current+1).time.isEqual(startTime) {
            current++
            topLyricLabel.text = lyric.get(current).str
            
            if current + 1 < lyric.lyric.count {
                bottomLyricLabel.text = lyric.get(current+1).str
            }
        }
        
        if disapperingLabelAlpha > 0 {
            let totalalpha: Float = timeToDisappear / 0.01
            let currentalpha: CGFloat = CGFloat(Float(disapperingLabelAlpha) / totalalpha)
            disapperingLabelAlpha--
            for label in disappearingLabels {
                label.alpha = currentalpha
                //label.textColor = UIColor.blackColo()
                if disapperingLabelAlpha == 0 {
                    label.removeFromSuperview()
                }
            }
        }
        
        refreshChordLabel()
        refreshProgressBlock()
        refreshTimeLabel()
        
    }
    
    
    func refreshChordLabel(){
        /// Change the location of each label
        for var i = 0; i < activelabels.count; ++i{
            var labels = activelabels[i]
            let t = chords[start+i].mTime
            var yPosition = Float(self.base.frame.height)*(startTime.toDecimalNumer() + freefallTime - t.toDecimalNumer()) / freefallTime
            if yPosition > Float(self.base.frame.height){
                yPosition = Float(self.base.frame.height)
            }
            for var j = 0; j < labels.count; ++j{
                var bottom = Float(bottomPoints[j])
                var top = Float(topPoints[j])
                var xPosition = CGFloat(bottom + (top - bottom) * (t.toDecimalNumer() - startTime.toDecimalNumer()) / freefallTime)
                if yPosition == Float(self.base.frame.height){
                    if(j != 0 ){
                       // labels[j].font = UIFont.systemFontOfSize(16.6)
                        labels[j].textColor = UIColor.blackColor()
                    }
                    
                    xPosition = bottomPoints[j]
                }
                
                labels[j].center = CGPointMake(xPosition, CGFloat(yPosition - Float(labels[j].frame.height / 2)))
            }
        }
        
    }
    
    
    func refreshProgressBlock(){
        
        if progressBlockViewWidth == nil {
            progressBlockViewWidth = CGFloat(player.nowPlayingItem.playbackDuration)
        }
        
        let newProgressPosition = (CGFloat(startTime.toDecimalNumer()) * self.progressBlock.frame.width / progressBlockViewWidth!) / self.progressBlock.frame.size.width
        
        let newOriginX = self.view.frame.width / 2 - CGFloat(startTime.toDecimalNumer()) * self.progressBlock.frame.width / progressBlockViewWidth!
        if !isPanning {
            self.progressChangedOrigin = newOriginX
            self.progressChangedPosition = newProgressPosition
            self.progressBlock.setProgress(newProgressPosition)
        }
        self.progressBlock.frame.origin.x = newOriginX
    }
    
    func refreshTimeLabel(){
        // update current time label
        // var tempcurrentTime:NSString = NSString(string: startTime.toDisplayString())
        // currentTimeLabel.text = tempcurrentTime.substringToIndex(tempcurrentTime.length-2)
        currentTimeLabel.text = startTime.toDisplayString()
    }
    
    func updateAll(time: Float){
        ///Set the start time
        startTime = TimeNumber(time: time)
        
        ///Remove all label in current screen
        for labels in activelabels{
            for label in labels{
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
            var mid: Int = (begin + end) / 2
            if startTime.isLongerThan(chords[mid].mTime) {
                begin = mid
            } else {
                end = mid
            }
            if begin == (end - 1) {
                start = begin
                if startTime.isLongerThan(chords[end].mTime) {
                    start = end
                }
                break
            }
        }
        
        begin = 0
        end = chords.count - 1
        let tn = TimeNumber(time: startTime.toDecimalNumer() + freefallTime)
        while true {
            var mid: Int = (begin + end) / 2
            if tn.isLongerThan(chords[mid].mTime) {
                begin = mid
            } else {
                end = mid
            }
            if begin == (end - 1) {
                last = begin
                if tn.isLongerThan( chords[end].mTime ) {
                    last = end
                }
                break
            }
        }
        
        if start == last {
            self.activelabelAppend(start)
        }
        
        if start < last {
            if startTime.isLongerThan(chords[start].mTime) && (TimeNumber(time: startTime.toDecimalNumer() + timeToDisappear)).isLongerThan(chords[start+1].mTime) {
                self.start++
            }
            
            for i in start...last {
                self.activelabelAppend(i)
            }
        }
        
        refreshChordLabel()
        refreshProgressBlock()
        refreshTimeLabel()
        //Update the content of the lyric
        current = -1
        while(current + 1 < lyric.lyric.count){
            if lyric.get(current + 1).time.toDecimalNumer() > startTime.toDecimalNumer() {
                break
            }
            current++
        }
        
        if current == -1{
            topLyricLabel.text = "..."//theSong.title
        }
        else {
            topLyricLabel.text = lyric.get(current).str
        }
        if current + 1 < lyric.lyric.count {
            bottomLyricLabel.text = lyric.get(current+1).str
        }
        else {
            bottomLyricLabel.text = "End~"
        }
    }
  
    
    func playPause(recognizer: UITapGestureRecognizer) {
        if player.playbackState == MPMusicPlaybackState.Paused {
            player.play()
            player.currentPlaybackRate = nowPlayingItemSpeed
            println("play")
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.2)
                //self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.progressBlock!.alpha = 1.0
                }, completion: { finished in
                    UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        }, completion: {
                            finished in self.progressBlockContainer.addGestureRecognizer(self.tapRecognizer)
                    })
                    
            })
        } else {
            nowPlayingItemSpeed = player.currentPlaybackRate
            player.pause()
            musicViewController!.nowView!.stop()
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveLinear, animations: {
                println("pause1")
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                //self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                self.progressBlock!.alpha = 0.5
                }, completion: { finished in self.progressBlockContainer.addGestureRecognizer(self.tapRecognizer)
                    
            })
        }
    }
    
    func changeChordMode() {
        timer.invalidate()
        mode = 1 - mode
        topPoints = topPointModes[mode]!
        bottomPoints = bottomPointModes[mode]!
        updateAll(startTime.toDecimalNumer())
        if player.playbackState == .Playing{
            startTimer()
        }
    }

    func startTimer(){
        //NOTE: To prevent startTimer() to be called consecutively
        //which would double the update speed. We only
        //start the timer when it is not valid
        //In case of receiving song changed and playback state 
        //notifications, notifications are triggered twice somehow
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01 / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        }
    }
    
    func createLabels(name: String, content: String) -> [UILabel]{
        var res = [UILabel]()
        
        let chordNameLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))

        chordNameLabel.text = name
        chordNameLabel.textColor = UIColor.blackColor()
        chordNameLabel.sizeToFit()
        chordNameLabel.textAlignment = NSTextAlignment.Center
        res.append(chordNameLabel)
        self.base.addSubview(chordNameLabel)
        
        if mode == fullchord {
            for i in 0...count(content)-1 {
                //if not a integer
                let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
                label.font = UIFont.systemFontOfSize(25)
                label.text = String(Array(content)[i])
                label.sizeToFit()
                label.textColor = UIColor.silverGray()
                label.textAlignment = NSTextAlignment.Center
                res.append(label)
                self.base.addSubview(label)
            }
        }
        return res
    }
    
    //////////////////////////////////

    func activelabelAppend(index: Int){
        activelabels.append(createLabels(chords[index].tab.name, content: chords[index].tab.content))
        dealWithLabelofChordName(activelabels.last!.first!)
    }

    private func dealWithLabelofChordName(chordLabel:UILabel){
        //make the text glow
        chordLabel.textColor = UIColor.blackColor()
        var color:UIColor = chordLabel.textColor
        chordLabel.layer.shadowColor = color.CGColor
        chordLabel.layer.shadowRadius = 4.0
        chordLabel.layer.shadowOpacity = 1.0
        chordLabel.layer.shadowOffset = CGSizeZero
        chordLabel.layer.masksToBounds = false
        
        chordLabel.alpha = 0.9
        
        //make the frame of the label fit to the text
        var chordNSString:NSString = NSString(string: chordLabel.text!)
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
}

