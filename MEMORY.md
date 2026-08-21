# Project Memory

Curated, non-secret context for future work. Read the relevant linked notes rather than treating this file as a chronological transcript.

## Stable project facts

- This repository is a defensive, public-information attack-surface analysis of Tempo, loosely modeled after `coinbase-analysis-2025`.
- The first phase is passive recon, architecture mapping, source review, and local reproduction. Active production testing requires explicit authorization.
- Research prioritizes theft paths associated with trusted access, developer/release compromise, third-party compromise, deceptive authorization, and privileged asset control. This is a behavioral lens, not attribution.
- `SCOPE.md` defines boundaries; `TASKS.md` tracks work; `PROCESS.md` defines the analysis workflow.

## Verified snapshots

- [Initial Tempo recon, 2026-08-21](recon/2026-08-21-initial-recon.md)
- [Current organizational attack surface, 2026-08-21](SURFACE.md)
- [Pinned public-repository manifest, 2026-08-21](recon/2026-08-21-public-repositories.csv)
- [Redacted public-history secret-scan report, 2026-08-21](recon/2026-08-21-public-repository-secret-scan.md)
- [Continuously maintained redacted findings register](FINDINGS.md)
- [Repository operating-system setup log, 2026-08-21](memory/logs/2026-08-21.md)

## Decisions

- [Memory and improvement model](memory/decisions/0001-memory-and-improvement-model.md)

## Reusable notes

- Add focused notes under `memory/notes/` when a fact or model will support more than one task.

## Learning queue

- [Proposed, active, and retired lessons](memory/learnings.md)

## Memory hygiene

- Prefer compact conclusions plus evidence pointers.
- Date mutable facts and refresh them before claiming they are current.
- Never store credentials, secrets, personal data, private vulnerability details, or unsupported allegations here.
- Condense or archive stale material when this index stops being easy to scan.
