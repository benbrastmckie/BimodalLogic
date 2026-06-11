# Phase 3 Handoff: nf_exist_formula_nested Definition Complete

**Task**: 273 | **Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## What Was Done

Defined `nf_exist_formula_nested` in NegationClosure.lean (lines ~421-528) with four helper functions:
- `ssn_var0_pred_assgn`: extracts variable-0 predicate assignment from arity-3 NF
- `ssn_compat_var0`: checks predicate compatibility between arity-3 and arity-1 NFs
- `ssn_in_interval_right`: classifies ssn as placing y in (t, x) for Until case
- `ssn_in_interval_left`: classifies ssn as placing y in (x, t) for Since case

The formula replaces `nf_exist_formula` in master_induction's P2(k+1) case. Both forward and backward directions are sorry'd (Phases 4-5).

## Formula Structure

```
nf_exist_formula_nested k char_kp1 char_k parent_atoms sub_nf :=
  if not t-compatible then bot
  else if both-orders then bot
  else match order_direction with
  | Until (t < x):
      disjunction over atom-compatible nf_x of:
        Until(
          event = char_{k+1}(nf_x) AND conj(Since(char_k_disj, top) for each positive interval ssn),
          guard = conj(neg(char_k_disj) for each negative interval ssn)
        )
  | Since (x < t): symmetric with Until/Since swapped
  | Identity (x = t): disjunction of char_{k+1}(nf_x)
```

Key design: the "nesting" is implicit through char_k, which is built from P2(k-1) via the master_induction hierarchy. No explicit recursion in the formula definition.

## Current State

| File | Sorries | Change |
|------|---------|--------|
| NegationClosure.lean | 2 (backward + forward in P2(k+1)) | +1 (forward now sorry'd because formula changed) |
| NfCharFormula.lean | 1 (nf_2var_exist_formula_prior) | unchanged |
| KampPrior.lean | 1 (nf_characterizable_temporal_prior k+1) | unchanged |
| Translation.lean | 0 | unchanged |
| PriorINF.lean | 0 | unchanged |

## Immediate Next Action

**Phase 4**: Prove `nf_exist_formula_nested` forward direction (existential -> formula truth). Strategy: given x with the right 2-var NF, extract the 1-var NF of x, show char_{k+1}(nf_x) holds, and for each positive interval ssn with y in (t,x), show the Since formula holds using y as witness. Use `char_k_correct` for characterizing y and `char_kp1_correct` for x.

## Key Decisions

1. Removed `atomMap` and `h_surj` from `nf_exist_formula_nested` signature (unused in definition body; kept only in `nf_exist_formula` for backward compatibility).
2. Used flat Since/Until from x for interval witness placement rather than multi-level recursive nesting. The recursive structure is implicit through the char function hierarchy.
3. Guard formula uses conjunction of negated char_k disjunctions (universal negative conditions).
