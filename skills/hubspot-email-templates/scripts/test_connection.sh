#!/bin/bash
# Verify ~/.hubspot_secrets holds a working HubSpot access token, without ever
# printing the token itself.
#
# Uses HubSpot's access-token introspection endpoint, which works for both
# Private App tokens and OAuth tokens and requires no specific scope beyond
# being a valid token. Prints the portal (hub) ID, app ID, and granted scopes
# on success — useful for confirming this is connected to the right HubSpot
# account before building anything on top of it.
#
# Usage: ./test_connection.sh

set -euo pipefail

SECRETS_FILE="$HOME/.hubspot_secrets"

if [ ! -f "$SECRETS_FILE" ]; then
  echo "ERROR: $SECRETS_FILE not found. Run ./setup_credentials.sh first." >&2
  exit 1
fi

source "$SECRETS_FILE"

if [ -z "${HUBSPOT_ACCESS_TOKEN:-}" ]; then
  echo "ERROR: HUBSPOT_ACCESS_TOKEN is empty in $SECRETS_FILE" >&2
  exit 1
fi

RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}\n" \
  "https://api.hubapi.com/oauth/v1/access-tokens/${HUBSPOT_ACCESS_TOKEN}")

STATUS=$(echo "$RESPONSE" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS:/d')

if [ "$STATUS" = "200" ]; then
  echo "CONNECTED."
  echo "$BODY" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print('  Hub ID:      ', d.get('hub_id'))
print('  Hub domain:  ', d.get('hub_domain'))
print('  App ID:      ', d.get('app_id'))
print('  Token type:  ', d.get('token_type', 'private_app' if 'app_id' in d else 'unknown'))
print('  User:        ', d.get('user', '(none — this is a Private App token, not a user-scoped OAuth token)'))
scopes = d.get('scopes', [])
print(f'  Scopes ({len(scopes)}):')
for s in sorted(scopes):
    print('    -', s)
"
else
  echo "FAILED: HTTP $STATUS" >&2
  echo "$BODY" >&2
  exit 1
fi
