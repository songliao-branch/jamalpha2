//
//  Constants.swift
//  
//
//  Created by Song Liao on 11/3/15.
//
//

import Foundation

let KGLOBAL_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_operationCache = [NSURL:NSBlockOperation]()

let KGLOBAL_init_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_init_operationCache = [NSURL:NSBlockOperation]()


// value is a BOOL
var KEY_isSoundWaveformGeneratingInBackground:Bool = false