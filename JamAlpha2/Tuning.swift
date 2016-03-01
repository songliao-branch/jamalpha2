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
    static let standardMidi = [7, 2, 10, 5, 0, 7]
  
    var maxTuningState: Int!
    var minTuningState: Int!
    var note: String!
    var tuningStateIncrements = 0 // 0 if equal to original note, negative means below original note,
    // positive means bigger than orignal note
    
    //MARK: to find tuning in half step down or half step up, used in TuningView
    
    //default is sharps
    static let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
    
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
        for i in 0..<Tuning.notes.count {
            if self.note == Tuning.notes[i] {
                if i == Tuning.notes.count - 1 {
                    self.note = Tuning.notes[0]
                } else {
                    self.note = Tuning.notes[i + 1]
                }
                break
            }
        }
    }
    
    //half step down
    func stepDown() {
        self.tuningStateIncrements--
        for i in 0..<Tuning.notes.count {
            if self.note == Tuning.notes[i] {
                if i == 0 {
                    self.note = Tuning.notes[Tuning.notes.count - 1]
                } else {
                    self.note = Tuning.notes[i - 1]
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
  
  class func toArrayWithoutArrow(sender: [String]) -> [String] {
    var midiValue = ["", "", "", "", "", ""]
    for i in 0..<6 {
      let char = sender[i].characters
      if char.count == 1 {
        midiValue[i] = sender[i]
      } else {
        let index = sender[i].startIndex.advancedBy(1)
        let endIndex = sender[i].endIndex.advancedBy(0)
        let tempChar = sender[i][Range(start: index, end: endIndex)]
        midiValue[i] = tempChar
      }
    }
    return midiValue
  }
  
    class func arrayToMidiDiff(max: [Int], min: [Int], sender: [String]) -> [Int] {
      var midiValue = [0, 0, 0, 0, 0, 0]
      for i in 0..<6 {
        let char = sender[i].characters
        if char.count == 1 {
          midiValue[i] = 0
          break
        } else {
          let index = sender[i].startIndex.advancedBy(1)
          let endIndex = sender[i].endIndex.advancedBy(0)
          let tempChar = sender[i][Range(start: index, end: endIndex)]
          if char.first == "\u{2191}" {
            for var j = Tuning.standardMidi[i]; j <= Tuning.standardMidi[i] + max[i]; j++ {
              let index = j % 12
              if tempChar == Tuning.notes[index] {
                midiValue[i] = j - Tuning.standardMidi[i]
                break
              }
            }
          } else if char.first == "\u{2193}" {
            for var j = Tuning.standardMidi[i]; j >= Tuning.standardMidi[i] + min[i]; j-- {
              var index = j % 12
              if index < 0 {
                index = index + 11
              }
              if tempChar == Tuning.notes[index] {
                midiValue[i] = j - Tuning.standardMidi[i]
                break
              }
            }
          }
        }
      }
      return midiValue
    }
}
 