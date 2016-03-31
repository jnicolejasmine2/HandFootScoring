//
//  GameTableViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/18/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData

class GameTableViewController: UIViewController,  NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var newGameButton: UIBarButtonItem!

    var firstTimeSwitch = true

    let statusIconArray = ["status0","status25","status50","status75","status100"]



    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()


    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check for first time, load the game, score elements in the profile
        checkForLoadedProfiles()

        // Fetch any existing Games and all the round
        fetchResultsGamesAndRounds()

        // Delete any games that are over 30 days old
        deleteGamesOver30DaysOld ()


        // Load the table
        gameTableView.rowHeight = 130.0
        gameTableView.reloadData()


        // REMOVE..... before submitting!!!!!!!!
        // Needed for DEBUG REMOVE AFTER TESTING 30 DAY DELETE
        let fetchedRounds = fetchedResultsControllerRound.fetchedObjects as! [RoundScore]
        print("fetchedRounds.count: \(fetchedRounds.count)")

        // USED ONLY FOR DEBUG
        // Fetch all the rounds for all games. Used to Calculate the team scores for the table view.
        do {
            try fetchedResultsControllerScoreElement .performFetch()
        } catch {}

        // Set the fetchedResultsController.delegate = self
        fetchedResultsControllerRound.delegate = self

        let fetchedScoreElements = fetchedResultsControllerScoreElement.fetchedObjects as! [RoundScore]
        print("fetchedScoreElements.count: \(fetchedScoreElements.count)")

        // REMOVE..... before submitting!!!!!!!!
    }

    override func viewDidAppear(animated: Bool) {

        // If app is first opened, check for a last started game. If found, skip table and go directly to summary
        if firstTimeSwitch == true {
            let defaults = NSUserDefaults.standardUserDefaults()
            let savedID = defaults.objectForKey("lastStartedGameId") as? String

            firstTimeSwitch = false
            if let savedIDFound = savedID {
                 checkForActiveGame(savedIDFound)
            }
        }
    }



    // If there is an active game, then present the game rounds, skipping the table
    func checkForActiveGame(savedGameId: String) {
        for fetchedGame in fetchedResultsControllerGame.fetchedObjects as! [Game]  {

            if fetchedGame.gameId == savedGameId {

                let dateCompareResult =  SharedFunctions.sharedInstance().compareDates(NSDate(), toDate: fetchedGame.date, granularity: .Day)

                if  dateCompareResult == "=" {
                    let summaryController = storyboard!.instantiateViewControllerWithIdentifier("GameSummaryViewController") as! GameSummaryViewController

                    // Pass the selected game
                    let selectedGame = fetchedGame
                    summaryController.selectedGame = selectedGame

                    presentViewController(summaryController, animated: true, completion: nil)
                }
            }
        }
    }


    // Check for loaded profiles and load if not found
    func checkForLoadedProfiles() {

        // Fetch any existing Existing Profile Games to check if the games are loaded
        do {
            try fetchedResultsController.performFetch()
        } catch {}

        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self

        let sectionInfo = fetchedResultsController.sections![0]

        // First time in, load the game profiles
        if sectionInfo.numberOfObjects == 0 {
            LoadProfiles.sharedInstance().initialLoadOfProfiles()
        }
    }


    // Delete games over 30 days old.
    func deleteGamesOver30DaysOld() {

        let currentDate = NSDate()
        let dateComponents = NSDateComponents()
        dateComponents.day = -30
        let date30DaysPast = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))

        var fetchedGameIndex = 0
        for fetchedGame in fetchedResultsControllerGame.fetchedObjects! {

            if fetchedGame.date != nil {
               // let order = NSCalendar.currentCalendar().compareDate(date30DaysPast!, toDate:date30DaysPast!, toUnitGranularity: .Day)

                let dateCompareResult =  SharedFunctions.sharedInstance().compareDates(date30DaysPast!, toDate: fetchedGame.date!, granularity: .Day)

                if  dateCompareResult == "<" {
                    // Older than 30 days deleted
                    // Delete the Game, Rounds and Score Elements

                    let gameManagedObject = self.fetchedResultsControllerGame.fetchedObjects![fetchedGameIndex] as! NSManagedObject
                    self.sharedContext.deleteObject(gameManagedObject)
                }
            }
            ++fetchedGameIndex
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }



    // ***** BUTTON MANAGEMENT  **** //

    // Plus Sign, New Game was requested.
    @IBAction func newGameAction(sender: AnyObject) {
        let newGameController = storyboard!.instantiateViewControllerWithIdentifier("NewGameViewController") as! NewGameViewController

        // Pass the Game Profiles so the user can select a game.
        newGameController.fetchedGameProfiles = fetchedResultsController.fetchedObjects as! [ProfileGame]

        // Present the view controller
        presentViewController(newGameController, animated: true, completion: nil)
    }




    // ***** TABLE MANAGEMENT  **** //

    // Number of Rows in each section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sections = fetchedResultsControllerGame.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    // Number of sections, there is a section for each day
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsControllerGame.sections!.count
    }

    // Set the title of the section. It is stored with the game and is formatted when a game is added
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if let sections = fetchedResultsControllerGame.sections {

            let currentSection = sections[section]  
            return currentSection.name
        }
        return " "
    }

    // Change the section header background and font colors
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Style.sharedInstance().tableHeader()
        header.textLabel!.textColor = UIColor.whiteColor()
    }


    // Load the images and text into the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {

        // Using a custom cell
        let cell = tableView.dequeueReusableCellWithIdentifier("GameTableCell", forIndexPath: indexPath) as! GameTableCell

        // Access the game that was selected
        let fetchedGame = fetchedResultsControllerGame.objectAtIndexPath(indexPath) as! Game

        // Set the game description
        cell.gameDescription!.text = fetchedGame.gameDescription

        // Set the Cell Team Info
        cell.team1Info!.text = buildTeamInfo(fetchedGame, team: 1)
        cell.team2Info!.text = buildTeamInfo(fetchedGame, team: 2)

        if fetchedGame.maximumNumberOfTeams == 3 {
            cell.team3Info!.text = buildTeamInfo(fetchedGame, team: 3)
        } else {
            cell.team3Info!.text = " "
        }


        // Set the game completed status image and set the background colors based on the status of the 
        // game.  Note the background color will be overriden if the game was started on a previous day

        // Default table background colors (both normaland selected
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.sharedInstance().tableBackgroundColor()

        cell.backgroundColor = Style.sharedInstance().tableBackgroundColor()

        let imageName = statusIconArray[Int(fetchedGame.lastCompletedRound)]
        cell.gameStatus.image = UIImage(named: imageName)

        // If game is completed, change the color on the table
        if fetchedGame.lastCompletedRound == 4 {

            cell.backgroundColor = Style.sharedInstance().tableCompleted()
            backgroundView.backgroundColor = Style.sharedInstance().tableCompleted()
        }

        // Check if game is in past. If so change the color to a dark disabled color


        // OLDER CODE: let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: fetchedGame.date, toUnitGranularity: .Day)

        let dateCompareResult =  SharedFunctions.sharedInstance().compareDates(NSDate(), toDate: fetchedGame.date, granularity: .Day)

        if  dateCompareResult == "<" {
            cell.backgroundColor = Style.sharedInstance().tableDisabled()
            backgroundView.backgroundColor = Style.sharedInstance().tableDisabled()
        }

        // Set the selected view to the background view color
        cell.selectedBackgroundView = backgroundView

        // Set separator color
        cell.separator.backgroundColor = Style.sharedInstance().tableHeader()

        // Do not show separator on last cell
        let totalRowsInSection = gameTableView.numberOfRowsInSection(indexPath.section)
        if indexPath.row == (totalRowsInSection - 1) {
            cell.separator.hidden = true
        } else {
            cell.separator.hidden = false
        }

        // Cell is ready to display
        return cell
    }


    // When a game is selected, show the game summary viewcontroller.  Pass the selected game
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        gameTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let summaryController = storyboard!.instantiateViewControllerWithIdentifier("GameSummaryViewController") as! GameSummaryViewController

        // Pass the selected game
        let selectedGame = fetchedResultsControllerGame.objectAtIndexPath(indexPath) as! Game
        summaryController.selectedGame = selectedGame

        presentViewController(summaryController, animated: true, completion: nil)
    }


    // Slide Delete Button, delete from Game table and from table view
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        // Delete the Game, Rounds and Score Elements 
        let gameManagedObject = self.fetchedResultsControllerGame.fetchedObjects![indexPath.item] as! NSManagedObject
        self.sharedContext.deleteObject(gameManagedObject)

        CoreDataStackManager.sharedInstance().saveContext()
    }




    // Build the team Info line for the cell
    func buildTeamInfo(fetchedGame: Game, team: Int) -> String {

        // Set the initials
        var teamInitial1 = " "
        var teamInitial2 = " "

        switch team {
        case 1:
            teamInitial1 = fetchedGame.team1Player1Initials
            teamInitial2 = fetchedGame.team1Player2Initials
            break
        case 2:
            teamInitial1 = fetchedGame.team2Player1Initials
            teamInitial2 = fetchedGame.team2Player2Initials
            break
        case 3:
            teamInitial1 = fetchedGame.team3Player1Initials!
            teamInitial2 = fetchedGame.team3Player2Initials!
            break
        default:
            return " "
        }

        //  Format the initials for the team
        var teamInfo =   teamInitial1 + " / " + teamInitial2


        // Format the meld and the game score
        // Determine last Completed Round
        let fetchedRounds = fetchedResultsControllerRound.fetchedObjects as! [RoundScore]
        let teamLastCompletedRound = sf.determineLastCompletedRound(fetchedGame, fetchedRounds: fetchedRounds)

        // Get the current team's score
        let teamGameTotal =  getGameTotal (fetchedGame, team: team)

        // From the score and last completed Round determine the current meld
        let teamMeld = sf.determineMeld(fetchedGame, gameTotalScore: teamGameTotal, lastCompletedRound: teamLastCompletedRound)

        // Add the meld and score to the team info
        teamInfo = teamInfo + "  Meld: " + teamMeld + "  Score: " + sf.formatScore(teamGameTotal)


        // To get the difference, must determine which team has the most score 
        // First get each teams total score by adding up all the round totals
        let team1GameTotal = getGameTotal(fetchedGame, team: 1)

        let team2GameTotal = getGameTotal(fetchedGame, team: 2)

        var team3GameTotal = 0
        if fetchedGame.maximumNumberOfTeams == 3 {
            team3GameTotal = getGameTotal(fetchedGame, team: 3)
        }

        // Then determine what is the highest score
        var winningGameTotal = 0

        if team1GameTotal > team2GameTotal && team1GameTotal > team3GameTotal {
            winningGameTotal = team1GameTotal
        }

        if team2GameTotal > team1GameTotal && team2GameTotal > team3GameTotal {
            winningGameTotal = team2GameTotal
        }

        if team3GameTotal > team1GameTotal && team3GameTotal > team2GameTotal {
            winningGameTotal = team3GameTotal
        }

        // Calculate the difference and add to the team line
        var teamGameDifference = 0
        teamGameDifference = winningGameTotal - teamGameTotal

        if teamGameDifference > 0 {
            teamInfo = teamInfo + "  -" + sf.formatScore(teamGameDifference)
        }

        return teamInfo
    }



    // Calculate the game total for the team. must total all the round scores up
    func getGameTotal (selectedGame: Game, team: Int) -> Int {
        var teamGameScore: Int = 0

        // Loop through all the teams and find the last completed round.
        for fetchedRound in fetchedResultsControllerRound.fetchedObjects as! [RoundScore] {

            if fetchedRound.gameId == selectedGame.gameId  && Int(fetchedRound.teamNumber) == team{
                teamGameScore = teamGameScore + Int(fetchedRound.roundTotal)
            }
        }
        return teamGameScore
    }


    
 
 // ***** CORE DATA  MANAGEMENT  **** //


    // Fetch any existing Games and all the round
    func fetchResultsGamesAndRounds() {

        // Fetch any existing Started Games --
        do {
            try fetchedResultsControllerGame.performFetch()
        } catch {}

        // Set the fetchedresult Delegate
        fetchedResultsControllerGame.delegate = self


        // Fetch all the rounds for all games. Used to Calculate the team scores for the table view.
        do {
            try fetchedResultsControllerRound .performFetch()
        } catch {}

       // Set the fetchedresult Delegate
        fetchedResultsControllerRound.delegate = self
    }

    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Fetch all Game Profiles
    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "ProfileGame")

        // Sort by gameProfileId
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "gameProfileId", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()


    // Fetch all Games
    lazy var fetchedResultsControllerGame: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Game")

        // Sort by gameProfileId
        let sectionDateSort = NSSortDescriptor(key: "sectionDate", ascending: false)
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sectionDateSort, dateSort]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: "sectionDate", cacheName: nil)

        return fetchedResultsController
    }()



    // Fetch all Rounds
    lazy var fetchedResultsControllerRound: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "RoundScore")

        // Sort by roundNumber 1-4
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "roundNumber", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()


    // Fetch all score Elements (!!!!!!USED FOR DEBUG ONLY!!!!!)
    lazy var fetchedResultsControllerScoreElement: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "ScoreElement")

        // Sort by roundNumber 1-4
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "elementNumber", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()



    // Begin updates. Needed so we can insert sections as needed
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        gameTableView.beginUpdates()
    }


    // Called when core data SECTION is added or deleted
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)  {

        switch type {

        // Insert a new section (new day)
        case .Insert:
            print(".insertGameSection ")

            gameTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break

        // Delete a section
        case .Delete:
            print(".deleteGameSection")
                 gameTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break

        case .Update:
            break

        // Move
        case .Move:
            break
        }
    }
    

    // Called when core data is modified for the game
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType,newIndexPath: NSIndexPath?) {
        let objectName = anObject.entity.name

        switch type {

        case .Insert:
             if objectName == "Game"  {
                gameTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            break

        case .Delete:
            if objectName == "Game"  {
                gameTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            if objectName == "RoundScore" {
                print("roundscoreDeleted")
            }
            if objectName == "ScoreElement" {
                print("ScoreElementDeleted")
            }
            break


        case .Update:
            if objectName == "Game"  {

                gameTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            break

        case .Move:
            break
        }
    }
    
    // Called when all updates are done
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        gameTableView.endUpdates()
    }

}
