//
//  LoadProfiles.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//


import UIKit
import CoreData



class LoadProfiles: NSObject, NSFetchedResultsControllerDelegate {



    var gameArray = [
        [
            ProfileGame.Keys.gameProfileId : "HNFThreshhold",
            ProfileGame.Keys.gameDescription : "Hand, Knee & Foot",
            ProfileGame.Keys.maximumNumberOfTeams : 2,
            ProfileGame.Keys.meldOption : "Threshhold",
            ProfileGame.Keys.meld1Value : "50",
            ProfileGame.Keys.meld2Value : "90",
            ProfileGame.Keys.meld3Value : "120",
            ProfileGame.Keys.meld4Value : "150",
            ProfileGame.Keys.meld1Threshold : 0,
            ProfileGame.Keys.meld2Threshold : 15000,
            ProfileGame.Keys.meld3Threshold : 30000,
            ProfileGame.Keys.meld4Threshold : 50000,
            ProfileGame.Keys.profileScoreElementId : "HNF"
        ],

        [
            ProfileGame.Keys.gameProfileId : "HNFStatic",
            ProfileGame.Keys.gameDescription : "Hand, Knee & Foot (Set Meld)",
            ProfileGame.Keys.maximumNumberOfTeams : 2,
            ProfileGame.Keys.meldOption : "Static",
            ProfileGame.Keys.meld1Value : "50",
            ProfileGame.Keys.meld2Value : "90",
            ProfileGame.Keys.meld3Value : "120",
            ProfileGame.Keys.meld4Value : "150",
            ProfileGame.Keys.meld1Threshold : 0,
            ProfileGame.Keys.meld2Threshold : 0,
            ProfileGame.Keys.meld3Threshold : 0,
            ProfileGame.Keys.meld4Threshold : 0,
            ProfileGame.Keys.profileScoreElementId : "HNF"
        ],
        [
            ProfileGame.Keys.gameProfileId : "HFStatic",
            ProfileGame.Keys.gameDescription : "Hand & Foot",
            ProfileGame.Keys.maximumNumberOfTeams : 2,
            ProfileGame.Keys.meldOption : "Static",
            ProfileGame.Keys.meld1Value : "50",
            ProfileGame.Keys.meld2Value : "90",
            ProfileGame.Keys.meld3Value : "120",
            ProfileGame.Keys.meld4Value : "150",
            ProfileGame.Keys.meld1Threshold : 0,
            ProfileGame.Keys.meld2Threshold : 0,
            ProfileGame.Keys.meld3Threshold : 0,
            ProfileGame.Keys.meld4Threshold : 0,
            ProfileGame.Keys.profileScoreElementId : "H&F"
        ],
        [
            ProfileGame.Keys.gameProfileId : "HFStatic3Team",
            ProfileGame.Keys.gameDescription : "Hand & Foot (3 Teams)",
            ProfileGame.Keys.maximumNumberOfTeams : 3,
            ProfileGame.Keys.meldOption : "Static",
            ProfileGame.Keys.meld1Value : "50",
            ProfileGame.Keys.meld2Value : "90",
            ProfileGame.Keys.meld3Value : "120",
            ProfileGame.Keys.meld4Value : "150",
            ProfileGame.Keys.meld1Threshold : 0,
            ProfileGame.Keys.meld2Threshold : 0,
            ProfileGame.Keys.meld3Threshold : 0,
            ProfileGame.Keys.meld4Threshold : 0,
            ProfileGame.Keys.profileScoreElementId : "H&F"
        ]
    ]




