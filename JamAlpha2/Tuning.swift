//
//  Tuning.swift
//  JamAlpha2
//
//  Created by Song Liao on 10/16/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation

class Tuning: NSObject {
    
    let upArrow = "\u{2191}"
    let downArrow = "\u{2193}"
    
    var note: String!
    var tuningStateIncrements = 0 // 0 if equal to original note, negative means below original note,
    // positive means bigger than orignal note
    
    //MARK: to find tuning in half step down or half step up, used in TuningView
    
    //default is sharps
    let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
    
    init(originalNote: String){
        self.note = originalNote
    }
    
    //return an direction together with the changed note
    func toDisplayString() -> String {
        let direction = getTuningDirection()
        return "\(direction)\(self.note)"
    }
    
    //half step up
    func stepUp() {
        self.tuningStateIncrements++
        for i in 0..<notes.count {
            if self.note == notes[i] {
                if i == notes.count-1 {
                    self.note = notes[0]
                } else {
                    self.note = notes[i+1]
                }
                break
            }
        }
    }
    
    //half step down
    func stepDown() {
        self.tuningStateIncrements--
        for i in 0..<notes.count {
            if self.note == notes[i] {
                if i == 0 {
                    self.note = notes[notes.count-1]
                } else {
                    self.note = notes[i-1]
                }
                break
            }
        }
    }
    
    func getTuningDirection() -> String {
        if self.tuningStateIncrements == 0 {
            return ""
        }
        if self.tuningStateIncrements > 0 {
            return upArrow
        } else {
            return downArrow
        }
    }
    
    //convert from format of 'E-A-B-D-A-E' to ['E', 'A', 'B', 'D', 'A', 'E']
    class func toArray(value: String) -> [String] {
        return value.characters.split{$0 == "-"}.map(String.init)
    }
}
 