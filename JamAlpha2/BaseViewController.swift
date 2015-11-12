//to set up pageviewcontroller for musicviewcontroller that switches between tracks, artist and albums
import UIKit
import MediaPlayer

class BaseViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate {
    
    
    var player: MPMusicPlayerController! // set to singleton in MusicManager
    
    var musicViewController: MusicViewController!

    var scrollView:UIScrollView!
    var pageViewController: UIPageViewController!
    var pageTitles: [String]!
    var pageImages: [String]!
    
    var musicTypeButtonContainer :UIView!
    var musicUnderlineSelector: UIView!
    
    var buttonText :[String] = []
    var currentPageIndex:Int!
    
    var nowView:VisualizerView! = VisualizerView()
    
    var isPageScrolling = false //prevent scrolling / button tap crash
    
    var statusAndNavigationBarHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MusicManager.sharedInstance.player
        setUpLogo()
        self.automaticallyAdjustsScrollViewInsets = false  //align tableview to top
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        setUpNowView()
        setupSegmentButtons()
        setUpSelector()//the horizontal bar that moves with button tapped
        setUpPageViewController()
        registerMusicPlayerNotificationForPlaybackStateChanged()
    }
    
    func registerMusicPlayerNotificationForPlaybackStateChanged(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playbackStateChanged:"), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: MusicManager.sharedInstance.player)
        print("registering notification in base view controller")
    }
    
    func playbackStateChanged(notification: NSNotification){
        let playbackState = player.playbackState
        print("playbackStateChanged \(player.playbackState.rawValue)")
        if playbackState == .Playing {
            print("now it starts again")
            nowView.start()
        } else  {
            
            nowView.stop()
        }
    }
    
    
    func setUpLogo(){
        let logo = UIImageView(frame: CGRect(origin: CGPointZero, size: CGSizeMake(self.view.frame.width/2, 22)))
        logo.image = UIImage(named: "logo_bold")
        logo.center = CGPointMake(self.view.center.x, 25) // half of navigation height
        logo.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationController!.navigationBar.addSubview(logo)
    }
    
    func setUpNowView(){
        nowView.initWithNumberOfBars(4)
        nowView.frame = CGRectMake(self.view.frame.width-55 ,0 ,45 , 40)
        let tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("goToNowPlaying"))
        nowView.addGestureRecognizer(tapRecognizer)
        self.navigationController!.navigationBar.addSubview(nowView)

    }
    
    func setUpPageViewController(){
        self.pageTitles = ["Song","Album","Artist"]
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pageviewcontroller") as! UIPageViewController
        
        //for didFinishAnimating to work
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as UIViewController
        let allViewControllers: [UIViewController] = [startVC]
        self.pageViewController.setViewControllers(allViewControllers, direction: .Forward, animated: true, completion: nil)
        
        //let heightOffset: CGFloat = 5 // height of table looks cut without minus 5
        self.pageViewController.view.frame = CGRectMake(0, statusAndNavigationBarHeight+CGRectGetMaxY(musicUnderlineSelector.frame), self.view.frame.width, self.view.frame.size.height + 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        
        //set up scroll view
        for view in self.pageViewController.view.subviews {
            if view.isKindOfClass(UIScrollView){
                self.scrollView = view as! UIScrollView
                self.scrollView.delegate = self
            }
        }
        self.currentPageIndex = 0
    }
    
    func goToNowPlaying() {
        for musicViewController in self.pageViewController.viewControllers as! [MusicViewController] {
            if player.nowPlayingItem != nil {
                musicViewController.popToCurrentSong()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
    }
    
    
    var buttonHolder = [UIButton]()
    

    func setupSegmentButtons() {

        let containerHeight: CGFloat = 30
        // 64 is status bar height(20) and navigation bar height(44)
        musicTypeButtonContainer = UIView(frame: CGRectMake(0 , statusAndNavigationBarHeight, self.view.frame.size.width,
           containerHeight))
        musicTypeButtonContainer.backgroundColor = UIColor.blackColor()
        
        if (buttonText.count == 0) {
            buttonText = ["Tracks","Artist","Album"]
        }
        
        let buttonTracks = UIButton(frame: CGRectMake(0, 0, self.view.frame.width / 3, containerHeight))
        let buttonArtist = UIButton(frame: CGRectMake(self.view.frame.width / 3, 0, self.view.frame.width / 3, containerHeight))
        let buttonAlbum = UIButton(frame: CGRectMake(CGFloat(2) * self.view.frame.width / 3, 0, self.view.frame.width / 3, containerHeight))
        
         buttonHolder = [ buttonTracks, buttonArtist, buttonAlbum]
        
        buttonTracks.setTitleColor(UIColor.mainPinkColor(), forState: UIControlState.Normal)
        buttonArtist.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        buttonAlbum.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        for i in 0..<3 {
            buttonHolder[i].backgroundColor = UIColor.whiteColor()
            buttonHolder[i].setTitle(buttonText[i], forState: UIControlState.Normal)
            buttonHolder[i].tag = i
            
            //set font
            buttonHolder[i].titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
            buttonHolder[i].setTitleColor(UIColor.mainPinkColor(), forState: UIControlState.Selected)
            //vertically align at the bottom
            buttonHolder[i].contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
            buttonHolder[i].addTarget(self, action: "tapButton:", forControlEvents: UIControlEvents.TouchUpInside)
            musicTypeButtonContainer.addSubview(buttonHolder[i])
        }
        
    
        self.view.addSubview(musicTypeButtonContainer)
        
    }
    
    func setUpSelector(){
        musicUnderlineSelector = UIView(frame: CGRectMake(0, self.musicTypeButtonContainer.frame.height, self.view.frame.width / 3, 2))
        musicUnderlineSelector.backgroundColor = UIColor.mainPinkColor()
        musicUnderlineSelector.alpha = 0.8
        self.musicTypeButtonContainer.addSubview(musicUnderlineSelector)
    }
    
    
    func tapButton(button:UIButton){
        
        if !self.isPageScrolling { //if done scrolling
            let current = self.currentPageIndex
            var direction:UIPageViewControllerNavigationDirection
            
            //return if pressed on current button
            if button.tag == current {
                return
            }
            self.isPageScrolling = true
            if button.tag > current { //swipe left to right
                direction = UIPageViewControllerNavigationDirection.Forward
                for i in current+1...button.tag {
                    let theVC = self.viewControllerAtIndex(i) as UIViewController
                    let tobeMovedViewControllers: [UIViewController] = [theVC]
                    self.pageViewController.setViewControllers(tobeMovedViewControllers, direction: direction, animated: true, completion: {
                        Void in
                        self.updateCurrentPageIndex(i)
                        self.changeButtonColorOnScroll()
                        self.isPageScrolling = false
                    
                    })
                }
            }
            else { //swipe right to left
                direction = UIPageViewControllerNavigationDirection.Reverse
                 for i in Array((button.tag...current-1).reverse()) {
                    let theVC = self.viewControllerAtIndex(i) as UIViewController
                    let tobeMovedViewControllers = [theVC]
                    self.pageViewController.setViewControllers(tobeMovedViewControllers, direction: direction, animated: true, completion: {
                        Void in
                        self.updateCurrentPageIndex(i)
                        self.changeButtonColorOnScroll()
                        self.isPageScrolling = false
                    
                    })
                }
            }
        }
    }

    func viewControllerAtIndex(index:Int) -> MusicViewController {
        if ((self.pageTitles.count == 0 ) || (index >= self.pageTitles.count)){
            return MusicViewController() //suppose to return nil here
        }
        
        musicViewController = self.storyboard?.instantiateViewControllerWithIdentifier("musicviewcontroller") as! MusicViewController
        musicViewController.pageIndex = index

        musicViewController.nowView = self.nowView!
        return musicViewController
    }

    //MARK: page view controller data source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! MusicViewController
       // vc.createdNewPage = true
        var index = vc.pageIndex

        if (index==0) || index == NSNotFound {
            return nil
        }

        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! MusicViewController
       // vc.createdNewPage = true
        var index = vc.pageIndex

        if (index == NSNotFound){
            return nil
        }
        
        index++
        if (index == self.pageTitles.count){
            return nil
        }
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

    
    func updateCurrentPageIndex(index:Int){
        self.currentPageIndex = index
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed){
            
            let lastViewController = pageViewController.viewControllers!.last! as! MusicViewController
            
            self.currentPageIndex = lastViewController.pageIndex
            
            changeButtonColorOnScroll()
        }
    }
    
    func changeButtonColorOnScroll() {
        for i in 0..<3 {
            if i == currentPageIndex {
                buttonHolder[i].setTitleColor(UIColor.mainPinkColor(), forState: UIControlState.Normal)
            }
            else {
                buttonHolder[i].setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            }
        }
    }
    
    //scrollview delegate methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let xFromCenter:CGFloat = self.view.frame.size.width - scrollView.contentOffset.x
        let xCoordinate:CGFloat = musicUnderlineSelector.frame.size.width *  CGFloat(self.currentPageIndex)
        musicUnderlineSelector.frame = CGRectMake(xCoordinate - xFromCenter / 3, musicUnderlineSelector.frame.origin.y, musicUnderlineSelector.frame.width, musicUnderlineSelector.frame.height)
    }

}
