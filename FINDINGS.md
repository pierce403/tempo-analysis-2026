# Findings Register

Last updated: **2026-08-21 16:48 UTC** \
Visibility: tracked, redacted index; detailed candidate reports remain ignored under `findings/`

## Purpose and handling

This is the continuously maintained index of interesting observations and candidate security findings. It explains how a financially motivated criminal could convert each condition into theft or durable control, while deliberately omitting credential values, exploit payloads, operational instructions, personal attribution, and unsupported claims.

An entry in this file is not necessarily a vulnerability, a deployed exposure, or something unknown to Tempo. Each entry separates:

- **assessment state:** observation, candidate, locally validated, finding, closed;
- **deployment state:** source-only, local-only, live-read-only, deployment-confirmed, unknown;
- **disclosure state:** not ready, ready, authorized, sent, acknowledged, resolved, public;
- **confidence:** mechanism, reachability, deployment, impact, and novelty;
- **rating:** consequence under stated prerequisites, not a claim that those prerequisites currently hold.

No external disclosure, GitHub issue, PR, workflow trigger, credential test, cloud change, package publication, or production transaction is authorized by this register.

## Priority summary

| ID | Priority | Short title | Assessment / deployment | Theft relevance | Next gate |
| --- | --- | --- | --- | --- | --- |
| C-005 | P0 | Member PR crosses into raffle escrow key boundary | Locally validated mechanism; live workflow path observed | Direct signing authority over application-held funds if the exposed key is the funded/shared key | Private owner confirmation and coordinated disclosure |
| C-002 | P0 | Tempo Apps PR code reaches production cloud deploy authority | Locally validated mechanism; authenticated member-PR upload observed | Could modify sponsor, key-manager, explorer, or verifier behavior to redirect or deceive users | Confirm Cloudflare scope/account separation; disclose systemic pattern |
| C-006 | P1 | Release tags bypass protected-branch review | Source/config validated; legitimate release paths observed | Could publish official signed node/container artifacts from unreviewed code | Confirm private tag controls and downstream consumers |
| C-008 | P1 | Wallet PR automation reaches release trust root | Dummy-local mechanism; release capability historically observed | Could publish a trusted wallet update that steals or misuses local access keys | Confirm current secret placement and trigger semantics; disclose with C-006 |
| C-003 | P1 | Scoped key can spend pre-existing ZonePortal allowance beyond its limit | Protocol primitive locally reproduced; deployment/user intent unresolved | A compromised delegated key could move more TIP-20 value than the displayed key budget | Confirm deployed portal state and intended wallet security model |
| C-004 | P2 | Accounts PR code reaches Cloudflare credential | Dummy-local mechanism; member-preview route observed | Could alter an auth/account Worker if the token reaches production resources | Establish token scope and production relationship |
| C-001 | P2 | Historical `auth.tempo.xyz` deployment anomaly | Live historical observation; current functional site restored | A hostile controller of a trusted auth origin could solicit deceptive wallet authorization | Confirm Vercel/DNS ownership and audit history |
| C-007 | P3 | `tempo-std` authorization RLP mismatch | Locally reproduced correctness issue | Expected rejection/DoS or integration failure, not an authorization bypass | Identify a production consumer and add cross-language vectors |
| OBS-001 | Closed observation | Removed `changelogs/bot/.env` | Historical scanner/source observation; absent from current default branch | A still-valid repository credential could enable source or automation abuse; no validity or scope established | Confirm revocation and audit the public-exposure interval internally |

## Systemic pattern: unreviewed code and privileged CI

C-002, C-004, C-005, and C-008 are separate instances of one repeated control failure family:

```text
compromised trusted repository identity
  → same-repository pull request or trusted automation trigger
  → unreviewed checkout/build/local action executes
  → privileged environment, executable, or deployment step receives a secret
  → cloud, release, signing, or directly funded application authority
```

Fork-secret protections and protected-branch review do not close this path because the privileged action occurs before merge and intentionally trusts organization members or collaborators. The durable fix is to keep unreviewed code and its outputs out of secret-bearing execution, then require independent approval and narrowly scoped credentials in a base-controlled deployer.

## C-005 — Member PR preview crosses into raffle escrow signing authority

- **Family:** privileged CI / application-held financial key
- **Priority and rating:** P0; High, potentially Critical if the preview key is shared with production or holds material funds
- **Assessment state:** locally validated candidate
- **Deployment state:** live workflow path observed; key identity, balance, and current rotation state unknown
- **Disclosure state:** ready after final owner/scope review; not sent
- **Affected asset:** `tempoxyz/tip.bot` at `e0a88f66bd7e1a6073b43f2cb6f3a5426d277318`
- **Evidence:** source inspection, public environment configuration, successful same-repository member PR run `32455547803`, and dummy-only local executable-resolution reproduction

