//
//  Style.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 3/9/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import Foundation

class Style {

    let blue = "#3f85eb"
    let yellow = "#fbb548"
    let red = "#fb4848"
     let grey = "#bbbbbb"


    func team1ButtonBackgroundColor() -> UIColor {
        let color = colorWithHexString(red).colorWithAlphaComponent(0.15)
        return color
    }

    func team2ButtonBackgroundColor() -> UIColor {
        let color = colorWithHexString(blue).colorWithAlphaComponent(0.15)

        return color
    }

    func team3ButtonBackgroundColor() -> UIColor {
        let color = colorWithHexString(yellow).colorWithAlphaComponent(0.15)

        return color
    }


    func gameSelectionControl() -> UIColor {
        let color = colorWithHexString(blue)
        return color
    }


    func keyButtonControl() -> UIColor {
        let color = colorWithHexString(blue)
        return color
    }

    func keyButtonControlSecondary() -> UIColor {
        let color = colorWithHexString(red)
        return color
    }


    func keyButtonControlDisabled() -> UIColor {
        let color = colorWithHexString(blue).colorWithAlphaComponent(0.35)

        return color
    }



    func textHighlightControl() -> UIColor {
        let color = colorWithHexString(blue).colorWithAlphaComponent(0.15)

        return color
    }


    func teamRoundDisabled() -> UIColor {
        let color = colorWithHexString(grey).colorWithAlphaComponent(0.15)

        return color
    }


    func tableHeader() -> UIColor {
         let color = colorWithHexString(blue)
        return color
    }


    func tableDisabled() -> UIColor {
        let color = colorWithHexString(grey).colorWithAlphaComponent(0.15)

        return color
    }

    func tableCompleted() -> UIColor {
        let color = colorWithHexString(blue).colorWithAlphaComponent(0.35)

        return color
    }


    func tableBackgroundColor() -> UIColor {
        let color = colorWithHexString(blue).colorWithAlphaComponent(0.15)

        return color
    }





    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString

        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }

        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }

        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)

        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)


        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }



    class func sharedInstance() -> Style {
        struct Singleton {
            static var sharedInstance = Style()
        }
        return Singleton.sharedInstance
    }
    


}



