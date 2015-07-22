import Foundation

//Chord is timed..
class Chord: NSObject {
    
    var mTime: TimeNumber
    var tab: Tab!

    init(tab:Tab, time: TimeNumber){
        self.tab = tab
        self.mTime = time
    }
    
    //example
    class func getRainbowChords() -> [Chord]{
        var chords = [Chord]()
        
        var C = Tab(name:"C",content:" 32010")
        var Dm7 = Tab(name:"Dm7",content:"  0211")
        var Am7 = Tab(name:"Am7",content:" 02013")
        var G = Tab(name:"G",content:"3 0030")
        var E = Tab(name: "E", content: "022100")
        var Am = Tab(name: "Am", content:" 02210")
        var AmG = Tab(name: "Am/G", content: "302210")
        var F = Tab(name: "F", content: "133211")
        var Gsus4 = Tab(name: "Gsus4", content:"320013")
        
        
        //intro
        var chord1 = Chord(tab: C, time: TimeNumber(time: 0.33))
        var chord2 = Chord(tab: Dm7, time: TimeNumber(time:1.97))
        var chord3 = Chord(tab: Am7, time: TimeNumber(time:3.6))
        var chord4 = Chord(tab: Dm7, time: TimeNumber(time:5.24))
        var chord5 = Chord(tab: C, time: TimeNumber(time:7.02))
        var chord6 = Chord(tab: Dm7, time: TimeNumber(time:8.57))
        var chord7 = Chord(tab: G, time: TimeNumber(time:10.18))
        
        //verse1
        var chord8 = Chord(tab: C, time: TimeNumber(time:13.20)) //哪里有彩虹
        var chord9 = Chord(tab: Dm7, time: TimeNumber(time:15.05))
        var chord10 = Chord(tab: Am7, time: TimeNumber(time:16.64))
        var chord11 = Chord(tab: Dm7, time: TimeNumber(time:22.9))
        var chord12 = Chord(tab: C, time: TimeNumber(time:24.5))
        
        var chord13 = Chord(tab: E, time: TimeNumber(time:29.2))
        var chord14 = Chord(tab: Am, time: TimeNumber(time:33.5))
        var chord15 = Chord(tab: AmG, time: TimeNumber(time:34.2))
        var chord16 = Chord(tab: F, time: TimeNumber(time:40.1))
        var chord17 = Chord(tab: G, time: TimeNumber(time:45.1))
        var chord18 = Chord(tab: Dm7, time: TimeNumber(time:48.1))
        var chord19 = Chord(tab: Gsus4, time: TimeNumber(time:55.0))
        
        chords.append(chord1)
        chords.append(chord2)
        chords.append(chord3)
        chords.append(chord4)
    
        chords.append(chord5)
        chords.append(chord6)
        chords.append(chord7)
        chords.append(chord8)
        
        
        chords.append(chord9)
        chords.append(chord10)
        chords.append(chord11)
        chords.append(chord12)
        
        chords.append(chord13)
        chords.append(chord14)
        chords.append(chord15)
        chords.append(chord16)
        chords.append(chord17)
        
        return chords
    }
    
    class func getExtremeChords() -> [Chord] {
        var stuff = [Chord]()
        
        var G =     Tab(name: "G",content:"320033")
        var GB =    Tab(name: "G/B", content: "-20033")
        var Csus9 = Tab(name: "Csus9", content: "-32033")
        var Am7 =   Tab(name: "Am7",content:"-02013")
        var C =     Tab(name: "C",content:"-32010")
        var D =     Tab(name: "D", content: "--0232")
        var Dsus4 = Tab(name: "Dsus4", content: "--0233")
        
        var Am =    Tab(name: "Am", content: "-02210")
        var Em =    Tab(name: "Em", content: "022000")
        var D7 =    Tab(name: "D7", content: "--0212")
        var DFSharp = Tab(name: "D/F#", content: "2-0232")
        var G7  = Tab(name: "G7", content: "353433")
        var Cm = Tab(name: "Cm", content: "-35543")
        var Em9 = Tab(name: "Em9", content: "022030")
        
        
        var Bm = Tab(name: "Bm", content: "-24432")
        
        //intro
        var chord1 = Chord(tab: G, time: TimeNumber(time: 0.21))
        var chord2 = Chord(tab: GB, time: TimeNumber(time:1.34))
        var chord3 = Chord(tab: Csus9, time: TimeNumber(time:2.81))
        var chord4 = Chord(tab: Am7, time: TimeNumber(time:5.27))
        var chord5 = Chord(tab: C, time: TimeNumber(time:7.9))
        var chord6 = Chord(tab: D, time: TimeNumber(time:9.16))
        var chord7 = Chord(tab: Dsus4, time: TimeNumber(time:9.82))
        
