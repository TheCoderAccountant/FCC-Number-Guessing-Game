#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PSQL_INSERT='INSERT INTO games(game_id, player_id, player_guess, secret) VALUES' 

echo  "Enter your username:"
read USERNAME
PLAYER_NAME=$($PSQL "SELECT name FROM players WHERE name='$USERNAME'")
# Check if name is exist in db
if [[ -z $PLAYER_NAME ]] ;then
  echo "Welcome, $USERNAME! It looks like this is your first time here.";
  INSERT_USERNAME=$($PSQL "INSERT INTO players(name) VALUES('$USERNAME')")
  
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE name='$USERNAME'")
 else 
 # Number of games played
  GAME_STAT=$($PSQL "SELECT MIN(player_guess), COUNT(DISTINCT game_id), player_id, name  FROM games INNER JOIN players USING(player_id) WHERE name='$USERNAME' GROUP BY player_id, name")
  IFS="|" read -r BEST_GAME GAMES_PLAYED PLAYER_ID USERNAME <<< "$GAME_STAT"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


echo "Guess the secret number between 1 and 1000:"

SECRET_NUMBER=$((RANDOM%1000+1))
GUESS_COUNT=0
GUESS() { 
read GUESSED_NUMBER

if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]] ; then
echo "That is not an integer, guess again:"
GUESS
else
    if (( SECRET_NUMBER < GUESSED_NUMBER )) ; then
      echo "It's lower than that, guess again:" 
      ((GUESS_COUNT++))
      GUESSED_NUMBER=$GUESS_COUNT
      GUESS
    elif (( SECRET_NUMBER > GUESSED_NUMBER )) ; then
      echo "It's higher than that, guess again:"
      ((GUESS_COUNT++))
      GUESSED_NUMBER=$GUESS_COUNT
      GUESS
   
    else
      ((GUESS_COUNT++))
      GUESSED_NUMBER=$GUESS_COUNT
      ((GAMES_PLAYED++))
      NEW_GAME_ID=$GAMES_PLAYED
      INSERT_GUESS=$($PSQL "$PSQL_INSERT($NEW_GAME_ID,$PLAYER_ID,$GUESSED_NUMBER,$SECRET_NUMBER)")
      echo "You guessed it in $GUESSED_NUMBER tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
fi
}

GUESS

