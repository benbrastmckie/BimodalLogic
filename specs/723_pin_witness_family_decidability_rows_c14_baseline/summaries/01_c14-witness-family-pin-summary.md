# Implementation Summary: Task #723

- **Task**: 723 - Ground the pinned:C14 claim on the three witness-family decidability rows of docs/theorem-index.md
- **Status**: [COMPLETED]
- **Started**: 2026-10-04T17:20:00Z
- **Completed**: 2026-10-04T18:05:00Z
- **Effort**: ~45 minutes
- **Dependencies**: Task 706 (file_scope collision, run in a disjoint cycle -- satisfied)
- **Artifacts**: plans/01_c14-witness-family-pin.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Re-verified that `docs/theorem-index.md` rows 151-153's `pcq pinned:C14` cells were asserting a
check that did not run -- confirmed real, not a false alarm -- and closed the gap by adding the
three witness-family decidability declarations to the C14 baseline pair in
`scripts/check-module-invariants.sh`. A full `bash scripts/check-module-invariants.sh` run
(`RUN_BUILD=1`) now passes with C14 reporting the three new declarations pinned.

## What Changed

- `scripts/check-module-invariants.sh` -- appended
  `'FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime'`,
  `'FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate'`, and
  `'FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime'` (each
  `depends on axioms: [propext, Classical.choice, Quot.sound]`) to the `C14_BASELINE` heredoc,
  and the matching three `#print axioms` directives in identical order to the `C14LEAN` heredoc.
  Added a pointer-comment paragraph (in the shell comment block above the `C14_BASELINE` opener,
  not inside either heredoc) naming the pending fourth sibling declaration,
  `Decidable (Derivable FrameClass.ZTime [] φ)`, for cheap future pinning once it lands. Also
  corrected the adjacent C21 comment's stale "C2 pins four ... 105 between them" to the live,
  recomputed "C2 pins fifty ... 251 between them" (see Plan Deviations).
- `docs/theorem-index.md` -- confirmed unchanged; rows 151-153 already stated the correct
  `pcq pinned:C14` value, which is now backed by a real check.

## Decisions

- Chose the baseline-addition route over the row-correction alternative: a live `#print axioms`
  probe (importing `FormalSystem`, matching the C14LEAN heredoc's own import) confirmed all three
  declarations resolve and report exactly `[propext, Classical.choice, Quot.sound]`, matching what
  the rows already claim.
- The fourth sibling declaration (`Decidable (Derivable FrameClass.ZTime [] φ)`) has not landed
  (`grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` returns zero hits), so only
  a naming pointer comment was added, not a fourth pin -- per the dispatch's hard constraint
  against pinning an unverified check.

## Plan Deviations

- **Task 3.1** altered: the plan's recompute formula trusted the pre-existing C21 comment's own
  "C2 pins four" claim at face value. That claim was accurate when the comment was authored
  (2026-09-07, when `AXIOM_BASELINE` genuinely had 4 entries) but has since gone stale
  independently of this task -- `AXIOM_BASELINE` now has 50 entries. Recomputed both baselines
  live instead of trusting the stale literal: C2 = 50, C14 (post this task's +3) = 201, total =
  251. Corroborated independently by the script's own C36 census line, which live-computes
  "251 pinned declaration(s) in C2+C14" -- matching exactly.

## Verification

- Build: Success (`bash scripts/check-module-invariants.sh`, full `RUN_BUILD=1`, exit 0, "ALL
  CHECKS PASSED")
- Tests: N/A (no Lean source changed; shell-script invariant checks are the verification surface)
- Files verified: Yes -- `git diff` across all three phase commits shows additions only; no
  existing C14/C2 baseline entry removed, reordered, or altered; no `.lean` file touched;
  `docs/theorem-index.md` untouched.

## Impacts

- `docs/theorem-index.md` rows 151-153's `pinned:C14` claim is now backed by a real,
  machine-checked baseline entry rather than an assertion that silently checked nothing.
- The pending fourth declaration (the `Derivable FrameClass.ZTime [] φ` decidability corollary)
  has a cheap, pre-written pinning path once it lands.

## Follow-ups

- When the fourth declaration (`Decidable (Derivable FrameClass.ZTime [] φ)`) lands, add its
  `#print axioms` line and expected-output line to both heredocs following this block's shape
  (pointer comment already in place above the `C14_BASELINE` opener), and add its
  `docs/theorem-index.md` row.

## References

- specs/723_pin_witness_family_decidability_rows_c14_baseline/reports/01_c14-witness-family-pin.md
- specs/723_pin_witness_family_decidability_rows_c14_baseline/plans/01_c14-witness-family-pin.md
- scripts/check-module-invariants.sh (C14_BASELINE / C14LEAN heredocs, lines ~2037-2463)
- docs/theorem-index.md (rows 151-153)
