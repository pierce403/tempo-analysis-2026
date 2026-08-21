# Learning Queue

Synced learnings must be generalized, evidence-backed, and free of secrets or sensitive finding details.

Use these states:

- `proposed`: observed once and useful immediately as a reminder, but not policy
- `active`: repeated or explicitly approved
- `retired`: incorporated into durable instructions or a validated skill
- `rejected`: disproven, too specific, or not useful

## Proposed

### L-001 — Separate organization discovery from production scope

- **State**: proposed
- **Tags**: `#scope` `#recon`
- **Observed**: 2026-08-21 during initial GitHub organization inventory.
- **Lesson**: A public repository name or README establishes a candidate asset, not production relevance. Require deployment, dependency, package, release, or official architecture evidence before classifying it as production-critical.
- **Evidence**: `recon/2026-08-21-initial-recon.md`
- **Graduation**: Promote into a recon skill if the same classification problem recurs during T-003.

### L-002 — Model privileged CI as a code-provenance boundary

- **State**: proposed
- **Tags**: `#github-actions` `#supply-chain`
- **Observed**: 2026-08-21 during T-008 workflow review.
- **Lesson**: A membership check, action SHA pin, or empty job token does not make a job safe if unreviewed code can change the workflow, a local action, a lifecycle hook, or an executable resolved later in the same credentialed job. Record trigger identity, checked-out ref, environment gate, credential timing, and executable provenance separately.
- **Evidence**: `memory/logs/2026-08-21.md`
- **Graduation**: Promote into a GitHub workflow-review skill after the same boundary model is reused in another organization audit.

### L-003 — Audit release tags independently from protected branches

- **State**: proposed
- **Tags**: `#github-actions` `#release`
- **Observed**: 2026-08-21 during T-008 release-path review.
- **Lesson**: Default-branch review rules do not establish release integrity when a write-capable identity can create a tag at an unreviewed commit. Review tag creation rules, workflow source provenance, environments, mutable artifact aliases, signing, and publication as one chain.
- **Evidence**: `memory/logs/2026-08-21.md`
- **Graduation**: Promote into a release-review skill after a second audit confirms the same control gap pattern.

### L-004 — Pair full-suite status with executable coverage

- **State**: proposed
- **Tags**: `#testing` `#contracts`
- **Observed**: 2026-08-21 during T-008 contract testing.
- **Lesson**: A complete green test command can still execute none of a library's security-sensitive helpers. Run coverage, compare covered code to the stated product surface, and preserve ignored-test counts before using green status as assurance evidence.
- **Evidence**: `recon/2026-08-21-contract-test-baseline.md`
- **Graduation**: Promote into the contract-review procedure after it recurs in another contract system.

## Active

None.
## Retired

None.

## Rejected

None.
