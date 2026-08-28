# Findings Register

Last updated: **2026-08-28 01:47 UTC** \
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
| C-006 | P1 | Release tags bypass protected-branch review | August 23 source/config validated; legitimate release paths observed | Could publish official signed node/container artifacts from unreviewed code | Confirm private tag controls and downstream consumers |
| C-008 | P1 | Wallet PR automation reaches release trust root | August 23 STS/lifecycle path and dummy-local mechanism validated | Could publish a trusted wallet update that steals or misuses local access keys if signing/publication authority is reachable | Confirm environment protection, STS operation, current secret placement, and trigger semantics; disclose with C-006 |
| C-003 | P1 | Scoped key can spend pre-existing ZonePortal allowance beyond its limit | Protocol primitive locally reproduced; relevant August 23 source unchanged; deployment/user intent unresolved | A compromised delegated key could move more TIP-20 value than the displayed key budget | Confirm deployed portal state and intended wallet security model |
| C-010 | P1 investigation | MPP streaming headroom can become payment for undelivered value | TypeScript and Rust paths reproduced; native reserve interface/constants observed read-only; public prior art is partial | A malicious or compromised paid endpoint can obtain an enforceable full-deposit voucher before delivering the priced stream | Confirm accepted-risk model and deployed source identity; review ordinary/scheduled settlement with the earlier close fix |
| C-009 | P1 investigation | Wallet CLI masks default unrestricted key authority | Output mismatch reproduced at the August 23 reviewed head; hosted policy and affected population unknown | A stolen CLI key retains unrestricted calls and may retain full spending while audit output says zero/empty | Confirm hosted limit policy and affected-key population; preserve optional semantics |
| C-004 | P2 | Accounts PR code reaches Cloudflare credential | Dummy-local mechanism; member-preview route observed | Could alter an auth/account Worker if the token reaches production resources | Establish token scope and production relationship |
| C-012 | P2 investigation | Rust multi-fetch accepts one-unit vouchers for 10,000-unit responses | Full verifier PoC reproduced; affected example current/released; production consumers unknown | A dishonest payer can underpay 99.99% for every protected response in the shipped integration pattern | Inventory copied/production consumers; make request-cost debit inseparable from successful verification |
| C-011 | P2 investigation | Concurrent Rust voucher reuse can authorize multiple paid responses | Real signed-voucher race reproduced through `Mpp::verify_session`; current/released code affected; production consumers unknown | A dishonest payer can receive multiple metered responses while durable voucher authorization advances once | Inventory production `verify_session` consumers; make voucher advancement and request-cost debit one atomic success condition |
| C-001 | P2 | Historical `auth.tempo.xyz` deployment anomaly | Live historical observation; functional site restored in the August 23 check | A hostile controller of a trusted auth origin could solicit deceptive wallet authorization | Confirm Vercel/DNS ownership and audit history |
| C-007 | P3 | `tempo-std` authorization RLP mismatch | Locally reproduced correctness issue | Expected rejection/DoS or integration failure, not an authorization bypass | Identify a production consumer and add cross-language vectors |
| OBS-002 | P2 investigation | Grafana credential-shaped value in public Tempo branch | Public non-default branch head confirmed; validity/scope untested | Could expose or poison profiling telemetry and weaken detection; no direct fund authority established | Revoke/rotate owner-side, inspect scope and audit logs, remove from public refs |
| OBS-003 | Low / Informational | Zone checker custody is RPC-trusted | Mock-locally confirmed at current source and open #1289; deployment configuration unknown | A compromised trusted RPC could suppress or fabricate the auxiliary solvency signal, not alter funds or consensus | Confirm intended RPC-fault model; authenticate custody against the header state root if required |
| OBS-001 | Known observation | Removed `changelogs/bot/.env` | Absent from default branch but present at 18 non-default branch heads; public PR says not live | A still-valid repository credential could enable source or automation abuse; no validity or scope established | Confirm revocation and audit the public-exposure interval internally |

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
- **Affected asset:** `tempoxyz/tempo` at the August 23 reviewed head `d656ef5581505b59f1611b358e611f5a602d399e` (original baseline `86ff4deaebfee38bb0b000e648b2b367810265ff`)
- **Evidence:** August 23 workflow source and public ruleset inventory, latest successful detailed environment snapshot, successful `v1.13.1` release/container histories, and a local no-publication ancestry model

