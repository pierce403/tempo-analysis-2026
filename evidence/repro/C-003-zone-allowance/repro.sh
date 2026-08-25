#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'usage: %s /path/to/tempo-checkout\n' "$0" >&2
  exit 2
fi

source_checkout="$1"
expected_revision="86ff4deaebfee38bb0b000e648b2b367810265ff"
repro_dir="$(cd "$(dirname "$0")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

git -C "$source_checkout" cat-file -e "${expected_revision}^{commit}"
git clone --quiet --no-hardlinks "$source_checkout" "$work_dir/tempo"
git -C "$work_dir/tempo" checkout --quiet "$expected_revision"
git -C "$work_dir/tempo" apply --check "$repro_dir/zone-allowance-poc.patch"
git -C "$work_dir/tempo" apply "$repro_dir/zone-allowance-poc.patch"

printf 'executed_utc=%s\nrevision=%s\npatch_sha256=' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$(git -C "$work_dir/tempo" rev-parse HEAD)"
sha256sum "$repro_dir/zone-allowance-poc.patch" | cut -d' ' -f1

(
  cd "$work_dir/tempo"
  cargo test -p tempo-precompiles --features test-utils \
    tip20::tests::test_zone_portal_deposit_scope_does_not_bound_preexisting_allowance \
    -- --exact --nocapture
)
