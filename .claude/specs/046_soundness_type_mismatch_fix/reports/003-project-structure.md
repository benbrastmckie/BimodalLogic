# Project Structure Research Report: Soundness Type Mismatch Fix

## Overview

This report documents the project structure analysis for fixing the Soundness.lean type mismatch errors, including file dependencies, testing strategy, and documentation updates.

## File Dependencies

### Core File Under Modification

```
Logos/Core/Metalogic/Soundness.lean (606 lines)
├── imports:
│   ├── Logos.Core.ProofSystem.Derivation
│   └── Logos.Core.Semantics.Validity
├── provides:
│   ├── 12 axiom validity theorems (prop_k_valid, etc.)
│   ├── axiom_valid helper theorem
│   └── soundness theorem
└── used by:
    ├── LogosTest/Core/Metalogic/SoundnessTest.lean
    └── (potentially other modules via Logos.lean)
```

### Upstream Dependencies (Read-Only)

```
Logos/Core/Semantics/Validity.lean
├── valid : Formula → Prop
├── semantic_consequence : Context → Formula → Prop
├── Notation: ⊨ φ, Γ ⊨ φ
└── Key insight: quantifies ∀ (T : Type) [LinearOrderedAddCommGroup T] ...

Logos/Core/Semantics/Truth.lean
├── truth_at : TaskModel F → WorldHistory F → T → (τ.domain t) → Formula → Prop
└── TimeShift module (time_shift_preserves_truth, etc.)

Logos/Core/Semantics/TaskFrame.lean
├── TaskFrame (T : Type*) [LinearOrderedAddCommGroup T]
└── nullity, compositionality constraints

Logos/Core/Semantics/TaskModel.lean
├── TaskModel {T : Type*} [inst] (F : TaskFrame T)
└── valuation function

Logos/Core/Semantics/WorldHistory.lean
├── WorldHistory {T} (F : TaskFrame T)
├── domain, states fields
└── time_shift operations
```

### Downstream Dependencies (To Update/Test)

```
LogosTest/Core/Metalogic/SoundnessTest.lean
├── Tests for soundness theorem
├── Tests for axiom validity
└── Must pass after fix

LogosTest/ (Full Test Suite)
├── Run via `lake test`
└── Verify no regression
```

## Test Files Analysis

### SoundnessTest.lean

Location: `LogosTest/Core/Metalogic/SoundnessTest.lean`

Likely tests:
1. Individual axiom validity (modal_t_valid, etc.)
2. Soundness of specific derivations
3. Integration with derivation module

### Running Tests

```bash
# Build and test full project
lake build && lake test

# Type-check specific file
lake env lean Logos/Core/Metalogic/Soundness.lean

# Type-check test file
lake env lean LogosTest/Core/Metalogic/SoundnessTest.lean
```

## Documentation Files to Update

### Required Updates

1. **IMPLEMENTATION_STATUS.md** (`Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`)
   - Update Soundness.lean status from partial to complete
   - Update soundness theorem completion status

2. **SORRY_REGISTRY.md** (`Documentation/ProjectInfo/SORRY_REGISTRY.md`)
   - If any sorry placeholders are added/removed
   - Update technical debt tracking

3. **TODO.md** (Root)
   - Mark Task 17 as complete
   - Update "Active Tasks" count

4. **.claude/TODO.md**
   - Update specs tracking
   - Add implementation summary

### Optional Updates

1. **CLAUDE.md** (Root)
   - Update CLAUDE.md if axiom/rule count changes
   - Update "Proven rules" section if needed

## Error Location Analysis

### Error Distribution in Soundness.lean

| Line Range | Module Section | Error Count | Fix Type |
|------------|---------------|-------------|----------|
| 84-103 | prop_k, prop_s validity | 2 | intro pattern |
| 114-142 | modal_t, modal_4 validity | 2 | intro pattern |
| 156-178 | modal_b validity | 1 | intro pattern |
| 191-217 | modal_k_dist, double_neg validity | 2 | intro pattern |
| 229-289 | temp_4, temp_a validity | 2 | intro pattern |
| 311-347 | temp_l validity | 1 | intro pattern |
| 363-429 | modal_future, temp_future validity | 2 | intro pattern + time_shift |
| 469-479 | soundness: axiom, assumption | 2 | intro + call |
| 481-502 | soundness: modus_ponens, necessitation | 2 | intro + IH calls |
| 504-566 | soundness: modal_k, temporal_k | 2 | intro + IH calls |
| 568-594 | soundness: temporal_duality | 1 | intro |
| 596-603 | soundness: weakening | 1 | intro + IH call |

