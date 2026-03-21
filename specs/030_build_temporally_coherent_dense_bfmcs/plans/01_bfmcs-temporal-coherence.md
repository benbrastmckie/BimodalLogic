# Implementation Plan: Task #30

- **Task**: 30 - build_temporally_coherent_dense_bfmcs
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: None
- **Research Inputs**: specs/018_dense_representation_theorem_completion/reports/14_spawn-analysis.md
- **Artifacts**: plans/01_bfmcs-temporal-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This task creates a complete BFMCS structure indexed by DovetailedTimelineQuot with proven temporal coherence. The existing DovetailedTimelineQuotBFMCS module provides modal saturation via closedFlags over CanonicalMCS, but does NOT construct a full BFMCS type with the `temporally_coherent` field that the parametric truth lemma requires.

The solution follows the DirectMultiFamilyBFMCS pattern from the discrete case: construct a BFMCS where families are indexed by DovetailedTimelineQuot, and prove temporal coherence by lifting the existing `dovetailedFMCS_forward_F` and `dovetailedFMCS_backward_P` proofs to all families.

### Research Integration

From the spawn analysis report (14_spawn-analysis.md):
- The parametric truth lemma requires `B.temporally_coherent` proof
- Existing `dovetailedFMCS_forward_F` and `dovetailedFMCS_backward_P` provide temporal coherence for the primary family
- The BFMCS must use `DovetailedTimelineQuot` as its domain (not `CanonicalMCS`) for the truth lemma instantiation

## Goals & Non-Goals

**Goals**:
- Define `dovetailedTimelineQuotBFMCS : BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof)` as a proper BFMCS structure
- Prove `dovetailedTimelineQuotBFMCS_temporally_coherent : B.temporally_coherent`
- Ensure the construction is compatible with parametric truth lemma instantiation
- Build compiles without new sorries

**Non-Goals**:
- Modifying the existing modal coherence infrastructure (closedFlags)
- Changing the underlying DovetailedFMCS construction
- Implementing the truth lemma instantiation (that is Task 31)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Domain mismatch between modal (CanonicalMCS) and temporal (DovetailedTimelineQuot) | H | M | Use singleton BFMCS pattern - single dovetailedFMCS family suffices for temporal coherence |
| Cross-family modal coherence issues (like DirectMultiFamilyBFMCS sorries) | H | L | Dense case has different architecture - use singleton family approach to avoid cross-family requirements |
| Incompatible BFMCS structure for parametric truth lemma | H | L | Study ParametricTruthLemma.lean requirements before finalizing structure |

## Implementation Phases

### Phase 1: Analyze BFMCS Requirements [NOT STARTED]

**Goal**: Understand exactly what structure the parametric truth lemma expects from a BFMCS

**Tasks**:
- [ ] Read ParametricTruthLemma.lean to identify BFMCS requirements
- [ ] Read TemporalCoherence.lean to understand temporally_coherent predicate
- [ ] Verify that singleton BFMCS approach is viable for the dense case
- [ ] Document the expected signature for the BFMCS construction

**Timing**: 30 minutes

**Files to read**:
- `Theories/Bimodal/Metalogic/Bundle/ParametricTruthLemma.lean` - parametric truth lemma requirements
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - temporally_coherent definition
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - BFMCS structure definition

**Verification**:
- Clear understanding of BFMCS fields required
- Identified signature: `BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof)`

---

### Phase 2: Construct BFMCS Structure [NOT STARTED]

**Goal**: Define the BFMCS structure with families indexed by DovetailedTimelineQuot

**Tasks**:
- [ ] Create new section in DovetailedTimelineQuotBFMCS.lean for full BFMCS construction
- [ ] Define singleton family set: `{dovetailedFMCS root_mcs root_mcs_proof}`
- [ ] Prove nonemptiness of family set
- [ ] Implement modal_forward using existing `dovetailedTimelineQuotBFMCS_modal_forward`
- [ ] Implement modal_backward (singleton case: trivial since only one family)
- [ ] Set eval_family to dovetailedFMCS
- [ ] Prove eval_family_mem

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuotBFMCS.lean` - add BFMCS construction

**Verification**:
- `dovetailedTimelineQuotBFMCS` definition type-checks
- All BFMCS fields are populated without sorry
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuotBFMCS` succeeds

---

### Phase 3: Prove Temporal Coherence [NOT STARTED]

**Goal**: Prove the BFMCS satisfies the temporally_coherent predicate

**Tasks**:
- [ ] Define helper theorem for forward_F on the singleton family
- [ ] Define helper theorem for backward_P on the singleton family
- [ ] Lift `dovetailedFMCS_forward_F` to BFMCS context
- [ ] Lift `dovetailedFMCS_backward_P` to BFMCS context
- [ ] Prove `dovetailedTimelineQuotBFMCS_temporally_coherent`
- [ ] Add docstrings documenting the connection to parametric truth lemma

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuotBFMCS.lean` - add temporal coherence proofs

**Verification**:
- `dovetailedTimelineQuotBFMCS_temporally_coherent` proves without sorry
- Type signature matches `(dovetailedTimelineQuotBFMCS root_mcs root_mcs_proof).temporally_coherent`
- Build succeeds with no new sorries

---

### Phase 4: Integration and Documentation [NOT STARTED]

**Goal**: Ensure the construction integrates properly and is documented for Task 31

**Tasks**:
- [ ] Add summary section to module docstring
- [ ] Export key theorems in module signature
- [ ] Verify imports are minimal and correct
- [ ] Run full `lake build` to check for regressions
- [ ] Document how Task 31 should use this BFMCS

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuotBFMCS.lean` - documentation updates

**Verification**:
- Full `lake build` succeeds
- No new sorries introduced anywhere in codebase
- Clear documentation for downstream Task 31

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuotBFMCS` compiles
- [ ] `lake build` (full project) succeeds
- [ ] `dovetailedTimelineQuotBFMCS` type signature is `BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof)`
- [ ] `dovetailedTimelineQuotBFMCS_temporally_coherent` proves `B.temporally_coherent`
- [ ] No new sorries in the implementation
- [ ] Grep for `sorry` in DovetailedTimelineQuotBFMCS.lean returns only pre-existing ones (if any)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuotBFMCS.lean` - updated with BFMCS and temporal coherence
- `specs/030_build_temporally_coherent_dense_bfmcs/summaries/01_bfmcs-temporal-coherence-summary.md` - implementation summary

## Rollback/Contingency

If the singleton BFMCS approach fails due to modal coherence requirements:
1. Revert changes to DovetailedTimelineQuotBFMCS.lean
2. Document the specific failure mode
3. Consider the DirectMultiFamilyBFMCS pattern with closedFlags-based family construction
4. May require splitting modal and temporal domains as in discrete case

The existing modal saturation infrastructure (Phase 4.1-4.5) should be preserved regardless of approach.
