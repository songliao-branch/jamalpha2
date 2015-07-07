import Foundation

class Chord: NSObject {
    
    var mTime: NSTimeInterval
    var tab: Tab!
    
    init(tab:Tab, time: NSTimeInterval){
        self.tab = tab
        self.mTime = time
    }
}

struct Tab {
    var name:String! //Cmajor
    var content:String! //032010
}