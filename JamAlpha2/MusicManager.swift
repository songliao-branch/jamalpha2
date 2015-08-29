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
    
    var player: MPMusicPlayerController!

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
        println("initialize Player")
        player = MPMusicPlayerController.systemMusicPlayer()
        
        player.stop()
        player.repeatMode = .All
        player.shuffleMode = .Off
        
        self.setPlayerQueue(uniqueSongs)
    }
    
    var lastPlayerQueue = [MPMediaItem]()
    
    func setPlayerQueue(collection: [MPMediaItem]){
        if lastPlayerQueue == collection { // if we are the same queue
           println("same collection")
        } else { //if different queue, means we are getting a new collection, reset the player queue
            player.setQueueWithItemCollection(MPMediaItemCollection(items: collection))
            lastPlayerQueue = collection
            println("setting a new queue")
            
            //testing
            for song in collection {
                println("setting up queue of song: \(song.title)")
            }
        }
    }
    
    func setIndexInTheQueue(selectedIndex: Int){
        if(player.repeatMode == .One && player.shuffleMode == .Off){
            player.repeatMode = .All
            if(player.nowPlayingItem != lastPlayerQueue[selectedIndex]||player.nowPlayingItem == nil){
                player.nowPlayingItem = lastPlayerQueue[selectedIndex]
            }
            player.repeatMode = .One
        }else{
            if(player.nowPlayingItem != lastPlayerQueue[selectedIndex]||player.nowPlayingItem == nil){
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