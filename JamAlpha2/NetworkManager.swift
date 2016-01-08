//
//  NetworkManager.swift
//  JamAlpha2
//
//  Created by FangXin on 1/8/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import Reachability

class NetworkManager: NSObject {
    var reachability: Reachability!
    
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
    
    var tableView: UITableView?
    
    func reachabilityChanged(notification: NSNotification) {
        
        if let table = tableView {
            table.reloadData()
        }
    }
}
