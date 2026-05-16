# Phase 1 Handoff (v5): BiCompat Architecture

**Task**: 154 - sum_preservation_ef_games
**Session**: sess_1778898743_3e2055
**Phase**: 1 (COMPLETED)
**Date**: 2026-05-15

## Summary

Phase 1 complete. Redesigned `sum_nf_lift_gen` with `BiCompat` witness oracle. All new definitions compile sorry-free. The 4 sorries in `sum_nf_agree_sentence` remain.

## Architecture Change

Plan v5 proposed `sum_nf_lift_gen` with `h_atoms` as the sole hypothesis for maintaining atom agreement through the inductive quantifier step. Analysis revealed that `h_atoms` (ordered-sum atom agreement, i.e., depth-0 information) is **insufficient** for deriving same-component order agreement when the induction introduces multiple elements in the same component.

**Root cause**: At the quantifier step, a new element `c` in the same component as an existing element `a` creates order atoms `.order 0 (k+1)` checking `c < a`. To find `c'` in `ms' j` preserving this order, we need component multi-var NF agreement (which includes order), not just atom-level agreement. Atom-level agreement from `h_atoms` gives depth-0 only, while the component NF agreement bootstrap requires depth > 0 agreement at each level, creating an off-by-one deadlock.

**Solution**: Added `BiCompat sig d n I ms ms' env_M env_N`, a recursive predicate (on `d`) that provides bi-directional witness oracles:

```
BiCompat sig 0 ... = True
BiCompat sig (d+1) n ... = 
  (forall j c', exists c, h_atoms' AND BiCompat sig d (n+1) ...)
  AND
  (forall j c, exists c', h_atoms' AND BiCompat sig d (n+1) ...)
```

Each oracle witness includes atom agreement for the extended environment AND the recursive BiCompat for the next level. This terminates because `d` decreases. `sum_nf_lift_gen` takes both `h_atoms` and `h_bc : BiCompat` as hypotheses.

## Proved Definitions (sorry-free)

All at `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`:

1. **`BiCompat`** (~line 155): Recursive witness oracle predicate
2. **`component_extend_fwd`** (~line 190): From comp depth-(K+1) r-var NF agreement + c', find c with depth-K (r+1)-var agreement
3. **`component_extend_bwd`** (~line 210): Symmetric version
4. **`sum_nf_lift_gen`** (~line 245): Main lifting lemma, proved by induction on d. Takes h_comp + h_atoms + BiCompat. Sorry-free.
5. **`atomKind_one_pred_only`** (~line 145): `AtomKind sig 1` has no order atoms

## Remaining Work: Construct BiCompat at Sorry Sites

The 4 sorry sites in `sum_nf_agree_sentence` (lines ~376, 398, 423, 443) each have:
- `h_agree_comp`: component depth-k 1-var NF agreement for `![a]` vs `![b]`
- `h_comp`: component sentence equiv at m <= k+1
- `hb_eval` or `ha_eval`: the other ordered sum satisfies `sub_nf`

**To close each sorry**: construct `BiCompat sig k 1 I ms ms' (![<i,a>]) (![<i,b>])`, then apply `sum_nf_lift_gen` to get NF agreement at depth k with 1 var, which gives the witness.

### BiCompat Construction Strategy

Construct `BiCompat sig d n` by induction on `d`, carrying per-component accumulated NF agreement:

**Component i (has projected elements)**:
- Initial state: `h_agree_comp` at depth k for 1 var
- Each same-component witness: `component_extend_fwd/bwd` reduces depth by 1, increases vars by 1
- Budget: k depth levels for k quantifier levels. At d=0: BiCompat = True, no more extensions needed
- Order invariant: `D + r = k + 1` where `D` = current comp NF depth, `r` = vars in projected env

**Other components (no initial projected elements)**:
- Fresh transfer from `h_comp` at each level
- Cross-component order: automatic from `Sigma.Lex.left` (j < i or i < j determined by indices)
- Pred atoms: from component NF via `atom_agreement_from_nf`
- Recursive BiCompat: from IH at lower depth

### Key Lemmas for Atom Agreement in Extended Envs

**Same-component** (j = i): After `component_extend`, get depth-K (r+1)-var comp NF agreement. Apply `atom_agreement_from_nf` to get all comp atoms including order. For ordered-sum order atoms:
```
show (orderedSum ms).carrier_order.toLT.lt <i,c> <i,a> <-> ...
show Sigma.Lex ... -- use Sigma.Lex.lt_def then simp
```
This reduces to component order `c < a <-> c' < b`, which `atom_agreement_from_nf` provides from the comp NF.

**Cross-component** (j != i): Order atoms reduce to index comparison:
```
orderedSum_lt_cross : j != i -> (<j,c> < <i,a> <-> j < i)
```
Pred atoms from fresh component transfer. No comp NF state needed.

### Implementation Challenge

The main difficulty is TRACKING per-component NF state through the recursion. Different components may accumulate elements at different rates. The simplest approach:
1. Track comp i's accumulated NF explicitly (as function parameters)
2. For other components, derive fresh NFs from `h_comp` at each level
3. If a cross-component j accumulates multiple elements, use `component_extend` on the fresh NF

Since `BiCompat`'s recursive structure already encodes the accumulated state (each level's witness carries the next level's BiCompat), the construction is a recursive function that builds BiCompat level by level.

## Build Status

`lake build` passes. Only sorry warning: `sum_nf_agree_sentence` (4 sorries, unchanged from prior attempts).

## Key Files

- **Source**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- **NormalForm infrastructure**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`
- **Plan**: `/home/benjamin/Projects/ProofChecker/specs/154_sum_preservation_ef_games/plans/04_sum-preservation-plan.md`