### Confirmed mechanism

Important branches require review and checks, but the 2026-08-23 public inventory returned 64 branch-targeted ruleset records (62 active and two disabled) and zero tag-targeted rulesets. A `v*.*.*` tag triggers container and binary workflows using the tagged commit's source and workflow definition. The container path publishes SemVer and mutable stable images with signing; the release path signs binaries, creates a release, and uploads to R2. The latest successful detailed environment snapshot showed no independent reviewer gate capable of substituting for tag protection. The August 23 reviewed head replaced one auxiliary stored App-credential path with short-lived GitHub STS, but did not bind release tags to reviewed `main` history or gate the artifact jobs on the version check.

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
- **Affected assets:** August 23 reviewed `wallet-cli` `5a06c07a76c175667507724da4c0b4ac185df048`, `wallet-rs` `7801e796b8239514d7d8544cc1c32bfe4795d810`, and Tempo launcher `d656ef5581505b59f1611b358e611f5a602d399e`; dummy PoC baseline `wallet-cli` `677e52278eaafa4ec356ed9c750446fba320cdfa`
- **Evidence:** August 23 workflow/STS/environment/source inspection, successful historical release jobs, live distribution manifests, launcher/update source, wallet key-storage source, and dummy-only local reproduction

### Confirmed mechanism

A label-triggered same-repository pull request enters the shared release environment before review, requests a short-lived GitHub App token through GitHub OIDC and the external STS, checks out the unmerged PR, and installs its dependencies/lifecycle code before later token/Anthropic consumers. The August 23 reviewed source says the replaced stored App wiring was never configured, so the old path is not treated as operational proof. The same named release boundary is used by the separate job that signs wallet extensions and writes binaries/manifests to `cli.tempo.xyz`. The Tempo launcher trusts that host and key and automatically installs or updates extensions; the wallet extension can read the user's locally stored delegated private keys while running as that user.

### How a criminal could use it

A criminal with a compromised eligible repository or automation identity could cross the PR/release boundary, obtain enough publication authority to place a higher-version malicious wallet extension, and have it accepted by normal launcher verification. The extension could then copy or misuse local access keys and transfer value within each key's on-chain scope, spending limit, and expiry.

### Preconditions and limits

- Requires same-repository influence and the relevant label/trigger path.
- Public evidence cannot prove a successful STS exchange, current environment protection/secret reachability, key rotation, number of updating clients, or balances authorized by local access keys.
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
- **Affected assets:** reproduced at Tempo `86ff4deaebfee38bb0b000e648b2b367810265ff` / Zones `acaa6a6734860ecd81d7f01de3c973b068dca2ac`; relevant trees remained byte-identical at the August 23 reviewed Tempo `d656ef5581505b59f1611b358e611f5a602d399e` / Zones `7e38642cdd5a1500784fd15cf30eda5366f3350a` heads
- **Evidence:** exact source/spec history, first-party maximum-approval guidance, focused local native-contract reproduction, and August 23 head tree comparison

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

## C-010 — MPP streaming headroom can become payment for undelivered value

