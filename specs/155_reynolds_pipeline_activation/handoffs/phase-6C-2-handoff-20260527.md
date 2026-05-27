# Phase 6C-2 through 6C-4 Handoff

## Summary

Deep analysis of the backward direction of `nf_2var_existence_characterizable` at k>=1 was completed. The sorry remains at line 2033 of StaviCompleteness.lean. The forward direction is already proved (`nf_exist_sf_forward`). The backward direction requires a bridge lemma that is mathematically non-trivial.

## Current State

- File: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
- Sorry location: line 2033, inside `nf_2var_existence_characterizable`, `succ k'` case
- Goal: `∃ x, nf_eval_nf M (k' + 1) (1 + 1) (Fin.cons x fun x ↦ t) sub_nf`
- Given: `h_sf : stavi_temporal_truth M atomMap t (nf_exist_sf atomMap h_surj (k' + 1) char_k parent_atoms sub_nf)`

## Root Cause Analysis

The backward direction fails because the formula `nf_exist_sf` with `sf_top` guard provides a witness x with the right 1-var depth-(k'+1) NF, but does NOT provide enough information to determine the 2-var depth-(k'+1) NF of (x,t). Specifically:

1. **What the formula gives**: x with `nf_eval_nf M (k'+1) 1 (fun _ => x) nf_x` (1-var NF at x), correct atoms, and correct ordering relative to t.

2. **What we need**: `nf_eval_nf M (k'+1) 2 (Fin.cons x (fun _ => t)) sub_nf` (2-var NF at (x,t)), which decomposes into atoms (provable) + quant part: for each `sub3 : NormalForm sig k' 3`, `(∃ z, nf_eval_nf M k' 3 (cons z (cons x t)) sub3) ↔ sub_nf.2 sub3 = true`.

3. **The gap**: The quant part asks about depth-k' 3-var NF existentials involving joint properties of (z,x,t). The 1-var NFs of x and t at depth k'+1 only give depth-k' 2-var existential info relative to each point INDEPENDENTLY. Whether a SINGLE z exists with specific 3-var NF relative to BOTH x and t is not determined by the pairwise info alone — the interval content between x and t is needed.

## Approaches Analyzed

### Approach A: Interval Guard (Plan's Primary)
- Replace `sf_top` with `sf_disjList [char_k nf_u | nf_u]` (disjunction of ALL 1-var NF formulas)
- Forward: trivial (every point has some NF)
- Backward: extract 1-var NFs of all intermediate points, use bridge argument to determine 2-var NF
- **Status**: Bridge argument works at k'=0 (depth-0 3-var NFs are just atoms+ordering, determined by 1-var NFs + position). For k'>=1, the bridge requires showing that depth-k' 3-var existentials are determined by depth-(k'+1) 1-var NFs + interval content — a non-trivial inductive argument.

### Approach B: Classical Good-Pair Disjunction (Attempted Implementation)
- Disjunct over (nf_x, nf_t) pairs that are "realizable" (witnessed by some model)
- Forward: straightforward
- Backward: transfer from witness model to current model requires NF invariance
- **Status**: The transfer FAILS because P = ∃x, nf_eval_nf M k 2... has quantifier depth k+1, but char_k only gives depth-k NFs. Property P is NOT invariant under depth-k NF equivalence — it's a depth-(k+1) property.

### Approach C: Nested Temporal Formula (Plan's Fallback)
- Directly encode the full multi-variable NF condition as nested Until/Since formulas
- Both directions by structural recursion
- **Status**: Requires encoding "∃ z with specific 3-var NF relative to (x,t)" as a temporal formula. This is the SAME problem at lower depth and higher arity. Requires a generalization of `nf_2var_existence_characterizable` to arbitrary arity, proved by strong induction on depth.

### Approach D: doets_lemma_1_1 Transfer
- Use `doets_lemma_1_1` at depth k to show NF invariance
- **Status**: P has quantifier depth k+1 but doets_lemma_1_1 at depth k only handles depth ≤ k. Does NOT apply.

## Mathematical Resolution Path

The correct resolution (from GHR93) uses the game-theoretic composition argument:
1. Two models where (x,t) and (x₀,t₀) have the same 1-var NFs at depth k+1 AND the same interval content can be connected by Duplicator winning strategies on sub-intervals.
2. The composition lemma (`ghr93_strategy_compose`, already proved in Composition.lean) combines these into a winning strategy on the full interval.
3. Winning the game implies NF agreement by `ghr93_game_iff_decomposition`.

The infrastructure exists but the bridge from game results (in terms of `ExtendedCarrier` and `ghr93_duplicator_wins`) to NF results (in terms of `NormalForm` and `nf_eval_nf`) is not formalized.

## Recommended Next Steps

1. **Formalize the bridge lemma** `nf_2var_from_1var_agreement`: if two 2-var environments have components with the same depth-k 1-var NFs (and same ordering and interval content), they have the same depth-k 2-var NF. Prove by induction on k.

2. **Base case k=0**: 3-var existentials are purely atom+ordering, determined by 1-var NFs + position in the linear order + interval content. The interval guard provides sufficient info.

3. **Inductive case**: Use the quant part of the 1-var NFs to transfer depth-(k-1) existentials between models, then compose via the IH at depth k-1.

4. **Alternative**: If the bridge is too complex, implement Approach C (nested temporal formula) as a multi-arity generalization of `nf_2var_existence_characterizable`.

## Key Files
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` — sorry at line 2033
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` — nf_eval_unique, nf_agreement_monotone, doets_lemma_1_1
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` — ghr93_strategy_compose
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Decomposition.lean` — ghr93_game_iff_decomposition
