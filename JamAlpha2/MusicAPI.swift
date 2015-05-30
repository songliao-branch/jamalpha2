

// Singelton Access for temporary music source

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
    
    func getArtist() -> [Artist]
    {
        return persistancyManager.getArtists()
    }
    
    
}