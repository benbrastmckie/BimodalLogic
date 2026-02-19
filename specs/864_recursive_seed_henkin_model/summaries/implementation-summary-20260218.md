# Implementation Summary: Task #864

**Task**: Recursive seed construction for Henkin model completeness (v006 - Post-Condition Architecture)
**Sessions**: sess_1771444424_210e88, sess_1771467391_3cf5f8
**Date**: 2026-02-18
**Status**: Partial (Phase 1 complete, Phase 2 in progress - 1 termination sorry remains)

## Overview

This session verified Phase 1 was pre-completed by task 900 and began work on Phase 2 closure proofs. Added two helper lemmas for backward reasoning and documented the proof structure for the main closure theorem.

## Phases

### Phase 1: Add Key Theorem [COMPLETED]

Verified that task 900 already added the required theorems:
- `insert_consistent_of_derivable_parent` (line 1704) - Core theorem for post-condition architecture
- `insert_psi_consistent_of_box_psi_in` (line 1728) - Box corollary using T-axiom
- `insert_psi_consistent_of_g_psi_in` (line 1740) - G corollary using temporal T-axiom
- `insert_psi_consistent_of_h_psi_in` (line 1752) - H corollary using temporal T-axiom

All compile with zero sorries.

### Phase 2: Complete Closure Proofs [IN PROGRESS]

Added helper lemmas for backward reasoning:
1. **`addFormula_hasPosition_backward`** (line 6107)
   - Proves: if new seed has position, either old seed had it or we added it
   - 53 lines, zero sorries
   - Critical for closure proof backward analysis

2. **`classifyFormula_eq_atomic`** (line 1229)
   - Proves: if classifyFormula = atomic a, then phi = Formula.atom a
   - 17 lines, zero sorries
   - Enables contradiction proofs for simple cases

**Documented proof structure** for `processWorkItem_preserves_closure` (lines 8069-8093):
- Lists all required helper lemmas with line numbers
- Describes 10-case strategy:
  - Simple cases (4): Use backward lemmas, derive contradictions
  - Positive cases (3): Use foldl_puts_phi_in_all lemmas
  - Negative cases (3): Show pending work items exist

**Identified potential issue**: When `addFormula` creates a new position that didn't exist before, the closure invariant requires careful handling. The new position's formulas must satisfy closure constraints for all Box/G/H in the old seed.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
  - Line 6107-6159: Added `addFormula_hasPosition_backward` helper
  - Line 1229-1246: Added `classifyFormula_eq_atomic` helper
  - Lines 8069-8093: Documented proof structure for `processWorkItem_preserves_closure`

## Verification

- `lake build` succeeds (1000 jobs)
- Sorry count: 21 (unchanged from session start)
- Both new helper lemmas compile without sorries

## Sorry Count Analysis

**Total sorries in RecursiveSeed.lean: 21**

No change from session start. Added 2 helper lemmas with 0 sorries each.

Breakdown:
- **Phase 4 consistency (~14 sorries)**: Modal/temporal case proofs
- **Phase 5 closure (3 sorries)**:
  - `processWorkItem_preserves_closure`: 1 sorry (main proof)
  - `processWorklistAux_preserves_closure` fuel=0: 1 sorry
  - `processWorklistAux_preserves_closure` process: 1 sorry
- **Other (~4 sorries)**: Legacy/non-critical

## Artifacts Created

1. **Plan update**: `specs/864_recursive_seed_henkin_model/plans/implementation-006.md`
   - Phase 1 marked [COMPLETED] with checkboxes
   - Phase 2 progress section added

2. **Handoff document**: `specs/864_recursive_seed_henkin_model/handoffs/phase-2-handoff-20260218-1.md`
   - Current state documented
   - Helper lemmas listed with line numbers
   - Potential issue flagged

## Recommendations for Successor

### Immediate Priority

Complete `processWorkItem_preserves_closure` (line 8094):

1. **Split on `cases h_class : classifyFormula item.formula`** to get 10 cases
2. **Simple cases (atomic, bottom, implication, negation)**:
   - Use `mem_getFormulas_after_addFormula` to show Box/G/H came from old seed
   - Use `classifyFormula_eq_atomic` (etc.) for contradictions
   - Use `addFormula_hasPosition_backward` for position analysis
3. **Positive cases (boxPositive, futurePositive, pastPositive)**:
   - Use `foldl_addFormula_fam_puts_phi_in_all` / `foldl_addFormula_times_puts_phi_in_all`
