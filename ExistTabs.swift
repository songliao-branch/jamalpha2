//
//  ExistTabs.swift
//  tabEditorV3
//
//  Created by Jun Zhou on 9/2/15.
//  Copyright (c) 2015 Jun Zhou. All rights reserved.
//

import Foundation
import CoreData

@objc(ExistTabs)
class ExistTabs: NSManagedObject {

    @NSManaged var index: NSNumber
    @NSManaged var name: String
    @NSManaged var content: String

}
