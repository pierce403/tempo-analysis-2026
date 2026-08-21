# Research Tasks

This is the authoritative queue for bounded research work. Detailed chronology belongs in `memory/logs/`; sensitive candidate findings should be handled privately.

## Active

None.

## Queued

### T-002 — Pin the mainnet protocol baseline

- **State**: queued
- **Outcome**: Identify the exact mainnet release, commit, chainspec, genesis, active hardfork/TIP set, and native contract deployments.
- **Evidence required**:
  - [ ] Sources are primary and dated.
  - [ ] Release/source/deployment relationships are explicit.
  - [ ] Unresolved mismatches are recorded rather than inferred away.

### T-003 — Classify the public repository inventory

- **State**: queued
- **Outcome**: Save and classify the `tempoxyz` public repositories as production-critical, supporting, experimental, forked, archived, deprecated, or unknown.
- **Evidence required**:
  - [ ] Machine-readable inventory records URL, default branch, latest commit, archive status, releases, and security-policy presence.
  - [ ] Production relevance is evidence-backed or marked unknown.

### T-004 — Map protocol trust boundaries

- **State**: queued
- **Outcome**: Trace authorization, fee payment, native token/policy/DEX state, consensus, and finality boundaries.
- **Evidence required**:
  - [ ] Architecture notes cite exact specifications and source locations.
  - [ ] Privileged actors, keys, upgrade gates, and fund flows are enumerated.
  - [ ] Security assumptions and open questions are explicit.

## Blocked

None.

## Complete

### T-001 — Establish the repository operating system

- **State**: complete
- **Outcome**: Add durable scope, task, memory, logging, and skill-maintenance conventions adapted from Recurse.
- **Evidence required**:
  - [x] Repository-wide operating instructions exist.
  - [x] Task states and completion rules are defined.
  - [x] Memory index, learning lifecycle, and dated log structure exist.
  - [x] Skill catalog and curator procedure exist.
  - [x] Repo-local skill validation passes.
  - [x] Documentation links and `git diff --check` pass.

### T-000 — Initial passive recon and scope

- **State**: complete
- **Evidence**: `SCOPE.md`, `PROCESS.md`, and `recon/2026-08-21-initial-recon.md`.
