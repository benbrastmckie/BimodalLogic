# Phase 3 Handoff: Master Induction k=0 Complete, k+1 Backward Remains

**Task**: 273 | **Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Current State

NegationClosure.lean: master simultaneous induction architecture with:
- **P1(k)**: depth-k arity-1 NF temporal characterizations
- **P2(k)**: depth-k 2-var existential temporal formulas

### Sorry Status (1 remaining)

| Location | Line | Content | Status |
|----------|------|---------|--------|
| backward_depth0 | ~98 | depth-0 backward direction | PROVED sorry-free |
| nf_2var_depth0_components | ~62 | atom eval case analysis | PROVED sorry-free |
| k+1 backward in master_induction | 366 | Rabinovich composition content | SORRY |

### Why k+1 Backward is Hard (Precise Statement)

At the sorry, we have:
- `char_kp1_correct`: depth-(k+1) arity-1 NF characterizations (P1(k+1), from IH)
- `p2_k`: depth-k 2-var existential formulas (P2(k), from IH)
- `h_formula`: `nf_exist_formula` at depth k+1 holds at t
- Goal: `exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`

The formula gives x with depth-(k+1) arity-1 NF = nf_x (from char_kp1).
But `nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` requires:
1. Atoms at (x,t) match sub_nf.1 -- PROVABLE from nf_x + h_atoms
2. Quantifier: for each `ssn : NormalForm sig k 3`, `(exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) <-> sub_nf.2(ssn) = true`

The quantifier condition involves depth-k arity-3 NFs. The existential `exists y, nf_eval_nf M k 3 ...` is equivalent to `eval M (Fin.cons x (fun _ => t)) (.ex (nf_to_formula ssn))`, which has qd = k+1 at arity 2. By doets_lemma_1_1, this is determined by the depth-(k+1) arity-2 NF of (x,t). But the depth-(k+1) arity-2 NF IS what we're trying to determine.

The existential property `.ex (nf_to_formula sub_nf)` at arity 1 has qd = k+2, which EXCEEDS our depth-(k+1) characterizations. So doets_lemma_1_1 at depth k+1 cannot directly handle it.

### Recommended Approach

The most promising direction: prove a **composition theorem for Prior structures** by induction on k. This would show that on Prior structures, the depth-k arity-2 NF of (x,t) is determined by the depth-k arity-1 NFs of x and t, plus the order relation.

At depth 0: purely atomic, trivially true (already proved via `nf_2var_depth0_components`).

At depth k+1: the quantifier part asks about depth-k arity-3 existentials. By the composition IH at depth k and arity 3 (which reduces to arity 1+orders), these are determined by the depth-k arity-1 NFs of the points + their orders. But arity-3 compositions require handling 3-point configurations (y, x, t), which involves case analysis on y's position relative to x and t.

On Prior structures, for each order region:
- y > x > t: existence of y determined by depth-(k+1) arity-1 NF of x (its "future" quantifier info)
- t < y < x: existence of y in interval (t,x) determined by Prior-UZ applied at t
- y < t < x: existence of y determined by depth-(k+1) arity-1 NF of t (its "past" quantifier info)
(and similarly for the Since direction when x < t)

This case analysis + Prior-UZ/SZ application is the Rabinovich negation closure content.

**Estimated effort**: 300-500 lines for the composition theorem + 50 lines to wire into the master induction.

## File Inventory

| File | Sorries |
|------|---------|
| Kamp/NegationClosure.lean | 1 (k+1 backward) |
| Kamp/NfCharFormula.lean | 1 (nf_2var_exist_formula_prior) |
| Kamp/KampPrior.lean | 1 (nf_characterizable_temporal_prior k+1) |
| All others | 0 |

## Immediate Next Action

Prove composition theorem for Prior structures by induction on k, handling the 3-region case analysis using Prior-UZ/SZ.
