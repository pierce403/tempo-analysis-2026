# Tempo.xyz External Attack-Surface and Code-Assisted Security Assessment

**Report date:** August 25, 2026 ([evidence](evidence/2026-08-25-report-claim-audit.txt))<br>
**Assessment window:** August 21–25, 2026 ([evidence](evidence/2026-08-25-report-claim-audit.txt))<br>
**Report version:** 1.3, incorporating an October 31, 2026 source/release follow-up; the original assessment remains dated August 25 ([baseline](evidence/2026-08-25-report-claim-audit.txt); [follow-up](evidence/2026-10-31-upstream-ci-release.txt))<br>
**Assessment type:** external, public-information, read-only infrastructure review and local source-code testing ([evidence](evidence/2026-08-25-report-claim-audit.txt))<br>
**Target:** Tempo (`tempo.xyz` and the public `tempoxyz` GitHub organization) ([evidence](evidence/2026-08-25-report-claim-audit.txt))<br>
**Handling:** private working report; no external disclosure has been made ([evidence](evidence/2026-08-25-report-claim-audit.txt))

## Executive summary

This assessment mapped Tempo's publicly observable organizational attack surface with a financial-theft threat model. The review emphasized paths a financially motivated, well-resourced actor—particularly one willing to compromise an employee, contractor, GitHub App, release identity, or service provider—could use to reach funds, wallet authority, production services, or trusted software distribution. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

The central assessment is that Tempo's highest-leverage externally visible risk is **trusted-identity compromise crossing into privileged automation**, rather than an unauthenticated Internet exploit. Three reviewed workflow paths execute same-repository pull-request code at or before a boundary carrying cloud or application-held financial-key authority; a fourth executes PR-controlled lifecycle code in a shared release environment, but signing and publication reach were not confirmed. A separate release design allows matching tags to initiate official artifact publication without public evidence that the tag must point to reviewed protected-branch history. These paths do not work for an ordinary outside-fork contributor under GitHub's normal secret model; they become relevant after compromise or misuse of a writer, member, collaborator, App, deploy key, or release identity. ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [C-008 evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt); [release-tag evidence](evidence/2026-08-23-C-006-release-tag-control.txt))

Twelve candidate issues were retained: two P0, five P1, four P2, and one P3. Two additional repository-secret-hygiene observations need owner-side confirmation. Ten candidates have harmless local PoCs that reproduce the relevant process, protocol, or serialization boundary with dummy values; the release-tag candidate adds a local no-publication control model. The MPP pass found three cross-layer disagreements: automatic clients can sign server-selected streaming headroom before delivery and ordinary/scheduled settlement can cash the voucher high-water mark rather than recorded consumption; the released Rust multi-fetch integration can accept a one-unit voucher despite an advertised 10,000-unit response price; and concurrent Rust verifier predicates can succeed for multiple responses while durable authorization advances once. The historical authentication-origin item is supported by a dated live-response timeline because its prior behavior is no longer present and should not be recreated. No live credential was confirmed, no production authorization was attempted, no GitHub workflow was triggered, no live payment was made, and no production data or state was changed. ([report audit](evidence/2026-08-25-report-claim-audit.txt); [MPP C-010](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt); [MPP C-011](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt); [MPP C-012](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))

No evidence in this assessment established that any candidate has been exploited, is unknown to Tempo, or exposes unrestricted production authority. Several ratings are conditional on private facts—credential scope, environment separation, key reuse, tag policy, hosted wallet policy, and affected balances—that only Tempo can resolve. Those conditions are called out per finding. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

An October 31 follow-up found source/release fixes for C-011, C-012, and C-009, plus a source fix for C-007 that is not in the latest formal GitHub release. C-005 and C-010 received meaningful but partial mitigations. The visible boundary remains in C-002, C-003, C-004, C-006, and C-008; owner-only controls and actual deployments were not tested. These are status updates to the August findings, not proof that the upstream changes were caused by this report. ([CI/release follow-up](evidence/2026-10-31-upstream-ci-release.txt); [protocol/wallet follow-up](evidence/2026-10-31-upstream-protocol-wallet.txt); [MPP follow-up](evidence/2026-10-31-upstream-mpp.txt))

### Risk profile

| Priority | Count | Main theme |
| --- | ---: | --- |
| P0 | 2 | Same-repository PR code can reach a Cloudflare credential configured in preview/production workflows or an application-held financial-key-named boundary ([C-002/C-004 evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt); [C-005 evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt)) |
| P1 | 5 | Release/wallet supply chain, delegated authorization, and MPP streaming overcapture with plausible theft impact ([C-003 evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [C-006 evidence](evidence/2026-08-23-C-006-release-tag-control.txt); [C-008 evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt); [C-009 evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt); [C-010 evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt)) |
| P2 | 4 | Cloud-preview authority, Rust request-price/concurrency defects, and historical trusted-origin control anomaly ([C-004 evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt); [C-011 evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt); [C-012 evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt); [C-001 evidence](evidence/2026-08-23-C-001-auth-origin.txt)) |
| P3 | 1 | Transaction-helper encoding correctness issue without a demonstrated authorization bypass ([C-007 evidence](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt)) |
| Observations | 2 | Historical/public-branch credential hygiene requiring owner-side revocation and audit confirmation ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt)) |

### Immediate recommendations

