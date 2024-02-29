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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing maven" 

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading Shipping application"

cd /app
VALIDATE $? "Opening app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE # -o --> overwrites the existing file
VALIDATE $? "Unziping Shipping application"

cd /app
VALIDATE $? "Opening app directory"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Moving the shipping.jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload
VALIDATE $? "Catalogue daemon reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling Shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting Shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MySQL"

mysql -h mysql.mydevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Setting the root password"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting Shipping"
