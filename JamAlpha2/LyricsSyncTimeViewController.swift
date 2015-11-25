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

class LyricsSyncViewController: UIViewController  {

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
    
    var theSong: MPMediaItem!
    
    var lyricsOrganizedArray: [String]!

    var player = AVAudioPlayer()
    var updateTimer = NSTimer()
    let updateInterval: NSTimeInterval = 0.1
    var playingSpeed: Float = 1
    
    // count down section
    var countdownTimer = NSTimer()
    var countDownStartSecond = 3 //will count down from 3 to 1
    var countdownView: CountdownView!
    
    // MARK: UIGestures
    var addedLyricsWithTime: lyricsWithTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addedLyricsWithTime = lyricsWithTime(count: self.lyricsOrganizedArray.count)
        self.viewWidth = self.view.frame.width
        self.viewHeight = self.view.frame.height
        //self.addLyricsToEditorView(theSong)
        setUpSong()
        setUpHeaderView()
        setUpLyricsTableView()
        setUpProgressBlock()
        setUpTimeLabels()
        setUpCountdownView()
        if tempLyricsTimeTuple.count > 0 {
            addUnfinishedLyrivsAndTime()
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
    
    // MARK: set up views
    func setUpSong() {
        let url: NSURL = theSong.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        self.player = try! AVAudioPlayer(contentsOfURL: url)
        self.player.volume = 1
        self.player.enableRate = true
        self.player.rate = self.playingSpeed
    }
    
    func setUpHeaderView() {
        let titleView: UIView = UIView()
        titleView.frame = CGRectMake(0, 0, self.viewWidth, 3.5 / 31 * self.viewHeight)
        titleView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        self.view.addSubview(titleView)
        
        let buttonWidth: CGFloat = 2.0 / 20 * self.viewWidth
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0.5 / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        backButton.setTitle("B", forState: UIControlState.Normal)
        backButton.setImage(UIImage(named: "lyrics_back_circle"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(backButton)
        
        let doneButton: UIButton = UIButton()
        doneButton.frame = CGRectMake(17.5
            / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        doneButton.setTitle("D", forState: UIControlState.Normal)
        doneButton.setImage(UIImage(named: "lyrics_done_circle"), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(doneButton)
        
        let titleLabel: UIImageView = UIImageView()
        titleLabel.frame = CGRectMake(6.5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, 7 / 20 * self.viewWidth, 2 / 31 * self.viewHeight)
        titleLabel.image = UIImage(named: "sync-lyrics")
        titleView.addSubview(titleLabel)
        
        let speedUpButton: UIButton = UIButton()
        speedUpButton.frame = CGRectMake(15 / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        speedUpButton.setTitle("U", forState: UIControlState.Normal)
        //speedUpButton.setImage(UIImage(named: "lyrics_back_circle"), forState: UIControlState.Normal)
        speedUpButton.addTarget(self, action: "pressSpeedUpButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(speedUpButton)
        
        
        let speedDownButton: UIButton = UIButton()
        speedDownButton.frame = CGRectMake(3 / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        speedDownButton.setTitle("D", forState: UIControlState.Normal)
        //speedDownButton.setImage(UIImage(named: "lyrics_back_circle"), forState: UIControlState.Normal)
        speedDownButton.addTarget(self, action: "pressSpeedDownButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(speedDownButton)
    }
    
    func setUpLyricsTableView() {
        let backgroundImageWidth: CGFloat = self.viewHeight - 3.5 / 31 * self.viewHeight
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(self.viewWidth / 2 - backgroundImageWidth / 2, 3.5 / 31 * self.viewHeight, backgroundImageWidth, backgroundImageWidth)
        let size: CGSize = CGSizeMake(self.viewWidth, self.viewHeight)
        backgroundImage.image = theSong.artwork!.imageWithSize(size)
        let blurredImage:UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        self.view.addSubview(backgroundImage)
        
        self.lyricsTableView.frame = CGRectMake(0, 3.5 / 31 * self.viewHeight, self.viewWidth, 24 / 31 * self.viewHeight)
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

        self.progressBlock = SoundWaveView(frame: CGRectMake(self.view.center.x, 0, CGFloat(theSong.playbackDuration) * 2, soundwaveHeight))
        
        if let soundWaveData = CoreDataManager.getSongWaveFormImage(theSong) {
            progressBlock.setWaveFormFromData(soundWaveData)
        }
        
        self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
        self.progressBlock!.alpha = 0.5
        progressBlockContainer.addSubview(self.progressBlock)
        
        tapGesture = UITapGestureRecognizer(target: self, action: "playPause:")
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
        
        totalTimeLabel.text = TimeNumber(time: Float(theSong.playbackDuration)).toDisplayString()
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
    
    var currentSelectIndex: Int = 0
    
    func playPause(sender: UITapGestureRecognizer) {
        if !self.player.playing {
            //start counting down 3 seconds
            //disable tap gesture that inadvertly starts timer
            progressBlockContainer.removeGestureRecognizer(tapGesture)
            countdownView.hidden = false
            countdownView.setNumber(countDownStartSecond)
            countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "startCountdown", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(countdownTimer, forMode: NSRunLoopCommonModes)

        } else {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
                self.progressBlock!.alpha = 0.5
                }, completion: nil)
            self.player.pause()
            self.updateTimer.invalidate()
           
        }
    }

    func startUpdateTimer() {
        if !updateTimer.valid {
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            
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
            player.play()
            startUpdateTimer()
            
            // animate up the soundwave
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.2)
                self.progressBlock!.alpha = 1.0
                }, completion: { finished in
                    
                    UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.progressBlock!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                        }, completion: nil)
                    
            })

        }
    }
    var isPanning = false
    
    func handleProgressPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        for childview in recognizer.view!.subviews {
            let child = childview
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
            updateTimer.invalidate()
            let toTime = Float(newPosition - self.view.frame.width / 2) / -(Float(progressWidthMultiplier))
            self.progressBlock.setProgress(CGFloat(toTime)/CGFloat(player.duration))
            
            refreshTimeLabel(NSTimeInterval(toTime))
            refreshProgressBlock(NSTimeInterval(toTime))

            //when finger is lifted
            if recognizer.state == UIGestureRecognizerState.Ended {
                progressChangedOrigin = newPosition
                isPanning = false
                
                player.currentTime = NSTimeInterval(toTime)
                if player.playing {
                    startUpdateTimer()
                }
            }
        }
    }

    func update() {
        refreshProgressBlock(player.currentTime)
        refreshTimeLabel(player.currentTime)
    }
  
    func refreshProgressBlock(time: NSTimeInterval){
        let newProgressPosition = (CGFloat(time) * progressWidthMultiplier) / self.progressBlock.frame.size.width
        let newOriginX = self.view.center.x - CGFloat(time) * progressWidthMultiplier
        
        if !isPanning {
            self.progressChangedOrigin = newOriginX
            self.progressBlock.setProgress(newProgressPosition)
        }
        self.progressBlock.frame.origin.x = newOriginX
    }

    func refreshTimeLabel(time: NSTimeInterval) {
        self.currentTimeLabel.text = TimeNumber(time: Float(time)).toDisplayString()
    }
}

// table view
extension LyricsSyncViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: Table view methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 4 / 31 * self.viewHeight
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
        
        if indexPath.row == 0 || (addedLyricsWithTime.timeAdded[indexPath.item - 1] && addedLyricsWithTime.time[indexPath.item - 1] < self.player.currentTime) == true {
            if self.addedLyricsWithTime.timeAdded[indexPath.item] == false {
                
                self.addedLyricsWithTime.time[indexPath.item] = player.currentTime
                self.addedLyricsWithTime.lyrics[indexPath.item] = lyricsOrganizedArray[indexPath.item]
                self.addedLyricsWithTime.timeAdded[indexPath.item] = true
                lyricsTableView.reloadData()
            }else {
                player.currentTime = self.addedLyricsWithTime.time[indexPath.item]
                //  self.currentTime = player.currentTime
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
                player.currentTime = 0
                //  self.currentTime = 0
            } else {
                player.currentTime = self.addedLyricsWithTime.time[indexPath.item - 1]
                // self.currentTime = player.currentTime
            }
        }
    }
}

