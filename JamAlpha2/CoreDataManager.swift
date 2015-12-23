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
    func getURL() -> AnyObject?
    func getArtWork() -> MPMediaItemArtwork?
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
    
    func getURL() -> AnyObject? {
        if let url = self.valueForProperty(MPMediaItemPropertyAssetURL){
            return url
        }else{
            return nil
        }
    }
    
    func getArtWork() -> MPMediaItemArtwork? {
        if let artwork = self.artwork{
            return artwork
        }
        return nil
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
    
    func getURL() -> AnyObject? {
        return nil
    }
    
    func getArtWork() -> MPMediaItemArtwork? {
        return nil
    }
}

extension AVPlayerItem: Findable {
    func getTitle() -> String {
        if let title = self.asset.commonMetadata[0].stringValue {
            return title
        }
        return ""
    }
    func getArtist() -> String {
        for item in self.asset.commonMetadata {
            if item.commonKey  == "artist" {
                return item.stringValue!
            }
        }
        return ""
    }
    
    func getAlbum() -> String {
        if let album = self.asset.commonMetadata[3].stringValue {
            return album
        }
        return ""
    }
    
    func getDuration() -> Float {
        if let time:Float = Float(self.asset.duration.seconds) {
            return time
        }
        return 0.0
    }

    func getURL() -> AnyObject? {
        let currentPlayerAsset = self.asset
        
        if (!currentPlayerAsset.isKindOfClass(AVURLAsset)) {
            return nil
        }
        // return the NSURL
        return (currentPlayerAsset as! AVURLAsset).URL
    }
    
    func getArtWork() -> MPMediaItemArtwork?{
        for item in self.asset.commonMetadata {
                if item.commonKey  == "artwork" {
                    if let audioImage = UIImage(data: item.value as! NSData) {
                        return MPMediaItemArtwork(image: audioImage)
                    }
                }
        }
        return nil
    }
}

extension LocalSong: Findable {
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
        if let album = self.album {
            return album
        }
        return ""
    }
    
    func getDuration() -> Float {
        if let time = self.duration {
            return time as Float
        }
        return 0.0
    }
    
    func getURL() -> AnyObject? {
        return nil
    }
    
    func getArtWork() -> MPMediaItemArtwork? {
        return nil
    }
}


class CoreDataManager: NSObject {
    
    static let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
    
