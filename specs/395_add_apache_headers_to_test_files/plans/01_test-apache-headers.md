# Implementation Plan: Apache Headers for Tests/

- **Task**: 395 - add_apache_headers_to_test_files
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/395_add_apache_headers_to_test_files/reports/01_test-header-inventory.md
- **Artifacts**: plans/01_test-apache-headers.md (this file)
- **Standards**: .claude/context/formats/plan-format.md; .claude/rules/plan-format-enforcement.md; .claude/rules/artifact-formats.md; .claude/rules/state-management.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Add the project's Apache 2.0 copyright header to all 42 `.lean` files under `Tests/`, using the
exact `/- -/` block form already committed across 279 `Theories/` files. 39 files get a plain
prepend; 3 files carry a non-conforming placeholder block on lines 1-4 that must be **replaced**
rather than prepended to. The per-file copyright year is the rename-aware git creation year,
already resolved in the research report — it is not to be re-derived. Done when
`bash scripts/check-copyright-headers.sh --strict Tests` reports 42/42 conforming with exit 0 and
`lake build BimodalTest` remains green.

### Research Integration

The inventory report (`reports/01_test-header-inventory.md`) is authoritative and supplies:

- The complete 42-file → year table (25 files at 2025, 17 at 2026), reproduced verbatim in
  Phases 1 and 2 below.
- **Correction A**: the git-year command in the task description omits `--follow` and therefore
  returns 2026 for all 42 files, because commit `9d4a15c9b` (2026-01-11) moved every test file
  into `Tests/` at once. `--follow --diff-filter=A` matches the committed `Theories/` headers
  279/279; the plain form matches only 248/279. **Do not re-run any year query** — use the tables
  in this plan.
- **Checker predicate: already correct, no fix required.** The task description made the header
  work conditional on first repairing the duplicate-detection predicate. It does not need
  repair. `scripts/check-copyright-headers.sh:68` runs `n_cop=$(grep -ci '^Copyright (c) ' "$f")`
  over the **whole file** with no `head` restriction, evaluates it **before** leading-block
  validation, and `continue`s into the `duplicate` bucket — so a double-headered file can never
  fall through to `conforming`. Verified directly against the script during planning. The
  planned checker-fix phase is therefore **dropped**, not deferred.
- A dry-run of the exact transformation in a scratch tree already passed
  `check-copyright-headers.sh --strict` at 42/42 conforming, exit 0.
- Pre-change build baseline is green: `lake build BimodalTest`, 1912 jobs, exit 0.
- Two out-of-graph modules (`ProofSystem/DerivationBenchmark`, `Semantics/SemanticBenchmark`) are
  **already broken** before this task (unknown identifiers, `List.get!` removal). They must be
  headered but must not be repaired, and must not be used as build gates.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` provided for this dispatch; no roadmap phases included.

## Goals & Non-Goals

**Goals**:
- Every one of the 42 `.lean` files under `Tests/` carries the exact house Apache 2.0 header.
- The three placeholder files end up with exactly one copyright block, not two.
- `bash scripts/check-copyright-headers.sh --strict Tests` exits 0 at 42/42 conforming.
- `lake build BimodalTest` and the 6 healthy out-of-graph modules stay green.

**Non-Goals**:
- Modifying `scripts/check-copyright-headers.sh` (its predicate is already correct — see above).
- Relying on Mathlib's `linter.style.header` (a proven false negative here: `isInLibraryRoot`
  looks for `./Bimodal.lean` while `srcDir := "Theories"` puts the root at
  `Theories/Bimodal.lean`, so it silently no-ops).
- Repairing the two pre-existing broken benchmark modules.
- Any proof work, new axioms, or `sorry` — this task touches comment blocks only.
- Headering anything outside `Tests/`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Prepending to a placeholder file instead of replacing → double header | H | M | Phases 1 and 2 use disjoint, explicitly enumerated file lists; Phase 1's command set never names the three placeholder files. The checker's duplicate bucket catches it anyway and `--strict` exits 1. |
| Implementer re-derives years without `--follow`, stamping 2026 on 25 files | M | M | Both year lists are embedded verbatim below; the plan forbids re-deriving. Checker does not catch this (any `20[0-9]{2}` passes) — it is caught only by following the tables. |
| Header inserted after an `import` line | H | L | All 42 files begin with `import` or the placeholder block; none has a leading module docstring. Insertion is strictly at line 1. |
| Benchmark-module build failure mistaken for header-induced breakage | M | M | Phase 3 gates only on `BimodalTest` plus the 6 healthy out-of-graph modules; the two broken ones are explicitly excluded from the gate. |
| Blank separator line lost on the placeholder files | L | M | Phase 2 deletes lines 1-4 only; line 5 (already blank) is retained and becomes the separator. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. Phases 1 and 2 operate on disjoint file
sets (39 files vs. 3 files) and may be run in either order or concurrently.

### Phase 1: Prepend header to the 39 unheadered files [COMPLETED]

**Goal**: All 39 `Tests/` files that currently have no copyright text carry the exact house
header with their correct per-file year.

**Header text** (exactly 5 lines, then one blank line, then the file's existing content):

```
/-
Copyright (c) YYYY Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

