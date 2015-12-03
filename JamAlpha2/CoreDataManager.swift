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
    class func initializeUser(id: Int, email: String, authToken: String, username: String? = nil, avatarUrl: String? = nil, thumbnailUrl: String? = nil, profileImage: NSData?, thumbnail: NSData?, nickName: String? = nil) {
        logoutUser()//for testing clear all users
        
        let user: User = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(User), managedObjectConect: moc) as! User
        user.id  = id
        user.email = email
        user.authToken = authToken
        user.profileImage = profileImage
        user.thumbnail = thumbnail
        if let url = thumbnailUrl {
            user.thumbnailUrl = url
        }
        user.thumbnailUrl = thumbnailUrl
        if let nick = nickName {
            user.nickName = nick
        }
        if let name = username {
            user.username = name
        }
        if let url = avatarUrl {
            user.avatarUrl = url
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
    class func updateUserProfileImage(userEmail: String, avatarUrl: String?=nil, thumbnailUrl: String?=nil, profileImage: NSData?, thumbnail: NSData?) -> Bool{
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == '\(userEmail)'")
        do {
            if let results = try moc.executeFetchRequest(fetchRequest) as? [User] {
                for item in results {
                    let temp: User = item as User
                    temp.avatarUrl = avatarUrl
                    temp.thumbnailUrl = thumbnailUrl
                    temp.profileImage = profileImage
                    temp.thumbnail = thumbnail
                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                    return true
                }
            }
        } catch {
            fatalError("There was an error fetching tabs on the index \(index)")
        }
        return false
    }
    
    class func updateUserProfileNickName(userEmail: String, nickName: String) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == '\(userEmail)'")
        do {
            if let results = try moc.executeFetchRequest(fetchRequest) as? [User] {
                for item in results {
                    let temp: User = item as User
                    temp.nickName = nickName
                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                    return true
                }
            }
        } catch {
            fatalError("There was an error fetching tabs on the index \(index)")
        }
        return false
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
    class func saveLyrics(item: Findable, lyrics: [String], times: [NSTimeInterval]) {
        
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
    
    class func getLyrics(item: Findable) -> [(String, NSTimeInterval)] {
        
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
    class func saveTabs(item: Findable, chords: [String], tabs: [String], times:[NSTimeInterval], tuning:String, capo: Int) {
        
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
    
    class func getTabs(item: Findable) -> ([Chord], String, Int) { //return chords, tuning and capo
        
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