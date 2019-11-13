#!/usr/bin/env bash

export TEMPLATE=cloudformation/lambda-stack.json
export STACK_NAME=lambda-cfn-deployment
export REGION=eu-west-1
export AWS_PROFILE=${AWS_PROFILE:-none}

install_packages() {
  rhel_status_code=$(command -v yum > /dev/null; echo $?)
  debian_status_code=$(command -v apt > /dev/null; echo $?)
  
  if [ ${rhel_status_code} == 0 ]
    then
      yum install jq -y
  fi
  
  if [ ${debian_status_code} == 0 ]
    then
      apt update && apt install jq -y
  fi
}

deploy_stack() {
  aws --profile ${AWS_PROFILE}  cloudformation create-stack \
     --stack-name $STACK_NAME \
     --region $REGION \
     --template-body file://$TEMPLATE --capabilities CAPABILITY_IAM
     
  aws --profile ${AWS_PROFILE} cloudformation wait stack-create-complete \
     --stack-name $STACK_NAME
 
  stack_status=$(aws --profile ${AWS_PROFILE} cloudformation describe-stacks \
     --stack-name $STACK_NAME | jq -r '.Stacks[].StackStatus')
     
  if [ ${stack_status} == "ROLLBACK_COMPLETE" ]
    then 
      exit 1
  fi
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
    install_packages
    deploy_stack
    echo "Stack: ${STACK_NAME} was deployed."
fi 
