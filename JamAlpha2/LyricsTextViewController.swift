//
//  ViewController.swift
//  lyricsEditorV2
//
//  Created by Jun Zhou on 9/15/15.
//  Copyright (c) 2015 TwistJam. All rights reserved.
//

import UIKit
import MediaPlayer

class LyricsTextViewController: UIViewController {

    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var theSong: MPMediaItem!
    var allLocalSong: [MPMediaItem] = [MPMediaItem]()
    
    var lyricsTextView: UITextView = UITextView()
    
    var textViewBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    var lyricsReorganizedArray: [String] = ["1~~~~~~~~~", "2~~~~~~~~~" ,"3~~~~~~~~~", "4~~~~~~~~~", "5~~~~~~~~~", "6~~~~~~~~~" ,"7~~~~~~~~~", "8~~~~~~~~~", "9~~~~~~~~~", "10~~~~~~~~~", "11~~~~~~~~~", "12~~~~~~~~~", "13~~~~~~~~~", "14~~~~~~~~~"]
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.viewWidth = self.view.frame.width
        self.viewHeight = self.view.frame.height
        addObjectsOnMainView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
    }
    
    func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool) {
        let userInfo = notification.userInfo!
        //let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        var originDelta: CGFloat = CGFloat()
        if showsKeyboard == true {
            originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        } else {
            originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        }
        self.lyricsTextView.frame = CGRectMake(0, 3.5 / 31 * self.viewHeight, self.viewWidth, self.lyricsTextView.frame.height + originDelta)
        self.lyricsTextView.layer.opacity = 0.1
        UIView.animateWithDuration(1.4, animations: {
            self.lyricsTextView.layer.opacity = 1
            
        })
    }
    
    func addObjectsOnMainView() {
        let backgroundImageWidth: CGFloat = self.viewHeight - 3.5 / 31 * self.viewHeight
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(self.viewWidth / 2 - backgroundImageWidth / 2, 3.5 / 31 * self.viewHeight, backgroundImageWidth, backgroundImageWidth)
        let size: CGSize = CGSizeMake(self.viewWidth, self.viewHeight)
        backgroundImage.image = theSong.artwork!.imageWithSize(size)
        let blurredImage:UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        self.view.addSubview(backgroundImage)
        
        
        self.addTitleView()
        //self.addMenuView()
        self.addLyricsTextView()
    }
    
    func addTitleView() {
        let titleView: UIView = UIView()
        titleView.frame = CGRectMake(0, 0, self.viewWidth, 3.5 / 31 * self.viewHeight)
        titleView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        self.view.addSubview(titleView)
        
        let buttonWidth: CGFloat = 2.5 / 20 * self.viewWidth
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        backButton.setTitle("B", forState: UIControlState.Normal)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.layer.borderWidth = 1
        titleView.addSubview(backButton)
        
        let doneButton: UIButton = UIButton()
        doneButton.frame = CGRectMake(17.5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        doneButton.setTitle("D", forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.layer.borderWidth = 1
        titleView.addSubview(doneButton)
        
        let titleLabel: UILabel = UILabel()
        titleLabel.frame = CGRectMake(5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, 10 / 20 * self.viewWidth, 2 / 31 * self.viewHeight)
        titleLabel.text = "lyrics editor"
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.layer.borderWidth = 1
        titleLabel.textColor = UIColor.whiteColor()
        titleView.addSubview(titleLabel)
        
        let deleteAllButton: UIButton = UIButton()
        deleteAllButton.frame = CGRectMake(2.5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        deleteAllButton.setTitle("D", forState: UIControlState.Normal)
        deleteAllButton.addTarget(self, action: "pressDeleteAllButton:", forControlEvents: UIControlEvents.TouchUpInside)
        deleteAllButton.layer.borderWidth = 1
        titleView.addSubview(deleteAllButton)
        
        let reorganizeButton: UIButton = UIButton()
        reorganizeButton.frame = CGRectMake(15 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        reorganizeButton.setTitle("R", forState: UIControlState.Normal)
        reorganizeButton.addTarget(self, action: "pressReorganizeButton:", forControlEvents: UIControlEvents.TouchUpInside)
        reorganizeButton.layer.borderWidth = 1
        titleView.addSubview(reorganizeButton)
        
        let tapOnTitleView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnTitleView.addTarget(self, action: "tapOnTitleView:")
        titleView.addGestureRecognizer(tapOnTitleView)
    }
    
    func tapOnTitleView(sender: UITapGestureRecognizer) {
        self.lyricsTextView.resignFirstResponder()
    }
    
//    func addMenuView() {
//        var menuView: UIView = UIView()
//        menuView.frame = CGRectMake(0, 29 / 31 * self.viewHeight, self.viewWidth, 2 / 31 * self.viewHeight)
//        menuView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
//        self.view.addSubview(menuView)
//        
//        var deleteAllButton: UIButton = UIButton()
//        deleteAllButton.frame = CGRectMake(2 / 20 * self.viewWidth, 0.25 / 31 * self.viewHeight, 6 / 20 * self.viewWidth, 1.5 / 31 * self.viewHeight)
//        deleteAllButton.setTitle("Delete All", forState: UIControlState.Normal)
//        deleteAllButton.addTarget(self, action: "pressDeleteAllButton:", forControlEvents: UIControlEvents.TouchUpInside)
//        deleteAllButton.layer.borderWidth = 1
//        menuView.addSubview(deleteAllButton)
//        
//        var reorganizeButton: UIButton = UIButton()
//        reorganizeButton.frame = CGRectMake(12 / 20 * self.viewWidth, 0.25 / 31 * self.viewHeight, 6 / 20 * self.viewWidth, 1.5 / 31 * self.viewHeight)
//        reorganizeButton.setTitle("Reorganize", forState: UIControlState.Normal)
//        reorganizeButton.addTarget(self, action: "pressReorganizeButton:", forControlEvents: UIControlEvents.TouchUpInside)
//        reorganizeButton.layer.borderWidth = 1
//        menuView.addSubview(reorganizeButton)
//        
//    }
    
    func addLyricsTextView() {
        self.lyricsTextView.frame = CGRectMake(0, 3.5 / 31 * self.viewHeight, self.viewWidth, 27.5 / 31 * self.viewHeight)
        self.lyricsTextView.backgroundColor = UIColor.clearColor()
        self.lyricsTextView.textAlignment = NSTextAlignment.Left
        self.lyricsTextView.font = UIFont.systemFontOfSize(18)
        self.lyricsTextView.textColor = UIColor.whiteColor()
        self.lyricsTextView.text = "When your legs don't work like they used to before\nAnd I can't sweep you off of your feet\nWill your mouth still remember the taste of my love?\nWill your eyes still smile from your cheeks?\nAnd, darling, I will be loving you 'til we're 70\nAnd, baby, my heart could still fall as hard at 23\nAnd I'm thinking 'bout how people fall in love in mysterious ways\nMaybe just the touch of a hand\nWell, me - I fall in love with you every single day\nAnd I just wanna tell you I am\nSo honey now\nTake me into your loving arms\nKiss me under the light of a thousand stars\nPlace your head on my beating heart\nI'm thinking out loud\nMaybe we found love right where we are\nWhen my hair's all but gone and my memory fades\nAnd the crowds don't remember my name\nWhen my hands don't play the strings the same way (mmm...)\nI know you will still love me the same\n'Cause honey your soul could never grow old, it's evergreen\nAnd, baby, your smile's forever in my mind and memory\nI'm thinking 'bout how people fall in love in mysterious ways\nMaybe it's all part of a plan\nWell, I'll just keep on making the same mistakes\nHoping that you'll understand\nThat, baby, now\nTake me into your loving arms\nKiss me under the light of a thousand stars\nPlace your head on my beating heart\nThinking out loud\nMaybe we found love right where we are (oh ohh)\nLa la la la la la la la lo-ud\nSo, baby, now\nTake me into your loving arms\nKiss me under the light of a thousand stars\nOh, darling, place your head on my beating heart\nI'm thinking out loud\nBut maybe we found love right where we are\nOh, baby, we found love right where we are\nAnd we found love right where we are"

        self.view.addSubview(self.lyricsTextView)
        
    }
    
    func pressBackButton(sender: UIButton) {
        print("back button")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pressDoneButton(sender: UIButton) {
        print("done button")
        //self.lyricsReorganizedArray = ["When your legs don't work like they used to before And I can not sweep you off of your feet", "Will your mouth still remember the taste of my love?", "And I can not sweep you off of your feet", "Will your mouth still remember the taste of my love?", "Will your eyes still smile from your cheeks?", "And, darling, I will be loving you 'til we're 70", "And, baby, my heart could still fall as hard at 23", "And I'm thinking 'bout how people fall in love in mysterious ways", "Maybe just the touch of a hand", "Well, me - I fall in love with you every single day", "And I just wanna tell you I am", "So honey now", "Take me into your loving arms", "Kiss me under the light of a thousand stars", "Place your head on my beating heart", "I'm thinking out loud", "Maybe we found love right where we are", "When my hair's all but gone and my memory fades", "And the crowds don't remember my name", "When my hands don't play the strings the same way (mmm...)", "I know you will still love me the same", "'Cause honey your soul could never grow old, it's evergreen", "And, baby, your smile's forever in my mind and memory", "I'm thinking 'bout how people fall in love in mysterious ways", "Maybe it's all part of a plan", "Well, I'll just keep on making the same mistakes", "Hoping that you'll understand", "That, baby, now", "Take me into your loving arms", "Kiss me under the light of a thousand stars", "Place your head on my beating heart", "Thinking out loud", "Maybe we found love right where we are (oh ohh)", "La la la la la la la la lo-ud", "So, baby, now", "Take me into your loving arms", "Kiss me under the light of a thousand stars", "Oh, darling, place your head on my beating heart", "I'm thinking out loud", "But maybe we found love right where we are", "Oh, baby, we found love right where we are", "And we found love right where we are"]
        self.lyricsReorganizedArray = formatLyrics(self.lyricsTextView.text)
        let lyricsSyncViewController = storyboard!.instantiateViewControllerWithIdentifier("lyricssyncviewcontroller") as! LyricsSyncViewController
        
        if lyricsTextView.text == "" {
            lyricsSyncViewController.lyricsFromTextView = "You don't have any lyrics"
        }else {
            lyricsSyncViewController.lyricsFromTextView = lyricsTextView.text
            lyricsSyncViewController.lyricsOrganizedArray = self.lyricsReorganizedArray
        }
        
        lyricsSyncViewController.theSong  = self.theSong
        
        self.presentViewController(lyricsSyncViewController, animated: true, completion: nil)
    }
    
    func formatLyrics(lyric: String) -> [String]{
        let maxCharPerLine = 80
        let lineArray: [String] = lyric.characters.split{$0 == "\n"}.map { String($0) }
        let letterOrnumber = NSCharacterSet.alphanumericCharacterSet()
        var result: [String] = [String]()
        for j in 0...(lineArray.count-1) {
            if lineArray[j].characters.count == 0 {
                continue
            }
            let strArray: [String] = lineArray[j].characters.split{$0 == " "}.map { String($0) }
            var str: String = ""
            for i in 0...(strArray.count-1) {
                var letter = strArray[i].unicodeScalars
                //Delete the puncuation at the start of a word
                while letter.count > 0 && !letterOrnumber.longCharacterIsMember(letter[letter.startIndex.advancedBy(0)].value){
                    letter.removeAtIndex(letter.startIndex.advancedBy(0))
                }
                if letter.count == 0{
                    continue
                }
                //check whether the last char is a puncuation
                if !letterOrnumber.longCharacterIsMember(letter[letter.startIndex.advancedBy(letter.count-1)].value) {
                    while letter.count > 0 && !letterOrnumber.longCharacterIsMember(letter[letter.startIndex.advancedBy(letter.count-1)].value){
                        letter.removeAtIndex(letter.startIndex.advancedBy(letter.count-1))
                    }
                    if letter.count > 0 {
                        let newstr = (str.characters.count == 0) ?  "\(letter)" : (str + " \(letter)")
                        
                        if newstr.characters.count > maxCharPerLine{
                            if str.characters.count > 0 {
                                result.append(str)
                            }
                            result.append("\(letter)")
                        }
                        else {
                            result.append(newstr)
                        }
                    }
                    str = ""
                }
                else
                {
                    let newstr = (str.characters.count == 0) ?  "\(letter)" : (str + " \(letter)")
                    if newstr.characters.count > maxCharPerLine {
                        if str.characters.count > 0 {
                            result.append(str)
                        }
                        str = "\(letter)"
                    }
                    else {
                        str = newstr
                    }
                }
                if i == (strArray.count-1) && str.characters.count > 0{
                    result.append(str)
                }
            }
        }
        return result
    }

    
    func pressDeleteAllButton(sender: UIButton) {
        print("delete all")
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all lyrics?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.lyricsTextView.text = "Here!"
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pressReorganizeButton(sender: UIButton) {
        print("reorganize")
        self.lyricsReorganizedArray = formatLyrics(self.lyricsTextView.text)
        self.lyricsTextView.text = array2String(self.lyricsReorganizedArray)
    }
    
    func array2String(sender: [String]) -> String {
        var tempString: String = String()
        for var index = 0; index < self.lyricsReorganizedArray.count; index++ {
            tempString += self.lyricsReorganizedArray[index]
            tempString += "\n"
        }
        return tempString
    }
    

}

