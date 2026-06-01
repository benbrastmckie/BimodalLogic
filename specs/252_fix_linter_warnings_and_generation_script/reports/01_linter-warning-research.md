# Research Report: Fix Linter Warnings and Improve Generation Scripts

**Task**: 252
**Date**: 2026-06-01
**Status**: Researched

## Summary

A full `lake build` of the project produces 799 total warnings. Excluding `sorry` declarations (which are expected for in-progress proofs), deprecated API usage, "Try this" suggestions, duplicated namespace notices, and "tactic is never executed" meta-warnings, there are approximately 638 actionable warnings. The task description identifies 5 specific files with 24 individual warnings. This report covers those specific warnings in detail and provides a categorized inventory of the broader warning landscape for prioritization.

## Category 1: Unused Variables `h_sc`, `h_mem` in Definition Binders

### Files Affected
- `Theories/Bimodal/Semantics/Validity.lean` (10 warnings across 5 locations)
- `Theories/Bimodal/FrameConditions/Validity.lean` (2 warnings at lines 56-57)
- `Theories/Bimodal/FrameConditions/Soundness.lean` (10 warnings across 5 locations)

### Root Cause
The definitions `valid`, `semantic_consequence`, `valid_dense`, `valid_discrete`, and `unsatisfiable_implies_all_fixed` all use forall-quantified binders `(h_sc : ShiftClosed Omega)` and `(h_mem : tau in Omega)`. These names appear in the binder position of the universal quantifier but are not referenced in the body of the definition. The body is `truth_at M Omega tau t phi`, which uses `Omega` and `tau` (bound earlier) but never references the proof terms `h_sc` or `h_mem` by name.

### Fix
Replace named binders with anonymous binders in each definition:
- `(h_sc : ShiftClosed Omega)` becomes `(_ : ShiftClosed Omega)`
- `(h_mem : tau in Omega)` becomes `(_ : tau in Omega)`

This is safe because:
1. The binder names are not used in the definition body
2. Downstream proofs that use these definitions (e.g., in Soundness.lean, Completeness.lean) introduce their own local names via `intro` or pattern matching -- they do not depend on the names from the definition signature
3. The type information is preserved, so the quantifier structure is unchanged

### Scope
- Semantics/Validity.lean: 5 definitions, each with 2 warnings = 10 warnings
- FrameConditions/Validity.lean: 1 definition with 2 warnings
- FrameConditions/Soundness.lean: 5 locations with 2 warnings each = 10 warnings
- Total: 22 warnings in this category

## Category 2: Unused Simp Arguments in TemporalFormulas.lean

### File
`Theories/Bimodal/Syntax/SubformulaClosure/TemporalFormulas.lean` (6 warnings)

### Specific Warnings

1. **Line 565**: `simp only [G_neg_neg_bot, Formula.all_future, f_nesting_depth]` -- `f_nesting_depth` unused
2. **Line 566**: `simp only [H_neg_neg_bot, Formula.all_past, f_nesting_depth]` -- `f_nesting_depth` unused
3. **Line 647**: `simp only [G_neg_neg_bot, Formula.all_future, p_nesting_depth]` -- `p_nesting_depth` unused
4. **Line 650**: `simp only [H_neg_neg_bot, Formula.all_past, p_nesting_depth]` -- `p_nesting_depth` unused
5. **Line 803**: `simp only [..., Formula.and, ...]` -- `Formula.and` unused
6. **Line 895**: `simp only [..., Formula.and, ...]` -- `Formula.and` unused

### Root Cause
After `G_neg_neg_bot` and `H_neg_neg_bot` unfold, the resulting expressions are pure `Formula.all_future`/`Formula.all_past` applications of negations. The nesting depth functions (`f_nesting_depth`, `p_nesting_depth`) are not needed because the simp lemmas for the constructor (`all_future`, `all_past`) already fully simplify the expression. Similarly, `Formula.and` is listed in simp calls at lines 803 and 895, but none of the serialityFormulas or blocking formulas contain `and` at the top level.

### Fix
Remove the unused arguments from each `simp only` call:
- Lines 565: `simp only [G_neg_neg_bot, Formula.all_future]`
- Lines 566: `simp only [H_neg_neg_bot, Formula.all_past]`
- Lines 647: `simp only [G_neg_neg_bot, Formula.all_future]`
- Lines 650: `simp only [H_neg_neg_bot, Formula.all_past]`
- Lines 803, 895: Remove `Formula.and` from the argument lists

These are safe because the linter confirms the args have no effect; the proofs close without them.

## Category 3: Unused `all_goals simp_wf` in ProofSearch/Core.lean

### File
`Theories/Bimodal/Automation/ProofSearch/Core.lean` (2 warnings at lines 1016, 1141)

### Root Cause
Both occurrences are in `decreasing_by` blocks for recursive functions:
```lean
termination_by depth
decreasing_by
  all_goals simp_wf
  all_goals omega
```
The `simp_wf` tactic does nothing because `omega` alone suffices to close all termination goals. In Lean 4 / Mathlib, `omega` handles the `Nat.lt` obligations that `simp_wf` would simplify, making the first tactic redundant.

### Fix
Remove `all_goals simp_wf` from both locations, leaving:
```lean
termination_by depth
decreasing_by
  all_goals omega
```

## Category 4: Unused Variable `fc` in CountermodelExtraction.lean

### File
`Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` (1 warning at line 128)

### Root Cause
The function `extractCountermodelFromTableau` takes a parameter `(fc : FrameClass := .Base)` with a default value, but never uses `fc` in the function body. The function simply pattern matches on the tableau and extracts a countermodel from an open branch.

