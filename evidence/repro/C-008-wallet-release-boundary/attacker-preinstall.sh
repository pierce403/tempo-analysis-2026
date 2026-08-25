#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_PATH:?GITHUB_PATH must model the Actions runner path file}"
repro_dir="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$repro_dir/fake-bin/git"
printf '%s\n' "$repro_dir/fake-bin" >> "$GITHUB_PATH"
