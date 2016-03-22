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
    let indexOfFreshChords = 0
    let indexOfTopSongs = 1
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var player: MPMusicPlayerController! // set to singleton in MusicManager
    
    var refreshControl: UIRefreshControl!
    
    var topSongs = [SearchResult]()
    var freshChords = [DownloadedTabsSet]()
    var animator: CustomTransitionAnimation?
    var isSeekingPlayerState = false
    
    var shouldLoadMoreChords = false
    var pageIndexFreshChords = 1
    
    var shouldLoadMoreTopSongs = false
    var pageIndexTopSongs = 1
    
    var viewdidAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MusicManager.sharedInstance.player
        createTransitionAnimation()
        setUpNavigationBar()
        setUpRefreshControl()
        setUpNowView()
        registerNotifications()
        
        fetchFreshChords()
        fetchTopSongs()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewdidAppear = true
    }
    
    
    func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(TopSongsViewController.fetchSelected), forControlEvents: UIControlEvents.ValueChanged)
        self.topSongsTable!.addSubview(self.refreshControl) // not required when using UITableViewController
    }
    

    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
 
    func fetchFreshChords() {
        freshChords = [DownloadedTabsSet]()
        shouldLoadMoreChords = false
        pageIndexFreshChords = 1
        loadMoreFreshChords(pageIndexFreshChords)
    }
 
    func fetchTopSongs() {
        topSongs = [SearchResult]()
        shouldLoadMoreTopSongs = false
        pageIndexTopSongs = 1
        loadMoreTopSongs(pageIndexTopSongs)
    }
    
    func fetchSelected() {
        if segmentedControl.selectedSegmentIndex == indexOfFreshChords {
            fetchFreshChords()
        } else {
            fetchTopSongs()
        }
    }
    
    func loadMoreFreshChords(index: Int) {
        
        APIManager.downloadFreshChords(index, completion: {
            sets in
            
            if sets.isEmpty { return }
            
            for set in sets {
                self.freshChords.append(set)
            }
            
            self.pageIndexFreshChords+=1
            if let table = self.topSongsTable {
                table.reloadData()
            }
            self.shouldLoadMoreChords = false
            self.refreshControl.endRefreshing()
        })
    }
    
    func loadMoreTopSongs(index: Int) {
        APIManager.getTopSongs(index, completion: {
            songs in

            if songs.isEmpty { return }
            
            for song in songs {
                self.topSongs.append(song)
            }
            
            self.pageIndexTopSongs+=1
            self.shouldLoadMoreTopSongs = false
            if let table = self.topSongsTable {
                table.reloadData()
            }
            self.refreshControl.endRefreshing()
        })
    }
        
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TopSongsViewController.playbackStateChanged(_:)), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: MusicManager.sharedInstance.player)
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
        
        ///TODO: if now playing item nil, pressing this will crash?
        //BUG: play a normal song, go to a search song and preview, press now view, bang!
        //
        if MusicManager.sharedInstance.player.nowPlayingItem == nil {
            print("nothing cannot go to current playing screen")
            return
        }
        
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
        if segmentedControl.selectedSegmentIndex == indexOfFreshChords {
            return self.freshChords.count
        }
        return self.topSongs.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == indexOfFreshChords {
            return 120
        }
        return 90
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == indexOfFreshChords {
            let cell = tableView.dequeueReusableCellWithIdentifier("FreshChordsCell", forIndexPath: indexPath) as! FreshChordsCell
            
            let newSong = freshChords[indexPath.row]
            cell.titleLabel.text = newSong.song.trackName
            cell.subtitleLabel.text = newSong.song.artistName
            
            cell.albumImage.image = nil
            let url = NSURL(string: newSong.song.artworkUrl100)!
            let fetcher = NetworkFetcher<UIImage>(URL: url)
            
            let cache = Shared.imageCache
            cache.fetch(fetcher: fetcher).onSuccess { image in
                cell.albumImage.image = image
            }
            
            cell.contributorNameLabel.text = "\(newSong.editor.nickname)"
            
            cell.timeLabel.text = NSDate.timeAgoSinceDate(newSong.lastEdited!, numericDates: true)
            
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
            
        } else if segmentedControl.selectedSegmentIndex == indexOfTopSongs {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("TopSongCell", forIndexPath: indexPath) as! TopSongCell
            
            let topSong = topSongs[indexPath.row]
            cell.titleLabel.text = topSong.trackName
            cell.subtitleLabel.text = topSong.artistName
            cell.numberLabel.text = "\(indexPath.row + 1)."
            
            cell.albumImage.image = nil
            let url = NSURL(string: topSong.artworkUrl100)!
            let fetcher = NetworkFetcher<UIImage>(URL: url)
            
            let cache = Shared.imageCache
            cache.fetch(fetcher: fetcher).onSuccess { image in
                cell.albumImage.image = image
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        isSeekingPlayerState = true
        
        let song = segmentedControl.selectedSegmentIndex == indexOfFreshChords ? freshChords[indexPath.row].song : topSongs[indexPath.row]
        
        let songVC = self.storyboard?.instantiateViewControllerWithIdentifier("songviewcontroller") as! SongViewController
        
        song.findMediaItem()
        
        if let item = song.mediaItem {
            MusicManager.sharedInstance.setPlayerQueue([item])
            MusicManager.sharedInstance.setIndexInTheQueue(0)
            
            //if the cloud item is on LTE (not on wifi), since the music player can be still seeking and the player.nowPlayingItem might be nil, we are using a background thread to constantly check when it finishes seeking and return the item
            if item.cloudItem && NetworkManager.sharedInstance.reachability.isReachableViaWWAN() {
                //checkPlayerSeekingState(tableView, songVC: songVC)
                
                dispatch_async((dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))) {
                    while (self.isSeekingPlayerState) {
                        print("Running\(CACurrentMediaTime())")
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
                                    songVC.transitioningDelegate = self.animator
                                    self.animator!.attachToViewController(songVC)
                                    
                                    self.presentViewController(songVC, animated: true, completion: nil)
                                }
                                self.isSeekingPlayerState = false
                                break
                            }
                        }
                    }
                }
                
                //if not network
            } else if item.cloudItem && !NetworkManager.sharedInstance.reachability.isReachable() {
                isSeekingPlayerState = false
                MusicManager.sharedInstance.player.stop()
                self.showConnectInternet(tableView)
                
                // if it is a local song
            } else {
                isSeekingPlayerState = false
                songVC.selectedFromTable = true
                songVC.transitioningDelegate = self.animator
                self.animator!.attachToViewController(songVC)
                self.presentViewController(songVC, animated: true, completion: nil)
            }
            
        } else {
            
            songVC.isSongNeedPurchase = true
            songVC.songNeedPurchase = song
            songVC.parentController = self
            songVC.reloadBackgroundImageAfterSearch(song)
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            self.presentViewController(songVC, animated: true, completion: nil)
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    @IBAction func segmentSelected(sender: UISegmentedControl) {
        topSongsTable?.reloadData()
    }
}

extension TopSongsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !viewdidAppear {
            return
        }
    
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            if segmentedControl.selectedSegmentIndex == indexOfFreshChords {
                if !shouldLoadMoreChords {
                    shouldLoadMoreChords = true
                    loadMoreFreshChords(pageIndexFreshChords)
                }
            } else {
                if !shouldLoadMoreTopSongs {
                    shouldLoadMoreTopSongs = true
                    loadMoreTopSongs(pageIndexTopSongs)
                }
            }
        }
    }
}