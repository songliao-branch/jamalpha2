//
//  SingleLyricsView.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/26/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension SongViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpBackgroundEffect() {
        backgroundBlurView = UIVisualEffectView()
        backgroundBlurView.frame = CGRectMake(0, 0, backgroundImageView.frame.size.width, backgroundImageView.frame.size.height)
        backgroundBlurView.effect = UIBlurEffect(style: .Dark)
        backgroundBlurView.alpha = 0
        backgroundImageView.addSubview(backgroundBlurView)
        
        bottomBlurView = UIView(frame: CGRect(x: 11, y: singleLyricsTableView.frame.origin.y + singleLyricsTableView.frame.size.height, width: self.view.frame.width-11*2, height: 0.5 ))
        bottomBlurView.backgroundColor = UIColor.baseColor()
        bottomBlurView.alpha = 0
        self.view.insertSubview(bottomBlurView, aboveSubview: singleLyricsTableView)
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            self.backgroundBlurView.alpha = 1
            self.bottomBlurView.alpha = 1
            }, completion: nil)
    }
    
    func releaseBackgroundEffect() {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.backgroundBlurView.alpha = 0
            self.bottomBlurView.alpha = 0
            }, completion: {
                completed in
                self.backgroundBlurView.removeFromSuperview()
                self.backgroundBlurView = nil
                
                self.bottomBlurView.removeFromSuperview()
                self.bottomBlurView = nil
        })
        
    }
    
    func setUpLyricsArray() {
        numberOfLineInSingleLyricsView = Int((basesHeight + 20) / 66) / 2 + 1
        if lyricsArray != nil {
            lyricsArray.removeAll()
        }
        lyricsArray = [(str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat)]()
        
        let contentOff: CGFloat = 33
        
        if lyric.lyric.count > 0 {
            for var i = 0; i < lyric.lyric.count + 2 * numberOfLineInSingleLyricsView; i++ {
                if i < numberOfLineInSingleLyricsView {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + contentOff))
                } else if i < lyric.lyric.count + numberOfLineInSingleLyricsView {
                    let temp: (str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat) = (lyric.lyric[i - numberOfLineInSingleLyricsView].str, NSTimeInterval(lyric.lyric[i - numberOfLineInSingleLyricsView].time.toDecimalNumer()), 0.5, CGFloat(i * 66) + contentOff)
                    lyricsArray.append(temp)
                } else {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + contentOff))
                }
            }
        } else {
            for var i = 0; i < numberOfLineInSingleLyricsView; i++ {
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
        }
    }
    
    func updateSingleLyricsAlpha() {
        for var i = 0; i < lyricsArray.count; i++ {
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
            singleLyricsTableView.alpha = 0
            setUpBackgroundEffect()
            self.view.insertSubview(singleLyricsTableView, aboveSubview: self.backgroundImageView)
            
            for label in tuningLabels {
                label.hidden = true
            }
            self.updateSingleLyricsAlpha()
            self.updateSingleLyricsPosition(false)
            
            UIView.animateWithDuration(0.15, delay: 0.15, options: .CurveEaseIn, animations: {
                self.singleLyricsTableView.alpha = 1
                }, completion: nil)
            
        }
    }
    func releaseSingleLyricsView() {
        if singleLyricsTableView != nil {
            releaseBackgroundEffect()
            UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseIn, animations: {
                self.singleLyricsTableView.alpha = 0
                }, completion: {
                    completd in
                    print("release")
                    self.singleLyricsTableView.removeFromSuperview()
                    self.singleLyricsTableView = nil
                    for label in self.tuningLabels {
                        label.hidden = false
                    }
                    self.lyricsArray.removeAll()
                    self.lyricsArray = nil
                    if (self.lyricbase.hidden){
                        self.lyricbase.hidden = false
                        UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseIn, animations: {
                            self.lyricbase.alpha = 1
                            }, completion: nil)
                    }
                    self.hideTempScrollLyricsView()
            })
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
}