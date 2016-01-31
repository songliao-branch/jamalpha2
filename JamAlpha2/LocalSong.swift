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
        //use a simple match first, make it faster, this is acceptable
        self.mediaItem = MusicManager.sharedInstance.uniqueSongs.filter{
            item in
            if title.lowercaseString == item.getTitle().lowercaseString && artist.lowercaseString == item.getArtist().lowercaseString && abs(duration - item.getDuration()) < 2 {
                return true
            }
            return false
        }.first
    }
    
    func findSearchResult(completion: ((searchResult: SearchResult?) -> Void)) {
        if mediaItem == nil {
            SearchAPI.searchSong(title + " " + artist, completion: {
                results in
                for result in results {
                    if MusicManager.sharedInstance.songsMatched(findableA: self, findableB: result) {
                        completion(searchResult: result)
                        return
                    }
                }
                completion(searchResult: nil)
            })
        }
    }
}
