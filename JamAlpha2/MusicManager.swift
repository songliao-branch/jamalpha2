//
//  MusicManager.swift
//  JamAlpha2
//
//  Created by Song Liao on 8/28/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class MusicManager: NSObject {
    
    let _TAG = "MusicManager"
    var player: MPMusicPlayerController!
    
    var avPlayer: AVQueuePlayer!
    
    // A queue that keep tracks the last queue to the player
    // this should never be accessed outside MusicManager
    // a current collection is always passed in from function
    // 'setPlayerQueue'
    var lastPlayerQueue = [MPMediaItem]()
    var lastSelectedIndex = -1
    
    var uniqueSongs : [MPMediaItem]!
    var uniqueAlbums = [Album]()
    var uniqueArtists = [Artist]()
    
    var demoSongs: [AVPlayerItem]!
    var lastLocalPlayerQueue = [AVPlayerItem]()
    
    //in case mediaItem was changed outside the app when exit to background from Editor screen
    //we save these two so that when we come back we always have the correct item
    var lastPlayingItem: MPMediaItem!
    var lastPlayingTime: NSTimeInterval!

    
    class var sharedInstance: MusicManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: MusicManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = MusicManager()
        }
        return Static.instance!
    }
    
    override init() {
        super.init()
        loadLocalSongs()
        loadDemoSongs()
        loadLocalAlbums()
        loadLocalArtist()
        initializePlayer()
        addNotification()
    }
    
    //check when search a cloud item, if it matches, we use the song we already have
    func isNeedReloadCollections(title:String, artist:String, duration:Float) -> MPMediaItem? {
        let result = uniqueSongs.filter{
            (song: MPMediaItem) -> Bool in
            if let tempTitle = song.title, tempArtist = song.artist {
                return tempTitle.lowercaseString == title.lowercaseString && tempArtist.lowercaseString == artist.lowercaseString && abs((Float(song.playbackDuration) - duration))<1.5
            }
            return false
        }.first
        if(result != nil){
            return result!
        }
        return nil
    }
    
    func addNotification(){
        MPMediaLibrary.defaultMediaLibrary().beginGeneratingLibraryChangeNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "musicLibraryDidChange", name: MPMediaLibraryDidChangeNotification, object: nil)
    }
    
    func musicLibraryDidChange(){
        
        reloadCollections()
        
        let rootViewController = (UIApplication.sharedApplication().delegate as! AppDelegate).rootVC
        let currentVC = (UIApplication.sharedApplication().delegate as! AppDelegate).topViewController(rootViewController)
        
        let baseVC = ((rootViewController as! TabBarController).childViewControllers[0].childViewControllers[0]) as! BaseViewController
        let searchVC = ((rootViewController as! TabBarController).childViewControllers[1].childViewControllers[0]) as! SearchViewController
        
        // if the collection is different i.e. new songs are added/old songs are removed
        // we manually reload MusicViewController table
        for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
            musicVC.reloadDataAndTable()
            if(!musicVC.uniqueSongs.isEmpty){
                musicVC.songCount = 0
                musicVC.generateWaveFormInBackEnd(musicVC.uniqueSongs[Int(musicVC.songCount)])
            }
        }
        
        searchVC.uniqueSongs = MusicManager.sharedInstance.uniqueSongs
        if searchVC.searchResultTableView != nil && searchVC.resultSearchController.active {
            searchVC.filterLocalSongs(searchVC.resultSearchController.searchBar.text!)
            searchVC.searchResultTableView.reloadData() 
        }
       
        if(currentVC.isKindOfClass(SongViewController)){
            let currentSongVC = currentVC as! SongViewController
            if (currentSongVC.isSongNeedPurchase) {
                if let purchasedItem = (isNeedReloadCollections(currentSongVC.songNeedPurchase.trackName!, artist: currentSongVC.songNeedPurchase.artistName!, duration: currentSongVC.songNeedPurchase.trackTimeMillis!)){
                    setPlayerQueue([purchasedItem])
                    setIndexInTheQueue(0)
                    currentSongVC.recoverToNormalSongVC(purchasedItem)
                }
            }
        }
        
        let thirdBarItemVC = (rootViewController as! TabBarController).childViewControllers[2]
        
        if thirdBarItemVC.childViewControllers.count > 1 { //means navigation controller has at least pushed one view controller (the root navigation controller is UserProfileViewController)
            let firstPushedVC = thirdBarItemVC.childViewControllers[1]
            if firstPushedVC.isKindOfClass(MyTabsAndLyricsViewController) {
                let myTabsLyricsVC = firstPushedVC as! MyTabsAndLyricsViewController
                myTabsLyricsVC.loadData()
            } else if firstPushedVC.isKindOfClass(MyFavoritesViewController) {
                let myFavoritesVC = firstPushedVC as! MyFavoritesViewController
                myFavoritesVC.loadData()
            }
        }
    }
    
    func reloadCollections() {
        loadLocalSongs()
        loadLocalAlbums()
        loadLocalArtist()
        queueChanged = true
    }
    
    func initializePlayer(){
            print("\(_TAG) Initialize Player")
            player = MPMusicPlayerController.systemMusicPlayer()
            
            player.stop() // 如果不stop 有出现bug，让player还在播放状态时重启，点击now item, 滑动 progress bar, 自动变成TheAteam (列表里第一首歌)， 点击别的歌也是The A Team， 可能原因是没通过setIndex的任何set player.nowPlayingItem
            // 暂时解决方法 App每次start就是先停下来
            
            player.repeatMode = .All
            player.shuffleMode = .Off
            self.setPlayerQueue(uniqueSongs)
        
        //initialize AVQueuePlayer
            self.avPlayer = AVQueuePlayer()
            self.avPlayer.actionAtItemEnd = .None
            self.setSessionActiveWithMixing()
    }
    
    //for playing mode and background mode
    private func setSessionActiveWithMixing() {
        do {
            //set option DefaultToSpeaker so that demo song will not lag while soundwave is generating in the background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: .DefaultToSpeaker)
        } catch _ {
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
    }
    
    private var queueChanged = false
    
    func setDemoSongQueue(collection: [AVPlayerItem], selectedIndex:Int){
        if(avPlayer.currentItem == nil || avPlayer.currentItem != collection[selectedIndex]){
            avPlayer.removeAllItems()
            avPlayer.insertItem(collection[selectedIndex], afterItem: nil)
        }
    }

    func setPlayerQueue(collection: [MPMediaItem]){

        if lastPlayerQueue == collection { // if we are the same queue
           print("\(_TAG) same collection")
            queueChanged = false
        } else { //if different queue, means we are getting a new collection, reset the player queue
            player.setQueueWithItemCollection(MPMediaItemCollection(items: collection))
            lastPlayerQueue = collection
            print("\(_TAG) setting a new queue")
            
            print(MPMediaItemPropertyReleaseDate)
            
            queueChanged = true
            return
        }
        
        // after come back from music app which the current playing item is set to nil, we set the collection
        if(!queueChanged && player.nowPlayingItem == nil){
            player.setQueueWithItemCollection(MPMediaItemCollection(items: collection))
            lastPlayerQueue = collection
            print("Coming from Music app with no playing item \(_TAG) setting a new queue")
        
            queueChanged = true
            KGLOBAL_isNeedToCheckIndex = false
            return
        }
        
        //coming from music app to twistjam, if the queue is different, we reset the queue to newly selected queue

        if KGLOBAL_isNeedToCheckIndex {

            let repeatMode = player.repeatMode
            let shuffleMode = player.shuffleMode
            player.repeatMode = .All
            player.shuffleMode = .Off
            if (player.nowPlayingItem == nil) || (lastPlayerQueue.indexOf(player.nowPlayingItem!) != nil ? Int(lastPlayerQueue.indexOf(player.nowPlayingItem!)!) : -1) != player.indexOfNowPlayingItem {
                player.setQueueWithItemCollection(MPMediaItemCollection(items: collection))
                lastPlayerQueue = collection
                print("Queue is different,  now reset queue")
                
                queueChanged = true
            }
            KGLOBAL_isNeedToCheckIndex = false
            player.repeatMode = repeatMode
            player.shuffleMode = shuffleMode
        }
    }
    
    func setIndexInTheQueue(selectedIndex: Int){
        // player.stop()
        // 如果单曲循环的话 切出去 再换一首歌的话 还是之前那个首歌
        if player.repeatMode == .One && player.shuffleMode == .Off {
            player.repeatMode = .All  //暂时让他变成列表循环
            if player.nowPlayingItem != lastPlayerQueue[selectedIndex] || player.nowPlayingItem == nil {
                print("\(_TAG)  ")
                player.nowPlayingItem = lastPlayerQueue[selectedIndex]
            }
            player.repeatMode = .One
        } else { // for other repeat mode
            
            // if current playing song is not what we selected from the table
            if player.nowPlayingItem != lastPlayerQueue[selectedIndex] || player.nowPlayingItem == nil {
                player.prepareToPlay()
                player.nowPlayingItem = lastPlayerQueue[selectedIndex]
                
            } else {
                if queueChanged { // if we selected the same song from a different queue this time
                    let lastPlaybackTime = player.currentPlaybackTime
                    player.prepareToPlay() // set current playing index to zero
                    player.nowPlayingItem = lastPlayerQueue[selectedIndex] // this has a really short time lag
                    
                    player.currentPlaybackTime = lastPlaybackTime + 0.32
                }
            }
        }
        lastSelectedIndex = selectedIndex
    }
    
    // MARK: get all MPMediaItems
    func loadLocalSongs(){
        uniqueSongs = [MPMediaItem]()
        let songCollection = MPMediaQuery.songsQuery()
        uniqueSongs = songCollection.items!.filter {
            song in
            song.playbackDuration > 30
        }
        
        //initialize everything in core data, the song needs to be in the coredata so that when we fetched all cloud tabs for the user it can find the right match immediately
        for song in uniqueSongs {
            CoreDataManager.initializeSongToDatabase(song)
        }
    }
    
    func loadDemoSongs() {
        //we have one demo song so far
        demoSongs = kSongNames.map {
            AVPlayerItem(URL: NSBundle.mainBundle().URLForResource($0, withExtension: "mp3")!)
        }
        
        for song in demoSongs {
            CoreDataManager.initializeSongToDatabase(song)
        }
    }
    
    func loadLocalAlbums(){
        uniqueAlbums = [Album]()
        //start new albums fresh
        var collectionInAlbum = [MPMediaItem]() // a collection of each album's represenstative item
        let albumQuery = MPMediaQuery()
        albumQuery.groupingType = MPMediaGrouping.Album
        for album in albumQuery.collections!{
            let representativeItem = album.representativeItem!
            
            //there is no song shorter than 30 seconds
            if representativeItem.playbackDuration < 30 { continue }
            
            collectionInAlbum.append(representativeItem)
            let thisAlbum = Album(theItem: representativeItem)
            uniqueAlbums.append(thisAlbum)
        }
    }
    
    //load artist must be called after getting all albums
    func loadLocalArtist() {
        uniqueArtists = [Artist]()
        
        var artistDictionary = [String: [Album]]() //key is artistName
        for album in uniqueAlbums {
            if artistDictionary[album.artistName] == nil {
                artistDictionary [album.artistName] = []
            }
            artistDictionary [album.artistName]?.append(album)
        }
        
        for artist in artistDictionary {
            let theArtist = Artist(artist: artist.0)
            
            let albumsByYearDescending = artist.1.sort({ album1, album2 in
                return album1.yearReleased > album2.yearReleased
            })
            
            for album in albumsByYearDescending {
                theArtist.addAlbum(album)
            }
            uniqueArtists.append(theArtist)
        }
        //sort by artist name ascending
        uniqueArtists.sortInPlace({
            artist1, artist2 in
            return artist1.artistName < artist2.artistName
        })
    }

    // we manually set the repeat mode to one before going to tabs or lyrics Editor
    // we save the shuffle, repeat, currentPlaying time state so that when we come back from editors we can resume correctly
    func saveMusicPlayerState(collection: [MPMediaItem]) -> (MPMusicRepeatMode, MPMusicShuffleMode, NSTimeInterval) {
        let previousRepeatMode: MPMusicRepeatMode = player.repeatMode
        let previousShuffleMode: MPMusicShuffleMode = player.shuffleMode
        let previousPlayingTime: NSTimeInterval = player.currentPlaybackTime
        player.repeatMode = .One
        player.shuffleMode = .Off
        player.currentPlaybackTime = 0
        
        return (previousRepeatMode, previousShuffleMode, previousPlayingTime)
    }
    
    // back to song view controller recover queue
    func recoverMusicPlayerState(sender: (MPMusicRepeatMode, MPMusicShuffleMode, NSTimeInterval), currentSong: MPMediaItem) {
        player.repeatMode = sender.0
        player.shuffleMode = sender.1
        player.currentPlaybackTime = sender.2
    }
}