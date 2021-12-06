#!/bin/bash
# This script is used to run the test stack (and tests) on your local dev environment.
# Refer to .github/workflows to update the GitHub Actions

echo "Building Docker Compose Stack for Notifications Test..."
docker-compose build

echo "Starting 'tester' container and its dependencies..."
if docker-compose up --abort-on-container-exit --exit-code-from tester tester; then
  echo "Pass"
else
  echo "Fail"
  exit 1
fi