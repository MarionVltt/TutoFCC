#!/bin/bash

# Number guessing game. After entering your username, try to guess the number chosen by the machine in the least guesses possible.

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Get user 
echo "Enter your username:"
read USER_NAME

FIND_USER=$($PSQL "SELECT * FROM number_guess WHERE name='$USER_NAME'")

if [[ -z $FIND_USER ]]
then
  echo  "Welcome, $USER_NAME! It looks like this is your first time here."
  RESULT_INSERT=$($PSQL "INSERT INTO number_guess(name) VALUES('$USER_NAME')")
else
  echo "$FIND_USER" | while IFS=" |" read USER_ID NAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Update the number of games played
UPDATE=$($PSQL "UPDATE number_guess SET games_played=games_played+1 WHERE name='$USER_NAME'")

# Guess the number
NUMBER_TO_GUESS=$(( $RANDOM % 1000 + 1))
COUNT_GUESSES=0

echo -e "\nGuess the secret number between 1 and 1000:"
read INPUT

while [[ $INPUT != $NUMBER_TO_GUESS ]]
do
  if [[ $INPUT =~ ^[0-9]+$ ]]
  then
    if [[ $INPUT < $NUMBER_TO_GUESS ]]
    then 
      echo "It's higher than that, guess again:"
      read INPUT
    else 
      echo "It's lower than that, guess again:"
      read INPUT
    fi
    ((COUNT_GUESSES++))
  else 
    echo "That is not an integer, guess again:"
    read INPUT
  fi
  
done

((COUNT_GUESSES++))
UPDATE=$($PSQL "UPDATE number_guess SET best_game=$COUNT_GUESSES WHERE name='$USER_NAME'")

echo "You guessed it in $COUNT_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
