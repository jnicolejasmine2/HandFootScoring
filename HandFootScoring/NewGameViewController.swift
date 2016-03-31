//
//  NewGameViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/19/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData


class NewGameViewController: UIViewController, UINavigationControllerDelegate, TeamPlayerCollectionViewControllerDelegate,  NSFetchedResultsControllerDelegate {

    // Game and Player initialization 
    var teamPlayerArray: [[[String: String]]] = [
        [
            [ "PlayerName" : "GuestA", "PlayerInitials" : "", "PlayerImageName" : "" ], // Team 1
            [ "PlayerName" : "GuestB", "PlayerInitials" : "", "PlayerImageName" : "" ]
        ],
        [   [ "PlayerName" : "GuestC", "PlayerInitials" : "", "PlayerImageName" : "" ], // Team 2
            [ "PlayerName" : "GuestD", "PlayerInitials" : "", "PlayerImageName" : "" ]
        ],
        [   [ "PlayerName" : "GuestE", "PlayerInitials" : "", "PlayerImageName" : "" ], // Team 3
            [ "PlayerName" : "GuestF", "PlayerInitials" : "", "PlayerImageName" : "" ]
        ]
    ]

    var gameTypes = ["HNFThreshhold", "HNFStatic","HFStatic", "HFStatic3Team"]
    var gameDescriptions = ["Hand, Knee\n& Foot", "Hand, Knee\n& Foot\n(Set Meld)", "Hand & Foot", "Hand & Foot\n(3 Teams)"]

    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()

    // Variables
    var selectedGameNumber: Int?
    var selectedGameID: String?
    var selectedProfileScoreElementId: String?
    var numberOfTeams: Int = 2
    var fetchedGameProfiles: [ProfileGame] = []


    //Outputs
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var CancelGame: UIBarButtonItem!
    @IBOutlet var segmentControl : ADVSegmentedControl!



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()


        // Fetch players so that their name, icon/photo and initials can be viewed and saved with the game
        do {
            try fetchedResultsControllerPlayers.performFetch()
        } catch {}

        // Set the fetchedResultsController.delegate = self
        fetchedResultsControllerPlayers.delegate = self

        // Hide the team/player buttons until a game is chosen
        hideControls()

        // Start button is not enabled until a game is chosen
        startButton.enabled = false

        // Set button colors
        startButton.backgroundColor = Style.sharedInstance().keyButtonControlDisabled()
        CancelGame.tintColor = Style.sharedInstance().keyButtonControl()

        // set up the custome Segment Control
        segmentControl.items = gameDescriptions
        segmentControl.font = UIFont(name: "Helvetica Neue", size: 14)
        segmentControl.borderColor = Style.sharedInstance().tableBackgroundColor()
        segmentControl.selectedIndex = 0
        segmentControl.addTarget(self, action: "segmentValueChanged:", forControlEvents: .ValueChanged)

