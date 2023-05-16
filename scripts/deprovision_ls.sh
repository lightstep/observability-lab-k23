#!/bin/bash

# Check if LIGHTSTEP_API_KEY is set
if [[ -z "${LIGHTSTEP_API_KEY}" ]]; then
  echo "Error: LIGHTSTEP_API_KEY environment variable is not set."
  exit 1
fi

# Check if LIGHTSTEP_PROJECT is set
if [[ -z "${LIGHTSTEP_PROJECT}" ]]; then
  echo "Error: LIGHTSTEP_PROJECT environment variable is not set."
  exit 1
fi

# Display the processing message
echo -n "🗑️ Please wait, deleting project..."

# DELETE request to delete the project
DELETE_PROJECT_RESPONSE=$(curl -fsS --request DELETE \
     --url "https://api.lightstep.com/public/v0.2/ap-k23-workshop/projects/${LIGHTSTEP_PROJECT}" \
     --header "Content-Type: application/json" \
     --header "Authorization: ${LIGHTSTEP_API_KEY}")

# Handle DELETE request response
if [[ $? -ne 0 ]]; then
  echo -e "\nError: Failed to delete project."
  exit 1
fi

# Print the success message
echo -e "\nProject ${LIGHTSTEP_PROJECT} deleted successfully!"
if [[ -z "${LIGHTSTEP_PROJECT}" ]]; then
  echo "Error: LIGHTSTEP_PROJECT environment variable is not set."
  exit 1
fi

# Display the processing message
echo -n "🗑️ Please wait, deleting project..."

# DELETE request to delete the project
DELETE_PROJECT_RESPONSE=$(curl -fsS --request DELETE \
     --url "https://api.lightstep.com/public/v0.2/ap-k23-workshop/projects/${LIGHTSTEP_PROJECT}" \
     --header "Content-Type: application/json" \
     --header "Authorization: ${LIGHTSTEP_API_KEY}")

# Handle DELETE request response
if [[ $? -ne 0 ]]; then
  echo -e "\nError: Failed to delete project."
  exit 1
fi

# Print the success message
echo -e "\nProject ${LIGHTSTEP_PROJECT} deleted successfully!"
