//
//  Player.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData

class Player: NSManagedObject {

    struct Keys {
        static let name = "name"
        static let initials = "initials"
        static let emailAddress = "emailAddress"
        static let phoneNumber = "phoneNumber"
        static let pictureFileName = "pictureFileName"
        static let groupID = "groupID"
    }

    @NSManaged var name: String
    @NSManaged var initials: String
    @NSManaged var emailAddress: String?
    @NSManaged var phoneNumber: NSNumber?
    @NSManaged var pictureFileName: String!
    @NSManaged var groupID: String!

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        // Prepare for Core Data Insert
        let entity =  NSEntityDescription.entityForName("Player", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Initialize the data elements for the Player
        name = dictionary[Keys.name] as! String
        initials = dictionary[Keys.initials] as! String
        emailAddress = dictionary[Keys.emailAddress] as? String
        phoneNumber = dictionary[Keys.phoneNumber] as? NSNumber
        pictureFileName = dictionary[Keys.pictureFileName] as! String
        groupID = dictionary[Keys.groupID] as! String
     }

}
