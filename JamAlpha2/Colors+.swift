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
        return UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)//240, 91, 97, #F05B61
    }
    //used for background for chordbase and lyricsbase
    class func baseColor() -> UIColor {
        return UIColor(red: 1, green: 1, blue: 1, alpha: 0.65)
    }
    // for falling labels and lyrics in SongViewController
    class func silverGray() -> UIColor {
        return UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)
    }
    
    class func tutorialBackgroundGray() -> UIColor {
        return UIColor(red: 76 / 255, green: 75 / 255, blue: 75 / 255, alpha: 0.4)
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

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
