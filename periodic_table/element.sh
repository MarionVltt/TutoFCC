#!/bin/bash

# Periodic table info - This script provides informations about chemical elements. 
# The input can be the atomic number, the name or the symbol (with the right capitalization) of the element. 
# Example : ./elements.sh 1, ./elements.sh Hydrogen and ./elements.sh H all return the information for Hydrogen

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $1 ]]
then 
  # Check if number
  if [[ $1 =~ ^[1-9]+$ ]]
  then
    # Get infos
    ELEMENT_INFOS=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) WHERE atomic_number=$1")
  else # Input is text
    ELEMENT_INFOS=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) WHERE name='$1' OR symbol='$1'")
  fi

  if [[ -z $ELEMENT_INFOS ]]
  then
    echo -e "I could not find that element in the database."
  else
    echo "$ELEMENT_INFOS" | while IFS=" |" read ATOMIC_NB SYM NAME ATOMIC_MASS MELTING BOILING TYPE_ID
    do
      # Get type
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
      echo -e "The element with atomic number $ATOMIC_NB is $NAME ($SYM). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
else
 echo "Please provide an element as an argument."
fi
