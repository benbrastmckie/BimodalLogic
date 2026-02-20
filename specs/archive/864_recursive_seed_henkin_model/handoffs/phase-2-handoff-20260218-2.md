# Phase 2 Handoff - 20260218 iteration 2

**Task**: 864 - Recursive Seed Henkin Model Construction
**Phase**: 2 - Complete Closure Proofs
**Session**: sess_1771444424_210e88
**Date**: 2026-02-18

## Immediate Next Action

Implement the bottom, implication, negation cases (lines 8305-8309) which follow the same pattern as the completed atomic case. Then implement boxPositive case (line 8311).

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Location**: Line 8305 onward - 9 case sorries in `processWorkItem_preserves_closure`
**Sorry count**: 29 (was 21 at session start, net +8 from case structure)

### Completed Work
- **atomic case**: Complete (130 lines of proof)
- **Added h_item_pos hypothesis**: `state.seed.hasPosition item.famIdx item.timeIdx`
- **Added 3 classification lemmas**: `classifyFormula_eq_bottom`, `classifyFormula_eq_implication`, `classifyFormula_eq_negation`

### Remaining Cases (9 sorries)
| Case | Line | Pattern | Notes |
|------|------|---------|-------|
| bottom | 8305 | Same as atomic | Use `classifyFormula_eq_bottom` |
| implication | 8307 | Same as atomic | Use `classifyFormula_eq_implication` |
| negation | 8309 | Same as atomic | Use `classifyFormula_eq_negation` |
| boxPositive | 8311 | Different - adds psi to ALL families | Use `foldl_addFormula_fam_puts_phi_in_all` |
| boxNegative | 8313 | Different - creates new family | Show new work item pending |
| futurePositive | 8315 | Same as boxPositive for times | Use `foldl_addFormula_times_puts_phi_in_all` |
| futureNegative | 8317 | Same as boxNegative | Show new work item pending |
| pastPositive | 8319 | Same as futurePositive | |
| pastNegative | 8321 | Same as futureNegative | |

## Key Decisions Made

1. **Added h_item_pos hypothesis**: Work item positions must exist in seed. This enables absurd contradiction in "new position" subcase.
2. **by_cases on old position existence**: For atomic case, split on `state.seed.hasPosition item.famIdx item.timeIdx` to handle both branches.
3. **Use pending branch for negative cases**: boxNegative/futureNegative/pastNegative create new work items, so use right disjunct of invariant.

## What NOT to Try

1. **Inline proof without case split**: Must case on `classifyFormula item.formula` due to different behaviors
2. **Trying to prove without h_item_pos**: The "new position" case requires knowing position exists
3. **Blocked tools**: Do NOT call `lean_diagnostic_messages` or `lean_file_outline`

## Critical Context (max 5 items)

- `WorklistClosureInvariant` is 3-part conjunction for Box/G/H with disjunction: closed OR pending work item
- For simple cases (atomic/bottom/implication/negation): Box/G/H in new seed must be from old seed (use `mem_getFormulas_after_addFormula`)
- For positive cases (boxPositive/futurePositive/pastPositive): psi added to ALL families/times, so left disjunct satisfied
- For negative cases: new work item created, so right disjunct satisfied
- `processWorklistAux_preserves_closure` at line 8343 needs to provide h_item_pos hypothesis when calling

## References (read only if stuck)

- Plan: `specs/864_recursive_seed_henkin_model/plans/implementation-006.md`, Phase 2
- Previous handoff: `specs/864_recursive_seed_henkin_model/handoffs/phase-2-handoff-20260218-1.md`
- Helper lemmas documented at lines 8106-8111 in RecursiveSeed.lean
