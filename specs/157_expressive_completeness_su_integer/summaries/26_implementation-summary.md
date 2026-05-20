# Implementation Summary: Task 157 -- GHR94-Faithful Case 2 Fix (v27)

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Plan**: v27 (Case 2 fix plan)
**Session**: sess_1779254268_6ebef4
**Status**: PARTIAL (Phase 1 complete, Phase 2 blocked)

## Changes Made

### Phase 1: Rewrite Case 2 to Match GHR94 [COMPLETED]

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean`

1. Defined `case2_psi a q A B : Formula` producing GHR94's 3-disjunct output:
   - d1 = `S(a, q^!A) ^ !A ^ !U(A,B)` -- only U is U(A,B) inside neg U(A,B)
   - d2 = `!A ^ !B ^ S(a, !A^q)` -- U-free
   - d3 = `S(!A^!B^q^S(a, !A^q), q)` -- U-free

2. Rewrote `elim_case_2_gen` with new semantic proof:
   - Forward: split neg_until_equiv at event point s into G and U' branches
   - G branch -> d1 (neg U(A,B) at t via G(neg A) implication)
   - U' branch: case split witness u vs t -> d3 (u<t), d2 (u=t), d1 (u>t)
   - Backward: reconstruct neg U(A,B) at event s using neg A on (s,t) + neg U(A,B) at t

3. Simplified `elim_case_2` to delegate to `elim_case_2_gen`

**Key property**: The output preserves `has_single_U_type _ A B` -- the ONLY U in the output is `(.untl A B)` inside `neg U(A,B) = .imp (.untl A B) .bot`.

### Phase 2: Partial Progress [BLOCKED]

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

1. Proved `case2_psi_has_single_U_type`: structural proof that `case2_psi a q A B` has single U-type `(A, B)` when a, q, A, B are U-free.

2. Fixed pre-existing broken proofs:
   - `case1_psi_has_single_U_type`: added missing `hA`, `hB` hypotheses (A, B U-free)
   - `imp_separable_with_type`: replaced `imp_congr` (Mathlib Prop-level, wrong type) with inline int_equiv congruence proof

### Phases 3-5: Not Started (Blocked by Phase 2)

## Blocker Analysis

Phase 2 Task 2.4 (`snce_single_U_depth_one_sep_with_U_type`) requires ALL 8 cases of Lemma 10.2.3 to produce separated output with `has_single_U_type`. Cases 1-4 can do this (explicit formulas with known structure). Cases 5-8 CANNOT because they use `all_separable` (an axiom) which provides no control over the U-type structure of the existentially quantified separated formula.

To unblock, one of:
- (A) Rewrite Cases 5-8 with explicit integer-time formulas that preserve single U-type. This is a significant mathematical challenge -- GHR94's explicit formulas for Cases 5-8 are known to be incorrect on discrete (integer) time.
- (B) Find an alternative proof strategy that avoids needing `is_separable_with_U_type` from 10.2.4 at the leaf level.
- (C) Accept that the oracle chain cannot be eliminated through the single-U-type approach and find a different termination argument.

## Build Status

- `lake build` succeeds with zero errors
- No new `sorry` introduced
- No new axioms introduced
- 12 existing axioms remain (same as baseline)

## Plan Deviations

- Task 1.3 deferred to Phase 2 (proved as `case2_psi_has_single_U_type` in Hierarchy.lean)
- Task 1.5 simplified: `elim_case_2` delegates to `elim_case_2_gen` instead of duplicating proof
- Phase 2 Tasks 2.3-2.4 blocked by Cases 5-8 using `all_separable` axiom

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Phase 1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (Phase 2 partial)
