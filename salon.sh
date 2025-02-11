#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Shop ~~~~~\n"
echo -e "\nWelcome to the digital salon, how can I help you?\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # main list of services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  # get service availability
  SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    SERVICE_MENU "That is not a valid service"
  else
    SCHEDULE
  fi
}

SCHEDULE() {
  echo -e "\nGreat. What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nWe don't have you in the system. What's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # echo $CUSTOMER_ID

  # get appointment time
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME

  # insert service
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # get appointment info
  # APPOINTMENT_ID=$($PSQL "SELECT appointment_id FROM appointments WHERE customer_id = $CUSTOMER_ID AND service_id = $SERVICE_ID_SELECTED")
  # echo "Current Appointment ID: $APPOINTMENT_ID"

  # if [[ -z $APPOINTMENT_ID ]]
  # then
    # EXIT "\n Looks like there was a problem scheduling your service"
  # fi

  SERVICE_NAME_RAW=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  CUSTOMER_NAME_RAW=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  # APPOINTMENT_TIME_RAW=$($PSQL "SELECT time FROM appointments WHERE appointment_id = $APPOINTMENT_ID")

  SERVICE_NAME=$(echo $SERVICE_NAME_RAW | sed 's/ //g')
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME_RAW | sed 's/ //g')

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  # send to main menu & display appointment 

}


EXIT() {
  echo -e "\nThanks for stopping by!\n"
}

SERVICE_MENU

