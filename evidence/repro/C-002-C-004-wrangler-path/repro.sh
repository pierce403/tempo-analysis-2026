#!/usr/bin/env bash
set -euo pipefail

repro_dir="$(cd "$(dirname "$0")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

printf 'executed_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$work_dir/app/node_modules/.bin"
cp "$repro_dir/package.json" "$work_dir/app/package.json"
cp "$repro_dir/fake-wrangler.sh" "$work_dir/app/node_modules/.bin/wrangler"
chmod +x "$work_dir/app/node_modules/.bin/wrangler"

run_case() {
  local case_id="$1"
  local dummy_value="$2"
  local capture="$work_dir/$case_id.txt"
  local output

  output="$({
    cd "$work_dir/app"
    env CLOUDFLARE_API_TOKEN="$dummy_value" \
      REPRO_CAPTURE="$capture" \
      npx --no-install wrangler --version
  })"

  test "$output" = "wrangler 4.0.0"
  test "$(cat "$capture")" = "$dummy_value"
  printf '%s stdout=%s capture=%s\n' "$case_id" "$output" "$(cat "$capture")"
}

run_case C-002 DUMMY_TEMPO_APPS_TOKEN_NOT_A_SECRET
run_case C-004 DUMMY_ACCOUNTS_TOKEN_NOT_A_SECRET
