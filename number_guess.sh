#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$((RANDOM % 1000 + 1))
#echo $NUMBER

#username
echo "Enter your username:"
read USERNAME
USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ ! -z $USER ]]
then
  IFS='|' read NAME GAMES_PLAYED BEST_GAME <<< "$USER"
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi



GUESS_NUMBER() {
  echo $1
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_NUMBER "That is not an integer, guess again: "
  elif [[ $GUESS -lt $NUMBER ]]
  then
    ((NUMBER_GUESSES++))
    GUESS_NUMBER "It's higher than that, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    ((NUMBER_GUESSES++))
    GUESS_NUMBER "It's lower than that, guess again:"
  elif [[ $GUESS -eq $NUMBER ]]
  then
    INSERT_GAME=$($PSQL "UPDATE users SET games_played=games_played+1, best_game=CASE WHEN best_game > $NUMBER_GUESSES OR best_game IS NULL THEN $NUMBER_GUESSES ELSE best_game END WHERE username='$USERNAME'")
    echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $NUMBER. Nice job!"
  fi
}


NUMBER_GUESSES=1
GUESS_NUMBER "Guess the secret number between 1 and 1000: "
