# Tempo.xyz External Attack-Surface and Code-Assisted Security Assessment

**Report date:** August 23, 2026<br>
**Assessment window:** August 21–23, 2026<br>
**Report version:** 1.0<br>
**Assessment type:** external, public-information, read-only infrastructure review and local source-code testing<br>
**Target:** Tempo (`tempo.xyz` and the public `tempoxyz` GitHub organization)<br>
**Handling:** private working report; no external disclosure has been made

## Executive summary

This assessment mapped Tempo's publicly observable organizational attack surface with a financial-theft threat model. The review emphasized paths a financially motivated, well-resourced actor—particularly one willing to compromise an employee, contractor, GitHub App, release identity, or service provider—could use to reach funds, wallet authority, production services, or trusted software distribution.

The central conclusion is that Tempo's highest-leverage externally visible risk is **trusted-identity compromise crossing into privileged automation**, rather than an unauthenticated Internet exploit. Four independently reviewed workflow paths execute same-repository pull-request code at or before a boundary carrying cloud, repository-write, or application signing authority. A separate release design allows matching tags to initiate official artifact publication without public evidence that the tag must point to reviewed protected-branch history. These paths do not work for an ordinary outside-fork contributor under GitHub's normal secret model; they become relevant after compromise or misuse of a writer, member, collaborator, App, deploy key, or release identity.

Nine candidate issues were retained: two P0, four P1, two P2, and one P3. Two additional repository-secret-hygiene observations need owner-side confirmation. Seven candidates have harmless local PoCs that reproduce the relevant process, protocol, or serialization boundary with dummy values; the release-tag candidate adds a local no-publication control model. The historical authentication-origin item is supported by a dated live-response timeline because its prior behavior is no longer present and should not be recreated. No live credential was confirmed, no production authorization was attempted, no GitHub workflow was triggered, and no production data or state was changed.

No evidence established that any candidate has been exploited, is unknown to Tempo, or currently exposes unrestricted production authority. Several ratings are conditional on private facts—credential scope, environment separation, key reuse, tag policy, hosted wallet policy, and affected balances—that only Tempo can resolve. Those conditions are called out per finding.

### Risk profile

| Priority | Count | Main theme |
| --- | ---: | --- |
| P0 | 2 | Same-repository PR code can reach a production cloud boundary or an application-held financial-key boundary |
| P1 | 4 | Release/wallet supply chain and authorization-composition failures with plausible theft impact |
| P2 | 2 | Cloud-preview authority with unresolved scope and historical trusted-origin control anomaly |
| P3 | 1 | Transaction-helper encoding correctness issue without a demonstrated authorization bypass |
| Observations | 2 | Historical/public-branch credential hygiene requiring owner-side revocation and audit confirmation |

### Immediate recommendations

1. Remove secrets and privileged executables from all PR-triggered jobs. Build untrusted code without credentials; deploy only a reviewed, immutable artifact from a clean base-controlled workflow.
2. Scope-confirm and rotate the C-002, C-004, and C-005 authorities after preserving audit evidence. For C-008, first confirm live STS/environment reachability and rotate any implicated release authority only if exposure is established. Separate preview, production, signing, storage, and financial keys by account and purpose.
3. Protect release tags, bind every release to a reviewed protected-branch commit, and require independent protected-environment approval with self-review disabled.
4. Treat wallet release signing and update metadata as separate trust roots. Add append-only/transparency monitoring and client-side provenance checks.
5. Decide and document whether delegated token limits are hard loss caps across allowance-backed calls; preserve unlimited, deny-all, and bounded states in wallet inventory.
6. Confirm ownership and audit history for every SaaS-bound `tempo.xyz` origin, beginning with `auth.tempo.xyz`, and revoke the two repository credential observations without testing the public values.

## 1. Engagement overview

### 1.1 Objectives

The assessment sought to:

- create a coherent map of public services, source, build, release, wallet, protocol, communications, and third-party trust boundaries;
- identify ways a criminal could convert a compromised insider or third party into financial theft or durable control;
- determine where outside contributors can submit code and where trusted writers' PRs cross privileged boundaries;
- run complete available smart-contract/native-contract suites and add focused tests for uncovered security invariants;
- scan every public repository's reachable history for credential-shaped material; and
- preserve reproducible, sanitized evidence without touching real credentials or changing production state.

### 1.2 Scope

Included:

- `tempo.xyz` hostnames found in official DNS, certificates, documentation, or current public source;
- all repositories publicly listed by the `tempoxyz` GitHub organization during the assessment;
- public GitHub Actions, branch/ruleset metadata, environments, releases, packages, and contributor entrypoints;
- public indications of Google Workspace/Gmail, Slack, VPN/SSO, support, cloud, observability, registry, and DevOps dependencies;
- Tempo, Zones, and `tempo-std` source and tests at the pinned revisions named below; and
- passive DNS/TLS/HTTP and conservative common-TCP-port service identification on confirmed Tempo hostnames.

Excluded:

- private repositories, internal networks, employee or customer accounts, and non-public organization settings;
- password reset, account recovery, MFA, SSO, VPN, Slack, Gmail, support, or OAuth authentication testing;
- credential validation, phishing, employee enumeration, social engineering, or personal-data collection;
- exploit delivery, destructive testing, denial of service, fuzzing against production, transaction submission, or cloud/GitHub state changes; and
- scanning unrelated infrastructure belonging to Cloudflare, Vercel, Google, Slack, AWS, Grafana, Bridge, Stripe, Privy, or other partners.

### 1.3 Method and evidence standard

The work combined public GitHub API/source review, full-history local mirrors, non-verifying TruffleHog scans, DNS/TLS/HTTP observation, bounded service identification, dependency/workflow tracing, and local execution of checked-in and focused security tests.

Evidence is labeled as one of:

- **Executed local PoC:** a harmless test using dummy values or in-memory/local state that reproduces the relevant boundary.
- **Static configuration proof:** immutable source/configuration establishes a trigger, permission, or data flow; no production trigger was invoked.
- **Live read-only observation:** an ordinary public response or public API record was observed without authentication or mutation.
- **Owner confirmation required:** the decisive fact is private and cannot be established responsibly from outside.

