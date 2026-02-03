# Implementation Plan: Task #826

- **Task**: 826 - FDSM Completeness Saturated Construction (Revised Plan v2)
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: Task 825 (completed - MCSTrackedHistory infrastructure)
- **Research Inputs**: specs/826_fdsm_completeness_saturated_construction/reports/research-003.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan incorporates research-003.md findings to complete remaining sorries that cannot be archived. The key insight from research is that **archival should happen first** to eliminate 10 blocked sorries, followed by systematic completion of the FDSM path. The previous plan (v1) had Phase 2 blocked and Phase 3 partial - this revision restructures to reflect the archive-first strategy and updated sorry inventory.

### Research Integration

From research-003.md:
- **73 total sorries** identified across Bimodal/Metalogic/
- **10 archivable** (ConsistentSatisfiable.lean: 9, FiniteStrongCompleteness.lean: 1)
- **3 fundamentally blocked** (omega-rule limitations in Bundle/) - accept as-is
- **~37 sorries in FDSM/** represent active implementation frontier
- **Critical path**: Archive -> TruthLemma (16) -> ModalSaturation (5 core) -> Completeness (3)

### Changes from v1

1. Added Phase 0 (Archive) at the start
2. Removed Phase 2 (FMP/Closure sorry - architecturally unprovable per v1 analysis)
3. Removed Phase 7 (FiniteStrongCompleteness - moves to Boneyard)
4. Consolidated remaining phases based on dependency analysis

## Goals & Non-Goals

**Goals**:
- Archive ConsistentSatisfiable.lean and FiniteStrongCompleteness.lean to Boneyard/
- Complete all 16 sorries in FDSM/TruthLemma.lean (closure membership tracking)
- Complete 5 core sorries in FDSM/ModalSaturation.lean
- Complete 3 sorries in FDSM/Completeness.lean
- Achieve sorry-free FDSM completeness path
- Document accepted limitations

**Non-Goals**:
- Fix omega-rule limitations in Bundle/TruthLemma.lean (fundamentally blocked)
- Fix modal_backward in Bundle/Construction.lean (architectural assumption)
- Modify SemanticCanonicalModel.lean (already sorry-free)
- Fix diamond_in_closureWithNeg_of_box (proven unprovable in v1)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Archive breaks imports | H | L | Verify imports before archiving; run lake build |
| Closure tracking more complex than expected | M | M | Use existing closure lemmas; accept partial if needed |
| MCS injection argument difficult | H | M | Research cardinality arguments; try multiple approaches |
| Saturation infrastructure sorries cascade | M | M | Complete in dependency order; isolate failures |
| Time estimate too optimistic | M | M | Structure phases for partial completion milestones |

## Implementation Phases

### Phase 0: Archive Blocked Files [NOT STARTED]

**Goal**: Remove 10 blocked sorries by archiving files with unsolvable validity bridge issues

**Tasks**:
- [ ] Create `Boneyard/FMP_Bridge/` directory
- [ ] Move `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` to Boneyard
- [ ] Move `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` to Boneyard
- [ ] Create `Boneyard/FMP_Bridge/README.md` documenting archival rationale
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` to remove archived imports
- [ ] Verify `lake build` succeeds

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` - Move to Boneyard
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Move to Boneyard
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Remove imports

**Verification**:
- `lake build` succeeds
- Sorry count reduced by 10 (from 73 to ~63)
- No compilation errors in dependent files

---

### Phase 1: FDSM TruthLemma Core Cases [NOT STARTED]

**Goal**: Complete the first 8 sorries in TruthLemma.lean (atomic, negation, conjunction cases)

**Tasks**:
- [ ] Complete line 76 sorry (closure membership in definition)
- [ ] Complete line 119 sorry (base case closure alignment)
- [ ] Complete lines 126-127 sorries (inductive hypothesis closure bounds)
- [ ] Complete line 133 sorry (conjunction closure handling)
- [ ] Complete line 160 sorry (closure membership alignment)
- [ ] Complete line 163 sorry (closure membership alignment)
- [ ] Use existing `closure_imp_left`, `closure_imp_right` lemmas

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean` - Complete 8 sorries

**Verification**:
- Build succeeds for TruthLemma.lean
- First 8 sorries eliminated
- Closure membership properly threaded

---

### Phase 2: FDSM TruthLemma Modal/Temporal Cases [NOT STARTED]

**Goal**: Complete the remaining 8 sorries in TruthLemma.lean (box, diamond, temporal cases)

**Tasks**:
- [ ] Complete line 184 sorry (box case closure membership)
- [ ] Complete line 187 sorry (diamond case closure membership)
- [ ] Complete line 195 sorry (all_future case)
- [ ] Complete line 200 sorry (some_future case)
- [ ] Complete line 208 sorry (all_past case)
- [ ] Complete line 214 sorry (some_past case)
- [ ] Complete lines 221, 225 sorries (remaining cases)
- [ ] Use `closure_box`, `closure_all_future`, `closure_all_past` lemmas

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean` - Complete remaining 8 sorries

**Verification**:
- `fdsm_truth_lemma` is sorry-free
- Build succeeds for TruthLemma.lean
- All 16 TruthLemma sorries eliminated

---

### Phase 3: Modal Saturation Core Proofs [NOT STARTED]

**Goal**: Complete the 5 core sorries in ModalSaturation.lean

**Tasks**:
- [ ] Complete `mcsTrackedHistory_finite` (line ~982) - finite injection argument
- [ ] Complete `fixed_point_is_saturated` (line ~852) - contrapositive on fixed point
- [ ] Complete `saturated_histories_saturated` (line ~905) - composition of saturation
- [ ] Complete `modal_backward_from_saturation` (line ~374) - uses truth lemma
- [ ] Complete `tracked_saturated_histories_saturated` (line ~1361) - main theorem

**Dependencies**: Requires Phase 2 completion (truth lemma)

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Complete 5 core sorries

**Verification**:
- Core saturation theorems sorry-free
- Build succeeds
- Tracked saturation infrastructure working

---

### Phase 4: Modal Saturation Infrastructure [NOT STARTED]

**Goal**: Complete the remaining ~10 infrastructure sorries that depend on core proofs

**Tasks**:
- [ ] Complete `projectTrackedHistories_modal_saturated` (line ~1432)
- [ ] Complete `fdsm_from_tracked_saturation.modal_saturated` (line ~1465)
- [ ] Complete remaining termination-related sorries
- [ ] Complete projection lemmas for tracked histories

**Dependencies**: Requires Phase 3 completion

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Complete infrastructure sorries

**Verification**:
- All ModalSaturation sorries eliminated (or documented as blocked)
- Build succeeds
- FDSM construction complete

---

### Phase 5: FDSM Completeness Integration [NOT STARTED]

**Goal**: Complete the 3 sorries in Completeness.lean and wire up the construction

**Tasks**:
- [ ] Complete `modal_saturated` case in `fdsm_from_closure_mcs` (line 106)
- [ ] Complete `fdsm_mcs_implies_truth` (line 168)
- [ ] Complete `fdsm_mcs_neg_implies_false` (line 187)
- [ ] Verify `fdsm_internal_completeness` compiles sorry-free
- [ ] Update Metalogic.lean to export FDSM completeness

**Dependencies**: Requires Phase 4 completion

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` - Complete 3 sorries
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Update exports

**Verification**:
- `fdsm_internal_completeness` is sorry-free
- Build succeeds
- FDSM completeness path operational

---

### Phase 6: Documentation and Final Verification [NOT STARTED]

**Goal**: Document limitations, verify sorry count, and create summary

**Tasks**:
- [ ] Run full `lake build` and capture sorry count
- [ ] Document accepted limitations in module docstrings:
  - Bundle/TruthLemma.lean omega-rule sorries (lines 383, 395)
  - Bundle/Construction.lean modal_backward (line 220)
  - FMP/Closure.lean diamond_in_closureWithNeg_of_box (architecturally blocked)
- [ ] Verify Bundle completeness path remains sorry-free (execution path only)
- [ ] Update FDSM module documentation
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Add limitation docstring
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Add limitation docstring
- `specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- Sorry count documented (target: reduce by 25-30 from current)
- All remaining sorries documented with reasons
- Build passes
- Implementation summary created

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new sorries introduced
- [ ] `fdsm_internal_completeness` proof compiles sorry-free
- [ ] `semantic_weak_completeness` remains sorry-free (regression check)
- [ ] `bmcs_weak_completeness` and `bmcs_strong_completeness` remain sorry-free
- [ ] Module-level sorry count decreases as expected

## Artifacts & Outputs

- `specs/826_fdsm_completeness_saturated_construction/plans/implementation-002.md` (this file)
- `specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-YYYYMMDD.md`
- `Boneyard/FMP_Bridge/README.md` (archival documentation)
- Modified Lean files with completed proofs

## Rollback/Contingency

If implementation fails partway:
1. Git revert to last working commit
2. Mark phases as [PARTIAL] with progress notes
3. Remaining work forms follow-up tasks
4. Document blockers discovered

If a sorry proves architecturally blocked:
1. Document the limitation in the plan file
2. Add to accepted limitations list
3. Continue with remaining phases
4. Update final sorry count expectations

## Sorry Count Tracking

| Phase | Target Sorries | Files | Expected Reduction |
|-------|----------------|-------|-------------------|
| Phase 0 | 10 | ConsistentSatisfiable, FiniteStrongCompleteness | -10 (archive) |
| Phase 1 | 8 | TruthLemma.lean | -8 |
| Phase 2 | 8 | TruthLemma.lean | -8 |
| Phase 3 | 5 | ModalSaturation.lean | -5 |
| Phase 4 | ~10 | ModalSaturation.lean | -10 |
| Phase 5 | 3 | Completeness.lean | -3 |
| **Total** | **~44** | | **-44** |

**Accepted Limitations** (not counted as reduction):
- Bundle/TruthLemma.lean: 2 (omega-rule)
- Bundle/Construction.lean: 1 (architectural)
- FMP/Closure.lean: 1 (unprovable)

## Dependencies Between Phases

```
Phase 0 (Archive)
    |
    +---> Phase 1 (TruthLemma Core)
              |
              +---> Phase 2 (TruthLemma Modal/Temporal)
                        |
                        +---> Phase 3 (ModalSaturation Core)
                                  |
                                  +---> Phase 4 (ModalSaturation Infrastructure)
                                            |
                                            +---> Phase 5 (Completeness Integration)
                                                      |
                                                      +---> Phase 6 (Documentation)
```

All phases are sequential - each depends on the previous phase's completion.

## Progress from v1

This plan supersedes implementation-001.md. Status of v1 phases:
- v1 Phase 1: [COMPLETED] - Core.lean sorry resolved
- v1 Phase 2: [BLOCKED] - FMP/Closure sorry unprovable (not in this plan)
- v1 Phase 3: [PARTIAL] - 4 of 12 done (incorporated into Phases 3-4)
- v1 Phases 4-8: [NOT STARTED] - Restructured into Phases 1-6
