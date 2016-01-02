//
//  AppDelegate.swift
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
      
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // it is important to registerDefaults as soon as possible,
        // because it can change so much of how your app behaves
        //
        var defaultsDictionary: [String : AnyObject] = [:]
        
        // by default we track the user location while in the background
        defaultsDictionary[kShowDemoSong] = true
        defaultsDictionary[kShowTutorial] = true
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
                    }else if presentVC.isKindOfClass(LyricsTextViewController){
                        isDemoSong = (presentVC as! LyricsTextViewController).isDemoSong
                    }
                    
                    if(!isDemoSong){
                        MusicManager.sharedInstance.player.pause()
                        
                        MusicManager.sharedInstance.lastPlayingItem = MusicManager.sharedInstance.player.nowPlayingItem
                        MusicManager.sharedInstance.lastPlayingTime = MusicManager.sharedInstance.player.currentPlaybackTime
                    }
                }
            }
        }
        
        self.suspended = KGLOBAL_init_queue.suspended
        KGLOBAL_queue.suspended = true
        KGLOBAL_init_queue.suspended = true
        print("Go into Background suspend nsoperationqueue:\(self.suspended)")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

         var isKeepGoingOn:Bool = true
        let currentVC = topViewController(rootViewController())
        MusicManager.sharedInstance.reloadCollections()
        // if the collection is different i.e. new songs are added/old songs are removed
        // we manually reload MusicViewController table
            if rootViewController().isKindOfClass(TabBarController) {
                let tabBarController = rootViewController() as! TabBarController
                for tabItemController in (tabBarController.viewControllers)! {
                    if tabItemController.isKindOfClass(UINavigationController){
                        for childVC in tabItemController.childViewControllers {
                            if childVC.isKindOfClass(BaseViewController) {
                                let baseVC = childVC as! BaseViewController

                                for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                                    musicVC.reloadDataAndTable()
                                    
                                    if(!musicVC.uniqueSongs.isEmpty && kShouldReloadMusicTable){
                                        musicVC.songCount = 0
                                        musicVC.generateWaveFormInBackEnd(musicVC.uniqueSongs[Int(musicVC.songCount)])
                                    }
                                }
                                if(currentVC.isKindOfClass(SongViewController)){
                                    let currentSongVC = currentVC as! SongViewController
                                    if(currentSongVC.isSongNeedPurchase){
                                        if let purchasedItem = (MusicManager.sharedInstance.isNeedReloadCollections(currentSongVC.songNeedPurchase.trackName!, artist: currentSongVC.songNeedPurchase.artistName!, duration: currentSongVC.songNeedPurchase.trackTimeMillis!)){
                                            MusicManager.sharedInstance.setPlayerQueue([purchasedItem])
                                            MusicManager.sharedInstance.setIndexInTheQueue(0)
                                            self.suspended = true
                                            ////////////////////////////////////
                                            currentSongVC.recoverToNormalSongVC(purchasedItem)
                                        }
                                    }else{
                                        if (MusicManager.sharedInstance.player != nil && MusicManager.sharedInstance.player.nowPlayingItem != nil && !currentSongVC.isDemoSong){
                                            if !MusicManager.sharedInstance.uniqueSongs.contains(MusicManager.sharedInstance.player.nowPlayingItem!){
                                                currentSongVC.dismissViewControllerAnimated(true, completion: {
                                                    completed in
                                                    KGLOBAL_queue.suspended = false
                                                    KGLOBAL_init_queue.suspended = self.suspended
                                                    isKeepGoingOn = false
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    
        if isKeepGoingOn {
            if currentVC.isKindOfClass(SongViewController) {
                let currentSongVC = currentVC as! SongViewController
                currentSongVC.removeAllObserver()
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
                    }else{
                        KGLOBAL_queue.suspended = false
                        KGLOBAL_init_queue.suspended = self.suspended
                        
                    }
                }else{
                    currentSongVC.registerMediaPlayerNotification()
                    currentSongVC.selectedFromTable = false
                    if(!currentSongVC.isSongNeedPurchase){
                        currentSongVC.resumeSong()
                    }
                    print("Song VC entering forground")
                    KGLOBAL_queue.suspended = false
                    KGLOBAL_init_queue.suspended = self.suspended
                }
                
                //check if the viewController is Tabs Editor or lyrics SyncEditor
                //in case mediaItem was changed outside the app, if changed, we used
                //the last playing item and time
                if(currentVC.presentedViewController != nil){
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
                                MusicManager.sharedInstance.player.setQueueWithItemCollection(MPMediaItemCollection(items: MusicManager.sharedInstance.lastPlayerQueue))
                                MusicManager.sharedInstance.player.nowPlayingItem = lastPlayingItem
                                MusicManager.sharedInstance.player.repeatMode = .One
                                MusicManager.sharedInstance.player.shuffleMode = .Off
                                MusicManager.sharedInstance.player.currentPlaybackTime = MusicManager.sharedInstance.lastPlayingTime                     }
                        } else if MusicManager.sharedInstance.player != nil && MusicManager.sharedInstance.player.nowPlayingItem != nil && MusicManager.sharedInstance.player.nowPlayingItem == lastPlayingItem {
                            MusicManager.sharedInstance.player.repeatMode = .One
                            MusicManager.sharedInstance.player.shuffleMode = .Off
                            MusicManager.sharedInstance.player.currentPlaybackTime = MusicManager.sharedInstance.lastPlayingTime
                        }
                    }
                }
            }
        }

        KGLOBAL_isNeedToCheckIndex = true
        print("Go into forground")
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

