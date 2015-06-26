

import Foundation

class Chord: NSObject {

    var mContent:String!
    //NSTimerInterval
    var mTime : Int!
    
    init(content:String, time : Int){
        self.mContent = content
        self.mTime = time
    }
    
    
}