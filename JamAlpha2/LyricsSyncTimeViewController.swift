//
//  syncTimeViewController.swift
//  lyricsEditorV2
//
//  Created by Jun Zhou on 9/16/15.
//  Copyright (c) 2015 TwistJam. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

var tempLyricsTimeTuple = [(String, NSTimeInterval)]()

class lyricsWithTime {
    var count: Int!
    var lyrics: [String]!
    var time: [NSTimeInterval]!
    var timeAdded: [Bool]!
    init(count: Int) {
        self.count = count
        self.lyrics = [String](count: count, repeatedValue: "")
        self.time = [NSTimeInterval](count: count, repeatedValue: 0)
        self.timeAdded = [Bool](count: count, repeatedValue: false)
    }
    func addExistLyrics(count: Int, lyrics: [String], time: [NSTimeInterval], timeAdded: [Bool]) {
        self.count = count
        self.lyrics = lyrics
        self.time = time
        self.timeAdded = timeAdded
    }
}

class LyricsSyncViewController: UIViewController, UIScrollViewDelegate {
    var currentTime: NSTimeInterval = 0
    var isDemoSong = false
    var isPlaying:Bool = false
    var stepPerSecond: Float = 100
    var startTime: TimeNumber = TimeNumber(second: 0, decimal: 0)
    var speed: Float = 1
    var recoverMode: (MPMusicRepeatMode, MPMusicShuffleMode, NSTimeInterval)!
    var lyricsTextViewController: LyricsTextViewController! //used to call dismiss function on it to go back to SongViewController
    // MARK: UI elements
    var lyricsTableView: UITableView = UITableView()
    var progressBlockContainer: UIView!
    var progressBlock: SoundWaveView!
    var tapGesture: UITapGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    var currentTimeLabel: UILabel = UILabel()
    var totalTimeLabel: UILabel = UILabel()
    var songViewController: SongViewController? //used to parse synced lyrics from LyricsSyncViewController
    var progressChangedOrigin: CGFloat!
    var lyricsFromTextView: String!
    var viewWidth = CGFloat()
    var viewHeight  = CGFloat()
    var theSong: Findable!
    var lyricsOrganizedArray: [String]!
    var avPlayer: AVAudioPlayer!
    var musicPlayer: MPMusicPlayerController!
    var updateTimer: NSTimer!
    // count down section
    var countdownTimer: NSTimer!
    var countDownStartSecond = 3 //will count down from 3 to 1
    var countdownView: CountdownView!
    var playButtonImageView: UIImageView = UIImageView()
    var defaultProgressBar:UIProgressView!
    // MARK: tutorial
    var tutorialImage: UIImageView!
    var tutorialCloseButton: UIButton!
    // MARK: UIGestures
    var addedLyricsWithTime: lyricsWithTime!
    let speedMatcher = ["0.7": 0.50, "0.8" : 0.67, "0.9": 0.79, "1.0": 1.00, "1.1": 1.25, "1.2": 1.50, "1.3": 2.00]
    var speedKey = 1.0
    var duration: NSTimeInterval!
    var currentSelectIndex: Int = 0
    var isPanning = false
    var toTime: NSTimeInterval = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        addedLyricsWithTime = lyricsWithTime(count: lyricsOrganizedArray.count)
        viewWidth = view.frame.width
        viewHeight = view.frame.height
        setUpPlayer()
        setUpHeaderView()
        setUpLyricsTableView()
        setUpProgressBlock()
        setUpTimeLabels()
        setUpCountdownView()
        setUpTutorial()
        if tempLyricsTimeTuple.count > 0 {
            addUnfinishedLyricsAndTime()
        } else {
            addLyricsToEditorView(theSong)
        }
        lyricsTableView.preservesSuperviewLayoutMargins = false
        lyricsTableView.separatorInset = UIEdgeInsetsZero
        lyricsTableView.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if (defaultProgressBar != nil) {
            defaultProgressBar.removeFromSuperview()
            defaultProgressBar = nil
        }
        stopCountDownTimer()
        stopUpdateTimer()
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    func setupDefaultProgressBar(){
        dispatch_async(dispatch_get_main_queue()) {
            self.defaultProgressBar = UIProgressView(frame: CGRectMake(0,self.progressBlockContainer.frame.height - 36,self.view.width,10))
            self.defaultProgressBar.progress = 1.0
            self.defaultProgressBar.trackTintColor = UIColor.mainPinkColor()
            self.defaultProgressBar.progressTintColor = UIColor.whiteColor()
            self.defaultProgressBar.alpha = 0.5
            self.progressBlockContainer.insertSubview(  self.defaultProgressBar , aboveSubview: self.progressBlock)
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
                startUpdateTimer()
                isPlaying = true
            }
            playButtonImageView.hidden = true
            progressBlock.alpha = 1
            if  defaultProgressBar != nil {
                defaultProgressBar.alpha = 1
            }
        } else if musicPlayer.playbackState == .Paused {
            isPlaying = false
            playButtonImageView.hidden = false
            stopUpdateTimer()
            progressBlock.alpha = 0.5
            if defaultProgressBar != nil {
                defaultProgressBar.alpha = 0.5
            }
        }
    }
    
    func currentSongChanged(sender: NSNotification){
        if musicPlayer.playbackState == .Playing {
            musicPlayer.currentPlaybackRate = speed
        }
    }
    // MARK: check theSong can convert to MPMediaItem
    func setUpPlayer() {
        if isDemoSong {
            avPlayer = AVAudioPlayer()
            duration = NSTimeInterval(MusicManager.sharedInstance.avPlayer.currentItem!.getDuration())
            let url: NSURL = theSong.getURL() as! NSURL
            avPlayer = try! AVAudioPlayer(contentsOfURL: url)
            avPlayer.currentTime = 0.0
            avPlayer.volume = 1
            avPlayer.enableRate = true
            avPlayer.rate = 1
            return
        }
        musicPlayer = MusicManager.sharedInstance.player
        musicPlayer.currentPlaybackTime = 0.0
        registerNotification()
        duration = (musicPlayer.nowPlayingItem!.playbackDuration.isNaN ? 1500 : musicPlayer.nowPlayingItem!.playbackDuration)
    }
    
    func setUpHeaderView() {
        let titleView: UIView = UIView()
        titleView.frame = CGRectMake(0, 0, viewWidth, 20 + 44)
        titleView.backgroundColor = UIColor.mainPinkColor()
        view.addSubview(titleView)
        
        let spacing: CGFloat = 10
        let buttonWidth: CGFloat = 50
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0, 0, buttonWidth, buttonWidth)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        backButton.setImage(UIImage(named: "lyrics_back_circle"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.center.y = 20 + 44/2
        titleView.addSubview(backButton)
        
        let doneButton: UIButton = UIButton()
        doneButton.frame = CGRectMake(17
            / 20 * viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        doneButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        doneButton.setImage(UIImage(named: "lyrics_done_circle"), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(doneButton)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.systemFontOfSize(20)
        titleLabel.text = "Sync lyrics"
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: titleView.center.x, y: 44/2 + 20)
        titleView.addSubview(titleLabel)
        
        let speedUpButton: UIButton = UIButton()
        speedUpButton.frame = CGRectMake(14 / 20 * viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        speedUpButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        speedUpButton.setImage(UIImage(named: "increase"), forState: UIControlState.Normal)
        speedUpButton.addTarget(self, action: "pressSpeedUpButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        titleView.addSubview(speedUpButton)
        
        let speedDownButton: UIButton = UIButton()
        speedDownButton.frame = CGRectMake(3 / 20 * viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        speedDownButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        speedDownButton.setImage(UIImage(named: "decrease"), forState: UIControlState.Normal)
        speedDownButton.addTarget(self, action: "pressSpeedDownButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(speedDownButton)
    }
    
    func setUpLyricsTableView() {
        let backgroundImageWidth: CGFloat = viewHeight - 64
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(viewWidth / 2 - backgroundImageWidth / 2, 64, backgroundImageWidth, backgroundImageWidth)
        let size: CGSize = CGSizeMake(viewWidth, viewHeight)
        var image:UIImage!
        if let artwork = theSong.getArtWork() {
            image = artwork.imageWithSize(size)
        } else {
            image = UIImage(named: "liwengbg")
        }
        if songViewController != nil {
          backgroundImage.image = image != nil ? image : songViewController!.backgroundImage
        } else {
          backgroundImage.image = UIImage(named: "liwengbg")
        }
        let blurredImage:UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        view.addSubview(backgroundImage)
        
        lyricsTableView.frame = CGRectMake(0, 64, viewWidth, 24 / 31 * viewHeight)
        lyricsTableView.delegate = self
        lyricsTableView.dataSource = self
        lyricsTableView.registerClass(LyricsSyncTimeTableViewCell.self, forCellReuseIdentifier: "lyricsSyncCell")
        lyricsTableView.backgroundColor = UIColor.clearColor()
        view.addSubview(lyricsTableView)
    }

    func setUpProgressBlock() {
        progressChangedOrigin = view.center.x
        progressBlockContainer = UIView(frame: CGRect(x: 0, y: viewHeight-progressContainerHeight, width: view.frame.width, height: progressContainerHeight))
        progressBlockContainer.backgroundColor = UIColor.clearColor()
        view.addSubview(progressBlockContainer)
        
        playButtonImageView.frame = CGRect(x: 0, y: view.frame.height - 50, width: 30, height: 30)
        playButtonImageView.center.x = view.center.x
        playButtonImageView.image = UIImage(named: "playbutton")
        view.addSubview(playButtonImageView)
        view.bringSubviewToFront(playButtonImageView)

        progressBlock = SoundWaveView(frame: CGRectMake(view.center.x, 0, CGFloat(theSong.getDuration()) * 2, soundwaveHeight))
      
        if KGLOBAL_progressBlock != nil && KGLOBAL_progressBlock.generatedNormalImage != nil {
          progressBlock.setWaveFormFromImage(KGLOBAL_progressBlock.generatedNormalImage)
        } else if let soundWaveData = CoreDataManager.getSongWaveFormImage(theSong) {
          progressBlock.setWaveFormFromData(soundWaveData)
        } else {
          setupDefaultProgressBar()
        }
      
        progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
        progressBlock!.alpha = 0.5
        if defaultProgressBar != nil {
            defaultProgressBar.alpha = 0.5
        }
        progressBlockContainer.addSubview(progressBlock)
        tapGesture = UITapGestureRecognizer(target: self, action: "playPause")
        panGesture = UIPanGestureRecognizer(target: self, action:Selector("handleProgressPan:"))
        progressBlockContainer.addGestureRecognizer(tapGesture)
        progressBlockContainer.addGestureRecognizer(panGesture)
    }
    
    func setUpTimeLabels(){
        let labelWidth: CGFloat = 40
        let labelHeight: CGFloat = 15
        let labelFontSize: CGFloat = 12
        let timeLabelOriginY = viewHeight-labelHeight
        
        let wrapper = UIView(frame: CGRect(x: 0, y: timeLabelOriginY, width: 85, height: labelHeight))
        wrapper.center.x = view.center.x
        wrapper.backgroundColor = UIColor.darkGrayColor()
        wrapper.alpha = 0.7
        wrapper.layer.cornerRadius = labelHeight/5
        view.addSubview(wrapper)
        
        currentTimeLabel = UILabel(frame: CGRect(x: view.center.x-labelWidth, y: timeLabelOriginY , width: labelWidth, height: labelHeight))
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
        view.addSubview(currentTimeLabel)
        
        totalTimeLabel = UILabel(frame: CGRect(x: view.center.x+1, y:timeLabelOriginY, width: labelWidth, height: labelHeight))
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.font = UIFont.systemFontOfSize(labelFontSize)
        
        totalTimeLabel.text = TimeNumber(time: Float(theSong.getDuration())).toDisplayString()
        totalTimeLabel.textAlignment = .Right
        view.addSubview(totalTimeLabel)
    }
    
    func setUpCountdownView() {
        countdownView = CountdownView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        countdownView.center = view.center
        countdownView.backgroundColor = UIColor.clearColor()
        countdownView.hidden = true
        view.addSubview(countdownView)
    }
    
    func setUpTutorial() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kShowLyricsTutorial) {
            return
        }
        tutorialImage = UIImageView(frame: view.bounds)
        tutorialImage.image = UIImage(named: "lyrics_tutorial")
        view.addSubview(tutorialImage)
 
        tutorialCloseButton = UIButton(frame: CGRect(x: 20, y: 15, width: 30, height: 30))
        tutorialCloseButton.setImage(UIImage(named: "closebutton"), forState: .Normal)
        tutorialCloseButton.addTarget(self, action: "hideTutorial", forControlEvents: .TouchUpInside)
        view.addSubview(tutorialCloseButton)
    }
    
    func hideTutorial() {
        tutorialImage.hidden = true
        tutorialCloseButton.hidden = true
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowLyricsTutorial)
    }
    

    
    func startCountDownTimer() {
        if countdownTimer == nil {
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func stopCountDownTimer() {
        if countdownTimer == nil {
            return
        }
        countdownTimer.invalidate()
        countdownTimer = nil
    }
    
    func playPause() {
        if isDemoSong ? !avPlayer.playing : (musicPlayer.playbackState != .Playing) {
            //start counting down 3 seconds
            //disable tap gesture that inadvertly starts timer
            isPlaying = true
            progressBlockContainer.removeGestureRecognizer(tapGesture)
            countdownView.hidden = false
            countdownView.setNumber(countDownStartSecond)
            startCountDownTimer()
            playButtonImageView.hidden = true
            return
        }
        playButtonImageView.hidden = false
        isPlaying = false
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
            self.progressBlock!.alpha = 0.5
            if (self.defaultProgressBar != nil){
                self.defaultProgressBar.alpha = 0.5
            }
            }, completion: nil)
        if isDemoSong {
            avPlayer.pause()
        } else {
            musicPlayer.pause()
        }
        stopUpdateTimer()
    }

    func startUpdateTimer() {
        if updateTimer != nil {
            return
        }
        if(isDemoSong){
            avPlayer.rate = speed
        }else{
            musicPlayer.currentPlaybackRate = speed
        }
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1 / Double(stepPerSecond) / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        // make sure the timer is not interfered by scrollview scrolling
        NSRunLoop.mainRunLoop().addTimer(updateTimer, forMode: NSRunLoopCommonModes)
    }
    
    func stopUpdateTimer() {
        if updateTimer == nil {
            return
        }
        updateTimer.invalidate()
        updateTimer = nil
    }
    
    func startCountdown() {
        countDownStartSecond--
        countdownView.setNumber(countDownStartSecond)
        if countDownStartSecond <= 0 {
            progressBlockContainer.addGestureRecognizer(tapGesture)
            countdownView.hidden = true
            countDownStartSecond = 3
            stopCountDownTimer()
            // animate up the soundwave
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.progressBlock!.alpha = 1.0
                if (self.defaultProgressBar != nil){
                    self.defaultProgressBar.alpha = 1
                }
                }, completion: { finished in
                    if self.isDemoSong {
                        self.avPlayer.play()
                    } else {
                        self.musicPlayer.play()
                    }
                    self.toTime = self.duration + 1
                    self.startUpdateTimer()
                }
            )
        }
    }
    
    func handleProgressPan(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            isPanning = true
            stopUpdateTimer()
        } else if sender.state == .Ended {
            isPanning = false
            startTime.setTime(Float(currentTime))
            if isDemoSong {
                avPlayer.currentTime = currentTime
                if avPlayer.playing {
                    startUpdateTimer()
                }
            } else {
                musicPlayer.currentPlaybackTime = currentTime
                if musicPlayer.playbackState == .Playing {
                    startUpdateTimer()
                }
            }
        } else if sender.state == .Changed {
            let translation = sender.translationInView(view)
            sender.view!.center = CGPointMake(sender.view!.center.x, sender.view!.center.y)
            sender.setTranslation(CGPointZero, inView: view)
            if currentTime >= -0.1 && currentTime <= duration + 0.1 {
                let timeChange = NSTimeInterval(-translation.x / 2)

                toTime = currentTime + timeChange
                if toTime < 0 {
                    toTime = 0
                } else if toTime > duration {
                    toTime = duration
                }
                currentTime = toTime
                startTime.setTime(Float(currentTime))
                let persent = CGFloat(currentTime) / CGFloat(duration)
                progressBlock.setProgress(persent)
                progressBlock.frame.origin.x = 0.5 * view.frame.size.width - persent * (CGFloat(theSong.getDuration() * Float(progressWidthMultiplier)))
                
                currentTimeLabel.text = TimeNumber(time: Float(currentTime)).toDisplayString()
                if(defaultProgressBar != nil){
                    defaultProgressBar.progress = 1 - Float(persent)
                }
            }
        }
    }

    func update() {
        if startTime.toDecimalNumer() > Float(duration) - 0.15 {
            if isDemoSong {
                avPlayer.pause()
            } else {
                musicPlayer.pause()
            }
            stopUpdateTimer()
            startTime.setTime(0)
            currentTime = 0
            progressBlock.alpha = 0.5
            if (defaultProgressBar != nil){
                defaultProgressBar.alpha = 0.5
            }
            
            if isDemoSong {
                avPlayer.currentTime = currentTime
            }else{
                musicPlayer.currentPlaybackTime = currentTime
            }
        }
        if !isPanning {
            let tempPlaytime = !isDemoSong ? musicPlayer.currentPlaybackTime : avPlayer.currentTime
            if startTime.toDecimalNumer() - Float(toTime) < (1 * speed ) && startTime.toDecimalNumer() - Float(toTime) >= 0 {
                startTime.addTime(Int(100 / stepPerSecond))
                currentTime = NSTimeInterval(startTime.toDecimalNumer())-0.01
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
                    currentTime = NSTimeInterval(startTime.toDecimalNumer())-0.01
                }
            }
        }
        if !isDemoSong {
            if(duration >= 1499 && !musicPlayer.nowPlayingItem!.playbackDuration.isNaN){
                duration = musicPlayer.nowPlayingItem!.playbackDuration
            }
        }
        refreshProgressBlock(currentTime)
        refreshTimeLabel(currentTime)
    }
  
    func refreshProgressBlock(time: NSTimeInterval){
        let newProgressPosition = (CGFloat(time) * progressWidthMultiplier) / progressBlock.frame.size.width
        let newOriginX = view.center.x - CGFloat(time) * progressWidthMultiplier
        
        if !isPanning {
            progressChangedOrigin = newOriginX
            progressBlock.setProgress(newProgressPosition)
        }
        progressBlock.frame.origin.x = newOriginX
        if(defaultProgressBar != nil){
            defaultProgressBar.progress = 1 - Float(newProgressPosition)
        }
    }

    func refreshTimeLabel(time: NSTimeInterval) {
        currentTimeLabel.text = TimeNumber(time: Float(time)).toDisplayString()
    }
}

