//
//  UpdateNickNameViewController.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 12/3/15.
//  Copyright © 2015 Song Liao. All rights reserved.
//

import UIKit

class UpdateNickNameViewController: UIViewController {
    
    var viewWidth: CGFloat = CGFloat()
    var viewHeight: CGFloat = CGFloat()

    var nickNameEditTextField: UITextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewWidth = self.view.frame.size.width
        self.viewHeight = self.view.frame.size.height
        // Do any additional setup after loading the view.
        setUpNavigationBar()
        setUpNickNameEditTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.barTintColor = UIColor.mainPinkColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.title = "Edit Name"
        
        let saveButton: UIBarButtonItem = UIBarButtonItem()
        saveButton.title = "Save"
        saveButton.action = "pressSaveButton:"
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func setUpNickNameEditTextField() {

        nickNameEditTextField.frame = CGRectMake(20, 0, self.viewWidth - 40, 44)
        if let oldNickName = CoreDataManager.getCurrentUser()?.nickName {
            nickNameEditTextField.placeholder = oldNickName
        }
        nickNameEditTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        nickNameEditTextField.textAlignment = .Center
        nickNameEditTextField.tintColor = UIColor.mainPinkColor()
        nickNameEditTextField.autocapitalizationType = .None
        nickNameEditTextField.autocorrectionType = .No
        self.view.addSubview(nickNameEditTextField)
        
        let bottomBorder: CALayer = CALayer()
        bottomBorder.frame = CGRectMake(0, 43, nickNameEditTextField.frame.size.width, 1);
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        nickNameEditTextField.layer.addSublayer(bottomBorder)
    }
    
    func setUpNickNameTitle() {
        let titleLabel: UILabel = UILabel()
        titleLabel.frame = CGRectMake(20, 44, self.viewWidth - 40, 22)
        titleLabel.text = "Pick a nick name easy to remember"
        self.view.addSubview(titleLabel)
    }
    
    func pressSaveButton(sender: UIButton) {
        if let name = nickNameEditTextField.text {
            let saveSuccess = CoreDataManager.updateUserProfileNickName((CoreDataManager.getCurrentUser()?.email)!, nickName: name)
            if saveSuccess {
                let refreshAlert = UIAlertController(title: "Save Nick Name", message: "Save Nick Name Successful", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            } else {
                let refreshAlert = UIAlertController(title: "Save Nick Name", message: "Save Nick Name Error", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}
