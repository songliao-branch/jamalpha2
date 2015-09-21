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

class LyricsSyncViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct lyricsWithTime {
        var count: Int!
        var lyrics: [String]!
        var time: [NSTimeInterval]!
        var timeTextStyle: [String]!
        var addedTime: [Bool]!
        
        init(count: Int) {
            self.count = count
            self.lyrics = [String](count: count, repeatedValue: "")
            self.time = [NSTimeInterval](count: count, repeatedValue: 0)
            self.addedTime = [Bool](count: count, repeatedValue: false)
            self.timeTextStyle = [String](count: count, repeatedValue: "0.0:0.0")
        }
    }
    
    var lyricsTableView: UITableView = UITableView()
    
    var lyricsFromTextView: String!
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var theSong: MPMediaItem!
    
    var lyricsOrganizedArray: [String]!
    
    var progressBlock: SoundWaveView!
    var currentTime: NSTimeInterval = NSTimeInterval()
    var player: AVAudioPlayer = AVAudioPlayer()
    var duration: NSTimeInterval = NSTimeInterval()
    
    var timer = NSTimer()
    
    var addedLyricsWithTime: lyricsWithTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.viewWidth = self.view.frame.width
        self.viewHeight = self.view.frame.height
        addObjectsOnMainView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func addObjectsOnMainView() {
        addTitleView()
        initialLyricsTableView()
        createSoundWave()
        self.view.addSubview(self.progressBlock)
        self.addedLyricsWithTime = lyricsWithTime(count: self.lyricsOrganizedArray.count)
        addTimeLabelOnProgressBlock()
    }
    
    func initialLyricsTableView() {
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
        self.lyricsTableView.registerClass(LyricsSyncTimeTableViewCell.self, forCellReuseIdentifier: "cell")
        self.lyricsTableView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(self.lyricsTableView)
    }
    
    func addTitleView() {
        let titleView: UIView = UIView()
        titleView.frame = CGRectMake(0, 0, self.viewWidth, 3.5 / 31 * self.viewHeight)
        titleView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        self.view.addSubview(titleView)
        
        let buttonWidth: CGFloat = 2.5 / 20 * self.viewWidth
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        backButton.setTitle("B", forState: UIControlState.Normal)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.layer.borderWidth = 1
        titleView.addSubview(backButton)
        
        let doneButton: UIButton = UIButton()
        doneButton.frame = CGRectMake(17.5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        doneButton.setTitle("D", forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.layer.borderWidth = 1
        titleView.addSubview(doneButton)
        
        let titleLabel: UILabel = UILabel()
        titleLabel.frame = CGRectMake(5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, 10 / 20 * self.viewWidth, 2 / 31 * self.viewHeight)
        titleLabel.text = "sync lyrics"
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.layer.borderWidth = 1
        titleLabel.textColor = UIColor.whiteColor()
        titleView.addSubview(titleLabel)
    }
    
    var currentTimeLabel: UILabel = UILabel()
    var totalTimeLabel: UILabel = UILabel()
    
    func addTimeLabelOnProgressBlock() {
        self.currentTimeLabel.frame = CGRectMake(0.5 * self.viewWidth - 2.5 / 20 * self.viewWidth, 29 / 31 * self.viewHeight, 2.5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight)
        self.totalTimeLabel.frame = CGRectMake(0.5 * self.viewWidth, 29 / 31 * self.viewHeight, 2.5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight)
        
        self.currentTimeLabel.layer.cornerRadius = 2
        self.totalTimeLabel.layer.cornerRadius = 2
        
        self.currentTimeLabel.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        self.totalTimeLabel.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        
        self.currentTimeLabel.textAlignment = NSTextAlignment.Center
        self.totalTimeLabel.textAlignment = NSTextAlignment.Center
        
        let minutesD = floor(self.duration / 60)
        let secondsD = round(self.duration - minutesD * 60)
        
        self.currentTimeLabel.text = "00:00"
        self.totalTimeLabel.text = "\(minutesD):\(secondsD)"
        
        self.currentTimeLabel.font = UIFont.systemFontOfSize(10)
        self.totalTimeLabel.font = UIFont.systemFontOfSize(10)
        
        let blackLine: UIView = UIView()
        blackLine.frame = CGRectMake(0.5 * self.viewWidth - 1, 28 / 31 * self.viewHeight, 2, 4 / 31 * self.viewHeight)
        blackLine.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(blackLine)
        self.view.addSubview(self.currentTimeLabel)
        self.view.addSubview(self.totalTimeLabel)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 4 / 31 * self.viewHeight
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LyricsSyncTimeTableViewCell = self.lyricsTableView.dequeueReusableCellWithIdentifier("cell") as! LyricsSyncTimeTableViewCell
        
        cell.initialTableViewCell(self.viewWidth, viewHeight: self.viewHeight)
        cell.backgroundColor = UIColor.clearColor()
        cell.lyricsSentenceLabel.backgroundColor = UIColor.clearColor()
        cell.lyricsSentenceLabel.textColor = UIColor.whiteColor()
        cell.currentTimeLabel.textColor = UIColor.whiteColor()
        
        if self.addedLyricsWithTime.addedTime[indexPath.item] == true {
            cell.timeView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        } else {
            cell.timeView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        }
        
        cell.lyricsSentenceLabel.text = self.lyricsOrganizedArray[indexPath.item]
        cell.currentTimeLabel.text = self.addedLyricsWithTime.timeTextStyle[indexPath.item]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lyricsOrganizedArray.count
    }
    
    var currentSelectIndex: Int = 0
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected \(lyricsOrganizedArray[indexPath.item])")
        if indexPath.row == 0 || addedLyricsWithTime.addedTime[indexPath.item - 1] == true {
            if self.addedLyricsWithTime.addedTime[indexPath.item] == false {
                let time = self.currentTime
                self.addedLyricsWithTime.time[indexPath.item] = time
                self.addedLyricsWithTime.lyrics[indexPath.item] = lyricsOrganizedArray[indexPath.item]
                self.addedLyricsWithTime.addedTime[indexPath.item] = true
                let minutesC = floor(self.currentTime / 60)
                let secondsC = round(self.currentTime - minutesC * 60)
                self.addedLyricsWithTime.timeTextStyle[indexPath.item] = "\(minutesC):\(secondsC)"
                lyricsTableView.reloadData()
            }else {
                player.currentTime = self.addedLyricsWithTime.time[indexPath.item]
                self.currentTime = player.currentTime
            }
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete && self.addedLyricsWithTime.addedTime[indexPath.item] == true {
            // handle delete (by removing the data from your array and updating the tableview)
            var index = indexPath.row
            while self.addedLyricsWithTime.addedTime[index] == true{
                self.addedLyricsWithTime.time[index] = 0
                self.addedLyricsWithTime.timeTextStyle[index] = "0.0:0.0"
                self.addedLyricsWithTime.addedTime[index] = false
                index++
                if index == self.addedLyricsWithTime.lyrics.count {
                    break
                }
            }
            lyricsTableView.reloadData()
            if indexPath.row == 0 {
                player.currentTime = NSTimeInterval(0)
                self.currentTime = 0
            } else {
                player.currentTime = self.addedLyricsWithTime.time[indexPath.item - 1]
                self.currentTime = player.currentTime
            }
        }
    }
    
    func pressBackButton(sender: AnyObject) {
        self.player.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pressDoneButton(sender: UIButton) {
        
    }
    
    func createSoundWave() {
        //var songCollection = MPMediaQuery.songsQuery()
        let frame = CGRectMake(0.5 * self.viewWidth, 27.5 / 31 * self.viewHeight, 4 * self.viewWidth, 7 / 31 * self.viewHeight)
        self.progressBlock = SoundWaveView(frame: frame)
        let url: NSURL = self.theSong.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        self.player = try! AVAudioPlayer(contentsOfURL: url)
        self.duration = self.player.duration
        self.currentTime = 0
        self.player.volume = 1
        self.progressBlock.SetSoundURL(url)
        
        let tapOnProgress: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnProgress.addTarget(self, action: "tapOnProgressBlock:")
        self.progressBlock.addGestureRecognizer(tapOnProgress)
    }
    
    var duringCountDown: Bool = false
    var countDownImageView: UIImageView = UIImageView()
    var countDownNumberImageView: UIImageView = UIImageView()
    var countDownNumber: Float = Float()
    
    func tapOnProgressBlock(sender: UITapGestureRecognizer) {
        if self.player.playing == false && self.duringCountDown == false {
            self.duringCountDown = true
            let imageWidth: CGFloat = 5 / 20 * self.viewHeight
            self.countDownImageView.frame = CGRectMake(0.5 * self.viewWidth - imageWidth / 2, 0.5 * self.viewHeight - imageWidth / 2, imageWidth, imageWidth)
            self.countDownImageView.image = UIImage(named: "countdown-timer")
            self.countDownNumberImageView.frame = CGRectMake(0, 0, imageWidth, imageWidth)
            self.countDownNumberImageView.image = UIImage(named: "countdown-timer-3")
            self.countDownImageView.addSubview(countDownNumberImageView)
            self.view.addSubview(countDownImageView)
            self.currentTime = player.currentTime
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
            
        } else if self.duringCountDown == false {
            self.player.pause()
            self.timer.invalidate()
            self.timer = NSTimer()
            self.countDownNumber = 0
        }
    }
    
    func update() {
        if self.countDownNumber > 3.0 {
            let minutesC = floor(self.currentTime / 60)
            let secondsC = round(self.currentTime - minutesC * 60)
            self.currentTimeLabel.text = "\(minutesC):\(secondsC)"
            self.duringCountDown = false
            self.currentTime = self.player.currentTime
            let persent = CGFloat(self.currentTime / self.duration)
            self.progressBlock.setProgress(persent)
            self.progressBlock.frame = CGRectMake(0.5 * self.viewWidth - persent * (4 * self.viewWidth), 27.5 / 31 * self.viewHeight, self.progressBlock.frame.width, self.progressBlock.frame.height)
            if self.player.playing == false {
                self.timer.invalidate()
                self.timer = NSTimer()
            }
        } else if self.countDownNumber <= 0.9 {
            self.countDownNumber = self.countDownNumber + 0.1
        } else if self.countDownNumber > 0.9 && self.countDownNumber <= 1.9 {
            self.countDownNumberImageView.image = UIImage(named: "countdown-timer-2")
            self.countDownNumber = self.countDownNumber + 0.1
        } else if self.countDownNumber > 1.9 && self.countDownNumber <= 2.9 {
            self.countDownNumberImageView.image = UIImage(named: "countdown-timer-1")
            self.countDownNumber = self.countDownNumber + 0.1
        } else if self.countDownNumber > 2.9 && self.countDownNumber <= 3.0 {
            self.countDownImageView.removeFromSuperview()
            self.countDownNumberImageView.removeFromSuperview()
            self.countDownNumber++
            self.player.play()
        }
        
    }

}
