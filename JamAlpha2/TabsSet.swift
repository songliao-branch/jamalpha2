//
//  TabsSet.swift
//  JamAlpha2
//
//  Created by Song Liao on 10/12/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData

@objc(TabsSet)
class TabsSet: NSManagedObject {
    @NSManaged var song: Song
    @NSManaged var chords: AnyObject
    @NSManaged var tabs: AnyObject
    @NSManaged var times: AnyObject
}