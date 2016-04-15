//
//  CardCountViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 3/2/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit

class CardCountViewController: UIViewController {

    // Card Count Delegate
    var delegate: CardCountViewControllerDelegate?

    // Passed from RoundScore View Controller
    var originalCardCount: Int = 0
    var originalSubtractCount: Int = 0
    var selectedViewTitle: String = " "

    // Variables
    var newCardCount: Int = 0
    var newSubtractCount: Int = 0

    // Outlets
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cardCountSegmentControl: UIStackView!
    @IBOutlet weak var subtractCountSegmentControl: UIStackView!
    @IBOutlet weak var completedButton: UIButton!


    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        navigationBar.topItem!.title = selectedViewTitle

        // Set the original card count for the view
        sf.setLabel (view.viewWithTag(91) as? UILabel, imageTextString: sf.formatScore(originalCardCount), backgroundColor: UIColor.whiteColor())

        // Set the original subtract count for the view
        sf.setLabel (view.viewWithTag(92) as? UILabel, imageTextString: sf.formatScore(originalSubtractCount), backgroundColor: UIColor.whiteColor())

        // Initialize the card count so we can adjust it
        newCardCount = originalCardCount
        newSubtractCount = originalSubtractCount * -1

        // Set colors of controls
        cardCountSegmentControl.backgroundColor = Style.sharedInstance().textHighlightControl()
        subtractCountSegmentControl.backgroundColor = Style.sharedInstance().textHighlightControl()
        completedButton.backgroundColor = Style.sharedInstance().keyButtonControl()
    }



    // ***** BUTTON MANAGEMENT  **** //

    // The finished button was selected
    @IBAction func completeButtonAction(sender: AnyObject) {

        dismissViewControllerAnimated(true, completion: nil)
    }


    // Called when either a subtract or a card count was selected 
    @IBAction func cardCountThousandAction(sender: UISegmentedControl) {

        // The tag ID matches the number selected +1 to accomodate the index of 0
        let tagID = sender.tag
        var numberChosen = sender.selectedSegmentIndex + 1

        // Moved 0 to end because the focus group wanted it there, have to switch the number
        if numberChosen == 10 {
            numberChosen = 0
        }


        // If a number was chosen 0-9, then add to the count and update the control
        if numberChosen <= 9 {

            // If tag == 1, then working with the card count
            // else working with the subtract count
            if tagID == 1 {

                // Add the digit to the number
                var cardCountTemp = String(newCardCount)
                cardCountTemp = cardCountTemp + String(numberChosen)

                // Check if exceded total length
                if cardCountTemp.characters.count < 5 {

                    newCardCount = Int(cardCountTemp)!
                    sf.setLabel(view.viewWithTag(91) as? UILabel, imageTextString: sf.formatScore(newCardCount), backgroundColor: UIColor.whiteColor())
                }
            } else {
                // Tag 2, working with Subtract Count

                // Add the digit to the number
                var cardCountTemp = String(newSubtractCount)
                cardCountTemp = cardCountTemp + String(numberChosen)

                // Check if exceded total
                if cardCountTemp.characters.count < 5  {

                    newSubtractCount = Int(cardCountTemp)!

                    sf.setLabel(view.viewWithTag(92) as? UILabel, imageTextString: sf.formatScore(newSubtractCount * -1), backgroundColor: UIColor.whiteColor())
                }
            }
        } else {

            // 11 Working with backspace

            // If tag == 11, then working with the card count backspace
            // else working with the subtract count
            if tagID == 1 {


                let cardCountTemp = String(newCardCount)
                var cardCountTemp2 = " "

                // Check that we do not exceed number of characters to delete
                if cardCountTemp.characters.count == 1 {

                    cardCountTemp2 = "0"

                } else  {

                    // Subtract the digit from the number
                    cardCountTemp2 = cardCountTemp.substringToIndex(cardCountTemp.endIndex.predecessor())
                }

                newCardCount = Int(cardCountTemp2)!
                sf.setLabel(view.viewWithTag(91) as? UILabel, imageTextString: sf.formatScore(newCardCount), backgroundColor: UIColor.whiteColor())


            } else {

                // Tag 12, working with Subtract Count backspa
                // Remove the last digit
                let cardCountTemp = String(newSubtractCount)
                var cardCountTemp2 = " "

                // Check that we do not exceed number of characters to delete
                if cardCountTemp.characters.count == 1 {
                    cardCountTemp2 = "0"

                } else  {

                    // Subtract the digit from the number
                    cardCountTemp2 = cardCountTemp.substringToIndex(cardCountTemp.endIndex.predecessor())
                }

                newSubtractCount = Int(cardCountTemp2)!
                sf.setLabel(view.viewWithTag(92) as? UILabel , imageTextString: sf.formatScore(newSubtractCount * -1), backgroundColor: UIColor.whiteColor())
            }
        }

        self.delegate!.updateCardCounts(self, cardCount: newCardCount, subtractCount: (newSubtractCount * -1))
    }


}



// Needed so that both card counts can be sent back to the roundscore vc
protocol CardCountViewControllerDelegate {
    func updateCardCounts(controller: CardCountViewController, cardCount: Int, subtractCount: Int)
}
