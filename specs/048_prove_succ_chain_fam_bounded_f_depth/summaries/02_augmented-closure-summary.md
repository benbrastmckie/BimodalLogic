# Implementation Summary: Task #48 v2 (Augmented Deferral Closure)

## Status: PARTIAL (Phases 0-3 complete, Phase 4 partial, Phases 5-6 not started)

## What Was Accomplished

### Phase 0: Closure Question Analysis [COMPLETED]
- Confirmed that `chi or F(chi)` is NOT a subformula when `F(chi)` is a subformula
- Verified all three seed components and their closure membership
- Determined that H-blocking formulas stay in u (hence in deferralClosure) when u is a full MCS

### Phase 1: Deferral Closure Definitions [COMPLETED]
- Added to `SubformulaClosure.lean`:
  - `extractFutureInner`, `extractPastInner` - extract inner formula from F/P patterns
  - `IsFutureFormula`, `IsPastFormula` - decidable predicates
  - `toFutureDeferral`, `toPastDeferral` - convert F/P formulas to deferral disjunctions
  - `deferralDisjunctionSet` - Finset of {chi or F(chi) | F(chi) in closureWithNeg}
  - `backwardDeferralSet` - Finset of {chi or P(chi) | P(chi) in closureWithNeg}
  - `deferralClosure` - closureWithNeg union deferralDisjunctionSet union backwardDeferralSet
  - Membership theorems: `deferral_of_F_in_closure`, `deferral_of_P_in_closure`

### Phase 2: F/P-Depth Bounding [COMPLETED]
- Proved that deferral disjunctions have f/p_nesting_depth = 0
- Proved `max_F_depth_deferralClosure_eq`: sup of f_nesting_depth over deferralClosure = max_F_depth_in_closure
- Proved symmetric `max_P_depth_deferralClosure_eq`
- Key insight: disjunctions are imp formulas, not F/P formulas

### Phase 3: DeferralRestrictedMCS [COMPLETED]
- Added to `RestrictedMCS.lean`:
  - `DeferralRestricted`, `DeferralRestrictedConsistent`, `DeferralRestrictedMCS` - definitions
  - `deferral_restricted_lindenbaum` - Zorn's lemma extension within deferralClosure
  - `deferral_restricted_mcs_negation_complete` - for formulas in subformulaClosure
  - `iter_F_not_mem_deferralClosure`, `iter_P_not_mem_deferralClosure` - exit bounds
  - `deferral_restricted_mcs_F_bounded`, `deferral_restricted_mcs_P_bounded` - F/P-nesting boundaries

### Phase 4: Seed Subset Lemmas [PARTIAL]
- Added to `SubformulaClosure.lean`:
  - `all_future_in_deferralClosure_is_in_closureWithNeg` - structural lemma
  - `all_past_in_deferralClosure_is_in_closureWithNeg` - structural lemma
  - `some_future_in_deferralClosure_is_in_closureWithNeg` - via depth argument
  - `some_past_in_deferralClosure_is_in_closureWithNeg` - via depth argument
  - `deferralClosure_all_future`, `deferralClosure_all_past` - G/H subformula lemmas
- Added to `SuccChainFMCS.lean`:
  - `g_content_subset_deferralClosure` - g_content stays in closure
  - `deferralDisjunctions_subset_deferralClosure` - deferral disjs stay in closure
  - `h_content_subset_deferralClosure` - h_content stays in closure
  - `pastDeferralDisjunctions_subset_deferralClosure` - past deferral disjs stay in closure
  - `f_step_blocking_formulas_subset_u` - blocking formulas are in u (new theorem)
  - `constrained_successor_seed_subset_deferralClosure` - full seed stays in closure
  - `predecessor_deferral_seed_subset_deferralClosure` - predecessor seed stays in closure

## What Remains (Blocking Issue)

### The Core Problem
The chain construction (`forward_chain`, `backward_chain`) uses `lindenbaumMCS_set` which produces
**full** `SetMaximalConsistent` sets. These are NOT restricted to deferralClosure.

The restricted alternatives (`DeferralRestrictedMCS`) are maximal only within deferralClosure.
They are NOT full MCS and lack:
- Global negation completeness (only within deferralClosure)
- Full closure under modus ponens for formulas outside deferralClosure

This is a problem because:
1. The `constrained_successor_seed_consistent` proof needs full MCS properties
   (specifically `p_step_blocking_formulas_subset_u` which uses `negation_complete` and `double_neg_elim`)
2. The `backward_witness` lemma needs `CanonicalTask_backward_MCS_P` which carries the P-step property
3. P-step blocking requires full MCS for the derivation `P(phi) notin u -> H(neg phi) in u`

### Viable Path Forward (for future session)
The seed subset lemmas prove that seeds stay in deferralClosure when u is a **full MCS**
within deferralClosure. This suggests the correct approach:

1. Define `DeferralBoundedMCS` as a full MCS (via lindenbaumMCS_set) that happens to be
   WITHIN deferralClosure. This is stronger than DeferralRestrictedMCS.
2. Prove that `lindenbaumMCS_set(seed)` stays in deferralClosure when seed is in deferralClosure.
   This requires showing that Lindenbaum's enumeration-based extension, when the seed is within
   a finite closure, doesn't escape the closure.
3. Alternatively, use `restricted_lindenbaum` to get a restricted MCS, then embed it into a
   full MCS while proving the full MCS stays within closure (not obvious).
4. Or prove the needed MCS properties (negation completeness, double neg elimination) for
   DeferralRestrictedMCS for the specific formula classes that appear in the proofs.

### Sorry Count
- Original sorries: 2 (f_nesting_is_bounded, p_nesting_is_bounded - deprecated, mathematically false)
- New sorries: 0
- Net change: 0 (original sorries remain, no new ones introduced)

## Files Modified
1. `Theories/Bimodal/Syntax/SubformulaClosure.lean` - deferralClosure definitions + structural lemmas
2. `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - DeferralRestrictedMCS + F/P bounds
3. `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - seed subset lemmas

## Build Status
`lake build` succeeds with no new errors or sorries.