### Confirmed mechanism

A non-draft same-repository PR from an accepted organization association is checked out before merge and executes repository-controlled setup. The preview deployment later introduces a nonempty mainnet fee-payer private key and other credentials into PR-influenced tooling. Application source shows that this key derives the shared raffle escrow address, receives ticket payments, and signs payouts; it is not merely a gas subsidy key.

### How a criminal could use it

A criminal who compromises an eligible Tempo GitHub identity could prepare a normal-looking PR that preserves tests and preview behavior while capturing the signing authority inside the runner. If the exposed key controls funded escrow, the attacker could authorize payouts to an address they control. The surrounding Slack and short-lived secrets-management authorities could help establish persistence or interfere with response, although those secondary effects have not been exercised.

### Preconditions and limits

- Requires a same-repository branch and an eligible member/collaborator identity; an ordinary outside fork PR is insufficient.
- Public evidence does not reveal whether preview and production use the same key, whether it has rotated, or what balance it controls.
- No real secret was read and no payout, PR, workflow, or endpoint was touched.

### Detection and remediation

Review member-PR workflow runs, OIDC token issuance, secret updates, payout signatures, escrow flows, and GitHub/cloud audit logs. Rotate the key after preserving evidence. Remove all financial keys from PR-triggered jobs, isolate preview funds/accounts, use a base-controlled deployer, and require independent environment approval with self-review disabled.

Detailed local report: `findings/C-005-tipbot-member-pr-escrow-key.md`.

## C-002 — Tempo Apps PR code reaches production Cloudflare deployment authority

- **Family:** privileged CI / shared production cloud credential
- **Priority and rating:** P0; High, with potentially Critical business impact
- **Assessment state:** locally validated candidate
- **Deployment state:** current source plus successful authenticated member-PR upload path; exact token policy unknown
- **Disclosure state:** ready after final scope review; not sent
- **Affected asset:** `tempoxyz/tempo-apps` at `5374dff9f01d050be7b9ab8d8d37349cf9506c76`
- **Evidence:** immutable workflow/action source, public member PR #1168 and run `30842288164`, public environment/ruleset data, and dummy-only local reproduction

### Confirmed mechanism

The pull-request workflow accepts same-repository members/owners/collaborators, executes the PR checkout and build, then supplies the Cloudflare credential also used by mainline production deployments to tooling resolved from the PR-influenced workspace. No GitHub Environment or second-person approval protects the secret-bearing preview job.

### How a criminal could use it

After compromising one eligible repository identity, a criminal could capture the deploy credential during an apparently legitimate preview. If its public-use evidence reflects its full policy, they could modify the mainnet sponsor, WebAuthn key-manager, explorer, contract verifier, or related routes. A malicious sponsor/auth service or frontend could substitute transactions, solicit broader wallet authority, or direct users toward attacker-controlled transfers while preserving the trusted `tempo.xyz` origin.

### Preconditions and limits

- Requires same-repository write access and a matching trusted association.
- Cloudflare resource policy, account separation, client-IP restrictions, and current token rotation are not public.
- A successful preview upload proves authentication and route reachability, not exploitation or unrestricted account access.

### Detection and remediation

Correlate member PRs with Cloudflare token use, Worker-version uploads, route/domain changes, key-manager and sponsor telemetry, and unexpected deployments. Rotate the credential, split production credentials per application/account, make previews non-production-only, and move privileged deployment to a clean base-controlled workspace behind required reviewers.

Detailed local report: `findings/C-002-tempo-apps-cloudflare-preview.md`.

## C-006 — Release tags bypass protected-branch review

- **Family:** source/release supply chain
- **Priority and rating:** P1; High, potentially Critical when mutable artifacts feed production automatically
- **Assessment state:** source and public-control candidate
- **Deployment state:** legitimate release runs prove the publication/signing paths; malicious trigger was not tested
- **Disclosure state:** ready after private-control check; not sent
- **Affected asset:** `tempoxyz/tempo` at `86ff4deaebfee38bb0b000e648b2b367810265ff`
- **Evidence:** workflow source, public ruleset/environment APIs, and successful `v1.13.1` release/container histories

### Confirmed mechanism

