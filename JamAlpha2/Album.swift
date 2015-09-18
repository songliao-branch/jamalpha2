
import Foundation
import MediaPlayer



class Album:NSObject{
    
    var albumTitle:String = ""
    var artistPersistantId:CUnsignedLongLong!
    var coverImage:MPMediaItemArtwork!
    var artistName:String = ""
    var numberOfTracks:Int = 0
    var totalRunningTime:NSTimeInterval = 0.0
    
    var releasedDate: NSDate? //can be nil if user add their own songs
    
    let representativeItem:MPMediaItem // this value must exist, it is not an optional
    
    var songsIntheAlbum:[MPMediaItem]!
    
    init(theItem: MPMediaItem){
     
        self.representativeItem = theItem
       // println("Album represent item: \(representativeItem.title)")
        
        self.albumTitle = representativeItem.albumTitle!
       // println(albumTitle)
        self.artistName = representativeItem.artist!
      //  println(artistName)
        self.coverImage = representativeItem.artwork!
        
        if let date = representativeItem.valueForProperty(MPMediaItemPropertyReleaseDate) as? NSDate {
            self.releasedDate = date
        }

        self.artistPersistantId = representativeItem.artistPersistentID
        let albumPredicate = MPMediaPropertyPredicate(value: albumTitle, forProperty: MPMediaItemPropertyAlbumTitle)
        let artistPredicate = MPMediaPropertyPredicate(value:artistName, forProperty:
            MPMediaItemPropertyArtist)
        
        let albumAndArtistQuery = MPMediaQuery()
        
        albumAndArtistQuery.addFilterPredicate(albumPredicate)
        albumAndArtistQuery.addFilterPredicate(artistPredicate)
        
        self.songsIntheAlbum = albumAndArtistQuery.items!

        //make sure there is no short song
        songsIntheAlbum.filter({song in song.playbackDuration > 30 })
      
        for song in songsIntheAlbum {
            self.totalRunningTime += song.playbackDuration
        }
        self.numberOfTracks = songsIntheAlbum.count

        
    }
    
}
