//
//  CloudKitClient.swift
//  HandFootScoring
//
//  Created by Jeanne Nicole Byers on 4/1/16.
//  Copyright © 2016 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import CloudKit
import SystemConfiguration


class CloudKitClient     {

    // Container and Database
    let cloudContainer = CKContainer.defaultContainer()
    let publicDataBase = CKContainer.defaultContainer().publicCloudDatabase

    // Leader board records to be uploaded
    var leaderboardRecords: [CKRecord] = []

    // Variables used to track which player records are going to be uploaded
    var playerArray: [String] = []
    var playersToUpload: [[String: AnyObject]] = []


    //  NNEEDDD  !!!!!!!!!!!!
    func updateLeaderboard(gamesToUploadArray: [Game], roundsToUploadArray: [RoundScore],  scoreElementsArray: [ScoreElement], completionHandler:(errorString: String? ) -> Void) {

        // Initialize the array
        leaderboardRecords = []

        // Loop through all the games that are completed and ready to upload
        for game in gamesToUploadArray {

            // Determine which team won the game
            let winningTeamArray =  self.determineWinningTeamArray (game, roundScores: roundsToUploadArray)

            // Games can have 2 or 3 teams based on which game was chosen
            let maximumTeams = game.maximumNumberOfTeams as Int

            //loop through the teams that played the game
            for team in 1...maximumTeams {

                // Loop through each of the players (2 in each team)
                for player in 1...2 {

                    // Look up the players name/ID from the team/player number
                    let playerName = self.getCurrentTeamPlayerInformation(game, team: team, player: player)

                    // Build a list of players so we can filter the records later. Include the player only once.
                    var appendToArray = true
                    for player in playerArray {
                        if playerName == player {
                            // player is already in array
                            appendToArray = false
                        }
                    }
                    // Append to player array if not already in arary.
                    if appendToArray == true {
                        playerArray.append(playerName)
                    }

                    // Initialize the variables that will be totaled
                    var gamesWon = 0
                    var roundsWon = 0
                    var moneyWon = 0.00


                    // DETERMINE GAME WON AND MONEY FOR THE WIN
                    // determine what position in the win 
                    // The winningTeamArray lists the teams in the order of their scores
                    var teamOrderIndex = 0
                    for teamOrder in winningTeamArray {
                        if teamOrder == team {
                            break
                        }
                        teamOrderIndex += 1
                    }

                    // If first place and only two teams, win the dollars
                    if teamOrderIndex == 0  {
                        gamesWon += 1
                        moneyWon += 2.00
                    }

                    // If second place and 3 teams, second place gets a $1 each
                    if teamOrderIndex == 1 && game.maximumNumberOfTeams == 3  {
                        gamesWon += 1
                        moneyWon += 1.00
                    }


                    // DETERMINE ROUNDS WON AND THE WINNINGS
                    // Rounds are won if they played all their cards first

                    // Loop through all the rounds for the game and team
                    for round in roundsToUploadArray {
                        if round.gameId == game.gameId && round.teamNumber == team {

                            // Look for score element to find the wins
                            for scoreElement in scoreElementsArray {

                                // If this is the zero element number(Win Bonus) and it matches the game, round and team, then the team won the round
                                if scoreElement.gameId == game.gameId && scoreElement.roundNumber == round.roundNumber && scoreElement.teamNumber == team  && scoreElement.elementNumber == 0  && scoreElement.earnedNumber == 1 {

                                    // If three teams, each round win is worth .75, else each player gets .5
                                    roundsWon += 1
                                    if game.maximumNumberOfTeams == 3 {
                                        moneyWon += 0.75
                                    } else {
                                        moneyWon += 0.50
                                    }
                                }
                            }
                        }
                    }

                    // create am array of updates for the

                    let currentPlayerDictionary = [
                        "playerName": playerName,
                        "gamesWon": gamesWon,
                        "roundsWon": roundsWon,
                        "moneyWon": moneyWon
                    ]
                    playersToUpload.append(currentPlayerDictionary as! [String : AnyObject])
                }
            }
        }


        // GET LEADERBOARD RECORDS AND UPDATE 

        // Connet to CloudKit to get all the player records
        // There is no support for OR so have to bring them back for the group
        getPlayerLeaderboardRecords() {results, errorString in

            // Loop through all the players that have information to upload, find their record and save it off
            // This way we only update records that need to be updated
            for playerName in self.playerArray {

                for record in results {
                    let recordPlayerName = record.objectForKey("playerName") as! String

                    if recordPlayerName == playerName {
                       self.leaderboardRecords.append(record)
                    }
                }
            }

            // loop through the player records and update the records
            for player in self.playersToUpload {
                let playerName = player["playerName"] as! String
                let gamesWon = player["gamesWon"] as! Int
                let roundsWon = player["roundsWon"] as! Int
                let moneyWon = player["moneyWon"] as! Double
                var percentageWon = 0.00

                // Check if the player has an existing leader board record.
                var recordFound = false
                var recordFoundIndex = 0
                for record in self.leaderboardRecords {
                    let recordPlayerName = record.objectForKey("playerName") as! String
                                    if recordPlayerName == playerName {
                        recordFound = true
                        break
                    }
                    recordFoundIndex += 1
                }


                // Player has an existing leader board record.  Need to do an update
                if recordFound == true {

                    // Get the existing values from the record
                    var recordGamesWon = self.leaderboardRecords[recordFoundIndex].objectForKey("gamesWon") as! Int
                    var recordroundsWon = self.leaderboardRecords[recordFoundIndex].objectForKey("roundsWon") as! Int
                    var recordGamesPlayed = self.leaderboardRecords[recordFoundIndex].objectForKey("gamesPlayed") as! Int
                    var recordmoneyWon = self.leaderboardRecords[recordFoundIndex].objectForKey("moneyWon") as! Double
                    var recordmoneySpent = self.leaderboardRecords[recordFoundIndex].objectForKey("moneySpent") as! Double

                    // Adjust for the new games
                    recordGamesPlayed += 1
                    recordGamesWon += gamesWon
                    recordroundsWon += roundsWon
                    recordmoneyWon +=  moneyWon
                    recordmoneySpent = (Double(recordGamesPlayed) * 2.00)
                    let recordPercentageWon: Double = (Double(recordGamesWon) / Double(recordGamesPlayed) * 100)

                    // Update the value in the dictionary.
                    self.leaderboardRecords[recordFoundIndex].setObject(recordGamesWon, forKey: "gamesWon")
                    self.leaderboardRecords[recordFoundIndex].setObject(recordroundsWon, forKey: "roundsWon")
                    self.leaderboardRecords[recordFoundIndex].setObject(recordGamesPlayed, forKey: "gamesPlayed")
                    self.leaderboardRecords[recordFoundIndex].setObject(recordmoneyWon, forKey: "moneyWon")
                    self.leaderboardRecords[recordFoundIndex].setObject(recordmoneySpent, forKey: "moneySpent")
                    self.leaderboardRecords[recordFoundIndex].setObject(recordmoneySpent, forKey: "moneySpent")
                    self.leaderboardRecords[recordFoundIndex].setObject(recordPercentageWon, forKey: "gamesWonPercentage")

                } else {

                    // Player does not have an existing leader board record-- add to dictionary
                    let leaderboardScore = CKRecord(recordType: "HandFootGameScores")
                    leaderboardScore.setObject("LagunaWoods", forKey: "groupID")
                    leaderboardScore.setObject(playerName, forKey: "playerName")
                    leaderboardScore.setObject(1, forKey: "gamesPlayed")
                    leaderboardScore.setObject(gamesWon, forKey: "gamesWon")
                    leaderboardScore.setObject(2.00, forKey: "moneySpent")
                    leaderboardScore.setObject(moneyWon, forKey: "moneyWon")
                    leaderboardScore.setObject(roundsWon, forKey: "roundsWon")
                    if gamesWon > 0 {
                        percentageWon = 100.00
                    } else {
                        percentageWon = 0.00
                    }
                    leaderboardScore.setObject(percentageWon, forKey: "gamesWonPercentage")
                    self.leaderboardRecords.append(leaderboardScore)
                }
            }

            // update the database when all the records are ready to go.
            let operation = CKModifyRecordsOperation(recordsToSave: self.leaderboardRecords, recordIDsToDelete: nil)
            self.publicDataBase.addOperation(operation)

            operation.modifyRecordsCompletionBlock = { (savedRecords , deleteRecord , error ) -> Void in

                if error != nil {
                    // Error occurred
                    return completionHandler (errorString: error?.localizedDescription)
                } else {
                    // Success
                    return completionHandler (errorString: nil)
                }
            }
        }
     }



