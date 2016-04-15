//
//  TextFieldDelegate.swift
//  MemeMe
//
//  Created by Jeanne Nicole Byers on 3/4/2016.
//  Copyright (c) 2016 Jeanne Nicole Byers. All rights reserved.
//
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {

    // Change color of background when focus is moved to the text field
    func textFieldDidBeginEditing(textField: UITextField) {

        textField.backgroundColor = Style.sharedInstance().textHighlightControl()
    }

    // Left the text field change background color back to white
    func textFieldDidEndEditing(textField: UITextField) {

        textField.backgroundColor = UIColor.whiteColor()
    }


    // Limit the number of characters that can be entered
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        if (range.length + range.location) > textField.text!.characters.count {
            return false
        }

        // Working with Profile Name, limit to 8
        if textField.tag == 1 {
            if (textField.text!.characters.count + string.characters.count - range.length) > 8  {
                return false
            } else {
                return true
            }
        }

        // Working with Initials,  limit to 3
        if textField.tag == 2 {
            if (textField.text!.characters.count + string.characters.count - range.length) > 3 {
                return false
            } else {
                return true
            }
        }

        // Working with phone, limit to 10
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
