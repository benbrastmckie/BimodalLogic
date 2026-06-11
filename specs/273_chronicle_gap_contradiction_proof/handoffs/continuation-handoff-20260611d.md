# Continuation Handoff: Phase 3a Progress -- Master Induction Architecture

**Task**: 273 | **Status**: PARTIAL (Phases 1-2 complete, Phase 3 in progress)
**Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Summary of This Session's Progress

### Architecture Established: Master Simultaneous Induction

Created `Kamp/NegationClosure.lean` (~200 lines) with the correct proof architecture for `nf_2var_exist_formula_prior`. The key insight (confirmed after extensive analysis of 6+ circular approaches):

**The only non-circular approach** is a simultaneous induction on k proving both:
- P1(k): depth-k arity-1 NF temporal characterizations
- P2(k): depth-k 2-var existential temporal formulas

The step k -> k+1 uses:
- P1(k+1) from P1(k) + P2(k) via `nf_char_kp1_from_2var` (inlined version of `nf_characterizable_temporal_prior_classical` that takes P2(k) as parameter instead of calling the sorry'd version)
- P2(k+1): forward direction is universal (no Prior needed); backward direction requires Prior axioms + composition theorem

### File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean`

Key definitions (all compiling):
- `nf_2var_depth0_components`: reconstructs arity-2 NF from component data (sorry in atom/order case analysis)
- `backward_depth0`: backward direction of nf_exist_formula at depth 0 (sorry, pure case analysis)
- `nf_char_kp1_from_2var`: builds P1(k+1) from P1(k) + P2(k), sorry-free
- `master_induction`: the simultaneous induction, sorry at k+1 backward
- `nf_2var_exist_formula_prior_fill`: extracts P2(k) from master_induction

### Sorry Status

| Location | Content | Difficulty | Estimated Lines |
|----------|---------|------------|-----------------|
| `nf_2var_depth0_components` | atom_eval case analysis for arity-2 NF at depth 0 | Low | ~30 |
| `backward_depth0` | Extract witness from Until/Since, apply depth0_components | Medium | ~80 |
| k+1 backward in `master_induction` | Rabinovich composition theorem / negation closure | **High** | 400-600 |

### What Was Tried and Why It Failed

Six alternative approaches were analyzed before settling on the master induction:

1. **Doets at depth k+1**: the existential has qd <= k+1, so it depends on depth-(k+1) NF. But expressing depth-(k+1) NFs requires P2(k), which is what we're proving. **Circular.**

2. **char_k alone (no char_{k+1})**: char_k gives depth-k characterizations, but the backward direction of nf_exist_formula at depth k+1 requires knowing the depth-(k+1) arity-2 NF of (x,t), which involves depth-k arity-3 existentials not covered by char_k. **Arity escalation.**

3. **Composition theorem from arity-1 NFs**: same arity-1 NFs + order should determine arity-2 NF on Prior. TRUE at k=0, but at k+1 the quantifier conditions involve arity-3 NFs in intervals, which are NOT determined by arity-1 NFs alone. **Requires arity-2 NF theory.**

4. **qd-based induction on MonadicFormula**: `.ex (nf_to_formula sub_nf)` has qd <= k+1, but the sub-problems also have qd <= k+1. **Same-depth, no decrease.**

5. **VEF closure without explicit VEF data**: tried to prove negation closure abstractly, but still requires the interval composition argument.

6. **Classical fixed-point**: use AC to simultaneously choose formulas for all sub_nf. Requires proving existence first, which is the original problem.

The master simultaneous induction (approach #7) breaks ALL these circularities by proving P1(k) and P2(k) together, where P2(k) feeds into P1(k+1) which feeds into P2(k+1). The only remaining content is the k+1 backward direction.

### Why the k+1 Backward Direction IS the Negation Closure

The backward direction at depth k+1 says: if `witness_type Until top` holds at t (with witness_type built from char_{k+1}), then exists x with the right depth-(k+1) arity-2 NF.

We have x > t with char_{k+1}(nf_x) holding. From char_{k+1}(nf_x), we know the depth-(k+1) arity-1 NF of x. From h_atoms, we know the depth-(k+1) arity-1 NF of t. From Until, we know t < x.

We need: the depth-(k+1) arity-2 NF of (x,t) matches sub_nf. The atoms part is easy. The quantifier part asks: for each depth-k arity-3 sub_sub_nf, does exists y with that 3-var NF exist?

By IH at depth k, depth-k arity-3 NFs are determined by depth-k arity-1 NFs + orders. So the question reduces to: for each (nf_y, position_of_y), does there exist y in that position with that arity-1 NF?

For y outside (t, x): determined by the depth-(k+1) arity-1 NFs of t and x (their quantifier conditions encode nearby existence).

For y in (t, x): this is where Prior is essential. On Prior structures, whether a specific depth-k arity-1 NF nf_y occurs between t and x is constrained by:
- Prior-UZ: if char_k(nf_y) occurs above t, the first occurrence is attained
- The position of this first occurrence relative to x determines occurrence in (t,x)

This positional determination uses the depth-(k+1) arity-1 NFs of t and x in a non-trivial way. The proof requires:
1. Showing that for each char_k(nf_y), "char_k(nf_y) occurs in (t,x)" is determined by the depth-(k+1) arity-1 NFs of t and x
2. This uses Prior-UZ/SZ applied at t with char_k(nf_y) as the temporal predicate
3. The first occurrence r_0 of char_k(nf_y) above t has r_0 < x iff char_k(nf_y) occurs in (t,x)
4. Whether r_0 < x is encoded in the relationship between the quantifier conditions of the depth-(k+1) NFs of t and x

This is the Rabinovich composition theorem, equivalent in content to Lemma 5.1 (negation closure).

## Immediate Next Action (for next session)

1. **Fill `backward_depth0`** (~80 lines): pure case analysis. Unfold nf_exist_formula, case-split on t-compatibility, order direction, extract witness from Until/Since, use char_0_M for atom data, apply nf_2var_depth0_components. The proof mirrors nf_exist_formula_forward from NfCharFormula.lean but in reverse.

2. **Fill `nf_2var_depth0_components`** (~30 lines): the atom_eval case analysis for .pred and .order with Fin 2. Main challenge is Fin.cons evaluation at specific indices. Use `simp [atom_eval, Fin.cons]` + hypothesis application.

3. **Fill k+1 backward direction** (~400-600 lines): The core Rabinovich content. Prove composition theorem at depth k+1 using:
   - IH at depth k (from P1(k) and P2(k))  
   - Prior-UZ/SZ for interval properties
   - The depth-(k+1) arity-1 NFs of x and t (from char_{k+1} + nf_exist_formula witness)

4. **Wire into NfCharFormula.lean**: Replace sorry at line 572 with call to `nf_2var_exist_formula_prior_fill`.

## File Inventory

| File | Status | Sorries |
|------|--------|---------|
| Kamp/Translation.lean | Sorry-free | 0 |
| Kamp/PriorINF.lean | Sorry-free | 0 |
| Kamp/ExistsForallNF.lean | Clean | 0 |
| Kamp/NfCharFormula.lean | 1 sorry (nf_2var_exist_formula_prior) | 1 |
| Kamp/KampPrior.lean | 1 sorry (nf_characterizable_temporal_prior k+1) | 1 |
| **Kamp/NegationClosure.lean** | **3 sorries (depth-0 x2, k+1 backward)** | **3** |

## Build Status

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds (with sorry warnings)
- All other Kamp pipeline files build as before
