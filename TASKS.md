# Research Tasks

This is the authoritative queue for bounded research work. Detailed chronology belongs in `memory/logs/`; sensitive candidate findings should be handled privately.

## Active

### T-002 — Pin the mainnet protocol baseline

- **State**: active
- **Outcome**: Identify the exact mainnet release, commit, chainspec, genesis, active hardfork/TIP set, and native contract deployments.
- **Evidence required**:
  - [ ] Sources are primary and dated.
  - [ ] Release/source/deployment relationships are explicit.
  - [ ] Unresolved mismatches are recorded rather than inferred away.

### T-005 — Build the theft-focused trust and adversary map

- **State**: active
- **Outcome**: Map trusted humans, developer/release systems, third parties, privileged on-chain roles, and their plausible conversion paths to movable value.
- **Evidence required**:
  - [ ] Every path identifies foothold, authority crossed, theft target, constraints, detection opportunities, and evidence confidence.
  - [ ] Behavioral resemblance is not presented as actor attribution.
  - [ ] Damage-only paths are deprioritized unless they enable theft or concealment.

### T-006 — Inventory Tempo's public infrastructure

- **State**: active
- **Outcome**: Build a dated inventory of public `tempo.xyz` hosts and services using passive sources followed by bounded read-only confirmation.
- **Evidence required**:
  - [ ] Passive sources, DNS answers, certificate names, HTTP behavior, provider inference, and ownership confidence are recorded.
  - [ ] Wildcard behavior is tested before any small rate-limited DNS wordlist.
  - [ ] No unrelated partner domains, intrusive requests, authentication testing, or state changes are included.

## Queued

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

### T-010 — Find and validate another high-impact theft-relevant bug

- **State**: complete
- **Outcome**: Identified C-009, a cross-repository wallet-authorization candidate in which the released CLI requests a 30-day unrestricted key but later reports omitted authority as zero-spend and empty-scoped. The output mismatch is locally reproduced; unrestricted call reachability is pinned to the current hosted schema; the private server's token-limit policy remains an explicit owner-confirmation gate.
- **Evidence required**:
  - [x] The affected repository, revision, invariant, and trust boundary are pinned exactly.
  - [x] The mechanism is reproduced locally with dummy state or rejected with a recorded falsification result; production state is not touched.
  - [x] Realistic theft impact, required privileges, deployed relevance, detection opportunities, and limiting conditions are explicit.
  - [x] Public prior art and adjacent tests are checked before novelty is claimed.
  - [x] Disclosure-sensitive details remain ignored while the tracked register contains only a redacted assessment.

### T-009 — Consolidate the current attack surface and scan public repository history

- **State**: complete
- **Outcome**: Maintain a root-level public attack-surface map and redacted findings register, backed by a complete pinned clone and non-verifying secret scan of every public `tempoxyz` repository.
- **Evidence required**:
  - [x] The current public repository set is enumerated from GitHub, completely cloned with history, and pinned to exact revisions.
  - [x] Secret scanning covers every clone and reachable commit history without attempting to authenticate with candidate credentials; binary/archive exceptions are explicit.
  - [x] Scanner candidates are manually triaged, values are never committed, and limitations are explicit.
  - [x] `SURFACE.md` distinguishes confirmed assets, trust boundaries, unknowns, and observation dates.
  - [x] `FINDINGS.md` uses stable identifiers, confidence/status, realistic criminal-abuse paths, prerequisites, evidence, and remediation without publishing exploit-ready details.

### T-008 — Audit PR trust paths and contract test coverage

- **State**: complete
- **Outcome**: Identify theft-relevant GitHub/PR automation boundaries and execute the complete available test suites for the highest-value public smart-contract systems at pinned revisions.
- **Evidence required**:
  - [x] Workflow conclusions distinguish fork, same-repository writer, member, bot, environment, runner, and secret prerequisites.
  - [x] Retained candidates are tied to immutable source and dummy/local reproduction only.
  - [x] Full-suite commands and results are recorded, with toolchain/environment failures separated from product failures.
  - [x] Public novelty checks and material impact constraints are explicit.

### T-007 — Validate private disclosure candidates

- **State**: complete
- **Outcome**: Triage the first protocol, supply-chain, and infrastructure candidates into evidence-backed private reports without touching production state.
- **Evidence required**:
  - [x] Each retained candidate is pinned to exact source or dated live evidence.
  - [x] Reproducible mechanisms use local dummy data only.
  - [x] Public prior art and material impact constraints are recorded.
  - [x] Disclosure-sensitive details remain outside committed task logs and memory.

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
