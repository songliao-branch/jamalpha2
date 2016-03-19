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
    
    var topSongs = [SearchResult]()
    var freshChords = NSMutableSet()
    var animator: CustomTransitionAnimation?
    var isSeekingPlayerState = false
    var shouldLoadMoreChords = false
    var pageIndex = 1
    var viewdidAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MusicManager.sharedInstance.player
        createTransitionAnimation()
        setUpNavigationBar()
        setUpRefreshControl()
        loadData()
        setUpNowView()
        registerNotifications()
    }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    viewdidAppear = true
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
//        APIManager.getTopSongs({
//            songs in
//            self.topSongs = songs
//            //TODO: this crashes somehow, needs to find out how to reproduce the crash
//            if let table = self.topSongsTable {
//                  table.reloadData()
//            }
//        })
        shouldLoadMoreChords = false
        pageIndex = 1
        loadMoreFreshChords(pageIndex)
    }
  
  func loadMoreFreshChords(index: Int) {
    
    APIManager.downloadFreshChords(index, completion: {
        sets in
        
        if sets.isEmpty { return }
        
        self.freshChords.addObjectsFromArray(sets)
        self.pageIndex++
        if let table = self.topSongsTable {
            table.reloadData()
        }
        self.shouldLoadMoreChords = false
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
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.freshChords.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FreshChordsCell", forIndexPath: indexPath) as! FreshChordsCell
        
        let newSongs = freshChords.allObjects
        let newSong = newSongs[freshChords.allObjects.count - indexPath.row - 1] as! DownloadedTabsSet
        cell.titleLabel.text = newSong.song.trackName
        cell.subtitleLabel.text = newSong.song.artistName
        
        cell.albumImage.image = nil
        let url = NSURL(string: newSong.song.artworkUrl100)!
        let fetcher = NetworkFetcher<UIImage>(URL: url)
        
        let cache = Shared.imageCache
        cache.fetch(fetcher: fetcher).onSuccess { image in
            cell.albumImage.image = image
        }
        
        cell.contributorNameLabel.text = "by \(newSong.editor.nickname) \(NSDate.timeAgoSinceDate(newSong.lastEdited!, numericDates: true))"
        
        AWSS3Manager.downloadImage(newSong.editor.avatarUrlThumbnail, isProfileBucket: true,completion: {
            image in
            dispatch_async(dispatch_get_main_queue()) {
                cell.contributorImage.image = image
                cell.contributorImage.layer.cornerRadius = cell.contributorImage.frame.height/2
                cell.contributorImage.layer.masksToBounds = true
                }
            }
        )
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        isSeekingPlayerState = true
        
        let newSongs = freshChords.allObjects
        let newSong = newSongs[freshChords.allObjects.count - indexPath.row - 1] as! DownloadedTabsSet
        newSong.song.findMediaItem()
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        songVC.selectedFromTable = true
        
        if let item = newSong.song.mediaItem {
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
        
            isSeekingPlayerState = false
            songVC.isSongNeedPurchase = true
            songVC.songNeedPurchase = newSong.song
            songVC.parentController = self
            songVC.reloadBackgroundImageAfterSearch(newSong.song)
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            self.presentViewController(songVC, animated: true, completion: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}


extension TopSongsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if !viewdidAppear {
      return
    }
    if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
      if !shouldLoadMoreChords {
        shouldLoadMoreChords = true
        loadMoreFreshChords(pageIndex)
      }
    }
  }
}