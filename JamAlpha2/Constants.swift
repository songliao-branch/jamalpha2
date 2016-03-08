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


var KGLOBAL_progressBlock: SoundWaveView!

var KGLOBAL_timer:NSTimer!

var KGLOBAL_isNeedToCheckIndex:Bool = false

var KGLOBAL_nowView = VisualizerView()
// value is a BOOL
var KEY_isSoundWaveformGeneratingInBackground:Bool = false

let facebookLoginSalt = "tJwIa021#1sm" //DO NOT MODIFITY THIS SALT, otherwise facebook user can get back their account created with facebook

let kShowDemoSong  = "showDemoSong"
let kShowTutorial = "showTutorial"
let kShowTabsEditorTutorialA = "kShowTabsEditorTutorialA"
let kShowTabsEditorTutorialB = "kShowTabsEditorTutorialB"
let kShowLyricsTutorial = "kShowLyricsTutorial"
let kSongNames = ["Go"]

//used in core data to refer to a locally created tabsSet/lyricsSet
let kLocalSetId = -1

var KAVplayer: AVPlayer!

let kMusicLibaryChangedNotification = "MusicLibraryChanged"
let kIndexOfTopPage = 0
let kIndexOfMyMusicPage = 1
let kIndexOfSearchPage = 2
let kIndexOfUserPage = 3

let APP_STORE_ID = "1066080131"

let FACEBOOK_PAGE_URL = "https://www.facebook.com/twistjam"
let VERSION_NUMBER = "1.0.0"//TODO: change this
let COPYRIGHTYEAR = "2015-2016"

let DEFAULT_COVER = "liweng"