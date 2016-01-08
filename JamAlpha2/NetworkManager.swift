//
//  NetworkManager.swift
//  JamAlpha2
//
//  Created by FangXin on 1/8/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import Reachability

class NetworkManager:NSObject {
    var reachability:Reachability!
    var isReachable:Bool = false
    var isReachableViaWWAN = false
    var isReachableViaWiFi = false
    
    class var sharedInstance: NetworkManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: NetworkManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = NetworkManager()
        }
        return Static.instance!
    }
    override init() {
        super.init()
        self.reachability = Reachability.reachabilityForInternetConnection()
        
        // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
        self.reachability!.reachableOnWWAN = false
        self.isReachableViaWiFi = self.reachability.isReachableViaWiFi()
        self.isReachableViaWWAN = self.reachability.isReachableViaWWAN()
        self.isReachable = self.isReachableViaWiFi || self.isReachableViaWWAN
        
        // Here we set up a NSNotification observer. The Reachability that caused the notification
        // is passed in the object parameter
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "reachabilityChanged:",
            name: kReachabilityChangedNotification,
            object: nil)
        
        self.reachability!.startNotifier()
 
    }
    deinit{
        if(self.reachability != nil){
            reachability.stopNotifier()
        }
    }
    
    func reachabilityChanged(notification: NSNotification) {
        if self.reachability!.isReachableViaWiFi(){
            print("Service avalaible!!!")
            self.isReachable = true
            self.isReachableViaWiFi = true
            self.isReachableViaWWAN = false
        } else if self.reachability!.isReachableViaWWAN() {
            self.isReachable = true
            self.isReachableViaWiFi = false
            self.isReachableViaWWAN = true
        }else {
            self.isReachable = false
            self.isReachableViaWiFi = false
            self.isReachableViaWWAN = false
            print("No service avalaible!!!")
        }
    }
}
