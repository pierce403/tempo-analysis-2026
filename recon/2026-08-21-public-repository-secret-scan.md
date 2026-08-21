# Public Repository History and Secret Scan

Observation window: **2026-08-21 16:13:41–16:48:11 UTC** \
Organization: [`tempoxyz`](https://github.com/tempoxyz) \
Mode: public source, local full-history analysis, no credential verification

## Outcome

All **68 public repositories** returned by the GitHub API were acquired as full bare mirrors, pinned, and presented to TruffleHog. All 68 canonical runs finished with exit status zero. The scans covered **201,832 per-repository commit visits** and emitted **1,281 unverified match records** across 26 repositories; 42 repositories emitted none.

No credential was authenticated, no provider API was queried with a candidate value, and no result was marked `Verified: true`. Manual metadata and public-source review did **not** confirm a live credential. Two contexts survived triage: **OBS-001**, an environment file removed from the default branch whose public deletion PR says its credentials were not live; and **OBS-002**, a Grafana Cloud credential-shaped value still hardcoded at the head of a public Tempo experiment branch. OBS-002 was not tested and requires owner-side revocation/scope confirmation.

This is not proof that no secret exists. It is a dated heuristic scan with explicit binary/archive coverage exceptions.

## Inventory and mirror evidence

- GitHub repository API observed: `2026-08-21T16:14:02Z`.
- Mirror acquisition: `2026-08-21T16:13:41Z–16:17:56Z`.
- Mirror validation: `2026-08-21T16:18:16Z`.
- Mirrors: 68/68 valid bare repositories, 68/68 non-shallow, 68/68 origin-matched, and 68/68 successful all-ref mirror fetches.
- Default heads: 68/68 match the tracked manifest.
- Mirror totals: 30,352 refs and 211,890 per-repository reachable commits; fork overlap means neither is a globally unique object count.
- Local mirror volume: approximately 2.6 GiB under ignored `target/public-repos/`.
- Tracked manifest: [`2026-08-21-public-repositories.csv`](2026-08-21-public-repositories.csv), SHA-256 `01d82888836c52173cd7c9bfe141f92c8d32beb7dec609a98b1424ad0050cfed`.
- Ignored validation manifest: `target/secret-scan/inventory/mirror-validation.tsv`, SHA-256 `0e6972f2c88c65a542000942e0000c848a8fc0b214e2d795d947ce105be8a2a2`.

The mirrors contain all reachable repository refs returned by `git clone --mirror`. Referenced third-party submodules were not recursively cloned because they are not Tempo organization repositories.

## Tool and execution

- TruffleHog version: `3.97.0`.
- Official Linux AMD64 archive SHA-256: `62224de2f9dd7cd418800feb953760a302ed2f82a7c547fe1146a4874fb179e4`.
- Extracted binary SHA-256: `6e76f66fa7c4f4a53bbf8bb6ea0984498965f27f877870eb2c2ad4682c3829f1`.
- Scan start: `2026-08-21T16:19:15Z`.
- Canonical scan end: `2026-08-21T16:48:11Z`.

Canonical command shape:

```text
target/secret-scan/tool/trufflehog \
  --json --no-verification --no-update --results=unverified \
  --fail-on-scan-errors --log-level=1 --concurrency=4 \
  git "file:///<absolute-bare-mirror>" --bare
```

The canonical `tempo` and `tempo-apps` reruns additionally placed `--force-skip-binaries --force-skip-archives` before the `git` subcommand after the initial runs spent substantial time misidentifying binary fixtures and generated artifacts as compressed archives. Their text/history runs then completed cleanly. Raw JSONL, stderr, status files, and all candidate values remain ignored under `target/secret-scan/`.

The canonical status manifest records the selected output, mode, exit status, completion marker, commit count, match count, structured-error count, and finish time for every repository. It contains 68 rows and has SHA-256 `a2a5d93489052efb5217bb5fa362da853aa19c2641b336a6fd318dd38bec351a`.

## Results

### Repository totals

| Repository | Match records |
| --- | ---: |
| `tempo-apps` | 419 |
| `tidx` | 95 |
| `viem` | 91 |
| `tempo` | 80 |
| `foundry` | 75 |
| `foundry-1` | 75 |
| `foundry-2` | 75 |
| `foundry-tempo-pr` | 75 |
| `tempo-foundry` | 62 |
| `changelogs` | 56 |
| `docs` | 30 |
| `wallet-rs` | 29 |
| `zones` | 29 |
| `accounts` | 27 |
| `mpp-specs` | 15 |
| `mpp` | 14 |
| `chains` | 7 |
| `tip.bot` | 6 |
| `txgen` | 6 |
| `pytempo` | 5 |
| `mpp-rs` | 3 |
| `ungoogled-chromium-mpp` | 3 |
| `hermes-mpp` | 1 |
| `mpp-discovery-mcp` | 1 |
| `scfuzzbench` | 1 |
| `tempo-ts` | 1 |

The 42 zero-match repositories were `.github`, `Tempo-Integrations`, `accounts-sdk-duplicate-iframe-repro`, `agents-tempo-xyz`, `appkit-wagmi-tempo-wallet`, `benchmarkoor-replay`, `bridgerton`, `cf-template-proxy`, `ci`, `examples`, `execution-payloads-benchmarks`, `export-tempo`, `frenchy`, `gh-actions`, `incur-rs`, `ledger-app-tempo`, `lints`, `metrics-derive`, `mpp-e2b`, `mpp-go`, `mpp-irl`, `mpp-proxy-cf`, `mpp-tools`, `openclaw-mpp`, `pathusd-reserves`, `pg_clickhouse`, `pympp`, `reth`, `reth-1`, `reth-2`, `reth-3`, `reth-4`, `revm-inspectors`, `rpc-tester`, `schelk`, `skills`, `tempo-evals`, `tempo-go`, `tempo-maybe-pay`, `tempo-std`, `tempo-support`, and `wallet-cli`.

### Detector totals

| Detector | Records | Detector | Records |
| --- | ---: | --- | ---: |
| URI | 291 | Box | 230 |
| Alchemy | 224 | Infura | 131 |
| TLy | 129 | Postgres | 91 |
| Cloudflare API token | 42 | Private key | 24 |
| Aiven | 20 | Etherscan | 15 |
| UnifyID | 12 | Cloudflare global API key | 10 |
| Urlscan | 8 | Qase | 8 |
| Phrase access token | 8 | FMFW | 8 |
| Circle | 5 | Parsers | 4 |
| Miro | 4 | GitHub OAuth2 | 4 |
| Sumo Logic key | 2 | Sirv | 2 |
| Juro | 2 | JWT | 2 |
| Mandrill | 1 | Humanity | 1 |
| Grafana | 1 | GitHub | 1 |
| Datadog API key | 1 |  |  |

These names are detector labels, not provider attribution or validity findings.

### Location and deduplication

- 293 records reference paths present in the current default tree: 132 exact detected byte sequences remain and 161 paths remain with changed content.
- 967 records reference history-only paths.
- 21 diff-metadata records did not resolve to a file path.
- 1,252 locations are unique by repository, detector, path, commit, and line.
- 970 locations remain after deduplicating identical metadata across repositories.
- 324 detector/value pairs remain after value-level deduplication performed in memory without persisting or printing values.

Path presence does not mean the same candidate value remains in the current file. No values were copied into the tracked analysis.

## Manual classification

| Class | Records | Assessment |
| --- | ---: | --- |
| Upstream toolchain/fork history | 453 | Foundry-family and archived `viem` tests, examples, sample keys, RPC fixtures, and inherited workflow strings; heavy cross-repository duplication |
| Generated bundle reports | 382 | History-only `tempo-apps/explorer-bundle-stats/sonda_*.html`; dense generated strings triggered many unrelated provider detectors |
| Other reviewed source/configuration | 244 | Public endpoints, local/default database URLs, chain data, static assets, config keys, and detector name collisions; no current credential established |
| Tests, examples, and documentation | 101 | Test RPC credentials, examples, documentation, fixtures, and local development configuration |
| Vendored dependency corpus | 55 | Historical `changelogs/bot/node_modules` package tests, examples, bundled code, and documentation |
| Workflow interpolation or diff metadata | 44 | GitHub Actions secret expressions and workflow-changing commits; these prove that a secret is referenced, not that its value is committed |
| Historical removed environment file | 1 | OBS-001; one of two high-signal credential-shaped source contexts |
| Public branch telemetry credential | 1 | OBS-002; an unverified Grafana credential-shaped value at a non-default branch head |

All 24 `PrivateKey` records occur in test, sample, or vendored files. The 44 Cloudflare-labeled records resolve to workflow expressions, related diff metadata, or generated/vendor material rather than a committed token value.

### OBS-001 — Removed `changelogs/bot/.env`

- **State:** known historical observation; likely revoked per the public owner statement, with no validity test performed.
- **First repository commit:** `38a9f721c2c68726a38ddf38ba7d5606e61a8528`, 2026-02-11.
- **Scanner context:** one unverified `Github` detector record at `bot/.env:1`.
- **Default tree:** absent from `master`; still present at 18 public non-default branch heads in the mirror snapshot.
- **Removal:** merge commit `79c502c94ab76cf8153d6a3bc22d02ae03850d3f`, [PR #115, “Delete bot/.env”](https://github.com/tempoxyz/changelogs/pull/115), 2026-05-02.
- **Public owner context:** the removal PR says the secrets were not live and deletes the file for posterity.

The committed file declared a GitHub credential and an external AI-service credential. Their values, exact shapes, and hashes are intentionally omitted. A criminal who found a still-valid historical repository or model-service credential could use its granted API authority to read or modify source, automation, releases, or service usage. The public statement and default-branch removal substantially lower current likelihood, but they do not independently prove revocation, remove the values from every public ref, or rule out use during the exposure window.

Defensive closeout is to confirm revocation/rotation, review provider and GitHub audit logs for the exposure interval, and enable push protection plus history-aware scanning. No credential should be tested merely to establish closure.

### OBS-002 — Grafana credential-shaped value at `tempo:zygis/pprof`

- **State:** unverified public-branch observation; private owner check warranted.
- **Branch head:** `zygis/pprof` at `e6cd619cee885d081d2d1a41b2a6ff390e593484`.
- **Commit date:** 2025-08-23.
- **Scanner context:** one unverified `Grafana` detector record at `bin/tempo/src/main.rs:43`.
- **Default tree:** absent from `main`.
- **Live public-ref check:** GitHub returned the same branch head and `protected: false` at `2026-08-21T16:58:08Z`.

Redacted source-context review shows a profiling agent configured with hardcoded basic-auth material for a Grafana Cloud Pyroscope endpoint. The value, exact shape, account identifier, and authorization header are omitted. It was not submitted to Grafana, so validity and scope are unknown.

If valid, the credential could permit some combination of reading profile telemetry, writing or poisoning profiles, consuming quota, or disrupting the monitoring signal used to investigate an intrusion. No direct authority over Tempo funds, deployments, source, or cloud administration is established.

Defensive closeout is immediate owner-side revocation/rotation, access-policy and audit-log review from the commit date onward, removal from all public refs, and secret injection for any future profiling experiment. Searching adjacent public branches for copied credentials is appropriate; testing this value is not.

### Other reviewed leads

- `mpp/package.json` triggered the Datadog detector at a script-name key for an MPP service provisioning task; key-path-only review established a name collision, not an embedded credential.
- `tidx` Postgres records cluster in checked-in local/production configuration templates whose schema selects password environment variables; detector metadata did not establish a password value.
- The historical `tempo-apps/charts/golden-axe/values.yaml` record resolves to configuration/comment context, not a promoted credential.
- `accounts` Postgres records are concentrated in `.env.example`, local Docker, and Wrangler configuration.
- Alchemy/Infura/Etherscan records predominantly come from inherited toolchain tests, public RPC examples, or official client test vectors.

None of these other contexts was promoted to `FINDINGS.md` as a credential observation.

## Coverage exceptions

The canonical status contains 12 structured scanner errors:

- `changelogs`: two Brotli-decoder failures on vendored Darwin binaries.
- `foundry`, `foundry-1`, `foundry-2`, and `foundry-tempo-pr`: two archive-identification failures each on compressed async-compression test artifacts.
- `reth-4`: two related timeout records for one `superchain-configs.tar` artifact.

The initial non-canonical Tempo run also produced 25 decode/archive errors on block fixture binaries before it was stopped, and the initial Tempo Apps run produced five binary-handler records across four swap/test-output files. The canonical reruns covered their Git histories and textual content but intentionally skipped **all** files that TruffleHog classified as binaries or archives. A credential embedded only inside one of those blobs would not be detected by the canonical pass.

Other limitations:

- Detection is heuristic and produces false positives and false negatives.
- Provider verification was disabled, so `Verified: false` means “not tested,” not “invalid.”
- Public mirrors do not cover private repositories, deleted unreachable objects, Git LFS objects unavailable through ordinary clone, private packages, artifacts, Actions logs, cloud storage, or provider-side history.
- The sum of commit visits includes duplicate histories carried by forks; it is not a count of globally unique commits.
- Current-tree classification is path-based metadata triage and does not prove that a historical matched value is unchanged.

## Defensive next steps

1. Revoke/rotate and scope-check OBS-002 internally without using the public value.
2. Confirm OBS-001 revocation and audit history, including the 18 branch heads that still carry the file.
3. Enable or review GitHub secret scanning and push protection across the organization, including custom patterns for Tempo's cloud, signing, fee-payer, observability, and release credential formats.
4. Remove generated bundles, vendored dependency trees, swap files, and test-output artifacts from Git history where practical; they obscure high-signal scanning.
5. Scan release artifacts, containers, packages, Actions artifacts, and cloud object stores from an authorized internal environment.
6. Run a separately resourced binary/archive scan against the explicitly skipped blobs with strict size, decompression, and timeout controls.
7. Route any real credential through incident response: preserve logs, revoke first, rotate dependent authority, inspect secondary footholds, and only then consider history rewriting.
