#!/bin/sh

# Extract EXTERNAL_URL from file
EXTERNAL_URL=$(jq -r '.EXTERNAL_URL' .env)

# Check if the URL is localhost and switch to HTTP if necessary
if echo "$EXTERNAL_URL" | grep -q "localhost"; then
  # Assuming localhost should not use HTTPS
  EXTERNAL_URL=$(echo $EXTERNAL_URL | sed 's/https:/http:/')
fi

# Check if EXTERNAL_URL is valid
if [ -z "$EXTERNAL_URL" ]; then
  echo "The EXTERNAL_URL is empty."
  exit 1
fi

# Send config.json via HTTP/HTTPS POST to the extracted URL
curl -X POST -H "Content-Type: application/json" -d @config.json "$EXTERNAL_URL" || echo "Curl command failed with status code $?"
