//
//  UIViewController+Utils.swift
//  JamAlpha2
//
//  Created by Song Liao on 11/19/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showMessage(title:String, message:String, actionTitle:String,completion: (() -> Void)? ){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated:true, completion: completion)
    }
}