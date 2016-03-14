//
//  TopSongsViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 1/12/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer
import Haneke

//TODO: this view controller has exactly same function as my favorites view controller, depending on the future designs we separate this controller as an indvidual
class TopSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topSongsTable: UITableView?
    var player: MPMusicPlayerController! // set to singleton in MusicManager
    
    var songs = [SearchResult]()
    var animator: CustomTransitionAnimation?
    var isSeekingPlayerState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MusicManager.sharedInstance.player
        createTransitionAnimation()
        setUpNavigationBar()
        setUpTopSection()
        setUpRefreshControl()
        loadData()
        setUpNowView()
        registerNotifications()
    }
  
    func setUpRefreshControl() {
        topSongsTable?.addPullToRefresh {
            self.loadData()
        }
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func loadData() {
        APIManager.getTopSongs({
            songs in
            self.songs = songs
            //TODO: this crashes somehow, needs to find out how to reproduce the crash
            if let table = self.topSongsTable {
              dispatch_async(dispatch_get_main_queue()){
                  table.reloadData()
              }
            }
        })
    }
  
    func registerNotifications() {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playbackStateChanged:"), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: MusicManager.sharedInstance.player)
    }
  
    func playbackStateChanged(notification: NSNotification){
      let playbackState = player.playbackState
      if playbackState == .Playing {
        KGLOBAL_nowView_topSong.start()
      } else  {
        KGLOBAL_nowView_topSong.stop()
      }
    }
  
    func setUpNowView() {
      KGLOBAL_nowView_topSong.frame = CGRectMake(self.view.frame.width-55 ,0 ,45 , 40)
      let tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("goToNowPlaying"))
      KGLOBAL_nowView_topSong.addGestureRecognizer(tapRecognizer)
      self.navigationController!.navigationBar.addSubview(KGLOBAL_nowView_topSong)
      
      if player.playbackState == .Playing {
        KGLOBAL_nowView_topSong.start()
      } else {
        KGLOBAL_nowView_topSong.stop()
      }
    }
  
    func goToNowPlaying(){
      let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
      
      if MusicManager.sharedInstance.avPlayer.currentItem != nil {
        songVC.isDemoSong = true
      }
      
      songVC.selectedFromTable = false
      songVC.transitioningDelegate = self.animator
      self.animator!.attachToViewController(songVC)
      self.navigationController!.presentViewController(songVC, animated: true, completion: nil)
    }
  
    func setUpNavigationBar() {
        self.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.5)
        self.navigationController?.navigationBar.translucent = false
