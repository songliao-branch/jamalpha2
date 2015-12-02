//
//  User.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData
@objc(User)
class User: NSManagedObject {
   
    @NSManaged var id: NSNumber
    @NSManaged var email: String
    @NSManaged var username: String? //this is not required
    @NSManaged var avatarUrl: String?
    @NSManaged var thumbnailUrl: String?
    @NSManaged var authToken: String
    @NSManaged var profileImage: NSData?
    @NSManaged var thumbnail: NSData?
    
    @NSManaged var tabsSets: NSSet
    @NSManaged var lyricsSets: NSSet
    
}