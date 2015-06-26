

import Foundation

class Chord: NSObject {

    var mContent:String!//G
    
    var mTime: NSTimeInterval
    
    init(content:String, time: NSTimeInterval){
        self.mContent = content
        self.mTime = time
    }
    
}