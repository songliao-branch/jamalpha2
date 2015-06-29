//to set up pageviewcontroller for musicviewcontroller that switches between tracks, artist and albums
import UIKit

class BaseViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate {
    
    var scrollView:UIScrollView!
    var pageViewController: UIPageViewController!
    var pageTitles: [String]!
    var pageImages: [String]!
    
    
    var musicTypeButtonContainer :UIView!
    var musicUnderlineSelector: UIView!
    
    var buttonText :[String] = []
    let mainPinkColor = UIColor(red: 0.941, green: 0.357, blue: 0.38, alpha: 1)
    var currentPageIndex:Int!
    
    var isPageScrolling = false //prevent scrolling / button tap crash

    
    @IBOutlet weak var placeHolderForSub: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false  //align tableview to top
       
        
        self.pageTitles = ["Song","Album","Artist"]
        self.pageImages = ["song","album","artist"]
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pageviewcontroller") as! UIPageViewController
        
        //for didFinishAnimating to work
        self.pageViewController.delegate = self
        
        self.pageViewController.dataSource = self
        
        var startVC = self.viewControllerAtIndex(0) as UIViewController
        var allViewControllers = [startVC]
        self.pageViewController.setViewControllers(allViewControllers as [AnyObject], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0,self.navigationController!.navigationBar.frame.height * 2,self.view.frame.width, self.view.frame.size.height)
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
       
        //change status bar text to light
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //change navigation bar color
        self.navigationController?.navigationBar.barTintColor = mainPinkColor
        
         setupSegmentButtons()
       
    }

    var buttonHolder = [UIButton]()
    
    func setupSegmentButtons() {
        self.placeHolderForSub.hidden = true
        
        let heightOfPlaceHolder = self.placeHolderForSub.frame.height
        musicTypeButtonContainer = UIView(frame: CGRectMake(0 , placeHolderForSub.frame.origin.y , self.view.frame.size.width,
           heightOfPlaceHolder))
        
        let numControllers = 3
        
        if (buttonText.count == 0) {
            buttonText = ["Tracks","Artist","Album"]
        }
        
        let buttonTracks = UIButton(frame: CGRectMake(0, 0, self.view.frame.width / 3, heightOfPlaceHolder))
        let buttonArtist = UIButton(frame: CGRectMake(self.view.frame.width / 3, 0, self.view.frame.width / 3, heightOfPlaceHolder))
        let buttonAlbum = UIButton(frame: CGRectMake(CGFloat(2) * self.view.frame.width / 3, 0, self.view.frame.width / 3, heightOfPlaceHolder))
        
        
      
         buttonHolder = [ buttonTracks, buttonArtist, buttonAlbum]
        
        buttonTracks.setTitleColor(mainPinkColor, forState: UIControlState.Normal)
        buttonArtist.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        buttonAlbum.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        for i in 0..<3 {
            buttonHolder[i].backgroundColor = UIColor.whiteColor()
            buttonHolder[i].setTitle(buttonText[i], forState: UIControlState.Normal)
            buttonHolder[i].tag = i
            
            //set font
            buttonHolder[i].titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
            buttonHolder[i].setTitleColor(mainPinkColor, forState: UIControlState.Selected)
            //vertically align at the bottom
            buttonHolder[i].contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
            buttonHolder[i].addTarget(self, action: "tapButton:", forControlEvents: UIControlEvents.TouchUpInside)
            musicTypeButtonContainer.addSubview(buttonHolder[i])
        }
        
        self.setUpSelector()
        self.view.addSubview(musicTypeButtonContainer)
        
    }
    
    func setUpSelector(){
        musicUnderlineSelector = UIView(frame: CGRectMake(0, self.musicTypeButtonContainer.frame.height, self.view.frame.width / 3, 2))
        musicUnderlineSelector.backgroundColor = mainPinkColor
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
       
        var vc: MusicViewController = self.storyboard?.instantiateViewControllerWithIdentifier("musicviewcontroller") as! MusicViewController
        
        vc.pageIndex = index
        return vc
    }

    //MARK: page view controller data source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var vc = viewController as! MusicViewController
        var index = vc.pageIndex
        if (index==0) || index == NSNotFound {
            return nil
        }

        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as! MusicViewController
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
                buttonHolder[i].setTitleColor(mainPinkColor, forState: UIControlState.Normal)
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
