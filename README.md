# Hand and Foot Scoring App 

Hand and Foot Scoring is an app that is used to score variations of the canasta card game. Both Hand and Foot and Hand, Knee and Foot can be scored using the app. Each game consists of four (4) rounds. Two or three teams of partners can play the game. 

The app tracks games, allows the scores for the rounds to be entered, tracks the winning scores, score differences for the other teams, and what is the current meld requirement (number of cards the team must place down to start playing).  

The app also tracks the game statistics for each of the players and presents them on a Leader Board.
  
# Special Features

### Preloaded Games 
The app loads the four Laguna Woods games automatically when the app is first opened. Six guest players are also loaded. The game profile is designed to allow a future feature where the app user can define their own game and rules. 

### Designed for Seniors
The app has been designed for seniors. After a focus group was conducted, it was apparent that seniors have difficulty swiping. There is no swiping feature in the app for this reason. 

Because the option to swipe a game to allow it to be deleted, the app automatically deletes all games more than 30 days old. This keeps core data as low as possible. 

### Ease of Use
When the app is opened and there is a current game in progress, the app will present the summary for the game bypassing the list of games.  

Quick summary of the game is shown in the game list. The teams information: initials, the current meld, the scores, the differences from the winning score and the percentage of the game completed are all displayed. 

### Automatic Cleanup of Games 
Automatically deletes games that are older than 30 days. 

### Player Statistics and Leader Board
When a game is completed and there is access to the internet, the game scores can be uploaded.  The leader board can be viewed.  The leaders are determined by the percentage of games won to games played. For each player, the number of games played, won, rounds won, and winnings balance is presented on the leader board. 
  
 

# Getting Started
### Starting a Game 
- Tap the plus sign (+) on the Games screen.  
- Select one of the four games: 
    -	Hand, Knee and Foot 
    -	Hand, Knee and Foot (Set Meld) 
    -	Hand & Foot 
    -	Hand & Foot (3 Teams) 
- The team players are defaulted to guests. Tap on the players to change to one of your friends. 
- Once you have selected the players, tap Start Game. 
- You will be returned to the list of games where you can select the game to add a score. 



### Adding a New Player 
- From the Select a Player screen, tap the plus sign (+) to add a player. 
- Enter an 8-character player name. The name must be unique. 
- Enter the players initials.  The initials must be unique. 
- Optionally, enter an email and phone number. 
- For the image: 
    - either take a photo using the camera, 
    - select an image from the album or 
    - select an icon.  _Note: Taping the icon multiple times will present a variety of icons you can select._
- Once the required data is entered, tap Add Player.
- You will be returned to the Select a Players screen where you can select the new player.  

### Entering Round Scores
- From the list of games, tap the game. _Note, if you open the app and there is an active game (not completed for today), the game summary screen will be automatically presented._
- There are four rounds to be scored. Each round becomes active as the prior round is completed. 
- Tap on the score button to enter the score. 

On the Round screen: 

- _All three teams are shown so that you can make sure you are entering the correct score.  The current team is the first one after the button. The other teams’ scores are shown with a gray background._
- If the team has won, tap the win button. 
    - For hand, knee and foot the required elements (flagged as bold) will be defaulted as well as the 200 points for the win. _
    - or hand and foot, the win bonus of 300 points will be set. The books must be set separately. 
- Tap the minus (-) or plus (+) buttons to add or remove items from the score.
- Tap on the Enter buttons to add the card count and counts to subtract.   
- When the score elements have all been entered, tap Finished.  
- You will be returned to the Round Summary screen 

### Uploading to the Leader Board 
- From the game list, tap the cloud upload arrow icon. Any games that are completed and not previously uploaded will be automatically loaded. 

_Note, if you cannot select the icon, then you do not have access to the internet or there are no completed games that have not been uploaded._

# Summary of scoring rules 
There is no consistent rule for hand and foot games. The four games implemented in the app are the ones played in Laguna Woods: 

