//
//  ViewController.swift
//  addView
//
//  Created by Jun Zhou on 6/30/15.
//  Copyright (c) 2015 Jun Zhou. All rights reserved.
//

import UIKit
import AVFoundation

class Chord2 {
    var chord_Name : String = String()
    var chord_Value = [String](count: 6, repeatedValue: " ")
}

class songChord {
    var time: Float = Float()
    var chord: Chord2 = Chord2()
}

class EditTabsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var audioPlayer = AVAudioPlayer()
    
    //first view
    var playButton: UIButton = UIButton()
    var bar: UISlider = UISlider()
    var dymaticLabel: UILabel = UILabel()
    var previousButton: UIButton = UIButton()
    var signLabel = [UILabel]()
    var timeLabel: UILabel = UILabel()
    var songC = [songChord]()
    
    //second view
    var plusButton: UIButton = UIButton()
    var secondView: UIControl = UIControl()
    var thirdView: UIControl = UIControl()
    var okButton: UIButton = UIButton()
    var chordName: UITextField = UITextField()
    var chordPicker: UIPickerView = UIPickerView()
    var cancelButton: UIButton = UIButton()
    
    //third view
    var chordSign = [UIButton]()
    var chord_temp = [Chord2]()
    var chord_Label: UILabel = UILabel()
    var moveupCount = 0
    var count = 0
    var backgroundColor: UIColor = UIColor.whiteColor()
    var textColor: UIColor = UIColor(red: 0.5607, green: 0.2126, blue: 0.2266, alpha: 1.0)
    
    //exit button
    var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
        //play sound
        
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("彩虹", ofType: "mp3")!)
        println(alertSound)
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        bar.maximumValue = Float(audioPlayer.duration)
        audioPlayer.prepareToPlay()
        
        
        //screen size
        var screenSize: CGRect = UIScreen.mainScreen().bounds
        var width = screenSize.width
        var height = screenSize.height
        
        
        //time label
        timeLabel.frame = CGRectMake(width * 0.4, height * 0.3, 80, 30)
        timeLabel.text = String(format: "%", audioPlayer.duration)
        //timeLabel.text = "time"
        timeLabel.textColor = UIColor.blueColor()
        timeLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(timeLabel)
        
        
        //play button
        playButton.frame = CGRectMake(width * 0.2, height * 0.25, 60, 30)
        playButton.setTitle("Play", forState: UIControlState.Normal)
        playButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        playButton.addTarget(self, action: "pressPlayMusic:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(playButton)
        
        //previous button
        previousButton.frame = CGRectMake(width * 0.6, height * 0.25, 80, 30)
        previousButton.setTitle("Previous", forState: UIControlState.Normal)
        previousButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        previousButton.addTarget(self, action: "pressPreviousChord:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(previousButton)
        
        
        //first view
        self.view.backgroundColor = backgroundColor
        
        
        //label on first view
        
        dymaticLabel.frame = CGRectMake(0, height * 0.05, width, 30)
        dymaticLabel.backgroundColor = backgroundColor
        dymaticLabel.textColor = textColor
        dymaticLabel.textAlignment = NSTextAlignment.Center
        dymaticLabel.text = "Twist Jam"
        self.view.addSubview(dymaticLabel)
        //button on first view
        
        plusButton.frame = CGRectMake(width * 0.05, height * 0.90, 60, 30)
        plusButton.setTitle("Plus", forState: UIControlState.Normal)
        plusButton.setTitleColor(textColor, forState: UIControlState.Normal)
        plusButton.addTarget(self, action: "pressplusButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(plusButton)
        //second view
        
        secondView.frame = CGRectMake(0, 0, width, height)
        secondView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
        //self.view.addSubview(secondView)
        //third view
        
        thirdView.frame = CGRectMake(width * 0.05, height * 0.3, width * 0.9, height * 0.4)
        thirdView.layer.cornerRadius = 25
        //thirdView.layer.borderWidth = 1
        thirdView.backgroundColor = backgroundColor
        secondView.addSubview(thirdView)
        //button on third view
        
        okButton.frame = CGRectMake(width * 0.3, height * 0.34, 30, 30)
        okButton.backgroundColor = backgroundColor
        okButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        okButton.setTitle("OK", forState: UIControlState.Normal)
        okButton.addTarget(self, action: "pressokButton:", forControlEvents: UIControlEvents.TouchUpInside)
        thirdView.addSubview(okButton)
        
        cancelButton.frame = CGRectMake(width * 0.5, height * 0.34, 60, 30)
        cancelButton.backgroundColor = backgroundColor
        cancelButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "presscancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
        thirdView.addSubview(cancelButton)
        //textfield on third view
        
        chordName.frame = CGRectMake(width * 0.05, height * 0.15, 50, 30)
        chordName.layer.cornerRadius = 5
        chordName.layer.borderWidth = 1
        
        //chordName.backgroundColor = UIColor.grayColor()
        thirdView.addSubview(chordName)
        
        //picker on the third view
        chordPicker.frame = CGRectMake(width * 0.25, height * 0.03, width * 0.6, 80)
        chordPicker.backgroundColor = backgroundColor
        chordPicker.layer.cornerRadius = 20
        chordPicker.layer.borderWidth = 1
        chordPicker.dataSource = self
        chordPicker.delegate = self
        
        //touch view hidden keyboard
        thirdView.addTarget(self, action: "backgroundTap:", forControlEvents: UIControlEvents.TouchDown)
        secondView.addTarget(self, action: "backgroundTap:", forControlEvents: UIControlEvents.TouchDown)
        chordName.addTarget(self, action: "textFieldDoneEditing:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
        
        //self.chordName.autocapitalizationType = UITextAutocapitalizationType
        
        //slider for play music
        bar.frame = CGRectMake(width * 0.05, height * 0.2, width * 0.9, 5)
        bar.backgroundColor = UIColor.blueColor()
        bar.layer.cornerRadius = 5
        bar.addTarget(self, action: "changeAudioTime:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(bar)
        
        thirdView.addSubview(chordPicker)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        //var timer2 = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update2"), userInfo: nil, repeats: true)
        
        exitButton = UIButton(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        exitButton.setTitle("Back", forState: UIControlState.Normal)
        exitButton.backgroundColor = UIColor.blackColor()
        self.view.addSubview(exitButton)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func exit(button:UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update2() {
        timeLabel.text = String(format: "%", audioPlayer.currentTime)
    }
    
    func pressPlayMusic(sender: UIButton) {
        
        if audioPlayer.playing == false {
            audioPlayer.play()
            playButton.setTitle("Pause", forState: UIControlState.Normal)
            println("press the play button")
        } else {
            audioPlayer.stop()
            playButton.setTitle("Play", forState: UIControlState.Normal)
            println("press the pause button")
        }
        
        //playButton.setTitle("Pause", forState: UIControlState.Normal)
        //playButton.addTarget(self, action: "pauseMusic:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func pressPreviousChord(sender: UIButton) {
        println("press the previous button")
        if songC.count > 0 {
            songC.removeLast()
            audioPlayer.stop()
            audioPlayer.currentTime = NSTimeInterval(songC[songC.count - 1].time)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            signLabel[signLabel.count - 1].removeFromSuperview()
            signLabel.removeLast()
        }
        
    }
    
    func pressSignButton(sender: UIButton) {
        //screen size
        var screenSize: CGRect = UIScreen.mainScreen().bounds
        var width = screenSize.width
        var height = screenSize.height
        
        var ct = Float(audioPlayer.currentTime)
        var d = Float(audioPlayer.duration)
        
        var tempLabel: UILabel = UILabel()
        
        
        //barLength = Float(width) * 0.9
        var barLength = Float(bar.frame.width)
        var startPoint = bar.frame.origin.x
        
        var currentPosition = Float(startPoint) + (bar.value / bar.maximumValue) * barLength * 0.9
        tempLabel.frame = CGRectMake(CGFloat(currentPosition), height * 0.15, 30, 30)
        tempLabel.textColor = UIColor.blueColor()
        tempLabel.text = sender.titleLabel?.text
        tempLabel.textAlignment = NSTextAlignment.Center
        
        var tempchord: songChord = songChord()
        
        var n = chord_temp.count - 1
        for index in 0...n {
            if chord_temp[index].chord_Name == tempLabel.text! {
                tempchord.chord = chord_temp[index]
            }
        }
        
        tempchord.time = ct
        songC.append(tempchord)
        
        signLabel.append(tempLabel)
        self.view.addSubview(tempLabel)
    }
    
    func changeAudioTime(sender: UISlider) {
        if audioPlayer.playing == true {
            audioPlayer.stop()
            audioPlayer.currentTime = NSTimeInterval(bar.value)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } else {
            audioPlayer.currentTime = NSTimeInterval(bar.value)
        }
    }
    
    
    
    //    func pauseMusic() {
    //        audioPlayer.pause()
    //        playButton.setTitle("Play", forState: UIControlState.Normal)
    //        playButton.addTarget(self, action:"playMusic:", forControlEvents: UIControlEvents.TouchUpInside)
    //    }
    
    func update() {
        bar.value = Float(audioPlayer.currentTime)
        
    }
    
    func presscancelButton() {
        removeAnimate()
    }
    
    
    func pressokButton(sender: UIButton!) {
        //        var alertView: UIAlertView = UIAlertView()
        //        alertView.addButtonWithTitle("OK")
        //        alertView.title = "Title"
        //        alertView.message = "messgae"
        //        alertView.show()
        var newChord: Chord2 = Chord2()
        newChord.chord_Name = chordName.text
        for index in 0 ... 5 {
            newChord.chord_Value[index] = chordTypes[chordPicker.selectedRowInComponent(index)]
        }
        chord_temp.append(newChord)
        arrangeSign()
        removeAnimate()
    }
    
    func arrangeSign() {
        var screenSize: CGRect = UIScreen.mainScreen().bounds
        var width = screenSize.width
        var height = screenSize.height
        var x = Int(width * 0.025)
        var y = Int(height * 0.85)
        var button_size = Int(width * 0.2)
        var button_place = Int(width * 0.25)
        var n = chord_temp.count
        var row = Int(n / 4)
        var line = n % 4
        
        if n % 4 == 0 {
            row--
        }
        if line == 0 {
            line = 4
        }
        
        var newSign: UIButton = UIButton()
        newSign.frame = CGRectMake(CGFloat(x + button_place * (line - 1)), CGFloat(y - row * button_place), CGFloat(button_size), CGFloat(button_size))
        
        var name = chord_temp[n - 1].chord_Name
        newSign.setTitle("\(name)", forState: UIControlState.Normal)
        newSign.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        newSign.backgroundColor = backgroundColor
        
        newSign.frame.size = CGSize(width: button_size, height: button_size)
        newSign.layer.cornerRadius = 0.5 * newSign.bounds.size.width
        newSign.layer.borderWidth = 1
        
        newSign.addTarget(self, action: "changeButtonColor:", forControlEvents: UIControlEvents.TouchDown)
        newSign.addTarget(self, action: "rechangeButtonColor:", forControlEvents: UIControlEvents.TouchUpInside)
        newSign.addTarget(self, action: "pressSignButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        newSign.alpha = 0
        chordSign.append(newSign)
        self.view.addSubview(newSign)
        if n % 4 == 1 {
            plusButtonmoveup()
        }
        //        var i = row
        //        var j = line
        //        for i in 0 ... row {
        //            var temp = 4
        //            if i == row {
        //                temp = line
        //            }
        //            for j in 0 ..< temp {
        //                var newSign: UIButton = UIButton()
        //                newSign.frame = CGRectMake(CGFloat(x + 40 * j), CGFloat(y - i * 40), 30, 30 )
        //                var name = chord_temp[4 * i + j].chord_Name
        //                newSign.setTitle("\(name)", forState: UIControlState.Normal)
        //                newSign.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        //                newSign.alpha = 0
        //                chordSign.append(newSign)
        //                self.view.addSubview(newSign)
        //            }
        //        }
        for i in 0 ..< n {
            UIView.animateWithDuration(0.5, animations: {
                self.chordSign[i].alpha = 1
            })
        }
    }
    
    func changeButtonColor(sender: UIButton) {
        UIView.animateWithDuration(0.15, animations: {
            sender.backgroundColor = UIColor.blackColor()
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        })
    }
    
    func rechangeButtonColor(sender:UIButton) {
        UIView.animateWithDuration(0.15, animations: {
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        })
    }
    
    
    
    func plusButtonmoveup() {
        UIView.animateWithDuration(0.5, animations: {
            self.plusButton.center.y -= 80
        })
        //moveupCount++
        //plusButton.center.x -= 30
    }
    
    //    func addchordSign() {
    //        var newButton: UIButton = UIButton()
    //
    //    }
    
    
    func pressplusButton(sender: UIButton!) {
        //        var alertView: UIAlertView = UIAlertView()
        //        alertView.addButtonWithTitle("OK")
        //        alertView.title = "Title"
        //        alertView.message = "messgae"
        //        alertView.show()
        self.view.addSubview(secondView)
        showAnimate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private let chordTypes = ["-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
    
    func textFieldDuringEditing(sender: UITextField) {
        sender.text.uppercaseString
    }
    
    func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func backgroundTap(sender: UIControl) {
        chordName.resignFirstResponder()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 6
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chordTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return chordTypes[row]
    }
    
    
    
    func showAnimate() {
        self.secondView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.secondView.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.secondView.alpha = 1.0
            self.secondView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate() {
        self.secondView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        UIView.animateWithDuration(0.25, animations: {
            self.secondView.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.secondView.alpha = 0.0;
            //self.secondView.alpha = 0.0
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.secondView.removeFromSuperview()
                    //self.thirdView.removeFromSuperview()
                }
        });
        
    }
}
