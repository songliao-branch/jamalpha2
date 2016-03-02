

import Foundation
import MediaPlayer

class SimpleArtist: NSObject, Sortable {
    
    var songCollection: MPMediaItemCollection!
    private var albums = [SimpleAlbum]()
    private var allSongs = [MPMediaItem]()
    
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
    
    func getSortableName() -> String {
        return getArtist()
    }
    
    func getArtwork() -> MPMediaItemArtwork? {
        for item in self.songCollection.items {
            if let artwork = item.artwork {
                return artwork
            }
        }
        return nil
    }
    
    func getAllSongs() -> [MPMediaItem] {
        
        allSongs = [MPMediaItem]()
        for album in getAlbums() {
            for item in album.songCollection.items {
                allSongs.append(item)
            }
        }
        return allSongs
    }
    
    
    func getAlbums() -> [SimpleAlbum] {
        
        if albums.count == 0 {
            print("generate albums")
            var itemsDictionary = [String: [MPMediaItem]]()
            
            for item in songCollection.items {
                let album = item.albumTitle == nil ? "" : item.albumTitle!
                
                if itemsDictionary[album] == nil {
                    itemsDictionary[album] = []
                    
                }
                itemsDictionary[album]?.append(item)
            }
            for (_, values) in itemsDictionary {
                let album = SimpleAlbum(collection: MPMediaItemCollection(items: values))
                albums.append(album)
            }
            
            albums = albums.sort({ album1, album2 in
                return album1.getYearReleased() > album2.getYearReleased() })
            return albums
        }
        return albums
    }
}