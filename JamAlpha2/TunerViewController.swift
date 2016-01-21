//
//  TunerViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 1/8/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import UIKit

class TunerViewController: UIViewController, UIActionSheetDelegate {
    
    var timer: NSTimer!
    var soundPowerLabel: UILabel!
    var audioRecognizer: ARAudioRecognizer!
    
    var minLabel: UILabel!
    var midLabel: UILabel!
    var maxLabel: UILabel!

    var infoLabel: UILabel!
    var count: Int = 0
    
    var HZArray: [Float] = [Float]()
    var progressBlockView: UIView!
    var progressBlockArray: [UIView]!
    var previousMax_HZ: Float = 0
    var sensitivity: Float = -35
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar()
        audioRecognizer = ARAudioRecognizer()
        startTimer()
        setUpOnMainView()
        setUpSoundLabel()
        setUpIndicator()
        setUpProgressBlock()
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
        
        let optionButton: UIBarButtonItem = UIBarButtonItem()
        optionButton.title = "Sensitivity"
        optionButton.tintColor = UIColor.whiteColor()
        optionButton.target = self
        optionButton.action = "pressSensitivityButton:"
        self.navigationItem.rightBarButtonItem = optionButton
    }
    
    func pressSensitivityButton(sender: UIButton) {
        let myActionSheet = UIActionSheet()
        myActionSheet.title = "Tuner Sensivities"
        myActionSheet.addButtonWithTitle("High")
        myActionSheet.addButtonWithTitle("Middle")
        myActionSheet.addButtonWithTitle("Low")
        myActionSheet.addButtonWithTitle("Cancel")
        myActionSheet.cancelButtonIndex = 3
        myActionSheet.delegate = self
        myActionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            sensitivity = -35
        } else if buttonIndex == 1 {
            sensitivity = -30
        } else {
            sensitivity = -25
        }
    }
    
    func countSimilarNumber(numberArray: [Float]) -> Float! {
        var mostArrayCount: Int = 0
        var averageNumber: Float = 0
        for var i = 0; i < numberArray.count; i++ {
            var tempArray: [Float] = [Float]()
            tempArray.append(numberArray[i])
            for var j = i + 1; j < numberArray.count; j++ {
                if numberArray[j] < numberArray[i] * 1.02 && numberArray[j] > numberArray[i] * 1.02 {
                    tempArray.append(numberArray[j])
                }
            }
            if mostArrayCount < tempArray.count {
                mostArrayCount = tempArray.count
                averageNumber = 0
                for item in tempArray {
                    averageNumber += item
                }
            }
        }
        return averageNumber / Float(mostArrayCount)
    }
    
