# Continuation Handoff: Rabinovich Pipeline (Plan v18) -- Post Phase 2

**Task**: 273 | **Status**: PARTIAL (Phases 1-2 complete, Phase 3 in progress)
**Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Progress Summary

### Phase 1: Translation Correctness [COMPLETED]
- Translation.lean: sorry-free (buildRight_correct, buildLeft_correct, translateEF1_correct, etc.)
- ExistsForallNF.lean: buildRight/buildLeft definition fixes

### Phase 2: Abstract INF + NfCharFormula [COMPLETED]
- PriorINF.lean: sorry-free (HasDefinableINF/HasDefinableSUP + Prior instantiation)
- NfCharFormula.lean: NEW file with formula construction for depth-(k+1) NF characterization

**Architecture change**: VEF closure properties (closed_conj, closed_ex, inf_point_is_vef)
SKIPPED in favor of NfCharFormula approach. The multi-arity VEF required by the original
plan is architecturally infeasible with the 2-boundary VEF type. NfCharFormula uses
classical existence (nf_2var_exist_formula_prior) instead.

### Phase 3: Negation Closure [IN PROGRESS]
- Plan heading marked [IN PROGRESS]
- Key sorry identified: nf_2var_exist_formula_prior in NfCharFormula.lean

### Phases 4-5: NOT STARTED

## The Single Remaining Key Sorry

The entire pipeline reduces to ONE sorry: **`nf_2var_exist_formula_prior`** in
Kamp/NfCharFormula.lean.

### Statement
```lean
theorem nf_2var_exist_formula_prior
    (k : Nat)
    (char_k : NormalForm sig k 1 -> Formula)
    (char_k_correct : ... temporal_truth <-> nf_eval_nf on Prior ...)
    (parent_atoms : AtomKind sig 1 -> Bool)
    (sub_nf : NormalForm sig k 2) :
    exists (A : Formula),
      forall M h_UZ h_SZ t,
        (atoms match parent_atoms) ->
        (temporal_truth M atomMap t A <->
         exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
```

### Why It Is Hard

The forward direction (existential -> formula) is easy: the witness x has a 1-var NF
characterized by char_k, and we build Until/Since formulas. (nf_exist_formula_forward,
currently sorry'd but mirrors proved StaviCompleteness code.)

The backward direction (formula -> existential) requires showing: if the Until formula
holds (there exists x > t with the right temporal predicates), then there ACTUALLY exists
x with the right 2-variable NF. This fails for general orders because the 1-var NF of x
does NOT determine the 2-var NF of (x, t).

For Prior structures, the backward direction IS provable because the UZ/SZ axioms
constrain which configurations are possible. Specifically, the Prior axioms give attained
first/last occurrences, which means interval properties between t and x are more
constrained than on general orders.

### Proof Approaches (in order of difficulty)

**Approach A: Model-Theoretic (recommended)**
Use the fact that on Prior structures, the depth-(k+1) NF of t determines the truth
value of any MonadicFormula sig 1 with qd <= k+1. Since `exists x, nf_eval_nf...` is
such a formula, it is determined by the NF. Build the temporal formula as a disjunction
over "good" depth-(k+1) NFs (those consistent with the existential being true).

The challenge: this requires depth-(k+1) NF characterizations, which is what we're
trying to build. The circularity must be broken.

**Approach B: Direct Construction with Guarded Formulas**
Replace the ⊤ guard in nf_exist_formula with an "interval guard" that captures the
types of intermediate points (like StaviCompleteness.interval_guard_sf). On Prior
structures, the interval guard + witness type determines the 2-var NF because:
- The 1-var NF of x determines predicates at x
- The order x > t is given
- The Prior-UZ axiom means that first occurrences of temporal predicates in (t,x)
  are attained, so the interval NFs are determined
This is essentially Rabinovich's negation closure argument.

**Approach C: Rabinovich's Full VEF Pipeline**
Define multi-arity VEF, prove VEF closure under conjunction/existential/negation
(with negation using HasDefinableINF/HasDefinableSUP), then compose with the
VEF-to-temporal translation. This is the most faithful to the paper but requires
500+ lines of multi-arity VEF infrastructure.

**Approach D: Bypass via nf_to_formula + Structural Induction**
Note that `exists x, nf_eval_nf M k 2 ... sub_nf` is equivalent to
`eval M (fun _ => t) (.ex (nf_to_formula sub_nf))`. So we need every
MonadicFormula sig 1 to have a temporal equivalent on Prior structures.
Prove this by structural induction on MonadicFormula, using a JOINT statement
at all arities. This requires defining "temporally definable at arity n"
and proving closure properties.

### Architecture After nf_2var_exist_formula_prior

Once nf_2var_exist_formula_prior is proved:

1. nf_characterizable_temporal_prior_classical (already in NfCharFormula.lean)
   gives depth-(k+1) NF characterizations from depth-k ones.

2. nf_characterizable_temporal_prior in KampPrior.lean can be filled:
   - Replace the sorry with a call to nf_characterizable_temporal_prior_classical
   - Or more directly, use nf_2var_exist_formula_prior + the classical assembly

3. kamp_prior_expressive_completeness (already proved modulo the sorry) becomes
   sorry-free.

4. US_expressively_complete_over_prior becomes sorry-free.

## File Inventory

| File | Status | Lines |
|------|--------|-------|
| Kamp/Translation.lean | Sorry-free | ~500 |
| Kamp/PriorINF.lean | Sorry-free | ~195 |
| Kamp/NfCharFormula.lean | 4 sorries (all gate on nf_2var_exist_formula_prior) | ~520 |
| Kamp/ExistsForallNF.lean | Clean (buildRight/buildLeft fix from Phase 1) | ~267 |
| Kamp/KampPrior.lean | 1 sorry (nf_characterizable_temporal_prior k+1) | ~253 |

## Build Status

- `lake build` succeeds
- Sorry count: 1 in KampPrior.lean (unchanged), 4 in NfCharFormula.lean (new infrastructure)
- All new sorry in NfCharFormula.lean are subordinate to filling the KampPrior.lean sorry
- No new axioms, no vacuous definitions

## Commit History (This Session)

- b8c2fd815: task 273 phase 2: NfCharFormula architecture for Prior NF characterization

## Immediate Next Action

1. Fill nf_exist_formula_forward (EASY: ~150 lines, mirrors StaviCompleteness.nf_exist_sf_forward)
2. Prove nf_2var_exist_formula_prior (HARD: the Phase 3 deliverable, ~500-1000 lines)
3. Wire NfCharFormula into KampPrior to fill the original sorry
4. Final verification (lake build, lean_verify, #print axioms)