Priority is an assessment workflow label. Severity describes plausible consequence under the prerequisites stated in each finding; it is not a claim that those prerequisites currently hold. “Potentially Critical” therefore means that a private scope/key-reuse fact could raise impact, not that Critical impact was demonstrated.

### 1.4 Limitations

This is not an internal penetration test. Public GitHub metadata does not reveal organization-wide rules, private repositories, secret values/scopes, App installation permissions, deploy keys, enterprise policy, audit alerts, or current credential rotation. Shared CDN addresses and open edge ports do not identify an origin server. Public DNS cannot establish internal VPN topology or identity-provider enforcement. Local green tests do not prove deployed bytecode, current privileged roles, or cross-system safety. The report records these unknowns instead of inferring absent controls.

## 2. Attack-surface assessment

### 2.1 Crown jewels and financially relevant authority

| Crown jewel | Theft or control consequence | High-leverage entrypoint |
| --- | --- | --- |
| User root keys, passkeys, and delegated access keys | Transfers, approvals, contract calls, persistent delegated authority | Auth/wallet origin, SDK, signed client update, dependency, endpoint, or local workstation compromise |
| TIP-20 issuer and TIP-403 policy roles | Mint, burn, freeze, pause, or compliance-policy control | Administrative key, privileged client, governance, or recovery compromise |
| DEX, fee-conversion, Zone, reserve, and application balances | Withdrawal, redirection, or concealed reconciliation loss | Contract flaw, stale allowance, signing key, integration credential, or misleading data plane |
| Fee-payer and raffle escrow keys | Sponsored transactions or application-held payout authority | Secret-bearing CI, Worker deployment, or application compromise |
| Release signing, registry, R2, and update metadata | Trusted malicious node/wallet distribution | Maintainer/App/tag compromise or PR-to-release automation |
| GitHub, cloud, DNS, and SaaS administration | Source, deployment, trusted-origin, and recovery control | Human identity, GitHub App, CI/OIDC, provider account, or support compromise |
| Validator identities and threshold shares | Consensus participation, finality, and incident response | Operator, host, release, backup, or recovery compromise |

### 2.2 Publicly facing services

The assessment started from source/documentation hostnames, rejected wildcard-only discoveries, and then used ordinary DNS, TLS, HTTP, and a small common-TCP-port set on confirmed Tempo names. Results identify public service fronts, not origin infrastructure. A CDN's `80/443` response—or any other shared-edge response—must not be interpreted as an exposed Tempo origin daemon.

The principal public trust boundaries observed during the initial snapshot were:

| Service family | Representative hosts | Security role |
| --- | --- | --- |
| Brand, documentation, and integration guidance | `tempo.xyz`, `accounts.tempo.xyz`, `docs.tempo.xyz`, `mpp.tempo.xyz` | Installation, SDK guidance, OAuth/wallet integration expectations, and user trust |
| Authorization and wallet | `auth.tempo.xyz`, `wallet.tempo.xyz`, `keys.tempo.xyz` | Transaction signing, access-key creation/revocation, WebAuthn/key management, and wallet approval display |
| Transaction and data plane | `rpc.tempo.xyz`, `indexer.tempo.xyz`, `explore.tempo.xyz`, `contracts.tempo.xyz`, `tokenlist.tempo.xyz` | Transaction submission, canonical/read views, decoded transaction presentation, source verification, and asset identity |
| Sponsorship and application services | `sponsor.tempo.xyz` and application-specific Tempo Apps routes | Fee-payer authority, transaction preparation, user-facing application behavior |
| Software and node distribution | `cli.tempo.xyz`, `snapshots.tempo.xyz`, GitHub Releases, GHCR, Docker Hub, language registries | Wallet extension, node snapshot, binary, container, and package trust |
| Test and development environments | Moderato RPC/explorer/faucet/sponsor plus source-referenced preview/dev names | Lower-assurance configurations that can still share CI, cloud, or identity boundaries |

The August 23 refresh checked all 96 source-indexed names. It found no general `*.tempo.xyz` address wildcard, but it did confirm `*.mpp.tempo.xyz`; an MPP name resolving to the shared Cloudflare edge is therefore not independent proof that the named integration exists. Public edges serving Tempo hostnames were principally Cloudflare and Vercel, with `rustdocs.tempo.xyz` on GitHub Pages. No Tempo origin was discovered. A bounded nmap sample of `tempo`, `auth`, `wallet`, `rpc`, and `rustdocs` showed only TCP 80/443 open and 22/8545 filtered on the sampled shared edges. This is provider-edge characterization, not an origin-port finding.

Current root responses included `200` for the canonical site, auth, wallet, explorer, console, snapshots, status, and Rust docs; expected API-style `400`, `401`, `402`, `404`, or `405` responses occurred on RPC, TIDX, indexer, keys/CLI, and MCP roots. In particular, `indexer.tempo.xyz` changed from the August 21 `404` to an August 23 `402`; neither status alone is a vulnerability. The exact DNS/TLS/HTTP/nmap transcript is linked in [public-perimeter evidence](evidence/2026-08-23-public-perimeter.txt). The broader source-derived inventory remains in [`SURFACE.md`](SURFACE.md) and [`recon/2026-08-21-source-referenced-hosts.tsv`](recon/2026-08-21-source-referenced-hosts.tsv).

### 2.3 Communications, identity, support, and remote access

Public evidence identifies Google-hosted email, Slack application/automation use, GitHub as the primary engineering identity boundary, Cloudflare and Vercel deployment surfaces, and additional AWS/OIDC, registry, R2, Grafana, support, and partner integration boundaries. These create high-value compromise and recovery paths even when they do not directly hold funds:

