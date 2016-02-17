
import Foundation
import MediaPlayer



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
