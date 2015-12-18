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
        if(term.isEmpty){
            return
        }
        
        if let result = find(term) {
            moc.deleteObject(result as NSManagedObject)
        }
        
        let history: SearchHistory = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(SearchHistory), managedObjectConect: moc) as! SearchHistory
        history.term = term
        
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
    func getAllHistory() -> [SearchHistory] {
        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(SearchHistory), withPredicate: nil, managedObjectContext: moc)
        
        if(results.count > 10){
            for i in 0..<results.count - 10{
                moc.deleteObject(results[i] as! NSManagedObject)
            }
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
            let resultsAfterDelete: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(SearchHistory), withPredicate: nil, managedObjectContext: moc)
            return resultsAfterDelete as! [SearchHistory]
        }
        
        return results as! [SearchHistory]
    }
    
    func find(term: String) -> SearchHistory? {
        let predicate: NSPredicate = NSPredicate(format: "(term CONTAINS[cd] '\(term.replaceApostrophe())')")
        
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(SearchHistory), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
            return nil
        } else {
            return results.lastObject! as? SearchHistory
        }
    }
    
    func clearHistory() {
       let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(SearchHistory), withPredicate: nil, managedObjectContext: moc)
        for result in results {
            
            moc.deleteObject(result as! NSManagedObject)
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
}