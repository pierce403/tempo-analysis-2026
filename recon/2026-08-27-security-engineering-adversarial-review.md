# Security-Engineering Adversarial Review

**Date:** 2026-08-27<br>
**Task:** T-015<br>
**Mode:** public metadata/source review and local dummy or unit testing only<br>
**Evidence:** [timestamped execution and source record](../evidence/2026-08-27-T-015-security-engineering-review.txt)

## Result

The proposed mental map is directionally useful, but public-history reach changes the emphasis:

| Engineer | Evidence-backed public pattern | Important correction |
| --- | --- | --- |
| 0xalpharush | Zones settlement, authenticated observations, privileges, incident response, enclave hardening | Several cited hardening designs are closed-unmerged or still open. The full immutable `BatchPlan`, exact timestamp equality, lockdown command, and enforce-on-submit solvency gates are not current-main behavior. |
| horsefacts | Tempo invariant rigor and MPP authorization | This is a concentrated February–April 2026 public cluster, not evidence of a current August assignment. Twelve Tempo test changes landed; eight did not. mpp-rs #188 is the clear production fix. |
| grandizzy | Checker/tooling architecture, fuzz reliability, DEX/accounting, transactional storage | Much of the freshest work remains open: checker isolation #1289, DEX parity #6614, scfuzzbench timeout scaling #35, and accounts #747 are not on their default branches. |

No new theft-relevant protocol vulnerability was validated. The strongest concrete new result is a low/informational trust-boundary qualification: the observe-only Zone checker authenticates headers and receipts, but its Portal custody decision accepts an `eth_call` balance without verifying a state proof. A compromised or faulty Tempo RPC can therefore suppress or fabricate the auxiliary solvency signal. This does not alter custody, execution, or consensus, and Tempo execution is explicitly documented as trusted. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

The strongest assurance gaps are test systems that can remain green for the wrong reason: Tempo's over-gas-cap invariant records but never requires the correctly classified rejection; the FeeAMM first-mint boundary handler accepts the opposite outcome in both directions; and scfuzzbench maps a Foundry replay timeout to success before upload. These are security-test or benchmark defects, not proof of corresponding protocol bugs. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

Focused negative results were equally useful: DEX #6614 passed nine parity tests including a 500-case fragmented-book property test; #2659's combined FeeAMM obligation invariant exercised its fee path in 10 runs × 50 calls; mpp-rs #188 binds every action variant present at its merge; and the current Zones timestamp test confirms intentional `zone timestamp >= authenticated Tempo anchor` behavior. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

## Cross-domain state-transition map

