# Phase 5 Handoff: NF-to-VecEA Bridge

**Session**: sess_1781193902_83bc5c
**Date**: 2026-06-12
**Phase**: 5 (FO-to-VecEA Equivalence and NF Bridge)
**Status**: BLOCKED

## Completed Work

Three sorry-free bridge theorems in `FoToVecEA.lean`:

1. **`nf_exist_iff_char_quant`**: The semantic equivalence
   `(exists x, nf_eval_nf M k 2 (x,t) sub_nf) <-> (nf_characteristic M (k+1) 1 t).2 sub_nf = true`
   
2. **`nf_exist_iff_nf1_disjunction`**: The NF existence as a disjunction of depth-(k+1) 1-var NF evaluations

3. **`p2_from_p1_succ`**: Given P1(k+1) (temporal characterizations at depth k+1), produces P2(k) (temporal formula for depth-k 2-var NF existence). Both directions sorry-free. The formula is a disjunction of char_{k+1} formulas filtered by quantifier assignment compatibility.

All three verify with `lean_verify` showing no `sorryAx`.

## The Blocker: P1/P2 Circularity

The fundamental issue preventing Phase 5 completion:

```
P2(k) needs P1(k+1)     [proved by p2_from_p1_succ]
P1(k+1) needs P2(k)     [proved by nf_characterizable_temporal_prior_classical]
```

Both implications are proved sorry-free. But they form a CYCLE. Breaking the cycle requires P2(k) to be provable from P1(k) alone (not P1(k+1)), which requires one of:

### Resolution Path 1: Composition Lemma (NfComposition.lean)
Prove `nf_3var_from_1var_nfs` -- that depth-k 3-var NFs are determined by depth-(k+1) 1-var NFs + ordering. This would make the backward direction of `nf_exist_formula_nested_backward` provable, and master_induction sorry-free.

**Status**: Failed 5 times. Root cause: witness merging (finding a single z' matching z's relationship to all three boundary points simultaneously). Requires an EF game argument on the interval decomposition of the linear order.

### Resolution Path 2: Lemma 3.2.2 (EA Decomposition)
Prove Rabinovich's Lemma 3.2.2: every EA formula with n>2 free variables is equivalent to a conjunction of EA formulas with at most 2 free variables. This enables the full Prop 4.3 (structural induction on MonadicFormula).

**Status**: Not attempted. Estimated 200-400 lines. The decomposition follows from the interval structure of the linear order.

### Resolution Path 3: Direct Game Proof
Prove P1 at all depths using Doets' Lemma 1.4/1.5 on ordered sums, bypassing the NF-based mutual induction entirely.

**Status**: Not attempted. Would require major restructuring.

## Immediate Next Action

For the successor agent: choose one of the three resolution paths and implement it. Path 2 (Lemma 3.2.2) is likely the most tractable as it requires no game-theoretic argument and builds on the existing vec-EA infrastructure.

Once the circularity is resolved:
- `p2_from_p1_succ` immediately gives P2(k) at all depths
- `nf_2var_exist_formula_prior` (NfCharFormula.lean:572) closes via P2
- `nf_characterizable_temporal_prior` (KampPrior.lean:149) closes via P1+P2
- `kamp_prior_expressive_completeness` closes
- All downstream consumers close

## Key Files
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` -- bridge theorems (sorry-free)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean:1371` -- backward sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean:572` -- P2 sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:149` -- P1 sorry

## Sorry Inventory
- NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`) -- 1 sorry
- NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) -- 1 sorry
- KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ case) -- 1 sorry
- NfComposition.lean:106,108 (`nf_3var_from_1var_nfs`) -- 2 sorries (bypassed)

Total: 3 active sorries on the critical path (all stem from the same circularity)
