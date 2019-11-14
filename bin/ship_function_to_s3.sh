#!/usr/bin/env bash

S3_BUCKET="${S3_BUCKET:-none}"
S3_KEY="${S3_KEY:-none}"
AWS_PROFILE="${AWS_PROFILE:-none}"

CURRENT_HASH=$(cat ./current_hash)
PACKAGE_NAME="${CURRENT_HASH}.zip"
S3_KEY="lambda/MyLambdaFunction/${GIT_COMMIT}/${CURRENT_HASH}.zip"

pushd ./code

# check if deployment package exist
if [ ! -f package.zip ]
  then 
    echo "deployment package does not exist"
    exit 0
fi

# ship deployment package to s3
need_to_ship=$(cat ./need_to_ship)

if [ $need_to_ship == "true" ]
then
  echo "${CURRENT_HASH}.zip => ${GIT_COMMIT}"
  aws --profile ${AWS_PROFILE} s3 cp package.zip s3://${S3_BUCKET}/${S3_KEY}
fi

popd
