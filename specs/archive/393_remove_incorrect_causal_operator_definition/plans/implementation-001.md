# Implementation Plan: Task #393

**Task**: Remove incorrect causal operator definition
**Version**: 001
**Created**: 2026-01-12
**Language**: lean

## Overview

Remove the incorrect Lewis (1973) counterfactual analysis implementation of the causal operator from Truth.lean and replace it with a `sorry` stub. Update docstrings in both Truth.lean and Syntax.lean to indicate the operator is primitive (not derived) and awaiting correct implementation from the paper semantics. This clears the way for Task 394 to implement the correct semantics.

## Phases

### Phase 1: Update Truth.lean semantic definition

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Replace incorrect causal operator semantics with `sorry` stub
2. Add comprehensive documentation explaining why it's a stub
3. Reference Task 394 and the paper specification

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - Lines 148-161

**Steps**:
1. Read Truth.lean and locate the `Formula.causal` case (lines 148-161)
2. Replace the current implementation:
   ```lean
   | Formula.causal φ ψ =>
       truthAt M τ t ht σ idx φ ∧
       (∃ y, ∃ hy : y ∈ τ.domain, y > t ∧ truthAt M τ y hy σ idx ψ) ∧
       truthAt M τ t ht σ idx (Formula.counterfactual (Formula.neg φ) (Formula.neg (Formula.some_future ψ)))
   ```
   With:
   ```lean
   | Formula.causal _ _ =>
       -- A ○→ B: A causes B
       -- STUB: Awaiting correct implementation from "Counterfactual Worlds"
       -- (Brast-McKie 2025), line 626.
       --
       -- The causal operator is PRIMITIVE (like the counterfactual conditional □→),
       -- NOT defined in terms of counterfactuals.
       --
       -- The current implementation used the simple Lewis (1973) counterfactual
       -- analysis: A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB). This is INCORRECT because:
       -- - It cannot handle preemption or overdetermination
       -- - It lacks context parameters ⟨time_cause, time_effect, background⟩
       -- - It lacks expected evolution/subevolution structure
       --
       -- Correct semantics requires three conditions:
       -- (1) Inclusion: cause and effect in background assumptions
       -- (2) Substantial contribution: minimal subevolution requirement
       -- (3) Difference-making: counterfactual via inverted effect
       --
       -- See Task 394 for implementation of correct semantics.
       sorry
   ```

**Verification**:
- File compiles with `lake build Logos.SubTheories.Explanatory.Truth`
- Only one `sorry` introduced (for the causal case)

---

### Phase 2: Update Truth.lean module docstring

**Estimated effort**: 5 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Remove the incorrect claim about counterfactual analysis in module docstring
2. Update to reflect that causal semantics is awaiting implementation

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - Lines 25-27

**Steps**:
1. Locate module docstring (lines 5-28)
2. Change lines 25-27 from:
   ```
   Truth evaluation is defined recursively on formula structure. The counterfactual
   conditional uses a simplified mereological formulation from the paper. The causal
   operator follows the counterfactual analysis: A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB).
   ```
   To:
   ```
   Truth evaluation is defined recursively on formula structure. The counterfactual
   conditional uses a simplified mereological formulation from the paper. The causal
   operator (○→) is awaiting correct implementation from "Counterfactual Worlds"
   (Brast-McKie 2025) - see Task 394.
   ```

**Verification**:
- Docstring accurately describes implementation state
- No misleading claims about counterfactual analysis

---

### Phase 3: Update Syntax.lean docstring

**Estimated effort**: 5 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update the `causal` constructor docstring to indicate primitive status
2. Remove the incorrect derived definition claim
3. Reference Task 394 for implementation

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Syntax.lean` - Lines 73-77

**Steps**:
1. Locate the `causal` constructor docstring (lines 73-77)
2. Change from:
   ```lean
   /-- Causation: A ○→ B (A causes B)
       Semantic definition follows counterfactual analysis:
       A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)
       See "Counterfactual Worlds" (Brast-McKie 2025) for hyperintensional foundation. -/
   | causal : Formula → Formula → Formula
   ```
   To:
   ```lean
   /-- Causation: A ○→ B (A causes B)

       This operator is PRIMITIVE (like the counterfactual conditional □→).

       AWAITING IMPLEMENTATION: The correct semantics from "Counterfactual Worlds"
       (Brast-McKie 2025) line 626 requires context parameters and expected evolutions.
       See Task 394 for research on porting the paper semantics. -/
   | causal : Formula → Formula → Formula
   ```

**Verification**:
- File compiles with `lake build Logos.SubTheories.Explanatory.Syntax`
- Docstring is accurate and informative

---

### Phase 4: Verify build and create summary

**Estimated effort**: 10 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Ensure full project builds successfully
2. Verify the sorry count is acceptable
3. Document changes for future reference

**Files to modify**:
- None (verification only)

**Steps**:
1. Run `lake build` to verify full project builds
2. Check diagnostics with lean_diagnostic_messages on both files
3. Verify only one sorry was introduced (in Truth.lean causal case)
4. Create implementation summary

**Verification**:
- `lake build` succeeds
- No new errors introduced
- Sorry count increased by exactly 1

## Dependencies

- None - this is a cleanup task

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breaks from sorry | Low | Low | sorry is valid Lean; builds will succeed |
| Other code depends on causal semantics | Medium | Low | Research found no dependent code |
| Task 394 description mismatch | Low | Low | Verified description matches paper |

## Success Criteria

- [ ] Truth.lean compiles with sorry stub for causal operator
- [ ] Syntax.lean compiles with updated docstring
- [ ] Full project builds (`lake build`)
- [ ] Module docstrings accurately reflect implementation state
- [ ] No incorrect claims about counterfactual analysis remain
- [ ] Task 394 is properly referenced for future implementation

## Rollback Plan

If implementation fails:
1. Revert all changes with `git checkout -- Theories/Logos/SubTheories/Explanatory/`
2. The original (incorrect) implementation will still compile
3. Investigate build issues before retrying