1. Remove secrets and privileged executables from all PR-triggered jobs. Build untrusted code without credentials; deploy only a reviewed, immutable artifact from a clean base-controlled workflow. ([GitHub evidence](evidence/2026-08-23-github-controls.txt))
2. Scope-confirm and rotate the C-002, C-004, and C-005 authorities after preserving audit evidence. For C-008, first confirm live STS/environment reachability and rotate any implicated release authority only if exposure is established. Separate preview, production, signing, storage, and financial keys by account and purpose. ([C-002/C-004 evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt); [C-005 evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt); [C-008 evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))
3. Protect release tags, bind every release to a reviewed protected-branch commit, and require independent protected-environment approval with self-review disabled. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))
4. Treat wallet release signing and update metadata as separate trust roots. Add append-only/transparency monitoring and client-side provenance checks. ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))
5. Decide and document whether delegated token limits are hard loss caps across allowance-backed calls; preserve unlimited, deny-all, and bounded states in wallet inventory. ([C-003 evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [C-009 evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))
6. Make MPP streaming authorization client-metered and finitely capped; refuse ordinary/scheduled settlement above durable consumed value, and make voucher advancement plus per-request cost reservation one atomic success condition. ([C-010 evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt); [C-011 evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt); [C-012 evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))
7. Confirm ownership and audit history for every SaaS-bound `tempo.xyz` origin, beginning with `auth.tempo.xyz`, and revoke the two repository credential observations without testing the public values. ([auth timeline](evidence/2026-08-23-C-001-auth-origin.txt); [secret-scan evidence](evidence/2026-08-23-public-repository-secret-scan.txt))

## October 31, 2026 upstream mitigation follow-up

This follow-up compares public upstream source and release metadata with the exact August baselines. “Fixed in source” means the reviewed code path changed at a pinned upstream revision; “released” means a formal upstream release includes it. Neither label establishes that every production consumer upgraded, that deployed bytecode matches source, or that a private control was absent. The original severity and PoC statements below describe the August assessment, not a fresh exploit validation. ([CI/release evidence](evidence/2026-10-31-upstream-ci-release.txt); [protocol/wallet evidence](evidence/2026-10-31-upstream-protocol-wallet.txt); [MPP evidence](evidence/2026-10-31-upstream-mpp.txt))

| Finding | Public upstream status on October 31 | Remaining question |
| --- | --- | --- |
| C-005 | Partial: [tip.bot PR #83](https://github.com/tempoxyz/tip.bot/pull/83) gates privileged workflows on current organization membership, closing the visible non-member collaborator route; authorized member PR code still reaches the preview's mainnet-named fee-payer key. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) | Key segregation, rotation, funded use, and private approvals remain owner-only. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) |
| C-002 | Visible PR-code-to-Cloudflare-token boundary remains at tempo-apps `c636175`; [PR #1244](https://github.com/tempoxyz/tempo-apps/pull/1244) added secure-runner/scanning controls. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) | Token scope and actual runner enforcement remain private. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) |
| C-006 | Partial release hardening: [PR #7341](https://github.com/tempoxyz/tempo/pull/7341) added an R2 upload environment, but direct `tempo/v*.*.*` tag-triggered release and Docker paths lack a visible reviewed-branch ancestry check; stronger-gate [PR #8798](https://github.com/tempoxyz/tempo/pull/8798) remains open. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) | Private tag/environment rules and approvals remain unknown. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) |
| C-008 | Visible wallet-cli PR/release-environment boundary remains; [PR #76](https://github.com/tempoxyz/wallet-cli/pull/76) added security tooling and [PR #122](https://github.com/tempoxyz/wallet-cli/pull/122) added versioned R2 overwrite checks. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) | Live STS, signing reach, environment controls, and client uptake remain unverified. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) |
| C-003 | Current Tempo source still composes ZonePortal allowance-backed deposit pulls with a delegated-limit check that meters the non-allowance path. Open [Tempo PR #8238](https://github.com/tempoxyz/tempo/pull/8238) and [Zones PR #1683](https://github.com/tempoxyz/zones/pull/1683) address a different withdrawal path. ([evidence](evidence/2026-10-31-upstream-protocol-wallet.txt)) | Deployment and intended limit semantics remain owner-side questions. ([evidence](evidence/2026-10-31-upstream-protocol-wallet.txt)) |
| C-010 | Partial: [mppx PR #1070](https://github.com/wevm/mppx/pull/1070), released in mppx@0.14.0, limits ordinary/scheduled SDK settlement to recorded spend. [mpp-rs PR #525](https://github.com/tempoxyz/mpp-rs/pull/525) extends optional caps to restored channels. Direct payee/operator settlement can still exercise signed headroom under current native source. ([evidence](evidence/2026-10-31-upstream-mpp.txt)) | Deployed reserve identity, payee behavior, and consumer caps remain unverified. ([evidence](evidence/2026-10-31-upstream-mpp.txt)) |
| C-009 | Fixed in source and released by [wallet-cli PR #154](https://github.com/tempoxyz/wallet-cli/pull/154), [accounts PR #846](https://github.com/tempoxyz/accounts/pull/846), and wallet-cli v0.12.1; output now distinguishes unrestricted, empty, bounded, and ambiguous legacy states. ([evidence](evidence/2026-10-31-upstream-protocol-wallet.txt)) | Live on-chain policy reconciliation and installed-version uptake remain unverified. ([evidence](evidence/2026-10-31-upstream-protocol-wallet.txt)) |
| C-004 | Visible accounts PR-build-to-Cloudflare-token path remains; [PR #754](https://github.com/tempoxyz/accounts/pull/754) added runner/scanning controls. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) | Token scope and private environment controls remain unknown. ([evidence](evidence/2026-10-31-upstream-ci-release.txt)) |
| C-012 | Fixed in source by [mpp-rs PR #416](https://github.com/tempoxyz/mpp-rs/pull/416) and released in v0.13.0: multi-fetch deducts the server's 10,000-unit response price before content delivery and rejects underpayment. ([evidence](evidence/2026-10-31-upstream-mpp.txt)) | Older or copied integrations and production adoption were not inventoried. ([evidence](evidence/2026-10-31-upstream-mpp.txt)) |
| C-011 | Fixed in source by [mpp-rs PR #415](https://github.com/tempoxyz/mpp-rs/pull/415) and released in v0.13.0: stale concurrent vouchers fail inside the atomic update and the request-cost delta is rechecked. ([evidence](evidence/2026-10-31-upstream-mpp.txt)) | Older deployed consumers may still need upgrading. ([evidence](evidence/2026-10-31-upstream-mpp.txt)) |
| C-001 | Historical deployment anomaly remains an owner-audit question; an intermediary 503 from this review environment is not evidence of application status. ([evidence](evidence/2026-10-31-upstream-historical-observations.txt)) | Tempo/Vercel deployment and domain logs are needed to assess historical control. ([evidence](evidence/2026-10-31-upstream-historical-observations.txt)) |
| C-007 | Fixed on tempo-std master by [PR #139](https://github.com/tempoxyz/tempo-std/pull/139) with RLP and interoperability regressions; latest formal GitHub release v0.1.6 predates the merge. ([evidence](evidence/2026-10-31-upstream-protocol-wallet.txt)) | A subsequent release and downstream adoption were not confirmed. ([evidence](evidence/2026-10-31-upstream-protocol-wallet.txt)) |

The original recommendation for an atomic voucher advance and price debit is implemented in the reviewed mpp-rs paths; operators should confirm they use v0.13.0 or newer rather than treating the August C-011/C-012 PoCs as current for upgraded code. For C-010, limiting SDK settlement to recorded spend reduces cooperative overcapture, while preventing a malicious payee from collecting signed but undelivered headroom still requires a client-enforced finite risk window and an explicit trust model for signed vouchers. ([MPP follow-up](evidence/2026-10-31-upstream-mpp.txt))

For CI, runner/scanner additions and membership gates reduce particular entry routes but do not by themselves remove the remaining PR-controlled execution next to credentials. Review C-002, C-004, C-005, and C-008 with the current actor, secret, STS, and environment policies before treating them as closed. C-006's release-preparation ancestry check does not gate arbitrary matching tag pushes in the observed release and Docker workflows. ([CI/release follow-up](evidence/2026-10-31-upstream-ci-release.txt))

The two repository-secret observations also changed unevenly: [changelogs PR #115](https://github.com/tempoxyz/changelogs/pull/115) removed `bot/.env` from the default branch, but the path remains at 18 non-default branch heads; the `zygis/pprof` branch ref was removed, but its historical commit is still retrievable. Neither observation establishes credential validity or revocation. ([evidence](evidence/2026-10-31-upstream-historical-observations.txt))

## 1. Engagement overview

### 1.1 Objectives

The assessment sought to satisfy the following bounded objectives. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

- create a coherent map of public services, source, build, release, wallet, protocol, communications, and third-party trust boundaries ([perimeter evidence](evidence/2026-08-23-public-perimeter.txt); [GitHub evidence](evidence/2026-08-23-github-controls.txt));
- identify ways a criminal could convert a compromised insider or third party into financial theft or durable control ([evidence](evidence/2026-08-25-report-claim-audit.txt));
- determine where outside contributors can submit code and where trusted writers' PRs cross privileged boundaries ([evidence](evidence/2026-08-23-github-controls.txt));
- run complete available smart-contract/native-contract suites and add focused tests for uncovered security invariants ([evidence](evidence/2026-08-23-contract-test-baseline.txt));
- review MPP agent and streaming-payment state machines for server-selected authorization, partial delivery, settlement, retry, cancellation, and atomic-swap-style free options ([C-010 evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt); [C-011 evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt); [C-012 evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt));
- scan every public repository's reachable history for credential-shaped material ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt)); and
- preserve reproducible, sanitized evidence without touching real credentials or changing production state ([evidence](evidence/2026-08-25-report-claim-audit.txt)).

### 1.2 Scope

Included scope was limited to the following public or locally reproducible surfaces. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

- `tempo.xyz` hostnames found in official DNS, certificates, documentation, or public source as observed August 23, 2026 ([evidence](evidence/2026-08-23-public-perimeter.txt));
- all repositories publicly listed by the `tempoxyz` GitHub organization in the August 23, 2026 inventory ([evidence](evidence/2026-08-23-github-controls.txt));
- public GitHub Actions, branch/ruleset metadata, environments, releases, packages, and contributor entrypoints observed August 23, 2026 ([evidence](evidence/2026-08-23-github-controls.txt));
- public indications of Google Workspace/Gmail, Slack, VPN/SSO, support, cloud, observability, registry, and DevOps dependencies observed August 23, 2026 ([evidence](evidence/2026-08-23-comms-devops-exposure.txt));
- Tempo, Zones, and `tempo-std` source and tests at the pinned revisions named below ([evidence](evidence/2026-08-23-contract-test-baseline.txt));
- MPP specifications, TypeScript/Rust/Go/Python SDKs, conformance tooling, wallet/agent integrations, and the TIP-1034 native address/interface pinned August 24 and passively refreshed August 25, 2026 ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt)); and
- passive DNS/TLS/HTTP and conservative common-TCP-port service identification on confirmed Tempo hostnames on August 23, 2026 ([evidence](evidence/2026-08-23-public-perimeter.txt)).

The following activities and systems were excluded. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

- private repositories, internal networks, employee or customer accounts, and non-public organization settings ([evidence](evidence/2026-08-25-report-claim-audit.txt));
- password reset, account recovery, MFA, SSO, VPN, Slack, Gmail, support, or OAuth authentication testing ([evidence](evidence/2026-08-23-comms-devops-exposure.txt));
- credential validation, phishing, employee enumeration, social engineering, or personal-data collection ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt));
- exploit delivery, destructive testing, denial of service, fuzzing against production, transaction submission, or cloud/GitHub state changes ([evidence](evidence/2026-08-25-report-claim-audit.txt));
- live MPP payments, deceptive agent interaction, wallet/key creation, or testing a third-party paid service ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt)); and
- scanning unrelated infrastructure belonging to Cloudflare, Vercel, Google, Slack, AWS, Grafana, Bridge, Stripe, Privy, or other partners ([perimeter evidence](evidence/2026-08-23-public-perimeter.txt); [comms evidence](evidence/2026-08-23-comms-devops-exposure.txt)).

### 1.3 Method and evidence standard

The work combined public GitHub API/source review, full-history local mirrors, non-verifying TruffleHog scans, DNS/TLS/HTTP observation, bounded service identification, dependency/workflow tracing, payment-state modeling, passive JSON-RPC reads, and local execution of checked-in and focused security tests. ([report audit](evidence/2026-08-25-report-claim-audit.txt); [GitHub evidence](evidence/2026-08-23-github-controls.txt); [contract evidence](evidence/2026-08-23-contract-test-baseline.txt))

Evidence is labeled using the following assessment taxonomy. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

- **Executed local PoC:** a harmless test using dummy values or in-memory/local state that reproduces the relevant boundary. ([evidence](evidence/2026-08-25-report-claim-audit.txt))
- **Static configuration proof:** immutable source/configuration establishes a trigger, permission, or data flow; no production trigger was invoked. ([evidence](evidence/2026-08-25-report-claim-audit.txt))
- **Live read-only observation:** an ordinary public response or public API record was observed without authentication or mutation. ([evidence](evidence/2026-08-25-report-claim-audit.txt))
- **Owner confirmation required:** the decisive fact is private and cannot be established responsibly from outside. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

Priority is an assessment workflow label. Severity describes plausible consequence under the prerequisites stated in each finding; it is not a claim that those prerequisites currently hold. “Potentially Critical” therefore means that a private scope/key-reuse fact could raise impact, not that Critical impact was demonstrated. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

### 1.4 Limitations

This is not an internal penetration test. Public GitHub metadata does not reveal organization-wide rules, private repositories, secret values/scopes, App installation permissions, deploy keys, enterprise policy, audit alerts, or credential rotation status. Shared CDN addresses and open edge ports do not identify an origin server. Public DNS cannot establish internal VPN topology or identity-provider enforcement. Local green tests do not prove deployed bytecode, privileged roles, cross-system safety, MPP service population, agent budgets, or whether a candidate is already privately known. The report records these unknowns instead of inferring absent controls. ([report audit](evidence/2026-08-25-report-claim-audit.txt); [GitHub evidence](evidence/2026-08-23-github-controls.txt); [perimeter evidence](evidence/2026-08-23-public-perimeter.txt))

## 2. Attack-surface assessment

### 2.1 Crown jewels and financially relevant authority

| Crown jewel | Theft or control consequence | High-leverage entrypoint |
| --- | --- | --- |
| User root keys, passkeys, and delegated access keys | Transfers, approvals, contract calls, persistent delegated authority | Auth/wallet origin, SDK, signed client update, dependency, endpoint, or local workstation compromise ([wallet evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt); [public origin evidence](evidence/2026-08-23-public-perimeter.txt)) |
| TIP-20 issuer and TIP-403 policy roles | Mint, burn, freeze, pause, or compliance-policy control | Administrative key, privileged client, governance, or recovery compromise ([source map](evidence/2026-08-25-report-claim-audit.txt); [test baseline](evidence/2026-08-23-contract-test-baseline.txt)) |
| DEX, fee-conversion, Zone, reserve, and application balances | Withdrawal, redirection, or concealed reconciliation loss | Contract flaw, stale allowance, signing key, integration credential, or misleading data plane ([source map](evidence/2026-08-25-report-claim-audit.txt); [C-003 evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [C-010 evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt)) |
| Fee-payer and raffle escrow keys | Sponsored transactions or application-held payout authority | Secret-bearing CI, Worker deployment, or application compromise ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt)) |
| Release signing, registry, R2, and update metadata | Trusted malicious node/wallet distribution | Maintainer/App/tag compromise or PR-to-release automation ([C-006 evidence](evidence/2026-08-23-C-006-release-tag-control.txt); [C-008 evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt)) |
| GitHub, cloud, DNS, and SaaS administration | Source, deployment, trusted-origin, and recovery control | Human identity, GitHub App, CI/OIDC, provider account, or support compromise ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [comms evidence](evidence/2026-08-23-comms-devops-exposure.txt)) |
| Validator identities and threshold shares | Consensus participation, finality, and incident response | Operator, host, release, backup, or recovery compromise ([source map](evidence/2026-08-25-report-claim-audit.txt); [test baseline](evidence/2026-08-23-contract-test-baseline.txt)) |

### 2.2 Publicly facing services

The assessment started from source/documentation hostnames, rejected wildcard-only discoveries, and then used ordinary DNS, TLS, HTTP, and a small common-TCP-port set on confirmed Tempo names. Results identify public service fronts, not origin infrastructure. A CDN's `80/443` response—or any other shared-edge response—must not be interpreted as an exposed Tempo origin daemon. ([evidence](evidence/2026-08-23-public-perimeter.txt))

The principal public trust boundaries observed in the August 23, 2026 snapshot were as follows. ([evidence](evidence/2026-08-23-public-perimeter.txt))

| Service family | Representative hosts | Security role |
| --- | --- | --- |
| Brand, documentation, and integration guidance | `tempo.xyz`, `accounts.tempo.xyz`, `docs.tempo.xyz`, `mpp.tempo.xyz` | Installation, SDK guidance, OAuth/wallet integration expectations, and user trust ([evidence](evidence/2026-08-23-public-perimeter.txt)) |
| Authorization and wallet | `auth.tempo.xyz`, `wallet.tempo.xyz`, `keys.tempo.xyz` | Transaction signing, access-key creation/revocation, WebAuthn/key management, and wallet approval display ([evidence](evidence/2026-08-23-public-perimeter.txt)) |
| Transaction and data plane | `rpc.tempo.xyz`, `indexer.tempo.xyz`, `explore.tempo.xyz`, `contracts.tempo.xyz`, `tokenlist.tempo.xyz` | Transaction submission, canonical/read views, decoded transaction presentation, source verification, and asset identity ([evidence](evidence/2026-08-23-public-perimeter.txt)) |
| Sponsorship and application services | `sponsor.tempo.xyz` and application-specific Tempo Apps routes | Fee-payer authority, transaction preparation, and user-facing application behavior ([evidence](evidence/2026-08-23-public-perimeter.txt)) |
| Software and node distribution | `cli.tempo.xyz`, `snapshots.tempo.xyz`, GitHub Releases, GHCR, Docker Hub, language registries | Wallet extension, node snapshot, binary, container, and package trust ([perimeter evidence](evidence/2026-08-23-public-perimeter.txt); [GitHub evidence](evidence/2026-08-23-github-controls.txt)) |
| Test and development environments | Moderato RPC/explorer/faucet/sponsor plus source-referenced preview/dev names | Lower-assurance configurations that can still share CI, cloud, or identity boundaries ([evidence](evidence/2026-08-23-public-perimeter.txt)) |

The August 23 refresh checked all 96 source-indexed names. It found no general `*.tempo.xyz` address wildcard, but it did confirm `*.mpp.tempo.xyz`; an MPP name resolving to the shared Cloudflare edge is therefore not independent proof that the named integration exists. Public edges serving Tempo hostnames were principally Cloudflare and Vercel, with `rustdocs.tempo.xyz` on GitHub Pages. No Tempo origin was discovered. A bounded nmap sample of `tempo`, `auth`, `wallet`, `rpc`, and `rustdocs` showed only TCP 80/443 open and 22/8545 filtered on the sampled shared edges. This is provider-edge characterization, not an origin-port finding. ([evidence](evidence/2026-08-23-public-perimeter.txt))

On August 23, root responses included `200` for the canonical site, auth, wallet, explorer, console, snapshots, status, and Rust docs; API-style `400`, `401`, `402`, `404`, or `405` responses occurred on RPC, TIDX, indexer, keys/CLI, and MCP roots. A status code alone is not treated as a vulnerability. The exact DNS/TLS/HTTP/nmap transcript is linked in [public-perimeter evidence](evidence/2026-08-23-public-perimeter.txt); the broader source-derived inventory remains in [`SURFACE.md`](SURFACE.md) and [`recon/2026-08-21-source-referenced-hosts.tsv`](recon/2026-08-21-source-referenced-hosts.tsv).

### 2.3 Communications, identity, support, and remote access

Public evidence collected August 23 identifies Google-hosted email, Slack application/automation use, GitHub as the primary engineering identity boundary, Cloudflare and Vercel deployment surfaces, and additional AWS/OIDC, registry, R2, Grafana, support, and partner integration boundaries. These create high-value compromise and recovery paths even when they do not directly hold funds. ([evidence](evidence/2026-08-23-comms-devops-exposure.txt))

| Boundary | Publicly established exposure | Financially relevant abuse path | Private control status |
| --- | --- | --- | --- |
| Google Workspace/Gmail | Complete Google MX set; SPF authorizes Google and Mailgun; DMARC rejects for the organizational domain and subdomains | Executive/developer mailbox takeover, OAuth consent abuse, password-reset interception, invoice/payment diversion | MFA, hardware keys, session policy, forwarding alerts, admin separation unknown ([evidence](evidence/2026-08-23-comms-devops-exposure.txt)) |
| Slack | `tip.bot` Slack app credentials/events plus CI notification/integration references | Compromise bot/app signing secrets, impersonate trusted operational context, steal tokens, suppress or redirect response | Enterprise Grid, SSO, retention, app allowlisting, token rotation unknown ([evidence](evidence/2026-08-23-comms-devops-exposure.txt)) |
| Tailscale / Zero Trust | August 23 domain-verification record and source-supported Tailscale design references; Cloudflare Dashboard SSO is separately domain-verified | A stolen identity/session could bridge into admin, cloud, runner, or trusted-CIDR paths if deployed policy is weak | Workforce enforcement, device posture, IdP binding, ACLs, split tunneling, break-glass controls unknown ([evidence](evidence/2026-08-23-comms-devops-exposure.txt)) |
| GitHub | Public organization, repositories, Actions, Apps/tokens, environments, releases, packages, and OIDC trust into an external GitHub-App STS | Source/release compromise, CI secret access, short-lived token minting, persistence through Apps or automation | Enterprise policy, MFA, audit streaming, STS/App ownership, deploy-key inventory unknown ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [comms evidence](evidence/2026-08-23-comms-devops-exposure.txt)) |
| Support and recovery | Public security/support channels and repository surfaces | Social-engineer recovery, suppress reports, redirect domain/account recovery | Staffing, identity verification, escalation and dual control unknown ([evidence](evidence/2026-08-23-comms-devops-exposure.txt)) |
| Cloud/DevOps | Cloudflare/DNS/R2, Vercel, AWS and GCP OIDC, third-party Depot runners, GHCR/Docker Hub, npm/crates/PyPI/Go, Grafana, Better Stack | Deploy malicious trusted-origin code, publish updates, alter telemetry, mint temporary authority, or create persistence | Account separation, IP restrictions, trust policies, token scopes, approval and recovery policy unknown ([evidence](evidence/2026-08-23-comms-devops-exposure.txt)) |

Source and public responses observed August 23 make two additional trust distinctions important. First, the GitHub Actions chain can exchange GitHub OIDC assertions with the externally hosted `gh-sts.tehq.net` service to mint short-lived GitHub App tokens; expanded use was observed in source commits authored August 21. Short-lived tokens reduce stored-secret exposure but make the STS, its policy repository, the App installation, and OIDC subject binding a joined release-security boundary. The third-party host was not scanned. Second, `wallet.tempo.xyz` exposed a public OIDC issuer for product verified-email tokens; this is not evidence that the same service is Tempo's workforce IdP. ([evidence](evidence/2026-08-23-comms-devops-exposure.txt))

Slack exposure observed in August 23 source is broader than a notification webhook. Public source describes a customer-facing Tipbot OAuth app with message/channel/group/user read scopes, interactive and slash-command callbacks, and chat-write authority. GitHub workflows can create, update, or delete preview Slack apps; a shared action rotates a Slack configuration token and writes the successor into GitHub Actions secrets. Separately, core benchmark automation posts through a bot and documentation feedback is forwarded to Slack after source-level secret redaction. The Tipbot manifest does not prove installation in Tempo's internal workspace, while the domain-verification record and separate automation establish an operational Slack relationship. ([evidence](evidence/2026-08-23-comms-devops-exposure.txt))

Tailscale-aware source reviewed August 23 provides two design-review leads: TIDX documents the Tailscale CGNAT range as an optional trusted administrative CIDR, and Tempo's contract verifier accepts `https://*.ts.net` origins and skips its application rate limiter for the allowlisted origin class. No evidence establishes that the example CIDR is deployed, every `ts.net` name is Tempo-controlled, or a private service is reachable. No Origin-spoofing request, rate-limit bypass, tailnet enumeration, or load test was attempted. ([evidence](evidence/2026-08-23-comms-devops-exposure.txt))

The August 23 public mail posture had a strong DMARC `p=reject; sp=reject` control. No public CAA, DNSSEC DS, MTA-STS, or SMTP TLS-reporting record was returned; DKIM was left unknown because no selector was guessed. These are hardening observations, not evidence of mailbox compromise. Tailscale domain verification plus trusted-CIDR/`*.ts.net` source references establish a relationship and review leads, not organization-wide employee VPN enforcement or reachable private services. Better Stack served the public status page during the snapshot. No login, tenant enumeration, recovery-flow probing, OAuth authorization, mailbox lookup, or personal identity collection was performed. The evidence and negative findings are recorded in [communications and DevOps exposure](evidence/2026-08-23-comms-devops-exposure.txt).

### 2.4 GitHub organization and pull-request entrypoints

Tempo's public GitHub organization was the widest observable engineering control plane in the August 23 snapshot. Public repositories generally allow an outside user to fork and propose a pull request unless a repository is archived or otherwise disables the path. That does **not** mean ordinary fork code receives repository secrets: GitHub's normal model withholds them. The high-impact candidates in this report instead require a compromised or malicious same-repository writer/member/collaborator, a privileged automation identity, or a tag-capable identity. ([evidence](evidence/2026-08-23-github-controls.txt))

The August 23 public inventory contained **68 repositories: 52 originals and 16 forks**. Fifteen were archived, leaving 53 nonarchived repositories and 48 active originals. An outside researcher therefore has a broad ordinary fork/PR proposal surface, but not the trusted association required by C-002/C-004/C-005/C-008. GitHub reported 67 default branches as protected; `txgen/main` was the only active default branch reported unprotected. `tip.bot/main` returned no ruleset list but was separately reported protected with five visible required checks. ([evidence](evidence/2026-08-23-github-controls.txt))

The review distinguishes the following paths. ([evidence](evidence/2026-08-23-github-controls.txt))

- Outside contributor → fork PR → untrusted CI, with ordinary repository secrets withheld. ([evidence](evidence/2026-08-23-github-controls.txt))
- Trusted or compromised writer → same-repository PR → member-gated preview job → PR-controlled checkout, install, or tool resolution → cloud or application-held financial authority. ([C-002/C-004 evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt); [C-005 evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))
- Trusted or compromised writer → same-repository wallet PR → PR-controlled lifecycle code in a shared release environment; signing and publication reach remain unconfirmed. ([C-008 evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))
- Writer, App, or deploy key → matching release tag → artifact build, sign, or publish path → official release, container, binary, or wallet-update trust. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))

The August 23 ruleset enumeration across all 53 nonarchived repositories returned 64 records—62 active and two disabled—all branch-targeted and **zero tag-targeted**. Fifty-one repositories inherited organization ruleset `12500570`, which blocked direct default-branch pushes and enforced squash/rebase merge modes; `tip.bot` and `txgen` returned no ruleset list. Tempo's repository rules additionally exposed required review/check controls for important branches. These are meaningful merge controls, but they do not protect a secret-bearing job that intentionally executes a trusted writer's unmerged PR, nor do branch rules protect tags. ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [release-tag evidence](evidence/2026-08-23-C-006-release-tag-control.txt))

The August 23 default branches contained 446 workflow files across 52 repositories; the 48 active originals contained 203 files across 34 repositories. Trigger and authority counts are review leads, not vulnerability counts. ([evidence](evidence/2026-08-23-github-controls.txt))

| Workflow characteristic | All public default branches | Active originals |
| --- | ---: | ---: |
| `pull_request` | 187 files / 49 repositories | 99 files ([evidence](evidence/2026-08-23-github-controls.txt)) |
| `pull_request_target` | 13 / 8 | 11 / 7 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| `issue_comment` | 9 / 7 | 9 / 7 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| `workflow_run` | 10 / 10 | 1 / 1 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| `workflow_call` | 56 / 25 | 31 / 11 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| Tag-filtered push | 39 / 21 | 14 / 10 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| Secrets-context reference | 232 / 47 | 98 / 30 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| Declared write permission | 235 / 45 | 114 / 30 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| `id-token: write` | 83 / 31 | 47 / 17 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| Environment declaration | 39 / 25 | 27 / 14 ([evidence](evidence/2026-08-23-github-controls.txt)) |
| Literal self-hosted runner | 3 files / 2 repositories | 3 / 2 ([evidence](evidence/2026-08-23-github-controls.txt)) |

In the latest successful detailed sample collected August 21, 40 environments were returned across 12 of 18 queried financially sensitive repositories. Only `tempo-go/releases` exposed required reviewers; self-review was still allowed and no sampled environment exposed a wait timer. Tempo `release`/`release-pr` exposed only branch policies, and wallet-cli/wallet-rs `release` exposed no reviewer rule in that snapshot. The August 23 detail refresh hit GitHub's public API rate limit, so private or subsequently changed protection remains possible. ([evidence](evidence/2026-08-23-github-controls.txt))

Seventeen default branches contained a recognized CODEOWNERS file on August 23, but only four active originals did: `mpp-rs`, `tempo`, `tempo-std`, and `zones`. Presence does not prove that code-owner approval is required. Literal self-hosted selections occurred in two Tempo benchmark workflows and one Zones benchmark workflow. Tempo's issue-comment dispatcher checked organization membership before calling its benchmark path; this is an intentional insider boundary, while runner ephemerality, network reach, and workspace/cache isolation remain private. ([evidence](evidence/2026-08-23-github-controls.txt))

Source observed August 23 had moved Tempo, wallet-cli, and wallet-rs release automation from stored GitHub App credentials toward GitHub OIDC and the external App-token STS. This reduces long-lived secret material but does not, by itself, require an approved commit, protect a release tag, or prevent PR-controlled lifecycle code from influencing a later token consumer. Shared actions, CODEOWNERS, self-hosted/third-party runner references, package publication, and the exact trigger inventory are enumerated in the linked evidence. ([evidence](evidence/2026-08-23-github-controls.txt))

The August 23 repository counts, PR entrypoints, sampled rulesets/protections, CODEOWNERS, environments, runner references, workflow trigger classes, and release paths are in [GitHub-controls evidence](evidence/2026-08-23-github-controls.txt). Finding C-006's specific tag/release boundary is in [release-tag evidence](evidence/2026-08-23-C-006-release-tag-control.txt).

### 2.5 Smart contracts, native contracts, and wallet authorization

The tested protocol surface includes Account Keychain authorization, TIP-20/TIP-403, stablecoin DEX and fee conversion, fee management, nonce handling, signatures, Zone Factory/Portal integration, and storage layouts. The following totals apply only to the pinned revisions in the evidence. ([evidence](evidence/2026-08-23-contract-test-baseline.txt))

- Zones: 485 Forge tests and 7 symbolic properties passed; production coverage was 95.78% of lines and 79.58% of branches; ABI and storage-layout comparisons passed. ([evidence](evidence/2026-08-23-contract-test-baseline.txt))
- Tempo native precompiles: 1,088 tests passed with 15 explicitly ignored. ([evidence](evidence/2026-08-23-contract-test-baseline.txt))
- `tempo-revm`: 197 tests passed. ([evidence](evidence/2026-08-23-contract-test-baseline.txt))
- `tempo-std`: its three checked-in tests passed, but they executed none of 538 transaction-helper lines or 92 helper functions. ([evidence](evidence/2026-08-23-contract-test-baseline.txt))

Focused review found two gaps that green component suites missed: allowance-backed Zone deposits can compose with delegated call scopes outside the delegated token limit (C-003), and the Solidity transaction helper changes the RLP type of a key-authorization list (C-007). A third wallet issue (C-009) is a cross-repository semantic failure: omitted/unlimited policy is collapsed into the same local representation as explicit-empty/deny-all policy and displayed as zero/non-unlimited. ([C-003 evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [C-007 evidence](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt); [C-009 evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))

The executable baselines were pinned before the final report date, so applicability at the August 23 heads was checked separately. Tempo's relevant precompile, transaction, handler, and embedded-Zone trees were byte-identical at head `d656ef5581505b59f1611b358e611f5a602d399e`; the relevant Zones Portal/runtime trees were byte-identical at head `7e38642cdd5a1500784fd15cf30eda5366f3350a`; and `tempo-std` remained at the exact tested head. The executed totals are preserved in [contract-test evidence](evidence/2026-08-23-contract-test-baseline.txt), and the dated tree comparison is in [contract-finding freshness evidence](evidence/2026-08-23-contract-finding-freshness.txt).

### 2.6 MPP streaming and agent-payment surface

MPP turns remote HTTP/SSE/WebSocket responses into wallet-signing inputs, so a paid endpoint is both an application-data peer and a financial counterparty. For one session, five cumulative quantities must be reviewed separately—on-chain deposit, payer-signed authorization, delivered/owed value, server-recorded consumption, and on-chain settlement—along with each request's authenticated cost. Plaintext streaming cannot provide perfect trustless fair exchange; MPP pays before delivery and can only bound the provider's option through small client-controlled windows. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

The August 24 pass pinned specifications, SDKs, conformance tools, wallets, agent plugins, examples, and Tempo reserve source. Two local mppx PoCs showed the managed SSE client signing 100 units for a one-unit quote before any application message, then the exported settlement helper submitting 100 from a record whose `spent` value was one. The signature was independently verified and chain I/O was stubbed. A Rust parity PoC generated a valid full-deposit voucher through the streaming helper; the recorded CI-equivalent Rust suite passed 1,160 library tests, 16 integration tests, and 61 executed doctests. That green suite does not establish the economic invariant. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

Passive JSON-RPC reads refreshed August 25 observed the TIP-1034 native marker and expected 900-second close-grace/type-hash interface on mainnet and Moderato; they did not pin deployed bytecode to source. Public source pinned August 24 pays the signed cumulative delta after signature/deposit checks and receives no quote, unit, request, or delivery proof. The pinned OpenClaw plugin locks affected mppx 0.8.15, omits `maxDeposit`, and drains response streams through its agent tool; its standard seven-day access key has a $10 total USDC cap, while custom policies or raw keys can be broader. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

C-010 records the agent-loss candidate. The raw server-controlled voucher boundary was already called out publicly in mppx PR #510 and is not novel. The potentially unreviewed composition is ordinary/scheduled `settle(highestVoucher)` after PR #196 fixed the same high-water overcharge for cooperative close. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

C-012 records the simpler reverse-direction merchant-loss path in mpp-rs: a local full-verifier PoC began with prior authorization fully consumed, authenticated an advertised 10,000-unit page price, then accepted a valid one-unit increment while leaving only one unspent unit. Static source shows the released multi-fetch example returns content after that success without debiting the advertised request price. C-011 separately records a concurrency race: two identical signed vouchers can both satisfy the example's verifier success predicate while durable authorization advances once; the PoC did not execute two HTTP responses. Both affected the August 24 head and published v0.11.0, but production consumers and application-side atomic debits are unknown. No claim is made that Tempo is unaware, and no live payment, agent, or service was exercised. ([C-012 evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt); [C-011 evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))

### 2.7 Public repository secret exposure

All 68 public repositories in the initial snapshot were acquired as full, non-shallow bare mirrors and scanned across reachable history with TruffleHog 3.97.0 verification disabled. The scanner made 201,832 per-repository commit visits and emitted 1,281 unverified matches across 26 repositories; 42 emitted none. No credential was authenticated and zero credentials were confirmed live. ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt))