    let scoreElementsArray =  [

        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 0,
            ProfileScoreElement.Keys.elementDescription : "Win Bonus",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 1,
            ProfileScoreElement.Keys.pointValue : 200,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 1
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 1,
            ProfileScoreElement.Keys.elementDescription : "Wild's Books",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 3,
            ProfileScoreElement.Keys.pointValue : 2500,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 1,
            ProfileScoreElement.Keys.winNumber : 1
        ],

        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 2,
            ProfileScoreElement.Keys.elementDescription : "7's Books",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 2,
            ProfileScoreElement.Keys.pointValue : 5000,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 1,
            ProfileScoreElement.Keys.winNumber : 1
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 3,
            ProfileScoreElement.Keys.elementDescription : "5's Books",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 2,
            ProfileScoreElement.Keys.pointValue : 3000,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 1,
            ProfileScoreElement.Keys.winNumber : 1
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 4,
            ProfileScoreElement.Keys.elementDescription : "Clean Req'd",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 1,
            ProfileScoreElement.Keys.pointValue : 500,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 1,
            ProfileScoreElement.Keys.winNumber : 1
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 5,
            ProfileScoreElement.Keys.elementDescription : "Dirty Req'd",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 1,
            ProfileScoreElement.Keys.pointValue : 300,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 1,
            ProfileScoreElement.Keys.winNumber : 1
        ],

        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 6,
            ProfileScoreElement.Keys.elementDescription : "Clean Extra Books",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 12,
            ProfileScoreElement.Keys.pointValue : 500,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 7,
            ProfileScoreElement.Keys.elementDescription : "Dirty  Extra Books",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 12,
            ProfileScoreElement.Keys.pointValue : 300,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 8,
            ProfileScoreElement.Keys.elementDescription : "Red 3's",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 13,
            ProfileScoreElement.Keys.pointValue : 100,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 9,
            ProfileScoreElement.Keys.elementDescription : "Red Book Bonus",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 2,
            ProfileScoreElement.Keys.pointValue : 300,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 10,
            ProfileScoreElement.Keys.elementDescription : "Card Count",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 9999,
            ProfileScoreElement.Keys.pointValue : 1,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "HNF",
            ProfileScoreElement.Keys.elementNumber : 11,
            ProfileScoreElement.Keys.elementDescription : "Subtract",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 9999,
            ProfileScoreElement.Keys.pointValue : 1,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ],

        [
            ProfileScoreElement.Keys.gameProfileId : "H&F",
            ProfileScoreElement.Keys.elementNumber : 0,
            ProfileScoreElement.Keys.elementDescription : "Win Bonus",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 1,
            ProfileScoreElement.Keys.pointValue : 300,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 1
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "H&F",
            ProfileScoreElement.Keys.elementNumber : 1,
            ProfileScoreElement.Keys.elementDescription : "Clean Books",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 12,
            ProfileScoreElement.Keys.pointValue : 500,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 1
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "H&F",
            ProfileScoreElement.Keys.elementNumber : 2,
            ProfileScoreElement.Keys.elementDescription : "Dirty Books",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 12,
            ProfileScoreElement.Keys.pointValue : 300,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 1
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "H&F",
            ProfileScoreElement.Keys.elementNumber : 10,
            ProfileScoreElement.Keys.elementDescription : "Card Count",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 9999,
            ProfileScoreElement.Keys.pointValue : 1,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ],
        [
            ProfileScoreElement.Keys.gameProfileId : "H&F",
            ProfileScoreElement.Keys.elementNumber : 11,
            ProfileScoreElement.Keys.elementDescription : "Subtract",
            ProfileScoreElement.Keys.minimumValue : 0,
            ProfileScoreElement.Keys.maximumValue : 9999,
            ProfileScoreElement.Keys.pointValue : 1,
            ProfileScoreElement.Keys.defaultNumber : 0,
            ProfileScoreElement.Keys.requiredNumber : 0,
            ProfileScoreElement.Keys.winNumber : 0
        ]

    ]

     let playersArray =  [

        [
            Player.Keys.name : "GuestA",
            Player.Keys.initials : "GSA",
            Player.Keys.phoneNumber: "9999999999",
            Player.Keys.pictureFileName : "iconHeart"
        ],
        [
            Player.Keys.name : "GuestB",
            Player.Keys.initials : "GSB",
            Player.Keys.phoneNumber : "9999999999",
            Player.Keys.pictureFileName : "iconClub"
        ],
        [
            Player.Keys.name : "GuestC",
            Player.Keys.initials : "GSC",
            Player.Keys.phoneNumber : "9999999999",
            Player.Keys.pictureFileName : "iconSpade"
        ],
        [
            Player.Keys.name : "GuestD",
            Player.Keys.initials : "GSD",
            Player.Keys.phoneNumber : "9999999999",
            Player.Keys.pictureFileName : "iconDiamond"
        ],
        [
            Player.Keys.name : "GuestE",
            Player.Keys.initials : "GSE",
            Player.Keys.phoneNumber : "9999999999",
            Player.Keys.pictureFileName : "iconSpade2"
        ],
        [
            Player.Keys.name : "GuestF",
            Player.Keys.initials : "GSF",
            Player.Keys.phoneNumber : "9999999999",
            Player.Keys.pictureFileName : "iconClub2"
        ]



    ]

    // Load the Game and Score Element profiles for Hand and Foot Game Variations
    func initialLoadOfProfiles() {
        dispatch_async(dispatch_get_main_queue(), {
            var elementIDCounter = 1

            // Load the Games
            for dictionary in self.gameArray {
                let _ = ProfileGame(dictionary: dictionary, context: self.sharedContext)
                ++elementIDCounter
            }


            // load the scoring elements
            for dictionary in self.scoreElementsArray {
                let _ = ProfileScoreElement(dictionary: dictionary, context: self.sharedContext)
            }


            // Load 6 guests
            for dictionary in self.playersArray {
                let _ = Player(dictionary: dictionary, context: self.sharedContext)
            }

            // Save the changes
            CoreDataStackManager.sharedInstance().saveContext()

        })

    }


    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    class func sharedInstance() -> LoadProfiles {
        struct Singleton {
            static var sharedInstance = LoadProfiles()
        }
        return Singleton.sharedInstance
    }



 }
























