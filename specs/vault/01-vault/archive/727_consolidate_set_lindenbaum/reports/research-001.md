# Research Report: Task #727

**Task**: Consolidate set_lindenbaum duplicates
**Date**: 2026-01-28
**Focus**: Analyze the three locations of `set_lindenbaum` theorem and determine safe consolidation strategy

## Summary

Task 727 addresses three duplicate `set_lindenbaum` definitions across the Boneyard. The canonical source at `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:290` is already properly re-exported via `Metalogic/Core/MaximalConsistent.lean`. The duplicates in `Boneyard/Metalogic/Completeness.lean:360` and `Boneyard/Metalogic/Representation/CanonicalModel.lean:139` are only used by other Boneyard files that will become fully deprecated once Task 726 completes.

**Key Finding**: This task is **dependent on Task 726**. Once Task 726 moves the 5 essential MCS lemmas out of `Boneyard/Metalogic/Completeness.lean`, the duplicates become fully isolated and can be safely removed.

## Findings

### Three `set_lindenbaum` Locations

| Location | Namespace | Status |
|----------|-----------|--------|
| `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:290` | `Bimodal.Metalogic_v2.Core` | **CANONICAL** |
| `Boneyard/Metalogic/Completeness.lean:360` | `Bimodal.Boneyard.Metalogic` | DUPLICATE |
| `Boneyard/Metalogic/Representation/CanonicalModel.lean:139` | `Bimodal.Boneyard.Metalogic.Representation` | DUPLICATE |

### Re-Export Chain (Canonical)

```
Boneyard/Metalogic_v2/Core/MaximalConsistent.lean (definition)
         ↓ imports
Metalogic/Core/MaximalConsistent.lean (re-export)
         ↓ imports
Metalogic/Representation/CanonicalWorld.lean (usage)
Metalogic/Representation/CoherentConstruction.lean (usage)
Metalogic/Representation/IndexedMCSFamily.lean (usage)
```

The active codebase correctly uses the canonical source via the re-export chain.

### Duplicate Usage Analysis

#### `Boneyard/Metalogic/Completeness.lean:360`

**Internal usage within file**:
- Line 2526: `set_lindenbaum (forward_seed S)` in forward extension construction
- Lines 3656, 3684: Documentation references

**External consumers** (files that import `Boneyard/Metalogic/Completeness.lean`):
| File | Reason for Import |
|------|-------------------|
| `Metalogic/Representation/IndexedMCSFamily.lean:4` | For `set_mcs_all_future_all_future` lemma |
| `Metalogic/Representation/CoherentConstruction.lean:3` | For `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past` |
| `Metalogic.lean:4-5` | Module aggregation |
| `Boneyard/Metalogic/Completeness/FiniteCanonicalModel.lean:6` | Internal Boneyard |
| `Boneyard/Metalogic/Representation/ContextProvability.lean:4` | Internal Boneyard |
| `Boneyard/Metalogic/Representation/FiniteModelProperty.lean:1` | Internal Boneyard |

**Critical**: The external consumers (`IndexedMCSFamily.lean`, `CoherentConstruction.lean`) import for the MCS lemmas, NOT for `set_lindenbaum`. They get `set_lindenbaum` from their primary import of `Metalogic/Core/MaximalConsistent.lean`.

#### `Boneyard/Metalogic/Representation/CanonicalModel.lean:139`

**External consumers**:
| File | Usage |
|------|-------|
| `Boneyard/Metalogic/Representation/TruthLemma.lean` | Uses `CanonicalWorldState` |
| `Boneyard/Metalogic/Representation/RepresentationTheorem.lean` | Calls `set_lindenbaum` at line 62 |
| `Boneyard/Metalogic/Representation/FiniteModelProperty.lean` | Internal Boneyard |

**Key Point**: `RepresentationTheorem.lean` at line 62 calls `set_lindenbaum` in the `Representation` namespace. This call resolves to the local duplicate in `CanonicalModel.lean`, NOT the canonical source.

### Definition Comparison

All three definitions are **semantically identical**:

```lean
theorem set_lindenbaum (S : Set Formula) (hS : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M := by
  -- Uses zorn_subset_nonempty from Mathlib.Order.Zorn
  -- Same proof structure in all three locations
```

