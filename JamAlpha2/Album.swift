
import Foundation
import MediaPlayer



class Album: NSObject, Sortable {
    
    var albumTitle: String = ""
    var songsIntheAlbum: [MPMediaItem]!
    
    //derivatives
//    var coverImage: MPMediaItemArtwork?
//    var artistName: String = ""
//    var numberOfTracks: Int = 0
//    var totalRunningTime: NSTimeInterval = 0.0
//    var yearReleased = 0 //can be nil if user add their own songs
    
    init(album: String, collection: [MPMediaItem]) {
        self.albumTitle = album
        self.songsIntheAlbum = collection
    }
    func addSong(song: MPMediaItem) {
        songsIntheAlbum.append(song)
    }
    
    func getCoverImage() -> MPMediaItemArtwork? {
        for song in songsIntheAlbum {
            if let artwork = song.artwork {
                return artwork
            }
        }
        return nil
    }
    
    func getNumberOfTracks() -> Int {
        return songsIntheAlbum.count
    }
    
    func getArtist() -> String {
        return songsIntheAlbum[0].artist!
    }
    
    func getTotalRunningTime() -> NSTimeInterval {
        var time = 0.0
        for song in songsIntheAlbum {
            time += song.playbackDuration
        }
        return time
    }
    
    func getYearReleased() -> Int {
        var year = 0
        for song in songsIntheAlbum {
            year = song.valueForProperty("year") as! Int
            if year > 1000 {
                return year
            }
        }
        return 0
    }
    
//    init(theItem: MPMediaItem){
//     
//        self.representativeItem = theItem
//        self.albumTitle = representativeItem.albumTitle!
//        self.artistName = representativeItem.getArtist()
//        
//        if let cover = representativeItem.getArtWork()  {
//            self.coverImage = cover
//        }
//        
//        self.artistPersistantId = representativeItem.artistPersistentID
//        let albumPredicate = MPMediaPropertyPredicate(value: albumTitle, forProperty: MPMediaItemPropertyAlbumTitle)
//        let artistPredicate = MPMediaPropertyPredicate(value:artistName, forProperty:
//            MPMediaItemPropertyArtist)
//        
//        let albumAndArtistQuery = MPMediaQuery()
//        
//        albumAndArtistQuery.addFilterPredicate(albumPredicate)
//        albumAndArtistQuery.addFilterPredicate(artistPredicate)
//        
//        self.songsIntheAlbum = albumAndArtistQuery.items!
//
//        //make sure there is no short song
//        songsIntheAlbum = songsIntheAlbum.filter({song in song.playbackDuration > 30 })
//        
//        for song in songsIntheAlbum {
//            self.totalRunningTime += song.playbackDuration
//        }
//        
//        // loop through all songs in the album till we find the one with an album year
//        for song in songsIntheAlbum {
//            let year = song.valueForProperty("year") as! Int
//            self.yearReleased = year
//            if year > 1000 {
//                self.yearReleased = year
//                break
//            }
//        }
//        self.numberOfTracks = songsIntheAlbum.count
//    }
    
    //Sortable protocol method used in MusicViewController to sort albums into sections by first alphabet
    func getSortableName() -> String {
        return self.albumTitle
    }
}
