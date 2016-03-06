
import Foundation
import MediaPlayer

class SimpleAlbum: NSObject, Sortable {

    var songCollection: MPMediaItemCollection!

    init(collection: MPMediaItemCollection) {
      self.songCollection = collection
    }
    
    func getAlbumTitle() -> String {
        if let title = self.songCollection.representativeItem?.albumTitle {
            return title
        }
        return ""
    }
    
    func getArtist() -> String {
        if let artist = self.songCollection.representativeItem?.artist {
            return artist
        }
        return ""
    }
    
    func getArtwork() -> MPMediaItemArtwork? {
        for item in self.songCollection.items {
            if let artwork = item.artwork {
                return artwork
            }
        }
        return nil
    }
    
    func getYearReleased() -> Int {
        var year = 0
        for song in songCollection.items {
            year = song.valueForProperty("year") as! Int
            if year > 1000 {
                return year
            }
        }
        return 0
    }
    
    func getSortableName() -> String {
        return getAlbumTitle()
    }
}

