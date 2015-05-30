


//TODO: whole model upon change when figuring out spotify api music model and ipod music library
import Foundation

class Artist: NSObject{
    let name:String
    var albums:[Album]
    
    init(name:String, albums: [Album]){
        self.name = name
        self.albums = albums
    }
}