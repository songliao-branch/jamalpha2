//
//  PhotoViewerViewController.swift
//  JamAlpha2
//
//  Created by FangXin on 11/29/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit
import QuartzCore
import AssetsLibrary

class PhotoViewerViewController: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate {
    var photoID: Int = 0 // Is set by the collection view while performing a segue to this controller.
    
    let scrollView = UIScrollView()
    var imageView = UIImageView()
    
    var photo:UIImage?
    var photoURL:String!
    
    
    var panRecognizer:UIPanGestureRecognizer!
    var singleTapRecognizer: UITapGestureRecognizer!
    
    var statusView: UIView!
    var successImage: UIImageView!
    var failureImage: UIImageView!
    var statusLabel: UILabel!
    var hideStatusViewTimer = NSTimer()
    
    // MARK: Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        setupView()
        
        loadPhoto()
        setUpStatusView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
    }
    
    func setupView() {
        // Visual feedback to the user, so they know we're busy loading an image
        
        
        // A scroll view is used to allow zooming
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        imageView.contentMode = .ScaleAspectFill
        if(self.photo != nil){
            imageView.image = self.photo
            self.imageView.frame = self.centerFrameFromImage(self.photo)

        }
        
        scrollView.addSubview(imageView)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecognizer.delegate = self
        scrollView.addGestureRecognizer(longPressRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.delegate = self
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingTap:")
        singleTapRecognizer.delegate = self
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panRecognizer.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panRecognizer)
        
        scrollView.panGestureRecognizer.requireGestureRecognizerToFail(panRecognizer)
        
        for recognizer:UIGestureRecognizer in scrollView.gestureRecognizers! {
            recognizer.enabled = false
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func loadPhoto() {
        for recognizer:UIGestureRecognizer in self.scrollView.gestureRecognizers! {
            recognizer.enabled = true
        }
        
        self.centerScrollViewContents()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func showActions() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Download Photo")
        actionSheet.showFromToolbar((navigationController?.toolbar)!)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
//            downloadPhoto()
        }
    }
    
    // MARK: Gesture Recognizers
    func handleLongPress(recognizer: UILongPressGestureRecognizer!) {
        if recognizer.state == UIGestureRecognizerState.Began {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                ALAssetsLibrary().writeImageToSavedPhotosAlbum(self.imageView.image!.CGImage,
                    orientation: ALAssetOrientation(rawValue: self.imageView.image!.imageOrientation.rawValue)!,
                    completionBlock:{ (path:NSURL!, error:NSError!) -> Void in
                        if(error == nil){
                           self.showStatusView(true)
                            self.startHideStatusViewTimer()
                        }else{
                            self.showStatusView(false)
                            self.startHideStatusViewTimer()
                            print(error)
                        }
                })
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            
            optionMenu.addAction(saveAction)
            optionMenu.addAction(cancelAction)

            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }

    
    func handleDoubleTap(recognizer: UITapGestureRecognizer!) {
        let pointInView = recognizer.locationInView(self.imageView)
        self.zoomInZoomOut(pointInView)
    }
    
    func handleSingTap(recognizer: UITapGestureRecognizer!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer!) {
            if(recognizer.state == .Ended && self.scrollView.zoomScale == self.scrollView.minimumZoomScale){
                self.dismissViewControllerAnimated(true, completion: nil)
            }
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale){
            self.view.removeGestureRecognizer(self.panRecognizer)
            scrollView.removeGestureRecognizer(self.singleTapRecognizer)
            
        }else if(self.scrollView.zoomScale == self.scrollView.minimumZoomScale){
            self.view.addGestureRecognizer(self.panRecognizer)
            scrollView.addGestureRecognizer(self.singleTapRecognizer)
        }
    }
    
    // MARK: ScrollView
    
    func centerFrameFromImage(image: UIImage?) -> CGRect {
        if image == nil {
            return CGRectZero
        }
        
        let scaleFactor = scrollView.frame.size.width / image!.size.width
        let newHeight = image!.size.height * scaleFactor
        
        var newImageSize = CGSize(width: scrollView.frame.size.width, height: newHeight)
        
        newImageSize.height = min(scrollView.frame.size.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: scrollView.frame.size.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func zoomInZoomOut(point: CGPoint!) {
        let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoomToRect(rectToZoom, animated: true)
    }
    
    func setUpStatusView() {
        statusView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        statusView.backgroundColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 0.80)
        statusView.hidden = true
        statusView.center = self.view.center
        statusView.layer.cornerRadius = 20
        self.view.addSubview(statusView)
        
        successImage = UIImageView(frame: CGRect(x: 0, y: 15, width: 40, height: 30))
        successImage.image = UIImage(named: "check")
        successImage.center.x = statusView.frame.width/2
        successImage.hidden = true
        statusView.addSubview(successImage)
        
        failureImage = UIImageView(frame: CGRect(x: 0, y: 15, width: 35, height: 35))
        failureImage.image = UIImage(named: "closebutton")
        failureImage.center.x = statusView.frame.width/2
        failureImage.hidden = true
        statusView.addSubview(failureImage)
        
        statusLabel = UILabel(frame: CGRect(x: 0, y: 55, width: 100, height: 35))
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.textAlignment = .Center
        statusLabel.font = UIFont(name: fontName, size: 16)
        statusLabel.center.x = statusView.frame.width/2
        statusView.addSubview(statusLabel)
    }
    
    func showStatusView(isSucess: Bool) {
        if isSucess {
            statusView.hidden = false
            successImage.hidden = false
            failureImage.hidden = true
            statusLabel.text = "Saved"
        } else {
            statusView.hidden = false
            successImage.hidden = true
            failureImage.hidden = false
            statusLabel.text = "failed"
        }
    }
    
    func startHideStatusViewTimer() {
        hideStatusViewTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("hideStatusView"), userInfo: nil, repeats: false)
    }
    
    func hideStatusView() {
        statusView.hidden = true
    }
    
    // MARK: Fix to portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}

