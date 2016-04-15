//
//  GameSummaryViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData

class GameSummaryViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // Passed when a game is selected from the game or is the active game
    var selectedGame: Game?
    var team1Initials = " "
    var team2Initials = " "
    var team3Initials = " "

    // Array of rounds for the game
    var fetchedRounds: [RoundScore] = []

    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()


    // Outlets
    @IBOutlet weak var navigationBar: UINavigationBar!



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Format Game's date for the view title
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        navigationBar.topItem!.title = "Summary: " + dateFormatter.stringFromDate(selectedGame!.date)


        // Fetch the round for the game
        do {
            try fetchedResultsControllerRound.performFetch()
        } catch {}
        fetchedResultsControllerRound.delegate = self
        fetchedRounds = fetchedResultsControllerRound.fetchedObjects as! [RoundScore]


        // Fetch the selected Round... Needed if the players are changed
        do {
            try fetchedResultsControllerSelectedGame.performFetch()
        } catch {}
        fetchedResultsControllerSelectedGame.delegate = self


        // Load the round/team buttons with their scores
        loadRoundTeamButtons()
    }



  // ***** BUTTON MANAGEMENT  **** //

    // Back to Game button chosen, dismiss view controller
    @IBAction func backToGamesButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }



    // A team/round was selected.  Give control to the Round Score VC to gather the score details
    @IBAction func roundSelectedButton(sender: AnyObject) {

        if  let tagID = sender.tag {

            // Separate the tag into the selected Round and Selected Team
            let tagDictionary = sf.separateTagId(tagID, option: "RoundTeam" )
            let selectedRound = Int(tagDictionary["round"]!)
            let selectedTeam = Int(tagDictionary["team"]!)

            // Check if we selected a round instead of the titles, totals and meld
            if selectedRound > 0 && selectedRound < 5 {

                var roundScoreController: RoundScoreViewController
                if selectedGame!.description.rangeOfString("Hand & Foot") != nil {
                    // Hand & Foot
                    roundScoreController = storyboard!.instantiateViewControllerWithIdentifier("HFRoundScoreViewController") as! RoundScoreViewController
                } else {
                    // Hand, Knee and Foot
                    roundScoreController = storyboard!.instantiateViewControllerWithIdentifier("RoundScoreViewController") as! RoundScoreViewController
                }

                // Pass information to the controller: game ID, round and team
                roundScoreController.selectedGameID = selectedGame!.gameId
                roundScoreController.selectedRoundNumber = selectedRound
                roundScoreController.selectedTeamNumber = selectedTeam

                // Pass information to the controller: Title that shows the round and the team initials
                // Also pass the initials for the other 2 teams
                let teamInformation = getCurrentTeamInformation(selectedTeam!)

                roundScoreController.selectedViewTitle = "Round: " + String(selectedRound!) + " Team: " + teamInformation["TeamInitials"]!
                roundScoreController.otherTeamInitials =  teamInformation["OtherTeam1Initials"]!
                roundScoreController.Other3rdTeamInitials =  teamInformation["OtherTeam2Initials"]!

                // Present the view controller
                presentViewController(roundScoreController, animated: true, completion: nil)
            }
        }
    }


    // ***** ROUND/TEAM CONTROLS MANAGEMENT  **** //

    // Load the headers, round scores, totals and meld for all the teams
    func loadRoundTeamButtons() {

        // set the initials and images for the team players
        initializePlayerTeamHeadings()

        // Run through all the rounds to total up scores and differences
        let totalDictionary = totalScores()

        // Loop through the rounds, loading the round scores into the buttons
        for fetchedRound in fetchedResultsControllerRound.fetchedObjects as! [RoundScore] {

            // If past date then grey out and disable buttons
            var backgoundColor = sf.setTeamBackgroundColor(String(Int(fetchedRound.teamNumber)))
            var disableOption = false
            if sf.compareDates(NSDate(), toDate: selectedGame!.date, granularity: .Day) != "=" {
                backgoundColor = Style.sharedInstance().teamRoundDisabled()
                disableOption = true
            }

            // Load the round scores
            let tagString =  String(fetchedRound.roundNumber) + String(fetchedRound.teamNumber)
            let tagID = Int(tagString)

            // set the round button
            sf.setButtonRound (view.viewWithTag(tagID!) as? UIButton, imageTextString: sf.formatScore(Int(fetchedRound.roundTotal)), backgroundColor: backgoundColor, toDate: selectedGame!.date, disable: disableOption )

            // Calculate the difference
            var teamScore = 0
            var teamScoreDifference = 0
            switch Int(fetchedRound.teamNumber) {
            case 1:
                teamScore = totalDictionary["team1TotalScore"]!
                teamScoreDifference = totalDictionary["team1ScoreDifference"]!
                 break
            case 2:
                teamScore = totalDictionary["team2TotalScore"]!
                teamScoreDifference = totalDictionary["team2ScoreDifference"]!
                break
            case 3:
                teamScore = totalDictionary["team3TotalScore"]!
                teamScoreDifference = totalDictionary["team3ScoreDifference"]!
                 break
            default:
                break
            }

            // Set the difference in the button
            var differenceText = " "
            if teamScoreDifference > 0{
                differenceText = "-" + sf.formatScore(teamScoreDifference)
            }
            sf.setButtonRound (view.viewWithTag(50 + Int(fetchedRound.teamNumber)) as? UIButton, imageTextString: sf.formatScore(teamScore)  + "\n" + differenceText, backgroundColor: backgoundColor, toDate: selectedGame!.date, disable: disableOption  )


            // Set the Melds, first determine last completed round for the static option, then set the meld button
            let lastCompletedRound = sf.determineLastCompletedRound(selectedGame!, fetchedRounds: fetchedRounds)

            let meld = sf.determineMeld(selectedGame!, gameTotalScore: teamScore, lastCompletedRound: lastCompletedRound)

            sf.setButtonRound (view.viewWithTag(60 + Int(fetchedRound.teamNumber)) as? UIButton, imageTextString: meld , backgroundColor: backgoundColor, toDate: selectedGame!.date, disable: disableOption  )
        }


        // The icon in the round indicates which rounds are completed.
        setRoundIconsBasedOnStatus()

        // Clear out controls for team 3 if there are less than 3 teams in the game 
        clearTeamThree()
    }



    // Set the icons based on the status of the round, complete or not
    func setRoundIconsBasedOnStatus() {

        // Set the round icons
        // First, determine last completed round for the static option
        let lastCompletedRound = sf.determineLastCompletedRound(selectedGame!, fetchedRounds: fetchedRounds)

        // Loop through the 4 rounds determining what the status is
        // and then setting the icon that matches that status
        for round in 1...4 {
            var roundIcon: String

            if lastCompletedRound >= round {
                roundIcon = "iconRound" + String(round)

            } else {
                roundIcon = "iconRound" + String(round) + "NotStarted"
            }

            sf.setImage (view.viewWithTag(90 + round) as? UIImageView , imageTextString: roundIcon)

            // Loop through the team/round buttons and if we are not at that round
            // disable the button so scores can be added in advance
            for team in 1...3 {
                let tagString = String(round) + String(team)
                let tagIDRound = Int(tagString)

                let lastCompletedRoundPlusNext = lastCompletedRound + 1

                if lastCompletedRoundPlusNext < round {
                    sf.setButtonRound (view.viewWithTag(tagIDRound!) as? UIButton, imageTextString: " ", backgroundColor: Style.sharedInstance().teamRoundDisabled(), toDate: selectedGame!.date, disable: true  )
                }
            }
        }
    }


    // If there is no team 3, need to set the labels and the buttons to whitespace
    // and blanks to hid time 3. 
    func clearTeamThree()  {

        let selectedNumberOfTeams = Int(selectedGame!.maximumNumberOfTeams)
        if selectedNumberOfTeams < 3 {

            // Loop through the 3 controls for the team and clear the buttons and labels
            for control in 0...8 {

                let team = "3"
                let tagString = String(control) + team
                let tagID = Int(tagString)

                if control > 0 && control < 7 {
                    sf.setButtonRound (view.viewWithTag(tagID!) as? UIButton, imageTextString: " ", backgroundColor: UIColor.whiteColor(), toDate: selectedGame!.date, disable: true  )

                } else {
                    sf.setLabel (view.viewWithTag(tagID!) as? UILabel, imageTextString: " ", backgroundColor: UIColor.whiteColor() )
                }
            }
        }
    }



    // Update the last completed round which indicates the status of the game.  Based on
    // the last completed round the icon for 1/4, 2/4, 3/4 or 4/4 rounds completed shows in table view.
    func setGameStatus() {

        let lastCompletedRound = sf.determineLastCompletedRound(selectedGame!, fetchedRounds: fetchedRounds)
        selectedGame!.lastCompletedRound = lastCompletedRound
        CoreDataStackManager.sharedInstance().saveContext()
    }



    // Total the round scores for all the teams and build a dictionary to be used.
    func totalScores() -> [String: Int!] {

        var team1TotalScore = 0
        var team2TotalScore = 0
        var team3TotalScore = 0

        var lastCompletedRoundTeam1: Int = 0
        var lastCompletedRoundTeam2: Int = 0
        var lastCompletedRoundTeam3: Int = 0


        // Loop through the rounds, loading the round scores into the buttons
        // Calculate the game total for each of the teams
        // Determine the lastcompletedround so the meld can be determined
        for fetchedRound in fetchedResultsControllerRound.fetchedObjects as! [RoundScore] {

            let team = String(fetchedRound.teamNumber)

            switch team {
            case "1":
                // add to team's total score
                team1TotalScore += Int(fetchedRound.roundTotal)

                // If the round total score is not equal to zero then the round for the team was completed
                if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam1 {
                    lastCompletedRoundTeam1 = Int(fetchedRound.roundNumber)
                }
                break

            case "2":
                // add to team's total score
                team2TotalScore += Int(fetchedRound.roundTotal)

                // If the round total score is not equal to zero then the round for the team was completed
                if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam2 {
                    lastCompletedRoundTeam2 = Int(fetchedRound.roundNumber)
                }
                break

            case "3":
                // add to team's total score
                team3TotalScore += Int(fetchedRound.roundTotal)

                // If the round total score is not equal to zero then the round for the team was completed
                if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam3 {
                    lastCompletedRoundTeam3 = Int(fetchedRound.roundNumber)
                }
                break

            default:
                break
            }
        }


        // Then determine what is the highest score
        var winningGameTotal = 0
        if team1TotalScore > team2TotalScore && team1TotalScore > team3TotalScore {
            winningGameTotal = team1TotalScore
        }

        if team2TotalScore > team1TotalScore && team2TotalScore > team3TotalScore {
            winningGameTotal = team2TotalScore
        }
        
        if team3TotalScore > team1TotalScore && team3TotalScore > team2TotalScore {
            winningGameTotal = team3TotalScore
        }

        return  [
            "team1TotalScore" : team1TotalScore,
            "team2TotalScore" : team2TotalScore,
            "team3TotalScore" : team3TotalScore,
            "lastCompletedRoundTeam1" : lastCompletedRoundTeam1,
            "lastCompletedRoundTeam2" : lastCompletedRoundTeam2,
            "lastCompletedRoundTeam3" : lastCompletedRoundTeam3,
            "team1ScoreDifference" : winningGameTotal - team1TotalScore,
            "team2ScoreDifference" : winningGameTotal - team2TotalScore,
            "team3ScoreDifference" : winningGameTotal - team3TotalScore,
            "winningGameTotal" : winningGameTotal
        ]
    }



    // Set the team initials and images
    func initializePlayerTeamHeadings() {

        // loop through each of the teams.
        for team in 1...3 {

            // Get the team information
            let teamInformation = getCurrentTeamInformation(team)

            // set the team Initials
            sf.setLabel (view.viewWithTag(team) as? UILabel, imageTextString: teamInformation["TeamInitials"], backgroundColor: UIColor.whiteColor() )

            if team != 3 || (selectedGame!.maximumNumberOfTeams == 3) {
                // set the team Player 1 Image
                sf.setImage (view.viewWithTag(70 + team) as? UIImageView, imageTextString: teamInformation["Player1ImageName"])

                // set the team Player 2 Image
                sf.setImage (view.viewWithTag(80 + team) as? UIImageView, imageTextString: teamInformation["Player2ImageName"])
            }
        }
    }


    // Get the current team inforamtion based on the team selected
    func getCurrentTeamInformation(team: Int) -> [String: String] {

            var player1Initials = " "
            var player2Initials =  " "
            var player1ImageName = " "
            var player2ImageName =  " "
            var teamInitials = " "
            var otherTeam1Initials = " "
            var otherTeam2Initials =  " "

            switch team {
            case  1:
                player1Initials = selectedGame!.team1Player1Initials
                player2Initials = selectedGame!.team1Player2Initials
                player1ImageName = selectedGame!.team1Player1ImageName
                player2ImageName = selectedGame!.team1Player2ImageName
                otherTeam1Initials = selectedGame!.team2Player1Initials + "/" + selectedGame!.team2Player2Initials
                if selectedGame!.maximumNumberOfTeams == 3 {
                    otherTeam2Initials = selectedGame!.team3Player1Initials! + "/" + selectedGame!.team3Player2Initials!
                }
                teamInitials = player1Initials + "/" + player2Initials
                break

            case  2:
                player1Initials = selectedGame!.team2Player1Initials
                player2Initials = selectedGame!.team2Player2Initials
                player1ImageName = selectedGame!.team2Player1ImageName
                player2ImageName = selectedGame!.team2Player2ImageName
                teamInitials = player1Initials + "/" + player2Initials
                otherTeam1Initials = selectedGame!.team1Player1Initials + "/" + selectedGame!.team1Player2Initials
                if selectedGame!.maximumNumberOfTeams == 3 {
                    otherTeam2Initials = selectedGame!.team3Player1Initials! + "/" + selectedGame!.team3Player2Initials!
                }
                break

            case  3:
                if selectedGame!.maximumNumberOfTeams == 3 {
                    player1Initials = selectedGame!.team3Player1Initials!
                    player2Initials = selectedGame!.team3Player2Initials!
                    player1ImageName = selectedGame!.team3Player1ImageName!
                    player2ImageName = selectedGame!.team3Player2ImageName!
                    otherTeam1Initials = selectedGame!.team1Player1Initials + "/" + selectedGame!.team1Player2Initials
                    otherTeam2Initials = selectedGame!.team2Player1Initials + "/" + selectedGame!.team2Player2Initials
                    teamInitials = player1Initials + "/" + player2Initials
                }
                break

            default:
                break
            }

        // return the dictionary of team information
        return ["Player1Initials": player1Initials,
            "Player2Initials": player2Initials,
            "Player1ImageName": player1ImageName,
            "Player2ImageName": player2ImageName,
            "TeamInitials" : teamInitials,
            "OtherTeam1Initials" : otherTeam1Initials,
            "OtherTeam2Initials" : otherTeam2Initials
            ]
    }




    // ***** CORE DATA  MANAGEMENT **** //

    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Fetch all saved Round Scores for the Game
    lazy var fetchedResultsControllerRound: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "RoundScore")
        fetchRequest.predicate = NSPredicate(format: "gameId == %@", self.selectedGame!.gameId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "roundNumber", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()


    // Fetch the Game so that it will be updated if the initial are changed
    lazy var fetchedResultsControllerSelectedGame: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "gameId == %@", self.selectedGame!.gameId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "gameId", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()


    // Called when a round score is updated from the RoundScore View Controller
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType,newIndexPath: NSIndexPath?) {

        guard let managedObject = anObject as? NSManagedObject else { fatalError() }
        let objectName = managedObject.entity.name

        switch type {

        case .Insert:
            break

        case .Delete:
           break

        case .Update:
            if objectName == "RoundScore"  {

                // Reload the round/team buttons
                loadRoundTeamButtons()

                // Set the game status so the status shows corrrectly in the game table
                setGameStatus()

                // Save the changes from setting the game status
                CoreDataStackManager.sharedInstance().saveContext()
            }
            break;

        case .Move:
            break
        }
    }

}
