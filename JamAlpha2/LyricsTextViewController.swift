//
//  ViewController.swift
//  lyricsEditorV2
//
//  Created by Jun Zhou on 9/15/15.
//  Copyright (c) 2015 TwistJam. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class LyricsTextViewController: UIViewController {
    
    var hiddenKeyboardView: UIView = UIView()
    
    var keyboardPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    var isDemoSong: Bool!
    var recoverMode: (MPMusicRepeatMode, MPMusicShuffleMode, NSTimeInterval)!
    
    var songViewController: SongViewController! //used to parse synced lyrics from LyricsSyncViewController
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var theSong: Findable!
    
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
        
        if !isDemoSong {
            self.recoverMode = MusicManager.sharedInstance.saveMusicPlayerState([theSong as! MPMediaItem])
        }
        
        addObjectsOnMainView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.lyricsTextView.removeKeyboardControl()
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
    
    var keyboardScreenBeginFrame: CGRect!
    var keyboardScreenEndFrame: CGRect!
    
    func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool) {
        let userInfo = notification.userInfo!
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        var originDelta: CGFloat = CGFloat()
        if showsKeyboard == true {
            originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
            self.hiddenKeyboardView.frame = CGRectMake(0, keyboardViewEndFrame.origin.y, self.viewWidth, 20)
            self.view.addSubview(self.hiddenKeyboardView)
            self.hiddenKeyboardView.hidden = false
        } else {
            originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
            self.hiddenKeyboardView.hidden = true
        }
        
        self.lyricsTextView.frame = CGRectMake(0, 3.5 / 31 * self.viewHeight, self.viewWidth, self.lyricsTextView.frame.height + originDelta)
        self.lyricsTextView.layer.opacity = 0.1
        UIView.animateWithDuration(1.4, animations: {
            self.lyricsTextView.layer.opacity = 1
            })
 
    }
    
    func keyboardPan(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(self.view)
        print(location.x)
        print(keyboardScreenEndFrame.size.height)
        if location.y > keyboardScreenEndFrame.size.height {
            self.lyricsTextView.resignFirstResponder()
        }
        
    }
    
    func hiddenKeyboardPanGesture(sender: UIPanGestureRecognizer) {
        let transform = sender.translationInView(self.hiddenKeyboardView)
        if transform.y > 5 {
            self.lyricsTextView.resignFirstResponder()
        }
    }
    
    func addObjectsOnMainView() {
        let hiddenKeyboardPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
        hiddenKeyboardPanGesture.addTarget(self, action: "hiddenKeyboardPanGesture")
        self.hiddenKeyboardView.addGestureRecognizer(hiddenKeyboardPanGesture)
        
        let backgroundImageWidth: CGFloat = self.viewHeight - 3.5 / 31 * self.viewHeight
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(self.viewWidth / 2 - backgroundImageWidth / 2, 3.5 / 31 * self.viewHeight, backgroundImageWidth, backgroundImageWidth)
        let size: CGSize = CGSizeMake(self.viewWidth, self.viewHeight)
        var image:UIImage!
        if let artwork = theSong!.getArtWork() {
            image = artwork.imageWithSize(size)
        } else {
            //TODO: add a placeholder album cover
            image = UIImage(named: "liwengbg")
        }
        backgroundImage.image = image
        let blurredImage: UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        self.view.addSubview(backgroundImage)
        self.addTitleView()
        self.addLyricsTextView()
    }
    
    func addTitleView() {
        let titleView: UIView = UIView()
        titleView.frame = CGRectMake(0, 0, self.viewWidth, 3.5 / 31 * self.viewHeight)
        titleView.backgroundColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
        self.view.addSubview(titleView)
        
        let buttonWidth: CGFloat = 2.0 / 20 * self.viewWidth
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0.5 / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        backButton.setTitle("B", forState: UIControlState.Normal)
        backButton.setImage(UIImage(named: "lyrics_back_circle"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(backButton)
        
        let doneButton: UIButton = UIButton()
        doneButton.frame = CGRectMake(17.5 / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        doneButton.setTitle("D", forState: UIControlState.Normal)
        doneButton.setImage(UIImage(named: "lyrics_done_circle"), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(doneButton)
        
        let titleLabel: UIImageView = UIImageView()
        titleLabel.frame = CGRectMake(6.5 / 20 * self.viewWidth, 1 / 31 * self.viewHeight, 7 / 20 * self.viewWidth, 2 / 31 * self.viewHeight)
        titleLabel.image = UIImage(named: "lyrics-editor")
        titleView.addSubview(titleLabel)
        
        let deleteAllButton: UIButton = UIButton()
        deleteAllButton.frame = CGRectMake(3 / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        deleteAllButton.setTitle("D", forState: UIControlState.Normal)
        deleteAllButton.setImage(UIImage(named: "lyrics_delete_circle"), forState: UIControlState.Normal)
        deleteAllButton.addTarget(self, action: "pressDeleteAllButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(deleteAllButton)
        
        let reorganizeButton: UIButton = UIButton()
        reorganizeButton.frame = CGRectMake(15 / 20 * self.viewWidth, 1.25 / 31 * self.viewHeight, buttonWidth, buttonWidth)
        reorganizeButton.setTitle("R", forState: UIControlState.Normal)
        reorganizeButton.setImage(UIImage(named: "lyrics_reorganize_circle"), forState: UIControlState.Normal)
        reorganizeButton.addTarget(self, action: "pressReorganizeButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(reorganizeButton)
        
        let tapOnTitleView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnTitleView.addTarget(self, action: "tapOnTitleView:")
        titleView.addGestureRecognizer(tapOnTitleView)
    }
    
    func tapOnTitleView(sender: UITapGestureRecognizer) {
        self.lyricsTextView.resignFirstResponder()
    }
    
    func addLyricsTextView() {
        self.lyricsTextView.frame = CGRectMake(0, 3.5 / 31 * self.viewHeight, self.viewWidth, 27.5 / 31 * self.viewHeight)
        self.lyricsTextView.contentSize = CGSizeMake(self.viewWidth, self.viewHeight)
        self.lyricsTextView.backgroundColor = UIColor.clearColor()
        self.lyricsTextView.textAlignment = .Left
        self.lyricsTextView.font = UIFont.systemFontOfSize(18)
        self.lyricsTextView.textColor = UIColor.whiteColor()
        self.lyricsTextView.tintColor = UIColor.mainPinkColor()
        self.lyricsTextView.delegate = self

        var lyric = Lyric()
        (lyric, _) =  CoreDataManager.getLyrics(theSong, fetchingLocalOnly: true)
        
        if lyric.lyric.count > 0 {
            var lyricsToDisplay = ""
            for line in lyric.lyric {
                lyricsToDisplay+="\(line.str)\n"
            }
            self.lyricsTextView.text = lyricsToDisplay
            self.lyricsTextView.textColor = UIColor.whiteColor()
        } else {
            self.lyricsTextView.text = "Put your lyrics here"
            self.lyricsTextView.textColor = UIColor.lightGrayColor()
        }
        
//        self.lyricsTextView.addKeyboardPanningWithActionHandler({
//            (keyboardFrameInView, opening, closing) -> Void in
//            if opening {
//                let tempFrame = CGRectMake(self.lyricsTextView.frame.origin.x, self.lyricsTextView.frame.origin.y, self.lyricsTextView.frame.size.width, keyboardFrameInView.size.height)
//                self.lyricsTextView.frame = tempFrame
//                self.lyricsTextView.contentSize = CGSizeMake(self.viewWidth, self.viewHeight)
//            } else if closing {
//                let tempFrame = CGRectMake(self.lyricsTextView.frame.origin.x, self.lyricsTextView.frame.origin.y, self.lyricsTextView.frame.size.width, 27.5 / 31 * self.viewHeight)
//                self.lyricsTextView.frame = tempFrame
//                self.lyricsTextView.contentSize = CGSizeMake(self.viewWidth, self.viewHeight)
//            }
//        })
        
        
        self.view.addSubview(self.lyricsTextView)
    }
    
    func pressBackButton(sender: UIButton) {
        tempLyricsTimeTuple.removeAll()
       
        self.dismissViewControllerAnimated(true, completion: {
            completed in
            if self.songViewController.isDemoSong {
                self.songViewController.avPlayer.play()
            } else {
                MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                self.songViewController.player.play()
            }
        })
    }
    
    func pressDoneButton(sender: UIButton) {
        print("done button")
        self.lyricsReorganizedArray = formatLyrics(self.lyricsTextView.text)
        let lyricsSyncViewController = storyboard!.instantiateViewControllerWithIdentifier("lyricssyncviewcontroller") as! LyricsSyncViewController
        
        lyricsSyncViewController.lyricsTextViewController = self
        if lyricsTextView.text == "" {
            lyricsSyncViewController.lyricsFromTextView = "You don't have any lyrics"
        }else {
            lyricsSyncViewController.lyricsFromTextView = lyricsTextView.text
            lyricsSyncViewController.lyricsOrganizedArray = self.lyricsReorganizedArray
        }
        lyricsSyncViewController.theSong  = self.theSong
        lyricsSyncViewController.recoverMode = self.recoverMode
        lyricsSyncViewController.isDemoSong = isDemoSong
        self.presentViewController(lyricsSyncViewController, animated: true, completion: nil)
    }

    func formatLyrics(lyric: String) -> [String]{
        let maxCharPerLine = 100
        let lineArray: [String] = lyric.characters.split{$0 == "\n"}.map { String($0) }
        let letterOrnumber = NSCharacterSet.alphanumericCharacterSet()
        var result: [String] = [String]()
        for var j = 0; j < lineArray.count; j++ {
            var str = lineArray[j].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).unicodeScalars
            if str.count == 0{
                continue
            }
            print(str)
            if(str.count <= maxCharPerLine)
            {
                result.append("\(str)")
            }
            else{
                var i: Int = maxCharPerLine
                while i > 0 && i < str.count
                {
                    if !letterOrnumber.longCharacterIsMember(str[str.startIndex.advancedBy(i-1)].value) && Character(str[str.startIndex.advancedBy(i)]) == " "
                    {
                        result.append(("\(str)" as NSString).substringToIndex(i))
                        str.removeRange(str.startIndex..<str.startIndex.advancedBy(i+1))
                        i = maxCharPerLine
                    }
                    else
                    {
                        i--
                    }
                }
            }
        }
        return result
    }
    
    func pressDeleteAllButton(sender: UIButton) {
        print("delete all")
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all lyrics?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.lyricsTextView.text = "Put lyrics here..."
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pressReorganizeButton(sender: UIButton) {
        print("reorganize")
        let alert = UIAlertController(title: "Reorganize Lyrics", message: "Are you sure you want to automatically organize the lyrics?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.lyricsReorganizedArray = self.formatLyrics(self.lyricsTextView.text)
            self.lyricsTextView.text = self.array2String(self.lyricsReorganizedArray)
            self.lyricsTextView.alpha = 0.1
            UIView.animateWithDuration(0.5, animations: {
                self.lyricsTextView.alpha = 1
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
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
extension LyricsTextViewController: UITextViewDelegate {
    //when user begins editing, if it has the placeholder(having a gray text color)
    //clear the text
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.lyricsTextView.contentSize = CGSizeMake(self.viewWidth, self.viewHeight)
    }
  
}

