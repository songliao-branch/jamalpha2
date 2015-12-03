//
//  SongManager.swift
//  JamAlpha2
//
//  Created by Song Liao on 9/10/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer

extension String {
    func replaceApostrophe() -> String {
        return self.stringByReplacingOccurrencesOfString("'", withString: "\\'")
    }
}

class CoreDataManager: NSObject {
    
    static let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
    
    //User-related
    class func logoutUser() {
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(User), withPredicate: nil, managedObjectContext: moc)
        
        //delete all user objects just to make sure we have none left
        for o in results {
            moc.deleteObject(o as! NSManagedObject)
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
    class func getCurrentUser() -> User? {
        
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(User), withPredicate: nil, managedObjectContext: moc)
        
        if results.count == 1 {
            return results.lastObject as? User
        }
        print("no users found")
        return nil
    }
    
    //the last two parameters can necessary for facebook logins
    // a normal call to this function only involves initializeUser(id,email,authToken)
    // a call with facebook involves all 5 parameters
    class func initializeUser(id: Int, email: String, authToken: String, username: String?=nil, avatarUrl: String?=nil) {
        logoutUser()//for testing clear all users
        
        let user: User = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(User), managedObjectConect: moc) as! User
        user.id  = id
        user.email = email
        user.authToken = authToken
        
        if let name = username {
            user.username = name
        }
        if let url = avatarUrl {
            user.avatarUrl = url
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    

    //song-related
    private class func findSong(item: MPMediaItem) -> Song? {
        // TODO: other special characters might corrupt the predicate, needs to check more later
        
        // some songs do NOT have all these attributes so we assign them an empty string to prevent optional unwrapping
        var titleToBeUsed = ""
        var artistToBeUsed = ""
        var albumToBeUsed = ""
        
        if let title = item.title {
            titleToBeUsed = title.replaceApostrophe()
        }
        if let artist = item.artist {
            artistToBeUsed = artist.replaceApostrophe()
        }
        if let album = item.albumTitle {
            albumToBeUsed = album.replaceApostrophe()
        }
        
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(titleToBeUsed)') AND (artist == '\(artistToBeUsed)') AND (album == '\(albumToBeUsed)')")
        
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
            print("song doesn't exist")
            return nil
        } else {
            return results.lastObject! as? Song
        }
    }
    
    class func initializeSongToDatabase(item: MPMediaItem) {
        // if we don't have the song in the database
        if findSong(item) == nil {
            let song: Song = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Song), managedObjectConect: moc) as! Song
            
            // some songs do NOT have all these attributes
            if let title = item.title {
                song.title = title
            }
            if let artist = item.artist {
                song.artist = artist
            }else{
                song.artist = ""
            }
            if let album = item.albumTitle {
                song.album = album
            }else{
                song.artist = ""
            }
            
            song.playbackDuration = Float(item.playbackDuration)
            
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    // MARK: save, retrieve soundwaves
    class func saveSoundWave(item: MPMediaItem, soundwaveData: NSMutableArray, soundwaveImage: NSData) {
        
