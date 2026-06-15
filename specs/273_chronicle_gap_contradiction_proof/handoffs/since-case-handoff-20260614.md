# Since Case Handoff - 2026-06-14

## Immediate Next Action
Fill the 5 remaining sub-sorries in `existPart_succ_n1_bypass_k0_since` (KampBypass.lean L1615 region).

## Current State
- Phase 1 of plan v32: Since case only (eq case handled by another agent)
- Sorry at L1615 has been decomposed into 5 smaller sub-sorries
- Proof skeleton is complete and compiles with sorries
- `ssn_xt_compat_since_of_nf_eval` helper lemma is sorry-free
- Backward direction membership proof (filterMap) solved via `rfl`
- Backward pre_at_t: above_t positive case sorry-free
- Backward pre_at_t: eq_t positive case sorry-free

## Remaining Sub-Sorries

### Sorry 1: Forward direction (L1693)
**Goal**: `∃ x, nf_eval_nf M 1 (1+1) (Fin.cons x (fun _ => t)) sub_nf`
**Context**: Have `nf_x` (from filterMap), `h_compat`, `h_snce` giving `∃ s < t, pt_x(s) ∧ guard(s,t)`, `h_nf_x : nf_eval_nf M 1 1 (fun _ => x) nf_x`
**Strategy**:
1. Witness is x from the Since semantics
2. Atom part: predicate atoms from nf_x compatibility + h_compat, order atoms from x < t (h_xt from Since)
3. Quant part: for each ssn, show `(∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ sub_nf.2 ssn`
   - For compatible ssns: use the zone conditions extracted from pre_at_t, pt_x, guard
   - For incompatible ssns: the existence side is false because the ssn's x-predicates or t-predicates don't match
4. The quant part is the hardest -- it's a reverse of the backward direction

### Sorry 2: Above_t negative (reconstruct_nf_eval_3var, ~L1914)
**Goal**: `∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn`
**Context**: Have `h_y_preds` (y satisfies nf_y_proj ssn), `h_compat_ssn`, `h_tly` (t < y), `h_xt` (x < t)
**Strategy**: Use `reconstruct_nf_eval_3var`. Need x_preds and t_preds from ssn_xt_compatible decomposition, and 6 order iffs. The x_preds extraction is tricky because `nf_x = nf_characteristic M 1 1 [x]` uses `decide`, requiring careful unfolding. Consider writing a helper `x_preds_from_compat` that extracts `∀ p, M.interp p x ↔ ssn (.pred p 1) = true` from `ssn_xt_compatible` + `h_nf_x`.

### Sorry 3: Eq_t negative (reconstruct nf_eval with y = t, ~L1914)
**Goal**: `∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn`
**Context**: Have `h_t_preds` (t satisfies nf_y_proj ssn), `h_eq_bools` (ssn says y=t zone), `h_compat_ssn`, `h_xt`
**Strategy**: Witness is t. Use `reconstruct_nf_eval_3var` with y = t. Order iffs: y<x ↔ t<x which is false (x<t), y<t ↔ false, x<y ↔ x<t which is true, x<t ↔ true, t<y ↔ false, t<x ↔ false. Need `ssn (.order 0 1)` value from eq_t zone conditions (y=t means ¬(y<t) ∧ ¬(t<y), plus ssn_xt_compatible says x<t=true).

### Sorry 4: Backward pt_x (temporal_truth at x, L1917)
**Goal**: `temporal_truth M atomMap x pt_x_f` where `pt_x_f = (char_1 nf_x).and (formula_conjList pt_x_conjuncts)`
**Strategy**:
1. `temporal_truth_and` -> show `char_1 nf_x` at x (via char_1_correct + h_nf_x) AND `formula_conjList pt_x_conjuncts` at x
2. For formula_conjList: use formula_conjList_iff, then for each ssn in the filtered list, show the zone condition at x
3. Zone conditions at x:
   - eq_x (y = x): char_y at x. From h_eval quant part + zone bridge eq_x adapted for x < t
   - below_x (y < x): Since(char_y, top) at x. From h_eval quant part, ∃ y < x with preds
   - between_xt positive (x < y < t): Until(char_y, top) at x. From h_eval quant part, ∃ y with x < y < t
4. This is structurally identical to the pre_at_t proof but at point x instead of t

