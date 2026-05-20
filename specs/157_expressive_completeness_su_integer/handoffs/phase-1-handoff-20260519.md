# Phase 1 Handoff: Plan v25 Blockers

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Plan**: v25 (GHR94-aligned oracle elimination)
**Session**: sess_1779243846_6348a0
**Date**: 2026-05-19
**Status**: BLOCKED at Phase 1

## Immediate Next Action

The plan v25 has two fundamental flaws that prevent implementation. A revised plan is needed before any code changes.

## Blockers

### Blocker 1: Phase 1 Task 1.3 -- Case 2 does NOT preserve single-U-type

**What failed**: The plan asks to prove `is_separable_preserving_U` for Cases 2, 5, 6, 7, 8 of `snce_single_U_depth_one_separable`. This requires proving that the separated output of each case has `has_single_U_type _ A B`.

**Why it fails**: Case 2 (`elim_case_2_gen` in `Eliminations.lean`) produces the output formula:
```
Formula.or psi_l psi1
```
where:
- `psi_l = (S(a, q ∧ ¬A) ∧ ¬A) ∧ G(¬A)`
- `psi1 = case1_psi a q (¬A ∧ ¬B) (¬A)` (Case 1 applied to different U-type args)

The `G(¬A)` component expands to `¬U(¬A, ⊤)` = `.imp (.untl (.imp A .bot) (.imp .bot .bot)) .bot`. This contains `.untl (.imp A .bot) (.imp .bot .bot)`, which has args `(¬A, ⊤)` -- NOT `(A, B)`. So `has_single_U_type psi_l A B` is FALSE.

Similarly, `psi1 = case1_psi a q (¬A ∧ ¬B) (¬A)` has `has_single_U_type _ (¬A ∧ ¬B) (¬A)`, NOT `has_single_U_type _ A B`.

**What was tried**: 
1. Traced through `elim_case_2_gen` proof in Eliminations.lean (lines 354-420)
2. Verified the output formula structure contains `Formula.all_future (Formula.neg A)`
3. Confirmed `Formula.all_future` expands to involve `.untl` with different args
4. Cases 5-8 in DedekindZ.lean use similar decompositions and likely have the same issue

**Root cause**: GHR94's language has {atom, ⊥, →, U, S} without `G` as a primitive. `¬U(A,B)` stays as `¬U(A,B)` (same U-type). Our Lean encoding has `all_future` as a derived operator using U, and the case proofs introduce `G(¬A) = ¬U(¬A, ⊤)` which is a different U-type. The Lean encoding of cases 2, 5-8 is NOT faithful to GHR94 in this respect.

**What is needed**: Either:
(a) Rewrite cases 2, 5-8 to not introduce new U-types (massive effort, requires redesigning the temporal decompositions), OR
(b) Find an alternative approach to oracle elimination that doesn't require single-U-type preservation through 10.2.4

### Blocker 2: Phase 4 -- Double induction termination gap

**What failed**: The plan's Phase 4 uses double strong induction on `(U_nesting_depth, count_U_total)` for `no_S_nested_sep`. At `UND ≤ 1`, it calls `lemma_10_2_6_no_oracle`, which internally uses `single_U_formula_separable_noax_param`. The oracle in `single_U_formula_separable_noax_param` at `snce_depth_of_U ≥ 2` produces formulas with unbounded `U_nesting_depth`, breaking the outer induction.

**Why it fails**: The oracle formula from `single_U_formula_separable_noax_param` is `.snce C'' F''` where C'', F'' are box-free separated forms. These can have `U_nesting_depth > 1` (e.g., when the separated form has nested `.untl` in S-free positions). The outer induction on `U_nesting_depth` at `d ≤ 1` cannot handle `d'' > 1`.

**What was tried**:
1. Analyzed the oracle formula structure from `single_U_formula_separable_noax_param` at depth ≥ 2
2. Constructed concrete example: callback formula `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c = `.snce (.snce (.atom p) (.atom x)) (.atom y)` gives `snce_depth_of_U = 2`
3. Verified that `U_nesting_depth` of the oracle formula is unbounded
4. Attempted alternative measures: `(JD, count_U_subformulas)`, `(UND, count_U_subformulas, sizeOf)` -- none capture the termination
5. Attempted fuel-based approach: infinite regress, no fixed depth suffices

**Root cause**: The oracle chain in `single_U_formula_separable_noax_param` can grow arbitrarily deep because:
1. Back-substitution creates `.snce` nodes with U inside nested `.snce`
2. These have `snce_depth_of_U ≥ 2`, triggering another oracle call
3. Each oracle call produces new `.snce` with potentially deeper nesting
4. No simple well-founded measure captures this

**What is needed**: A fundamentally different termination argument, possibly:
(a) Track a more refined measure that accounts for the nesting structure of `.snce` in separated forms
(b) Restructure the proof to avoid the oracle chain entirely (e.g., by proving `single_U_formula_separable` self-contained without going through separated forms)
(c) Use the approach from GHR94 directly: induction on "S-nesting above U" where applying 10.2.4 directly reduces the nesting (requires faithful GHR94 case proofs without introducing new U-types)

## Key Decisions

1. Plan v25 cannot be implemented as written
2. The core issue is the mismatch between GHR94's language (no `G` primitive) and our Lean encoding (where `G = ¬U(¬·, ⊤)` introduces new U-types)
3. A plan v26 is needed that either:
   - Redesigns the case proofs to be GHR94-faithful (avoiding `G`/`all_future`)
   - Finds a different termination argument for the oracle chain
   - Uses a completely different approach to oracle elimination

## Current State

- No code changes made to the codebase
- All existing proofs still build (`lake build` succeeds)
- Phase 1 blocked, Phases 2-5 depend on Phase 1

## Files Analyzed

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (2839 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (cases 1-2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (cases 5-8)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (280 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (441 lines)
