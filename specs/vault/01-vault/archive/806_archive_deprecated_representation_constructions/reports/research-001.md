# Research Report: Archive Deprecated Representation Constructions

**Task**: 806
**Date**: 2026-02-02
**Session**: sess_1769996369_5f91ea

## Executive Summary

Investigation of `IndexedMCSFamily.lean` and `CanonicalHistory.lean` reveals that while both files contain deprecated constructions marked as "SUPERSEDED", they **cannot be safely archived** to Boneyard because other active code depends on them. However, the deprecated portions within `IndexedMCSFamily.lean` account for **4 sorries** that could potentially be removed by refactoring.

## Files Analyzed

### 1. IndexedMCSFamily.lean
**Location**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Contents**:
- `IndexedMCSFamily` structure - Core abstraction for indexed MCS families (ACTIVE)
- Helper lemmas for coherence, T-axiom closure (ACTIVE)
- Seed set definitions (`future_seed`, `past_seed`, `time_seed`) (ACTIVE)
- Seed consistency lemmas (ACTIVE)
- **SUPERSEDED**: `construct_indexed_family` function with 4 sorries (lines 636, 643, 650, 657)

**Deprecation Evidence**:
```lean
/-!
## SUPERSEDED CONSTRUCTION

**Note**: The `construct_indexed_family` function below uses an independent Lindenbaum
extension approach that cannot prove the required coherence conditions. This approach
has been superseded by `CoherentConstruction.lean`.
-/
```

**Sorry Count**: 4 (all in the superseded `construct_indexed_family` function)

### 2. CanonicalHistory.lean
**Location**: `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean`

**Contents**:
- `UniversalCanonicalFrame` definition (ACTIVE)
- `full_domain` predicates (ACTIVE)
- **BLOCKED**: `canonical_history_respects` with 2 sorries (lines 136, 139) - uses same-MCS approach
- `canonical_history_family_*` functions using IndexedMCSFamily approach (ACTIVE)

**Deprecation Evidence**:
```lean
- `canonical_history` uses same MCS at all times (BLOCKED by T-axiom requirement)
- `canonical_history_family` uses family's varying MCS (works without T-axiom)
```

**Sorry Count**: 2 (in the blocked `canonical_history_respects` function)

## Dependency Analysis

### Files That Import IndexedMCSFamily.lean
| File | Active/Boneyard | Notes |
|------|-----------------|-------|
| `CanonicalHistory.lean` | Active | Uses `IndexedMCSFamily` structure |
| `TruthLemma.lean` | Active | Uses `IndexedMCSFamily`, `canonical_history_family` |
| `CoherentConstruction.lean` | Active | Uses `IndexedMCSFamily` structure for bridge |
| `UniversalCanonicalModel.lean` | Active | Uses `IndexedMCSFamily`, `TruthLemma` |

### Files That Import CanonicalHistory.lean
| File | Active/Boneyard | Notes |
|------|-----------------|-------|
| `TruthLemma.lean` | Active | Uses `canonical_history_family`, `UniversalCanonicalFrame` |

## What is Deprecated vs. Active

### IndexedMCSFamily.lean - HYBRID
**Active Components** (cannot be archived):
- `IndexedMCSFamily` structure (4 coherence fields, `mcs`, `is_mcs`)
- All accessor lemmas (`at`, `consistent`, `maximal`)
- All derived coherence lemmas (`forward_G_chain`, `backward_H_chain`, etc.)
- T-axiom closure lemmas (`mcs_closed_temp_t_future`, `mcs_closed_temp_t_past`)
- Seed definitions and consistency lemmas
- `mcs_at_time`, `mcs_at_time_contains_seed`, `mcs_at_time_is_mcs`

**Deprecated Components** (sorries):
- `construct_indexed_family` function (4 sorries)
- `construct_indexed_family_origin`
- `construct_indexed_family_origin_extends`

### CanonicalHistory.lean - HYBRID
**Active Components** (cannot be archived):
- `UniversalCanonicalFrame` definition
- `full_domain`, `full_domain_convex`
- `canonical_history_family_states`
- `canonical_history_family_respects` (PROVEN, no sorries)
- `canonical_history_family` definition
- All `canonical_history_family_*` lemmas

**Deprecated/Blocked Components** (sorries):
- `canonical_history_states` (no sorries, but blocked approach)
- `canonical_history_respects` (2 sorries)
- `canonical_history` (uses blocked approach)
- All `canonical_history_*` lemmas (non-family versions)

