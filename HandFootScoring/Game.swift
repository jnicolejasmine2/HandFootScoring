//
//  Game.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//
import UIKit
import CoreData

class Game: NSManagedObject {

    struct Keys {
        static let gameId = "gameId"
        static let date = "date"
        static let sectionDate = "sectionDate"

        static let gameDescription = "gameDescription"
        static let maximumNumberOfTeams = "maximumNumberOfTeams"
        static let meldOption = "meldOption"
        static let meld1Value = "meld1Value"
        static let meld2Value = "meld2Value"
        static let meld3Value = "meld3Value"
        static let meld4Value = "meld4Value"
        static let meld1Threshold = "meld1Threshold"
        static let meld2Threshold = "meld2Threshold"
        static let meld3Threshold = "meld3Threshold"
        static let meld4Threshold = "meld4Threshold"
        
        static let team1Player1 = "team1Player1"
        static let team1Player2 = "team1Player2"
        static let team2Player1 = "team2Player1"
        static let team2Player2 = "team2Player2"
        static let team3Player1 = "team3Player1"
        static let team3Player2 = "team3Player2"

        static let team1Player1Initials = "team1Player1Initials"
        static let team1Player2Initials = "team1Player2Initials"
        static let team2Player1Initials = "team2Player1Initials"
        static let team2Player2Initials = "team2Player2Initials"
        static let team3Player1Initials = "team3Player1Initials"
        static let team3Player2Initials = "team3Player2Initials"

        static let team1Player1ImageName = "team1Player1ImageName"
        static let team1Player2ImageName = "team1Player2ImageName"
        static let team2Player1ImageName = "team2Player1ImageName"
        static let team2Player2ImageName = "team2Player2ImageName"
        static let team3Player1ImageName = "team3Player1ImageName"
        static let team3Player2ImageName = "team3Player2ImageName"



        static let lastCompletedRound = "lastCompletedRound"
    }

    @NSManaged var gameId: String
    @NSManaged var date: NSDate
    @NSManaged var sectionDate: String

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

    @NSManaged var team1Player1: String
    @NSManaged var team1Player2: String
    @NSManaged var team2Player1: String
    @NSManaged var team2Player2: String
    @NSManaged var team3Player1: String?
    @NSManaged var team3Player2: String?


    @NSManaged var team1Player1Initials: String
    @NSManaged var team1Player2Initials: String
    @NSManaged var team2Player1Initials: String
    @NSManaged var team2Player2Initials: String
    @NSManaged var team3Player1Initials: String?
    @NSManaged var team3Player2Initials: String?

    @NSManaged var team1Player1ImageName: String
    @NSManaged var team1Player2ImageName: String
    @NSManaged var team2Player1ImageName: String
    @NSManaged var team2Player2ImageName: String
    @NSManaged var team3Player1ImageName: String?
    @NSManaged var team3Player2ImageName: String?



