

// Singelton Access API for music

import Foundation

class MusicAPI: NSObject{

    private let persistancyManager: PersistencyManager
 
    class var sharedIntance: MusicAPI {
        struct Singelton {
            static let instance = MusicAPI()
        }
        return Singelton.instance
    }
    
    override init(){
        persistancyManager = PersistencyManager()        
        super.init()
    }
    
    //delete this
    func getArtist() -> [Artist]
    {
        return persistancyManager.getArtists()
    }
    
    func getSongs()->[MPMediaItem]{
        return persistancyManager.getSongItems()
    }
    
    func getAlbums()->[MPMediaItem]{
        return persistancyManager.getAlbumItems()
    }
    
    func getArtists()->[MPMediaItem]{
        return persistancyManager.getArtistItem()
    }
    
    
}