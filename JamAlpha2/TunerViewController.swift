//
//  TunerViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/8/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit

class TunerViewController: UIViewController {
    
    var timer: NSTimer!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TunerManager.initialTuner()
        startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTimer(sender: NSTimer) {
        let max_HZ: Float = TunerManager.getMaxHZ()
        TunerFunction.sharedInstance.getMax_HZ(max_HZ)
        let result = TunerFunction.sharedInstance.checkTheHZRange()
        print("\(result.0), \(result.1), \(result.2), \(result.3)")
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "handleTimer:", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        timer = nil
    }
    
}
