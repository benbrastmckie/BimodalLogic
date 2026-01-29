# Research Report: Task #726

**Task**: Move essential MCS lemmas to Core
**Date**: 2026-01-28
**Focus**: Eliminate Boneyard imports from active codebase while preserving documentation of historical origins; improve Metalogic/Core/ structure

## Summary

Task 726 addresses a structural issue where the active `Metalogic/` codebase imports directly from `Boneyard/Metalogic/Completeness.lean` for 5 essential MCS lemmas. The user's requirements clarify that:

1. **No active imports from Boneyard** - The active codebase should not reference Boneyard files
2. **Document provenance in comments** - Explain where moved lemmas came from
3. **Improve Metalogic/Core/ structure** - Ensure Core contains what it should for a well-organized Metalogic/

## Findings

### Current State: Boneyard Imports in Active Files

Three active files import from Boneyard:

| File | Import | Lemmas Used |
|------|--------|-------------|
| `Metalogic/Core/MaximalConsistent.lean` | `Boneyard.Metalogic_v2.Core.MaximalConsistent` | Re-exports MCS definitions |
| `Metalogic/Representation/IndexedMCSFamily.lean` | `Boneyard.Metalogic.Completeness` | `set_mcs_closed_under_derivation`, `set_mcs_all_future_all_future` |
| `Metalogic/Representation/TruthLemma.lean` | (via IndexedMCSFamily) | `set_mcs_implication_property`, `set_mcs_negation_complete` |
| `Metalogic/Representation/CoherentConstruction.lean` | `Boneyard.Metalogic.Completeness` | `set_mcs_closed_under_derivation`, `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past` |

### Lemmas That Need to Be in Core

The 5 lemmas mentioned in the task description, plus their dependencies:

#### Essential Lemmas (from Boneyard/Metalogic/Completeness.lean)

| Lemma | Line | Purpose |
|-------|------|---------|
| `set_mcs_closed_under_derivation` | 577 | MCS deductive closure - **CRITICAL** |
| `set_mcs_implication_property` | 655 | Modus ponens in MCS |
| `set_mcs_negation_complete` | 679 | φ ∈ S ∨ ¬φ ∈ S |
| `set_mcs_all_future_all_future` | 1055 | G-4 axiom: Gφ ∈ S → GGφ ∈ S |
| `set_mcs_all_past_all_past` | 1115 | H-4 axiom: Hφ ∈ S → HHφ ∈ S |

#### Dependencies (from Boneyard/Metalogic_v2/Core/MaximalConsistent.lean)

These are already re-exported by `Metalogic/Core/MaximalConsistent.lean`:

| Definition/Lemma | Purpose |
|------------------|---------|
| `SetConsistent` | Set-based consistency |
| `SetMaximalConsistent` | Set-based MCS |
| `set_lindenbaum` | Lindenbaum's lemma |
| `set_mcs_finite_subset_consistent` | Bridge lemma |
| `derivation_uses_finite_context` | Finite subset property |
| `derives_bot_from_phi_neg_phi` | Contradiction helper |

#### Required Helper (from Boneyard/Metalogic_v2/Core/DeductionTheorem.lean)

| Definition/Lemma | Purpose |
|------------------|---------|
| `deduction_theorem` | Used by `set_mcs_closed_under_derivation` |
| `derivation_exchange` | Context permutation helper |

### Current Metalogic/Core/ Structure

```
Metalogic/Core/
├── Core.lean              # Module re-export
└── MaximalConsistent.lean # Re-exports from Boneyard/Metalogic_v2/Core/MaximalConsistent.lean
```

The current structure re-exports definitions from `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` but not the lemmas from `Boneyard/Metalogic/Completeness.lean` that are needed by the Representation layer.

### Where the 5 Lemmas Are Defined

All 5 lemmas are in `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean`:

