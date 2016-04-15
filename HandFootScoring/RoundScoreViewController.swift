//
//  RoundScoreViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 2/26/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import CoreData

class RoundScoreViewController: UIViewController, NSFetchedResultsControllerDelegate, CardCountViewControllerDelegate {

    // Passed Variables
    var selectedGameID: String?
    var selectedRoundNumber: Int?
    var selectedTeamNumber: Int?
    var selectedViewTitle: String = " "
    var otherTeamInitials: String = " "
    var Other3rdTeamInitials: String = " "
    var calculatedRoundScore = 0

    // If other team won, then the win button cannot be selected again
    var otherTeamWithWinnerSet = false

    // Toggle back and forth on win, adding and removing score elements earned
    var winToggle: Bool = false

    // Oher Outlets
    @IBOutlet weak var winCheckMark: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    // Buttons
    @IBOutlet weak var cardCountEnterButton: UIButton!
    @IBOutlet weak var subtractCountEnterButton: UIButton!
    @IBOutlet weak var finishedButton: UIButton!
    @IBOutlet weak var winButton: UIButton!


    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()




    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title and other team initials
        navigationBar.topItem!.title = selectedViewTitle

        // Set other teams initials  NOTE: alls team show here so that the scorer can make sure they are working with the correct team and the score makes sense
        sf.setLabel(view.viewWithTag(122) as? UILabel, imageTextString: otherTeamInitials, backgroundColor: UIColor.whiteColor())
        sf.setLabel(view.viewWithTag(123) as? UILabel, imageTextString: Other3rdTeamInitials, backgroundColor: UIColor.whiteColor())


        // Fetch the score elements
        do {
            try fetchedResultsController.performFetch()
        } catch {}

        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self


        // Load any previously entered scores
        loadScoreValues(selectedTeamNumber!, option: "Selected", adjustControl: 0)

        // Load the other teams scores
        if selectedTeamNumber == 1 {
            // Load other team scores
            loadScoreValues(2, option: "Other", adjustControl: 1)
            loadScoreValues(3, option: "Other", adjustControl: 2)

        } else  if selectedTeamNumber == 2 {
            // Load other team scores
            loadScoreValues(1, option: "Other", adjustControl: 1)
            loadScoreValues(3, option: "Other", adjustControl: 2)

        } else {
            // Load other team scores
            loadScoreValues(1, option: "Other", adjustControl: 1)
            loadScoreValues(2, option: "Other", adjustControl: 2)
        }

        // Set the colors of the team buttons
        setColorsOfButtons()

        // Set colors of other buttons
        cardCountEnterButton.backgroundColor = Style.sharedInstance().keyButtonControl()
        subtractCountEnterButton.backgroundColor = Style.sharedInstance().keyButtonControl()
        finishedButton.backgroundColor = Style.sharedInstance().keyButtonControl()
        winButton.backgroundColor = Style.sharedInstance().keyButtonControl()

