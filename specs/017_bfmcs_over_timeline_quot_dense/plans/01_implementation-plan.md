# Implementation Plan: BFMCS over TimelineQuot Dense

- **Task**: 17 - bfmcs_over_timeline_quot_dense
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 16 (DenseTask relation - complete)
- **Research Inputs**: specs/017_bfmcs_over_timeline_quot_dense/reports/01_bfmcs-dense-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Construct a temporally complete BFMCS bundle indexed by TimelineQuot that satisfies both modal coherence (`modal_backward`, `modal_forward`) and temporal coherence (`forward_F`, `backward_P`). The singleton BFMCS approach (documented in MultiFamilyBFMCS.lean) fails `modal_backward` because Diamond(psi) in M does NOT imply psi in M. The solution requires multiple FMCS families with closure-based saturation using the ClosedFlagBundle pattern.

### Research Integration

Key findings from research report 01_bfmcs-dense-research.md:
- Singleton BFMCS mathematically impossible for modal saturation (line 277-286 of MultiFamilyBFMCS.lean)
- ClosedFlagBundle infrastructure provides multi-Flag closure (`closedFlags_closed_under_witnesses`)
- DenseTask from Task 16 provides temporal backbone
- WitnessFamilyBundle provides `buildWitnessRecord` for Diamond witness construction
- SaturatedBFMCSConstruction provides `saturated_modal_backward` framework

## Goals & Non-Goals

**Goals**:
- Define `TimelineQuotWitnessFMCS` structure for witness families over TimelineQuot
- Build `TimelineQuotClosedBFMCS` via closure over witness families
- Prove `modal_forward` via T-axiom and BoxContent propagation
- Prove `modal_backward` via saturated closure construction
- Prove `forward_F` and `backward_P` for temporal coherence
- Wire to DenseTaskFrame for truth lemma compatibility

**Non-Goals**:
- Full dense completeness proof (blocked on this task)
- Alternative domain types (CanonicalMCS directly)
- Singleton bundle approaches (proven impossible)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness family temporal coherence breaks forward_G | High | Medium | Staged construction ensures witnesses added in CanonicalR order |
| Domain type heterogeneity across families | High | Low | All families use TimelineQuot domain, differ only in mcs function |
| Infinite family proliferation | Medium | Low | Closure-based saturation terminates for finite formula subsets |
| BoxContent propagation across families | High | Medium | Reuse MCSBoxContent_subset_of_CanonicalR from existing infrastructure |

## Implementation Phases

### Phase 1: Define TimelineQuotWitnessFMCS [NOT STARTED]

**Goal**: Create the witness family structure that maps TimelineQuot elements to MCS, placing Diamond witnesses at specific times.

**Tasks**:
- [ ] Define `WitnessSeed` structure: source time, witness MCS, target time
- [ ] Define `TimelineQuotWitnessFMCS`: FMCS over TimelineQuot with witness placement
- [ ] Implement `witnessFMCS_mcs`: maps `t` to witness MCS at seed time, else `timelineQuotMCS t`
- [ ] Prove `witnessFMCS_is_mcs`: all mapped values are MCS
- [ ] Prove `witnessFMCS_forward_G`: G-coherence using CanonicalR structure
- [ ] Prove `witnessFMCS_backward_H`: H-coherence using CanonicalR structure

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean` (new file)

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotBFMCS` compiles
- No sorry markers in witness family definitions

---

### Phase 2: Build ClosedFamily BFMCS [NOT STARTED]

**Goal**: Construct the multi-family BFMCS via transfinite closure over witness obligations.

**Tasks**:
- [ ] Define `TimelineQuotInitialFamilies`: set containing `timelineQuotFMCS`
- [ ] Define `addTimelineQuotWitnessFamilies`: one-step closure adding witness families
- [ ] Define `TimelineQuotClosedFamilies`: transfinite closure of witness families
- [ ] Prove `closedFamilies_nonempty`: at least one family exists
- [ ] Define `timelineQuotClosedBFMCS`: BFMCS structure with closed families
- [ ] Prove families closure: every Diamond obligation has witness in some family

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`

**Verification**:
- BFMCS structure defined with all fields except modal coherence proofs
- Closure property proven for witness obligations

---

### Phase 3: Prove Modal Coherence [NOT STARTED]

**Goal**: Establish modal_forward and modal_backward for the closed BFMCS.

**Tasks**:
- [ ] Prove `timelineQuotBFMCS_modal_forward`: Box phi implies phi via T-axiom
- [ ] Define `DiamondWitnessSaturation`: saturation predicate for closed families
- [ ] Prove `closedFamilies_saturated`: closure ensures Diamond witnesses exist
- [ ] Prove `timelineQuotBFMCS_modal_backward`: phi in all families implies Box phi
- [ ] Connect to `saturated_modal_backward` from ModalSaturation.lean

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`

**Verification**:
- `modal_forward` and `modal_backward` fields have no sorry
- Saturation lemmas connect to ClosedFlagBundle infrastructure

---

### Phase 4: Prove Temporal Coherence [NOT STARTED]

**Goal**: Establish forward_F and backward_P for temporal coherence within families.

**Tasks**:
- [ ] Prove `witnessFMCS_forward_F`: F(phi) in mcs(t) implies phi in mcs(s) for some s > t
- [ ] Prove `witnessFMCS_backward_P`: P(phi) in mcs(t) implies phi in mcs(s) for some s < t
- [ ] Prove `closedFamilies_temporal_coherent`: all families satisfy forward_F/backward_P
- [ ] Connect witness placement to DenseTask ordering via TimelineQuot order
- [ ] Prove witnesses placed at strictly later/earlier times via Cantor-assigned rationals

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`

**Verification**:
- forward_F and backward_P proofs reference ClosureSaturation.lean infrastructure
- Witnesses placed at correct temporal positions

---

### Phase 5: Wire to Truth Lemma [NOT STARTED]

**Goal**: Connect BFMCS to DenseTaskFrame for completeness proof.

**Tasks**:
- [ ] Define `timelineQuotBFMCSTaskFrame`: TaskFrame instance using DenseTask
- [ ] Prove truth lemma for Box: Box phi in mcs iff phi in all families
- [ ] Prove truth lemma compatibility with BFMCS structure
- [ ] Connect to dense_representation_conditional from DenseTaskRelation.lean
- [ ] Export final `timelineQuotDenseBFMCS` construction

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`
- Update imports in `Theories/Bimodal/Metalogic/Algebraic/` files if needed

**Verification**:
- BFMCS integrates with existing DenseTaskFrame
- Export theorem provides fully constructed BFMCS for completeness proofs

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] No sorry markers in final construction
- [ ] `timelineQuotClosedBFMCS` satisfies all BFMCS field requirements
- [ ] Modal coherence proofs use ClosedFlagBundle infrastructure correctly
- [ ] Temporal coherence proofs connect to DenseTask ordering
- [ ] Truth lemma for Box phi established

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean` - Main implementation
- `specs/017_bfmcs_over_timeline_quot_dense/plans/01_implementation-plan.md` - This plan
- `specs/017_bfmcs_over_timeline_quot_dense/summaries/01_implementation-summary.md` - Execution summary (after completion)

## Rollback/Contingency

If the full multi-family construction is blocked:
1. Isolate blocking lemma into a separate sorry-tracked theorem
2. Document the specific mathematical obstacle
3. Create follow-up task for the blocked component
4. Preserve partial progress in working state

If temporal coherence breaks:
1. Check if witnesses are placed in CanonicalR order
2. Verify DenseTask properties for witness placement
3. Consider alternative witness placement strategies from ClosureSaturation.lean
