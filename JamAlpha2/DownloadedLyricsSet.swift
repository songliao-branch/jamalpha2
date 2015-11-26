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
    var lyricsPreview = ""
    var numberOfLines = 0
    
    var votesScore = 0
    var voteStatus = "" //up, down, yet, not applicable
    var lyrics = [String]()
    var times = [Float]()
    
    init(id: Int, songId: Int, userId: Int, votesScore: Int, lyricsPreview: String, lines: Int, voteStatus: String) {
        self.id = id
        self.songId = songId
        self.userId = userId
        self.votesScore = votesScore
        self.lyricsPreview = lyricsPreview
        self.numberOfLines = lines
        self.voteStatus = voteStatus
    }
    
}
