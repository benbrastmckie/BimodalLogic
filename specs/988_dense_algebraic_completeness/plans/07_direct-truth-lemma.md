# Implementation Plan: Task #988

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [NOT STARTED]
- **Effort**: 22 hours
- **Dependencies**: Task 982 (completed)
- **Research Inputs**: specs/988_dense_algebraic_completeness/reports/07_post-982-resolution.md
- **Artifacts**: plans/07_direct-truth-lemma.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

With task 982 completed, the dovetailed construction provides sorry-free `has_future` and `has_past` coverage lemmas in DovetailedCoverage.lean. This plan fills the remaining sorry in `timelineQuot_not_valid_of_neg_consistent` (TimelineQuotCompleteness.lean:127) using a direct TimelineQuot truth lemma approach, avoiding the BFMCS modal_backward architectural issue entirely.

### Research Integration

The research report (07_post-982-resolution.md) identified that task 982's completion fundamentally changes the landscape:
- DovetailedCoverage.lean now has 0 sorries for `dovetailedTimeline_has_future` and `dovetailedTimeline_has_past`
- The recommended approach is a direct TimelineQuot truth lemma rather than BFMCS transport
- This avoids the singleton BFMCS modal_backward issue that blocked previous attempts

## Goals & Non-Goals

**Goals**:
- Fill `timelineQuot_not_valid_of_neg_consistent` sorry
- Achieve `dovetailed_dense_completeness` with no sorries
- Prove `valid_dense phi -> provable phi` as final dense completeness theorem
- Clean `lake build Bimodal` with no new axioms

**Non-Goals**:
- BFMCS-based transport approach (avoided due to modal_backward singleton issue)
- Overlap with task 982 (TimelineQuot construction approach)
- Changing the existing parametric truth lemma infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CanonicalR-order bridge harder than expected | High | Low | Staged construction has CanonicalR alignment invariants; may need to expose them |
| Truth lemma induction complexity | Medium | Medium | Adapt existing ParametricTruthLemma structure as template |
| TimelineQuot quotient extraction tricky | Low | Low | `ofAntisymmetrization` already provides this; proven in TimelineQuotCompleteness.lean |
| Shift-closed Omega construction non-trivial | Medium | Low | ShiftClosedParametricCanonicalOmega provides working template |
| Instance unification issues with TimelineQuot | Medium | Medium | Use letI/haveI carefully; existing code shows pattern |

## Implementation Phases

### Phase 1: CanonicalR-Order Bridge [NOT STARTED]

**Goal**: Connect CanonicalR witness existence in dovetailed construction to TimelineQuot `<` order

**Tasks**:
- [ ] Define MCS extraction from TimelineQuot element (verify `timelineQuotMCS` works)
- [ ] Prove `canonicalR_implies_lt`: CanonicalR p.mcs q.mcs -> p < q in TimelineQuot order
- [ ] Prove `lt_implies_canonicalR`: p < q in TimelineQuot -> CanonicalR p.mcs q.mcs (if needed)
- [ ] Verify connection to dovetailedTimelineUnion membership

**Timing**: 4 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBridge.lean`
- Potentially modify: `TimelineQuotAlgebra.lean` (if bridge lemmas belong there)

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotBridge` succeeds
- `lean_verify` on `canonicalR_implies_lt`
- All lemmas have no `sorry`

---

### Phase 2: dovetailedFMCS Construction [NOT STARTED]

**Goal**: Build a TemporalCoherentFamily over TimelineQuot using dovetailed coverage

**Tasks**:
- [ ] Define `dovetailedFMCS : TemporalCoherentFamily (TimelineQuot M0 h_M0_mcs)`
  - `mcs t := (ofAntisymmetrization (· ≤ ·) t).1.mcs`
  - `is_mcs t := (ofAntisymmetrization (· ≤ ·) t).1.is_mcs`
- [ ] Prove `forward_F` using `dovetailedTimeline_has_future` + Phase 1 bridge
- [ ] Prove `backward_P` using `dovetailedTimeline_has_past` + Phase 1 bridge
- [ ] Verify root MCS membership property holds

**Timing**: 6 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean`

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedFMCS` succeeds
- `lean_verify` on `dovetailedFMCS.forward_F` and `dovetailedFMCS.backward_P`
- All lemmas have no `sorry`

---

### Phase 3: Direct Truth Lemma [NOT STARTED]

**Goal**: Prove truth lemma over TimelineQuot: phi in mcs t <-> truth_at M Omega tau t phi

