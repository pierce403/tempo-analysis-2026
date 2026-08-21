# Project Scope

## Objective

Build an evidence-backed map of Tempo's attack surface, prioritizing paths that a sophisticated financially motivated operator could convert into theft: trusted-access abuse, developer and release compromise, third-party compromise, deceptive authorization, privileged asset control, and software-supply-chain compromise.

This is initially an external, public-information review. A repository, deployed contract, or network behavior is not considered audited until its exact version or deployment is pinned and the relevant analysis phase is completed.

`THREAT_MODEL.md` defines the Lazarus-style theft lens. It is a prioritization model, not an attribution exercise. Damage-only outcomes are secondary unless they enable theft, concealment, coercive recovery, or compromise of a higher-value boundary.

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
| Protocol implementation | `tempoxyz/tempo` | Execution or upgrade paths that can authorize, conceal, or amplify theft; source-to-deployment integrity |
| Native payment primitives | TIP-20, TIP-403, rewards, fees, DEX | Unauthorized mint/freeze/transfer, policy bypass, accounting loss, order-book manipulation, fee-conversion failure |
| Transaction authorization | Tempo transactions, account keychain, passkeys, sponsorship, nonce keys | Replay, signature-domain or parser ambiguity, privilege escalation, spending-limit bypass, sponsor griefing |
| Network operations | mainnet `4217`, Moderato `42431`, validators, snapshots/releases | Privileged operator access, validator/signing-key lifecycle, unsafe recovery, release provenance, theft-relevant finality failures |
| User-facing applications | `tempo-apps`, `accounts`, wallet clients, explorer/faucet | Key/session compromise, malicious signing, origin confusion, transaction simulation/display mismatch |
| Public data/API plane | RPC, WebSocket, indexer, contract verifier | Method exposure, inconsistent views, parser/resource exhaustion, verification confusion, trust-boundary failures |
| Supply chain | GitHub, maintainers, Actions, packages, binaries, containers, SDKs | Trusted contributor/workstation compromise, review or workflow bypass, dependency risk, artifact substitution, provenance gaps |

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

## Infrastructure discovery progression

Infrastructure mapping proceeds in bounded stages:

1. Passive discovery through official sources, repository references, certificate transparency, public DNS/passive-DNS datasets, package metadata, and search indexes.
2. Read-only confirmation of discovered `tempo.xyz` hosts through authoritative DNS, TLS certificates, HTTP headers, documented public API calls, and low-frequency connection checks.
3. A small, rate-limited DNS wordlist against `tempo.xyz`, only after wildcard detection and resolver controls are documented. No broad Internet scanning or partner-domain enumeration.
4. Manual and passive-proxy web/API crawling of confirmed in-scope surfaces. Burp active scanning, intrusive checks, authentication testing, or state-changing requests require a separate explicit gate.

Record discovery source, query time, resolution, certificate names, HTTP behavior, inferred owner/provider, and confidence. A subdomain's existence does not prove that it is Tempo-operated, production, or authorized for invasive testing.

## Priority threat outcomes

1. Unauthorized movement, minting, redemption, freezing, or durable control of payment assets
2. Compromise of trusted humans, developer systems, source control, CI/CD, packages, releases, wallets, web origins, DNS, or deployment credentials that can be converted into theft
3. Forged, replayed, over-broad, persistent, or misleading user/delegated authorization
4. Compromise of a third party whose trusted access or data can redirect funds or sensitive authorization
5. DEX/internal-balance insolvency, fee-conversion failure, reserve/bridge abuse, or accounting manipulation
6. Compliance-policy or issuer-control abuse that enables seizure, redirection, laundering, or selective bypass
7. Consensus, validator, RPC, indexer, or verifier failures when they enable theft, concealment, or unsafe recovery

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
