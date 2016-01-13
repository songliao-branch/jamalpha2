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
    
    var searchResult: SearchResult? //if mediaItem is not found, we find a corresponding API object
    
    init(title: String, artist: String, duration: Float) {
        self.title = title
        self.artist = artist
        self.duration = duration
    }
    
    func findMediaItem() {
        self.mediaItem = MusicManager.sharedInstance.uniqueSongs.filter{
            item in
            if let itemTitle = item.title, itemArtist = item.artist {
                return itemTitle.lowercaseString == title.lowercaseString && itemArtist.lowercaseString == artist.lowercaseString && abs((Float(item.playbackDuration) - duration)) < 1.5
            }
            return false
        }.first
    }
    
    func findSearchResult(completion: ((searchResult: SearchResult) -> Void)) {
        if mediaItem == nil {
            SearchAPI.searchSong(title + " " + artist, completion: {
                results in
                for result in results {
                    if result.getTitle().lowercaseString == self.title.lowercaseString && result.getArtist().lowercaseString == self.artist.lowercaseString && abs(result.getDuration() - self.duration) < 1.5 {
                        completion(searchResult: result)
                        break
                    }
                }
            })
        }
    }
}