    // Get records for all players.  Cannot use an OR so we have to bring them all back for the group
    func getPlayerLeaderboardRecords(completionHandler: (results: [CKRecord], errorString: String?) -> Void)  {

        // Request for the group
        let queryPredicate = NSPredicate(format: "groupID = %@", "LagunaWoods")
        let query = CKQuery(recordType: "HandFootGameScores", predicate: queryPredicate)

        // Sort leader board by percentage won, games played, games won
        let sortDescripter1 = NSSortDescriptor(key: "gamesWonPercentage", ascending: false)
        let sortDescripter2 = NSSortDescriptor(key: "gamesPlayed", ascending: false)
        let sortDescripter3 = NSSortDescriptor(key: "gamesWon", ascending: false)
        query.sortDescriptors = [sortDescripter1, sortDescripter2, sortDescripter3 ]

        // Call cloudkit
        publicDataBase.performQuery(query, inZoneWithID: nil) { (result, error) -> Void in

            if error == nil {

                // No error check if any results
                if result!.count > 0 {
                    return completionHandler (results: result!, errorString: nil)
                } else {
                    return completionHandler (results: [], errorString: nil)
                }

            } else {
                // Error occurred, send back message
                return completionHandler (results: [], errorString: error?.localizedDescription)
            }
        }
    }



