//
//  LocalSongs.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import MediaPlayer

//a temporary object used for matching songs downloaded to our findables
class LocalSong: NSObject {
    var title = ""
    var artist = ""
    var duration: Float = 0.0
    
    var mediaItem: MPMediaItem? //it might or might not have a corresponding mediaItem found
    
    init(title: String, artist: String, duration: Float) {
        self.title = title
        self.artist = artist
        self.duration = duration
    }
    
    func findMediaItem(title: String, artist: String, duration: Float) {
        self.mediaItem = MusicManager.sharedInstance.uniqueSongs.filter{
            item in
            if let itemTitle = item.title, itemArtist = item.artist {
                return itemTitle == title && itemArtist == artist && abs((Float(item.playbackDuration) - duration)) < 1
            }
            return false
        }.first
    }
}
