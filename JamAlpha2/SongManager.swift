//
//  SongManager.swift
//  JamAlpha2
//
//  Created by Song Liao on 8/27/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation
import MediaPlayer

class SongManager: NSObject {
    
    private var allSongs = [Song]()
    
    class var sharedInstance: SongManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SongManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SongManager()
        }
        return Static.instance!
    }
    
    override init() {
        super.init()
        loadAllSongs()
    }
    
    func getAllSongs() -> [Song]{
        return allSongs
    }
    
    func getAllMediaItems() -> [MPMediaItem]{
        var items = [MPMediaItem]()
        for song in allSongs{
            items.append(song.mediaItem)
        }
        return items
    }
    
    func loadAllSongs(){
        var songCollection = MPMediaQuery.songsQuery()
        var uniqueSongs = (songCollection.items as! [MPMediaItem]).filter({song in song.playbackDuration > 30 })
        for song in uniqueSongs {
            allSongs.append(Song(mediaItem: song))
        }
        
        
    }

}