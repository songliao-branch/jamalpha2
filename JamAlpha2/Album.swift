
import Foundation
import MediaPlayer



class Album:NSObject{
    
    var albumTitle:String = ""
    var artistPersistantId:CUnsignedLongLong!
    var coverImage:MPMediaItemArtwork!
    var artistName:String = ""
    var numberOfTracks:Int = 0
    var totalRunningTime:NSTimeInterval = 0.0
    
    let representativeItem:MPMediaItem // this value must exist, it is not an optional
    
    var songsIntheAlbum:[MPMediaItem]!
    
    init(theItem:MPMediaItem){
     
        self.representativeItem = theItem
       // println("Album represent item: \(representativeItem.title)")
        
        self.albumTitle = representativeItem.albumTitle!
       // println(albumTitle)
        self.artistName = representativeItem.artist!
      //  println(artistName)
        self.coverImage = representativeItem.artwork!
        self.artistPersistantId = representativeItem.artistPersistentID
        var albumPredicate = MPMediaPropertyPredicate(value: albumTitle, forProperty: MPMediaItemPropertyAlbumTitle)
        var artistPredicate = MPMediaPropertyPredicate(value:artistName, forProperty:
            MPMediaItemPropertyArtist)
        
        var albumAndArtistQuery = MPMediaQuery()
        
        albumAndArtistQuery.addFilterPredicate(albumPredicate)
        albumAndArtistQuery.addFilterPredicate(artistPredicate)
        
        self.songsIntheAlbum = albumAndArtistQuery.items as! [MPMediaItem]
        
        //make sure there is no short song
        songsIntheAlbum.filter({song in song.playbackDuration > 30 })
      
        for song in songsIntheAlbum {
            self.totalRunningTime += song.playbackDuration
        }
        self.numberOfTracks = songsIntheAlbum.count

       // println(totalRunningTime)
     //   println(numberOfTracks)
        
    }
    
}
