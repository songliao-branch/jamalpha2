//
//  iTunesPreview.swift
//  JamAlpha2
//
//  Created by Song Liao on 2/1/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

extension SongViewController {
    
    func initPurchaseItunsSongItem(){
        setUpPreviewButton()
        setUpPreviewActionView()
    }
    
    func setUpPreviewButton(){
        playPreveiwButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width/2-35,UIScreen.mainScreen().bounds.size.height-bottomViewHeight-90,70,70))
        playPreveiwButton.setImage((UIImage(named: "playbutton")), forState: UIControlState.Normal)
        playPreveiwButton.addTarget(self, action: "showPreviewActionView", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(playPreveiwButton)
        let url: NSURL = NSURL(string: songNeedPurchase.previewUrl)!
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
      self.dismissAction()
      let suffix = "&app=itunes&at=1001l9DT"
      UIApplication.sharedApplication().openURL(NSURL(string:songNeedPurchase.trackViewUrl + suffix)!)
    }
    
    func goToAppleMusic(){
        self.dismissAction()
        UIApplication.sharedApplication().openURL(NSURL(string: songNeedPurchase.trackViewUrl)!)
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

}