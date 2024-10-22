#!/bin/bash

# Set your GitHub App ID and Installation ID here
APP_ID=1033286
INSTALLATION_ID=56284975

# Path to your private key file (in PKCS8 format)
PRIVATE_KEY="private_key-pkcs8.pem"

# Get the current time and expiration time (max 10 minutes = 600 seconds)
ISSUED_AT=$(date +%s)
EXPIRATION=$(($ISSUED_AT + 600))

# Base64 URL encode the header
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Base64 URL encode the payload (contains issued and expiration times, and app ID)
PAYLOAD=$(echo -n "{\"iat\":$ISSUED_AT,\"exp\":$EXPIRATION,\"iss\":$APP_ID}" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Sign the JWT using your private key (PKCS8 format)
SIGNATURE=$(echo -n "$HEADER.$PAYLOAD" | openssl dgst -sha256 -sign "$PRIVATE_KEY" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Combine header, payload, and signature into the final JWT
JWT="$HEADER.$PAYLOAD.$SIGNATURE"

# Output the generated JWT
echo "Generated JWT: $JWT"

# Use the JWT to request an installation token from GitHub
TOKEN_RESPONSE=$(curl -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens)

# Output the full response for debugging
echo "Token Response: $TOKEN_RESPONSE"

# Extract the token from the response using jq (ensure jq is installed)
INSTALLATION_TOKEN=$(echo $TOKEN_RESPONSE | jq -r .token)

# Output the installation token
echo "Installation Token: $INSTALLATION_TOKEN"

# Use the installation token to test an authenticated GitHub API request (optional)
# curl -H "Authorization: Bearer $INSTALLATION_TOKEN" \
#      -H "Accept: application/vnd.github+json" \
#      https://api.github.com/repos/OWNER/REPO/actions/workflows
