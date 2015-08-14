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
        var G7  = Tab(name: "G7", content: "320001")
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
        
        var chord8 = Chord(tab: G, time: TimeNumber(time: 10.76))
        var chord9 = Chord(tab: GB, time: TimeNumber(time: 11.87))
        var chord10 = Chord(tab: Csus9, time: TimeNumber(time: 13.28))
        var chord11 = Chord(tab: Am7, time: TimeNumber(time: 15.83))
        var chord12 = Chord(tab: C, time: TimeNumber(time: 18.28))
        var chord13 = Chord(tab: D, time: TimeNumber(time: 19.69))
        var chord14 = Chord(tab: Dsus4, time: TimeNumber(time: 20.12))
        
        //verse 1: saying i'm love you
        var chord15 = Chord(tab: G, time: TimeNumber(time: 21.16))
        var chord16 = Chord(tab: GB, time: TimeNumber(time: 22.19))
        var chord17 = Chord(tab: Csus9, time: TimeNumber(time: 23.65))
        var chord18 = Chord(tab: Am7, time: TimeNumber(time: 26.23))
        var chord19 = Chord(tab: C, time: TimeNumber(time:28.88))
        var chord20 = Chord(tab: D, time: TimeNumber(time: 30.21))
        var chord21 = Chord(tab: Dsus4, time: TimeNumber(time: 30.89))
        
//        //it's not that I want you not to say
        var chord22 = Chord(tab: G, time: TimeNumber(time: 31.23))
        var chord23 = Chord(tab: GB, time: TimeNumber(time: 32.52))
        var chord24 = Chord(tab: Csus9, time: TimeNumber(time: 33.98))
        var chord25 = Chord(tab: Am7, time: TimeNumber(time: 36.54))
        var chord26 = Chord(tab: C, time: TimeNumber(time: 39.12))
        var chord27 = Chord(tab: D, time: TimeNumber(time: 40.45))
        var chord28 = Chord(tab: Dsus4, time: TimeNumber(time: 41.13))
