#!/bin/bash
# Update an existing Braze email template's body (and optionally subject/preheader)
# from a local HTML file. Same disk-to-request-body approach as create_template.sh —
# no retyping large HTML through a tool-call parameter.
#
# Usage: update_template.sh <html_file> <email_template_id> [subject] [preheader]
# Prints the raw Braze JSON response.

set -euo pipefail

HTML_FILE="$1"
TEMPLATE_ID="$2"
SUBJECT="${3:-}"
PREHEADER="${4:-}"

if [ ! -f "$HTML_FILE" ]; then
  echo "ERROR: file not found: $HTML_FILE" >&2
  exit 1
fi

PAYLOAD_FILE=$(mktemp)
HTML_FILE="$HTML_FILE" TEMPLATE_ID="$TEMPLATE_ID" SUBJECT="$SUBJECT" PREHEADER="$PREHEADER" PAYLOAD_FILE="$PAYLOAD_FILE" python3 -c "
import json, os
body = open(os.environ['HTML_FILE'], encoding='utf-8').read()
payload = {
    'email_template_id': os.environ['TEMPLATE_ID'],
    'body': body,
}
subject = os.environ.get('SUBJECT', '')
if subject:
    payload['subject'] = subject
preheader = os.environ.get('PREHEADER', '')
if preheader:
    payload['preheader'] = preheader
json.dump(payload, open(os.environ['PAYLOAD_FILE'], 'w'))
"

source ~/.braze_secrets
curl -s -w "\nHTTP_STATUS:%{http_code}\n" -X POST \
  "https://rest.iad-06.braze.com/templates/email/update" \
  -H "Authorization: Bearer $BRAZE_API_KEY" -H "Content-Type: application/json" \
  --data-binary @"$PAYLOAD_FILE"

rm -f "$PAYLOAD_FILE"
