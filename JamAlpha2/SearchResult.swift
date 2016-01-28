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
    
    //MARK: for top songs
    private var titleAliases = "" //the result returned from server may has name in many forms, if either of the name matches the mediaItem, we count it as a match
    private var artistAliases = ""
    
    var mediaItem: MPMediaItem?
    
    override init() {
        
    }
    
    init(id: Int, title: String, artist: String, duration: Float, previewUrl: String, trackViewUrl: String, artwork: String, titleAliases: String, artistAliases: String) {
        self.trackId = id
        self.trackName = title
        self.artistName = artist
        self.trackTimeMillis = duration
        self.previewUrl = previewUrl
        self.trackViewUrl = trackViewUrl
        self.artworkUrl100 = artwork
        self.titleAliases = titleAliases
        self.artistAliases = artistAliases
    }
    
    func findMediaItem() {
        self.mediaItem = MusicManager.sharedInstance.uniqueSongs.filter{
            item in
            let findable = item as Findable
            if self.titleAliases.lowercaseString.containsString(findable.getTitle().lowercaseString) && self.artistAliases.lowercaseString.containsString(findable.getArtist().lowercaseString) && abs(self.getDuration() - findable.getDuration()) < 2 {
                return true
            }
            return false
        }.first
    }
}
