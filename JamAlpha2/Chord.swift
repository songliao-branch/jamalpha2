import Foundation

//Tab represents full six numbers on a guitar board
//For example, C major is 032010
struct Tab {
    var name:String! //Cmajor
    var content: String! //xx0302000100, 12 characters, as in x32010
    var contentArray: [String]! //to be used in SongViewController
    init(name: String, content: String) {
        self.name = name
        self.content = content
        self.contentArray = [String]()
        for var i = 11; i >= 0; i = i - 2 {
            let startIndex = content.startIndex.advancedBy(11 - i)
            let endIndex = content.startIndex.advancedBy(11 - i + 2)
            let charAtIndex = content[Range(startIndex..<endIndex)]
            if let number = Int(charAtIndex)  {
                 contentArray.append(String(number))
            } else if charAtIndex == "xx" {
                contentArray.append("x")
            } else {
                contentArray.append(" ")
            }
        }
    }
}

//Chord is timed..
class Chord: NSObject {
    
    var time: TimeNumber
    var tab: Tab!

    init(tab:Tab, time: TimeNumber){
        self.tab = tab
        self.time = time
    }
    
    class func getJasonMrazChords()-> [Chord]{
        var chords = [Chord]()
        let G = Tab(name:"G",content:"030200000300")
        let D = Tab(name:"D",content:"xxxx00020302")
        let Em =    Tab(name: "Em", content: "000202000000")
        let C = Tab(name:"C",content:"xx0302000100")
        
        chords.append(Chord(tab: G, time: TimeNumber(time: 1.00)))
        chords.append(Chord(tab: D, time: TimeNumber(time: 3.88)))
        chords.append(Chord(tab: Em, time: TimeNumber(time: 6.99)))
        chords.append(Chord(tab: C, time: TimeNumber(time: 10.11)))
        
        chords.append(Chord(tab: G, time: TimeNumber(time: 13.44)))
        chords.append(Chord(tab: D, time: TimeNumber(time: 16.55)))
        chords.append(Chord(tab: Em, time: TimeNumber(time: 19.88)))
        chords.append(Chord(tab: C, time: TimeNumber(time: 22.84)))
        
        chords.append(Chord(tab: G, time: TimeNumber(time: 26.11)))
        chords.append(Chord(tab: D, time: TimeNumber(time: 29.44)))
        chords.append(Chord(tab: Em, time: TimeNumber(time: 32.33)))
        chords.append(Chord(tab: C, time: TimeNumber(time: 35.55)))
        
        chords.append(Chord(tab: G, time: TimeNumber(time: 38.88)))
        chords.append(Chord(tab: D, time: TimeNumber(time: 41.92)))
        chords.append(Chord(tab: Em, time: TimeNumber(time: 45.22)))
        chords.append(Chord(tab: C, time: TimeNumber(time: 48.31)))
        return chords
    }
    
    class func getDaughters() -> [Chord] {
        var chords = [Chord]()
        let chord1 = Tab(name:"",content:"070007070000")
        let chord2 = Tab(name:"",content:"000705070000")
     let chord3 = Tab(name: "", content: "050005070000")
        let chord4 = Tab(name:"",content:"000504070000")
        
