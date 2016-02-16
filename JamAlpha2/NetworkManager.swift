//
//  NetworkManager.swift
//  JamAlpha2
//
//  Created by FangXin on 1/8/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import ReachabilitySwift

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
    
    do {
      reachability = try Reachability.reachabilityForInternetConnection()
    } catch {
      print("Unable to create Reachability")
      return
    }
    
//    // Here we set up a NSNotification observer. The Reachability that caused
//    // the notification is passed in the object parameter
//    NSNotificationCenter.defaultCenter().addObserver(self,
//      selector: "reachabilityChanged:",
//      name: ReachabilityChangedNotification,
//      object: nil)
//    
//    
//    do {
//      try self.reachability!.startNotifier()
//    } catch {
//      print("Unable to start the notification")
//      return
//    }
  }
  
  deinit {
//    if (self.reachability != nil) {
//      reachability.stopNotifier()
//    }
  }
  
  func reachabilityChanged(notification: NSNotification) {
    
  }
}
