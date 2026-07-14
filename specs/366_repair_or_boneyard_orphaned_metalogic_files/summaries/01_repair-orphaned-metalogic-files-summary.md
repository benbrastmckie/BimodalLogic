# Implementation Summary: Task #366 — Repair or Boneyard Orphaned Metalogic Files

- **Task**: 366 — Repair or boneyard orphaned metalogic files
- **Type**: lean4
- **Session**: sess_1784053407_4f1694_366
- **Status**: Implemented (7/7 phases complete)
- **Plan**: plans/01_repair-orphaned-metalogic-files.md

## What Was Done

Executed the repair-then-boneyard path across all 7 phases:

1. **Phase 1 (LaTeX prose)**: Replaced both stale `ContextDerivable` references in
   `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` — line 328 →
   `\texttt{Derivable FrameClass.Base [] $\varphi$}`, line 433 → `\texttt{Derivable}` (+ mention of
   `\texttt{Consistent}` for MCS). `grep -c ContextDerivable` = 0.
2. **Phase 2 (repair Deferral)**: Added `open Bimodal.Metalogic.Bundle` after line 7 of
   `Deferral.lean`, resolving all `Unknown identifier` errors. Scoped build EXIT 0, 0 sorries.
3. **Phase 3 (repair AlgebraicCompleteness)**: Moved the misplaced closing paren on line 156 so
   `trivial` becomes the final argument to `DerivationTree.axiom` (matching the line-99 pattern).
   Scoped build EXIT 0, 0 in-file sorries.
4. **Phase 4 (delete FMP aggregator)**: `git rm Metalogic/Decidability/FMP.lean` (0 live importers).
   Default build EXIT 0.
5. **Phase 5 (relocate Deferral)**: `git mv` Deferral to
   `Boneyard/RestrictedMCSDeferral/Deferral.lean` (module
   `Bimodal.Boneyard.RestrictedMCSDeferral.Deferral`); updated all 6 boneyard consumer import
   paths; deleted `Metalogic/Core/Core.lean`. Old path fully retired (0 importers), new path used
   by all 6 consumers.
6. **Phase 6 (relocate AlgebraicCompleteness)**: `git mv` to
   `Boneyard/UltrafilterFrame/AlgebraicCompleteness.lean`; deleted `Metalogic/Algebraic/Algebraic.lean`.
   Scoped build EXIT 0, 0 in-file sorries.
7. **Phase 7 (final verification)**: Default `lake build` EXIT 0 (1759 jobs); all 5 retired module
   paths have 0 importers; 0 sorries in both relocated repaired files; all 3 aggregators deleted.

## Verification Results

| Check | Result |
|-------|--------|
| Default `lake build` | EXIT 0 (1759 jobs) |
| Scoped build relocated Deferral | EXIT 0 (752 jobs) |
| Scoped build relocated AlgebraicCompleteness | EXIT 0 (722 jobs) |
| New sorries introduced | 0 |
| New axioms introduced | 0 |
| Vacuous defs introduced | 0 |
| Retired module-path importers | 0 for all 5 |
| `ContextDerivable` in 04-Metalogic.tex | 0 |

## Plan Deviations

- **Phases 5 & 6 — BoneyardArchive full-build verification (altered)**: The plan's Phase 5/6/7
  verification criterion `lake build BoneyardArchive` EXIT 0 is **unachievable and was based on a
  faulty premise**. `BoneyardArchive` is PRE-EXISTING RED for reasons entirely unrelated to task
  366: `KampBypassArchive/*` (archived by task 305, importing now-deleted
  `Bimodal.Metalogic.WeakCanonical.Kamp.*` modules), `DeadChronicleGapElimination/GapElimination.lean`
  (stale API — unknown identifiers), `UltrafilterFrame/TenseS5Algebra.lean` (type mismatches),
  `FiltrationOrdering/SigmaOrdering.lean` and `VecEADecomposition/VecEADecomposition.lean` (bad
  imports). None of these files were touched by task 366. The plan's assumption that "repairing
  Deferral turns BoneyardArchive green" was incorrect — BoneyardArchive was never green and is not
  the CI gate (the default `lake build` is). **Verification of record substituted**: (1) scoped
  build of each relocated file EXIT 0 with 0 in-file sorries; (2) each relocated file replays
  cleanly under the BoneyardArchive glob with no import error (only benign unused-simp warnings);
  (3) no BoneyardArchive error references either new module path; (4) default `lake build` EXIT 0.
  No regression: the 6 Deferral consumers' import now resolves where it previously pointed at a
  broken module. This matches the plan's own Risk-table row acknowledging BoneyardArchive was
  "already RED before changes."
- **Concurrent-session git interaction (note, not a code deviation)**: Parallel orchestrator
  sessions (tasks 364, 365) committed during this run and swept the already-staged Phase 5/6
  `git mv`/`git rm` operations into their commits. End state is correct and verified (moves +
  deletions present in HEAD, content intact including the Phase 2/3 fixes); a follow-up commit
  finalized the 6 consumer import edits.

## Out-of-Scope (untouched, as directed)

- 3 pre-existing upstream ultrafilter-chain sorries: `LindenbaumQuotient.lean:169`,
  `InteriorOperators.lean:73` (plan cited 177/182/83; current line numbers differ but these are the
  same pre-existing shared-chain sorries), plus pre-existing sorries in `Bundle/SuccExistence.lean`.
  Surfaced only as warnings; not fixed.
- `ContextConsistent` reference in `Boneyard/ChainCompleteness/Completeness/SuccChainCompleteness.lean:74`.

## Files Changed

- Modified: `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`
- Relocated + repaired: `Deferral.lean` → `Boneyard/RestrictedMCSDeferral/Deferral.lean`
- Relocated + repaired: `AlgebraicCompleteness.lean` → `Boneyard/UltrafilterFrame/AlgebraicCompleteness.lean`
- Updated imports: 6 boneyard consumer files (ChainCompleteness ×3, StrictSemanticsLegacy ×2, RoundRobinChain ×1)
- Deleted: `Metalogic/Core/Core.lean`, `Metalogic/Algebraic/Algebraic.lean`, `Metalogic/Decidability/FMP.lean`
