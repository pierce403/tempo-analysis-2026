# Contract Test Baseline — 2026-08-21

## Purpose and boundary

This run established a reproducible local baseline for Tempo's public contract systems before treating static-review hypotheses as defects. It used pinned public source and local execution only. No transaction, RPC write, deployment, workflow dispatch, or production credential was used.

A green suite is evidence that the checked-in properties hold at the pinned revision; it is not evidence that the implementation is vulnerability-free.

## Zones Solidity runtime

- Repository: `tempoxyz/zones`
- Commit: `acaa6a6734860ecd81d7f01de3c973b068dca2ac`
- Commit time: `2026-08-21T09:58:04Z`
- Contract root: `crates/contracts`
- CI definition: `.github/workflows/contracts.yml`

### Exact toolchain

The stock local Forge build could not model this target: it did not support the configured `tempo:T8` hardfork, and its automatic compiler lookup was unavailable in the restricted environment. That was a toolchain failure, not a product-test failure.

The successful run mirrored the repository's pinned CI toolchain:

- Foundry commit `6902a96211da7bcc3d9c4d8e97910ac5c9d5d2c6`
- Foundry version `1.7.2-dev`
- Tempo patch source `18a5d71d6ab621433145e5ea86dfe3dbace0763a`
- Rust `1.97.0`
- Solidity `0.8.35`
- hardfork `tempo:T8`
- `via-ir = true`
- Z3 `4.13.3`
- locked Rust Tempo dependency `9f7fc9295ea3fa3b49ec2b0a9e524a8b2cb202b1`

The repository pins those Foundry and Tempo revisions in its contract workflow. A local Forge binary was built from the same revisions rather than substituting an upstream release.

### Complete checked-in Forge suite

Working directory: `target/protocol-zones/crates/contracts`

```sh
../../../foundry-tempo/target/release/forge test -vvv --match-path "test/**"
```

Result: **485 passed, 0 failed, 0 skipped across 13 suites**.

### Symbolic properties

```sh
../../../foundry-tempo/target/release/forge test \
  --symbolic --match-test "check_" \
  --symbolic-solver z3 --symbolic-timeout 180 -vvv
```

Result: **7 passed, 0 failed, 0 skipped across 3 suites**.

The symbolic set covers selected fee/gas bounds, withdrawal-queue behavior, and encrypted-deposit plaintext round trips. It is not a symbolic exploration of every authorization or asset-transfer path.

### Coverage and configured gate

```sh
../../../foundry-tempo/target/release/forge coverage \
  --ir-minimum --match-path "test/**" --exclude-tests --report summary
```

The coverage run executed the same **485 tests with 0 failures or skips**. Aggregate production coverage was:

- Lines: **95.78% (568/593)**
- Statements: **95.31% (630/661)**
- Branches: **79.58% (113/142)**
- Functions: **97.87% (92/94)**

The repository's production-source gate passed its configured minimums of 88% lines and 60% branches.

### Build-size check

```sh
../../../foundry-tempo/target/release/forge build --sizes
```

The build completed successfully. `ZonePortal` was the largest observed runtime at 23,359 bytes, leaving 1,217 bytes below the 24,576-byte EIP-170 runtime limit. This is deployment-headroom evidence, not a security finding.

`forge fmt --check src/runtime test` also passed.

### ABI and storage conformance

The two remaining contract-workflow conformance commands also passed:

```sh
cargo run -p tempo-xtask -- check-abi
cargo test -p zone-precompiles --test storage --features test-utils
```

- ABI comparison: **5/5 matched** (`TempoState`, `IZoneInbox`, `IZoneOutbox`, `ZoneFactory`, and `ZonePortal`).
- Storage-layout tests: **4 passed, 0 failed, 0 skipped** (`tempo_state`, `zone_inbox`, `zone_outbox`, and `zone_portal`).

