#!/bin/sh

# env.sh

# Change the contents of this output to get the environment variables
# of interest. The output must be valid JSON, with strings for both
# keys and values.
cat <<EOF
{
  "lightstep_access_token": "$LIGHTSTEP_ACCESS_TOKEN",
  "lightstep_api_key": "$LIGHTSTEP_API_KEY",
  "lightstep_org": "$LIGHTSTEP_ORG",
  "do_token": "$DIGITALOCEAN_TOKEN"
}
EOF