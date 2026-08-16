#!/bin/bash
# Fetch a template's body back from Braze and diff it against the local source file.
# This is the trust-but-verify step: the REST-direct upload path is far more reliable
# than retyping base64/HTML through a tool call, but "far more reliable" still isn't
# "guaranteed" — always confirm what actually landed rather than trusting a 200/201.
#
# Usage: verify_template.sh <email_template_id> <local_html_path>
# Exit code 0 = byte-perfect match. Non-zero = mismatch, with a diff printed.

set -euo pipefail

TEMPLATE_ID="$1"
LOCAL_PATH="$2"

if [ ! -f "$LOCAL_PATH" ]; then
  echo "ERROR: local file not found: $LOCAL_PATH" >&2
  exit 1
fi

CHECK_PATH=$(mktemp)
source ~/.braze_secrets
curl -s "https://rest.iad-06.braze.com/templates/email/info?email_template_id=${TEMPLATE_ID}" \
  -H "Authorization: Bearer $BRAZE_API_KEY" \
  | CHECK_PATH="$CHECK_PATH" python3 -c "
import json, os, sys
d = json.load(sys.stdin)
open(os.environ['CHECK_PATH'], 'w', encoding='utf-8').write(d['body'])
"

if diff -q "$CHECK_PATH" "$LOCAL_PATH" > /dev/null; then
  echo "VERIFIED: byte-perfect match"
  rm -f "$CHECK_PATH"
  exit 0
else
  echo "MISMATCH: uploaded body differs from local source" >&2
  diff "$CHECK_PATH" "$LOCAL_PATH" || true
  rm -f "$CHECK_PATH"
  exit 1
fi