The initialized `tempo-std` submodule was clean at gitlink `96f882963ce3b0e0abc7ec2b41d03d42457877bb`. Foundry warned that the committed lockfile records older revision `6e1bf3f`; this did not alter the pinned checkout and all build, test, symbolic, coverage, ABI, and storage checks passed. The revision mismatch should nevertheless be reconciled for noiseless reproducibility.

## Tempo native contracts and precompiles

- Repository: `tempoxyz/tempo`
- Commit: `88b5d7720d29655fdf9025bb14ddcd6bba1f645c`
- Package: `tempo-precompiles`

The later observed `main` commit `86ff4deaebfee38bb0b000e648b2b367810265ff` has identical `crates/precompiles` (`ceb28f7c30546748dd23e8d34ca024798e17537d`) and `crates/contracts` (`c5b9dd9d9efb06de1ae36f7564d67475660e6d5e`) Git trees, so the tested code remained current across that intervening documentation/release-workflow movement.

The complete package suite, including its opt-in test utilities and storage-layout integration target, ran with Rust 1.97.0:

```sh
cargo test -p tempo-precompiles --features test-utils
```

Result:

- Library/unit tests: **999 passed, 0 failed, 1 ignored**
- Storage integration tests: **89 passed, 0 failed, 1 ignored**
- Doctests: **0 failed, 13 ignored**
- Aggregate: **1,088 passed, 0 failed, 15 ignored**

The executed set covers the Account Keychain, TIP-20/TIP-403 policy paths, stablecoin DEX, fee manager, nonces, signature verification, Zone Factory, and native storage layouts. Ignored tests are called out separately below rather than counted as successful coverage.

The ignored inventory was enumerated with:

```sh
cargo test -p tempo-precompiles --features test-utils -- --ignored --list
```

- `storage::evm::tests::test_t4_sstore_restore_refund_matches_tip1016_spec` is an explicit known TODO. Direct execution currently observes a 19,900 refund rather than the future specification's 247,800 expectation. TIP-1016 is explicitly disabled in the pinned production configuration, so this is a deferred pre-activation test rather than a current product failure.
- `storage_tests::solidity::precompiles::export_all_storage_constants` is an intentionally ignored artifact-export utility, not an assertion.
- The other 13 are explicitly ignore-fenced, non-standalone documentation examples in the packing, thread-local checkpoint, array, set, slot, vector, and test-utility modules.

The adjacent Tempo EVM adapter suite was also run at the same revision:

```sh
cargo test -p tempo-revm
```

Result: **197 passed, 0 failed, 0 ignored**, with no doctests.

## `tempo-std` transaction helpers

- Repository: `tempoxyz/tempo-std`
- Commit: `c77f1671f7fd01c698f1344c2a5f38f11a7f8384`

```sh
/home/pierce/.foundry/bin/forge test -vvv
/home/pierce/.foundry/bin/forge coverage --report summary
```

The full checked-in suite passed: **3 passed, 0 failed, 0 skipped**. Coverage nevertheless reported **0/538 lines, 0/597 statements, 0/30 branches, and 0/92 functions** across its executable signature, transaction-builder, and RLP helper libraries. The three tests cover constants and ABI selectors rather than those helpers.

A focused local-only regression probe then reproduced one developer-library correctness candidate. Its details remain in the ignored private findings path rather than this synced baseline. The temporary test was removed and the source checkout was restored clean.

## Interpretation

- Zones has a substantial green unit/fuzz baseline, a small green symbolic set, and strong aggregate coverage at the pinned revision. No failing regression was found in the complete checked-in Forge suite.
- Tempo's native precompile and EVM-adapter packages likewise produced no active test failure; the one ignored failing assertion targets an explicitly disabled future hardfork rule.
- The `tempo-std` suite is green but provides no executed coverage of its transaction machinery. Green status alone would have concealed the reproduced encoding candidate.
- Cross-system authorization integration remains thinner than the strong component-level totals. Future contract review should preserve the exact Tempo-capable toolchain, add cross-language golden vectors where Solidity constructs node-consumed wire formats, and distinguish test absence from a demonstrated exploitable condition.
