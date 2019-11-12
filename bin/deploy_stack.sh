#!/usr/bin/env bash

export TEMPLATE=lambda-stack.json
export STACKNAME=../cloudformation/lambda-cfn-deployment
export REGION=eu-west-1
export AWS_PROFILE=default

aws --profile $AWS_PROFILE cloudformation create-stack \
   --stack-name $STACKNAME \
   --region $REGION \
   --template-body file://$TEMPLATE --capabilities CAPABILITY_IAM
