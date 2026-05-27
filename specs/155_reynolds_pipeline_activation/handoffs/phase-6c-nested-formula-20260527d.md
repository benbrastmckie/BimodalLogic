# Phase 6C Handoff: nf_2var_existence_characterizable — Nested Formula Analysis

**Date**: 2026-05-27
**Session**: sess_1779910019_ec7547
**Status**: 1 sorry remaining, Phase 6C BLOCKED

## Current State

- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
- **Sorry location**: Line 1865
- **Build**: Passes with 1 sorry warning
- **All other code**: Unchanged from prior session

## What Was Done This Session

### Deep Analysis of the Backward Direction

Spent the session analyzing WHY the backward direction of `nf_2var_existence_characterizable` is hard and evaluating 5 different proof strategies. All were found to be either circular, insufficient, or require substantial new infrastructure.

### Key Finding: The Core Issue

The formula `nf_exist_sf` uses `sf_top` as the guard in Until/Since. This means:
- `U(witness_type, sf_top)` says "there exists x above t where x has the right 1-variable depth-k type"
- The forward direction works: if x has the right 2-var type, it certainly has the right 1-var type
- The backward direction FAILS for k > 0: knowing x's 1-var type does NOT determine the 2-var type of (x,t)

At depth 0, the 2-var NF is purely atomic (predicates at x and t, plus order between them), so the 1-var type + order IS sufficient. The backward direction at k=0 is provable (~100 lines).

At depth k > 0, the 2-var NF includes quantifier information: for each `sub3 : NormalForm sig (k-1) 3`, whether `exists y, nf_eval_nf M (k-1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) sub3`. This depends on ALL three of (y, x, t), not just x alone.

### Strategies Evaluated

| # | Strategy | Verdict | Why |
|---|----------|---------|-----|
| 1 | Prove backward of nf_exist_sf with sf_top | FAILS k>0 | 1-var type of x doesn't determine 2-var type of (x,t) |
| 2 | "Good NF" disjunction (a la stavi_expressive_completeness) | FAILS | Property has QD k+1, char_k only provides depth-k information |
| 3 | NF finiteness + definability | CIRCULAR | Showing invariance under StaviFormula equivalence IS expressive completeness |
| 4 | Reduce to stavi_expressive_completeness | CIRCULAR | stavi_expressive_completeness uses nf_characterizable_by_stavi at depth k+1 |
| 5 | **Nested temporal formula construction** | **VIABLE** | Build recursive formula encoding full 2-var NF; ~700-1000 lines |

### The Viable Approach: Nested Temporal Formula

**Idea**: Build a formula that encodes not just the 1-var type of x but the FULL 2-var type of (x,t), by recursively encoding the quantifier part.

For `sub_nf : NormalForm sig (k'+1) 2` where `sub_nf = (atoms, quant)`:
- Build `U(witness_type AND quant_constraints, sf_top)` where:
  - `witness_type` = disjunction of `char_k nf_x` for atom-compatible nf_x (same as current)
  - `quant_constraints` = conjunction over all `sub3 : NormalForm sig k' 3`:
    - If `quant sub3 = true`: a nested temporal formula expressing `exists y, nf_eval_nf M k' 3 (Fin.cons y (Fin.cons x (fun _ => t))) sub3`
    - If `quant sub3 = false`: negation of the above

Each nested temporal formula for `exists y, 3-var-NF at (y,x,t)` is itself built using:
- Case-split on order atoms of sub3 to determine y's position relative to x
- Until/Since at x (evaluated inside the outer Until) for the y-direction
- At depth k' > 0: recurse for the quantifier part of sub3

The recursion terminates after k levels (reaching depth 0, which is purely atomic).

**Why this works**:
- Forward: if (x,t) has 2-var type sub_nf, then all quantifier constraints hold (each existential is witnessed)
- Backward: the nested witnesses provide exact NF matching at each level; nf_eval_unique gives uniqueness

**Estimated effort**: 700-1000 lines total:
- Formula construction: ~200-300 lines (recursive def, case splits on order atoms for 3+ var NFs)
- Forward direction: ~100-200 lines (extract witnesses from NF, show formula holds)
- Backward direction: ~200-400 lines (extract temporal witnesses, show NF matches using nf_eval_unique + recursion)
- Helper lemmas: ~100 lines (Fin.cons equalities, atom compatibility, order atom rewriting)

### Infrastructure Available (All Sorry-Free)

| Theorem | File | Purpose |
|---------|------|---------|
| `char_k_correct` | IH | Depth-k 1-var NF <-> StaviFormula truth |
| `nf_eval_unique` | NormalForm.lean | Two NFs satisfied at same env are equal |
| `nf_characteristic_satisfies` | NormalForm.lean | Canonical NF is satisfied |
| `nf_exist_sf_forward` | StaviCompleteness.lean | Forward direction (exists -> formula truth) |
| `ghr93_strategy_compose` | Composition.lean | Game composition (may help alternative proof) |
| `ghr93_game_iff_decomposition` | Decomposition.lean | Game <-> decomposition (may help alternative proof) |

## Immediate Next Action

Implement the nested temporal formula construction for `nf_2var_existence_characterizable`. Start with:
1. Define `nf_exist_sf_full` as a recursive function on k
2. Prove forward direction (`nf_exist_sf_full_forward`)
3. Prove backward direction (`nf_exist_sf_full_backward`)
4. Use these to close the sorry

## Goal State at Sorry (Line 1865)

```
sig : MonadicSignature
atomMap : Formula -> sig.preds
h_surj : forall p : sig.preds, exists a, atomMap (Formula.atom a) = p
k : Nat
char_k : NormalForm sig k 1 -> StaviFormula
char_k_correct : forall (nf_k : NormalForm sig k 1) (M : OrderedMonadicStructure sig) (t : M.carrier),
    stavi_temporal_truth M atomMap t (char_k nf_k) <-> nf_eval_nf M k 1 (fun _ => t) nf_k
parent_atoms : AtomKind sig 1 -> Bool
sub_nf : NormalForm sig k 2
|- exists sf, forall (M : OrderedMonadicStructure sig) (t : M.carrier),
    (forall (a : AtomKind sig 1), atom_eval M (fun _ => t) a <-> parent_atoms a = true) ->
    (stavi_temporal_truth M atomMap t sf <->
     exists x, nf_eval_nf M k (1+1) (Fin.cons x (fun _ => t)) sub_nf)
```

## Alternative Approaches Worth Considering

1. **Bridge from game infrastructure to NFs**: If someone formalizes the connection between `decomposition_agreement` (ExtendedCarrier/rank_type) and `nf_eval_nf` (NormalForm), the existing game theorems could provide the backward direction more directly. This is ~300 lines of bridge infrastructure.

2. **Restructure nf_characterizable_by_stavi**: Instead of proving `nf_2var_existence_characterizable` as a separate lemma, integrate the formula construction directly into the induction of `nf_characterizable_by_stavi`, with a simultaneous induction that characterizes n-var NFs for all n.

3. **Weaken the lemma**: If the full backward direction is too hard, one could try to prove a weaker version that still suffices for downstream phases. For example, prove it only for specific sub_nf patterns that actually appear in the bx_completeness proof chain.
