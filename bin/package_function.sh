#!/usr/bin/env bash
set -ex

pushd ./code

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
#find ${PWD} -type d -maxdepth 1 -mindepth 1 -exec rm -rf {} \;
popd
