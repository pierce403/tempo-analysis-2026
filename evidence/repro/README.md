# Sanitized Reproduction Assets

These fixtures support the timestamped transcripts in `../`. They use only public source at pinned revisions and dummy, local, in-memory, or mocked state. They do not contain real credentials and must not be pointed at production services.

Each evidence transcript states the exact source revision, command, captured result, and limitation. A reviewer should clone the named upstream repository at that revision, copy or apply the matching fixture, install the repository's pinned dependencies/toolchain, and run only the focused command from the transcript.

| Finding | Committed reproduction asset |
| --- | --- |
| C-002 / C-004 | `C-002-C-004-wrangler-path/repro.sh` |
| C-003 | `C-003-zone-allowance/repro.sh` and `zone-allowance-poc.patch` |
| C-005 | `C-005-tipbot-key-boundary/repro.sh` |
| C-006 | `C-006-release-tag-control/repro.sh` |
| C-007 | `C-007-tempo-std-rlp/repro.sh` and `KeyAuthEncodingProbe.t.sol` |
| C-008 | `C-008-wallet-release-boundary/repro.sh` |
| C-009 | `C-009-wallet-authority-output/repro.sh` and two proof patches |
| C-010 (TypeScript) | `C-010-mpp-streaming-overcapture/Skimming.poc.test.ts` and `SettlementSkim.poc.test.ts` |
| C-010 (Rust) | `C-010-mpp-streaming-overcapture/full-deposit-voucher-poc.patch` |
| C-011 | `C-011-mpp-rust-voucher-race/full-mpp-content-gate-poc.patch` |
| C-012 | `C-012-mpp-rust-unit-price-bypass/full-mpp-unit-price-poc.patch` |

The shell models create isolated temporary directories with `mktemp -d` and delete them on exit. Patch-based tests should be applied to a disposable checkout. Never apply them to a production build or submit their dummy transactions/credentials to a network.