Important branches require review and checks, but no public tag ruleset was returned. A `v*.*.*` tag triggers container and binary workflows using the tagged commit's source and workflow definition. The container path publishes SemVer and mutable stable images with signing; the release path signs binaries, creates a release, and uploads to R2. Public environment configuration showed no independent reviewer gate capable of substituting for tag protection.

### How a criminal could use it

A criminal controlling a write-capable maintainer, GitHub App, or deploy key could tag an unreviewed commit rather than merging through protected `main`. The resulting artifacts could appear official and signed. A node/operator compromise could then expose validator credentials, RPC traffic, deployment secrets, or transaction handling, and could become a stepping stone to financial theft or concealment.

### Preconditions and limits

- Requires a write-capable identity able to create matching tags.
- Private organization policy or a downstream deployment approval could reduce reach but is not externally visible.
- No tag, release, image, or package was created during this research.

### Detection and remediation

Alert on tag creation and compare every tag target to a reviewed protected-branch commit. Add immutable protected tag rules, restrict tag creation to a release identity, require independent protected environments, and build releases from a base-controlled workflow bound to an approved commit. Avoid mutable production tags or monitor their digest movement.

Detailed local report: `findings/C-006-unprotected-release-tags-bypass-main-review.md`.

## C-008 — Wallet PR automation reaches the release trust root

- **Family:** privileged CI / wallet supply chain
- **Priority and rating:** P1; High, potentially Critical if current signing and R2 authorities remain co-located
- **Assessment state:** statically and dummy-locally validated candidate
- **Deployment state:** legitimate `v0.7.0` signing/publication observed; no public successful privileged changelog run found
- **Disclosure state:** ready after trigger/secret-placement check; not sent
- **Affected assets:** `wallet-cli` `677e52278eaafa4ec356ed9c750446fba320cdfa`, `wallet-rs` `5245df47d3ada6a6eecf67342f03919d0123e8fc`, and Tempo launcher `86ff4deaebfee38bb0b000e648b2b367810265ff`
- **Evidence:** workflow/environment/source inspection, successful historical release jobs, live distribution manifests, launcher/update source, wallet key-storage source, and dummy-only local reproduction

### Confirmed mechanism

A label-triggered same-repository pull request enters an unprotected release environment before review, mints a release-bot token, checks out the unmerged PR, and installs its dependencies/lifecycle code. The same release boundary is used to sign wallet extensions and write current binaries/manifests to `cli.tempo.xyz`. The Tempo launcher trusts that host and key and automatically installs or updates extensions; the wallet extension can read the user's locally stored delegated private keys while running as that user.

### How a criminal could use it

A criminal with a compromised eligible repository or automation identity could cross the PR/release boundary, obtain enough publication authority to place a higher-version malicious wallet extension, and have it accepted by normal launcher verification. The extension could then copy or misuse local access keys and transfer value within each key's on-chain scope, spending limit, and expiry.

### Preconditions and limits

- Requires same-repository influence and the relevant label/trigger path.
- Public evidence cannot prove present secret placement, key rotation, number of updating clients, or balances authorized by local access keys.
- The research did not label a PR, trigger a workflow, obtain a secret, or modify an object.

### Detection and remediation

Audit label events, release-environment entries, App-token minting, signing-key use, R2 object versions, manifest/version changes, and client update telemetry. Separate changelog automation from signing/publication, protect the release environment with independent reviewers, prohibit PR-head execution in privileged jobs, split signing from storage credentials, and make update metadata append-only or transparently logged.

Detailed local report: `findings/C-008-wallet-cli-pr-release-secrets.md`.

## C-003 — Scoped access key can exceed its token limit through a pre-existing ZonePortal allowance

- **Family:** authorization composition / on-chain asset movement
- **Priority and rating:** P1; Medium, potentially High when wallets present the delegated limit as an independent loss cap
- **Assessment state:** protocol primitive locally reproduced; product intent unresolved
- **Deployment state:** source/local only; current portal deployment and affected account state not established
- **Disclosure state:** requires product-intent and deployment check; not sent
- **Affected assets:** Tempo `88b5d7720d29655fdf9025bb14ddcd6bba1f645c` and Zones `acaa6a6734860ecd81d7f01de3c973b068dca2ac`
- **Evidence:** exact source/spec history, first-party maximum-approval guidance, and focused local native-contract reproduction

### Confirmed mechanism