    // Based on the Team and player numbers, send back the players name so we can save in array
    func getCurrentTeamPlayerInformation(game: Game, team: Int, player: Int) -> String {

        let teamPlayer = Int(String(team) + String(player))!

        switch teamPlayer {

        case  11:
            return game.team1Player1

        case  12:
            return game.team1Player2

        case  21:
            return game.team2Player1

        case  22:
            return game.team2Player2

        case  31:
            if game.maximumNumberOfTeams == 3 {
                return game.team3Player1!
            }
            break

        case  32:
            if game.maximumNumberOfTeams == 3 {
                return game.team3Player2!
            }
            break

        default:
            break
        }
        return " "
    }



    // Calculate the game total for the team. must total all the round scores up
    func getGameTotal (selectedGame: Game, team: Int, roundScores: [RoundScore]) -> Int {
        var teamGameScore: Int = 0

        // Loop through all the teams and find the last completed round.
        for fetchedRound in roundScores {

            if fetchedRound.gameId == selectedGame.gameId  && Int(fetchedRound.teamNumber) == team {
                teamGameScore = teamGameScore + Int(fetchedRound.roundTotal)
            }
        }
        return teamGameScore
    }



    // Create an array of the winning order.  This is used in the leaderboard upload
    // to decide who won.
    func determineWinningTeamArray (fetchedGame: Game, roundScores: [RoundScore]) -> [Int] {

        // Determine which team has the most score
        // First get each teams total score by adding up all the round totals
        let team1GameTotal = getGameTotal(fetchedGame, team: 1, roundScores: roundScores)

        let team2GameTotal = getGameTotal(fetchedGame, team: 2, roundScores: roundScores)

        var team3GameTotal = 0
        if fetchedGame.maximumNumberOfTeams == 3 {
            team3GameTotal = getGameTotal(fetchedGame, team: 3, roundScores: roundScores)
        }

        // Then determine what is the highest score
        var winningGameTotal = 0

        if team1GameTotal > team2GameTotal && team1GameTotal > team3GameTotal {
            winningGameTotal = team1GameTotal
        }

        if team2GameTotal > team1GameTotal && team2GameTotal > team3GameTotal {
            winningGameTotal = team2GameTotal
        }

        if team3GameTotal > team1GameTotal && team3GameTotal > team2GameTotal {
            winningGameTotal = team3GameTotal
        }

        var teamWinOrder: [Int] = []

        // Set winning team
        if team1GameTotal == winningGameTotal {
            teamWinOrder.append(1)
            if team2GameTotal > team3GameTotal {
                teamWinOrder.append(2)
                teamWinOrder.append(3)
            } else {
                teamWinOrder.append(3)
                teamWinOrder.append(2)
            }
        } else if team2GameTotal == winningGameTotal {
            teamWinOrder.append(2)
            if team1GameTotal > team3GameTotal {
                teamWinOrder.append(1)
                teamWinOrder.append(3)
            } else {
                teamWinOrder.append(3)
                teamWinOrder.append(1)
            }
        } else if team3GameTotal == winningGameTotal {
            teamWinOrder.append(3)
            if team1GameTotal > team2GameTotal {
                teamWinOrder.append(1)
                teamWinOrder.append(2)
            } else {
                teamWinOrder.append(2)
                teamWinOrder.append(1)
            }
        }
        return teamWinOrder
    }


    // Check to see if there is an internet connection
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()

        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0

        return (isReachable && !needsConnection)
    }



    //***  SHARED FUNCTIONS TO SET CONTROL  ****/
    class func sharedInstance() -> CloudKitClient {
        struct Singleton {
            static var sharedInstance = CloudKitClient()
        }
        return Singleton.sharedInstance
    }

}
