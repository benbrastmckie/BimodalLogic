# Implementation Summary: Task 25 - Rename CanonicalR to ExistsTask

## Overview

Completed rename of `CanonicalR` to `ExistsTask` across the codebase with backward compatibility aliases.

## Statistics

| Metric | Before | After |
|--------|--------|-------|
| CanonicalIrreflexivity.lean lines | 1515 | 298 |
| Lines removed (Phase 1) | - | ~1200 |
| Files modified (Phase 2) | - | 8 |

## Phase 1: Retire Gabbay Infrastructure

**Completed**: Reduced CanonicalIrreflexivity.lean from 1515 to 298 lines.

**Removed**:
- ~1200 lines of abandoned working notes and sorried proofs
- Fresh G-Atom Per-Witness Strictness section
- Extensive MCS pathology analysis and commentary
- Sorried `Gneg_seed_consistent` and related theorems

**Preserved**:
- Fresh atom utilities (`atoms_of_set`, `fresh_for_set`)
- Reflexivity theorems (`existsTask_reflexive`, `existsTask_past_reflexive`)
- Per-construction strictness helpers
- Layer 2 axiom documentation

## Phase 2: Rename CanonicalR to ExistsTask

**Core Definition Changes**:
```lean
-- CanonicalFrame.lean
def ExistsTask (M M' : Set Formula) : Prop := g_content M ⊆ M'
@[simp] lemma ExistsTask_def : ExistsTask M M' = (g_content M ⊆ M') := rfl
abbrev CanonicalR := ExistsTask  -- backward compatibility

def ExistsTask_past (M M' : Set Formula) : Prop := h_content M ⊆ M'
@[simp] lemma ExistsTask_past_def : ExistsTask_past M M' = (h_content M ⊆ M') := rfl
abbrev CanonicalR_past := ExistsTask_past  -- backward compatibility
```

**Theorem Renames** (with backward compatibility aliases):
| Old Name | New Name |
|----------|----------|
| `canonicalR_reflexive` | `existsTask_reflexive` |
| `canonicalR_past_reflexive` | `existsTask_past_reflexive` |
| `canonicalR_transitive` | `existsTask_transitive` |
| `lt_of_canonicalR_and_not_reverse` | `lt_of_existsTask_and_not_reverse` |
| `canonicalR_irreflexive_axiom` | `existsTask_irreflexive_axiom` |
| `canonicalR_irreflexive` | `existsTask_irreflexive` |

**Rewrite Tactic Fixes**:
Changed `rw [CanonicalR, Set.not_subset]` to `simp only [ExistsTask_def, Set.not_subset]` in 5 files:
- SeparationLemma.lean
- ConstructiveFragment.lean
- StagedExecution.lean
- DensityFrameCondition.lean
- DensityFrameCondition_StrictAttempt.lean (Boneyard)

## Phase 3: Documentation

- Updated module docstrings to reference `ExistsTask` names
- Updated Layer 2 documentation to use `existsTask_reflexive`
- Preserved `CanonicalR` in existing documentation via aliases

## Backward Compatibility

All existing code continues to work unchanged via `abbrev` aliases:
- `CanonicalR` resolves to `ExistsTask`
- `CanonicalR_past` resolves to `ExistsTask_past`
- All theorem names have backward compatibility aliases

## Verification

- `lake build` passes (1044 jobs)
- No new sorries introduced
- No new axioms introduced
- All tests pass

## Files Modified

1. `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (major cleanup + rename)
2. `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (definition rename)
3. `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` (tactic fix)
4. `Theories/Bimodal/Metalogic/StagedConstruction/SeparationLemma.lean` (tactic fix)
5. `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` (tactic fix)
6. `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` (tactic fix)
7. `Theories/Bimodal/Boneyard/Task956_StrictDensity/DensityFrameCondition_StrictAttempt.lean` (tactic fix)

## Notes

- The rename is complete with backward compatibility
- Existing code using `CanonicalR` names continues to work
- New code should use `ExistsTask` names going forward
- Full deprecation of `CanonicalR` names can be done in a future task if desired
