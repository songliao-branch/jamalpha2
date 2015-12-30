//
//  MyFavoritesViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/11/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

class MyFavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var songs = [LocalSong]()
    var animator: CustomTransitionAnimation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTransitionAnimation()
        loadData()
        setUpNavigationBar()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }

    func loadData() {
        
        songs =  CoreDataManager.getFavorites()
        for song in songs {
            song.findMediaItem()
        }
        self.tableView.reloadData()

    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = "My Favorites"
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyFavoritesCell", forIndexPath: indexPath) as! MyFavoritesCell
        let song = songs[indexPath.row]
        cell.numberLabel.text = "\(indexPath.row+1)."
        cell.titleLabel.text = song.title
        cell.artistLabel.text = song.artist
        
        return cell
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let song = songs[indexPath.row]
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        songVC.selectedFromTable = true
        // TODO: fix this crash bug
        // songVC.transitioningDelegate = self.animator
        // self.animator!.attachToViewController(songVC)
        if let item = song.mediaItem {
            MusicManager.sharedInstance.setPlayerQueue([item])  //TODO: for a selection?
            MusicManager.sharedInstance.setIndexInTheQueue(0)
            MusicManager.sharedInstance.avPlayer.pause()
            MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
            MusicManager.sharedInstance.avPlayer.removeAllItems()
        } else if song.artist == "Alex Lisell" {
            
            MusicManager.sharedInstance.setDemoSongQueue(MusicManager.sharedInstance.demoSongs, selectedIndex: 0)
            songVC.selectedRow = 0
            MusicManager.sharedInstance.player.pause()
            MusicManager.sharedInstance.player.currentPlaybackTime = 0
            songVC.isDemoSong = true
            
        }
        
        songVC.transitioningDelegate = self.animator
        self.animator!.attachToViewController(songVC)
        
        self.presentViewController(songVC, animated: true, completion: nil)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}