| Boundary | Publicly established exposure | Financially relevant abuse path | Private control status |
| --- | --- | --- | --- |
| Google Workspace/Gmail | Complete Google MX set; SPF authorizes Google and Mailgun; DMARC rejects for the organizational domain and subdomains | Executive/developer mailbox takeover, OAuth consent abuse, password-reset interception, invoice/payment diversion | MFA, hardware keys, session policy, forwarding alerts, admin separation unknown |
| Slack | `tip.bot` Slack app credentials/events plus CI notification/integration references | Compromise bot/app signing secrets, impersonate trusted operational context, steal tokens, suppress or redirect response | Enterprise Grid, SSO, retention, app allowlisting, token rotation unknown |
| Tailscale / Zero Trust | Current domain-verification record and source-supported Tailscale design references; Cloudflare Dashboard SSO is separately domain-verified | A stolen identity/session could bridge into admin, cloud, runner, or trusted-CIDR paths if deployed policy is weak | Workforce enforcement, device posture, IdP binding, ACLs, split tunneling, break-glass controls unknown |
| GitHub | Public organization, repositories, Actions, Apps/tokens, environments, releases, packages, and OIDC trust into an external GitHub-App STS | Source/release compromise, CI secret access, short-lived token minting, persistence through Apps or automation | Enterprise policy, MFA, audit streaming, STS/App ownership, deploy-key inventory unknown |
| Support and recovery | Public security/support channels and repository surfaces | Social-engineer recovery, suppress reports, redirect domain/account recovery | Staffing, identity verification, escalation and dual control unknown |
| Cloud/DevOps | Cloudflare/DNS/R2, Vercel, AWS and GCP OIDC, third-party Depot runners, GHCR/Docker Hub, npm/crates/PyPI/Go, Grafana, Better Stack | Deploy malicious trusted-origin code, publish updates, alter telemetry, mint temporary authority, or create persistence | Account separation, IP restrictions, trust policies, token scopes, approval and recovery policy unknown |

Current source makes two additional trust distinctions important. First, the GitHub Actions chain can exchange GitHub OIDC assertions with the externally hosted `gh-sts.tehq.net` service to mint short-lived GitHub App tokens; expanded use was observed in the August 23 refresh in source commits authored August 21. Short-lived tokens reduce stored-secret exposure but make the STS, its policy repository, the App installation, and OIDC subject binding a joined release-security boundary. The third-party host was not scanned. Second, `wallet.tempo.xyz` exposes a live public OIDC issuer for product verified-email tokens; this is not evidence that the same service is Tempo's workforce IdP.

Slack exposure is broader than a notification webhook. Public source describes a customer-facing Tipbot OAuth app with message/channel/group/user read scopes, interactive and slash-command callbacks, and chat-write authority. GitHub workflows can create, update, or delete preview Slack apps; a shared action rotates a Slack configuration token and writes the successor into GitHub Actions secrets. Separately, core benchmark automation posts through a bot and documentation feedback is forwarded to Slack after source-level secret redaction. The Tipbot manifest does not prove installation in Tempo's internal workspace, while the domain-verification record and separate automation do establish an operational Slack relationship.

Tailscale-aware code provides two design-review leads: TIDX documents the Tailscale CGNAT range as an optional trusted administrative CIDR, and Tempo's contract verifier accepts `https://*.ts.net` origins and skips its application rate limiter for the allowlisted origin class. No evidence establishes that the example CIDR is deployed, every `ts.net` name is Tempo-controlled, or a private service is reachable. No Origin-spoofing request, rate-limit bypass, tailnet enumeration, or load test was attempted.

The public mail posture has a strong DMARC `p=reject; sp=reject` control. No public CAA, DNSSEC DS, MTA-STS, or SMTP TLS-reporting record was returned; DKIM was left unknown because no selector was guessed. These are hardening observations, not evidence of mailbox compromise. Tailscale domain verification plus trusted-CIDR/`*.ts.net` source references establish a relationship and review leads, not organization-wide employee VPN enforcement or reachable private services. Better Stack currently serves the public status page. No login, tenant enumeration, recovery-flow probing, OAuth authorization, mailbox lookup, or personal identity collection was performed. The evidence and negative findings are recorded in [communications and DevOps exposure](evidence/2026-08-23-comms-devops-exposure.txt).

### 2.4 GitHub organization and pull-request entrypoints

Tempo's public GitHub organization is the widest observable engineering control plane. Public repositories generally allow an outside user to fork and propose a pull request unless a repository is archived or otherwise disables the path. That does **not** mean ordinary fork code receives repository secrets: GitHub's normal model withholds them. The high-impact candidates in this report instead require a compromised or malicious same-repository writer/member/collaborator, a privileged automation identity, or a tag-capable identity.

The August 23 public inventory contained **68 repositories: 52 originals and 16 forks**. Fifteen were archived, leaving 53 nonarchived repositories and 48 active originals. An outside researcher therefore has a broad ordinary fork/PR proposal surface, but not the trusted association required by C-002/C-004/C-005/C-008. GitHub reported 67 default branches as protected; `txgen/main` was the only active default branch reported unprotected. `tip.bot/main` returned no ruleset list but was separately reported protected with five visible required checks.

The review considers these distinct paths:

```text
outside contributor → fork PR → untrusted CI (ordinary secrets withheld)

trusted/compromised writer → same-repository PR → member-gated preview/release job
  → PR-controlled checkout/install/tool resolution → cloud, signing, or financial authority

writer/App/deploy key → matching release tag → artifact build/sign/publish path
  → official release, container, binary, or wallet-update trust
```

The current ruleset enumeration across all 53 nonarchived repositories returned 64 records—62 active and two disabled—all branch-targeted and **zero tag-targeted**. Fifty-one repositories inherit organization ruleset `12500570`, which blocks direct default-branch pushes and enforces squash/rebase merge modes; `tip.bot` and `txgen` returned no ruleset list. Tempo's repository rules additionally expose required review/check controls for important branches. These are meaningful merge controls, but they do not protect a secret-bearing job that intentionally executes a trusted writer's unmerged PR, nor do branch rules protect tags.

The current default branches contain 446 workflow files across 52 repositories; the 48 active originals contain 203 files across 34 repositories. Trigger and authority counts are review leads, not vulnerability counts:

