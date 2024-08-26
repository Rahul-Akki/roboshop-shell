#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP="date +%m-%d-%Y_%H=%M-%S"
LOGFILE="/tmp/$0-$TIMESTAMP.log" 

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 $R Failed..! $N "
        exit 1
    else 
        echo -e "$2 $G succeeded.. $N "
    fi
}

ID=$(id -u)

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR: You are not the root User, This Package Need root access for installation $N"
    exit 1    
else
    echo -e "$G You are the root User... $N"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabeling of current nodejs module is"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling of nodejs:18 module is"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installation of nodejs is"
