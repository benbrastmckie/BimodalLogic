# Implementation Plan: Task #988

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 982 (completed), Task 995 (completed)
- **Research Inputs**: specs/988_dense_algebraic_completeness/reports/09_fmcs-transfer-unblock.md
- **Artifacts**: plans/10_dovetailed-timelinequot-bridge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Version**: 10 (revised based on FMCSTransfer analysis)

## Overview

Research report 09 revealed that FMCSTransfer from Task 995 cannot be directly applied to D = Rat because CanonicalMCS has incomparable elements (non-total order) while Rat is totally ordered. The recommended path bypasses FMCSTransfer entirely and instead connects DovetailedCoverage's sorry-free `has_future`/`has_past` lemmas directly to the ratFMCS construction via TimelineQuot bridges.

### Research Integration

Key findings from 09_fmcs-transfer-unblock.md:
- FMCSTransfer requires order isomorphism between source and target domains
- CanonicalMCS is NOT totally ordered (many MCS are incomparable)
- TimelineQuot ≃o Rat exists via Cantor isomorphism (CantorApplication.lean)
- DovetailedCoverage provides `dovetailedTimeline_has_future/has_past` (sorry-free)
- The bridge lemmas in TimelineQuotCanonical.lean already exist

### Why Previous Plans Failed

| Plan | Blocker |
|------|---------|
| v4, v6 | CanonicalMCS lacks AddCommGroup |
| v8 | DovetailedTimelineQuot density sorry (DenselyOrdered blocked) |
| v9 | TimelineQuot-DovetailedCoverage bridge architectural gap |

### Key Insight: Direct Truth Lemma Path

Rather than bridging two constructions, we observe that:
1. TimelineQuot already has DenselyOrdered, NoMaxOrder, NoMinOrder (proven)
2. The missing pieces are forward_F/backward_P for `timelineQuotFMCS`
3. DovetailedCoverage provides witnesses for F/P-demands
4. The truth lemma can be built directly over TimelineQuot once forward_F/backward_P are filled

The approach: Fill the TimelineQuot forward_F/backward_P by showing that DovetailedCoverage witnesses exist in the same MCS-reachable set as TimelineQuot elements.

## Goals & Non-Goals

**Goals**:
- Fill `ratFMCS_forward_F` and `ratFMCS_backward_P` sorries in CanonicalEmbedding.lean
- Fill `timelineQuot_not_valid_of_neg_consistent` sorry in TimelineQuotCompleteness.lean
- Achieve sorry-free `dovetailed_dense_completeness` theorem
- Clean `lake build Bimodal` with no new axioms
- Wire `construct_bfmcs_rat` to `dense_representation_conditional`

**Non-Goals**:
- Using FMCSTransfer for D = Rat (architecturally blocked)
- Creating DovetailedTimelineQuot with DenselyOrdered (too complex)
- Modifying the FMCSTransfer design (it works for its intended purpose)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dovetailed witnesses not in TimelineQuot | High | Medium | Both constructions build from same root MCS; prove set equality or subset |
| Truth lemma over TimelineQuot complex | Medium | Medium | Use ParametricTruthLemma template |
| Modal coherence for singleton BFMCS | Medium | Low | T-axiom closure already in MCS properties |
| Instance unification issues | Low | Medium | letI/haveI pattern established |

## Implementation Phases

### Phase 1: DovetailedCoverage to TimelineQuot Connection [BLOCKED]

**Goal**: Prove that DovetailedCoverage witnesses exist in the TimelineQuot construction

**Tasks**:
- [ ] Analyze set relationship: `dovetailedTimelineUnion` vs `denseTimelineUnion`
- [ ] Prove lemma: DovetailedPoint in timeline -> exists equivalent DenseTimelineElem
- [ ] Or prove: Forward/backward witnesses for TimelineQuot MCS exist in timeline
- [ ] Create `TimelineQuotForwardF.lean` module for connection lemmas

