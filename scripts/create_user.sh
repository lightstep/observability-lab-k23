#!/bin/bash

BASE_URL="https://api.lightstep.com/public/v0.2"
ORGANIZATION="ap-k23-workshop"
API_KEY=$(echo "$LIGHTSTEP_API_KEY")
MAILSAC_API_KEY=$(echo "$MAILSAC_API_KEY")
USERNAME="${GITHUB_USER:-$USER}@o11y.moe"

cat <<EOF > create_user_payload.json
{
  "userName": "$USERNAME",
  "name": {
    "givenName": "John",
    "familyName": "Doe"
  },
  "emails": [
    {
      "primary": true,
      "value": "$USERNAME"
    }
  ]
}
EOF

# Print the loading message
echo -ne "👟 Creating Lightstep account, please wait...\\r"

# Create the account
curl -s -X POST -H "Authorization: Bearer $API_KEY" -H "Content-Type: application/json" -d @create_user_payload.json "${BASE_URL}/${ORGANIZATION}/Users" > /dev/null

# Request password reset email
URL="https://app.lightstep.com/api/v1/user/send_reset_password_email"
PAYLOAD="{\"email\":\"$USERNAME\"}"
curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$URL" > /dev/null

# Get the password reset email
while true; do
  EMAILS=$(curl -s -H "Mailsac-Key: $MAILSAC_API_KEY" "https://mailsac.com/api/addresses/${USERNAME}/messages")
  
  RESET_EMAIL_ID=$(echo "$EMAILS" | jq -r 'sort_by(.received) | reverse | .[0] | select(.subject == "Lightstep Password Reset") | ._id')
  if [ -n "$RESET_EMAIL_ID" ]; then
    break
  fi
  sleep 1
done

# Fetch the plaintext email body and extract the password reset link
EMAIL_BODY_RESPONSE=$(curl -s -H "Mailsac-Key: $MAILSAC_API_KEY" "https://mailsac.com/api/text/${USERNAME}/${RESET_EMAIL_ID}")
PASSWORD_RESET_LINK=$(echo "$EMAIL_BODY_RESPONSE" | grep -o 'https://app.lightstep.com/account/reset[^ ]*')

# Purge the mailbox
curl -s -X DELETE -H "Mailsac-Key: $MAILSAC_API_KEY" "https://mailsac.com/api/addresses/${USERNAME}/messages"

# Print the username and password reset link
echo "Your login is $USERNAME, please follow the link to set your password: $PASSWORD_RESET_LINK"
