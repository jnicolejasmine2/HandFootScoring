//
//  TextFieldDelegate.swift
//  MemeMe
//
//  Created by Jeanne Nicole Byers on 3/4/2016.
//  Copyright (c) 2016 Jeanne Nicole Byers. All rights reserved.
//
////

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {

    // Clear text field before accepting new text
    func textFieldDidBeginEditing(textField: UITextField) {

        textField.backgroundColor = Style.sharedInstance().textHighlightControl() 

    }

    // Clear text field before accepting new text
    func textFieldDidEndEditing(textField: UITextField) {

        textField.backgroundColor = UIColor.whiteColor()
        
    }


    // Convert both textfields UpperCase
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //    textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)

        if (range.length + range.location) > textField.text!.characters.count {
            return false
        }

        // Working with Profile Name
        if textField.tag == 1 {

            if (textField.text!.characters.count + string.characters.count - range.length) > 8  {
                return false
            } else {
                return true
            }
        }

        // Working with Initials
        if textField.tag == 2 {

            if (textField.text!.characters.count + string.characters.count - range.length) > 3 {

                return false
            } else {

                return true
            }
        }




        // Working with phone
        if textField.tag == 4 {

            if (textField.text!.characters.count + string.characters.count - range.length) > 10  {
                return false
            } else {
                return true
            }
        }


        return true
    }


    // Allows the keyboard to be closed
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
}