**Key Insight**: Both constructions start from the same `root_mcs` and build via Lindenbaum extensions with CanonicalR chains. The dovetailed construction processes F/P-demands explicitly (via formula encoding), while the staged construction processes demands less systematically. The question is whether F/P witnesses end up in both.

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotForwardF.lean`

**Key Lemma**:
```lean
/-- If F(phi) in timelineQuotMCS(t), there exists t' > t with phi in timelineQuotMCS(t') -/
theorem timelineQuot_forward_F
    (t : TimelineQuot root_mcs root_mcs_proof) (phi : Formula)
    (h_F : Formula.some_future phi ∈ timelineQuotMCS root_mcs root_mcs_proof t) :
    ∃ t' : TimelineQuot root_mcs root_mcs_proof, t < t' ∧
      phi ∈ timelineQuotMCS root_mcs root_mcs_proof t'
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotForwardF`
- No `sorry` in forward_F proof

---

### Phase 2: Fill ratFMCS Forward_F/Backward_P [NOT STARTED]

**Goal**: Remove sorries from CanonicalEmbedding.lean using TimelineQuot connection

**Tasks**:
- [ ] Import TimelineQuotForwardF.lean into CanonicalEmbedding.lean
- [ ] Fill `ratFMCS_forward_F` using `timelineQuot_forward_F` + Cantor isomorphism
- [ ] Fill `ratFMCS_backward_P` using `timelineQuot_backward_P` + Cantor isomorphism
- [ ] Verify `ratFMCS` compiles with no sorry

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`

**Key Pattern**:
```lean
theorem ratFMCS_forward_F (q : ℚ) (phi : Formula)
    (h_F : Formula.some_future phi ∈ ratMCS root_mcs root_mcs_proof q) :
    ∃ q' : ℚ, q < q' ∧ phi ∈ ratMCS root_mcs root_mcs_proof q' := by
  let iso := canonicalIso root_mcs root_mcs_proof
  let t := iso.symm q
  -- h_F gives F(phi) in timelineQuotMCS(t)
  obtain ⟨t', h_lt, h_phi⟩ := timelineQuot_forward_F root_mcs root_mcs_proof t phi h_F
  -- Transfer to Rat
  use iso t'
  constructor
  · exact iso.strictMono h_lt
  · exact h_phi
```

**Verification**:
- `grep -c sorry CanonicalEmbedding.lean` shows 2 fewer sorries
- `lake build Bimodal.Metalogic.Algebraic.CanonicalEmbedding`

---

### Phase 3: Truth Lemma over TimelineQuot [NOT STARTED]

**Goal**: Build truth lemma connecting MCS membership to semantic truth

**Tasks**:
- [ ] Define TaskModel over TimelineQuot using timelineQuotMCS
- [ ] Define shift-closed Omega set for history
- [ ] Prove forward direction: phi in mcs(t) -> truth_at M Omega tau t phi
- [ ] Prove backward direction: truth_at M Omega tau t phi -> phi in mcs(t)
- [ ] Package as `timelineQuot_truth_lemma`

**Timing**: 5 hours

**Files to create/modify**:
- Create: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean`
- Or extend: `TimelineQuotCanonical.lean`

**Key Theorem**:
```lean
theorem timelineQuot_truth_lemma
    (fam : timelineQuotFMCS root_mcs root_mcs_proof)
    (t : TimelineQuot root_mcs root_mcs_proof) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at (timelineQuotTaskModel root_mcs root_mcs_proof)
        (timelineQuotOmega root_mcs root_mcs_proof)
        (timelineQuotHistory root_mcs root_mcs_proof) t phi
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotTruthLemma`
- `lean_verify` on `timelineQuot_truth_lemma`

---

### Phase 4: Fill timelineQuot_not_valid_of_neg_consistent [NOT STARTED]

**Goal**: Complete the main sorry blocking dense completeness

**Tasks**:
- [ ] Import TimelineQuotTruthLemma into TimelineQuotCompleteness.lean
- [ ] Use truth lemma: phi.neg in root MCS -> not(truth_at ... phi)
- [ ] Construct countermodel from TimelineQuotFMCS
- [ ] Fill `timelineQuot_not_valid_of_neg_consistent` proof

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**Key Proof Pattern**:
```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (phi : Formula) (h_cons : ContextConsistent [phi.neg]) :
    let M₀ := lindenbaumMCS [phi.neg] h_cons
    let h_M₀_mcs := lindenbaumMCS_is_mcs [phi.neg] h_cons
    @valid_over (TimelineQuot M₀ h_M₀_mcs) _ _ _ := by
  intro M₀ h_M₀_mcs
  -- Build countermodel
  let F := timelineQuotTaskFrame M₀ h_M₀_mcs
  let M := timelineQuotTaskModel M₀ h_M₀_mcs
  let Omega := timelineQuotOmega M₀ h_M₀_mcs
  let tau := timelineQuotHistory M₀ h_M₀_mcs
  -- phi.neg in root MCS
  have h_neg_in : phi.neg ∈ M₀ := lindenbaumMCS_extends_context ...
  -- By truth lemma, phi.neg is true at root
  have h_neg_true := (timelineQuot_truth_lemma ...).mp h_neg_in
  -- Therefore phi is false at root
  use F, M, Omega, tau, ..., root_time
  exact truth_neg_iff.mp h_neg_true
