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
    
    func addLine(time: TimeNumber, str: String){
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
        
        lyric.addLine(TimeNumber(time:12.56), str: "哪里有彩虹告诉我")
        lyric.addLine(TimeNumber(time:18.80), str: "能不能把我的愿望还给我")
        lyric.addLine(TimeNumber(time:25.82), str: "为什么天这么安静")
        lyric.addLine(TimeNumber(time:31.98), str: "所有的云都跑到我这里")
        lyric.addLine(TimeNumber(time:38.91), str: "有没有口罩一个给我")
        lyric.addLine(TimeNumber(time:44.79), str: "释怀说了太多就成真不了")
        lyric.addLine(TimeNumber(time:51.90), str: "也许时间是一种解药")
        lyric.addLine(TimeNumber(time:57.82), str: "也是我现在正服下的毒药")
        lyric.addLine(TimeNumber(time:63.91), str: "看不见妳的笑 我怎么睡得着")
        lyric.addLine(TimeNumber(time:70.44), str: "妳的声音这么近我却抱不到")
        lyric.addLine(TimeNumber(time:76.78), str: "没有地球 太阳还是会绕")
        lyric.addLine(TimeNumber(time:83.18), str: "没有理由 我也能自己走")
        lyric.addLine(TimeNumber(time:89.99), str: "妳要离开 我知道很简单")
        lyric.addLine(TimeNumber(time:96.2), str: "妳说依赖 是我们的阻碍")
        lyric.addLine(TimeNumber(time:102.74), str: "就算放开 但能不能别没收我的爱")
        lyric.addLine(TimeNumber(time:110.27), str: "当作我最后才明白")
        return lyric
    }
    
    class func getRollingLyrics()-> Lyric {
        var lyric = Lyric()
        lyric.addLine(TimeNumber(time:5.35), str: "There's a fire starting in my heart")
        lyric.addLine(TimeNumber(time: 9.85), str: "Reaching a fever pitch, it's bringing me out the dark")
        lyric.addLine(TimeNumber(time:14.66), str: "Finally I can see you crystal clear")
        lyric.addLine(TimeNumber(time: 18.85), str: "Go 'head and sell me out and I'll lay your ship bare")
        lyric.addLine(TimeNumber(time:23.13), str: "See how I leave with every piece of you")
        lyric.addLine(TimeNumber(time:27.88), str: "Don't underestimate the things that I will do")
        lyric.addLine(TimeNumber(time:32.22), str: "There's a fire starting in my heart")
        lyric.addLine(TimeNumber(time:37.21), str: "Reaching a fever pitch And it's brining me out the dark")
        lyric.addLine(TimeNumber(time:42.88), str: "The scars of your love remind me of us")
        lyric.addLine(TimeNumber(time:47.31), str: "They keep me thinking that we almost had it all")
        lyric.addLine(TimeNumber(time:51.84), str: "The scars of your love, they leave breathless")
        lyric.addLine(TimeNumber(time:56.88), str: "I can't help feeling")
        lyric.addLine(TimeNumber(time:58.44), str: "We could have had it all")
        
        return lyric
    }
    
    
    class func getExtremeLyrics()-> Lyric {
        var lyric = Lyric()
        
        lyric.addLine(TimeNumber(time: 22.11), str: "Saying I love you")
        lyric.addLine(TimeNumber(time: 25.96 ), str: "Is not the words I want to hear from you")
        lyric.addLine(TimeNumber(time: 32.82), str: "It's not that I want you not to say")
        lyric.addLine(TimeNumber(time: 36.82), str: "But if you only knew")
        
        lyric.addLine(TimeNumber(time: 42.9), str: "How easy it would be to show me how you feel")
        lyric.addLine(TimeNumber(time: 53.73), str: "More than words is all you have to do to make it real")
        lyric.addLine(TimeNumber(time: 63.88), str: "Then you wouldn't have to say that you love me")
        lyric.addLine(TimeNumber(time: 72.41), str: "Cos I'd already know")
        
        lyric.addLine(TimeNumber(time: 79.69), str: "What would you do if my heart was torn in two")
        lyric.addLine(TimeNumber(time: 90.09), str: "More than words to show you feel")
        lyric.addLine(TimeNumber(time: 94.69), str: "That your love for me is real")
        
        lyric.addLine(TimeNumber(time: 100.52), str: "What would you say if I took those words away")
        lyric.addLine(TimeNumber(time: 110.8), str: "Then you couldn't make things new")
        lyric.addLine(TimeNumber(time: 115.9), str: "Just by saying I love you")
        
        lyric.addLine(TimeNumber(time: 142.3), str: "Now I've tried to talk to you and make you understand")
        lyric.addLine(TimeNumber(time: 153.18), str: "All you have to do is close your eyes")
        lyric.addLine(TimeNumber(time: 159.19), str: "And just reach out your hands and touch me")
        lyric.addLine(TimeNumber(time: 167.3), str: "Hold me close don't ever let me go")
        
        lyric.addLine(TimeNumber(time: 174.63), str: "More than words is all I ever needed you to show")
        lyric.addLine(TimeNumber(time: 184.34), str: "Then you wouldn't have to say that you love me")
        lyric.addLine(TimeNumber(time: 193.62), str: "Cos I'd already know")
        
        lyric.addLine(TimeNumber(time: 201.15), str: "What would you do if my heart was torn in two")
        lyric.addLine(TimeNumber(time: 211.26), str: "More than words to show you feel")
        lyric.addLine(TimeNumber(time: 216.64), str: "That your love for me is real")
        
        lyric.addLine(TimeNumber(time: 224.8), str: "What would you say if I took those words away")
        lyric.addLine(TimeNumber(time: 232.4), str: "Then you couldn't make things new")
        lyric.addLine(TimeNumber(time: 237.88), str: "Just by saying I love you")
        return lyric
    }
}

struct  Line {
    var time: TimeNumber
    var str: String
}