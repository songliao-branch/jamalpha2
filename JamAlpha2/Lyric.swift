//
//  Lyric.swift
//  JamAlpha2
//
//  Created by Xing Liu on 7/6/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation

class Lyric: NSObject{
    var lyric: [Line]
    
    override init(){
        lyric = [Line]()
    }
    
    func addLine(time: NSTimeInterval, str: String){
        lyric.append(Line(time: time, str: str))
    }
    
    func get(i: Int) -> Line{
        return lyric[i]
    }
    
    func getLyric(filePath: String) -> [Line] {
        return lyric
    }
}

struct  Line {
    var time: NSTimeInterval
    var str: String
}