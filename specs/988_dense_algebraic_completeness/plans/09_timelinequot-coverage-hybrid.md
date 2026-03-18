# Implementation Plan: Task #988

- **Task**: 988 - dense_algebraic_completeness
- **Version**: 9 (revised from v8 based on density gap discovery)
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: Task 982 (completed)
- **Research Inputs**: specs/988_dense_algebraic_completeness/handoffs/02_density-gap-analysis.md
- **Artifacts**: plans/09_timelinequot-coverage-hybrid.md (this file)
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v8 discovered that DovetailedBuild provides **coverage** (forward_F/backward_P via dovetailing) but NOT **pair-wise density** (needed for DenselyOrdered). This plan combines both constructions:

- **DenseTimeline/TimelineQuot**: Provides `DenselyOrdered` (via `densityWitnessesForSet`)
- **DovetailedCoverage**: Provides `forward_F`/`backward_P` (via dovetailing)

### Key Insight: The Bridge Already Exists

`TimelineQuotCanonical.lean` contains:
- `timelineQuot_lt_implies_canonicalR`: t < t' → CanonicalR (mcs t) (mcs t')
- `canonicalR_implies_timelineQuot_le`: CanonicalR (mcs t) (mcs t') → t ≤ t'

This means DovetailedCoverage's CanonicalR-based witnesses can be lifted to TimelineQuot `<` order directly.

### What v8 Built (Preserved)

- `DovetailedFMCS.lean`: FMCS construction with forward_G, backward_H (sorry-free)
- `DovetailedTimelineQuot.lean`: Partially useful (NoMaxOrder, NoMinOrder work; DenselyOrdered has sorry)

### Resolution Strategy

Fill `timelineQuot_not_valid_of_neg_consistent` by:
1. Using TimelineQuot for DenselyOrdered (already proven)
2. Using DovetailedCoverage for forward_F/backward_P (via TimelineQuotCanonical bridge)
3. Building truth lemma over TimelineQuot directly

## Goals & Non-Goals

**Goals**:
- Fill `timelineQuot_not_valid_of_neg_consistent` in TimelineQuotCompleteness.lean
- Achieve `dovetailed_dense_completeness` with no sorries
- Clean `lake build Bimodal` with no new axioms
- Reuse DovetailedCoverage's sorry-free coverage lemmas

**Non-Goals**:
- Fixing DovetailedTimelineQuot density sorry (abandoned - density comes from DenseTimeline)
- Creating a third construction that combines both (too complex)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bridge lemmas don't compose cleanly | Medium | Low | Already proven in TimelineQuotCanonical |
| Truth lemma over TimelineQuot complex | Medium | Medium | ParametricTruthLemma provides template |
| DovetailedCoverage witnesses not in TimelineQuot | Medium | Low | Both constructions build from same root; witnesses exist |
| Instance unification issues | Medium | Medium | letI/haveI pattern established |

## Implementation Phases

### Phase 1: TimelineQuot Forward_F/Backward_P via DovetailedCoverage [NOT STARTED]

**Goal**: Prove forward_F and backward_P for TimelineQuot using DovetailedCoverage bridge

**Tasks**:
- [ ] Prove `timelineQuotFMCS_forward_F` using `dovetailedTimeline_has_future` + bridge
- [ ] Prove `timelineQuotFMCS_backward_P` using `dovetailedTimeline_has_past` + bridge
- [ ] Verify these replace the sorries in ClosureSaturation.lean lines 658-679
- [ ] Create helper lemmas connecting DovetailedCoverage witnesses to TimelineQuot

**Key Insight**: The dovetailed timeline and dense timeline both build from the same root MCS via CanonicalR chains. A witness that exists in the dovetailed timeline also exists in the dense timeline (they're not disjoint sets - the dovetailed construction is more thorough in coverage, dense is more thorough in density).

**Timing**: 5 hours

**Files to modify**:
- Modify: `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- Create: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCoverageWiring.lean` (optional helper)

**Key Lemma**:
```lean
/-- DovetailedCoverage witnesses lift to TimelineQuot -/
theorem dovetailed_forward_F_to_timelineQuot
    (t : TimelineQuot root_mcs root_mcs_proof)
    (phi : Formula) (h_F : Formula.some_future phi ∈ timelineQuotMCS t) :
    ∃ s : TimelineQuot root_mcs root_mcs_proof, t < s ∧ phi ∈ timelineQuotMCS s := by
  -- Extract DovetailedPoint from TimelineQuot representative
  -- Apply dovetailedTimeline_has_future
  -- Use timelineQuot_lt_implies_canonicalR for the order direction
  sorry -- To be filled
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.ClosureSaturation` with no sorries on forward_F/backward_P
- `grep -c sorry ClosureSaturation.lean` decreases by 2

---

### Phase 2: Truth Lemma Infrastructure [NOT STARTED]

**Goal**: Build truth lemma over TimelineQuot

**Tasks**:
- [ ] Define TaskFrame over TimelineQuot using existing `ParametricCanonicalTaskFrame` pattern
- [ ] Define TaskModel with MCS valuation using `timelineQuotMCS`
- [ ] Define shift-closed Omega set using `ShiftClosedParametricCanonicalOmega` template
- [ ] Prove forward direction: φ ∈ mcs t → truth_at
- [ ] Prove backward direction: truth_at → φ ∈ mcs t

**Timing**: 6 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean`

**Key Structure**:
```lean
/-- Truth lemma for TimelineQuot -/
theorem timelineQuot_truth_lemma
    (fam : TimelineQuotFMCS root_mcs root_mcs_proof)
    (t : TimelineQuot root_mcs root_mcs_proof)
    (φ : Formula) :
    φ ∈ fam.mcs t ↔ truth_at TimelineQuotTaskModel Omega (fam_to_history fam) t φ
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotTruthLemma` succeeds
- `lean_verify` on `timelineQuot_truth_lemma`

---

### Phase 3: Fill timelineQuot_not_valid_of_neg_consistent [NOT STARTED]

**Goal**: Complete the main sorry in TimelineQuotCompleteness.lean

**Tasks**:
- [ ] Import TimelineQuotTruthLemma
- [ ] Apply truth lemma: φ.neg ∈ root MCS → ¬truth_at ... φ
- [ ] Construct countermodel using TimelineQuotFMCS
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` proof

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**Key Proof**:
```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (φ : Formula) (h_cons : ContextConsistent [φ.neg]) :
    ... ¬valid_over D φ := by
  -- Build countermodel from TimelineQuotFMCS
  -- φ.neg ∈ root MCS (by Lindenbaum)
  -- Apply truth lemma: φ.neg true at root → φ false at root
  -- Countermodel witness constructed
```

**Verification**:
- `grep -c sorry TimelineQuotCompleteness.lean` returns 0
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness` succeeds

---

### Phase 4: Wire Dense Completeness Theorem [NOT STARTED]

**Goal**: Verify final dense completeness theorem

**Tasks**:
- [ ] Verify `dovetailed_dense_completeness` in DovetailedCompleteness.lean has no sorries
- [ ] Verify `dense_completeness_theorem` in TimelineQuotCompleteness.lean has no sorries
- [ ] Verify full `lake build Bimodal` succeeds
- [ ] Count total sorries in Theories/ - should decrease
- [ ] Create completion summary

**Timing**: 2 hours

**Files to verify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCompleteness.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**Verification**:
- `lake build Bimodal` succeeds with no errors
- `grep -rn sorry Theories/Bimodal/Metalogic/StagedConstruction/` shows reduction
- No new axioms introduced

## Testing & Validation

- [ ] Each phase builds independently
- [ ] `lake build Bimodal` succeeds after all phases
- [ ] `timelineQuot_not_valid_of_neg_consistent` has no sorry
- [ ] `dovetailed_dense_completeness` has no sorry
- [ ] Sorry count in `Theories/Bimodal/Metalogic/StagedConstruction/` decreases
- [ ] No new axioms introduced

## Artifacts & Outputs

- Modified `ClosureSaturation.lean` with forward_F/backward_P proofs (Phase 1)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean` (Phase 2)
- Modified `TimelineQuotCompleteness.lean` with filled sorry (Phase 3)
- `specs/988_dense_algebraic_completeness/summaries/04_completion-summary.md`

## Reusable Work from v8

The following files from v8 remain potentially useful:
- `DovetailedFMCS.lean`: Forward_G, backward_H proofs (FMCS core structure)
- `DovetailedTimelineQuot.lean`: NoMaxOrder/NoMinOrder proofs (DenselyOrdered sorry is now irrelevant)

These may inform the Phase 1 approach even if not directly imported.

## Comparison with Previous Plans

| Aspect | Plan v8 | Plan v9 (this) |
|--------|---------|----------------|
| Primary domain | DovetailedTimelineQuot | TimelineQuot |
| DenselyOrdered source | DovetailedBuild (FAILED) | DenseTimeline (proven) |
| Coverage source | DovetailedCoverage | DovetailedCoverage |
| Bridge needed | No | Yes (but already exists) |
| Estimated effort | 19h | 16h |
| Blocker | Density gap | None identified |

## Rollback/Contingency

If the TimelineQuot approach proves intractable:

**Fallback**: Add pair-wise density to DovetailedBuild
- Modify DovetailedBuild.lean to add `processPairwiseDensityDovetailed`
- Similar to DenseTimeline's `densityWitnessesForSet`
- Estimated additional effort: 8-10 hours

**Revert Changes**:
- ClosureSaturation.lean changes can be reverted via git
- New files can be deleted
- No destructive changes to existing working code
