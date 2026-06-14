# KampBypass.lean Depth-0 Composition Sorries Handoff

## Dispatch Summary

Attempted to fill 7 depth-0 composition sorries in KampBypass.lean (lines 670-1075).

### Accomplishments

1. **witness_eq_t_of_no_order** (sorry-free helper, line 640-655): Proves that when both order booleans are false in sub_nf, any witness x must equal t. Used by equality case.

2. **zone_3var_exist_iff_1var** (helper stub, line 814-842): Zone decomposition helper that relates `exists y, nf_eval_nf M 0 3 (y,x,t) ssn` to zone-specific 1-var conditions. Currently sorry -- the proof requires ~200 lines of zone-by-zone case analysis.

### Critical Discovery: Formula Soundness Issue

**The `pre_conditions_at_t_until` formula is potentially unsound for order-inconsistent ssn values.**

#### The Problem

`ssn_xt_compatible` checks x-predicates, t-predicates, and x-t order compatibility, but does NOT check y-related order consistency. The `ssn_zone_until` classifies ssn into zones based on y-t and y-x orders but only verifies they are not BOTH true (no mutual contradiction).

For the `below_t` zone (y < t), an ssn can have:
- `ssn(.order 0 2) = true` (y < t) -- OK
- `ssn(.order 0 1) = false` (NOT y < x) -- INCONSISTENT with y < t < x

Such an ssn passes `ssn_xt_compatible` and is classified as `below_t`, but is UNSATISFIABLE (no y can have y < t but NOT y < x when t < x).

Since `sub_nf.2 ssn = false` for unsatisfiable ssn, the formula includes `neg S(char_y, top)`. But `S(char_y, top)` CAN be true at t if there exists y < t with the right predicates (the Since formula only checks y < t + predicates, not y < x).

This means the backward direction (`exists x, nf_eval -> holdsLeft`) is FALSE for models where such a y exists.

#### Impact

- The backward direction of `backward_holdsLeft_of_nf_eval` (line 806) is unprovable with the current formula
- The biconditional in `existPart_succ_n1_bypass_k0_until` (line 1048) may be false for the chosen formula
- The theorem STATEMENT is still correct (`exists A, ...`) -- a different A would work
- The formula construction needs modification, not the theorem

#### Fix

Filter `pre_conditions_at_t_until` to only include ssn values where ALL order booleans are consistent with the zone:

For `below_t` zone with t < x:
- Require `ssn(.order 0 1) = true` (y < x, implied by y < t < x)
- Require `ssn(.order 1 0) = false` (NOT x < y)
- Require `ssn(.order 2 0) = false` (NOT t < y, contradicts y < t)

Similarly for other zones. Alternatively, add a `ssn_order_consistent` check that verifies all 6 order booleans are realizable.

This filter should be added to `pre_conditions_at_t_until`, `enriched_point_type_x_until`, and `enriched_vecEA2_until`.

After this fix, the backward proofs should go through because:
- For consistent ssn: the temporal formula correctly captures the 3-var existential
- For inconsistent ssn: they are filtered out, no formula generated

### Sorry Inventory

| # | File | Line | Statement | Why Deferred | Next Dispatch |
|---|------|------|-----------|-------------|---------------|
| 1 | KampBypass.lean | 690 | `existPart_succ_n1_bypass_k0_eq` | Equality case: complex proof with 3 sub-cases. Two incompatible sub-cases handled in comments; compatible sub-case needs quantifier profile correctness | Implement after zone helper is ready |
| 2 | KampBypass.lean | 842 | `zone_3var_exist_iff_1var` | Zone decomposition helper: requires ~200 lines of zone-by-zone case analysis with order bookkeeping | Write one zone at a time |
| 3 | KampBypass.lean | 923 | `backward_holdsLeft_of_nf_eval` endLeft | BLOCKED by formula soundness issue | Fix formula first |
| 4 | KampBypass.lean | 935 | endRight | Same issue as #3 for eq_x and above_x zones | Fix formula first |
| 5 | KampBypass.lean | 939 | bracket | Same issue for between_tx zone | Fix formula first |
| 6 | KampBypass.lean | 997 | `forward_nf_eval_of_holdsLeft` | Requires zone helper (#2) for quantifier reconstruction | Implement after #2 |
| 7 | KampBypass.lean | 1109 | `existPart_succ_n1_bypass_k0_since` | Mirror of Until case; blocked by same issues | Fix Until first, then mirror |
| 8 | KampBypass.lean | 1197 | k>0 case | Different mathematical content (IH at higher depth) | Skip per task instructions |

### Recommended Next Steps

1. **Fix formula construction**: Add order consistency filter to `ssn_xt_compatible` or to each zone formula builder. This is the critical blocker for sorries #3-5.

2. **Complete zone_3var_exist_iff_1var**: After the formula fix, this helper becomes the key infrastructure for all proofs. Each zone case follows the same pattern: extract/reconstruct using `reconstruct_nf_3var`.

3. **Prove below_t zone first**: The simplest zone case. Prototype the pattern, then extend to others.

4. **Equality case**: Can be proved independently using `enriched_bypass_eq` + the zone helper.

5. **Since case**: Mirror of Until after Until is done.
