# Implementation Plan: Task #826

- **Task**: 826 - FDSM Completeness Saturated Construction (Expanded Scope)
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours
- **Dependencies**: Task 825 (completed - MCSTrackedHistory infrastructure)
- **Research Inputs**: specs/826_fdsm_completeness_saturated_construction/reports/research-001.md, specs/818_refactor_bimodal_metalogic_modules/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the remaining sorries required for a sorry-free FDSM metalogic path, with explicit exclusion of architectural blockers that belong in task 818's Boneyard archival. The scope is expanded from the original task 826 description to cover all addressable sorries in the FDSM, FMP/Closure, and Completeness modules - totaling approximately 27 sorries across 5 files.

### Research Integration

The task 826 and task 818 research reports identify:
- **31 total sorries** in active metalogic code
- **27 addressable sorries** (this plan)
- **10+ architectural blockers** to archive in task 818 (NOT this plan)

### Exclusions (Boneyard Candidates for Task 818)

The following sorries are **NOT addressed** in this plan because they are architecturally blocked:

| Sorry Location | Count | Reason for Exclusion |
|----------------|-------|---------------------|
| Bundle/Construction.lean `modal_backward` | 1 | Single-family BMCS trivializes modal semantics |
| Bundle/TruthLemma.lean temporal backward | 2 | Omega-rule limitation in finitary system |
| FMP/ConsistentSatisfiable.lean | 6 | General validity != FMP validity bridge blocked |
| Deprecated single-history saturation | ~4 | Replaced by MCSTrackedHistory approach |

These will be documented and archived to Boneyard/ in task 818.

## Goals & Non-Goals

**Goals**:
- Complete all addressable sorries in FDSM module (24 sorries)
- Complete diamond_in_closureWithNeg_of_box in FMP/Closure.lean (1 sorry)
- Complete validity bridge in Completeness/FiniteStrongCompleteness.lean (1 sorry)
- Replace fdsm_from_closure_mcs usage with fdsm_from_full_mcs in completeness path
- Verify build passes with reduced sorry count

