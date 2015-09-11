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

class SongManager: NSObject {

    let moc: NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
    
    func addNewSong(item: MPMediaItem, soundwave: NSData) {
        var song: Song = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Song), managedObjectConect: moc) as! Song
        song.title = item.title
        song.artist = item.artist
        song.album = item.albumTitle
        song.playbackDuration = Float(item.playbackDuration)
        song.soundwave = soundwave
        
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
    }
    
    func getSongWaveForm(item: MPMediaItem) -> NSData? {
    
        let predicate: NSPredicate = NSPredicate(format: "(title == '\(item.title)') AND (artist == '\(item.artist)')")
        
        let results: NSArray = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Song), withPredicate: predicate, managedObjectContext: moc)
        
        if results.count == 0 {
            return nil
        }
        
        let song: Song = results.lastObject as! Song
        
        return song.soundwave
    }
}