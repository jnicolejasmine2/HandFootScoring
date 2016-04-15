//
//  LeaderboardTableViewController.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 4/8/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//
//
//

import UIKit
import CloudKit

class LeaderboardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leaderboardTableView: UITableView!

    // Leaderboard records returned from CloudKit
    var leaderboardRecords: [CKRecord] = []


    // Shared Functions ShortCode
    let sf = SharedFunctions.sharedInstance()


    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()
     }


    override func viewDidAppear(animated: Bool) {

        // First step is to get the leaderboard records from CloudKit
        // Start the activity indicator
        activityIndicator.startAnimating()

        // Check if connected to the internet
        let isConnectionReturnCode = CloudKitClient.sharedInstance().isConnectedToNetwork()

        // If connected, get the leaderboard records and load the table
        if isConnectionReturnCode == true {

            // get the player leaderboard records
            CloudKitClient.sharedInstance().getPlayerLeaderboardRecords() { results , errorString in

                if errorString == nil {
                    // No error, leaderboard records were fetched
                    dispatch_async(dispatch_get_main_queue(), {

                        self.leaderboardRecords = results

                        // Load the table
                        self.leaderboardTableView.rowHeight = 50.0
                        self.leaderboardTableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    })
                } else {
                    // Eror occurred when fetching the cloud kit leaderboard records
                    dispatch_async(dispatch_get_main_queue(), {

                        self.activityIndicator.stopAnimating()
                        self.presentAlert(errorString!, includeRetry: true, includeOK: true )
                    })
                }
            }
        } else {
            // Alert the internet is not available
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                self.presentAlert("The Internet connection appears to be offline.",  includeRetry: true, includeOK: true )
            })
        }
    }



    // ***** BUTTON MANAGEMENT  **** //
 


    // ***** TABLE MANAGEMENT  **** //


    // Number of Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardRecords.count
    }


    // Set the title of the section. It is stored with the game and is formatted when a game is added
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerCell = tableView.dequeueReusableCellWithIdentifier("LeaderboardCustomHeader") as! LeaderboardCustomHeader
        headerCell.backgroundColor = Style.sharedInstance().leaderboardTableHeading()
        return headerCell
    }


    // set the height for the header section
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }


    // Load the text for each players statistics
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {

        // Using a custom cell
        let cell = tableView.dequeueReusableCellWithIdentifier("LeaderboardTableCell", forIndexPath: indexPath) as! LeaderboardTableCell

        let leaderboardPlayer = leaderboardRecords[indexPath.row]

        // Move fields from the leadership record
        cell.playerName.text = leaderboardPlayer.objectForKey("playerName") as? String

        let percentageWinUnformatted = leaderboardPlayer.objectForKey("gamesWonPercentage") as! Double
        cell.percentageWon.text = String(format:"%.2f", percentageWinUnformatted)

        let gamesPlayedUnFormatted =  leaderboardPlayer.objectForKey("gamesPlayed") as! Int
        cell.gamesPlayed.text = sf.formatScore(gamesPlayedUnFormatted)

        let gamesWonUnFormatted = leaderboardPlayer.objectForKey("gamesWon") as! Int
        cell.gamesWon.text = sf.formatScore(gamesWonUnFormatted)

        let roundsWonUnFormatted = leaderboardPlayer.objectForKey("roundsWon") as! Int
        cell.roundsWon.text = sf.formatScore(roundsWonUnFormatted)
        
        let moneySpent = leaderboardPlayer.objectForKey("moneySpent") as! Double
        let moneyWon = leaderboardPlayer.objectForKey("moneyWon") as! Double

        // Calculate current balance by subtracting money spent from won (can go negative)
        let moneyWonLost = moneyWon - moneySpent
        cell.moneyWonLost.text = String(format:"%.2f", moneyWonLost)

        // Set separator color
        cell.separator.backgroundColor = Style.sharedInstance().leaderboardButtonControl()

        // Cell is ready to display
        return cell
    }


    // No details to show.  Because cloud kit only returns 100 records it was not feasable to store all the games in detail
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     }



    // ***** ALERT MANAGEMENT  **** //

    func presentAlert(alertMessage: String, includeRetry: Bool, includeOK: Bool) {

        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)

        // Option: Try again
        if includeRetry  {
            alert.addAction(UIAlertAction(title: "Try Again ", style: UIAlertActionStyle.Default, handler: {
                action in

                dispatch_async(dispatch_get_main_queue(), {
                    self.viewDidLoad()
                })
            }))
        }

        // Option: OK
        if includeOK {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                action in

            }))
        }

        // Present the Alert!
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

}