**Non-Goals**:
- Fix architectural blockers (task 818 scope)
- Modify Bundle/ module (working sorry-free core path)
- Archive deprecated code (task 818 scope)
- Modify SemanticCanonicalModel.lean (already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure membership infrastructure too complex | H | M | Start with infrastructure phase; can pivot to dependent types |
| Saturation termination requires classical argument | M | M | Use Lean's classical tactics; document approach |
| Projection lemmas need MCS tracing | M | L | MCSTrackedHistory has derived_from_mcs field |
| Truth lemma sorries have hidden dependencies | H | L | Address in logical order (forward before backward) |
| Time estimate too optimistic | M | M | Structure phases for partial completion; can stop at milestones |

## Implementation Phases

### Phase 1: Closure Membership Infrastructure [NOT STARTED]

**Goal**: Establish the closure membership lemmas needed by TruthLemma.lean and Core.lean sorries

**Tasks**:
- [ ] Add `closure_neg_mem_of_mem` lemma: `psi ∈ closure phi → psi.neg ∈ closure phi`
- [ ] Add `closure_subformula_mem` lemmas for Box, Diamond, G, H operators
- [ ] Add `closure_binary_mem` lemmas for And, Or, Impl
- [ ] Create `ClosureMembership.lean` module if needed for organization
- [ ] Complete Core.lean line 205 sorry (closure membership in modal_saturated)

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Add closure membership lemmas
- `Theories/Bimodal/Metalogic/FDSM/Core.lean` - Fix line 205 sorry

**Verification**:
- `lake build Theories/Bimodal/Metalogic/FMP/Closure.lean` succeeds
- `lake build Theories/Bimodal/Metalogic/FDSM/Core.lean` succeeds with 0 sorries

---

### Phase 2: FMP/Closure.lean Sorry [NOT STARTED]

**Goal**: Complete the diamond_in_closureWithNeg_of_box lemma

**Tasks**:
- [ ] Analyze `diamond_in_closureWithNeg_of_box` at line 728
- [ ] Use closure membership lemmas from Phase 1
- [ ] Complete the proof (likely uses closure_neg_mem and diamond_neg_iff_neg_box)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Complete line 728 sorry

**Verification**:
- `lake build Theories/Bimodal/Metalogic/FMP/Closure.lean` succeeds with 0 sorries

---

### Phase 3: Modal Saturation Fixed-Point Proofs [NOT STARTED]

**Goal**: Complete the saturation termination and fixed-point theorems in ModalSaturation.lean

**Tasks**:
- [ ] Complete `neg_box_iff_diamond_neg` (line 309) - classical equivalence
- [ ] Complete `saturation_terminates` (line 728) - cardinality-based termination
- [ ] Complete `fixed_point_is_saturated` (lines 803, 815) - fixed point property
- [ ] Complete `modal_backward_from_saturation` (line 877) - modal backward direction
- [ ] Complete `tracked_saturated_histories_saturated` (line 1211) - tracked version

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Complete 6 sorries

**Verification**:
- `lean_goal` at each sorry location shows "no goals" after fix
- `lake build Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` shows reduced sorry count

---

### Phase 4: Projection Lemmas [NOT STARTED]

**Goal**: Complete the projection lemmas connecting tracked histories to modal saturation

**Tasks**:
- [ ] Analyze `projectTrackedHistories_modal_saturated` (line 1273)
- [ ] Use `derived_from_mcs` field to trace MCS membership
- [ ] Complete `fdsm_from_tracked_saturation` modal_saturated case (line 1306)
- [ ] Verify projection preserves saturation property

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Complete lines 1273, 1306

**Verification**:
- `lake build Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` succeeds with 0 new sorries in tracked section

---

### Phase 5: Truth Lemma Closure Membership [NOT STARTED]

**Goal**: Complete the 12+ sorries in TruthLemma.lean for closure membership tracking

**Tasks**:
- [ ] Complete line 76 sorry (closure membership in definition)
- [ ] Complete line 119 sorry (base case closure alignment)
- [ ] Complete lines 126-127 sorries (inductive hypothesis closure bounds)
- [ ] Complete line 133 sorry (conjunction closure handling)
- [ ] Complete lines 160, 163 sorries (closure membership alignment)
- [ ] Complete lines 184, 187, 195, 200, 208, 214, 221, 225 sorries (case-by-case)

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean` - Complete 14 sorries

**Verification**:
- `lake build Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean` succeeds with 0 sorries
- Truth lemma (fdsm_truth_lemma) is sorry-free

---

### Phase 6: Completeness Bridge Lemmas [NOT STARTED]

**Goal**: Complete the bridge lemmas in Completeness.lean and wire up the new construction

**Tasks**:
- [ ] Complete `modal_saturated` case in `fdsm_from_closure_mcs` (line 106)
- [ ] Complete `fdsm_mcs_implies_truth` (line 168)
- [ ] Complete `fdsm_mcs_neg_implies_false` (line 187)
- [ ] Update completeness proof to prefer `fdsm_from_full_mcs` where MCS is available
- [ ] Verify `fdsm_internal_completeness` compiles

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` - Complete 3 sorries, update wiring

**Verification**:
- `lake build Theories/Bimodal/Metalogic/FDSM/Completeness.lean` succeeds with 0 sorries
- `fdsm_internal_completeness` is sorry-free

---

### Phase 7: Validity Bridge (FiniteStrongCompleteness) [NOT STARTED]

**Goal**: Complete the validity bridge from general validity to FMP-internal validity

**Tasks**:
- [ ] Analyze line 130 sorry in FiniteStrongCompleteness.lean
- [ ] Determine if this is addressable or architecturally blocked
- [ ] If addressable: complete the proof using FDSM construction
- [ ] If blocked: document and mark for task 818 archival

**Note**: This sorry may be architecturally blocked like ConsistentSatisfiable. Investigation in this phase will determine.

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Attempt line 130

**Verification**:
- Build succeeds
- Document outcome (fixed or marked for 818)

---

### Phase 8: Final Verification and Audit [NOT STARTED]

**Goal**: Verify all targeted sorries are resolved and document remaining work

**Tasks**:
- [ ] Run full `lake build` and capture output
- [ ] Grep for remaining sorries in FDSM/, Completeness/, FMP/Closure.lean
- [ ] Document any sorries that could not be resolved
- [ ] Update module documentation with sorry status
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- Various module docstrings
- `specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- Total sorry count reduced from 27 to target (0 ideal, <5 acceptable)
- All remaining sorries documented with reasons
- Build passes

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new sorries introduced
- [ ] `fdsm_internal_completeness` proof compiles
- [ ] `semantic_weak_completeness` remains sorry-free (regression check)
- [ ] Module-level grep shows expected sorry count

## Artifacts & Outputs

- `specs/826_fdsm_completeness_saturated_construction/plans/implementation-001.md` (this file)
- `specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-YYYYMMDD.md`
- Modified Lean files with completed proofs

## Rollback/Contingency

If implementation fails partway:
1. Git revert to last working commit
2. Mark phases as [PARTIAL] with progress notes
3. Remaining work forms follow-up tasks
4. Document blockers discovered for task 818 planning

If a phase proves architecturally blocked:
1. Document the limitation in the plan file
2. Mark as candidate for task 818 Boneyard
3. Continue with remaining phases
4. Update final sorry count expectations

## Sorry Count Tracking

| Phase | Target | Files | Expected Reduction |
|-------|--------|-------|-------------------|
| Phase 1 | 1 | Core.lean | 1 |
| Phase 2 | 1 | Closure.lean | 1 |
| Phase 3 | 6 | ModalSaturation.lean | 6 |
| Phase 4 | 2 | ModalSaturation.lean | 2 |
| Phase 5 | 14 | TruthLemma.lean | 14 |
| Phase 6 | 3 | Completeness.lean | 3 |
| Phase 7 | 1 | FiniteStrongCompleteness.lean | 0-1 (may be blocked) |
| **Total** | **28** | | **27-28** |

## Dependencies Between Phases

```
Phase 1 (Closure Infrastructure)
    |
    +---> Phase 2 (FMP/Closure sorry)
    |
    +---> Phase 5 (TruthLemma sorries)

Phase 3 (Saturation proofs)
    |
    +---> Phase 4 (Projection lemmas)
           |
           +---> Phase 6 (Completeness bridge)

Phase 6 + Phase 5
    |
    +---> Phase 7 (Validity bridge)
           |
           +---> Phase 8 (Final audit)
```

Phases 1-2 and Phases 3-4 can proceed in parallel.
Phase 5 depends on Phase 1.
Phase 6 depends on Phases 4 and 5.
Phase 7 depends on Phase 6.
Phase 8 depends on all others.
