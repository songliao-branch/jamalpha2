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
    
    var songs = [SearchResult]()
    var newFreshSongs = NSMutableSet()
    var animator: CustomTransitionAnimation?
    var isSeekingPlayerState = false
    var isLoadingMoreData = true
    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTransitionAnimation()
        setUpNavigationBar()
        setUpRefreshControl()
        loadData()
      
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
        isLoadingMoreData = false
        pageIndex = 1
        loadNewFresh(pageIndex)
    }
  
  func loadNewFresh(index: Int) {
    APIManager.downloadFreshSongsInfo(index, completion: {
      downloadedTabsSet in
      if(downloadedTabsSet.isEmpty) {
        return
      }
      self.newFreshSongs.addObjectsFromArray(downloadedTabsSet)
      self.pageIndex++
      if let table = self.topSongsTable {
        dispatch_async(dispatch_get_main_queue()){
          table.reloadData()
          self.isLoadingMoreData = false
        }
      }
    })
    }
  
    
    func setUpNavigationBar() {
        self.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor().colorWithAlphaComponent(0.5)
        self.navigationController?.navigationBar.translucent = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + self.newFreshSongs.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? 160 : 90
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
    
            let cell = tableView.dequeueReusableCellWithIdentifier("TopSectionCell", forIndexPath: indexPath) as! TopSectionCell
            cell.sectionCollectionView.delegate = self
            cell.sectionCollectionView.dataSource = self
            cell.sectionCollectionView.reloadData()
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FreshChordsCell", forIndexPath: indexPath) as! FreshChordsCell
        let tempNewFreshSongs = newFreshSongs.allObjects
        let newFreshSong = tempNewFreshSongs[newFreshSongs.count - indexPath.row] as! DownloadedTabsSet
        cell.titleLabel.text = newFreshSong.song.trackName
        cell.subtitleLabel.text = newFreshSong.song.artistName
        
        cell.albumImage.image = nil
        let url = NSURL(string: newFreshSong.song.artworkUrl100)!
        let fetcher = NetworkFetcher<UIImage>(URL: url)
        
        let cache = Shared.imageCache
        cache.fetch(fetcher: fetcher).onSuccess { image in
            cell.albumImage.image = image
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        isSeekingPlayerState = true
        
        let tempNewFreshSongs = newFreshSongs.allObjects
        let newFreshSong = tempNewFreshSongs[newFreshSongs.count - indexPath.row] as! DownloadedTabsSet
        newFreshSong.song.findMediaItem()
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        songVC.selectedFromTable = true
        
        if let item = newFreshSong.song.mediaItem {
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
                self.showConnectInternet(tableView)
            }
            
        } else { //if the mediaItem is not found, and an searchResult is found
        
            isSeekingPlayerState = false
            songVC.isSongNeedPurchase = true
            songVC.songNeedPurchase = newFreshSong.song
            songVC.parentController = self
            songVC.reloadBackgroundImageAfterSearch(newFreshSong.song)
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            self.presentViewController(songVC, animated: true, completion: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

extension TopSongsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SongCardCell", forIndexPath: indexPath) as! SongCardCell
        let song = songs[indexPath.row]
        cell.titleLabel.text = song.trackName
        cell.subtitleLabel.text = song.artistName
        
        cell.albumImage.image = nil
        let url = NSURL(string: song.artworkUrl100)!
        let fetcher = NetworkFetcher<UIImage>(URL: url)
        
        let cache = Shared.imageCache
        cache.fetch(fetcher: fetcher).onSuccess { image in
            cell.albumImage.image = image
        }
        return cell
    }
}

extension TopSongsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
      if !isLoadingMoreData {
        isLoadingMoreData = true
        loadNewFresh(pageIndex)
      }
    }
  }
}