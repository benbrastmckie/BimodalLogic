# Implementation Summary: BracketFormula k Encoding Fix for KampBypass

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [COMPLETED]
- **Started**: 2026-06-15
- **Completed**: 2026-06-16
- **Effort**: ~9 hours across 5 phases (plan v39)
- **Artifacts**: plans/39_bracketformula-k-encoding.md

## Overview

Replaced the broken `BracketFormula 0` + Since-at-endpoint encoding in KampBypass.lean with `BracketFormula k` (where k = number of positive between_tx SSNs). The BracketFormula 0 encoding was definitionally unprovable in the forward direction because `Formula.snce char_y Formula.top` at x loses the lower bound `t < y`. The BracketFormula k approach is semantically correct: `IntervalPattern.holds` directly provides k strictly ordered witnesses in `(t, x)` with both bounds guaranteed.

## What Changed

- **Phase 1** (Definition Rewrite): Rewrote `enriched_vecEA2_until` from `BracketFormula 0` to `BracketFormula pos_between.length`. Created sorry-free `bracket_from_distinct_witnesses` helper using `Finset.orderEmbOfFin`.
- **Phase 2** (Backward Until): Re-proved `backward_holdsLeft_of_nf_eval` sorry-free with BracketFormula k. Key sub-proofs: `h_wit_injective` for witness distinctness, `seg_guard_on_interval` for segment guards, `h_wit_pos_pt` for pointType conditions.
- **Phase 3** (Forward Until): Proved `forward_nf_eval_of_holdsLeft` sorry-free. Extracted k witnesses from `IntervalPattern.holds`, established pointType and segment guard conditions.
- **Phase 4** (Since Direction): Rewrote `enriched_bypass_since` with BracketFormula k for the Since direction. Proved both `forward_nf_eval_of_holdsRight` and `backward_holdsRight_of_nf_eval` sorry-free. Created zone-specific temporal equivalence lemmas for all 5 Since zones.
- **Phase 5** (Chain Verification): Verified build green, confirmed sorry isolation, documented sorry inventory.

## Verification Results

| Theorem | File | sorryAx? |
|---------|------|----------|
| `existPart_succ_n1_bypass_k0` | KampBypass.lean | No |
| `existPart_succ_n1_bypass_k0_until` | KampBypass.lean | No |
| `existPart_succ_n1_bypass_k0_since` | KampBypass.lean | No |
| `existPart_succ_n1_bypass_k0_eq` | KampBypass.lean | No |
| `backward_holdsLeft_of_nf_eval` | KampBypass.lean | No |
| `forward_nf_eval_of_holdsLeft` | KampBypass.lean | No |
| `backward_holdsRight_of_nf_eval` | KampBypass.lean | No |
| `forward_nf_eval_of_holdsRight` | KampBypass.lean | No |
| `existPart_succ_n1_bypass` | KampBypass.lean | Yes (k>0) |
| `kamp_prior_expressive_completeness` | KampPrior.lean | Yes (via above) |
| `US_expressively_complete_over_prior` | PriorExpressiveness.lean | Yes (via above) |
| `completeness_discrete` | Completeness.lean | Yes (via above + other sorries) |

## Decisions

- Used shared `pos_pt` disjunction for bracket pointTypes instead of per-SSN `char_y(nf_y_proj ssn_i)` to avoid witness-index permutation issues.
- Used `Finset.orderEmbOfFin` instead of `Tuple.sort` for witness sorting -- cleaner API, handles sorting + injectivity + bracket construction in one helper.
- Inlined `nf_y_proj_injective_on_pos_between` and `seg_guard_subinterval` into the backward proof (Phase 2) rather than creating standalone helpers.
- Since direction uses BracketFormula k mirroring the Until approach (Option A from plan).

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| KampBypass.lean | 4486 | `existPart_succ_n1_bypass` (k>0 case) | Quarantined -- requires depth induction for k>0 |

The k>0 sorry is isolated: it only affects `existPart_succ_n1_bypass` at the `succ k'` branch. All k=0 theorems (`existPart_succ_n1_bypass_k0`, `_until`, `_since`, `_eq`) and all internal helpers are sorry-free. The sorry propagates through: `existPart_succ_n1_bypass` -> `kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior` -> downstream.

## Impacts

- The k=0 Kamp bypass path is now fully proved, closing the primary encoding flaw that blocked the forward direction.
- The k>0 sorry remains as a separate task requiring depth-k induction with 3-variable NF conditions.
- `completeness_discrete` remains blocked by both the k>0 sorry and separate sorries in `ChronicleToCountermodel.lean`.
- Pre-existing heartbeat timeout in `CanonicalTaskRelation.lean` is unrelated to this task.

## Follow-ups

- Close k>0 sorry in `existPart_succ_n1_bypass` (separate task -- requires depth induction).
- Close remaining sorries in `ChronicleToCountermodel.lean` (separate sorry chain).
- Consider file splitting of KampBypass.lean (~4488 lines) for maintainability.

## References

- `specs/273_chronicle_gap_contradiction_proof/plans/39_bracketformula-k-encoding.md`
- `specs/273_chronicle_gap_contradiction_proof/reports/38_team-research.md`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
