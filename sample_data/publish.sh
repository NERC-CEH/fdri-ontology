#!/bin/bash

set -e

QUEUE=$(awk '$1==ENVIRON["GITHUB_REF_NAME"] {print $2}' branch.map)

if [ -z "$QUEUE" ]
then
  echo "SQS not found for $GITHUB_REF_NAME"
  exit 1
fi

QUEUE_URL=https://sqs.eu-west-1.amazonaws.com/293385631482/$QUEUE

S3_DESTINATION_PREFIX=$(awk '$1==ENVIRON["GITHUB_REF_NAME"] {print $3}' branch.map)

if [ -z "$S3_DESTINATION_PREFIX" ]
then
  echo "S3 Destination not found for $GITHUB_REF_NAME"
  exit 1
fi

for file in build/*.ttl
do 
  # Upload data to s3
  S3_DESTINATION=$S3_DESTINATION_PREFIX/${file#"build/"}
  echo Uploading $file to $S3_DESTINATION
  aws s3 cp $file $S3_DESTINATION

  # Publish data to sqs queue
  BODY=$(printf '{"payload":"%s","action":"replace-graph","context":"http://fdri.ceh.ac.uk/graph/%s","content-type":"text/turtle"}' $S3_DESTINATION ${file#"build/"})
  echo "Sending $BODY to $QUEUE_URL"
  aws sqs send-message --message-group-id=data --queue-url=$QUEUE_URL --message-body="$BODY"
done
