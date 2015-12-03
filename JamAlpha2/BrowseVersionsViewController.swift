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
    
    var downloadedLyricsSets = [DownloadedLyricsSet]()
    
    var allTabsSets = [Int: [DownloadedTabsSet]]()//with a key 0 is local, key 1 is downloaded ones
    var lastSelectedTabsId = 0
    var mediaItem: MPMediaItem!
    var songId = -1
    
    var centerButton: UIButton!//to display "Add your own tabs or lyrics if none is found"
    
    override func viewDidLoad() {

        setUpHeader()
        setUpCenterButton()
        let layer = UIView()
        layer.backgroundColor = UIColor.backgroundGray()
        resultsTableView.backgroundView = layer
        
        
        ( _, _, _, lastSelectedTabsId) = CoreDataManager.getTabs(mediaItem, fetchingLocalOnly: false)
        loadLocalData()
        fetchData()
    }
    
    func loadLocalData() {
        if CoreDataManager.getCurrentUser() == nil {
            print("user not signed in, no local tabs nor lyrics")
            return
        }
        if isPullingTabs {
            //must initialize with key
            allTabsSets[0] = []
        
            var chords = [Chord]()
            var tuning = ""
            var capo = -1
            
            (chords, tuning, capo, _) = CoreDataManager.getTabs(mediaItem, fetchingLocalOnly: true)
     
            var preview = ""
            
            for i in 0..<chords.count {
                if i >= 10 {
                    break
                }
                preview += "\(chords[i].tab.name)  "
            }
            
            if chords.count > 2 { //just checking if there is a local tabs, a local tabs must have a tuning
                
                let set = DownloadedTabsSet(id: -1, tuning: tuning, capo: capo, songId: -1, votesScore: 0, userName: CoreDataManager.getCurrentUser()!.email, updatedAt: "", chordsPreview: preview, voteStatus: "")
                allTabsSets[0]?.append(set)
            }
        }

    }
    
    func fetchData() {
        if isPullingTabs {
            allTabsSets[1] = []
            
            APIManager.downloadTabs(mediaItem, completion: {
                downloads in
                
                for download in downloads {
                    self.allTabsSets[1]?.append(download)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultsTableView.reloadData()
                    
                    if self.allTabsSets[0]!.count == 0 && downloads.count < 1 {
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        view.backgroundColor = UIColor.backgroundGray()
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 20))
        label.textColor = UIColor.silverGray()
        label.font = UIFont.systemFontOfSize(15)
        
        if section == 0 {
            label.text = isPullingTabs ? "My tabs" : "My lyrics"
        } else {
            label.text = isPullingTabs ? "Top tabs" : "Top lyrics"
        }
        
        view.addSubview(label)
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPullingTabs && allTabsSets[section]?.count < 1 {
            return 0
        }
        return 22
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPullingTabs {
            if allTabsSets[section]?.count < 1 {
                return 0
            }
            return (allTabsSets[section]?.count)!
        }
        return downloadedLyricsSets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("browseversionscell", forIndexPath: indexPath) as! BrowseVersionsCell
        
        if isPullingTabs {
            
            let tabsInOneSection = allTabsSets[indexPath.section]
            let tabsSet: DownloadedTabsSet = tabsInOneSection![indexPath.row]
            
            var tuning = ""
            if tabsSet.tuning == "E-B-G-D-A-E-" {
                tuning = "standard"
            } else {
                tuning = tabsSet.tuning
            }
            
            
            
            if tabsSet.voteStatus == "up" {
                  cell.upVoteButton.setImage(UIImage(named: "vote_up_pink"), forState: .Normal)
                  cell.downVoteButton.setImage(UIImage(named: "vote_down_gray"), forState: .Normal)
            } else if tabsSet.voteStatus == "down" {
                cell.upVoteButton.setImage(UIImage(named: "vote_up_gray"), forState: .Normal)
                 cell.downVoteButton.setImage(UIImage(named: "vote_down_pink"), forState: .Normal)
            } else {
                cell.upVoteButton.setImage(UIImage(named: "vote_up_gray"), forState: .Normal)
                cell.downVoteButton.setImage(UIImage(named: "vote_down_gray"), forState: .Normal)
            }
            
            cell.votesLabel.text = String(tabsSet.votesScore)
            cell.titleLabel.text = tabsSet.chordsPreview + "..."
            cell.subtitleLabel.text = "Tuning: \(tuning) | Capo: \(tabsSet.capo)"
            cell.profileName.text = tabsSet.userName
            cell.dateLabel.text = tabsSet.updatedAt
            
            if tabsSet.id == lastSelectedTabsId {
                cell.checkmark.hidden = false
                cell.previewRightConstraint.constant = 45
            } else {
                cell.checkmark.hidden = true
                cell.previewRightConstraint.constant = 8
            }
            
        } else {
            let lyricsSet = downloadedLyricsSets[indexPath.row]
            
            if lyricsSet.voteStatus == "up" {
                cell.upVoteButton.setImage(UIImage(named: "vote_up_pink"), forState: .Normal)
                cell.downVoteButton.setImage(UIImage(named: "vote_down_gray"), forState: .Normal)
            } else if lyricsSet.voteStatus == "down" {
                cell.upVoteButton.setImage(UIImage(named: "vote_up_gray"), forState: .Normal)
                cell.downVoteButton.setImage(UIImage(named: "vote_down_pink"), forState: .Normal)
            } else {
                cell.upVoteButton.setImage(UIImage(named: "vote_up_gray"), forState: .Normal)
                cell.downVoteButton.setImage(UIImage(named: "vote_down_gray"), forState: .Normal)
            }
            
            cell.votesLabel.text = String(lyricsSet.votesScore)
            cell.titleLabel.text = lyricsSet.lyricsPreview + "..."
            cell.subtitleLabel.text = "\(lyricsSet.numberOfLines) lines"
            
            cell.profileName.text = lyricsSet.userName
            cell.dateLabel.text = lyricsSet.updatedAt
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
            
            let tabsInOneSection = allTabsSets[indexPath.section]
            let tabsSet: DownloadedTabsSet = tabsInOneSection![indexPath.row]
            
            if indexPath.section == 0 {

                CoreDataManager.setLocalTabsMostRecent(self.mediaItem)
                self.songViewController.updateMusicData(self.mediaItem)
                 self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                APIManager.downloadTabsSetContent(tabsSet, completion: {
                    download in
                    
                    var times = [NSTimeInterval]()
                    for t in download.times {
                        times.append(NSTimeInterval(t))
                    }
                    
                    CoreDataManager.saveTabs(self.mediaItem, chords: download.chords, tabs: download.tabs, times: times, tuning: download.tuning, capo: download.capo, tabsSetId: download.id)
                    
                    self.songViewController.updateMusicData(self.mediaItem)
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        } else {
            let lyricsSet = downloadedLyricsSets[indexPath.row]
            APIManager.downloadLyricsSetContent(lyricsSet, completion: {
                download in
                
                let lyricsToBeUsed = Lyric()
                for i in 0..<download.times.count {
                    lyricsToBeUsed.addLine(TimeNumber(time: download.times[i]), str: download.lyrics[i])
                }
                
                self.songViewController.lyric = lyricsToBeUsed
                 self.dismissViewControllerAnimated(true, completion: nil)

            })
        }
       

    }
    
    func upVoted(button: UIButton) {
        
        //show sign up screen if no user found
        if shouldShowSignUpPage() {
            return
        }
        
        let downloadedTabsSets = allTabsSets[1]
        
        let id = isPullingTabs ? downloadedTabsSets![button.tag].id : downloadedLyricsSets[button.tag].id
        
        APIManager.updateVotes(true, isTabs: isPullingTabs, setId: id, completion: {
            voteStatus, voteScore in
            
            if self.isPullingTabs {
                downloadedTabsSets![button.tag].voteStatus = voteStatus
                downloadedTabsSets![button.tag].votesScore = voteScore
            } else {
                self.downloadedLyricsSets[button.tag].voteStatus = voteStatus
                self.downloadedLyricsSets[button.tag].votesScore = voteScore
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.resultsTableView.reloadData()
            }
            
        })

        print("up button: \(button.tag) pressed")
    }
    
    func downVoted(button: UIButton) {
        
        if shouldShowSignUpPage() {
            return
        }
        
        let downloadedTabsSets = allTabsSets[1]
        
        let id = isPullingTabs ? downloadedTabsSets![button.tag].id : downloadedLyricsSets[button.tag].id
        APIManager.updateVotes(false, isTabs: isPullingTabs, setId: id, completion: {
            voteStatus, voteScore in
            
            if self.isPullingTabs {
                downloadedTabsSets![button.tag].voteStatus = voteStatus
                downloadedTabsSets![button.tag].votesScore = voteScore
            } else {
                self.downloadedLyricsSets[button.tag].voteStatus = voteStatus
                self.downloadedLyricsSets[button.tag].votesScore = voteScore
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.resultsTableView.reloadData()
            }
        })
        print("down button: \(button.tag) pressed")
    }
    
    
    func shouldShowSignUpPage() -> Bool {
        //show sign up screen if no user found
        if CoreDataManager.getCurrentUser() == nil {
            let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("meloginVC") as! MeLoginOrSignupViewController
            signUpVC.showCloseButton = true
            self.presentViewController(signUpVC, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}