```

**Tasks**:
- [x] Prepend the header with `YYYY` = **2025** to these 25 files:
  - `Tests/BimodalTest/Automation/ProofSearchTest.lean`
  - `Tests/BimodalTest/Automation/TacticsTest.lean`
  - `Tests/BimodalTest/Automation/TacticsTest_Simple.lean`
  - `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean`
  - `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean`
  - `Tests/BimodalTest/Integration/ComplexDerivationTest.lean`
  - `Tests/BimodalTest/Integration/EndToEndTest.lean`
  - `Tests/BimodalTest/Integration/Helpers.lean`
  - `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean`
  - `Tests/BimodalTest/Integration/TemporalIntegrationTest.lean`
  - `Tests/BimodalTest/ProofSystem/AxiomsTest.lean`
  - `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean`
  - `Tests/BimodalTest/ProofSystem/DerivationTest.lean`
  - `Tests/BimodalTest/Property/Generators.lean`
  - `Tests/BimodalTest/Property.lean`
  - `Tests/BimodalTest/Semantics/SemanticPropertyTest.lean`
  - `Tests/BimodalTest/Semantics/TaskFrameTest.lean`
  - `Tests/BimodalTest/Semantics/TruthTest.lean`
  - `Tests/BimodalTest/Syntax/ContextTest.lean`
  - `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean`
  - `Tests/BimodalTest/Syntax/FormulaTest.lean`
  - `Tests/BimodalTest/Theorems/ModalS4Test.lean`
  - `Tests/BimodalTest/Theorems/ModalS5Test.lean`
  - `Tests/BimodalTest/Theorems/PerpetuityTest.lean`
  - `Tests/BimodalTest/Theorems/PropositionalTest.lean`
- [x] Prepend the header with `YYYY` = **2026** to these 14 files:
  - `Tests/BimodalTest.lean`
  - `Tests/BimodalTest/Automation/C5SmokeTest.lean`
  - `Tests/BimodalTest/Automation/DeductionTest.lean`
  - `Tests/BimodalTest/Automation/EdgeCaseTest.lean`
  - `Tests/BimodalTest/Automation/FormulaMutatorTest.lean`
  - `Tests/BimodalTest/Automation/InterestingnessTest.lean`
  - `Tests/BimodalTest/Automation/LemmaDBTest.lean`
  - `Tests/BimodalTest/Automation/NormalizationTest.lean`
  - `Tests/BimodalTest/Automation/ProofFirstTests.lean`
  - `Tests/BimodalTest/Automation/ProofSearchBenchmark.lean`
  - `Tests/BimodalTest/Automation/WeakeningSearchTest.lean`
  - `Tests/BimodalTest/Metalogic/PropDecideTest.lean`
  - `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`
  - `Tests/BimodalTest/Semantics/SemanticBenchmark.lean`
- [x] Confirm no file in this phase received two copyright blocks. *(verified: `grep -c` returns 1 for all 39; diffstat 39 files, +234, -0)*

**Do NOT touch** in this phase: `Tests/BimodalTest/TraceCertificateTest.lean`,
`Tests/BimodalTest/TraceExporterE2ETest.lean`, `Tests/BimodalTest/TraceExportTest.lean` — those
are Phase 2's territory and require replacement, not prepending.

**Reference implementation** (a scripted pass is appropriate; the two lists above are the
authoritative input, do not substitute a `git log` query):

```bash
prepend() {  # $1 = year, $2 = file
  printf '/-\nCopyright (c) %s Benjamin Brast-McKie. All rights reserved.\nReleased under Apache 2.0 license as described in the file LICENSE.\nAuthors: Benjamin Brast-McKie\n-/\n\n' "$1" \
    | cat - "$2" > "$2.tmp" && mv "$2.tmp" "$2"
}
```

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- The 39 `Tests/**/*.lean` files enumerated above — insert 6 lines at the top of each; no other
  content changes.

**Verification**:
- `grep -c '^Copyright (c) ' <file>` returns exactly `1` for each of the 39 files.
- `head -1 <file>` is `/-` and `sed -n 5p <file>` is `-/` for each.
- `git diff --stat -- Tests` shows exactly 39 files changed, `+234` insertions, 0 deletions.

---

### Phase 2: Replace the placeholder block in the 3 Trace test files [IN PROGRESS]

**Goal**: The three files carrying a non-conforming placeholder block end with exactly one
copyright block — the house header — and no residue of the old one.

**Current content** (all three are byte-identical in their first 6 lines; the placeholder block
occupies **lines 1-4**, line 5 is blank, line 6 begins the imports):

```
/-
Copyright (c) 2026 BimodalLogic contributors.
Released under the project's standard license.
-/

