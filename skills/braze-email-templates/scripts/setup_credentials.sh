#!/bin/bash
# One-time setup: writes ~/.braze_secrets with your own Braze REST API key.
# Run this once per machine/account before using any other script in this skill.
# The key is never embedded in this skill's files — it only ever lives in the
# local ~/.braze_secrets file this script creates, chmod 600, on your machine.
#
# Usage:
#   ./setup_credentials.sh              (prompts for the key, input hidden — recommended)
#   ./setup_credentials.sh <api_key>    (less safe: the key briefly appears in shell
#                                         history / process list, but fine for a quick
#                                         one-off if you're on a trusted machine)

set -euo pipefail

SECRETS_FILE="$HOME/.braze_secrets"

if [ -f "$SECRETS_FILE" ]; then
  read -r -p "$SECRETS_FILE already exists. Overwrite? [y/N] " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted — existing file left untouched."
    exit 0
  fi
fi

if [ "${1:-}" != "" ]; then
  API_KEY="$1"
else
  read -rsp "Paste your Braze REST API key (input hidden): " API_KEY
  echo
fi

if [ -z "$API_KEY" ]; then
  echo "ERROR: no key provided" >&2
  exit 1
fi

printf 'export BRAZE_API_KEY="%s"\n' "$API_KEY" > "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"
echo "Wrote $SECRETS_FILE (chmod 600, readable only by you)."
echo "Never share, cat, echo, or otherwise print this file's contents."