| Workflow characteristic | All public default branches | Active originals |
| --- | ---: | ---: |
| `pull_request` | 187 files / 49 repositories | 99 files |
| `pull_request_target` | 13 / 8 | 11 / 7 |
| `issue_comment` | 9 / 7 | 9 / 7 |
| `workflow_run` | 10 / 10 | 1 / 1 |
| `workflow_call` | 56 / 25 | 31 / 11 |
| Tag-filtered push | 39 / 21 | 14 / 10 |
| Secrets-context reference | 232 / 47 | 98 / 30 |
| Declared write permission | 235 / 45 | 114 / 30 |
| `id-token: write` | 83 / 31 | 47 / 17 |
| Environment declaration | 39 / 25 | 27 / 14 |
| Literal self-hosted runner | 3 files / 2 repositories | 3 / 2 |

In the latest successful detailed sample, 40 environments were returned across 12 of 18 queried financially sensitive repositories. Only `tempo-go/releases` exposed required reviewers; self-review was still allowed and no sampled environment exposed a wait timer. Tempo `release`/`release-pr` exposed only branch policies, and wallet-cli/wallet-rs `release` exposed no reviewer rule in that snapshot. The August 23 detail refresh hit GitHub's public API rate limit, so private or subsequently changed protection remains possible.

Seventeen default branches contain a recognized CODEOWNERS file, but only four active originals do: `mpp-rs`, `tempo`, `tempo-std`, and `zones`. Presence does not prove that code-owner approval is required. Current literal self-hosted selections occur in two Tempo benchmark workflows and one Zones benchmark workflow. Tempo's issue-comment dispatcher checks organization membership before calling its benchmark path; this is an intentional insider boundary, while runner ephemerality, network reach, and workspace/cache isolation remain private.

Current source also moved Tempo, wallet-cli, and wallet-rs release automation from stored GitHub App credentials toward GitHub OIDC and the external App-token STS. This reduces long-lived secret material but does not, by itself, require an approved commit, protect a release tag, or prevent PR-controlled lifecycle code from influencing a later token consumer. Shared actions, CODEOWNERS, self-hosted/third-party runner references, package publication, and the exact trigger inventory are enumerated in the linked evidence.

The refreshed repository counts, PR entrypoints, sampled rulesets/protections, CODEOWNERS, environments, runner references, workflow trigger classes, and release paths are in [GitHub-controls evidence](evidence/2026-08-23-github-controls.txt). Finding C-006's specific tag/release boundary is in [release-tag evidence](evidence/2026-08-23-C-006-release-tag-control.txt).

### 2.5 Smart contracts, native contracts, and wallet authorization

The tested protocol surface includes Account Keychain authorization, TIP-20/TIP-403, stablecoin DEX and fee conversion, fee management, nonce handling, signatures, Zone Factory/Portal integration, and storage layouts. At pinned revisions:

- Zones: 485 Forge tests and 7 symbolic properties passed; production coverage was 95.78% of lines and 79.58% of branches; ABI and storage-layout comparisons passed.
- Tempo native precompiles: 1,088 tests passed with 15 explicitly ignored.
- `tempo-revm`: 197 tests passed.
- `tempo-std`: its three checked-in tests passed, but they executed none of 538 transaction-helper lines or 92 helper functions.

Focused review found two gaps that green component suites missed: allowance-backed Zone deposits can compose with delegated call scopes outside the delegated token limit (C-003), and the Solidity transaction helper changes the RLP type of a key-authorization list (C-007). A third wallet issue (C-009) is a cross-repository semantic failure: omitted/unlimited policy is collapsed into the same local representation as explicit-empty/deny-all policy and displayed as zero/non-unlimited.

The executable baselines were pinned before the final report date, so current-head applicability was checked separately. Tempo's relevant precompile, transaction, handler, and embedded-Zone trees are byte-identical at August 23 head `d656ef5581505b59f1611b358e611f5a602d399e`; the relevant Zones Portal/runtime trees are byte-identical at head `7e38642cdd5a1500784fd15cf30eda5366f3350a`; and `tempo-std` remains at the exact tested head. The executed totals are preserved in [contract-test evidence](evidence/2026-08-23-contract-test-baseline.txt), and the current-tree comparison is in [contract-finding freshness evidence](evidence/2026-08-23-contract-finding-freshness.txt).

### 2.6 Public repository secret exposure

All 68 public repositories in the initial snapshot were acquired as full, non-shallow bare mirrors and scanned across reachable history with TruffleHog 3.97.0 verification disabled. The scanner made 201,832 per-repository commit visits and emitted 1,281 unverified matches across 26 repositories; 42 emitted none. No credential was authenticated and zero credentials were confirmed live.

Manual triage retained two owner-check items: a removed `changelogs` environment file publicly described as non-live but still reachable from 18 non-default branch heads, and a Grafana/Pyroscope credential-shaped value in a public Tempo experiment branch. Neither value is reproduced here or was sent to a provider. See [secret-scan evidence](evidence/2026-08-23-public-repository-secret-scan.txt).

## 3. Findings summary

| ID | Priority | Conditional severity | Status | Title | Evidence |
| --- | --- | --- | --- | --- | --- |
| C-005 | P0 | High; potentially Critical | Local mechanism validated; live workflow path observed | Member PR crosses into raffle escrow key boundary | [PoC](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt) |
| C-002 | P0 | High; potentially Critical | Local mechanism validated; authenticated member-PR upload observed | Tempo Apps PR code reaches production cloud deploy authority | [PoC](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt) |
| C-006 | P1 | High; potentially Critical | Source/control validated; legitimate release paths observed | Release tags can bypass protected-branch review | [Evidence](evidence/2026-08-23-C-006-release-tag-control.txt) |
| C-008 | P1 | High; potentially Critical | Current STS/lifecycle shape and dummy-local mechanism validated; live issuance/secret reach unknown | Wallet PR automation reaches release trust root | [PoC](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt) |
| C-003 | P1 | Medium; potentially High | Protocol primitive reproduced; deployment/user intent unresolved | Scoped key can spend pre-existing ZonePortal allowance beyond its limit | [PoC](evidence/2026-08-23-C-003-zone-allowance-poc.txt) |
| C-009 | P1 investigation | Medium; potentially High | Output mismatch reproduced; hosted policy unknown | Wallet CLI masks default unrestricted key authority | [PoC](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt) |
| C-004 | P2 | Medium; High if production-scoped | Local mechanism validated; token scope unresolved | Accounts PR code reaches Cloudflare credential | [PoC](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt) |
| C-001 | P2 investigation | Undetermined | Historical live observation; current site restored | Historical `auth.tempo.xyz` deployment anomaly | [Timeline](evidence/2026-08-23-C-001-auth-origin.txt) |
| C-007 | P3 | Low / Informational | Serialization mismatch reproduced; consumer unknown | `tempo-std` key-authorization RLP mismatch | [PoC](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt) |

