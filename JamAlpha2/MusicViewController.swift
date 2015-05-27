//
//  SecondViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit

class MusicViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    enum MUSIC_SELECTION_TYPE: Int {
        case TRACKS = 0
        case ARTIST = 1
        case ALBUM = 2
    }
    
    @IBOutlet weak var musicTable: UITableView!
    var demoTitles = ["彩虹", "Thinking out loud", "海阔天空","Sugar"]
    var demoArtist = ["周杰伦","Ed","Beyond","Maroon 5"]
   
    @IBOutlet weak var musicTypeSegment: UISegmentedControl!

    
    @IBAction func musicSelectionChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue {
        
            musicTable.reloadData()

            
        } else if sender.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
            
            musicTable.reloadData()
            
        } else if sender.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ALBUM.rawValue {
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.musicTable.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoTitles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("musiccell", forIndexPath: indexPath) as! MusicCell
        
        if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue {
            cell.titleLabel.text = demoTitles[indexPath.row]
            cell.subtitleLabel.text = demoArtist[indexPath.row]
            
        } else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
            
           cell.titleLabel.text = demoArtist[indexPath.row]
           cell.subtitleLabel.text = "1 Track"
            
        } else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ALBUM.rawValue {
            
        }
        
       
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.TRACKS.rawValue  {
            println("song \(indexPath.row) selected")
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailviewstoryboard") as! DetailViewController
            
            self.showViewController(detailVC, sender: self)
            
            
        }
        else if musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
             println("album \(indexPath.row) selected")
            let headVC = self.storyboard?.instantiateViewControllerWithIdentifier("headviewstoryboard") as! HeadViewController
            
            self.showViewController(headVC, sender: self)
            
        }
        else if  musicTypeSegment.selectedSegmentIndex == MUSIC_SELECTION_TYPE.ARTIST.rawValue {
            
        }
        self.musicTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "gosong" {
//            var detailVC = segue.destinationViewController as! DetailViewController
//            let index = self.musicTable.indexPathForSelectedRow()!.row
//            detailVC.demoString = demoArtist[index]
//            
//        }
//    }
//    
    
    
    
    

}

