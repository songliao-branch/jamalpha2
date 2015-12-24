//
//  LocalSongs.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation

class LocalSong: NSObject {
     var title = ""
     var artist = ""
     var duration: Float = 0.0
    
    init(title: String, artist: String, duration: Float) {
        self.title = title
        self.artist = artist
        self.duration = duration
    }
}
