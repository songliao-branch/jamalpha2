//
//  PopOverSlider.swift
//  PopOverSlider
//
//  Created by Anne Dong on 8/27/15.
//  Copyright (c) 2015 Xin Fang. All rights reserved.
//

import UIKit

class PopOverSlider: UISlider {

    var popOver:PopOver!
    var songVC:SongViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
          self.popOver = popover()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func popover() -> PopOver{
        if(popOver == nil){
            self.addTarget(self, action: "updatePopOverFrame", forControlEvents: UIControlEvents.ValueChanged)
            popOver = PopOver(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y-32, 40, 32))
            self.updatePopOverFrame()
        }
        return popOver
    }
    
    override func setValue(value: Float, animated: Bool) {
        super.setValue(value, animated: animated)
        self.updatePopOverFrame()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.updatePopOverFrame()
        self.showPopoverAnimated(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("touchesEnded")
        songVC!.player.currentPlaybackRate = self.value + 1
        songVC!.speed = self.value + 1
        songVC!.timer.invalidate()
        songVC!.startTimer()
        self.hidePopoverAnimated(true)
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        println("touchesCancelled")
        self.hidePopoverAnimated(true)
        super.touchesCancelled(touches, withEvent: event)
    }
    
    
    func updatePopOverFrame(){
        var minimum:CGFloat = CGFloat(self.minimumValue)
        var maximum:CGFloat = CGFloat(self.maximumValue)
        var value:CGFloat = CGFloat(self.value)
        
        if(minimum < 0.0){
            value = CGFloat(self.value) - minimum
            maximum = maximum - minimum
            minimum = 0.0
        }
        
        var x:CGFloat = self.frame.origin.x
        var maxMin = (maximum + minimum) / 2.0
        
        x += (((value - minimum) / (maximum - minimum)) * self.frame.size.width) - (self.popOver.frame.size.width / 2.0)
        
        if (value > maxMin) {
            
            value = (value - maxMin) + (minimum * 1.0)
            value = value / maxMin
            value = value * 11.0
            
            x = x - value
            
        } else {
            
            value = (maxMin - value) + (minimum * 1.0)
            value = value / maxMin
            value = value * 11.0
            
            x = x + value
        }
        
        var popoverRect:CGRect = self.popOver.frame
        popoverRect.origin.x = x
        popoverRect.origin.y = self.frame.origin.y - popoverRect.size.height/2 + 25
        
        self.popOver.frame = popoverRect
    }
    
    func showPopover(){
        self.showPopoverAnimated(false)
    }
    
    func showPopoverAnimated(animated:Bool){
        if(animated){
            UIView.animateWithDuration(0.25, animations: {
                self.popOver.alpha = 1.0
            })
        }else{
            self.popOver.alpha = 1.0
        }
    }
    
    func hidePopover(){
        self.hidePopoverAnimated(false)
    }
    
    func hidePopoverAnimated(animated:Bool){
        if(animated){
            UIView.animateWithDuration(0.25, animations: {
                self.popOver.alpha = 0.0
            })
        }else{
            self.popOver.alpha = 0.0
        }
    }

}