        // Disable Win button if Other team is flagged as having one"
        if otherTeamWithWinnerSet == true {
            winButton.backgroundColor = Style.sharedInstance().keyButtonControlDisabled()
            winButton.enabled = false
        }
    }


    // Set color of the plus/minus buttons 
    func setColorsOfButtons() {

        for elementScore in 1...11 {
            for control in 1...2 {

                let tag = String(elementScore) + String(control)
                let tagID = Int(tag)

                // Update the color of the buttons
                if let button = view.viewWithTag(tagID!) as? UIButton {

                    // Control 1 is the minus, Control 2 is the plus
                    if control == 1 {
                        button.backgroundColor = Style.sharedInstance().keyButtonControlSecondary()
                    } else  {
                        button.backgroundColor = Style.sharedInstance().keyButtonControl()
                    }
                }
            }
        }
    }


    // Load any previously entered scores
    func loadScoreValues(team: Int, option: String, adjustControl: Int) {

        // If loading the other teams then we need to save off the calculatedRoundScore whick should reflect 
        // the selected team's score so it can be adjusted with the other controls
        var calculatedRoundScoreSave =  0

        // If we are loading mutliple team columns, then we need to adjust the controls by 1 for other team 1
        if option == "Other" {
            calculatedRoundScoreSave = calculatedRoundScore
        }

        calculatedRoundScore = 0

        // Loop through all the score elements and set the amount selected as well as the calculated score
        for fetchedScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

            // We fetch all the score elements so filter by team/round that was selected
            if fetchedScoreElement.roundNumber == selectedRoundNumber && fetchedScoreElement.teamNumber == team {

                let elementNumber = String(fetchedScoreElement.elementNumber)

                // Set win options (element Number 0). If the team was marked as the winner turn on the checkMark
                if Int(fetchedScoreElement.elementNumber) == 0 {

                    if Int(fetchedScoreElement.earnedNumber) > 0 {

                        if option != "Other" {
                            winCheckMark.image = UIImage(named: "checkMark")
                            winToggle = true
                        } else {
                            otherTeamWithWinnerSet = true
                        }
                    } else {
                        if option != "Other" {
                            winCheckMark.image = UIImage(named: "notWinner")
                            winToggle = false
                        }
                    }
                }

                var tagString: String = " "
                tagString = elementNumber + "0"
                let tagID = Int(tagString)

                if option != "Other" {
                    // Update the label for the earnedNumber
                    sf.setLabel(view.viewWithTag(tagID!) as? UILabel, imageTextString: sf.formatScore(Int(fetchedScoreElement.earnedNumber)), backgroundColor: UIColor.whiteColor())
                }

                // Update the label for control 3, 4 or 5 which is the calculated score
                tagString = elementNumber + String( 3 + adjustControl)

                if option == "Other" {
                    sf.setLabel(view.viewWithTag( Int(tagString)!) as? UILabel, imageTextString: sf.formatScore(Int(fetchedScoreElement.earnedNumber) * Int(fetchedScoreElement.pointValue)), backgroundColor: Style.sharedInstance().teamRoundDisabled() )
                } else {
                    sf.setLabel(view.viewWithTag( Int(tagString)!) as? UILabel, imageTextString: sf.formatScore(Int(fetchedScoreElement.earnedNumber) * Int(fetchedScoreElement.pointValue)), backgroundColor: UIColor.whiteColor())
                }

                // Add score to the total score for the round
                calculatedRoundScore += Int(fetchedScoreElement.earnedNumber) * Int(fetchedScoreElement.pointValue)
            }
        }

        // Once we have looped through all the controlls, format the total
        sf.setLabel(view.viewWithTag(993 + adjustControl) as? UILabel, imageTextString: sf.formatScore(calculatedRoundScore), backgroundColor: UIColor.whiteColor())

        // Restore the calculated Round score which should match the selected round score so the balance 
        // will reflect correctly when anything changes 
        if option == "Other" {
            calculatedRoundScore = calculatedRoundScoreSave
        }
    }




    // ***** BUTTON MANAGEMENT  **** //

    // Finished was chosen
    @IBAction func roundTeamComplete(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // Card Count or Subtract Count was selected, present the card count controller
    @IBAction func enterCardCountSubtract(sender: AnyObject) {

        let cardCountController = storyboard!.instantiateViewControllerWithIdentifier("CardCountViewController") as! CardCountViewController
        cardCountController.delegate = self

        // Pass the round/Team title
        cardCountController.selectedViewTitle = selectedViewTitle

        // Located the fetched item so we can send the original values for card and subtract count to the card count view controller
        for fetchedScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

            if  fetchedScoreElement.roundNumber == selectedRoundNumber && fetchedScoreElement.teamNumber == selectedTeamNumber {

                // Original Card Count
                if fetchedScoreElement.elementNumber == 10 {
                    cardCountController.originalCardCount = Int(fetchedScoreElement.earnedNumber)
                }

                // Original Subtract Count
                if fetchedScoreElement.elementNumber == 11 {
                    cardCountController.originalSubtractCount = Int(fetchedScoreElement.earnedNumber)
                }
            }
        }
       presentViewController(cardCountController, animated: true, completion: nil)
    }


    // Win button was selected. It toggles on and off
    // When on, we add the winNumber to any of the score elements
    // that are considered requirements to win. 
    @IBAction func winButtonAction(sender: AnyObject) {

        var minusPlus = " "
        if winToggle == false {

            // off before, now on: add the winNumber
            winToggle = true
            minusPlus = "+"

        } else {

            // on before, now off: subtract the winNumber
            winToggle = false
            minusPlus = "-"
        }

        // Look through all the score elements. When there is a winNumber that means that earned amount 
        // is set when there is a win (kind of like a default).  Each individual score element that has 
        // this option must be adjusted
        for matchingScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

            // Match on the round and team
            if matchingScoreElement.roundNumber == selectedRoundNumber && matchingScoreElement.teamNumber == selectedTeamNumber  {

                // Check Win Number if found, need to adjust
                if Int(matchingScoreElement.winNumber ) > 0 {

                    var earnedNumberAdjusted = Int(matchingScoreElement.earnedNumber)

                    if minusPlus == "-" {
                        earnedNumberAdjusted = earnedNumberAdjusted - Int(matchingScoreElement.winNumber)
                    } else {
                        earnedNumberAdjusted = earnedNumberAdjusted + Int(matchingScoreElement.winNumber)
                    }

                    // Adjust the total for minimum, cannot go negative
                    if earnedNumberAdjusted < Int(matchingScoreElement.minimumValue) {
                        earnedNumberAdjusted = Int(matchingScoreElement.minimumValue)
                    }

                    // Adjust the total for maximum, cannot exceed maximum
                    if earnedNumberAdjusted > Int(matchingScoreElement.maximumValue) {
                        earnedNumberAdjusted = Int(matchingScoreElement.maximumValue)
                    }

                    // Adjust the earned and update
                    matchingScoreElement.adjustEarnedNumber(earnedNumberAdjusted)
                }
            }
        }

        // Update core data
        CoreDataStackManager.sharedInstance().saveContext()

        // Load the scores again
        loadScoreValues(selectedTeamNumber!, option: "Selected", adjustControl: 0)
    }


    // The Plus or Minus button was touched.  Need to adjust the earned amount 
    // and the calculated amount as well as the total for the round.
    @IBAction func plusMinusButtonAction(sender: AnyObject) {

        var originalBonusRed3s = 0
        var bonusRed3s = 0

        // find the score element and control from the button selected
        if let tagID =  sender.tag {

            // first digit of tagID is the score element
            // Second digit of the tagID is the control (1 or 2) that represents + or -
            let tagIDDictionary = sf.separateTagId(tagID, option: "ElementControl")
            let scoreElementNumber = Int(tagIDDictionary["scoreElement"]!)
            let control = tagIDDictionary["control"]

            // A control number of 1 indicates we are subtracting from the score.
            // A control number of 2 indicates we are adding to the score.
            var minusPlus = " "

            if control == "1" {
                minusPlus = "-"
            } else {
                minusPlus = "+"
            }

            // Loop through the score elements for the game
            var scoreElementIndex = 0
            for matchingScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

                // Match on the element number, round number and team number to get the matching score element for the +- button
                if Int(matchingScoreElement.elementNumber)  ==  scoreElementNumber && Int(matchingScoreElement.roundNumber) == selectedRoundNumber && Int(matchingScoreElement.teamNumber) == selectedTeamNumber {

                    // Match was found
                    var earnedNumberAdjusted = Int(matchingScoreElement.earnedNumber)

                    // If counting Red threes (control 8), set indicator for bonus so the bonus can be adjusted later
                    // Bonus red 3's of 300 is added for a book of 7 or more
                    if Int(matchingScoreElement.elementNumber) == 8 {
                        originalBonusRed3s = earnedNumberAdjusted
                    }

                    // Add or subtract from the earned number
                    if minusPlus == "-" {
                        earnedNumberAdjusted -= 1
                    } else {
                        earnedNumberAdjusted += 1
                    }

                    // If counting Red threes, set indicator for bonus so the bonus can be adjusted later
                    if Int(matchingScoreElement.elementNumber) == 8 {
                        bonusRed3s = earnedNumberAdjusted
                    }

                    // If within the minimum and maximum, then continue to adjust the score.  Else ignore the button touch.
                    if earnedNumberAdjusted >= Int(matchingScoreElement.minimumValue) && earnedNumberAdjusted <= Int(matchingScoreElement.maximumValue) {

                        var tagString: String = " "

                        tagString = String(scoreElementNumber!) + "0"
                        let tagID = Int(tagString)

                        //  Set the earned number. Not done for control score element 0 because 
                        // it is used for the win which does not have a number
                        if tagID > 0 {

                            // Update the label for the earnedNumber
                            sf.setLabel (view.viewWithTag(tagID!) as? UILabel, imageTextString: sf.formatScore(earnedNumberAdjusted), backgroundColor: UIColor.whiteColor())
                        }

                        // Update the label for the calculated score. Earned by Points
                        tagString = String(scoreElementNumber!) + "3"
                        let tagID3 = Int(tagString)

                         // Update the calculated round score and update score element
                        adjustRoundTotalUpdateScoreElement(matchingScoreElement, earnedNumberAdjusted: earnedNumberAdjusted, tagID: tagID3!)
                    }
                    break
                }
                scoreElementIndex += 1
            }

            // Check for a bonus in Reds. Over 7 there is a bonus. if less than 7 there is not a bonus
            if (originalBonusRed3s < 7 && bonusRed3s >= 7 ) || (originalBonusRed3s >= 7 && bonusRed3s < 7 ) {

                for matchingScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

                    // Find the bonus element for Bonus Red 3's  (control number 9)
                    if matchingScoreElement.elementNumber ==  9 && matchingScoreElement.roundNumber == selectedRoundNumber && matchingScoreElement.teamNumber == selectedTeamNumber {

                        var earnedNumberAdjusted = Int(matchingScoreElement.earnedNumber)

                        // Check if adding or removing the bonus red 3's
                        if (originalBonusRed3s < 7 && bonusRed3s >= 7 ) {
                            earnedNumberAdjusted += 1
                        } else {
                            earnedNumberAdjusted -= 1
                        }

                        // Add to round and update score element
                        adjustRoundTotalUpdateScoreElement(matchingScoreElement, earnedNumberAdjusted: earnedNumberAdjusted, tagID: 93)
                        break
                    }
                }
            }
        }
    }


    // Adds to the round score, sets the control and update the score element
    func adjustRoundTotalUpdateScoreElement(scoreElement: ScoreElement, earnedNumberAdjusted: Int, tagID: Int) {

        // Calculate the new score
        let originalScore = Int(scoreElement.earnedNumber) * Int(scoreElement.pointValue)
        let newScore = earnedNumberAdjusted * Int(scoreElement.pointValue)

        // Add to the round score
        calculatedRoundScore -= originalScore
        calculatedRoundScore += newScore

        // Update the label for the bonus red 3's score amount
        sf.setLabel (view.viewWithTag(tagID) as? UILabel, imageTextString: sf.formatScore(newScore), backgroundColor: UIColor.whiteColor())

        // Update the round total
        sf.setLabel (view.viewWithTag(993) as? UILabel, imageTextString: sf.formatScore(calculatedRoundScore), backgroundColor: UIColor.whiteColor())

        // Adjust the earned amount and the Round Total
        scoreElement.adjustEarnedNumber(earnedNumberAdjusted)
        CoreDataStackManager.sharedInstance().saveContext()
    }




   // ***** DELEGATE MANAGEMENT  (FROM CardCountViewController) **** //

    // Called when the card count or subtract count is updated
    // Update card counts, both card counts and/or subtract count
    func updateCardCounts(controller: CardCountViewController, cardCount: Int, subtractCount: Int) {

        for matchingScoreElement in self.fetchedResultsController.fetchedObjects as! [ScoreElement] {

            // Find the element for the card cound and the subtract 
            if (matchingScoreElement.elementNumber  ==  10 || matchingScoreElement.elementNumber == 11) && matchingScoreElement.roundNumber == self.selectedRoundNumber && matchingScoreElement.teamNumber == self.selectedTeamNumber {

                var earnedNumberAdjusted = 0
                if matchingScoreElement.elementNumber  ==  10 {
                    earnedNumberAdjusted = cardCount
                } else {
                    earnedNumberAdjusted = subtractCount
                }

                let tag = String(Int(matchingScoreElement.elementNumber)) + "3"
                let tagID = Int(tag)

                 // Adds to the round score, sets the control and update the score element
                adjustRoundTotalUpdateScoreElement(matchingScoreElement, earnedNumberAdjusted: earnedNumberAdjusted, tagID: tagID!)
            }
        }
    }




    // ***** CORE DATA  MANAGEMENT  **** //

    // Shared Context Helper
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Fetch all the score elements for the gam
    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "ScoreElement")

       fetchRequest.predicate = NSPredicate(format: "gameId == %@", self.selectedGameID!)

        // Sort by element number
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "elementNumber", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()

}
