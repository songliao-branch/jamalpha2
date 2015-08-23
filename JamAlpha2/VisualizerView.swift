//
//  VisualizerView.swift
//  AudioVisualizer
//
//  Created by Anne Dong on 8/12/15.
//  Copyright (c) 2015 Xin Fang. All rights reserved.
//

import UIKit
import AVFoundation


let kWidth = 5
let kPadding = 1

class VisualizerView: UIView {
    var barColor:UIColor!
    var barArray:NSArray!
    var timer:NSTimer!
    
    func initWithNumberOfBars(numberOfBars:Int)
    {
    
        self.frame = CGRectMake(0, 0, CGFloat(kPadding*(numberOfBars+4)+(kWidth*numberOfBars)), 50);
        var tempBarArray:NSMutableArray = NSMutableArray(capacity: numberOfBars)
        
        for i in 0..<numberOfBars {
            var bar:UIImageView = UIImageView(frame: CGRectMake(CGFloat(kWidth*2+i*kWidth+i*kPadding), 5 , CGFloat(kWidth), 10))
            
            bar.backgroundColor = UIColor.whiteColor()
            
            self.addSubview(bar)
            tempBarArray.addObject(bar)
        }
    
        
        self.barArray = NSArray(array: tempBarArray)
    
        var transform:CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(M_PI_2*2))
        self.transform = transform
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stop", name: "stopTimer", object: nil)
    
    
    }
    
    
    func start(){
        if(timer == nil){
            self.hidden = false
            timer = NSTimer.scheduledTimerWithTimeInterval(0.35, target:self, selector: "ticker", userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    
    func stop(){
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }

    func ticker(){
        UIView.animateWithDuration(0.35, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            for bar in self.barArray{
                let tempbar = bar as! UIImageView
                var rect:CGRect = bar.frame
                rect.size.height = CGFloat(arc4random() % 20 + 1)
                tempbar.frame = rect
            }}, completion: nil)
    }
}
