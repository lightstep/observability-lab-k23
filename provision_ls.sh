#!/bin/bash

# Check if LIGHTSTEP_API_KEY is set
if [[ -z "${LIGHTSTEP_API_KEY}" ]]; then
  echo "Error: LIGHTSTEP_API_KEY environment variable is not set."
  exit 1
fi

# Set project name
if [[ -n "${GITHUB_USER}" ]]; then
  BASE_NAME="${GITHUB_USER}"
else
  BASE_NAME="${USER}"
fi

# Generate four random UTF-8 characters
RANDOM_CHARS=$(LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom 2>/dev/null | head -c 4)

# Concatenate base name with random characters
PROJECT_NAME="${BASE_NAME}-${RANDOM_CHARS}"

# Display the processing message
echo -n "🚀 Please wait, creating project..."
while :; do
  echo -n "."
  sleep 1
done &

# POST request to create project
CREATE_PROJECT_RESPONSE=$(curl -fsS --request POST \
     --url https://api.lightstep.com/public/v0.2/ap-k23-workshop/projects \
     --header "Content-Type: application/json" \
     --header "Authorization: ${LIGHTSTEP_API_KEY}" \
     --data "{\"data\":{\"name\":\"${PROJECT_NAME}\"}}")

# Handle POST request response
if [[ $? -ne 0 ]]; then
  kill "$!" # stop the background blinking cursor
  echo -e "\nError: Failed to create project."
  exit 1
fi

# GET request to fetch access tokens
ACCESS_TOKENS_RESPONSE=$(curl -fsS --request GET \
     --url "https://api.lightstep.com/public/v0.2/ap-k23-workshop/projects/${PROJECT_NAME}/access_tokens" \
     --header "Content-Type: application/json" \
     --header "Authorization: ${LIGHTSTEP_API_KEY}")

# Handle GET request response
if [[ $? -ne 0 ]]; then
  kill "$!" # stop the background blinking cursor
  echo -e "\nError: Failed to fetch access tokens."
  exit 1
fi

# Get the access token ID and set it as an environment variable
LIGHTSTEP_ACCESS_TOKEN=$(echo "${ACCESS_TOKENS_RESPONSE}" | jq -r '.data[0].id')

# Stop the background blinking cursor and print the success message
kill "$!"
echo -e "\nProject ${PROJECT_NAME} created!"
echo "To set the token as an environment variable in your current shell session, run:"
echo "export LIGHTSTEP_ACCESS_TOKEN=${LIGHTSTEP_ACCESS_TOKEN}"