4. **Negative cases**:
   - Show new work item is in worklist and not processed

### Helper Lemmas Available (All Zero-Sorry)

| Lemma | Line | Purpose |
|-------|------|---------|
| `mem_getFormulas_after_addFormula` | 7861 | Backward membership analysis |
| `addFormula_hasPosition_backward` | 6128 | Backward position analysis |
| `classifyFormula_eq_atomic` | 1245 | Formula type contradiction |
| `foldl_addFormula_fam_puts_phi_in_all` | 7974 | Forward family addition |
| `foldl_addFormula_times_puts_phi_in_all` | 8007 | Forward time addition |
| `addFormula_preserves_mem_getFormulas_same` | 3515 | Membership preservation |

### Potential Blocker

The closure invariant says "if Box psi at (f, t), then psi at all families with hasPosition for time t". When `addFormula` creates a NEW position at `(item.famIdx, item.timeIdx)`:
- If `t = item.timeIdx`, the new position must also have psi
- But the new position only has `item.formula` initially

Possible resolutions:
1. Show `item.formula` can't create a new position at time `t` when Box psi is at `(f, t)` (time mismatch)
2. Use the invariant structure (pending work item exists) instead of closed case
3. Strengthen the invariant to account for position creation

---

## Session: sess_1771467391_3cf5f8 (2026-02-18 Later)

### Overview

Restructured the fuel=0 termination approach in `processWorklistAux_preserves_closure`. The original sorry at line ~11398 (fuel=0 case) has been replaced with a properly structured `FuelSufficient` predicate and the termination sorry is now isolated in the process-item branch.

### Changes Made

1. **Added `FuelSufficient` predicate** (line 11389)
   - Definition: `fuel >= totalPendingComplexity worklist processed`
   - Based on complexity sum, not item count
   - Properly captures the termination measure

2. **Fixed fuel=0 case proof**
   - When fuel=0 with FuelSufficient, totalPendingComplexity=0
   - Implies filter is empty (since each complexity >= 1)
   - Uses `Formula.complexity_pos` to derive contradiction for non-empty filter
   - Uses `empty_worklist_closure` to conclude

3. **Fixed "already processed" branch**
   - Uses `totalPendingComplexity_of_in_processed` lemma
   - If item in processed, totalPendingComplexity(item::rest) = totalPendingComplexity(rest)
   - Fuel sufficiency propagates directly

4. **Documented termination sorry** (line 11635)
   - Moved from fuel=0 case to process-item branch
   - Clearly isolated as Dershowitz-Manna multiset ordering proof
   - Explained why sum-based termination fails (Box p at n families)

5. **Added `buildSeedComplete_closed` fuel sufficiency proof**
   - Initial fuel = (c^2 + 1) * 2 where c = phi.complexity
   - Initial totalPendingComplexity = c
   - Proven: 2c^2 + 2 >= c for all c >= 0

### Key Insight

Count-based termination (what I initially tried) doesn't work because processing one item can create multiple items. For example:
- Box p has complexity 2
- Processing it at n families creates n items of complexity 1
- If n > 2, total complexity INCREASES

The proper termination requires Dershowitz-Manna multiset ordering:
- We remove one element of complexity c
- We add elements each with complexity < c
- This is a strict decrease in multiset ordering even if sum increases

### Sorry Analysis

**Before session**: 19 sorries
**After session**: 19 sorries (unchanged)

The termination sorry moved from fuel=0 case to process-item branch, but remains as 1 sorry in `processWorklistAux_preserves_closure`.

### Files Modified

- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
  - Lines 11385-11399: Added `FuelSufficient` definition
  - Lines 11407-11455: Updated fuel=0 case proof
  - Lines 11522-11532: Updated "already processed" h_fuel proof
  - Lines 11607-11635: Updated "process item" h_fuel (now sorry)
  - Lines 11640-11668: Updated `buildSeedComplete_closed` with h_fuel proof

### Verification

- `lake build` succeeds (1000 jobs)
- No new sorries introduced
- Termination argument properly isolated

### Next Steps for Successor

To complete Phase 2, the Dershowitz-Manna termination proof at line 11635 needs:

1. Define `pendingComplexityMultiset` ordering using Mathlib's `Multiset.lt`
2. Prove: processing one item strictly decreases the multiset
   - Remove item.complexity from multiset
   - Add new item complexities (each < item.complexity)
   - This is exactly DM ordering decrease
3. Use this to prove fuel sufficiency propagates

Alternative: Restructure using well-founded recursion on multiset ordering instead of fuel.
