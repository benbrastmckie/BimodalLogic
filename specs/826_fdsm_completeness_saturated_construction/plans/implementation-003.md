# Implementation Plan: Task #826

- **Task**: 826 - FDSM Completeness Saturated Construction (Revised Plan v3)
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours
- **Dependencies**: Task 825 (completed - MCSTrackedHistory infrastructure)
- **Research Inputs**: specs/826_fdsm_completeness_saturated_construction/reports/research-003.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan revises v2 based on the principle: **there are no accepted limitations, only failures requiring different approaches**. Previous plans marked certain sorries as "architectural blockers" to accept. This plan instead:

1. Documents each unsolved sorry as a **failure with potential alternative strategies**
2. Removes the concept of "accepted limitations"
3. Maintains focus on the FDSM completeness path while tracking all failures for future work

### Research Integration

From research-003.md:
- **73 total sorries** identified across Bimodal/Metalogic/
- **10 archivable** (ConsistentSatisfiable.lean: 9, FiniteStrongCompleteness.lean: 1) - Note: archival documents failure, doesn't accept it
- **~37 sorries in FDSM/** represent active implementation frontier
- **Critical path**: Archive (document failures) → TruthLemma (16) → ModalSaturation (5 core) → Completeness (3)

### Changes from v2

1. **Removed "Accepted Limitations"** - all sorries are either solved or documented as failures
2. **Reframed archival** - archiving is documenting failure (not accepting it)
3. **Added Phase 7** - Failure Analysis and Alternative Approaches documentation
4. **Updated Non-Goals** - these are "deferred failures" not "accepted limitations"

### Philosophy

Every sorry represents a failure to find a proof. Failures should be:
1. **Documented** - why the current approach doesn't work
2. **Analyzed** - what alternative approaches might succeed
3. **Tracked** - for future work to attempt different strategies

"Architectural blockers" are simply failures where the current approach is unsuitable. The architecture can be changed.

## Goals & Non-Goals

**Goals**:
- Archive ConsistentSatisfiable.lean and FiniteStrongCompleteness.lean to Boneyard/ (documenting the failure)
- Complete all 16 sorries in FDSM/TruthLemma.lean (closure membership tracking)
- Complete 5 core sorries in FDSM/ModalSaturation.lean
- Complete 3 sorries in FDSM/Completeness.lean
- Achieve sorry-free FDSM completeness path
- Document all remaining failures with analysis of alternative approaches

**Deferred Failures** (not goals of this task, but require future work):
- Bundle/TruthLemma.lean omega-rule sorries (lines 383, 395) - **Failure**: finitary system cannot express infinitary rule; **Alternative**: unbounded time model or omega-completeness
- Bundle/Construction.lean modal_backward (line 220) - **Failure**: single-family construction trivializes; **Alternative**: multi-family BMCS construction
- FMP/Closure.lean diamond_in_closureWithNeg_of_box - **Failure**: current closure definition insufficient; **Alternative**: expand closure or use different witnessing strategy

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Archive breaks imports | H | L | Verify imports before archiving; run lake build |
| Closure tracking more complex than expected | M | M | Use existing closure lemmas; document partial progress |
| MCS injection argument difficult | H | M | Research cardinality arguments; try multiple approaches |
| Saturation infrastructure sorries cascade | M | M | Complete in dependency order; isolate failures |
| Time estimate too optimistic | M | M | Structure phases for partial completion milestones |
| Current approach fundamentally unsuitable | H | L | Document failure thoroughly for alternative approach |

## Implementation Phases

### Phase 0: Archive and Document Failures [NOT STARTED]

**Goal**: Remove blocked sorries by archiving files, but document the failures for future alternative approaches

**Tasks**:
- [ ] Create `Boneyard/FMP_Bridge/` directory
- [ ] Move `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` to Boneyard
- [ ] Move `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` to Boneyard
- [ ] Create `Boneyard/FMP_Bridge/README.md` documenting:
  - Why the validity bridge approach failed
  - What alternative strategies could work (e.g., different semantic notion)
  - References to relevant research
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` to remove archived imports
- [ ] Verify `lake build` succeeds

**Timing**: 1 hour (includes thorough failure documentation)

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` - Move to Boneyard
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Move to Boneyard
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Remove imports
- `Boneyard/FMP_Bridge/README.md` - Create failure documentation

**Verification**:
- `lake build` succeeds
- Sorry count reduced by 10 (from 73 to ~63)
- Failure analysis documented in README.md

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

**Failure Protocol**: If any sorry proves intractable:
1. Document the specific failure in phase notes
2. Document what approach was tried
3. Suggest alternative strategies
4. Continue with remaining sorries

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

**Failure Protocol**: Same as Phase 1

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

**Failure Protocol**: Same as Phase 1

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
- All ModalSaturation sorries eliminated OR documented as failures
- Build succeeds
- FDSM construction complete

**Failure Protocol**: Same as Phase 1

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

**Failure Protocol**: Same as Phase 1

---

### Phase 6: Final Verification [NOT STARTED]

**Goal**: Run full build, count sorries, verify regression safety

**Tasks**:
- [ ] Run full `lake build` and capture sorry count
- [ ] Verify Bundle completeness path remains sorry-free (execution path only)
- [ ] Run any existing tests
- [ ] Update FDSM module documentation

**Timing**: 0.5 hours

**Files to modify**:
- None (verification only)

**Verification**:
- Build passes
- Sorry count reduced as expected
- No regressions in working theorems

---

### Phase 7: Failure Documentation [NOT STARTED]

**Goal**: Document all remaining failures with analysis of alternative approaches

**Tasks**:
- [ ] For each remaining sorry, create failure entry:
  - Location (file:line)
  - What approach was tried
  - Why it failed
  - Alternative strategies to attempt
- [ ] Document Bundle/TruthLemma.lean:383,395 failures (omega-rule)
  - Current approach: finitary proof system
  - Failure: cannot express infinitary rule
  - Alternatives: unbounded time semantics, omega-completeness extension, infinitary proof system
- [ ] Document Bundle/Construction.lean:220 failure (modal_backward)
  - Current approach: single-family BMCS construction
  - Failure: single family trivializes modal witnesses
  - Alternatives: multi-family BMCS, indexed bundle families
- [ ] Document FMP/Closure.lean:728 failure (diamond_in_closureWithNeg)
  - Current approach: closure = subformulas + negations
  - Failure: diamond psi may require box psi which isn't in closure
  - Alternatives: expand closure definition, different witnessing lemma
- [ ] Create implementation summary with failure tracking
- [ ] Add follow-up task recommendations for failed approaches

**Timing**: 1.5 hours

**Files to modify**:
- `specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- All remaining sorries documented with failure analysis
- Alternative approaches identified for each failure
- Summary created with actionable follow-up recommendations

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new sorries introduced
- [ ] `fdsm_internal_completeness` proof compiles sorry-free
- [ ] `semantic_weak_completeness` remains sorry-free (regression check)
- [ ] `bmcs_weak_completeness` and `bmcs_strong_completeness` remain sorry-free
- [ ] Module-level sorry count decreases as expected

## Artifacts & Outputs

- `specs/826_fdsm_completeness_saturated_construction/plans/implementation-003.md` (this file)
- `specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-YYYYMMDD.md`
- `Boneyard/FMP_Bridge/README.md` (failure documentation)
- Modified Lean files with completed proofs

## Rollback/Contingency

If implementation fails partway:
1. Git revert to last working commit
2. Mark phases as [PARTIAL] with progress notes
3. Remaining work forms follow-up tasks
4. **Document failures discovered** - this is valuable output even if proof is incomplete

If a sorry proves intractable with current approach:
1. Document the failure in detail
2. Analyze why the approach doesn't work
3. Propose alternative strategies
4. Continue with remaining phases
5. **Do NOT mark as "accepted" - it is a documented failure**

## Sorry Count Tracking

| Phase | Target Sorries | Files | Expected Change |
|-------|----------------|-------|-----------------|
| Phase 0 | 10 | ConsistentSatisfiable, FiniteStrongCompleteness | -10 (archive with failure docs) |
| Phase 1 | 8 | TruthLemma.lean | -8 (or document failures) |
| Phase 2 | 8 | TruthLemma.lean | -8 (or document failures) |
| Phase 3 | 5 | ModalSaturation.lean | -5 (or document failures) |
| Phase 4 | ~10 | ModalSaturation.lean | -10 (or document failures) |
| Phase 5 | 3 | Completeness.lean | -3 (or document failures) |
| Phase 7 | - | - | Document all remaining as failures |
| **Total** | **~44** | | **-44 (with failure docs for any unsolved)** |

## Documented Failures (To Be Populated)

This section will be populated in Phase 7 with any sorries that remain unsolved:

### Bundle/TruthLemma.lean:383,395 (Omega-Rule)
- **Status**: Deferred failure
- **Current approach**: Finitary proof system with bounded time
- **Why it fails**: All_future/all_past require checking infinitely many time points
- **Alternative strategies to attempt**:
  1. Unbounded time model with omega-completeness
  2. Infinitary proof system extension
  3. Approximation via finite unrolling with soundness preservation

### Bundle/Construction.lean:220 (Modal Backward)
- **Status**: Deferred failure
- **Current approach**: Single-family BMCS construction
- **Why it fails**: Single family means all histories from same MCS, trivializing modal witnesses
- **Alternative strategies to attempt**:
  1. Multi-family BMCS construction (like FDSM multi-history)
  2. Indexed bundle families parameterized by MCS
  3. Different semantics that doesn't require backward modal implication

### FMP/Closure.lean:728 (Diamond in Closure)
- **Status**: Deferred failure
- **Current approach**: Closure defined as subformulas + negations
- **Why it fails**: Diamond psi membership doesn't ensure Box psi in closure
- **Alternative strategies to attempt**:
  1. Expand closure to include modal duals
  2. Different witnessing strategy not requiring closure membership
  3. Relativized closure per operator type

## Dependencies Between Phases

```
Phase 0 (Archive + Document Failures)
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
                                                      +---> Phase 6 (Verification)
                                                                |
                                                                +---> Phase 7 (Failure Documentation)
```

All phases are sequential - each depends on the previous phase's completion.

## Progress from v2

This plan supersedes implementation-002.md. Key changes:

| Aspect | v2 | v3 |
|--------|----|----|
| Philosophy | "Accept limitations" | "Document failures" |
| Omega-rule sorries | Accepted as limitation | Documented failure with alternatives |
| modal_backward | Architectural assumption | Documented failure with alternatives |
| diamond_in_closure | Unprovable | Documented failure with alternatives |
| Phase 6 | Documentation + accepted limitations | Final verification only |
| Phase 7 | (none) | NEW: Failure documentation + alternatives |

**Every sorry is either solved or documented as a failure with alternative approaches.**
