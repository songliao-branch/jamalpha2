//
//  DetailViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 5/26/15.
//  Copyright (c) 2015 Song Liao. All rights reserved.
//

import UIKit
import MediaPlayer

class DetailViewController: UIViewController {

    var theSong:MPMediaItem!
    
//    @IBOutlet weak var titleLabel: UILabel!
//
//    @IBOutlet weak var artistLabel: UILabel!
//    
//    @IBOutlet weak var albumLabel: UILabel!
//    
//    @IBOutlet weak var albumCoverImage: UIImageView!
    
    @IBOutlet weak var playerProgressSlider: UISlider!
    @IBOutlet weak var base: ChordBase!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    var isPlaying = false
    
    let player = MPMusicPlayerController.applicationMusicPlayer()

    var chords = [Chord]()
    var current = 0
    var delcur = 0
    var labels = [UILabel]()
    var startTime: Float = 0
    var timer: NSTimer!
    
    let widthOfLabel : CGFloat = 30
    let heightOfLabel:CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderView()
        setUpSong()
        setUpDemoChords()
        
        initializeChordOnView()
        
        playerProgressSlider.maximumValue = Float(theSong.playbackDuration)
        playerProgressSlider.minimumValue = 0
        playerProgressSlider.value = 0
        
        
    }
    
    
    
    func setUpDemoChords(){
        
        var chord1 = Chord(content: "C", time: 1.2)
        var chord2 = Chord(content: "F", time: 3.1)
        var chord3 = Chord(content: "Em", time: 6.2)
        var chord4 = Chord(content: "D", time: 10.6)
        
        var chord5 = Chord(content: "D", time: 13.4)
        var chord6 = Chord(content: "Em", time: 14.3)
        var chord7 = Chord(content: "F", time: 16.2)
        var chord8 = Chord(content: "D", time: 17.1)
        
        var chord9 = Chord(content: "C", time: 20.1)
        var chord10 = Chord(content: "G", time: 21.2)
        var chord11 = Chord(content: "Em", time: 22.9)
        var chord12 = Chord(content: "D", time: 24.5)
        
        var chord13 = Chord(content: "C", time: 29.2)
        var chord14 = Chord(content: "G", time: 33.5)
        var chord15 = Chord(content: "Em", time: 34.2)
        var chord16 = Chord(content: "D", time: 40.1)
        
        chords.append(chord1)
        chords.append(chord2)
        chords.append(chord3)
        chords.append(chord4)
        
        
        chords.append(chord5)
        chords.append(chord6)
        chords.append(chord7)
        chords.append(chord8)
        
        
        chords.append(chord9)
        chords.append(chord10)
        chords.append(chord11)
        chords.append(chord12)
        
        
        chords.append(chord13)
        chords.append(chord14)
        chords.append(chord15)
        chords.append(chord16)

    }
    
    func initializeChordOnView(){
        var isLessThan5 = true
        
        while isLessThan5 {
            if current < chords.count
            {
                var theChord = chords[current]
                if theChord.mTime <= 5 {
                    current++
                    
                    println(theChord.mTime)
                    //1

                    let segmentForOneSecond: Float = Float(base.frame.height / 5)
                    let yPosition : CGFloat = CGFloat(Float(base.frame.height) - Float(theChord.mTime) * segmentForOneSecond)
                    let label = UILabel(frame: CGRectMake(0, 0, widthOfLabel, heightOfLabel))
                    label.center = CGPointMake(self.base.frame.width / 2, yPosition)
                    label.text = theChord.mContent
                    label.textAlignment = NSTextAlignment.Center
                    labels.append(label)
                    self.base.addSubview(label)
                }
                else {
                    isLessThan5 = false
                }
            }
            else {
                isLessThan5 = false
            }
        }
    }
    
 
    func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
    }
    
    func stopTimer(){
        if timer.valid {
            timer.invalidate()
        }
    }
    
  
    
    
    func update(){
        //update slider
        
        if startTime == 0 {
            for i in 0...current-1{
 
                
                UIView.animateWithDuration( NSTimeInterval(chords[i].mTime), animations: {
                    self.labels[i].center.y = CGFloat(Float(self.base.frame.height) - self.heightOfLabel / 2)
                })
            }
        }
        
        
        playerProgressSlider.value = Float(player.currentPlaybackTime)
        
        
        startTime += 0.1
        if delcur+1 < chords.count && abs(startTime - Float(chords[delcur+1].mTime)+1) < 0.001
        {
            UIView.animateWithDuration(0.6, animations: {
                self.labels[self.delcur].alpha = 0
            })
            delcur++
        }
        
        if current < chords.count && abs(startTime - Float(chords[current].mTime) + 5) < 0.001 {
            var label = UILabel(frame: CGRectMake(0, 0, 30,20))
            label.text = chords[current].mContent
            label.textAlignment = NSTextAlignment.Center
            label.center = CGPointMake(self.base.frame.width/2, 0 - 20/2)
            
            self.base.addSubview(label)
            labels.append(label)
            
            
            UIView.animateWithDuration(NSTimeInterval(5), delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                label.center.y = self.base.frame.height
            
                }, completion: nil)
            
            current++
        }
    }
    

    func renderView(){
        if let song = theSong {
            println("song title: \(song.title)")
            println("song artist: \(song.artist)")
            println("song album: \(song.albumTitle)")
            
      
//            titleLabel.text = song.title
//            
//            artistLabel.text = song.artist
//            albumLabel.text = song.albumTitle
//            var artwork = song.artwork
//            var bounds = artwork.bounds
//            if let art = artwork {
//                let uncroppedImage = art.imageWithSize(bounds.size)
//                 albumCoverImage.image = Toucan(image: uncroppedImage).maskWithEllipse(borderWidth: 0, borderColor: UIColor.clearColor()).image
//            }
        }
        else
        {
            println("song cannot be loaded")
        }
    }
    func setUpSong(){
        var items = [MPMediaItem]()
        items.append(theSong)
        var collection = MPMediaItemCollection(items: items)
        player.setQueueWithItemCollection(collection)
    }
    
    @IBAction func sliderTouchDown(sender: AnyObject) {
        stopTimer()
    }
    
    @IBAction func sliderTouchUp(sender: UISlider) {
        player.currentPlaybackTime = NSTimeInterval(sender.value)
        startTimer()
    }

    @IBAction func playPause(sender: UIButton) {
        println("play button pressed")
        //if not playing,starts
        if !isPlaying {
            player.play()
            playPauseButton.setTitle("Pause", forState: UIControlState.Normal)
            isPlaying = true
            
            startTimer()
            
            
        } else {
            player.pause()
            playPauseButton.setTitle("Play", forState: UIControlState.Normal)
            isPlaying = false

            stopTimer()
        }
        
        
    }
}
