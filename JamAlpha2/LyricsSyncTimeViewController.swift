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
    
    var progressChangedOrigin: CGFloat!
    
    var lyricsFromTextView: String!
    
    var viewWidth = CGFloat()
    var viewHeight  = CGFloat()
    
    var theSong: Findable!
    
    var lyricsOrganizedArray: [String]!

    var avPlayer: AVAudioPlayer!
    var musicPlayer: MPMusicPlayerController!
    
    var updateTimer = NSTimer()
    
    // count down section
    var countdownTimer = NSTimer()
    var countDownStartSecond = 3 //will count down from 3 to 1
    var countdownView: CountdownView!
    
    
    var playButtonImageView: UIImageView = UIImageView()
    
    var defaultProgressBar:UIProgressView!
    
    // MARK: tutorial
    var tutorialImage: UIImageView!
    var tutorialCloseButton: UIButton!
    
    // MARK: UIGestures
    var addedLyricsWithTime: lyricsWithTime!
    
    let speedMatcher = ["0.7": 0.50, "0.8" :0.67 , "0.9": 0.79,  "1.0" :1.00 , "1.1": 1.25  , "1.2" :1.50, "1.3" : 2.00]
    var speedKey = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addedLyricsWithTime = lyricsWithTime(count: self.lyricsOrganizedArray.count)
        self.viewWidth = self.view.frame.width
        self.viewHeight = self.view.frame.height
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
            self.addLyricsToEditorView(theSong)
        }
        
        self.lyricsTableView.preservesSuperviewLayoutMargins = false
        self.lyricsTableView.separatorInset = UIEdgeInsetsZero
        self.lyricsTableView.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if (self.defaultProgressBar != nil) {
            self.defaultProgressBar.removeFromSuperview()
            self.defaultProgressBar = nil
        }
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
            if(!isPlaying){
                startUpdateTimer()
                isPlaying = true
            }
            playButtonImageView.hidden = true
            self.progressBlock.alpha = 1
            if (self.defaultProgressBar != nil){
                self.defaultProgressBar.alpha = 1
            }
        } else if musicPlayer.playbackState == .Paused {
            isPlaying = false
            playButtonImageView.hidden = false
            updateTimer.invalidate()
            updateTimer = NSTimer()
            self.progressBlock.alpha = 0.5
            if (self.defaultProgressBar != nil){
                self.defaultProgressBar.alpha = 0.5
            }
        }
    }
    
    func currentSongChanged(sender: NSNotification){
        if musicPlayer.playbackState == .Playing {
            musicPlayer.currentPlaybackRate = self.speed
        }
    }
    
    var duration: NSTimeInterval!
    // MARK: check theSong can convert to MPMediaItem
    
    func setUpPlayer() {
        if isDemoSong {
            avPlayer = AVAudioPlayer()

            self.duration = NSTimeInterval(MusicManager.sharedInstance.avPlayer.currentItem!.getDuration())
         
            let url: NSURL = theSong.getURL() as! NSURL
            self.avPlayer = try! AVAudioPlayer(contentsOfURL: url)
            
            self.avPlayer.currentTime = 0.0
            self.avPlayer.volume = 1
            self.avPlayer.enableRate = true
            self.avPlayer.rate = 1
            
        } else {
            musicPlayer = MusicManager.sharedInstance.player
            musicPlayer.currentPlaybackTime = 0.0
            registerNotification()
            self.duration = musicPlayer.nowPlayingItem?.playbackDuration
        }
    }

    
    func setUpHeaderView() {
        let titleView: UIView = UIView()
        titleView.frame = CGRectMake(0, 0, self.viewWidth, 20 + 44)
        titleView.backgroundColor = UIColor.mainPinkColor()
        self.view.addSubview(titleView)
        
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
            / 20 * self.viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
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
        speedUpButton.frame = CGRectMake(14 / 20 * self.viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        speedUpButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        speedUpButton.setImage(UIImage(named: "increase"), forState: UIControlState.Normal)
        speedUpButton.addTarget(self, action: "pressSpeedUpButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        titleView.addSubview(speedUpButton)
        
        let speedDownButton: UIButton = UIButton()
        speedDownButton.frame = CGRectMake(3 / 20 * self.viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        speedDownButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        speedDownButton.setImage(UIImage(named: "decrease"), forState: UIControlState.Normal)
        speedDownButton.addTarget(self, action: "pressSpeedDownButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(speedDownButton)
    }
    
    func setUpLyricsTableView() {
        let backgroundImageWidth: CGFloat = self.viewHeight - 64
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(self.viewWidth / 2 - backgroundImageWidth / 2, 64, backgroundImageWidth, backgroundImageWidth)
        let size: CGSize = CGSizeMake(self.viewWidth, self.viewHeight)
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
        
        self.lyricsTableView.frame = CGRectMake(0, 64, self.viewWidth, 24 / 31 * self.viewHeight)
        self.lyricsTableView.delegate = self
        self.lyricsTableView.dataSource = self
        self.lyricsTableView.registerClass(LyricsSyncTimeTableViewCell.self, forCellReuseIdentifier: "lyricsSyncCell")
        self.lyricsTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.lyricsTableView)
    }

    func setUpProgressBlock() {
        progressChangedOrigin = self.view.center.x
        progressBlockContainer = UIView(frame: CGRect(x: 0, y: viewHeight-progressContainerHeight, width: self.view.frame.width, height: progressContainerHeight))
        progressBlockContainer.backgroundColor = UIColor.clearColor()
        self.view.addSubview(progressBlockContainer)
        
        playButtonImageView.frame = CGRect(x: 0, y: self.view.frame.height - 50, width: 30, height: 30)
        playButtonImageView.center.x = self.view.center.x
        playButtonImageView.image = UIImage(named: "playbutton")
        self.view.addSubview(playButtonImageView)
        self.view.bringSubviewToFront(playButtonImageView)

        self.progressBlock = SoundWaveView(frame: CGRectMake(self.view.center.x, 0, CGFloat(theSong.getDuration()) * 2, soundwaveHeight))
        
        if let soundWaveData = CoreDataManager.getSongWaveFormImage(theSong) {
            progressBlock.setWaveFormFromData(soundWaveData)
        }else{
            self.setupDefaultProgressBar()
        }
        
        self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
        self.progressBlock!.alpha = 0.5
        if (self.defaultProgressBar != nil){
            self.defaultProgressBar.alpha = 0.5
        }
        progressBlockContainer.addSubview(self.progressBlock)
        
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
        
        totalTimeLabel.text = TimeNumber(time: Float(theSong.getDuration())).toDisplayString()
        totalTimeLabel.textAlignment = .Right
        self.view.addSubview(totalTimeLabel)
    }
    
    func setUpCountdownView() {
        countdownView = CountdownView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        countdownView.center = self.view.center
        countdownView.backgroundColor = UIColor.clearColor()
        countdownView.hidden = true
        self.view.addSubview(countdownView)
    }
    
    func setUpTutorial() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(kShowLyricsTutorial) {
            return
        }
        
        tutorialImage = UIImageView(frame: self.view.bounds)
        tutorialImage.image = UIImage(named: "lyrics_tutorial")
        self.view.addSubview(tutorialImage)
 
        tutorialCloseButton = UIButton(frame: CGRect(x: 20, y: 15, width: 30, height: 30))
        tutorialCloseButton.setImage(UIImage(named: "closebutton"), forState: .Normal)
        tutorialCloseButton.addTarget(self, action: "hideTutorial", forControlEvents: .TouchUpInside)
        self.view.addSubview(tutorialCloseButton)
    }
    
    func hideTutorial() {
        tutorialImage.hidden = true
        tutorialCloseButton.hidden = true
        
         NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShowLyricsTutorial)
    }
    
    var currentSelectIndex: Int = 0
    
    func playPause() {
        if self.isDemoSong ? !avPlayer.playing : (musicPlayer.playbackState != .Playing) {
            //start counting down 3 seconds
            //disable tap gesture that inadvertly starts timer
            self.isPlaying = true
            progressBlockContainer.removeGestureRecognizer(tapGesture)
            countdownView.hidden = false
            countdownView.setNumber(countDownStartSecond)
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)
            playButtonImageView.hidden = true
        } else {
            playButtonImageView.hidden = false
            
            self.isPlaying = false
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                self.progressBlock!.alpha = 0.5
                if (self.defaultProgressBar != nil){
                    self.defaultProgressBar.alpha = 0.5
                }
                }, completion: nil)
            if isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
            }
            self.updateTimer.invalidate()
           
        }
    }

    func startUpdateTimer() {

        if !updateTimer.valid {
            if(isDemoSong){
                self.avPlayer.rate = speed
            }else{
                self.musicPlayer.currentPlaybackRate = speed
            }
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(1 / Double(stepPerSecond) / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            
            // make sure the timer is not interfered by scrollview scrolling
            NSRunLoop.mainRunLoop().addTimer(updateTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func startCountdown() {
        countDownStartSecond--
        countdownView.setNumber(countDownStartSecond)

        if countDownStartSecond <= 0 {
            progressBlockContainer.addGestureRecognizer(tapGesture)
            countdownTimer.invalidate()
            countdownView.hidden = true
            countDownStartSecond = 3
            countdownTimer = NSTimer()
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
    
    var isPanning = false
    var toTime: NSTimeInterval = 0
    
    func handleProgressPan(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            self.isPanning = true
            self.updateTimer.invalidate()
            self.updateTimer = NSTimer()
        } else if sender.state == .Ended {
            self.isPanning = false
            startTime.setTime(Float(self.currentTime))
            if isDemoSong {
                self.avPlayer.currentTime = self.currentTime
                if self.avPlayer.playing {
                    startUpdateTimer()
                }
            } else {
                self.musicPlayer.currentPlaybackTime = self.currentTime
                if self.musicPlayer.playbackState == .Playing {
                    startUpdateTimer()
                }
            }
            
        } else if sender.state == .Changed {
            let translation = sender.translationInView(self.view)
            sender.view!.center = CGPointMake(sender.view!.center.x, sender.view!.center.y)
            sender.setTranslation(CGPointZero, inView: self.view)

            if self.currentTime >= -0.1 && self.currentTime <= self.duration + 0.1 {
                let timeChange = NSTimeInterval(-translation.x / 2)

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
                self.progressBlock.frame.origin.x = 0.5 * self.view.frame.size.width - persent * (CGFloat(theSong.getDuration() * Float(progressWidthMultiplier)))
                
                self.currentTimeLabel.text = TimeNumber(time: Float(self.currentTime)).toDisplayString()
                if(self.defaultProgressBar != nil){
                    self.defaultProgressBar.progress = 1 - Float(persent)
                }
            }
        }
    }

    func update() {
        if startTime.toDecimalNumer() > Float(self.duration) - 0.15 {
            if isDemoSong {
                self.avPlayer.pause()
            } else {
                self.musicPlayer.pause()
            }
            updateTimer.invalidate()
            updateTimer = NSTimer()
            startTime.setTime(0)
            self.currentTime = 0
            self.progressBlock.alpha = 0.5
            if (self.defaultProgressBar != nil){
                self.defaultProgressBar.alpha = 0.5
            }
            
            if isDemoSong {
                avPlayer.currentTime = currentTime
            }else{
                musicPlayer.currentPlaybackTime = currentTime
            }
        }
        if !isPanning {
            let tempPlaytime = !isDemoSong ? self.musicPlayer.currentPlaybackTime : self.avPlayer.currentTime
            if startTime.toDecimalNumer() - Float(self.toTime) < (1 * speed ) && startTime.toDecimalNumer() - Float(self.toTime) >= 0 {
                startTime.addTime(Int(100 / stepPerSecond))
                self.currentTime = NSTimeInterval(startTime.toDecimalNumer())-0.01
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
                    self.currentTime = NSTimeInterval(startTime.toDecimalNumer())-0.01
                }
            }
        }
        
        refreshProgressBlock(currentTime)
        refreshTimeLabel(currentTime)
    }
  
    func refreshProgressBlock(time: NSTimeInterval){
        let newProgressPosition = (CGFloat(time) * progressWidthMultiplier) / self.progressBlock.frame.size.width
        let newOriginX = self.view.center.x - CGFloat(time) * progressWidthMultiplier
        
        if !isPanning {
            self.progressChangedOrigin = newOriginX
            self.progressBlock.setProgress(newProgressPosition)
        }
        self.progressBlock.frame.origin.x = newOriginX
        if(self.defaultProgressBar != nil){
            self.defaultProgressBar.progress = 1 - Float(newProgressPosition)
        }
    }

    func refreshTimeLabel(time: NSTimeInterval) {
        self.currentTimeLabel.text = TimeNumber(time: Float(time)).toDisplayString()
    }
}

// table view
extension LyricsSyncViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: Table view methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LyricsSyncTimeTableViewCell = self.lyricsTableView.dequeueReusableCellWithIdentifier("lyricsSyncCell") as! LyricsSyncTimeTableViewCell
        
        cell.initialTableViewCell(self.viewWidth, viewHeight: self.viewHeight)
        cell.backgroundColor = UIColor.clearColor()
        cell.lyricsSentenceLabel.backgroundColor = UIColor.clearColor()
        cell.lyricsSentenceLabel.textColor = UIColor.whiteColor()
        cell.currentTimeLabel.textColor = UIColor.whiteColor()
        
        if self.addedLyricsWithTime.timeAdded[indexPath.item] {
            cell.currentTimeLabel.text = TimeNumber(time: Float(addedLyricsWithTime.time[indexPath.item])).toDisplayString()
            cell.timeView.backgroundColor = UIColor.mainPinkColor()
        } else {
            cell.currentTimeLabel.text = "0:00.0"
            cell.timeView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        }
        
        cell.lyricsSentenceLabel.text = self.lyricsOrganizedArray[indexPath.item]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lyricsOrganizedArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 || addedLyricsWithTime.timeAdded[indexPath.item - 1]  {
            if self.addedLyricsWithTime.timeAdded[indexPath.item] == false {
                
                self.addedLyricsWithTime.time[indexPath.item] = self.currentTime
                self.addedLyricsWithTime.lyrics[indexPath.item] = lyricsOrganizedArray[indexPath.item]
                self.addedLyricsWithTime.timeAdded[indexPath.item] = true
                lyricsTableView.reloadData()
            }else {
                if isDemoSong {
                    avPlayer.currentTime = self.addedLyricsWithTime.time[indexPath.item]
                    if !avPlayer.playing {
                        playPause()
                    }
                } else {
                    musicPlayer.currentPlaybackTime = self.addedLyricsWithTime.time[indexPath.item]
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
        if editingStyle == UITableViewCellEditingStyle.Delete && self.addedLyricsWithTime.timeAdded[indexPath.item] {
            // handle delete (by removing the data from your array and updating the tableview)
            var index = indexPath.row
            while self.addedLyricsWithTime.timeAdded[index] {
                self.addedLyricsWithTime.time[index] = 0
                //self.addedLyricsWithTime.timeTextStyle[index] = "0.0:0.0"
                self.addedLyricsWithTime.timeAdded[index] = false
                index++
                if index == self.addedLyricsWithTime.lyrics.count {
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
                    avPlayer.currentTime = self.addedLyricsWithTime.time[indexPath.item - 1]
                } else {
                    musicPlayer.currentPlaybackTime = self.addedLyricsWithTime.time[indexPath.item - 1]
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
        self.speed = newSpeed
    }
    
    func pressBackButton(sender: UIButton) {
        removeNotification()
        if isDemoSong {
            avPlayer.pause()
        } else {
            musicPlayer.pause()
        }
        updateTimer.invalidate()
        updateTimer = NSTimer()
        for i in 0..<self.addedLyricsWithTime.lyrics.count {
            if self.addedLyricsWithTime.timeAdded[i] == true {
                tempLyricsTimeTuple.append((self.addedLyricsWithTime.lyrics[i], self.addedLyricsWithTime.time[i]))
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pressDoneButton(sender: UIButton) {
        removeNotification()
        if isDemoSong {
            avPlayer.pause()
        } else {
            musicPlayer.pause()
        }
        updateTimer.invalidate()
        updateTimer = NSTimer()
        var lyricsTimesTuple = [(String, NSTimeInterval)]()
        
        for i in 0..<self.addedLyricsWithTime.lyrics.count {
            lyricsTimesTuple.append((self.addedLyricsWithTime.lyrics[i], self.addedLyricsWithTime.time[i]))
        }
        
        var times = [Float]()
        for t in addedLyricsWithTime.time {
            times.append(Float(t))
        }
        
        //check if lyricsSet id is bigger than 0, if so, means this lyrics has been saved to the cloud, then we use same lyricsSetId, otherwise if less than one, it means it's new
        
        if (lyricsTimesTuple.count < 3) {
            let alertController = UIAlertController(title: nil, message: "Please add at least THREE single lines into your lyric", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }

        
        let savedLyricsSetId = CoreDataManager.getLyrics(theSong, fetchingUsers: true).1
        
        CoreDataManager.saveLyrics(theSong, lyrics: addedLyricsWithTime.lyrics, times: times, userId: Int(CoreDataManager.getCurrentUser()!.id), lyricsSetId: savedLyricsSetId > 0 ? savedLyricsSetId: kLocalSetId ,lastEditedDate: NSDate())
        
        //TODO: add placeholder lyrics if lyrics.count is 2 or less
        APIManager.uploadLyrics(isDemoSong ? MusicManager.sharedInstance.demoSongs[0]: theSong , completion: {
            cloudId in
            
            CoreDataManager.saveCloudIdToLyrics(self.isDemoSong ? MusicManager.sharedInstance.demoSongs[0]: self.theSong, cloudId: cloudId)
        })
        if let songVC = self.lyricsTextViewController.songViewController {
            if songVC.singleLyricsTableView != nil {
                songVC.updateSingleLyricsAlpha()
                songVC.updateSingleLyricsPosition(false)
            }
        }
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated( true, completion: {
            
            completed in
            
            if let songVC = self.lyricsTextViewController.songViewController {
                songVC.lyric = Lyric(lyricsTimesTuple: lyricsTimesTuple)
                if songVC.singleLyricsTableView != nil {
                    songVC.setUpLyricsArray()
                    songVC.singleLyricsTableView.reloadData()
                }
                songVC.addLyricsPrompt.hidden = true
                if songVC.isDemoSong {
                    songVC.avPlayer.play()
                } else {
                    MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                    songVC.player.play()
                }
            }
        })
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
            
            self.addedLyricsWithTime.addExistLyrics(tempLyricsTimeTuple.count, lyrics: lyrics, time: time, timeAdded: timeAdded)
        }
        tempLyricsTimeTuple.removeAll()
    }
    
    func addLyricsToEditorView(sender: Findable) {
        
        var lyric = Lyric()
        (lyric, _) = CoreDataManager.getLyrics(sender, fetchingUsers: true)
     
        let count = lyric.lyric.count
        var i = 0
        if count > 0 && count <= self.lyricsOrganizedArray.count {
            var lyrics: [String] = [String]()
            var time: [NSTimeInterval] = [NSTimeInterval]()
            var timeAdded: [Bool] = [Bool]()
            for line in lyric.lyric {
                if line.str == self.lyricsOrganizedArray[i] {
                    lyrics.append(line.str)
                    time.append(NSTimeInterval(line.time.toDecimalNumer()))
                    timeAdded.append(true)
                    i++
                } else {
                    break
                }
            }
            for _ in i..<self.lyricsOrganizedArray.count {
                lyrics.append(self.lyricsOrganizedArray[i])
                time.append(self.addedLyricsWithTime.time[i])
                timeAdded.append(self.addedLyricsWithTime.timeAdded[i])
            }
            self.addedLyricsWithTime.addExistLyrics(count, lyrics: lyrics, time: time, timeAdded: timeAdded)
            
        }
        if i == 0 {
            i = 1 // if don't have the same line of lyrics, make the time equals to 0
        }
    }
}
