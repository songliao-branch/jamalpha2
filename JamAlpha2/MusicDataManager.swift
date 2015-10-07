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

class MusicDataManager: NSObject {
    
    let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
    
    private func findSong(item: MPMediaItem) -> Song? {
        // TODO: other special characters might corrupt the predicate, needs to check more later
        let title = item.title!.replaceApostrophe()
        let artist = item.artist!.replaceApostrophe()
        let album = item.albumTitle!.replaceApostrophe()
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(title)') AND (artist == '\(artist)') AND (album == '\(album)')")
        
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
            print("song doesn't exist")
            return nil
        } else {
            print("song found in core data")

            return results.lastObject! as? Song
        }
    }
    
    func initializeSongToDatabase(item: MPMediaItem) {
        // if we don't have the song in the database
        if findSong(item) == nil {
            let song: Song = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Song), managedObjectConect: moc) as! Song
            song.title = item.title!
            song.artist = item.artist!
            song.album = item.albumTitle!
            song.playbackDuration = Float(item.playbackDuration)
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    
    // MARK: save, retrieve soundwaves
    func saveSoundWave(item: MPMediaItem, soundwaveData: NSMutableArray, soundwaveImage: NSData) {
        
        if let matchedSong = findSong(item) {
            let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(soundwaveData as AnyObject)
            matchedSong.soundwaveData = data
            matchedSong.soundwaveImage = soundwaveImage
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
    }
    

    func getSongWaveFormData(item: MPMediaItem) -> NSMutableArray? {
        if let matchedSong = findSong(item) {
            print("sound wave data found for song")

            return NSKeyedUnarchiver.unarchiveObjectWithData(matchedSong.soundwaveData as! NSData) as? NSMutableArray
        }
        return nil
    }
    
    func getSongWaveFormImage(item: MPMediaItem) -> NSData? {
        if let matchedSong = findSong(item) {
            print("sound wave image found for song")
            return matchedSong.soundwaveImage
        }
        return nil

    }
    
    // MARK: save, retrieve lyrics
    func saveLyrics(item: MPMediaItem, lyrics: [String], times: [NSTimeInterval]) {
        
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
    
    func getLyrics(item: MPMediaItem) -> [(String, NSTimeInterval)] {
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
}