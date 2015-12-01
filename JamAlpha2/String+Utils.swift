//
//  String+Utils.swift
//  JamAlpha2
//
//  Created by Song Liao on 8/28/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation

extension String {

    func isValidEmail() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}

// to get substring of a string, for example
// var a = "hello world"
// var result = a[0...2] //returns 'he'
extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let subStart = self.startIndex.advancedBy(r.startIndex, limit: self.endIndex)
            let subEnd = subStart.advancedBy(r.endIndex - r.startIndex, limit: self.endIndex)
            return self.substringWithRange(Range(start: subStart, end: subEnd))
        }
    }
    func substring(from: Int) -> String {
        let end = self.characters.count
        return self[from..<end]
    }
    func substring(from: Int, length: Int) -> String {
        let end = from + length
        return self[from..<end]
    }
}

extension String {
    func addPluralSubscript(length: Int) -> String {
        if length > 1 {
            return self + "s"
        }
        else {
            return self
        }
    }
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}