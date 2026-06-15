# Phase 1 Handoff: Eq Case (L974)

## Immediate Next Action
Verify build passes, then proceed to Phase 2 (bracket case L2096) or Phase 3 (forward direction L2154).

## Current State
- Phase 1: eq case sorry at original L974 replaced with full proof
- Build: pending verification (lake build running with maxHeartbeats 3200000)
- Remaining sorries: 4 (bracket ~L2096, forward ~L2154, since ~L2266, depth>=2 ~L2354)

## Key Decisions
1. **ssn compatibility guard**: Added `by_cases h_ssn_compat` in `existPart_succ_n1_bypass_k0_eq` to handle unrealizable 3-var sub-NFs. When sub_nf.2 ssn = true for an incompatible ssn, the existential is impossible and we use Bot. This was mathematically necessary -- enriched_bypass_eq does NOT correctly characterize the existential when there are incompatible ssn with sub_nf.2 = true.

2. **Helper theorems**: Created `eq_case_t_pred_1`, `eq_case_t_pred_2` for extracting t-predicate hypotheses, and `eq_case_iff` for the core biconditional. The iff takes an `h_ssn_compat` parameter.

3. **Zone bridge usage**: Backward direction uses `.mpr` of zone bridges, forward direction uses `.mp`. Both handle all 6 zone cases (below+pos, below+neg, above+pos, above+neg, eq+pos, eq+neg) via the existing `eq_case_zone_{below,above,eq}` theorems.

4. **maxHeartbeats**: Increased to 3200000 for both `eq_case_iff` and `existPart_succ_n1_bypass_k0_eq` to accommodate the additional complexity.

## Sorry Inventory
| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| KampBypass.lean | ~2096 | backward_holdsLeft_of_nf_eval bracket case | IntervalPattern.holds needs strictly increasing witnesses | Phase 2: bracket helper | Implement bracket_holds_of_uniform_segments |
| KampBypass.lean | ~2154 | forward_nf_eval_of_holdsLeft | Reconstruct nf_eval from VecEA2 holdsLeft | Phase 3: forward direction | Zone-by-zone reconstruction using .mp zone bridges |
| KampBypass.lean | ~2266 | existPart_succ_n1_bypass_k0_since | Since case analogous to Until | Phase 4: verify enriched_bypass_since soundness first |
| KampBypass.lean | ~2354 | existPart_succ_n1_bypass (k>0) | Depth >= 2 case | Out of scope |

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- replaced eq case sorry, added 3 helper theorems (~360 new lines)
- `specs/273_chronicle_gap_contradiction_proof/plans/34_kamp-sorry-closure.md` -- Phase 1 [IN PROGRESS], checklist items marked
