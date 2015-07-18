
import UIKit
import MediaPlayer
import AVFoundation


let chordwithname:Int = 1
let fullchord:Int = 0

class DetailViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    // MARK: for testing in simulator
    var isTesting = false
    
    var audioPlayer = AVAudioPlayer()
    let player = MPMusicPlayerController.applicationMusicPlayer()
    
    var theSong:MPMediaItem!
    
    //@IBOutlet weak var base: ChordBase!
    @IBOutlet weak var playPauseButton: UIButton!
    
    // MARK: Custom views
    var base : ChordBase!
    
    //MARK: progress Container
    var progressBlock:UIView!
    var progressBlockContainer:UIView!
    var progressChangedOrigin:CGFloat!
    let progressWidthMultiplier:CGFloat = 2
    var recognizer:UIPanGestureRecognizer!
    var isPanning = false
    
    var verticalBar:UIView!
    var currentTimeLabel:UILabel!
    var totalTimeLabel:UILabel!
    
    var isPause: Bool = true
    var chords = [Chord]()
    var start: Int = 0
    var activelabels = [[UILabel]]()
    var startTime: TimeNumber = TimeNumber(second: 0, decimal: 0)
    var timer: NSTimer = NSTimer()
    
    var topPoints = [CGFloat]()
    var bottomPoints = [CGFloat]()
    
    var topPointModes = [Int: [CGFloat]]()
    var bottomPointModes = [Int: [CGFloat]]()
    
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
    
    var mode:Int = 0
    //for displaying 4 buttons, Favorite, Shuffle state, Changed chord version, dots
    var bottomView:UIView!
    
    var favoriateButton:UIButton!
    var shuffleButton:UIButton!
    var shareButton:UIButton!
    var othersButton:UIButton!
    
    //constant 
    let bottomViewHeight:CGFloat = 40 //this is fixed
    let progressContainerHeight:CGFloat = 100 //TODO: Change to percentange
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide tab bar
        self.tabBarController?.tabBar.hidden = true
        //load data 载入彩虹吉他谱和歌词
        setUpRainbowData()
        loadSong()
      
        //set up views from top to bottom
        setUpChordBase()
        setUpLyricsBase()
        setUpProgressContainer()
        setUpTimeLabels()
        setUpBottomViewWithButtons()
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
    
    func loadSong(){
        if isTesting {
            setUpTestSong()
        }
        else {
            setUpSong()
        }
    }
    
    func setUpProgressContainer(){
        progressChangedOrigin = self.view.frame.width / 2
        progressBlockContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: progressContainerHeight))
        
        progressBlockContainer.center.y = self.view.frame.height - bottomViewHeight - progressContainerHeight / 2
        
        progressBlockContainer.backgroundColor = UIColor.clearColor()
        self.view.addSubview(progressBlockContainer)
        
        var blockWidth:CGFloat
        if isTesting {
            blockWidth = CGFloat(audioPlayer.duration) * progressWidthMultiplier
        } else {
            blockWidth = CGFloat(theSong.playbackDuration) * progressWidthMultiplier
        }
        
        progressBlock = UIView(frame: CGRect(x: progressChangedOrigin, y: 0, width: blockWidth, height: 5))
        progressBlock.center.y = progressContainerHeight / 2
        progressBlock.backgroundColor = mainPinkColor
        progressBlockContainer.addSubview(progressBlock)
        recognizer = UIPanGestureRecognizer(target: self, action:Selector("handlePan:"))
        recognizer.delegate = self
        progressBlockContainer.addGestureRecognizer(recognizer)
    }

    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        for childview in recognizer.view!.subviews {
            let child = childview as! UIView
            self.isPanning = true
            
            var newPosition = progressChangedOrigin + translation.x
            
            // leftmost point of inner bar cannot be more than half of the view
            if newPosition > self.view.frame.width / 2 {
                newPosition = self.view.frame.width / 2
            }
            
            // the end of inner bar cannot be smaller left half of view
            if newPosition + child.frame.width < self.view.frame.width / 2 {
                newPosition = self.view.frame.width / 2 - child.frame.width
            }
            
            //update all chords, lyrics
            timer.invalidate()
            
            //new Position from 160 to -357
            //-self.view.frame.width /2 
            //= from 0 ot -517
            //divide by -2: from 0 to 258
            let toTime = Float(newPosition - self.view.frame.width / 2) / -Float(self.progressWidthMultiplier)
            //258  517
            updateAll(toTime)
            if !isPause {
                startTimer()
            }
            child.frame.origin.x = newPosition
            
            //when finger is lifted
            if recognizer.state == UIGestureRecognizerState.Ended {
                progressChangedOrigin = newPosition
                isPanning = false
                if isTesting {
                    audioPlayer.currentTime = NSTimeInterval(toTime)
                }
                else {
                    player.currentPlaybackTime = NSTimeInterval(toTime)
                
                }
            }
        }
    }
    
    
    func setUpTimeLabels(){
        verticalBar = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: progressContainerHeight / 2))
        verticalBar.center = progressBlockContainer.center
        verticalBar.backgroundColor = UIColor.blueColor()
        self.view.addSubview(verticalBar)
        
        currentTimeLabel = UILabel(frame: CGRect(x: 0, y: progressBlockContainer.frame.origin.y, width: 100, height: 30))
        
        currentTimeLabel.font = UIFont.systemFontOfSize(10)
        currentTimeLabel.text = "0:00.00"
        currentTimeLabel.textColor = UIColor.blueColor()
        self.view.addSubview(currentTimeLabel)
        
        totalTimeLabel = UILabel(frame: CGRect(x: self.view.frame.width - 50, y: progressBlockContainer.frame.origin.y, width: 0, height: 30))
        totalTimeLabel.textColor = UIColor.blackColor()
        totalTimeLabel.font = UIFont.systemFontOfSize(10)
        
        if isTesting {
         totalTimeLabel.text = TimeNumber(time: Float(audioPlayer.duration)).toDisplayString()
        } else {
         totalTimeLabel.text = TimeNumber(time: Float(theSong.playbackDuration)).toDisplayString()
        }
        
        totalTimeLabel.sizeToFit()
        totalTimeLabel.center.x = self.view.frame.width - totalTimeLabel.frame.width / 2 - 5
        self.view.addSubview(totalTimeLabel)
        
    }

    //from left to right: share, favoriate, shuffle, others
    func setUpBottomViewWithButtons(){
        let edgeButtonSideMargin:CGFloat = 50
        bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - bottomViewHeight, width: self.view.frame.width, height: bottomViewHeight))
        bottomView.backgroundColor = UIColor.blackColor()
        bottomView.alpha = 0.6
        self.view.addSubview(bottomView)
        
        
        othersButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        othersButton.setTitle("Others", forState: UIControlState.Normal)
        othersButton.center.x = bottomView.frame.width - edgeButtonSideMargin
        othersButton.sizeToFit()
        othersButton.center.y = bottomViewHeight / 2
        othersButton.backgroundColor = UIColor.redColor()
        othersButton.addTarget(self, action: "showActionSheet", forControlEvents: UIControlEvents.TouchUpInside)
        bottomView.addSubview(othersButton)
    }
    
    func showActionSheet(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let changeTabsMode = UIAlertAction(title: "Change Tab Mode", style: .Default, handler: {
            (alert:UIAlertAction!) -> Void in
            self.changeChordMode()
        })

        
        let addTabsAction = UIAlertAction(title: "Add your tabs", style: .Default, handler: {
            (alert:UIAlertAction!) -> Void in
            
            let editTabsVC = EditTabsViewController()
            self.presentViewController(editTabsVC, animated: true, completion: nil)
            //Go to edit tabs screen
            
        })
        
        let addLyricsAction = UIAlertAction(title: "Add your lyrics", style: .Default, handler: {
            (alert:UIAlertAction!) -> Void in
            //TODO: Go to edit lyrics screens
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:nil)
        optionMenu.addAction(changeTabsMode)
        optionMenu.addAction(addTabsAction)
        optionMenu.addAction(addLyricsAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    func setUpTestSong(){
        if var filePath = NSBundle.mainBundle().pathForResource("彩虹",ofType:"mp3"){
            var fileWithPath = NSURL.fileURLWithPath(filePath)
            audioPlayer = AVAudioPlayer(contentsOfURL: fileWithPath, error: nil)
        }
        else{
            NSLog("mp3 not found")
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
        topPoints = [CGFloat](count: 7, repeatedValue: 0)
        
        topPoints[0] = CGFloat(topLeft)
        for i in 1..<6 {
            topPoints[i] = CGFloat(Float(topPoints[i - 1]) + Float(topWidth * scale * 2))
        }
        
        bottomPoints = [CGFloat](count: 7, repeatedValue: 0)
        bottomPoints[0] = CGFloat(Float(width) * scale)
        for i in 1..<6 {
            bottomPoints[i] = CGFloat(Float(bottomPoints[i - 1]) + Float(width) * scale * 2)
        }

        //add things
        let top0: CGFloat = CGFloat(margin * Float(base.frame.width) - 20)
        let buttom0: CGFloat = CGFloat(-20)
        
        topPoints.insert(top0, atIndex: 0)
        bottomPoints.insert(buttom0, atIndex: 0)
        
        //Mode 0
        topPointModes[0] = topPoints
        bottomPointModes[0] = bottomPoints
        
        //Mode 1
        topPoints = [width / 2]
        bottomPoints = [width / 2]
        
        topPointModes[1] = topPoints
        bottomPointModes[1] = bottomPoints
        
        topPoints = topPointModes[mode]!
        bottomPoints = bottomPointModes[mode]!

    }

    
    func update(){

        startTime.addMinimal()

        if activelabels.count > 0 && start+1 < chords.count && chords[start+1].mTime.isEqual(TimeNumber( time: startTime.toDecimalNumer() + 0.6))
        {

            var labels = activelabels.removeAtIndex(0)
            for label in labels {
                UIView.animateWithDuration(0.01 * 60 / Double(speed), animations: {
                  
                    label.alpha = 0
                    }, completion: {
                        Void in
                        
                        label.removeFromSuperview()
                })
            }
            start++
        }
        
        // Add new chord
        let end = start + activelabels.count
        if end < chords.count && chords[end].mTime.isEqual(TimeNumber(time: rangeOfChords + startTime.toDecimalNumer())) {
            activelabels.append(createLabels(chords[end].tab.name, content: chords[end].tab.content))
        }
        
        if current + 1 < lyric.lyric.count && lyric.get(current+1).time.isEqual(startTime) {
            current++
            label1.text = lyric.get(current).str
            
            if current + 1 < lyric.lyric.count {
                label2.text = lyric.get(current+1).str
                
//                UIView.animateWithDuration(0.1, animations: {
//                    self.label2.alpha = 1
//                })
            }
        }
        
        refreshChordLabel()
        refreshProgressBlock()
        refreshTimeLabel()
        
    }
    
    
    func refreshChordLabel(){
        /// Change the location of each label
        for var i = 0; i < activelabels.count; ++i{
            var labels = activelabels[i]
            let t = chords[start+i].mTime
            var yPosition = Float(self.base.frame.height)*(startTime.toDecimalNumer() + rangeOfChords - t.toDecimalNumer()) / rangeOfChords
            if yPosition > Float(self.base.frame.height){
                yPosition = Float(self.base.frame.height)
            }
            for var j = 0; j < labels.count; ++j{
                var bottom = Float(bottomPoints[j])
                var top = Float(topPoints[j])
                var xPosition = CGFloat(bottom + (top - bottom) * (t.toDecimalNumer() - startTime.toDecimalNumer()) / rangeOfChords)
                if yPosition == Float(self.base.frame.height){
                    xPosition = bottomPoints[j]
                }
                
                labels[j].center = CGPointMake(xPosition, CGFloat(yPosition - Float(labels[j].frame.height / 2)))
            }
        }
        
    }
    
    func refreshProgressBlock(){
        var barWidth:CGFloat
        
        if isTesting {
            barWidth = CGFloat(audioPlayer.duration)
        }
        else {
            barWidth = CGFloat(theSong.playbackDuration)
        }
        
        let newOriginX = self.view.frame.width / 2 - CGFloat(startTime.toDecimalNumer()) * self.progressBlock.frame.width / barWidth
        if !isPanning {
            self.progressChangedOrigin = newOriginX
        }
        
        self.progressBlock.frame.origin.x = newOriginX
    }
    
    
    
    func refreshTimeLabel(){
        //update current time label
        currentTimeLabel.text = startTime.toDisplayString()
    }
    
    func updateAll(time: Float){
        ///Set the start time
        startTime = TimeNumber(time: time)
        
        ///Remove all label in current screen
        for labels in activelabels{
            for label in labels{
                label.removeFromSuperview()
            }
        }
        activelabels.removeAll(keepCapacity: true)
        
        //find the start of the chord whose time is larger than current time
        start = 0
        var last: Int = 0 //the end index of the chord that would show on the screen
        
        var begin: Int = 0
        var end: Int = chords.count - 1
        
        while true {
            var mid: Int = (begin + end) / 2
            if startTime.isLongerThan(chords[mid].mTime) {
                begin = mid
            } else {
                end = mid
            }
            if begin == (end - 1) {
                start = begin
                if startTime.isLongerThan(chords[end].mTime) {
                    start = end
                }
                break
            }
        }
        
        begin = 0
        end = chords.count - 1
        let tn = TimeNumber(time: startTime.toDecimalNumer() + rangeOfChords)
        while true {
            var mid: Int = (begin + end) / 2
            if tn.isLongerThan(chords[mid].mTime) {
                begin = mid
            } else {
                end = mid
            }
            if begin == (end - 1) {
                last = begin
                if tn.isLongerThan( chords[end].mTime ) {
                    last = end
                }
                break
            }
        }

        if start == last {
            activelabels.append(createLabels(chords[start].tab.name, content: chords[start].tab.content))
        }
        
        if start < last {
            if startTime.isLongerThan(chords[start].mTime) && (TimeNumber(time: startTime.toDecimalNumer() + 0.6)).isLongerThan(chords[start+1].mTime) {
                self.start++
            }
            
            for i in start...last {
                activelabels.append(createLabels(chords[i].tab.name, content: chords[i].tab.content))
            }
        }
        
        refreshChordLabel()
        
        //Update the content of the lyric
        current = -1
        while(current + 1 < lyric.lyric.count){
            if lyric.get(current + 1).time.toDecimalNumer() > startTime.toDecimalNumer() {
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
    
    func changeChordMode() {
        timer.invalidate()
        mode = 1 - mode
        topPoints = topPointModes[mode]!
        bottomPoints = bottomPointModes[mode]!
        updateAll(startTime.toDecimalNumer())
        if !isPause{
            startTimer()
        }
    }

    func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01 / Double(speed), target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    
    func createLabels(name: String, content: String) -> [UILabel]{
        var res = [UILabel]()
        
        let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
        label.font = UIFont.systemFontOfSize(25)
        label.text = name
        label.sizeToFit()
        label.textAlignment = NSTextAlignment.Center
        res.append(label)
        self.base.addSubview(label)
        
        if mode == fullchord {
            for i in 0...count(content)-1 {
                let label = UILabel(frame: CGRectMake(0, 0, 0, 0))
                label.font = UIFont.systemFontOfSize(25)
                label.text = String(Array(content)[i])
                label.sizeToFit()
                label.textAlignment = NSTextAlignment.Center
                res.append(label)
                self.base.addSubview(label)
        }
        }
        return res
    }
}