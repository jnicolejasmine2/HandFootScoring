//
//  ScoreElement.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData

class ScoreElement: NSManagedObject {

    struct Keys {
        static let gameId = "gameId"
        static let roundNumber = "roundNumber"
        static let teamNumber = "teamNumber"
        static let elementNumber = "elementNumber"
        static let elementDescription = "elementDescription"
        static let minimumValue = "minimumValue"
        static let maximumValue = "maximumValue"
        static let pointValue = "pointValue"
        static let defaultNumber = "defaultNumber"
        static let requiredNumber = "requiredNumber"
        static let winNumber = "winNumber"
        static let earnedNumber = "earnedNumber"
    }

    @NSManaged var gameId: String
    @NSManaged var roundNumber: NSNumber
    @NSManaged var teamNumber: NSNumber
    @NSManaged var elementNumber: NSNumber
    @NSManaged var elementDescription: String
    @NSManaged var minimumValue: NSNumber
    @NSManaged var maximumValue: NSNumber
    @NSManaged var pointValue: NSNumber
    @NSManaged var defaultNumber: NSNumber
    @NSManaged var requiredNumber: NSNumber
    @NSManaged var winNumber: NSNumber
    @NSManaged var earnedNumber: NSNumber
    @NSManaged var round: RoundScore


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }


    init(dictionary: [String : AnyObject], context: NSManagedObjectContext, relatedRound: RoundScore) {

        // Prepare for Core Data Insert
        let entity =  NSEntityDescription.entityForName("ScoreElement", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Initialize the data elements for the Score Element
        gameId = dictionary[Keys.gameId] as! String
        roundNumber = dictionary[Keys.roundNumber] as! NSNumber
        teamNumber = dictionary[Keys.teamNumber] as! NSNumber
        elementNumber = dictionary[Keys.elementNumber] as! NSNumber
        elementDescription = dictionary[Keys.elementDescription] as! String
        minimumValue = dictionary[Keys.minimumValue] as! NSNumber
        maximumValue = dictionary[Keys.maximumValue] as! NSNumber
        pointValue = dictionary[Keys.pointValue] as! NSNumber
        defaultNumber = dictionary[Keys.defaultNumber] as! NSNumber
        requiredNumber = dictionary[Keys.requiredNumber] as! NSNumber
        winNumber = dictionary[Keys.winNumber] as! NSNumber
        earnedNumber = 0
        round = relatedRound
    }


    // Called when the earned number is added or subtracted.  Keeps the round total up to date and current.
    func adjustEarnedNumber(adjustedNumber: Int)   {

        // Save off original, it will be subtracted.
        let originalNumberInt = Int(earnedNumber)

        // get the point value
        let pointValueInt = Int(pointValue)

        // set new earned number
        earnedNumber = adjustedNumber

        // Multiple the original and new earned numbers by the point value
        let originalScore = originalNumberInt * pointValueInt
        let newScore = adjustedNumber * pointValueInt

        // Adjust the round total by subtracting original score and adding new score
        var adjustedRoundTotal = Int(round.roundTotal)
        adjustedRoundTotal -= originalScore
        adjustedRoundTotal += newScore

        // Set the round total 
        round.roundTotal = adjustedRoundTotal
    }

}
