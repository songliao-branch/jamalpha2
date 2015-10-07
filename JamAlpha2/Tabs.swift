//
//  Tabs.swift
//  JamAlpha2
//
//  Created by Song Liao on 10/7/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData

@objc(Tabs)
class Tabs: NSManagedObject {
    
    @NSManaged var index: NSNumber
    @NSManaged var name: String
    @NSManaged var content: String
    @NSManaged var isOriginal: Bool
}
