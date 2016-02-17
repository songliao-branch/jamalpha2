


//TODO: whole model upon change when figuring out spotify api music model and ipod music library
import Foundation
import MediaPlayer

//Sortable protocol method used in MusicViewController to sort artist into sections by first alphabet
protocol Sortable {
    func getSortableName()-> String
}

extension MPMediaItem: Sortable {
    func getSortableName() -> String {
        return self.title!
    }
}

class Artist: NSObject, Sortable {
    
    var artistName:String
    
    var numberOfTracks:Int = 0
    var totalRunningTime:NSTimeInterval = 0.0
    
    private var albums = [Album]()
    private var allSongs: [MPMediaItem]!
    
    init(artist:String){
        self.artistName = artist
    }
    
    func addAlbum(album:Album){
        self.albums.append(album)
        self.numberOfTracks += album.getNumberOfTracks()
        self.totalRunningTime += album.getTotalRunningTime()
    }
    
    func getAlbums() -> [Album]{
        return albums.sort({ album1, album2 in
            return album1.getYearReleased() > album2.getYearReleased()
        })
    }
    
    func getSongs()-> [MPMediaItem] {
        allSongs = [MPMediaItem]()
        for album in self.getAlbums() {
            for song in album.getSongs() {
                allSongs.append(song)
            }
        }
        return allSongs
    }
   
    func getSortableName() -> String {
        return artistName
    }
}
