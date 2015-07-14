

import UIKit
import MediaPlayer
import AVFoundation

let player = MPMusicPlayerController.applicationMusicPlayer()

class DetailViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    // MARK: for testing in simulator
    var audioPlayer = AVAudioPlayer()
    var isTesting = false
    
    var theSong:MPMediaItem!
    
    //@IBOutlet weak var base: ChordBase!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressBar: UISlider!
    
    // MARK: Custom views
    var base : ChordBase!
    
    //MARK:Scrollview 
    var scrollView:UIScrollView!
    var durationBar:UIView!
    var timeToJumpTo:NSTimeInterval!
    
    var currentTimeBar:UIView!
    var currentTimeLabel:UILabel!
    var totalTimeLabel:UILabel!
    
    var isPause: Bool = true

    var chords = [Chord]()
    var start: Int = 0
    var activelabels = [[UILabel]]()
    var startTime: Float = 0
    var timer: NSTimer = NSTimer()
    
    var topPoints = [CGFloat]()
    var bottomPoints = [CGFloat]()
    
    var labelHeight:CGSize!
    //speed to control playback speed and
    //corresponding playback speed
    var speed = 1
    
    var rangeOfChords:Float = 5
    
    //Lyric
    var lyricbase: UIView!
    
    var label1: UILabel = UILabel()
    var label2: UILabel = UILabel()
    
    var current: Int = 0    //current line of lyric
    var lyric: Lyric = Lyric()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set a background image
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        //hide tab bar
        self.tabBarController?.tabBar.hidden = true
        //load data 载入彩虹吉他谱和歌词
        setUpRainbowData()
      
        //set up views from top to bottom
        setUpChordBase()
        setUpLyricsBase()
        setUpDurationBar()
        setUpTimeLabels()
        
        //get top and bottom points of six lines
        calculateXPoints()
        updateAll(0)
    }
    
    
    func setUpRainbowData(){
        chords = Chord.getRainbowChords()
        lyric = Lyric.getRainbowLyrics()
    }
    
    func setUpLyricsBase(){
        //Lyric labels
        current = -1
        lyricbase = UIView(frame: CGRect(x: base.frame.origin.x, y: base.frame.origin.y + base.frame.height, width: base.frame.width, height: base.frame.height / 3))
        lyricbase.backgroundColor = mainPinkColor
        self.view.addSubview(lyricbase)
        
        label1.frame = CGRectMake(0, 0, lyricbase.frame.width, 2 * lyricbase.frame.height/3)
        label1.center = CGPointMake(lyricbase.frame.width/2, lyricbase.frame.height/3)
        label1.numberOfLines = 2
        label1.textAlignment = NSTextAlignment.Center
        label1.font = UIFont.systemFontOfSize(15)
        label1.lineBreakMode = .ByWordWrapping
        lyricbase.addSubview(label1)
        
        label2.frame = CGRectMake(0, 0, lyricbase.frame.width, lyricbase.frame.height / 3)
        label2.center = CGPointMake(lyricbase.frame.width/2, 5 * lyricbase.frame.height/6)
        label2.numberOfLines = 2
        label2.textAlignment = NSTextAlignment.Center
        label2.font = UIFont.systemFontOfSize(10)
        label2.lineBreakMode = .ByWordWrapping
        lyricbase.addSubview(label2)
    }
    
    func setUpChordBase(){
        base = ChordBase(frame: CGRect(x: 0, y: 100, width: self.view.frame.width * 0.7, height: self.view.frame.height * 0.4))
        base.center.x = self.view.center.x
        base.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(base)
    }

    
    //TODO: the container does not fully wrap duration bar, huge bug must fix
    func setUpDurationBar(){
        let scrollViewHeight:CGFloat = 100
        scrollView = UIScrollView(frame: CGRect(x: 0, y: lyricbase.frame.origin.y + lyricbase.frame.height, width: self.view.frame.width, height: scrollViewHeight))
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.brownColor()
        self.view.addSubview(scrollView)
        
        var barWidth:CGFloat
        
        //TODO: delete progress bar after
        progressBar.minimumValue = 0
        if isTesting {
            setUpTestSong()
            //TODO: delete progress bar after
            progressBar.maximumValue = Float(audioPlayer.duration)
            barWidth = CGFloat(audioPlayer.duration)
        }
        else {
            setUpSong()
            //TODO: delete progress bar after
            progressBar.maximumValue = Float(theSong.playbackDuration)
            barWidth = CGFloat(theSong.playbackDuration) * 2
        }
        
        let containerSize = CGSize(width: self.view.frame.width / 2  + barWidth , height: scrollViewHeight)
        let containerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: containerSize))
        scrollView.addSubview(containerView)
        
        durationBar = UIView(frame: CGRect(x: self.view.frame.width / 2, y: 0, width: barWidth, height: 10))
        durationBar.center.y = containerView.frame.height / 2
        durationBar.backgroundColor = UIColor.purpleColor()
        scrollView.addSubview(durationBar)
        
        scrollView.contentSize = containerSize
        scrollView.showsHorizontalScrollIndicator = true
        
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isTesting {
            audioPlayer.currentTime = timeToJumpTo
        } else{
            player.currentPlaybackTime = timeToJumpTo
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if isTesting {
            audioPlayer.currentTime = timeToJumpTo
        } else{
            player.currentPlaybackTime = timeToJumpTo
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let xFromCenter:CGFloat = scrollView.contentOffset.x
        var playTime:CGFloat
        if isTesting {
            timeToJumpTo = NSTimeInterval(xFromCenter / self.durationBar.frame.width * CGFloat(audioPlayer.duration))
        }
        else {
            timeToJumpTo = NSTimeInterval(xFromCenter / self.durationBar.frame.width * CGFloat(theSong.playbackDuration))
        }
        updateAll(Float(timeToJumpTo))
    }
    
    
    func setUpTimeLabels(){
        //Timed bar
        currentTimeBar = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 30))
        currentTimeBar.center.x = self.view.center.x
        currentTimeBar.center.y = self.scrollView.frame.origin.y + 50 //TODO: make better margins
        currentTimeBar.backgroundColor = UIColor.redColor()
        self.view.addSubview(currentTimeBar)
        
        let marginFromCenter:CGFloat = 30
        currentTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        currentTimeLabel.center.x = self.view.frame.width / 2 - marginFromCenter
        currentTimeLabel.center.y = scrollView.frame.origin.y + scrollView.frame.height / 2
        currentTimeLabel.text = "0:00     "
        currentTimeLabel.sizeToFit()
        currentTimeLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(currentTimeLabel)
        
        totalTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        totalTimeLabel.center.x = self.view.frame.width / 2 + marginFromCenter
        totalTimeLabel.center.y = scrollView.frame.origin.y + scrollView.frame.height / 2
        totalTimeLabel.textColor = UIColor.whiteColor()
        if isTesting {
         totalTimeLabel.text = "\(audioPlayer.duration)"
        }
        else {
         totalTimeLabel.text = "\(theSong.playbackDuration)"
        }
       
        totalTimeLabel.sizeToFit()
        self.view.addSubview(totalTimeLabel)
    }

    
    func setUpTestSong(){
        if var filePath = NSBundle.mainBundle().pathForResource("彩虹",ofType:"mp3"){
            var fileWithPath = NSURL.fileURLWithPath(filePath)
            audioPlayer = AVAudioPlayer(contentsOfURL: fileWithPath, error: nil)
        }
        else{
            println("mp3 not found")
        }
        audioPlayer.prepareToPlay()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = mainPinkColor
        self.tabBarController?.tabBar.hidden = false
        
        if isTesting {
            audioPlayer.stop()
        }
    }
    
    func calculateXPoints(){
        let width = base.frame.width
        
        let margin:Float = 0.25
        let initialPoint:CGFloat = CGFloat(Float(width) * margin)
        let rightTopPoint:CGFloat = CGFloat(Float(width) * (1 - margin))
        
        let scale:Float = 1 / 12
        let topWidth = Float(rightTopPoint) - Float(initialPoint)
        let topLeft = Float(initialPoint) + Float(topWidth) * scale
        topPoints = [CGFloat](count: 6, repeatedValue: 0)
        
        topPoints[0] = CGFloat(topLeft)
        for i in 1..<6 {
            topPoints[i] = CGFloat(Float(topPoints[i - 1]) + Float(topWidth * scale * 2))
        }
        
        bottomPoints = [CGFloat](count: 6, repeatedValue: 0)
        bottomPoints[0] = CGFloat(Float(width) * scale)
        for i in 1..<6 {
            bottomPoints[i] = CGFloat(Float(bottomPoints[i - 1]) + Float(width) * scale * 2)
        }
    }

    
    func update(){
        startTime += 0.01
        
        progressBar.value = startTime
        
   
        if activelabels.count > 0 && start+1 < chords.count && abs(startTime - Float(chords[start+1].mTime) + 0.6) < 0.01
        {
            var labels = activelabels.removeAtIndex(0)
            for label in labels {
                UIView.animateWithDuration(0.01 * 60 / Double(speed), animations: {
                    label.alpha = 0
                    }, completion: { finished in
                        label.removeFromSuperview()
                })
            }
            start++
        }
        
        /// Add new chord
        let end = start + activelabels.count
        if end < chords.count && abs(startTime - Float(chords[end].mTime) + rangeOfChords) < 0.01 {
            activelabels.append(createLabels(chords[end].tab.content))
        }
        
        if current + 1 < lyric.lyric.count && abs(startTime - Float(lyric.get(current+1).time)) < 0.001 {
            current++
            label1.text = lyric.get(current).str
            
            if current + 1 < lyric.lyric.count {
                label2.text = lyric.get(current+1).str
                label2.alpha = 0
                UIView.animateWithDuration(0.1, animations: {
                    self.label2.alpha = 1
                })
            }
        }
        
        refresh()
    }
    
    
    func updateAll(time: Float){
        ///Set the start time
        let startTime_int: Int = Int(time*100)
        startTime = Float(startTime_int)/100
        
        ///Remove all label in current screen
        for labels in activelabels{
            for label in labels{
                label.removeFromSuperview()
            }
        }
        activelabels.removeAll(keepCapacity: true)
        
        start = 0;
        var index: Int = 0
        var in_interval = true;
        while in_interval && index < chords.count{
            let chord_time = Float(chords[index].mTime)
            if chord_time > (startTime + rangeOfChords) {
                in_interval = false
            }else if chord_time >= startTime {
                /// Add labels to activelabels
                activelabels.append(createLabels(chords[index].tab.content))
                
                //Set the start value
                if index == 0 || Float(chords[index-1].mTime) < startTime {
                    start = index
                }
            }
            index++
        }
        
        if start > 0 && Float(chords[start].mTime) - startTime > 0.6{
            start--
            activelabels.insert(createLabels(chords[start].tab.content), atIndex: 0)
        }
        
        refresh()
        
        //Update the content of the lyric
        current = -1
        while(current + 1 < lyric.lyric.count){
            if Float(lyric.get(current + 1).time) > startTime {
                break
            }
            current++
        }
        
        if current == -1{
            label1.text = "..."//theSong.title
        }
        else {
            label1.text = lyric.get(current).str
        }
        if current + 1 < lyric.lyric.count {
            label2.text = lyric.get(current+1).str
        }
        else {
            label2.text = "End~"
        }
        
        println("startTime\(startTime)")
        //update progress view
        
    }
    
    func setUpSong(){
        var items = [MPMediaItem]()
        items.append(theSong)
        var collection = MPMediaItemCollection(items: items)
        player.setQueueWithItemCollection(collection)
    }
    
    @IBAction func playPause(sender: UIButton) {
            if self.isPause{
                startTimer()
                self.isPause = false
                
                if isTesting {
                    audioPlayer.play()
                }else {
                     player.play()
                }
                sender.setTitle("Pause", forState: .Normal)
            }
            else {
                timer.invalidate()
                self.isPause = true
                if isTesting {
                    audioPlayer.pause()
                }else {
                    player.pause()
                }
                sender.setTitle("Continue", forState: .Normal)
            }
    }
    
    
    @IBAction func progressBarChanged(sender: UISlider) {
        timer.invalidate()
        updateAll(sender.value)
        if !isPause{
            startTimer()
        }
    }
    
    
    //TODO:Delete ths UISlider after replacing it with a fully functional uiscrollviews
    @IBAction func progressBarChangeEnded(sender: UISlider) {
        if isTesting {
            audioPlayer.currentTime = NSTimeInterval(sender.value)
        }else {
            player.currentPlaybackTime = NSTimeInterval(sender.value)
        }

    }
    
    func refresh(){
        /// Change the location of each label
        for var i = 0; i < activelabels.count; ++i{
            var labels = activelabels[i]
            let t = Float(chords[start+i].mTime)
            var yPosition = Float(self.base.frame.height)*(startTime + rangeOfChords - t) / rangeOfChords
            if yPosition > Float(self.base.frame.height){
                yPosition = Float(self.base.frame.height)
            }
            for var j = 0; j < labels.count; ++j{
                var bottom = Float(bottomPoints[j])
                var top = Float(topPoints[j])
                var xPosition = CGFloat(bottom + (top - bottom) * (t - startTime) / rangeOfChords)
                if yPosition == Float(self.base.frame.height){
                    xPosition = bottomPoints[j]
                }
                
                labels[j].center = CGPointMake(xPosition, CGFloat(yPosition - Float(labels[j].frame.height / 2)))
            }
        }
        
        refreshDurationBar()
        refreshTimeLabel()
    }
    
    func refreshDurationBar()
    {
        var xOffset:CGFloat
        if isTesting {
            xOffset = CGFloat(startTime) * self.durationBar.frame.width / CGFloat(audioPlayer.duration)
        }
        else {
            xOffset = CGFloat(startTime) * self.durationBar.frame.width / CGFloat(theSong.playbackDuration)
        }
        durationBar.frame = CGRectMake(self.view.frame.width / 2 - xOffset, durationBar.frame.origin.y, durationBar.frame.width, durationBar.frame.height)
        
    }
    func refreshTimeLabel(){
        currentTimeLabel.text = "\(startTime)"
    }
    
    func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01 / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    
    func createLabels(content: String) -> [UILabel]{
        var res = [UILabel]()
        
        for i in 0...count(content)-1{
            let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
            label.font = UIFont.systemFontOfSize(25)
            label.text = String(Array(content)[i])
            label.sizeToFit()
            label.textAlignment = NSTextAlignment.Center
            res.append(label)
            self.base.addSubview(label)
        }
        return res
    }
}