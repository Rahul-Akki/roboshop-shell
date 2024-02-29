#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%m-%d-%Y-%A-%X)
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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installlling Python 3.6" 

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading Payment application"

cd /app
VALIDATE $? "Opening app directory"

unzip -o /tmp/payment.zip &>> $LOGFILE # -o --> overwrites the existing file
VALIDATE $? "Unziping Payment application"

cd /app
VALIDATE $? "Opening app directory"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copying Payment service file"

systemctl daemon-reload
VALIDATE $? "Payment daemon reload"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling Payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting Payment"