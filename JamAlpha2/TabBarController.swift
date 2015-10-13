//
//  TabBarController.swift
//  JamAlpha2
//
//  Created by FangXin on 10/11/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