// table view
extension LyricsSyncViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: Table view methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 4 / 31 * viewHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LyricsSyncTimeTableViewCell = lyricsTableView.dequeueReusableCellWithIdentifier("lyricsSyncCell") as! LyricsSyncTimeTableViewCell
        cell.initialTableViewCell(viewWidth, viewHeight: viewHeight)
        cell.backgroundColor = UIColor.clearColor()
        cell.lyricsSentenceLabel.backgroundColor = UIColor.clearColor()
        cell.lyricsSentenceLabel.textColor = UIColor.whiteColor()
        cell.currentTimeLabel.textColor = UIColor.whiteColor()
        
        if addedLyricsWithTime.timeAdded[indexPath.item] {
            cell.currentTimeLabel.text = TimeNumber(time: Float(addedLyricsWithTime.time[indexPath.item])).toDisplayString()
            cell.timeView.backgroundColor = UIColor.mainPinkColor()
        } else {
            cell.currentTimeLabel.text = "0:00.0"
            cell.timeView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        }
        
        cell.lyricsSentenceLabel.text = lyricsOrganizedArray[indexPath.item]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricsOrganizedArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 || addedLyricsWithTime.timeAdded[indexPath.item - 1]  {
            if addedLyricsWithTime.timeAdded[indexPath.item] == false {
                
                addedLyricsWithTime.time[indexPath.item] = currentTime
                addedLyricsWithTime.lyrics[indexPath.item] = lyricsOrganizedArray[indexPath.item]
                addedLyricsWithTime.timeAdded[indexPath.item] = true
                lyricsTableView.reloadData()
            }else {
                if isDemoSong {
                    avPlayer.currentTime = addedLyricsWithTime.time[indexPath.item]
                    if !avPlayer.playing {
                        playPause()
                    }
                } else {
                    musicPlayer.currentPlaybackTime = addedLyricsWithTime.time[indexPath.item]
                    if musicPlayer.playbackState == .Paused {
                        playPause()
                    }
                }
            }
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete && addedLyricsWithTime.timeAdded[indexPath.item] {
            // handle delete (by removing the data from your array and updating the tableview)
            var index = indexPath.row
            while addedLyricsWithTime.timeAdded[index] {
                addedLyricsWithTime.time[index] = 0
                //addedLyricsWithTime.timeTextStyle[index] = "0.0:0.0"
                addedLyricsWithTime.timeAdded[index] = false
                index++
                if index == addedLyricsWithTime.lyrics.count {
                    break
                }
            }
            lyricsTableView.reloadData()
            if indexPath.row == 0 {
                if isDemoSong {
                    avPlayer.currentTime = 0
                } else {
                    musicPlayer.currentPlaybackTime = 0
                }
            } else {
                if isDemoSong {
                    avPlayer.currentTime = addedLyricsWithTime.time[indexPath.item - 1]
                } else {
                    musicPlayer.currentPlaybackTime = addedLyricsWithTime.time[indexPath.item - 1]
                }
            }
        }
    }
}

