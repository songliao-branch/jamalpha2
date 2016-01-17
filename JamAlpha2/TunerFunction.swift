//
//  TunerFunction.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/11/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation

class TunerFunction: NSObject {
    // line: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
    // column:1 to 7
    let NOTE_HZ: [[Float]] = [
        [32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49.00, 51.91, 55.00, 58.27, 61.74],
        [65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98.00, 103.8, 110.0, 116.5, 123.5],
        [130.8, 138.6, 146.8, 155.6, 164.8, 174.6, 185.0, 196.0, 207.7, 220.0, 233.1, 246.9],
        [261.6, 277.2, 293.7, 311.1, 329.6, 349.2, 370.0, 392.0, 415.3, 440.0, 466.2, 493.9],
        [523.3, 554.4, 587.3, 622.3, 659.3, 698.5, 740.0, 784.0, 830.6, 880.0, 932.3, 987.8],
        [1047, 1109, 1175, 1245, 1319, 1397, 1480, 1568, 1661, 1760, 1865, 1976],
        [2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951]
    ]
    
    let noteName = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let noteIndex = ["1", "2", "3", "4", "5", "6", "7"]
    
    var max_HZ: Float = 0
    
    class var sharedInstance: TunerFunction {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: TunerFunction? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = TunerFunction()
        }
        return Static.instance!
    }
    
    // min, mid, max, minname, midname, maxname, midIndex, midName
    func checkTheHZRange() -> (Float, Float, Float, String!, String!, String!, Int, Int) {
        var range_min_HZ: Float = 0
        var range_mid_HZ: Float = 0
        var range_max_HZ: Float = 0
        var range_min_Name: String = ""
        var range_mid_Name: String = ""
        var range_max_Name: String = ""
        var noteI: Int = 0
        var noteN: Int = 0
        for var i = 1; i < noteIndex.count - 2; i++ {
            if max_HZ >= NOTE_HZ[i][0] && max_HZ < NOTE_HZ[i + 1][0] {
                for var j = 0; j < noteName.count - 1; j++ {
                    if max_HZ >= NOTE_HZ[i][j] && max_HZ < NOTE_HZ[i][j + 1] {
                        if (max_HZ - NOTE_HZ[i][j]) / (NOTE_HZ[i][j + 1] - NOTE_HZ[i][j]) >= 0.5 {
                            range_min_HZ = NOTE_HZ[i][j]
                            range_mid_HZ = NOTE_HZ[i][j + 1]
                            if j + 2 > 11 {
                                range_max_HZ = NOTE_HZ[i + 1][0]
                                range_max_Name = noteName[0] + noteIndex[i + 1]
                            } else {
                                range_max_HZ = NOTE_HZ[i][j + 2]
                                range_max_Name = noteName[j + 2] + noteIndex[i]
                            }
                            
                            range_min_Name = noteName[j] + noteIndex[i]
                            range_mid_Name = noteName[j + 1] + noteIndex[i]
                            
                            noteI = i
                            noteN = j + 1
                        } else {
                            if j - 1 < 0 {
                                range_min_HZ = NOTE_HZ[i - 1][11]
                                range_min_Name = noteName[11] + noteIndex[i - 1]
                            } else {
                                range_min_HZ = NOTE_HZ[i][j - 1]
                                range_min_Name = noteName[j - 1] + noteIndex[i]
                            }
                            range_mid_HZ = NOTE_HZ[i][j]
                            range_max_HZ = NOTE_HZ[i][j + 1]
                            range_mid_Name = noteName[j] + noteIndex[i]
                            range_max_Name = noteName[j + 1] + noteIndex[i]
                            noteI = i
                            noteN = j
                        }
                        break
                    }
                }
            }
        }
        return (range_min_HZ, range_mid_HZ,range_max_HZ, range_min_Name, range_mid_Name, range_max_Name, noteI, noteN)
    }
    
    func getMax_HZ(sender: Float) {
        max_HZ = sender
    }
    
    func calcPosition(range_min_HZ: Float, range_max_HZ: Float) -> Float {
        return (max_HZ - range_min_HZ) / (range_max_HZ - range_min_HZ)
    }
}