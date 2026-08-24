# MPP Economic-Security Audit

**Date:** 2026-08-24<br>
**Task:** T-012<br>
**Mode:** public source and metadata review, passive chain reads, and dummy/local testing only

## Result

The strongest agent-skimming candidate is C-010: a malicious or compromised paid endpoint can turn MPP streaming headroom into an immediately enforceable claim for undelivered value. The protocol necessarily gives one side a small fair-exchange option when a plaintext stream is paid incrementally, but the current TypeScript and Rust clients let the server choose the cumulative authorization boundary. In the TypeScript reference stack, exported and scheduled settlement then submit the highest signed voucher rather than the server's recorded consumption.

Two local TypeScript PoCs reproduced the composition at current `wevm/mppx` head: the real managed SSE client signed a valid voucher for a 100-unit deposit before receiving any application message, and the real exported settlement helper submitted 100 while the supplied server record said one unit was spent. A separate Rust PoC produced and verified a full-deposit voucher through the helper used by streaming clients; existing Rust tests also intentionally accept a cooperative-close amount far above recorded spend.

The raw server-controlled voucher jump was already identified publicly during mppx PR #510 and must not be claimed as novel. The potentially new issue is its composition with the current ordinary/scheduled `settle(highestVoucher)` path, which recreates the high-water overcharge invariant that mppx PR #196 fixed for cooperative close. No evidence establishes whether Tempo already knows, accepts, or has privately mitigated this composition.

A second retained candidate, C-011, faces the other direction: the current and released Rust SDK can authenticate multiple concurrent paid HTTP requests with the same valid voucher while durable credit advances once. The bundled multi-fetch pattern then delivers protected content for every success. This is service theft by a dishonest payer rather than theft from an agent, but it is a concrete TOCTOU left after prior replay/store fixes.

The simpler merchant-side candidate is C-012: the same released multi-fetch integration advertises 10,000 base units per page but configures a zero minimum voucher delta and never debits authenticated request cost. A full-verifier PoC started with prior authorization fully consumed and showed that a valid one-unit increment still satisfies the content-success predicate. Static source then releases the nominal 10,000-unit response.

## Pinned surface

| Component | Revision reviewed | Role and result |
| --- | --- | --- |
| `tempoxyz/mpp` | `0cb05db7c4fb6d1ea13d09345942487fa72fb255` | MPP documentation/meta surface and integration index |
| `tempoxyz/mpp-specs` | `6de3b4d5d13b4a80310bd80e021c02a4126428e2` | Normative streaming order, voucher format, close rule, threat model |
| `wevm/mppx` | `3f73a17eeba9522d90894099635a43d6d2934cf5` | TypeScript reference client/server; C-010 composition locally reproduced |
| `mppx@0.8.19` | tag `e2e8e375db4bb0ba4d8686138a658d2132ace5b7` | Released package retains both server-directed signing and high-water settlement |
| `mppx@0.8.15` | tag `ae3548dd3ec40e6b4a024fa72819d8411246025e` | Version locked by the current OpenClaw plugin; retains the same behavior |
| `tempoxyz/mpp-rs` | `fadc88c044b9f8700b58d275bb659d403b231e07` | Rust streaming parity plus released HTTP unit-price and concurrency candidates reproduced |
| `tempoxyz/mpp-go` | `8dd5e00a620cfb2defc9743141a7067d4708cc1c` | No concrete Tempo streaming-session implementation found |
| `tempoxyz/pympp` | `4e5283efcc4b2c5cfed1cb544d53aef1a122fb31` | Generic intent registration and MCP retries, but no concrete Tempo streaming-session implementation found |
| `tempoxyz/mpp-tools` | `ed290d6eedf8b9f91afb34d46c7195c8e30311f9` | Cross-SDK core/charge conformance; does not assert streaming economic invariants |
| `tempoxyz/hermes-mpp` | `5a453e8cf2437d4dc9f8e4bfd21f9dfa42700b7e` | Agent/service integration searched for session construction and payment limits; no separate retained path |
| `tempoxyz/openclaw-mpp` | `4e30d5677145c5e5c4aebd1c7a3d372f072db419` | Agent-facing payment-aware fetch; locks mppx 0.8.15 and supplies no `maxDeposit` |
| `tempoxyz/mpp-irl` | `20079f6fe6a45ce53f70187712662cd1870c43d0` | Example/integration surface searched for session construction and caps; deployment not inferred |
| `tempoxyz/mpp-e2b` | `9979cb61127b0e8925c1bf71aad63bbfbf93e7ce` | E2B integration searched for payment-session reachability; no separate retained path |
| `tempoxyz/mpp-proxy-cf` | `4f86d874687e6c39442777d452c364474a41748c` | Cloudflare proxy integration searched for payment and retry boundaries; no separate retained path |
| `tempoxyz/tempo-maybe-pay` | `293d802d3af14624cdd89d3c50403fdbd7ff76ca` | Example agent-payment integration searched; example presence not treated as deployment |
| `tempoxyz/agents-tempo-xyz` | `f0c15788448cda8fc1290a5fd0d9f367a18cd90c` | Agent examples searched for automatic session reachability and configured budgets |
| `tempoxyz/wallet-cli` | `bf3c874e9e851c72e2fc48d916d06bf69304b874` | Uses mppx 0.8.14 but computes its CLI voucher increment locally; not classified as the same automatic-stream reachability |
| `tempoxyz/tempo` | `18c174325061fa07ef577ef3fd59f5a7869bd556` | Current public TIP-1034 reserve source; deployed bytecode identity not pinned |

