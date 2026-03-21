# Implementation Plan: Unify DenseTimeline and DovetailedTimeline

- **Task**: 27 - unify_densetimeline_dovetailedtimeline
- **Status**: [COMPLETED]
- **Effort**: 4-5 hours
- **Dependencies**: DovetailedCoverageReach.lean (existing), DovetailedBuild.lean (existing)
- **Research Inputs**: specs/027_unify_densetimeline_dovetailedtimeline/reports/01_timeline-unification.md
- **Artifacts**: plans/01_timeline-unification-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan unifies the DenseTimeline and DovetailedTimeline constructions by replacing DenseTimeline with DovetailedTimeline in TimelineQuot. The root cause of the `forward_F`/`backward_P` sorries in ClosureSaturation.lean is that DenseTimeline processes formulas by encoding order (stage 2k+1), creating gaps when points enter after their F-formula was processed. DovetailedTimeline fixes this via Cantor pairing, ensuring every (point, formula) obligation is processed.

### Research Integration

The research report (01_timeline-unification.md) recommends a **wholesale replacement** approach:
- Replace `DenseTimelineElem` with `DovetailedTimelineElem`
- Replace `TimelineQuot` (built on DenseTimeline) with `DovetailedTimelineQuot`
- Use `forward_F_via_coverage` and `backward_P_via_coverage` from DovetailedCoverageReach.lean
- No bridge layer needed (per user constraint)

## Goals & Non-Goals

**Goals**:
- Define `DovetailedTimelineElem` as subtype of DovetailedPoint in the timeline union
- Define `DovetailedTimelineQuot` as antisymmetrization of `DovetailedTimelineElem`
- Port all Cantor prerequisites (Countable, NoMaxOrder, NoMinOrder, DenselyOrdered) to DovetailedTimelineQuot
- Update TimelineQuotCanonical.lean to use DovetailedTimelineQuot
- Update ClosureSaturation.lean to use DovetailedCoverageReach theorems
- Eliminate the `forward_F` and `backward_P` sorries in ClosureSaturation.lean

**Non-Goals**:
- Creating a bridge layer between DenseTimeline and DovetailedTimeline
- Modifying the base StagedExecution.lean construction
- Resolving the edge-case sorries in DovetailedCoverageReach.lean (process_step=0, p existed at process_step-1)
- Modifying DenseTimeline.lean itself (it remains for potential other uses)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missing prerequisite theorems in DovetailedBuild | High | Low | Research verified DovetailedPoint.le exists and matches StagedPoint.le |
| Cantor prerequisite proofs diverge from DenseTimeline pattern | Medium | Medium | DenseTimeline proofs provide template; structure is isomorphic |
| DovetailedCoverageReach edge-case sorries propagate | Medium | Low | These are localized to k=0 edge cases, do not block main coverage |
| Import cycle when adding DovetailedTimelineQuot | Medium | Low | Place in new file or extend CantorApplication.lean carefully |

## Implementation Phases

### Phase 1: Define DovetailedTimelineElem and Preorder [COMPLETED]

**Goal**: Create the element type and preorder instance for the dovetailed timeline, mirroring DenseTimelineElem.

**Tasks**:
- [ ] Add `DovetailedTimelineElem` definition to DovetailedBuild.lean:
  ```lean
  def DovetailedTimelineElem (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) : Type :=
    { p : DovetailedPoint // p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof }
  ```
- [ ] Add Preorder instance for DovetailedTimelineElem (using DovetailedPoint.le)
- [ ] Prove IsTotal instance for the preorder (using dovetailedBuild_linear or equivalent)
- [ ] Add DecidableLE and DecidableLT instances (via Classical.propDecidable)
- [ ] Verify `lake build` passes

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` - add DovetailedTimelineElem and instances

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedBuild` succeeds
- New definitions type-check

---

### Phase 2: Define DovetailedTimelineQuot with LinearOrder [COMPLETED]

**Goal**: Create the antisymmetrization quotient and establish it has a linear order.

**Tasks**:
- [ ] Create new file `DovetailedTimelineQuot.lean` or extend CantorApplication.lean
- [ ] Define `DovetailedTimelineQuot`:
  ```lean
  def DovetailedTimelineQuot (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) : Type :=
    Antisymmetrization (DovetailedTimelineElem root_mcs root_mcs_proof) (· ≤ ·)
  ```
- [ ] Add LinearOrder instance (inherits from Antisymmetrization + IsTotal)
- [ ] Verify `lake build` passes

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` or new file

**Verification**:
- LinearOrder instance infers successfully
- No import cycles

---

### Phase 3: Port Cantor Prerequisites to DovetailedTimelineQuot [COMPLETED]

**Goal**: Establish Countable, NoMaxOrder, NoMinOrder, DenselyOrdered, and Nonempty for DovetailedTimelineQuot.

**Tasks**:
- [ ] Prove `Nonempty (DovetailedTimelineQuot)` using root_in_dovetailedBuild_0
- [ ] Prove `Countable (DovetailedTimelineQuot)` using dovetailedTimeline_countable (or prove if missing)
- [ ] Prove `NoMaxOrder (DovetailedTimelineQuot)`:
  - Use dovetailed_timeline_has_future
  - Apply canonicalR_strict via irreflexivity axiom
- [ ] Prove `NoMinOrder (DovetailedTimelineQuot)`:
  - Use dovetailed_timeline_has_past
  - Apply canonicalR_strict via irreflexivity axiom
- [ ] Prove `DenselyOrdered (DovetailedTimelineQuot)`:
  - Use density_frame_condition for intermediate MCS
  - Apply canonicalR_strict for strictness
- [ ] Add cantor_iso theorem for DovetailedTimelineQuot

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` (or new file)