- **Family:** payment-channel fair exchange / agent-payment overcapture
- **Priority and rating:** P1 investigation; High candidate under a malicious or compromised paid endpoint
- **Assessment state:** locally validated cross-layer candidate; raw authorization weakness is public prior art
- **Deployment state:** released TypeScript and current Rust SDK behavior; TIP-1034 reserve interface/constants observed on mainnet and Moderato by passive calls; deployed source identity and live paid integrations remain unconfirmed
- **Disclosure state:** needs owner awareness/accepted-risk confirmation and coordinated review; not sent
- **Affected assets:** mppx `3f73a17eeba9522d90894099635a43d6d2934cf5` and releases 0.8.15/0.8.19; mpp-rs `fadc88c044b9f8700b58d275bb659d403b231e07`; mpp-specs `6de3b4d5d13b4a80310bd80e021c02a4126428e2`; Tempo `18c174325061fa07ef577ef3fd59f5a7869bd556`; OpenClaw MPP plugin `4e30d5677145c5e5c4aebd1c7a3d372f072db419`
- **Evidence:** two executed TypeScript PoCs, one executed Rust signature PoC, an existing Rust close-above-spent test, CI-equivalent Rust suite, immutable source/spec/prior-art review, and passive native-interface constants

### Confirmed mechanism

MPP's plaintext stream necessarily gives one party a small fair-exchange option: the payer signs a cumulative voucher before the corresponding delivery window, so the payee can withhold that window. While the channel remains settleable, the voucher is an on-chain claim the payer cannot revoke, bound to a channel and cumulative amount but not to price, units, request, resource, delivery, or expiry; channel finalization ends enforceability. Small client-controlled windows can bound this inherent risk.

Current managed clients make the window server-controlled. A need-voucher event supplies `requiredCumulative`; mppx and mpp-rs can sign that amount after only deposit and optional absolute-cap checks, without deriving it from locally observed delivered value. `maxDeposit` is optional. The mppx local PoC received zero application messages but produced and independently verified a full-deposit voucher: 100 authorized for a one-unit quote. The Rust parity PoC raised a 1,000-unit prior authorization to a valid 10,000-unit full-deposit voucher.

Under the current public TIP-1034 source, the payee can redeem the signed voucher directly: the reserve checks signature, monotonic amount, and deposit rather than off-chain consumption. The mppx exported and scheduled settlement path additionally automates the mismatch: a second local PoC supplied `highestVoucher=100` and `spent=1`, and the actual helper submitted 100 to its chain boundary. Passive reads observed the expected native interface/constants, but did not pin deployed bytecode to this source. The current specification requires exact-spend capture for cooperative close but does not state the same rule for ordinary settlement.

### How a criminal could use it

A criminal could compromise an MPP-enabled API, its operator/payee authority, or a third party that an unattended agent already calls. The endpoint could advertise a small per-unit price, induce a much larger cumulative authorization or top-up before useful output, withhold the stream, and redeem the signed amount. Payer-key compromise is not required; the agent signs through the intended automatic payment path.

The eventual excess if the full authorization `A` is redeemed is `max(0, A - X)`, where `X` is value actually delivered and owed. Already realized excess is `max(0, S - X)`, where `S` is settled on-chain; the remaining collectible exposure is `max(0, A - max(S, X))`. A finite local cap and deposit bound one channel, but uncapped server-influenced top-ups can enlarge the practical ceiling toward available balance.

### Preconditions and limits

- Requires a malicious/compromised selected endpoint and its payee/operator settlement capability, plus an agent willing and funded to open or reuse an automatic session channel.
- OpenClaw's normal setup creates a seven-day key with a total $10 USDC limit. That bounds its default key; larger custom policies and raw-private-key configuration can be materially broader.
- The reviewed wallet CLI computes increments locally and was not classified as reachable through the same automatic-stream path merely because it depends on mppx.
- mppx PR #510 already contains a public warning that server values plus an uncapped default can coerce vouchers up to deposit. The possible new regression/composition is ordinary/scheduled high-water settlement after PR #196 fixed the same invariant for cooperative close. Public silence does not prove Tempo is unaware.
- No separate machine-token-only FX/free-option claim was retained, and no live payment, wallet, key, agent, endpoint, or state-changing transaction was used.

### Detection and remediation

