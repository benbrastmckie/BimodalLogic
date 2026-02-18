# Phase 2 Handoff: Closure Proofs

**Task**: 864 - Recursive Seed Henkin Model Construction
**Phase**: 2 - Complete Closure Proofs
**Session**: sess_1771444424_210e88
**Date**: 2026-02-18

## Immediate Next Action

Complete the `processWorkItem_preserves_closure` theorem (line 8094) by implementing the 10-case proof structure documented in the file.

## Current State

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Location**: Line 8094 - `processWorkItem_preserves_closure` theorem with 1 sorry
**Sorry count**: 21 (unchanged from session start)

### Proof Goal
```lean
theorem processWorkItem_preserves_closure (item : WorkItem) (state : WorklistState)
    (h_inv : WorklistClosureInvariant state)
    (h_item_not_proc : item ∉ state.processed) :
    let (newWork, state') := processWorkItem item state
    WorklistClosureInvariant {
      seed := state'.seed,
      worklist := state.worklist ++ newWork.filter (fun w => w ∉ state'.processed),
      processed := Insert.insert item state'.processed
    }
```

## Key Decisions Made

1. **Added `addFormula_hasPosition_backward`** (line 6107) - Enables backward reasoning about positions after addFormula
2. **Added `classifyFormula_eq_atomic`** (line 1229) - Enables proving formula type contradictions
3. **Documented proof structure** in comments at line 8069-8093 - Lists helper lemmas and case strategies

## What NOT to Try

1. **Inline proof without cases**: The proof must split on `classifyFormula item.formula` with 10 cases
2. **Ignoring new position creation**: When `addFormula` creates a NEW position (didn't exist before), the closure invariant needs careful handling - can't just use old invariant directly
3. **Blocked tools**: Do NOT use `lean_diagnostic_messages` or `lean_file_outline`

## Critical Context

### Helper Lemmas (all compile without sorry)
| Lemma | Line | Purpose |
|-------|------|---------|
| `mem_getFormulas_after_addFormula` | 7861 | If phi in new getFormulas, either from old or equals added formula |
| `addFormula_hasPosition_backward` | 6128 | If new seed has position, either old did or we added it |
| `classifyFormula_eq_atomic` | 1245 | If classifyFormula = atomic a, then phi = Formula.atom a |
| `foldl_addFormula_fam_puts_phi_in_all` | 7974 | Foldl addFormula puts phi in all families |
| `foldl_addFormula_times_puts_phi_in_all` | 8007 | Foldl addFormula puts phi in all times |
| `addFormula_preserves_mem_getFormulas_same` | 3515 | Old membership preserved in new seed |

### Case Strategy
1. **atomic, bottom, implication, negation**: Use backward lemmas to show Box/G/H must be from old seed, then use invariant
2. **boxPositive, futurePositive, pastPositive**: Use foldl_puts_phi_in_all to show closure completed
3. **boxNegative, futureNegative, pastNegative**: Show pending work item exists in worklist

### Potential Issue
When `addFormula` creates a new position that didn't exist before:
- Old invariant said: "psi at all families with hasPosition"
- New seed has MORE positions with hasPosition
- Need to show psi is at the new position too

Possible resolution: The new position only has the added formula (e.g., atomic), so if Box psi was in old seed at (f, t) and closure was satisfied, the new position at item.timeIdx has t = item.timeIdx. But the closure check is for time `t` from where Box psi is, not item.timeIdx. Need to verify this logic carefully.

## References

- **Plan**: `specs/864_recursive_seed_henkin_model/plans/implementation-006.md`
- **Research**: `specs/900_prove_cut_rule_derivation_tree_manipulation/reports/research-002.md`
- **Main file**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