Manual triage retained two owner-check items: a removed `changelogs` environment file publicly described as non-live but still reachable from 18 non-default branch heads, and a Grafana/Pyroscope credential-shaped value in a public Tempo experiment branch. Neither value is reproduced here or was sent to a provider. See [secret-scan evidence](evidence/2026-08-23-public-repository-secret-scan.txt).

## 3. Findings summary

The status and affected-version fields in sections 3–4 preserve the August 25 assessment; the dated follow-up above is the current public-source comparison. ([baseline](evidence/2026-08-25-report-claim-audit.txt); [follow-up](evidence/2026-10-31-upstream-ci-release.txt))

| ID | Priority | Conditional severity | Status at August assessment | Title | Evidence |
| --- | --- | --- | --- | --- | --- |
| C-005 | P0 | High; potentially Critical | Local mechanism validated; live workflow path observed | Member PR crosses into raffle escrow key boundary | [PoC](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt) |
| C-002 | P0 | High; potentially Critical | Local mechanism validated; public run metadata records an authenticated member-PR upload | Tempo Apps PR code reaches a Cloudflare credential configured for preview and production workflows | [PoC](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt) |
| C-006 | P1 | High; potentially Critical | Source/control validated; legitimate release paths observed | Public controls do not bind release tags to protected-branch review | [Evidence](evidence/2026-08-23-C-006-release-tag-control.txt) |
| C-008 | P1 | High; potentially Critical | August 23 STS/lifecycle shape and dummy-local mechanism validated; signing/publication reach unconfirmed | Wallet PR automation executes in a shared release environment | [PoC](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt) |
| C-003 | P1 | Medium; potentially High | Protocol primitive reproduced; deployment/user intent unresolved | Scoped portal call composes with allowance pulls beyond delegated-limit accounting | [PoC](evidence/2026-08-23-C-003-zone-allowance-poc.txt) |
| C-010 | P1 investigation | High candidate | TypeScript/Rust mechanisms reproduced; native reserve interface observed; public prior art partial | MPP streaming headroom can become payment for undelivered value | [PoC](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt) |
| C-009 | P1 investigation | Medium; potentially High | Output mismatch reproduced; hosted policy unknown | Wallet CLI masks omitted-limit unrestricted authority | [PoC](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt) |
| C-004 | P2 | Medium; High if production-scoped | Local mechanism validated; token scope unresolved | Accounts PR code reaches Cloudflare credential | [PoC](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt) |
| C-012 | P2 investigation | Medium; potentially High | Full verifier PoC reproduced; August 24 and released example affected; production consumers unknown | Rust multi-fetch verifier accepts one-unit vouchers despite an advertised 10,000-unit response price | [PoC](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt) |
| C-011 | P2 investigation | Medium; potentially High | Real signed-voucher race reproduced; August 24 and released code affected; production consumers unknown | Concurrent Rust voucher reuse can satisfy multiple paid-response predicates | [PoC](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt) |
| C-001 | P2 investigation | Undetermined | Analyst-recorded historical observation; current state is rerunnable, historical raw response is not | Historical `auth.tempo.xyz` deployment anomaly | [Timeline](evidence/2026-08-23-C-001-auth-origin.txt) |
| C-007 | P3 | Low / Informational | Serialization mismatch reproduced; consumer unknown | `tempo-std` key-authorization RLP mismatch | [PoC](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt) |

