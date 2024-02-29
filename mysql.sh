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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disabeling MySQL"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copying MySQL"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing mysql community server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Setting MySQL root password"





