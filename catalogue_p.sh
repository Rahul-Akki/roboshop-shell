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

id roboshop &>> $LOGFILE
if [ $? -ne 0 ] #if roboshop user already exists, skip and go to next step.
    then 
        useradd roboshop 
        VALIDATE $? "Creating the Roboshop User"
    else
        echo -e "roboshop user already exist $Y SKIPPING $N"
    fi

mkdir /app &>> $LOGFILE
VALIDATE $? "App Directory creation is"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading the application code is"

cd /app &>> $LOGFILE
VALIDATE $? "Open app directory is"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping the application code in app directory is"

cd /app &>> $LOGFILE
VALIDATE $? "Open app directory is"

npm install &>> $LOGFILE
VALIDATE $? "Dependencies installation is"

cp /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Setup SystemD Catalogue Service is"

sed -i 's/<MONGODB-SERVER-IPADDRESS>/mongodb.mydevops.online/g' /etc/mongod.conf  &>> $LOGFILE
VALIDATE $? "MongoDB DNS Configuration is"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon-reload is"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling Catlogue is"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting Catlogue is"

cp /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "MongoDB repo setup is"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "MongoDB client Installation is"

mongo --host mongodb.mydevops.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Load Schema"

