//
//  File.swift
//  JamAlpha2
//
//  Created by FangXin on 3/8/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer


class TwistJamController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: reloadCollectionsNotificationKey, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: reloadCollectionsNotificationKey, object: nil)
  }
  
  func refreshData() {
    // TODO: should be overrided in childview controller
  }
  
}
