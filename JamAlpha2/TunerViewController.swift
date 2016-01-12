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
    var frequencyScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TunerManager.initialTuner()
        startTimer()
        setUpOnMainView()
        setUpIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        stopTimer()
        TunerManager.deinitialTuner() 
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func handleTimer(sender: NSTimer) {
        let max_HZ: Float = TunerManager.getMaxHZ()
        TunerFunction.sharedInstance.getMax_HZ(max_HZ)
        let result = TunerFunction.sharedInstance.checkTheHZRange()
        print("\(result.0), \(result.1), \(result.2), \(result.3)")
        let letterWidth: CGFloat = self.view.frame.size.width / 6
        if result.0 == result.1 {
            self.frequencyScrollView.setContentOffset(CGPointMake(letterWidth / 2 + letterWidth * CGFloat((result.4 * 12 + result.5) * 2) - 1.5 * letterWidth, 0), animated: true)
        } else {
            let position = TunerFunction.sharedInstance.calcPosition(result.0, range_max_HZ: result.1)
            self.frequencyScrollView.setContentOffset(CGPointMake(letterWidth / 2 + letterWidth * CGFloat((result.4 * 12 + result.5) * 2) - 1.5 * letterWidth + letterWidth * CGFloat(position), 0), animated: true)
        }
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "handleTimer:", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        timer = nil
    }
    
}

extension TunerViewController {
    func setUpOnMainView() {
        let letterWidth: CGFloat = self.view.frame.size.width / 6
        let frame = CGRectMake(0, self.view.center.y - letterWidth * 2, self.view.frame.size.width, letterWidth)
        self.frequencyScrollView = UIScrollView(frame: frame)
        self.frequencyScrollView.contentSize = CGSizeMake(self.view.frame.width * 28, letterWidth)
        
        for var i = 0; i < 7 * 12; i++ {
            let noteLabel: UILabel = UILabel()
            noteLabel.frame = CGRectMake(letterWidth / 2 + letterWidth * CGFloat(i * 2), 0, letterWidth, letterWidth)
            let lineNumber = i / 12
            let columnNumber = i % 12
            noteLabel.text = "\(TunerFunction.sharedInstance.noteName[columnNumber])\(TunerFunction.sharedInstance.noteIndex[lineNumber])"
            noteLabel.textAlignment = .Center
            noteLabel.font = UIFont.systemFontOfSize(20)
            self.frequencyScrollView.addSubview(noteLabel)
        }
        self.view.addSubview(self.frequencyScrollView)
    }
    
    func setUpIndicator() {
        let letterWidth: CGFloat = self.view.frame.size.width / 6
        let indicatorView: UIView = UIView()
        indicatorView.frame = CGRectMake(self.view.centerX - 1, self.view.centerY - letterWidth, 2, 20)
        indicatorView.backgroundColor = UIColor.blueColor()
        self.view.addSubview(indicatorView)
    }
}
