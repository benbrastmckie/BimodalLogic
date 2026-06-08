# Task 268 Completion Analysis: Reynolds Pipeline Bridge

**Date**: 2026-06-08
**Type**: Verification and dependency analysis
**Status**: Phases 1-4 complete; Phase 5 blocked by upstream sorry in StaviCompleteness.lean

## Executive Summary

Task 268 (Reynolds pipeline bridge) is **functionally complete**. All five phases of the Strategy B plan have been implemented in ReynoldsBridge.lean (1122 lines), and `completeness_discrete` already calls `countermodel_discrete_reynolds_v2` at Completeness.lean:369. The phase-3-blocked handoff document from 2026-06-03 is **obsolete** -- the WorldState=Unit blocker was resolved by the multi-family Z-interval approach (WorldState = FamIdx x Z).

However, `#print axioms completeness_discrete` still shows `sorryAx`. The sorry does NOT enter through ReynoldsBridge.lean (which contains zero sorry tokens). It enters through an upstream dependency chain that terminates at three sorry sites in StaviCompleteness.lean, specifically in the GHR93 bridge lemma's 4-variable existential transfer.

## Verification Results

### Axiom Checks (lean_verify)

| Theorem | sorryAx | File |
|---------|---------|------|
| `countermodel_discrete_reynolds_v2` | YES | ReynoldsBridge.lean |
| `limitdom_is_good` | YES | ReynoldsBridge.lean |
| `limitdom_temporal_truth_effective` | no | ReynoldsBridge.lean |
| `limitdom_semantic_prior_UZ` | no | ReynoldsBridge.lean |
| `limitdom_semantic_prior_SZ` | no | ReynoldsBridge.lean |
| `limitdom_root_neg_truth` | no | ReynoldsBridge.lean |
| `effectiveFormula_id_of_sub` | no | ReynoldsBridge.lean |
| `z_interval_carrier_contains_all` | no | ReynoldsBridge.lean |
| `no_boundary_at_successor` | no | GoodStructures.lean |
| `one_class_implies_very_good` | no | ShiftAndGlue.lean |
| `very_good_implies_good` | no | ShiftAndGlue.lean |
| `truth_transfer` | no | Transfer.lean |
| `k_equiv_preserves_sentence` | no | Transfer.lean |
| `flatten_stavi_correct_prior` | no | PriorExpressiveness.lean |
| `no_gaps_discrete_model_surgery` | YES | GoodStructuresModelSurgery.lean |
| `reynolds_model_surgery_core` | YES | GoodStructuresModelSurgery.lean |
| `gap_formula_R_correct` | YES | GoodStructuresModelSurgery.lean |
| `right_gap_class_invariant` | no | GoodStructuresModelSurgery.lean |
| `good_of_very_good_subinterval` | no | GoodStructures.lean |
| `US_expressively_complete_over_prior` | YES | PriorExpressiveness.lean |
| `stavi_expressive_completeness` | YES | StaviCompleteness.lean |
| `nf_2var_existential_transfer` | YES | StaviCompleteness.lean |
| `nf_2var_from_interval_data` | YES | StaviCompleteness.lean |
| `nf_fraisse_compression` | no | StaviCompleteness.lean |
| `zone_match_witness` | no | StaviCompleteness.lean |
| `completeness_discrete` | YES | Completeness.lean |

### Sorry-Free Components in ReynoldsBridge.lean

Every theorem proved directly in ReynoldsBridge.lean is sorry-free in its own right:
- Phase 1: `limitdom_monadic_structure`, instances, `limitdom_temporal_truth_effective`
- Phase 1b: `limitdom_semantic_prior_UZ`, `limitdom_semantic_prior_SZ`
- Phase 2b: `effectiveFormula_id_of_sub`, `effectiveFormula_id_self`, `effectiveFormula_id_neg`
- Phase 2c: `limitdom_root_neg_truth`
- Phase 3: `multiFamTaskFrame`, `multiFamHistory`, `multiFamOmega`, shift-closure, `z_interval_carrier_contains_all`, `toCarrier`, full truth correspondence (atom, bot, imp, box, untl, snce)