Alert on large `requiredCumulative` jumps, top-ups disproportionate to delivered units, `highestVoucher > spent`, and settlement exceeding service-accounting records. Correlate agent tool calls, stream delivery, voucher signatures, merchant/operator identity, and reserve settlement.

Make a finite local budget mandatory and require `newAuthorization <= locallyObservedDeliveredValue + configuredRiskWindow` before every signature. Treat server snapshots and cumulative/deposit hints as untrusted. Refuse ordinary or scheduled settlement above durable spend; obtain an exact-spend voucher or wait for consumption. Extend the specification's no-overcapture rule to every settlement path and add cross-SDK model tests over deposit, authorization, delivered value, spend, and settlement.

Sanitized execution evidence: [`evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt`](evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt). Detailed local report and PoC patches: `findings/C-010-mpp-streaming-overcapture/`.

## C-009 — Wallet CLI masks the authority of its default unrestricted access key

- **Family:** delegated wallet authorization / misleading security telemetry
- **Priority and rating:** P1 investigation; Medium severity, potentially High financial consequence after local-key compromise
- **Assessment state:** locally validated candidate; reference flow reachable
- **Deployment state:** release/protocol/hosted-client schema and read-only public UI assets observed through August 23; private server limit policy unknown
- **Disclosure state:** needs private policy/affected-key confirmation; not sent
- **Affected assets:** August 23 reviewed wallet-cli `5a06c07a76c175667507724da4c0b4ac185df048` (issue-relevant source unchanged from tested `677e52278eaafa4ec356ed9c750446fba320cdfa`), Accounts 0.16.0 `ce4d2c1e981d443deecd2193d65cdea610478ea6`, and Tempo `d656ef5581505b59f1611b358e611f5a602d399e`
- **Evidence:** pinned cross-repository semantics, upstream localnet vectors, August 23 head focused wallet-output regression, and passive inspection of August 23 public approval assets

### Confirmed mechanism

Wallet CLI v0.7.0 requests a 30-day access key with only an expiry. The pinned CLI-auth schema has no call-scope field, so the resulting key is unrestricted for contract calls. In the reference policy, omitted token limits also produce unlimited spending; a private hosted policy could still inject a finite limit. Tempo's protocol explicitly distinguishes omitted limits/scopes (unlimited/unrestricted) from explicit empty collections (deny all).

The CLI later destroys that distinction: absent limits normalize to `[]`, and `whoami`/`keys` report `unlimited: false`, `limit: "0.000000"`, no spending limits, and empty scopes. The same key remains payment-capable. A focused test reproduced the false output; the Accounts 0.16.0 localnet suite already demonstrates that an expiry-only extractable P-256 key can transfer before and after filesystem persistence. Public wallet assets observed on August 23 correctly rendered the omitted limit as `Spend — Unlimited`, so the approval screen itself was not hidden or deceptive.

### How a criminal could use it

After compromising a workstation, dependency, insider, or trusted wallet update, a criminal could steal the CLI's locally persisted access-key material and use its actual on-chain transfer, approval, and contract-call authority during the remaining authorization window. A victim, agent, or responder relying on the documented CLI inventory could see zero spending and empty scopes, underestimate the loss ceiling, and delay revocation. Under an unrestricted/unlimited issuance, the ceiling is the root account's accessible value rather than the displayed zero.

### Preconditions and limits

- The user explicitly approves the key, and the current browser UI visibly labels a missing limit as Unlimited.
- The output mismatch does not provide initial access; theft requires later compromise or misuse of local key material.
- Keys expire after approximately 30 days by default and are non-admin; balance, allowances, revocation, and detection bound loss.
- Tempo's private hosted policy may inject a finite token limit. No device code, authorization, key, balance, or production transaction was created or queried.
- Accounts documentation already warns that unbounded keys are too broad for safe production use. Public searches found no exact report of wallet-cli's expiry-only default plus its false zero/empty audit representation, but private awareness is unknown.

### Detection and remediation