//    func handleTimer(sender: NSTimer) {
//        infoLabel.text = "\(TunerManager.getMaxHZ()) HZ"
//        if audioRecognizer.getPower() > sensitivity && count < 3 {
//            count++
//            self.soundPowerLabel.text = "Detected the sound"
//            self.soundPowerLabel.textColor = UIColor.greenColor()
//            
//            HZArray.append(TunerManager.getMaxHZ())
//            if HZArray.count > 5 {
//                HZArray.removeAll()
//            }
//            if let max_HZ = countSimilarNumber(HZArray) {
//                if max_HZ != previousMax_HZ {
//                    previousMax_HZ = max_HZ
//                    count = 0
//                    TunerFunction.sharedInstance.getMax_HZ(max_HZ)
//                    let result = TunerFunction.sharedInstance.checkTheHZRange()
//                    print("\(result.0), \(result.1), \(result.2), \(result.3), \(result.4), \(result.5), \(result.6), \(result.7)")
//
//                    UIView.animateWithDuration(0.5, animations: {
//                        animate in
//                        if let temp = result.3 {
//                            self.minLabel.text = temp
//                        }
//                        if let temp = result.4 {
//                            self.midLabel.text = temp
//                        }
//                        if let temp = result.5 {
//                            self.maxLabel.text = temp
//                        }
//                    })
//          
//                    moveIndicator(result.0, midHZ: result.1, maxHZ: result.2, detectedHZ: max_HZ)
//                    
//                    infoLabel.textColor = UIColor.greenColor()
//                    UIView.animateWithDuration(0.5, animations: {
//                            animate in
//                        self.count = 0
//                        self.minLabel.alpha = 1
//                        self.midLabel.alpha = 1
//                        self.maxLabel.alpha = 1
//                    })
//                }
//            }
//        } else {
//            count++
//            if count > 3 {
//                UIView.animateWithDuration(0.5, animations: {
//                    animate in
//                    self.minLabel.alpha = 0.3
//                    self.midLabel.alpha = 0.3
//                    self.maxLabel.alpha = 0.3
//                    }, completion: {
//                        complete in
//                        self.HZArray.removeAll()
//                        self.previousMax_HZ = 0
//                        self.count = 0
//                })
//                self.soundPowerLabel.text = "Please pick one string"
//                self.soundPowerLabel.textColor = UIColor.redColor()
//                self.infoLabel.textColor = UIColor.redColor()
//                for item in progressBlockArray {
//                    item.backgroundColor = UIColor.whiteColor()
//                }
//            }
//        }
//    }
    
        func handleTimer(sender: NSTimer) {
            infoLabel.text = "\(TunerManager.getMaxHZ()) HZ"
            if audioRecognizer.getPower() > sensitivity {
                HZArray.append(TunerManager.getMaxHZ())
                if TunerManager.getMaxHZ() != HZArray.maxElement() {
                    TunerFunction.sharedInstance.getMax_HZ(TunerManager.getMaxHZ())
                    let result = TunerFunction.sharedInstance.checkTheHZRange()
                    print("\(result.0), \(result.1), \(result.2), \(result.3), \(result.4), \(result.5), \(result.6), \(result.7)")
                    if result.1 != previousMax_HZ {
                        previousMax_HZ = result.1
                        HZArray.removeAll()
                    }
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
        
                    moveIndicator(result.0, midHZ: result.1, maxHZ: result.2, detectedHZ: TunerManager.getMaxHZ())
        
                    infoLabel.textColor = UIColor.greenColor()
                    UIView.animateWithDuration(0.5, animations: {
                                    animate in
                                self.count = 0
                                self.minLabel.alpha = 1
                                self.midLabel.alpha = 1
                                self.maxLabel.alpha = 1
                    })
                }
            } else {
                UIView.animateWithDuration(0.5, animations: {
                    animate in
                    self.minLabel.alpha = 0.3
                    self.midLabel.alpha = 0.3
                    self.maxLabel.alpha = 0.3
                    }, completion: {
                        complete in
                        self.HZArray.removeAll()
                        self.previousMax_HZ = 0
                        self.count = 0
                })
                self.soundPowerLabel.text = "Please pick one string"
                self.soundPowerLabel.textColor = UIColor.redColor()
                self.infoLabel.textColor = UIColor.redColor()
                for item in progressBlockArray {
                    item.backgroundColor = UIColor.whiteColor()
                }
            }
        }

    
    func moveIndicator(minHZ: Float, midHZ: Float, maxHZ: Float, detectedHZ: Float) {
        let labelWidth: CGFloat = self.view.frame.size.width / 7
        
        let tempView: UIView = UIView()
        tempView.frame = CGRectMake(labelWidth, self.view.centerY / 2 + labelWidth / 2, self.view.frame.size.width - 2 * labelWidth, 20)
        tempView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(tempView)
        
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
        let targetPosition: CGFloat = self.view.centerX + 2 * labelWidth * CGFloat(position) - 1.5 * labelWidth
        let number: Int = Int(targetPosition) / 4
        var delay:NSTimeInterval = -0.05
        let colorValue: CGFloat = 255 / CGFloat(progressBlockArray.count)
        for var i = 0; i <= number; i++ {
            delay = delay+0.05
            UIView.animateWithDuration(0.2, delay: delay, options: .CurveEaseInOut, animations: {
                animate in
                self.progressBlockArray[i].backgroundColor = UIColor(red: colorValue * CGFloat(i), green: 0, blue: 0, alpha: 1)
                }, completion: nil)
        }
    }
    
    
    
    func setUpProgressBlock() {
        progressBlockArray = [UIView]()
        let labelWidth: CGFloat = self.view.frame.size.width / 7
        progressBlockView = UIView()
        progressBlockView.frame = CGRectMake(labelWidth * 1.5, self.view.centerY / 2 + labelWidth / 2, self.view.frame.size.width - 2 * labelWidth, 20)
        progressBlockView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(progressBlockView)
        
        let number: Int = Int(self.view.frame.size.width - 3 * labelWidth) / 4
        
        for var i = 0; i < number; i++ {
            let tempView: UIView = UIView()
            tempView.frame = CGRectMake(0 + CGFloat(i) * 4, 0, 2, 30)
            tempView.backgroundColor = UIColor.whiteColor()
            tempView.layer.borderColor = UIColor.redColor().CGColor
            tempView.layer.borderWidth = 0.25
            progressBlockArray.append(tempView)
            progressBlockView.addSubview(tempView)
            
            
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
        infoLabel = UILabel()
        infoLabel.frame = CGRectMake(0, self.view.centerY / 2 + labelWidth / 2 + 50, self.view.frame.size.width, 16)
        infoLabel.textAlignment = .Center
        infoLabel.text = "\(TunerManager.getMaxHZ()) HZ"
        infoLabel.textColor = UIColor.redColor()
        self.view.addSubview(infoLabel)
    }
}
