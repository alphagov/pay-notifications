#!/bin/bash

echo "Running tests"

echo "Starting containers"

if docker-compose up --build --exit-code-from tester; then
  echo "Pass"
else
  echo "Fail"
  exit 1
fi