Inventory and, where appropriate, revoke/reissue CLI-created keys with `enforceLimits=false` or `allowAnyCalls=true`. Correlate their creation with wallet-cli versions and review subsequent transfers, approvals, and contract calls. Change the default request to a bounded token/period and narrow call scopes; make unrestricted authority an explicit escalation. Preserve omitted, explicit-empty, and populated states in storage and output, cross-check canonical on-chain metadata, and add end-to-end request-to-display tests for all three states.

Detailed local report: `findings/C-009-wallet-cli-unrestricted-key-misreport.md`.

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

## C-012 — Rust multi-fetch accepts one-unit vouchers for 10,000-unit responses

- **Family:** request-price accounting / merchant-side service theft
- **Priority and rating:** P2 investigation; Medium, potentially High where protected calls have material cost or resale value
- **Assessment state:** locally validated current/released integration candidate
- **Deployment state:** affected pattern is shipped in the bundled multi-fetch example at current head and v0.11.0; copied or production consumers are unknown
- **Disclosure state:** needs consumer inventory and coordinated review; not sent
- **Affected assets:** mpp-rs current head `fadc88c044b9f8700b58d275bb659d403b231e07` and published v0.11.0 commit `e2e27edc17c1f8274bab982f3dc91477fcc01a44`
- **Evidence:** deterministic signed-voucher PoC through the real `Mpp::verify_session` path, current/release source comparison, specification review, and adjacent public security history

### Confirmed mechanism

The bundled Rust multi-fetch server advertises 10,000 base units per page and authenticates that `amount` inside the MPP challenge, but configures `min_voucher_delta=0`. `Mpp::verify_session` validates the challenge, currency, recipient, channel, voucher monotonicity, deposit, and signature; the voucher branch does not compare its increment with `SessionRequest.amount` or atomically debit request cost from `spent`. The example then returns protected content for every non-management verification success.

The full local PoC began with the prior 10,000-unit authorization fully consumed (`highest=spent=10,000`), created an HMAC-bound challenge with `amount=10,000`, and presented a valid voucher advancing cumulative authorization by exactly one. The real verifier succeeded even though only one unspent unit was available and durable `spent` remained unchanged. It reproduced the example's non-management-success predicate; static source establishes that the bundled handler releases content for that result. The same example is byte-identical at published v0.11.0, whose voucher path has the same omission.

### How a criminal could use it

A payer using its own funded channel and signer could submit successively higher vouchers in one-unit increments to an integration copied from the example. Each accepted increment can release one response advertised at 10,000 units. For advertised cost `P` and increment `d`, uncompensated service value per response is `P-d`; the shipped values permit 9,999 units, or 99.99%, underpayment without a race, forgery, stolen key, or server compromise.

### Preconditions and limits

- This steals service from a merchant; it does not take money from an agent.
- Scope is the bundled fixed-price HTTP example and similar consumers that treat bare `verify_session` success as full payment while `min_voucher_delta < request cost`.
- The Tempo session draft assigns cost calculation and atomic `spent += cost` to the application. This is therefore an unsafe official integration/API footgun rather than evidence that every conforming session server is affected.
- Rust SSE/WebSocket paths use the atomic debit helper; current mppx HTTP accounting also charges. Those paths were not shown affected.
- Production adoption, response value, rate limits, and additional application accounting are unknown.
- Public GHSA `GHSA-fxc9-7j2w-vx54` fixed adjacent free-session/payment bypasses but did not add this request-cost debit. No specific public report was identified; private awareness remains unknown.
- All execution used local keys/state and an in-process mocked chain response. No live channel, service, credential, payment, or RPC was used.

### Detection and remediation

Inventory production and copied uses of the Rust multi-fetch/`verify_session` pattern. Correlate response count and advertised cost with voucher growth and `spent`; alert when delivered value exceeds durably debited cost.

