//
//  SearchResult.swift
//  JamAlpha2
//
//  Created by Song Liao on 1/28/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchResult: NSObject {
    
    var songId = 0 //jamApi's song id, used to match core data song database
    var trackId = 0 //iTunes id
    var trackName = ""
    var artistName = ""
    var collectionName = ""
    var trackTimeMillis: Float = 0.0 //in milliseconds
    
    var artworkUrl100 = ""//large 100
    var previewUrl = ""
    var trackViewUrl = "" // link to apple music or iTunes
    
    var image: UIImage?
    
    var mediaItem: MPMediaItem?
    
    override init() {
        
    }
    
    init(songId: Int, trackId: Int, title: String, artist: String, duration: Float, previewUrl: String, trackViewUrl: String, artwork: String) {
        self.songId = songId
        self.trackId = trackId
        self.trackName = title
        self.artistName = artist
        self.trackTimeMillis = duration
        self.previewUrl = previewUrl
        self.trackViewUrl = trackViewUrl
        self.artworkUrl100 = artwork
    }
    
    func findMediaItem() {
        if let song = CoreDataManager.findSongById(songId) {
            self.mediaItem = MusicManager.sharedInstance.uniqueSongs.filter{
                item in
                if song.title.lowercaseString == item.getTitle().lowercaseString && song.artist.lowercaseString == item.getArtist().lowercaseString && abs(Float(song.playbackDuration) - item.getDuration()) < 2 {
                    return true
                }
                return false
            }.first
            
        }
    }

}
