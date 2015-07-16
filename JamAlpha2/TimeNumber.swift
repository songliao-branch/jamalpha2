//
//  TimeNumber.swift
//  JamAlpha2
//
//  Created by Xing Liu on 7/10/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import Foundation

class TimeNumber {
    var second: Int
    var decimal: Int
    
    init(second: Int, decimal: Int){
        self.second = (second + decimal/100)
        self.decimal = decimal % 100
    }
    
    init(time: Float){
        var str = NSString(format: "%.2f", time) as String
        var nums = split(str){$0 == "." }
        second = nums[0].toInt()!
        decimal = (nums.count > 1) ? nums[1].toInt()! : 0
    }
    
    func isEqual(tn: TimeNumber) -> Bool{
        return self.second == tn.second && self.decimal == tn.decimal
    }
    
    func isEqual(time: Float) -> Bool {
        var a = Int(100*time)
        return second == (a / 100) && second == (a % 100)
    }
    
    func toDecimalNumer() -> Float{
        return (self.toString() as NSString).floatValue
    }
    
    func addMinimal(){
        decimal++
        if(decimal == 100) {
            decimal = 0
            second++
        }
    }
    
    func toString() -> String{
        if decimal < 10{
            return "\(second).0\(decimal)"
        }
        return "\(second).\(decimal)"
    }
    
    func isLongerThan(tn: TimeNumber) -> Bool{
        var res: Bool = true
        if self.second == tn.second{
            res = (self.decimal > tn.decimal)
        }
        else{
            res = (self.second > tn.second)
        }
        return res
    }
}