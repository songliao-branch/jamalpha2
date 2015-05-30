
import Foundation

class Album{
    let name:String
    let songs:[Song]
    
    init(name:String, songs:[Song]){
        self.name = name
        self.songs = songs
    }
}