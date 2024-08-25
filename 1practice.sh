#!/bin/bash

R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

ID=$( id -u )

if [ ID -ne 0 ]
then    
    echo "$G You are the root User... $N"
else
    echo "$R You are not the root User, This Package Need root access for installation"
    exit1
fi