## 4. Detailed findings

### C-005 — Member PR crosses into raffle escrow signing authority

**Priority / severity:** P0 / High, potentially Critical if the exposed preview key is shared with production or holds material funds<br>
**Affected revision:** `tempoxyz/tip.bot` `e0a88f66bd7e1a6073b43f2cb6f3a5426d277318`<br>
**Evidence type:** public workflow/source proof plus executed dummy-local process-boundary PoC<br>
**Evidence:** [2026-08-23-C-005-tipbot-key-boundary-poc.txt](evidence/2026-08-23-C-005-tipbot-key-boundary-poc.txt)

#### Description and demonstrated impact

A non-draft same-repository PR from an accepted organization association is checked out before merge and runs repository-controlled setup. The preview deployment later supplies a mainnet fee-payer private-key-named value, Slack credentials, and other secrets to PR-influenced tooling. Application source ties the mainnet signing identity to the shared raffle escrow address and payout signatures; it is not only a gas-subsidy key.

The local PoC used literal dummy strings and a fake package-manager executable. It reproduced the workflow's argument/stdin boundary and showed that the repository-selected process receives the full secret payload while preserving the expected command shape. If preview and funded production escrow share that key, a compromised eligible GitHub identity could extract signing authority and direct unauthorized payouts.

#### Preconditions and limits

- Requires a same-repository branch and eligible member/collaborator identity; an ordinary outside fork is insufficient.
- Key equality, rotation, current balance, and production use are private and unproven.
- No PR, workflow, secret, signature, payout, Slack endpoint, or Tempo endpoint was touched.

#### Remediation and detection

Preserve and review PR, runner, OIDC, secret-update, and escrow-signature logs; then rotate the key. Use isolated, minimally funded preview keys. Do not expose any financial key to PR code or its executable search path. Build without secrets, promote an immutable reviewed artifact in a base-controlled job, and require independent protected-environment approval.

### C-002 — Tempo Apps PR code reaches production Cloudflare authority

**Priority / severity:** P0 / High, potentially Critical depending on token scope and route coverage<br>
**Affected revision:** `tempoxyz/tempo-apps` `5374dff9f01d050be7b9ab8d8d37349cf9506c76`<br>
**Evidence type:** public workflow/run proof plus executed dummy-local executable-resolution PoC<br>
**Evidence:** [2026-08-23-C-002-C-004-wrangler-resolution-poc.txt](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt)

#### Description and demonstrated impact

The pull-request workflow accepts same-repository members/owners/collaborators, executes the PR checkout and build, and then provides a Cloudflare credential also used by mainline production deployment to tooling resolved from the PR-influenced workspace. Public configuration showed no independent Environment reviewer between unreviewed execution and the credential-bearing preview step.

The local PoC placed a fake `wrangler` in the workspace, injected only `DUMMY_TEMPO_APPS_TOKEN_NOT_A_SECRET`, and invoked the same local resolution form. The fake executable received the complete value and returned a normal-looking Wrangler version. If the real token's observed production use reflects its full scope, an attacker with one eligible compromised GitHub identity could modify sponsor, key-manager, explorer, verifier, or related behavior and use a trusted Tempo origin to substitute transaction intent or solicit broader wallet authority.

#### Preconditions and limits

- Requires same-repository write influence and the workflow's trusted association.
- Cloudflare resource policy, account separation, IP policy, and current rotation are not public.
- A successful historical preview upload proves authentication/reachability, not unrestricted account authority or exploitation.

#### Remediation and detection

Correlate member PRs with Cloudflare API use, Worker-version uploads, route changes, and sponsor/key-manager anomalies. Rotate the credential, split production credentials per resource/account, isolate previews, and ensure no executable or artifact influenced by unreviewed code runs after credential injection.

### C-006 — Release tags can bypass protected-branch review

**Priority / severity:** P1 / High, potentially Critical when mutable artifacts are automatically consumed<br>
**Affected revision:** `tempoxyz/tempo` current August 23 head `d656ef5581505b59f1611b358e611f5a602d399e`; originally reproduced/configuration-pinned at `86ff4deaebfee38bb0b000e648b2b367810265ff`<br>
**Evidence type:** public source/control and successful legitimate-release observations plus local no-publication control model<br>
**Evidence:** [2026-08-23-C-006-release-tag-control.txt](evidence/2026-08-23-C-006-release-tag-control.txt)

#### Description and demonstrated impact

Important branches require review and checks, but the public controls reviewed did not return a matching protected-tag rule. A `v*.*.*` tag triggers workflows from the tagged commit that build and sign binaries, create a GitHub release, upload to R2, and publish SemVer/mutable container tags. Public environment data did not show an independent reviewer gate capable of replacing tag protection.

The evidence demonstrates the distinction between branch ancestry and tag reachability locally and ties the actual trigger to successful legitimate Tempo release paths. A writer, GitHub App, deploy key, or release identity able to create a matching tag could point it at unreviewed code and obtain official-looking, signed artifacts without merging through protected `main`. A malicious node or container update could capture validator/operator credentials, RPC traffic, service secrets, or transaction handling.

#### Preconditions and limits

- Requires a tag-capable write identity; it is not an outside-contributor path.
- Private organization rules or downstream deployment approvals may reduce reach.
- No tag, release, image, object, signature, or package was created.

