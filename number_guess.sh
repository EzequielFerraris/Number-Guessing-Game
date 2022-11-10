#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

MAIN() {
  #Ask for username "Enter your username:"
  echo -e "Enter your username: " 
  read USERNAME

  #Check if it exist

  USERNAME_E=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")

  #It does not exist. Ask for a new username "Welcome, <username>! It looks like this is your first time here."

  if [[ -z $USERNAME_E ]]
  then 
    #Create user and give a welcome message
    NEW_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")

  else
    #It exist. Retrieve information and welcome back message 
    INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME_E';")
    echo "$INFO" | while IFS='|' read USERNAME GAMES_PLAYED BEST_GAME
    do
      echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi

  #Set the count for the current game
  TRIALS_COUNT=0
  #Set the random number for this game:
  NUMBER_TO_GUESS=$[$RANDOM % 1000 + 1]
  #Count of games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")
  #Best game so far
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
  
  echo -e "\nGuess the secret number between 1 and 1000:"
  #LOOP
  LOOP

}

LOOP() {
    read GAME
    
  if [[ ! $GAME =~ ^[0-9]+$ ]]
  then
  #It is not. Message and re-loop 
    echo -e "\nThat is not an integer, guess again:"
    LOOP
  else 
    #Check if the numbers coincide. Add +1 to counter.
    if [[ $GAME != $NUMBER_TO_GUESS ]]
    then
      if (( $GAME < $NUMBER_TO_GUESS ))
      then
      #The number is greater.
      ((TRIALS_COUNT+=1)) 
      echo -e "\nIt's higher than that, guess again:"
      LOOP
      elif (( $GAME > $NUMBER_TO_GUESS ))
      #The number is lower.
      then
      ((TRIALS_COUNT+=1)) 
      echo -e "\nIt's lower than that, guess again:"
      LOOP
      fi
    else
    #The numbers coincide. Congratulate and check the number of trials.
      ((TRIALS_COUNT+=1))
      ((GAMES_PLAYED+=1))
      NEW_INFO=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME';")
      if [[ -z $BEST_GAME || $BEST_GAME > $TRIALS_COUNT ]]
      then
      NEW_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TRIALS_COUNT WHERE username = '$USERNAME';")
      fi
      echo -e "You guessed it in $TRIALS_COUNT tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
    fi
  fi
  
}

MAIN