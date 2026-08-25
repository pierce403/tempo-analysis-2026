#!/usr/bin/env bash
set -euo pipefail

: "${CAPTURE_FILE:?CAPTURE_FILE is required}"
payload="$(cat)"
printf 'argv=%s\nenv_mainnet=%s\nstdin=%s\n' \
  "$*" \
  "$FEE_PAYER_PRIVATE_KEY_MAINNET" \
  "$payload" > "$CAPTURE_FILE"