Total: ~20 locations need fixes

## Project Quality Metrics

### Current Status

From IMPLEMENTATION_STATUS.md and TODO.md:
- Soundness: 12/12 axioms, 4/8 rules proven (with sorries in some helper functions)
- Task 17: Not Started

### After Fix

Expected:
- Soundness: 12/12 axioms, 4/8 rules proven (same, but type errors resolved)
- Task 17: Complete

## Findings

### Finding 1: Isolated Module

Soundness.lean is relatively isolated - it imports from Semantics and ProofSystem but doesn't have many downstream consumers. This limits blast radius.

### Finding 2: Test Coverage Exists

SoundnessTest.lean provides test coverage for the soundness theorem and axiom validity lemmas. Tests should pass after fixes.

### Finding 3: No API Changes

The fix doesn't change any public API signatures - only internal proof structures. This means:
- No downstream breaking changes
- No documentation updates for API
- Tests should work unchanged

### Finding 4: truth_at Signature

The `truth_at` function already has the correct signature with explicit domain proof:
```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t) : Formula → Prop
```

This is consistent and doesn't need changes.

## Recommendations

### Recommendation 1: Incremental Fix Strategy

Apply fixes in sections, testing after each:

1. **Section 1**: Fix axiom validity lemmas (12 functions)
   - `lake env lean Logos/Core/Metalogic/Soundness.lean`

2. **Section 2**: Fix soundness theorem cases (8 cases)
   - `lake env lean Logos/Core/Metalogic/Soundness.lean`

3. **Section 3**: Run full test suite
   - `lake build && lake test`

### Recommendation 2: Documentation Update Order

After code fix is complete:

1. Update TODO.md - Mark Task 17 complete
2. Update IMPLEMENTATION_STATUS.md - Update Soundness.lean status
3. Update .claude/TODO.md - Add implementation summary reference
4. Create implementation summary in specs directory

### Recommendation 3: Git Commit Strategy

Single commit with message:
```
fix(metalogic): Resolve Soundness.lean type mismatch errors (Task 17)

- Add missing type parameter T to intro patterns in axiom validity lemmas
- Fix intro patterns in soundness theorem cases
- Update IH and function call sites with correct arguments

All 12 axiom validity proofs and 8 soundness cases now type-check.
Closes Task 17.
```

## Implementation Checklist

### Pre-Implementation

- [ ] Read current Soundness.lean
- [ ] Verify error count with `lake env lean`
- [ ] Review test file structure

### Implementation

- [ ] Fix intro patterns in axiom validity lemmas (12)
- [ ] Fix intro pattern in soundness: axiom case
- [ ] Fix intro pattern in soundness: assumption case
- [ ] Fix intro pattern in soundness: modus_ponens case
- [ ] Fix intro pattern in soundness: necessitation case
- [ ] Fix intro pattern in soundness: modal_k case
- [ ] Fix intro pattern in soundness: temporal_k case
- [ ] Fix intro pattern in soundness: temporal_duality case
- [ ] Fix intro pattern in soundness: weakening case
- [ ] Update IH call sites in modus_ponens
- [ ] Update IH call sites in necessitation
- [ ] Update IH call sites in modal_k
- [ ] Update IH call sites in temporal_k
- [ ] Update IH call sites in weakening

### Post-Implementation

- [ ] Verify with `lake env lean Logos/Core/Metalogic/Soundness.lean`
- [ ] Run `lake build`
- [ ] Run `lake test`
- [ ] Update TODO.md
- [ ] Update IMPLEMENTATION_STATUS.md
- [ ] Create implementation summary

## Conclusion

The project structure supports a clean fix:
1. Single file modification (Soundness.lean)
2. No API changes
3. Existing test coverage
4. Clear documentation update path

The fix is low-risk and well-contained within the Soundness.lean module.
