//
//  coreData.swift
//  tabEditorV3
//
//  Created by Jun Zhou on 9/2/15.
//  Copyright (c) 2015 Jun Zhou. All rights reserved.
//

import Foundation
import CoreData

class TabsDataManager: NSObject {
    
    let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
    
    let fretsBoard: [[String]] = [
        //Fret board note, from high E string to low E string
        ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E"],
        ["B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"],
        ["G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G"],
        ["D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D"],
        ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A"],
        ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E"]
    ]

    func commonChords() -> [String: String] {
        var commonChords: [String: String] = [String: String]()
        //4th string
        commonChords["40000"] = "xxxx00020302"//D
        commonChords["40001"] = "xxxx00020301"
        commonChords["40002"] = "xxxx00020102"
        commonChords["40003"] = "xxxx00020101"
        commonChords["40300"] = "xxxx03020101"//F
        //5th string
        for var i = 0; i < 4; i++ {
            for var j = 0; j < 23; j++ {
                if i == 0 { // major chords, e,g, A major -> xx 00 22 22 22 00
                    if j == 3 {
                        commonChords["50300"] = "xx0302000100"
                    } else {
                        if j < 8 {
                            //xx0204040404
                            commonChords["\(500 + j)00"] = "xx0\(j)0\(j + 2)0\(j + 2)0\(j + 2)0\(j)"
                        } else if j >= 8 && j < 10 {
                            commonChords["\(500 + j)00"] = "xx0\(j)\(j + 2)\(j + 2)\(j + 2)0\(j)"
                        } else {
                            commonChords["\(500 + j)00"] = "xx\(j)\(j + 2)\(j + 2)\(j + 2)\(j)"
                        }
                    }
                } else if i == 1 {
                    if j < 8 { //minor chords, Bm -> xx 02 04 04 03 00
                        commonChords["\(500 + j)01"] = "xx0\(j)0\(j + 2)0\(j + 2)0\(j + 1)0\(j)"
                    } else if j == 8 {
                        commonChords["\(500 + j)01"] = "xx0\(j)\(j + 2)\(j + 2)0\(j + 1)0\(j)"
                    } else if j == 9 {
                        commonChords["\(500 + j)01"] = "xx0\(j)\(j + 2)\(j + 2)\(j + 1)0\(j)"
                    }else {
                        commonChords["\(500 + j)01"] = "xx\(j)\(j + 2)\(j + 2)\(j + 1)\(j)"
                    }
                } else if i == 2 { //7
                    if j < 8 {
                        commonChords["\(500 + j)02"] = "xx0\(j)0\(j + 2)0\(j)0\(j + 2)0\(j)"
                    } else if j >= 8 && j < 10 {
                        commonChords["\(500 + j)02"] = "xx0\(j)\(j + 2)0\(j)\(j + 2)0\(j)"
                    } else {
                        commonChords["\(500 + j)02"] = "xx\(j)\(j + 2)\(j)\(j + 2)\(j)"
                    }
                } else if i == 3 { //m7
                    if j < 8 {
                        commonChords["\(500 + j)03"] = "xx0\(j)0\(j + 2)0\(j)0\(j + 1)0\(j)"
                    } else if j == 8 {
                        commonChords["\(500 + j)03"] = "xx0\(j)\(j + 2)0\(j)0\(j + 1)0\(j)"
                    } else if j == 9 {
                        commonChords["\(500 + j)03"] = "xx0\(j)\(j + 2)0\(j)\(j + 1)0\(j)"
                    } else {
                        commonChords["\(500 + j)03"] = "xx\(j)\(j + 2)\(j)\(j + 1)\(j)"
                    }
                }
            }
        }
        
        //6th string
        for var i = 0; i < 3; i++ {
            for var j = 0; j < 23; j++ {
                if i == 0 {
                    if j == 3 {
                        commonChords["60300"] = "030200000003"
                    } else {
                        if j < 8 {
                            commonChords["\(600 + j)00"] = "0\(j)0\(j + 2)0\(j + 2)0\(j + 1)0\(j)0\(j)"
                        } else if j == 8 {
                            commonChords["\(600 + j)00"] = "0\(j)\(j + 2)\(j + 2)0\(j + 1)0\(j)0\(j)"
                        } else if j == 9 {
                            commonChords["\(600 + j)00"] = "x\(j)\(j + 2)\(j + 2)\(j + 1)0\(j)0\(j)"
                        }else {
                            commonChords["\(600 + j)00"] = "\(j)\(j + 2)\(j + 2)\(j + 1)\(j)\(j)"
                        }
                    }
                } else if i == 1 {
                    if j < 8 {
                        commonChords["\(600 + j)01"] = "0\(j)0\(j + 2)0\(j + 2)0\(j)0\(j)0\(j)"
                    } else if j >= 8 && j < 10 {
                        commonChords["\(600 + j)01"] = "0\(j)\(j + 2)\(j + 2)0\(j)0\(j)0\(j)"
                    } else {
                        commonChords["\(600 + j)01"] = "\(j)\(j + 2)\(j + 2)\(j)\(j)\(j)"
                    }
                } else if i == 2 {
                    if j == 3 {
                        commonChords["60302"] = "03xx00000001"
                    }
                    if j < 8 {
                        commonChords["\(600 + j)02"] = "0\(j)0\(j + 2)0\(j)0\(j + 1)0\(j)0\(j)"
                    } else if j == 8 {
                        commonChords["\(600 + j)02"] = "0\(j)\(j + 2)0\(j)0\(j + 1)0\(j)0\(j)"
                    } else if j == 9 {
                        commonChords["\(600 + j)02"] = "0\(j)\(j + 2)0\(j)\(j + 1)0\(j)0\(j)"
                    }else {
                        commonChords["\(600 + j)02"] = "\(j)\(j + 2)\(j)\(j + 1)\(j)\(j)"
                    }
                }
            }
        }
        commonChords["60003"] = "000202000300"
        return commonChords
    }
    
