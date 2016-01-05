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
import Haneke
class BrowseVersionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var songViewController: SongViewController!
    
    var isPullingTabs = true //variable called when this viewcontroller is instantiated, a negative value means we are downloading lyrics
    
    @IBOutlet weak var resultsTableView: UITableView!

    var allTabsSets = [DownloadedTabsSet]()//only downloaded ones
    var allLyricsSets = [DownloadedLyricsSet]()
    
    var lastSelectedSetId = 0
    
    var findable: Findable!
    var songId = -1
    
    var centerButton: UIButton!//to display "Add your own tabs or lyrics if none is found"
    
    var awsS3: AWSS3Manager = AWSS3Manager()
    
    override func viewDidLoad() {

        setUpHeader()
        setUpCenterButton()
        let layer = UIView()
        layer.backgroundColor = UIColor.backgroundGray()
        resultsTableView.backgroundView = layer
        
        if isPullingTabs {
            ( _, _, _, lastSelectedSetId, _) = CoreDataManager.getTabs(findable, fetchingUsers: false)
        } else {
            (_, lastSelectedSetId) = CoreDataManager.getLyrics(findable, fetchingUsers: false)
        }

        fetchData()
    }

    func fetchData() {
        
        allTabsSets = [DownloadedTabsSet]()
        allLyricsSets = [DownloadedLyricsSet]()
        
        if isPullingTabs {
           
            APIManager.downloadTabs(findable, completion: {
                downloads in
                
                for download in downloads {
                    
                    self.allTabsSets.append(download)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultsTableView.reloadData()
                    
                    // if no local tabs and no downloaded tabs
                    if downloads.count < 1 {
                        self.centerButton.hidden = false
                    }
                }
            })
        } else {
            APIManager.downloadLyrics(findable, completion: {
                downloads in
                for download in downloads {
                    self.allLyricsSets.append(download)
                }
                
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
        
        let title:String = findable.getTitle()
        let attributedString = NSMutableAttributedString(string:title)
        songNameLabel.attributedText = attributedString
        songNameLabel.textAlignment = NSTextAlignment.Center
        
        artistNameLabel.text = findable.getArtist()
        
        
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
            return allTabsSets.count
        } else {
            return allLyricsSets.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("browseversionscell", forIndexPath: indexPath) as! BrowseVersionsCell
        
        if isPullingTabs {
            
            let tabsSet = allTabsSets[indexPath.row]
            
            var tuning = ""
            
            if tabsSet.tuning == "E-B-G-D-A-E-" {
                tuning = "standard"
            } else {
                tuning = tabsSet.tuning
            }
            
            if tabsSet.id < 0 {//my tabs
                cell.upVoteButton.hidden = true
                cell.downVoteButton.hidden = true
                cell.votesLabel.hidden = true
            } else {
                cell.upVoteButton.hidden = false
                cell.downVoteButton.hidden = false
                cell.votesLabel.hidden = false
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
            cell.dateLabel.text = NSDate.timeAgoSinceDate(tabsSet.lastEdited!, numericDates: true)
            
            //user section
            cell.profileName.text = tabsSet.editor.nickname
            
            cell.profileImage.image = nil
            awsS3.downloadImage(tabsSet.editor.avatarUrlThumbnail, completion: {
                image in
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.profileImage.image = image
                        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
                        cell.profileImage.layer.masksToBounds = true
                    }
                }
            )
          
            if tabsSet.id == lastSelectedSetId {
                cell.checkmark.hidden = false
                cell.previewRightConstraint.constant = 45
            } else {
                cell.checkmark.hidden = true
                cell.previewRightConstraint.constant = 8
            }
            
        } else {
            let lyricsSet = allLyricsSets[indexPath.row]

            if lyricsSet.id < 0 {//my tabs
                cell.upVoteButton.hidden = true
                cell.downVoteButton.hidden = true
                cell.votesLabel.hidden = true
            } else {
                cell.upVoteButton.hidden = false
                cell.downVoteButton.hidden = false
                cell.votesLabel.hidden = false
            }
            
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
            
            cell.profileName.text = lyricsSet.editor.nickname
            cell.dateLabel.text = NSDate.timeAgoSinceDate(lyricsSet.lastEdited!, numericDates: true)
            
        
            cell.profileImage.image = nil
            awsS3.downloadImage(lyricsSet.editor.avatarUrlThumbnail, completion: {
                image in
                dispatch_async(dispatch_get_main_queue()) {
                    cell.profileImage.image = image
                    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
                    cell.profileImage.layer.masksToBounds = true
                }
                }
            )
            
            if lyricsSet.id == lastSelectedSetId {
                cell.checkmark.hidden = false
                cell.previewRightConstraint.constant = 45
            } else {
                cell.checkmark.hidden = true
                cell.previewRightConstraint.constant = 8
            }

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
            
            let tabsSet = allTabsSets[indexPath.row]
            
            APIManager.downloadTabsSetContent(tabsSet, completion: {
                download in
                
                CoreDataManager.saveTabs(self.findable, chords: download.chords, tabs: download.tabs, times: download.times, tuning: download.tuning, capo: download.capo, userId: download.editor.userId, tabsSetId: download.id, visible: true)
                
                self.songViewController.updateMusicData(self.findable)
                
                self.dismissViewControllerAnimated(true, completion: nil)
               
            })
        } else {
            let lyricsSet = allLyricsSets[indexPath.row]
            APIManager.downloadLyricsSetContent(lyricsSet, completion: {
                download in
                
                CoreDataManager.saveLyrics(self.findable, lyrics: download.lyrics, times: download.times, userId: download.editor.userId, lyricsSetId: download.id)
                
                (self.songViewController.lyric, _) = CoreDataManager.getLyrics(self.findable, fetchingUsers: false)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    func upVoted(button: UIButton) {
        
        //show sign up screen if no user found
        if shouldShowSignUpPage() {
            return
        }
        
        let id = isPullingTabs ? allTabsSets[button.tag].id : allLyricsSets[button.tag].id
        
        APIManager.updateVotes(true, isTabs: isPullingTabs, setId: id, completion: {
            voteStatus, voteScore in
            
            if self.isPullingTabs {
                self.allTabsSets[button.tag].voteStatus = voteStatus
                self.allTabsSets[button.tag].votesScore = voteScore
            } else {
                self.allLyricsSets[button.tag].voteStatus = voteStatus
                self.allLyricsSets[button.tag].votesScore = voteScore
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                let i = NSIndexPath(forRow: button.tag, inSection: 1)
                self.resultsTableView.reloadRowsAtIndexPaths([i], withRowAnimation: UITableViewRowAnimation.None)
            }
            
        })

        print("up button: \(button.tag) pressed")
    }
    
    func downVoted(button: UIButton) {
        
        if shouldShowSignUpPage() {
            return
        }
        
        let id = isPullingTabs ? allTabsSets[button.tag].id : allLyricsSets[button.tag].id
        APIManager.updateVotes(false, isTabs: isPullingTabs, setId: id, completion: {
            voteStatus, voteScore in
            
            if self.isPullingTabs {
                self.allTabsSets[button.tag].voteStatus = voteStatus
                self.allTabsSets[button.tag].votesScore = voteScore
            } else {
                self.allLyricsSets[button.tag].voteStatus = voteStatus
                self.allLyricsSets[button.tag].votesScore = voteScore
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                let i = NSIndexPath(forRow: button.tag, inSection: 1)
                self.resultsTableView.reloadRowsAtIndexPaths([i], withRowAnimation: UITableViewRowAnimation.None)
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