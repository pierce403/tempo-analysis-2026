# Theft-Focused Threat Model

## Purpose

Prioritize attack paths resembling those historically favored by sophisticated financially motivated operators, including Lazarus Group: abuse of trusted access, developer or release compromise, third-party compromise, deceptive authorization, and conversion of technical access into transferable value.

This is a behavioral lens, not an attribution claim. A technique's resemblance to a known group's tradecraft does not identify an actor or prove exploitability.

## Primary adversary objective

Steal or gain durable control over stablecoins, tokenized deposits, fees, reserves, signing authority, issuer privileges, exchange balances, or credentials that can later be converted into those assets.

Availability, privacy, and integrity issues are prioritized when they facilitate theft, concealment, coercive recovery, market manipulation, or compromise of a more valuable trust boundary. Pure vandalism and generalized denial of service are lower priority.

## Priority intrusion-to-theft chains

### 1. Trusted human or insider access

Potential footholds include employees, contractors, validator operators, release engineers, support personnel, and personnel at critical vendors.

Research questions:

- Which roles can alter code, releases, deployments, DNS, packages, apps, policy contracts, token controls, validators, or incident recovery?
- Which sensitive actions require independent approval, hardware-backed authentication, timelocks, or observable on-chain confirmation?
- Can a legitimate but compromised role create a durable second foothold or suppress evidence?
- Which emergency processes deliberately weaken normal controls?

The passive phase maps roles and controls. It does not target or test people.

### 2. Developer workstation and source-control compromise

Potential outcomes include malicious commits, workflow edits, dependency substitution, token theft, review bypass, and tampered build inputs.

Research questions:

- Are protected paths, reviews, CODEOWNERS, branch rules, and release workflows aligned with the highest-impact code?
- Can pull-request code obtain secrets or influence privileged workflows?
- Are actions and dependencies pinned, releases reproducible, and artifacts tied to reviewed commits?
- Can archived forks, examples, typo-prone packages, or deprecated SDKs remain in an active dependency path?

### 3. Build, package, and release compromise

Potential targets include GitHub Actions, registries, containers, installers, update channels, signed binaries, SDK packages, and the Ledger application.

Research questions:

- What identity signs each artifact and what protects that identity?
- Can provenance, checksums, signatures, or SBOMs be substituted together with the artifact?
- Do wallets, nodes, and operators fail safely on verification or update failure?
- Which production systems consume floating tags, branches, mutable images, or unpinned dependencies?

### 4. Web, wallet, and authorization deception

Potential outcomes include key/session theft, deceptive signatures, malicious transaction substitution, origin confusion, and abuse of passkeys, delegated keys, sponsorship, batching, scheduled calls, or parallel nonces.

Research questions:

- Does the signer display the actual authority, calls, assets, limits, sponsor, chain, and persistence being granted?
- Can compromised frontends, SDKs, RPC responses, indexers, or verification metadata induce a different signature than the user expects?
- Are WebAuthn origins, chain/domain separation, callbacks, embedded frames, and session recovery unambiguous?
- Can delegated authority be broadened, replayed, hidden in a batch, or retained after apparent revocation?

### 5. Third-party and integration compromise

Potential boundaries include issuers, bridges, custody/key-management services, wallets, RPC/CDN/DNS providers, contract verification, indexing, oracles, compliance providers, package registries, and payment partners.

Research questions:

- What authority or trusted data crosses each vendor boundary?
- Can one vendor compromise minting, redemption, routing, signing, display, deployment, or recovery?
- Are contradictory RPC/indexer/verifier/vendor views detected before a sensitive action?
- Are vendor credentials narrowly scoped, rotated, monitored, and independently revocable?

Unrelated third-party infrastructure remains out of scope. Review stops at Tempo's integration boundary unless separate authorization exists.

### 6. Privileged on-chain and operational control

Potential targets include TIP-20 issuer roles, TIP-403 policy managers, native contracts, fee conversion, DEX balances, validator admission, protocol upgrades, treasury/reserve operations, and incident controls.

Research questions:

- Which keys can mint, burn, freeze, redirect, upgrade, admit validators, change policy, or move escrowed/internal balances?
- Can compromised privileges be combined across contracts or administrative planes?
- Do timelocks, multisignatures, limits, monitoring, and emergency controls constrain theft before finality?
- Can unsafe recovery or inconsistent validator/operator state create an opportunity to authorize or conceal theft?

## Prioritization rubric

Score candidate surfaces qualitatively across:

- **Value access**: direct custody/control, authorization influence, or only indirect support
- **Trust**: unauthenticated, user-authorized, single privileged role, multi-party control
- **Reach**: one user, one issuer/integration, or system-wide
- **Stealth and persistence**: easy to detect/revoke versus durable and concealable
- **Conversion path**: clear route from compromise to movable value
- **Evidence quality**: speculation, source-supported, locally reproduced, or deployment-confirmed

High priority means a plausible and evidence-backed conversion to theft. Severity is not assigned from actor capability or scary branding alone.

## Research constraints

- No social engineering, credential testing, employee targeting, or malicious package/commit activity.
- No fund movement, privilege changes, persistent production state, or exploit validation on mainnet.
- Do not enumerate or test unrelated partner infrastructure.
- Keep candidate vulnerability details private and follow the current disclosure policy.

