# Research Report: Task #397

**Task**: 397 - update_stale_toolchain_version_in_claudemd
**Started**: 2026-07-25
**Completed**: 2026-07-25
**Effort**: small
**Dependencies**: None
**Sources/Inputs**: - Codebase (project-root CLAUDE.md, README.md, docs/, lean-toolchain, lake-manifest.json, lakefile.lean, .lake/packages/mathlib), `lake env lean --version`, `git log` on the mathlib package checkout
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The stale string lives in the **project-root** `CLAUDE.md:25` (`/home/benjamin/Projects/BimodalLogic/CLAUDE.md`), under the `## Lean Version` heading (line 23). It is NOT in `.claude/CLAUDE.md` (auto-generated, must not be hand-edited).
- True Lean version, confirmed two ways: `lean-toolchain` reads `leanprover/lean4:v4.33.0-rc1`; `lake env lean --version` reports `Lean (version 4.33.0-rc1, ..., commit 62eed1db4d67327ec8120be05f1a1b0847d74561, Release)`.
- True Mathlib version, established empirically (not assumed to mirror the Lean string): `lakefile.lean:8` requests mathlib4 `@ "v4.33.0-rc1"`; `lake-manifest.json` resolves this to pinned commit `79d0395a1825a6264ad5d269e35e60537518955e`, whose own commit message is `chore: bump toolchain to v4.33.0-rc1 (#41779)` (2026-07-16). Mathlib4 has no independent semver — it is versioned by git tags that track the Lean release they build against, so "Mathlib v4.33.0-rc1" (the tag) plus the pinned commit hash is the correct, complete way to state it.
- The sweep found **9 additional files** with the stale `v4.27.0-rc1` string (12 individual lines) that should also be corrected, plus a set of in-source `-- (Lean 4.31)` / `-- (Lean 4.33)` code comments that are **accurate historical technical notes, not staleness** — left as-is.
- Recommended replacement text for CLAUDE.md is drafted below, including a re-derivation note (`cat lean-toolchain`) so future readers don't have to trust a hand-maintained number.

## Context & Scope

Scope per task 397: fix the stale toolchain assertion in the project-root CLAUDE.md, verify the true Lean and Mathlib versions empirically, sweep the repo for other stale version strings, classify each hit, and draft exact replacement text. This is a documentation-only, research-only dispatch — no files other than this report were edited.

## Findings

### 1. Location of the stale string

```
/home/benjamin/Projects/BimodalLogic/CLAUDE.md
23:## Lean Version
24:
25:v4.27.0-rc1 with Mathlib v4.27.0-rc1
```

Confirmed this is the project-root `CLAUDE.md` (the one referenced by `.claude/CLAUDE.md`'s `## Context Imports` as `@README.md`/project docs, and distinct from `.claude/CLAUDE.md` itself, which is auto-generated from merge-sources per that file's own header comment and must not be hand-edited).

### 2. True Lean version (two-way verification)

```
$ cat lean-toolchain
leanprover/lean4:v4.33.0-rc1

$ lake env lean --version
Lean (version 4.33.0-rc1, x86_64-unknown-linux-gnu, commit 62eed1db4d67327ec8120be05f1a1b0847d74561, Release)
```

Both agree: **Lean v4.33.0-rc1**.

### 3. True Mathlib version (established empirically)

- `lakefile.lean:7-8`:
  ```
  require mathlib from git
    "https://github.com/leanprover-community/mathlib4.git" @ "v4.33.0-rc1"
  ```
- `lake-manifest.json` (mathlib entry): `"rev": "79d0395a1825a6264ad5d269e35e60537518955e"`, `"inputRev": "v4.33.0-rc1"`.
- `.lake/packages/mathlib/lean-toolchain`: `leanprover/lean4:v4.33.0-rc1` (mathlib's own pinned toolchain matches the project's, confirming compatibility).
- `git -C .lake/packages/mathlib log -1`: `79d0395a1825a6264ad5d269e35e60537518955e 2026-07-16 chore: bump toolchain to v4.33.0-rc1 (#41779)`.