## Superseding Implementation

The deprecated constructions were superseded by **CoherentConstruction.lean**:

```lean
-- From CoherentConstruction.lean
def CoherentIndexedFamily.toIndexedMCSFamily (F : CoherentIndexedFamily D) :
    IndexedMCSFamily D where
  mcs := F.mcs
  is_mcs := F.is_mcs
  forward_G := fun t t' φ h_lt h_G => (F.pairwise_coherent t t').1 h_lt φ h_G
  backward_H := fun t t' φ h_lt h_H => (F.pairwise_coherent t t').2.1 h_lt φ h_H
  forward_H := fun t t' φ h_lt h_H => (F.pairwise_coherent t t').2.2.1 h_lt φ h_H
  backward_G := fun t t' φ h_lt h_G => (F.pairwise_coherent t t').2.2.2 h_lt φ h_G
```

The representation theorem in `UniversalCanonicalModel.lean` uses:
```lean
let coherent := construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot
let family := coherent.toIndexedMCSFamily
```

## Recommendations

### Option A: Full Archival (NOT RECOMMENDED)
Cannot archive either file entirely because:
1. `IndexedMCSFamily` structure is used by 4 active files
2. `UniversalCanonicalFrame` and `canonical_history_family` are used by TruthLemma
3. Would require major refactoring of the representation theorem chain

### Option B: Partial Cleanup (RECOMMENDED)
**Phase 1**: Remove deprecated constructions while keeping active components

For `IndexedMCSFamily.lean`:
1. Remove or comment out `construct_indexed_family` function
2. Remove or comment out `construct_indexed_family_origin*` lemmas
3. Add clear documentation directing to `CoherentConstruction.lean`
4. **Reduces sorry count by 4**

For `CanonicalHistory.lean`:
1. Remove or comment out non-family `canonical_history*` functions
2. Keep only `canonical_history_family*` functions
3. Add clear documentation
4. **Reduces sorry count by 2**

### Option C: Documentation-Only (CONSERVATIVE)
Leave code as-is but add prominent deprecation warnings to help developers avoid using deprecated code paths.

## Sorry Count Impact

| File | Current Sorries | After Cleanup | Reduction |
|------|-----------------|---------------|-----------|
| IndexedMCSFamily.lean | 4 | 0 | -4 |
| CanonicalHistory.lean | 2 | 0 | -2 |
| **Total** | 6 | 0 | **-6** |

## Additional Context

### Why Deprecation Occurred
The original "same MCS at all times" approach in `CanonicalHistory.lean` and the "independent Lindenbaum extension" approach in `IndexedMCSFamily.lean` both failed because:

1. **T-axiom requirement**: The same-MCS approach requires `G phi -> phi` to show task relation holds, but TM logic has IRREFLEXIVE temporal operators (no temporal T-axiom).

2. **Coherence impossible after construction**: Independent Lindenbaum extensions at each time point can add conflicting formulas, making it impossible to prove the four coherence conditions post-hoc.

The solution (`CoherentConstruction.lean`) builds coherence **definitionally** into the construction itself, using `coherent_at` relation and chain constructions with seed-based extensions.

### Related Files (Also with Sorries)
- `TaskRelation.lean`: 6 sorries in `canonical_task_rel_comp`
- `CanonicalWorld.lean`: 2 sorries in `neg_complete` and `deductively_closed`
- `CoherentConstruction.lean`: 12 sorries (but documented as "NOT REQUIRED FOR COMPLETENESS")
- `TruthLemma.lean`: 4 sorries (documented as architectural limitations or not required)

## Implementation Considerations

If proceeding with Option B (partial cleanup):

1. **Create Boneyard stubs**: Move deprecated functions to `Boneyard/Metalogic_v5/` for historical reference
2. **Update documentation**: Add module-level docs explaining the design evolution
3. **Verify build**: Run `lake build` to ensure no remaining references
4. **Test imports**: Verify all importing files still compile

## Conclusion

The task description suggested archiving entire files, but analysis shows this is not feasible due to active dependencies. Instead, the deprecated **portions** of these files can be removed, reducing the sorry count by 6. The active components must remain in place as they form the foundation of the representation theorem chain.

Recommended approach: **Option B (Partial Cleanup)** - Remove deprecated constructions while preserving active components.
