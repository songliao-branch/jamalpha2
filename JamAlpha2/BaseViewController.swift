//to set up pageviewcontroller for musicviewcontroller that switches between tracks, artist and albums
import UIKit

class BaseViewController: UIViewController, UIPageViewControllerDataSource {

    @IBOutlet weak var indicatorButton: UIButton!
    
    var pageViewController: UIPageViewController!
    var pageTitles: [String]!
    var pageImages: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pageTitles = ["Song","Album","Artist"]
        self.pageImages = ["song","album","artist"]
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pageviewcontroller") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        var startVC = self.viewControllerAtIndex(0) as UIViewController
        var viewControllers = [startVC]
        self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0,100,self.view.frame.width, self.view.frame.size.height)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        // Do any additional setup after loading the view.
    }

    
    func viewControllerAtIndex(index:Int) -> MusicViewController {
        if ((self.pageTitles.count == 0 ) || (index >= self.pageTitles.count)){
            return MusicViewController() //suppose to return nil here
        }
       // changeButtonColorFromIndex(index)
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
        println("beforeViewController  \(index)")
        changeIndicatorText(index)
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var vc = viewController as! MusicViewController
        var index = vc.pageIndex
        if (index == NSNotFound){
            return nil
        }
        println("afterViewcontroller  \(index)")
        changeIndicatorText(index)
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
    //TODO: not correct
    func changeIndicatorText(index:Int){
        if index == 0 {
            indicatorButton.setTitle("Tracks", forState: UIControlState.Normal)
        } else if index == 1 {
            indicatorButton.setTitle("Artist", forState: UIControlState.Normal)
        } else if index == 2 {
            indicatorButton.setTitle("Album", forState: UIControlState.Normal)
        }

    }

}
