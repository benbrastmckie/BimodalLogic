# Phase 6BC Handoff: nf_characterizable_by_stavi Formula Fix

**Date**: 2026-05-27
**Session**: sess_1748407200_orch155b
**Status**: 1 sorry remaining (down from 2)

## What Was Done

### Bug Diagnosis

The prior proof of `nf_characterizable_by_stavi` used `nf_succ_sf` which assembled the characteristic formula from `nf_exist_sf` formulas. The critical bug: `nf_exist_sf` with `sf_top` guard mapped ALL 2-variable NFs with the same atom assignment to the SAME StaviFormula. When the actual NF of a structure assigned different quant values to same-atom sub_nfs (which is common for depth >= 2), the formula conjunction required both A and (not A) for the same formula A -- making the formula ALWAYS FALSE. Both original sorries were on FALSE statements.

### Fix Applied

Replaced the `nf_succ_sf`-based proof with a proof that uses classically-chosen existence formulas via a new lemma `nf_2var_existence_characterizable`. Each 2-variable NF gets its own formula (via Classical.choose) that correctly characterizes realizability. Both directions of the biconditional follow directly from the properties of the chosen formulas.

**Result**: 2 sorries (false) -> 1 sorry (true).

### The Remaining Sorry

```lean
private theorem nf_2var_existence_characterizable
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ...) (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ...)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (sf : StaviFormula),
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
          parent_atoms a = true) →
        (stavi_temporal_truth M atomMap t sf ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)
```

Located at line 1865 of StaviCompleteness.lean.

## What Needs to Be Done

To close `nf_2var_existence_characterizable`, two components are needed:

### 1. Build the correct formula (~50-100 lines)

The formula must encode the FULL 2-variable NF, not just atoms. Options:
- **Recursive construction**: For each 3-variable NF nf3 in sub_nf's quant part, add nested Until/Since formulas using the IH char_k. This produces a formula of depth proportional to k.
- **Interval guard approach** (GHR93 original): Replace sf_top in U(A, B) with a guard B that constrains intermediate point types using char_k. The guard specifies which 1-variable types must/must not appear in the interval.

### 2. Prove the backward direction (~150-300 lines)

Given formula truth, extract a witness x with the exact 2-variable NF. This requires:
- The game-theoretic argument that interval type profiles + endpoint types + order determine multi-variable NFs
- Bridge from game infrastructure (ghr93_strategy_compose, ghr93_game_iff_decomposition) to NF equality
- The game infrastructure is sorry-free in Composition.lean and Decomposition.lean

### Key Infrastructure Available

| Theorem | File | Status | Purpose |
|---------|------|--------|---------|
| ghr93_strategy_compose | Composition.lean | sorry-free | Game composition for interval splitting |
| ghr93_game_iff_decomposition | Decomposition.lean | sorry-free | Game <-> decomposition agreement |
| nf_eval_unique | NormalForm.lean | sorry-free | Two NFs satisfied at same env are equal |
| nf_characteristic_satisfies | NormalForm.lean | sorry-free | Canonical NF is satisfied |
| char_k_correct | IH (available) | sorry-free | Depth-k 1-var NF <-> StaviFormula truth |

## Immediate Next Action

Research the bridge from game wins to NF equality: how does `ghr93_game_iff_decomposition` (operating on ExtendedCarrier/rank_type) connect to `nf_eval_nf` (operating on NormalForm)? This bridge is the missing piece.
