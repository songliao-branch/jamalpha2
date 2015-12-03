//
//  DownloadedTabsSet.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/12/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
class DownloadedTabsSet: NSObject {
    var id = -1
    //these varibles are required for showing the array of DownloadedTabs in the browse tableview
    var tuning = ""
    var capo = 0
    
    var songId = -1
    //var userId = -1
    var userName = "" //TODO: use email for now, will change for username later
    var updatedAt = "" //TODO: change to a string
    var votesScore = 0
    var chordsPreview = ""
    
    var voteStatus = ""
    //these variables are downloaded again when a single tabsSet is selected
    var chords = [String]()
    var tabs = [String]()
    var times = [Float]()
    
    init(id: Int, tuning: String, capo: Int, songId: Int, votesScore: Int, userName: String, updatedAt: String, chordsPreview: String, voteStatus: String) {
        self.id = id
        self.tuning = tuning
        self.capo = capo
        self.songId = songId
        self.userName = userName
        self.updatedAt = NSDate.convertFromIsoToHumanizedFormat(updatedAt)
        self.votesScore = votesScore
        self.chordsPreview = chordsPreview
        self.voteStatus = voteStatus
    }
}
