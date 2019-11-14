#!/usr/bin/env bash
set -ex

S3_BUCKET="${S3_BUCKET:-none}"
S3_KEY="lambda/MyLambdaFunction/version"

pushd ./code

# functions
get_version(){
  aws --profile ${AWS_PROFILE} s3 cp s3://${S3_BUCKET}/${S3_KEY} ./previous_hash
}

publish_version(){
  aws --profile ${AWS_PROFILE} s3 cp ./current_hash s3://${S3_BUCKET}/${S3_KEY}
}

# versioning
echo "1" > ./tmpfile
aws --profile ${AWS_PROFILE} s3 cp ./tmpfile s3://${S3_BUCKET}/${S3_KEY}
get_version
current_hash=$(md5sum lambda_function.py | awk '{print $1}')
previous_hash=$(cat ./previous_hash)

if [ $current_hash == $previous_hash ]
then
  echo "function code did not change"
  function_change=false
  echo "$function_change" > ./need_to_ship
  exit 0
else 
  echo "function code changed"
  function_change=true
  echo "$current_hash" > ./current_hash
  echo "$function_change" > ./need_to_ship
  publish_version
fi

# create a virtual environment
venv_id=$(date +%s)
python_path=$(which python)
virtualenv -p ${python_path} ${venv_id}
source ${venv_id}/bin/activate

# install dependencies and place in current directory
pip install -r requirements.txt -t .
deactivate
rm -rf ${venv_id}

# package function with dependencies
zip -r package.zip .

# cleanup
find ${PWD} -type d -maxdepth 1 -mindepth 1 -exec rm -rf {} \;
popd