### Fix
Rename `fc` to `_fc` or `_` to suppress the warning. However, this parameter may have been intended for future use (frame-class-aware countermodel extraction). Two options:
- **Option A**: Rename to `_fc` to indicate it is intentionally unused for now
- **Option B**: Remove the parameter entirely if no callers pass it

To determine which: check if any callers pass a non-default `fc` argument. Since the default is `.Base`, if all callers rely on the default, the parameter can be safely removed.

### Recommendation
Use `_fc` since this appears to be scaffolding for frame-class-aware extraction that may be implemented later.

## Category 5: Unused Variables in ProofSearch/Strategies.lean

### File
`Theories/Bimodal/Automation/ProofSearch/Strategies.lean` (4 warnings at lines 365, 371, 375, 376)

### Specific Warnings
1. **Line 365**: `exists (proof : ...)` -- `proof` unused in existential binder
2. **Line 371**: `exists (proof : ...)` -- `proof` unused in existential binder
3. **Line 375**: `(h : [p.box] |- p)` -- `h` unused in example
4. **Line 376**: `exists (proof : ...)` -- `proof` unused in existential binder

### Root Cause
These are documentation `example` declarations. The existential binders name the witness `proof` but the name is never used in the proof term (the proof constructs the witness directly). Similarly, hypothesis `h` in line 375 is a parameter that is not needed for the actual proof (which uses `assumption` instead).

### Fix
- Replace `(proof : ...)` with `(_ : ...)` in the existential binders at lines 365, 371, 376
- Replace `(h : [p.box] |- p)` with `(_ : [p.box] |- p)` at line 375

## Category 6: Generation Script Robustness

### File
`scripts/run_dataset_generation.sh`

### Current State
The script is well-structured with:
- `set -euo pipefail` for strict error handling
- Clear help text and usage documentation
- Separate functions per tier (smoke, c5, c7, c9, c11)
- Timestamps at start/end of each run

### Areas for Improvement

1. **No signal trapping**: If interrupted (Ctrl-C), partial output files remain with no indication they are incomplete. Add a `trap` handler.

2. **No exit code checking with reporting**: While `set -e` catches failures, there is no user-friendly error message when `lake exe dataset_generator` fails (e.g., if the binary has not been built).

3. **No prerequisite check**: The script documents `lake build dataset_generator` as a prerequisite in the comments but does not verify the binary exists before running.

4. **No progress indicator for long runs**: The c9 and c11 tiers can take 30 minutes to 4 hours. The script provides no intermediate progress output.

5. **No feasibility gate checking**: The comments mention feasibility gates (timeout rate < 20%, valid fraction >= 15%, at least 3 goal categories) but there is no automated checking of these gates after a run completes.

6. **Smoke test cleanup on failure**: If the smoke test fails partway, the `rm -f` cleanup on line 47 is never reached due to `set -e`.

### Recommended Improvements
- Add `trap cleanup EXIT` with a cleanup function
- Add a `check_prereqs()` function that verifies `lake exe dataset_generator` exists
- Add basic metadata file validation after each run
- Add a `--dry-run` option that prints the command without executing

## Broader Warning Landscape (Beyond Task Scope)

The full build reveals 638 actionable warnings beyond the 5 files listed in this task. The largest contributors:

| File | Warnings | Primary Type |
|------|----------|-------------|
| Metalogic/Soundness.lean | 162 | Unused simp args (repetitive pattern) |
| WeakCanonical/Expressiveness/CaseAnalysis.lean | 84 | Unused simp args |
| WeakCanonical/EFGames/CustomGame.lean | 59 | Mixed (unused vars + simp args) |
| WeakCanonical/EFGames/StaviCompleteness.lean | 37 | Mixed |
| WeakCanonical/Expressiveness/DConsistencyTransport.lean | 30 | Unused simp args |
| SoundnessLemmas/DenseValidity.lean | 29 | Unused simp args |
| WeakCanonical/NEquivalence.lean | 26 | Unused simp args |
| WeakCanonical/EFGames/Decomposition.lean | 19 | Mixed (simp does nothing + unused vars) |
| WeakCanonical/EFGames/GapDetection.lean | 18 | Mixed |
| All other files combined | ~174 | Various |

These are out of scope for this task but represent a significant cleanup opportunity. The Soundness.lean warnings alone (162) follow a repeated pattern of unused simp arguments in `truth_at` lemma simplification calls, suggesting a systematic fix could address many at once.

## Implementation Plan Recommendations

### Phase 1: Fix Task-Scoped Warnings (24 warnings across 5 files)
- Semantics/Validity.lean: Replace 10 named binders with `_`
- SubformulaClosure/TemporalFormulas.lean: Remove 6 unused simp args
- ProofSearch/Core.lean: Remove 2 `all_goals simp_wf` lines
- CountermodelExtraction.lean: Rename 1 `fc` to `_fc`
- ProofSearch/Strategies.lean: Replace 4 names with `_`

### Phase 2: Fix Additional Same-Pattern Warnings
- FrameConditions/Validity.lean: Same `h_sc`/`h_mem` pattern (2 warnings)
- FrameConditions/Soundness.lean: Same `h_sc`/`h_mem` pattern (10 warnings)
- Automation/Tactics/Helpers.lean: Unused `fc` (2 warnings)

### Phase 3: Generation Script Improvements
- Add signal trapping and cleanup
- Add prerequisite checking
- Add basic post-run validation

### Phase 4: Verification
- Run `lake build` and confirm warning count decreased
- Verify no regressions (all proofs still close)

### Risk Assessment
- **Low risk**: All changes are mechanical (rename to `_`, remove unused args, remove no-op tactics)
- **Verification**: `lake build` after each file change confirms no regressions
- **No sorry introduction**: None of these changes introduce or require `sorry`
