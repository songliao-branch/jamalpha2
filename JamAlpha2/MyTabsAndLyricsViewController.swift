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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        createTransitionAnimation()
        loadData()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
    }
    
    func loadData() {
        if isViewingTabs {
            self.navigationItem.title = "My Tabs"
            self.allTabsSets = CoreDataManager.getAllUserTabsOnDisk()
            self.tableView.reloadData()
            for t in self.allTabsSets {
                let song = LocalSong(title: t.title, artist: t.artist, duration: t.duration)
                songs.append(song)
            }
        } else {
            self.navigationItem.title = "My Lyrics"
            self.allLyricsSets = CoreDataManager.getAllUserLyricsOnDisk()
            for l in self.allLyricsSets {
                let song = LocalSong(title: l.title, artist: l.artist, duration: l.duration)
                songs.append(song)
            }
        }
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
    }
    
    func pressUploadButton(sender: UIButton) {
        // upload the tab
       // changeUploadUnUpload()
    }
    
    func pressDeleteButton(sender: UIButton) {
        // upload the tab
        // changeUploadUnUpload()
    }
    
//    func changeUploadUnUpload() {
//        if selectRow.count > 0 {
//            if myDataArray[selectRow[0].item - 1].2 == "0" {
//                myDataArray[selectRow[0].item - 1].2 = "1"
//            } else {
//                myDataArray[selectRow[0].item - 1].2 = "0"
//            }
//            self.tableView.reloadData()
//        }
//    }

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
        
        let mediaItem = MusicManager.sharedInstance.uniqueSongs.filter{
            item in
            if let itemTitle = item.title, itemArtist = item.artist {
                return itemTitle == song.title && itemArtist == song.artist && abs((Float(item.playbackDuration) - song.duration)) < 1
            }
            return false
            }.first
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        songVC.selectedFromTable = true
        //TODO: fix this crash bug
        // songVC.transitioningDelegate = self.animator
        // self.animator!.attachToViewController(songVC)
        
        if let item = mediaItem {
            print("item found title:\(item.title!)")
            MusicManager.sharedInstance.setPlayerQueue([item])
            MusicManager.sharedInstance.setIndexInTheQueue(0)
            MusicManager.sharedInstance.avPlayer.pause()
            MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
            MusicManager.sharedInstance.avPlayer.removeAllItems()
        } else {
            //TODO: search the song first..
            
        }// TODO: if demo song
        
        self.presentViewController(songVC, animated: true, completion: nil)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellHeight
    }
    
}
