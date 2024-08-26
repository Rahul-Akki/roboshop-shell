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

ID=$( id -u )

if [ $ID -ne 0 ]
then
    echo -e "$R You are not the root User, This Package Need root access for installation $N"
    exit1    
else
    echo -e "$G You are the root User... $N"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE #Setup the MongoDB repo file
VALIDATE $? "MongoDB repo file setup is"

dnf install mongodb-org -y  &>> $LOGFILE #Install MongoDB
VALIDATE $? "Installation of MongoDB is"

systemctl enable mongod  &>> $LOGFILE
VALIDATE $? "Enableing of MongoDB Service" 

systemctl start mongod  &>> $LOGFILE
VALIDATE $? "Starting of MongoDB Service" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf  &>> $LOGFILE
VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB"

