# Phase 2 (v28) Blocked Handoff

**Date**: 2026-06-13
**Session**: sess_1781410465_3cee28
**Phase**: 2 (Build NF-to-EA bridge at depth k+1)
**Status**: BLOCKED

## What Was Accomplished

1. **Factored the sorry at NfCharFormula.lean:597**: The monolithic sorry in the k+1 branch of `nf_2var_exist_formula_prior` has been replaced with a structured proof:
   - Forward direction (`∃ x → formula truth`): sorry-free, via `nf_exist_formula_forward'`
   - Backward direction (`formula truth → ∃ x`): isolated in `nf_exist_backward_prior` (line 540)
   - The formula used is `nf_exist_formula` (already existed)

2. **Documented the fundamental blocker**: The sorry at NfCharFormula.lean:540 and the sorry at NegationClosure.lean:1716 are manifestations of the SAME mathematical gap: the Prior composition property.

## The Blocker: Prior Composition Property

**Statement**: On structures satisfying `semantic_prior_UZ` and `semantic_prior_SZ`, the depth-k n-var NF of a tuple (y, x, t, ...) is determined by the depth-(k+1) 1-var NFs of the component points plus the linear order.

**Why it's needed**: The backward direction extracts x from Until/Since with `char_kp1(nf_x)` holding at x. This gives x's full depth-(k+1) 1-var NF. But to verify `nf_eval_nf M (k+1) 2 (x, t) sub_nf`, we need the quantifier profile: for each `ssn : NormalForm sig k 3`, whether `∃ y, nf_eval_nf M k 3 (y, x, t) ssn` holds. This 3-var existential depends on the interaction between y, x, and t -- not just their individual 1-var NFs.

**Why VecEA2 doesn't help**: The VecEA2 approach constructs a different formula but faces the same mathematical content. Encoding quantifier conditions in the formula requires expressing `∃ y, nf_eval_nf M k 3 (y, x, t) ssn` as a temporal formula, which requires the same composition property.

**Why the composition is false on general orders but should hold on Prior**: Counterexample on Z (in NfComposition.lean): (0, 2) and (0, 1) have the same 1-var NFs but different 2-var NFs (non-empty vs empty zone between the points). On Prior structures, the UZ/SZ axioms constrain the zone structure to prevent this.

## What Needs to Happen Next

1. **Prove the Prior composition property**: This is a standalone mathematical theorem. It should state: if M satisfies Prior-UZ/SZ, and two tuples have component-wise equal depth-(k+1) 1-var NFs and the same linear order, then they have the same depth-k n-var NF. This fills both NfCharFormula.lean:540 and NegationClosure.lean:1716.

2. **Alternative: restructure the induction**: Instead of `nf_2var_exist_formula_prior` taking only `char_k` (P1), restructure `nf_characterizable_temporal_prior_classical` as a simultaneous P1+P2 induction (like `master_induction` in NegationClosure.lean). Then P2(k) is available when proving P2(k+1), allowing the backward direction to use lower-depth 2-var existential formulas.

3. **Do NOT attempt**: Formula-level rearrangements (VecEA2 encoding, enriched formulas, nested Since/Until) -- these all require the same composition content.

## Sorry Inventory

| File | Line | Statement | Status | Next |
|------|------|-----------|--------|------|
| NfCharFormula.lean | 540 | `nf_exist_backward_prior` | SORRY | Prove Prior composition |
| NegationClosure.lean | 1716 | `nf_exist_formula_nested_backward` | SORRY | Same blocker |
| RabinovichNegation.lean | 291 | `nf_2var_exist_formula_prior_neg` k+1 backward | SORRY | Same blocker |
| RabinovichGeneralized.lean | 446 | `existPart_succ` n=1 | SORRY | Depends on above |
| RabinovichGeneralized.lean | 474 | `existPart_succ` n>=2 | SORRY | Depends on n=1 |

All five sorries trace to the same fundamental blocker: Prior composition.

## Key Decisions

- Used `nf_exist_formula` as the formula (not a VecEA2 construction) because it's already available and the backward direction blocker is the same regardless of formula choice.
- Did NOT attempt to construct VecEA2 for 3-var existentials because it requires the same composition property.
- Did NOT modify function signatures or restructure the induction (would affect multiple files).
