//
//  Constants.swift
//  
//
//  Created by Song Liao on 11/3/15.
//
//

import UIKit

let KGLOBAL_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_operationCache = [NSURL:NSBlockOperation]()

let KGLOBAL_init_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_init_operationCache = [NSURL:NSBlockOperation]()

var KGLOBAL_progressBlock: SoundWaveView!

var KGLOBAL_timer:NSTimer!

var KGLOBAL_isNeedToCheckIndex:Bool = false

// value is a BOOL
var KEY_isSoundWaveformGeneratingInBackground:Bool = false

let facebookLoginSalt = "tJwIa021#1sm" //DO NOT MODIFITY THIS SALT, otherwise facebook user can get back their account created with facebook

//reload music table after detecting new songs are added
var kShouldReloadMusicTable = false

let kShowDemoSong  = "showDemoSong"

let kSongNames = ["Go"]

//var KGLOBAL_closeDemoButton:UIButton!