     let chord5 = Tab(name: "", content: "000706070000")
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 0.22)))
        chords.append(Chord(tab: chord2, time: TimeNumber(time: 3.10)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 6.39)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 8.60)))
        
        
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 11.80)))
        chords.append(Chord(tab: chord2, time: TimeNumber(time: 14.85)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 17.60)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 20.77)))
        
        
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 23.84)))
        chords.append(Chord(tab: chord2, time: TimeNumber(time: 26.4)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 29.33)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 32.40)))
        
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 35.10)))
        chords.append(Chord(tab: chord2, time: TimeNumber(time: 37.62)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 40.7)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 43.41)))

        chords.append(Chord(tab: chord1, time: TimeNumber(time: 46.41)))
        chords.append(Chord(tab: chord2, time: TimeNumber(time: 49.33)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 52.23)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 55.12)))
        
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 57.75)))
        chords.append(Chord(tab: chord2, time: TimeNumber(time: 60.81)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 63.9)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 66.61)))
        
        //chorus
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 69.50)))
        chords.append(Chord(tab: chord5, time: TimeNumber(time: 70.81)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 72.4)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 73.9)))
        
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 75.20)))
        chords.append(Chord(tab: chord5, time: TimeNumber(time: 76.80)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 78.1)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 79.6)))
        
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 80.8)))
        chords.append(Chord(tab: chord5, time: TimeNumber(time: 82.6)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 84.3)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 85.5)))

        
        chords.append(Chord(tab: chord1, time: TimeNumber(time: 87.2)))
        chords.append(Chord(tab: chord5, time: TimeNumber(time: 88.4)))
        chords.append(Chord(tab: chord3, time: TimeNumber(time: 89.6)))
        chords.append(Chord(tab: chord4, time: TimeNumber(time: 91.1)))
        
        return chords
        
    }
    
    // standard tuning no capo
    class func getRainbowChords() -> [Chord]{
        var chords = [Chord]()
        
        let C = Tab(name:"C",content:"--0302000100")
    let Dm7 = Tab(name:"Dm7",content:"----00020101")
    let Am7 = Tab(name:"Am7",content:"--0002000103")
        let G = Tab(name:"G",content:"03xx00000300")
     let E = Tab(name: "E", content: "000202010000")
    let Am = Tab(name: "Am", content:"--0002020100")
let AmG = Tab(name: "Am/G", content: "030002020100")
     let F = Tab(name: "F", content: "010303020101")

        //intro
        let chord1 = Chord(tab: C, time: TimeNumber(time: 0.33))
        let chord2 = Chord(tab: Dm7, time: TimeNumber(time:1.97))
        let chord3 = Chord(tab: Am7, time: TimeNumber(time:3.6))
        let chord4 = Chord(tab: Dm7, time: TimeNumber(time:5.24))
        let chord5 = Chord(tab: C, time: TimeNumber(time:7.02))
        let chord6 = Chord(tab: Dm7, time: TimeNumber(time:8.57))
        let chord7 = Chord(tab: G, time: TimeNumber(time:10.18))
        
        //verse1
        let chord8 = Chord(tab: C, time: TimeNumber(time:13.20)) //哪里有彩虹
        let chord9 = Chord(tab: Dm7, time: TimeNumber(time:15.05))
        let chord10 = Chord(tab: Am7, time: TimeNumber(time:16.64))
        let chord11 = Chord(tab: Dm7, time: TimeNumber(time:22.9))
        let chord12 = Chord(tab: C, time: TimeNumber(time:24.5))
        
        let chord13 = Chord(tab: E, time: TimeNumber(time:29.2))
        let chord14 = Chord(tab: Am, time: TimeNumber(time:33.5))
        let chord15 = Chord(tab: AmG, time: TimeNumber(time:34.2))
        let chord16 = Chord(tab: F, time: TimeNumber(time:40.1))
        let chord17 = Chord(tab: G, time: TimeNumber(time:45.1))

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
    
    // standard tuning, 3rd capo
    class func getRollingChords ()-> [Chord]{ //capo 3
        var stuff = [Chord]()
        let Am7 = Tab(name: "Am7",content:"xx0002000103")
     let Em =    Tab(name: "Em", content: "000202000000")
        let G =     Tab(name: "G",content:"030200000003")
        
        let chord1 = Chord(tab: Am7, time: TimeNumber(time: 1.11))
        let chord2 = Chord(tab: Em, time: TimeNumber(time:7.98))
        let chord3 = Chord(tab: G, time: TimeNumber(time:10.26))
        let chord4 = Chord(tab: Em, time: TimeNumber(time:12.25))
        let chord5 = Chord(tab: G, time: TimeNumber(time:13.11))
        
        let chord6 = Chord(tab: Am7, time: TimeNumber(time: 14.35))
        let chord7 = Chord(tab: Em, time: TimeNumber(time:17.48))
        let chord8 = Chord(tab: G, time: TimeNumber(time:19.16))
        let chord9 = Chord(tab: Em, time: TimeNumber(time:21.05))
        let chord10 = Chord(tab: G, time: TimeNumber(time:22.51))
        
        let chord11 = Chord(tab: Am7, time: TimeNumber(time: 23.15))
        let chord12 = Chord(tab: Em, time: TimeNumber(time:26.50))
        let chord13 = Chord(tab: G, time: TimeNumber(time:28.76))
        let chord14 = Chord(tab: Em, time: TimeNumber(time:30.87))
        let chord15 = Chord(tab: G, time: TimeNumber(time:31.88))
        
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
        return stuff
    }
    
    // all strings half note down tuning
    class func getExtremeChords() -> [Chord] {
        var stuff = [Chord]()
        
               let G = Tab(name: "G",content:"030200000303")
       let GB =    Tab(name: "G/B", content: "--0200000303")
     let Csus9 = Tab(name: "Csus9", content: "--0302000303")
         let Am7 =   Tab(name: "Am7",content:"--0002000103")
           let C =     Tab(name: "C",content:"--0302000100")
         let D =     Tab(name: "D", content: "----00020302")
     let Dsus4 = Tab(name: "Dsus4", content: "----00020303")
        
        let Am =    Tab(name: "Am", content: "--0002020100")
        let Em =    Tab(name: "Em", content: "000202000000")
        let D7 =    Tab(name: "D7", content: "----00020102")
    let DFSharp = Tab(name: "D/F#", content: "02--00020302")
          let G7  = Tab(name: "G7", content: "030200000001")
           let Cm = Tab(name: "Cm", content: "--0305050403")
 
           let Bm = Tab(name: "Bm", content: "--0204040302")
        
        //intro
        let chord1 = Chord(tab: G, time: TimeNumber(time: 0.21))
        let chord2 = Chord(tab: GB, time: TimeNumber(time:1.34))
        let chord3 = Chord(tab: Csus9, time: TimeNumber(time:2.81))
        let chord4 = Chord(tab: Am7, time: TimeNumber(time:5.27))
        let chord5 = Chord(tab: C, time: TimeNumber(time:7.9))
        let chord6 = Chord(tab: D, time: TimeNumber(time:9.16))
        let chord7 = Chord(tab: Dsus4, time: TimeNumber(time:9.82))
        
        let chord8 = Chord(tab: G, time: TimeNumber(time: 10.76))
        let chord9 = Chord(tab: GB, time: TimeNumber(time: 11.87))
        let chord10 = Chord(tab: Csus9, time: TimeNumber(time: 13.28))
        let chord11 = Chord(tab: Am7, time: TimeNumber(time: 15.83))
        let chord12 = Chord(tab: C, time: TimeNumber(time: 18.28))
        let chord13 = Chord(tab: D, time: TimeNumber(time: 19.69))
        let chord14 = Chord(tab: Dsus4, time: TimeNumber(time: 20.12))
        
        //verse 1: saying i'm love you
        let chord15 = Chord(tab: G, time: TimeNumber(time: 21.16))
        let chord16 = Chord(tab: GB, time: TimeNumber(time: 22.19))
        let chord17 = Chord(tab: Csus9, time: TimeNumber(time: 23.65))
        let chord18 = Chord(tab: Am7, time: TimeNumber(time: 26.23))
        let chord19 = Chord(tab: C, time: TimeNumber(time:28.88))
        let chord20 = Chord(tab: D, time: TimeNumber(time: 30.21))
        let chord21 = Chord(tab: Dsus4, time: TimeNumber(time: 30.89))
        
//        //it's not that I want you not to say
        let chord22 = Chord(tab: G, time: TimeNumber(time: 31.23))
        let chord23 = Chord(tab: GB, time: TimeNumber(time: 32.52))
        let chord24 = Chord(tab: Csus9, time: TimeNumber(time: 33.98))
        let chord25 = Chord(tab: Am7, time: TimeNumber(time: 36.54))
        let chord26 = Chord(tab: C, time: TimeNumber(time: 39.12))
        let chord27 = Chord(tab: D, time: TimeNumber(time: 40.45))
        let chord28 = Chord(tab: Dsus4, time: TimeNumber(time: 41.13))
//
        //how easy
        let chord29 = Chord(tab: Em, time: TimeNumber(time: 41.51))
        let chord30 = Chord(tab: Am7, time: TimeNumber(time: 44.17))
        
        let chord31 = Chord(tab: D7, time: TimeNumber(time: 46.85))
        let chord32 = Chord(tab: G, time: TimeNumber(time: 49.40))
        let chord33 = Chord(tab: DFSharp, time: TimeNumber(time: 50.80))
        let chord34 = Chord(tab: Em, time: TimeNumber(time: 52.01))
        let chord35 = Chord(tab: Am, time: TimeNumber(time: 54.98))

        //is more than words is all you have to say
        let chord36 = Chord(tab: D, time: TimeNumber(time: 57.80))
        let chord37 = Chord(tab: G7, time: TimeNumber(time: 60.10))
        let chord38 = Chord(tab: C, time: TimeNumber(time: 62.50))
        let chord39 = Chord(tab: Cm, time: TimeNumber(time: 64.80))
        let chord40 = Chord(tab: GB, time: TimeNumber(time: 67.30))
        let chord41 = Chord(tab: DFSharp, time: TimeNumber(time: 68.90))
        let chord42 = Chord(tab: Em, time: TimeNumber(time: 71.50))
        
        //cause I already know
        let chord43 = Chord(tab: Am, time: TimeNumber(time: 72.89))
        let chord44 = Chord(tab: D7, time: TimeNumber(time: 75.80))
        let chord45 = Chord(tab: G, time: TimeNumber(time: 78.50))

        //chorus
        //what would you say if my heart was torn in two
        let chord46 = Chord(tab: GB, time: TimeNumber(time: 79.40))
        let chord47 = Chord(tab: G, time: TimeNumber(time: 80.50))
        let chord48 = Chord(tab: GB, time: TimeNumber(time: 81.40))
        let chord49 = Chord(tab: DFSharp, time: TimeNumber(time: 83.34))
        let chord50 = Chord(tab: Em, time: TimeNumber(time: 85.90))
        let chord51 = Chord(tab: Bm, time: TimeNumber(time: 87.20))
        let chord52 = Chord(tab: C, time: TimeNumber(time: 88.80))
        let chord53 = Chord(tab: G, time: TimeNumber(time: 92.9))
        
        
        let chord54 = Chord(tab: Am7, time: TimeNumber(time: 93.80))
        //that your love for me is real
        let chord55 = Chord(tab: D, time: TimeNumber(time: 96.20))
        
        let chord56 = Chord(tab: G, time: TimeNumber(time: 99.10))
        let chord57 = Chord(tab: GB, time: TimeNumber(time: 100.4))
        //what would you say
        let chord58 = Chord(tab: G, time: TimeNumber(time: 101.30))
        let chord59 = Chord(tab: GB, time: TimeNumber(time: 102.70))
        
        let chord60 = Chord(tab: DFSharp, time: TimeNumber(time: 104.50))
        let chord61 = Chord(tab: Em, time: TimeNumber(time: 106.50))
        let chord62 = Chord(tab: Bm, time: TimeNumber(time: 108.20))
        let chord63 = Chord(tab: C, time: TimeNumber(time: 109.20))
        let chord64 = Chord(tab: G, time: TimeNumber(time: 112.9))
        let chord65 = Chord(tab: Am7, time: TimeNumber(time: 114.80))
        let chord66 = Chord(tab: D7, time: TimeNumber(time: 117.20))
        let chord67 = Chord(tab: G, time: TimeNumber(time: 120.20))
    
        //la ri la ri la
        let chord68 = Chord(tab: GB, time: TimeNumber(time: 121.50))
        let chord69 = Chord(tab: Csus9, time: TimeNumber(time: 122.50))
        let chord70 = Chord(tab: Am7, time: TimeNumber(time: 125.30))
        let chord71 = Chord(tab: C, time: TimeNumber(time: 127.78))
        let chord72 = Chord(tab: D, time: TimeNumber(time: 129.20))
        let chord73 = Chord(tab: Dsus4, time: TimeNumber(time: 129.65))
        
        let chord74 = Chord(tab: G, time: TimeNumber(time: 130.5))
        let chord75 = Chord(tab: GB, time: TimeNumber(time: 131.7))
        let chord76 = Chord(tab: Csus9, time: TimeNumber(time: 133.1))
        let chord77 = Chord(tab: Am7, time: TimeNumber(time: 135.80))
        let chord78 = Chord(tab: D7, time: TimeNumber(time: 138.7))
        
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