Example code is not treated as deployed simply because it exists.

## Economic state model

For one channel, keep five monetary ledgers distinct:

- `D`: verified on-chain deposit;
- `A`: highest cumulative voucher signed by the payer;
- `V`: value actually delivered and owed;
- `T`: value durably recorded as consumed (`spent`), which can lead delivery by one window or after a failure;
- `S`: cumulative amount already settled on-chain.

For each request or stream window, also keep `C`: the server-owned authenticated cost of the value about to be delivered. `C` is not a cumulative ledger, but it must be reconciled with available authorization and `T` before release.

The intended streaming order is:

```text
quote and channel D
  -> payer signs cumulative authorization A
  -> server persists A
  -> server records the next consumed window in T
  -> server emits the application window
  -> delivered/owed value V catches up
  -> payee may advance on-chain settlement S
```

Ordinary plaintext delivery cannot make every arrow atomic. If content is sent before payment, a payer can stop after receiving a free window. If authorization is signed first, a payee can withhold a paid window. MPP chooses the latter and can only bound that inherent option through small windows and idempotent delivery.

The avoidable safety properties are:

```text
A - V <= locally approved delivery-risk window
S <= V
top-up <= locally approved budget
server hints do not increase any client-side bound
A - T >= C before a merchant releases the current response
T advances by C in the same linearizable success condition as delivery authorization
```

C-010 violates the first property at signing time and the second at settlement time. C-012 violates the request-cost properties; C-011 violates their single-winner/concurrency requirement.

## C-010 composition

### 1. The server obtains the option before delivery

The session specification requires the voucher to be accepted and persisted before corresponding service, and permits settlement at any time. A voucher signs only `channelId` and `cumulativeAmount`; it has no quote, unit count, request, resource, delivery proof, or expiry. A payer's forced-close request starts a 900-second grace period rather than revoking an existing voucher.

This is analogous to an American-style free option: after receiving authorization `A`, the payee can choose whether and when to perform its side of the exchange, while retaining an enforceable claim up to `A`. With an honest small-window policy, the option value is approximately one chunk. It becomes material when the counterparty can choose `A`.

### 2. Managed clients let the server choose the high-water mark

