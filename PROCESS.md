# Analysis Process

## 1. Scope and evidence ledger

- [x] Record the official domain, GitHub organization, security contact, and current bounty statement.
- [x] Confirm the public mainnet chain ID through a read-only JSON-RPC call.
- [x] Capture an initial public repository inventory.
- [ ] Create an asset ledger with owner, environment, version, source, and last verification time.
- [ ] Build a passive subdomain/service inventory and record confidence, ownership, DNS/TLS/HTTP evidence, and observation time.
- [ ] Pin the mainnet release, chainspec, genesis, active protocol version, and native contracts.
- [ ] Collect audit reports and map them to commits and deployments.

## 2. Architecture and trust boundaries

- [ ] Trace transaction submission through RPC, pool validation, execution, proposal, consensus, and finality.
- [ ] Map key types, authorization domains, nonce spaces, fee payers, and sponsored execution.
- [ ] Map TIP-20/TIP-403 roles, upgrades, issuer controls, rewards, and compliance dependencies.
- [ ] Trace DEX deposits, internal balances, orders, fills, swaps, fees, and withdrawals.
- [ ] Map validator admission, DKG, signing-share storage, rotation, recovery, and protocol upgrades.
- [ ] Map build, signing, package, container, and deployment pipelines.
- [ ] Map human and third-party trust: maintainers, reviewers, release operators, issuer/policy administrators, validators, support/recovery roles, and critical vendors.
- [ ] For each privileged boundary, document the plausible conversion path from compromise to movable value.

## 3. Reproducible local baselines

- [ ] Clone each selected target into an ignored `target/` workspace.
- [ ] Pin full commit hashes and preserve upstream URLs.
- [ ] Build with documented toolchain versions and run the upstream tests.
- [ ] Verify release artifacts/provenance where available.
- [ ] Start a local network and record a minimal known-good transaction/finality baseline.

## 4. Systematic review

- [ ] Review parser and serialization boundaries, custom transaction validation, and signature handling.
- [ ] Review consensus safety/liveness assumptions and adversarial validator/network states.
- [ ] Review all native-contract asset and privilege flows.
- [ ] Review RPC/P2P resource limits and cross-layer consistency without testing production load.
- [ ] Review wallet/app origin, session, passkey, signing, simulation, and display boundaries.
- [ ] Review release and deployment supply chains.
- [ ] Review third-party integration failure and compromise paths at Tempo-controlled boundaries.
- [ ] Prioritize issues with a plausible theft, persistent access, authorization, or concealment outcome over damage-only weaknesses.
- [ ] Add focused static analysis, fuzzing, property tests, and differential tests.

## 5. Bounded infrastructure and application mapping

- [ ] Start with certificate transparency, public DNS sources, repository/config references, and search indexes.
- [ ] Confirm candidate `tempo.xyz` hosts with low-frequency DNS, TLS, and HTTP observations; detect wildcards before wordlist enumeration.
- [ ] Keep any DNS wordlist small, rate-limited, logged, and restricted to `tempo.xyz`.
- [ ] Map confirmed web/API surfaces with ordinary browser behavior and passive proxy capture first.
- [ ] Require a separate explicit authorization gate before Burp active scanning, intrusive payloads, authentication testing, or state-changing requests.

## 6. Validation and reporting

- [ ] Reproduce suspected issues locally at an exact commit.
- [ ] Distinguish specification ambiguity, implementation defect, deployment mismatch, and operational risk.
- [ ] Prove prerequisites and realistic impact; do not infer fund loss from a theoretical code path.
- [ ] Check whether the issue is already fixed, disclosed, or covered by a hardfork/TIP.
- [ ] Keep sensitive candidate findings private and use Tempo's current disclosure channel.

## Evidence standard

Prefer, in order: exact source/commit and local reproduction; verified deployed bytecode or live read-only protocol behavior; official specifications and security policy; signed releases/audit reports; reputable independent research. Date every mutable fact.
