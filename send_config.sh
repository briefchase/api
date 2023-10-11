#!/bin/sh

# Extract EXTERNAL_URL from file
EXTERNAL_URL=$(jq -r '.EXTERNAL_URL' .env)

# Send config.json via HTTPS POST to the extracted URL
curl -X POST -H "Content-Type: application/json" -d @config.json $EXTERNAL_URL

# Note: 
# - The '@config.json' tells curl to read the content from the config.json file.
# - The '-H "Content-Type: application/json"' sets the appropriate content type for the request.
