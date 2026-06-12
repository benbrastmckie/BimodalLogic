# Phase 5a Handoff: Syntactic V-EA Negation Infrastructure

**Session**: sess_1781284347_6fed81
**Date**: 2026-06-12
**Phase**: 5a (VecEADecomposition.lean -- Lemma 3.2.2)
**Status**: IN PROGRESS (architecture designed, partial implementation)

## Summary

Extensive analysis of the P1/P2 circularity and the Rabinovich approach has been completed. The key architectural decisions have been made and initial infrastructure is in place.

## Key Findings from Analysis

### The Circularity (Confirmed)

The fundamental circularity is:
- P1(k+1) requires P2(k) (via `nf_characterizable_temporal_prior_classical`)
- P2(k) requires P1(k+1) (via `p2_from_p1_succ`, or via the fact that the
  truth of `∃x, nf_eval_nf M k 2 (x,t) sub_nf` depends on depth-(k+1) NF of t)

This CANNOT be resolved by:
- Strong induction on k (P2(k) still needs P1(k+1))
- Modified induction proving P1 alone (P1(k+1) uses P2(k) via `nf_char_kp1_from_2var`)
- NF enumeration at depth k+1 (requires P1(k+1) to characterize NFs)

### The Resolution: Rabinovich Prop 4.3

The ONLY way to break the circularity is structural induction on `MonadicFormula`
(Rabinovich Prop 4.3). This simultaneously proves V-EA equivalence at ALL depths,
avoiding the depth-indexed induction entirely.

### Required Infrastructure

The structural induction requires:
1. **V-EA equivalence at arity 1**: temporal Formula equivalent
2. **V-EA equivalence at arity 2**: VVecEA2 equivalent (UNIFORM, model-independent)
3. **V-EA equivalence at arity ≥ 3**: for the `.ex` case at arity 2

For the `.not` case at arity 2, **UNIFORM Prop 4.2** is needed:
Given VVecEA2 v, construct VVecEA2 v' such that for ALL Prior M, z0 < z1:
v'.holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1

The existing `neg_2var_vec_ea` in NegationClosureProp42.lean is SEMANTIC
(model-dependent). The uniform version requires syntactic construction.

### Architecture Decision: Syntactic Negation

The syntactic negation of BracketFormula n is constructed by induction on n:
- n = 0: 1-witness counter-pattern with negated segment type
- n+1: three families (A: α₀ absent, B: β₀ fails before α₀, C: tail fails)

This is implemented in `neg_bracket_syn` in VecEADecomposition.lean.

## Completed Work

### VecEADecomposition.lean (new file, compiles with 3 sorries)

1. **`neg_bracket_syn`** (definition, sorry-free): Syntactic negation of
   BracketFormula. Produces a VBracketFormula by case analysis:
   - n=0: `purePoint (β₀.neg)`
   - n+1: caseA (pureSeg α₀.neg) ++ caseB (2-witness β₀.neg/α₀) ++ caseC (prepend to tail negation)

2. **`neg_bracket_syn_sound`** (sorry): If counter-pattern holds, then ¬bf.holds.
   Strategy: case split on which disjunct holds.
   - caseA: if pureSeg α₀.neg holds, then no α₀ witness exists, so bf can't hold
   - caseB: if 2-witness pattern holds, β₀ fails in (z0, first-α₀-witness)
   - caseC: if prepended tail-negation holds, tail fails after first witness

3. **`neg_bracket_syn_complete`** (sorry): Over Prior, ¬bf.holds → counter-pattern holds.
   Strategy: induction on n, using `first_occurrence_prior` from NegationClosure5.lean.
   - n=0: push_neg gives witness y with ¬β₀(y), match with purePoint
   - n+1: three cases using Prior-UZ for first occurrence of α₀

4. **`neg_vecEA2_syn`** (definition, sorry-free): Negation of VecEA2 via de Morgan.

5. **`neg_vecEA2_syn_iff`** (sorry): Correctness, follows from neg_bracket_syn_iff.

6. **`nf_exist_as_monadic`** (SORRY-FREE): Bridge lemma showing
   `∃x, nf_eval_nf M k 2 (x,t) sub_nf ↔ eval M (fun _ => t) (.ex (nf_to_formula sub_nf))`

## What Remains

### Phase 5a Completion (~3-4 hours estimated)

1. **Fill `neg_bracket_syn_sound`**: ~60-80 lines. Case analysis on which
   disjunct of the VBracketFormula holds. For each case, show that bf.holds
   leads to contradiction with the counter-pattern's conditions.

2. **Fill `neg_bracket_syn_complete`**: ~100-150 lines. By induction on n.
   Uses `first_occurrence_prior_strict` from NegationClosure5.lean for the
   n+1 case. The existing `neg_interval_formula` proof structure can be
   closely followed.

3. **Build `neg_vvecEA2_syn` properly**: For conjunction of negated disjuncts.
   The conjunction of multiple VVecEA2's requires distributing disjunctions.
   Strategy: given VVecEA2 with disjuncts [d₁,...,dₖ], the negation is
   ∧ᵢ neg_vecEA2_syn(dᵢ). Each neg is a VVecEA2 (disjunction). The conjunction
   of disjunctions = disjunction of selections (one from each neg).
   Size: product of disjunct counts, potentially exponential but FINITE.

### Phase 5b: Prop43.lean (~3-4 hours)

Structural induction on MonadicFormula to produce VVecEA2 at arity 2 and
temporal Formula at arity 1.

Key cases:
- `.atom`, `.lt`: trivial VVecEA2 with 0 witnesses
- `.not`: IH gives VVecEA2, negate via neg_vvecEA2_syn
- `.and`: IH gives two VVecEA2's, conjoin via syntactic conjunction
- `.ex`: IH at arity 3 gives pairwise VVecEA2's, existential closure
- `.all`: rewrite as ¬∃¬, use .ex + .not cases

The `.ex` case at arity 2 (α at arity 3) is the HARDEST: requires
V-EA at arity 3 and existential closure to arity 2. Strategy: represent
arity-3 V-EA as conjunction of VVecEA2's on pairs (0,1), (0,2), (1,2).
Existential: fold variable 0 into brackets, splitting by order class.

### Phase 5c: Bridge Wiring (~1 hour)

Use `nf_exist_as_monadic` + Prop 4.3 at arity 1 to fill KampPrior.lean:149:
1. nf_to_formula nf : MonadicFormula sig 1
2. Prop 4.3 gives temporal A with temporal_truth ↔ eval
3. nf_to_formula_correct gives eval ↔ nf_eval_nf
4. Compose: temporal_truth ↔ nf_eval_nf

### Phase 6: Full Build Verification (~0.5 hours)

## Immediate Next Action

The successor agent should:
1. Fill `neg_bracket_syn_sound` and `neg_bracket_syn_complete` in
   VecEADecomposition.lean (following the structure of `neg_interval_formula`
   in NegationClosure5.lean)
2. Build `neg_vvecEA2_syn` as proper conjunction-of-negations
3. Then proceed to Prop43.lean with the structural induction

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomposition.lean` -- NEW (3 sorries)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` -- neg_interval_formula (reference)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` -- neg_2var_vec_ea (reference)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:149` -- TARGET sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean:572` -- TARGET sorry

## Sorry Inventory (unchanged from plan v22)

- KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ case) -- 1 sorry
- NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) -- 1 sorry
- NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`) -- 1 sorry (dead code)
- NfComposition.lean:106,108 (`nf_3var_from_1var_nfs`) -- 2 sorries (bypassed)
- VecEADecomposition.lean -- 3 sorries (NEW, Phase 5a in progress)