// top view button reaction function 
extension LyricsSyncViewController {
    
    func pressSpeedUpButton(sender: UIButton) {
        if self.playingSpeed < 1.95 {
            self.playingSpeed = self.playingSpeed + 0.15
            self.player.rate = self.playingSpeed
        }
    }
    
    func pressSpeedDownButton(sender: UIButton) {
        if self.playingSpeed > 0.55 {
            self.playingSpeed = self.playingSpeed - 0.15
            self.player.rate = self.playingSpeed
        }
    }
    
    func pressBackButton(sender: UIButton) {
        self.player.stop()
        for i in 0..<self.addedLyricsWithTime.lyrics.count {
            if self.addedLyricsWithTime.timeAdded[i] == true {
                tempLyricsTimeTuple.append((self.addedLyricsWithTime.lyrics[i], self.addedLyricsWithTime.time[i]))
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pressDoneButton(sender: UIButton) {
        var lyricsTimesTuple = [(String, NSTimeInterval)]()
        for i in 0..<self.addedLyricsWithTime.lyrics.count {
            lyricsTimesTuple.append((self.addedLyricsWithTime.lyrics[i], self.addedLyricsWithTime.time[i]))
        }
        
        self.lyricsTextViewController.songViewController.lyric = Lyric(lyricsTimesTuple: lyricsTimesTuple)
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        CoreDataManager.saveLyrics(theSong, lyrics: addedLyricsWithTime.lyrics, times: addedLyricsWithTime.time)
    }
}

// read the exsit song's lyrics from coredata
extension LyricsSyncViewController {
    
    func addUnfinishedLyrivsAndTime() {
        if lyricsOrganizedArray.count > 0 {
            var lyrics: [String] = [String]()
            var time: [NSTimeInterval] = [NSTimeInterval]()
            var timeAdded: [Bool] = [Bool]()
            for var i = 0; i < lyricsOrganizedArray.count; i++ {
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
    
    func addLyricsToEditorView(sender: MPMediaItem) {
        let lyricsWithTime = CoreDataManager.getLyrics(sender)
        let count = lyricsWithTime.count
        if count > 0 {
            var lyrics: [String] = [String]()
            var time: [NSTimeInterval] = [NSTimeInterval]()
            var timeAdded: [Bool] = [Bool]()
            for item in lyricsWithTime {
                lyrics.append(item.0)
                time.append(item.1)
                timeAdded.append(true)
            }
            self.addedLyricsWithTime.addExistLyrics(count, lyrics: lyrics, time: time, timeAdded: timeAdded)
        }
    }
}
