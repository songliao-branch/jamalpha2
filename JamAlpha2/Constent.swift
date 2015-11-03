//
//  Constent.swift
//  JamAlpha2
//
//  Created by FangXin on 11/2/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

let KGLOBAL_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_operationCache = [NSURL:NSBlockOperation]()

let KGLOBAL_init_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_init_operationCache = [NSURL:NSBlockOperation]()

var KGLOBAL_progressBlock: SoundWaveView!


//keys

// value is a BOOL
var KEY_isSoundWaveFormInBackgroundGenerated:Bool = false

