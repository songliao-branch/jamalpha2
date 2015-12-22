//
//  SongTutorialPageViewController.swift
//  JamAlpha2
//
//  Created by Song Liao on 12/21/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class SongTutorialPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let numberOfItemViewControllers = 3
    
    var pageViewController: UIPageViewController!
    
    var itemVC: SongTutorialPageItemViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.5)
        setUpPageViewController()
        
    }
    
    func setUpPageViewController() {
        
        pageViewController = UIPageViewController(
            transitionStyle: .Scroll,
            navigationOrientation: .Horizontal,
            options: nil)
        
        pageViewController.view.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.width,
            height: self.view.frame.height)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor.clearColor()
        
        pageViewController.setViewControllers(
            [self.viewControllerAtIndex(0)],
            direction: .Forward,
            animated: true,
            completion: nil)
        
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController.didMoveToParentViewController(self)
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.grayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.whiteColor()
    }
    
    func viewControllerAtIndex(index: Int) -> SongTutorialPageItemViewController {
        itemVC = self.storyboard?.instantiateViewControllerWithIdentifier(
            "songtutorialpageitemviewcontroller") as! SongTutorialPageItemViewController
        itemVC.pageIndex = index
        itemVC.parent = self
        return itemVC
    }
    
    // MARK: pageViewController delegate methods
    func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            
            let vc = viewController as! SongTutorialPageItemViewController
            vc.parent = self
            var index = vc.pageIndex
            
            if (index==0) || index == NSNotFound {
                return nil
            }
            
            index--
            return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            
            let vc = viewController as! SongTutorialPageItemViewController
            vc.parent = self
            var index = vc.pageIndex
            
            if (index == NSNotFound){
                return nil
            }
            
            index++
            if (index == self.numberOfItemViewControllers){
                return nil
            }
            return self.viewControllerAtIndex(index)
    }
}
