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

### T-013 — Enforce report claim-to-evidence traceability

- **State**: complete
- **Outcome**: Every factual or analytical claim unit in `REPORT.md` now links directly to committed evidence with dated provenance, safe rerun instructions, captured results, and limitations. Portable sanitized fixtures replace ignored workstation-only PoCs, and a mandatory tracked-file validator enforces the contract before publication.
- **Evidence required**:
  - [x] Every report metadata line, prose claim block, list item, and data-table row has a direct `evidence/` link; headings and table separators are excluded.
  - [x] Linked evidence is committed and contains timestamp/provenance, rerun instructions, captured output or expected deterministic result, and explicit limits.
  - [x] Sanitized local-only PoC fixtures referenced by evidence are committed rather than hidden only under ignored `target/` or `findings/` paths.
  - [x] An automated verifier fails on missing claim links, missing files, non-evidence targets, or incomplete evidence metadata.
  - [x] Markdown links, evidence coverage, deterministic repros, secret scanning, and both working-tree/staged `git diff --check` gates pass before direct publication to `origin/main`.

### T-012 — Audit MPP streaming and agent-payment economics

- **State**: complete
- **Outcome**: Audited the current public Machine Payments Protocol stack for theft-relevant implementation defects and protocol asymmetries, with a focused streaming-payment/free-option model. Retained C-010 after local TypeScript/Rust reproduction and passive reserve-interface checks, while separating public prior art and inherent fair-exchange risk from the possibly unreviewed ordinary-settlement composition. Separately retained C-012 after a full-verifier PoC accepted a one-unit increment for the released example's 10,000-unit response, and C-011 after a deterministic verifier race produced two non-management/content-gate predicate successes for one durable voucher increment; static source supplies the handler-delivery composition. Production consumer reach remains an owner-side gate.
- **Evidence required**:
  - [x] Current specifications, implementations, integrations, releases, and exact revisions are inventoried with deployed relevance separated from examples.
  - [x] Payment, streaming, settlement, cancellation, retry, and delivery state machines are mapped with explicit payer/payee invariants and loss bounds.
  - [x] Upstream suites and focused adversarial properties ran locally; confirmed candidates have deterministic dummy/local reproduction and falsified hypotheses are retained as negative results.
  - [x] Each retained candidate distinguishes an implementation bug from an inherent fairness tradeoff and records prerequisites, realistic theft impact, limiting controls, prior art, and owner-confirmation gates.
  - [x] No live payment, credential use, deceptive agent interaction, production mutation, load test, or unrelated third-party testing was performed.

### T-011 — Produce the consolidated pentest report and evidence pack

- **State**: complete
- **Outcome**: Created a dated root `REPORT.md` presenting the assessed Tempo attack surface, findings, local-only PoC evidence, public perimeter, communications/identity exposure, and GitHub governance in a conventional pentest-report structure.
- **Evidence required**:
  - [x] Every issue is tied to a stable identifier, severity, affected revision/asset, prerequisites, impact, remediation, and a linked sanitized text evidence record.
  - [x] Reproduction evidence distinguishes executed local/dummy PoCs, static configuration proof, and live read-only observations; conditional findings are not presented as exploited.
  - [x] Public hosts, DNS/TLS/HTTP/common-port observations, and provider/shared-edge limitations are current and timestamped.
  - [x] Communications, email, Slack, VPN/SSO, support, and DevOps exposure is limited to public evidence with private controls marked unknown.
  - [x] GitHub inventory covers outside-fork versus trusted-writer PR paths, branch/ruleset visibility, workflows, environments, runners, and release/deploy entrypoints.
  - [x] No credential was verified, no authentication or state-changing request was attempted, and no unrelated provider/partner infrastructure was scanned.

### T-006 — Inventory Tempo's public infrastructure

- **State**: complete
- **Outcome**: Built a dated inventory of public `tempo.xyz` hosts and services using passive sources followed by bounded DNS/TLS/HTTP/common-port confirmation, with shared-provider edges and wildcard results explicitly separated from Tempo origins.
- **Evidence required**:
  - [x] Passive sources, DNS answers, certificate names, HTTP behavior, provider inference, and ownership confidence are recorded.
  - [x] Wildcard behavior was tested before interpreting the source-derived name inventory.
  - [x] No unrelated partner domains, intrusive requests, authentication testing, or state changes were included.

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
