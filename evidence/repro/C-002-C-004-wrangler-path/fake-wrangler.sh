#!/usr/bin/env bash
set -euo pipefail

: "${REPRO_CAPTURE:?REPRO_CAPTURE is required}"
printf '%s\n' "${CLOUDFLARE_API_TOKEN:-missing}" > "$REPRO_CAPTURE"
printf 'wrangler 4.0.0\n'
