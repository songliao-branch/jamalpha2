//
//  Colors+.swift
//  JamAlpha2
//
//  Created by Song Liao on 8/19/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit
extension UIColor {
    //Main color for the app
    class func mainPinkColor() -> UIColor {
        return UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)//240, 91, 97
    }
    //used for background for chordbase and lyricsbase
    class func baseColor() -> UIColor {
        return UIColor(red: 1, green: 1, blue: 1, alpha: 0.65)
    }
    // for falling labels and lyrics in SongViewController
    class func silverGray() -> UIColor {
        return UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)
    }
    
    // for use in search table view section header
    class func backgroundGray()-> UIColor {
        return UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    class func actionGray()-> UIColor {
        return UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 0.9)
    }
    
    class func facebookBlue() -> UIColor {
        return UIColor(red: 0.231, green: 0.349, blue: 0.596, alpha: 1) /* #3b5998 */
    }
    
    class func borderCellColor() -> UIColor {
        return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
}
