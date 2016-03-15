//
//  SharedFunctions.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 3/14/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//


import UIKit
import Foundation

class SharedFunctions {

    func compareDates(fromDate: NSDate, toDate: NSDate, granularity: NSCalendarUnit) -> String {
        // Check if game is in past. If so change the color to a dark disabled color

        let order = NSCalendar.currentCalendar().compareDate(fromDate, toDate: toDate, toUnitGranularity: granularity)

        switch order {
        case .OrderedDescending:
            return "<"
        case .OrderedAscending:
            return ">"
        case .OrderedSame:
            return "="
        }
    }



    class func sharedInstance() -> SharedFunctions {
        struct Singleton {
            static var sharedInstance = SharedFunctions()
        }
        return Singleton.sharedInstance
    }
    
    
    
}


