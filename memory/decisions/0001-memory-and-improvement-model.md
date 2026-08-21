# Decision 0001 — Memory and improvement model

- **Date**: 2026-08-21
- **Status**: adopted

## Decision

Use a human-reviewable promotion loop:

`task evidence -> dated log -> proposed learning -> active learning -> AGENTS.md or validated skill`

The repository keeps four distinct knowledge layers:

1. `TASKS.md` for bounded work, state, and acceptance evidence.
2. `memory/logs/` for chronological run records.
3. `MEMORY.md`, `memory/notes/`, and `memory/decisions/` for durable factual or architectural context.
4. `SKILLS.md` and `skills/` for repeatable procedures.

Validated task and milestone checkpoints are committed and pushed to the configured private GitHub remote by default. This makes the memory and evidence trail durable without making it public; visibility changes still require explicit user direction.

## Rationale

This preserves the useful Recurse conventions—durable context, positive and negative lessons, compact skill discovery, and regular reflection—without allowing a single agent run to rewrite policy based on its own unverified interpretation.

## Promotion rules

- A one-off observation remains in a dated log.
- A generalized cross-task lesson starts as `proposed` in `memory/learnings.md`.
- A repeated or user-approved lesson becomes `active`.
- A stable repository-wide rule moves to `AGENTS.md`.
- A stable reusable procedure moves to a validated skill.
- The original learning becomes `retired` and links to its destination.
