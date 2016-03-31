//
//  SharedFunctions.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 3/14/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//


import UIKit
import Foundation

class SharedFunctions {

    let staticMeldArray = ["50","90","120","150"]

    func compareDates(fromDate: NSDate, toDate: NSDate, granularity: NSCalendarUnit) -> String {
        // Check if game is in past. If so change the color to a dark disabled color

        let order = NSCalendar.currentCalendar().compareDate(fromDate, toDate: toDate, toUnitGranularity: granularity)

        switch order {
        case .OrderedDescending:
            return "<"
        case .OrderedAscending:
            return ">"
        case .OrderedSame:
            return "="
        }
    }


    // Add the comma to the score and totals
    func formatScore(score: Int!) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter.stringFromNumber(score)!
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



    // Determine the meld.  There is a threshhold option where the meld is dependent on score
    // and there is a static (set) meld where each round has a set meld
    func determineMeld(selectedGame: Game, gameTotalScore: Int, lastCompletedRound: Int) -> String! {

        var meldValue = "  "

        // Meld is based on score thresholds.
        if selectedGame.meldOption == "Threshhold" {

            // Check total score against threshholds, send back meld
            meldValue = selectedGame.meld1Value

            if gameTotalScore > Int(selectedGame.meld4Threshold) {
                meldValue = selectedGame.meld4Value

            } else if gameTotalScore > Int(selectedGame.meld3Threshold) {
                meldValue = selectedGame.meld3Value

            } else if gameTotalScore > Int(selectedGame.meld2Threshold) {
                meldValue = selectedGame.meld2Value
            }

        } else if selectedGame.meldOption == "Static" {

            // Meld is based on the completed round
            meldValue = staticMeldArray[lastCompletedRound]
        }
        
        return meldValue
    }



    //*** SET CONTROL FUNCTIONS **/
    // Set button image from an Icon
    func setButton (button: UIButton?, imageTextString: String!, backgroundColor: UIColor) {

        if button !=  nil {
            if (imageTextString.rangeOfString("icon") != nil) || imageTextString == "whitespace" {
                dispatch_async(dispatch_get_main_queue(), {
                    button!.hidden = true
                    button!.setImage(UIImage(named: imageTextString),  forState: UIControlState.Normal)
                    button!.backgroundColor = backgroundColor
                    button!.hidden = false
                })
            }
            else {
                // saved Photo in documents folder

                let photoDocumentsUrl = imageFileURL(imageTextString).path

                // Check if image is in documents folder
                let manager = NSFileManager.defaultManager()

                if (manager.fileExistsAtPath(photoDocumentsUrl!)) {
                    let documentImage = UIImage(contentsOfFile: photoDocumentsUrl!)!

                    // Image was found, set the button
                    dispatch_async(dispatch_get_main_queue(), {
                        button!.hidden = true
                        button!.setImage(documentImage,  forState: UIControlState.Normal)
                        button!.backgroundColor = backgroundColor
                        button!.hidden = false
                    })

                } else {

                    // For some reason, picture has not been set... set to missing player image
                    dispatch_async(dispatch_get_main_queue(), {
                        button!.hidden = true
                        button!.setImage(UIImage(named: "missingPlayer"),  forState: UIControlState.Normal)
                        button!.backgroundColor = backgroundColor
                        button!.hidden = false
                    })
                }
            }
            
        }
    }


    // Set images
    func setImage (image: UIImageView!, imageTextString: String!) {

        if image != nil {

            if (imageTextString.rangeOfString("icon") != nil) || imageTextString == "whitespace" {
                dispatch_async(dispatch_get_main_queue(), {
                    image.hidden = true

                    image.image = UIImage(named: imageTextString)
                    if imageTextString ==  "whitespace" {
                        image.backgroundColor = UIColor.whiteColor()
                    }

                    image.hidden = false
                })
            } else {
                // saved Photo in documents folder

                let photoDocumentsUrl = imageFileURL(imageTextString).path

                // Check if image is in documents folder
                let manager = NSFileManager.defaultManager()

                if (manager.fileExistsAtPath(photoDocumentsUrl!)) {
                    let documentImage = photoDocumentsUrl!

                    // Image was found, set the button
                    dispatch_async(dispatch_get_main_queue(), {
                        image!.hidden = true
                        image!.image = UIImage(contentsOfFile: documentImage)
                        image!.hidden = false
                    })

                } else {

                    // For some reason, picture has not been set... set to missing player image
                    dispatch_async(dispatch_get_main_queue(), {
                        image!.hidden = true
                        image!.image = UIImage(named: "missingPlayer")
                        image!.hidden = false
                    })
                }
            }
        }
    }
    


 
    // Set the label text and background color
    func setLabel (label: UILabel!, imageTextString: String!, backgroundColor: UIColor) {

        if label != nil {
            dispatch_async(dispatch_get_main_queue(), {
                label.hidden = true

                label.text = imageTextString
                label.backgroundColor = backgroundColor

                
                label.hidden = false
            })
        }
    }


