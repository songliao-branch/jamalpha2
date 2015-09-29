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

class MusicDataManager: NSObject {
    
    let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
    
    func findSong(item: MPMediaItem) -> Song? {
        print("title is \(item.title!)")
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(item.title!)') AND (artist == '\(item.artist!)')")
        
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
    
    func saveSoundWave(item: MPMediaItem, soundwaveData: NSMutableArray, soundwaveImage: NSData) {
        
        if let matchedSong = findSong(item) {
            let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(soundwaveData as AnyObject)
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
}