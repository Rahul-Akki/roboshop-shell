#!/bin/bash

AMI=ami-0f3c7d07486cad139 #Replace Zone ID
SG_ID=sg-06b9f4678b7c43359
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispach" "web")
ZONE_ID=Z067191133W0RZ98BMQ5V #Replace Zone ID
DOMAIN_NAME="mydevops.online"

for i in "${INSTANCES[@]}"
do
    
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i : $IP_ADDRESS"

    #Create Rout53 record, Make sure exesting records are deleted
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"  
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done