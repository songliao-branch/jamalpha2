//
//  MyTabsViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/10/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

class MyTabsAndLyricsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var isViewingTabs = true //false means lyrics

    var animator: CustomTransitionAnimation?
    @IBOutlet weak var tableView: UITableView!
    
    let cellHeight: CGFloat = 60
    //title, artist, "1"(uploaded), "unpressed", songId, set id
    //var myDataArray: [(String, String, String, String, Int, Int)] = [(String, String, String, String, Int, Int)]()
  
    var songs = [LocalSong]()//for showing title and artist for the tableview
    
    var lastInsertedRow = -1
    let optionPlaceHolderTitle = "optionPlaceHolderTitle"//used to identify a placeholder inserted to songs to instantiate an options cell
    var allTabsSets = [DownloadedTabsSet]()
    var allLyricsSets = [DownloadedLyricsSet]()
    
    
    //status view pop up
    var statusView: UIView!
    var successImage: UIImageView!
    var failureImage: UIImageView!
    var statusLabel: UILabel!
    var hideStatusViewTimer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        createTransitionAnimation()
        loadData()
        setUpStatusView()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func setUpNavigationBar() {
        self.navigationItem.title = isViewingTabs ? "My Tabs" : "My Lyrics"
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
    }
    
    //also called when a set is deleted
    func loadData() {
        songs = [LocalSong]()
        if isViewingTabs {
            self.allTabsSets = CoreDataManager.getAllUserTabsOnDisk()
            for t in self.allTabsSets {
                let song = LocalSong(title: t.title, artist: t.artist, duration: t.duration)
                song.findMediaItem()
                songs.append(song)
            }
        } else {
            self.allLyricsSets = CoreDataManager.getAllUserLyricsOnDisk()
            for l in self.allLyricsSets {
                let song = LocalSong(title: l.title, artist: l.artist, duration: l.duration)
                song.findMediaItem()
                songs.append(song)
            }
        }
        
        lastInsertedRow = -1 //reset the insertedRow because all cells have been reset
        self.tableView.reloadData()
    }

    func optionsButtonPressed(sender: UIButton) {
        //TODO: UI bug: open last row's option, then this row
        
        //if an options cell is open
        if lastInsertedRow > 0 {
            //close it
            songs.removeAtIndex(lastInsertedRow)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: lastInsertedRow, inSection: 0)], withRowAnimation: .Automatic)
            
            //if selecting the same cell opened the options cell, the above close just fine
            if lastInsertedRow - 1 == sender.tag {
                lastInsertedRow = -1
            } else { //if select a different cell while the cell is open
                let index = NSIndexPath(forRow: sender.tag, inSection: 0)
                insertOptionsRow(index)
            }

        } else { //if no cells is open
            let index = NSIndexPath(forRow: sender.tag, inSection: 0)
            insertOptionsRow(index)
        }
    }
    
    func removeInsertedRow() {
        if lastInsertedRow > 0 {
            songs.removeAtIndex(lastInsertedRow)
            self.tableView.reloadData()
            lastInsertedRow = -1
        }
    }

    func insertOptionsRow(indexPath: NSIndexPath) {
        //remove last options row
        
        let placeHolder = LocalSong(title: optionPlaceHolderTitle, artist: "", duration: 0.0)
        songs.insert(placeHolder, atIndex: indexPath.row + 1)
        let pathToBeInserted = NSIndexPath(forRow: indexPath.row + 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([pathToBeInserted], withRowAnimation: .Automatic)
        lastInsertedRow = indexPath.row + 1
    }
    
    func pressEditButton(sender: UIButton) {
        // go to edit tab vc,
        let song = songs[sender.tag-1]
        guard let item = song.mediaItem else {
            print("no media item found for \(song.title)")
            return
        }
        
        if let _ = MusicManager.sharedInstance.player.nowPlayingItem {
            MusicManager.sharedInstance.player.pause()
        }
        
        if isViewingTabs {
            let tabsEditorVC = self.storyboard?.instantiateViewControllerWithIdentifier("tabseditorviewcontroller") as! TabsEditorViewController
            
            tabsEditorVC.theSong = item
            
            //  tabsEditorVC.isDemoSong = false
            self.presentViewController(tabsEditorVC, animated: true, completion: {
                completed in
                self.removeInsertedRow()
            })
            
            
        } else {
            let lyricsEditor = self.storyboard?.instantiateViewControllerWithIdentifier("lyricstextviewcontroller")
                as! LyricsTextViewController
            lyricsEditor.theSong = item
            self.presentViewController(lyricsEditor, animated: true, completion: {
                completed in
                self.removeInsertedRow()
            })
        }
    }
    
    func pressUploadButton(sender: UIButton) {
        
        let song = songs[sender.tag-1]
        guard let item = song.mediaItem else {
            print("no media item found for \(song.title)")
            return
        }
        
        if isViewingTabs {
            APIManager.uploadTabs(item, completion: {
                cloudId in
                
                CoreDataManager.saveCloudIdToTabs(item, cloudId: cloudId)
                self.showStatusView(true)
                self.startHideStatusViewTimer()
                self.loadData()
            })
        } else {
            APIManager.uploadLyrics(item, completion: {
                cloudId in
                
                CoreDataManager.saveCloudIdToLyrics(item, cloudId: cloudId)
                self.showStatusView(true)
                self.startHideStatusViewTimer()
                self.loadData()
            })
        }
    }
    
    func pressDeleteButton(sender: UIButton) {
        
        let song = songs[sender.tag-1]
        guard let item = song.mediaItem else {
            print("no media item found for \(song.title)")
            return
        }
        
        let id = isViewingTabs ? allTabsSets[sender.tag-1].id : allLyricsSets[sender.tag-1].id
        
        //delete local core data first
        if isViewingTabs {
            CoreDataManager.deleteLocalTab(item)
        } else {
            CoreDataManager.deleteLocalLyrics(item)
        }
        
        self.loadData()
        
        if id > 0 { //if this is cloud saved set, delete the cloud too
            APIManager.deleteSet(isTabs: isViewingTabs, id: id)
        }
    }

    //MARK: tableview delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let song = songs[indexPath.row] //TODO: Filter by edit date
        
        if song.title == optionPlaceHolderTitle {
            let cell = tableView.dequeueReusableCellWithIdentifier("OptionsCell", forIndexPath: indexPath) as! OptionsCell
            cell.editButton.tag = indexPath.row
            cell.editButton.addTarget(self, action: "pressEditButton:", forControlEvents: .TouchUpInside)
            cell.uploadButton.tag = indexPath.row
            cell.uploadButton.addTarget(self, action: "pressUploadButton:", forControlEvents: .TouchUpInside)
            
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: "pressDeleteButton:", forControlEvents: .TouchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserTabsLyricsCell", forIndexPath: indexPath) as! UserTabsLyricsCell
            cell.numberLabel.text = "\(indexPath.row + 1)."

            cell.titleLabel.text = song.title
            cell.artistLabel.text = song.artist
            
            cell.optionsButton.tag = indexPath.row
            
            if isViewingTabs {
                if allTabsSets[indexPath.row].id < 0 { //if tabsSet id less than 1, means not uploaded
                    cell.uploadedImage.hidden = true
                } else {
                    cell.uploadedImage.hidden = false
                }
            } else {
                if allLyricsSets[indexPath.row].id < 0 { //if tabsSet id less than 1, means not uploaded
                    cell.uploadedImage.hidden = true
                } else {
                    cell.uploadedImage.hidden = false
                }
            }
            
            cell.optionsButton.addTarget(self, action: "optionsButtonPressed:", forControlEvents: .TouchUpInside)
            
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let song = songs[indexPath.row]
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        songVC.selectedFromTable = true
        //TODO: fix this crash bug

        if let item = song.mediaItem {
            print("item found title:\(item.title!)")
            MusicManager.sharedInstance.setPlayerQueue([item])
            MusicManager.sharedInstance.setIndexInTheQueue(0)
            MusicManager.sharedInstance.avPlayer.pause()
            MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
            MusicManager.sharedInstance.avPlayer.removeAllItems()
        } else {
            //TODO: search the song first..
            
        }// TODO: if demo song
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        
        self.presentViewController(songVC, animated: true, completion: {
            completed in
            self.removeInsertedRow()
        })
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    
    func setUpStatusView() {
        statusView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        statusView.backgroundColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 0.80)
        statusView.hidden = true
        statusView.center = self.view.center
        statusView.layer.cornerRadius = 20
        self.view.addSubview(statusView)
        
        successImage = UIImageView(frame: CGRect(x: 0, y: 15, width: 40, height: 30))
        successImage.image = UIImage(named: "check")
        successImage.center.x = statusView.frame.width/2
        successImage.hidden = true
        statusView.addSubview(successImage)
        
        failureImage = UIImageView(frame: CGRect(x: 0, y: 15, width: 35, height: 35))
        failureImage.image = UIImage(named: "closebutton")
        failureImage.center.x = statusView.frame.width/2
        failureImage.hidden = true
        statusView.addSubview(failureImage)
        
        statusLabel = UILabel(frame: CGRect(x: 0, y: 55, width: 100, height: 35))
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.textAlignment = .Center
        statusLabel.font = UIFont.systemFontOfSize(16)
        statusLabel.center.x = statusView.frame.width/2
        statusView.addSubview(statusLabel)
    }
    
    func showStatusView(isSucess: Bool) {
        if isSucess {
            statusView.hidden = false
            successImage.hidden = false
            failureImage.hidden = true
            statusLabel.text = "Uploaded"
        } else {
            statusView.hidden = false
            successImage.hidden = true
            failureImage.hidden = false
            statusLabel.text = "Upload failed"
        }
    }
    
    func startHideStatusViewTimer() {
        hideStatusViewTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("hideStatusView"), userInfo: nil, repeats: false)
    }
    
    func hideStatusView() {
        statusView.hidden = true
    }
}
