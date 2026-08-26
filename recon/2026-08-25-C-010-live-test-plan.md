# C-010 Live-Test Plan

**Prepared:** 2026-08-25

**Status:** plan only; no active test authorized or executed

**Finding:** [C-010 — MPP streaming headroom can become payment for undelivered value](../FINDINGS.md#c-010--mpp-streaming-headroom-can-become-payment-for-undelivered-value)

**Existing evidence:** [sanitized local reproduction](../evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt)

## Purpose and decision boundary

The existing local TypeScript and Rust reproductions establish that reviewed managed clients can sign a server-selected cumulative authorization up to the channel limit before application delivery, and that the reviewed TypeScript ordinary/scheduled settlement path can submit the voucher high-water mark rather than recorded spend. A live test should answer only the remaining deployment questions:

1. Does an exact deployed client and server integration expose the reviewed path?
2. Can an authorized server request cumulative authorization greater than locally observed delivered value plus an explicitly approved risk window?
3. Is the resulting voucher valid and enforceable against a real, active test channel?
4. If settlement is separately authorized, can the payee settle more than the test service's durable delivered/owed value?

This document does **not** authorize a payment, signature, channel transaction, credential use, settlement, production request, or contact with a service owner. Every target remains a candidate until the authorization record below is complete. An indexed public endpoint is not implicit permission to test it.

## Required authorization record

Before any networked test beyond ordinary unauthenticated discovery, record all of the following in a private engagement artifact:

- asset owner and an owner representative who can authorize the test;
- exact origin, endpoint, environment, chain, and expected deployed revision;
- written permission for each intended action: fund payer, open channel, sign voucher, request an adversarial cumulative amount, settle, close, and retain evidence;
- start/end time, source addresses if relevant, request ceiling, and emergency contact;
- maximum channel deposit, maximum authorized cumulative amount, and maximum permitted realized transfer;
- whether testnet, owner staging, or production is approved;
- payer/payee key custody, test-token or real-token source, reimbursement/refund procedure, and evidence-retention rules;
- explicit confirmation that no unrelated tenant, customer, employee, or production data can be reached.

Missing or ambiguous authorization is a stop condition. Production testing additionally requires a separately approved settlement ceiling; permission to open a channel does not imply permission to settle an over-authorization.

## Preferred environments

### 1. Controlled Moderato harness — preferred

Run both payer and payee in a dedicated harness on Tempo Testnet (Moderato, chain ID `42431`). Use a faucet-funded disposable account and test `pathUSD`, not real funds. Tempo documents the faucet and `tempo_fundAddress` testnet RPC flow in its [faucet guide at `c7d1e8d`](https://github.com/tempoxyz/docs/blob/c7d1e8d937346918c59e90b5ac76bf2286d0b4f6/src/pages/docs/quickstart/faucet.mdx) and the network parameters in its [connection guide at the same revision](https://github.com/tempoxyz/docs/blob/c7d1e8d937346918c59e90b5ac76bf2286d0b4f6/src/pages/docs/quickstart/connection-details.mdx).

Pin one affected client revision already covered by the C-010 evidence before adding a current-head comparison. The malicious test server should be a purpose-built local or owner-controlled staging service. This variant proves the cross-layer mechanism without touching an unrelated merchant.

### 2. Owner-controlled staging clone — best deployment validation

Deploy the candidate merchant's exact production build and configuration to an isolated owner-controlled staging origin, substitute test recipient and payer keys, and use Moderato. Record the production-to-staging revision and configuration differences. This is the preferred way to establish whether a real integration exposes the path.

### 3. Authorized production canary — last resort

Use production only when the owner cannot reproduce the integration in staging and explicitly authorizes every transaction. Fund a new account with the exact TIP-20 token and decimals named by the live `402` challenge; do not assume that a token marketed as USDC has the same address or behavior as another USDC-like asset. Use the smallest accepted deposit, a finite client-side cap, and no other balance or authority on the key.

An honest endpoint may never issue an excessive authorization request. A negative production result would show only that the observed interaction behaved normally, not that the service would remain safe if compromised or that every client version is safe.

## Concrete controlled scenario

Use integer base units throughout. Let:

- `P` be the advertised price per delivered unit;
- `D` be the channel deposit;
- `R` be the explicitly approved client risk window;
- `A` be the highest signed cumulative authorization;
- `X` be durable delivered/owed value;
- `S` be cumulative on-chain settlement.

For a six-decimal test token, a minimal illustrative run is:

- `P = 1,000` base units (`0.001` token);
- `D = 10,000` base units (`0.01` token);
- `R = 1,000` base units (one priced unit);
- server-requested cumulative authorization `A = 10,000` before any application event;
- expected delivered/owed value at the decision point `X = 0`.

The authorized test sequence is:

1. Create fresh payer and payee keys used only for this run.
2. Fund the payer with test tokens; confirm both balances and the chain ID.
3. Start structured payer and merchant logs with secrets, raw private keys, and reusable credentials excluded.
4. Fetch the endpoint without a credential and preserve the `402` challenge, normalized price, token, decimals, recipient, escrow address, and expiry.
5. Open a real channel with deposit `D` and confirm the on-chain channel, payer, payee, token, authorized signer, and deposit.
6. Sign only the ordinary initial authorization required to begin the controlled session.
7. Before sending any application data, have the controlled server emit the protocol's voucher-renewal control event requesting cumulative `A = D`.
8. Record whether the exact client signs the requested amount, blocks it, clamps it to `X + R`, or requires user approval.
9. If a voucher is produced, verify its EIP-712 signature independently and confirm that it binds the real active channel and authorized signer.
10. Stop at the signature gate unless settlement was separately approved.
11. If testnet settlement is approved, submit the merchant's ordinary settlement path and record the requested amount, receipt, token balance delta, `S`, and merchant-recorded spend.
12. Close/finalize the channel, verify the refund or final balance, revoke/discard the keys, and preserve sanitized evidence.

Tempo's streamed-payment documentation at `c7d1e8d` describes deposit, channel opening, `payment-need-voucher`, automatic voucher renewal, periodic settlement, and close in this order: [Accept streamed payments](https://github.com/tempoxyz/docs/blob/c7d1e8d937346918c59e90b5ac76bf2286d0b4f6/src/pages/docs/guide/machine-payments/streamed-payments.mdx).

## Evidence and verdicts

Capture these artifacts with UTC timestamps and exact revisions:

- client/server package versions, lockfiles, source SHAs, runtime configuration, chain ID, and endpoint;
- redacted initial challenge and voucher-renewal control event;
- channel-open transaction and decoded channel state;
- application event count and bytes delivered before and after each authorization;
- every signed cumulative amount, independent signature-verification result, and client cap;
- server `spent`/units state, settlement input, transaction receipt, and before/after balances;
- close/finalization transaction and remaining/refunded balance;
- packet/application logs sufficient to order authorization, delivery, and settlement without retaining secrets.

Classify the result precisely:

- **Client authorization reproduced:** a valid voucher has `A > X + R` on an active channel before corresponding delivery.
- **Settlement composition reproduced:** the ordinary/scheduled merchant path selects `A` when durable spend is lower.
- **End-to-end testnet impact reproduced:** on-chain `S > X` after the approved settlement, with excess `S - X`.
- **Falsified for tested build/configuration:** the client rejects or clamps the request, or settlement refuses amounts above durable spend. This conclusion applies only to the pinned build and configuration.
- **Inconclusive:** the service does not exercise the relevant streaming control flow, deployed revision is unpinned, channel state is not enforceable, or evidence cannot distinguish authorization from delivery.

Never convert a signature-only result into a realized-loss claim. Never convert a normal interaction with an honest service into a general security claim.

## Safety and stop conditions

- Default to Moderato and faucet tokens. Do not bridge or purchase real assets for the controlled harness.
- Never reuse a personal, treasury, agent, or production wallet. The payer key must have no unrelated authority or balances.
- Enforce the cap independently of the client under test and abort if a requested or submitted amount exceeds it.
- One session, one channel, and one settlement attempt are the default ceiling. This is not a load, replay, fuzz, or concurrency test.
- Do not test unrelated authentication, employee/customer identifiers, or paid application functionality.
- Stop on target/version mismatch, unexpected redirect or chain, third-party data, cap failure, inability to close, owner request, or any effect outside the approved account pair.
- Do not publish service names as vulnerable without owner confirmation, reproducible evidence, and coordinated disclosure review.

## Potential targets from the mpp.ninja index

These are review candidates, not authorized targets. The index supplies advertised and time-specific runtime evidence; it does not establish affected client population, malicious behavior, deployment revision, or vulnerability.

### Target A — controlled affected-client harness

**Priority:** highest.

**Why:** directly exercises the C-010 client and settlement invariants while both parties and all funds are controlled.

**Environment:** Moderato with faucet test tokens.

**Readiness:** the repository already contains portable TypeScript and Rust fixtures for the affected client behavior; the missing element is a real test channel and controlled payee settlement.

**Gate:** create an isolated harness and pin the exact mppx/mpp-rs and Tempo reserve revisions before execution.

### Target B — owner-provided reference or production-equivalent staging service

**Priority:** high after owner coordination.

**Why:** answers deployed-integration reachability without probing a public merchant.

**Environment:** owner staging on Moderato.

**Gate:** obtain exact production revision/configuration mapping and written permission to issue the adversarial voucher request and optionally settle it.

### Candidate C — Remlo Payroll API balance stream

**Indexed surface:** `GET https://www.remlo.xyz/api/mpp/employee/balance/stream` in the [mpp.ninja service record](https://mpp.ninja/api/services/mppscan-7bde9a93e10ebb53e0e26fc9).

**Observation:** mpp.ninja recorded a valid Tempo session `402` at `2026-08-25T19:09:47.385Z`, amount `1,000`, unit type `second`, chain `4217`.

**Positive evidence:** the public repository contains an SSE route and an `mppx` session wrapper.

**Limiting evidence:** the public lockfile pins `mppx 0.4.7`, not the C-010-tested `0.8.15`/`0.8.19` revisions; the public wrapper does not by itself establish the later server-selected cumulative-authorization flow; and the public commit is not pinned to the live deployment. The route also reaches employee-related application logic, making isolation and owner staging mandatory.

**Disposition:** source/version clarification and owner-provided staging only. Do not run a paid or authenticated request against the public endpoint without written authorization.

### Candidate D — Dune execution-results session challenge

**Indexed surface:** `GET https://api.dune.com/api/v1/execution/:execution_id/results` in the [mpp.ninja service record](https://mpp.ninja/api/services/catalog-155720519a37efbdd4fd3089bf1d4b01da876e5698c9b3fa).

**Observation:** mpp.ninja recorded a valid Tempo session `402` at `2026-08-25T18:47:54.443Z`, chain `4217`, with a dynamic challenge and suggested deposit metadata.

**Limiting evidence:** the endpoint is not established as SSE or incrementally streamed, has no observed unit type, uses a placeholder execution identifier, exposes no implementation/version marker, and may represent a dynamic per-request session rather than the C-010 streaming control path.

**Disposition:** low-priority owner/source clarification. Do not create an execution, use an identifier, authenticate, pay, or open a channel against production without explicit Dune authorization.

### Other indexed Tempo-session offers

At the `2026-08-26T00:17:49Z` production-index snapshot, mpp.ninja contained 21 active Tempo-session offer rows representing 18 endpoints across nine services, but only the two candidates above had runtime-observed valid session challenges. Catalog/OpenAPI advertisement alone is insufficient to select an active target. Re-query the moving index immediately before any owner-coordination decision and retain the timestamped result.

## Recommended next action

Build Target A first and stop at the signature gate. If it reproduces against a real Moderato channel, request owner review of the affected client and settlement paths. Pursue Target B only with a production-equivalent staging mapping. Treat Candidates C and D as owner-contact questions, not public test invitations.
