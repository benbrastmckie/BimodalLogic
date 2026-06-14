# Zone Bridge Wiring Handoff

## What Was Done

1. **Removed circular dependency**: ZoneBridge.lean no longer imports KampBypass.lean (the import was unnecessary -- ZoneBridge is self-contained). KampBypass.lean now imports ZoneBridge.lean.

2. **Deleted unused sorry**: `zone_3var_exist_iff_1var` (was private, unused, contained sorry) was deleted entirely.

3. **Added compat extraction helpers**: Three small helpers that extract predicate and order conditions from `ssn_xt_compatible`:
   - `ssn_xt_compat_x_preds`: extract x-predicate conditions
   - `ssn_xt_compat_t_preds`: extract t-predicate conditions
   - `ssn_xt_compat_tx_order`: extract t<x order condition

4. **Added `pre_conditions_at_t_until_holds` theorem signature**: This is the key helper for filling the endLeft sorry. Currently contains `sorry` but has complete type signature and docstring describing the proof strategy.

## Current Sorry Inventory (8 sorries, 2 out of scope)

| Line | Location | Statement | Why Deferred | Next Steps |
|------|----------|-----------|--------------|------------|
| 802 | `existPart_succ_n1_bypass_k0_eq` | equality case compatible | Needs enriched_bypass_eq temporal iff proof. When x=t, show nf_eval iff disjunct list match | Unfold enriched_bypass_eq, use formula_disjList_iff, iterate over compatible nf_x with zone bridge eq_x/eq_t |
| 913 | `pre_conditions_at_t_until_holds` | pre_conditions conjlist holds | Zone bridge integration for below_t and eq_t zones | See proof strategy below |
| 993 | `backward_holdsLeft_of_nf_eval` endLeft | endpointLeft eval at t | Blocked on 913 | Call pre_conditions_at_t_until_holds once 913 is filled |
| 1005 | `backward_holdsLeft_of_nf_eval` endRight | right_conjuncts at x | Zone bridge for eq_x and above_x zones at x | Same pattern as pre_conditions but at x, different zones |
| 1009 | `backward_holdsLeft_of_nf_eval` bracket | bracket.holds t x | Bracket witnesses for positive between_tx + segment guards | Need BracketFormula.holds definition + zone_bridge_between_tx |
| 1067 | `forward_nf_eval_of_holdsLeft` | reconstruct nf_eval from holdsLeft | Reverse of backward: extract zone witnesses from temporal formula | Use char_1_correct inverse, zone bridge reverse, reconstruct nf_eval_nf |
| 1179 | `existPart_succ_n1_bypass_k0_since` | Since case (x < t) | Mirror of Until case with swapped zones | Symmetric to Until, needs own pre_conditions/endRight/bracket helpers |
| 1267 | `existPart_succ_n1_bypass` k>0 | General k>0 case | Requires depth-k IH not available at this level | Out of scope for k=0 work |

## Proof Strategy for pre_conditions_at_t_until_holds (Line 913)

The proof should follow this structure:

```
1. Unfold pre_conditions_at_t_until to formula_conjList over filtered ssns
2. Apply formula_conjList_iff to reduce to: for each ssn in the list, show temporal truth
3. Decompose list membership via List.mem_filterMap to get ssn + h_compat + h_some
4. Split on ssn_zone_until ssn (only below_t and eq_t produce conjuncts)
5. For each zone:
   a. Use ssn_xt_compat_{x_preds,t_preds,tx_order} for predicate/order extraction
   b. Use h_eval_quant to determine ∃ y, nf_eval_nf ... ↔ sub_nf.2 ssn
   c. Apply zone_bridge_{below_t,eq_t} from ZoneBridge.lean
   d. Use nf_depth0_char_formula_correct to convert predicates ↔ temporal formula
   e. For below_t positive: construct Since(char_y, top) witness
   f. For below_t negative: show ¬Since(char_y, top) by contradiction
   g. For eq_t positive: show char_y at t using y=t substitution
   h. For eq_t negative: show ¬char_y at t by contradiction
```

The main difficulty is extracting all 6 order atoms from `ssn_zone_until` classification + `ssn_order_consistent`. The `ssn_zone_until` definition uses if-then-else chains on the order booleans, and extracting individual order atoms requires careful case analysis.

## Key Challenge: Boolean Extraction from ssn_zone_until

The `ssn_zone_until` function uses a complex if-then-else chain:
```lean
if y_lt_x && x_lt_y then .inconsistent
else if y_lt_t && t_lt_y then .inconsistent
else if y_lt_t then .below_t
else if !y_lt_t && !t_lt_y then
  if y_lt_x || (!y_lt_x && !x_lt_y) then .eq_t
  else .inconsistent
else if t_lt_y && y_lt_x then .between_tx
else if t_lt_y && !y_lt_x && !x_lt_y then .eq_x
else if t_lt_y && x_lt_y then .above_x
else .inconsistent
```

To extract individual order atoms from `ssn_zone_until ssn = .below_t`:
- y_lt_t = true (from the 3rd branch)
- Not both y_lt_x && x_lt_y (from 1st branch negation)
- Not both y_lt_t && t_lt_y (from 2nd branch negation, so t_lt_y = false)
- y_lt_x needs ssn_order_consistent: y<t=true, t<x=true implies y<x=true
- x_lt_y = false (from antisymmetry + y_lt_x=true)

This extraction is tedious but mechanical. A helper `ssn_zone_order_atoms` that returns all 6 order booleans given the zone would simplify the proof significantly.

## Build Status

- `lake build` passes with sorry warnings only
- ZoneBridge.lean: 0 sorries (421 lines)
- KampBypass.lean: 8 sorries (1268 lines), 6 in scope for k=0 work

## Immediate Next Action

Fill `pre_conditions_at_t_until_holds` (line 913) using the proof strategy above. Once filled, the endLeft sorry at line 993 can be resolved by calling it with appropriate arguments (need to extract h_x_pred from h_eval_atoms and h_nf_x).
