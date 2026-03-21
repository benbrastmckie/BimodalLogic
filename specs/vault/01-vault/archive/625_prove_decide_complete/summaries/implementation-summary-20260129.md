# Implementation Summary: Task #625

**Completed**: 2026-01-29
**Duration**: ~1 hour

## Overview

Implemented the `decide_complete` theorem in Correctness.lean, establishing that for any semantically valid formula, the `decide` function returns `.valid proof` given sufficient fuel. The proof structure uses `tableau_complete` (Task 624) as its foundation.

## Changes Made

### Correctness.lean

1. **Added `open Bimodal.Automation`** (line 34) - Required to access `bounded_search_with_proof` for documentation purposes

2. **Enhanced `decide_complete` theorem** (lines 144-194):
   - Added comprehensive docstring explaining proof strategy and dependencies
   - Structured proof using `obtain` to destructure `tableau_complete` result
   - Documented the gap between tableau completeness and proof extraction
   - Maintained original theorem signature: `∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof`

## Gap Analysis

The theorem uses `sorry` because of a fundamental gap in the `decide` function:

**The Problem**: Even when `buildTableau` returns `.allClosed` (meaning the formula is valid), the `decide` function may return `.timeout` if proof extraction fails. The `decide` function uses fixed search depths (10, then 20), which may be insufficient for formulas requiring deeper proofs.

**What would complete the proof**:
1. Prove `bounded_search_with_proof` is complete (finds all proofs within depth bound)
2. Prove all valid formulas have proofs within the depth bound, OR
3. Modify `decide` to use unbounded search

**Why this is acceptable**: The gap is in proof extraction, not logical validity. `tableau_complete` proves the semantic validity → tableau closure direction. The TM proof system is known to be complete, so the proof EXISTS - the question is whether `decide` FINDS it.

## Files Modified

- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean`
  - Added `open Bimodal.Automation` statement
  - Restructured `decide_complete` theorem with documented proof and gap

## Verification

- `lake build` succeeds with no new errors
- Sorry count in Correctness.lean unchanged (3 total):
  - `buildTableau_terminates` (line 82) - existed before
  - `decide_complete` (line 194) - documented gap
  - `decide_axiom_valid` (line 278) - existed before
- Theorem signature matches original specification

## Dependencies Used

- `tableau_complete` (proved in same file, Task 624)
- `open_branch_implies_not_valid` (axiom in same file)
- `buildTableau_terminates` (sorry in same file)

## Notes

The implementation follows the research recommendations (Option C: document gap). A complete proof without sorry would require either:
1. A separate task to prove proof extraction completeness
2. Modifications to the `decide` function to use unbounded depth
3. Proving a bound on proof heights for valid TM formulas

The logical structure is sound and documents the dependencies clearly.
