


//TODO: whole model upon change when figuring out spotify api music model and ipod music library
import Foundation

class Artist: NSObject {
    
    var artistName:String
    
    var numberOfTracks:Int = 0
    var totalRunningTime:NSTimeInterval = 0.0
    private var albums = [Album]()
    
    init(artist:String){
        self.artistName = artist
    }
    
//    init(albums: [Album]){
//        super.init()
//        self.artistName = albums[0].artistName
//        self.albums = albums
//        for album in albums {
//            self.numberOfTracks += album.numberOfTracks
//            self.totalRunningTime += album.totalRunningTime
//        }
//    } 
    
    func addAlbum(album:Album){
        self.albums.append(album)
        self.numberOfTracks += album.numberOfTracks
        self.totalRunningTime += album.totalRunningTime
    }
    
    func getAlbums() -> [Album]{
        return self.albums
    }
}