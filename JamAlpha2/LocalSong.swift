//
//  LocalSongs.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation

class LocalSong: NSObject {
     var title: String!
     var artist: String!
     var album: String!
     var duration: NSNumber!
     var soundwaveData: AnyObject! // used for image generation in TabsEditor
     var albumCover: NSData!
     var soundwaveImage: NSData! //used for image in SongViewController
     var tabsSets: NSSet!
     var lyricsSets: NSSet!
     var id: NSNumber! //retrieved from cloud
    
}
