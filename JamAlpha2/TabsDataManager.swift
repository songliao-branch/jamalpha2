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
    }
    
    
    func insertInitialTabs(index: NSNumber, name: String, dict: Dictionary<String, String>) {
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
    }
    
    // get all tabs give a fret positino
    func getTabsSets(index: NSNumber) -> [NormalTabs] {

        var tempTabSet: [NormalTabs] = [NormalTabs]()
        
        let fetchRequest = NSFetchRequest(entityName: "Tabs")
        fetchRequest.predicate = NSPredicate(format: "index == '\(index)'")
        do {
            if let results = try SwiftCoreDataHelper.managedObjectContext().executeFetchRequest(fetchRequest) as? [Tabs] {
                for item in results {
                    let tempItem: Tabs = item as Tabs
                    let tempTab: NormalTabs = NormalTabs()
                    tempTab.name = tempItem.name
                    tempTab.index = tempItem.index
                    tempTab.content = tempItem.content
                    tempTab.isOriginal = tempItem.isOriginal
                    tempTab.tabs = tempItem
                    tempTabSet.append(tempTab)
                }
                    return tempTabSet
            }
        } catch {
            fatalError("There was an error fetching tabs on the index \(index)")
        }
        return [NormalTabs]()
    }

    
    func addNewTabs(index: NSNumber, name: String, content: String) {
        let tabs: Tabs = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Tabs), managedObjectConect: moc) as! Tabs
        tabs.index = index
        tabs.name = name
        tabs.content = content
        tabs.isOriginal = false
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    

    func removeTabs(tabs: Tabs) {
        if tabs.isOriginal {
            print("cannot remove original tabs")
            return
        }
        SwiftCoreDataHelper.managedObjectContext().deleteObject(tabs)
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }

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

}