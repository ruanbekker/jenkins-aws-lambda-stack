#!/usr/bin/env bash

export TEMPLATE=../cloudformation/lambda-stack.json
export STACK_NAME=lambda-cfn-deployment
export REGION=eu-west-1
export AWS_PROFILE=dev

deploy_stack() {
  aws --profile ${AWS_PROFILE}  cloudformation create-stack \
     --stack-name $STACK_NAME \
     --region $REGION \
     --template-body file://$TEMPLATE --capabilities CAPABILITY_IAM
}

update_stack(){ 
  aws --profile ${AWS_PROFILE}  cloudformation update-stack \
     --stack-name $STACK_NAME \
     --region $REGION \
     --template-body file://$TEMPLATE --capabilities CAPABILITY_IAM
}

if aws --profile ${AWS_PROFILE} cloudformation describe-stacks --stack-name ${STACKNAME} >/dev/null 2>&1 
  then
    echo "Stack: ${STACK_NAME} exists, updating stack..."
    update_stack
    echo "Stack: ${STACK_NAME} was updated."
  else
    echo "Stack: ${STACK_NAME} does not exist, creating..."
    deploy_stack
    echo "Stack: ${STACK_NAME} was deployed."
fi 
