#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  printf 'usage: %s MANIFEST.csv OUTPUT_DIR /path/to/trufflehog\n' "$0" >&2
  exit 2
fi

manifest="$1"
output_dir="$2"
trufflehog_bin="$3"

[[ -f "$manifest" ]] || { printf 'manifest not found: %s\n' "$manifest" >&2; exit 2; }
[[ -x "$trufflehog_bin" ]] || { printf 'trufflehog is not executable: %s\n' "$trufflehog_bin" >&2; exit 2; }
[[ ! -e "$output_dir" ]] || { printf 'refusing to overwrite existing output: %s\n' "$output_dir" >&2; exit 2; }

umask 077
mkdir -p "$output_dir/mirrors" "$output_dir/raw" "$output_dir/status"
printf 'scan_started_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee "$output_dir/run.txt"
"$trufflehog_bin" --version | tee -a "$output_dir/run.txt"
sha256sum "$manifest" "$trufflehog_bin" | tee -a "$output_dir/run.txt"

overall_rc=0
{
  read -r _header
  while IFS=, read -r name url _rest; do
    [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || { printf 'unsafe repository name: %s\n' "$name" >&2; exit 2; }
    [[ "$url" == https://github.com/tempoxyz/* ]] || { printf 'unexpected repository URL: %s\n' "$url" >&2; exit 2; }

    mirror="$output_dir/mirrors/$name.git"
    raw="$output_dir/raw/$name.jsonl"
    stderr_file="$output_dir/raw/$name.stderr"
    status="$output_dir/status/$name.txt"

    git clone --mirror "$url" "$mirror"
    git -C "$mirror" rev-parse --is-bare-repository
    git -C "$mirror" rev-parse --is-shallow-repository
    git -C "$mirror" remote get-url origin

    extra_flags=()
    if [[ "$name" == tempo || "$name" == tempo-apps ]]; then
      extra_flags+=(--force-skip-binaries --force-skip-archives)
    fi

    set +e
    "$trufflehog_bin" \
      --json --no-verification --no-update --results=unverified \
      --fail-on-scan-errors --log-level=1 --concurrency=4 \
      "${extra_flags[@]}" git "file://$mirror" --bare >"$raw" 2>"$stderr_file"
    scan_rc=$?
    set -e

    {
      printf 'repository=%s\nurl=%s\nfinished_utc=%s\nexit_code=%s\n' \
        "$name" "$url" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$scan_rc"
      printf 'commit_visits=%s\nmatch_records=%s\n' \
        "$(git -C "$mirror" rev-list --all --count)" "$(wc -l < "$raw")"
    } >"$status"

    if [[ "$scan_rc" -ne 0 ]]; then
      overall_rc=1
    fi
  done
} < "$manifest"

printf 'scan_finished_utc=%s\noverall_exit=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$overall_rc" | tee -a "$output_dir/run.txt"
printf 'Raw JSON may contain credential-shaped values. Keep OUTPUT_DIR private and never commit it.\n'
exit "$overall_rc"
