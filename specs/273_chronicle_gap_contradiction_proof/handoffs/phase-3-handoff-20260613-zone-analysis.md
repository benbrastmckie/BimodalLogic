# Phase 3 Handoff: Zone-Based Formula Construction Analysis

**Session**: sess_1781374494_d4f20d
**Date**: 2026-06-13
**Status**: PARTIAL -- structural progress, root sorry identified

## What Was Done

1. Added `ih_char : CharPart atomMap k` parameter to `existPart_succ` in RabinovichGeneralized.lean. This provides depth-k characteristic formulas needed for zone formula construction.

2. Filled the n=1 sorry at line 440 with delegation to `nf_2var_exist_formula_prior_neg` at depth k+1. This establishes the correct formula (nf_exist_formula) and proves the forward direction. The backward direction at k >= 1 remains sorry.

3. Identified the ROOT SORRY: `nf_exist_formula_nested_backward` at NegationClosure.lean:1712. All other sorries in the pipeline trace back to this one.

## Root Cause Analysis

The backward direction of `nf_exist_formula_nested` at depth k+1 fails because:

1. The formula extracts a witness x from Until/Since semantics
2. x satisfies `char_kp1(nf_x)` for some atom-compatible nf_x
3. From `char_kp1(nf_x)`, we get `nf_eval_nf M (k+1) 1 (fun _ => x) nf_x` -- the full depth-(k+1) arity-1 type of x
4. Atom conditions on (x, t) follow from nf_x + parent_atoms + order direction
5. **BLOCKED**: Quantifier conditions `∀ ssn : NormalForm sig k 3, (∃ y, nf_eval_nf M k 3 (y, x, t) ssn) ↔ sub_nf.2 ssn = true` cannot be verified

The quantifier conditions involve 3-var depth-k existentials at (y, x, t). The arity-1 type of x (nf_x) determines 2-var depth-k existentials at (y, x), NOT 3-var existentials at (y, x, t). The joint type of (x, t) is not determined by the individual types of x and t -- this is documented as FALSE in NfComposition.lean (counterexample: (0,2) vs (0,1) on Z at depth 1).

## Current Formula Structure

`nf_exist_formula_nested` (NegationClosure.lean:793) encodes:
- **Interval zones (zone 3: t < y < x)**: Positive ssns encoded via `Since(char_kp1(nf_y), ⊤)` at x. These ARE recoverable in the backward direction.
- **Non-interval zones (1: y > x, 2: y = x, 4: y = t, 5: y < t)**: Checked only for atom compatibility via `nf_full_compat_right`. Returns `true` for atom-compatible ssns without checking quantifier conditions. These are NOT recoverable.

## Viable Fix

Modify `nf_exist_formula_nested` to encode ALL zone conditions:

### Zone 1 (y > x > t)
Encode as `Until(witness_type_for_y, ⊤)` at x (inside the event formula). The witness_type_for_y is a disjunction of char_kp1(nf_y) for nf_y compatible with ssn's var-0 atoms. This gives ∃ y > x with the right 1-var type.

**Issue**: At depth k >= 1, the 1-var type of y does NOT determine the 3-var type at (y, x, t). Same composition problem, but recursively at depth k-1.

### Zone 5 (y < t < x)
Encode as a condition at t (outside the Until, or as a separate conjunct). Or encode as a nested Since from x: `Since(Since(witness_type_for_y, ⊤), ⊤)` which gives ∃ y < (something < x).

**Issue**: Same depth recursion.

### Zones 2, 4 (y = x, y = t)
These are deterministic (no existential on y). The condition `nf_eval_nf M k 3 (x, x, t) ssn` (for y = x) involves the depth-k arity-3 characteristic of (x, x, t), which has redundant variables. This should reduce but still involves the joint type of (x, t).

## Recursive Resolution

At each depth level k, the zone conditions involve depth-(k-1) existentials with mixed base. This recursion terminates at depth 0, where everything is purely atomic and the zone conditions ARE determined by atom types.

The formula construction must therefore be RECURSIVE on k:
- k=0: all zone conditions are purely atomic, verifiable from atom types
- k+1: zone conditions use depth-k zone formulas for the sub-existentials

This is essentially Rabinovich's full negation closure argument (Section 5, Lemma 5.1) formalized in our NF framework.

**Estimated effort**: 200-400 lines of new Lean code for the recursive zone formula constructor + correctness proof.

## Immediate Next Action

1. Define a recursive helper `zone_exist_formula` that, given depth k, builds temporal formulas for each zone condition
2. At depth 0: use CharPart(0) for atom-based zone conditions
3. At depth k+1: use CharPart(k+1) + zone_exist_formula at depth k
4. Modify `nf_exist_formula_nested` to use zone_exist_formula
5. Prove forward and backward for the modified formula

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|-------------|--------------|
| NegationClosure.lean | 1712 | nf_exist_formula_nested_backward | Assumes zone formula encoding handles all zones | Non-interval zone quantifier conditions not encoded in formula | Implement recursive zone formula constructor |
| RabinovichGeneralized.lean | 464 | existPart_succ n>=2 | Depends on n=1 case being sorry-free | n=1 delegates to nf_2var_exist_formula_prior_neg which has sorry at k+1 | Fill nf_exist_formula_nested_backward first |
| RabinovichNegation.lean | 291 | nf_2var_exist_formula_prior_neg k+1 backward | Same root cause | Same root cause | Same |
| RabinovichWiring.lean | 359 | nf_2var_exist_via_rabinovich k+1 backward | Same root cause | Same root cause | Same |
| NfCharFormula.lean | 572 | nf_2var_exist_formula_prior | Same root cause | Same root cause | Same |

## Key Files

- `NegationClosure.lean:1712` -- ROOT SORRY
- `NegationClosure.lean:793` -- `nf_exist_formula_nested` definition (formula to modify)
- `NegationClosure.lean:511` -- `nf_full_compat_right` (filter to strengthen)
- `NegationClosure.lean:924` -- forward direction (sorry-free)
- `RabinovichGeneralized.lean:389` -- `existPart_succ` with new `ih_char` parameter
- `NfComposition.lean:228` -- `intra_structure_extend` (may be useful for zone 2/4)
