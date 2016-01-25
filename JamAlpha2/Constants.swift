//
//  Constants.swift
//  
//
//  Created by Song Liao on 11/3/15.
//
//

import UIKit
import MediaPlayer
import AVFoundation

let KGLOBAL_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_operationCache = [String:NSBlockOperation]()

let KGLOBAL_init_queue:NSOperationQueue = NSOperationQueue()
var KGLOBAL_init_operationCache = [String:NSBlockOperation]()

var KGLOBAL_progressBlock: SoundWaveView!
var KGLOBAL_defaultProgressBar:UIProgressView!

var KGLOBAL_timer:NSTimer!

var KGLOBAL_isNeedToCheckIndex:Bool = false

var KGLOBAL_nowView = VisualizerView()
// value is a BOOL
var KEY_isSoundWaveformGeneratingInBackground:Bool = false

let facebookLoginSalt = "tJwIa021#1sm" //DO NOT MODIFITY THIS SALT, otherwise facebook user can get back their account created with facebook


let kShowDemoSong  = "showDemoSong"
let kShowTutorial = "showTutorial"
let kShowTabsEditorTutorial = "kShowTabsEditorTutorial"
let kShowLyricsTutorial = "kShowLyricsTutorial"
let kSongNames = ["Go"]

//used in core data to refer to a locally created tabsSet/lyricsSet
let kLocalSetId = -1

var KAVplayer: AVPlayer!

let kIndexOfMyMusicPage = 0
let kIndexOfSearchPage = 1
let kIndexOfTopPage = 2
let kIndexOfUserPage = 3
