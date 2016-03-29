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
  
    var songs = [SearchResult]()//for showing title and artist for the tableview
    
    var allTabsSets = [DownloadedTabsSet]()
    var allLyricsSets = [DownloadedLyricsSet]()
    var isSeekingPlayerState = false
    
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
        setUpStatusView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func createTransitionAnimation(){
        if(animator == nil){
            self.animator = CustomTransitionAnimation()
        }
    }
    
    func setUpNavigationBar() {
        self.navigationItem.title = isViewingTabs ? "My Chords" : "My Lyrics"
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
    } 
    
    //also called when a set is deleted
    func loadData() {
        songs = [SearchResult]()
        if isViewingTabs {
            self.allTabsSets = CoreDataManager.getAllUserTabsOnDisk()
            for t in self.allTabsSets {
                print("MY Tabs song: \(t.song.songId),\(t.song.getTitle()),\(t.song.getArtist()),\(t.song.getDuration())")

                let song = SearchResult(songId: t.song.songId, title: t.song.getTitle(), artist: t.song.getArtist(), duration: t.song.getDuration())
                song.findMediaItem()
                songs.append(song)
            }
        } else {
            self.allLyricsSets = CoreDataManager.getAllUserLyricsOnDisk()
            for l in self.allLyricsSets {
                let song = SearchResult(songId: l.song.songId, title: l.song.getTitle(), artist: l.song.getArtist(), duration: l.song.getDuration())
                song.findMediaItem()
                songs.append(song)
            }
        }
        
        self.tableView.reloadData()
    }

    func optionsButtonPressed(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.goToEditor(sender.tag)
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.deleteSet(sender.tag)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        optionMenu.view.tintColor = UIColor.mainPinkColor()
    }
    
    func goToEditor(index: Int) {
        let song = songs[index]
        guard let item = song.mediaItem else {

            return
        }
        
        MusicManager.sharedInstance.player.pause()
        MusicManager.sharedInstance.setPlayerQueue([item])
        MusicManager.sharedInstance.setIndexInTheQueue(0)
        
        if isViewingTabs {
            let tabsEditorVC = self.storyboard?.instantiateViewControllerWithIdentifier("tabseditorviewcontroller") as! TabsEditorViewController
            
            CoreDataManager.setUserTabsMostRecent(item)
            tabsEditorVC.theSong = item
            
            
            self.presentViewController(tabsEditorVC, animated: true, completion: nil)
            
        } else {
            let lyricsEditor = self.storyboard?.instantiateViewControllerWithIdentifier("lyricstextviewcontroller")
                as! LyricsTextViewController
            CoreDataManager.setUserLyricsMostRecent(item)
            lyricsEditor.theSong = item
            self.presentViewController(lyricsEditor, animated: true, completion: nil)
        }
    }

    func deleteSet(index: Int) {
        let id = isViewingTabs ? allTabsSets[index].id : allLyricsSets[index].id
        
        //delete local core data first
        if isViewingTabs {
            CoreDataManager.deleteUserTabs(id)
        } else {
            CoreDataManager.deleteUserlyrics(id)
        }
        
        self.loadData()
        
        if id > 0 { //if this is cloud saved set, delete the cloud too
            APIManager.deleteSet(isTabs: isViewingTabs, id: id)
        }
    }

    //MARK: tableview delegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let song = songs[indexPath.row] //TODO: Filter by edit date
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTabsLyricsCell", forIndexPath: indexPath) as! UserTabsLyricsCell
        cell.numberLabel.text = "\(indexPath.row + 1)"

        cell.titleLabel.text = song.getTitle()
        cell.subtitleLabel.text = song.getArtist()
        
        cell.optionsButton.tag = indexPath.row
        cell.optionsButton.addTarget(self, action: #selector(MyTabsAndLyricsViewController.optionsButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        cell.spinner.hidden = true
        
        if let _ = song.mediaItem {
            cell.searchIcon.hidden = true
            cell.titleRightConstraint.constant = 35
            cell.subtitleRightConstraint.constant = 35
        } else {
            cell.searchIcon.hidden = false
            cell.titleRightConstraint.constant = 75
            cell.subtitleRightConstraint.constant = 75
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        isSeekingPlayerState = true
        
        let song = songs[indexPath.row]
        
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
        }  else if song.getArtist() == "Alex Lisell" { //if demo song
            isSeekingPlayerState = false

            MusicManager.sharedInstance.setDemoSongQueue(MusicManager.sharedInstance.demoSongs, selectedIndex: 0)
            songVC.selectedRow = 0
            songVC.parentController = self
            MusicManager.sharedInstance.player.pause()
            MusicManager.sharedInstance.player.currentPlaybackTime = 0
            songVC.isDemoSong = true
            
            songVC.transitioningDelegate = self.animator
            self.animator!.attachToViewController(songVC)
            
            self.presentViewController(songVC, animated: true, completion: nil)
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

            
        } else { //if the mediaItem is not found, and an searchResult is found
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserTabsLyricsCell
            
            cell.searchIcon.hidden = true
            cell.spinner.hidden = false
            cell.spinner.startAnimating()
            isSeekingPlayerState = false
            song.findSearchResult( {
                result in
                
                cell.spinner.stopAnimating()
                cell.spinner.hidden = true
                cell.searchIcon.hidden = false
                
                guard let song = result else {
                    
                    self.showMessage("Ooops.. we can't find this song in iTunes.", message: "", actionTitle: "OK", completion: nil)
                    return
                }
                
                songVC.isSongNeedPurchase = true
                songVC.parentController = self
                songVC.songNeedPurchase = song
                songVC.reloadBackgroundImageAfterSearch(song)
                songVC.transitioningDelegate = self.animator
                self.animator!.attachToViewController(songVC)
                self.presentViewController(songVC, animated: true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            })
        }
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
        hideStatusViewTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(MyTabsAndLyricsViewController.hideStatusView), userInfo: nil, repeats: false)
    }
    
    func hideStatusView() {
        statusView.hidden = true
    }
}
