#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables to be able to run tests multiple times
echo $($PSQL "TRUNCATE teams, games")

# Loop on the file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do 
  if [[ $YEAR != year ]]
  then
    # Get winner team id 
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # If not found
    if [[ -z $WINNER_ID ]]
    then
      # Insert the team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $WINNER
      fi

      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Get opponent team id 
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # If not found
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert the team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insert game
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, \
                                                  round, \
                                                  winner_id, \
                                                  opponent_id, \
                                                  winner_goals, \
                                                  opponent_goals) \
                                VALUES($YEAR, '$ROUND', $WINNER_ID, \
                                      $OPPONENT_ID, \
                                      $W_GOALS, \
                                      $O_GOALS)" \
                                      ) 

    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo Inserted into games, $ROUND, $YEAR : $WINNER - $OPPONENT
    fi
  fi
done