#### Remediation and detection

Protect immutable release tags; restrict tag creation to a dedicated release identity; reject targets not reachable from a reviewed protected-branch commit; require independent protected-environment approval; and build in base-controlled workflows. Alert on tag creation/deletion/movement and compare release subjects, provenance, R2 objects, and container digest movement to the approved commit.

### C-008 — Wallet PR automation reaches the release trust root

**Priority / severity:** P1 / High, potentially Critical if current signing and publication authorities remain co-located<br>
**Affected revisions:** current `wallet-cli` `5a06c07a76c175667507724da4c0b4ac185df048`; current `wallet-rs` `7801e796b8239514d7d8544cc1c32bfe4795d810`; current Tempo launcher `d656ef5581505b59f1611b358e611f5a602d399e`; PoC baseline `wallet-cli` `677e52278eaafa4ec356ed9c750446fba320cdfa`<br>
**Evidence type:** public workflow/distribution proof plus executed dummy-local lifecycle/executable-resolution PoC<br>
**Evidence:** [2026-08-23-C-008-wallet-release-boundary-poc.txt](evidence/2026-08-23-C-008-wallet-release-boundary-poc.txt); [current-head source comparison](evidence/2026-08-23-finding-freshness.txt)

#### Description and demonstrated impact

A label-triggered same-repository PR enters the shared release environment before review, requests a short-lived GitHub App token through GitHub OIDC and the external STS, checks out the unmerged PR, and installs its dependencies/lifecycle code. The policy requests `contents: write` and `pull_requests: write`; later steps introduce both the intended token and an Anthropic key. The same named release boundary is used by the separate wallet extension signing and current binary/manifest delivery path at `cli.tempo.xyz`. The Tempo launcher trusts that host and signing key and installs/updates extensions that can read locally stored delegated private keys.

The PoC used pinned pnpm and a dummy App token. PR-controlled lifecycle code altered later executable resolution; the later fake `git` received the dummy token while preserving the expected push command. This proves the local process boundary, not a successful live STS exchange or current signing-secret reachability. Source comments now state that the replaced stored App-credential wiring was never configured, so the current mechanism must be described as the STS route rather than proof that the old token path ever operated. If current release-environment signing/publication values can also be selected by the PR workflow, an attacker could publish a higher-version malicious wallet extension that normal update verification accepts, then misuse delegated keys within their on-chain scope, limit, and expiry.

#### Preconditions and limits

- Requires eligible same-repository influence and the relevant label/trigger authority.
- Current environment protection, STS issuance, signing-secret reachability, rotation, client uptake, and user balances are unknown.
- No PR was labeled; no workflow, App token, signing key, R2 object, manifest, or client was touched.

#### Remediation and detection

Separate changelog/PR automation from signing and publication. Never install PR-controlled dependencies in a privileged job. Protect the release environment with independent reviewers, split signing and object-storage credentials, bind manifests to reviewed provenance, and add append-only update transparency. Audit label events, App-token minting, signing-key use, object versions, manifest changes, and client update telemetry.

### C-003 — Scoped key can spend a pre-existing ZonePortal allowance beyond its token limit

**Priority / severity:** P1 / Medium, potentially High if users treat the delegated limit as a hard independent loss cap<br>
**Affected/tested revisions:** reproduced on Tempo `86ff4deaebfee38bb0b000e648b2b367810265ff` using source first pinned at `88b5d7720d29655fdf9025bb14ddcd6bba1f645c`, and Zones `acaa6a6734860ecd81d7f01de3c973b068dca2ac`; relevant trees remain byte-identical at current Tempo `d656ef5581505b59f1611b358e611f5a602d399e` and Zones `7e38642cdd5a1500784fd15cf30eda5366f3350a`<br>
**Evidence type:** executed focused Rust test with dummy addresses and in-memory state<br>
**Evidence:** [2026-08-23-C-003-zone-allowance-poc.txt](evidence/2026-08-23-C-003-zone-allowance-poc.txt); [current-head source comparison](evidence/2026-08-23-contract-finding-freshness.txt)

#### Description and demonstrated impact

A delegated key may be scoped to the official ZonePortal deposit selector. The portal can pull value from a root account's existing TIP-20 allowance, while native spending-limit enforcement intentionally treats allowance-backed `transferFrom` differently from direct delegated spending. The caller chooses the encrypted Zone recipient, so a direct recipient allowlist does not bind that hidden destination.

The focused T8 test configured a root balance and portal allowance of 1,000 units, a delegated token limit of 1 unit, and only the portal/deposit call scope. Scope validation succeeded; the separately modeled portal `transferFrom` then moved all 1,000 allowance-backed units and left the delegated limit at 1. In this composition the effective loss ceiling is `min(balance, remaining allowance)`, not the displayed delegated limit.

#### Preconditions and limits

- Requires a stolen active delegated key with the call scope, a compatible portal/token, valid recipient data, and a pre-existing allowance/balance.
- The test reproduces the native primitive but not a deployed Zone runtime or current mainnet user state.
- The allowance exemption itself is documented; the security question is its composition with delegated scope and user expectations.

#### Remediation and detection

Define whether delegated limits are hard caps. If so, enforce the cap across allowance-backed contract calls or bind token, amount, and Zone recipient in authorization. Wallets should include existing allowances in effective-risk display, prefer exact/one-time approvals, and alert on delegated calls that consume root allowances.

### C-009 — Wallet CLI masks default unrestricted key authority

**Priority / severity:** P1 investigation / Medium, potentially High after local-key compromise<br>
**Affected revisions:** current wallet-cli `5a06c07a76c175667507724da4c0b4ac185df048` (source-identical for the issue to tested `677e52278eaafa4ec356ed9c750446fba320cdfa`); Accounts 0.16.0 `ce4d2c1e981d443deecd2193d65cdea610478ea6`; current Tempo `d656ef5581505b59f1611b358e611f5a602d399e`<br>
**Evidence type:** executed regression test, complete identity suite, and proof-only patch<br>
**Evidence:** [2026-08-23-C-009-wallet-authority-output-poc.txt](evidence/2026-08-23-C-009-wallet-authority-output-poc.txt); [current-head regression](evidence/2026-08-23-finding-freshness.txt)

