//
//  CustomSegue.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 11/17/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import Foundation
import UIKit

class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
        sourceViewController.navigationController?.setViewControllers([destinationViewController], animated: true)
    }
}