        //verse 1  saying 'I love you'
//        var chord8 = Chord(tab: G, time: TimeNumber(time: 0.33))
//        var chord9 = Chord(tab: GB, time: TimeNumber(time:1.97))
//        var chord10 = Chord(tab: Csus9, time: TimeNumber(time:3.6))
//        var chord11 = Chord(tab: Am7, time: TimeNumber(time:5.24))
//        var chord12 = Chord(tab: C, time: TimeNumber(time:7.02))
//        var chord13 = Chord(tab: D, time: TimeNumber(time:8.57))
//        var chord14 = Chord(tab: Dsus4, time: TimeNumber(time:10.18))
//        
//        //it's not that I want you not to say
//        var chord15 = Chord(tab: G, time: TimeNumber(time: 0.33))
//        var chord16 = Chord(tab: GB, time: TimeNumber(time:1.97))
//        var chord17 = Chord(tab: Csus9, time: TimeNumber(time:3.6))
//        var chord18 = Chord(tab: Am7, time: TimeNumber(time:5.24))
//        var chord19 = Chord(tab: C, time: TimeNumber(time:7.02))
//        var chord20 = Chord(tab: D, time: TimeNumber(time:8.57))
//        var chord21 = Chord(tab: Dsus4, time: TimeNumber(time:10.18))
//        
//        //if you only knew, how easy
//        var chord22 = Chord(tab: Em, time: TimeNumber(time: 0.33))
//        var chord23 = Chord(tab: Am7, time: TimeNumber(time:1.97))
//        var chord24 = Chord(tab: D7, time: TimeNumber(time:3.6))
//        var chord25 = Chord(tab: G, time: TimeNumber(time:5.24))
//        var chord26 = Chord(tab: DFSharp, time: TimeNumber(time:7.02))
//        var chord27 = Chord(tab: Em, time: TimeNumber(time:8.57))
//        var chord28 = Chord(tab: Am, time: TimeNumber(time:10.18))
//
//        //more than words, is all you have to do
//        var chord29 = Chord(tab: Em, time: TimeNumber(time: 0.33))
//        var chord30 = Chord(tab: Am7, time: TimeNumber(time:1.97))
//        var chord31 = Chord(tab: D, time: TimeNumber(time:3.6))//is all you
//        var chord32 = Chord(tab: G7, time: TimeNumber(time:5.24))//have to say
//        var chord33 = Chord(tab: C, time: TimeNumber(time:7.02))
//        var chord34 = Chord(tab: Cm, time: TimeNumber(time:8.57))
//        var chord35 = Chord(tab: G, time: TimeNumber(time:10.18))
//        
//        var chord36 = Chord(tab: Em, time: TimeNumber(time:10.18))
//        
//        
//        var chord37 = Chord(tab: Am7, time: TimeNumber(time:10.18))//cause i'd
//        var chord38 = Chord(tab: D, time: TimeNumber(time:10.18))//already
//        var chord39 = Chord(tab: G, time: TimeNumber(time:10.18))//know...
        
        stuff.append(chord1)
        stuff.append(chord2)
        stuff.append(chord3)
        stuff.append(chord4)
        stuff.append(chord5)
        stuff.append(chord6)
        stuff.append(chord7)
//        stuff.append(chord8)
//        stuff.append(chord9)
//        stuff.append(chord10)
//        stuff.append(chord11)
//        stuff.append(chord12)
//        stuff.append(chord13)
//        stuff.append(chord14)
//        stuff.append(chord15)
//        stuff.append(chord16)
//        stuff.append(chord17)
//        stuff.append(chord18)
//        stuff.append(chord19)
//        stuff.append(chord20)
//        stuff.append(chord21)
//        stuff.append(chord22)
//        stuff.append(chord23)
//        stuff.append(chord24)
//        stuff.append(chord25)
//        stuff.append(chord26)
//        stuff.append(chord27)
//        stuff.append(chord28)
//        stuff.append(chord29)
//        stuff.append(chord30)
//        stuff.append(chord31)
//        stuff.append(chord32)
//        stuff.append(chord33)
//        stuff.append(chord34)
//        stuff.append(chord35)
//        stuff.append(chord36)
//        stuff.append(chord37)
//        stuff.append(chord38)
//        stuff.append(chord39)
        return stuff
    }
}

//Tab represents full six numbers on a guitar board
//For example, C major is 032010
struct Tab {
    var name:String! //Cmajor
    var content:String! //032010
}