```

**Verification**:
- `grep -c sorry TimelineQuotCompleteness.lean` returns 0
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness`

---

### Phase 5: Verify Dense Completeness & Wire BFMCS [NOT STARTED]

**Goal**: Verify final dense completeness theorem and complete construct_bfmcs_rat

**Tasks**:
- [ ] Verify `dovetailed_dense_completeness` in DovetailedCompleteness.lean has no sorries
- [ ] Fill remaining sorries in `ratBFMCS` (modal_backward)
- [ ] Fill `ratFMCS_root_eq` and `construct_bfmcs_rat_for_root`
- [ ] Wire `construct_bfmcs_rat_for_root` to `dense_representation_conditional`
- [ ] Verify full `lake build Bimodal` succeeds
- [ ] Count total sorries - should decrease

**Timing**: 1 hour

**Files to verify/modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCompleteness.lean`
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` (if wiring needed)

**Verification**:
- `lake build Bimodal` succeeds
- `grep -rn sorry Theories/Bimodal/Metalogic/StagedConstruction/` shows reduction
- `grep -rn sorry Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean` returns 0
- No new axioms introduced

## Testing & Validation

- [ ] Each phase builds independently
- [ ] `lake build Bimodal` succeeds after all phases
- [ ] `timelineQuot_not_valid_of_neg_consistent` has no sorry
- [ ] `dovetailed_dense_completeness` has no sorry
- [ ] `ratFMCS_forward_F` has no sorry
- [ ] `ratFMCS_backward_P` has no sorry
- [ ] Sorry count in `Theories/Bimodal/Metalogic/` decreases by at least 4
- [ ] No new axioms introduced

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotForwardF.lean` (Phase 1)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean` (Phase 3)
- Modified `CanonicalEmbedding.lean` with filled sorries (Phase 2, 5)
- Modified `TimelineQuotCompleteness.lean` with filled sorry (Phase 4)
- `specs/988_dense_algebraic_completeness/summaries/10_completion-summary.md`

## Comparison with Previous Plans

| Aspect | Plan v9 | Plan v10 (this) |
|--------|---------|-----------------|
| Primary approach | TimelineQuot-DovetailedCoverage bridge | Direct TimelineQuot forward_F |
| Bridge complexity | Phase 1 architecture gap | Lemma in single file |
| Truth lemma domain | TimelineQuot (same) | TimelineQuot (same) |
| Key insight | Coverage from DovetailedCoverage | Witnesses in same MCS-reachable set |
| Estimated effort | 16h | 14h |
| FMCSTransfer usage | None (bypassed) | None (confirmed blocked) |

## Rollback/Contingency

If TimelineQuot forward_F proves intractable due to witness availability:

**Fallback A**: Prove DovetailedTimelineUnion = DenseTimelineUnion (set equality)
- If the two constructions produce the same set of MCS, witnesses transfer trivially
- Requires analyzing both staged build algorithms

**Fallback B**: Weaken to subset relation
- Prove DenseTimelineUnion subset DovetailedTimelineUnion
- This may suffice if TimelineQuot elements all have DovetailedCoverage witnesses

**Revert Changes**:
- New files can be deleted
- CanonicalEmbedding.lean changes revertible via git
- TimelineQuotCompleteness.lean changes revertible via git