**Verification**:
- All five Cantor prerequisites have instances
- `cantor_iso : Nonempty (DovetailedTimelineQuot ≃o Rat)` type-checks

---

### Phase 4: Update TimelineQuotCanonical.lean to Use DovetailedTimeline [COMPLETED]

**Goal**: Replace DenseTimeline references with DovetailedTimeline in the canonical model construction.

**Tasks**:
- [ ] Add import for DovetailedBuild.lean (or new file with DovetailedTimelineQuot)
- [ ] Define `dovetailedTimelineQuotMCS` extraction function:
  ```lean
  noncomputable def dovetailedTimelineQuotMCS
      (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
      (t : DovetailedTimelineQuot root_mcs root_mcs_proof) : Set Formula :=
    (ofAntisymmetrization (· ≤ ·) t).1.mcs
  ```
- [ ] Port `denseTimelineElem_mutual_le_implies_mcs_eq` to DovetailedTimelineElem
- [ ] Port core linking lemma `timelineQuot_lt_implies_canonicalR` to DovetailedTimelineQuot
- [ ] Port `canonicalR_implies_timelineQuot_le` to DovetailedTimelineQuot
- [ ] Port FMCS coherence theorems (forward_G, backward_H) to DovetailedTimelineQuot
- [ ] Update `timelineQuotFMCS` to use DovetailedTimelineQuot

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`

**Verification**:
- All ported theorems compile without error
- No dependencies on DenseTimelineElem remain in active code paths

---

### Phase 5: Update ClosureSaturation.lean and Eliminate forward_F/backward_P Sorries [COMPLETED]

**Goal**: Wire DovetailedCoverageReach theorems to eliminate the forward_F and backward_P sorries.

**Tasks**:
- [ ] Add import for DovetailedCoverageReach.lean
- [ ] Update `timelineQuotFMCS_forward_F` proof:
  - Use `forward_F_via_coverage` from DovetailedCoverageReach
  - Convert between DovetailedTimelineQuot and DovetailedPoint
- [ ] Update `timelineQuotFMCS_backward_P` proof:
  - Use `backward_P_via_coverage` from DovetailedCoverageReach
  - Convert between DovetailedTimelineQuot and DovetailedPoint
- [ ] Remove or mark obsolete the old sorry-based proofs
- [ ] Verify the BFMCS construction compiles with new proofs
- [ ] Run `lake build` for full project verification

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`

**Verification**:
- `timelineQuotFMCS_forward_F` and `timelineQuotFMCS_backward_P` have no sorries
- `lake build` succeeds for the full project
- Grep for `sorry` in ClosureSaturation.lean shows only the modal_backward sorry (which is documented as unfixable in singleton BFMCS)

---

### Phase 6: Update TimelineQuotCompleteness.lean and Verify Integration [COMPLETED]

**Goal**: Ensure the completeness theorem infrastructure uses the unified DovetailedTimelineQuot.

**Tasks**:
- [ ] Update `timelineQuotMCS` references to use dovetailedTimelineQuotMCS
- [ ] Verify `timelineQuotMCS_is_mcs` still holds
- [ ] Verify completeness theorem structure compiles
- [ ] Add integration test or example theorem using the unified construction
- [ ] Run full `lake build` and verify no regressions

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`
- Possibly other files that import TimelineQuotCanonical

**Verification**:
- Full `lake build` succeeds
- No new sorries introduced (except documented edge cases in DovetailedCoverageReach)

## Testing & Validation

- [ ] `lake build` passes for all modified files individually
- [ ] `lake build` passes for full project
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` shows only the documented modal_backward sorry
- [ ] `grep -r "DenseTimelineElem" Theories/Bimodal/Metalogic/StagedConstruction/` shows no active uses in completeness path
- [ ] Cantor isomorphism theorem type-checks for DovetailedTimelineQuot

## Artifacts & Outputs

- `plans/01_timeline-unification-plan.md` (this file)
- Modified `DovetailedBuild.lean` with DovetailedTimelineElem, DovetailedTimelineQuot
- Modified `TimelineQuotCanonical.lean` using DovetailedTimeline
- Modified `ClosureSaturation.lean` with forward_F/backward_P proofs
- Modified `TimelineQuotCompleteness.lean` with unified construction
- `summaries/02_timeline-unification-summary.md` (on completion)

## Rollback/Contingency

If the unification introduces unforeseen issues:
1. All changes are in Lean files under version control
2. DenseTimeline.lean is NOT modified; it remains available
3. CantorApplication.lean retains the original DenseTimeline-based TimelineQuot
4. Rollback: `git checkout` the modified files to restore DenseTimeline path
5. Alternative: If DovetailedTimelineQuot works but Cantor prerequisites are problematic, could keep both quotient types and choose based on use case
