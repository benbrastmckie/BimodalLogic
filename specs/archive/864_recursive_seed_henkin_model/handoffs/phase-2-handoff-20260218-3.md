# Phase 2 Handoff - 20260218 iteration 3

**Task**: 864 - Recursive Seed Henkin Model Construction
**Phase**: 2 - Complete Closure Proofs
**Session**: sess_1771444424_210e88
**Date**: 2026-02-18
**Status**: BLOCKED - Build Failure

## Critical Finding: Build Breakage

The committed RecursiveSeed.lean file **does not build** due to Lean/Mathlib API changes. Errors start at line 1234.

### Root Causes

1. **`List.mem_eraseDups.mpr`** - Unknown constant (API changed)
2. **`Prod.mk.injEq.mp`** - Unknown constant (should use `Prod.mk.inj`)
3. **Classification lemma proofs** - Lines 1234-1245 have "unsolved goals"

### Build Error Summary

```
error: Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean:1234:8: unsolved goals
error: Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean:1235:10: unsolved goals
... (continues)
error: Unknown constant `Prod.mk.injEq.mp`
error: Unknown constant `List.mem_eraseDups.mpr`
```

## Immediate Next Action

**MUST FIX BUILD BEFORE CONTINUING PROOF WORK**

1. Fix API breakage in classification lemmas (lines 1234-1245)
2. Replace all `Prod.mk.injEq.mp` with `Prod.mk.inj` (8 occurrences)
3. Verify `List.mem_eraseDups.mpr` usage at line 8117
4. Run `lake build` to confirm file compiles
5. THEN resume proof completion

## API Fixes Required

| Old API | New API | Occurrences |
|---------|---------|-------------|
| `Prod.mk.injEq.mp h_proc` | `Prod.mk.inj h_proc` | 8 |
| `List.mem_eraseDups.mpr` | Check if this still works in context | 1 |

## What Was Attempted

This session attempted to:
1. Add proof structure for bottom, implication, negation cases (following atomic pattern)
2. Add proof structure for boxNegative, futureNegative, pastNegative cases
3. These changes compile structurally but the proofs have additional issues due to context changes after simp/subst

The attempted proof structure was reverted since the base file doesn't build.

## Original Phase 2 Status (From Iteration 2)

Before build breakage was discovered:
- **atomic case**: Complete (130 lines of proof)
- **Added h_item_pos hypothesis**: `state.seed.hasPosition item.famIdx item.timeIdx`
- **Added 3 classification lemmas**: `classifyFormula_eq_bottom`, `classifyFormula_eq_implication`, `classifyFormula_eq_negation`
- **9 cases remain**: bottom, implication, negation, boxPositive, boxNegative, futurePositive, futureNegative, pastPositive, pastNegative

## What NOT to Try

- **DO NOT add proofs without fixing build first** - cannot verify correctness
- **DO NOT call blocked tools** (lean_diagnostic_messages, lean_file_outline)
- **DO NOT assume atomic case proof pattern still works** - needs verification after API fix

## Pattern Notes (For After Build Fix)

### Simple cases (bottom, implication, negation)

Follow atomic pattern:
1. `simp only [processWorkItem, h_class] at h_proc`
2. `obtain ⟨h_newWork, h_state'⟩ := Prod.mk.inj h_proc`
3. Use `mem_getFormulas_after_addFormula` to show Box/G/H must be from old seed
4. Use `classifyFormula_eq_*` to derive contradiction for added formula case

### Negative cases (boxNegative, futureNegative, pastNegative)

Neither neg(Box/G/H psi) nor neg psi is a Box/G/H formula, so closure is preserved from old seed.

## References

- Plan: `specs/864_recursive_seed_henkin_model/plans/implementation-001.md`, Phase 2
- Previous handoff: `specs/864_recursive_seed_henkin_model/handoffs/phase-2-handoff-20260218-2.md`
- API investigation notes in this handoff
