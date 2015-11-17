//
//  DownloadedLyricsSet.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/16/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class DownloadedLyricsSet: NSObject {

    var id = -1
    var songId = -1
    var userId = -1
    var upVotes = 0
    var downVotes = 0
    var lyricsPreview = ""
    var numberOfLines = 0
    
    var lyrics = [String]()
    var times = [Float]()
    
    init(id: Int, songId: Int, userId: Int, upvotes: Int, downvotes: Int, lyricsPreview: String, lines: Int) {
        self.id = id
        self.songId = songId
        self.userId = userId
        self.upVotes = upvotes
        self.downVotes = downvotes
        self.lyricsPreview = lyricsPreview
        self.numberOfLines = lines
    }
    
}
