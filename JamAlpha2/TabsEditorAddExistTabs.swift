//
//  TabsEditorAddExistTabs.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/25/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

//MARK: ADD exist chord to tab editor view
extension TabsEditorViewController {
    // get tabs from coredata and show it on tab editor
    func getBasicNoteIndex(sender: [String]) -> Int {
        for var i = 0; i < 6; i++ {
            if sender[i] != "x" {
                let stringIndex = 6 - i
                let fretIndex = Int(sender[i])
                return stringIndex * 100 + fretIndex!
            }
        }
        return 0
    }
    
    func getUnrepeatTabs(sender: [Chord]) -> [NormalTabs] {
        var tabs: [NormalTabs] = [NormalTabs]()
        for item in sender {
            let tempNormalTabs = getNormalTabFromChord(item)
            var unrepeat: Bool = false
            for tab in tabs {
                if tab.tabs == tempNormalTabs.tabs {
                    unrepeat = true
                }
            }
            if unrepeat == false {
                tabs.append(tempNormalTabs)
            }
        }
        return tabs
    }
    
    func getNormalTabFromChord(sender: Chord) -> NormalTabs {
        let index = getBasicNoteIndex(sender.tab.contentArray)
        let name = sender.tab.name
        let content = sender.tab.content
        let tempNormalTabs = TabsDataManager.getUniqueTab(index, name: name, content: content)
        return tempNormalTabs!
    }
    
    func addTabsFromCoreDataToMainViewDataArray(sender: [Chord]) {
        let unrepeatTabs = self.getUnrepeatTabs(sender)
        //noteButtonWithTabArray.removeAll()
        for item in unrepeatTabs {
            self.addTabsToMainViewDataArray(item)
        }
        self.isShowDiscardAlert = false
        reorganizeMainViewDataArray()
        collectionView.reloadData()
    }
    
    func addTabsFromCoreDataToMusicControlView(sender: [Chord]) {
        for item in sender {
            for var i = 0; i < noteButtonWithTabArray.count; i++ {
                let normalTab = getNormalTabFromChord(item)
                if normalTab.name == noteButtonWithTabArray[i].tab.name && normalTab.index == noteButtonWithTabArray[i].tab.index && normalTab.content == noteButtonWithTabArray[i].tab.content {
                    self.currentTime = Double(item.time.toDecimalNumer())
                    let presentPosition = CGFloat(self.currentTime / self.duration)
                    //
                    
                    //self.progressBlock.setProgress(presentPosition)
                    
                    //
                    self.progressBlock.frame.origin.x = 0.5 * self.trueWidth - presentPosition * (CGFloat(theSong.getDuration()) * tabsEditorProgressWidthMultiplier)
                    
                    let returnValue = addTabViewOnMusicControlView(i)
                    
                    self.allTabsOnMusicLine.append(returnValue.1)
                    self.progressBlock.addSubview(returnValue.0)
                }
            }
        }
        
        let current = 0.0
        if isDemoSong {
            self.avPlayer.currentTime = current
        } else {
            self.musicPlayer.currentPlaybackTime = current
        }
        update()
        self.findCurrentTabView()
    }
    
    func checkChordsWithCoredata(chords: [Chord], completion: ((complete: [Chord]) -> Void)) {
        var needAddNewChords: Bool = false
        var newChords: [Chord] = chords
        var needAddNewChordsArray: [Tab] = [Tab]()
        for item in chords {
            let index = self.getBasicNoteIndex(item.tab.contentArray)
            if let _ = TabsDataManager.getUniqueTab(index, name: item.tab.name, content: item.tab.content) {
                continue
            } else {
                needAddNewChords = true
                needAddNewChordsArray.append(item.tab)
            }
        }
        
        if needAddNewChords {
            var nameString: String = ""
            var set:[String: Int] = [String: Int]()
            for item in needAddNewChordsArray {
                set[item.name] = 0
            }
            for item in set {
                nameString = nameString + item.0 + ", "
            }
            let alertController = UIAlertController(title: nil, message: "This song contains \(nameString)do you want add them in your Chord Library?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default,handler: {
                action in
                for var i = chords.count - 1; i >= 0; i-- {
                    let index = self.getBasicNoteIndex(chords[i].tab.contentArray)
                    if let _ = TabsDataManager.getUniqueTab(index, name: chords[i].tab.name, content: chords[i].tab.content) {
                        continue
                    } else {
                        newChords.removeAtIndex(i)
                    }
                }
                completion(complete: newChords)
            }))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,handler: {
                action in
                for item in needAddNewChordsArray {
                    let index = self.getBasicNoteIndex(item.contentArray)
                    if let _ = TabsDataManager.getUniqueTab(index, name: item.name, content: item.content) {
                        continue
                    } else {
                        TabsDataManager.addNewTabs(index, name: item.name, content: item.content)
                    }
                }
                completion(complete: newChords)
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            completion(complete: newChords)
        }
    }
    
    // This is the main function to add the chord into editor view, I used this function in ViewDidLoad at line 203
    func addChordToEditorView(sender: Findable) {
        let tabs = CoreDataManager.getTabs(sender, fetchingUsers: true)
        let chord: [Chord] = tabs.0
        let tuning: String = tabs.1
        let capoValue: Int = tabs.2
        let visible: Bool = tabs.4
        
        //let visible
        if chord.count > 0 {
            self.checkChordsWithCoredata(chord, completion: {
                complete in
                self.addTabsFromCoreDataToMainViewDataArray(complete)
                self.addTabsFromCoreDataToMusicControlView(complete)
                let tuningValues = Tuning.toArray(tuning)
                for i in 0..<self.tuningValueLabels.count {
                    self.tuningValueLabels[i].text = tuningValues[i]
                }
                self.capoStepper.value = Double(capoValue)
                self.capoLabel.text = "Capo: \(capoValue)"
                self.isPublic = visible
                if self.isPublic {
                    self.privacyButton.setImage(UIImage(named: "globeIcon"), forState: .Normal)
                    self.privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.43 / 20 * self.trueHeight, 1.1 / 20 * self.trueHeight, 0.93 / 20 * self.trueHeight, 0.2 / 20 * self.trueHeight)
                } else {
                    self.privacyButton.setImage(UIImage(named: "privateButton"), forState: .Normal)
                    self.privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0.3 / 20 * self.trueHeight, 1 / 20 * self.trueHeight, 0.8 / 20 * self.trueHeight, 0.1 / 20 * self.trueHeight)
                }
            })
        }
    }
}
