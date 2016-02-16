//
//  TabBarController.swift
//  JamAlpha2
//
//  Created by FangXin on 10/11/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
         (UIApplication.sharedApplication().delegate as! AppDelegate).rootVC = self
    }
  
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {

        let allVCs = tabBarController.viewControllers
       
        if CoreDataManager.getCurrentUser() == nil &&  allVCs?[tabBarController.selectedIndex] == viewController {
            return false
        }
        return true
    }    
}




