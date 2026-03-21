# Research Report: Task #826

**Task**: Update FDSM Completeness to Use Saturated Construction
**Date**: 2026-02-03
**Focus**: Remaining sorry inventory for sorry-free metalogic, task 826 scope, work remaining beyond 826

## Summary

After task 825's completion of the multi-history modal saturation infrastructure, the metalogic has approximately 43-47 sorries distributed across FDSM, Bundle, FMP, and Completeness modules. Task 826's scope is narrow (1-2 sorries in Completeness.lean), while the remaining sorries form distinct categories: (1) technical infrastructure sorries that can be fixed with focused work, (2) truth lemma sorries blocked by closure membership bookkeeping, and (3) architectural limitations that require fundamental redesigns (appropriate for task 818).

## Sorry Inventory by Module

### FDSM/ Module (Core path - 21 sorries)

| File | Count | Categories |
|------|-------|------------|
| **Core.lean** | 1 | Closure membership in modal_saturated definition |
| **TruthLemma.lean** | 12 | Closure membership tracking, case-by-case gaps |
| **ModalSaturation.lean** | 8 | Saturation proofs, MCSTrackedHistory finite |
| **Completeness.lean** | 3 | fdsm_from_closure_mcs modal_saturated, bridge lemmas |

**Total FDSM: 24 sorries**

### Bundle/ Module (BMCS approach - 4 sorries)

| File | Count | Categories |
|------|-------|------------|
| **Construction.lean** | 1 | modal_backward (architectural - single-family) |
| **TruthLemma.lean** | 2 | Temporal backward (omega-rule limitation) |
| **Other files** | 0-1 | Cleanup/documentation |

**Total Bundle: 3-4 sorries**

### FMP/ Module (Semantic approach - 8 sorries)

| File | Count | Categories |
|------|-------|------------|
| **ConsistentSatisfiable.lean** | 6 | Modal/temporal truth correspondence blocked |
| **Closure.lean** | 1 | diamond_in_closureWithNeg_of_box |
| **SemanticCanonicalModel.lean** | 0 | SORRY-FREE - the canonical completeness |

**Total FMP: 7-8 sorries**

### Completeness/ Module (Strong completeness - 1 sorry)

| File | Count | Categories |
|------|-------|------------|
| **FiniteStrongCompleteness.lean** | 1 | Validity bridge (general -> FMP-internal) |

**Total Completeness: 1 sorry**

## Canonical Sorry-Free Path

**The canonical sorry-free completeness result exists**: `semantic_weak_completeness` in `SemanticCanonicalModel.lean`.

This theorem is PROVEN (no sorry) and provides weak completeness via:
- FMP-internal validity (SemanticWorldState, not general TaskModel)
- Contrapositive construction

The bridge from "general validity" to "FMP-internal validity" is **architecturally blocked** for modal/temporal operators (see ConsistentSatisfiable.lean documentation).

## Task 826 Specific Scope

Task 826's description calls for:
1. Replace `fdsm_from_closure_mcs` with `fdsm_from_saturated_histories`
2. Update `modal_saturated` proof to use saturation property
3. Ensure eval_history properly selected

**Current State After Task 825**:
- `fdsm_from_tracked_saturation` exists in ModalSaturation.lean (line 1287)
- `tracked_fixed_point_is_saturated` proven (key correctness theorem)
- `mcsTrackedHistory_from_mcs` builds initial tracked history
- `fdsm_from_tracked_saturation_eval_history` established

**What Remains for 826**:
1. Replace `fdsm_from_closure_mcs` usage in Completeness.lean (line 271) with `fdsm_from_full_mcs` (which already exists and uses tracked saturation)
2. The `modal_saturated` sorry in fdsm_from_tracked_saturation (line 1306) needs completion
3. Verify completeness theorems compile with the updated construction

**Estimated Effort**: 1-2 hours (the infrastructure from task 825 is in place)

## Remaining Work Categories for Sorry-Free Metalogic

### Category A: Closure Membership Infrastructure (6-8 sorries)

**Pattern**: Many sorries exist because `psi ∈ closure phi` proofs need threading through constructions.

**Affected files**:
- `TruthLemma.lean`: 10+ sorries for closure membership tracking
- `Core.lean`: 1 sorry in modal_saturated definition
- `Closure.lean`: 1 sorry in diamond_in_closureWithNeg_of_box

**Solution**: Add consistent closure membership infrastructure - either:
- Carry proofs explicitly through all definitions
- Use dependent types `{psi : Formula // psi ∈ closure phi}`
- Provide automation lemmas

**Effort**: 4-6 hours (systematic but straightforward)

### Category B: Saturation Termination/Fixed-Point (3 sorries)

**Pattern**: Classical well-foundedness arguments for saturation termination

**Sorries in ModalSaturation.lean**:
- `saturation_terminates` (line 728)
- `tracked_saturated_histories_saturated` (line 1211)
- `mcsTrackedHistory_finite` (line 877)

