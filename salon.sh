#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  # display arguement if user get sent back to main menu
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display services
  echo "$($PSQL "SELECT * FROM services ORDER BY service_id")" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  SCHEDULE_APPOINTMENT
}

SCHEDULE_APPOINTMENT() {
  read SERVICE_ID_SELECTED

  # if input is not a number send to main menu
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # if service name does not exist send to main menu
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if customer phone does not exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # ask for customer's name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert new customer data to customer table
        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
  
      # ask for customer's desired time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?" | sed -r 's/  */ /g'
      read SERVICE_TIME

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # insert new data into appointment
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed -r 's/  */ /g'
    fi
  fi  
}

MAIN_MENU
