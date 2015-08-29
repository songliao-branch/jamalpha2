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
    
    @IBOutlet weak var placeHolderForSub: UILabel!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MusicManager.sharedInstance.player
        
        title = "twistjam"
        self.automaticallyAdjustsScrollViewInsets = false  //align tableview to top
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        setUpNowView()
        setupSegmentButtons()
        setUpSelector()//the horizontal bar that moves with button tapped
        setUpPageViewController()
        registerMusicPlayerNotificationForSongChanged()
    }
    

    func registerMusicPlayerNotificationForSongChanged(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("currentSongChanged:"), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
    }
    
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func currentSongChanged(notification: NSNotification){
        synced(self) {
            if self.player.repeatMode == .One {
                println("\(self.player.nowPlayingItem.title) is repeating")
                return
            }
            
            if self.player.indexOfNowPlayingItem != MusicManager.sharedInstance.lastSelectedIndex {
                for musicViewController in self.pageViewController.viewControllers as! [MusicViewController] {
                    // only for tracks only ,TODO: index might be different for artist and album
                    if musicViewController.pageIndex == 0 {

                        musicViewController.musicTable.reloadData()
                    }
                }
            }
        }
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
        
        var startVC = self.viewControllerAtIndex(0) as UIViewController
        var allViewControllers = [startVC]
        self.pageViewController.setViewControllers(allViewControllers as [AnyObject], direction: .Forward, animated: true, completion: nil)
        
        
        self.pageViewController.view.frame = CGRectMake(0, CGRectGetMaxY(musicUnderlineSelector.frame) + self.navigationController!.navigationBar.frame.height, self.view.frame.width, self.view.frame.size.height + 15)
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
    }
    
    
    var buttonHolder = [UIButton]()
    

    func setupSegmentButtons() {
        self.placeHolderForSub.hidden = true
        
        let heightOfPlaceHolder = self.placeHolderForSub.frame.height
        musicTypeButtonContainer = UIView(frame: CGRectMake(0 , self.navigationController!.navigationBar.frame.height , self.view.frame.size.width,
           heightOfPlaceHolder))
        
        let numControllers = 3
        
        if (buttonText.count == 0) {
            buttonText = ["Tracks","Artist","Album"]
        }
        
        let buttonTracks = UIButton(frame: CGRectMake(0, 0, self.view.frame.width / 3, heightOfPlaceHolder))
        let buttonArtist = UIButton(frame: CGRectMake(self.view.frame.width / 3, 0, self.view.frame.width / 3, heightOfPlaceHolder))
        let buttonAlbum = UIButton(frame: CGRectMake(CGFloat(2) * self.view.frame.width / 3, 0, self.view.frame.width / 3, heightOfPlaceHolder))
        
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
            var indexScrollingFrom:Int
            
            //return if pressed on current button
            if button.tag == current {
                return
            }
            
            self.isPageScrolling = true

            if button.tag > current { //swipe left to right
    
                direction = UIPageViewControllerNavigationDirection.Forward
                
                for i in current+1...button.tag {
                    var theVC = self.viewControllerAtIndex(i) as UIViewController
                    var tobeMovedViewControllers = [theVC]
                    
                    self.pageViewController.setViewControllers(tobeMovedViewControllers as [AnyObject], direction: direction, animated: true, completion: { (Void) in
                        self.updateCurrentPageIndex(i)
                        self.changeButtonColorOnScroll()
                        self.isPageScrolling = false
                    })
                }
            }
            else { //swipe right to left
                direction = UIPageViewControllerNavigationDirection.Reverse

                 for i in reverse(button.tag...current-1) {
                    var theVC = self.viewControllerAtIndex(i) as UIViewController
                    var tobeMovedViewControllers = [theVC]
                    
                    self.pageViewController.setViewControllers(tobeMovedViewControllers as [AnyObject], direction: direction, animated: true, completion: { (Void) in
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
        var vc = viewController as! MusicViewController
       // vc.createdNewPage = true
        var index = vc.pageIndex

        if (index==0) || index == NSNotFound {
            return nil
        }

        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as! MusicViewController
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

    func tapMusicTypeButtonAction(button: UIButton){
        let tempIndex = self.currentPageIndex
        
    }
    
    func updateCurrentPageIndex(index:Int){
        self.currentPageIndex = index
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if(completed){
            
            let lastViewController = pageViewController.viewControllers.last as! MusicViewController
            
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
    
    
    //MARK : Navigation item action
    
}
