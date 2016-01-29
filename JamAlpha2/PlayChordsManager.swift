//
//  PlaySoundManager.swift
//
//  Created by Jun Zhou on 1/5/16.
//  Copyright © 2016 myStride. All rights reserved.
//

import Foundation
import QuartzCore

class PlayChordsManager: NSObject {
    var soundBank: SoundBankPlayer!
    var timer: NSTimer!
    var playingArpeggio: Bool = false
    var arpeggioStartTime: CFTimeInterval = 0
    var arpeggioDelay: CFTimeInterval = 0
    var arpeggioNotes: NSMutableArray = NSMutableArray()
    var arpeggioIndex: Int = 0
    let standardFret0Midi = [76, 71, 67, 62, 57, 52]
    var fret0Midi = [76, 71, 67, 62, 57, 52]
    
    
    class var sharedInstance: PlayChordsManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayChordsManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = PlayChordsManager()
        }
        return Static.instance!
    }
    
    override init() {
        super.init()
        initialSoundBank()
    }
    
    func convertIndexToMidi(index: Int) -> Int32 {
        
        let stringIndex = index / 100
        let fretIndex = index - stringIndex * 100
        return Int32(fret0Midi[stringIndex - 1] + fretIndex)
    }
    
    func tuningString(stringIndex: Int, up: Bool) -> Bool {
        if up {
            let temp = fret0Midi[stringIndex - 1] + 1
            if temp <= standardFret0Midi[stringIndex - 1] + 4 && temp >= standardFret0Midi[stringIndex - 1] - 5 {
                fret0Midi[stringIndex - 1]++
                return true
            }
        } else {
            let temp = fret0Midi[stringIndex - 1] - 1
            if  temp <= standardFret0Midi[stringIndex - 1] + 4 && temp >= standardFret0Midi[stringIndex - 1] - 5 {
                fret0Midi[stringIndex - 1]--
                return true
            }
        }
        return false
    }
    
    func convertContentToIndexArray(content: String) -> [Int32] {
        var midiArray: [Int32] = [Int32]()
        for var i = 11; i >= 0; i = i - 2 {
            let startIndex = content.startIndex.advancedBy(11 - i)
            let endIndex = content.startIndex.advancedBy(11 - i + 2)
            let charAtIndex = content[Range(start: startIndex, end: endIndex)]
            var indexFret: Int = Int()
            if charAtIndex == "xx" {
                indexFret = 0
            } else {
                indexFret = Int(String(charAtIndex))!
                let indexString = i / 2 + 1
                let index = indexString * 100 + indexFret
                midiArray.append(convertIndexToMidi(index))
            }
        }
        return midiArray.reverse()
    }
    
    func initialSoundBank() {
        self.soundBank = SoundBankPlayer()
        self.soundBank.setSoundBank("GuitarSoundFont")
        self.playingArpeggio = false
    }
    
    func deinitialSoundBank() {
        stopTimer()
        soundBank.allNotesOff()
        arpeggioNotes.removeAllObjects()
    }
    
    func changeVolumn(newVolume:Float) {
        self.soundBank.volume = newVolume
    }
    
    func playSingleNoteSound(index: Int) {
        soundBank.allNotesOff()
        let midi = convertIndexToMidi(index)
        soundBank.queueNote(midi, gain: 0.4)
        soundBank.playQueuedNotes()
    }
    
    func playChordSimultenous(content: String) {
        soundBank.allNotesOff()
        let midiArray: [Int32] = convertContentToIndexArray(content)
        for item in midiArray {
            soundBank.queueNote(item, gain: 0.4)
        }
        soundBank.playQueuedNotes()
    }
    
    func playChordArpeggio(content: String, delay: CFTimeInterval, completion: ((complete: Bool) -> Void)) {
        soundBank.allNotesOff()
        self.stopTimer()
        self.startTimer()
        let midiArray: [Int32] = convertContentToIndexArray(content)
        
        playingArpeggio = true
        arpeggioNotes.removeAllObjects()
        for var i = midiArray.count - 1; i >= 0 ; i-- {
            arpeggioNotes.addObject(NSNumber(int:midiArray[i]))
        }
        arpeggioIndex = 0
        arpeggioDelay = delay
        arpeggioStartTime = CACurrentMediaTime()
    }
    var counter = 0
    func startTimer() {
        counter = 0
        if(self.timer == nil){
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "handleTimer:", userInfo: nil, repeats: true)
             NSRunLoop.mainRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func stopTimer() {
        counter = 0
        if(self.timer != nil){
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    func handleTimer(timer: NSTimer) {
        counter++
        if playingArpeggio {
            let now: CFTimeInterval = CACurrentMediaTime()
            if now - arpeggioStartTime >= arpeggioDelay {
                let number: NSNumber = arpeggioNotes[arpeggioIndex] as! NSNumber
                soundBank.noteOn(number.intValue, gain: 0.4)
                arpeggioIndex = arpeggioIndex + 1
                if arpeggioIndex == arpeggioNotes.count {
                    playingArpeggio = false
                } else {
                    arpeggioStartTime = now
                }
            }
        }
        if(counter == 100){
            stopTimer()
            arpeggioNotes.removeAllObjects()
            soundBank.allNotesOff()
        }
    }
    
    func changeCapo(sender: Int) {
        for i in 0..<fret0Midi.count {
            fret0Midi[i] = standardFret0Midi[i] + sender
        }
    }
}