**Conclusion**: Mathlib4 does not carry an independent semantic version number — it is tagged/branched to track the Lean release it builds against. The correct, verifiable statement is: **Mathlib pinned to tag `v4.33.0-rc1`, resolved commit `79d0395a1825a6264ad5d269e35e60537518955e`**. This happens to numerically match the Lean version string in this case, but that is a Mathlib-release-tagging convention, not something to assume — it was checked, not inferred.

### 4. Full sweep results

Command: `grep -rn -E 'v4\.2|v4\.3|4\.27|4\.31|4\.33|Lean 4 version' . --exclude-dir=.lake --exclude-dir=.git --exclude-dir=specs`

| File:Line | Content | Classification |
|---|---|---|
| `CLAUDE.md:25` | `v4.27.0-rc1 with Mathlib v4.27.0-rc1` | **STALE** (primary target) |
| `lean-toolchain:1` | `leanprover/lean4:v4.33.0-rc1` | ACCURATE (source of truth) |
| `lakefile.lean:8` | mathlib `@ "v4.33.0-rc1"` | ACCURATE (build config) |
| `lake-manifest.json:11,91` | `"inputRev": "v4.33.0-rc1"` | ACCURATE (auto-generated, do not hand-edit) |
| `README.md:111` | `Lean 4 v4.27.0-rc1 and Lake (included with Lean).` | **STALE** |
| `docs/installation/README.md:35` | `\| Lean 4 \| v4.27.0-rc1 \| Theorem prover \|` | **STALE** |
| `docs/installation/README.md:37` | `\| Mathlib \| v4.27.0-rc1 \| Mathematical library \|` | **STALE** |
| `docs/training/SYNC_PROTOCOL.md:101` | `LEAN_VERSION=v4.27.0-rc1` (inside an illustrative "Example" block for a metadata-file format) | **STALE-EXAMPLE** (low priority — it's a sample value, not a documented current-state claim, but should be refreshed for consistency) |
| `docs/installation/BASIC_INSTALLATION.md:16` | `\| **Lean 4** \| The theorem prover (v4.27.0-rc1) \|` | **STALE** |
| `docs/installation/BASIC_INSTALLATION.md:144` | `rm -rf ~/.elan/toolchains/leanprover-lean4-v4.27.0-rc1/lib/lean4/library/` | **STALE** (example command path) |
| `docs/installation/BASIC_INSTALLATION.md:159` | `ProofChecker requires Lean v4.27.0-rc1. Check and update:` | **STALE** |
| `docs/installation/BASIC_INSTALLATION.md:161` | `lean --version  # Should show v4.27.0-rc1` | **STALE** |
| `docs/development/CONTRIBUTING.md:13` | `- Lean 4 v4.27.0-rc1` | **STALE** |
| `docs/development/CONTRIBUTING.md:335` | `- Lean: v4.27.0-rc1` | **STALE** |
| `docs/development/PROPERTY_TESTING_GUIDE.md:597` | CI YAML snippet: `lean-version: 'leanprover/lean4:v4.27.0-rc1'` | **STALE** |
| `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:128` | `-- transparency. Apply the iff as a term instead (Lean 4.31).` | IRRELEVANT — accurate historical/technical comment about elaboration behavior at a past Lean version, explaining a workaround; not a claim about current toolchain |
| `Theories/.../NfMultiAnchorBridge/ExteriorBracketK.lean:336` | same pattern, `(Lean 4.31)` | IRRELEVANT (same reasoning) |
| `Theories/.../NfMultiAnchorBridge/ExteriorNegationK.lean:171` | same pattern, `(Lean 4.31)` | IRRELEVANT (same reasoning) |
| `Theories/.../WeakCanonical/Transfer.lean:273,1252` | same pattern, `(Lean 4.31)` | IRRELEVANT (same reasoning) |
| `Theories/.../WeakCanonical/MonadicFO.lean:253` | `closed these before Lean 4.33; they now unfold...` | IRRELEVANT — accurate note about a behavior change introduced by the 4.31→4.33 upgrade (corroborates the version bump, not stale) |
| `Theories/.../Expressiveness/SplitPoint.lean:334` | `(Lean 4.31 respects transparency levels...)` | IRRELEVANT (same reasoning) |
| `Theories/.../Kamp/ExteriorNegation.lean:937` | `Since Lean 4.31 definitional...` | IRRELEVANT (same reasoning) |
| `Theories/.../IntegerModel/ReynoldsBridge.lean:892` | `(Lean 4.31.)` | IRRELEVANT (same reasoning) |
| `Theories/.../Kamp/ExteriorNegationPast.lean:275` | `Since Lean 4.31 definitional equality` | IRRELEVANT (same reasoning) |

**Corroborating fact for the record**: the in-source comments above are workaround notes written during the v4.31→v4.33 Mathlib/Lean upgrade; they are consistent with — and independently corroborate — the fact that the documented `v4.27.0-rc1` in CLAUDE.md/README/docs is several releases behind the actual `v4.33.0-rc1` toolchain. The 554 deprecation warnings currently present in the build are the same upgrade's residue (per the task description) and support the same conclusion. These in-source comments should NOT be edited — they correctly describe *why* a specific tactic sequence exists, referencing the Lean version at the time the behavior changed, which remains true regardless of what version the toolchain later moves to.

### 5. Recommended replacement text for CLAUDE.md

Replace lines 23-25 of `/home/benjamin/Projects/BimodalLogic/CLAUDE.md`:

```markdown
## Lean Version

Lean v4.33.0-rc1 with Mathlib pinned to tag `v4.33.0-rc1` (commit `79d0395a`).

To re-derive the current version rather than trusting this note, run:

\`\`\`
cat lean-toolchain
lake env lean --version
\`\`\`

Mathlib's pinned commit is recorded in `lake-manifest.json` (or `lakefile.lean`'s
`require mathlib` line) and does not necessarily track Lean's version number as a
coincidence of naming — Mathlib4 tags/branches by the Lean release it builds
against, so the two strings matching here is expected, not assumed.
```

(Adjust code-fence escaping as appropriate for the file — the report escapes the inner fence with `\`\`\`` for readability here.)

## Decisions

- Treat the project-root `CLAUDE.md` (not `.claude/CLAUDE.md`) as the sole edit target for the primary fix, per the auto-generation note in `.claude/CLAUDE.md`'s own header.
- Report, but do not alter, the in-source `-- (Lean 4.31)` / `(Lean 4.33)` code comments — they are accurate technical history, not documentation staleness.
- Recommend updating all 9 STALE/STALE-EXAMPLE hits in `README.md`, `docs/installation/README.md`, `docs/installation/BASIC_INSTALLATION.md`, `docs/development/CONTRIBUTING.md`, `docs/development/PROPERTY_TESTING_GUIDE.md`, and `docs/training/SYNC_PROTOCOL.md` (the last as lower-priority since it's an illustrative example value) for consistency with the corrected CLAUDE.md, since the task instructs "fix or report them" for the sweep.

## Risks & Mitigations

- **Risk**: A future Mathlib/Lean bump (this project is already mid-upgrade residue per the 554 deprecation warnings) will make today's numbers stale again. **Mitigation**: the drafted replacement text includes the re-derivation commands so the note is self-correcting guidance rather than a number to trust blindly.
- **Risk**: Editing the CI YAML snippet in `docs/development/PROPERTY_TESTING_GUIDE.md:597` could be confused with an actual live CI config change. **Mitigation**: verify whether this is a live `.github/workflows/*.yml` file too (not found in the sweep under `.github/`; the hit is only in the docs snippet) before editing — implementation should double check there is no matching live workflow file that also needs the bump.

## Context Extension Recommendations

None — this is a one-off documentation correction; no new context file is warranted.

## Appendix

- Search command: `grep -rn -E 'v4\.2|v4\.3|4\.27|4\.31|4\.33|Lean 4 version' . --exclude-dir=.lake --exclude-dir=.git --exclude-dir=specs`
- Verification commands: `cat lean-toolchain`, `lake env lean --version`, `git -C .lake/packages/mathlib log -1`
- No live `.github/workflows/*.yml` file was found matching the PROPERTY_TESTING_GUIDE.md CI snippet in this sweep (sweep excluded only `.lake/`, `.git/`, `specs/` — a `.github/` hit would have surfaced if the string existed there); implementation should re-check for out-of-pattern CI config strings (e.g. `4.33` without `v` prefix) if closer certainty is wanted.
