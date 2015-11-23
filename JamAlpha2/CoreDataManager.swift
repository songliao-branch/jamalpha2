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
        
        //for testing 
        for o in results {
            moc.deleteObject(o as! NSManagedObject)
        }
//        if results.count == 1 {
//            let user = results.firstObject as? User
//             moc.deleteObject(user!)
//            
//        }
        
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
    
    class func initializeUser(id: Int, email: String, authToken: String) {
        logoutUser()//for testing clear all users
        
        let user: User = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(User), managedObjectConect: moc) as! User
        user.id  = id
        user.email = email
        user.authToken = authToken
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
            }
            if let album = item.albumTitle {
                song.album = album
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
    
    //Tabs, TODO: need to store tuning, capo number
    class func saveTabs(item: MPMediaItem, chords: [String], tabs: [String], times:[NSTimeInterval], tuning:String, capo: Int) {
        
        if let matchedSong = findSong(item) {
            // TODO: find a better way managing user's lyrics, now just clear existing lyrics
            matchedSong.tabsSets = NSSet()
            
            let tabsSet = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(TabsSet), managedObjectConect: moc) as! TabsSet
            
            let chordsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(chords as AnyObject)
            let tabsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(tabs as AnyObject)
            let timesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(times as AnyObject)
            tabsSet.chords = chordsData
            tabsSet.tabs = tabsData
            tabsSet.times = timesData
            tabsSet.song = matchedSong
            tabsSet.tuning = tuning
            tabsSet.capo = capo
            print("just saved tabs")
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func getTabs(item: MPMediaItem) -> ([Chord], String, Int) { //return chords, tuning and capo
        
        if let matchedSong = findSong(item) {
            print("has \(matchedSong.tabsSets.count) set of tabs")
            if matchedSong.tabsSets.count > 0 {
                let theSet = matchedSong.tabsSets.allObjects.last as! TabsSet
                
                let chords = NSKeyedUnarchiver.unarchiveObjectWithData(theSet.chords as! NSData) as! [String]
                let tabs = NSKeyedUnarchiver.unarchiveObjectWithData(theSet.tabs as! NSData) as! [String]
                
                let times = NSKeyedUnarchiver.unarchiveObjectWithData(theSet.times as! NSData) as! [NSTimeInterval]
                
                var chordsToBeUsed = [Chord]()
                
                for i in 0..<chords.count {
                    let singleChord = Tab(name: chords[i], content: tabs[i])
                    let timedChord = Chord(tab: singleChord, time: TimeNumber(time: Float(times[i])))
                    chordsToBeUsed.append(timedChord)
                }
                return (chordsToBeUsed, theSet.tuning, Int(theSet.capo))
            }
        }
        return ([Chord](), "", 0)
    }
    
    
    
}