In mppx, `resolveNeedVoucherContext` accepts the SSE/WebSocket `requiredCumulative`, checks only the channel and optional absolute cap, performs a server-influenced top-up if needed, and returns that cumulative amount for signing. `maxDeposit` is optional, and absence is represented as uncapped. There is no check against locally observed delivered units multiplied by the quoted unit price.

The Rust streaming helper follows the same model. The focused Rust PoC began at cumulative 1,000 with price 1,000 and deposit/cap 10,000; a server request for 10,000 produced a valid full-deposit EIP-712 voucher.

### 3. Settlement exercises the full option

The mppx `settle()` helper loads `channel.highestVoucher.cumulativeAmount` and submits it to TIP-1034. `maybeSettleScheduled()` invokes the same helper. It does not clamp the transaction to `channel.spent`. The local settlement PoC supplied `highestVoucher=100` and `spent=1`; the helper called the chain layer with 100.

Current public TIP-1034 source checks that the voucher amount is increasing, no greater than the deposit, and correctly signed, then transfers the delta to the payee. It has no knowledge of quote, units, `spent`, or delivery. Passive calls on 2026-08-24 observed the native marker and expected 900-second grace-period/type-hash interface at `0x4D50500000000000000000000000000000000000` on mainnet (chain `4217`) and Moderato (`42431`). Those reads do not pin deployed bytecode to the reviewed source. No transaction or state change was made.

### 4. Loss bound

The total enforceable excess over delivered value is:

```text
totalExcess = max(0, A - V)
```

The additional excess still collectible after current settlement is:

```text
remainingExcess = max(0, A - max(V, S))
```

With a correctly enforced local cap `M`, the bounds for the current deposit are:

```text
totalExcess <= max(0, min(D, M) - V)
remainingExcess <= max(0, min(D, M) - max(V, S))
```

Without a cap, the current deposit is the immediate bound. Automatic top-up can enlarge `D` in response to the same server-selected requirement, so the practical multi-step ceiling approaches the payer's available token balance, subject to transaction success and integer bounds.

## Agent-facing reachability

The current OpenClaw MPP plugin constructs mppx with a persistent channel store and no `maxDeposit`, then exposes `mpp_fetch`, which drains response streams and therefore processes payment-control events during an ordinary agent tool call. Its lockfile resolves mppx 0.8.15, where both halves of C-010 are present.

The plugin's normal setup creates a seven-day access key with a total `USDC=10` limit. That is a meaningful default loss bound, not a fix for the channel invariant. A custom larger policy raises the ceiling, and the supported raw-private-key configuration does not inherit the setup key's $10 limit. No OpenClaw instance, live endpoint, wallet, or payment was exercised.

The current wallet CLI was not classified as automatically reachable through the same path: although it depends on an affected mppx release, its reviewed command path computes the next voucher increment from advertised price and local state and can apply `maxSpend`. Reachability must be established per integration rather than inferred from dependency presence.

## C-012: authenticated request price is not charged by the Rust multi-fetch pattern

The bundled Rust multi-fetch example advertises `amount=10000` and `unitType=page` but constructs the session method with `min_voucher_delta=0`. `Mpp::verify_session` authenticates the challenge and checks currency/recipient, while the voucher branch validates channel state, signature, deposit, monotonicity, and only the configured minimum delta. It does not compare the increment or available unspent authorization with `SessionRequest.amount`, and the handler does not call the atomic `deduct_from_channel` helper before returning content.

The deterministic full-path PoC began with `highest=spent=10000`, so no prepaid balance remained. It created an HMAC-bound 10,000-unit challenge and presented a valid cumulative-10,001 voucher. Real request parsing, signature verification, mocked `getChannel` ABI decoding, and `Mpp::verify_session` succeeded; only one unspent unit remained and `spent` was unchanged. The test reproduced the handler's non-management-success predicate, while source shows the handler releases protected content for each such result.