### Hand, Knee and Foot Points
Element|Points
-------------:|:---  
Win          |200
Book of Wilds|2500 
Book of 7’s  |5000
Book of 5's  |3000
Req'd Clean Book|500
Req'd Dirty Book|300
Extra Clean Books|500
Extra Clean Books|300
Played Red 3’s|100 
Red 3 Bonus|300  (more than 7 played red 3's)
Card Count|Card points earned by the team 
Subtract Count|Points against the team


### Hand and Foot 
Element|Points
-------------:|:---  
Win          |300
Extra Clean Books|500 
Extra Clean Books|300
Card Count|Card points earned by the team 
Subtract Count|Points against the team

### Melds

#### Threshold meld: 
Points|Meld
-------------:|:---  
0-15,000|50 
15,000-29,999|90
30,000-49,999|120
50,000+|150

#### Set meld (all teams meld same)
Round|Meld
-------------:|:---  
Round 1|50 
Round 2|90
Round 3|120
Round 4|150 


### Winnings sent to leader board
Wins/Costs|Winnings ($$)
-------------:|:---  
Game Ante|2.00
Round Win (2 teams)|.5
Round Win (3 teams)|.75 
Game Win (2 teams)|2.00
Game Win (3 teams)|2.00
Second Place (3 teams)|1.00 

_Note: A game is won when the team has the highest score. A round is won when the team plays all their cards first (flagged as a Win when the round score is entered)._


For more information on playing hand and foot games:
- [https://www.pagat.com/rummy/handfoot.html#introduction](https://www.pagat.com/rummy/handfoot.html#introduction)
- [http://handkneeandfootcardgame.blogspot.com/](http://handkneeandfootcardgame.blogspot.com/)


# Notes for Udacity Reviewer 

##### User Interface 
- More than one view controller: 
    - 8 different screens 

- A table or Collection View 
    - GameTableViewController
    - TeamPlayerCollectionViewController	
    - LeaderboardTableViewController
- Navigation and model presentation  
	- Tab bar for games and leader board
	- Model screens for other screens 
	- Pass data between controllers
	- Use delegates to pass back data _(see CardCountViewController as an example)_
- Image Assets	
	- All have the three formats
	- App Icon has the correct sizes

##### Networking 
- Choose an API and integrate downloaded data into the app
	- CloudKit
- Give users feedback around network activity, 
	- Activity indicators in GameTableViewController and LeaderboardViewController 
	- Check for internet connection in both controllers when a) uploading and b) when displaying leaderboard
- Encapsulate networking code ina  class to reduce detail in VC
	- CloudKitClient 

##### Persistence 
- Core Data 
	- Game, RoundScore, ScoreElement, ProfileScoreElement, ProfileGame, Player 
- Manage the Core Data in a separate core datastack
	- CoreDataStackManager 
- Additonal state outside Core data 
	- NSUserDefaults, see Game.  Stores last started game. 
	
# Database and stored Data 
### NSUserDefaults 
The last started game is stored in NSUserDefaults. It is used to bypass the games list and present the current game.  If the game store in NSUserDefaults was started on the current day and is not completed, then the game table is bypassed so they can quickly add the game scores. 

### Core Data 

#### Game 
Entry for each game that is started. The team member and meld information is stored in the game.  The score is not. 

#### Round Score 
Entry for each round and team for each game.  Each game can have up to 12 round scores. A game with two teams will have rounds for team1/round1, team2/round1, team1/round2, team2/round2, team1/round3, team2/round3, team1/round4, and team2/round4.  The round scores are created when the game is started. 
Each team’s rounds score is kept in this record. 

#### Score Elements 
Each set of score elements is stored for each team for each round for each game.  For example, extra clean books, book of 7’s, book of wilds, have a score element record of their own. There is one of each for each team and each round. 

When a game is first started, each of the score elements for each of the teams and each of the rounds is created, ready to have the earned number set when the score is entered.  

Edit information is also stored in this record. 

#### Profile Game 
The game description, number of teams, and meld information is stored in the profile. It is loaded the first time the app is opened. For this release there are four (4) games stored.   

When a game is started the game information is copied to the Game table. 

See  LoadProfiles.swift file for the entries. 

#### Profile Score Elements 
The score elements for the two different types of games is stored here, Hand, Knee and foot (HNF) and Hand and Foot (H&F). A score element is an individual item a team can earn when playing. Edit information is also maintained  in this record. 

See  LoadProfiles.swift file for the entries.

When a game is started this information is copied to the ScoreElement table. 

#### Player

The player holds the individual player information.  When the app is first opened, six (6) guest players are added so games can be quickly started.  The images are stored in the documents folder. 

For this release, there is only one group, “LagunaWoods”. In future releases, the app user will be able to define their own groups. 

For this release, the email and phone are not required and only gathered, They will be used in a later release. 

See LoadProfiles.swift file for the entries. 

### Cloud Kit Records

The player statistics are stored on the cloud kit.  Multiple groups and players will be uploading the different games. 

There is only one record for each unique group ID and player name. If a player plays on Wednesday and uses their IPad to score and plays again on Thursday entering a score in their iPhone, both these scores will be merged into the players statistics and presented on the Leader Board. 

The information stored in the cloud is for player statistics. Data elements include:
 
Data Element|Type
-------------:|:---  
groupID|String	(defaulted to LagunaWoods)
playerName|String
gamesPlayed|Int
gamesWon|Int
gamesWonPercentage|Double
moneySpent|Double
moneyWon|Double


# Other Code Used 
Special thanks to ADV App Design Vault for their custom selection control that was used for the game selection.  [App Design Vault](http://www.appdesignvault.com/) 

_Note for reviewer:  I sent an email asking about license and/or acknowledgment that they would like but have not heard back from them. Will update the file when I do hear from them._

# License

HandandFootScoring, Copyright © 2015 Jeanne-Nicole Byers. It is free software, and may be redistributed under the terms specified in the [http://choosealicense.com/licenses/lgpl-3.0/](http://choosealicense.com/licenses/lgpl-3.0/)