        if let matchedSong = findSong(item) {
            let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(soundwaveData as AnyObject)
            matchedSong.soundwaveData = data
            matchedSong.soundwaveImage = soundwaveImage
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    

    class func getSongWaveFormData(item: MPMediaItem) -> NSMutableArray? {
        if let matchedSong = findSong(item) {
            print("sound wave data found for song")
            
            return NSKeyedUnarchiver.unarchiveObjectWithData(matchedSong.soundwaveData as! NSData) as? NSMutableArray
        }
        return nil
    }
    
    class func getSongWaveFormImage(item: MPMediaItem) -> NSData? {
        if let matchedSong = findSong(item) {
            print("sound wave image found for song")
            return matchedSong.soundwaveImage
        }
        return nil

    }
    
    // MARK: save, retrieve lyrics
    class func saveLyrics(item: MPMediaItem, lyrics: [String], times: [NSTimeInterval]) {
        
        if let matchedSong = findSong(item) {
            // TODO: find a better way managing user's lyrics, now just clear existing lyrics
            matchedSong.lyricsSets = NSSet()

            let lyricsSet = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(LyricsSet), managedObjectConect: moc) as! LyricsSet
            
            let lyricsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(lyrics as AnyObject)
            let timesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(times as AnyObject)
            
            lyricsSet.lyrics = lyricsData
            lyricsSet.times = timesData
            lyricsSet.song = matchedSong
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func getLyrics(item: MPMediaItem) -> [(String, NSTimeInterval)] {
        if let matchedSong = findSong(item) {
            print("has \(matchedSong.lyricsSets.count) set of lyrics")
            if matchedSong.lyricsSets.count > 0 {
                var results = [(String, NSTimeInterval)]()
                let theSet = matchedSong.lyricsSets.allObjects.last as! LyricsSet
                let lyrics = NSKeyedUnarchiver.unarchiveObjectWithData(theSet.lyrics as! NSData) as! [String]
                let times = NSKeyedUnarchiver.unarchiveObjectWithData(theSet.times as! NSData) as! [NSTimeInterval]
                
                for i in 0..<lyrics.count {
                    results.append((lyrics[i], times[i]))
                }
                return results
            }
        }
        return [(String, NSTimeInterval)]()
    }
    
    
    class func setLocalTabsMostRecent (item: MPMediaItem) {
        if let matchedSong = findSong(item) {
         let savedSets = matchedSong.tabsSets.allObjects as! [TabsSet]
            
           let foundLocalSet = savedSets.filter({ $0.isLocal == true }).first
            if foundLocalSet == nil {
                return
            }
           foundLocalSet?.lastSelectedDate = NSDate()
           SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    
    //We save both user edited tabs and downloaded tabs, the last parameter is for the downloaded tabs, if they match what we have in the database we don't store them
    class func saveTabs(item: MPMediaItem, chords: [String], tabs: [String], times:[NSTimeInterval], tuning:String, capo: Int, tabsSetId: Int?=nil ) {
        
        if let matchedSong = findSong(item) {
            
            let savedSets = matchedSong.tabsSets.allObjects as! [TabsSet]
            let chordsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(chords as AnyObject)
            let tabsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(tabs as AnyObject)
            let timesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(times as AnyObject)
            
            if let id = tabsSetId where id > 0 { //if downloaded tabs
                var foundDownloadedTabsSet: TabsSet!
                var found = false
                
                //find the exisiting downloaded tabs
                for set in savedSets {
                    if set.id == id  {
                        foundDownloadedTabsSet = set
                        found = true
                        foundDownloadedTabsSet.chords = chordsData
                        foundDownloadedTabsSet.tabs = tabsData
                        foundDownloadedTabsSet.times = timesData
                        foundDownloadedTabsSet.tuning = tuning
                        foundDownloadedTabsSet.capo = capo
                        foundDownloadedTabsSet.lastSelectedDate = NSDate()
                        break
                    }
                }
                
                //if the downloaded tabsSet with id is not found, we create a new one
                if !found {
                    let tabsSet = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(TabsSet), managedObjectConect: moc) as! TabsSet
                    
                    tabsSet.chords = chordsData
                    tabsSet.tabs = tabsData
                    tabsSet.times = timesData
                    tabsSet.song = matchedSong
                    tabsSet.tuning = tuning
                    tabsSet.capo = capo
                    tabsSet.lastSelectedDate = NSDate()
                    tabsSet.id = id
                    tabsSet.isLocal = false
                }
                
            } else {//if saving local tabs
                
                var foundLocalTabsSet: TabsSet!
                var found = false
                //if this tabs is already in the core data
                for set in savedSets {
                    if set.isLocal {
                        foundLocalTabsSet = set
                        found = true
                        foundLocalTabsSet.chords = chordsData
                        foundLocalTabsSet.tabs = tabsData
                        foundLocalTabsSet.times = timesData
                        foundLocalTabsSet.tuning = tuning
                        foundLocalTabsSet.capo = capo
                        foundLocalTabsSet.lastSelectedDate = NSDate()
                        break
                    }
                }
                
                //create a new one if none found
                if !found {
                    let tabsSet = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(TabsSet), managedObjectConect: moc) as! TabsSet
                   
                    tabsSet.chords = chordsData
                    tabsSet.tabs = tabsData
                    tabsSet.times = timesData
                    tabsSet.song = matchedSong
                    tabsSet.tuning = tuning
                    tabsSet.capo = capo
                    tabsSet.lastSelectedDate = NSDate()
                    tabsSet.isLocal = true
                    tabsSet.id = -1 //this is needed to check which tabs is last selected in the BrowseTable
                }
            }
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }

    
    //if isLocal is true, we get the ONE tabs from the database, otherwise we selected the one last selected
    class func getTabs(item: MPMediaItem, fetchingLocalOnly: Bool) -> ([Chord], String, Int, Int) { //return chords, tuning and capo, song_id
        
        //song id is used to determine which tabs
        if let matchedSong = findSong(item) {
            print("has \(matchedSong.tabsSets.count) set of tabs")
            
            let sets = matchedSong.tabsSets.allObjects as! [TabsSet]
            
            var foundTabsSet: TabsSet!
            
            if fetchingLocalOnly {
                foundTabsSet = sets.filter({ $0.isLocal == true }).first
            } else {
                //find the most recently selected tabsSet
                foundTabsSet = sets.sort({
                    setA, setB in
                    if setA.lastSelectedDate.compare(setB.lastSelectedDate) ==  NSComparisonResult.OrderedDescending {
                        return true
                    }
                    return false
                }).first
            }
            
            if foundTabsSet == nil {
                return ([Chord](), "", 0, 0)
            }
            
            let chords = NSKeyedUnarchiver.unarchiveObjectWithData(foundTabsSet.chords as! NSData) as! [String]
            let tabs = NSKeyedUnarchiver.unarchiveObjectWithData(foundTabsSet.tabs as! NSData) as! [String]
            let times = NSKeyedUnarchiver.unarchiveObjectWithData(foundTabsSet.times as! NSData) as! [NSTimeInterval]
            
            var chordsToBeUsed = [Chord]()
            
            for i in 0..<chords.count {
                let singleChord = Tab(name: chords[i], content: tabs[i])
                let timedChord = Chord(tab: singleChord, time: TimeNumber(time: Float(times[i])))
                chordsToBeUsed.append(timedChord)
            }
            return (chordsToBeUsed, foundTabsSet.tuning, Int(foundTabsSet.capo), Int(foundTabsSet.id))
        }
        return ([Chord](), "", 0, 0)
    }
}