    //User-related
    class func logoutUser() {

        
        let userResults = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(User), withPredicate: nil, managedObjectContext: moc)
        let lyricsSetResults = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(LyricsSet), withPredicate: nil, managedObjectContext: moc)
        let tabsSetResults = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(TabsSet), withPredicate: nil, managedObjectContext: moc)
        
        let favorites = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: NSPredicate(format: " isFavorited == true"), managedObjectContext: moc) as! [Song]
        
        //delete all user objects just to make sure we have none left
        for o in userResults {
            moc.deleteObject(o as! NSManagedObject)
        }
        for o in lyricsSetResults {
            moc.deleteObject(o as! NSManagedObject)
        }
        for o in tabsSetResults {
            moc.deleteObject(o as! NSManagedObject)
        }
        
        for f in favorites {
            f.isFavorited = false
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
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(item.getTitle().replaceApostrophe())') AND (artist == '\(item.getArtist().replaceApostrophe())') AND (playbackDuration <= '\(item.getDuration() + 1)') AND (playbackDuration >= '\(item.getDuration() - 1)')")

        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
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
         //   print("sound wave data found for song")
            return NSKeyedUnarchiver.unarchiveObjectWithData(matchedSong.soundwaveData as! NSData) as? NSMutableArray
        }
        return nil
    }
    
    class func getSongWaveFormImage(item: Findable) -> NSData? {
        
        if let matchedSong = findSong(item) {
           // print("sound wave image found for song")
            return matchedSong.soundwaveImage
        }
        
        return nil

    }
    
    // MARK: save, retrieve lyrics, userId can be either localuserId or downloaded lyricsSet's user id
    class func saveLyrics(item: Findable, lyrics: [String], times: [Float], userId: Int, lyricsSetId: Int) {

        if let matchedSong = findSong(item) {
          
            let savedSets = matchedSong.lyricsSets.allObjects as! [LyricsSet]
            
            let lyricsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(lyrics as AnyObject)
            let timesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(times as AnyObject)
            
            //if let id = lyricsSetId where id > 0 { //if downloaded lyrics
            var foundDownloadedLyricsSet: LyricsSet!
            var found = false
            
            for set in savedSets {
                if set.id == lyricsSetId {
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
                lyricsSet.id = lyricsSetId
                lyricsSet.userId = userId
            }
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    //if fetchingLocalUserOnly true, will get the currently locally saved lyrics,
    //otherwise we will retrieve all lyricsSet(both local user's and downloaded) and select the most 
    //recently selected one
    class func getLyrics(item: Findable, fetchingLocalUserOnly: Bool) -> (Lyric, Int) {
        
        if let matchedSong = findSong(item) {
            print("has \(matchedSong.lyricsSets.count) set of lyrics")
        
            let sets = matchedSong.lyricsSets.allObjects as! [LyricsSet]
            
            var foundLyricsSet: LyricsSet!
            
            if fetchingLocalUserOnly {
                let localUserId = CoreDataManager.getCurrentUser()!.id
                foundLyricsSet = sets.filter({ $0.userId == localUserId }).first
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
            let foundLocalSet = savedSets.filter({ $0.userId == CoreDataManager.getCurrentUser()!.id }).first
            
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
            
            let foundLocalSet = savedSets.filter({ $0.userId == CoreDataManager.getCurrentUser()!.id }).first
            if foundLocalSet == nil {
                return
            }
            foundLocalSet?.lastSelectedDate = NSDate()
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }

    //We save both user edited tabs and downloaded tabs, the last parameter is for the downloaded tabs, if they match what we have in the database we don't store them
    class func saveTabs(item: Findable, chords: [String], tabs: [String], times:[NSTimeInterval], tuning:String, capo: Int, userId: Int, tabsSetId: Int) {
        
        if let matchedSong = findSong(item) {
            
            let savedSets = matchedSong.tabsSets.allObjects as! [TabsSet]
            let chordsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(chords as AnyObject)
            let tabsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(tabs as AnyObject)
            let timesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(times as AnyObject)
            
            var foundDownloadedTabsSet: TabsSet!
            var found = false

            for set in savedSets {
                if set.id == tabsSetId  {
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
                tabsSet.id = tabsSetId
                tabsSet.userId = userId
            }
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    
//    class func getAllLocalTabs() -> [LocalTabSet] {
//        let predicate: NSPredicate = NSPredicate(format: "(userId == \(CoreDataManager.getCurrentUser()!.id))")
//        do {
//            let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(TabsSet), withPredicate: predicate, managedObjectContext: moc)
//            var tabSets: [LocalTabSet] = [LocalTabSet]()
//            for result in results {
//                let temp = result as! TabsSet
//                let tabSet: LocalTabSet = LocalTabSet(id: temp.id as Int, song: temp.song)
//                tabSets.append(tabSet)
//            }
//            return tabSets
//        } catch {
//            fatalError("There was an error fetching all new tabs")
//        }
//    }
//    
//    
//    class func getAllLocalLyrics() -> [LocalLyrics] {
//        let predicate: NSPredicate = NSPredicate(format: "(userId == \(CoreDataManager.getCurrentUser()!.id))")
//        do {
//            let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(LyricsSet), withPredicate: predicate, managedObjectContext: moc)
//            var lyricsSets: [LocalLyrics] = [LocalLyrics]()
//            for result in results {
//                let temp = result as! LyricsSet
//                let lyricsSet: LocalLyrics = LocalLyrics(id: temp.id as Int, song: temp.song)
//                lyricsSets.append(lyricsSet)
//            }
//            return lyricsSets
//        } catch {
//            fatalError("There was an error fetching all new tabs")
//        }
//    }
    
    class func getAllLocalSongs() -> [LocalSong] {
        do {
            let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: nil, managedObjectContext: moc)
            var localSongs: [LocalSong] = [LocalSong]()
            for result in results {
                let temp = result as! Song
                let song: LocalSong = LocalSong()
                song.id = temp.id
                song.title = temp.title
                song.artist = temp.artist
                song.album = temp.album
                song.duration = temp.playbackDuration
                song.soundwaveData = temp.soundwaveData
                song.albumCover = temp.albumCover
                song.soundwaveImage = temp.soundwaveImage
                song.tabsSets = temp.tabsSets
                song.lyricsSets = temp.lyricsSets
                localSongs.append(song)
            }
            return localSongs
        } catch {
            fatalError("There was an error fetching all new tabs")
        }
    }
    
    //if fetchingLocalUserOnly true, will get the currently locally saved tabs,
    //otherwise we will retrieve all tabsSets(both local user's and downloaded) and select the most
    //recently selected one
    class func getTabs(item: Findable, fetchingLocalUserOnly: Bool) -> ([Chord], String, Int, Int) { //return chords, tuning and capo, song_id
        
        //song id is used to determine which tabs
        if let matchedSong = findSong(item) {
            print("has \(matchedSong.tabsSets.count) set of tabs")
            
            let sets = matchedSong.tabsSets.allObjects as! [TabsSet]
            
            var foundTabsSet: TabsSet!
            
            if fetchingLocalUserOnly {
                foundTabsSet = sets.filter({ $0.userId == CoreDataManager.getCurrentUser()!.id }).first
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


    //favorite/unfavorite a song
    class func favoriteTheSong(item: Findable, shouldFavorite: Bool) {
        if let matchedSong = findSong(item) {
            matchedSong.isFavorited = shouldFavorite
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func isFavorited(item: Findable) -> Bool {
        if let matchedSong = findSong(item) {
            return matchedSong.isFavorited
        }
        return false
    
    }
    
    class func saveSongId(findable: Findable, id: Int) {
        if let matchedSong = findSong(findable) {
            matchedSong.id = id
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }

    
    class func getSongId(findable: Findable) -> Int {
        if let matchedSong = findSong(findable) {
            return  Int(matchedSong.id!)
        }
        return 0 //should not reach here
    }
    
//    class func downloadUsersAllTabsLyricsSetToCoreData(id: NSNumber) {
//        let currentUserId: Int = id as Int
//        let localSongs: [LocalSong] = CoreDataManager.getAllLocalSongs()
//        APIManager.getUserTabsInfo(currentUserId, completion: {
//            downloadedTabSets in
//            let locaTabSets: [LocalLyrics] = CoreDataManager.getAllLocalLyrics()
//            print("local tab sets: \(locaTabSets.count)")
//            print("download tab sets: \(downloadedTabSets.count)")
//            for temp in downloadedTabSets {
//                if locaTabSets.count > 0 {
//                    for item in locaTabSets {
//                        if item.localSong.title == temp.title && item.localSong.artist == temp.artist && (item.localSong.playbackDuration as Float) <= temp.duration + 1 && (item.localSong.playbackDuration as Float) >= temp.duration - 1 {
//                            break
//                        } else {
//                            let local: LocalSong = LocalSong()
//                            local.title = item.localSong.title
//                            local.artist = item.localSong.artist
//                            local.album = item.localSong.album
//                            local.duration = item.localSong.playbackDuration
//                            local.soundwaveData = item.localSong.soundwaveData
//                            local.albumCover = item.localSong.albumCover
//                            local.soundwaveImage = item.localSong.soundwaveImage
//                            local.tabsSets = item.localSong.tabsSets
//                            local.lyricsSets = item.localSong.lyricsSets
//                            local.id = -1
//                            let downloadTabsContent: DownloadedTabsSet = DownloadedTabsSet()
//                            downloadTabsContent.id = temp.id
//                            APIManager.downloadTabsSetContent(downloadTabsContent, completion: {
//                                downloadWithContent in
//                                let times: [NSTimeInterval] = downloadTabsContent.times.map{(Float time) -> NSTimeInterval in
//                                    let output: NSTimeInterval = NSTimeInterval(time)
//                                    return output
//                                }
////                                CoreDataManager.saveMyTabs(local as Findable, chords: downloadTabsContent.chords, tabs: temp.tabs, times: times, tuning: temp.tuning, capo: temp.capo, id: temp.id)
//                                print("tabs save to core data: \(item.localSong.title)")
//                            })
//                            
//                        }
//                    }
//                } else {
//                    for item in localSongs {
//                        if item.title == temp.title && item.artist == temp.artist && (item.duration as Float) <= temp.duration + 1 && (item.duration as Float) >= temp.duration - 1 {
//                            let downloadTabsContent: DownloadedTabsSet = DownloadedTabsSet()
//                            downloadTabsContent.id = temp.id
//                            APIManager.downloadTabsSetContent(downloadTabsContent, completion: {
//                                downloadWithContent in
//                                let times: [NSTimeInterval] = downloadTabsContent.times.map{(Float time) -> NSTimeInterval in
//                                    let output: NSTimeInterval = NSTimeInterval(time)
//                                    return output
//                                }
////                                CoreDataManager.saveMyTabs(item as Findable, chords: temp.chords, tabs: temp.tabs, times: times, tuning: temp.tuning, capo: temp.capo, id: temp.id)
//                                print("tabs save to core data: \(item.title)")
//                            })
//                        }
//                    }
//                }
//            }
//            
//        })
//        APIManager.getUserLyricsInfo(currentUserId, completion: {
//            downloadedLyricsSets in
//            let localLyricsSets: [LocalLyrics] = CoreDataManager.getAllLocalLyrics()
//            print("local tabssets: \(localLyricsSets.count)")
//            print("downloaded lyrics set: \(downloadedLyricsSets.count)")
//            for temp in downloadedLyricsSets {
//                if localLyricsSets.count > 0 {
//                    for item in localLyricsSets {
//                        if item.localSong.title == temp.title && item.localSong.artist == temp.artist && (item.localSong.playbackDuration as Float) <= temp.duration + 1 && (item.localSong.playbackDuration as Float) >= temp.duration - 1 {
//                            break
//                        } else {
//                            let local: LocalSong = LocalSong()
//                            local.title = item.localSong.title
//                            local.artist = item.localSong.artist
//                            local.album = item.localSong.album
//                            local.duration = item.localSong.playbackDuration
//                            local.soundwaveData = item.localSong.soundwaveData
//                            local.albumCover = item.localSong.albumCover
//                            local.soundwaveImage = item.localSong.soundwaveImage
//                            local.tabsSets = item.localSong.tabsSets
//                            local.lyricsSets = item.localSong.lyricsSets
//                            local.id = -1
//                            
//                            let downloadLyricsContent: DownloadedLyricsSet = DownloadedLyricsSet()
//                            downloadLyricsContent.id = temp.id
//                            APIManager.downloadLyricsSetContent(downloadLyricsContent, completion: {
//                                downloadWithContent in
////                                CoreDataManager.saveMyLyrics(local as Findable, lyrics: downloadLyricsContent.lyrics, times: downloadLyricsContent.times, id: temp.id)
//                                print("lyrics save to core data: \(item.localSong.title)")
//                            })
//                            
//                        }
//                    }
//                } else {
//                    for item in localSongs {
//                        if item.title == temp.title && item.artist == temp.artist && (item.duration as Float) <= temp.duration + 1 && (item.duration as Float) >= temp.duration - 1 {
//                            let downloadLyricsContent: DownloadedLyricsSet = DownloadedLyricsSet()
//                            downloadLyricsContent.id = temp.id
//                            APIManager.downloadLyricsSetContent(downloadLyricsContent, completion: {
//                                downloadWithContent in
////                                CoreDataManager.saveMyLyrics(item as Findable, lyrics: temp.lyrics, times: temp.times, id: temp.id)
//                                print("lyrics save to core data: \(item.title)")
//                            })
//                        }
//                    }
//                }
//            }
//        })
//    }
//
//    class func downloadMyLyricsFromDatabase(sender: Findable) -> DownloadedLyricsSet {
//        let download: DownloadedLyricsSet = DownloadedLyricsSet()
//        let allLyrics = CoreDataManager.getAllLocalLyrics()
//        for item in allLyrics {
//            if item.localSong.title == sender.getTitle() && item.localSong.artist == sender.getArtist() && (item.localSong.playbackDuration as Float) <= sender.getDuration() + 1 && (item.localSong.playbackDuration as Float) >= sender.getDuration() - 1 {
//                download.id = item.id
//            }
//        }
//        APIManager.downloadLyricsSetContent(download, completion: {
//            downloadWithContent in
//            return download
//        })
//        return download
//    }
}




