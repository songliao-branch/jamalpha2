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
    func setUpLyricsArray() {
        numberOfLineInSingleLyricsView = Int((basesHeight + 20) / 66) / 2 + 1
        if lyricsArray != nil {
            lyricsArray.removeAll()
        }
        lyricsArray = [(str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat)]()
        if lyric.lyric.count > 0 {
            for var i = 0; i < lyric.lyric.count + 2 * numberOfLineInSingleLyricsView; i++ {
                if i < numberOfLineInSingleLyricsView {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + 11))
                } else if i < lyric.lyric.count + numberOfLineInSingleLyricsView {
                    let temp: (str: String, time: NSTimeInterval, alpha: CGFloat, offSet: CGFloat) = (lyric.lyric[i - numberOfLineInSingleLyricsView].str, NSTimeInterval(lyric.lyric[i - numberOfLineInSingleLyricsView].time.toDecimalNumer()), 0.5, CGFloat(i * 66) + 11)
                    lyricsArray.append(temp)
                } else {
                    lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + 11))
                }
            }
        } else {
            for var i = 0; i < numberOfLineInSingleLyricsView; i++ {
                lyricsArray.append(("", 0, 0.5, CGFloat(i * 66) + 11))
            }
            lyricsArray.append(("You don't have any lyric, please add it in Lyrics Editor or select one from others", 0, 0.5, CGFloat(numberOfLineInSingleLyricsView * 66) + 11))
        }
    }
    
    func setUpScrollLine() {
        numberOfLineInSingleLyricsView = Int((basesHeight + 20) / 66) / 2 + 1
        tempPlayButton = UIButton()
        tempPlayButton.frame = CGRectMake(0, CGRectGetMaxY(topView.frame) + CGFloat(numberOfLineInSingleLyricsView) * 66 + 11 + 33 - 22, 44, 44)
        tempPlayButton.setImage(UIImage(named: "playbutton"), forState: .Normal)
        tempPlayButton.imageEdgeInsets = UIEdgeInsetsMake(12, 5, 12, 19)
        tempPlayButton.hidden = true
        tempPlayButton.addTarget(self, action: "pressTempPlayButton:", forControlEvents: .TouchUpInside)
        self.view.insertSubview(tempPlayButton, belowSubview: guitarActionView)
        
        tempScrollLine = UIView()
        tempScrollLine.frame = CGRectMake(30, CGRectGetMaxY(topView.frame) + CGFloat(numberOfLineInSingleLyricsView) * 66 + 11 + 33, self.view.frame.size.width - 60, 1)
        tempScrollLine.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        tempScrollLine.hidden = true
        self.view.insertSubview(tempScrollLine, belowSubview: guitarActionView)
        
        tempScrollTime = NSTimeInterval(startTime.toDecimalNumer())
        
        tempScrollTimeLabel = UILabel()
        tempScrollTimeLabel.frame = CGRectMake(self.view.frame.size.width - 25, CGRectGetMaxY(topView.frame) + CGFloat(numberOfLineInSingleLyricsView) * 66 + 11 + 33 - 7.5, 20, 15)
        tempScrollTimeLabel.font = UIFont.systemFontOfSize(6)
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
        for var i = 0; i < lyricsArray.count; i++ {
            self.lyricsArray[i].alpha = 0.5
            if i == currentLyricsIndex + numberOfLineInSingleLyricsView {
                self.lyricsArray[currentLyricsIndex + numberOfLineInSingleLyricsView].alpha = 1
            }
        }
        
        singleLyricsTableView.reloadData()
        if currentLyricsIndex > 0 && currentLyricsIndex < self.lyricsArray.count {
            singleLyricsTableView.setContentOffset(CGPoint(x: 0, y: self.lyricsArray[currentLyricsIndex].offSet), animated: animated)
        } else {
            singleLyricsTableView.setContentOffset(CGPoint(x: 0, y: self.lyricsArray[0].offSet), animated: animated)
        }

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
            
            let tapOnTableView: UITapGestureRecognizer = UITapGestureRecognizer()
            tapOnTableView.addTarget(self, action: "tapOnTableView:")
            singleLyricsTableView.addGestureRecognizer(tapOnTableView)
            
            self.view.insertSubview(singleLyricsTableView, belowSubview: guitarActionView)
            
            for label in tuningLabels {
                label.hidden = true
            }
            self.updateSingleLyricsPosition(false)
        }
        
    }
    
    func releaseSingleLyricsView() {
        if singleLyricsTableView != nil {
            print("release")
            self.singleLyricsTableView.removeFromSuperview()
            self.singleLyricsTableView = nil
            for label in self.tuningLabels {
                label.hidden = false
            }
            self.lyricsArray.removeAll()
            self.lyricsArray = nil
            self.lyricbase.hidden = false
        }
    }
    
    func tapOnTableView(sender: UITapGestureRecognizer) {
        dismissAction()
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
        let tempRowRect: CGRect = singleLyricsTableView.rectForRowAtIndexPath(indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}