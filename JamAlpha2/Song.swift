//
//  Song.swift
//  JamAlpha2
//
//  Created by Song Liao on 8/27/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.


import Foundation
import MediaPlayer


class Song: NSObject {
    
    var mediaItem: MPMediaItem!
    
    var title: String!
    var artist: String!
    var albumTitle: String!
    var playbackDuration: NSTimeInterval!
    
    var soundWave: SoundWaveView!
    var cache = NSCache()
    
    init(mediaItem: MPMediaItem){
        self.mediaItem = mediaItem
        
        // meta data from media item
        self.title = mediaItem.title
        self.artist = mediaItem.artist
        self.albumTitle = mediaItem.albumTitle
        self.playbackDuration = mediaItem.playbackDuration
        
    }
}