## 4. Detailed findings

### C-005 — Member PR crosses into raffle escrow signing authority

**Priority / severity:** P0 / High, potentially Critical if the exposed preview key is shared with production or holds material funds ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))<br>
**Affected revision:** `tempoxyz/tip.bot` `e0a88f66bd7e1a6073b43f2cb6f3a5426d277318` ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))<br>
**Evidence type:** public workflow/source proof plus executed dummy-local process-boundary PoC ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))<br>
**Evidence:** [2026-08-23-C-005-tipbot-key-boundary-poc.txt](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt)

#### Description and demonstrated impact

A non-draft same-repository PR from an accepted organization association is checked out before merge and runs repository-controlled setup. The preview deployment later supplies a mainnet fee-payer private-key-named value, Slack credentials, and other secrets to PR-influenced tooling. Application source ties the mainnet signing identity to the shared raffle escrow address and payout signatures; it is not only a gas-subsidy key. ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))

The local PoC used literal dummy strings and a fake package-manager executable. It reproduced the workflow's argument/stdin boundary and showed that the repository-selected process receives the full secret payload while preserving the expected command shape. If preview and funded production escrow share that key, a compromised eligible GitHub identity could extract signing authority and direct unauthorized payouts. ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))

#### Preconditions and limits

- Requires a same-repository branch and eligible member/collaborator identity; an ordinary outside fork is insufficient. ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))
- Key equality, rotation, current balance, and production use are private and unproven. ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))
- No PR, workflow, secret, signature, payout, Slack endpoint, or Tempo endpoint was touched. ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))