    func addDefaultData() {
        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Tabs), withPredicate: nil, managedObjectContext: moc)
        if results.count < 1 { // if results are empty, we initiate original tabs
            let dict = commonChords()
            for var i = 4; i < 7; i++ { //chord starts at 4th string
                for var j = 0; j < 25; j++ {
                    let index = NSNumber(integer: i * 10000 + j * 100)
                    let note = fretsBoard[i - 1][j]
                    print("\(note)")
                    insertInitialTabs(index, name: note, dict: dict)
                }
            }
        } else {
            print("Original tabs already in place")
        }
        
//        if results.count == 269 {
//            print("Database already exist")
//            for result in results {
//                let singleTab: Tabs = result as! Tabs
//                print("\(singleTab.index) + \(singleTab.name) + \(singleTab.content)")
//            }
//        } else {
//            removeAllFromDatabase()
//            let dict = initfingersString()
//            for var i = 1; i < 7; i++ {
//                for var j = 0; j < 25; j++ {
//                    let index = NSNumber(integer: i * 10000 + j * 100)
//                    let note = fretsBoard[i - 1][j]
//                    print("\(note)")
//                    insertInitialTabs(index, name: note, dict: dict)
//                }
//            }
//        }
    }
    
//    func removeAllFromDatabase() {
//        let resultsForExistTabs: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(ExistTabs), withPredicate: nil, managedObjectContext: moc)
//        let resultsForNewTabs: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(NewTabs), withPredicate: nil, managedObjectContext: moc)
//        for result in resultsForExistTabs {
//            let item = result as! NSManagedObject
//            moc.deleteObject(item)
//        }
//        for result in resultsForNewTabs {
//            let item = result as! NSManagedObject
//            moc.deleteObject(item)
//        }
//        SwiftCoreDataHelper.saveManagedObjectContext(moc)
//    }
    
    func insertInitialTabs(index: NSNumber, name: String, dict: Dictionary<String, String>) {
//        if Int(index) < 40000 {
//            let tab: Tabs = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Tabs), managedObjectConect: moc) as! Tabs
//            tab.name = name
//            let tempIndex = Int(index) / 100
//            tab.index = NSNumber(integer: tempIndex)
//            tab.content = ""
//            tab.isOriginal = true
//            SwiftCoreDataHelper.saveManagedObjectContext(moc)
//        } else {
    var tabSuffix: [String] = ["", "m", "7", "m7"]

    for var i = 0; i < 4; i++ {
        let temp = "\(Int(index) + i)"
        if dict[temp] != nil {
            let tab: Tabs = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Tabs), managedObjectConect: moc) as! Tabs
            let noteName = "\(name)\(tabSuffix[i])"
            tab.name = noteName
            let tempIndex = Int(index) / 100
            tab.isOriginal = true
            tab.index = NSNumber(integer: tempIndex)
            tab.content = dict[temp]!
        }
    }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)