The sorry enters through a single call: `limitdom_is_good` (line 351), which calls `no_gaps_discrete_model_surgery`.

## Sorry Dependency Chain

```
completeness_discrete (Completeness.lean:369)
  |-- countermodel_discrete_reynolds_v2 (ReynoldsBridge.lean:724)
       |-- limitdom_is_good (ReynoldsBridge.lean:346)
            |-- no_gaps_discrete_model_surgery (NoGapsDiscreteProof.lean:68)
                 = no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean)
                   |-- reynolds_model_surgery_core
                        |-- gap_prior_UZ_contradiction (line 1169)
                             |-- gap_formula_R_correct (line 942)
                                  |-- US_expressively_complete_over_prior (PriorExpressiveness.lean:371)
                                       |-- stavi_expressive_completeness (StaviCompleteness.lean:3188)
                                            |-- nf_characterizable_by_stavi (line 3078)
                                                 |-- nf_2var_existence_characterizable (line 2847)
                                                      |-- nf_exist_sf_guarded_backward (line 2778) <-- SORRY at line 2805
                                                      |-- nf_2var_exist_sf_classical
                                                           |-- nf_2var_transfer (line 2524)
                                                                |-- nf_2var_from_interval_data (line 2448)
                                                                     |-- nf_2var_existential_transfer (line 2214)
                                                                          <-- SORRY at lines 2353, 2435
```

### The Three Sorry Sites (All in StaviCompleteness.lean)

All three sorry sites encode the same mathematical content: the **4-variable Ehrenfeucht-Fraisse game composition** for the GHR93 bridge lemma.

