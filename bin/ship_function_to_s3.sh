#!/usr/bin/env bash

S3_BUCKET="${S3_BUCKET_NAME:-none}"
S3_KEY="${S3_KEY_NAME:-none}"
AWS_PROFILE="${AWS_PROFILE:-none}"
PACKAGE_NAME="${LAMBDA_PACKAGE_NAME:-package.zip}"

pushd ./code

# check if deployment package exist
if [ ! -f package.zip ]
  then 
    echo "deployment package does not exist"
    exit 1
fi

# ship deployment package to s3
aws --profile ${AWS_PROFILE} cp ${PACKAGE_NAME} s3://${S3_BUCKET}/${S3_KEY}

popd
