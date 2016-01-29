//
//  SingleLyricsView.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/26/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension SongViewController {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if tutorialScrollView != nil {
            if  tutorialScrollView.hidden {
                return
            }
            for i in 0..<numberOfTutorialPages {
                tutorialIndicators[i].frame.origin.x = scrollView.contentOffset.x + indicatorOriginXPositions[i]
            }
        }
        self.lyricDidScroll()
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.lyricWillScroll()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if tutorialScrollView != nil {
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
        self.lyricEndDeceleration()
    }
}



extension SongViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpBackgroundEffect() {
        self.singleLyricsTableView.alpha = 0
        
        bottomBlurView.frame.origin.y = self.singleLyricsTableView.frame.origin.y + self.singleLyricsTableView.frame.size.height
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            self.backgroundBlurView.alpha = 1
            self.bottomBlurView.alpha = 1
            }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 0.1, options: .CurveEaseIn, animations: {
            self.singleLyricsTableView.alpha = 1
            }, completion: nil)
    }
    
    func releaseBackgroundEffect() {
        if ( (isChordShown || isTabsShown ) && isLyricsShown){
            self.chordBase.alpha = 0
            UIView.animateWithDuration(0.2, delay: 0.1, options: [.CurveEaseIn, .AllowUserInteraction], animations: {
                self.chordBase.alpha = 1
                }, completion: nil)
        }
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.backgroundBlurView.alpha = 0
            self.bottomBlurView.alpha = 0
            self.singleLyricsTableView.alpha = 0
            }, completion: nil)
    }
    
    func setUpLyricsArray() {
        numberOfLineInSingleLyricsView = Int((basesHeight + 20) / 66) / 2 + 1
        if lyricsArray != nil {
            lyricsArray.removeAll()
        }
        lyricsArray = [(str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat)]()
        let contentOff: CGFloat = 33
        if lyric.lyric.count > 0 {
            for  i in 0..<(lyric.lyric.count + 2 * numberOfLineInSingleLyricsView) {
                if i < numberOfLineInSingleLyricsView {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + contentOff))
                } else if i < lyric.lyric.count + numberOfLineInSingleLyricsView {
                    let temp: (str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat) = (lyric.lyric[i - numberOfLineInSingleLyricsView].str, NSTimeInterval(lyric.lyric[i - numberOfLineInSingleLyricsView].time.toDecimalNumer()), 0.5, CGFloat(i * 66) + contentOff)
                    lyricsArray.append(temp)
                } else {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + contentOff))
                }
            }
            if (self.singleLyricsTableView != nil){
                self.singleLyricsTableView.scrollEnabled = true
            }
        } else {
            if (self.singleLyricsTableView != nil){
                self.singleLyricsTableView.scrollEnabled = false
            }
            for i in 0..<numberOfLineInSingleLyricsView {
                lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + contentOff))
            }
            lyricsArray.append(("You don't have any lyric, please add it in Lyrics Editor or select one from others", 0, 0.5, CGFloat(numberOfLineInSingleLyricsView * 66) + contentOff))
        }
    }
    
    func setUpScrollLine() {
        numberOfLineInSingleLyricsView = Int((basesHeight + 20) / 66) / 2 + 1
        tempPlayButton = UIButton()
        tempPlayButton.frame = CGRectMake(0, CGRectGetMaxY(topView.frame) + CGFloat(numberOfLineInSingleLyricsView) * 66 - 22, 44, 44)
        tempPlayButton.setImage(UIImage(named: "playbutton"), forState: .Normal)
        tempPlayButton.imageEdgeInsets = UIEdgeInsetsMake(9.5, 2.5, 9.5, 16.5)
        tempPlayButton.hidden = true
        tempPlayButton.addTarget(self, action: "pressTempPlayButton:", forControlEvents: .TouchUpInside)
        self.view.insertSubview(tempPlayButton, belowSubview: guitarActionView)
        
        tempScrollLine = UIView()
        tempScrollLine.frame = CGRectMake(30, CGRectGetMaxY(topView.frame) + CGFloat(numberOfLineInSingleLyricsView) * 66, self.view.frame.size.width - 60, 1)
        tempScrollLine.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        tempScrollLine.hidden = true
        self.view.insertSubview(tempScrollLine, belowSubview: guitarActionView)
        
        tempScrollTime = NSTimeInterval(startTime.toDecimalNumer())
        
        tempScrollTimeLabel = UILabel()
        tempScrollTimeLabel.frame = CGRectMake(self.view.frame.size.width - 22.5, CGRectGetMaxY(topView.frame) + CGFloat(numberOfLineInSingleLyricsView) * 66 - 7.5, 25, 15)
        tempScrollTimeLabel.font = UIFont.systemFontOfSize(8)
        tempScrollTimeLabel.textColor = UIColor.whiteColor()
        let min: Int = Int(tempScrollTime) / 60
        let sec: Int = Int(tempScrollTime) % 60
        if min < 10 {
            if sec < 10 {
                tempScrollTimeLabel.text = "0\(min):0\(sec)"
            } else {
                tempScrollTimeLabel.text = "0\(min):\(sec)"
            }
        } else {
            if sec < 10 {
                tempScrollTimeLabel.text = "\(min):0\(sec)"
            } else {
                tempScrollTimeLabel.text = "\(min):\(sec)"
            }
        }
        tempScrollTimeLabel.hidden = true
        self.view.insertSubview(tempScrollTimeLabel, belowSubview: guitarActionView)
    }

    func pressTempPlayButton(sender: UIButton) {
        stopTimer()
        hideTempScrollLyricsView()
        self.toTime = Float(tempScrollTime)
        updateAll(self.toTime)
        var isPlaying = false
        if isDemoSong {
            self.avPlayer.seekToTime(CMTimeMakeWithSeconds(Float64(self.toTime), 1))
            isPlaying = avPlayer.rate > 0
        }else{
            if(self.player != nil){
                self.player.currentPlaybackTime = tempScrollTime
                isPlaying = self.player.playbackState == .Playing
            }
        }
        if (!isPlaying){
            if isDemoSong {
                self.avPlayer.rate = self.speed
            }else{
                if(self.player != nil){
                    self.player.currentPlaybackRate = self.speed
                }
            }

        }
        self.isScrolling = false
        if (self.currentLyricsIndex == 0 ){
            self.currentLyricsIndex = -1
        }
        startTimer()
    }
    
    func showTempScrollLyricsView() {
        tempPlayButton.hidden = false
        tempScrollLine.hidden = false
        tempScrollTimeLabel.hidden = false
        tempScrollTime = NSTimeInterval(startTime.toDecimalNumer())
        let min: Int = Int(tempScrollTime) / 60
        let sec: Int = Int(tempScrollTime) % 60
        if min < 10 {
            if sec < 10 {
                tempScrollTimeLabel.text = "0\(min):0\(sec)"
            } else {
                tempScrollTimeLabel.text = "0\(min):\(sec)"
            }
        } else {
            if sec < 10 {
                tempScrollTimeLabel.text = "\(min):0\(sec)"
            } else {
                tempScrollTimeLabel.text = "\(min):\(sec)"
            }
        }
    }
    
    func hideTempScrollLyricsView() {
        if singleLyricsTableView != nil {
            tempPlayButton.hidden = true
            tempScrollLine.hidden = true
            tempScrollTimeLabel.hidden = true
            updateSingleLyricsPosition(true)
        }
    }
    
    func updateSingleLyricsPosition(animated:Bool) {
        if currentLyricsIndex > 0 && currentLyricsIndex < self.lyricsArray.count - numberOfLineInSingleLyricsView {
            singleLyricsTableView.setContentOffset(CGPoint(x: 0, y: self.lyricsArray[currentLyricsIndex].offSet), animated: animated)
        } else if currentLyricsIndex == -1 {
            singleLyricsTableView.setContentOffset(CGPoint(x: 0, y: self.lyricsArray[0].offSet), animated: animated)
        }
    }
    
    func updateSingleLyricsAlpha() {
            for i in 0..<lyricsArray.count {
                self.lyricsArray[i].alpha = 0.5
                if i == currentLyricsIndex + numberOfLineInSingleLyricsView {
                    self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView].alpha = 1
                }
            }
            singleLyricsTableView.reloadData()
    }
    
    func updateSingleLyricsArray() {
        if currentLyricsIndex > 0 {
            let topRowIndex: NSIndexPath = NSIndexPath(forItem: currentLyricsIndex, inSection: 0)
            let bottomRowIndex: NSIndexPath = NSIndexPath(forItem: currentLyricsIndex + numberOfLineInSingleLyricsView * 2 - 1, inSection: 0)
            
            for var i = 0; i < lyricsArray.count; i++ {
                self.lyricsArray[i].alpha = 0.5
            }
            
            self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView].alpha = 1
            
            lyricsArray[topRowIndex.item].alpha = -singleLyricsTableView.rectForRowAtIndexPath(topRowIndex).origin.y / 66 * 0.5
            print("alpha: \(lyricsArray[topRowIndex.item].alpha)")
            lyricsArray[bottomRowIndex.item].alpha = (singleLyricsTableView.frame.size.height - singleLyricsTableView.rectForRowAtIndexPath(topRowIndex).origin.y) / 66 * 0.5
            
            singleLyricsTableView.reloadRowsAtIndexPaths([topRowIndex, bottomRowIndex], withRowAnimation: .None)
        }
    }
    
    func setUpSingleLyricsView() {
        if singleLyricsTableView == nil {
            let sideMargin: CGFloat = 20
            let marginToTopView: CGFloat = 0
            let frame: CGRect = CGRectMake(sideMargin, CGRectGetMaxY(topView.frame) + marginToTopView, self.view.frame.size.width - 2 * sideMargin, basesHeight + 20)
            
            let frame2: CGRect = CGRectMake(0, 0, frame.size.width, frame.size.height)
            let gradient = CAGradientLayer()
            gradient.frame = frame2
            gradient.colors = [UIColor.clearColor().CGColor, UIColor.baseColor().CGColor, UIColor.clearColor().CGColor]
            setUpLyricsArray()
            singleLyricsTableView = UITableView(frame: frame, style: .Plain)
            singleLyricsTableView.backgroundColor = UIColor.clearColor()
            singleLyricsTableView.delegate = self
            singleLyricsTableView.dataSource = self
            singleLyricsTableView.registerClass(SingleLyricsTableViewCell.self, forCellReuseIdentifier: "cell")
            singleLyricsTableView.separatorStyle = .None
            singleLyricsTableView.showsHorizontalScrollIndicator = false
            singleLyricsTableView.showsVerticalScrollIndicator = false
            setUpBackgroundEffect()
            self.view.insertSubview(singleLyricsTableView, aboveSubview: self.backgroundImageView)
            
            for label in tuningLabels {
                label.alpha = 0
            }
            self.updateSingleLyricsAlpha()
            self.updateSingleLyricsPosition(false)
            if (lyric.lyric.count) == 0 {
                self.singleLyricsTableView.scrollEnabled = false
            }else {
                self.singleLyricsTableView.scrollEnabled = true
            }
        }
    }
    
    func releaseSingleLyricsView() {
        if singleLyricsTableView != nil {
            print("release")
            releaseBackgroundEffect()
            self.singleLyricsTableView.removeFromSuperview()
            self.singleLyricsTableView = nil
            for label in tuningLabels {
                label.alpha = 1
            }
            self.lyricsArray.removeAll()
            self.lyricsArray = nil
            self.lyricbase.hidden = false
            hideTempScrollLyricsView()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lyricsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SingleLyricsTableViewCell = self.singleLyricsTableView.dequeueReusableCellWithIdentifier("cell") as! SingleLyricsTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.updateLyricsLabel(self.lyricsArray[indexPath.item].str, labelAlpha: self.lyricsArray[indexPath.item].alpha)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func lyricDidScroll(){
        if tempScrollLine != nil && tempScrollLine.hidden == false {
            disapperCount = 0
            let centerPoint: CGPoint = self.tempScrollLine.center
            
            
            var min_loop = 0
            var max_loop = self.lyricsArray.count - numberOfLineInSingleLyricsView - 1
            
            while min_loop <= max_loop {
                let mid = Int((max_loop + min_loop) / 2)
                let tempIndex: NSIndexPath = NSIndexPath(forItem: mid, inSection: 0)
                let tempRect: CGRect = singleLyricsTableView.rectForRowAtIndexPath(tempIndex)
                let superViewRect: CGRect = singleLyricsTableView.convertRect(tempRect, toView: self.view)
                
                if CGRectContainsPoint(superViewRect, centerPoint) {
                    currentSelectTempIndex = NSIndexPath(forItem: mid, inSection: 0)
                    if mid > 0 {
                        if self.lyricsArray[mid - 1].alpha < 1 {
                            self.lyricsArray[mid - 1].alpha = 0.5
                        }
                    }
                    if self.lyricsArray[mid].alpha < 1 {
                        self.lyricsArray[mid].alpha = 0.7
                    }
                    if self.lyricsArray[mid + 1].alpha < 1 {
                        self.lyricsArray[mid + 1].alpha = 0.5
                    }
                    
                    let tempIndexPath: [NSIndexPath] = [NSIndexPath(forItem: mid - 1, inSection: 0), NSIndexPath(forItem: mid, inSection: 0), NSIndexPath(forItem: mid + 1, inSection: 0)]
                    
                    singleLyricsTableView.reloadRowsAtIndexPaths(tempIndexPath, withRowAnimation: .None)
                    
                    tempScrollTime = self.lyricsArray[mid].time
                    let min: Int = Int(tempScrollTime) / 60
                    let sec: Int = Int(tempScrollTime) % 60
                    if min < 10 {
                        if sec < 10 {
                            tempScrollTimeLabel.text = "0\(min):0\(sec)"
                        } else {
                            tempScrollTimeLabel.text = "0\(min):\(sec)"
                        }
                    } else {
                        if sec < 10 {
                            tempScrollTimeLabel.text = "\(min):0\(sec)"
                        } else {
                            tempScrollTimeLabel.text = "\(min):\(sec)"
                        }
                    }
                    break
                }else {
                    if superViewRect.origin.y > centerPoint.y {
                        max_loop = mid - 1
                    } else {
                        min_loop = mid
                        if (min_loop >= max_loop - 1){
                            min_loop = mid + 1
                        }
                    }
                }
            }
        }
    }
    
    func lyricWillScroll(){
        isScrolling = true
        if singleLyricsTableView != nil {
            print("will begin scroll")
            self.stopDisapperTimer()
            if lyricsArray.count != numberOfLineInSingleLyricsView + 1 {
                showTempScrollLyricsView()
            }
        }
    }
    
    func lyricEndDeceleration(){
        if singleLyricsTableView != nil {
            var isPlaying = false
            if isDemoSong {
                isPlaying = avPlayer.rate > 0
            }else{
                if(self.player != nil){
                    isPlaying = self.player.playbackState == .Playing
                }
            }
            if isPlaying {
                print("did end dragging")
                startDisapperTimer()
            }else{
                isScrolling = false
            }
        }
    }
    
    func lyricEndDraggin(decelerate:Bool){
        if singleLyricsTableView != nil {
            print("did end dragging")
            if !decelerate {
                var isPlaying = false
                if isDemoSong {
                    isPlaying = avPlayer.rate > 0
                }else{
                    if(self.player != nil){
                        isPlaying = self.player.playbackState == .Playing
                    }
                }
                if isPlaying {
                    startDisapperTimer()
                }else{
                    isScrolling = false
                }
            }
        }
    }
    
    func startDisapperTimer(){
        if disapperTimer == nil{
            disapperTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "disapperCount:", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(disapperTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func stopDisapperTimer(){
        if disapperTimer != nil {
            disapperTimer.invalidate()
            disapperTimer = nil
            disapperCount = 0
        }
    }
    
    
    func disapperCount(sender: NSTimer) {
        disapperCount++
        print("keep runing")
        if disapperCount >= 1 {
            print("diapper")
            isScrolling = false
            disapperCount = 0
            if self.lyricsArray.count > 0 {
                self.hideTempScrollLyricsView()
            }
            self.stopDisapperTimer()
        }
    }

}