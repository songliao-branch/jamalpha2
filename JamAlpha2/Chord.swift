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
}

//Tab represents full six numbers on a guitar board
//For example, C major is 032010
struct Tab {
    var name:String! //Cmajor
    var content:String! //032010
}
