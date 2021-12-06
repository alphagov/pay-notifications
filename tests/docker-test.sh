#!/bin/bash

echo "Building Docker Compose Stack for Notifications Test..."
docker-compose build

echo "Starting 'tester' container and its depdendencies..."
if docker-compose up --abort-on-container-exit --exit-code-from tester tester; then
  echo "Pass"
else
  echo "Fail"
  exit 1
fi