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
    @NSManaged var id: NSNumber //tabsSet id retrieved from online, if > 0, means it is from the cloud
    @NSManaged var song: Song
    @NSManaged var user: User
    @NSManaged var chords: AnyObject
    @NSManaged var tabs: AnyObject
    @NSManaged var times: AnyObject
    @NSManaged var capo: NSNumber
    @NSManaged var tuning: String
    @NSManaged var lastSelectedDate: NSDate//everytime when this is saved
    @NSManaged var isLocal: Bool
}