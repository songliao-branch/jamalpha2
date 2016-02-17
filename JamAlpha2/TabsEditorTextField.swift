//
//  TabsEditorTextField.swift
//  JamAlpha2
//
//  Created by Jun Zhou on 2/16/16.
//  Copyright © 2016 Song Liao. All rights reserved.
//

import Foundation
import UIKit

extension TabsEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
      tabFingerPointChanged = true
      if (tempTapView == nil) {
        tempTapView = UIView()
        tempTapView!.frame = completeStringView.frame
        tempTapView!.backgroundColor = UIColor.clearColor()
        editView.addSubview(tempTapView!)
      }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
      if tempTapView != nil {
        tempTapView!.removeFromSuperview()
        tempTapView = nil
      }
      if (specificTabsScrollView.subviews.count == 1 && specificTabsScrollView.subviews[0].isKindOfClass(UILabel) && !isTextChanged){
        removeObjectsOnSpecificTabsScrollView()
        tabNameTextField.text = ""
      }else if pressDoneButton && !isTextChanged {
        tabNameTextField.text = ""
      }
      pressDoneButton = false
      isTextChanged = false
    }
    
    func textFieldTextChanged(textField : UITextField){
      let tempString = tabNameTextField.text?.replace(" ", replacement: "")
      if tempString != self.currentBaseButton.titleLabel!.text {
        isTextChanged = true
      }else{
        isTextChanged = false
      }
    }
}