#!/bin/bash
# One-time setup: writes ~/.hubspot_secrets with your own HubSpot Private App
# access token (Personal Access Key).
# Run this once per machine/account before using any other script in this skill.
# The token is never embedded in this skill's files — it only ever lives in the
# local ~/.hubspot_secrets file this script creates, chmod 600, on your machine.
#
# This mirrors braze-email-templates/scripts/setup_credentials.sh exactly, on
# purpose: same guarantee — never shared, never synced, never baked into any
# distributable file. Each person runs this themselves, with their own token.
#
# Usage:
#   ./setup_credentials.sh                (prompts for the token, input hidden — recommended)
#   ./setup_credentials.sh <access_token> (less safe: appears in shell history /
#                                           process list, but fine for a quick
#                                           one-off if you're on a trusted machine)

set -euo pipefail

SECRETS_FILE="$HOME/.hubspot_secrets"

if [ -f "$SECRETS_FILE" ]; then
  read -r -p "$SECRETS_FILE already exists. Overwrite? [y/N] " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted — existing file left untouched."
    exit 0
  fi
fi

if [ "${1:-}" != "" ]; then
  ACCESS_TOKEN="$1"
else
  read -rsp "Paste your HubSpot access token (input hidden): " ACCESS_TOKEN
  echo
fi

if [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR: no token provided" >&2
  exit 1
fi

printf 'export HUBSPOT_ACCESS_TOKEN="%s"\n' "$ACCESS_TOKEN" > "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"
echo "Wrote $SECRETS_FILE (chmod 600, readable only by you)."
echo "Never share, cat, echo, or otherwise print this file's contents."
