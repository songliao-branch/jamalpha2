//
//  MyTabsViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/10/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class MyTabsAndLyricsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var isViewingTabs = true //false means lyrics

    @IBOutlet weak var tableView: UITableView!
    
    let cellHeight: CGFloat = 60
    //title, artist, "1"(uploaded), "unpressed", songId, set id
    //var myDataArray: [(String, String, String, String, Int, Int)] = [(String, String, String, String, Int, Int)]()
  
    var songs = [LocalSong]()//for showing title and artist for the tableview
    var lastInsertedRow = -1
    let optionPlaceHolderTitle = "..optionPlaceHolderTitle"//used to identify a placeholder inserted to songs to instantiate an options cell
    var allTabsSets = [DownloadedTabsSet]()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        loadData()
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
            for t in CoreDataManager.getAllUserTabsOnDisk() {
                let song = LocalSong(title: t.title, artist: t.artist, duration: t.duration)
                songs.append(song)
                print("USER TABS: \(t.title)  and  chords are \(t.chords[0])")

            }
        } else {
             self.navigationItem.title = "My Lyrics"
        }
    }

    func optionsButtonPressed(sender: UIButton) {
        print("last inserted row is: \(lastInsertedRow), current pressed is \(sender.tag)")
        
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
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserTabsLyricsCell", forIndexPath: indexPath) as! UserTabsLyricsCell
            cell.numberLabel.text = "\(indexPath.row + 1)."

            cell.titleLabel.text = song.title
            cell.artistLabel.text = song.artist
            
            cell.optionsButton.tag = indexPath.row
            cell.optionsButton.addTarget(self, action: "optionsButtonPressed:", forControlEvents: .TouchUpInside)
            
            return cell
        }

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellHeight
    }
    
}