For advertised response cost `P` and accepted increment `d`, uncompensated service value per response is `P-d`. The shipped values allow 9,999 units, or 99.99%, underpayment without concurrency. The example and relevant voucher path are present at current head and published v0.11.0.

This is scoped to the bundled fixed-price HTTP example and similar bare-`verify_session` consumers with `minVoucherDelta < request cost`. The Tempo draft requires the application to compute cost, ensure `acceptedCumulative-spent` is sufficient, and persist `spent += cost` before or atomically with delivery. Rust SSE/WebSocket and current mppx HTTP paths perform charging steps and were not shown affected. Public GHSA `GHSA-fxc9-7j2w-vx54` fixed adjacent free-session issues but did not add the missing request-cost debit; private awareness and production adoption remain unknown.

## C-011: concurrent voucher acceptance can deliver multiple paid responses

At mpp-rs head and published v0.11.0, voucher replay/minimum-delta checks run against a channel snapshot obtained before the atomic store update. Two concurrent requests can validate the same newly incremented signed voucher against the same old snapshot. The update winner advances `highest_voucher_amount`; the loser observes that the amount is no longer higher but returns the current state as a successful no-op. Both calls then receive success receipts.

The bundled `examples/session/multi-fetch` handler treats each `verify_session` success as authorization to compute and return one protected response, without atomically debiting `spent` before delivery. The focused test used a real signed voucher, forced two concurrent verifier calls, observed two delivery-gate successes, and confirmed that durable cumulative credit advanced from 1,000 to 2,000 only once.

For `N` calls that capture the old snapshot, up to `N` responses may be delivered for one accepted increment `delta`. If each response has value `P`, uncompensated exposure is `max(0, N*P-delta)`; when the increment correctly prices one response (`delta=P`), the race-only duplicate loss is `(N-1)*P`. The dishonest payer needs its own funded channel and signer, not a forged signature or someone else's key. The exact timing/concurrency bound and production use of this example pattern remain unknown.

This specific path does not apply to the bundled SSE and WebSocket servers, which atomically deduct before each event/frame, or to an application that performs a linearizable per-request debit before delivery. The current draft requires serialized voucher/balance updates and spend persistence before or atomically with delivery. Exact management-voucher retries can remain idempotent, but a losing compare-and-swap/no-op cannot authorize a fresh metered response.

Public history includes an earlier multi-payment GHSA, store serialization in PR #177, and sequential replay rejection in PR #247. C-011 succeeds with a serialized store because the losing transition is deliberately reported as success, making it a surviving TOCTOU rather than the previously fixed raw store race.

## Specification contradiction and prior art

The session draft promises incremental payment “exactly for resources received,” but its persistence order necessarily permits one paid-but-undelivered window. It explicitly says cooperative close must capture `max(spent, settledOnChain)` and must not capture more than consumed, yet it does not extend that rule to ordinary settlement.

Public history narrows the novelty claim:

