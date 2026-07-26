# Implementation Plan: Task #397

- **Task**: 397 - update_stale_toolchain_version_in_claudemd
- **Status**: [COMPLETED]
- **Effort**: 0.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/397_update_stale_toolchain_version_in_claudemd/reports/01_version-staleness-sweep.md
- **Artifacts**: plans/01_version-corrections.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Documentation-only correction of a stale Lean toolchain assertion. The project runs Lean
v4.33.0-rc1 with Mathlib pinned to tag `v4.33.0-rc1`, but the project-root `CLAUDE.md` and six
documentation files still assert `v4.27.0-rc1` — several releases behind. This plan replaces
every stale occurrence with the verified version, adds a re-derivation note to `CLAUDE.md` so the
number becomes self-correcting rather than hand-maintained, and verifies that no stale string
remains and that the deliberately-excluded in-source comments were left untouched. No code, build
config, or CI file is modified.

### Research Integration

The research report establishes all ground truth used here; it is not re-derived during
implementation:

- **Lean version, two-way verified**: `lean-toolchain` reads `leanprover/lean4:v4.33.0-rc1`;
  `lake env lean --version` reports `4.33.0-rc1`. Both agree.
- **Mathlib version, established empirically**: `lakefile.lean:8` requests mathlib4
  `@ "v4.33.0-rc1"`; `lake-manifest.json` resolves this to pinned commit
  `79d0395a1825a6264ad5d269e35e60537518955e` (commit message: `chore: bump toolchain to
  v4.33.0-rc1`). Mathlib4 carries no independent semantic version — it tags releases to track the
  Lean release it builds against, so "tag `v4.33.0-rc1`, commit `79d0395a`" is the correct
  complete statement. The two strings matching is a verified fact, not an assumption.
- **Edit target disambiguation**: the primary fix belongs in the **project-root**
  `/home/benjamin/Projects/BimodalLogic/CLAUDE.md`, NOT `.claude/CLAUDE.md`. See Non-Goals.
- **Exclusions**: in-source `(Lean 4.31)` / `before Lean 4.33` comments under
  `Theories/Bimodal/Metalogic/WeakCanonical/**.lean` were classified ACCURATE. See Non-Goals.

**Count correction against the research report**: the report's executive summary says "9
additional files". A re-run of the sweep at plan time gives the authoritative figures used by
this plan's verification criteria:

```
grep -rn 'v4\.27\.0-rc1' --exclude-dir=.lake --exclude-dir=.git --exclude-dir=specs .
```

returns **12 lines across 7 files** — `CLAUDE.md` (1 line) plus **6 additional files carrying 11
additional lines**. The report's own findings table is consistent with this; only the summary
sentence's file count was off (it appears to have counted hits, not distinct files). The
per-file/per-line breakdown in the report's table is accurate and is what Phase 2 works from.

**Live-CI check resolved**: the report flagged as a risk that
`docs/development/PROPERTY_TESTING_GUIDE.md:597` might shadow a live CI config. A live workflow
does exist at `.github/workflows/ci.yml`, but it contains **no** `v4.27.0-rc1` string and pins no
Lean version at all — it uses `leanprover/lean-action@v1`, which reads `lean-toolchain`
automatically. The guide's snippet is therefore documentation-only with no CI consequence, and
this risk is closed before implementation begins.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided for this task; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Replace the stale version assertion in the project-root `CLAUDE.md` with the verified Lean
  v4.33.0-rc1 / Mathlib tag `v4.33.0-rc1` (commit `79d0395a`) statement.
- Include re-derivation commands (`cat lean-toolchain`, `lake env lean --version`) in the
  `CLAUDE.md` section so a future reader can confirm the number instead of trusting it.
- Correct all 11 remaining stale `v4.27.0-rc1` occurrences across the 6 documentation files.
- Verify the repository is free of `v4.27.0-rc1` outside `.lake/`, `.git/`, and `specs/`, and
  that the excluded in-source comments are byte-for-byte unchanged.

