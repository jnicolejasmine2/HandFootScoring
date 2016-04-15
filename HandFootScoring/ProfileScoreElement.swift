//
//  ProfileScoreElement.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData

class ProfileScoreElement: NSManagedObject {

    struct Keys {
        static let gameProfileId = "gameProfileId"
        static let elementNumber = "elementNumber"
        static let elementDescription = "elementDescription"
        static let minimumValue = "minimumValue"
        static let maximumValue = "maximumValue"
        static let pointValue = "pointValue"
        static let defaultNumber = "defaultNumber"
        static let requiredNumber = "requiredNumber"
        static let winNumber = "winNumber"
    }

    @NSManaged var gameProfileId: String
    @NSManaged var elementNumber: NSNumber
    @NSManaged var elementDescription: String
    @NSManaged var minimumValue: NSNumber
    @NSManaged var maximumValue: NSNumber
    @NSManaged var pointValue: NSNumber
    @NSManaged var defaultNumber: NSNumber
    @NSManaged var requiredNumber: NSNumber
    @NSManaged var winNumber: NSNumber
    @NSManaged var profileGame: ProfileGame



    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        // Prepare for Core Data Insert
        let entity =  NSEntityDescription.entityForName("ProfileScoreElement", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Initialize the data elements for the Profile Score Element
        gameProfileId = dictionary[Keys.gameProfileId] as! String
        elementNumber = dictionary[Keys.elementNumber] as! NSNumber
        elementDescription = dictionary[Keys.elementDescription] as! String
        minimumValue = dictionary[Keys.minimumValue] as! NSNumber
        maximumValue = dictionary[Keys.maximumValue] as! NSNumber
        pointValue = dictionary[Keys.pointValue] as! NSNumber
        defaultNumber = dictionary[Keys.defaultNumber] as! NSNumber
        requiredNumber = dictionary[Keys.requiredNumber] as! NSNumber
        winNumber = dictionary[Keys.winNumber] as! NSNumber
    }

}
