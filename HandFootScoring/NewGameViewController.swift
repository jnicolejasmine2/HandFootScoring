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

    var fetchedGameProfiles: [ProfileGame] = []

    var newTeam1Player1: String = "GuestA"
    var newTeam1Player2: String = "GuestB"
    var newTeam2Player1: String = "GuestC"
    var newTeam2Player2: String = "GuestD"
    var newTeam3Player1: String = "GuestE"
    var newTeam3Player2: String = "GuestF"

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


        segmentControl.items = ["Hand, Knee\n& Foot", "Hand, Knee\n& Foot\n(Set Meld)", "Hand & Foot", "Hand & Foot\n(3 Teams)"]
        segmentControl.font = UIFont(name: "Helvetica Neue", size: 14)
        segmentControl.borderColor = Style.sharedInstance().tableBackgroundColor()
        segmentControl.selectedIndex = 0

        // Default to hand knee and foot 
        checkGameChosen(0)
        segmentControl.addTarget(self, action: "segmentValueChanged:", forControlEvents: .ValueChanged)

    }



    // ***** BUTTON MANAGEMENT  **** //

    // Segmented COntrol
    func segmentValueChanged(sender: AnyObject?){

        let gameChosen = segmentControl.selectedIndex!

        checkGameChosen(gameChosen)

    }

    // Check if game chosen and set the game 
    func checkGameChosen(gameChosen: Int!) {

        // Save off the team member names
        switch gameChosen {
        case 0:
            selectedGameID = "HNFThreshhold"
            numberOfTeams = 2
            break

        case 1:
            selectedGameID = "HNFStatic"
            numberOfTeams = 2
            break

        case 2:
            selectedGameID = "HFStatic"
            numberOfTeams = 2
            break

        case 3:
            selectedGameID = "HFStatic3Team"
            numberOfTeams = 3
            break

        default:
            selectedGameID = " "
            break
        }

        // Game was chosen
        startButton.enabled = true
        startButton.backgroundColor = Style.sharedInstance().keyButtonControl()


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

                // Save the Game to core data
                let dictionary: [String : AnyObject] = [
                    Game.Keys.team1Player1 : newTeam1Player1,
                    Game.Keys.team1Player2 : newTeam1Player2,
                    Game.Keys.team2Player1 : newTeam2Player1,
                    Game.Keys.team2Player2 : newTeam2Player2,
                    Game.Keys.team3Player1 : newTeam3Player1,
                    Game.Keys.team3Player2 : newTeam3Player2,
                    Game.Keys.team1Player1Initials : newTeam1Player1Initials,
                    Game.Keys.team1Player2Initials : newTeam1Player2Initials,
                    Game.Keys.team2Player1Initials : newTeam2Player1Initials,
                    Game.Keys.team2Player2Initials : newTeam2Player2Initials,
                    Game.Keys.team3Player1Initials : newTeam3Player1Initials,
                    Game.Keys.team3Player2Initials : newTeam3Player2Initials,
                    Game.Keys.team1Player1ImageName : newTeam1Player1ImageName,
                    Game.Keys.team1Player2ImageName : newTeam1Player2ImageName,
                    Game.Keys.team2Player1ImageName : newTeam2Player1ImageName,
                    Game.Keys.team2Player2ImageName : newTeam2Player2ImageName,
                    Game.Keys.team3Player1ImageName : newTeam3Player1ImageName,
                    Game.Keys.team3Player2ImageName : newTeam3Player2ImageName,
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

        // Initalize variables for load
        let _ = setPlayerInformation (selectedPlayer.name, controlTagNumber: teamPlayerID)

        let selectedButton = self.view.viewWithTag(teamPlayerID) as! UIButton

        let teamPlayerIDValue = String(teamPlayerID)
        let index1 = teamPlayerIDValue.startIndex.advancedBy(0)
        let teamID = String(teamPlayerIDValue[index1])

        // Get the background color based on the team number/ID
        let backgroundColor = setTeamBackgroundColor(teamID)


        // Update the team/Player button with the new players icon or image
        if let _ = selectedPlayer.pictureFileName!.rangeOfString("icon") {
            setButton (selectedButton, imageTextString: selectedPlayer.pictureFileName!, backgroundColor: backgroundColor)

        }  else {
            // saved Photo
            let photoDocumentsFileName = selectedPlayer.pictureFileName

            // Put the image from the documents folder into the cell
            let photoDocumentsUrl = imageFileURL(photoDocumentsFileName!).path

            // Check if photo is still in documents folder
            let manager = NSFileManager.defaultManager()
            if (manager.fileExistsAtPath(photoDocumentsUrl!)) {
                let documentImage = UIImage(contentsOfFile: photoDocumentsUrl!)!
                setButtonFromDocument(selectedButton, image: documentImage, backgroundColor: backgroundColor)
            } else {
                
                // For some reason, picture has not been set... set to missing player image
                setButton(selectedButton, imageTextString: "missingPlayer", backgroundColor: backgroundColor)
            }
        }


        // Update the label for the player name
        let index2 = teamPlayerIDValue.startIndex.advancedBy(1)
        let playerID = String(teamPlayerIDValue[index2])

        var tagID = 0
        if playerID == "1" {
            tagID = Int(teamID + "4")!
        } else {
            tagID = Int(teamID + "5")!
        }

        if let label  = view.viewWithTag(tagID) as? UILabel  {
            setLabel(label, imageTextString: selectedPlayer.name, backgroundColor: backgroundColor)
        }
    }


    // Build the URL to retrieve the photo from the documents folder
    func imageFileURL(fileName: String) ->  NSURL {

        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

        let pathArray = [dirPath, fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!

        return fileURL
    }



    // ***** MANAGE BUTTONS, LABELS ON VIEW  **** //

    // Loop through all the players to get the initials and picture/icon
    func setPlayerInformation (teamPlayer: String, controlTagNumber: Int) -> Player? {


        // Loop through all players and find he matching player. 
        // Then update the correct teamplayer information that will be used when the game is added
        for fetchedPlayer in fetchedResultsControllerPlayers.fetchedObjects as! [Player] {

            if teamPlayer == fetchedPlayer.name {

                switch controlTagNumber {
                case 11, 14:
                    newTeam1Player1 = fetchedPlayer.name
                    newTeam1Player1Initials = fetchedPlayer.initials
                    newTeam1Player1ImageName = fetchedPlayer.pictureFileName
                    return fetchedPlayer

                case 12, 15:
                    newTeam1Player2 = fetchedPlayer.name
                    newTeam1Player2Initials = fetchedPlayer.initials
                    newTeam1Player2ImageName = fetchedPlayer.pictureFileName
                    return fetchedPlayer

                case 21, 24:
                    newTeam2Player1 = fetchedPlayer.name
                    newTeam2Player1Initials = fetchedPlayer.initials
                    newTeam2Player1ImageName = fetchedPlayer.pictureFileName
                    return fetchedPlayer

                case 22, 25:
                    newTeam2Player2 = fetchedPlayer.name
                    newTeam2Player2Initials = fetchedPlayer.initials
                    newTeam2Player2ImageName = fetchedPlayer.pictureFileName
                    return fetchedPlayer

                case 31, 34:
                    newTeam3Player1 = fetchedPlayer.name
                    newTeam3Player1Initials = fetchedPlayer.initials
                    newTeam3Player1ImageName = fetchedPlayer.pictureFileName
                    return fetchedPlayer

                case 32, 35:
                    newTeam3Player2 = fetchedPlayer.name
                    newTeam3Player2Initials = fetchedPlayer.initials
                    newTeam3Player2ImageName = fetchedPlayer.pictureFileName
                    return fetchedPlayer

                default:
                    break
                }

            }
        }
        return nil
    }



    // Load the teams
    func loadTeamPlayers(numberOfTeams: Int) {

        // Loop through all the teams, all the players, loading images, names and background colors for 2 or 3 teams
        for teamNumber in 1...3 {
            var backgroundColor: UIColor = UIColor.whiteColor()

            for control  in 0...5 {

                var teamPlayer = " "
                let teamPlayerTemp: String = String(teamNumber) + String(control)
                let teamPlayerID = Int(teamPlayerTemp)!

                print("teamPlayerID: \(teamPlayerID)")
                switch teamPlayerID {
                case 11, 14:
                    teamPlayer = newTeam1Player1
                    break
                case 12, 15:
                    teamPlayer = newTeam1Player2
                    break
                case 21, 24:
                    teamPlayer = newTeam2Player1
                    break
                case 22, 25:
                    teamPlayer = newTeam2Player2
                    break
                case 31, 34:
                    teamPlayer = newTeam3Player1
                    break
                case 32, 35:
                    teamPlayer = newTeam3Player2
                    break

                default:
                    break
                }

                // Get the background color based on the team number/ID
                backgroundColor = setTeamBackgroundColor(String(teamNumber))

                let tag = String(teamNumber) + String(control)
                let tagID = Int(tag)


                // Control =  "0" is the image that indicates the team number
                if control == 0 {

                    let image = view.viewWithTag(tagID!) as! UIImageView

                    //If team number is 3 and there are not 3 times just fill with whitespace else set to number in solid round
                    if teamNumber == 3 && numberOfTeams < 3 {
                        setImage(image, imageTextString: "whitespace")
                    }  else  {
                        let imageName = "iconRound" + String(teamNumber)
                        setImage(image, imageTextString: imageName)
                    }

                }

                // Find the current player, setting the variables and finding the matching player from the fetched profile
                let fetchedPlayer = setPlayerInformation (teamPlayer, controlTagNumber: teamPlayerID)

                if fetchedPlayer != nil {

                    // Load player image from their profile
                    if control == 1 || control == 2  {
                        if let button = view.viewWithTag(tagID!) as? UIButton     {

                            // Set image to players image
                            if fetchedPlayer!.pictureFileName != nil {
                                setButton(button, imageTextString: fetchedPlayer!.pictureFileName!, backgroundColor: backgroundColor)

                            } else {

                                // For some reason, picture has not been set... set to missing player image
                                setButton(button, imageTextString: "missingPlayer", backgroundColor: backgroundColor)
                            }

                            // There is no team three, set to whitespace
                            if teamNumber == 3 && numberOfTeams < 3 {
                                setButton(button, imageTextString: "whitespace", backgroundColor: UIColor.whiteColor())
                            }
                        }
                    }

                    // Set the Team Player Name
                    if control == 4 || control == 5  {
                        // Update the label for the player name
                        if let label  = view.viewWithTag(tagID!) as? UILabel  {

                            // Blank out name if no team 3
                            if teamNumber == 3 && numberOfTeams < 3 {
                                setLabel(label, imageTextString:"   ",  backgroundColor: UIColor.whiteColor())
                                
                            } else {
                                
                                //Set the label name for the player
                                setLabel(label, imageTextString: fetchedPlayer!.name, backgroundColor: backgroundColor)
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
                if let buttonControl = view.viewWithTag(tagID!) as? UIButton  {
                    setButton(buttonControl, imageTextString: "whitespace", backgroundColor: UIColor.whiteColor() )
                }
            }

            // Set the Player Name labels to blanks and background white
            for label in 3...5 {

                let tag = String(team) + String(label)
                let tagID = Int(tag)

                if let labelControl = view.viewWithTag(tagID!) as? UILabel  {
                    setLabel(labelControl, imageTextString: "    ", backgroundColor: UIColor.whiteColor())
                }
            }
        }
    }


    // Set images
    func setImage (image: UIImageView!, imageTextString: String!) {

        dispatch_async(dispatch_get_main_queue(), {
            image.hidden = true

            image.image = UIImage(named: imageTextString)
            if imageTextString ==  "whitespace" {
                image.backgroundColor = UIColor.whiteColor()
            }

            image.hidden = false
        })

    }

    // Set button image from an Icon
    func setButton (button: UIButton!, imageTextString: String!, backgroundColor: UIColor) {

        dispatch_async(dispatch_get_main_queue(), {
            button.hidden = true

            button.setImage(UIImage(named: imageTextString),  forState: UIControlState.Normal)
            button.backgroundColor = backgroundColor
            button.hidden = false
        })

    }

    // Set button image from a saved photo in the documents folder
    func setButtonFromDocument (button: UIButton!, image: UIImage, backgroundColor: UIColor) {

        dispatch_async(dispatch_get_main_queue(), {
            button.hidden = true

            button.setImage(image, forState: UIControlState.Normal)
            button.backgroundColor = backgroundColor
            button.hidden = false
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
