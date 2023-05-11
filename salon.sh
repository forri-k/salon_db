#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Main menu
MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "$1"
  fi

  # show list of services 
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
  SERVICE_SELECTED
}

# select service id func
SERVICE_SELECTED () {
  # read user input
  read SERVICE_ID_SELECTED
  # if not a number?
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that. What would you like today?"
  else
    # read service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'" | sed -E 's/^ +| +$//g')
    #echo "$SERVICE_NAME"
    if [[ -z $SERVICE_NAME ]] 
    then
      # then 'enter a valid option'
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
  fi
}

CUSTOMER_LOOKUP () {
  # get customer name from phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed -E 's/^ +| +$//g')
  #echo "$CUSTOMER_NAME"
}

NEW_CUSTOMER () {
  echo -e "\nI don't have a record for that phone number, what's your name?"
  # then ask for name
  read CUSTOMER_NAME
  # insert into customer table
  INSERT_CUSTOMER_DATA=$($PSQL"INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  #if [[ $INSERT_CUSTOMER_DATA == 'INSERT 0 1' ]]
  #then 
  #  echo 'Inserted new customer, '$CUSTOMER_NAME''
  #fi
}

# create appointment
CREATE_APPOINTMENT () {
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'" | sed -E 's/^ +| +$//g')
  #echo "$CUSTOMER_ID"
  INSERT_APPOINTMENT_DATA=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
  #if [[ $INSERT_APPOINTMENT_DATA == 'INSERT 0 1' ]]
  #then 
  # echo 'Inserted appointment, for '$CUSTOMER_ID', '$CUSTOMER_NAME''
  #fi
}


echo -e "\n~~~~~ MY SALON ~~~~~\n"
# starting welcome message
echo -e "Welcome to My Salon, how can I help you?\n"
# go to main menu
MAIN_MENU
#selection

#customer lookup with phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_LOOKUP
# check if customer exists
if [[ -z $CUSTOMER_NAME ]]
  then
    # create new customer
    NEW_CUSTOMER
fi 

# ask the time for appointment
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

CREATE_APPOINTMENT
# reconfirm appointment details
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."


