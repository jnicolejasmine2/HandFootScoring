//
//  ProfileGame.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//


import UIKit
import CoreData

class ProfileGame: NSManagedObject {

    struct Keys {
        static let gameProfileId = "gameProfileId"
        static let gameDescription = "gameDescription"
        static let maximumNumberOfTeams = "maximumNumberOfTeams"
        static let meldOption = "meldOption"  // Round / Threshold
        static let meld1Value = "meld1Value"
        static let meld2Value = "meld2Value"
        static let meld3Value = "meld3Value"
        static let meld4Value = "meld4Value"
        static let meld1Threshold = "meld1Threshold"
        static let meld2Threshold = "meld2Threshold"
        static let meld3Threshold = "meld3Threshold"
        static let meld4Threshold = "meld4Threshold"
        static let profileScoreElementId = "profileScoreElementId"


    }

    @NSManaged var gameProfileId: String
    @NSManaged var gameDescription: String
    @NSManaged var maximumNumberOfTeams: NSNumber
    @NSManaged var meldOption: String
    @NSManaged var meld1Value: String
    @NSManaged var meld2Value: String
    @NSManaged var meld3Value: String
    @NSManaged var meld4Value: String
    @NSManaged var meld1Threshold: NSNumber
    @NSManaged var meld2Threshold: NSNumber
    @NSManaged var meld3Threshold: NSNumber
    @NSManaged var meld4Threshold: NSNumber
    @NSManaged var profileScoreElementId: String
    @NSManaged var profileScoreElements: [ProfileScoreElement]


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

               // Prepare for Core Data Insert
        let entity =  NSEntityDescription.entityForName("ProfileGame", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        print("Begin Init Game")

        // Initialize the data elements for the Pin
        gameProfileId = dictionary[Keys.gameProfileId] as! String
        gameDescription = dictionary[Keys.gameDescription] as! String
        maximumNumberOfTeams = dictionary[Keys.maximumNumberOfTeams] as! NSNumber
        meldOption = dictionary[Keys.meldOption] as! String
        meld1Value = dictionary[Keys.meld1Value] as! String
        meld2Value = dictionary[Keys.meld2Value] as! String
        meld3Value = dictionary[Keys.meld3Value] as! String
        meld4Value = dictionary[Keys.meld4Value] as! String
        meld1Threshold = dictionary[Keys.meld1Threshold] as! NSNumber
        meld2Threshold = dictionary[Keys.meld2Threshold] as! NSNumber
        meld3Threshold = dictionary[Keys.meld3Threshold] as! NSNumber
        meld4Threshold = dictionary[Keys.meld4Threshold] as! NSNumber
        profileScoreElementId = dictionary[Keys.profileScoreElementId] as! String

           print("End Init Game")
    }
}
