//
//  ChangePlayersViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 3/14/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData


class ChangePlayersViewController: UIViewController, UINavigationControllerDelegate, TeamPlayerCollectionViewControllerDelegate,  NSFetchedResultsControllerDelegate {

    var selectedGame: Game?

    var fetchedGameProfiles: [ProfileGame] = []

    var newTeam1Player1: String = " "
    var newTeam1Player2: String = " "
    var newTeam2Player1: String = " "
    var newTeam2Player2: String = " "
    var newTeam3Player1: String = " "
    var newTeam3Player2: String = " "

    var newTeam1Player1Initials: String = " "
    var newTeam1Player2Initials: String = " "
    var newTeam2Player1Initials: String = " "
    var newTeam2Player2Initials: String = " "
    var newTeam3Player1Initials: String = " "
    var newTeam3Player2Initials: String = " "

    var newTeam1Player1ImageName: String = " "
    var newTeam1Player2ImageName: String = " "
    var newTeam2Player1ImageName: String = " "
    var newTeam2Player2ImageName: String = " "
    var newTeam3Player1ImageName: String = " "
    var newTeam3Player2ImageName: String = " "

    var selectedGameNumber: Int?
    var selectedGameID: String?
    var selectedProfileScoreElementId: String?
    var numberOfTeams: Int = 2

    @IBOutlet weak var Team1View: UIStackView!
    @IBOutlet weak var Team1Label: UIStackView!
    @IBOutlet weak var Team2View: UIStackView!
    @IBOutlet weak var Team2Label: UIStackView!
    @IBOutlet weak var Team3View: UIStackView!
    @IBOutlet weak var Team3Label: UIStackView!


    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()


// Need Finished Button.......................................

    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch the selected Round... Needed if the players are changed
        do {
            try fetchedResultsControllerSelectedGame.performFetch()
        } catch {}
        fetchedResultsControllerSelectedGame.delegate = self


