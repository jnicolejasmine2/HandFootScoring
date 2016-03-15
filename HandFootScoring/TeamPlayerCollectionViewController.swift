//
//  TeamPLayerCollectionViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/19/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//


//

import Foundation
import UIKit
import CoreData

class  TeamPlayerCollectionViewController: UIViewController, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate    {

    @IBOutlet var teamMemberCollection: UICollectionView!

    var selectedTeamPlayer: Int = 0

    var delegate: TeamPlayerCollectionViewControllerDelegate?

    var selectedPlayer: Player?
    var teamPlayerID: Int?

    var fetchedPlayerArray: [Player] = []


    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var newPlayerPlusSignButton: UIBarButtonItem!
    
    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)


        print("Got to TeamPlayerCollectionViewController- teamPlayerID: \(teamPlayerID)")

        // Fetch any existing Existing Games -- Only needed at this point for debugging move to the new game vc at that time
        do {
            try fetchedResultsController.performFetch()
        } catch {}

        fetchedPlayerArray = fetchedResultsController.fetchedObjects as! [Player]

        // Set the fetchedresultscontroller for the pin
        fetchedResultsController.delegate = self

        let sectionInfo = fetchedResultsController.sections![0]
        print("Number of Returned objects: \(sectionInfo.numberOfObjects)")

        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
        _ = fetchedResultsController.fetchedObjects as! [Player]

        // Reload data when returned from other views
        teamMemberCollection.reloadData()

        // Set background color of New Player Button
        cancelButton.tintColor = Style.sharedInstance().keyButtonControl()
        newPlayerPlusSignButton.tintColor = Style.sharedInstance().keyButtonControl()


    }

    @IBAction func cancelButtonAction(sender: AnyObject) {

        dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func newPlayerButtonAction(sender: AnyObject) {

        let newPlayerController = storyboard!.instantiateViewControllerWithIdentifier("PlayerProfileViewController") as! PlayerProfileViewController
                 // Present the view controller


        newPlayerController.fetchedPlayers = fetchedPlayerArray

        presentViewController(newPlayerController, animated: true, completion: nil)
        

    }

    // ***** COLLECTION MANAGEMENT  **** //

    // Number of Items
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects

    }


    // Load the images into the collection
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // Using a custom cell
        let cell: PlayerCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("TeamPlayerCell", forIndexPath: indexPath) as! PlayerCollectionCell

        // Get the photo that is being formatted
        let player = fetchedResultsController.objectAtIndexPath(indexPath) as! Player

    
        cell.playerName.text = player.name

        if let _ = player.pictureFileName!.rangeOfString("icon") {

            cell.collectionCellImage.image = UIImage(named: player.pictureFileName!)

        } else {
            // saved Photo
            let photoDocumentsFileName = player.pictureFileName

            // Put the image from the documents folder into the cell
            let photoDocumentsUrl = imageFileURL(photoDocumentsFileName!).path

            // Check if photo is still in documents folder
            let manager = NSFileManager.defaultManager()
            if (manager.fileExistsAtPath(photoDocumentsUrl!)) {

                let photoImage = UIImage(contentsOfFile: photoDocumentsUrl!)
                cell.collectionCellImage.image = photoImage
                cell.collectionCellImage.contentMode = .ScaleAspectFit

            }
        }



        return cell
    }



    // Build the URL to retrieve the photo from the documents folder
    func imageFileURL(fileName: String) ->  NSURL {

        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

        let pathArray = [dirPath, fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!

        return fileURL
    }



    // When a meme is selected, push the MemedView controller.  Pass the Meme (used to present details) and the indexPath.Row (used for delete)
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        print("selectedfromCollectionView: \(indexPath.item)")

        // Get the photo that is being formatted
        let selectedPlayer = fetchedResultsController.objectAtIndexPath(indexPath) as! Player

        // Send back to the add location view controller so it can be presented and submitted
        self.delegate!.playerChosen(self, selectedPlayer: selectedPlayer, teamPlayerID: teamPlayerID)

        dismissViewControllerAnimated(true, completion: nil)
    }


    // ***** CORE DATA  MANAGEMENT - PHOTO  **** //
    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Fetch all existing Players that can be assigned to a team
    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Player")

        // Sort by gameProfileId
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()


    // Called when core data is modified
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType,newIndexPath: NSIndexPath?) {
        let objectName = anObject.entity.name

        switch type {

            // Insert a new photo
        case .Insert:
            print(".insert")
            if objectName == "Player"  {
                teamMemberCollection.insertItemsAtIndexPaths([newIndexPath!])
            }

            break

            // Deleting a photo
        case .Delete:
            print(".deletePlayer: \(indexPath)")
            if objectName == "Player"  {

            }
            break


        case .Update:
            print(".update")
            if objectName == "Player"  {

               

            }
            
            break;
            // Move
        case .Move:
            break
        }
    }
    

}



// Needed so that the location and coordinates can be sent back to the Add information
protocol TeamPlayerCollectionViewControllerDelegate {
    func playerChosen(controller: TeamPlayerCollectionViewController, selectedPlayer: Player, teamPlayerID: Int!)
}