//        else if i == 0 {
//            let tab: ExistTabs = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(ExistTabs), managedObjectConect: moc) as! ExistTabs
//            tab.name = name
//            let tempIndex = Int(index) / 100
//            tab.index = NSNumber(integer: tempIndex)
//            tab.content = ""
//        }
//  }
    }
    
    // get all tabs give a fret positino
    func getTabsSets(index: NSNumber) -> [Tabs] {

        let fetchRequest = NSFetchRequest(entityName: "Tabs")
        fetchRequest.predicate = NSPredicate(format: "index == '\(index)'")
        do {
            if let results = try SwiftCoreDataHelper.managedObjectContext().executeFetchRequest(fetchRequest) as? [Tabs] {
                return results
            }
        } catch {
            fatalError("There was an error fetching tabs on the index \(index)")
        }
        return [Tabs]()
    }

//    func getExistTab(index: NSNumber) -> [NSDictionary] {
//        let predicate: NSPredicate = NSPredicate(format: "index == '\(index)'")
//        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(ExistTabs), withPredicate: predicate, managedObjectContext: moc)
//        var tabDict: [NSDictionary] = [NSDictionary]()
//        for result in results {
//            let singleTab: ExistTabs = result as! ExistTabs
//            if singleTab.index == index {
//                tabDict.append(["index": singleTab.index, "name": singleTab.name, "content": singleTab.content])
//            }
//        }
//        return tabDict
//    }
//    
//    func getExistTabWithName(index: NSNumber, name: String) -> NSDictionary {
//        let predicate: NSPredicate = NSPredicate(format: "index == '\(index)'")
//        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(ExistTabs), withPredicate: predicate, managedObjectContext: moc)
//        var tabDict: NSDictionary = NSDictionary()
//        for result in results {
//            let singleTab: ExistTabs = result as! ExistTabs
//            if singleTab.index == index && singleTab.name == name {
//                tabDict = ["index": singleTab.index, "name": singleTab.name, "content": singleTab.content]
//            }
//        }
//        return tabDict
//    }
    
    func addNewTabs(index: NSNumber, name: String, content: String) {
        let tabs: Tabs = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Tabs), managedObjectConect: moc) as! Tabs
        tabs.index = index
        tabs.name = name
        tabs.content = content
        tabs.isOriginal = false
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
//    func getNewTab(index: NSNumber) -> [NSDictionary] {
//        let predicate: NSPredicate = NSPredicate(format: "index == '\(index)'")
//        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(NewTabs), withPredicate: predicate, managedObjectContext: moc)
//        var tabDict: [NSDictionary] = [NSDictionary]()
//        for result in results {
//            let singleTab: NewTabs = result as! NewTabs
//            if singleTab.index == index {
//                tabDict.append(["index": singleTab.index, "name": singleTab.name, "content": singleTab.content])
//            }
//        }
//        return tabDict
//    }
//    
//    func getNewTabWithName(index: NSNumber, name: String) -> NSDictionary {
//        let predicate: NSPredicate = NSPredicate(format: "index == '\(index)'")
//        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(NewTabs), withPredicate: predicate, managedObjectContext: moc)
//        var tabDict: NSDictionary = NSDictionary()
//        for result in results {
//            let singleTab: NewTabs = result as! NewTabs
//            if singleTab.index == index && singleTab.name == name {
//                tabDict = ["index": singleTab.index, "name": singleTab.name, "content": singleTab.content]
//            }
//        }
//        return tabDict
//    }
//    
    func removeTabs(tabs: Tabs) {
        if tabs.isOriginal {
            print("cannot remove original tabs")
            return
        }
        SwiftCoreDataHelper.managedObjectContext().deleteObject(tabs)
    }
    
//    func removeNewTab(index: NSNumber, name: String) {
//        let predicate: NSPredicate = NSPredicate(format: "index == '\(index)'")
//        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(NewTabs), withPredicate: predicate, managedObjectContext: moc)
//        for result in results {
//            let singleTab: NewTabs = result as! NewTabs
//            if singleTab.name == name {
//                let item = singleTab as NSManagedObject
//                moc.deleteObject(item)
//            }
//        }
//        SwiftCoreDataHelper.saveManagedObjectContext(moc)
//    }
    func printAllNewTabs() {
        let fetchRequest = NSFetchRequest(entityName: "Tabs")
        fetchRequest.predicate = NSPredicate(format: "isOriginal == false")//needs to verify this works
        do {
            if let results = try SwiftCoreDataHelper.managedObjectContext().executeFetchRequest(fetchRequest) as? [Tabs] {
                for result in results {
                    print("\(result.index) + \(result.name) + \(result.content)")
                }
            }
        } catch {
            fatalError("There was an error fetching all new tabs")
        }
    }
    
//    
//    
//    func printAllNewTab() {
//        let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
//        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(NewTabs), withPredicate: nil, managedObjectContext: moc)
//        for result in results {
//            let item: NewTabs = result as! NewTabs
//            print("\(item.index) + \(item.name) + \(item.content)")
//        }
//    }
}