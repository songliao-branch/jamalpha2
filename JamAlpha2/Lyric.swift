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
    
    
    class func getRainbowLyrics ()-> Lyric {
        var lyric = Lyric()
        
        lyric.addLine(12.56, str: "哪里有彩虹告诉我")
        lyric.addLine(18.80, str: "能不能把我的愿望还给我")
        lyric.addLine(25.82, str: "为什么天这么安静")
        lyric.addLine(31.98, str: "所有的云都跑到我这里")
        lyric.addLine(38.91, str: "有没有口罩一个给我")
        lyric.addLine(44.79, str: "释怀说了太多就成真不了")
        lyric.addLine(51.90, str: "也许时间是一种解药")
        lyric.addLine(57.82, str: "也是我现在正服下的毒药")
        lyric.addLine(63.91, str: "看不见妳的笑 我怎么睡得着")
        lyric.addLine(70.44, str: "妳的声音这么近我却抱不到")
        lyric.addLine(76.78, str: "没有地球 太阳还是会绕")
        lyric.addLine(83.18, str: "没有理由 我也能自己走")
        lyric.addLine(89.99, str: "妳要离开 我知道很简单")
        lyric.addLine(96.2, str: "妳说依赖 是我们的阻碍")
        lyric.addLine(102.74, str: "就算放开 但能不能别没收我的爱")
        lyric.addLine(110.27, str: "当作我最后才明白")
        return lyric
    }
}

struct  Line {
    var time: NSTimeInterval
    var str: String
}