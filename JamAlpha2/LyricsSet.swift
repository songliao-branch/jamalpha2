//
//  LyricsSet.swift
//  JamAlpha2
//
//  Created by Song Liao on 9/29/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData

@objc(LyricsSet)
class LyricsSet: NSManagedObject {
    @NSManaged var song: Song
    @NSManaged var lyrics: AnyObject
    @NSManaged var times: AnyObject
    
    @NSManaged var id: NSNumber
    @NSManaged var lastSelectedDate: NSDate
    @NSManaged var userId: NSNumber
    @NSManaged var lastEditedDate: NSDate
}