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
    
    var songId = -1
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
    
    init(id: Int, songId: Int, tuning: String, capo: Int, chordsPreview: String, votesScore: Int, voteStatus: String, editor: Editor, updatedAt: String) {
        self.id = id
        self.songId = songId
        self.tuning = tuning
        self.capo = capo
        self.chordsPreview = chordsPreview
        self.votesScore = votesScore
        self.voteStatus = voteStatus
        self.editor = editor
        self.updatedAt = NSDate.convertFromIsoToHumanizedFormat(updatedAt)
    }
}
