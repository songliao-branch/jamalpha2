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
    var soundPowerLabel: UILabel!
    var audioRecognizer: ARAudioRecognizer!
    
    var minLabel: UILabel!
    var midLabel: UILabel!
    var maxLabel: UILabel!
    
    var indicatorView: UIView!
    var infoLabel: UILabel!
    var count: Int = 0
    
    var HZArray: [Float] = [Float]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar()
        audioRecognizer = ARAudioRecognizer()
        startTimer()
        setUpOnMainView()
        setUpSoundLabel()
        setUpIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        TunerManager.initialTuner()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopTimer()
        TunerManager.deinitMomuAudio()
    }
    override func viewDidDisappear(animated: Bool) {
        TunerManager.deinitialTuner() 
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = "Tuner"
    }
    
    func handleTimer(sender: NSTimer) {
        if audioRecognizer.getPower() > -35 {
            self.soundPowerLabel.text = "Detected the sound"
            self.soundPowerLabel.textColor = UIColor.greenColor()
            
            HZArray.append(TunerManager.getMaxHZ())
            count++
            if let max_HZ = HZArray.maxElement() {
                TunerFunction.sharedInstance.getMax_HZ(max_HZ)
                let result = TunerFunction.sharedInstance.checkTheHZRange()
                print("\(result.0), \(result.1), \(result.2), \(result.3), \(result.4), \(result.5), \(result.6), \(result.7)")

                UIView.animateWithDuration(0.5, animations: {
                    animate in
                    if let temp = result.3 {
                        self.minLabel.text = temp
                    }
                    if let temp = result.4 {
                        self.midLabel.text = temp
                    }
                    if let temp = result.5 {
                        self.maxLabel.text = temp
                    }
                })
      
                moveIndicator(result.0, midHZ: result.1, maxHZ: result.2, detectedHZ: max_HZ)
                
                if HZArray.count > 2 {
                    infoLabel.hidden = true

                    infoLabel.alpha = 1
                    UIView.animateWithDuration(0.5, animations: {
                            animate in
                        self.count = 0
                        self.minLabel.alpha = 1
                        self.midLabel.alpha = 1
                        self.maxLabel.alpha = 1
                        self.infoLabel.alpha = 0
                    })
                }
            }
        } else {
            count++
            if count > 5 {
                self.infoLabel.hidden = false
                self.infoLabel.alpha = 0.1
                UIView.animateWithDuration(0.5, animations: {
                    animate in
                    self.infoLabel.alpha = 1
                    self.minLabel.alpha = 0.3
                    self.midLabel.alpha = 0.3
                    self.maxLabel.alpha = 0.3
                    }, completion: {
                        complete in
                        self.HZArray.removeAll()
                        self.count = 0
                })
            }
            self.soundPowerLabel.text = "Sound is too small to detect"
            self.soundPowerLabel.textColor = UIColor.redColor()
        }
    }
    
    func moveIndicator(minHZ: Float, midHZ: Float, maxHZ: Float, detectedHZ: Float) {
        let labelWidth: CGFloat = self.view.frame.size.width / 7
        var tempHZ = detectedHZ
        var position: Float = 0
        if detectedHZ > midHZ * 0.98 && detectedHZ < midHZ * 1.02 {
            tempHZ = midHZ
        }
        if midHZ - minHZ > 0 {
            position = abs((tempHZ - midHZ) / (midHZ - minHZ))
        } else {
            position = 0
        }
        print("position: \(position)")
        UIView.animateWithDuration(0.4, animations: {
            animate in
            self.indicatorView.frame = CGRectMake(self.view.centerX + labelWidth * CGFloat(position), self.view.centerY / 2 + labelWidth / 2, 2, 20)
        })
        
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
        self.soundPowerLabel = UILabel()
        self.soundPowerLabel.frame = CGRectMake(0, 44, self.view.frame.size.width, 44)
        self.soundPowerLabel.text = "Sound is too small to detect"
        self.soundPowerLabel.textColor = UIColor.redColor()
        self.soundPowerLabel.textAlignment = .Center
        self.view.addSubview(self.soundPowerLabel)
    }
    
    func setUpSoundLabel() {
        let labelWidth: CGFloat = self.view.frame.size.width / 7
        
        minLabel = UILabel()
        minLabel.frame = CGRectMake(labelWidth + labelWidth * CGFloat(0), (self.view.centerY - labelWidth) / 2, labelWidth, labelWidth)
        minLabel.textAlignment = .Center
        minLabel.alpha = 0.3
        minLabel.text = "C3"
        self.view.addSubview(minLabel)
        
        midLabel = UILabel()
        midLabel.frame = CGRectMake(labelWidth + labelWidth * CGFloat(2), (self.view.centerY - labelWidth) / 2, labelWidth, labelWidth)
        midLabel.textAlignment = .Center
        midLabel.font = UIFont.systemFontOfSize(24)
        midLabel.alpha = 0.3
        midLabel.text = "C#3"
        self.view.addSubview(midLabel)
        
        maxLabel = UILabel()
        maxLabel.frame = CGRectMake(labelWidth + labelWidth * CGFloat(4), (self.view.centerY - labelWidth) / 2, labelWidth, labelWidth)
        maxLabel.textAlignment = .Center
        maxLabel.alpha = 0.3
        maxLabel.text = "D3"
        self.view.addSubview(maxLabel)
    }
    
    func setUpIndicator() {
        let labelWidth: CGFloat = self.view.frame.size.width / 7
        indicatorView = UIView()
        indicatorView.frame = CGRectMake(self.view.centerX, self.view.centerY / 2 + labelWidth / 2, 2, 20)
        indicatorView.backgroundColor = UIColor.blueColor()
        self.view.addSubview(indicatorView)
        
        infoLabel = UILabel()
        infoLabel.frame = CGRectMake(0, self.view.centerY / 2 + labelWidth / 2 + 50, self.view.frame.size.width, 16)
        infoLabel.textAlignment = .Center
        infoLabel.text = "Need More Sound Sample"
        infoLabel.textColor = UIColor.redColor()
        self.view.addSubview(infoLabel)
    }
}