//        let titleImageView: UIImageView = UIImageView()
//        titleImageView.frame = CGRectMake(0, 0, self.view.frame.width/2, 22)
//        titleImageView.image = UIImage(named: "topSongsText")
//        titleImageView.contentMode = .ScaleAspectFit
//        self.navigationItem.titleView = titleImageView
        
        
    }
    
    //a horizontal scrollview for 15 top songs
    func setUpTopSection() {
        
        
        
        
        let topSectionHeight: CGFloat = 160
        self.topSongsTable?.contentInset = UIEdgeInsetsMake(topSectionHeight, 0, 0, 0)
        
        //white background
        let sectionBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: topSectionHeight))
        sectionBackground.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(sectionBackground)
        
        //Top 100 button
        let topSongPromptButton = UIButton(frame: CGRect(x: 9, y: 14, width: 200, height: 18))
        topSongPromptButton.setTitle("Top 100 >", forState: .Normal)
        topSongPromptButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        sectionBackground.addSubview(topSongPromptButton)

        //scrollview
        let padding: CGFloat = 5
        let scrollview = UIScrollView(frame: CGRect(x: 0, y: CGRectGetMaxY(topSongPromptButton.frame) + padding, width: self.view.frame.width, height: topSectionHeight - padding - CGRectGetMaxY(topSongPromptButton.frame)))
        sectionBackground.addSubview(scrollview)
        
        
        
    }
    
    func createTopSongCard(index: Int, song: SearchResult) {
        let imageDimension: CGFloat = 90
        let albumImage = UIImageView(frame: CGRect(x: 0, y: 0, width: imageDimension, height: imageDimension))
        
//        
//        cell.albumImage.image = nil
//        let url = NSURL(string: song.artworkUrl100)!
//        let fetcher = NetworkFetcher<UIImage>(URL: url)
//        
//        let cache = Shared.imageCache
//        cache.fetch(fetcher: fetcher).onSuccess { image in
//            cell.albumImage.image = image
//        }
//        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TopSongsCell", forIndexPath: indexPath) as! TopSongsCell
        let song = songs[indexPath.row]
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.titleLabel.text = song.trackName
        cell.subtitleLabel.text = song.artistName
        
        //toggle speaker icon for current playing item
        cell.speaker.hidden = true
        cell.titleRightConstraint.constant = 20
        if let item = song.mediaItem {
            if MusicManager.sharedInstance.player.nowPlayingItem == item {
                cell.speaker.hidden = false
                cell.titleRightConstraint.constant = 50
            }
        }
        
        cell.albumImage.image = nil
        let url = NSURL(string: song.artworkUrl100)!
        let fetcher = NetworkFetcher<UIImage>(URL: url)
        
        let cache = Shared.imageCache
        cache.fetch(fetcher: fetcher).onSuccess { image in
            cell.albumImage.image = image
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        isSeekingPlayerState = true
        
        let song = songs[indexPath.row]
        song.findMediaItem()
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        songVC.selectedFromTable = true
        
        if let item = song.mediaItem {
            MusicManager.sharedInstance.setPlayerQueue([item])
            MusicManager.sharedInstance.setIndexInTheQueue(0)
            MusicManager.sharedInstance.avPlayer.pause()
            MusicManager.sharedInstance.avPlayer.seekToTime(kCMTimeZero)
            MusicManager.sharedInstance.avPlayer.removeAllItems()
            
            if(item.cloudItem && NetworkManager.sharedInstance.reachability.isReachableViaWWAN() ){
                dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                    while (self.isSeekingPlayerState){
                        
                        if(MusicManager.sharedInstance.player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex){
                            MusicManager.sharedInstance.player.stop()
                            KGLOBAL_nowView.stop()
                          KGLOBAL_nowView_topSong.stop()
                            dispatch_async(dispatch_get_main_queue()) {
                                self.showCellularEnablesStreaming(tableView)
                            }
                            self.isSeekingPlayerState = false
                            break
                        }
                        if(MusicManager.sharedInstance.player.indexOfNowPlayingItem == MusicManager.sharedInstance.lastSelectedIndex && MusicManager.sharedInstance.player.playbackState != .SeekingForward){
                            if(MusicManager.sharedInstance.player.nowPlayingItem != nil){
                                dispatch_async(dispatch_get_main_queue()) {
                                    songVC.selectedFromTable = true
                                    songVC.parentController = self
                                    songVC.transitioningDelegate = self.animator
                                    self.animator!.attachToViewController(songVC)
                                    self.presentViewController(songVC, animated: true, completion: {
                                        completed in
                                        //reload table to show loudspeaker icon on current selected row
                                        tableView.reloadData()
                                    })
                                }
                                self.isSeekingPlayerState = false
                                break
                            }
                        }
                    }
                }
            }else if (NetworkManager.sharedInstance.reachability.isReachableViaWiFi() || !item.cloudItem){
                isSeekingPlayerState = false
                if(MusicManager.sharedInstance.player.nowPlayingItem == nil){
                    MusicManager.sharedInstance.player.play()
                }
                songVC.selectedFromTable = true
                songVC.parentController = self
                songVC.transitioningDelegate = self.animator
                self.animator!.attachToViewController(songVC)
                self.presentViewController(songVC, animated: true, completion: {
                    completed in
                    //reload table to show loudspeaker icon on current selected row
                    tableView.reloadData()
                })
            } else if ( !NetworkManager.sharedInstance.reachability.isReachable() && item.cloudItem) {
                isSeekingPlayerState = false
                MusicManager.sharedInstance.player.stop()
                KGLOBAL_nowView.stop()
                KGLOBAL_nowView_topSong.stop()
                self.showConnectInternet(tableView)
            }
            
        } else { //if the mediaItem is not found, and an searchResult is found
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopSongsCell

            isSeekingPlayerState = false
            songVC.isSongNeedPurchase = true
            songVC.songNeedPurchase = song
            songVC.parentController = self
            songVC.reloadBackgroundImageAfterSearch(song)
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            self.presentViewController(songVC, animated: true, completion: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

}