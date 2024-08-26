#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE() {
    if [$1 -ne 0]
    then
        echo "$2 $R Failed..! $N "
        exit 1
    else 
        echo "$2 $G succeeded.. $N "
}

ID=$( id -u )

if [ $ID -ne 0 ]
then
    echo -e "$R You are not the root User, This Package Need root access for installation $N"
    exit1    
else
    echo -e "$G You are the root User... $N"
fi

cp etc/yum.repos.d/mongo.repo
VALIDATE $? "MongoDB repo file setup is"
