//
//  ActionSheet.swift
//  JamAlpha2
//
//  Created by Song Liao on 2/1/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

extension SongViewController {
    
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
        if isChordShown {
            releaseSingleLyricsView()
            if self.isTabsShown && self.isLyricsShown {
                self.lyricbase.hidden = false
            }
        }
        toggleChordsDisplayMode()
    }
    
    func tabsModeChanged() {
        isTabsShown = tabsSwitch.on
        isChordShown = chordsSwitch.on
        lyricsSwitch.on = !lyricsSwitch.on
        isLyricsShown = lyricsSwitch.on
        if isLyricsShown == false {
            releaseSingleLyricsView()
        }
        if isChordShown {
            releaseSingleLyricsView()
            if self.isTabsShown && self.isLyricsShown {
                self.lyricbase.hidden = false
            }
        }
        toggleLyrics()
    }
    
    func tabsSwitchChanged(uiswitch: UISwitch) {
        isTabsShown = uiswitch.on
        if isTabsShown {
            releaseSingleLyricsView()
            if self.isChordShown && self.isLyricsShown {
                self.lyricbase.hidden = false
            }
        }
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
        self.chordBaseAnimation()
        
        if isChordShown == false && isTabsShown == false && isLyricsShown {
            lyricbase.hidden = true
            setUpSingleLyricsView()
            
        }
        
        dispatch_async(dispatch_get_main_queue()){
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
        
        applyEffectsToBackgroundImage(changeSong: false)
    }
    
    func lyricsSwitchChanged(uiswitch: UISwitch) {
        isLyricsShown = uiswitch.on
        if isLyricsShown == false {
            releaseSingleLyricsView()
        }
        toggleLyrics()
    }
    
    func lyricsModeChanged() {
        lyricsSwitch.on = !lyricsSwitch.on
        isLyricsShown = lyricsSwitch.on
        if isLyricsShown == false {
            releaseSingleLyricsView()
        }
        toggleLyrics()
    }
    
    func toggleLyrics() {
        // show lyrics if the boolean is not hidden
        if isLyricsShown {
            lyricbase.hidden = false
        } else {
            lyricbase.hidden = true
        }
        
        self.chordBaseAnimation()
        
        if isChordShown == false && isTabsShown == false && isLyricsShown {
            lyricbase.hidden = true
            setUpSingleLyricsView()
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
    
    func chordBaseAnimation(){
        if ((isChordShown || isTabsShown) && !isLyricsShown) {
            if (self.chordBase.frame.origin.y <= CGRectGetMaxY(self.topView.frame) + 21){
                if (self.isViewDidAppear){
                    UIView.animateWithDuration(0.3, delay: 0.0, options: [.CurveEaseOut, .AllowUserInteraction] , animations: {
                        self.chordBase.frame.origin.y = CGRectGetMaxY(self.topView.frame) + 20 + self.view.frame.height/8
                        self.chordBase.alpha = 1
                        for i in 0..<self.tuningLabels.count {
                            self.tuningLabels[i].center = CGPoint(x: self.topPoints[i+1]+self.chordBase.frame.origin.x, y:  CGRectGetMaxY(self.topView.frame) + 20 + self.view.frame.height/8 - 10)
                        }
                        }, completion: {
                            finished in UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                self.previousButton.frame.origin.y = self.chordBase.frame.origin.y
                                self.nextButton.frame.origin.y = self.chordBase.frame.origin.y
                                }, completion: nil)
                    })
                }else{
                    self.chordBase.frame.origin.y = CGRectGetMaxY(self.topView.frame) + 20 + self.view.frame.height/8
                    self.chordBase.alpha = 1
                    self.previousButton.frame.origin.y = self.chordBase.frame.origin.y
                    self.nextButton.frame.origin.y = self.chordBase.frame.origin.y
                    for i in 0..<self.tuningLabels.count {
                        self.tuningLabels[i].center = CGPoint(x: self.topPoints[i+1]+self.chordBase.frame.origin.x, y:  CGRectGetMaxY(self.topView.frame) + 20 + self.view.frame.height/8 - 10)
                    }
                }
            }
        } else if (isLyricsShown) {
            if (self.chordBase.frame.origin.y > CGRectGetMaxY(self.topView.frame) + 20){
                if (self.isViewDidAppear){
                    self.lyricbase.alpha = 0
                    self.lyricbase.transform = CGAffineTransformMakeScale(0.95, 0.95)
                    UIView.animateWithDuration(0.3, delay: 0.0, options: [.CurveEaseOut, .AllowUserInteraction] , animations: {
                        self.chordBase.frame.origin.y = CGRectGetMaxY(self.topView.frame) + 20
                        for i in 0..<self.tuningLabels.count {
                            self.tuningLabels[i].center = CGPoint(x: self.topPoints[i+1]+self.chordBase.frame.origin.x, y:  CGRectGetMaxY(self.topView.frame) + 20 - 10)
                        }
                        }, completion: {
                            finished in
                            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: [.CurveEaseOut, .AllowUserInteraction], animations: {
                                self.previousButton.frame.origin.y = self.chordBase.frame.origin.y
                                self.nextButton.frame.origin.y = self.chordBase.frame.origin.y
                                }, completion: nil)
                    })
                    UIView.animateWithDuration(0.3, delay: 0.2, options: [.CurveEaseOut, .AllowUserInteraction] , animations: {
                        self.lyricbase.alpha = 1
                        self.lyricbase.transform = CGAffineTransformMakeScale(1, 1)
                        },completion: nil)
                }else{
                    self.chordBase.frame.origin.y = CGRectGetMaxY(self.topView.frame) + 20
                    self.previousButton.frame.origin.y = self.chordBase.frame.origin.y
                    self.nextButton.frame.origin.y = self.chordBase.frame.origin.y
                    for i in 0..<self.tuningLabels.count {
                        self.tuningLabels[i].center = CGPoint(x: self.topPoints[i+1]+self.chordBase.frame.origin.x, y:  CGRectGetMaxY(self.topView.frame) + 20 - 10)
                    }
                }
            }
        } else if (!isChordShown && !isTabsShown && !isLyricsShown) {
            self.chordBase.frame.origin.y = CGRectGetMaxY(self.topView.frame) + 20 + self.view.frame.height/8
            self.chordBase.alpha = 0
            for i in 0..<self.tuningLabels.count {
                self.tuningLabels[i].center = CGPoint(x: self.topPoints[i+1]+self.chordBase.frame.origin.x, y:  CGRectGetMaxY(self.topView.frame) + 20 + self.view.frame.height/8 - 10)
            }
        }
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
                if (self.isViewDidAppear){
                    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut , animations: {
                        
                        self.backgroundImageView.transform = CGAffineTransformMakeScale(1,1)
                        self.chordBase.alpha = 1
                        }, completion: {
                            finished in UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                self.previousButton.frame.origin.y = self.chordBase.frame.origin.y
                                self.nextButton.frame.origin.y = self.chordBase.frame.origin.y
                                }, completion: nil)
                    })
                }else{
                    self.backgroundImageView.transform = CGAffineTransformMakeScale(1,1)
                    self.chordBase.alpha = 1
                    self.previousButton.frame.origin.y = self.chordBase.frame.origin.y
                    self.nextButton.frame.origin.y = self.chordBase.frame.origin.y
                }
            }
        } else if (!isChordShown && !isTabsShown && !isLyricsShown && isBlurred) { // center the image
            
            dispatch_async(dispatch_get_main_queue()) {
                self.backgroundImageView.image = self.backgroundImage
            }
            
            for label in tuningLabels {
                label.hidden = true
            }
            
            self.isBlurred = false
            
            // we dont' need animation when changing song
            if !changeSong {
                if (self.isViewDidAppear){
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
                }else{
                    self.backgroundImageView.transform = CGAffineTransformMakeScale(self.backgroundScaleFactor, self.backgroundScaleFactor)
                    self.backgroundImageView.layer.shadowOpacity = 0.9
                    self.backgroundImageView.layer.shadowOffset = CGSize(width: 1, height: 1)
                    self.backgroundImageView.layer.shadowColor = UIColor.blackColor().CGColor
                    self.previousButton.center.y = self.view.center.y
                    self.nextButton.center.y = self.view.center.y
                }
                
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
            if (KGLOBAL_defaultProgressBar != nil){
                KGLOBAL_defaultProgressBar.alpha = 0.5
            }
        } else {
            self.player.pause()
            stopTimer()
            KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
            KGLOBAL_progressBlock!.alpha = 0.5
            if (KGLOBAL_defaultProgressBar != nil){
                KGLOBAL_defaultProgressBar.alpha = 0.5
            }
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
            if (KGLOBAL_defaultProgressBar != nil){
                KGLOBAL_defaultProgressBar.alpha = 0.5
            }
        } else {
            self.player.pause()
            stopTimer()
            KGLOBAL_progressBlock!.transform = CGAffineTransformMakeScale(1.0, 0.5)
            KGLOBAL_progressBlock!.alpha = 0.5
            if (KGLOBAL_defaultProgressBar != nil){
                KGLOBAL_defaultProgressBar.alpha = 0.5
            }
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
}