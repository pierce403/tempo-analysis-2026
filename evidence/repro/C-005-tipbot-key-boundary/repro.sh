#!/usr/bin/env bash
set -euo pipefail

repro_dir="$(cd "$(dirname "$0")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

printf 'executed_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$work_dir/fake-bin"
cp "$repro_dir/fake-pnpm.sh" "$work_dir/fake-bin/pnpm"
chmod +x "$work_dir/fake-bin/pnpm"

export CAPTURE_FILE="$work_dir/capture.txt"
export PATH="$work_dir/fake-bin:$PATH"
export FEE_PAYER_PRIVATE_KEY_MAINNET=DUMMY_FEE_PAYER_PRIVATE_KEY_MAINNET
export FEE_PAYER_PRIVATE_KEY_TESTNET=DUMMY_FEE_PAYER_PRIVATE_KEY_TESTNET
export SECRET_KEY=DUMMY_SECRET_KEY
export SLACK_CLIENT_ID=DUMMY_SLACK_CLIENT_ID
export SLACK_CLIENT_SECRET=DUMMY_SLACK_CLIENT_SECRET
export SLACK_SIGNING_SECRET=DUMMY_SLACK_SIGNING_SECRET
export TEMPO_API_KEY=DUMMY_TEMPO_API_KEY

payload='{"FEE_PAYER_PRIVATE_KEY_MAINNET":"DUMMY_FEE_PAYER_PRIVATE_KEY_MAINNET","FEE_PAYER_PRIVATE_KEY_TESTNET":"DUMMY_FEE_PAYER_PRIVATE_KEY_TESTNET","SECRET_KEY":"DUMMY_SECRET_KEY","SLACK_CLIENT_ID":"DUMMY_SLACK_CLIENT_ID","SLACK_CLIENT_SECRET":"DUMMY_SLACK_CLIENT_SECRET","SLACK_SIGNING_SECRET":"DUMMY_SLACK_SIGNING_SECRET","TEMPO_API_KEY":"DUMMY_TEMPO_API_KEY"}'
printf '%s' "$payload" | pnpm exec wrangler secret bulk --env preview

grep -Fq 'argv=exec wrangler secret bulk --env preview' "$CAPTURE_FILE"
grep -Fq 'env_mainnet=DUMMY_FEE_PAYER_PRIVATE_KEY_MAINNET' "$CAPTURE_FILE"
grep -Fq '"FEE_PAYER_PRIVATE_KEY_MAINNET":"DUMMY_FEE_PAYER_PRIVATE_KEY_MAINNET"' "$CAPTURE_FILE"
sed -n '1,3p' "$CAPTURE_FILE"
