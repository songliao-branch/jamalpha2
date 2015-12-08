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

protocol Findable {
    func getTitle() -> String
    func getArtist() -> String
    func getAlbum() -> String
    func getDuration() -> Float
}

extension MPMediaItem: Findable {
    func getTitle() -> String {
        if let title = self.title {
            return title
        }
        return ""
    }
    func getArtist() -> String {
        if let artist = self.artist {
            return artist
        }
        return ""
    }
    
    func getAlbum() -> String {
        if let album = self.albumTitle {
            return album
        }
        return ""
    }
    
    func getDuration() -> Float {
        return Float(self.playbackDuration)
    }
}

extension SearchResult: Findable {
    func getTitle() -> String {
        if let title = self.trackName {
            return title
        }
        return ""
    }
    func getArtist() -> String {
        if let artist = self.artistName {
            return artist
        }
        return ""
    }
    
    func getAlbum() -> String {
        if let album = self.collectionName {
            return album
        }
        return ""
    }
    
    func getDuration() -> Float {
        if let time = self.trackTimeMillis {
            return time
        }
        return 0.0
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
    class func initializeUser(id: Int, email: String, authToken: String, nickname: String, avatarUrl: String, thumbnailUrl: String, fbToken: String?=nil) {
        logoutUser()//for testing clear all users
        
        let user: User = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(User), managedObjectConect: moc) as! User
        user.id  = id
        user.email = email
        user.authToken = authToken
        user.nickname = nickname
        
        user.thumbnailUrl = thumbnailUrl
        user.avatarUrl = avatarUrl
        
        if let token = fbToken {
            user.fbToken = token
        }
        
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
    class func saveUserProfileImage(avatarUrl: String?=nil, thumbnailUrl:String?=nil, profileImageData: NSData?=nil, thumbnailData: NSData?=nil){
        let currentUser = CoreDataManager.getCurrentUser()!
        
        if let avatarUrl = avatarUrl {
            currentUser.avatarUrl = avatarUrl
        }
        if let thumbnailUrl = thumbnailUrl {
            currentUser.thumbnailUrl = thumbnailUrl
        }
        
        if let profile = profileImageData {
            currentUser.profileImage = profile
        }
        if let thumbnail = thumbnailData {
            currentUser.thumbnail = thumbnail
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
    class func saveUserProfileNickname(nickname: String) -> Bool {
        if CoreDataManager.getCurrentUser() == nil {
            return false
        }
        let currentUser = CoreDataManager.getCurrentUser()!
        currentUser.nickname = nickname
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
        return true
    }
    
    
    //song-related

    private class func findSong(item: Findable) -> Song? {
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(item.getTitle().replaceApostrophe())') AND (artist == '\(item.getArtist().replaceApostrophe())') AND (album == '\(item.getAlbum().replaceApostrophe())')")

        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
            print("song doesn't exist")
            return nil
        } else {
            return results.lastObject! as? Song
        }
    }

    
    class func initializeSongToDatabase(item: Findable) {
        // if we don't have the song in the database
        if findSong(item) == nil {
            let song: Song = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Song), managedObjectConect: moc) as! Song
            song.title = item.getTitle()
            song.artist = item.getArtist()
            song.album = item.getAlbum()
            song.playbackDuration = item.getDuration()
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    // MARK: save, retrieve soundwaves
    class func saveSoundWave(item: Findable, soundwaveData: NSMutableArray, soundwaveImage: NSData) {
        
        if let matchedSong = findSong(item) {
            let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(soundwaveData as AnyObject)
            matchedSong.soundwaveData = data
            matchedSong.soundwaveImage = soundwaveImage
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    

    class func getSongWaveFormData(item: Findable) -> NSMutableArray? {
        
        if let matchedSong = findSong(item) {
            print("sound wave data found for song")
            return NSKeyedUnarchiver.unarchiveObjectWithData(matchedSong.soundwaveData as! NSData) as? NSMutableArray
        }
        return nil
    }
    
    class func getSongWaveFormImage(item: Findable) -> NSData? {
        
        if let matchedSong = findSong(item) {
            print("sound wave image found for song")
            return matchedSong.soundwaveImage
        }
        
        return nil

    }
    
    // MARK: save, retrieve lyrics
    class func saveLyrics(item: Findable, lyrics: [String], times: [Float], lyricsSetId: Int?=nil) {

        if let matchedSong = findSong(item) {
          
            let savedSets = matchedSong.lyricsSets.allObjects as! [LyricsSet]
            
            let lyricsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(lyrics as AnyObject)
            let timesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(times as AnyObject)
            
            if let id = lyricsSetId where id > 0 { //if downloaded lyrics
                var foundDownloadedLyricsSet: LyricsSet!
                var found = false
                
                //find the exisiting downloaded lyrics
                for set in savedSets {
                    if set.id == id  {
                        foundDownloadedLyricsSet = set
                        found = true
                        foundDownloadedLyricsSet.lyrics = lyricsData
                        
                        foundDownloadedLyricsSet.times = timesData
                        foundDownloadedLyricsSet.lastSelectedDate = NSDate()
                        break
                    }
                }
                
                //if the downloaded lyricsSet with id is not found, we create a new one
                if !found {
                    let lyricsSet = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(LyricsSet), managedObjectConect: moc) as! LyricsSet

                    lyricsSet.lyrics = lyricsData
                    lyricsSet.times = timesData
                    lyricsSet.song = matchedSong
                    
                    lyricsSet.lastSelectedDate = NSDate()
                    lyricsSet.id = id
                    lyricsSet.isLocal = false
                }
                
            } else {//if saving local lyrics
                
                var foundLyricsSet: LyricsSet!
                var found = false
                //if this lyrics is already in the core data
                for set in savedSets {
                    if set.isLocal {
                        foundLyricsSet = set
                        found = true
                        foundLyricsSet.lyrics = lyricsData
                        foundLyricsSet.times = timesData
                        foundLyricsSet.lastSelectedDate = NSDate()
                        break
                    }
                }
                
                //create a new one if none found
                if !found {
                    let lyricsSet = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(LyricsSet), managedObjectConect: moc) as! LyricsSet
                    
                    lyricsSet.lyrics = lyricsData
                    lyricsSet.times = timesData
                    lyricsSet.song = matchedSong
                    
                    lyricsSet.lastSelectedDate = NSDate()
                    lyricsSet.isLocal = true
                    lyricsSet.id = -1 //this is needed to check which lyrics is last selected in the BrowseTable
                }
            }
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func getLyrics(item: Findable, fetchingLocalOnly: Bool) -> (Lyric, Int) {
        
        if let matchedSong = findSong(item) {
            print("has \(matchedSong.lyricsSets.count) set of lyrics")
        
            let sets = matchedSong.lyricsSets.allObjects as! [LyricsSet]
            
            var foundLyricsSet: LyricsSet!
            
            if fetchingLocalOnly {
                foundLyricsSet = sets.filter({ $0.isLocal == true }).first
            } else {
                //find the most recently selected tabsSet
                foundLyricsSet = sets.sort({
                    setA, setB in
                    if setA.lastSelectedDate.compare(setB.lastSelectedDate) ==  NSComparisonResult.OrderedDescending {
                        return true
                    }
                    return false
                }).first
            }
            
            if foundLyricsSet == nil {
                return (Lyric(), 0)
            }
            
            let lyrics = NSKeyedUnarchiver.unarchiveObjectWithData(foundLyricsSet.lyrics as! NSData) as! [String]
            let times = NSKeyedUnarchiver.unarchiveObjectWithData(foundLyricsSet.times as! NSData) as! [Float]
            
            let lyric = Lyric()
            for i in 0..<lyrics.count {
                lyric.addLine(TimeNumber(time: times[i]), str: lyrics[i])
            }
            
            return (lyric, Int(foundLyricsSet.id))
        }
        return (Lyric(), 0)
    }
    
    class func setLocalLyricsMostRecent(item: Findable) {
        if let matchedSong = findSong(item) {
            let savedSets = matchedSong.lyricsSets.allObjects as! [LyricsSet]
            let foundLocalSet = savedSets.filter({ $0.isLocal == true }).first
            
            if foundLocalSet == nil {
                return
            }
            foundLocalSet?.lastSelectedDate = NSDate()
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func setLocalTabsMostRecent (item: Findable) {
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
    class func saveTabs(item: Findable, chords: [String], tabs: [String], times:[NSTimeInterval], tuning:String, capo: Int, tabsSetId: Int?=nil ) {
        
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
    class func getTabs(item: Findable, fetchingLocalOnly: Bool) -> ([Chord], String, Int, Int) { //return chords, tuning and capo, song_id
        
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