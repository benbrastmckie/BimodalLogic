# Report 43: Backward Direction Bridging Theorem for nf_characterizable_by_stavi

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: What theorem bridges the gap from temporal formula truth to 2-variable NF satisfaction?

## The Two Sorry Sites

Both sorries (lines 1903 and 1959) need the same core fact:

**Sorry 1903** (quant=true, forward): Given `stavi_temporal_truth M atomMap t (nf_exist_sf ...)`, prove `∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`.

**Sorry 1959** (quant=false, backward): Contrapositive of the same — if `¬ ∃ x, nf_eval_nf ...`, then `¬ stavi_temporal_truth M atomMap t (nf_exist_sf ...)`.

Sorry 1959 follows from 1903 by contraposition. So the single theorem needed is:

```
nf_exist_sf_backward: stavi_temporal_truth M atomMap t (nf_exist_sf ...) →
  ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf
```

## Why the Backward Direction Fails Standalone

`nf_exist_sf` builds `U(disjList(char_k nf_x | nf_x atom-compatible), sf_top)`. When this holds at t, we get a witness x > t where `sf_disjList` holds — meaning `char_k nf_x` holds at x for SOME atom-compatible nf_x. By IH correctness, `nf_eval_nf M k 1 (fun _ => x) nf_x`.

We know:
1. The 1-variable depth-k NF of x is nf_x (from `char_k` + IH)
2. x > t (or x < t, from the temporal connective direction)
3. Predicates at x match sub_nf's variable-0 predicates (atom compatibility filter)
4. Predicates at t match the parent atom assignment (t-consistency)

We need: `nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`

The gap: knowing the 1-var type of x (nf_x) and the 1-var type of t and the order x>t does NOT uniquely determine the 2-var NF of (x,t). For k≥1, the 2-var NF includes the quantifier assignment `sub_nf.2 : NormalForm sig (k-1) 3 → Bool`, which describes which 3-variable depth-(k-1) NFs are realizable with a THIRD variable. The 1-variable types of x and t individually cannot determine this.

## The Bridging Theorem: `nf_exist_sf` Must Be Strengthened

The current `nf_exist_sf` uses `sf_top` as the guard formula (the B in U(A, B)). This means the Until formula is `U(witness_type, True)` — there exists x above t with the right 1-var type, with no constraint on intermediate points.

**GHR93's construction is different.** The paper uses a guard formula B that constrains the INTERVAL TYPE between t and x, not just the type of x. Specifically, B encodes "the interval (t, x) has a specific type" using the IH formulas. This additional constraint is what makes the backward direction work: the interval type + endpoint types fully determine the 2-variable NF.

## What GHR93 Actually Does

GHR93's formula for "∃x with 2-var type = sub_nf" is NOT simply U(A_x, True). It is:

For the Until case (x > t):
```
U(A_x ∧ C_{interval}, B_{guard})
```

where:
- `A_x` characterizes the 1-var type of x (same as current)
- `B_{guard}` characterizes the 1-var type of ALL intermediate points in (t, x) — this is what constrains the interval type
- `C_{interval}` may include additional constraints

The key insight: by the IH at depth k, the 1-var types of ALL points determine the decomposition agreement (via Proposition 7 / Lemma 11). So constraining the 1-var types of intermediate points + the 1-var type of x + order fully determines the 2-var type.

## The Fix: Replace sf_top with Interval Guard

The current `nf_exist_sf` definition at line 1597:
```lean
| some true =>  .std_untl witness_type sf_top
```

Must be changed to:
```lean
| some true =>  .std_untl witness_type interval_guard_formula
```

where `interval_guard_formula` characterizes the 1-var types of points in the interval (t, x). This can be built from the IH: for each 1-var depth-k NF nf_u, `char_k nf_u` or `¬ char_k nf_u` depending on what sub_nf.2 requires.

## Exact Statement of the Bridging Theorem

With the corrected formula, the bridging theorem is:

**Claim**: If points t and x satisfy:
1. x > t (or x < t)
2. nf_eval_nf M k 1 (fun _ => x) nf_x (x has 1-var type nf_x)
3. For all u in (t, x): stavi_temporal_truth M atomMap u B_guard (the guard holds at intermediate points)
4. nf_x is atom-compatible with sub_nf

Then: nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf.

**Proof sketch**: The 2-var NF of (x,t) is determined by:
- Atoms at x and t (given by atom compatibility + parent atoms)
- Order between x and t (given by the temporal direction)
- For each 3-var depth-(k-1) NF nf3: whether ∃z with nf_eval_nf M (k-1) 3 (Fin.cons z (Fin.cons x (fun _ => t))) nf3

The last point requires knowing which points z exist and what their types are relative to x and t. This is where the interval guard B is essential: it constrains the types of ALL intermediate points, which (by the IH + Proposition 7) determines which 3-variable NFs are realizable.

## Implementation Recommendation

1. **Redefine `nf_exist_sf`** to use a proper interval guard instead of `sf_top`. The guard should be a conjunction over all 1-var NFs nf_u: if sub_nf's quantifier assignment requires nf_u to be present in the interval, include `char_k nf_u`; if it requires absence, include `¬ char_k nf_u`.

2. **Re-prove `nf_exist_sf_forward`** with the strengthened formula (the guard adds obligations but they follow from `nf_characteristic_satisfies` at intermediate points).

3. **Prove `nf_exist_sf_backward`** using the interval guard: the temporal witness gives x with the right type AND intermediate points with constrained types, which together determine the 2-var NF.

4. **Estimated effort**: Redefining the formula is ~20 lines. Re-proving forward is ~50 lines (the guard condition follows from the existing proof + `nf_characteristic_satisfies`). Proving backward is ~100-200 lines (the main argument connecting interval types to 2-var NFs via the IH).

## Existing Infrastructure

- `decomposition_agreement` (Decomposition.lean:62): Exactly captures "matching types at all positions" — could serve as the formal bridge
- `ghr93_game_iff_decomposition` (Decomposition.lean:302): Game wins ↔ decomposition agreement
- `ghr93_strategy_compose` (Composition.lean): Composes sub-interval strategies — may not be directly needed for backward direction but validates the construction
- `nf_eval_unique` (NormalForm.lean:245): If two NFs are both satisfied at the same env, they're equal — essential for uniqueness arguments
- `nf_characteristic_satisfies` (NormalForm.lean:224): The canonical NF for an environment satisfies nf_eval_nf

## Summary

The backward direction fails because `nf_exist_sf` uses `sf_top` (no constraint on intermediate points) instead of GHR93's interval guard. Fix: replace `sf_top` with a guard formula built from the IH that constrains intermediate point types. This is a formula-level fix (~20 lines changed) plus re-proving forward (~50 lines) and proving backward (~100-200 lines). No new infrastructure theorems needed — the existing `nf_eval_unique` and `nf_characteristic_satisfies` suffice.
