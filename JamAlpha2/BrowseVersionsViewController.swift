//
//  BrowseAllTabsViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/8/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit

class BrowseVersionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var songViewController: SongViewController!
    
    var isPullingTabs = true //variable called when this viewcontroller is instantiated, a negative value means we are downloading lyrics
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    var downloadedTabsSets = [DownloadedTabsSet]()
    var downloadedLyricsSets = [DownloadedLyricsSet]()
    var mediaItem: MPMediaItem!
    var songId = -1
    
    var centerButton: UIButton!//to display "Add your own tabs or lyrics if none is found"
    
    override func viewDidLoad() {
        setUpHeader()
        setUpCenterButton()
        let layer = UIView()
        layer.backgroundColor = UIColor.backgroundGray()
        resultsTableView.backgroundView = layer
       
        fetchData()
    }
    
    func fetchData() {
        if isPullingTabs {
            downloadedTabsSets = [DownloadedTabsSet]()
            APIManager.downloadTabs(mediaItem, completion: {
                downloads in
                self.downloadedTabsSets = downloads
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultsTableView.reloadData()
                    if downloads.count < 1 {
                        self.centerButton.hidden = false
                    }
                }
            })
        } else {
            APIManager.downloadLyrics(mediaItem, completion: {
                downloads in
                self.downloadedLyricsSets = downloads
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultsTableView.reloadData()
                    if downloads.count < 1 {
                        self.centerButton.hidden = false
                    }
                }
            })
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setUpHeader() {
        let statusBarLayer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        statusBarLayer.backgroundColor = UIColor.mainPinkColor()
        self.view.addSubview(statusBarLayer)
        
        let topView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44))
        topView.backgroundColor = UIColor.mainPinkColor()
        self.view.addSubview(topView)
        
        let buttonDimension: CGFloat = 50
        let pulldownButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonDimension, height: buttonDimension))
        
        pulldownButton.setImage(UIImage(named: "pullDown"), forState: UIControlState.Normal)
        pulldownButton.center = CGPoint(x: self.view.frame.width / 12, y: topView.height/2)
        pulldownButton.addTarget(self, action: "pullDownButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(pulldownButton)
        
        let songNameLabel = MarqueeLabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 20)))
        songNameLabel.type = .Continuous
        songNameLabel.scrollDuration = 15.0
        songNameLabel.fadeLength = 5.0
        songNameLabel.trailingBuffer = 30.0
        
        let artistNameLabel = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: 180, height: 10)))
        artistNameLabel.textAlignment = NSTextAlignment.Center
        
        let title:String = mediaItem.title!
        let attributedString = NSMutableAttributedString(string:title)
        songNameLabel.attributedText = attributedString
        songNameLabel.textAlignment = NSTextAlignment.Center
        
        artistNameLabel.text = mediaItem.artist!
        
        
        songNameLabel.font = UIFont.systemFontOfSize(18)
        artistNameLabel.font = UIFont.systemFontOfSize(12)
        
        //increase edge width
        //TODO: set a max of width to avoid clashing with pulldown and tuning button
        songNameLabel.frame.size = CGSize(width: songNameLabel.frame.width + 20, height: 30)
        artistNameLabel.frame.size = CGSize(width: artistNameLabel.frame.width + 20, height: 30)
        songNameLabel.center.x = self.view.frame.width / 2
        songNameLabel.center.y = pulldownButton.center.y - 7
        
        artistNameLabel.center.x = self.view.frame.width / 2
        artistNameLabel.center.y = CGRectGetMaxY(songNameLabel.frame) + 3
        
        songNameLabel.textColor = UIColor.whiteColor()
        artistNameLabel.textColor =  UIColor.whiteColor()
        
        artistNameLabel.backgroundColor = UIColor.clearColor()
        
        topView.addSubview(songNameLabel)
        topView.addSubview(artistNameLabel)
    }
    
    func setUpCenterButton() {
        centerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        centerButton.titleLabel?.font = UIFont.systemFontOfSize(18)
        centerButton.titleLabel?.numberOfLines = 2
        centerButton.setTitleColor(UIColor.mainPinkColor(), forState: .Normal)
        centerButton.layer.borderWidth = 2
        centerButton.layer.borderColor = UIColor.mainPinkColor().CGColor
        centerButton.layer.cornerRadius = 20
        if isPullingTabs {
          centerButton.setTitle("No tabs found, click here to add your own.", forState: .Normal)
        } else {
          centerButton.setTitle("No lyrics found, click here to add your own.", forState: .Normal)
        }
        centerButton.center = self.view.center
        centerButton.hidden = true
        centerButton.addTarget(self, action: "centerButtonPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(centerButton)
    }
    
    func centerButtonPressed() {
        if isPullingTabs {
            self.dismissViewControllerAnimated(false, completion: {
                completed in
                self.songViewController.goToTabsEditor()
            })
        } else {
            self.dismissViewControllerAnimated(false, completion: {
                completed in
                self.songViewController.goToLyricsEditor()
            })
        }
    }
    
    func pullDownButtonPressed(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPullingTabs {
            return downloadedTabsSets.count
        }
        return downloadedLyricsSets.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("browseversionscell", forIndexPath: indexPath) as! BrowseVersionsCell
        
        if isPullingTabs {
            let tabsSet = downloadedTabsSets[indexPath.row]
            
            var tuning = ""
            if tabsSet.tuning == "E-B-G-D-A-E-" {
                tuning = "standard"
            } else {
                tuning = tabsSet.tuning
            }
            
            cell.votesLabel.text = String(tabsSet.upVotes - tabsSet.downVotes)
            cell.titleLabel.text = tabsSet.chordsPreview + "..."
            cell.subtitleLabel.text = "Tuning: \(tuning) | Capo: \(tabsSet.capo)"

        } else {
            let lyricsSet = downloadedLyricsSets[indexPath.row]
            
            cell.votesLabel.text = String(lyricsSet.upVotes - lyricsSet.downVotes)
            cell.titleLabel.text = lyricsSet.lyricsPreview + "..."
            cell.subtitleLabel.text = "\(lyricsSet.numberOfLines) lines"
        }
        
        //add actions for up and down vote buttons
        cell.upVoteButton.addTarget(self, action: "upVoted:", forControlEvents: .TouchUpInside)
        cell.upVoteButton.tag = indexPath.row
        
        cell.downVoteButton.addTarget(self, action: "downVoted:", forControlEvents: .TouchUpInside)
        cell.downVoteButton.tag = indexPath.row
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if isPullingTabs {
            let tabsSet = downloadedTabsSets[indexPath.row]
            APIManager.downloadTabsSetContent(tabsSet, completion: {
                download in
                
                self.songViewController.updateTuning(tabsSet.tuning)
                self.songViewController.updateCapo(tabsSet.capo)
                
                var chordsToBeUsed = [Chord]()
                for i in 0..<download.chords.count {
                    let chord = Chord(tab: Tab(name: download.chords[i], content: download.tabs[i]), time: TimeNumber(time: download.times[i]))
                    chordsToBeUsed.append(chord)
                }
                self.songViewController.chords = chordsToBeUsed
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        
        } else {
            let lyricsSet = downloadedLyricsSets[indexPath.row]
            APIManager.downloadLyricsSetContent(lyricsSet, completion: {
                download in
                
                var lyricsToBeUsed = Lyric()
                for i in 0..<download.times.count {
                    lyricsToBeUsed.addLine(TimeNumber(time: download.times[i]), str: download.lyrics[i])
                }
                
                self.songViewController.lyric = lyricsToBeUsed
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    func upVoted(button: UIButton) {
        APIManager.updateVotes(true, tabsSet: downloadedTabsSets[button.tag])
        //should be callback to see if it is s
        print("up button: \(button.tag) pressed")
    }
    
    func downVoted(button: UIButton) {
        APIManager.updateVotes(false, tabsSet: downloadedTabsSets[button.tag])

        print("down button: \(button.tag) pressed")
    }
    
}