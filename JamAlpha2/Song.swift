//
//  Song.swift
//  JamAlpha2
//
//  Created by Song Liao on 9/10/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData
@objc(Song)
class Song: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var artist: String
    @NSManaged var album: String
    @NSManaged var playbackDuration: NSNumber
    @NSManaged var soundwaveData: AnyObject // used for image generation in TabsEditor
    @NSManaged var albumCover: NSData
    @NSManaged var soundwaveImage: NSData //used for image in SongViewController
    @NSManaged var tabsSets: NSSet
    @NSManaged var lyricsSets: NSSet
    
}