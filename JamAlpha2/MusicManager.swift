//
//  MusicManager.swift
//  JamAlpha2
//
//  Created by Song Liao on 8/28/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation
import MediaPlayer
class MusicManager: NSObject {
    
    let _TAG = "MusicManager"
    var player: MPMusicPlayerController!
    
    // A queue that keep tracks the last queue to the player
    // this should never be accessed outside MusicManager
    // a current collection is always passed in from function
    // 'setPlayerQueue'
    private var lastPlayerQueue = [MPMediaItem]()
    
    var uniqueSongs : [MPMediaItem]!
    var uniqueAlbums = [Album]()
    var uniqueArtists = [Artist]()
    
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
        loadLocalAlbums()
        loadLocalArtist()
        initializePlayer()
    }
    
    func initializePlayer(){
        println("\(_TAG) Initialize Player")
        player = MPMusicPlayerController.systemMusicPlayer()
        
        player.stop() // 如果不stop 有出现bug，让player还在播放状态时重启，点击now item, 滑动 progress bar, 自动变成TheAteam (列表里第一首歌)， 点击别的歌也是The A Team， 可能原因是没通过setIndex的任何set player.nowPlayingItem
        // 暂时解决方法 App每次start就是先停下来
        player.repeatMode = .All
        player.shuffleMode = .Off
        
        self.setPlayerQueue(uniqueSongs)
    }
    

    func setPlayerQueue(collection: [MPMediaItem]){

        if lastPlayerQueue == collection { // if we are the same queue
           println("\(_TAG) same collection")
        } else { //if different queue, means we are getting a new collection, reset the player queue
            player.setQueueWithItemCollection(MPMediaItemCollection(items: collection))
            lastPlayerQueue = collection
            println("\(_TAG) setting a new queue")
            
            //testing
            for song in collection {
                println("\(_TAG) setting up queue of song: \(song.title)")
            }
        }
    }
    
    func setIndexInTheQueue(selectedIndex: Int){
        // 如果单曲循环的话 切出去 再换一首歌的话 还是之前那个首歌
        if player.repeatMode == .One && player.shuffleMode == .Off {
            player.repeatMode = .All  //暂时让他变成列表循环
            if player.nowPlayingItem != lastPlayerQueue[selectedIndex] || player.nowPlayingItem == nil {
                println("\(_TAG)  ")
                player.nowPlayingItem = lastPlayerQueue[selectedIndex]
            }
            player.repeatMode = .One //set player item 还是还原为单曲循环
        } else {  //如果是其他循环模式
            
            //如果现在播放的不是选中的
            if player.nowPlayingItem != lastPlayerQueue[selectedIndex] || player.nowPlayingItem == nil {
                player.nowPlayingItem = lastPlayerQueue[selectedIndex]
            }
        }
        
    }
    
    // MARK: get all MPMediaItems
    func loadLocalSongs(){
        var songCollection = MPMediaQuery.songsQuery()
        uniqueSongs = (songCollection.items as! [MPMediaItem]).filter({song in song.playbackDuration > 30 })
    }
    
    func loadLocalAlbums(){
        //start new albums fresh
        var collectionInAlbum = [MPMediaItem]() // a collection of each album's represenstative item
        var albumQuery = MPMediaQuery()
        albumQuery.groupingType = MPMediaGrouping.Album;
        for album in albumQuery.collections{
            var representativeItem = album.representativeItem as MPMediaItem
            
            //there is no song shorter than 30 seconds
            if representativeItem.playbackDuration < 30 { continue }
            
            collectionInAlbum.append(representativeItem)
            var thisAlbum = Album(theItem: representativeItem)
            uniqueAlbums.append(thisAlbum)
        }
    }
    
    //load artist must be called after getting all albums
    func loadLocalArtist(){
        
        var allArtistRepresentiveSong = [MPMediaItem]() // a list of one song per artist
        var artistQuery = MPMediaQuery()
        artistQuery.groupingType = MPMediaGrouping.Artist
        for artist in artistQuery.collections {
            var representativeItem = artist.representativeItem as MPMediaItem
            if representativeItem.playbackDuration < 30 { continue }
            allArtistRepresentiveSong.append(representativeItem)
            
            var artist = Artist(artist: representativeItem.artist)
            
            uniqueAlbums.sort({ album1, album2 in
                if let album1date = album1.releasedDate, let album2date = album2.releasedDate {
                    return album1date.isGreaterThanDate(album2date)
                } else {
                    return false
                }
            })
            
            for album in uniqueAlbums {
                if representativeItem.artistPersistentID == album.artistPersistantId {
                    artist.addAlbum(album)
                }
            }
            uniqueArtists.append(artist)
        }
    }

}