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
    @NSManaged var user: User
    @NSManaged var lyrics: AnyObject
    @NSManaged var times: AnyObject
}