| Property | Current or reviewed control | Residual question |
| --- | --- | --- |
| Authenticated inputs | Current Zones replication verifies finalized header/receipt relationships and exact anchor coordinates. The checker independently decodes authenticated Portal logs. | Restart settlement recovery retains one raw-log edge; checker custody is RPC-trusted rather than state-proof authenticated. Both are availability/monitoring concerns under the documented trusted-RPC model. |
| Immutable snapshot | Current settlement signatures bind the Zone/set/height/withdrawal index/verifier, Tempo and anchor hashes, transitions, and configuration; metadata is gathered together. | [Zones #822](https://github.com/tempoxyz/zones/pull/822)'s complete immutable plan was closed-unmerged. Current controls are narrower than that proposal. |
| Solvency | Withdrawal-fee caps landed; manual fixed-snapshot accounting and the merged observe-only checker compare custody with derived liabilities. | [#720](https://github.com/tempoxyz/zones/pull/720) closed and [#797](https://github.com/tempoxyz/zones/pull/797) remains open. Current main has no equivalent enforce-on-submit assets-versus-liabilities gate. |
| Privilege boundary | Typed Portal roles/capabilities and sequencer-role mirroring from [tempo #7171](https://github.com/tempoxyz/tempo/pull/7171) and [#7175](https://github.com/tempoxyz/tempo/pull/7175) are in current Tempo and the Zones-pinned dependency. | Separate-encryption-key [#1108](https://github.com/tempoxyz/zones/pull/1108) remains open and is stale relative to safer current key-input plumbing; [#1114](https://github.com/tempoxyz/zones/pull/1114) closed, though successor pause/rotation tooling landed. |
| Incident response | Current Portal pause/rotation code has explicit caller boundaries, bounded pause, simulation/readback, and withdrawal blocking. | Batch submission intentionally remains available while paused and the verifier is still a prototype stub; threshold signatures and stopped payouts constrain this known architecture risk. |
| Time anchor | Current Zones code requires the Zone timestamp at or after the authenticated Tempo anchor; Tempo consensus separately enforces parent monotonicity and future drift. | Exact equality from [#1155](https://github.com/tempoxyz/zones/pull/1155) did not remain. The prose specification still describing equality is documentation drift. |

This matrix is a source/revision assessment, not deployment proof. Exact pins, file locations, ancestry, and local commands are in the [execution record](../evidence/2026-08-27-T-015-security-engineering-review.txt).

## Retained observations

### OBS-003 — Zone checker custody is RPC-trusted

The current checker and open [zones #1289](https://github.com/tempoxyz/zones/pull/1289) retain authenticated receipt evidence but perform Portal `balanceOf` through a historical `eth_call`. `requireCanonical` asks an honest server for a canonical block; it does not authenticate the value a Byzantine server returns. The focused mock supplied only an arbitrary ABI balance, with no header or account/storage proof, and the real helper accepted it at both revisions. Full patched library suites remained green: 60/60 on current main and 77/77 on #1289. ([evidence and patch](../evidence/2026-08-27-T-015-security-engineering-review.txt))

A false-high value can hide a real checker shortfall; a false-low value can create a durable false divergence. The impact is monitoring integrity and detection delay, not creation of insolvency. README language explicitly treats Tempo consensus/execution as trusted and says the checker does not re-execute Tempo. A public #1216 reviewer had already raised the broader shared-RPC trust concern, so this is a concrete refinement of adjacent prior art rather than a standalone novel vulnerability. ([public review](https://github.com/tempoxyz/zones/pull/1216#discussion_r3846435907); [evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

The strongest fix is to retain the authenticated header's state root, obtain the TIP-20 account/storage proof, and derive the Portal balance only after locally verifying that proof. An independently operated node or provider quorum improves resilience but is not cryptographically equivalent. At minimum, documentation should call the value “RPC-trusted custody,” not proof-authenticated custody. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

### Checker omitted-account coverage

The checker reads every enabled token's supply but rereads account balances only for accounts named by decoded `Transfer` logs. A real-module witness showed that the accounting layer accepts the same total supply with no candidate account balances even when its durable ledger attributes all value to Alice; it has no observation with which to discover a supply-conserving Alice-to-Bob state reassignment. ([evidence and patch](../evidence/2026-08-27-T-015-security-engineering-review.txt))

This is a documented coverage boundary, not a demonstrated user path. It becomes relevant only if an execution defect or malicious transition changes balances without canonical `Transfer` logs. Normal modeled TIP-20 paths name the affected accounts, and observe mode remains fail-open relative to consensus. A future mutation suite should inject silent balance writes and state explicitly whether detecting them is in scope. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

### Security-test false-green conditions

- `BlockGasLimits.t.sol` increments `ghost_txOverCapRejected` only for the expected cap error, but the invariant never consumes that counter. An unrelated revert can therefore make the property look green. This remains current after horsefacts' #2599 discrimination change. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- `FeeAMM.t.sol::tryFirstMintBoundary` accepts the boundary mint succeeding and accepts broad known errors when the above-boundary mint should succeed. `_totalMints` is not a reachability gate. Direct unit coverage currently tests the correct implementation behavior, so this is redundant-oracle weakness rather than evidence of a live AMM defect. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- StablecoinDEX DEX6 still skips balance assertions whenever the actor has any active order, and DEX7 quote equality remains commented. These are explicit blind spots around open-order/self-trade state, not a confirmed DEX defect. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- scfuzzbench's current Foundry showmap path caps replay at 1,800 seconds, while the generic wrapper converts timeout 124 to success. A one-second dummy probe returned zero after timing out. Open #35 scales the limit but retains the success normalization. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

The common correction is to make the positive witness part of the property: distinguish expected reject, unexpected reject, expected success, wrong success, timeout/partial result, and unexercised state. Mutation tests should prove that each wrong outcome fails the harness. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

### Unresolved availability hardening

One source-only prover availability-hardening question emerged, but its mechanism, deployment routing, authentication, and Nitro behavior were not validated. It remains in ignored scratch pending a bounded local harness and owner-side exposure confirmation; it is not a tracked finding. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

Open checker #1289 substantially improves isolation, replay, Finish gating, and fail-closed reorg behavior. A public post-head review still questions whether fail-fast concurrent RPC batches can abandon dispatched WebSocket requests that Alloy later replays. That comment was not locally reproduced and remains an open review item, not a finding. ([zones #1289](https://github.com/tempoxyz/zones/pull/1289); [evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

## 0xalpharush track

### What is current

- Receipt-root-authenticated Portal observations and exact anchor validation are present in current Zones replication. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- Narrow snapshot/binding successors to #822 landed, but not the complete immutable `BatchPlan`. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- Typed Portal roles and sequencer-role mirroring from Tempo #7171/#7175 reach current source. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- Pause, readback, and role-rotation tooling landed through successors to closed #1114. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- Fee caps and observe/manual solvency checks exist; enforcement proposals #720/#797 do not. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

### What the adversarial pass rejected or bounded

- The old exact-anchor theory is not current. The pinned test accepts a later Zone timestamp, while consensus still applies future-drift and monotonicity rules. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- Closed #775's stale-context expected-red test did not model the current committed transaction path. It is not evidence of a live bug. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- Raw restart recovery logs are a defense-in-depth availability concern under a Byzantine RPC; local hash/queue/on-chain validation prevented a credible forged-withdrawal path. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- The always-true verifier test confirms a declared prototype stub. It is vacuous as proof-soundness evidence but does not bypass the separate threshold certificate in the reviewed flow. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))
- Open #1108 would regress secret handling if merged in its stale command-line form; current rotation code uses environment/file-backed input. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

## horsefacts track

GitHub's public query returned 22 horsefacts-authored `tempoxyz` PRs created in 2026: 20 Tempo PRs in February, mpp-rs #188 in April, and accounts #184 later that month. No later authored PR appeared. This corrects “current focus” to “public historical specialization”; it says nothing about private work. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

Twelve of the Tempo changes remain ancestral to current main, and all twelve are test/spec-verification changes. Eight closed without merge. In particular, #2604 did not land; #2659 superseded it. The exact #2659 merge ran 500 invariant calls with its fee-collection path exercised and no failure. Its combined reserve-plus-fee obligation is sound within the harness's bounded actor/token universe. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

#2661 improves diagnostic attribution by separating revoked and expired counters. It does not repair mathematical masking: the previous shared counter was monotonic and zero-checked, so either prohibited success already failed. Both current paths could still be vacuous unless a positive attempt/classified-rejection reach property is added. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

#2595 repaired a permanently disabled DEX6 handler but retained an active-order skip. #2599 classified the expected gas-cap error but did not require observing it. This is exactly the distinction horsefacts' work invites: a better diagnostic is not necessarily a non-vacuous invariant. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

[mpp-rs #188](https://github.com/tempoxyz/mpp-rs/pull/188) is the production security fix in this set. At its merge there were four credential actions—Open, TopUp, Voucher, and Close—and central dispatch passed challenge-derived expected payee and token into all four. No missed fifth action or unbound current variant was found. Release inclusion is confirmed; production consumer adoption is not. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

## grandizzy track

[Tempo #6614](https://github.com/tempoxyz/tempo/pull/6614) makes T11 quotes and execution walk the same resting orders with the same per-order rounding functions. Nine focused tests passed, including fragmented books, boundary ticks, state side effects, exhaustion, tight slippage, and a 500-case property test. No independent T11 rounding path remained. The result is strong branch-head evidence, but the PR is still open and not current-main behavior. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

The merged checker [#1216](https://github.com/tempoxyz/zones/pull/1216) creates a useful independent accounting view, while open [#1289](https://github.com/tempoxyz/zones/pull/1289) improves its operational isolation. Its precise independence boundary is narrower than “independent truth”: Zone accounting is rederived, Zone state is read locally, authenticated logs are decoded, and Tempo execution/RPC custody remains trusted. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

Zones #546 landed a smaller symbolic/coverage base. The much larger #557/#887 lifecycle, solvency, sequencer, and real-DEX expansions closed without merge; current router tests still use a mock DEX. Treating those branches as current coverage would overstate assurance. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

[Accounts #747](https://github.com/tempoxyz/accounts/pull/747)'s participating-writer design survived 20 core cases and 11 distinct storage cases across isolated runs, plus a direct local lock/unlock probe. The cross-process storage case did not complete. No stale-credential resurrection was reproduced. It remains open; advisory locking, parent-directory durability, the uncompleted contention case, and native-addon packaging/smoke remain explicit gates before calling it shipped. ([evidence](../evidence/2026-08-27-T-015-security-engineering-review.txt))

## Next bounded work

1. Ask the checker owner whether resilience to a faulty/compromised Tempo RPC is an intended property. If yes, add state-root-bound balance proof verification and a regression in which the RPC claims a false-high custody value.
2. Add mutation gates to the gas-cap and FeeAMM handlers so wrong success, wrong revert, and unexercised paths each fail deterministically.
3. Make scfuzzbench represent replay timeout as incomplete/failed evidence; do not upload it as a successful complete run.
4. Finish review/landing decisions for #1289 and #6614, then rerun the exact suites on their merge commits rather than branch heads.
5. Use a bounded localhost-only harness for the unresolved prover availability question; do not test a deployed enclave or external endpoint without explicit authorization.
6. Keep full enforced solvency and immutable transition planning as explicit architecture gaps until equivalent code actually reaches main and deployment.

No external disclosure or production interaction was performed. The [evidence record](../evidence/2026-08-27-T-015-security-engineering-review.txt) contains the exact revisions, commands, executed results, harness failures, and safety limits.
