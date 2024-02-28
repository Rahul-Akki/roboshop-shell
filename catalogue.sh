#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
MONGODB_HOST=mongodb.mydevops.online

echo "scrip started executing at $TIMESTAMP" &>> $LOGFILE
echo "scrip started executing at $TIMESTAMP"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILED $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

ID=$(id -u) #--> Sudo access validation

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR : Please run this script with root access $N" 
    exit 1 # we can can give any number other than 0. -->   # EXIT STATUS --> echo $? = 0
else
    echo "Your are root user"
fi # fi indicates, end of if condition

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabeling nodeJS" 

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling nodeJS:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Starting nodeJS:18"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ] #if roboshop user already exists, skip and go to next step.
    then 
        useradd roboshop 
        VALIDATE $? "Creating the Roboshop User"
    else
        echo -e "roboshop user already exist $Y SKIPPING $N"
    fi

mkdir -p /app #mkdir -p <file-name> --> if file-name already exists, it will not execute anything.
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading Catalogue application"

cd /app
VALIDATE $? "Opening app directory"

unzip -o /tmp/catalogue.zip &>> $LOGFILE # -o --> overwrites the existing file
VALIDATE $? "Unziping Catalogue application"

cd /app
VALIDATE $? "Opening app directory"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload
VALIDATE $? "Catalogue daemon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying Mongo Repo file"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js $LOGFILESS
VALIDATE $? "Loding Catlogue data into MongoDB"


