
// Abstraction layer for system music library fetching


import Foundation
import MediaPlayer

class PersistencyManager: NSObject{
    
    private var artists = [Artist]()
    
    private var songItems:[MPMediaItem]!
    private var artistItems:[MPMediaItem]!//unique
    private var albumItems:[MPMediaItem]!
    
    override init(){
        super.init()

        println("Persistancy manager initialized")
        
        var songCollection = MPMediaQuery.songsQuery()
        songItems = songCollection.items as! [MPMediaItem]
        
        var artistCollection = MPMediaQuery.artistsQuery()
        artistItems = artistCollection.items as! [MPMediaItem]

        
        //TODO: fix this filtering
        var uniqueArtist = [MPMediaItem]()
        for index in 1...artistItems.count-1 {
            var currentId = artistItems[index].artistPersistentID as CUnsignedLongLong
            var previousId = artistItems[index-1].artistPersistentID as CUnsignedLongLong
            if currentId != previousId {
                uniqueArtist.append(artistItems[index])
                
            }
        }
        artistItems = uniqueArtist
        
        var albumCollection = MPMediaQuery.albumsQuery()
        albumItems = albumCollection.items as! [MPMediaItem]
        var uniqueAlbums = [MPMediaItem]()
        for index in 1...albumItems.count-1 {
            var currentId = albumItems[index].albumPersistentID as CUnsignedLongLong
            var previousId = albumItems[index-1].albumPersistentID as CUnsignedLongLong
            if currentId != previousId {
                uniqueAlbums.append(albumItems[index])
            }
        }
        albumItems = uniqueAlbums
        
        //delete this
        let theATeam = Song(title: "The A Team")
        let drunk = Song(title: "Drunk")
        let UNI = Song(title: "UNI")
        let grade8 = Song(title: "Grade8")
        let smallBump = Song(title: "Small Bump")
        let this = Song(title: "This")
        let legoHouse = Song(title:"Lego House")
        let kissMe = Song(title: "Kiss Me")
        let giveMeLove = Song(title: "Give Me Love")
        let songs1 = [theATeam,drunk,UNI,grade8,smallBump,this,legoHouse,kissMe,giveMeLove]
        let plus = Album(name: "+", songs: songs1)
        
        let one = Song(title: "One")
        let mess = Song(title: "mess")
        let sing = Song(title: "Sing")
        let dont = Song(title: "Don't")
        let nina = Song(title: "Nina")
        let photograph = Song(title: "Photograph")
        let bloodstream = Song(title: "Bloodstream")
        let sea = Song(title:"Tenerife Sea")
        let runnaway = Song(title: "Runnaway")
        let theman = Song(title: "The Man")
        let songs2 = [one,mess,sing,dont,nina,photograph,bloodstream,sea,runnaway,theman]
        let multiply = Album(name: "X", songs: songs2)
        
        let albs = [plus,multiply]
        let ed = Artist(name: "Ed Sheeran", albums: albs)
        
        artists = [ed]
        
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

}
