#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'usage: %s /path/to/tempo-std-checkout\n' "$0" >&2
  exit 2
fi

source_checkout="$1"
expected_revision="c77f1671f7fd01c698f1344c2a5f38f11a7f8384"
repro_dir="$(cd "$(dirname "$0")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

git -C "$source_checkout" cat-file -e "${expected_revision}^{commit}"
git clone --quiet --no-hardlinks "$source_checkout" "$work_dir/tempo-std"
git -C "$work_dir/tempo-std" checkout --quiet "$expected_revision"
cp "$repro_dir/KeyAuthEncodingProbe.t.sol" "$work_dir/tempo-std/test/KeyAuthEncodingProbe.t.sol"

printf 'executed_utc=%s\nrevision=%s\nfixture_sha256=' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$(git -C "$work_dir/tempo-std" rev-parse HEAD)"
sha256sum "$repro_dir/KeyAuthEncodingProbe.t.sol" | cut -d' ' -f1

(
  cd "$work_dir/tempo-std"
  forge test --match-contract KeyAuthEncodingProbe -vvv
)