A delegated key may be scoped to the official ZonePortal deposit selector. The portal can pull from a root account's already existing TIP-20 allowance, while native spending-limit enforcement treats allowance-backed `transferFrom` differently from direct delegated spending. The caller chooses the encrypted Zone recipient, so a direct recipient allowlist does not bind that hidden destination. In the local reproduction, value moved through the allowance while the delegated key's configured token limit remained unchanged.

### How a criminal could use it

After stealing a seemingly low-limit access key that is allowed to call the portal, a criminal could direct a deposit to a Zone recipient they control and consume the root account's pre-existing portal allowance. The loss ceiling would be the smaller of balance and allowance, not the delegated key's displayed budget.

### Preconditions and limits

- Requires a compromised active delegated key with the relevant call scope, a compatible portal/token, a valid encrypted recipient, and a pre-existing allowance/balance.
- The intentional allowance behavior is publicly documented; the novel question is its composition with scoped delegated keys and hidden Zone recipients.
- No live allowance, balance, portal, or mainnet transaction was queried or modified.

### Detection and remediation

Wallets should calculate and display effective contract allowance as delegated risk, alert on scoped contract calls that consume root allowances, and prefer exact/one-time approvals. If token limits are intended as hard caps, enforce them at the contract/system boundary or bind token, amount, and Zone recipient in authorization.

Detailed local report: `findings/C-003-zone-portal-access-key-limit-composition.md`.

## C-004 — Accounts PR code reaches a Cloudflare deployment credential

- **Family:** privileged CI / account-service cloud credential
- **Priority and rating:** P2; High if production resources are in scope, otherwise Medium
- **Assessment state:** source and dummy-locally validated candidate
- **Deployment state:** successful member preview observed; token policy and production relationship unknown
- **Disclosure state:** validate scope; not sent
- **Affected asset:** `tempoxyz/accounts` at `bff90b590894e074d2cd25e9ee9d5b197813ff33`

### Confirmed mechanism

A same-repository member PR runs unreviewed install/build code before a deployment action receives a Cloudflare token. The action can resolve tooling from the PR-controlled workspace. Unlike C-002, public source does not establish the same breadth of production resources for this credential.

### How a criminal could use it

If the token can alter a production Accounts/auth Worker or route, a compromised writer could capture it during preview and deploy a wallet-connect or authorization flow that solicits broader access keys or substitutes transaction intent. If the credential is restricted to isolated preview resources, financial impact is much lower.

### Preconditions, detection, and remediation

Requires an eligible same-repository identity. Confirm Cloudflare account/resource scope and token rotation before rating deployment impact. Review preview deployments and token use; isolate preview accounts and credentials, prohibit PR-resolved executables after secret injection, and require independent environment approval.

Detailed local report: `findings/C-004-accounts-pr-cloudflare-token.md`.

## C-001 — Historical `auth.tempo.xyz` Vercel deployment anomaly

- **Family:** SaaS custom-domain/deployment control
- **Priority and rating:** P2 investigation item; severity depends entirely on unauthorized project control
- **Assessment state:** historical observation; controller and intent unresolved
- **Deployment state:** live behavior changed during the review
- **Disclosure state:** ask owner privately; not sent
- **Affected asset:** `auth.tempo.xyz`

### Timeline

- 2026-07-13 public third-party observation: Vercel `307` to `/rest`.
- 2026-08-14 public third-party observation: `200`, title `Tempo Auth`.
- 2026-08-21 13:40–13:43 UTC direct observation: catch-all malformed relative redirect naming an unrelated bug-bounty domain.
- 2026-08-21 16:15 UTC direct recheck: `200`, title `Tempo Auth`, with transaction-signing and access-key routes in the server-rendered route manifest.

### Security relevance and criminal use

The current functional site means the malformed redirect is historical evidence, not a current takeover. If an unauthorized party ever controlled the Vercel project bound to this valid HTTPS authentication origin, they could present a convincing wallet/signing flow, exploit any origin allowlists, or attempt to obtain user authorization. There is no evidence that this occurred, that credentials were collected, or that the project was unauthorized.

### Next gate and remediation

Tempo should confirm the DNS and Vercel project owner and review deployment/domain audit history across the timeline. Also review OAuth/origin/CSP/CORS/cookie allowlists and visits to the hostname. If every deployment was authorized, close the candidate as configuration/research noise; if not, preserve logs, reclaim the custom domain, rotate affected authority, and inspect adjacent SaaS-bound subdomains.

Detailed local report: `findings/C-001-auth-tempo-vercel-control.md`.

## C-007 — `tempo-std` key-authorization RLP mismatch