        // Default to hand knee and foot which will be the first game chosen
        checkGameChosen(0)
    }

    

    // ***** BUTTON MANAGEMENT  **** //

    // Segmented Control - a Game was chosen
    func segmentValueChanged(sender: AnyObject?){

        checkGameChosen(segmentControl.selectedIndex!)
    }


    // Check if game chosen and set the game
    func checkGameChosen(gameChosen: Int!) {

        selectedGameID = gameTypes[gameChosen]
        if gameChosen == 3  {
            numberOfTeams = 3
        } else {
            numberOfTeams = 2
        }

        // Game was chosen
        startButton.enabled = true
        startButton.backgroundColor = Style.sharedInstance().keyButtonControl()
 
        // Load the team/player controls
        loadTeamPlayers (numberOfTeams)
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



    // Cancel was chosen
    @IBAction func cancelNewGameButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // Start Game Button was Selected
    @IBAction func startGameAction(sender: AnyObject) {

        // Locate the game profile we are using
        for gameProfile in fetchedGameProfiles  {

            if gameProfile.gameProfileId == selectedGameID {

                selectedProfileScoreElementId = gameProfile.profileScoreElementId

                // Fetch the selected game profile scoring entries to send to be loaded when the game is added
                do {
                    try fetchedResultsController2.performFetch()
                } catch {}

                // Set the fetchedResultsController.delegate = self
                fetchedResultsController2.delegate = self

                let profileScoreElementArray = fetchedResultsController2.fetchedObjects as! [ProfileScoreElement]

                let dictionary: [String : AnyObject] = [
                    Game.Keys.team1Player1 : teamPlayerArray[0][0]["PlayerName"]!,
                    Game.Keys.team1Player2 : teamPlayerArray[0][1]["PlayerName"]!,
                    Game.Keys.team2Player1 : teamPlayerArray[1][0]["PlayerName"]!,
                    Game.Keys.team2Player2 : teamPlayerArray[1][1]["PlayerName"]!,
                    Game.Keys.team3Player1 : teamPlayerArray[2][0]["PlayerName"]!,
                    Game.Keys.team3Player2 : teamPlayerArray[2][1]["PlayerName"]!,
                    Game.Keys.team1Player1Initials : teamPlayerArray[0][0]["PlayerInitials"]!,
                    Game.Keys.team1Player2Initials : teamPlayerArray[0][1]["PlayerInitials"]!,
                    Game.Keys.team2Player1Initials : teamPlayerArray[1][0]["PlayerInitials"]!,
                    Game.Keys.team2Player2Initials : teamPlayerArray[1][1]["PlayerInitials"]!,
                    Game.Keys.team3Player1Initials : teamPlayerArray[2][0]["PlayerInitials"]!,
                    Game.Keys.team3Player2Initials : teamPlayerArray[2][1]["PlayerInitials"]!,
                    Game.Keys.team1Player1ImageName : teamPlayerArray[0][0]["PlayerImageName"]!,
                    Game.Keys.team1Player2ImageName :teamPlayerArray[0][1]["PlayerImageName"]!,
                    Game.Keys.team2Player1ImageName : teamPlayerArray[1][0]["PlayerImageName"]!,
                    Game.Keys.team2Player2ImageName : teamPlayerArray[1][1]["PlayerImageName"]!,
                    Game.Keys.team3Player1ImageName : teamPlayerArray[2][0]["PlayerImageName"]!,
                    Game.Keys.team3Player2ImageName : teamPlayerArray[2][1]["PlayerImageName"]!,
                    Game.Keys.maximumNumberOfTeams : numberOfTeams
                ]

                let _ = Game(dictionary: dictionary, context: sharedContext, profileGame: gameProfile, profileScoreElementArray: profileScoreElementArray)

                CoreDataStackManager.sharedInstance().saveContext()
            }
        }

        dismissViewControllerAnimated(true, completion: nil)
    }




    // Delegate from the team player view controller when a player was selected
    func playerChosen(controller: TeamPlayerCollectionViewController, selectedPlayer: Player, teamPlayerID: Int!) {

        // Using the tag ID which is the teamPlayer ID, separate into team and player

        let tagDictionary = sf.separateTagId(teamPlayerID, option: "TeamPlayer")
        let teamID  =  tagDictionary["team"]
        let teamIndex =  Int(teamID!)!  - 1
        let playerNumber  = Int(tagDictionary["player"]!)
        let playerIndex = playerNumber! - 1

        // Get the background color based on the team number/ID
        let backgroundColor = sf.setTeamBackgroundColor(teamID!)

        // Update the Array that will be used to insert into the Game
        setPlayerInformation(selectedPlayer, teamIndex: teamIndex, playerIndex: playerIndex)

        // Update the team/Player button with the new players icon or image
        sf.setButton (self.view.viewWithTag(teamPlayerID) as? UIButton, imageTextString: selectedPlayer.pictureFileName!, backgroundColor: backgroundColor)

        // Update the label for the player namr
        var tagID = 0
        if playerNumber == 1 {
            tagID = Int(teamID! + "4")!
        } else {
            tagID = Int(teamID! + "5")!
        }

        // Set the name label
        sf.setLabel(view.viewWithTag(tagID) as? UILabel, imageTextString: selectedPlayer.name, backgroundColor: backgroundColor)
    }


    func setPlayerInformation(player: Player!, teamIndex: Int!, playerIndex: Int!) {
        // Update the Array that will be used to insert into the Game
        teamPlayerArray[teamIndex][playerIndex].updateValue(player.name, forKey: "PlayerName")
        teamPlayerArray[teamIndex][playerIndex].updateValue(player.initials, forKey: "PlayerInitials")
        teamPlayerArray[teamIndex][playerIndex].updateValue(player.pictureFileName, forKey: "PlayerImageName")
    }


    // ***** MANAGE BUTTONS, LABELS ON VIEW  **** //

    // Load the teams
    func loadTeamPlayers(numberOfTeams: Int) {

        // Loop through all the teams, all the players, loading images, names and background colors for 2 or 3 teams
        for teamNumber in 1...3 {

            let teamIndex = teamNumber - 1
            var playerIndex = 0

            // Get the background color based on the team number/ID
            var backgroundColor: UIColor = UIColor.whiteColor()
            backgroundColor = sf.setTeamBackgroundColor(String(teamNumber))

            // Control =  "0" is the image that indicates the team number


            // Set team Number images (tag 10, 20, 30)
            //If team number is 3 and there are not 3 times just fill with whitespace else set to number in solid round
            if teamNumber == 3 && numberOfTeams < 3 {
                sf.setImage(view.viewWithTag(teamNumber * 10) as! UIImageView, imageTextString: "whitespace")
            }  else  {
                let imageName = "iconRound" + String(teamNumber)
                sf.setImage(view.viewWithTag(teamNumber * 10) as! UIImageView, imageTextString: imageName)
            }

            // Loop through all 5 controls loading them up
            for control in 1...5 {

                let teamPlayerTemp: String = String(teamNumber) + String(control)
                let teamPlayerID = Int(teamPlayerTemp)!

                switch teamPlayerID {

                // Player 1
                case 11, 14, 21, 24, 31, 34:
                    playerIndex = 0
                    break

                //Player 2
                case 12, 15, 22, 25, 32, 35:
                    playerIndex = 1
                    break

                default:
                    break
                }


                let tag = String(teamNumber) + String(control)
                let tagID = Int(tag)
 

                if let playerName = teamPlayerArray[teamIndex][playerIndex]["PlayerName"] {

                    // Locate the player and set initials and image name
                    for fetchedPlayer in fetchedResultsControllerPlayers.fetchedObjects as! [Player] {

                        if playerName == fetchedPlayer.name {

                            // Update the Array that will be used to insert into the Game
                            setPlayerInformation(fetchedPlayer, teamIndex: teamIndex, playerIndex: playerIndex)
                        }
                    }

                    // Control 1 or 2 Player Image
                    if control == 1 || control == 2  {

                        // There is no team three, set to whitespace
                        if teamNumber == 3 && numberOfTeams < 3 {
                            sf.setButton(view.viewWithTag(tagID!) as? UIButton, imageTextString: "whitespace", backgroundColor: UIColor.whiteColor())

                        } else {
                            // Set image to players image
                            if let playerImageName = teamPlayerArray[teamIndex][playerIndex]["PlayerImageName"]  {

                                //setButton(button, imageTextString: playerImageName, backgroundColor: backgroundColor)
                                sf.setButton(view.viewWithTag(tagID!) as? UIButton, imageTextString: playerImageName, backgroundColor: backgroundColor)
                            } else {

                                // For some reason, picture has not been set... set to missing player image
                                sf.setButton(view.viewWithTag(tagID!) as? UIButton, imageTextString: "missingPlayer", backgroundColor: backgroundColor)
                            }
                        }
                    }


                    // Set the Player Name
                    if control == 4 || control == 5  {

                        // Blank out name if no team 3
                        if teamNumber == 3 && numberOfTeams < 3 {
                            sf.setLabel( view.viewWithTag(tagID!) as? UILabel, imageTextString:"   ",  backgroundColor: UIColor.whiteColor())

                        } else {
                            if let playerName = teamPlayerArray[teamIndex][playerIndex]["PlayerName"] {

                                //Set the label name for the player
                                sf.setLabel(view.viewWithTag(tagID!) as? UILabel, imageTextString: playerName, backgroundColor: backgroundColor)
                            }   else {

                                // Name not found set to unknown
                                sf.setLabel( view.viewWithTag(tagID!) as? UILabel, imageTextString: "Unknown", backgroundColor: backgroundColor)
                            }
                        }
                    }
                }
            }
        }
    }



    // When view is first presented, set all the controls to white space
    func hideControls() {

        for team in 1...3 {

            // set Player Image buttons to white space and a white background
            for button in 0...2 {

                let tag = String(team) + String(button)
                let tagID = Int(tag)

                // Hide the information
                sf.setButton(view.viewWithTag(tagID!) as? UIButton, imageTextString: "whitespace", backgroundColor: UIColor.whiteColor() )
            }

            // Set the Player Name labels to blanks and background white
            for label in 3...5 {

                let tag = String(team) + String(label)
                let tagID = Int(tag)

                sf.setLabel(view.viewWithTag(tagID!) as? UILabel, imageTextString: "    ", backgroundColor: UIColor.whiteColor())
            }
        }
    }



    // ***** CORE DATA  MANAGEMENT  **** //

    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Fetch all saved Game Profiles
    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "ProfileGame")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "gameProfileId", ascending: true)]


        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        return fetchedResultsController
    }()


    // Fetch the scoring rules for the game -- used to pre-load the rules when the game is added
    lazy var fetchedResultsController2: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "ProfileScoreElement")
        fetchRequest.predicate = NSPredicate(format: "gameProfileId == %@", self.selectedProfileScoreElementId!);
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "elementNumber", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    
    // Fetch the Players, need to get their image/icon, name and initials to display and save with the game
    lazy var fetchedResultsControllerPlayers: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Player")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    

    
}
