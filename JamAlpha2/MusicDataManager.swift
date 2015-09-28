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
    
    func addNewSong(item: MPMediaItem, soundwaveData: NSMutableArray, soundwaveImage: NSData) {
        let song: Song = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Song), managedObjectConect: moc) as! Song
        song.title = item.title!
        song.artist = item.artist!
        song.album = item.albumTitle!
        song.playbackDuration = Float(item.playbackDuration)
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(soundwaveData as AnyObject)
        song.soundwaveData = data
        song.soundwaveImage = soundwaveImage
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    

    func getSongWaveFormData(item: MPMediaItem) -> NSMutableArray? {
        // TODO: make this predicate more secure
        // BUG: words like `Don'\t`, the \ is messing up the predicate
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(item.title!)') AND (artist == '\(item.artist!)')")
        
        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
            print("none found in database")
            return nil
        }
        
        let song: Song = results.lastObject as! Song
      
        return NSKeyedUnarchiver.unarchiveObjectWithData(song.soundwaveData as! NSData) as? NSMutableArray
    }
    
    func getSongWaveFormImage(item: MPMediaItem) -> NSData? {
        // TODO: make this predicate more secure
        // BUG: words like `Don'\t`, the \ is messing up the predicate
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(item.title!)') AND (artist == '\(item.artist!)')")
        
        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
            print("none found in database")
            return nil
        }
        
        let song: Song = results.lastObject as! Song
        
        return song.soundwaveImage
    }
}