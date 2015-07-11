import Foundation

class Chord: NSObject {
    
    var mTime: TimeNumber
    var tab: Tab!

    init(tab:Tab, time: TimeNumber){
        self.tab = tab
        self.mTime = time
    }
}

struct Tab {
    var name:String! //Cmajor
    var content:String! //032010
}