They also share identical helper definitions:
- `SetConsistent`
- `SetMaximalConsistent`
- `ConsistentSupersets`
- `self_mem_consistent_supersets`
- `finite_list_in_chain_member`
- `consistent_chain_union`

### Dependency Relationships

```
Task 726: Move 5 MCS lemmas to Core
    ├── Removes active codebase imports of Boneyard/Metalogic/Completeness.lean
    └── After completion, Completeness.lean is FULLY DEPRECATED

Task 727: Consolidate set_lindenbaum (THIS TASK)
    ├── Depends on Task 726 completion
    └── Can safely remove duplicates after 726
```

### Consolidation Strategy

#### Phase 1: Wait for Task 726
Task 726 will move the 5 essential MCS lemmas (`set_mcs_closed_under_derivation`, etc.) from `Boneyard/Metalogic/Completeness.lean` to `Metalogic/Core/MCSProperties.lean`. This removes all legitimate reasons for active code to import `Completeness.lean`.

#### Phase 2: Verify Isolation
After Task 726:
- No active file (outside Boneyard) should import `Boneyard/Metalogic/Completeness.lean`
- No active file should import `Boneyard/Metalogic/Representation/CanonicalModel.lean`

#### Phase 3: Add Deprecation Notices
Add deprecation comments to both duplicate files:

```lean
/- DEPRECATED: This `set_lindenbaum` is a duplicate.
   Canonical source: `Bimodal.Metalogic_v2.Core.set_lindenbaum`
   Re-exported via: `Bimodal.Metalogic.Core.set_lindenbaum`
   This file remains for historical reference only.
-/
```

#### Phase 4: Document in Boneyard README
Update `Boneyard/Metalogic/README.md` and `Boneyard/Metalogic/Representation/README.md` to explain:
- Historical context of the duplicates
- Canonical source location
- Why these files are preserved for reference

### Files to Modify

| File | Change |
|------|--------|
| `Boneyard/Metalogic/Completeness.lean` | Add deprecation notice to `set_lindenbaum` |
| `Boneyard/Metalogic/Representation/CanonicalModel.lean` | Add deprecation notice to `set_lindenbaum` |
| `Boneyard/Metalogic/README.md` | Document deprecation status |
| `Boneyard/Metalogic/Representation/README.md` | Create or update with deprecation info |

### What NOT to Do

1. **DO NOT remove `set_lindenbaum` from duplicates** - The Boneyard internal files still use them
2. **DO NOT change imports in Boneyard files** - They form a self-contained historical artifact
3. **DO NOT force Boneyard files to use canonical source** - Introduces cross-Boneyard dependencies

## Decisions

1. **Deprecate, don't delete**: Mark duplicates as deprecated, don't remove them
2. **Preserve Boneyard integrity**: Boneyard files should remain self-contained
3. **Depend on Task 726**: This task should wait for 726 to complete first
4. **Documentation focus**: The consolidation is primarily about documentation and preventing future confusion

## Recommendations

### Recommended Approach

1. **Block on Task 726**: Add dependency marker in state.json
2. **Add deprecation notices**: To duplicate `set_lindenbaum` definitions
3. **Create/update README files**: Document canonical source and deprecation status
4. **No code deletion**: Boneyard remains compilable and self-contained

### Alternative Approach (Not Recommended)

Refactor all Boneyard files to import from canonical source. This is:
- High effort for files that are already deprecated
- Introduces risk of breaking Boneyard compilation
- No benefit since Boneyard is not part of active development

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Premature consolidation before Task 726 | Build failures in active code | Wait for 726 completion |
| Confusion about canonical source | Future dev uses wrong import | Clear deprecation notices |
| Boneyard rot if not documented | Historical context lost | README documentation |

## Dependencies

- **Blocked by**: Task 726 (Move essential MCS lemmas to Core)
- **Parent**: Task 722
- **Related**: Task 726 (sibling subtask)

## Effort Estimate

- After Task 726 completes: 1-2 hours
- Tasks: Add deprecation comments, update/create READMEs, verify isolation

## Next Steps

1. Add dependency on Task 726 in state.json
2. Wait for Task 726 completion
3. `/implement 727` after Task 726 completes
