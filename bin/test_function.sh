#!/usr/bin/env bash
set -e
docker build -f docker/Dockerfile.lambci -t ruanbekker/lambci-lambda:python-3.7 .
docker run --rm -v "$PWD/code":/var/task ruanbekker/lambci-lambda:python-3.7 lambda_function.lambda_handler '{"name": "ruan"}'
