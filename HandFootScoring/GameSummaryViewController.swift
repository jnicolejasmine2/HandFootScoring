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

    var fetchedRounds: [RoundScore] = []
    var selectedGame: Game?

    var team1Initials = " "
    var team2Initials = " "
    var team3Initials = " "

    @IBOutlet weak var changePlayers: UIButton!
 
    @IBOutlet weak var navigationBar: UINavigationBar!



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Format Game's date for the view title
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let dateMMDD = dateFormatter.stringFromDate(selectedGame!.date)
        navigationBar.topItem!.title = "Summary: " + dateMMDD

        // Fetch the round for the game
        do {
            try fetchedResultsControllerRound.performFetch()
        } catch {}
        fetchedResultsControllerRound.delegate = self



        // Fetch the selected Round... Needed if the players are changed
        do {
            try fetchedResultsControllerSelectedGame.performFetch()
        } catch {}
        fetchedResultsControllerSelectedGame.delegate = self


        // Save off the fetched results in an array
        fetchedRounds = fetchedResultsControllerRound.fetchedObjects as! [RoundScore]

        // Load the round/team buttons with their scores
        loadRoundTeamButtons()
    }



  // ***** BUTTON MANAGEMENT  **** //

    @IBAction func backToGamesButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }



    // A team/round was selected.  Give control to the Round Score VC to gather the score details
    @IBAction func roundSelectedButton(sender: AnyObject) {

        let tagIDString: String? = String(sender.tag)

        if  let tagID = tagIDString {

            // Separate the tag into the selected Round and Selected Team
            let index1 = tagID.startIndex.advancedBy(0)
            let firstDigit = String(tagID[index1])
            let selectedRound = Int(firstDigit)
            let index2 = tagID.startIndex.advancedBy(1)
            let selectedTeam = Int(tagID.substringFromIndex(index2))


            // Check if we selected a round instead of the titles, totals and meld
            if selectedRound > 0 && selectedRound < 5 {

                let roundScoreController = storyboard!.instantiateViewControllerWithIdentifier("RoundScoreViewController") as! RoundScoreViewController

                // Pass information to the controller: game ID, round and team
                roundScoreController.selectedGameID = selectedGame!.gameId
                roundScoreController.selectedRoundNumber = selectedRound
                roundScoreController.selectedTeamNumber = selectedTeam

                // Pass information to the controller: Title that shows the round and the team initials
                // Also pass the initials for the other 2 teams
                switch selectedTeam! {
                case 1:
                    roundScoreController.selectedViewTitle = "Round: " + String(selectedRound!) + " Team: " + team1Initials
                    roundScoreController.otherTeamInitials = team2Initials
                    roundScoreController.Other3rdTeamInitials = team3Initials
                    break
                case 2:
                    roundScoreController.selectedViewTitle = "Round: " + String(selectedRound!) + " Team: " + team2Initials
                    roundScoreController.otherTeamInitials = team1Initials
                    roundScoreController.Other3rdTeamInitials = team3Initials
                    break

                case 3:
                    roundScoreController.selectedViewTitle = "Round: " + String(selectedRound!) + " Team: " + team3Initials
                    roundScoreController.otherTeamInitials = team1Initials
                    roundScoreController.Other3rdTeamInitials = team2Initials
                    break

                default:
                    break
                }

                // Present the view controller
                presentViewController(roundScoreController, animated: true, completion: nil)
            }
        }
    }


    @IBAction func changePlayersButtonAction(sender: AnyObject) {

        let changePlayersController = storyboard!.instantiateViewControllerWithIdentifier("ChangePlayersViewController") as! ChangePlayersViewController

        changePlayersController.selectedGame = selectedGame!

        // Present the view controller
        presentViewController(changePlayersController, animated: true, completion: nil)
    }


    // ***** ROUND/TEAM CONTROLS MANAGEMENT  **** //


    // Load the headers, round scores, totals and meld for all the teams
    func loadRoundTeamButtons() {

        var team1TotalScore = 0
        var team2TotalScore = 0
        var team3TotalScore = 0

        var lastCompletedRoundTeam1: Int = 0
        var lastCompletedRoundTeam2: Int = 0
        var lastCompletedRoundTeam3: Int = 0

        // set the initials and images for the team players
        initializePlayerTeamHeadings()

        // Loop through the rounds, loading the round scores into the buttons
        // Calculate the game total for each of the teams 
        // Determine the lastcompletedround so the meld can be determined
        for fetchedRound in fetchedResultsControllerRound.fetchedObjects as! [RoundScore] {

            let round = String(fetchedRound.roundNumber)
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


            // Load the round scores
            let tagString = round + team
            let tagID = Int(tagString)

            if let button = view.viewWithTag(tagID!) as? UIButton {
                setButton (button, imageTextString: formatScore(Int(fetchedRound.roundTotal)), backgroundColor: setTeamBackgroundColor(team) )
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


        print("winningGameTotal: \(winningGameTotal)")




        // Loop through the total buttons setting the total score as the title
        for team in 1...3 {

            var gameTotalScore = 0
            if let button = view.viewWithTag(50 + team) as? UIButton {

                switch team {
                case 1:
                    gameTotalScore = team1TotalScore
                    let difference =  winningGameTotal - gameTotalScore
                    var differenceText = " "
                    if difference != 0 {
                        differenceText = "-" + formatScore(difference)
                    }

                     setButton (button, imageTextString: formatScore(team1TotalScore)  + "\n" + differenceText, backgroundColor: setTeamBackgroundColor(String(team)) )
                    break

                case 2:
                    gameTotalScore = team2TotalScore
                    let difference =  winningGameTotal - gameTotalScore
                    var differenceText = " "
                    if difference != 0 {
                        differenceText = "-" + formatScore(difference)
                    }

                    setButton (button, imageTextString: formatScore(team2TotalScore) + "\n" + differenceText, backgroundColor: setTeamBackgroundColor(String(team)) )
                    break

                case 3:
                    gameTotalScore = team3TotalScore
                    let difference =  winningGameTotal - gameTotalScore
                    var differenceText = " "
                    if difference != 0 {
                        differenceText = "-" + formatScore(difference)
                    }

                    setButton (button, imageTextString: formatScore(team3TotalScore) + "\n" + differenceText, backgroundColor: setTeamBackgroundColor(String(team)) )
                    break

                default:
                    break
                }
            }

            // Set the Melds, first determine last completed round for the static option
            let lastCompletedRound =  determineLastCompletedRound()

            let meld = determineMeld(gameTotalScore, lastCompletedRound: lastCompletedRound)

            if let button = view.viewWithTag(60 + team) as? UIButton {
                setButton (button, imageTextString: meld , backgroundColor: setTeamBackgroundColor(String(team)) )
            }
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
        let lastCompletedRound =  determineLastCompletedRound()

        print("lastCompletedRound: \(lastCompletedRound)")

        // Loop through the 4 rounds determining what the status is
        // and then setting the icon that matches that status
        for round in 1...4 {
            var roundIcon: String

            if lastCompletedRound >= round {
                roundIcon = "iconRound" + String(round)

            } else {
                roundIcon = "iconRound" + String(round) + "NotStarted"
            }


            if let image = view.viewWithTag(90 + round) as? UIImageView  {
                setImage (image , imageTextString: roundIcon)
            }


            // Loop through the team/round buttons and if we are not at that round
            // disable the button so scores can be added in advance
            for team in 1...3 {
                let tagString = String(round) + String(team)
                let tagIDRound = Int(tagString)

                let lastCompletedRoundPlusNext = lastCompletedRound + 1

                if lastCompletedRoundPlusNext < round {
                    if let button = view.viewWithTag(tagIDRound!) as? UIButton {
                        setButton (button, imageTextString: " ", backgroundColor: Style.sharedInstance().teamRoundDisabled() )
                    }
                }
                
            }
        }

    }


    // If there is no team 3, need to set the labels and the buttons to whitespace
    // and blanks to hid time 3. 
    func clearTeamThree()  {

        let selectedNumberOfTeams = Int(selectedGame!.maximumNumberOfTeams)
        if selectedNumberOfTeams < 3 {

            // Loop through the 3 controls for the team
            for control in 0...8 {

                let team = "3"
                let tagString = String(control) + team
                let tagID = Int(tagString)

                if control > 0 && control < 7 {
                    if let button = view.viewWithTag(tagID!) as? UIButton {
                       setButton (button, imageTextString: " ", backgroundColor: UIColor.whiteColor() )
                    }
                } else {
                    if let label = view.viewWithTag(tagID!) as? UILabel {
                        setLabel (label, imageTextString: " ", backgroundColor: UIColor.whiteColor() )
                    }
                }
            }
        }
    }



    // Update the last completed round which indicates the status of the game.  Based on
    // the last completed round the icon for 1/4, 2/4, 3/4 or 4/4 rounds completed shows in table view.
    func setGameStatus() {

        let lastCompletedRound =  determineLastCompletedRound()
        selectedGame!.lastCompletedRound = lastCompletedRound
        CoreDataStackManager.sharedInstance().saveContext()
    }



    // Loop through all the rounds for all the teams to determine which rounds are completed.
    // They are considered completed when all the teams have a non-zero score
    func determineLastCompletedRound() -> Int {
        var lastCompletedRoundTeam1: Int = 0
        var lastCompletedRoundTeam2: Int = 0
        var lastCompletedRoundTeam3: Int = 0

        // Loop through all the teams and find the last completed round.
        for fetchedRound in fetchedResultsControllerRound.fetchedObjects as! [RoundScore] {

            switch fetchedRound.teamNumber {
            case 1:
                if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam1 {
                    lastCompletedRoundTeam1 = Int(fetchedRound.roundNumber)
                }
                break
            case 2:
                if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam2 {
                    lastCompletedRoundTeam2 = Int(fetchedRound.roundNumber)
                }
                break
            case 3:
                if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam3 {
                    lastCompletedRoundTeam3 = Int(fetchedRound.roundNumber)
                }
                break
            default:
                break
            }
        }

        // Look at the last completed rounds for the teams and set the last completed round
        var lastCompletedRound: Int = 0

        if lastCompletedRoundTeam1 <= lastCompletedRoundTeam2 {
            lastCompletedRound = lastCompletedRoundTeam1
        } else {
            lastCompletedRound = lastCompletedRoundTeam2
        }

        if selectedGame!.maximumNumberOfTeams == 3  && lastCompletedRoundTeam3 <= lastCompletedRound {
            lastCompletedRound = lastCompletedRoundTeam3
        }
        return lastCompletedRound
    }



    // Set the team initials and images
    func initializePlayerTeamHeadings() {

        for team in 1...3 {
            var player1Initials = " "
            var player2Initials =  " "
            var player1ImageName = " "
            var player2ImageName =  " "

            switch team {
            case  1:
                player1Initials = selectedGame!.team1Player1Initials
                player2Initials = selectedGame!.team1Player2Initials
                player1ImageName = selectedGame!.team1Player1ImageName
                player2ImageName = selectedGame!.team1Player2ImageName
                team1Initials = player1Initials + "/" + player2Initials
                break

            case  2:
                player1Initials = selectedGame!.team2Player1Initials
                player2Initials = selectedGame!.team2Player2Initials
                player1ImageName = selectedGame!.team2Player1ImageName
                player2ImageName = selectedGame!.team2Player2ImageName
                team2Initials = player1Initials + "/" + player2Initials
                break

            case  3:
                if selectedGame!.maximumNumberOfTeams == 3 {
                    player1Initials = selectedGame!.team3Player1Initials!
                    player2Initials = selectedGame!.team3Player2Initials!
                    player1ImageName = selectedGame!.team3Player1ImageName!
                    player2ImageName = selectedGame!.team3Player2ImageName!
                    team3Initials = player1Initials + "/" + player2Initials
                }
                break

            default:
                break
            }

            // set the team Initials
            if let label = view.viewWithTag(team) as? UILabel {
                let initials = player1Initials + "/" + player2Initials

                setLabel (label, imageTextString: initials, backgroundColor: UIColor.whiteColor() )
            }

            // set the team Player 1 Image
            //  var tagID = 70 + team
            if let image = view.viewWithTag(70 + team) as? UIImageView {
                setImage  (image, imageTextString: player1ImageName)
            }

            // set the team Player 2 Image
            if let image = view.viewWithTag(80 + team) as? UIImageView {

                setImage  (image, imageTextString: player2ImageName)
            }
        }
    }


    // Set images
    func setImage (image: UIImageView!, imageTextString: String!) {

        dispatch_async(dispatch_get_main_queue(), {

            image.hidden = true

            if let _ = imageTextString.rangeOfString("icon") {
                image.image = UIImage(named: imageTextString)

            } else {
                // saved Photo
                let photoDocumentsFileName = imageTextString

                // Put the image from the documents folder into the cell
                let photoDocumentsUrl = self.imageFileURL(photoDocumentsFileName).path

                // Check if photo is still in documents folder
                let manager = NSFileManager.defaultManager()
                if (manager.fileExistsAtPath(photoDocumentsUrl!)) {

                    let buttonImage = UIImage(contentsOfFile: photoDocumentsUrl!)!
                    image.image  = buttonImage
                }
            }

            if imageTextString ==  "whitespace" {
                image.backgroundColor = UIColor.whiteColor()
            }

            image.hidden = false
        })

    }


    // Build the URL to retrieve the photo from the documents folder
    func imageFileURL(fileName: String) ->  NSURL {

        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

        let pathArray = [dirPath, fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!

        return fileURL
    }
    



    // Set button title
    func setButton (button: UIButton!, imageTextString: String!, backgroundColor: UIColor) {

        dispatch_async(dispatch_get_main_queue(), {
            button.hidden = true

            button.setTitle(imageTextString, forState: UIControlState.Normal)
            button.backgroundColor = backgroundColor
            button.hidden = false
            button.titleLabel?.textAlignment = .Center
            button.setTitleColor(UIColor.blackColor(), forState:  UIControlState.Normal)

            // If round is after next or current rounds, then disable
            if imageTextString == " " {
                button.enabled = false
            } else {
                button.enabled = true
            }

            // Check if game is in past. If so change the color to a dark disabled color

           //  let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.selectedGame!.date, toUnitGranularity: .Day)

            let dateCompareResult =  SharedFunctions.sharedInstance().compareDates(NSDate(), toDate: self.selectedGame!.date, granularity: .Day)
            print("selectedate: \(self.selectedGame!.date)")
            print("dateCompareResult: \(dateCompareResult)")
            if  dateCompareResult == ">" {
                button.backgroundColor = Style.sharedInstance().teamRoundDisabled()
                button.enabled = false

            }
         })
    }


    // Set the label text and background color
    func setLabel (label: UILabel!, imageTextString: String!, backgroundColor: UIColor) {

        dispatch_async(dispatch_get_main_queue(), {
            label.hidden = true

            label.text = imageTextString
            label.backgroundColor = backgroundColor

            label.hidden = false
        })

    }


    // Add the comma to the score and totals
    func formatScore(score: Int!) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter.stringFromNumber(score)!
    }


    // Based on the team number set the background color for the player button
    func setTeamBackgroundColor(teamID: String) -> UIColor {

        // Set the background color based on the team ID
        var backgroundColor = UIColor.whiteColor()
        switch teamID {
        case "1":
            backgroundColor =  Style.sharedInstance().team1ButtonBackgroundColor()
            break
        case "2":
            backgroundColor =  Style.sharedInstance().team2ButtonBackgroundColor()
            break
        case "3":
            backgroundColor =  Style.sharedInstance().team3ButtonBackgroundColor()
            break
        default:
            backgroundColor =  UIColor.whiteColor()
            break
        }
        return backgroundColor
    }


    func determineMeld(gameTotalWork: Int, lastCompletedRound: Int) -> String! {

        var meldValue = "  "

        // Meld is based on score thresholds.
        if selectedGame!.meldOption == "Threshhold" {

            // Check total score against threshholds, send back meld
            meldValue = selectedGame!.meld1Value

            if gameTotalWork > Int(selectedGame!.meld4Threshold) {
                meldValue = selectedGame!.meld4Value

            } else if gameTotalWork > Int(selectedGame!.meld3Threshold) {
                meldValue = selectedGame!.meld3Value

            } else if gameTotalWork > Int(selectedGame!.meld2Threshold) {
                meldValue = selectedGame!.meld2Value
            }
            
        } else if selectedGame!.meldOption == "Static" {
            
            print("lastCompletedRound: \(lastCompletedRound)")
            // Meld is based on the completed round
            if lastCompletedRound == 0 {
                meldValue =  "50"
            } else if lastCompletedRound == 1 {
                meldValue =  "90"
            } else if lastCompletedRound == 2 {
                meldValue =  "120"
            } else  {
                meldValue = "150"
            }
        }
        return meldValue
    }
    




    // ***** CORE DATA  MANAGEMENT - PHOTO  **** //

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
        let objectName = anObject.entity.name

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

            if objectName == "Game"  {

                // set the initials and images for the team players
                initializePlayerTeamHeadings()
            }

            break;

        case .Move:
            break
        }
    }



}