**Tasks**:
- [ ] Define TaskFrame over TimelineQuot (use `denseCanonicalTaskFrame` pattern)
- [ ] Define TaskModel with MCS valuation: `valuation(p) = lambda a => a in (extract_mcs p)`
- [ ] Define Omega set (shift-closed) using ShiftClosedParametricCanonicalOmega as template
- [ ] Prove forward direction: phi in mcs t -> truth_at
- [ ] Prove backward direction: truth_at -> phi in mcs t
  - Use `temporal_backward_G` and `temporal_backward_H` from TemporalCoherence.lean
  - Requires dovetailedFMCS from Phase 2

**Timing**: 8 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean`

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotTruthLemma` succeeds
- `lean_verify` on main truth lemma theorem
- All lemmas have no `sorry`

---

### Phase 4: Fill timelineQuot_not_valid_of_neg_consistent [NOT STARTED]

**Goal**: Replace the sorry in TimelineQuotCompleteness.lean with a complete proof

**Tasks**:
- [ ] Import TimelineQuotTruthLemma
- [ ] Apply truth lemma: phi.neg in root MCS -> neg(truth_at ... phi)
- [ ] Construct countermodel from dovetailedFMCS structure
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` proof
- [ ] Verify `dense_completeness_theorem` now compiles

**Timing**: 2 hours

**Files to modify**:
- Modify: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**Verification**:
- `grep -c sorry TimelineQuotCompleteness.lean` returns 0
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness` succeeds

---

### Phase 5: Wire Dense Completeness Theorem [NOT STARTED]

**Goal**: Verify final dense completeness theorem compiles and export cleanly

**Tasks**:
- [ ] Verify `dovetailed_dense_completeness` in DovetailedCompleteness.lean has no sorries
- [ ] Add `dense_algebraic_completeness : valid_dense phi -> provable phi` if not already present
- [ ] Verify full `lake build Bimodal` succeeds
- [ ] Count total sorries in Theories/ - should decrease by at least 1
- [ ] Document any remaining work in completion summary

**Timing**: 2 hours

**Files to modify**:
- Verify: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCompleteness.lean`
- Possibly create: `Theories/Bimodal/Metalogic/DenseCompleteness.lean` (export wrapper)

**Verification**:
- `lake build Bimodal` succeeds with no errors
- `grep -rn sorry Theories/Bimodal/Metalogic/StagedConstruction/` shows reduction
- No new axioms introduced (`grep -rn "axiom " Theories/`)

## Testing & Validation

- [ ] Each phase builds independently (`lake build Module.Name`)
- [ ] `lake build Bimodal` succeeds after all phases
- [ ] `timelineQuot_not_valid_of_neg_consistent` has no sorry
- [ ] `dovetailed_dense_completeness` has no sorry
- [ ] Sorry count in `Theories/Bimodal/Metalogic/StagedConstruction/` decreases
- [ ] No new axioms introduced
- [ ] Instance unification works correctly (no typeclass resolution errors)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBridge.lean` (Phase 1)
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean` (Phase 2)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotTruthLemma.lean` (Phase 3)
- Modified `TimelineQuotCompleteness.lean` (Phase 4)
- Verified `DovetailedCompleteness.lean` (Phase 5)
- `specs/988_dense_algebraic_completeness/summaries/02_completion-summary.md`

## Rollback/Contingency

If the direct TimelineQuot truth lemma approach proves intractable:

**Fallback Option A**: BFMCS Transport with Multi-Family
- Use existing multi-family BFMCS infrastructure over all MCSs
- Transport via Cantor isomorphism TimelineQuot ≃o Rat
- Estimated additional effort: 10-15 hours

**Fallback Option B**: Parametric Transport
- Define parametric transport theorems for FMCS/BFMCS
- Map TimelineQuot FMCS to Rat FMCS via order isomorphism
- Use existing `dense_representation_conditional` with transported BFMCS

**Revert Changes**:
- New files can simply be deleted
- TimelineQuotCompleteness.lean changes can be reverted via git
- No destructive changes to existing working code

## Comparison with Previous Plans

| Aspect | Plan v6 | Plan v7 (this) |
|--------|---------|----------------|
| Primary path | Fix ClosureSaturation sorries | Direct TimelineQuot truth lemma |
| Leverages task 982 | Partially (expected DovetailedTimelineQuot) | Fully (uses DovetailedCoverage) |
| BFMCS approach | Singleton (problematic) | Avoids BFMCS entirely |
| Estimated hours | 17-20h | 22h |
| Architectural cleanliness | Moderate | High |
| Sorries addressed | 4 in ClosureSaturation | 1 in TimelineQuotCompleteness |
| Blocker resolution | Needed dovetailing first | Dovetailing complete |
