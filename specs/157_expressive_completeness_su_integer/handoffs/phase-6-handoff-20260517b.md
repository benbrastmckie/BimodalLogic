# Phase 6 Handoff: Temporal Closure Infrastructure Built (Still BLOCKED)

**Date**: 2026-05-17 (second attempt)
**Session**: sess_1779003456_c5b522
**Status**: BLOCKED (infrastructure built, core proof blocked)

## What Was Accomplished

Created `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` (~250 LOC) with:

1. **Box normalization** (`replace_box_with_top`): Replaces degenerate `box` nodes with `top`. Preserves `int_equiv`, `is_syntactically_separated`, `is_U_free`, `is_S_free`.

2. **Key structural theorem** (`replace_box_separated_no_S_nested`): A box-normalized separated formula satisfies `no_S_nested_in_U`. This resolves the "box loophole" that previously blocked the approach.

3. **Dual predicate** (`no_U_nested_in_S`): Defined with duality conversions via `swap_temporal`.

4. **Temporal recomposition properties**: Proved that `snce`/`all_past` of normalized separated formulas satisfy `no_S_nested_in_U`, and `untl`/`all_future` satisfy `no_U_nested_in_S`.

5. **Congruence lemmas**: Box normalization commutes with temporal operators (int_equiv preserved).

## What Remains Blocked

The 4+4 axioms cannot be removed until `no_S_nested_in_U phi -> is_separable phi` is proved without axioms. The core difficulty:

### The Circular Dependency (irreducible)

- **Primary direction** (U-out-of-S): Prove `no_S_nested_in_U phi -> is_separable phi`
  - Induction on `count_U_subformulas`
  - Base case (U-free): formula may contain `all_future (snce ...)` which needs S-elimination (dual direction)
  - Inductive step: abstract one U-type, apply Lemma 10.2.4 (Cases 1-8). Cases 5-8 call `all_separable` (circular)

- **Dual direction** (S-out-of-U): Prove `no_U_nested_in_S phi -> is_separable phi`
  - Via `swap_temporal` + primary direction (infrastructure built)
  - Base case (S-free): formula may contain `all_past (untl ...)` which needs U-elimination (primary direction)

### The Resolution Path (from GHR94)

GHR94 Lemma 10.2.8 resolves this via junction-depth induction:
1. Extract S-subformulas from inside U-args, replace with fresh atoms
2. Apply Lemma 10.2.7 to simplified formula (no S inside U)
3. Resubstitute: junction depth drops by >= 2
4. Apply IH at lower junction depth

This requires ~800-1200 LOC of new proof code.

## Immediate Next Action

If resuming: implement full GHR94 junction-depth induction (Lemma 10.2.8).

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (8 axioms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` (Cases 5-8)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (single_U uses axiom)
