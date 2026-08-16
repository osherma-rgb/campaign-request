#!/bin/bash
# Create a new Braze email template from a local HTML file.
# Builds the JSON payload with python3 (bytes go straight from disk into the request
# body) and posts it with curl — never inline large HTML as a bash string argument,
# and never retype it into an MCP tool-call parameter.
#
# Usage: create_template.sh <html_file> <template_name> <subject> [preheader]
# preheader (preview text) is optional — omit it or pass "" to leave it unset, unlike
# subject which Braze requires.
# Prints the raw Braze JSON response, including the new email_template_id on success.

set -euo pipefail

HTML_FILE="$1"
TEMPLATE_NAME="$2"
SUBJECT="$3"
PREHEADER="${4:-}"

if [ ! -f "$HTML_FILE" ]; then
  echo "ERROR: file not found: $HTML_FILE" >&2
  exit 1
fi

PAYLOAD_FILE=$(mktemp)
HTML_FILE="$HTML_FILE" TEMPLATE_NAME="$TEMPLATE_NAME" SUBJECT="$SUBJECT" PREHEADER="$PREHEADER" PAYLOAD_FILE="$PAYLOAD_FILE" python3 -c "
import json, os
body = open(os.environ['HTML_FILE'], encoding='utf-8').read()
payload = {
    'template_name': os.environ['TEMPLATE_NAME'],
    'subject': os.environ['SUBJECT'],
    'body': body,
}
preheader = os.environ.get('PREHEADER', '')
if preheader:
    payload['preheader'] = preheader
json.dump(payload, open(os.environ['PAYLOAD_FILE'], 'w'))
"

source ~/.braze_secrets
curl -s -w "\nHTTP_STATUS:%{http_code}\n" -X POST \
  "https://rest.iad-06.braze.com/templates/email/create" \
  -H "Authorization: Bearer $BRAZE_API_KEY" -H "Content-Type: application/json" \
  --data-binary @"$PAYLOAD_FILE"

rm -f "$PAYLOAD_FILE"
