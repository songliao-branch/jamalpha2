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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var suspended:Bool = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
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
        }
        self.suspended = KGLOBAL_init_queue.suspended
        KGLOBAL_queue.suspended = true
        KGLOBAL_init_queue.suspended = true
        print("Go into Background suspend nsoperationqueue:\(self.suspended)")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        MusicManager.sharedInstance.reloadCollections()
        
        let currentVC = topViewController(rootViewController())
        
        if kShouldReloadMusicTable {
            if rootViewController().isKindOfClass(TabBarController) {
                let tabBarController = rootViewController() as! TabBarController
                
                for tabItemController in (tabBarController.viewControllers)! {
                    if tabItemController.isKindOfClass(UINavigationController){
                        for childVC in tabItemController.childViewControllers {
                            if childVC.isKindOfClass(BaseViewController) {
                                let baseVC = childVC as! BaseViewController

                                for musicVC in baseVC.pageViewController.viewControllers as! [MusicViewController] {
                                    musicVC.reloadDataAndTable()
                                }
                            }
                        }
                    }
                }
            }
        }

        if currentVC.isKindOfClass(SongViewController) {
            let currentSongVC = currentVC as! SongViewController
            currentSongVC.selectedFromTable = false
            if(!currentSongVC.isSongNeedPurchase){
                currentSongVC.resumeSong()
            }
            print("Song VC entering forground")
        }
        KGLOBAL_queue.suspended = false
        KGLOBAL_init_queue.suspended = self.suspended
        print("Go into forground:\(self.suspended)")
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