#### Remediation and detection

Preserve and review PR, runner, OIDC, secret-update, and escrow-signature logs; then rotate the key. Use isolated, minimally funded preview keys. Do not expose any financial key to PR code or its executable search path. Build without secrets, promote an immutable reviewed artifact in a base-controlled job, and require independent protected-environment approval. ([evidence](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt))

### C-002 — Tempo Apps PR code reaches a Cloudflare credential configured in preview and production workflows

**Priority / severity:** P0 / High, potentially Critical depending on the token's private scope and route coverage ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))<br>
**Affected revision:** `tempoxyz/tempo-apps` `5374dff9f01d050be7b9ab8d8d37349cf9506c76` ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))<br>
**Evidence type:** public workflow/run proof plus executed dummy-local executable-resolution PoC ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))<br>
**Evidence:** [2026-08-23-C-002-C-004-wrangler-resolution-poc.txt](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt)

#### Description and demonstrated impact

The pull-request workflow accepts same-repository members/owners/collaborators, executes the PR checkout and build, and then provides a Cloudflare credential to tooling resolved from the PR-influenced workspace. The same named secret is configured in mainline production-deployment jobs, and the public workflow declares no independent GitHub Environment reviewer between unreviewed execution and the credential-bearing preview step; this establishes configuration reuse, not observed production authority. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

The local PoC placed a fake `wrangler` in the workspace, injected only `DUMMY_TEMPO_APPS_TOKEN_NOT_A_SECRET`, and invoked the same local resolution form. The fake executable received the complete value and returned a normal-looking Wrangler version. If the token's private policy permits modification of the configured production resources, an attacker with one eligible compromised GitHub identity could alter sponsor, key-manager, explorer, verifier, or related behavior from a trusted Tempo origin. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

#### Preconditions and limits

- Requires same-repository write influence and the workflow's trusted association. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))
- Cloudflare resource policy, account separation, IP policy, and current rotation are not public. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))
- A successful historical preview upload proves authentication/reachability, not unrestricted account authority, production-resource control, or exploitation. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

#### Remediation and detection

Correlate member PRs with Cloudflare API use, Worker-version uploads, route changes, and sponsor/key-manager anomalies. Rotate the credential, split production credentials per resource/account, isolate previews, and ensure no executable or artifact influenced by unreviewed code runs after credential injection. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

### C-006 — Public controls do not bind release tags to protected-branch review

**Priority / severity:** P1 / High, potentially Critical when mutable artifacts are automatically consumed ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))<br>
**Affected revision:** `tempoxyz/tempo` August 23 reviewed head `d656ef5581505b59f1611b358e611f5a602d399e`; originally reproduced/configuration-pinned at `86ff4deaebfee38bb0b000e648b2b367810265ff` ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))<br>
**Evidence type:** public source/control and successful legitimate-release observations plus local no-publication control model ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))<br>
**Evidence:** [2026-08-23-C-006-release-tag-control.txt](evidence/2026-08-23-C-006-release-tag-control.txt)

#### Description and demonstrated impact

Important branches require review and checks, but the public controls reviewed did not expose a rule binding release tags to commits reachable from reviewed `main`. A `v*.*.*` tag triggers workflows from the tagged commit that build and sign binaries, create a GitHub release, upload to R2, and publish SemVer/mutable container tags. Public environment data did not show an independent reviewer gate; private organization rules or approvals remain unknown. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))

The evidence demonstrates the distinction between branch ancestry and tag reachability locally and ties the actual trigger to successful legitimate Tempo release paths. Unless a private rule or approval blocks it, a writer, GitHub App, deploy key, or release identity able to create a matching tag could point it at unreviewed code and produce official-looking artifacts without merging through protected `main`; whether such an identity can do so is not established by the public controls. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))

#### Preconditions and limits

- Requires a tag-capable write identity; it is not an outside-contributor path. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))
- Private organization rules or downstream deployment approvals may reduce reach. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))
- No tag, release, image, object, signature, or package was created. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))

#### Remediation and detection

Protect immutable release tags; restrict tag creation to a dedicated release identity; reject targets not reachable from a reviewed protected-branch commit; require independent protected-environment approval; and build in base-controlled workflows. Alert on tag creation/deletion/movement and compare release subjects, provenance, R2 objects, and container digest movement to the approved commit. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))

### C-008 — Wallet PR automation executes inside a shared release environment

**Priority / severity:** P1 / High, potentially Critical if signing or publication authority is reachable from the shared environment ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))<br>
**Affected revisions:** August 23 reviewed `wallet-cli` `5a06c07a76c175667507724da4c0b4ac185df048`, `wallet-rs` `7801e796b8239514d7d8544cc1c32bfe4795d810`, and Tempo launcher `d656ef5581505b59f1611b358e611f5a602d399e`; PoC baseline `wallet-cli` `677e52278eaafa4ec356ed9c750446fba320cdfa` ([evidence](evidence/2026-08-23-finding-freshness.txt))<br>
**Evidence type:** public workflow/distribution proof plus executed dummy-local lifecycle/executable-resolution PoC ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))<br>
**Evidence:** [2026-08-23-C-008-wallet-release-boundary-poc.txt](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt); [August 23 source comparison](evidence/2026-08-23-finding-freshness.txt)

#### Description and demonstrated impact

A label-triggered same-repository PR enters a shared named release environment before review, requests a short-lived GitHub App token through GitHub OIDC and an external STS, checks out the unmerged PR, and installs its dependencies/lifecycle code. The requested App policy includes `contents: write` and `pull_requests: write`; later steps introduce the intended token and an Anthropic key. Separate wallet-extension signing and distribution workflows use the same environment name, but public evidence does not establish that their signing or publication authority is available to the PR job. ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))

