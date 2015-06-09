
// THIS CLASS IS USED FOR TESTING and Practicing, not used anymore

import Foundation
import MediaPlayer

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
    
    func getRightAlbum()->[Album]{
        return persistancyManager.getAlbums()
    }
    
    
}