
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AWSS3
import MediaPlayer
import AVFoundation
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var suspended:Bool = false
    
    var shuffleMode:MPMusicShuffleMode!
    var repeatMode:MPMusicRepeatMode!
    var rootVC: UIViewController!
      
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // it is important to registerDefaults as soon as possible,
        // because it can change so much of how your app behaves
        //
        var defaultsDictionary: [String : AnyObject] = [:]
        
        // by default we track the user location while in the background
        defaultsDictionary[kShowDemoSong] = true
        defaultsDictionary[kShowTutorial] = true
        defaultsDictionary[kShowTabsEditorTutorial] = true
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultsDictionary)
                
        return true
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics.self])

        // Universal setting
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        // fackbook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        // aws s3 and cognito
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: CognitoRegionType, identityPoolId: CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: DefaultServiceRegionType, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        NetworkManager.sharedInstance.reachability.isReachable()

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        let currentVC = topViewController(rootViewController())
        if currentVC.isKindOfClass(SongViewController) {
            let currentSongVC = currentVC as! SongViewController
            if(!currentSongVC.isSongNeedPurchase){
                currentSongVC.stopTimer()
            }       
            print("Song VC entering background")
            
            // save music state if exit Twistjam when in Editor mode
            if(currentVC.presentedViewController != nil){
                let presentVC = currentVC.presentedViewController!
                if presentVC.isKindOfClass(TabsEditorViewController) || presentVC.isKindOfClass(LyricsTextViewController) {
                    var isDemoSong:Bool = false
                    if presentVC.isKindOfClass(TabsEditorViewController) {
                        isDemoSong = (presentVC as! TabsEditorViewController).isDemoSong
                        if(!isDemoSong){
                            (presentVC as! TabsEditorViewController).removeNotification()
                        }
                        (presentVC as! TabsEditorViewController).isPlaying = false
                        (presentVC as! TabsEditorViewController).playPauseButton.setImage(UIImage(named: "playButton"), forState: UIControlState.Normal)
                    }else if presentVC.isKindOfClass(LyricsTextViewController){
                        isDemoSong = (presentVC as! LyricsTextViewController).isDemoSong
                    }
                    
                    if(!isDemoSong){
                        
                        MusicManager.sharedInstance.player.pause()
                    }
                }
            }
        }
        if(MusicManager.sharedInstance.player != nil && MusicManager.sharedInstance.player.nowPlayingItem != nil){
            MusicManager.sharedInstance.lastPlayingItem = MusicManager.sharedInstance.player.nowPlayingItem
            MusicManager.sharedInstance.lastPlayingTime = MusicManager.sharedInstance.player.currentPlaybackTime
        }
        
        self.suspended = KGLOBAL_init_queue.suspended
        KGLOBAL_queue.suspended = true
        KGLOBAL_init_queue.suspended = true
        shuffleMode = MusicManager.sharedInstance.player.shuffleMode
        repeatMode = MusicManager.sharedInstance.player.repeatMode
        
        print("Go into Background suspend nsoperationqueue:\(self.suspended)")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        let currentVC = topViewController(rootViewController())
        
       
        if(MusicManager.sharedInstance.player != nil){
            MusicManager.sharedInstance.player.shuffleMode = self.shuffleMode
            MusicManager.sharedInstance.player.repeatMode = repeatMode
        }
    
        if currentVC.isKindOfClass(SongViewController) {
            let currentSongVC = currentVC as! SongViewController
            currentSongVC.removeAllObserver()
            
            //check if the viewController is Tabs Editor or lyrics SyncEditor
            //in case mediaItem was changed outside the app, if changed, we used
            //the last playing item and time
            if(currentVC.presentedViewController != nil){
                currentSongVC.registerMediaPlayerNotification()
                let presentVC = currentVC.presentedViewController!
                if presentVC.isKindOfClass(TabsEditorViewController) || presentVC.isKindOfClass(LyricsTextViewController) {
                    var isDemoSong:Bool = false
                    if presentVC.isKindOfClass(TabsEditorViewController) {
                        isDemoSong = (presentVC as! TabsEditorViewController).isDemoSong
                    }else if presentVC.isKindOfClass(LyricsTextViewController){
                        isDemoSong = (presentVC as! LyricsTextViewController).isDemoSong
                    }
                    
                    let lastPlayingItem = MusicManager.sharedInstance.lastPlayingItem
                    
                    if(!isDemoSong){
                        
                        if MusicManager.sharedInstance.player != nil && (MusicManager.sharedInstance.player.nowPlayingItem == nil || MusicManager.sharedInstance.player.nowPlayingItem != lastPlayingItem){
                            MusicManager.sharedInstance.player.stop()
                            MusicManager.sharedInstance.player.repeatMode = .All
                            MusicManager.sharedInstance.player.shuffleMode = .Off
                            if(MusicManager.sharedInstance.lastPlayerQueue.contains(lastPlayingItem)){
                                MusicManager.sharedInstance.player.setQueueWithItemCollection(MPMediaItemCollection(items: MusicManager.sharedInstance.lastPlayerQueue))
                            }else{
                                MusicManager.sharedInstance.player.setQueueWithItemCollection(MPMediaItemCollection(items: [lastPlayingItem]))
                                MusicManager.sharedInstance.lastPlayerQueue = [lastPlayingItem]
                            }
                            MusicManager.sharedInstance.player.nowPlayingItem = lastPlayingItem
                            MusicManager.sharedInstance.player.repeatMode = .One
                            MusicManager.sharedInstance.player.shuffleMode = .Off
                            MusicManager.sharedInstance.player.currentPlaybackTime = MusicManager.sharedInstance.lastPlayingTime
                            MusicManager.sharedInstance.player.pause()
                            if presentVC.isKindOfClass(TabsEditorViewController) {
                                (presentVC as! TabsEditorViewController).registerNotification()
                            }
                        }else if MusicManager.sharedInstance.player != nil && MusicManager.sharedInstance.player.nowPlayingItem != nil && MusicManager.sharedInstance.player.nowPlayingItem == lastPlayingItem {
                            MusicManager.sharedInstance.player.repeatMode = .One
                            MusicManager.sharedInstance.player.shuffleMode = .Off
                            MusicManager.sharedInstance.player.currentPlaybackTime = MusicManager.sharedInstance.lastPlayingTime
                            MusicManager.sharedInstance.player.pause()
                            if presentVC.isKindOfClass(TabsEditorViewController) {
                                (presentVC as! TabsEditorViewController).registerNotification()
                            }
                        }
                    }else{
                        if  MusicManager.sharedInstance.player != nil && MusicManager.sharedInstance.player.nowPlayingItem != nil {
                            MusicManager.sharedInstance.player.pause()
                        }
                    }
                }
            }else {
                if MusicManager.sharedInstance.player != nil && MusicManager.sharedInstance.player.nowPlayingItem == nil && !currentSongVC.isDemoSong {
                    // if go outside Twistjam and close Music App, nowPlayingItem is set to nil
                    // we force to dismiss SongViewController and re-initialize player
                    if (!currentSongVC.isSongNeedPurchase) {
                        
                        currentSongVC.viewDidDisappear(false)
                        currentSongVC.dismissViewControllerAnimated(true, completion: {
                            completed in
                            KGLOBAL_queue.suspended = false
                            KGLOBAL_init_queue.suspended = self.suspended
                            MusicManager.sharedInstance.initializePlayer()
                        })
                    } else {
                        currentSongVC.registerMediaPlayerNotification()
                        KGLOBAL_queue.suspended = false
                        KGLOBAL_init_queue.suspended = self.suspended
                    }
                } else {
                    currentSongVC.registerMediaPlayerNotification()
                    currentSongVC.selectedFromTable = false
                    if(!currentSongVC.isSongNeedPurchase){
                        currentSongVC.currentSongChanged()
                        currentSongVC.resumeSong()
                    }
                    print("Song VC entering forground")
                    KGLOBAL_queue.suspended = false
                    KGLOBAL_init_queue.suspended = self.suspended
                }
            }
        } else {
            if (MusicManager.sharedInstance.player != nil && MusicManager.sharedInstance.player.nowPlayingItem != nil){
                if(MusicManager.sharedInstance.player.playbackState == .Playing){
                    KGLOBAL_nowView.start()
                }
                if (MusicManager.sharedInstance.avPlayer.rate == 0 && MusicManager.sharedInstance.player.currentPlaybackTime != 0){
                    MusicManager.sharedInstance.avPlayer.removeAllItems()
                }
            }else{
                KGLOBAL_nowView.stop()
            }
        }
        
        KGLOBAL_isNeedToCheckIndex = true
    }


    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //facebook
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
    }
    
    func rootViewController() -> UIViewController
    {
        
        return UIApplication.sharedApplication().keyWindow!.rootViewController!
    }
    
    func topViewController(rootVC: UIViewController) -> UIViewController {
        if rootVC.presentedViewController == nil {
            
            return rootVC
        }
        if rootVC.presentedViewController!.isKindOfClass(UINavigationController) {
            let navigationController = UINavigationController(rootViewController: rootVC)
            return navigationController.viewControllers.last!

        }
        let presentViewController = rootVC.presentedViewController
        return presentViewController!
    }
}

