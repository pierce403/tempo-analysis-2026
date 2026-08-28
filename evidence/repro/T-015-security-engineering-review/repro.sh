#!/usr/bin/env bash
set -euo pipefail

analysis_root="$(git rev-parse --show-toplevel)"
scratch_dir="$(mktemp -d /tmp/tempo-t015-checker.XXXXXX)"
main_revision=016e4c30530f943d6714e895ce0a34e22b01b9c1
pr_revision=8c492eb7b8800866ec0d64f43a6abebaa909408a
target_dir="$scratch_dir/target"
bindgen_include="$(gcc -print-file-name=include)"

cleanup() {
  rm -rf -- "$scratch_dir"
}
trap cleanup EXIT

git clone --filter=blob:none https://github.com/tempoxyz/zones.git "$scratch_dir/main"
git -C "$scratch_dir/main" checkout --detach "$main_revision"
git -C "$scratch_dir/main" apply \
  "$analysis_root/evidence/repro/T-015-security-engineering-review/zone-checker-unproven-custody.patch"

(
  cd "$scratch_dir/main"
  CARGO_TARGET_DIR="$target_dir" \
    BINDGEN_EXTRA_CLANG_ARGS="-I$bindgen_include" \
    cargo +1.95.0 test -p zone-checker \
    l1::tests::portal_balance_accepts_an_unproven_rpc_claim \
    --lib -- --exact --nocapture
)

git clone --filter=blob:none https://github.com/tempoxyz/zones.git "$scratch_dir/pr1289"
git -C "$scratch_dir/pr1289" fetch origin pull/1289/head
git -C "$scratch_dir/pr1289" checkout --detach "$pr_revision"
git -C "$scratch_dir/pr1289" apply \
  "$analysis_root/evidence/repro/T-015-security-engineering-review/zone-checker-unproven-custody.patch"
git -C "$scratch_dir/pr1289" apply \
  "$analysis_root/evidence/repro/T-015-security-engineering-review/zone-checker-omitted-account.patch"

(
  cd "$scratch_dir/pr1289"
  CARGO_TARGET_DIR="$target_dir" \
    BINDGEN_EXTRA_CLANG_ARGS="-I$bindgen_include" \
    cargo +1.95.0 test -p zone-checker \
    l1::tests::portal_balance_accepts_an_unproven_rpc_claim \
    --lib -- --exact --nocapture
  CARGO_TARGET_DIR="$target_dir" \
    BINDGEN_EXTRA_CLANG_ARGS="-I$bindgen_include" \
    cargo +1.95.0 test -p zone-checker \
    omitted_value_conserving_balance_reassignment_is_not_checked \
    --lib -- --nocapture
)

if [[ "${RUN_FULL:-0}" == "1" ]]; then
  (
    cd "$scratch_dir/main"
    CARGO_TARGET_DIR="$target_dir" \
      BINDGEN_EXTRA_CLANG_ARGS="-I$bindgen_include" \
      cargo +1.95.0 test -p zone-checker --lib
  )
  (
    cd "$scratch_dir/pr1289"
    CARGO_TARGET_DIR="$target_dir" \
      BINDGEN_EXTRA_CLANG_ARGS="-I$bindgen_include" \
      cargo +1.95.0 test -p zone-checker --lib
  )
fi
