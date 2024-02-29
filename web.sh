#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%m-%d-%Y-%A-%X)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing Ngnix"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling Ngnix"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting Ngnix"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "Removing the default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Download the frontend content in /temp/ directory"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "Opening html directory"

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "Unziping the front end content"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "Copying the roboshop revers proxy confg"

systemctl restart nginx $LOGFILE
VALIDATE $? "Restarting Ngnix"