//
//  RoundScore.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData

class RoundScore: NSManagedObject {

    struct Keys {
        static let gameId = "gameId"
        static let roundNumber = "roundNumber"
        static let teamNumber = "teamNumber"
        static let roundTotal = "total"
        static let game = "game"
    }

    @NSManaged var gameId: String
    @NSManaged var roundNumber: NSNumber
    @NSManaged var teamNumber: NSNumber
    @NSManaged var roundTotal: NSNumber
    @NSManaged var game: Game!
    @NSManaged var scoreElements: [ScoreElement]



    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }


    init(dictionary: [String : AnyObject], context: NSManagedObjectContext, relatedGame: Game) {

        // Prepare for Core Data Insert
        let entity =  NSEntityDescription.entityForName("RoundScore", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Initialize the data elements for the Round Score
        gameId = dictionary[Keys.gameId] as! String
        roundNumber = dictionary[Keys.roundNumber] as! NSNumber
        teamNumber = dictionary[Keys.teamNumber] as! NSNumber
        roundTotal = 0
        game = relatedGame
    }

}
