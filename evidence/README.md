# Evidence contract

`REPORT.md` uses claim-local evidence: every metadata line, prose paragraph,
list item, and table data row must directly include an inline Markdown link to
a tracked file below this directory. A link elsewhere in the section or in the
evidence index does not cover the claim. Headings, blank lines, table
headers/separators, and fenced-code-only lines are exempt.

Each linked narrative `.txt` artifact must contain explicit, human-readable
entries for all four fields:

1. **Timestamp/provenance** — an observation/execution date and, where
   applicable, the pinned commit, release, endpoint, or chain.
2. **Re-run command/procedure** — an exact safe command or bounded sequence
   another reviewer can execute. Reference only scripts, patches, fixtures, and
   source files that are tracked in this repository.
3. **Captured result** — the relevant output, assertion, status, hash, or other
   result produced by the recorded run.
4. **Limitations/safety** — what was not established or attempted and the
   authorization boundary for the procedure.

Run the mandatory gate from the repository root before committing or pushing a
report change:

```sh
python3 scripts/verify_report_evidence.py --require-tracked
```

The checker emits source line numbers for missing claim links, broken or
untracked targets, and incomplete narrative evidence artifacts. It exits
nonzero until every requirement is satisfied.

## Additional task evidence

- [`2026-08-27-T-015-security-engineering-review.txt`](2026-08-27-T-015-security-engineering-review.txt) pins the reviewed public security-engineering changes, records local checker/DEX/invariant/tooling results, and separates current-main reach from open or closed-unmerged work.
