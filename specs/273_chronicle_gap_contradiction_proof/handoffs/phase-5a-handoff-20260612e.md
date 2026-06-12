# Phase 5a Handoff: Syntactic Negation Soundness BLOCKED

**Session**: sess_1781284347_6fed81
**Date**: 2026-06-12
**Phase**: 5a (VecEADecomposition.lean -- syntactic negation)
**Status**: BLOCKED

## Summary

Completed completeness proof for `neg_bracket_syn` (the syntactic BracketFormula negation), fixed caseB from a 2-witness to a 1-witness construction with `alpha0.neg.conj beta0.neg`, and proved `prepend_holds_direct`. However, SOUNDNESS of Case C is fundamentally blocked due to an interval mismatch between the counter-pattern's first witness and bf's first witness.

## What Changed

1. **Fixed caseB**: Changed from BracketFormula 2 to BracketFormula 1 with pointType = `alpha0.neg.conj beta0.neg`. This ensures soundness for Case B by forcing the counter-witness to differ from any alpha0 witness (via the negated alpha0 point type).

2. **Proved `prepend_holds_direct`**: Direct holds proof for `BracketFormula.prepend`, matching on k (0 and k'+1 cases). Sorry-free.

3. **Proved `neg_bracket_syn_complete`**: Full completeness proof by induction on n. All three cases (A: no alpha0, B: beta0 fails before alpha0, C: tail fails) are sorry-free.

4. **Identified Case C soundness blocker**: The soundness direction (neg_bracket_syn.holds -> not bf.holds) fails for Case C because:
   - The counter-pattern `bf_tail_neg.prepend beta0 alpha0` holds on (z0, z1) with some first witness `r`
   - The IH gives `not bf.tail.holds r z1`
   - But bf.holds gives `bf.tail.holds w(0) z1` where w(0) may differ from r
   - `bf.tail.holds w(0) z1` does NOT imply `bf.tail.holds r z1` when r < w(0) (the first segment widens, potentially violating segment type conditions)
   - Open-interval semantics prevent bracket constraints from forcing r = w(0)

## Sorry Inventory

- `neg_bracket_syn_iff` (line ~276): soundness direction only -- BLOCKED
- `neg_vecEA2_syn_iff` (line ~304): depends on neg_bracket_syn_iff -- BLOCKED
- KampPrior.lean:149: unchanged (Phase 5c target)
- NfCharFormula.lean:572: unchanged (Phase 5c target)
- NegationClosure.lean:1371: dead code (Phase 6)
- NfComposition.lean:106,108: bypassed

## Resolution Paths

### Path (a): Compactness/Finiteness Lift
Lift the semantic `neg_2var_vec_ea` to a model-independent version. Since VVecEA2 over a fixed finite TemporalPred set is finite, enumerate all VVecEA2 patterns and find one that works for all Prior models. Requires showing the negation's TemporalPred components are bounded by the input formula.

### Path (b): Semantic Prop 4.3
Change Prop 4.3 to produce model-dependent VVecEA2 (not uniform). The statement becomes: for each Prior M and MonadicFormula, there exists VVecEA2 equivalent on M. This weakens the result but may still suffice for KampPrior.lean if the final temporal formula can be constructed model-independently from the VVecEA2.

### Path (c): Canonical Witness Lemma
Prove that `bf.holds z0 z1` implies existence of a witness configuration where the first witness IS the first alpha0 occurrence. This would give `bf.tail.holds r0 z1` and resolve the interval mismatch. Requires showing the "canonical" configuration satisfies all segment type conditions on the wider interval (z0, r0).

### Path (d): Different Syntactic Construction
Replace Case C with a construction that doesn't require prepending. For example, use a single large bracket formula that encodes both "first occurrence" and "tail negation" in a single existential, avoiding the need to relate two separate existentials.

## Immediate Next Action

Research which resolution path is most promising. Path (c) seems most direct but requires a non-trivial "canonical witness" lemma. Path (a) requires finiteness infrastructure. Path (b) changes the statement.

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomposition.lean` -- 2 sorries (BLOCKED)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` -- semantic neg (sorry-free, reference)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` -- neg_interval_formula (sorry-free, reference)
