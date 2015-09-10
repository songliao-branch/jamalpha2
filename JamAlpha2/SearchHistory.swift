//
//  SearchHistory.swift
//  JamAlpha2
//
//  Created by Song Liao on 9/8/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData

@objc(SearchHistory)
class SearchHistory: NSManagedObject {

    @NSManaged var term: String

}
