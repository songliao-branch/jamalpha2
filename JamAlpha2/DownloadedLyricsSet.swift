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
    var lyricsPreview = ""
    var numberOfLines = 0
    
    var votesScore = 0
    var voteStatus = "" //up, down, yet, not applicable
    
    var editor: Editor!//owner of this tabs
    var lastEdited = "" //TODO: change to a string
    
    //retrieved later when user clicks one of the lyricsSet in the list
    var lyrics = [String]()
    var times = [Float]()

    init(id: Int, songId: Int, lyricsPreview: String, numberOfLines: Int, votesScore: Int, voteStatus: String, editor: Editor, lastEdited: String) {
        self.id = id
        self.songId = songId
        self.lyricsPreview = lyricsPreview
        self.numberOfLines = numberOfLines
        self.votesScore = votesScore
        self.voteStatus = voteStatus
        self.editor = editor
        self.lastEdited =  NSDate.convertFromIsoToHumanizedFormat(lastEdited)
    }
}
