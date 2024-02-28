#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "scrip started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILED $N"
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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied MongoDB Repo"

dnf install mongodb-org -y 
VALIDATE $? "Installing MongoDB" &>> $LOGFILE

systemctl enable mongod
VALIDATE $? "Enabling MongoDB" &>> $LOGFILE

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB"
