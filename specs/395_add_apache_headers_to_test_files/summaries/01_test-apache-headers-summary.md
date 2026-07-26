# Implementation Summary: Apache Headers for Tests/

- **Task**: 395 - add_apache_headers_to_test_files
- **Status**: COMPLETED
- **Session**: sess_1785047501_b839c2_395
- **Plan**: specs/395_add_apache_headers_to_test_files/plans/01_test-apache-headers.md
- **Report**: specs/395_add_apache_headers_to_test_files/reports/01_test-header-inventory.md
- **Phases**: 3 of 3 completed

## Outcome

All 42 `.lean` files under `Tests/` now carry the exact house Apache 2.0 header in `/- -/` block
form, positioned at line 1 ahead of every `import`, with a blank separator line. The header gate
`bash scripts/check-copyright-headers.sh --strict Tests` reports **42 conforming, 0
nonconforming, 0 duplicate, 0 missing, exit 0** (pre-change baseline was 0/3/0/39).

Per-file years came verbatim from the research report's rename-aware (`git log --follow`) table —
25 files at 2025, 17 at 2026 — and were not re-derived. The `--follow`-less query in the task
description would have stamped 2026 on the 25 files whose true creation year is 2025.

## Phase Results

### Phase 1: Prepend header to the 39 unheadered files [COMPLETED]

Prepended the 5-line header plus blank separator to the 39 files with no existing copyright text
(25 at year 2025, 14 at year 2026). A guard refused to touch any file already containing a
`^Copyright (c) ` line, which mechanically enforced disjointness from Phase 2's three files.

Verification: `grep -c '^Copyright (c) '` returns exactly 1 for each of the 39; line 1 is `/-`,
line 5 is `-/`, line 6 is blank for all 39; `git diff --stat` showed exactly
`39 files changed, 234 insertions(+)` and **zero deletions**, matching the plan's prediction
exactly.

### Phase 2: Replace the placeholder block in the 3 Trace test files [COMPLETED]

`TraceCertificateTest.lean`, `TraceExporterE2ETest.lean`, and `TraceExportTest.lean` each carried
a 4-line placeholder block attributing to the collective "BimodalLogic contributors" with no
`Authors:` line. Lines 1-4 were **deleted and replaced** (not prepended to); line 5, already
blank, was retained as the separator. A guard verified the exact expected placeholder text before
deleting, so an unexpected file would have aborted rather than losing content.

Verification: `grep -c '^Copyright (c) '` returns exactly 1 for each of the three (a 2 would have
meant a prepend-instead-of-replace error and would have tripped the checker's duplicate bucket);
`grep -rn 'BimodalLogic contributors' Tests` and
`grep -rn "Released under the project's standard license." Tests` both return nothing.

### Phase 3: Verify headers and confirm the build stays green [COMPLETED]

| Gate | Result |
|------|--------|
| `bash scripts/check-copyright-headers.sh --strict Tests` | 42 conforming, 0 nonconforming, 0 duplicate, 0 missing, **exit 0** |
| `lake build BimodalTest` | `Build completed successfully (1912 jobs)`, **exit 0** |
| 6 healthy out-of-graph modules | `Build completed successfully (774 jobs)`, **exit 0** |
| `lake test` (testDriver = `BimodalTest`) | **exit 0** |
| Diff scope | 42 files under `Tests`, 243 insertions / 6 deletions, **0 non-header lines changed** |

The 1912-job count and exit 0 match the pre-change baseline recorded in the research report
exactly. Remaining output is pre-existing `linter.unusedSimpArgs` warnings, unrelated to headers.

The two out-of-graph benchmark modules excluded from the gate were confirmed to still fail with
their **pre-existing** error counts — `DerivationBenchmark` 39 errors, `SemanticBenchmark`
7 errors — identical to the counts recorded in the research report before any header change.
They were headered as required and deliberately not repaired.

## Checker Script: No Modification Made

The task description made the header work conditional on first repairing the duplicate-detection
predicate in `scripts/check-copyright-headers.sh`. Re-verified directly against the script: **no
repair was needed.** At `scripts/check-copyright-headers.sh:68`, `n_cop=$(grep -ci '^Copyright
(c) ' "$f")` counts across the whole file with no `head` restriction, is evaluated *before*
leading-block validation, and `continue`s into the `duplicate` bucket — so a double-headered file
can never fall through to `conforming`. The script was left untouched, confirming the plan's
decision to drop that phase rather than defer it.

## Files Modified

42 `.lean` files under `Tests/` (leading comment blocks only; no Lean declaration, import, or
proof text altered). No files outside `Tests/` were touched by this task.

## Plan Deviations

- **Phase 2 verification criterion, altered**: the plan predicted `git diff --stat` would show a
  net `+2` lines per placeholder file ("5 inserted, 4 removed"). The arithmetic was off by one —
  a 4-line block replaced by a 5-line block is net `+1`. Git's minimal diff reports `+3/-2` per
  file (line 1 `/-` and the closing `-/` are unchanged; lines 2-3 are rewritten and the
  `Authors:` line is new), totalling `9 insertions(+), 6 deletions(-)` across the three. The
  header content is exactly as specified; only the plan's predicted line arithmetic was wrong.
  Annotated inline on the plan's Phase 2 verification item.
- No other deviations. Phases 1 and 3 executed exactly as planned.

## Verification Notes

- Zero `sorry`, zero vacuous definitions, zero new axioms — this task touched comment blocks only.
- Mathlib's `linter.style.header` was **not** used as evidence at any point. It is a proven false
  negative in this repo: `isInLibraryRoot` looks for `./Bimodal.lean` while the lakefile's
  `srcDir := "Theories"` puts the root at `Theories/Bimodal.lean`, so it silently no-ops.