    // Set button title
    func setButtonRound (button: UIButton!, imageTextString: String!, backgroundColor: UIColor, toDate: NSDate, disable: Bool) {

        dispatch_async(dispatch_get_main_queue(), {
            button.hidden = true

            button.setTitle(imageTextString, forState: UIControlState.Normal)
            button.backgroundColor = backgroundColor
            button.hidden = false
            button.titleLabel?.textAlignment = .Center
            button.setTitleColor(UIColor.blackColor(), forState:  UIControlState.Normal)

            // If round is after next or current rounds, then disable
            if imageTextString == " " {
                button.enabled = false
            } else {
                button.enabled = true
            }

            // Disalble buttons if in past
            if disable == true {
                button.enabled = false
            }

            // Check if game is in past. If so change the color to a dark disabled color

            //  let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: self.selectedGame!.date, toUnitGranularity: .Day)

            let dateCompareResult = self.compareDates(NSDate(), toDate: toDate, granularity: .Day)
            if  dateCompareResult == ">" {
                button.backgroundColor = Style.sharedInstance().teamRoundDisabled()
                button.enabled = false
                
            }
        })
    }

    func separateTagId(tagID: Int, option: String ) -> [String: String] {

        // EDITS TO MAKE SURE WE DO NOT RETURN GARBAGE.... 
        
        let tagIDString = String(tagID)
        let index1 = tagIDString.startIndex.advancedBy(0)
        let firstDigit = String(tagIDString[index1])
        let index2 = tagIDString.startIndex.advancedBy(1)
        let secondDigit = String(tagIDString[index2])

        if option == "RoundTeam" {
            return [
                "round": firstDigit,
                "team": secondDigit
            ]

        }
        if option == "TeamPlayer" {
            return [
                "team": firstDigit,
                "player": secondDigit
            ]

        }
        if option == "ElementControl" {
            return [
                "scoreElement": firstDigit,
                "control": secondDigit
            ]

        }


        return [ "firstDigit": firstDigit,
            "secondDigit": secondDigit,
        ]
    }





    // Loop through all the rounds for all the teams to determine which rounds are completed.
    // They are considered completed when all the teams have a non-zero score
    func determineLastCompletedRound(selectedGame: Game, fetchedRounds: [RoundScore] ) -> Int {
        var lastCompletedRoundTeam1: Int = 0
        var lastCompletedRoundTeam2: Int = 0
        var lastCompletedRoundTeam3: Int = 0

        // Loop through all the teams and find the last completed round.
        for fetchedRound in fetchedRounds {

            if fetchedRound.gameId == selectedGame.gameId {

                switch fetchedRound.teamNumber {
                case 1:
                    if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam1 {
                        lastCompletedRoundTeam1 = Int(fetchedRound.roundNumber)
                    }
                    break
                case 2:
                    if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam2 {
                        lastCompletedRoundTeam2 = Int(fetchedRound.roundNumber)
                    }
                    break
                case 3:
                    if Int(fetchedRound.roundTotal) > 0 && Int(fetchedRound.roundNumber) > lastCompletedRoundTeam3 {
                        lastCompletedRoundTeam3 = Int(fetchedRound.roundNumber)
                    }
                    break
                default:
                    break
                }
            }
        }
        // Look at the last completed rounds for the teams and set the last completed round
        var lastCompletedRound: Int = 0

        if lastCompletedRoundTeam1 <= lastCompletedRoundTeam2 {
            lastCompletedRound = lastCompletedRoundTeam1
        } else {
            lastCompletedRound = lastCompletedRoundTeam2
        }

        if selectedGame.maximumNumberOfTeams == 3  && lastCompletedRoundTeam3 <= lastCompletedRound {
            lastCompletedRound = lastCompletedRoundTeam3
        }
        return lastCompletedRound
    }
    





    
    //***  SHARED FUNCTIONS TO SET CONTROL  ****/
    class func sharedInstance() -> SharedFunctions {
        struct Singleton {
            static var sharedInstance = SharedFunctions()
        }
        return Singleton.sharedInstance
    }







    // Build the URL to retrieve the photo from the documents folder
    func imageFileURL(fileName: String) ->  NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

        let pathArray = [dirPath, fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!

        return fileURL
    }
    

}


