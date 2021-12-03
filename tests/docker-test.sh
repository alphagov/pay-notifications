#!/bin/bash

echo "Running tests"

echo "Starting containers"

if docker-compose up --build --force-recreate --abort-on-container-exit --exit-code-from tester tester; then
  echo "Pass"
else
  echo "Fail"
  exit 1
fi