//
//  AboutViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/4/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit


class AboutViewController: UIViewController, UITextFieldDelegate {
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()
    
    var layoutManager:NSLayoutManager!
    var textContainer:NSTextContainer!
    var textStorage:NSTextStorage!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        setUpNavigationBar()
        setUpVersionView()
        setUpCopyrightView()
    }
    func setUpNavigationBar() {
        self.navigationItem.title = "About"
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    func setUpVersionView() {
        let imageWidth: CGFloat = 100
        let logoImageView: UIImageView = UIImageView(frame: CGRectMake((self.viewWidth - imageWidth) / 2, 40, imageWidth, imageWidth))
        logoImageView.image = UIImage(named: "splash_logo")
        self.view.addSubview(logoImageView)
        
        let versionLabel: UILabel = UILabel()
        versionLabel.frame = CGRectMake((self.viewWidth - imageWidth) / 2, 40 + imageWidth, imageWidth, 44)
        versionLabel.textAlignment = NSTextAlignment.Center
        versionLabel.text = "Version " + VERSION_NUMBER
        self.view.addSubview(versionLabel)
    }
    
    func setUpCopyrightView() {
        let imageWidth: CGFloat = 200
        
        let string = "Copyright \(COPYRIGHTYEAR) Twistjam. All Rights Reserved"
        let text = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont(name: fontName, size: 16)!])
        text.addAttribute(NSLinkAttributeName, value: "https://www.twistjam.com", range: NSMakeRange(15, 8))
        text.addAttribute(NSLinkAttributeName, value: "https://www.twistjam.com", range: NSMakeRange(29, 6))
        
        let copyrightLabel: UILabel = UILabel()
        copyrightLabel.userInteractionEnabled = true
        let tapOnLabel: UITapGestureRecognizer = UITapGestureRecognizer()
        tapOnLabel.addTarget(self, action: "handleTapGesture:")
        copyrightLabel.addGestureRecognizer(tapOnLabel)
        copyrightLabel.frame = CGRectMake((self.viewWidth - imageWidth) / 2, 80 + imageWidth, imageWidth, 88)
        copyrightLabel.textAlignment = NSTextAlignment.Center
        copyrightLabel.numberOfLines = 2
        copyrightLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        copyrightLabel.attributedText = text
        self.view.addSubview(copyrightLabel)
        
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer(size: CGSizeZero)
        textStorage = NSTextStorage(attributedString: text)
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
    }
    
    func handleTapGesture(sender: UITapGestureRecognizer) {
        let locationOfTouchInLabel:CGPoint = sender.locationInView(sender.view)
        let labelSize:CGSize = sender.view!.bounds.size
        let textBoundingBox:CGRect = self.layoutManager.usedRectForTextContainer(self.textContainer)
        
        let textContainerOffset:CGPoint = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer:CGPoint = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
            locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter:NSInteger = self.layoutManager.characterIndexForPoint(locationOfTouchInTextContainer,
            inTextContainer:self.textContainer,
            fractionOfDistanceBetweenInsertionPoints:nil)
        
        let linkRange1:NSRange = NSMakeRange(15, 8)
        let linkRange2: NSRange = NSMakeRange(29, 6)
        if (NSLocationInRange(indexOfCharacter, linkRange1)) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.twistjam.com")!)
        } else if (NSLocationInRange(indexOfCharacter, linkRange2)) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.twistjam.com")!)
        }
    }
}