        // Default to hand knee and foot
        checkGameChosen(0)
    }



    // ***** BUTTON MANAGEMENT  **** //


    // Check if game chosen and set the game
    func checkGameChosen(gameChosen: Int!) {

        // Save off the team member names
        switch selectedGame!.description  {
        case "HNFThreshhold", "HNFStatic", "HFStatic":
            numberOfTeams = 2
            break

        case "HFStatic3Team":
            numberOfTeams = 3
            break

        default:
            numberOfTeams = 2
            break
        }

        // Load the team/player controls
        loadTeamPlayers(numberOfTeams)

    }


    // A player was chosen for a team.  Present the player collection view so a player can be set for the team.
    // Send the button so that the player collection vc knows which one is being updated
    @IBAction func teamPlayerButton(sender: AnyObject) {

        let button = sender as! UIButton

        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TeamPlayerCollectionViewController") as! TeamPlayerCollectionViewController

        controller.delegate = self
        controller.teamPlayerID = button.tag

        self.presentViewController(controller, animated: true, completion: nil)
    }



    // Finished was chosen
    @IBAction func finishedButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // Delegate from the team player view controller when a player was selected
    func playerChosen(controller: TeamPlayerCollectionViewController, selectedPlayer: Player, teamPlayerID: Int!) {

        // Initalize variables for load



        let teamPlayerIDValue = String(teamPlayerID)
        let index1 = teamPlayerIDValue.startIndex.advancedBy(0)
        let teamID = String(teamPlayerIDValue[index1])

        // Get the background color based on the team number/ID
        let backgroundColor = sf.setTeamBackgroundColor(teamID)


        // Update the team/Player button with the new players icon or image
        sf.setButton (self.view.viewWithTag(teamPlayerID) as? UIButton, imageTextString: selectedPlayer.pictureFileName!, backgroundColor: backgroundColor)

        // Update the label for the player name
        let index2 = teamPlayerIDValue.startIndex.advancedBy(1)
        let playerID = String(teamPlayerIDValue[index2])

        var tagID = 0
        if playerID == "1" {
            tagID = Int(teamID + "4")!
        } else {
            tagID = Int(teamID + "5")!
        }


        sf.setLabel(view.viewWithTag(tagID) as? UILabel , imageTextString: selectedPlayer.name, backgroundColor: backgroundColor)


        // managed object for the selected Game
        let gameManagedObject = fetchedResultsControllerSelectedGame.fetchedObjects![0] as! Game

       
        // Update the game
        switch teamPlayerID {
        case 11:
            gameManagedObject.setValue(selectedPlayer.name, forKey: "team1Player1")
            gameManagedObject.setValue(selectedPlayer.initials, forKey: "team1Player1Initials")
            gameManagedObject.setValue(selectedPlayer.pictureFileName, forKey: "team1Player1ImageName")
            break

        case 12:
            gameManagedObject.setValue(selectedPlayer.name, forKey: "team1Player2")
            gameManagedObject.setValue(selectedPlayer.initials, forKey: "team1Player2Initials")
            gameManagedObject.setValue(selectedPlayer.pictureFileName, forKey: "team1Player2ImageName")
            break

        case 21:
            gameManagedObject.setValue(selectedPlayer.name, forKey: "team2Player1")
            gameManagedObject.setValue(selectedPlayer.initials, forKey: "team2Player1Initials")
            gameManagedObject.setValue(selectedPlayer.pictureFileName, forKey: "team2Player1ImageName")
            break

        case 22:
            gameManagedObject.setValue(selectedPlayer.name, forKey: "team2Player2")
            gameManagedObject.setValue(selectedPlayer.initials, forKey: "team2Player2Initials")
            gameManagedObject.setValue(selectedPlayer.pictureFileName, forKey: "team2Player2ImageName")
            break

        case 31:
            gameManagedObject.setValue(selectedPlayer.name, forKey: "team3Player1")
            gameManagedObject.setValue(selectedPlayer.initials, forKey: "team3Player1Initials")
            gameManagedObject.setValue(selectedPlayer.pictureFileName, forKey: "team3Player1ImageName")
            break

        case 32:
            gameManagedObject.setValue(selectedPlayer.name, forKey: "team3Player2")
            gameManagedObject.setValue(selectedPlayer.initials, forKey: "team3Player2Initials")
            gameManagedObject.setValue(selectedPlayer.pictureFileName, forKey: "team3Player2ImageName")
            break

        default:
            break
        }

        CoreDataStackManager.sharedInstance().saveContext()
    }


    // Build the URL to retrieve the photo from the documents folder
    func imageFileURL(fileName: String) ->  NSURL {

        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

        let pathArray = [dirPath, fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!

        return fileURL
    }



    // ***** MANAGE BUTTONS, LABELS ON VIEW  **** //


    // Load the teams
    func loadTeamPlayers(numberOfTeams: Int) {

        // Loop through all the teams, all the players, loading images, names and background colors for 2 or 3 teams
        for teamNumber in 1...3 {
            var backgroundColor: UIColor = UIColor.whiteColor()

            for control  in 0...5 {

                var teamPlayer = " "
                var teamImageName = "whitespace"
                var teamInitial = " "

                let teamPlayerTemp: String = String(teamNumber) + String(control)
                let teamPlayerID = Int(teamPlayerTemp)!

                switch teamPlayerID {
                case 11, 14:
                    teamPlayer = selectedGame!.team1Player1
                    teamImageName = selectedGame!.team1Player1ImageName
                    teamInitial = selectedGame!.team1Player1Initials
                    break
                case 12, 15:
                    teamPlayer = selectedGame!.team1Player2
                    teamImageName = selectedGame!.team1Player2ImageName
                    teamInitial = selectedGame!.team1Player2Initials

                    break
                case 21, 24:
                    teamPlayer = selectedGame!.team2Player1
                    teamImageName = selectedGame!.team2Player1ImageName
                    teamInitial = selectedGame!.team2Player1Initials

                    break
                case 22, 25:
                    teamPlayer = selectedGame!.team2Player2
                    teamImageName = selectedGame!.team2Player2ImageName
                    teamInitial = selectedGame!.team2Player2Initials

                    break
                case 31, 34:
                    teamPlayer = selectedGame!.team3Player1!
                    teamImageName = selectedGame!.team3Player1ImageName!
                    teamInitial = selectedGame!.team3Player1Initials!

                    break
                case 32, 35:
                    teamPlayer = selectedGame!.team3Player2!
                    teamImageName = selectedGame!.team3Player2ImageName!
                    teamInitial = selectedGame!.team3Player2Initials!
                    break

                default:
                    break
                }

                // Get the background color based on the team number/ID
                backgroundColor = sf.setTeamBackgroundColor(String(teamNumber))

                let tag = String(teamNumber) + String(control)
                let tagID = Int(tag)


                // Control =  "0" is the image that indicates the team number
                if control == 0 {

                    //If team number is 3 and there are not 3 times just fill with whitespace else set to number in solid round
                    if teamNumber == 3 && numberOfTeams < 3 {
                        sf.setImage(view.viewWithTag(tagID!) as! UIImageView, imageTextString: "whitespace")
                    }  else  {
                      //  let imageName = "iconRound" + String(teamNumber)
                        sf.setImage(view.viewWithTag(tagID!) as! UIImageView, imageTextString: "iconRound" + String(teamNumber))
                    }

                }


                // Load player image from their profile
                if control == 1 || control == 2  {

                    // Set image to players image
                    sf.setButton(view.viewWithTag(tagID!) as? UIButton, imageTextString: teamImageName, backgroundColor: backgroundColor)

                    // There is no team three, set to whitespace
                    if teamNumber == 3 && numberOfTeams < 3 {
                        sf.setButton(view.viewWithTag(tagID!) as? UIButton, imageTextString: "whitespace", backgroundColor: UIColor.whiteColor())
                    }



                    // Set the Team Player Name
                    if control == 4 || control == 5  {
                        // Update the label for the player name

                        // Blank out name if no team 3
                        if teamNumber == 3 && numberOfTeams < 3 {
                            sf.setLabel(view.viewWithTag(tagID!) as? UILabel, imageTextString:"   ",  backgroundColor: UIColor.whiteColor())

                        } else {

                            print("teamPlayer: \(teamPlayer)")
                            //Set the label name for the player
                            sf.setLabel(view.viewWithTag(tagID!) as? UILabel, imageTextString: teamPlayer, backgroundColor: backgroundColor)
                        }

                    }
                }
            }
        }
    }



    // ***** CORE DATA  MANAGEMENT  **** //

    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Fetch the Game so that it will be updated if the initial are changed
    lazy var fetchedResultsControllerSelectedGame: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "gameId == %@", self.selectedGame!.gameId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "gameId", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()
    


    
    
    
}
