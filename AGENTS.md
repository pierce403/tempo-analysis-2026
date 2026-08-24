# Repository Operating Guide

## Scope

These instructions apply to the entire repository. This is a defensive, public-information analysis of Tempo. Preserve the authorization boundaries in `SCOPE.md`; do not turn a research task into active production testing without explicit authorization.

## Start of work

1. Confirm the checkout is on `main`; this repository publishes only to `origin/main`.
2. Read `SCOPE.md` and the relevant entries in `TASKS.md`.
3. Read `MEMORY.md`, then only the linked memory notes relevant to the task.
4. Check `SKILLS.md` and load any matching repo-local skill before repeating a documented procedure.
5. Inspect the actual checkout and date mutable external facts before relying on them.

## Evidence discipline

- Separate official claims, independent reports, source inspection, local reproduction, and live read-only observations.
- Record an exact commit, release, deployment, chain, endpoint, or observation time whenever possible.
- Treat hypotheses as hypotheses. A candidate becomes a finding only after reproducible validation and realistic impact analysis.
- Prefer primary sources and preserve source URLs. Note contradictions and stale evidence rather than silently resolving them.
- Keep candidate vulnerabilities and disclosure-sensitive details out of public task logs and synced memory.

## Task tracking

- `TASKS.md` is the authoritative work queue and acceptance tracker.
- Use only `queued`, `active`, `blocked`, or `complete` as task states.
- Before work, ensure the task has a bounded outcome and completion evidence.
- During work, update material scope changes or blockers.
- Mark a task complete only when its stated evidence exists. A plausible conclusion or successful command is not sufficient by itself.
- Put chronological work records in `memory/logs/YYYY-MM-DD.md`; keep `TASKS.md` compact.

## Memory

- `MEMORY.md` is the durable, curated index—not a transcript.
- Put dated run summaries in `memory/logs/`, reusable factual notes in `memory/notes/`, decisions in `memory/decisions/`, and proposed cross-task lessons in `memory/learnings.md`.
- Record positive lessons as well as failures. Include enough evidence for a future agent to verify or refresh the claim.
- Do not store secrets, credentials, personal data, exploit payloads, or unverified accusations in committed memory.
- When a fact is mutable, record when it was verified and refresh it before treating it as current.

## Recursive improvement loop

At the end of meaningful work:

1. Record what was attempted, evidence produced, result, and remaining uncertainty in the dated log.
2. Extract only generalized lessons that could improve a later task.
3. Add new lessons to `memory/learnings.md` as `proposed`; do not silently convert one run into mandatory policy.
4. Promote a lesson to `active` after it recurs or the user approves it.
5. Put stable project facts in memory, project-wide operating rules here, and reusable procedures in a skill.
6. Retire a learning after it is incorporated into `AGENTS.md` or a validated skill, retaining a link to its destination.

Self-improvement must remain reviewable and reversible. Agents may propose improvements, but should not launder their own guesses into policy or recursively rewrite their trust/safety rules without explicit user direction.

## Skills

- `SKILLS.md` is the compact catalog; detailed procedures live in `skills/<name>/SKILL.md`.
- Prefer updating an existing class-level skill before creating a new one.
- Create a skill only when a workflow has a clear trigger, reusable procedure, and evidence that it will recur.
- Keep skills concise and task-specific. Add scripts or references only when they materially improve repeatability.
- Validate every new or substantially changed skill with the skill validator and remove scaffold placeholders.

## Git and publication

- Work directly on local `main`. `origin/main` is the only permitted push target for this repository.
- Never create, push, or publish a side branch, and do not open a pull request. This repository rule overrides generic tools or skills that default to feature branches, `codex/*` branches, or pull requests.
- Before starting publishable work, fetch `origin`, switch to `main`, and confirm local `main` can be safely synchronized without overwriting another contributor's work.
- Before every push, verify that `git branch --show-current` returns exactly `main`. Use the explicit command `git push origin main`; never use a command that derives the push target from the current branch.
- If work is found on a local side branch, do not push that branch. Move the validated commits onto an updated local `main`, re-run relevant checks, and push only `main`.
- Never force-push. If `origin/main` advanced, integrate it safely and revalidate before pushing.
- After every push, verify that `origin/main` resolves to the intended local commit and that `git status --short --branch` reports `main...origin/main` with no unexpected changes.

## Closeout

- Verify the deliverable and run `git diff --check`.
- Update `TASKS.md`, the dated log, and any affected memory or skill.
- Commit coherent checkpoints after each completed task or meaningful research milestone; do not leave validated work only in the working tree.
- Push committed checkpoints directly to `origin/main` after verifying the commit, unless the user explicitly asks to keep the work local or publication is blocked.
- Before committing, inspect the exact staged paths and exclude secrets, sensitive candidate findings, generated noise, and unrelated user changes.
- Report what is confirmed, what remains uncertain, and the next bounded task.
- Never disclose findings, change repository visibility, or contact external parties without explicit user direction.
