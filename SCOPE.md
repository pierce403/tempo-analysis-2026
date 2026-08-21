# Project Scope

## Objective

Build an evidence-backed map of Tempo's attack surface, then analyze the paths most likely to affect funds, transaction authorization, finality, availability, compliance enforcement, and software-supply-chain integrity.

This is initially an external, public-information review. A repository, deployed contract, or network behavior is not considered audited until its exact version or deployment is pinned and the relevant analysis phase is completed.

## System model

Tempo is an EVM-compatible, payments-focused Layer 1 built with the Reth SDK. The design adds or enshrines several security-critical behaviors:

- Threshold Simplex consensus and a currently permissioned validator set
- Tempo transaction type `0x76`, including batching, parallel nonce keys, fee sponsorship, scheduled calls, and passkey/P-256 authentication
- TIP-20 payment tokens, issuer controls, rewards, and transfer memos
- TIP-403 compliance policies and shared policy administration
- payment-lane transaction classification and reserved blockspace
- multi-token fee payment and protocol conversion
- an enshrined stablecoin order-book DEX with internal balances
- wallet, account, RPC, explorer, indexer, verification, SDK, and Machine Payments Protocol surfaces

## Phase 1 core scope

| Area | Representative assets | Primary security questions |
| --- | --- | --- |
| Protocol implementation | `tempoxyz/tempo` | Consensus safety/liveness, execution correctness, state transitions, RPC/P2P exposure, upgrade activation |
| Native payment primitives | TIP-20, TIP-403, rewards, fees, DEX | Unauthorized mint/freeze/transfer, policy bypass, accounting loss, order-book manipulation, fee-conversion failure |
| Transaction authorization | Tempo transactions, account keychain, passkeys, sponsorship, nonce keys | Replay, signature-domain or parser ambiguity, privilege escalation, spending-limit bypass, sponsor griefing |
| Network operations | mainnet `4217`, Moderato `42431`, validators, snapshots/releases | Validator-key lifecycle, DKG failure, equivocation protections, unsafe recovery, release provenance, availability |
| User-facing applications | `tempo-apps`, `accounts`, wallet clients, explorer/faucet | Key/session compromise, malicious signing, origin confusion, transaction simulation/display mismatch |
| Public data/API plane | RPC, WebSocket, indexer, contract verifier | Method exposure, inconsistent views, parser/resource exhaustion, verification confusion, trust-boundary failures |
| Supply chain | GitHub Actions, packages, binaries, containers, SDKs | Maintainer/workflow compromise, dependency risk, artifact substitution, provenance gaps |

## Secondary scope

These assets matter but should enter detailed review only after their relationship to core funds or authorization paths is documented:

- Machine Payments Protocol implementations and hosted services
- `pathUSD` reserve reporting and bridge/orchestration components
- Ledger application and other hardware-wallet integrations
- examples, developer tooling, test generators, fuzzing/benchmark projects
- third-party wallets, bridges, issuers, oracles, custody providers, and payment partners

Third-party components are analyzed at the integration boundary. Their unrelated internal systems are out of scope without separate authorization.

## Explicitly out of scope for the passive phase

- denial-of-service or load testing against public services
- exploitation, fund movement, or persistent state changes on mainnet
- credential attacks, phishing, social engineering, or employee targeting
- scanning unrelated Stripe, Paradigm, validator, partner, or vendor infrastructure
- claims about private infrastructure based only on vendor headers or DNS

## Priority threat outcomes

1. Unauthorized movement, minting, freezing, or destruction of payment assets
2. Forged, replayed, mis-scoped, or misleading user authorization
3. Consensus safety failure, chain halt, invalid finality, or unsafe validator recovery
4. DEX/internal-balance insolvency or fee-conversion/accounting failure
5. Compliance-policy bypass or illegitimate policy administration
6. Compromise of releases, wallets, web origins, packages, or deployment pipelines
7. RPC/indexer/verifier inconsistencies that induce unsafe downstream decisions

## Scope gates still to resolve

- Pin the exact mainnet protocol release, chainspec, genesis, and activated hardfork/TIP set.
- Enumerate native/predeployed contracts and verify mainnet bytecode against source.
- Identify the authoritative web, RPC, WebSocket, explorer, faucet, indexer, verifier, package, and container endpoints.
- Determine which GitHub repositories are production-critical versus experiments, forks, or deprecated components.
- Inventory published audits and map each report to exact commits and deployed versions.
- Reconfirm the security policy and whether a bounty or safe-harbor terms have been introduced.
- Decide whether later active testing will have written authorization and a dedicated test environment.

## Scope-control rule

Every tested asset must have an owner, environment, exact version or observation time, authorization basis, and evidence source. Hypotheses remain observations until independently reproduced and impact-validated.
