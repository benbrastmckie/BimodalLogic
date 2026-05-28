# Phase 2 Start Handoff: Independent X_t Construction

**Status**: IN PROGRESS (started, not yet implemented)
**Session**: sess_1779994794_96be99
**Date**: 2026-05-28

## Context

Phase 1 is complete. The sorry at Theorem6.lean:325 (rank-varying IH, delta=4) is closed. Phase 2 is the next critical dependency.

## Phase 2 Requirements

Create `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (~200-300 lines).

### Key Definitions Needed

1. **nf_repr_stavi** : `NormalForm sig r 1 -> StaviFormula`
   - For each 1-variable NormalForm at rank r, produce a StaviFormula of depth <= r that characterizes it
   - Use `Classical.choice` on existence
   - Existence argument: each NF class is defined by agreement on depth-<=r StaviFormulas, so a finite conjunction of separating formulas suffices

2. **x_t_formula** : `ExtendedCarrier M atomMap r -> StaviFormula`  
   - X_t = the characteristic formula at position t
   - Conjunction of `nf_repr_stavi nf` for NFs satisfied at t, plus negations of others
   - Prove `stavi_depth (x_t_formula t) <= r`
   - Prove correctness: truth of x_t_formula at u iff rank_type equality with t

3. **x_interval_formula** : `ExtendedCarrier -> ExtendedCarrier -> StaviFormula`
   - A = disjunction of X_v for mu-points v in (t, u)
   - Prove depth bound and correctness

4. **sf_untl_formula** : `StaviFormula -> StaviFormula -> StaviFormula`
   - U(B, A) = `.std_untl B A`
   - Prove depth bound: `stavi_depth (sf_untl_formula B A) = max(stavi_depth B, stavi_depth A) + 2`

### Existing Infrastructure

- `StaviFormula` (StaviConnectives.lean:135): inductive type with base, neg, conj, std_untl, std_snce, stavi_untl, stavi_snce
- `stavi_depth` (Defs.lean:164): depth counting for temporal nesting
- `stavi_temporal_truth_mu` (TypeFormulas.lean:304): mu-relativized truth on ExtendedCarrier
- `rank_type` (TypeFormulas.lean:381): set of depth-<=r formulas true at position
- `interval_types` (TypeFormulas.lean:391): set of rank_types in interval
- `NormalForm sig k n` (NormalForm.lean:134): recursive type, Fintype for all k,n
- `rank_type_eq_iff` (TypeFormulas.lean:399): same rank_type => same truth on bounded formulas

### Critical Design Decision

The plan recommends constructing X_t independently (without nf_characterizable_by_stavi from StaviCompleteness.lean). The alternative (using nf_characterizable_by_stavi) would put sorry on bx_completeness critical path. The independent construction uses Classical.choice and the finiteness of NormalForm.

### Import Structure

CharacteristicFormula.lean should import:
- `Bimodal.Metalogic.WeakCanonical.EFGames.TypeFormulas` (for rank_type, stavi_temporal_truth_mu)
- `Bimodal.Metalogic.WeakCanonical.NormalForm` (for NormalForm, Fintype instance)

And NOT import:
- StaviCompleteness.lean (would put sorry on critical path)

## Next Immediate Action

Create CharacteristicFormula.lean with task 2.1 (nf_repr_stavi). Start with the existence proof using Classical.choice, then prove the depth bound.