- **Family:** SDK/wire-format correctness and test integrity
- **Priority and rating:** P3; Low/Informational absent a production consumer
- **Assessment state:** locally reproduced
- **Deployment state:** library source only; consumer reach unknown
- **Disclosure state:** needs consumer/prior-art check; not sent
- **Affected asset:** `tempoxyz/tempo-std` at `c77f1671f7fd01c698f1344c2a5f38f11a7f8384`

### Confirmed mechanism

The Solidity helper wraps a caller-supplied RLP key-authorization list as an RLP string where the canonical Rust transaction implementation expects a list. A focused local vector reproduced the divergent bytes. The repository's three passing tests cover constants/selectors and execute none of the transaction-helper lines.

### How a criminal could use it

The expected consequence is malformed transaction generation, rejection, denial of service, or inconsistent test fixtures—not acceptance of unauthorized authority. A criminal benefit would be indirect, such as selectively breaking a consumer's authorization or exploiting confusion during recovery, and has not been demonstrated.

### Next gate and remediation

Identify real consumers, add cross-language golden vectors against the Rust implementation, test nested RLP structures, and correct or constrain the helper API. Do not rate this as theft without an acceptance differential or affected production flow.

Detailed local report: `findings/C-007-tempo-std-key-authorization-encoding.md`.

## OBS-001 — Historical credential file removed from `changelogs`

- **Family:** repository-history credential hygiene
- **Priority and rating:** known/closed historical observation; current severity not established
- **Assessment state:** high-signal historical context, not a validated live secret
- **Deployment state:** history-only; `bot/.env` is absent from the current `master` tree
- **Disclosure state:** publicly acknowledged by the removal PR; internal revocation/audit confirmation remains appropriate
- **Affected asset:** `tempoxyz/changelogs` commit `38a9f721c2c68726a38ddf38ba7d5606e61a8528`
- **Evidence:** one unverified GitHub-detector record at `bot/.env:1`, path history, removal merge `79c502c94ab76cf8153d6a3bc22d02ae03850d3f`, and public PR #115

### Observation and owner context

The history contains a committed environment file declaring a GitHub credential and an external AI-service credential. The file was removed on 2026-05-02 by [PR #115, “Delete bot/.env”](https://github.com/tempoxyz/changelogs/pull/115); the PR says the secrets were not live. Values, exact shapes, and hashes are omitted, and neither credential was tested.

### How a criminal could use it

If a historical repository credential were still valid and sufficiently scoped, a criminal could use its API authority to read or alter source, automation, releases, or related organization resources. A valid external service key could be abused for unauthorized service use, cost, or as evidence of a broader developer-environment compromise. Scope, validity during the exposure window, and any actual use are unknown.

### Detection and remediation

Confirm revocation or rotation through the owning providers, then review GitHub and service audit logs for the public-exposure interval and for any secondary credentials created through the same identity. Enable push protection and history-aware scanning. Do not authenticate the historical values merely to prove closure.

## Public-repository secret scan

All 68 public repository mirrors completed canonical TruffleHog `3.97.0` full-history runs with provider verification disabled: 201,832 per-repository commit visits and 1,281 unverified match records. Raw values and JSON stay ignored under `target/secret-scan/`. Metadata triage found 293 current-path records, 967 history-only records, and 21 records without file metadata; path presence is not credential validity.

No actionable current credential was established. OBS-001 is the only high-signal credential-shaped source context. The rest was classified as generated/vendor/upstream/test material, workflow expressions, public endpoints, local configuration, or detector collisions. Binary/archive exceptions and the lack of provider verification remain explicit limitations.

Final redacted results and limitations: [`recon/2026-08-21-public-repository-secret-scan.md`](recon/2026-08-21-public-repository-secret-scan.md).

## Update protocol

For every material research pass:

1. Recheck mutable observations and add a dated timeline rather than overwriting old evidence.
2. Add or update the summary row and stable `C-*` entry.
3. Record foothold, authority crossed, value target, criminal conversion path, constraints, detection, recovery, confidence, and next validation gate.
4. Keep secret values, exploit payloads, private personal data, and operational proof-of-concept steps out of this tracked file.
5. Update the ignored detailed report and its checksum when deeper evidence changes.
6. Do not mark an issue “finding,” “unknown to Tempo,” “exploited,” or “resolved” without the corresponding evidence.

## Current disclosure order

Subject to final owner/scope checks, the recommended private discussion order is C-005, C-002, a coordinated C-006/C-008 release review, C-003, then C-004. C-001 is an urgent ownership/audit-history question rather than a current takeover claim. C-007 is a lower-priority correctness report.
