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
    var userId = -1
    var upVotes = 0
    var downVotes = 0
    
    //these variables are downloaded again when a single tabsSet is selected
    var chords = [String]()
    var tabs = [String]()
    var times = [Float]()
    
    init(id: Int, tuning: String, capo: Int, songId: Int, upVotes: Int, downVotes: Int, userId: Int) {
        self.id = id
        self.tuning = tuning
        self.capo = capo
        self.songId = songId
        self.userId = userId
        self.upVotes = upVotes
        self.downVotes = downVotes
    }
}