1. **`set_mcs_closed_under_derivation`** (line 577) - Depends on `deduction_theorem` from Boneyard/Metalogic_v2/Core/DeductionTheorem.lean
2. **`set_mcs_implication_property`** (line 655) - Uses `set_mcs_closed_under_derivation`
3. **`set_mcs_negation_complete`** (line 679) - Uses `deduction_theorem` and `set_mcs_closed_under_derivation`
4. **`set_mcs_all_future_all_future`** (line 1055) - Uses `set_mcs_closed_under_derivation` + temporal axioms
5. **`set_mcs_all_past_all_past`** (line 1115) - Uses `set_mcs_closed_under_derivation` + temporal axioms

### Proposed Architecture

Create a clean `Metalogic/Core/` that owns all MCS theory, no Boneyard imports:

```
Metalogic/Core/
├── Core.lean                    # Module re-export
├── Consistency.lean             # Consistent, SetConsistent definitions
├── MaximalConsistent.lean       # SetMaximalConsistent, set_lindenbaum
├── DeductionTheorem.lean        # deduction_theorem (moved from Boneyard)
└── MCSProperties.lean           # The 5 essential lemmas (NEW)
```

**Alternative (simpler)**: Keep one MaximalConsistent.lean file and add the 5 lemmas directly to it, with comments explaining they originate from Boneyard/Metalogic/Completeness.lean.

### Documentation Requirements

Per user request, each moved lemma should have a comment like:

```lean
/--
Set-based MCS deductive closure.

**Origin**: Originally in `Boneyard/Metalogic/Completeness.lean:577`.
Moved to Core to eliminate Boneyard imports from active codebase.
-/
lemma set_mcs_closed_under_derivation ...
```

### Documentation Updates Needed

1. **Metalogic/README.md** - Update "Main Components" table to reflect new Core structure
2. **Metalogic/Core/MaximalConsistent.lean** - Remove re-export pattern, contain actual definitions
3. **Representation files** - Change imports from `Boneyard.Metalogic.Completeness` to `Metalogic.Core.MCSProperties`

## Decisions

1. **Consolidate vs Split**: Recommend a single `MCSProperties.lean` for the 5 lemmas rather than splitting across multiple files, to minimize import complexity
2. **Copy vs Move**: Copy lemmas to Core (they stay in Boneyard for historical reference), update imports in active files
3. **DeductionTheorem**: Needs its own file in Core since it's a dependency of the 5 lemmas

## Recommendations

### Phase 1: Create Core/DeductionTheorem.lean

Copy `deduction_theorem` and `derivation_exchange` from `Boneyard/Metalogic_v2/Core/DeductionTheorem.lean` with origin comments.

### Phase 2: Create Core/MCSProperties.lean

Copy the 5 essential lemmas with origin comments:
- `set_mcs_closed_under_derivation`
- `set_mcs_implication_property`
- `set_mcs_negation_complete`
- `set_mcs_all_future_all_future`
- `set_mcs_all_past_all_past`

### Phase 3: Update Core/MaximalConsistent.lean

Remove the import from `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean`. Instead, either:
- Copy the definitions directly with origin comments, OR
- Re-export from Core/Consistency.lean + Core/DeductionTheorem.lean + Core/MCSProperties.lean

### Phase 4: Update Representation Imports

Change imports in:
- `IndexedMCSFamily.lean`: `Boneyard.Metalogic.Completeness` → `Metalogic.Core.MCSProperties`
- `CoherentConstruction.lean`: Same change
- `TruthLemma.lean`: May need explicit import of MCSProperties

### Phase 5: Update Documentation

- Update `Metalogic/README.md` to reflect new Core structure
- Add "Origin" comments to all moved code

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Build breakage from circular imports | High | Careful import ordering: DeductionTheorem → MCSProperties → MaximalConsistent |
| Missing dependencies | Medium | Run `lake build` after each phase |
| Namespace conflicts | Low | Keep original namespace `Bimodal.Metalogic.Core` |

## Dependencies

- Task 726 is a subtask of Task 722 (parent)
- No blocking dependencies
- Related tasks: 727 (consolidate set_lindenbaum duplicates)

## Next Steps

1. `/plan 726` - Create implementation plan with phases
2. Build incrementally, verifying compilation after each file
3. Update documentation last
