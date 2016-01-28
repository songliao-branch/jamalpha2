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
    func isKindOfClass(aClass: AnyClass) -> Bool
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
        return self.trackName
    }
    func getArtist() -> String {
        return artistName
    }
    
    func getAlbum() -> String {
        return collectionName
    }
    
    func getDuration() -> Float {
        return trackTimeMillis
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
        return title
    }
    
    func getArtist() -> String {
        return artist
    }
    
    func getAlbum() -> String {
        return ""
    }
    
    func getDuration() -> Float {
        return self.duration
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
    class func findSong(item: Findable) -> Song? {
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(item.getTitle().replaceApostrophe())') AND (artist == '\(item.getArtist().replaceApostrophe())') AND (playbackDuration <= '\(item.getDuration() + 1.5)') AND (playbackDuration >= '\(item.getDuration() - 1.5)')")

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
    class func saveSoundWave(item: Findable, soundwaveImage: NSData) {
        if let matchedSong = findSong(item) {
            matchedSong.soundwaveImage = soundwaveImage
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }

    class func getSongWaveFormImage(item: Findable) -> NSData? {
        if let matchedSong = findSong(item) {
           // print("sound wave image found for song")
            return matchedSong.soundwaveImage
        }
        
        return nil

    }
    
    
    class func saveCoverImage(item: Findable, coverImage: UIImage) {
        let imageData = UIImagePNGRepresentation(coverImage)
        if let matchedSong = findSong(item) {
            matchedSong.albumCover = imageData!
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func getCoverImage(item: Findable) -> UIImage? {
        if let matchedSong = findSong(item) {
            // print("sound wave image found for song")
            return   UIImage(data: matchedSong.albumCover)
        }
        
        return nil
        
    }
    
    // MARK: save, retrieve lyrics, userId can be either localuserId or downloaded lyricsSet's user id
    class func saveLyrics(item: Findable, lyrics: [String], times: [Float], userId: Int, lyricsSetId: Int, lastEditedDate: NSDate?=nil) {

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
                    
                    if let lastEdited = lastEditedDate {
                        foundDownloadedLyricsSet.lastEditedDate = lastEdited
                    }
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
                
                if let lastEdited = lastEditedDate {
                    lyricsSet.lastEditedDate = lastEdited
                }
            }
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    //if fetchingLocalUserOnly true, will get user's lyrics,
    //otherwise we will retrieve all lyricsSet and select the most
    //recently selected one
    class func getLyrics(item: Findable, fetchingUsers: Bool) -> (Lyric, Int) { //return lyrics count and lyrics set id
        
        if let matchedSong = findSong(item) {
            print("has \(matchedSong.lyricsSets.count) set of lyrics")
        
            let sets = matchedSong.lyricsSets.allObjects as! [LyricsSet]
            
            var foundLyricsSet: LyricsSet!
            
            if fetchingUsers {
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
    
    class func setUserLyricsMostRecent(item: Findable) {
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
    
    class func setUserTabsMostRecent (item: Findable) {
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
    class func saveTabs(item: Findable, chords: [String], tabs: [String], times:[Float], tuning:String, capo: Int, userId: Int, tabsSetId: Int, visible: Bool, lastEditedDate: NSDate?=nil) {//last parameter is only required for user tabs
        
        if let matchedSong = findSong(item) {
            
            let savedSets = matchedSong.tabsSets.allObjects as! [TabsSet]
            let chordsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(chords as AnyObject)
            let tabsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(tabs as AnyObject)
            let timesData: NSData = NSKeyedArchiver.archivedDataWithRootObject(times as AnyObject)
            
            var foundTabsSet: TabsSet!
            var found = false
            
            for set in savedSets {
                if set.id == tabsSetId  {
                    foundTabsSet = set
                    found = true
                    foundTabsSet.chords = chordsData
                    foundTabsSet.tabs = tabsData
                    foundTabsSet.times = timesData
                    foundTabsSet.tuning = tuning
                    foundTabsSet.capo = capo
                    foundTabsSet.lastSelectedDate = NSDate()
                    foundTabsSet.visible = visible
                    
                    //save last edited date of only user tabs, this is used to sorted descending in my tabs
                    if let lastEdited = lastEditedDate {
                        foundTabsSet.lastEditedDate = lastEdited
                    }
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
                tabsSet.visible = visible
                
                if let lastEdited = lastEditedDate {
                    tabsSet.lastEditedDate = lastEdited
                }
            }
            
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func getAllUserTabsOnDisk() -> [DownloadedTabsSet] {
        
        var sets = [DownloadedTabsSet]()
        let predicate: NSPredicate = NSPredicate(format: "(userId == \(CoreDataManager.getCurrentUser()!.id))")
        
        var results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(TabsSet), withPredicate: predicate, managedObjectContext: moc) as! [TabsSet]
        
        results.sortInPlace({
            setA, setB in
            return setA.lastEditedDate.compare(setB.lastEditedDate) == NSComparisonResult.OrderedDescending
        })
        
        for result in results {
            let temp = result
            
            let t = DownloadedTabsSet(id: Int(temp.id), tuning: temp.tuning, capo: Int(temp.capo), chordsPreview: "", votesScore: 0, voteStatus: "", editor: Editor(), lastEdited: "")
            
            let chords = NSKeyedUnarchiver.unarchiveObjectWithData(temp.chords as! NSData) as! [String]
            let tabs = NSKeyedUnarchiver.unarchiveObjectWithData(temp.tabs as! NSData) as! [String]
            let times = NSKeyedUnarchiver.unarchiveObjectWithData(temp.times as! NSData) as! [Float]
            
            t.chords = chords 
            t.tabs = tabs
            
            var theTimes = [Float]()
            for t in times {
                theTimes.append(Float(t))
            }
            t.times = theTimes
            t.visible = temp.visible
            //used to display in the table
            t.title = temp.song.title
            t.artist = temp.song.artist
            t.duration = Float(temp.song.playbackDuration)
            
            sets.append(t)
        }
        return sets
    }
    
    class func getAllUserLyricsOnDisk() -> [DownloadedLyricsSet] {
        
        var sets = [DownloadedLyricsSet]()
        let predicate: NSPredicate = NSPredicate(format: "(userId == \(CoreDataManager.getCurrentUser()!.id))")
        
        var results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(LyricsSet), withPredicate: predicate, managedObjectContext: moc) as! [LyricsSet]
        
        results.sortInPlace({
            setA, setB in
            return setA.lastEditedDate.compare(setB.lastEditedDate) == NSComparisonResult.OrderedDescending
        })
        
        for result in results {
            let temp = result
            
            let l = DownloadedLyricsSet(id: Int(temp.id), lyricsPreview: "", numberOfLines: 0, votesScore: 0, voteStatus: "", editor: Editor(),lastEdited: "")
            
            let lyrics = NSKeyedUnarchiver.unarchiveObjectWithData(temp.lyrics as! NSData) as! [String]
            let times = NSKeyedUnarchiver.unarchiveObjectWithData(temp.times as! NSData) as! [Float]
            
            l.lyrics = lyrics
            l.times = times
            
            //used to display in the table
            l.title = temp.song.title
            l.artist = temp.song.artist
            l.duration = Float(temp.song.playbackDuration)
            sets.append(l)
        }
        return sets
    }

    
    //if fetchingLocalUserOnly true, will get the currently locally saved tabs,
    //otherwise we will retrieve all tabsSets(both local user's and downloaded) and select the most
    //recently selected one
    class func getTabs(item: Findable, fetchingUsers: Bool) -> ([Chord], String, Int, Int, Bool) { //return chords, tuning and capo, tabsSet id, visible
        
        //song id is used to determine which tabs
        if let matchedSong = findSong(item) {
            
            let sets = matchedSong.tabsSets.allObjects as! [TabsSet]
            
            var foundTabsSet: TabsSet!
            
            
            if fetchingUsers {
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
                return ([Chord](), "", 0, 0, false)
            }
            
            let chords = NSKeyedUnarchiver.unarchiveObjectWithData(foundTabsSet.chords as! NSData) as! [String]
            let tabs = NSKeyedUnarchiver.unarchiveObjectWithData(foundTabsSet.tabs as! NSData) as! [String]
            let times = NSKeyedUnarchiver.unarchiveObjectWithData(foundTabsSet.times as! NSData) as! [Float]
            
            var chordsToBeUsed = [Chord]()
            
            for i in 0..<chords.count {
                let singleChord = Tab(name: chords[i], content: tabs[i])
                let timedChord = Chord(tab: singleChord, time: TimeNumber(time: times[i]))
                chordsToBeUsed.append(timedChord)
            }
            return (chordsToBeUsed, foundTabsSet.tuning, Int(foundTabsSet.capo), Int(foundTabsSet.id), foundTabsSet.visible)
        }
        return ([Chord](), "", 0, 0, false)
    }
    
    
    class func deleteUserTabs(setId: Int) {
        let sets = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(TabsSet), withPredicate: NSPredicate(format: "id == \(setId)"), managedObjectContext: moc) as! [TabsSet]
        
        if sets.count == 1 {
            moc.deleteObject(sets[0])
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    class func deleteUserlyrics(setId: Int) {
        let sets = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(LyricsSet), withPredicate: NSPredicate(format: "id == \(setId)"), managedObjectContext: moc) as! [LyricsSet]
        
        if sets.count == 1 {
            moc.deleteObject(sets[0])
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    //a local tabs that has never been uploaded will have an id -1, once it's uploaded, the retrieved cloud id will
    class func saveCloudIdToTabs(findable: Findable, cloudId: Int) {
        if let matchedSong = findSong(findable) {
            let sets = matchedSong.tabsSets.allObjects as! [TabsSet]
            
            var foundTabsSet: TabsSet!
            
            foundTabsSet = sets.filter({ $0.userId == CoreDataManager.getCurrentUser()!.id }).first
            
            if foundTabsSet != nil {
                foundTabsSet.id = cloudId
                SwiftCoreDataHelper.saveManagedObjectContext(moc)
            }
        }
    }
    
    class func saveCloudIdToLyrics(findable: Findable, cloudId: Int) {
        if let matchedSong = findSong(findable) {
            let sets = matchedSong.lyricsSets.allObjects as! [LyricsSet]
            
            var foundLyricsSet: LyricsSet!
            
            foundLyricsSet = sets.filter({ $0.userId == CoreDataManager.getCurrentUser()!.id }).first
            
            if foundLyricsSet != nil {
                foundLyricsSet.id = cloudId
                SwiftCoreDataHelper.saveManagedObjectContext(moc)
            }
        }
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
    
    class func getFavorites() -> [LocalSong] {
        let favorites = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: NSPredicate(format: " isFavorited == true"), managedObjectContext: moc) as! [Song]
        var localSongs = [LocalSong]()
        for fav in favorites {
            let song = LocalSong(title: fav.title, artist: fav.artist, duration: Float(fav.playbackDuration))
            localSongs.append(song)
        }
        return localSongs
    }
    
    class func setSongId(item: Findable, id: Int) {
        if let matchedSong = findSong(item) {
            matchedSong.id = id
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    // used to update soundwave_url
    class func getSongId(item: Findable) -> Int {
        if let matchedSong = findSong(item) {
            return Int(matchedSong.id)
        }
        return 0
    }
}