### Sorry 5: Backward guard (∀ r, x < r < t → guard holds at r, L1917)
**Goal**: `∀ r, x < r → r < t → temporal_truth M atomMap r guard_f`
**Strategy**:
1. `formula_conjList_iff` at r
2. Guard only contains negative between_xt ssns: `¬char_y` at r
3. For each such ssn (x_lt_y && y_lt_t, sub_nf.2 ssn = false):
   - Need to show `temporal_truth M atomMap r (nf_depth0_char_formula ... (nf_y_proj ssn)).neg`
   - = `¬(temporal_truth M atomMap r (nf_depth0_char_formula ... (nf_y_proj ssn)))`
   - = `¬(∀ p, M.interp p r ↔ ssn (.pred p 0) = true)`
   - From h_eval quant part: `(∃ y, nf_eval [y,x,t] ssn) ↔ false`, so no y with nf_eval
   - But if char_y holds at r, we could reconstruct nf_eval with y = r (since x < r < t matches between_xt zone)
   - This gives a contradiction: char_y at r + r between x and t + ssn compatible → ∃ y with nf_eval, contradicting sub_nf.2 ssn = false

## Key Decisions
- Proof uses `unfold enriched_bypass_since; rw [formula_disjList_iff]` to work with the formula at a reasonable level
- Backward direction provides nf_characteristic as the nf_x witness
- Membership in filterMap proved by `rfl` (definitional equality after `simp [h_compat]`)
- Zone bridges from ZoneBridge.lean are direction-specific (t < x), so Since direction uses `reconstruct_nf_eval_3var` directly

## Helper Lemma
`ssn_xt_compat_since_of_nf_eval` (sorry-free): proves ssn_xt_compatible for a realized ssn in the Since direction (x < t). Available for use by the forward/backward proofs.

## Critical Technical Notes

### nf_characteristic and decide
`nf_x = nf_characteristic M 1 1 [x]` uses `@decide` for atom assignments. When extracting predicates, `h_nf_x` gives `∀ a, atom_eval M [x] a ↔ (decide (atom_eval M [x] a)) = true`, which is tautological. To get `M.interp p x ↔ ssn (.pred p 1) = true`, use ssn_xt_compatible decomposition (the x_preds condition) rather than going through nf_x.

### Order atoms from ssn_order_consistent
To determine unknown order atom values (e.g., y < x when only t < y and x < t are known), extract from `ssn_order_consistent` using transitivity. The approach: case-split on the unknown boolean using `cases h : ssn (.order ...)` then use `simp_all` to discharge inconsistent cases via the boolean transitivity constraints in `ssn_order_consistent`.

## Sorry Inventory
```json
[
  {"file": "KampBypass.lean", "line": 753, "statement": "existPart_succ_n1_bypass_k0_eq compatible subcase", "assumption": "x=t collapse", "why_deferred": "Being handled by another agent", "next_dispatch": "Other agent completes eq case"},
  {"file": "KampBypass.lean", "line": 1284, "statement": "bracket_holds_of_eval_quant IntervalPattern.holds", "assumption": "bracket witness ordering", "why_deferred": "Not in scope for this phase", "next_dispatch": "Phase 2"},
  {"file": "KampBypass.lean", "line": 1503, "statement": "forward_nf_eval_of_holdsLeft", "assumption": "VecEA2 forward direction", "why_deferred": "Not in scope for this phase", "next_dispatch": "Phase 2"},
  {"file": "KampBypass.lean", "line": 1693, "statement": "have (leaf): forward direction Since case", "assumption": "formula truth implies nf_eval", "why_deferred": "Context exhaustion during backward direction work", "next_dispatch": "Fill forward direction using zone decomposition"},
  {"file": "KampBypass.lean", "line": 1914, "statement": "have (leaf): above_t/eq_t negative reconstruct", "assumption": "reconstruct_nf_eval_3var from char_y + order", "why_deferred": "Requires x_preds extraction from compat + decide unwrapping", "next_dispatch": "Write x_preds_from_compat helper, then fill reconstruct calls"},
  {"file": "KampBypass.lean", "line": 1917, "statement": "have (leaf): backward pt_x and guard Since", "assumption": "zone conditions at x and between x,t", "why_deferred": "Large plumbing proof for zone-by-zone conjList", "next_dispatch": "Mirror pre_at_t proof structure for pt_x; guard uses contradiction via nf_eval non-existence"},
  {"file": "KampBypass.lean", "line": 2005, "statement": "existPart_succ_n1_bypass depth >= 2", "assumption": "arity-climbing induction", "why_deferred": "Not in scope for this phase", "next_dispatch": "Phase 4"}
]
```