import Bimodal.Syntax
```

The existing attribution names an undefined collective ("BimodalLogic contributors") and has no
`Authors:` line; the house format attributes to the individual holder. Both aspects change.

**Required edit, identical for all three files** — delete lines 1-4, then insert the 5-line
header at line 1. **Retain line 5** (the blank line): it becomes the blank separator before
`import`, matching the convention in all 279 `Theories/` files.

**Resulting first 7 lines**:

```
/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Syntax
```

**Tasks**:
- [ ] `Tests/BimodalTest/TraceCertificateTest.lean` — replace lines 1-4, year **2026**
- [ ] `Tests/BimodalTest/TraceExporterE2ETest.lean` — replace lines 1-4, year **2026**
- [ ] `Tests/BimodalTest/TraceExportTest.lean` — replace lines 1-4, year **2026**
- [ ] Confirm the string `BimodalLogic contributors` no longer appears anywhere under `Tests/`.
- [ ] Confirm the string `Released under the project's standard license.` no longer appears
      anywhere under `Tests/`.

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `Tests/BimodalTest/TraceCertificateTest.lean` — lines 1-4 replaced
- `Tests/BimodalTest/TraceExporterE2ETest.lean` — lines 1-4 replaced
- `Tests/BimodalTest/TraceExportTest.lean` — lines 1-4 replaced

**Verification**:
- `grep -c '^Copyright (c) ' <file>` returns exactly `1` for each of the three files (a `2`
  means the file was prepended to instead of replaced).
- `grep -rn 'BimodalLogic contributors' Tests` returns nothing.
- `git diff --stat` for these three shows a net `+2` lines each (5 inserted, 4 removed, blank
  line 5 untouched).

---

### Phase 3: Verify headers and confirm the build stays green [NOT STARTED]

**Goal**: The header gate passes at 42/42 with exit 0 and the test build is no worse than the
pre-change baseline.

**Tasks**:
- [ ] Run the header gate: `bash scripts/check-copyright-headers.sh --strict Tests`. Require
      `conforming: 42`, `nonconforming: 0`, `duplicate: 0`, `missing: 0`, `total: 42`, exit 0.
- [ ] If the `duplicate` count is nonzero, inspect `$OUTDIR/duplicate.txt` — a hit there means a
      Phase 2 file was prepended to rather than replaced. Fix by removing the stale block; do not
      relax the checker.
- [ ] Run the build gate: `lake build BimodalTest` — must complete with exit 0 (baseline: 1912
      jobs, exit 0, linter warnings only).
- [ ] Run the out-of-graph gate on the 6 healthy modules:
      `lake build BimodalTest.Automation.FormulaMutatorTest BimodalTest.Automation.InterestingnessTest BimodalTest.Automation.ProofFirstTests BimodalTest.TraceCertificateTest BimodalTest.TraceExporterE2ETest BimodalTest.TraceExportTest`
- [ ] Confirm `git diff --stat -- Tests` touches exactly 42 files and contains no changes outside
      the leading comment blocks.

**Explicitly NOT gated on**: `BimodalTest.ProofSystem.DerivationBenchmark` (39 pre-existing
errors) and `BimodalTest.Semantics.SemanticBenchmark` (7 pre-existing errors). Both were broken
before this task and are out of scope. Header them (Phase 1 does); do not repair them; do not
treat their failure as a regression.

**Timing**: 20 minutes

**Depends on**: 1, 2

**Files to modify**: none (verification only)

**Verification**:
- Header gate exits 0 at 42/42 conforming.
- `lake build BimodalTest` exits 0.
- The 6 healthy out-of-graph modules build clean.

## Testing & Validation

- [ ] `bash scripts/check-copyright-headers.sh --strict Tests` → exit 0, 42 conforming, 0
      nonconforming, 0 duplicate, 0 missing.
- [ ] `lake build BimodalTest` → exit 0 (matches the green pre-change baseline).
- [ ] The 6 healthy out-of-graph modules build clean.
- [ ] `grep -rn 'BimodalLogic contributors' Tests` → no matches.
- [ ] `git diff -- Tests` shows only leading-comment-block insertions/replacements; no Lean
      declaration, import, or proof text is altered.
- [ ] Spot-check one 2025 file and one 2026 file to confirm the year partition was applied from
      the plan's tables rather than a re-derived query.

## Artifacts & Outputs

- `specs/395_add_apache_headers_to_test_files/plans/01_test-apache-headers.md` (this file)
- 42 modified `Tests/**/*.lean` files (comment blocks only)
- `specs/395_add_apache_headers_to_test_files/summaries/01_test-apache-headers-summary.md`
  (written at implementation completion)

## Rollback/Contingency

All changes are confined to leading comment blocks in `Tests/`, so rollback is a scoped checkout
of the test tree:

```bash
git checkout -- Tests
```

Because this discards uncommitted work, run `bash .claude/scripts/git-snapshot.sh` first per
`.claude/rules/git-workflow.md` ("No Destructive Git on Uncommitted Work"). Preferred
alternative: commit Phases 1 and 2 separately once each is green, so a bad phase can be reverted
with `git revert` and no snapshot dance is needed.

Partial-completion contingency: Phases 1 and 2 are independent, so a failure in one leaves the
other's files correctly headered. Re-run only the failing phase; the checker's per-file bucket
lists (`$OUTDIR/missing.txt`, `$OUTDIR/duplicate.txt`) identify precisely which files still need
work.