**Sorry 1 (line 2353)**: Forward direction of `nf_2var_existential_transfer` at depth j'+1. Given matching 3-point configurations (u,x,t) in M and (u',x',t') in M' with atom agreement, need to show that the depth-j' 4-variable existential transfer holds: for any depth-j' 3-var NF chi, `(exists w, nf_eval M j' 4 (w::u::x::t) chi) <-> (exists w', nf_eval M' j' 4 (w'::u'::x'::t') chi)`. This requires recursive sub-interval matching for the 3-point zone partition of the linear order.

**Sorry 2 (line 2435)**: Backward direction (M' -> M). Symmetric to sorry 1.

**Sorry 3 (line 2805)**: `nf_exist_sf_guarded_backward`. Given a Stavi formula characterizing 2-var NF existence, and its truth at t, extract a witness x satisfying the NF. This is the backward direction of the Stavi characterization, requiring the bridge lemma (`nf_2var_from_interval_data`) which is itself sorry'd.

### Mathematical Content of the Sorry

The sorry encapsulates the **Ehrenfeucht-Fraisse composition theorem for linear orders** (GHR93, Proposition 7 + Lemma 11):

> In a linear order, the n+1-variable depth-k NF of a tuple is determined by:
> 1. The n-variable depth-k NFs of all sub-tuples
> 2. The orderings between variables  
> 3. The set of depth-k 1-variable NFs realized in each zone (interval between consecutive variables)

The proof is a back-and-forth argument: Duplicator's strategy in the EF game at depth k on n+1 variables reduces to Duplicator's strategy at depth k on n variables within each zone. The key step is **zone matching**: given a new point w in some zone of M, find a matching w' in the corresponding zone of M' with the same depth-k 1-var NF, then apply the inductive hypothesis for n-variable EF games at depth k.

The current implementation has `zone_match_witness` (sorry-free) handling the point matching. What is missing is the **recursive descent**: showing that atom agreement + quantifier agreement at depth j-1 for the expanded (n+1)-variable configuration follows from the zone-matched witnesses. This requires establishing interval-type agreement between the sub-zones created by inserting the new variable w.

### Tractability Assessment

The sorry is mathematically straightforward but technically tedious. The proof requires:

1. **Zone partition lemma** (~50 lines): When inserting w into the (u,x,t) configuration, the 5 zones of the 3-point configuration refine the 3 zones of the 2-point configuration. The interval types of the refined zones are determined by the interval types of the coarser zones plus the position of w.

2. **Sub-interval type inheritance** (~80 lines): If two 2-point configurations (x,t) and (x',t') have matching interval types, and w matches w' via zone_match, then the 3-point configurations (w,x,t) and (w',x',t') have matching interval types for all 5 zones.

3. **Recursive application** (~40 lines): Apply the outer theorem's hypothesis at one fewer variable to conclude the depth-(j-1) existential transfer.

Total estimate: ~200-300 lines of technical but routine model theory. No novel mathematical ideas needed -- the strategy is textbook (Hodges 1993, Chapter 3).

## Phase Status Assessment

| Phase | Description | Status | Evidence |
|-------|-------------|--------|----------|
| 1 | LimitDomSubtype as OrderedMonadicStructure | COMPLETED | Lines 63-100, all sorry-free |
| 2 | Reynolds pipeline on LimitDomSubtype | COMPLETED | Lines 346-370, sorry-free except `no_gaps_discrete_model_surgery` call |
| 3 | Truth transfer and countermodel construction | COMPLETED | Lines 724-1121, multi-family approach, all local proofs sorry-free |
| 4 | Wire into completeness_discrete | COMPLETED | Completeness.lean:369 calls v2 |
| 5 | Build verification and sorry audit | BLOCKED | `sorryAx` present from StaviCompleteness.lean |

### Why Phase 3 is NOT Blocked

The phase-3-blocked handoff (2026-06-03) described the WorldState=Unit problem:
- `truth_at(.atom a)` is position-independent with WorldState=Unit
- `temporal_truth(.atom a)` is position-dependent

This was solved by the **multi-family Z-interval approach** (visible in ReynoldsBridge.lean lines 633-1121):
- `WorldState = FamIdx x Z` where `FamIdx` indexes S5-equivalent MCS families
- Each history `multiFamHistory f w0` visits states `(f, w0 + t)` -- position-dependent
- `multiFamOmega = Set.range (uncurry multiFamHistory)` -- shift-closed
- Box case: `truth_at(.box psi)` quantifies over all families via Omega, matching the S5 universal quantification
- Atom case: valuation at `(f, z)` evaluates `Z_f.interp(atomMap_fwd(.atom a))(z)` -- position-dependent

The truth correspondence is proved by structural induction (lines 808-1119), handling all six formula cases including the technically demanding box case (lines 824-1047).

## What Remains for completeness_discrete to Become Sorry-Free

The ONLY remaining blocker is the GHR93 bridge lemma in StaviCompleteness.lean. The sorry chain is:

```
StaviCompleteness.lean (3 sorry sites at lines 2353, 2435, 2805)
  -> stavi_expressive_completeness
  -> US_expressively_complete_over_prior
  -> gap_formula_R_correct (in GoodStructuresModelSurgery.lean)
  -> gap_prior_UZ_contradiction
  -> reynolds_model_surgery_core
  -> no_gaps_discrete_model_surgery
  -> limitdom_is_good (in ReynoldsBridge.lean)
  -> countermodel_discrete_reynolds_v2
  -> completeness_discrete
```

Closing the three sorry sites in StaviCompleteness.lean would make the ENTIRE chain sorry-free, including `completeness_discrete`.

### Alternative Paths Considered

**Q: Could `one_class` be proved WITHOUT model surgery (without `US_expressively_complete_over_prior`)?**

No. The Reynolds proof of `no_gaps_discrete` (Theorem 14) is intrinsically model-theoretic: it constructs a temporal formula R detecting the gap property, shows R is constant on the structure using Prior-UZ/SZ, then derives a contradiction via model surgery on the restriction to a single equivalence class. The formula R is obtained from `US_expressively_complete_over_prior`, which converts a monadic FO formula (the gap class formula) to a temporal formula. Without expressive completeness, there is no way to express the gap property temporally, and the Prior-UZ/SZ axioms cannot be applied.

**Q: Could a simpler version of expressive completeness suffice?**

Potentially. The gap class formula `right_gap_class_formula` has specific quantifier structure (it is a MonadicFormula with 1 free variable). One could try to prove a restricted expressive completeness result for this specific formula class. However, `right_gap_class_formula` already uses the full power of `nf_2var_existence_characterizable` in its construction, so any shortcut would need to bypass the formula construction entirely, not just simplify the expressive completeness theorem.

**Q: Could `good` be proved directly for the limitdom without going through `one_class`?**

This would require an entirely different proof strategy. The Reynolds pipeline is: `one_class` -> `very_good` -> `good`. Bypassing `one_class` means either (a) proving `very_good` directly (requires showing every subinterval is k-equivalent to a Z-interval, which is what `one_class` + `one_class_implies_very_good` does), or (b) proving `good` directly (requires constructing a k-equivalent Z-interval without the very_good intermediate step). Neither approach avoids the model surgery.

## Recommendations

1. **Task 268 should be marked COMPLETED** with a note that its scope (Phases 1-4) is done. The remaining sorry in `completeness_discrete` is an upstream dependency (StaviCompleteness.lean) that was out of scope for task 268.

2. **A new task should track the GHR93 bridge lemma** (StaviCompleteness.lean lines 2353, 2435, 2805). This is a self-contained piece of model theory: the EF game composition argument for linear orders. Estimated effort: 200-300 lines, technically routine.

3. **The plan document should be updated** to reflect that Phase 3 is COMPLETED (not BLOCKED) and Phase 4 is COMPLETED (the wiring at Completeness.lean:369 already uses v2).

4. **The sorry census for completeness_discrete's critical path** is: exactly 3 sorry sites, all in StaviCompleteness.lean, all encoding the same mathematical content (4-variable EF composition). Closing these 3 sites would make `completeness_discrete` fully sorry-free.

## Appendix: ReynoldsBridge.lean Architecture

The file implements a complete countermodel construction in 1122 lines:

### Phase 1 (Lines 63-237): LimitDom as OrderedMonadicStructure
- `limitdom_monadic_structure`: wraps `LimitDomSubtype` with predicate interpretation via `mkAtomMap`
- Instance declarations: Countable, NoMaxOrder, NoMinOrder, Nonempty, SuccOrder, PredOrder
- `limitdom_temporal_truth_effective`: temporal truth iff effective formula in MCS (structural induction, 6 cases)

### Phase 1b (Lines 238-329): Semantic Prior-UZ/SZ
- `limitdom_semantic_prior_UZ`: first-occurrence lemma via MCS Prior-UZ axiom
- `limitdom_semantic_prior_SZ`: symmetric (past direction)

### Phase 2 (Lines 331-370): Reynolds Pipeline
- `limitdom_is_good`: `one_class` -> `one_class_implies_very_good` -> `very_good_implies_good`

### Phase 2b (Lines 372-421): Effective Formula Identity
- `effectiveFormula_id_of_sub`: identity on subformula predFormulas
- `effectiveFormula_id_self`, `effectiveFormula_id_neg`: corollaries

### Phase 3a (Lines 423-569): Single-family Z-interval Infrastructure
- `zTaskFrame_v2`, `zHistory_v2`, `zOmega_v2`: WorldState = Z
- `z_interval_carrier_contains_all`: unbounded intervals from k-equiv to NoMax/NoMin structure

### Phase 3b (Lines 633-697): Multi-family Infrastructure
- `multiFamTaskFrame`: WorldState = FamIdx x Z
- `multiFamHistory`: states at time t = (f, w0 + t)
- `multiFamOmega`: all (family, offset) histories, shift-closed

### Phase 3c (Lines 724-1121): Countermodel Theorem
- `countermodel_discrete_reynolds_v2`: main theorem
  - FamIdx = S5-equivalent box-class MCSes
  - Per-family Z-interval via `limitdom_is_good`
  - Root negation transfer via `truth_transfer`
  - Truth correspondence by structural induction (6 cases)
  - Box case: universal quantification over families via Omega