- [mppx PR #196](https://github.com/wevm/mppx/pull/196), merged 2026-03-18, fixed cooperative close after documenting a 3,000,000 authorization, 500,000 spend, and 2,500,000 overcharge.
- [mppx PR #510](https://github.com/wevm/mppx/pull/510), merged 2026-06-09, introduced the current TIP-1034 session stack and the ordinary/scheduled high-water settlement helper.
- [A public review comment on PR #510](https://github.com/wevm/mppx/pull/510#discussion_r3377899233) already warned that a server could coerce vouchers up to the channel deposit, especially with an uncapped default.

The raw authorization problem is therefore known public prior art. Searches of public mppx issues, pull requests, and review discussion did not identify an explicit treatment of the current `settle(highestVoucher)` plus server-selected headroom composition. That absence is not proof that the security team is unaware.

## Tests and negative results

- Current mppx client and settlement PoCs passed in network-disabled mode. The voucher signature was independently verified and the settlement call was captured at the chain boundary.
- The current mppx session run completed with 648 passing, 13 failing, and 13 skipped tests. Twelve failures were sandbox socket-bind denials; the remaining transient WebSocket case passed alone. Both focused PoCs passed, but this environment does not support a blanket green-suite claim.
- Existing mppx SSE and WebSocket tests also confirm the irreducible one-window case: after a post-commit hook failure, `spent`/units remain incremented while no application message is emitted.
- The mpp-rs all-feature CI-equivalent run passed 1,160 library tests, 11 Stripe integration tests, five WebSocket integration tests, and 61 executed doctests, with zero failures. The green suite includes close-above-spent behavior; it does not assert the economic invariant.
- Sequential exact-voucher replay is rejected. C-011 demonstrates that concurrent calls can both pass before the winning atomic update, while the losing update is still reported as success.
- C-012's full-verifier PoC passes with prior authorization fully consumed, authenticated price 10,000, voucher growth one, available authorization one, and unchanged `spent`; no race is involved.
- mpp-rs also rejects an equal-highest exact voucher despite the current draft requiring a 200 idempotent response. A local retry model showed that, after an ambiguous lost response, a caller that abandons the rejected credential and signs the next cumulative voucher can authorize two request costs for one logical purchase when the application has no stable idempotency key. This is retained as an integration hazard and normative-conformance defect, not a standalone theft finding: exact replay cannot advance settlement, the default client returns an error rather than silently retrying, application retry is required, the draft already warns about this composition, and no deployed reachability was shown.
- Go and Python expose generic session intent concepts but do not implement the reviewed Tempo streaming voucher state machine.
- No distinct machine-token-only theft primitive was confirmed. Its extra router authorization signs the same channel/cumulative pair, but contract-level swap/refund timing needs a separate reproduction before making an FX or atomic-swap claim.
- A top-up can cancel a pending forced close at the reserve layer, but no safe local reproduction established a remotely exploitable cancellation race in a released client.
- No claim was retained for cross-channel voucher replay: the voucher's channel ID binds payer, payee, token, signer, salt, chain, reserve, and opening context.

## Recommended fixes

1. Make a finite local session budget mandatory for managed clients. Default to one small window and require an explicit unsafe opt-in for uncapped operation.
2. Before every signature, enforce `newAuthorization <= locallyObservedDeliveredValue + configuredRiskWindow`. Do not treat a server receipt or `requiredCumulative` as delivery evidence.
3. Derive deposits and top-ups from the same local budget. Treat server snapshots and suggested/required amounts as untrusted hints.
4. Make ordinary and scheduled settlement refuse when `highestVoucher > spent`; obtain an exact-spend voucher or wait until consumption catches up.
5. Extend the specification's no-overcapture rule to every settlement path, not only cooperative close.
6. Add cross-SDK model/property tests over `D`, `A`, `V`, `T`, and `S`, including malicious jumps, reconnects, retries, concurrency, hook failures, forced close, and crash recovery.
7. For stronger fair exchange, consider ciphertext-first chunks with hashlocked key release. Quote/session/expiry binding improves attribution and limits stale options, but plaintext chunking can only bound the underlying asymmetry.
8. In Rust request/response integrations, combine voucher advancement, authenticated per-request cost validation, and `spent` debit in one linearizable transition; an underpriced request or losing concurrent transition must not cross the paid-delivery gate.

## Evidence and handling

Sanitized execution transcripts are [C-010 streaming overcapture](../evidence/2026-08-24-C-010-mpp-streaming-overcapture-poc.txt), [C-011 Rust voucher race](../evidence/2026-08-24-C-011-mpp-rust-voucher-race-poc.txt), and [C-012 Rust unit-price bypass](../evidence/2026-08-24-C-012-mpp-rust-unit-price-bypass-poc.txt). Detailed test patches and analysis remain ignored under `findings/`. No live credential, deceptive agent interaction, production request beyond passive JSON-RPC reads, transaction submission, or external disclosure occurred.