**Non-Goals**:
- **Do NOT edit `.claude/CLAUDE.md`.** It is auto-generated from extension merge-sources (per its
  own header: "This file is generated automatically from loaded extensions. Do not edit
  directly."). The `## Lean Version` section being fixed exists only in the project-root
  `CLAUDE.md`. An implementer that edits the generated file will have its change silently
  reverted on the next extension sync.
- **Do NOT edit the in-source Lean comments.** The following are ACCURATE historical/technical
  notes explaining why specific tactic sequences exist, referencing the Lean version at which an
  elaboration behavior changed. They remain true regardless of the current toolchain and MUST be
  left exactly as-is:
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:128`
  - `Theories/Bimodal/Metalogic/WeakCanonical/.../NfMultiAnchorBridge/ExteriorBracketK.lean:336`
  - `Theories/Bimodal/Metalogic/WeakCanonical/.../NfMultiAnchorBridge/ExteriorNegationK.lean:171`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:273,1252`
  - `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean:253`
  - `Theories/Bimodal/Metalogic/WeakCanonical/.../Expressiveness/SplitPoint.lean:334`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean:937`
  - `Theories/Bimodal/Metalogic/WeakCanonical/.../IntegerModel/ReynoldsBridge.lean:892`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegationPast.lean:275`
- Do not edit `lean-toolchain`, `lakefile.lean`, or `lake-manifest.json` — these are the sources
  of truth (and the manifest is auto-generated by `lake`).
- Do not modify `.github/workflows/ci.yml`. It pins no version and needs no change.
- Do not restructure the `PROPERTY_TESTING_GUIDE.md` CI snippet to match the live workflow's
  no-pin style. Only the version string is corrected; changing the documented pattern is out of
  scope for a version-staleness fix.
- Do not run `lake build` or address the 554 deprecation warnings mentioned in the task
  description. This is a documentation-only task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer edits `.claude/CLAUDE.md` instead of project-root `CLAUDE.md` | M | M | Non-Goals states the distinction explicitly with the reason; Phase 1 tasks name the absolute path; Phase 3 verifies `.claude/CLAUDE.md` is unmodified |
| Implementer "helpfully" updates the excluded in-source Lean comments | M | M | Non-Goals enumerates all 9 excluded sites; Phase 3 runs `git status` and asserts no `.lean` file is modified |
| A future toolchain bump restales these numbers | L | H | The `CLAUDE.md` replacement embeds re-derivation commands, making the section self-correcting guidance rather than a bare number to trust |
| Blind find-and-replace corrupts an unrelated `4.27` string | L | L | Only the exact literal `v4.27.0-rc1` is replaced; the 12 target lines are enumerated with file:line in Phases 1-2 |
| Deprecation-warning residue implies further version drift mid-task | L | L | Out of scope by Non-Goals; Phase 3's sweep is the sole completeness check |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint file sets and
both use replacement strings fixed by this plan, so they are genuinely independent; executing
them sequentially in a single agent run is equally valid for a task this size.

### Phase 1: Correct project-root CLAUDE.md [COMPLETED]

**Goal**: Replace the stale `## Lean Version` section in the project-root `CLAUDE.md` with the
verified versions plus re-derivation guidance.

**Tasks**:
- [x] Open `/home/benjamin/Projects/BimodalLogic/CLAUDE.md` (project root — confirm the file
      begins with `# ProofChecker`, which distinguishes it from the generated `.claude/CLAUDE.md`
      that begins with `# Agent System`) *(completed)*
- [x] Replace line 25 (`v4.27.0-rc1 with Mathlib v4.27.0-rc1`) with the replacement block below,
      keeping the existing `## Lean Version` heading on line 23 *(completed)*

**Replacement text** (replaces line 25 only; heading and blank line above are unchanged):

````
Lean v4.33.0-rc1 with Mathlib pinned to tag `v4.33.0-rc1` (resolved commit `79d0395a`).

To re-derive these rather than trusting this note:

```
cat lean-toolchain          # toolchain pin
lake env lean --version     # Lean version actually in use
```

Mathlib's resolved commit is recorded in `lake-manifest.json`; the requested tag is in
`lakefile.lean`. Mathlib4 has no independent version number of its own — it tags releases to
track the Lean release they build against, so the two version strings matching here is
expected rather than coincidental.
````

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**:
- `/home/benjamin/Projects/BimodalLogic/CLAUDE.md` — replace the stale one-line version
  assertion under `## Lean Version` with the block above

**Verification**:
- `grep -n 'v4\.27\.0-rc1' CLAUDE.md` returns no matches
- `grep -n 'v4\.33\.0-rc1' CLAUDE.md` returns matches on the new lines
- `grep -c 'lake env lean --version' CLAUDE.md` returns at least 1
- `git diff --stat` shows only `CLAUDE.md` changed by this phase, and `.claude/CLAUDE.md` is NOT
  listed

---

### Phase 2: Correct remaining documentation files [COMPLETED]

**Goal**: Replace all 11 remaining `v4.27.0-rc1` occurrences across the 6 documentation files
with `v4.33.0-rc1`.

**Tasks**:
- [x] `README.md:111` — `**Requirements**: Lean 4 v4.27.0-rc1 and Lake (included with Lean).`
      -> `v4.33.0-rc1` *(completed)*
- [x] `docs/installation/README.md:35` — requirements table row `| Lean 4 | v4.27.0-rc1 | Theorem
      prover |` -> `v4.33.0-rc1` *(completed)*
- [x] `docs/installation/README.md:37` — requirements table row `| Mathlib | v4.27.0-rc1 |
      Mathematical library |` -> `v4.33.0-rc1` (correct per the research: Mathlib's tag tracks the
      Lean release, verified — not assumed) *(completed)*
- [x] `docs/installation/BASIC_INSTALLATION.md:16` — `| **Lean 4** | The theorem prover
      (v4.27.0-rc1) |` -> `v4.33.0-rc1` *(completed)*
- [x] `docs/installation/BASIC_INSTALLATION.md:144` — troubleshooting command
      `rm -rf ~/.elan/toolchains/leanprover-lean4-v4.27.0-rc1/lib/lean4/library/` ->
      `leanprover-lean4-v4.33.0-rc1` (this path must match the installed toolchain directory or
      the documented recovery step silently no-ops) *(completed)*
- [x] `docs/installation/BASIC_INSTALLATION.md:159` — `ProofChecker requires Lean v4.27.0-rc1.
      Check and update:` -> `v4.33.0-rc1` *(completed)*
- [x] `docs/installation/BASIC_INSTALLATION.md:161` — `lean --version  # Should show v4.27.0-rc1`
      -> `v4.33.0-rc1` *(completed)*
- [x] `docs/development/CONTRIBUTING.md:13` — prerequisites bullet `- Lean 4 v4.27.0-rc1` ->
      `v4.33.0-rc1` *(completed)*
- [x] `docs/development/CONTRIBUTING.md:335` — bug-report template line `- Lean: v4.27.0-rc1` ->
      `v4.33.0-rc1` *(completed)*
- [x] `docs/development/PROPERTY_TESTING_GUIDE.md:597` — CI YAML snippet
      `lean-version: 'leanprover/lean4:v4.27.0-rc1'` -> `leanprover/lean4:v4.33.0-rc1`
      (documentation-only; the live `.github/workflows/ci.yml` pins no version and is not touched)
      *(completed)*
- [x] `docs/training/SYNC_PROTOCOL.md:101` — `LEAN_VERSION=v4.27.0-rc1` -> `v4.33.0-rc1`
      *(completed)*

**Decision on `SYNC_PROTOCOL.md:101` (the illustrative example value)**: **correct it.** The
research classified this STALE-EXAMPLE / low priority and left the call to planning. It is
corrected because the surrounding text documents `LEAN_VERSION` as recording the actual Lean
version at export time, so a reader comparing a real emitted metadata file against this example
would see a spurious mismatch. The change is a single literal with no downstream consumer, so the
consistency benefit is free.

**Timing**: 0.35 hours

**Depends on**: none

**Files to modify**:
- `README.md` — 1 line
- `docs/installation/README.md` — 2 lines
- `docs/installation/BASIC_INSTALLATION.md` — 4 lines
- `docs/development/CONTRIBUTING.md` — 2 lines
- `docs/development/PROPERTY_TESTING_GUIDE.md` — 1 line
- `docs/training/SYNC_PROTOCOL.md` — 1 line

**Verification**:
- `grep -rn 'v4\.27\.0-rc1' README.md docs/` returns no matches
- `grep -rc 'v4\.33\.0-rc1' README.md docs/installation/README.md
  docs/installation/BASIC_INSTALLATION.md docs/development/CONTRIBUTING.md
  docs/development/PROPERTY_TESTING_GUIDE.md docs/training/SYNC_PROTOCOL.md` shows counts
  1, 2, 4, 2, 1, 1 respectively
- No file outside the six listed above appears in `git status --short` for this phase

---

### Phase 3: Verify completeness and exclusions [COMPLETED]

**Goal**: Confirm no stale string survives anywhere in scope, and that every deliberately
excluded file is untouched.

**Tasks**:
- [x] Run the full sweep and confirm zero hits:
      `grep -rn 'v4\.27\.0-rc1' --exclude-dir=.lake --exclude-dir=.git --exclude-dir=specs .`
      *(completed: exit status 1, zero hits)*
- [x] Confirm the sources of truth are unchanged: `git status --short` lists neither
      `lean-toolchain`, `lakefile.lean`, nor `lake-manifest.json` *(completed)*
- [x] Confirm no Lean source was touched: `git status --short` lists no `*.lean` path (guards the
      9 excluded in-source comments listed in Non-Goals) *(completed)*
- [x] Confirm the generated agent file was not edited: `git status --short` does not list
      `.claude/CLAUDE.md` *(completed)*
- [x] Confirm CI is untouched: `git status --short` does not list `.github/workflows/ci.yml`
      *(completed)*
- [x] Confirm the final modified set is exactly 7 files: `CLAUDE.md`, `README.md`,
      `docs/installation/README.md`, `docs/installation/BASIC_INSTALLATION.md`,
      `docs/development/CONTRIBUTING.md`, `docs/development/PROPERTY_TESTING_GUIDE.md`,
      `docs/training/SYNC_PROTOCOL.md` *(completed: diff-stat confirms exactly these 7 files)*
- [x] Spot-check the rendered `## Lean Version` section in `CLAUDE.md` for correct markdown
      (the nested fenced code block must open and close cleanly) *(completed: verified clean)*

**Timing**: 0.15 hours

**Depends on**: 1, 2

**Files to modify**:
- None (verification only)

**Verification**:
- The sweep command returns exit status 1 (no matches) — this is the definition of done for the
  correction work
- `git diff --stat` shows exactly 7 changed files and no `.lean`, `.yml`, `.json`, or
  `lean-toolchain` entries

---

## Testing & Validation

- [ ] `grep -rn 'v4\.27\.0-rc1' --exclude-dir=.lake --exclude-dir=.git --exclude-dir=specs .`
      returns no matches
- [ ] `CLAUDE.md` states Lean v4.33.0-rc1 and Mathlib tag `v4.33.0-rc1` (commit `79d0395a`)
- [ ] `CLAUDE.md` includes both re-derivation commands (`cat lean-toolchain`,
      `lake env lean --version`)
- [ ] Exactly 7 files modified; no `.lean` source file, no `.claude/CLAUDE.md`, no build config,
      no CI workflow among them
- [ ] The documented version matches `cat lean-toolchain` at time of writing
- [ ] No build is required or run — this task changes no compiled content

## Artifacts & Outputs

- `specs/397_update_stale_toolchain_version_in_claudemd/plans/01_version-corrections.md` (this
  plan)
- `specs/397_update_stale_toolchain_version_in_claudemd/summaries/01_version-corrections-summary.md`
  (on implementation completion)
- Modified: `CLAUDE.md`, `README.md`, `docs/installation/README.md`,
  `docs/installation/BASIC_INSTALLATION.md`, `docs/development/CONTRIBUTING.md`,
  `docs/development/PROPERTY_TESTING_GUIDE.md`, `docs/training/SYNC_PROTOCOL.md`

## Rollback/Contingency

All changes are text-only edits to tracked markdown files with no build or runtime dependency, so
rollback is trivial and carries no risk of losing other work. Revert the phase commit with
`git revert <sha>`, or restore individual files from `HEAD` if the working tree is otherwise
clean. If a version number is later found to be wrong, the re-derivation commands now embedded in
`CLAUDE.md` give the corrected value directly — re-run them and reapply Phases 1-2 with the new
literal.
