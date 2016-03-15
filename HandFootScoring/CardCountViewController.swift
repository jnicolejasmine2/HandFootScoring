//
//  CardCountViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 3/2/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import UIKit

class CardCountViewController: UIViewController {

    var delegate: CardCountViewControllerDelegate?

    var originalCardCount: Int = 0
    var originalSubtractCount: Int = 0

    var newCardCount: Int = 0
    var newSubtractCount: Int = 0

    var selectedViewTitle: String = " "

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cardCountSegmentControl: UIStackView!
    @IBOutlet weak var subtractCountSegmentControl: UIStackView!
    @IBOutlet weak var completedButton: UIButton!


    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        navigationBar.topItem!.title = selectedViewTitle

        // Set the original card count
        if let label = view.viewWithTag(91) as? UILabel {
            setLabel (label, imageTextString: formatScore(originalCardCount), backgroundColor: UIColor.whiteColor())
        }

        // Set the original subtract count
        if let label = view.viewWithTag(92) as? UILabel {
            setLabel (label, imageTextString: formatScore(originalSubtractCount), backgroundColor: UIColor.whiteColor())
        }

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

        let tagID = sender.tag
        let numberChosen = sender.selectedSegmentIndex

        if numberChosen <= 9 {

            // If tag == 1, then working with the card count
            // else working with the subtract count
            if tagID == 1 {

                // Add the digit to the number
                var cardCountTemp = String(newCardCount)
                cardCountTemp = cardCountTemp + String(numberChosen)

                // Check if exceded total
                if cardCountTemp.characters.count < 5 {

                    newCardCount = Int(cardCountTemp)!
                    if let label = view.viewWithTag(91) as? UILabel {
                         setLabel(label, imageTextString: formatScore(newCardCount), backgroundColor: UIColor.whiteColor())
                    }
                }
            } else {

                // Tag 2, working with Subtract Count

                // Add the digit to the number
                var cardCountTemp = String(newSubtractCount)
                cardCountTemp = cardCountTemp + String(numberChosen)

                // Check if exceded total
                if cardCountTemp.characters.count < 5  {

                    newSubtractCount = Int(cardCountTemp)!
                    if let label = view.viewWithTag(92) as? UILabel {
                        setLabel(label, imageTextString: formatScore(newSubtractCount * -1), backgroundColor: UIColor.whiteColor())
                    }
                }
            }
        } else {

            // 11 Working with backspace

            // If tag == 1, then working with the card count
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
                if let label = view.viewWithTag(91) as? UILabel {
                    setLabel(label, imageTextString: formatScore(newCardCount), backgroundColor: UIColor.whiteColor())
                }

            } else {

                // Tag 2, working with Subtract Count
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
                if let label = view.viewWithTag(92) as? UILabel {
                    setLabel(label, imageTextString: formatScore(newSubtractCount * -1), backgroundColor: UIColor.whiteColor())
                }
            }
        }

        self.delegate!.updateCardCounts(self, cardCount: newCardCount, subtractCount: (newSubtractCount * -1))
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

}



// Needed so that the location and coordinates can be sent back to the Add information
protocol CardCountViewControllerDelegate {
    func updateCardCounts(controller: CardCountViewController, cardCount: Int, subtractCount: Int)
}

