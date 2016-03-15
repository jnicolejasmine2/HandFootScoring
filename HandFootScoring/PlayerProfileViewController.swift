//
//  PlayerProfileViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 3/4/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//


import UIKit
import CoreData

class PlayerProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate    {

    // TextFields
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var playerInitials: UITextField!
    @IBOutlet weak var playerEmail: UITextField!
    @IBOutlet weak var playerPhone: UITextField!
    private let textDelegate = TextFieldDelegate()

    var allTextFields: [UITextField]!

      // Image Controls along with variable to support selecting an image
    @IBOutlet weak var playerImage: UIImageView!

    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var iconButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!

    var playerFileName: String?
    private var imagePicker = UIImagePickerController()
    var lastIconNumber: Int = 1


    // Buttons
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    // Fetched Player Profiles
    var fetchedPlayers: [Player] = []

    var selectedPlayer: Player?



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up to dismiss the keyboards when tapped outside
        allTextFields = [playerName, playerInitials, playerEmail, playerPhone]

        // Set the three text delegates
        playerName.delegate = textDelegate
        playerInitials.delegate = textDelegate
        playerEmail.delegate = textDelegate
        playerPhone.delegate = textDelegate


        // Set the control colors
        updateProfileButton.backgroundColor = Style.sharedInstance().keyButtonControl()
        cancelButton.tintColor = Style.sharedInstance().keyButtonControl()
        cameraButton.tintColor = Style.sharedInstance().keyButtonControl()
        albumButton.tintColor = Style.sharedInstance().keyButtonControl()
        iconButton.tintColor = Style.sharedInstance().keyButtonControl()
         deleteButton.tintColor = Style.sharedInstance().keyButtonControl()

        // Dismiss keyboards
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboardFromView"))

        // Set the verbiage for the add/update 
        if selectedPlayer == nil {
            updateProfileButton.setTitle("Add Player", forState: UIControlState.Normal )
        }
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Enable camera button if the phone has a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.Camera)

    }

    func dismissKeyboardFromView() {
        for textField in allTextFields {
            textField.resignFirstResponder()
        }
    }


    // ***** BUTTON MANAGEMENT  **** //
    @IBAction func cancelButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // Select an image from the photo album
    @IBAction func pickAnImage(sender: AnyObject) {
        pickAnImageControl(.PhotoLibrary)
    }


    // Camara Take a photo with the Camera
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        pickAnImageControl(.Camera)
    }



    // Touching icon rotates through icons
    @IBAction func iconButtonAction(sender: AnyObject) {

        ++lastIconNumber

        if lastIconNumber > 9 {
            lastIconNumber = 1
        }

        let iconName = "icon" + String(lastIconNumber)
        playerImage.image = UIImage(named: iconName)
        playerImage.contentMode = .Center

        playerFileName = iconName
    }


    // Add or Update the player ( FOR NOW ONLY DOING AN INSERT....................!!! NEED TO FINISH WITH PROFILE MANAGEMENT)
    @IBAction func updateButtonAction(sender: AnyObject) {

        var missingElementNumber = 0
        var errorMessage = " "

        // Edit that the name, initials, photo/icon are entered/selected. If not build the message to show in alert
        if playerName.text == "" || playerName.text == " " {

            errorMessage = errorMessage + "Name"
            ++missingElementNumber

        } else {

            // Check for duplicate player. If one is found, build the alert and present it.
            for player in fetchedPlayers {

                if player.name == playerName.text {

                    self.presentAlert("Player name is already used.", includeOK: true )
                    return
                }
            }
        }

        // Check for initials were entered.  If not build the message to show in alert
        if playerInitials.text == "" || playerInitials.text == " " {

            if missingElementNumber > 0 {
                errorMessage = errorMessage + ", "
            }
            errorMessage = errorMessage + "Initials"
            ++missingElementNumber

        }else {

            // Check for duplicate initials. If found, present alert.
            for player in fetchedPlayers {
                if player.initials == playerInitials.text {

                    self.presentAlert("Player initials are already used.", includeOK: true )
                    return
                }
            }
        }


        // Check if a photo/Icon was selected. If not prepare an edit message for the alert.
        if playerFileName == nil {

            if missingElementNumber > 0 {
                errorMessage = errorMessage + ", "
            }
            errorMessage = errorMessage + "Photo/Icon"
            ++missingElementNumber

        }

       // Check if a required element is missing. Adjust the message and present the alert
        if missingElementNumber == 1 {

            errorMessage = errorMessage + " is required."
            self.presentAlert(errorMessage, includeOK: true )

        } else   if missingElementNumber > 1 {

            errorMessage = errorMessage + " are required."
            self.presentAlert(errorMessage, includeOK: true )

        } else {

            // Passed the Edits, insert/update the player  (FOR NOW ONLY DO AN INSERT !!!!!!!!!!!)
            var dictionary: [String : AnyObject] = [

                Player.Keys.name : playerName.text!,
                Player.Keys.initials : playerInitials.text!
            ]

            if playerEmail !=  nil {
                dictionary[Player.Keys.emailAddress] =  playerEmail.text!
            }

            if playerPhone !=  nil {
                dictionary[Player.Keys.phoneNumber] =  playerPhone.text!
            }

            if playerFileName !=  nil {
                dictionary[Player.Keys.pictureFileName] =  playerFileName!
            }
            
            let _ = Player(dictionary: dictionary, context: self.sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()

            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // Delete the Player 
    @IBAction func deletePlayer(sender: AnyObject) {
    }


    // ***** SELECT AN IMAGE MANAGEMENT  **** //

    // Either opens Album or Camera based on option chosen
    func pickAnImageControl(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }


    // Show photo that was selected from Album or picture that was taken
    // Save selected image in the documents folder
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject])  {

        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        playerImage.contentMode = .ScaleAspectFit
        playerImage.image = chosenImage

        var filename: String?

        // Using unique ID for the document name
        let uniqueID = NSUUID()
        filename = uniqueID.UUIDString
        playerFileName = filename

        let playerImageData = UIImagePNGRepresentation(playerImage.image!)

        // Save image in documents folder
        if let fileURL = self.imageFileURL(filename!).path {
            NSFileManager.defaultManager().createFileAtPath(fileURL, contents: playerImageData,   attributes:nil)
        }

        dismissViewControllerAnimated(true, completion: nil)
    }


    // Get access to the documents folder and add the photo file name
    func imageFileURL(fileName: String) ->  NSURL {

        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

        let pathArray = [dirPath, fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        return fileURL
    }


    // Image was not selected or taken
    func imagePickerControllerDidCancel(_: UIImagePickerController){
        dismissViewControllerAnimated(true, completion: nil)
    }



    // ***** CORE DATA  MANAGEMENT  **** //

    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    

    
    // ***** ALERT MANAGEMENT  **** //

    func presentAlert(alertMessage: String, includeOK: Bool ) {

        print("got to alert")

        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)

        // Option: OK
        if includeOK  {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                action in

                dispatch_async(dispatch_get_main_queue(), {
                    self.viewDidLoad()
                })
            }))
        }

        // Present the Alert!
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    



}

