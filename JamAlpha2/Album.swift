
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


class Album: NSObject, Sortable {
    
    var albumTitle: String = ""
    private var songsIntheAlbum: [MPMediaItem]!
    
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
    
    func getSongs() -> [MPMediaItem] {
       return self.songsIntheAlbum.sort{
            song1, song2 in
            return song1.albumTrackNumber < song2.albumTrackNumber
        }
    }
    
    //Sortable protocol method used in MusicViewController to sort albums into sections by first alphabet
    func getSortableName() -> String {
        return self.albumTitle
    }
}
