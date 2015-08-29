//
//  UIView+Geometry.swift
//  waveForm
//
//  Created by Anne Dong on 7/19/15.
//  Copyright (c) 2015 Anne Dong. All rights reserved.
//

import UIKit
import Foundation

extension UIView{
    public var sizeToFitWithinSize: CGSize {
        get {
            return CGSize()
        }
        set(value) {
            var frame:CGRect = self.frame
            frame.size = self.sizeThatFits(value)
            self.frame = frame
        }
    }
    
    public var left:CGFloat{
        get{
            return self.frame.origin.x
        }set(value){
            var frame:CGRect = self.frame
            frame.origin.x = value
            self.frame = frame
    
        }
    }

    
    public var top:CGFloat{
        get{
            return self.frame.origin.y
        }set(value){
            var frame:CGRect = self.frame
            frame.origin.y = value
            self.frame = frame
        }
    }
    
    
    public var right:CGFloat{
        get{
            return self.frame.origin.x+self.frame.size.width
        }set(value){
            var frame:CGRect = self.frame
            frame.origin.x = value - frame.size.width
            self.frame = frame
        }
    }
    
    public var bottom:CGFloat{
        get{
            return self.frame.origin.y + self.frame.size.height
        }set(value){
            var frame:CGRect = self.frame
            frame.origin.y = value - frame.size.height
            self.frame = frame

        }
    }
    
    public var centerX:CGFloat{
        get{
            return self.center.x
        }set(value){
           self.center = CGPointMake(value, self.center.y)
        }
    }
    
    public var centerY:CGFloat{
        get{
            return self.center.y
        }set(value){
            self.center = CGPointMake(self.center.x, value)
        }
    }
    
    public var width:CGFloat{
        get{
            return self.frame.size.width
        }set(value){
            var frame:CGRect = self.frame
            frame.size.width = value
            self.frame = frame

        }
    }
    
    public var height:CGFloat{
        get{
            return self.frame.size.height
        }set(value){
            var frame:CGRect = self.frame
            frame.size.height = value
            self.frame = frame
        }
    }
    
    
    public var visible:Bool{
        get{
            return !self.hidden
        }set(value){
            self.hidden = !value
        }
    }
    
}
