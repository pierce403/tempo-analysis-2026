#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'usage: %s /path/to/wallet-cli-checkout\n' "$0" >&2
  exit 2
fi

source_checkout="$1"
expected_revision="677e52278eaafa4ec356ed9c750446fba320cdfa"
repro_dir="$(cd "$(dirname "$0")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

git -C "$source_checkout" cat-file -e "${expected_revision}^{commit}"
git clone --quiet --no-hardlinks "$source_checkout" "$work_dir/wallet-cli"
git -C "$work_dir/wallet-cli" checkout --quiet "$expected_revision"
git -C "$work_dir/wallet-cli" apply --check "$repro_dir/omitted-limit-regression.patch"
git -C "$work_dir/wallet-cli" apply "$repro_dir/omitted-limit-regression.patch"

printf 'executed_utc=%s\nrevision=%s\nregression_patch_sha256=' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(git -C "$work_dir/wallet-cli" rev-parse HEAD)"
sha256sum "$repro_dir/omitted-limit-regression.patch" | cut -d' ' -f1

(
  cd "$work_dir/wallet-cli"
  corepack pnpm@11.0.8 install --frozen-lockfile
  set +e
  ./node_modules/.bin/vitest run test/identity.test.ts \
    -t 'reports an omitted-limit access key as unlimited'
  regression_rc=$?
  set -e
  test "$regression_rc" -ne 0
  printf 'upstream_regression_exit=%s (expected nonzero)\n' "$regression_rc"
)

git -C "$work_dir/wallet-cli" apply --check "$repro_dir/display-only-diagnostic.patch"
git -C "$work_dir/wallet-cli" apply "$repro_dir/display-only-diagnostic.patch"

(
  cd "$work_dir/wallet-cli"
  ./node_modules/.bin/vitest run test/identity.test.ts
  ./node_modules/.bin/tsc -b --noEmit
)
