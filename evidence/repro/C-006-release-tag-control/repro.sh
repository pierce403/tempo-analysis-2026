#!/usr/bin/env bash
set -euo pipefail

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT


printf 'executed_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

git -C "$work_dir" init -q -b main
git -C "$work_dir" config user.name "Tempo report local model"
git -C "$work_dir" config user.email "local-model@example.invalid"

printf 'reviewed\n' > "$work_dir/reviewed.txt"
git -C "$work_dir" add reviewed.txt
git -C "$work_dir" commit -q -m reviewed
main_sha="$(git -C "$work_dir" rev-parse HEAD)"

git -C "$work_dir" switch -q -c unreviewed
printf 'synthetic-unreviewed-artifact\n' > "$work_dir/artifact.txt"
git -C "$work_dir" add artifact.txt
git -C "$work_dir" commit -q -m unreviewed
git -C "$work_dir" tag v9.9.9
tag_sha="$(git -C "$work_dir" rev-parse v9.9.9^{commit})"
git -C "$work_dir" switch -q main

set +e
git -C "$work_dir" merge-base --is-ancestor v9.9.9 main
ancestor_rc=$?
set -e

case v9.9.9 in
  v*.*.*) trigger_match=yes ;;
  *) trigger_match=no ;;
esac

test "$ancestor_rc" -eq 1
test "$trigger_match" = yes
test "$(git -C "$work_dir" show v9.9.9:artifact.txt)" = synthetic-unreviewed-artifact

printf 'main_sha=%s\ntag_sha=%s\ntrigger_match=%s\nmerge_base_is_ancestor_rc=%s\ntag_payload=%s\n' \
  "$main_sha" "$tag_sha" "$trigger_match" "$ancestor_rc" \
  "$(git -C "$work_dir" show v9.9.9:artifact.txt)"
