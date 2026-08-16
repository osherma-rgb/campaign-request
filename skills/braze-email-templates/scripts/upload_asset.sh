#!/bin/bash
# Upload a single binary asset to Braze's media library via the REST API.
# Bypasses the braze MCP tool's asset_file_base64 parameter entirely — curl reads the
# file straight off disk into the multipart request, so there's no base64 text for an
# LLM to retype (retyping base64 reliably introduces silent corruption).
#
# Usage: upload_asset.sh <file_path> [app_group_id]
# Prints the raw Braze JSON response. Grab the CDN url from .new_assets[0].url

set -euo pipefail

FILE_PATH="$1"
APP_GROUP_ID="${2:-609909f4cde3c93ffa1267cb}"  # monday.com Prod default

if [ ! -f "$FILE_PATH" ]; then
  echo "ERROR: file not found: $FILE_PATH" >&2
  exit 1
fi

source ~/.braze_secrets
curl -s -w "\nHTTP_STATUS:%{http_code}\n" -X POST \
  "https://rest.iad-06.braze.com/media_library/create" \
  -H "Authorization: Bearer $BRAZE_API_KEY" \
  -F "app_group_id=${APP_GROUP_ID}" \
  -F "asset_file=@${FILE_PATH}"
