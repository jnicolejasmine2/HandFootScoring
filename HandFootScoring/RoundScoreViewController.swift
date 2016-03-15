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


    var selectedGameID: String?
    var selectedRoundNumber: Int?
    var selectedTeamNumber: Int?
    var selectedViewTitle: String = " "
    var otherTeamInitials: String = " "
    var Other3rdTeamInitials: String = " "
    var calculatedRoundScore = 0
    var otherTeamWithWinnerSet = false


    var winToggle: Bool = false

    @IBOutlet weak var winCheckMark: UIImageView!

    @IBOutlet weak var navigationBar: UINavigationBar!

    // Buttons
    @IBOutlet weak var cardCountEnterButton: UIButton!
    @IBOutlet weak var subtractCountEnterButton: UIButton!
    @IBOutlet weak var finishedButton: UIButton!
    @IBOutlet weak var winButton: UIButton!



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        navigationBar.topItem!.title = selectedViewTitle

        // Set other team initials
        if let label = view.viewWithTag(122) as? UILabel {
            setLabel(label, imageTextString: otherTeamInitials, backgroundColor: UIColor.whiteColor())
        }


        // Fetch any existing Started Games --
        do {
            try fetchedResultsController.performFetch()
        } catch {}

        // Set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self

        // Load any previously entered scores
        loadScoreValues(selectedTeamNumber!, option: "Selected")

        if selectedTeamNumber == 1 {
            // Load other team scores
            loadScoreValues(2, option: "Other")
        } else {
            // Load other team scores
            loadScoreValues(1, option: "Other")
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
    func loadScoreValues( team: Int, option: String) {

        // If loading the other teams then we need to save off the calculatedRoundScore whick should reflect 
        // the selected team's score so it can be adjusted with the other controls
        var calculatedRoundScoreSave =  0

        // If we are loading mutliple team columns, then we need to adjust the controls by 1 for otehr team 1
        var controlAdjustment = 0
        if option == "Other" {
            controlAdjustment = 1
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
                        print("flaggedAsWinner")
                        if option != "Other" {
                            winCheckMark.image = UIImage(named: "checkMark")
                            winToggle = true
                        } else {
                            otherTeamWithWinnerSet = true
                        }
                    } else {
                        print("NotWinner")
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
                    if let label = view.viewWithTag(tagID!) as? UILabel {
                        setLabel(label, imageTextString: formatScore(Int(fetchedScoreElement.earnedNumber)), backgroundColor: UIColor.whiteColor())
                    }
                }

                // Updae the label for control 3 which is the calculated score
                let control345 = 3 + controlAdjustment

                tagString = elementNumber + String(control345)
                let tagID3 = Int(tagString)

                if let label = view.viewWithTag(tagID3!) as? UILabel {
                    if option == "Other" {
                        setLabel(label, imageTextString: formatScore(Int(fetchedScoreElement.earnedNumber) * Int(fetchedScoreElement.pointValue)), backgroundColor: Style.sharedInstance().teamRoundDisabled() )
                    } else {
                        setLabel(label, imageTextString: formatScore(Int(fetchedScoreElement.earnedNumber) * Int(fetchedScoreElement.pointValue)), backgroundColor: UIColor.whiteColor())
                    }

                    // Add score to the total score for the round
                    calculatedRoundScore += Int(fetchedScoreElement.earnedNumber) * Int(fetchedScoreElement.pointValue)
                }
            }
        }


        // Once we have looped through all the controlls, format the total
        if let label = view.viewWithTag(993 + controlAdjustment) as? UILabel {
            setLabel(label, imageTextString: formatScore(calculatedRoundScore), backgroundColor: UIColor.whiteColor())
         }

        // Restore the calculated Round score which should match the selected round score so the balance 
        // will reflect correctly when anything changes 
        if option == "Other" {
            calculatedRoundScore = calculatedRoundScoreSave
        }
    }



    // ***** BUTTON MANAGEMENT  **** //

    // Cancel was Chosen
    @IBAction func returnToSummary(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


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

        print("Gothere to winbutton: \(winToggle)")

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


        for matchingScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

            // Match on the round and team
            if matchingScoreElement.roundNumber == selectedRoundNumber && matchingScoreElement.teamNumber == selectedTeamNumber  {


           //     if Int(matchingScoreElement.elementNumber) >= 0 && Int(matchingScoreElement.elementNumber) <= 5 {

                print("matchingScoreElement.winNumber: \(matchingScoreElement.winNumber)")
                if   Int(matchingScoreElement.winNumber ) > 0 {

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
        
        CoreDataStackManager.sharedInstance().saveContext()

        // Load the scores again
        loadScoreValues(selectedTeamNumber!, option: "Selected")

    }


    // The Plus or Minus button was touched.  Need to adjust the earned amount 
    // and the calculated amount as well as the total for the round.
    @IBAction func plusMinusButtonAction(sender: AnyObject) {


        var originalBonusRed3s = 0
        var bonusRed3s = 0

        let tagIDString: String? = String(sender.tag)


        // find the score element and control from the button selected
        if let tagID = tagIDString {

            // first digit of tagID is the score element
            let index1 = tagID.startIndex.advancedBy(0)
            let scoreElementNumber = Int(String(tagID[index1]))

            // Second digit of the tagID is the control (1 or 2) that represents + or -
            let index2 = tagID.startIndex.advancedBy(1)
            let control  = tagID.substringFromIndex(index2)

            // A control number of 1 indicates we are subtracting from the score.
            // A control number of 2 indicates we are adding to the score.
            var minusPlus = " "

            if control == "1" {
                minusPlus = "-"
            } else {
                minusPlus = "+"
            }

            var scoreElementIndex = 0
            // Loop through the score elements for the game
            for matchingScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

                // Match on the element number, round number and team number to get the matching score element for the +- button
                if matchingScoreElement.elementNumber  ==  scoreElementNumber && matchingScoreElement.roundNumber == selectedRoundNumber && matchingScoreElement.teamNumber == selectedTeamNumber {

                    // Matchwas found

                    var earnedNumberAdjusted = Int(matchingScoreElement.earnedNumber)

                    // If counting Red threes (control 8), set indicator for bonus so the bonus can be adjusted later
                    if Int(matchingScoreElement.elementNumber) == 8 {
                        originalBonusRed3s = earnedNumberAdjusted
                    }

                    // Add or subtract from the earned number
                    if minusPlus == "-" {
                        --earnedNumberAdjusted
                    } else {
                        ++earnedNumberAdjusted
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
                            if let label = view.viewWithTag(tagID!) as? UILabel {
                                setLabel (label, imageTextString: formatScore(earnedNumberAdjusted), backgroundColor: UIColor.whiteColor())
                            }
                        }

                        // Update the label for the calculated score. Earned by Points
                        tagString = String(scoreElementNumber!) + "3"
                        let tagID3 = Int(tagString)

                        // Update the label for the calculated score
                        if let label = view.viewWithTag(tagID3!) as? UILabel {
                            setLabel (label, imageTextString: formatScore(Int(earnedNumberAdjusted) * Int(matchingScoreElement.pointValue)), backgroundColor: UIColor.whiteColor())
                        }


                        // Update the calculated round score.
                        // Must subtract the original score and add the new score
                        // Update the label for the calculated score
                        if let label = view.viewWithTag(993) as? UILabel {

                            let originalScore = Int(matchingScoreElement.earnedNumber) * Int(matchingScoreElement.pointValue)
                            let newScore = Int(earnedNumberAdjusted) * Int(matchingScoreElement.pointValue)

                            // Add to the round score
                            calculatedRoundScore -= originalScore
                            calculatedRoundScore += newScore

                            // Set the label for the round total
                            setLabel (label, imageTextString: formatScore(calculatedRoundScore), backgroundColor: UIColor.whiteColor())
                        }

                        // Adjust the earned amount and the Round Total
                        matchingScoreElement.adjustEarnedNumber(earnedNumberAdjusted)

                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                    
                    break
                }
                ++scoreElementIndex
            }

            // Check for a bonus in Reds. Over 7 there is a bonus. if less than 7 there is not a bonus
            if (originalBonusRed3s < 7 && bonusRed3s >= 7 ) || (originalBonusRed3s >= 7 && bonusRed3s < 7 ) {

                for matchingScoreElement in fetchedResultsController.fetchedObjects as! [ScoreElement] {

                    // Find the bonus element for Bonus Red 3's  (control number 9)
                    if matchingScoreElement.elementNumber ==  9 && matchingScoreElement.roundNumber == selectedRoundNumber && matchingScoreElement.teamNumber == selectedTeamNumber {

                        var earnedNumberAdjusted = Int(matchingScoreElement.earnedNumber)

                        // Check if adding or removing the bonus red 3's
                        if (originalBonusRed3s < 7 && bonusRed3s >= 7 ) {
                            ++earnedNumberAdjusted
                        } else {
                            --earnedNumberAdjusted
                        }

                        // Calculate the new score
                        let originalScore = Int(matchingScoreElement.earnedNumber) * Int(matchingScoreElement.pointValue)
                        let newScore = Int(earnedNumberAdjusted) * Int(matchingScoreElement.pointValue)

                        // Add to the round score
                        calculatedRoundScore -= originalScore
                        calculatedRoundScore += newScore

                        // Update the label for the bonus red 3's score amount
                        if let label = view.viewWithTag(93) as? UILabel {
                            setLabel (label, imageTextString: formatScore(newScore), backgroundColor: UIColor.whiteColor())
                         }

                        // Update the round total
                        if let label = view.viewWithTag(993) as? UILabel {
                            setLabel (label, imageTextString: formatScore(calculatedRoundScore), backgroundColor: UIColor.whiteColor())
                        }

                        // Adjust the earned amount and the Round Total
                        matchingScoreElement.adjustEarnedNumber(earnedNumberAdjusted)
                        CoreDataStackManager.sharedInstance().saveContext()

                        break
                    }
                }
            }
        }
    }


    
   // ***** DELEGATE MANAGEMENT  (FROM CardCountViewController) **** //

    // Called when the card count or subtract count is updated
    // Update card counts, both card counts and/or subtract count
    func updateCardCounts(controller: CardCountViewController, cardCount: Int, subtractCount: Int) {

        print("got back to updateCardCounts: \(cardCount), \(subtractCount)")

        for matchingScoreElement in self.fetchedResultsController.fetchedObjects as! [ScoreElement] {

            print("matchingScoreElement.elementNumber: \(matchingScoreElement.elementNumber)")
            print("matchingScoreElement.roundNumber: \(matchingScoreElement.roundNumber)")
            print("matchingScoreElement.teamNumber: \(matchingScoreElement.teamNumber)")

            // Find the element for the card cound and the subtract 
            if (matchingScoreElement.elementNumber  ==  10 || matchingScoreElement.elementNumber == 11) && matchingScoreElement.roundNumber == self.selectedRoundNumber && matchingScoreElement.teamNumber == self.selectedTeamNumber {

                print("a match was found")

                var earnedNumberAdjusted = 0
                if matchingScoreElement.elementNumber  ==  10 {
                    earnedNumberAdjusted = cardCount
                } else {
                    earnedNumberAdjusted = subtractCount
                }

                let tag = String(Int(matchingScoreElement.elementNumber)) + "3"
                let tagID = Int(tag)
 
                // Update the label for the card count
                if let label = view.viewWithTag(tagID!) as? UILabel {

                    // Calculate the scores
                    let originalScore = Int(matchingScoreElement.earnedNumber) * Int(matchingScoreElement.pointValue)
                    let newScore = Int(earnedNumberAdjusted) * Int(matchingScoreElement.pointValue)

                    // Add to the round score
                    calculatedRoundScore -= originalScore
                    calculatedRoundScore += newScore

                    setLabel (label, imageTextString: formatScore(newScore), backgroundColor: UIColor.whiteColor())
                }

                // Update the totals
                if let label = view.viewWithTag(993) as? UILabel {

                    setLabel (label, imageTextString: formatScore(calculatedRoundScore), backgroundColor: UIColor.whiteColor())
                }

                // Adjust the earned amount and the Round Total
                matchingScoreElement.adjustEarnedNumber(earnedNumberAdjusted)

                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }

   // ***** LABEL MANAGEMENT **** //

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


