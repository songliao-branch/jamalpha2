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

    var lyricsPreview = ""
    var numberOfLines = 0
    
    var votesScore = 0
    var voteStatus = "" //up, down, yet, not applicable
    
    var editor: Editor!//owner of this tabs
    var updatedAt = "" //TODO: change to a string
    
    //retrieved later when user clicks one of the lyricsSet in the list
    var lyrics = [String]()
    var times = [Float]()

    //only needed when in buck list for a user 
    var song_id = -1
    var title = ""
    var artist = ""
    var duration: Float = 0
    
    init(id: Int, lyricsPreview: String, numberOfLines: Int, votesScore: Int, voteStatus: String, editor: Editor, updatedAt: String) {
        self.id = id
        self.lyricsPreview = lyricsPreview
        self.numberOfLines = numberOfLines
        self.votesScore = votesScore
        self.voteStatus = voteStatus
        self.editor = editor
        self.updatedAt =  NSDate.convertFromIsoToHumanizedFormat(updatedAt)
    }
    
    override init() {
        // perform some initialization here
    }
    
    func initialLyricsSet(id: Int, cached_votes_score: Int, number_of_lines: Int, lyrics_preview: String, vote_status: String, updated_at: String, song_id: Int, title: String, artist: String, duration: Float) {
        self.id = id
        self.votesScore = cached_votes_score
        self.numberOfLines = number_of_lines
        self.lyricsPreview = lyrics_preview
        self.voteStatus = vote_status
        self.updatedAt = NSDate.convertFromIsoToHumanizedFormat(updated_at)
        self.song_id = song_id
        self.title = title
        self.artist = artist
        self.duration = duration
    }
}

class LocalLyrics {
    var id = -1
    var localSong: Song!
    
    init(id: Int, song: Song) {
        self.id = id
        self.localSong = song
    }
}