The PoC used pinned pnpm and a dummy App token. PR-controlled lifecycle code altered later executable resolution; the later fake `git` received the dummy token while preserving the expected push command. This proves execution in the modeled privileged process boundary, not a successful live STS exchange, signing-secret reachability, or publication reach. Comments in the August 23 source state that the replaced stored App-credential wiring was never configured, so the reviewed mechanism is the STS route rather than evidence that the old token path operated. If signing or publication authority is in fact reachable from the PR job, an attacker could attempt to publish a higher-version malicious wallet extension and misuse delegated keys within their actual on-chain authority. ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))

#### Preconditions and limits

- Requires eligible same-repository influence and the relevant label/trigger authority. ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))
- Current environment protection, STS issuance, signing-secret reachability, rotation, client uptake, and user balances are unknown. ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))
- No PR was labeled; no workflow, App token, signing key, R2 object, manifest, or client was touched. ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))

#### Remediation and detection

Separate changelog/PR automation from signing and publication. Never install PR-controlled dependencies in a privileged job. Protect the release environment with independent reviewers, split signing and object-storage credentials, bind manifests to reviewed provenance, and add append-only update transparency. Audit label events, App-token minting, signing-key use, object versions, manifest changes, and client update telemetry. ([evidence](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))

### C-003 — Native ZonePortal allowance composition exceeds delegated token-limit accounting

**Priority / severity:** P1 / Medium, potentially High if users treat the delegated limit as a hard independent loss cap ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))<br>
**Affected/tested revisions:** reproduced on Tempo `86ff4deaebfee38bb0b000e648b2b367810265ff` using source first pinned at `88b5d7720d29655fdf9025bb14ddcd6bba1f645c`, and Zones `acaa6a6734860ecd81d7f01de3c973b068dca2ac`; relevant trees remained byte-identical at the August 23 reviewed Tempo `d656ef5581505b59f1611b358e611f5a602d399e` and Zones `7e38642cdd5a1500784fd15cf30eda5366f3350a` heads ([evidence](evidence/2026-08-23-contract-finding-freshness.txt))<br>
**Evidence type:** executed focused Rust test with dummy addresses and in-memory state ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))<br>
**Evidence:** [2026-08-23-C-003-zone-allowance-poc.txt](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [August 23 source comparison](evidence/2026-08-23-contract-finding-freshness.txt)

#### Description and demonstrated impact

A delegated key may be scoped to the official ZonePortal deposit selector. In the reviewed native primitives, the portal can pull value from a root account's existing TIP-20 allowance while delegated spending-limit enforcement treats allowance-backed `transferFrom` differently from direct delegated spending. The caller chooses the encrypted Zone recipient, so a direct recipient allowlist does not bind that hidden destination. ([PoC](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [pinned source](evidence/2026-08-23-contract-finding-freshness.txt))

The focused T8 test configured a root balance and portal allowance of 1,000 units, a delegated token limit of 1 unit, and only the portal/deposit call scope. Scope validation succeeded; the separately modeled portal `transferFrom` then moved all 1,000 allowance-backed units and left the delegated limit at 1. This proves the native allowance primitive and a modeled pull ceiling of `min(balance, remaining allowance)` for the tested composition; it does not prove a deployed Zone flow or realized loss. ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))

#### Preconditions and limits

- Requires a stolen active delegated key with the call scope, a compatible portal/token, valid recipient data, and a pre-existing allowance/balance. ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))
- The test reproduces the native primitive but not a deployed Zone runtime, transaction, or current mainnet user state. ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))
- The allowance exemption itself is documented; the security question is its composition with delegated scope and user expectations. ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))

#### Remediation and detection

Define whether delegated limits are hard caps. If so, enforce the cap across allowance-backed contract calls or bind token, amount, and Zone recipient in authorization. Wallets should include existing allowances in effective-risk display, prefer exact/one-time approvals, and alert on delegated calls that consume root allowances. ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))

### C-010 — MPP streaming headroom can become payment for undelivered value

**Priority / severity:** P1 investigation / High candidate under a malicious or compromised paid endpoint ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))<br>
**Affected revisions:** mppx `3f73a17eeba9522d90894099635a43d6d2934cf5` and released 0.8.15/0.8.19; mpp-rs `fadc88c044b9f8700b58d275bb659d403b231e07`; mpp-specs `6de3b4d5d13b4a80310bd80e021c02a4126428e2`; Tempo `18c174325061fa07ef577ef3fd59f5a7869bd556`; OpenClaw plugin `4e30d5677145c5e5c4aebd1c7a3d372f072db419` ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))<br>
**Evidence type:** executed local TypeScript/Rust PoCs, existing upstream tests/full suite, static source/spec/prior-art proof, and passive native-interface reads ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))<br>
**Evidence:** [2026-08-24-C-010-mpp-streaming-overcapture-poc.txt](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt)

#### Description and demonstrated impact

MPP authorizes each plaintext streaming window before delivery. That creates an inherent provider-side free option, analogous to a free option in an atomic exchange, which should be limited to one small client-approved window. At the pinned revisions, managed mppx and mpp-rs clients accept a server-provided `requiredCumulative` after deposit and optional-cap checks; the authorization is not derived from locally observed delivered units and price, and the cap is optional. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

The mppx client PoC received no application message, yet the SSE management path constructed and posted a valid cumulative-100 voucher for a one-unit quote in a fully stubbed local run; it constructed the channel-open transaction but did not open a channel. The Rust parity PoC raised a 1,000-unit authorization to a valid 10,000-unit full-deposit voucher. Under the pinned public TIP-1034 source, settlement checks the signed amount rather than price or delivery, while passive reads observed the expected native interface but did not pin deployed bytecode to that source. The mppx settlement helper additionally reproduced `highestVoucher=100`, `spent=1`, and a stubbed chain-submission amount of 100. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

While a channel remains active and nonfinalized, if `A` is its highest enforceable authorization and `X` is delivered/owed value, full exercise would produce total excess `max(0, A-X)`. If `S` is already settled, realized excess is `max(0, S-X)` and remaining collectible exposure is `max(0, A-max(S,X))`; finalization/deletion ends that remaining channel claim. A finite local cap limits one channel, while uncapped server-influenced top-ups can move the authorization toward available balance. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

#### Preconditions and limits

- Requires a malicious/compromised endpoint and its payee/operator settlement capability, plus an automatic session channel funded by the payer. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
- The normal OpenClaw setup key has a seven-day, $10 total USDC cap. Custom policies and supported raw keys can have higher authority. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
- Payer-key compromise is not required, but the agent must select or already trust the paid endpoint. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
- The raw coercible voucher boundary was publicly identified in mppx PR #510. The candidate new composition is ordinary/scheduled high-water settlement after PR #196 fixed high-water cooperative close; public silence is not proof of private unawareness. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
- No distinct machine-token-only FX claim, live agent, paid endpoint, credential, wallet, channel, or state-changing transaction was tested. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

#### Remediation and detection

Require a finite local budget and enforce `newAuthorization <= locallyObservedDeliveredValue + configuredRiskWindow` before each signature. Treat server snapshots and deposit/cumulative hints as untrusted. Refuse ordinary/scheduled settlement above durable consumption; obtain an exact-spend voucher or wait until consumed value catches up. Extend the specification's no-overcapture rule to all settlement paths and add cross-SDK model tests over deposit, authorization, delivered value, spend, and settlement. Alert on disproportionate cumulative jumps/top-ups and settlement that exceeds service-accounting records. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

### C-009 — Wallet CLI masks omitted-limit unrestricted key authority

**Priority / severity:** P1 investigation / Medium, potentially High after local-key compromise ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))<br>
**Affected revisions:** August 23 reviewed wallet-cli `5a06c07a76c175667507724da4c0b4ac185df048` (source-identical for the issue to tested `677e52278eaafa4ec356ed9c750446fba320cdfa`) and August 23 Tempo `d656ef5581505b59f1611b358e611f5a602d399e` ([evidence](evidence/2026-08-23-finding-freshness.txt))<br>
**Evidence type:** executed regression test, complete identity suite, and proof-only patch ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))<br>
**Evidence:** [2026-08-23-C-009-wallet-authority-output-poc.txt](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt); [August 23 regression](evidence/2026-08-23-finding-freshness.txt)

#### Description and demonstrated impact

Tempo's pinned authorization model distinguishes omitted limits/scopes (unlimited/unrestricted) from explicit empty collections (deny all). In the tested Wallet CLI path, store normalization maps a missing limits field to `[]`, while current-key output hardcodes `unlimited: false`, shows zero, and renders a missing unrestricted call scope as an empty list. ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))

A focused run asserting that an omitted limit must be displayed as unlimited failed that test while skipping the other 39. After a proof-only display change, the complete 40-test identity suite and TypeScript compilation passed. That one-line change is not a complete fix because normalization has already collapsed protocol-opposite states. A responder relying on the tested inventory output can materially underestimate a stolen key's authority and delay revocation. ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))

#### Preconditions and limits

- The mismatch does not provide initial access; compromise of a workstation, dependency, insider, or wallet update is still required. ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))
- The private hosted service may inject a finite token limit, and the canonical state may differ from the locally normalized representation; no production authorization request was made. ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))
- The transcript does not establish current approval-UI rendering, default lifetime, administrative status, or private hosted-policy schema. ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))

#### Remediation and detection

Preserve omitted, explicit-empty, and populated states end to end and cross-check canonical on-chain metadata. Make unrestricted authority an explicit escalation; request bounded token/period limits and narrow call scopes by default. Add request-to-approval-to-inventory tests for all three states. Inventory/revoke or reissue affected keys and review their transfer, approval, and contract-call histories. ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))

### C-004 — Accounts PR code reaches a Cloudflare credential

**Priority / severity:** P2 / Medium, High if the token can change production Accounts/auth resources ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))<br>
**Affected revision:** `tempoxyz/accounts` `bff90b590894e074d2cd25e9ee9d5b197813ff33` ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))<br>
**Evidence type:** public workflow/run proof plus executed dummy-local executable-resolution PoC ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))<br>
**Evidence:** [2026-08-23-C-002-C-004-wrangler-resolution-poc.txt](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt)

#### Description and demonstrated impact

The workflow accepts every pull request and executes checked-out install/build code before its deployment action. The privileged credential case demonstrated by the public run and local process-boundary PoC requires a same-repository writer-controlled branch: ordinary fork PRs do not receive repository secrets. In that same-repository case, the action can resolve tooling from the PR-controlled workspace, and the shared PoC shows that local `wrangler` path receiving a dummy token. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

If production Accounts/auth Workers or routes are within the token's private scope, a compromised writer could attempt to deploy a deceptive wallet-connect or authorization flow from a trusted Tempo origin. If the credential is restricted to isolated preview resources, the impact is substantially lower. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