#### Description and demonstrated impact

Wallet CLI v0.7.0 requests a 30-day access key with expiry but no call scope or requested token limit. Tempo distinguishes omitted limits/scopes (unlimited/unrestricted) from explicit empty collections (deny all). A private hosted policy may inject a finite token limit, but the current CLI-auth schema cannot add call scopes. The CLI then normalizes a missing limits field to `[]` and reports the current key as `unlimited: false`, zero, and empty-scoped.

A focused run asserting that an omitted limit must be displayed as unlimited failed that test while skipping the other 39. After a proof-only display change, the complete 40-test identity suite and TypeScript compilation passed. That one-line change is not the complete fix because normalization has already collapsed protocol-opposite states. A responder relying on the released inventory can materially underestimate a stolen key's authority and delay revocation.

#### Preconditions and limits

- The user explicitly approves the key, and the current public approval UI labels a missing token limit as Unlimited.
- The mismatch does not provide initial access; compromise of a workstation, dependency, insider, or wallet update is still required.
- Keys expire after about 30 days by default and are non-admin; revocation, balances, allowances, and monitoring bound loss.
- The private hosted policy may inject a finite token limit; no production authorization request was made.

#### Remediation and detection

Preserve omitted, explicit-empty, and populated states end to end and cross-check canonical on-chain metadata. Make unrestricted authority an explicit escalation; request bounded token/period limits and narrow call scopes by default. Add request-to-approval-to-inventory tests for all three states. Inventory/revoke or reissue affected keys and review their transfer, approval, and contract-call histories.

### C-004 — Accounts PR code reaches a Cloudflare credential

**Priority / severity:** P2 / Medium, High if the token can change production Accounts/auth resources<br>
**Affected revision:** `tempoxyz/accounts` `bff90b590894e074d2cd25e9ee9d5b197813ff33`<br>
**Evidence type:** public workflow/run proof plus executed dummy-local executable-resolution PoC<br>
**Evidence:** [2026-08-23-C-002-C-004-wrangler-resolution-poc.txt](evidence/2026-08-23-C-002-C-004-wrangler-resolution-poc.txt)

#### Description and demonstrated impact

A same-repository member PR executes unreviewed install/build code before a deployment action receives a Cloudflare token, and the action can resolve tooling from the PR-controlled workspace. The shared PoC shows the local `wrangler` resolution path receives a dummy token. Unlike C-002, public evidence does not establish the same breadth of production use.

If production Accounts/auth Workers or routes are in scope, a compromised writer could deploy a deceptive wallet-connect or authorization flow from a trusted Tempo origin. If the credential is restricted to isolated preview resources, the impact is substantially lower.

#### Preconditions and limits

- Requires an eligible same-repository identity.
- Token scope, account separation, and production relationship are unknown.
- No token, PR, workflow, Worker, route, account, or auth flow was accessed.

#### Remediation and detection

Confirm scope and rotate after preserving logs. Isolate preview credentials/accounts, remove PR-resolved executables from secret-bearing steps, deploy only reviewed immutable artifacts, and require independent environment approval. Review member preview runs against Cloudflare token and deployment history.

### C-001 — Historical `auth.tempo.xyz` deployment anomaly

**Priority / severity:** P2 investigation / undetermined<br>
**Affected asset:** `auth.tempo.xyz`<br>
**Evidence type:** historical and current live read-only responses; no exploit PoC because the historical behavior is no longer present<br>
**Evidence:** [2026-08-23-C-001-auth-origin.txt](evidence/2026-08-23-C-001-auth-origin.txt)

#### Description and impact hypothesis

Public observations show `auth.tempo.xyz` changing from a functional Tempo Auth application to a malformed catch-all redirect naming an unrelated bug-bounty domain on August 21, then returning to a functional Tempo Auth application later that day. The current site exposes expected transaction-signing and access-key routes. The malformed behavior is historical evidence, not a current takeover.

If an unauthorized project ever controlled this valid HTTPS authentication origin, it could present a convincing wallet/signing flow, exploit origin allowlists, or solicit access-key authorization. There is no evidence that control was unauthorized, credentials were collected, or users were harmed. The decisive evidence—Vercel project ownership, deployment actors, and domain audit logs—is private.

#### Remediation and detection

Confirm the DNS and Vercel project owner and review deployments/domain changes across the evidence timeline. Review OAuth/origin/CSP/CORS/cookie allowlists and visits to the hostname. If all deployments were authorized, close the item as configuration/research noise; otherwise preserve logs, reclaim the binding, and review adjacent SaaS-bound subdomains.

### C-007 — `tempo-std` key-authorization RLP mismatch

**Priority / severity:** P3 / Low or Informational absent a production consumer<br>
**Affected revision:** `tempoxyz/tempo-std` `c77f1671f7fd01c698f1344c2a5f38f11a7f8384` (still the current default-branch head on August 23)<br>
**Evidence type:** executed focused Foundry encoding test<br>
**Evidence:** [2026-08-23-C-007-tempo-std-rlp-poc.txt](evidence/2026-08-23-C-007-tempo-std-rlp-poc.txt); [current-head source comparison](evidence/2026-08-23-contract-finding-freshness.txt)

#### Description and demonstrated impact

The Solidity helper wraps a caller-supplied RLP key-authorization list as an RLP string where the canonical Rust transaction implementation expects a list. The focused test passed `c180` and showed the resulting transaction suffix `82 c1 80`: the added `0x82` changes the field type. The original three-test suite did not execute transaction-helper code.

The PoC demonstrates malformed serialization. Canonical decoder-source analysis predicts rejection, inconsistent fixtures, or integration failure—not unauthorized acceptance or fund loss. Criminal benefit would be indirect, such as selectively breaking an affected consumer during a recovery event.

#### Remediation and detection

Identify consumers, correct or constrain the helper API, and add cross-language golden vectors against the Rust encoder/decoder for nested and optional fields. Do not elevate the issue without an affected production flow or acceptance differential.

