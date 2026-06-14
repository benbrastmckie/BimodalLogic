# Handoff: Zone-Aware Enriched Formula v2 (VecEA2 Brackets)

## Date: 2026-06-14
## Status: partial (formulas defined, proofs pending)

## What Was Accomplished

### 1. Identified v1 Formula Defect
The `depth0_3var_exist_formula` (renamed to `_v1`) encoded y-x order but NOT y-t order.
Two ssn values differing only in y-t order produced the SAME temporal formula, causing
phi AND neg-phi contradictions in `quant_profile_conj_depth0`.

### 2. Zone-Aware Formula Definitions (v2)
Created zone classification and three formula components:
- `YZone` inductive: below_t, eq_t, between_tx, eq_x, above_x, inconsistent
- `ssn_zone_until`: classifies each ssn's y-zone for the Until direction
- `pre_conditions_at_t_until`: handles y < t (Since/H) and y = t (direct) zones
- `interval_guard_until`: handles NEGATIVE t < y < x via guard (neg char_y)
- `enriched_point_type_x_until`: handles y = x (direct) and y > x (Until/G) zones

### 3. Critical Finding: Positive Between_tx Backward Direction
The initial approach (Since(char_y, top) at x) for positive t < y < x conditions fails
in the backward direction: Since gives y' < x but doesn't guarantee y' > t.

### 4. VecEA2 Bracket Fix
Replaced Since-based encoding with VecEA2 bracket infrastructure:
- `enriched_vecEA2_until`: builds a VecEA2 with bracket witnesses for between_tx zone
- Bracket witnesses are BETWEEN t and x BY CONSTRUCTION
- Negative between_tx conditions go in segment guards (forall r in interval, neg char_y)
- VecEA2.translateLeft gives temporal formula with sorry-free bracketBuildRight

### 5. Full Formula Assembly
- `enriched_bypass_until`: VVecEA2 disjunction over compatible nf_x values
- `enriched_bypass_formula_zone`: handles Until (brackets), Since (mirror), Eq cases
- `existPart_succ_n1_bypass_k0`: k=0 specialized theorem (formula provided, proof pending)
- `existPart_succ_n1_bypass`: dispatches k=0 to above, k>0 sorry

## Immediate Next Action

Prove `existPart_succ_n1_bypass_k0` for the Until case (sub_nf says t < x).
The proof strategy:

**Forward** (exists x with nf_eval_nf -> formula truth):
1. Show t_compat via `t_compat_holds`
2. Match on order booleans -> (true, false) Until case
3. Formula = VVecEA2.translateLeft; use VVecEA2.translateLeft_correct
4. Find nf_x as x's depth-1 1-var NF; show nf_x_compat_check passes
5. Show endpointLeft(t): verify each pre-condition conjunct
6. Show endpointRight(x): char_1_correct gives char_1(nf_x), verify eq_x/above_x conjuncts
7. Show bracket.holds(t, x): for each positive between_tx ssn, provide y witness in (t, x)

**Backward** (formula truth -> exists x with nf_eval_nf):
1. From VVecEA2.translateLeft_correct: extract VecEA2.holdsLeft
2. Extract nf_x from disjunction
3. Extract x > t from Until semantics
4. From char_1(nf_x) at x: get nf_eval_nf M 1 1 (fun _ => x) nf_x
5. From bracket.holds(t, x): get bracket witnesses y_i in (t, x) for positive between_tx ssns
6. From segment guards: no y in (t, x) for negative between_tx ssns
7. From pre-conditions at t: verify y < t and y = t conditions
8. From endpointRight conjuncts: verify y = x and y > x conditions
9. Assemble nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf

## Current State

- KampBypass.lean: 721 lines, 2 sorries (down from 1 sorry but same theorem, now factored)
- Build: passes (0 errors)
- VecEADecomp.lean: 898 lines, sorry-free (preserved)
- NfToVecEA.lean: 766 lines, sorry-free (preserved)

## Sorry Inventory

| File | Line | Statement | Why Deferred | Next Dispatch |
|------|------|-----------|-------------|---------------|
| KampBypass.lean | 690 | existPart_succ_n1_bypass_k0 | Proof body needs ~200-400 lines of tactic work | Prove forward + backward directions |
| KampBypass.lean | 721 | existPart_succ_n1_bypass (k>0) | Requires depth-k IH for 3-var conditions | Add ih_exist parameter; generalize VecEA2 approach |

## Key Decisions

1. Renamed defective `depth0_3var_exist_formula` to `_v1` (kept for reference)
2. Used VecEA2 brackets for positive between_tx zone (correct backward direction)
3. Factored k=0 case into separate theorem for clarity
4. Kept old v1 definitions (quant_profile_conj_depth0 etc.) for reference

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` (major changes)