#### Preconditions and limits

- Requires same-repository write influence for the secret-bearing path; an ordinary outside fork is insufficient. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))
- Token scope, account separation, and production relationship are unknown. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))
- No token, PR, workflow, Worker, route, account, or auth flow was accessed. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

#### Remediation and detection

Confirm scope and rotate after preserving logs. Isolate preview credentials/accounts, remove PR-resolved executables from secret-bearing steps, deploy only reviewed immutable artifacts, and require independent environment approval. Review member preview runs against Cloudflare token and deployment history. ([evidence](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt))

### C-012 — Rust multi-fetch verifier accepts one-unit vouchers despite a 10,000-unit advertised price

**Priority / severity:** P2 investigation / Medium, potentially High where protected calls have material cost or resale value ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))<br>
**Affected revisions:** mpp-rs August 24 reviewed head `fadc88c044b9f8700b58d275bb659d403b231e07` and published v0.11.0 commit `e2e27edc17c1f8274bab982f3dc91477fcc01a44` ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))<br>
**Evidence type:** executed full-verifier signed-voucher PoC, pinned head/release source comparison, and specification review ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))<br>
**Evidence:** [2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt)

#### Description and demonstrated impact

The bundled Rust multi-fetch server advertises 10,000 base units per page but configures `min_voucher_delta=0`. The HMAC-authenticated `SessionRequest.amount` reaches `Mpp::verify_session`, yet the voucher branch does not compare voucher growth or available unspent authorization with that request cost. It validates channel/signature/deposit/monotonicity, persists any positive increment, and returns success without charging `spent`. Static source shows that the example releases protected content for every non-management success. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))

The deterministic PoC began at `highest=spent=10,000`, so no old prepaid balance remained. A real locally signed cumulative-10,001 voucher passed the full verifier for an authenticated 10,000-unit price, leaving only one available unit and `spent` unchanged. The test reproduced the example's success predicate; static source supplies the content-release composition. For advertised price `P` and accepted increment `d`, underpayment relative to that price is `P-d`: 9,999 units, or 99.99%, in the bundled configuration. This is an advertised-price shortfall, not proof of the merchant's economic loss or response value. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))

#### Preconditions and limits

- The payer uses its own funded channel and signer; no stolen key, forgery, race, or server compromise is required. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))
- Scope is the bundled fixed-price HTTP example and similar consumers that treat bare `verify_session` success as full payment while minimum delta is below request cost. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))
- The Tempo session draft delegates cost calculation and atomic `spent += cost` to the application. This is an unsafe official integration/API footgun, not evidence that all conforming session implementations are affected. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))
- The reviewed Rust SSE/WebSocket paths atomically debit per event/frame and were not shown affected; current TypeScript integrations were not evaluated for this exact shape. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))
- Production adoption, response value, rate limits, and additional application accounting are unknown. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))
- No live channel, service, credential, payment, or RPC was used. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))

#### Remediation and detection

Make successful fixed-request payment one linearizable operation: persist the higher voucher if needed, derive a server-owned route cost, require enough unspent authorization, increment `spent`, and only then permit delivery. Keep `minVoucherDelta` separate as an anti-flood control. Fix the official example and add valid-but-underpriced voucher tests. Detect response count or advertised charges that exceed voucher growth or durable cost debits. ([evidence](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))

### C-011 — Concurrent Rust voucher reuse returns multiple paid-delivery success predicates

**Priority / severity:** P2 investigation / Medium, potentially High for expensive or resalable protected responses ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))<br>
**Affected revisions:** mpp-rs August 24 reviewed head `fadc88c044b9f8700b58d275bb659d403b231e07` and published v0.11.0 commit `e2e27edc17c1f8274bab982f3dc91477fcc01a44` ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))<br>
**Evidence type:** executed deterministic local race through real verifier/credential/ABI paths and pinned head/release source review ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))<br>
**Evidence:** [2026-08-24-C-011-mpp-rust-voucher-race-poc.txt](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt)

#### Description and demonstrated impact

The Rust session verifier checks a voucher's increment and signature against a loaded channel snapshot, then applies a serialized atomic state transition. Two synchronized requests can validate the same increment against the same old snapshot. The winner advances durable `highest_voucher`; the losing transition notices that state already advanced but returns a successful no-op. Both verifier calls therefore return success receipts. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))

The stronger PoC sent two identically signed local credentials through the actual `Mpp::verify_session` path, including credential parsing and mocked on-chain channel decoding. Both satisfied the non-management-success predicate used by the bundled multi-fetch handler, while durable `highest_voucher` moved from 1,000 to 2,000 once and durable `spent` remained 1,000, so no prior unused authorization remained. The PoC exercised the verifier predicate, not an Axum HTTP request or actual content delivery; static source shows that the bundled handler releases protected content for each such success. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))

For `N` responses of value `P`, one accepted increment `delta`, and prior unused authorization `U = max(0, highest_0-spent_0)`, uncompensated exposure is `max(0, N*P-(U+delta))`. In the revised PoC `highest_0=spent_0=1,000`, so `U=0`; when `delta=P`, the race-only duplicate shortfall is `(N-1)*P`, subject to concurrency and application controls. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))

#### Preconditions and limits

- The payer needs its own funded channel and valid signing key; no signature forgery or victim-key compromise is involved. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))
- This is potential service theft from a merchant, not monetary skimming from an agent. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))
- The affected shape is verification-only HTTP delivery such as the bundled multi-fetch example. The bundled SSE/WebSocket examples use an additional atomic spend debit and were not shown affected. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))
- Production consumers, response value, rate limits, deduplication, and application-side debit behavior are unknown. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))
- No live channel, service, credential, payment, RPC, Axum HTTP delivery, or protected response was used. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))

#### Remediation and detection

Make a stale or losing atomic voucher transition fail verification. Prefer one atomic operation that advances the voucher and reserves/debits the specific request cost, keyed by a stable request identifier. Require exactly one of two barrier-synchronized same-voucher requests to cross the delivery gate in regression tests. Alert when concurrent successful responses share a channel and voucher hash/cumulative amount without corresponding authorization or cost increments. ([evidence](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))

### C-001 — Historical `auth.tempo.xyz` deployment anomaly

**Priority / severity:** P2 investigation / undetermined ([evidence](evidence/2026-08-23-C-001-auth-origin.txt))<br>
**Affected asset:** `auth.tempo.xyz` ([evidence](evidence/2026-08-23-C-001-auth-origin.txt))<br>
**Evidence type:** analyst-recorded historical observations plus later live read-only responses; no exploit PoC because the recorded historical behavior is no longer present ([evidence](evidence/2026-08-23-C-001-auth-origin.txt))<br>
**Evidence:** [2026-08-23-C-001-auth-origin.txt](evidence/2026-08-23-C-001-auth-origin.txt)

#### Description and impact hypothesis

The analyst's August 21 notes record `auth.tempo.xyz` changing from a functional Tempo Auth application to a malformed catch-all redirect containing a different bug-bounty-themed domain string, then returning to a functional Tempo Auth application later that day. Subsequent read-only requests returned the expected transaction-signing and access-key routes. The historical sequence was not preserved in an independently archived capture and cannot be recreated from the current endpoint, so it is an analyst-recorded anomaly rather than independently reproducible proof of a takeover. ([evidence](evidence/2026-08-23-C-001-auth-origin.txt))

If an unauthorized project ever controlled this valid HTTPS authentication origin, it could present a convincing wallet/signing flow, exploit origin allowlists, or solicit access-key authorization. There is no evidence that control was unauthorized, credentials were collected, or users were harmed. The decisive evidence—Vercel project ownership, deployment actors, and domain audit logs—is private. ([evidence](evidence/2026-08-23-C-001-auth-origin.txt))

#### Remediation and detection

Confirm the DNS and Vercel project owner and review deployments/domain changes across the evidence timeline. Review OAuth/origin/CSP/CORS/cookie allowlists and visits to the hostname. If all deployments were authorized, close the item as configuration/research noise; otherwise preserve logs, reclaim the binding, and review adjacent SaaS-bound subdomains. ([evidence](evidence/2026-08-23-C-001-auth-origin.txt))

### C-007 — `tempo-std` key-authorization RLP mismatch

**Priority / severity:** P3 / Low or Informational absent a production consumer ([evidence](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt))<br>
**Affected revision:** `tempoxyz/tempo-std` `c77f1671f7fd01c698f1344c2a5f38f11a7f8384` (still the default-branch head at the August 23 refresh) ([evidence](evidence/2026-08-23-contract-finding-freshness.txt))<br>
**Evidence type:** executed focused Foundry encoding test ([evidence](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt))<br>
**Evidence:** [2026-08-23-C-007-tempo-std-rlp-poc.txt](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt); [August 23 source comparison](evidence/2026-08-23-contract-finding-freshness.txt)

#### Description and demonstrated impact

The Solidity helper wraps a caller-supplied RLP key-authorization list as an RLP string where the canonical Rust transaction implementation expects a list. The focused test passed `c180` and showed the resulting transaction suffix `82 c1 80`: the added `0x82` changes the field type. The original three-test suite did not execute transaction-helper code. ([evidence](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt))

The PoC demonstrates malformed serialization. Canonical decoder-source analysis predicts rejection, inconsistent fixtures, or integration failure—not unauthorized acceptance or fund loss. No affected production consumer or exploitable acceptance differential was established. ([evidence](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt))

#### Remediation and detection

Identify consumers, correct or constrain the helper API, and add cross-language golden vectors against the Rust encoder/decoder for nested and optional fields. Do not elevate the issue without an affected production flow or acceptance differential. ([evidence](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt))

## 5. Repository credential-hygiene observations

### OBS-001 — Removed `changelogs/bot/.env`

The full-history scan found a removed environment file. The public deletion PR states the credentials were not live, but the file remained at 18 non-default public branch heads in the snapshot. Neither value was tested or retained in this report. If a repository credential remained valid during exposure, it could enable source, automation, or release abuse. ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt))

Tempo should confirm revocation/rotation through provider-side records, audit the public-exposure interval, remove the file from all public refs, and ensure push protection covers the relevant formats. ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt))

### OBS-002 — Grafana/Pyroscope credential-shaped value in public branch

A public, unprotected Tempo experiment branch at `e6cd619cee885d081d2d1a41b2a6ff390e593484` contains a Grafana Cloud credential-shaped value associated with profiling. It was not validated or reproduced. If live, its plausible impact is telemetry disclosure/injection, quota abuse, or degraded monitoring—not established source, deployment, signing, or fund authority. ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt))