//
        //how easy
        var chord29 = Chord(tab: Em, time: TimeNumber(time: 41.51))
        var chord30 = Chord(tab: Am7, time: TimeNumber(time: 44.17))
        
        var chord31 = Chord(tab: D7, time: TimeNumber(time: 46.85))
        var chord32 = Chord(tab: G, time: TimeNumber(time: 49.40))
        var chord33 = Chord(tab: DFSharp, time: TimeNumber(time: 50.80))
        var chord34 = Chord(tab: Em, time: TimeNumber(time: 52.01))
        var chord35 = Chord(tab: Am, time: TimeNumber(time: 54.98))

        //is more than words is all you have to say
        var chord36 = Chord(tab: D, time: TimeNumber(time: 57.80))
        var chord37 = Chord(tab: G7, time: TimeNumber(time: 60.10))
        var chord38 = Chord(tab: C, time: TimeNumber(time: 62.50))
        var chord39 = Chord(tab: Cm, time: TimeNumber(time: 64.80))
        var chord40 = Chord(tab: GB, time: TimeNumber(time: 67.30))
        var chord41 = Chord(tab: DFSharp, time: TimeNumber(time: 68.90))
        var chord42 = Chord(tab: Em, time: TimeNumber(time: 71.50))
        
        //cause I already know
        var chord43 = Chord(tab: Am, time: TimeNumber(time: 72.89))
        var chord44 = Chord(tab: D7, time: TimeNumber(time: 75.80))
        var chord45 = Chord(tab: G, time: TimeNumber(time: 78.50))

        //chorus
        //what would you say if my heart was torn in two
        var chord46 = Chord(tab: GB, time: TimeNumber(time: 79.40))
        var chord47 = Chord(tab: G, time: TimeNumber(time: 80.50))
        var chord48 = Chord(tab: GB, time: TimeNumber(time: 81.40))
        var chord49 = Chord(tab: DFSharp, time: TimeNumber(time: 83.34))
        var chord50 = Chord(tab: Em, time: TimeNumber(time: 85.90))
        var chord51 = Chord(tab: Bm, time: TimeNumber(time: 87.20))
        var chord52 = Chord(tab: C, time: TimeNumber(time: 88.80))
        var chord53 = Chord(tab: G, time: TimeNumber(time: 92.9))
        
        
        var chord54 = Chord(tab: Am7, time: TimeNumber(time: 93.80))
        //that your love for me is real
        var chord55 = Chord(tab: D, time: TimeNumber(time: 96.20))
        
        var chord56 = Chord(tab: G, time: TimeNumber(time: 99.10))
        var chord57 = Chord(tab: GB, time: TimeNumber(time: 100.4))
        //what would you say
        var chord58 = Chord(tab: G, time: TimeNumber(time: 101.30))
        var chord59 = Chord(tab: GB, time: TimeNumber(time: 102.70))
        
        var chord60 = Chord(tab: DFSharp, time: TimeNumber(time: 104.50))
        var chord61 = Chord(tab: Em, time: TimeNumber(time: 106.50))
        var chord62 = Chord(tab: Bm, time: TimeNumber(time: 108.20))
        var chord63 = Chord(tab: C, time: TimeNumber(time: 109.20))
        var chord64 = Chord(tab: G, time: TimeNumber(time: 112.9))
        var chord65 = Chord(tab: Am7, time: TimeNumber(time: 114.80))
        var chord66 = Chord(tab: D7, time: TimeNumber(time: 117.20))
        var chord67 = Chord(tab: G, time: TimeNumber(time: 120.20))
    
        //la ri la ri la
        var chord68 = Chord(tab: GB, time: TimeNumber(time: 121.50))
        var chord69 = Chord(tab: Csus9, time: TimeNumber(time: 122.50))
        var chord70 = Chord(tab: Am7, time: TimeNumber(time: 125.30))
        var chord71 = Chord(tab: C, time: TimeNumber(time: 127.78))
        var chord72 = Chord(tab: D, time: TimeNumber(time: 129.20))
        var chord73 = Chord(tab: Dsus4, time: TimeNumber(time: 129.65))
        
        var chord74 = Chord(tab: G, time: TimeNumber(time: 130.5))
        var chord75 = Chord(tab: GB, time: TimeNumber(time: 131.7))
        var chord76 = Chord(tab: Csus9, time: TimeNumber(time: 133.1))
        var chord77 = Chord(tab: Am7, time: TimeNumber(time: 135.80))
        var chord78 = Chord(tab: D7, time: TimeNumber(time: 138.7))
        
        //end of chorus1
        stuff.append(chord1)
        stuff.append(chord2)
        stuff.append(chord3)
        stuff.append(chord4)
        stuff.append(chord5)
        stuff.append(chord6)
        stuff.append(chord7)
        stuff.append(chord8)
        stuff.append(chord9)
        stuff.append(chord10)
        stuff.append(chord11)
        stuff.append(chord12)
        stuff.append(chord13)
        stuff.append(chord14)
        stuff.append(chord15)
        stuff.append(chord16)
        stuff.append(chord17)
        stuff.append(chord18)
        stuff.append(chord19)
        stuff.append(chord20)
        stuff.append(chord21)
        stuff.append(chord22)
        stuff.append(chord23)
        stuff.append(chord24)
        stuff.append(chord25)
        stuff.append(chord26)
        stuff.append(chord27)
        stuff.append(chord28)
        stuff.append(chord29)
        stuff.append(chord30)
        stuff.append(chord31)
        stuff.append(chord32)
        stuff.append(chord33)
        stuff.append(chord34)
        stuff.append(chord35)
        stuff.append(chord36)
        stuff.append(chord37)
        stuff.append(chord38)
        stuff.append(chord39)
        stuff.append(chord40)
        stuff.append(chord41)
        stuff.append(chord42)
        stuff.append(chord43)
        stuff.append(chord44)
        stuff.append(chord45)
        stuff.append(chord46)
        stuff.append(chord47)
        stuff.append(chord48)
        stuff.append(chord49)
        stuff.append(chord50)
        stuff.append(chord51)
        stuff.append(chord52)
        stuff.append(chord53)
        stuff.append(chord54)
        stuff.append(chord55)
        stuff.append(chord56)
        stuff.append(chord57)
        stuff.append(chord58)
        stuff.append(chord59)
        stuff.append(chord60)
        stuff.append(chord61)
        stuff.append(chord62)
        stuff.append(chord63)
        stuff.append(chord64)
        stuff.append(chord65)
        stuff.append(chord66)
        stuff.append(chord67)
        stuff.append(chord68)
        stuff.append(chord69)
        stuff.append(chord70)
        stuff.append(chord71)
        stuff.append(chord72)
        stuff.append(chord73)
        stuff.append(chord74)
        stuff.append(chord75)
        stuff.append(chord76)
        stuff.append(chord77)
        stuff.append(chord78)
        return stuff
    }
}

//Tab represents full six numbers on a guitar board
//For example, C major is 032010
struct Tab {
    var name:String! //Cmajor
    var content:String! //032010
}