    @NSManaged var lastCompletedRound: NSNumber
    @NSManaged var rounds: [RoundScore]


    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext, profileGame: ProfileGame, profileScoreElementArray: [ProfileScoreElement]) {

        // Prepare for Core Data Insert
        let entity =  NSEntityDescription.entityForName("Game", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Initialize the data elements for the Pin
        gameId = NSUUID().UUIDString

        // Save off
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(gameId, forKey: "lastStartedGameId")


        date = NSDate()
        sectionDate = buildSectionDate(date)

        gameDescription = profileGame.gameDescription
        maximumNumberOfTeams = dictionary[Keys.maximumNumberOfTeams] as! NSNumber
        let numberOfTeams = dictionary[Keys.maximumNumberOfTeams] as! Int

        meldOption = profileGame.meldOption

        meld1Value = profileGame.meld1Value
        meld2Value = profileGame.meld2Value
        meld3Value = profileGame.meld3Value
        meld4Value = profileGame.meld4Value

        meld1Threshold = profileGame.meld1Threshold
        meld2Threshold = profileGame.meld2Threshold
        meld3Threshold = profileGame.meld3Threshold
        meld4Threshold = profileGame.meld4Threshold

        team1Player1 = dictionary[Keys.team1Player1] as! String
        team1Player2 = dictionary[Keys.team1Player2] as! String
        team2Player1 = dictionary[Keys.team2Player1] as! String
        team2Player2 = dictionary[Keys.team2Player2] as! String
        team3Player1 = dictionary[Keys.team3Player1] as? String
        team3Player2 = dictionary[Keys.team3Player2] as? String


        team1Player1Initials = dictionary[Keys.team1Player1Initials] as! String
        team1Player2Initials = dictionary[Keys.team1Player2Initials] as! String
        team2Player1Initials = dictionary[Keys.team2Player1Initials] as! String
        team2Player2Initials = dictionary[Keys.team2Player2Initials] as! String
        team3Player1Initials = dictionary[Keys.team3Player1Initials] as? String
        team3Player2Initials = dictionary[Keys.team3Player2Initials] as? String


        team1Player1ImageName = dictionary[Keys.team1Player1ImageName] as! String
        team1Player2ImageName = dictionary[Keys.team1Player2ImageName] as! String
        team2Player1ImageName = dictionary[Keys.team2Player1ImageName] as! String
        team2Player2ImageName = dictionary[Keys.team2Player2ImageName] as! String
        team3Player1ImageName = dictionary[Keys.team3Player1ImageName] as? String
        team3Player2ImageName = dictionary[Keys.team3Player2ImageName] as? String

        lastCompletedRound = 0


        // Load the 4 rounds for each time, also loading the score elements (aka rules)
        for teamNumber in 0...(numberOfTeams - 1) {
        
            for roundNumber in 0...3 {

                // Save the rounds to core data
                let dictionary: [String : AnyObject] = [
                    RoundScore.Keys.gameId : self.gameId,
                    RoundScore.Keys.roundNumber : roundNumber + 1,
                    RoundScore.Keys.teamNumber : teamNumber + 1,
                    RoundScore.Keys.roundTotal : 0
                
                ]
                let newRound = RoundScore(dictionary: dictionary, context: self.sharedContext, relatedGame: self)

                for scoreElement in profileScoreElementArray{

                    // Save the score elements fo each round 
                    let dictionary: [String : AnyObject] = [
                        ScoreElement.Keys.gameId : self.gameId,
                        ScoreElement.Keys.roundNumber : roundNumber + 1,
                        ScoreElement.Keys.teamNumber : teamNumber + 1,

                        ScoreElement.Keys.elementNumber : scoreElement.elementNumber,
                        ScoreElement.Keys.elementDescription : scoreElement.elementDescription,
                        ScoreElement.Keys.minimumValue : scoreElement.minimumValue,
                        ScoreElement.Keys.maximumValue : scoreElement.maximumValue,
                        ScoreElement.Keys.pointValue : scoreElement.pointValue,
                        ScoreElement.Keys.defaultNumber : scoreElement.defaultNumber,
                        ScoreElement.Keys.requiredNumber : scoreElement.requiredNumber,
                        ScoreElement.Keys.winNumber : scoreElement.winNumber,
                        ScoreElement.Keys.earnedNumber : 0
                    ]
                    let _ = ScoreElement(dictionary: dictionary, context: self.sharedContext, relatedRound: newRound)
                }
            }
        }
    }


    // Get day of week name 

    func buildSectionDate(todayDate: NSDate) -> String {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.stringFromDate(todayDate)

        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Month, .Year], fromDate: todayDate)
        let year = components.year
        let month = components.month
        let day = components.day
        
        let sectionDateFormatted: String = dayOfWeekString + ", " + String(month) + "/" + String(day) + "/" + String(year)
        return sectionDateFormatted
    }


    func getCurrentDate(todayDate: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.stringFromDate(todayDate)
        return dayOfWeekString
    }

    // When a photo is deleted from core data delete the corresponding document
    override func prepareForDeletion() {
    }

     // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


}

