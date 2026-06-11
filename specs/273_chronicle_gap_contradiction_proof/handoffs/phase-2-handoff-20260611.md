# Phase 2 Handoff: Abstract INF Hypothesis and Prior Instantiation

**Task**: 273 | **Phase**: 2 | **Status**: PARTIAL
**Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Completed

- Created `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` with:
  - `kplus`/`kminus` definitions (K+ operator from Rabinovich eq 5.2)
  - `kplus_formula` (TL encoding of K+)
  - `HasDefinableINF` structure (abstract first-occurrence hypothesis)
  - `HasDefinableSUP` structure (abstract last-occurrence hypothesis)
  - `prior_hasDefinableINF` theorem (sorry-free, Prior UZ instantiation)
  - `prior_hasDefinableSUP` theorem (sorry-free, Prior SZ instantiation)

## Remaining Work

1. **`inf_point_is_vef`**: Show the INF configuration is a VEF. This is needed by the negation closure proof (Phase 3) to construct VEF formulas from the INF point.

2. **`VEF.closed_conj`** (Lemma 3.2.1): Conjunction of two VEFs is VEF. The proof requires merging witness sequences from two interval patterns. For each pair of patterns (n1 witnesses, n2 witnesses), enumerate all interleaving orderings as separate VEF disjuncts.

3. **`VEF.closed_ex`** (Lemma 3.4): Existential quantification of a VEF is VEF. The existentially quantified variable becomes an additional witness point.

4. **Dedekind-complete instantiation**: Not cheap (requires ConditionallyCompleteLattice machinery from Mathlib). Should be a doc comment placeholder, not a sorry.

## Architecture Notes

The `HasDefinableINF` structure uses `r0 ≤ z1` (not strict `<`) to handle the case where the first occurrence is at the right boundary. The disjunction `P(r0) ∨ K+(P)(r0)` is essential for the general (non-Prior) case where the infimum may not be attained.

For Prior structures, the instantiation produces `Or.inl h_Pr0` — the P(r0) disjunct holds directly from `semantic_prior_UZ`, and K+ is never needed.

## Immediate Next Action

Phase 3 (Negation Closure) depends on Phase 2 completion (VEF closure properties). The continuation should either:
- Complete VEF closure properties first, then proceed to negation closure
- OR restructure to avoid VEF closure by working directly with temporal formulas (see architectural note below)

## Architectural Decision Point

The current VEF type (`IntervalPattern`, `VEF` in ExistsForallNF.lean) stores SEMANTIC interval patterns. The VEF closure proofs (closed_conj, closed_ex) require constructing new interval patterns from old ones, which involves complex witness-merging list manipulations.

An alternative approach: instead of proving VEF closure properties on the data type, prove `rabinovich_fo_to_temporal_prior` directly by a combined induction on quantifier depth and arity, using `nf_to_formula` to reduce the problem. This would bypass VEF closure entirely but requires a different proof strategy for the existential case. See report 09 for the root cause analysis.
