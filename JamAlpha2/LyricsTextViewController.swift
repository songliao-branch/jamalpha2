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


class LyricsTextViewController: UIViewController, UIGestureRecognizerDelegate {
    var formattedLyrics: Bool = false
    var hiddenKeyboardView: UIView = UIView()
    let hiddenKeyboardPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    var isDemoSong = false
    var recoverMode: (MPMusicRepeatMode, MPMusicShuffleMode, NSTimeInterval)!
    var songViewController: SongViewController? //used to parse synced lyrics from LyricsSyncViewController
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    var theSong: Findable!
    var titleView = UIView()
    var lyricsTextView: UITextView = UITextView()
    var textViewBottomLayoutGuideConstraint: NSLayoutConstraint!
    var lyricsReorganizedArray: [String] = [String]()
    var timeArray: [Float]!
  
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
        viewWidth = view.frame.width
        viewHeight = view.frame.height
        if !isDemoSong {
            recoverMode = MusicManager.sharedInstance.saveMusicPlayerState([theSong as! MPMediaItem])
        }
        addBackground()
        addTitleView()
        addLyricsTextView()
        addGotoSafariButton()
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
        lyricsTextView.resignFirstResponder()
    }

    func handleKeyboardWillShowNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
    }

    
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
            hiddenKeyboardView.addGestureRecognizer(hiddenKeyboardPanGesture)
            lyricsTextView.addGestureRecognizer(hiddenKeyboardPanGesture)
            hiddenKeyboardView.frame = CGRectMake(0, keyboardViewEndFrame.origin.y - 5, viewWidth, 5)
            view.addSubview(hiddenKeyboardView)
            hiddenKeyboardView.hidden = false
        } else {
            originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
            hiddenKeyboardView.hidden = true
            hiddenKeyboardView.removeGestureRecognizer(hiddenKeyboardPanGesture)
            lyricsTextView.removeGestureRecognizer(hiddenKeyboardPanGesture)
        }
        lyricsTextView.frame = CGRectMake(0, 20 + 44, viewWidth, lyricsTextView.frame.height + originDelta)
        lyricsTextView.layer.opacity = 0.1
        UIView.animateWithDuration(1.4, animations: {
            self.lyricsTextView.layer.opacity = 1
            })
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func hiddenKeyboardPanGesture(sender: UIPanGestureRecognizer) {
        let location = sender.locationInView(hiddenKeyboardView)
        if location.y > 0 {
            lyricsTextView.resignFirstResponder()
        }
    }
    

    func addBackground() {
        hiddenKeyboardPanGesture.addTarget(self, action: "hiddenKeyboardPanGesture:")
        hiddenKeyboardPanGesture.delegate = self
        let backgroundImageWidth: CGFloat = viewHeight - 44 - 20
        let backgroundImage: UIImageView = UIImageView()
        backgroundImage.frame = CGRectMake(viewWidth / 2 - backgroundImageWidth / 2, 44 + 20, backgroundImageWidth, backgroundImageWidth)
        let size: CGSize = CGSizeMake(viewWidth, viewHeight)
        var image:UIImage!
        if let artwork = theSong!.getArtWork() {
            image = artwork.imageWithSize(size)
        } else {
            //TODO: add a placeholder album cover
            image = UIImage(named: "liwengbg")
        }
      if songViewController != nil {
        backgroundImage.image = image != nil ? image : songViewController!.backgroundImage
      } else {
         backgroundImage.image = UIImage(named: "liwengbg")
      }
        let blurredImage: UIImage = backgroundImage.image!.applyLightEffect()!
        backgroundImage.image = blurredImage
        view.addSubview(backgroundImage)
    }
    
    func addTitleView() {
        titleView.frame = CGRectMake(0, 0, viewWidth, 20 + 44)//status bar height and navigation bar height
        titleView.backgroundColor = UIColor.mainPinkColor()
        view.addSubview(titleView)
        
        let spacing: CGFloat = 10
        let buttonWidth: CGFloat = 50
        let backButton: UIButton = UIButton()
        backButton.frame = CGRectMake(0, 0, buttonWidth, buttonWidth)
        backButton.setImage(UIImage(named: "lyrics_back_circle"), forState: UIControlState.Normal)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.center.y = 20 + 44/2
        titleView.addSubview(backButton)
        
        let doneButton: UIButton = UIButton()
        doneButton.frame = CGRectMake(17 / 20 * viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        doneButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        doneButton.setImage(UIImage(named: "lyrics_done_circle"), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "pressDoneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(doneButton)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.systemFontOfSize(20)
        titleLabel.text = "Add lyrics"
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: titleView.center.x, y: 44/2 + 20)
        titleView.addSubview(titleLabel)
        
        let deleteAllButton: UIButton = UIButton()
        deleteAllButton.frame = CGRectMake(3 / 20 * viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        deleteAllButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        deleteAllButton.setImage(UIImage(named: "lyrics_delete_circle"), forState: UIControlState.Normal)
        deleteAllButton.addTarget(self, action: "pressDeleteAllButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(deleteAllButton)
        
        let reorganizeButton: UIButton = UIButton()
        reorganizeButton.frame = CGRectMake(14 / 20 * viewWidth, backButton.frame.origin.y, buttonWidth, buttonWidth)
        reorganizeButton.imageEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        reorganizeButton.setImage(UIImage(named: "lyrics_reorganize_circle"), forState: UIControlState.Normal)
        reorganizeButton.addTarget(self, action: "pressReorganizeButton:", forControlEvents: UIControlEvents.TouchUpInside)
        titleView.addSubview(reorganizeButton)
        
        let tapOnTitleView: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnTitleView.addTarget(self, action: "tapOnTitleView:")
        titleView.addGestureRecognizer(tapOnTitleView)
    }
    
    func tapOnTitleView(sender: UITapGestureRecognizer) {
        lyricsTextView.resignFirstResponder()
    }
    
    func addLyricsTextView() {
        lyricsTextView.frame = CGRect(x: 0, y: CGRectGetMaxY(titleView.frame), width: viewWidth, height: viewHeight - (20 + 44))
        lyricsTextView.backgroundColor = UIColor.clearColor()
        lyricsTextView.textAlignment = .Left
        lyricsTextView.font = UIFont.systemFontOfSize(18)
        lyricsTextView.textColor = UIColor.whiteColor()
        lyricsTextView.tintColor = UIColor.mainPinkColor()
        lyricsTextView.delegate = self
        var lyrics: Lyric = Lyric()
        (lyrics, _) = CoreDataManager.getLyrics(theSong, fetchingUsers: true)

        if lyrics.lyric.count > 0 {
            var lyricsToDisplay = ""
            for line in lyrics.lyric {
                lyricsToDisplay += line.str
                lyricsToDisplay += "\n"
            }
            lyricsTextView.text = lyricsToDisplay
            lyricsTextView.textColor = UIColor.whiteColor()
        } else {
            lyricsTextView.text = "Put your lyrics here"
            lyricsTextView.textColor = UIColor.lightGrayColor()
        }
        view.addSubview(lyricsTextView)
    }
    
    func addGotoSafariButton() {
        let safariButton: UIButton = UIButton()
        safariButton.frame = CGRectMake(view.frame.width - 60, view.frame.height - 60, 60, 60)
        safariButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 5, 5)
        safariButton.setImage(UIImage(named: "safari"), forState: .Normal)
        safariButton.addTarget(self, action: "pressSafariButton:", forControlEvents: .TouchUpInside)
        view.addSubview(safariButton)
        
        if isDemoSong {
            safariButton.removeFromSuperview()
        }
    }

    func pressSafariButton(sender: UIButton) {
        if !isDemoSong {
            let name:String = (theSong.getTitle() + " lyrics" + " " + theSong.getArtist()).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let url:NSURL = NSURL(string: "x-web-search://?\(name)")!
            if !UIApplication.sharedApplication().openURL(url) {
                print("cannot open")
            }
        }
    }

    func pressBackButton(sender: UIButton) {
//        tempLyricsTimeTuple.removeAll()
//        if let songVC = songViewController {
//            if songVC.singleLyricsTableView != nil {
//                songVC.updateSingleLyricsAlpha()
//                songVC.updateSingleLyricsPosition(false)
//            }
//        }
        dismissViewControllerAnimated(true, completion: {
            completed in
            if let songVC = self.songViewController {
                if songVC.isDemoSong {
                    songVC.avPlayer.play()
                } else {
                    MusicManager.sharedInstance.recoverMusicPlayerState(self.recoverMode, currentSong: self.theSong as! MPMediaItem)
                    songVC.player.play()
                }
            }
        })
    }
    
    func pressDoneButton(sender: UIButton) {
        if lyricsTextView.text.characters.count < 2 {
            showMessage("Please add some lyrics before syncing", message: "", actionTitle: "OK", completion: nil)
            return
        }
        lyricsReorganizedArray = formatLyrics(lyricsTextView.text)
        let lyricsSyncViewController = storyboard!.instantiateViewControllerWithIdentifier("lyricssyncviewcontroller") as! LyricsSyncViewController
        lyricsSyncViewController.lyricsTextViewController = self
        if lyricsTextView.text == "" {
            lyricsSyncViewController.lyricsFromTextView = "You don't have any lyrics"
            lyricsSyncViewController.lyricsOrganizedArray = ["You don't have any lyrics"]
        } else {
            lyricsSyncViewController.lyricsFromTextView = lyricsTextView.text
            lyricsSyncViewController.lyricsOrganizedArray = lyricsReorganizedArray
        }
        lyricsSyncViewController.theSong  = theSong
        lyricsSyncViewController.recoverMode = recoverMode
        lyricsSyncViewController.isDemoSong = isDemoSong
        lyricsSyncViewController.songViewController = songViewController
        presentViewController(lyricsSyncViewController, animated: true, completion: nil)
    }

    func formatLyrics(lyric: String) -> [String]{
        let maxCharPerLine = 100
        let lineArray: [String] = lyric.characters.split{$0 == "\n"}.map { String($0) }
        let letterOrnumber = NSCharacterSet.alphanumericCharacterSet()
        var result: [String] = [String]()
        for j in 0..<lineArray.count {
            var str = lineArray[j].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).unicodeScalars
            if str.count == 0{
                continue
            }
            if(str.count <= maxCharPerLine)
            {
                result.append("\(str)")
            } else {
                var i: Int = maxCharPerLine
                while i > 0 && i < str.count {
                    if !letterOrnumber.longCharacterIsMember(str[str.startIndex.advancedBy(i-1)].value) && Character(str[str.startIndex.advancedBy(i)]) == " " {
                        result.append(("\(str)" as NSString).substringToIndex(i))
                        str.removeRange(str.startIndex..<str.startIndex.advancedBy(i+1))
                        i = maxCharPerLine
                    } else {
                        i--
                    }
                }
            }
        }
        return result
    }
    
    func pressDeleteAllButton(sender: UIButton) {
        lyricsTextView.resignFirstResponder()
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all lyrics?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.lyricsTextView.text = "Put your lyrics here"
            self.lyricsTextView.textColor = UIColor.lightGrayColor()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pressReorganizeButton(sender: UIButton) {
        let alert = UIAlertController(title: "Reorganize Lyrics", message: "Are you sure you want to automatically organize the lyrics?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.lyricsReorganizedArray = self.formatLyrics(self.lyricsTextView.text)
            self.lyricsTextView.text = self.array2String(self.lyricsReorganizedArray)
            self.lyricsTextView.alpha = 0.1
            UIView.animateWithDuration(0.5, animations: {
                self.lyricsTextView.alpha = 1
            })
            self.formattedLyrics = true
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    func array2String(sender: [String]) -> String {
        var tempString: String = String()
        for index in 0..<sender.count {
            tempString += sender[index]
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
        if textView.text == "" {
            textView.text = "Put your lyrics here"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}


