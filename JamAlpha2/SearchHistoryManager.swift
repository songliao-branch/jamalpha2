//
//  SearchHistoryData.swift
//  JamAlpha2
//
//  Created by Song Liao on 9/10/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData

class SearchHistoryManager: NSObject {

    let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()


    func addNewHistory(term: String) {
        var history: SearchHistory = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(SearchHistory), managedObjectConect: moc) as! SearchHistory
        history.term = term
        
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
    func getAllHistory() -> [SearchHistory]{
        
      var results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(SearchHistory), withPredicate: nil, managedObjectContext: moc)
        
        return results as! [SearchHistory]
    }
    
    func clearHistory() {
       var results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(SearchHistory), withPredicate: nil, managedObjectContext: moc)
        for result in results {
            
            moc.deleteObject(result as! NSManagedObject)
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
}