**Solution**: Complete cardinality-based termination proofs. The structure is there:
- `saturation_step_card_increase` is proven
- Need to compose into well-founded argument

**Effort**: 2-4 hours

### Category C: Projection Lemmas (2-3 sorries)

**Pattern**: Connecting tracked history world states back to MCS membership

**Sorries in ModalSaturation.lean**:
- `projectTrackedHistories_modal_saturated` (line 1273)
- `fdsm_from_tracked_saturation` modal_saturated (line 1306)

**Solution**: Need lemmas connecting:
- `(th.history.states t).toSet` to `th.mcs`
- Use `derived_from_mcs` field in MCSTrackedHistory

**Effort**: 2-3 hours

### Category D: Architectural Blockers (Leave to 818)

**Pattern**: Fundamental design limitations requiring major refactors

| Sorry | Location | Limitation |
|-------|----------|------------|
| `modal_backward` | Bundle/Construction.lean | Single-family BMCS trivializes |
| Temporal backward | Bundle/TruthLemma.lean | Omega-rule in finitary system |
| Modal/temporal truth correspondence | FMP/ConsistentSatisfiable.lean | General validity != FMP validity |
| Validity bridge | Completeness/FiniteStrongCompleteness.lean | Same root cause |

**Recommendation**: These should be documented and archived to Boneyard. The FDSM approach was designed specifically to avoid these blockers by using bounded time and multi-history saturation.

## Priority Ordering for Sorry Removal

### High Priority (Task 826)
1. Complete `fdsm_from_tracked_saturation` modal_saturated case
2. Update Completeness.lean to use the new construction
3. Verify completeness theorems compile

### Medium Priority (Post-826, Pre-818)
4. Complete saturation termination proofs (Category B)
5. Add closure membership infrastructure (Category A - partial)
6. Complete projection lemmas (Category C)

### Lower Priority (Task 818 Scope)
7. Full closure membership overhaul
8. Archive Bundle approach sorries with documentation
9. Archive ConsistentSatisfiable bridge approach
10. Refactor for clean, maintainable structure

## Files Requiring Modification for Task 826

1. **Theories/Bimodal/Metalogic/FDSM/Completeness.lean**
   - Replace `fdsm_from_closure_mcs` usage with `fdsm_from_full_mcs`
   - The construction already exists, just needs wiring
   - Estimated: 30 minutes

2. **Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean**
   - Complete the `modal_saturated` case in `fdsm_from_tracked_saturation` (line 1306)
   - May need `projectTrackedHistories_modal_saturated` first (line 1273)
   - Estimated: 1-1.5 hours

## Key Dependencies

| Component | Status | Needed For |
|-----------|--------|------------|
| `MCSTrackedHistory` | Implemented (825) | Track MCS through saturation |
| `tracked_saturation_step` | Implemented (825) | One saturation round |
| `tracked_fixed_point_is_saturated` | PROVEN (825) | Modal saturation property |
| `fdsm_from_tracked_saturation` | Structure complete | Task 826 uses this |
| `projectTrackedHistories_modal_saturated` | SORRY | Blocks final modal_saturated |

## Recommendations

### For Task 826 (Immediate)
1. Focus narrowly on bridging Phase 4 to Phase 6
2. Complete `projectTrackedHistories_modal_saturated` first
3. Then fill `fdsm_from_tracked_saturation` modal_saturated
4. Update Completeness.lean to use new construction
5. Verify `fdsm_internal_completeness` still compiles

### For Task 818 (Major Refactor)
1. Archive Bundle approach (3-4 sorries) with full documentation
2. Archive ConsistentSatisfiable.lean bridge approach (6 sorries)
3. Mark FMP/SemanticCanonicalModel.lean as canonical path
4. Consider whether FDSM approach should become the main path
5. Consolidate and clean imports/dependencies

### For Sorry-Free Main Path
The existing `semantic_weak_completeness` is already sorry-free. The FDSM approach provides an alternative path that:
- Makes temporal operators finite (bounded time)
- Makes modal saturation explicit (multi-history)
- Could become the canonical construction with 826 + follow-up work

## Summary Table

| Scope | Sorries | Effort | Owner |
|-------|---------|--------|-------|
| Task 826 core | 2-3 | 2 hours | Task 826 |
| Saturation termination | 3 | 3 hours | Post-826 |
| Closure membership | 6-8 | 5 hours | Post-826 or 818 |
| Projection lemmas | 2 | 2 hours | Task 826 or post |
| Architectural blockers | 10+ | Archive | Task 818 |

**Total addressable without major refactor**: ~15 sorries with ~12 hours effort

**Architectural blockers to archive (818)**: ~10+ sorries (document and move to Boneyard)

## Next Steps

1. Begin task 826 implementation
2. Start with `projectTrackedHistories_modal_saturated`
3. Complete `fdsm_from_tracked_saturation` modal_saturated
4. Wire Completeness.lean to new construction
5. Verify build passes
6. Document remaining sorries for 818 planning
