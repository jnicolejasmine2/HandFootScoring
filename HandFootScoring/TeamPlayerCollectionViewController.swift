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

    // Passed data -- Tag ID that identifies the team and player to be changed
    var teamPlayerID: Int?

    // Variables

    var selectedPlayer: Player?
    var fetchedPlayerArray: [Player] = []

    // Delegate used to pass back the team player chosen
    var delegate: TeamPlayerCollectionViewControllerDelegate?
    

    // Outlets
    @IBOutlet var teamMemberCollection: UICollectionView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var newPlayerPlusSignButton: UIBarButtonItem!


    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Fetch all players
        do {
            try fetchedResultsController.performFetch()
        } catch {}

        // Set the array
        fetchedPlayerArray = fetchedResultsController.fetchedObjects as! [Player]

        // Set the fetchedresultscontroller for the players
        fetchedResultsController.delegate = self

        // Reload data when returned from other views
        teamMemberCollection.reloadData()

        // Set background color of New Player Button
        cancelButton.tintColor = Style.sharedInstance().keyButtonControl()
        newPlayerPlusSignButton.tintColor = Style.sharedInstance().keyButtonControl()
    }



// ***** BUTTON MANAGEMENT  **** //


    // Canel was chosen, return to new game screen
    @IBAction func cancelButtonAction(sender: AnyObject) {

        dismissViewControllerAnimated(true, completion: nil)
    }


    // New player button was selected. Send the player array so the view can check for a duplicate player
    @IBAction func newPlayerButtonAction(sender: AnyObject) {

        let newPlayerController = storyboard!.instantiateViewControllerWithIdentifier("PlayerProfileViewController") as! PlayerProfileViewController

        // Send the fetched player array, used to check for duplicates
        newPlayerController.fetchedPlayers = fetchedPlayerArray

        presentViewController(newPlayerController, animated: true, completion: nil)
    }




    // ***** COLLECTION MANAGEMENT  **** //

    // Number of Items
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }


    // Load the players into the collection
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // Using a custom cell
        let cell: PlayerCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("TeamPlayerCell", forIndexPath: indexPath) as! PlayerCollectionCell

        // get the player being formatted
        let player = fetchedResultsController.objectAtIndexPath(indexPath) as! Player

        // set the name
        cell.playerName.text = player.name

        // Check if the player has their own picture or selected one of the icons
        if let _ = player.pictureFileName!.rangeOfString("icon") {

            cell.collectionCellImage.image = UIImage(named: player.pictureFileName!)
            cell.collectionCellImage.contentMode = .Center

        } else {
            // saved Photo
            let photoDocumentsFileName = player.pictureFileName

            // Put the image from the documents folder into the cell
            let photoDocumentsUrl = sf.imageFileURL(photoDocumentsFileName!).path

            // Check if photo is still in documents folder
            let manager = NSFileManager.defaultManager()
            if (manager.fileExistsAtPath(photoDocumentsUrl!)) {

                let photoImage = UIImage(contentsOfFile: photoDocumentsUrl!)
                cell.collectionCellImage.image = photoImage
                cell.collectionCellImage.contentMode = .ScaleAspectFit
            }
        }

        // Set background color so the cell is visible for selection
        cell.contentView.backgroundColor = Style.sharedInstance().tableBackgroundColor()

        return cell
    }


    // When a player is selected, pass the information back to the new game controller using the delegate function
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        // Get the player that was selected
        let selectedPlayer = fetchedResultsController.objectAtIndexPath(indexPath) as! Player

        // Send back to the new game view
        self.delegate!.playerChosen(self, selectedPlayer: selectedPlayer, teamPlayerID: teamPlayerID)

        dismissViewControllerAnimated(true, completion: nil)
    }




    // ***** CORE DATA  MANAGEMENT - PLAYERS  **** //

    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Fetch all existing Players that can be assigned to a team
    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Player")

        // Sort by name
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()



    // Called when core data when a player is added
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType,newIndexPath: NSIndexPath?) {

        guard let managedObject = anObject as? NSManagedObject else { fatalError() }
        let objectName = managedObject.entity.name

        switch type {

        case .Insert:
            if objectName == "Player"  {
                teamMemberCollection.insertItemsAtIndexPaths([newIndexPath!])
            }
            break

        case .Delete:
            break

        case .Update:
            break;

        case .Move:
            break
        }
    }


}



// Needed so that the selected player can be updated in the new game view controller
protocol TeamPlayerCollectionViewControllerDelegate {
    func playerChosen(controller: TeamPlayerCollectionViewController, selectedPlayer: Player, teamPlayerID: Int!)
}