Tempo should revoke/rotate owner-side without testing the public value, inspect policy scope and audit logs, remove it from all refs, and search adjacent experiments for reuse. ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt))

## 6. Conditional compound attack paths

The table below is an assessment-prioritized set of conditional threat scenarios, not evidence that any end-to-end chain was executed. Each row remains bounded by the prerequisites and owner-confirmation gaps in its linked findings. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

| Initial foothold | Control crossed | Criminal objective | Relevant findings |
| --- | --- | --- | --- |
| Compromised GitHub member/collaborator | Same-repository PR into preview CI | Attempt to extract escrow-signing or Cloudflare authority, subject to private key equality and token scope | [C-005](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt), [C-002/C-004](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt) |
| Compromised wallet repo/automation identity | Label-triggered PR into a shared release environment | Attempt release persistence; signing/publication reach and live delegated-key population remain unconfirmed | [C-008](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt), [C-009](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt) |
| Compromised writer/App/deploy key | Matching release tag without a visible tag rule | Attempt official artifact publication from unreviewed source, subject to private tag and environment controls | [C-006](evidence/2026-08-23-C-006-release-tag-control.txt) |
| Stolen delegated wallet key | Scoped portal call plus pre-existing root allowance | Attempt a pull beyond the delegated-limit accounting primitive; deployed applicability is unknown | [C-003](evidence/2026-08-23-C-003-zone-allowance-poc.txt) |
| Compromised or malicious MPP paid endpoint | Automatic agent session plus payee/operator reserve authority | Obtain active-channel authorization headroom before proportional stream delivery and attempt high-water settlement | [C-010](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt) |
| Dishonest MPP payer | Underpriced or concurrent vouchers into a verification-only content gate | Satisfy protected-response predicates with underpriced or duplicate authorization increments; HTTP delivery was not executed by the PoCs | [C-012](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt), [C-011](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt) |
| Cloud/SaaS deployment compromise | Trusted auth, sponsor, explorer, verifier, or wallet origin | Attempt to misrepresent transaction intent or obtain broader user authorization; no such control was demonstrated | [C-002/C-004](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt), [C-001](evidence/2026-08-23-C-001-auth-origin.txt) |
| Observability credential compromise during another intrusion | Profiling/monitoring data plane | Potential reconnaissance or concealment if the unverified value were live | [OBS-002](evidence/2026-08-23-public-repository-secret-scan.txt) |

The assessment-prioritized Lazarus-style scenario is identity-led: compromise a developer or vendor identity, use an ordinary-looking same-repository PR or release action to approach a CI trust boundary, seek persistence in cloud/release/update infrastructure, and attempt to convert that access into wallet-key or application-fund theft. This is a threat-model judgment, not a measured likelihood or demonstrated chain. ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [communications evidence](evidence/2026-08-23-comms-devops-exposure.txt))

## 7. Remediation roadmap

### 0–7 days

- Privately scope-confirm and rotate the C-002/C-004/C-005 authorities after preserving logs. Confirm C-008 STS/environment reachability first, and rotate any implicated release authority only if exposure is established. ([C-002/C-004](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt); [C-005](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt); [C-008](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))
- Disable or gate secret-bearing PR workflows until untrusted-code separation is complete. ([evidence](evidence/2026-08-23-github-controls.txt))
- Add protected tag rules and alerts; verify every current release tag is immutable and reachable from an approved commit. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))
- Revoke/rotate OBS-001/OBS-002 owner-side without authenticating public values. ([evidence](evidence/2026-08-23-public-repository-secret-scan.txt))
- Confirm `auth.tempo.xyz` project/domain history and inventory all SaaS-bound `tempo.xyz` names. ([evidence](evidence/2026-08-23-C-001-auth-origin.txt))
- Confirm whether C-010's server-selected headroom and ordinary high-water settlement are known/accepted; disable uncapped automatic streaming or default it to a small finite window pending review. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
- Inventory production/copied mpp-rs `verify_session` consumers; ensure underpriced credentials and losing voucher transitions cannot release paid responses (C-012/C-011). ([C-012](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt); [C-011](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt))

### 7–30 days

- Implement build-once/promote-after-review pipelines with clean base-controlled deployers. ([evidence](evidence/2026-08-23-github-controls.txt))
- Separate preview/production accounts, wallet signing/storage, and release identities; reduce token scope and lifetime. ([C-002/C-004](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt); [C-008](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt))
- Require two-person approval for production deployment, release signing, tag creation, DNS/domain binding, and break-glass recovery. ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [comms evidence](evidence/2026-08-23-comms-devops-exposure.txt))
- Preserve wallet policy optionality and make unrestricted delegated authority explicit and accurately observable. ([evidence](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt))
- Decide and test the allowance/delegated-limit security invariant across Zone flows. ([evidence](evidence/2026-08-23-C-003-zone-allowance-poc.txt))
- Make MPP authorization client-metered, bind top-ups to local budget, and prevent ordinary/scheduled settlement from exceeding durable consumed value. ([evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
- Atomically combine MPP voucher advancement, per-request cost reservation, and response identity; add same-voucher concurrency tests. ([C-011](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt); [C-012](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt))

### 30–90 days

- Add organization-wide policy-as-code for workflow triggers, action pinning, permissions, environments, runners, and artifact provenance. ([evidence](evidence/2026-08-23-github-controls.txt))
- Continuously reconcile release subjects, signatures, container digests, R2 object versions, package owners, and client update metadata to reviewed commits. ([evidence](evidence/2026-08-23-C-006-release-tag-control.txt))
- Correlate GitHub, cloud, IdP, email, Slack, signing, DNS, and on-chain audit streams around identity and recovery changes. ([evidence](evidence/2026-08-23-comms-devops-exposure.txt))
- Pin deployed protocol revisions, native bytecode, privileged roles, validator/recovery controls, and cross-system invariants. ([contract evidence](evidence/2026-08-23-contract-test-baseline.txt); [MPP evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
- Add adversarial cross-repository tests for wallet issuance/display, allowance composition, transaction serialization, and MPP deposit/authorization/delivery/spend/settlement invariants. ([C-003](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [C-007](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt); [C-009](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt); [C-010](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

## 8. Evidence index

All linked transcripts and committed fixtures use dummy, local, mocked, redacted, or public read-only material; candidate credential values and production-targeting payloads are excluded. This is additionally checked by manual review and the final-tree evidence gate, not represented as proof that automated secret detection is perfect. ([report audit](evidence/2026-08-25-report-claim-audit.txt); [secret-scan limitations](evidence/2026-08-23-public-repository-secret-scan.txt))

| Evidence file | Type | Supports |
| --- | --- | --- |
| [public perimeter](evidence/2026-08-23-public-perimeter.txt) | Live read-only DNS/TLS/HTTP/common-port observations | Public services, C-001 current state |
| [communications and DevOps exposure](evidence/2026-08-23-comms-devops-exposure.txt) | Public passive evidence | Google/Slack/VPN/SSO/support/cloud boundaries |
| [GitHub controls](evidence/2026-08-23-github-controls.txt) | Public API/source/configuration evidence | Repository/PR/ruleset/environment/runner/release surface |
| [C-001 auth-origin timeline](evidence/2026-08-23-C-001-auth-origin.txt) | Historical/current live read-only observation | C-001 |
| [C-002/C-004 Wrangler resolution](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt) | Executed dummy-local PoC | C-002, C-004 |
| [C-003 Zone allowance](evidence/2026-08-23-C-003-zone-allowance-poc.txt) | Executed in-memory Rust test | C-003 |
| [C-005 tip.bot key boundary](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt) | Executed dummy-local PoC | C-005 |
| [C-006 release-tag control](evidence/2026-08-23-C-006-release-tag-control.txt) | Public config plus local control model | C-006 |
| [C-007 RLP helper](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt) | Executed local Foundry test | C-007 |
| [C-008 wallet release boundary](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt) | Executed dummy-local PoC | C-008 |
| [C-009 wallet authority output](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt) | Executed regression/proof test | C-009 |
| [C-010 MPP streaming overcapture](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt) | Executed local TypeScript/Rust PoCs plus passive native-interface check | C-010 |
| [C-011 Rust voucher race](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt) | Executed deterministic verifier/non-management-predicate race | C-011 |
| [C-012 Rust unit-price bypass](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt) | Executed deterministic full-verifier underpayment PoC | C-012 |
| [August 23 finding freshness](evidence/2026-08-23-finding-freshness.txt) | Dated public source plus same-head local regression | C-006, C-008, C-009 applicability at the reviewed heads |
| [contract test baseline](evidence/2026-08-23-contract-test-baseline.txt) | Complete checked-in suites and focused probes | Protocol/contract assurance |
| [contract-finding freshness](evidence/2026-08-23-contract-finding-freshness.txt) | Current-head Git object/source comparison | C-003, C-007 current applicability |
| [public-repository secret scan](evidence/2026-08-23-public-repository-secret-scan.txt) | Full-history non-verifying scan and manual triage | OBS-001, OBS-002 |

Supporting living documents include `SURFACE.md`, `FINDINGS.md`, `SCOPE.md`, the MPP economic-security audit, and the `recon/` snapshots; the claim gate intentionally requires report claims to link the dated evidence files above rather than relying on those living documents. ([evidence](evidence/2026-08-25-report-claim-audit.txt))

## 9. Final assessment

Tempo's August 23–24 public snapshots show meaningful controls—protected important branches, required checks, a security policy, pinned actions in several paths, artifact checksums/signatures/provenance, and extensive protocol component testing. The retained candidates concentrate where those controls may not compose: protected merge paths coexist with privileged execution of trusted writers' unmerged code; signed release paths coexist with no visible tag-targeted rule; delegated-limit accounting coexists with allowance-backed calls; canonical wallet authority is collapsed in local output; and MPP's off-chain price, authorization, delivery, spend, concurrency, and on-chain settlement ledgers can disagree. ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [contract evidence](evidence/2026-08-23-contract-test-baseline.txt); [MPP evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))

The recommended highest-priority reduction is to make **reviewed immutable provenance** the required input to every cloud deployment, release signature, wallet update, and financial-key operation, then monitor those boundaries as one joined control plane. For streaming payments, the analogous invariant is that only client-observed delivered value plus a small explicit risk window should become an authorization enforceable while the channel remains active. ([GitHub evidence](evidence/2026-08-23-github-controls.txt); [C-010 evidence](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt))
