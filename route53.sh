#!/bin/bash

ENV=uat 
DNS=abcd-External-9982627718-1916763929.us-west-1.elb.amazonaws.com

# Creates route 53 records based on env name

aws route53 change-resource-record-sets \
  --hosted-zone-id 1234567890ABC \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : "CREATE"
      ,"ResourceRecordSet"  : {
        "Name"              : "'" $ENV "'.company.com"
        ,"Type"             : "CNAME"
        ,"TTL"              : 120
        ,"ResourceRecords"  : [{
            "Value"         : "'" $DNS "'"
        }]
      }
    }]
  }
  '