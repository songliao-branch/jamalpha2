//
//  Constants.swift
//  
//
//  Created by Song Liao on 11/3/15.
//
//

import Foundation
import UIKit

let KGLOBAL_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_operationCache = [NSURL:NSBlockOperation]()

let KGLOBAL_init_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_init_operationCache = [NSURL:NSBlockOperation]()

var KGLOBAL_progressBlock: SoundWaveView!

// value is a BOOL
var KEY_isSoundWaveFormInBackgroundGenerated:Bool = false

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height