Provide a high-level atomic request-payment primitive that persists a higher voucher if needed, derives server-owned route cost, requires sufficient unspent authorization, increments `spent` by that cost, and only then permits delivery. Keep `minVoucherDelta` as an independent anti-flood control. Fix the official example and add tests where a valid voucher increment is smaller than the authenticated challenge price.

Sanitized execution evidence: [`evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt`](evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt). Detailed local report and PoC patch: `findings/C-012-mpp-rust-session-unit-price-bypass/`.

## C-011 — Concurrent Rust voucher reuse can authorize multiple paid responses

- **Family:** payment replay / concurrency / merchant-side service theft
- **Priority and rating:** P2 investigation; Medium, potentially High for expensive or resalable protected responses
- **Assessment state:** locally validated current/released implementation candidate
- **Deployment state:** affected verification pattern is present in the bundled multi-fetch example; production consumers and pricing are unknown
- **Disclosure state:** needs consumer inventory and coordinated review; not sent
- **Affected assets:** mpp-rs current head `fadc88c044b9f8700b58d275bb659d403b231e07` and published v0.11.0 commit `e2e27edc17c1f8274bab982f3dc91477fcc01a44`
- **Evidence:** deterministic signed-voucher race through the actual `Mpp::verify_session` boundary, real credential parsing and mocked on-chain channel decoding; focused core-state reproduction; current and release source review

### Confirmed mechanism

The Rust session verifier reads the current channel state, validates a voucher delta and signature against that snapshot, then performs a serialized atomic state update. Two concurrent requests can therefore validate the same increment against the same old snapshot. The first update advances durable `highest_voucher`; the second transition detects that the state already advanced but returns a successful no-op rather than rejecting the stale request. Both verifier calls consequently return success receipts.

The stronger local PoC drove two concurrent, identically signed requests through the real `Mpp::verify_session` path, including HMAC/credential parsing and mocked `getChannel` ABI decoding. Both satisfied the same non-management-success predicate that gates content in the bundled example, while durable authorization advanced only from 1,000 to 2,000 once and no request cost was atomically debited. Static source shows the handler returns protected content for each such success. The ordinary sequential replay test still rejects the same voucher; the gap is specifically concurrent time-of-check/time-of-use behavior.

### How a criminal could use it

A payer with its own funded session and valid signing key could race the same incremental voucher across parallel requests. For a service that treats verifier success as sufficient to return protected content, every raced request can receive a response while the merchant obtains only one increment of enforceable authorization. For `N` successful responses of value `P` and one accepted voucher increment `delta`, uncompensated exposure is `max(0, N*P-delta)`; when `delta=P`, the race-only duplicate loss is `(N-1)*P`. Concurrency, downstream delivery, and application controls bound the result. No signature forgery or victim key is required.

### Preconditions and limits

- This steals paid service from a merchant; it does not take money from an agent and is distinct from C-010.
- The demonstrated application shape is verification-only HTTP delivery, matching the bundled multi-fetch example. The bundled SSE and WebSocket examples perform a separate atomic spend debit and were not shown affected.
- Production use of `verify_session`, response value, rate limits, deduplication, and application-side debit behavior are not public.
- Earlier public replay/store fixes serialized state and reject sequential reuse. This race survives serialization because the losing transition is deliberately reported as success; private awareness remains unknown.
- All tests used local keys, in-memory state, and mocked transport. No live channel, service, credential, payment, or RPC was used.

### Detection and remediation

Correlate simultaneous requests by channel, voucher hash/cumulative amount, and response identifier; alert when more than one successful response maps to one authorization increment. Inventory every `verify_session` consumer and determine whether it performs a linearizable request-cost debit before releasing value.

Make a stale or losing atomic voucher transition fail authentication. Prefer one atomic server operation that both advances the voucher and reserves/debits the specific request cost, keyed by a stable request identifier. Add a barrier-synchronized regression test that requires exactly one of two same-voucher requests to cross the delivery gate, and retain application-level idempotency and concurrency limits as defense in depth.

