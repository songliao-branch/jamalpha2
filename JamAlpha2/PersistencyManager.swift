
// THIS CLASS IS USED FOR TESTING and Practicing, not used anymore


import Foundation
import MediaPlayer

class PersistencyManager: NSObject{
    
    private var artists = [Artist]()
    private var songItems:[MPMediaItem]!
    private var artistItems:[MPMediaItem]!//unique
    private var albumItems:[MPMediaItem]!
    
    private var albums = [Album]()
    
    override init(){
        super.init()

        println("Persistancy manager initialized")
        
        var songCollection = MPMediaQuery.songsQuery()
        songItems = songCollection.items as! [MPMediaItem]
       
        var query = MPMediaQuery()
        query.groupingType = MPMediaGrouping.Album;
        var albums = query.collections
        for album in albums{
            var representativeItem = album.representativeItem as MPMediaItem
            var artistName = representativeItem.valueForProperty(MPMediaItemPropertyAlbumArtist) as! String
            var albumName = representativeItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String
            album.item
            var whichSong = representativeItem.valueForProperty(MPMediaItemPropertyTitle) as! String
            
            println("\(albumName)  by \(artistName) song: \(whichSong)")
            //ok now I have album..now retrive the next task
        }

    }
    
    func getSongItems()->[MPMediaItem]{
        return self.songItems
    }
    
    func getAlbumItems()->[MPMediaItem]{
        return self.albumItems
    }
    
    func getArtistItem()->[MPMediaItem]{
        return self.artistItems
    }
    
    func getArtists() -> [Artist] {
        return self.artists
    }
    
    func getAlbums()->[Album]{
        return self.albums
    }

}