// top view button reaction function 
extension LyricsSyncViewController {
    func pressSpeedUpButton(sender: UIButton) {
        if speedKey >= 1.3{
            return
        }
        speedKey += 0.1
        let stringSpeedKey = NSString(format: "%.1f", speedKey) as String
        let adjustedSpeed = Float(speedMatcher[stringSpeedKey]!)
        changeSpeed(adjustedSpeed)
    }
    
    func pressSpeedDownButton(sender: UIButton) {
        if speedKey <= 0.71 {
            return
        }
        speedKey -= 0.1
        let stringSpeedKey = NSString(format: "%.1f", speedKey) as String
        let adjustedSpeed = Float(speedMatcher[stringSpeedKey]!)
        
        changeSpeed(adjustedSpeed)
    }
    
    func changeSpeed(newSpeed: Float) {
        if isDemoSong  {
            if avPlayer.playing {
                avPlayer.rate = newSpeed
            }
        } else {
            if musicPlayer.playbackState == .Playing {
                musicPlayer.currentPlaybackRate = newSpeed
            }
        }
        speed = newSpeed
    }
    
    func pressBackButton(sender: UIButton) {
        removeNotification()
        if isDemoSong {
            avPlayer.pause()
        } else {
            musicPlayer.pause()
        }
        stopUpdateTimer()
        for i in 0..<addedLyricsWithTime.lyrics.count {
            if addedLyricsWithTime.timeAdded[i] == true {
                tempLyricsTimeTuple.append((addedLyricsWithTime.lyrics[i], addedLyricsWithTime.time[i]))
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pressDoneButton(sender: UIButton) {
        removeNotification()
        if isDemoSong {
            avPlayer.pause()
        } else {
            musicPlayer.pause()
        }
        stopUpdateTimer()
        var lyricsTimesTuple = [(String, NSTimeInterval)]()
        for i in 0..<addedLyricsWithTime.lyrics.count {
            lyricsTimesTuple.append((addedLyricsWithTime.lyrics[i], addedLyricsWithTime.time[i]))
        }
        var times = [Float]()
        for t in addedLyricsWithTime.time {
            times.append(Float(t))
        }
        //check if lyricsSet id is bigger than 0, if so, means this lyrics has been saved to the cloud, then we use same lyricsSetId, otherwise if less than one, it means it's new
        if lyricsTimesTuple.count < 3 {
            let alertController = UIAlertController(title: nil, message: "Please add at least THREE single lines into your lyric", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        let savedLyricsSetId = CoreDataManager.getLyrics(theSong, fetchingUsers: true).1
        CoreDataManager.saveLyrics(theSong, lyrics: addedLyricsWithTime.lyrics, times: times, userId: Int(CoreDataManager.getCurrentUser()!.id), lyricsSetId: savedLyricsSetId > 0 ? savedLyricsSetId: kLocalSetId ,lastEditedDate: NSDate())
        //TODO: add placeholder lyrics if lyrics.count is 2 or less
        APIManager.uploadLyrics(isDemoSong ? MusicManager.sharedInstance.demoSongs[0]: theSong , completion: {
            cloudId in
            CoreDataManager.saveCloudIdToLyrics(self.isDemoSong ? MusicManager.sharedInstance.demoSongs[0]: self.theSong, cloudId: cloudId)
        })
//        if let songVC = lyricsTextViewController.songViewController {
//            if songVC.singleLyricsTableView != nil {
//                songVC.updateSingleLyricsAlpha()
//                songVC.updateSingleLyricsPosition(false)
//            }
//        }
//        presentingViewController?.presentingViewController?.dismissViewControllerAnimated( true, completion: {
//            completed in
//            if let songVC = self.lyricsTextViewController.songViewController {
//                songVC.lyric = Lyric(lyricsTimesTuple: lyricsTimesTuple)
//                if songVC.singleLyricsTableView != nil {
//                    songVC.setUpLyricsArray()
//                    songVC.singleLyricsTableView.reloadData()
//                }
//                songVC.addLyricsPrompt.hidden = true
//                if songVC.isDemoSong {
//                    songVC.avPlayer.play()
//                } else {
//                    MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
//                    songVC.player.play()
//                }
//            }
//        })
    }
}

// read the exsit song's lyrics from coredata
extension LyricsSyncViewController {
    func addUnfinishedLyricsAndTime() {
        if lyricsOrganizedArray.count > 0 {
            var lyrics: [String] = [String]()
            var time: [NSTimeInterval] = [NSTimeInterval]()
            var timeAdded: [Bool] = [Bool]()
            for i in 0..<lyricsOrganizedArray.count {
                if i < tempLyricsTimeTuple.count {
                    lyrics.append(tempLyricsTimeTuple[i].0)
                    time.append(tempLyricsTimeTuple[i].1)
                    timeAdded.append(true)
                } else {
                    lyrics.append(lyricsOrganizedArray[i])
                    time.append(0)
                    timeAdded.append(false)
                }
            }
            addedLyricsWithTime.addExistLyrics(tempLyricsTimeTuple.count, lyrics: lyrics, time: time, timeAdded: timeAdded)
        }
        tempLyricsTimeTuple.removeAll()
    }
    
    func addLyricsToEditorView(sender: Findable) {
        var lyric = Lyric()
        (lyric, _) = CoreDataManager.getLyrics(sender, fetchingUsers: true)
        let count = lyric.lyric.count
        var i = 0
        if count > 0 && count <= lyricsOrganizedArray.count {
            var lyrics: [String] = [String]()
            var time: [NSTimeInterval] = [NSTimeInterval]()
            var timeAdded: [Bool] = [Bool]()
            for line in lyric.lyric {
                if line.str == lyricsOrganizedArray[i] {
                    lyrics.append(line.str)
                    time.append(NSTimeInterval(line.time.toDecimalNumer()))
                    timeAdded.append(true)
                    i++
                } else {
                    break
                }
            }
            for _ in i..<lyricsOrganizedArray.count {
                lyrics.append(lyricsOrganizedArray[i])
                time.append(addedLyricsWithTime.time[i])
                timeAdded.append(addedLyricsWithTime.timeAdded[i])
            }
            addedLyricsWithTime.addExistLyrics(count, lyrics: lyrics, time: time, timeAdded: timeAdded)
            
        }
        if i == 0 {
            i = 1 // if don't have the same line of lyrics, make the time equals to 0
        }
    }
}