Sanitized execution evidence: [`evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt`](evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt). Detailed local report and PoC patches: `findings/C-011-mpp-rust-session-voucher-race/`.

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
- 2026-08-23 14:17–14:29 UTC direct refresh: `200`, title `Tempo Auth`, still served through the Vercel custom-domain path.

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
- **Priority and rating:** known historical observation; likely revoked per public owner statement, but current severity is not independently established
- **Assessment state:** high-signal historical context, not a validated live secret
- **Deployment state:** absent from `master`, but still present at 18 public non-default branch heads in the 2026-08-21 mirror
- **Disclosure state:** publicly acknowledged by the removal PR; internal revocation/audit confirmation remains appropriate
- **Affected asset:** `tempoxyz/changelogs` commit `38a9f721c2c68726a38ddf38ba7d5606e61a8528`
- **Evidence:** one unverified GitHub-detector record at `bot/.env:1`, path history, removal merge `79c502c94ab76cf8153d6a3bc22d02ae03850d3f`, and public PR #115

### Observation and owner context

The history contains a committed environment file declaring a GitHub credential and an external AI-service credential. The file was removed from `master` on 2026-05-02 by [PR #115, “Delete bot/.env”](https://github.com/tempoxyz/changelogs/pull/115); the PR says the secrets were not live. The snapshot still finds that file at 18 non-default branch heads. Values, exact shapes, and hashes are omitted, and neither credential was tested.

### How a criminal could use it

If a historical repository credential were still valid and sufficiently scoped, a criminal could use its API authority to read or alter source, automation, releases, or related organization resources. A valid external service key could be abused for unauthorized service use, cost, or as evidence of a broader developer-environment compromise. Scope, validity during the exposure window, and any actual use are unknown.

### Detection and remediation

Confirm revocation or rotation through the owning providers, then review GitHub and service audit logs for the public-exposure interval and for any secondary credentials created through the same identity. Enable push protection and history-aware scanning. Do not authenticate the historical values merely to prove closure.

## OBS-002 — Grafana Cloud credential-shaped value in a public Tempo branch

- **Family:** repository credential hygiene / observability integrity
- **Priority and rating:** P2 investigation; Medium if valid with telemetry read/write scope
- **Assessment state:** unverified credential-shaped source observation
- **Deployment state:** public non-default branch `zygis/pprof`; absent from `main`
- **Disclosure state:** ready for private owner-side revocation/scope confirmation; not sent
- **Affected asset:** `tempoxyz/tempo` branch head `e6cd619cee885d081d2d1a41b2a6ff390e593484`
- **Evidence:** TruffleHog `Grafana` detector at `bin/tempo/src/main.rs:43`, redacted source-context review, local-ref containment, and GitHub API confirmation at `2026-08-21T16:58:08Z`

### Observation

The branch hardcodes basic-auth material for a Tempo node profiling agent that sends to a Grafana Cloud Pyroscope endpoint. GitHub reported the public branch at the pinned commit and as unprotected. The credential value is omitted and was not sent to Grafana; validity, permissions, owner, rotation state, and whether the experiment ever ran are unknown.

### How a criminal could use it

If still valid, a criminal could exercise whatever profiling authority it grants: potentially reading operational profile data, injecting or corrupting profiles, exhausting quota, or degrading the monitoring signal used during an intrusion. That could aid reconnaissance or concealment, but no deployment, fund-signing, cloud-administration, or source-control authority is established from the public evidence.

### Detection and remediation

Tempo should revoke or rotate the credential without testing the public value, inspect Grafana access-policy scope and audit logs from the 2025-08-23 commit onward, and determine whether the profiler sent production or test data. Remove the value from every public ref, move profiler authentication to an injected secret, add pre-receive/push protection for Grafana formats, and review adjacent experimental branches for copied credentials.

## OBS-003 — Zone checker Portal custody is RPC-trusted

- **Family:** monitoring independence / state authentication
- **Priority and rating:** Low / Informational under the documented trust model
- **Assessment state:** source and mock-locally confirmed observation
- **Deployment state:** present at Zones `016e4c30530f943d6714e895ce0a34e22b01b9c1` and open #1289 head `8c492eb7b8800866ec0d64f43a6abebaa909408a`; operator configuration and deployment unknown
- **Disclosure state:** not sent; adjacent shared-RPC trust concern is already public in #1216 review
- **Evidence:** authenticated-header/receipt source inspection, documented Tempo execution trust boundary, and a focused mock showing that the custody helper accepts one unproved RPC balance

### Observation

The observe-only checker independently derives Zone liabilities and authenticates Portal event receipts, but its Portal custody comparison obtains `balanceOf` through a historical RPC call. The canonical-block parameter constrains an honest server; the returned state value is not verified against the authenticated header's state root. A focused mock supplied only an arbitrary encoded balance—no account or storage proof—and the real helper accepted it on current main and the open isolation branch. The complete patched checker library suites still passed.

The checker documentation explicitly treats Tempo consensus/execution as trusted and says it does not re-execute Tempo. This narrows the result to a precise independence qualification: liabilities are rederived, while Portal custody remains trusted RPC execution output. Observe mode cannot modify custody, execution, or consensus.

### How a criminal could use it

An attacker who already controls the checker's trusted Tempo RPC path could report a falsely high custody value to delay the auxiliary detector's insolvency signal or a falsely low value to create a false durable divergence. This does not create insolvency or move funds, and the same foothold already violates a documented infrastructure trust boundary. Exact deployment routing, redundant providers, alerting, and owner expectations are unknown.

### Next gate and remediation

Confirm whether resilience to a faulty or compromised Tempo RPC is an intended property. If it is, retain the authenticated header state root, retrieve the TIP-20 account/storage proof, and verify the Portal balance locally before advancing the checker. A separately operated node or provider quorum is useful defense in depth but is not equivalent to a cryptographic proof. Documentation should explicitly distinguish RPC-trusted custody from receipt-authenticated activity.

Sanitized execution evidence and tracked mock patches: [`evidence/2026-08-27-T-015-security-engineering-review.txt`](evidence/2026-08-27-T-015-security-engineering-review.txt).

## Public-repository secret scan

All 68 public repository mirrors completed canonical TruffleHog `3.97.0` full-history runs with provider verification disabled: 201,832 per-repository commit visits and 1,281 unverified match records. Raw values and JSON stay ignored under `target/secret-scan/`. Triage found 132 exact detected sequences in current default content, 161 current paths with changed content, 967 deleted paths, and 21 records without file metadata; byte presence is not credential validity.

No credential was confirmed live. Two contexts survived triage: the publicly acknowledged, likely revoked OBS-001 and the unverified public-branch OBS-002, which warrants owner-side revocation/scope confirmation. The rest was classified as generated/vendor/upstream/test material, workflow expressions, public endpoints, local configuration, or detector collisions. Binary/archive exceptions and the lack of provider verification remain explicit limitations.

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

The first owner-side hygiene check is OBS-002 because revocation is low-cost and does not require testing the public value. Subject to final owner/scope checks, the recommended vulnerability-discussion order is C-005, C-002, C-010, a coordinated C-006/C-008 release review, C-003, C-009, C-004, C-012, then C-011. C-010's first question is whether server-selected authorization headroom and high-water ordinary settlement are known/accepted; the existing local evidence is sufficient without a live payment. C-012/C-011 first require a private inventory of production or copied `verify_session` consumers and whether response release shares one atomic request-cost debit with voucher advancement. C-009's first question is a low-risk owner-side check of the hosted limit policy and affected-key population; no live authorization is needed. C-001 is an urgent ownership/audit-history question rather than a current takeover claim. C-007 is a lower-priority correctness report. OBS-003 first needs a threat-model question about whether the checker is expected to tolerate a faulty Tempo RPC; no live RPC test is needed.