## 5. Repository credential-hygiene observations

### OBS-001 — Removed `changelogs/bot/.env`

The full-history scan found a removed environment file. The public deletion PR states the credentials were not live, but the file remained at 18 non-default public branch heads in the snapshot. Neither value was tested or retained in this report. If a repository credential remained valid during exposure, it could enable source, automation, or release abuse.

Tempo should confirm revocation/rotation through provider-side records, audit the public-exposure interval, remove the file from all public refs, and ensure push protection covers the relevant formats. Evidence: [public-repository secret scan](evidence/2026-08-23-public-repository-secret-scan.txt).

### OBS-002 — Grafana/Pyroscope credential-shaped value in public branch

A public, unprotected Tempo experiment branch at `e6cd619cee885d081d2d1a41b2a6ff390e593484` contains a Grafana Cloud credential-shaped value associated with profiling. It was not validated or reproduced. If live, its plausible impact is telemetry disclosure/injection, quota abuse, or degraded monitoring—not established source, deployment, signing, or fund authority.

Tempo should revoke/rotate owner-side without testing the public value, inspect policy scope and audit logs, remove it from all refs, and search adjacent experiments for reuse. Evidence: [public-repository secret scan](evidence/2026-08-23-public-repository-secret-scan.txt).

## 6. Compound attack paths

The findings become most important when composed:

| Initial foothold | Control crossed | Criminal objective | Relevant findings |
| --- | --- | --- | --- |
| Compromised GitHub member/collaborator | Same-repository PR into preview CI | Extract escrow signing or production cloud authority | C-005, C-002, C-004 |
| Compromised wallet repo/automation identity | Label-triggered PR into release boundary | Publish trusted wallet update and steal delegated keys | C-008, amplified by C-009 |
| Compromised writer/App/deploy key | Unprotected release tag | Publish official signed node/container code; steal operator or service authority | C-006 |
| Stolen delegated wallet key | Scoped portal call plus pre-existing root allowance | Move more value than the key's nominal token budget | C-003 |
| Cloud/SaaS deployment compromise | Trusted auth, sponsor, explorer, verifier, or wallet origin | Misrepresent transaction intent or obtain broader user authorization | C-002, C-004, C-001 |
| Observability credential compromise during another intrusion | Profiling/monitoring data plane | Reconnaissance or concealment | OBS-002 |

The most plausible Lazarus-style path is therefore not “scan an RPC port and exploit it.” It is: compromise a developer/vendor identity, use a normal-looking same-repository PR or release action to cross a CI trust boundary, establish persistence in cloud/release/update infrastructure, and convert that control into wallet-key or application-fund theft while using communications/observability access to delay response.

## 7. Remediation roadmap

### 0–7 days

- Privately scope-confirm and rotate the C-002/C-004/C-005 authorities after preserving logs. Confirm C-008 STS/environment reachability first, and rotate any implicated release authority only if exposure is established.
- Disable or gate secret-bearing PR workflows until untrusted-code separation is complete.
- Add protected tag rules and alerts; verify every current release tag is immutable and reachable from an approved commit.
- Revoke/rotate OBS-001/OBS-002 owner-side without authenticating public values.
- Confirm `auth.tempo.xyz` project/domain history and inventory all SaaS-bound `tempo.xyz` names.

### 7–30 days

- Implement build-once/promote-after-review pipelines with clean base-controlled deployers.
- Separate preview/production accounts, wallet signing/storage, and release identities; reduce token scope and lifetime.
- Require two-person approval for production deployment, release signing, tag creation, DNS/domain binding, and break-glass recovery.
- Preserve wallet policy optionality and make unrestricted delegated authority explicit and accurately observable.
- Decide and test the allowance/delegated-limit security invariant across Zone flows.

### 30–90 days

- Add organization-wide policy-as-code for workflow triggers, action pinning, permissions, environments, runners, and artifact provenance.
- Continuously reconcile release subjects, signatures, container digests, R2 object versions, package owners, and client update metadata to reviewed commits.
- Correlate GitHub, cloud, IdP, email, Slack, signing, DNS, and on-chain audit streams around identity and recovery changes.
- Pin deployed protocol revisions, native bytecode, privileged roles, validator/recovery controls, and cross-system invariants.
- Add adversarial cross-repository tests for wallet issuance/display, allowance composition, and transaction serialization.

## 8. Evidence index

All linked transcripts are sanitized: real credential values, exploit payloads, personal data, and state-changing instructions are excluded.

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
| [finding current-head freshness](evidence/2026-08-23-finding-freshness.txt) | Fresh public source plus current-head local regression | C-006, C-008, C-009 current applicability |
| [contract test baseline](evidence/2026-08-23-contract-test-baseline.txt) | Complete checked-in suites and focused probes | Protocol/contract assurance |
| [contract-finding freshness](evidence/2026-08-23-contract-finding-freshness.txt) | Current-head Git object/source comparison | C-003, C-007 current applicability |
| [public-repository secret scan](evidence/2026-08-23-public-repository-secret-scan.txt) | Full-history non-verifying scan and manual triage | OBS-001, OBS-002 |

Supporting living documents: [`SURFACE.md`](SURFACE.md), [`FINDINGS.md`](FINDINGS.md), [`SCOPE.md`](SCOPE.md), and [`recon/`](recon/).

## 9. Final assessment

Tempo's public architecture shows meaningful controls—protected important branches, required checks, a security policy, pinned actions in several paths, artifact checksums/signatures/provenance, and extensive protocol component testing. The remaining risk is concentrated where those controls do not compose: protected merge paths coexist with privileged execution of trusted writers' unmerged code; signed releases coexist with apparently less-protected tag creation; delegated limits coexist with allowance-backed calls; and canonical wallet authority is collapsed in local audit output.

The fastest material reduction in theft risk is to make **reviewed immutable provenance** the required input to every cloud deployment, release signature, wallet update, and financial-key operation, then monitor those boundaries as one joined control plane rather than separate GitHub, cloud, wallet, and on-chain systems.
