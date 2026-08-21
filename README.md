# Tempo Attack-Surface Analysis 2026

This repository is a public-information security review and threat-modeling project for [Tempo](https://tempo.xyz), a payments-focused Layer 1 blockchain.

The work is loosely modeled on `coinbase-analysis-2025`, but the initial scope is broader than a Solidity audit. Tempo's security boundary includes a Rust execution/consensus client, enshrined payment contracts, a custom transaction type, wallets and passkeys, public RPC and indexing services, web applications, SDKs, release infrastructure, and payment integrations.

## Research status

Initial passive recon and scope definition began on 2026-08-21. No vulnerability is asserted by anything in this repository unless it is explicitly promoted to a validated finding with reproducible evidence.

Start with:

- [SCOPE.md](SCOPE.md) — boundaries, priorities, and open scope questions
- [THREAT_MODEL.md](THREAT_MODEL.md) — theft-focused adversary and trust-boundary model
- [PROCESS.md](PROCESS.md) — evidence and analysis workflow
- [TASKS.md](TASKS.md) — bounded research queue and acceptance evidence
- [AGENTS.md](AGENTS.md) — repository operating and improvement loop
- [MEMORY.md](MEMORY.md) — curated durable context
- [SKILLS.md](SKILLS.md) — reusable procedure catalog
- [recon/2026-08-21-initial-recon.md](recon/2026-08-21-initial-recon.md) — first public-source snapshot

## Safety and disclosure

This project starts with passive collection and local review of public code. Do not perform disruptive testing, social engineering, credential testing, high-volume traffic, or testing against third-party systems without explicit authorization.

Tempo's published security policy directs vulnerability reports to `security@tempo.xyz`, asks researchers not to use public GitHub issues, and currently says that Tempo is undergoing audit and has no active bug bounty. Reconfirm that policy before any testing or disclosure because it can change.
