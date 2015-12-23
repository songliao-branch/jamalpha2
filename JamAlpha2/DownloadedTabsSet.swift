//
//  DownloadedTabsSet.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/12/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

struct Editor {
    var userId = -1
    var nickname = ""
    var avatarUrlMedium = ""
    var avatarUrlThumbnail = ""
}

class DownloadedTabsSet: NSObject {
    var id = -1
    //these varibles are required for showing the array of DownloadedTabs in the browse tableview
    var tuning = ""
    var capo = 0
    var chordsPreview = ""

    var votesScore = 0
    var voteStatus = ""//return "up", "down" ,"yet" vote status for current user, if not logged in show 
    //"no user applicable"
    var editor: Editor!//owner of this tabs
    var updatedAt = "" //TODO: change to a string
    
 
    //these variables are downloaded again when a single tabsSet is selected
    var chords = [String]()
    var tabs = [String]()
    var times = [Float]()
    
    //only needed when this comes in a buck list for a user
    //when first signed in and initialized all tabs of the user, we need to match this with current database
    var song_id = -1
    var title = ""
    var artist = ""
    var duration: Float = 0
    
    init(id: Int, tuning: String, capo: Int, chordsPreview: String, votesScore: Int, voteStatus: String, editor: Editor, updatedAt: String) {
        self.id = id
        self.tuning = tuning
        self.capo = capo
        self.chordsPreview = chordsPreview
        self.votesScore = votesScore
        self.voteStatus = voteStatus
        self.editor = editor
        self.updatedAt = NSDate.convertFromIsoToHumanizedFormat(updatedAt)
    }
    
    func findSongInCoreData(findable: Findable) -> Bool {
        if self.title == findable.getTitle() && artist == findable.getArtist() && abs(self.duration-findable.getDuration()) < 1 {
            return true
        }
        return false
    }
    
//    func initialTabSet(id: Int, tuning: String, capo: Int, cached_votes_score: Int, chords_preview: String, vote_status: String, updated_at: String, song_id: Int, title: String, artist: String, duration: Float) {
//        self.id = id
//        self.tuning = tuning
//        self.capo = capo
//        self.votesScore = cached_votes_score
//        self.chordsPreview = chords_preview
//        self.voteStatus = vote_status
//        self.updatedAt = NSDate.convertFromIsoToHumanizedFormat(updated_at)
//        self.song_id = song_id
//        self.title = title
//        self.artist = artist
//        self.duration = duration
//    }

}
//
//class LocalTabSet {
//    var id = -1
//    var localSong: Song!
//    
//    init(id: Int, song: Song) {
//        self.id = id
//        self.localSong = song
//    }
//}



