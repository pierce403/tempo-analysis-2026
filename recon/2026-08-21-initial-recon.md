# Initial Recon — 2026-08-21

Passive public-source snapshot. This is an asset-discovery note, not a vulnerability report and not a complete subdomain or infrastructure inventory.

## Organization and positioning

- Official domain: [tempo.xyz](https://tempo.xyz)
- Verified GitHub organization: [tempoxyz](https://github.com/tempoxyz)
- Tempo describes itself as a payments-first Layer 1 incubated by Stripe and Paradigm.
- The official launch post names design partners across payments, banking, commerce, and agentic systems. Those relationships indicate integration boundaries; they do not make the partners' infrastructure in scope.
- Official vulnerability channel: `security@tempo.xyz` via the [`tempoxyz/tempo` security policy](https://github.com/tempoxyz/tempo/security)
- Policy observed on 2026-08-21: undergoing audit, no active bug bounty, and submissions not bounty-eligible until audits conclude.

## Network snapshot

| Network/surface | Observed value | Evidence |
| --- | --- | --- |
| Tempo mainnet | chain ID `4217` (`0x1079`) | Read-only `eth_chainId` response from `https://rpc.tempo.xyz` on 2026-08-21 |
| Moderato testnet | chain ID `42431` | Official repository/docs |
| Mainnet RPC | `https://rpc.tempo.xyz` | Official project sources and live response |
| Explorer | `https://explore.tempo.xyz` | Official repository/docs |
| Contract verifier | `https://contracts.tempo.xyz` | Official contract-verification docs |
| Mainnet indexer | `https://indexer.tempo.xyz` | `tempoxyz/tidx` documentation |
| Canonical docs mount | `https://tempo.xyz/developers` | `tempoxyz/docs`; legacy docs hosts redirect/proxy |

The main `tempo.xyz` response observed on 2026-08-21 was served by Vercel and included HSTS plus a `frame-ancestors 'self'` CSP. That identifies an edge provider for this response only; it does not establish the origin architecture or the posture of other subdomains.

## Protocol characteristics with security impact

- Rust node built on the Reth SDK and EVM-compatible execution
- Threshold Simplex consensus; official validator documentation says active-set management is currently permissioned
- ED25519 validator identity keys and BLS12-381 threshold signing shares, with periodic on-chain DKG
- Tempo transaction type `0x76` with passkeys/P-256, batching, fee sponsorship, scheduled calls, and parallel nonces
- TIP-20 native payment tokens and TIP-403 shared compliance policies
- reserved payment blockspace based on transaction classification
- multi-stablecoin fees and protocol-level conversion
- singleton stablecoin DEX documented at `0xdec0000000000000000000000000000000000000`
- EVM JSON-RPC plus public explorer, indexer, and source-verification services

These features concentrate early review around authorization-domain separation, native/predeploy state transitions, validator/DKG lifecycle, fee accounting, payment classification, and discrepancies between RPC/indexer/verifier views.

## Public repository surface

The GitHub API returned 66 public repositories on 2026-08-21. This count includes archived forks and experiments and is not equivalent to 66 production assets.

### Core and production-adjacent candidates

| Repository | Apparent role | Initial priority |
| --- | --- | --- |
| [`tempo`](https://github.com/tempoxyz/tempo) | node, consensus, execution, protocol/TIPs | Critical |
| [`tempo-apps`](https://github.com/tempoxyz/tempo-apps) | Tempo applications, including explorer-facing code | High |
| [`accounts`](https://github.com/tempoxyz/accounts) | account/passkey application surface | High |
| [`wallet-cli`](https://github.com/tempoxyz/wallet-cli), [`wallet-rs`](https://github.com/tempoxyz/wallet-rs) | wallet and transaction clients | High |
| [`tidx`](https://github.com/tempoxyz/tidx) | chain indexer and query API | High |
| [`tempo-std`](https://github.com/tempoxyz/tempo-std) | Solidity interfaces, signing and transaction helpers | High |
| [`tempo-go`](https://github.com/tempoxyz/tempo-go), [`pytempo`](https://github.com/tempoxyz/pytempo) | SDKs | Medium |
| [`docs`](https://github.com/tempoxyz/docs) | specifications and canonical documentation | High as evidence |
| [`pathusd-reserves`](https://github.com/tempoxyz/pathusd-reserves), [`bridgerton`](https://github.com/tempoxyz/bridgerton) | reserve/bridge-related surfaces | High pending architecture mapping |
| [`ledger-app-tempo`](https://github.com/tempoxyz/ledger-app-tempo) | hardware-wallet integration | High for signing UX |
| [`gh-actions`](https://github.com/tempoxyz/gh-actions), [`ci`](https://github.com/tempoxyz/ci) | shared build/release automation | High |
| [`mpp`](https://github.com/tempoxyz/mpp) and language/tool variants | Machine Payments Protocol ecosystem | Medium; raise if used in core flows |

### Inventory cautions

- `tempo-ts` and several Reth/Foundry forks are archived; determine replacement and residual dependency use before excluding them.
- Repository names and README claims are discovery evidence, not proof of production deployment.
- The organization inventory should be saved in machine-readable form on the next pass, including default branch, archive status, latest commit, releases, packages, and security policy.

## Early attack-surface hypotheses

These are review prompts, not suspected vulnerabilities:

1. Cross-check transaction acceptance between wallet encoders, RPC/txpool validation, block execution, and SDKs for type `0x76`.
2. Model passkey, delegated-key, fee-payer, nonce-key, batch, and scheduled-call combinations for domain or privilege confusion.
3. Trace issuer and compliance-manager authority across TIP-20/TIP-403, including shared-policy blast radius.
4. Prove DEX internal-balance conservation across partial fills, flip orders, multi-hop paths, pause/freeze states, and fee conversion.
5. Test payment-lane classification properties locally, especially payload-only classification and reverted/gas-heavy payment calls.
6. Examine validator admission, DKG transitions, persisted signing shares, crash recovery, and protection against unsafe identity reuse.
7. Compare source, released binaries, containers, chainspecs, active hardforks, and deployed native bytecode.
8. Map trust and consistency among RPC, explorer, indexer, contract verifier, wallets, and off-chain payment/reconciliation systems.

## Sources

- [Tempo GitHub organization](https://github.com/tempoxyz)
- [`tempoxyz/tempo`](https://github.com/tempoxyz/tempo)
- [Tempo security policy](https://github.com/tempoxyz/tempo/security)
- [Tempo protocol overview](https://docs.tempo.xyz/protocol)
- [Validator documentation](https://docs.tempo.xyz/guide/node/validator)
- [Payment lane specification](https://docs.tempo.xyz/protocol/blockspace/payment-lane-specification)
- [Stablecoin DEX specification](https://docs.tempo.xyz/protocol/exchange/spec)
- [Contract verification and network IDs](https://docs.tempo.xyz/quickstart/verify-contracts)
- [Introducing Tempo](https://tempo.xyz/blog/introducing-tempo)
- [`tempoxyz/docs` routing notes](https://github.com/tempoxyz/docs)
- [`tempoxyz/tidx`](https://github.com/tempoxyz/tidx)
