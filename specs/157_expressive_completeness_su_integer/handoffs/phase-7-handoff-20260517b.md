# Phase 7 Handoff: Quantifier Elimination Analysis Complete

**Date**: 2026-05-17 (third attempt)
**Session**: sess_1779003456_c5b522
**Status**: BLOCKED (deep analysis complete, implementation path identified)

## What Was Accomplished This Session

1. **Deep analysis of the quantifier elimination step**: Identified that the `const_at_ref` predicates are the core difficulty. They represent "P holds at reference time t" which is a CONSTANT from the quantified variable z's perspective, but cannot be expressed as a temporal formula over original atoms evaluated at varying times.

2. **Identified correct solution (case-split approach)**:
   - Iterate over all truth-value assignments sigma : sig.preds -> Bool
   - For each sigma, substitute const_at_ref_p_atom with top/bot
   - Apply level-aware R-atom substitution (lt_ref/gt_ref) using purity
   - Form finite disjunction with guards checking sigma matches M at t
   - Result uses only original atoms

3. **Added infrastructure to ExpressiveCompleteness.lean**:
   - `qdepth_reduceElimLast_le`: quantifier depth preservation (for n >= 1)
   - `extIntStruct`: extended IntStructure construction
   - `extAtomMap`: atom map for extended signature (extends original atomMap)
   - Detailed proof outlines in comments for .all and .ex cases

4. **Key mathematical insights documented**:
   - Global substitution of const_at_ref with atomMap(p) is UNSOUND (different semantics at s != t)
   - Level-aware substitution of lt_ref/gt_ref IS sound: in past-only parts at s < t, lt_ref = True; in future-only parts at s > t, gt_ref = True
   - `past_only_subst_correct` applies at time S (not t), and at s < t all times r <= s satisfy r < t
   - Case-split over Fintype (sig.preds -> Bool) handles const_at_ref correctly

## What Remains

Implement the 5-part quantifier elimination pipeline (~500 LOC):
- (a) `reduceElimLast_correct`: eval at (z,t) in sig <-> eval at z in extSignature
- (b) `extAtomMap_injective`: disjointness of base strings guarantees injectivity
- (c) `elimExtAtoms`: level-aware substitution function for properly separated formulas
- (d) Level-aware substitution correctness proofs
- (e) Case-split assembly with finite disjunction over assignments

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (2 sorries remain at lines ~525, ~540)
- `specs/157_expressive_completeness_su_integer/plans/03_hierarchy-first-plan.md` (updated BLOCKER)

## Immediate Next Action

If resuming: implement `reduceElimLast_correct` first (hardest due to Fin arithmetic). The env relationship is: `Fin.cons z (fun _ => t) : Fin 2 -> Int` maps 0->z, 1->t, and after reduction the env `(fun _ => z) : Fin 1 -> Int` maps 0->z. For nested quantifiers within alpha, the env grows via Fin.cons and the relationship propagates through the recursion.

## Dependencies

- Phase 6 (blocked): 8 axioms in SeparationThm.lean make h_sep depend on axioms
- The sorry in Phase 7 is independent of Phase 6's axioms (different mathematical content)
- Both blockers can be worked on independently
