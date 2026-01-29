# Implementation Plan: Task #741

- **Task**: 741 - Witness extraction architecture for backward Truth Lemma
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: Medium
- **Dependencies**: Tasks 654, 656, 659
- **Research Inputs**: specs/741_witness_extraction_architecture_for_backward_truth_lemma/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements witness extraction architecture to complete the backward Truth Lemma temporal cases (lines 423, 441 in TruthLemma.lean). The core challenge is proving `Hpsi not-in mcs(t) -> exists s < t. psi not-in mcs(s)`. Research identified three architectural approaches, with the contrapositive via H-completeness being recommended. The approach is: (1) prove H/G-completeness lemmas establishing that universal past/future membership implies temporal operator membership, (2) derive witness extraction lemmas as immediate corollaries, (3) complete the backward Truth Lemma cases using witness extraction with the forward induction hypothesis.

### Research Integration

The research report (research-001.md) established:
- The forward_H coherence property provides the wrong direction (universal, not existential)
- Contrapositive approach via H-completeness is recommended
- No omega-rule exists in TM logic, so direct derivation is blocked
- The construction-specific argument analyzing MCS structure is required
- Mathlib's `Int.exists_least_of_bdd` is available for bounded witness extraction if needed

## Goals & Non-Goals

**Goals**:
- Prove H-completeness: `(forall s < t, psi in mcs(s)) -> Hpsi in mcs(t)`
- Prove G-completeness: `(forall s > t, psi in mcs(s)) -> Gpsi in mcs(t)`
- Derive witness extraction lemmas as contrapositive consequences
- Complete backward Truth Lemma cases at lines 423 and 441
- Ensure all proofs compile without `sorry`

**Non-Goals**:
- Modifying the IndexedMCSFamily construction (use existing infrastructure)
- Proving an omega-rule for TM logic (not needed with contrapositive approach)
- Changing the overall truth_lemma_mutual induction structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| H-completeness proof requires omega-rule | High | Medium | Use construction-specific argument via Lindenbaum properties, not general derivability |
| Circular dependency in induction | High | Low | Carefully use only forward IH for subformula psi, never backward direction being proven |
| extendToMCS behavior hard to analyze | Medium | Medium | May need to strengthen Lindenbaum lemmas or add intermediate properties |
| MCS negation properties insufficient | Medium | Low | set_mcs_negation_complete already proven; verify it provides needed direction |
| Infinite witness range complicates proof | Medium | Medium | Focus on contrapositive; avoid direct witness construction on unbounded domain |

## Implementation Phases

### Phase 1: Infrastructure Analysis and Preparation [COMPLETED]

**Goal**: Understand existing MCS infrastructure and prepare for H/G-completeness proofs

**Tasks**:
- [x] Review IndexedMCSFamily.lean for existing coherence conditions and construction details
- [x] Review MCSProperties.lean for negation completeness and derivation closure properties
- [x] Identify which existing lemmas can be reused directly
- [x] Document the exact induction structure in truth_lemma_mutual to avoid circularity
- [x] Create new file TemporalCompleteness.lean with module structure and imports

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - create new file

**Verification**:
- New file compiles with correct imports
- Module structure aligns with existing Representation namespace
- Documentation explains the induction non-circularity

---

### Phase 2: Prove H-completeness Lemma [IN PROGRESS]

**Goal**: Establish that universal past membership implies Hpsi membership

**Tasks**:
- [ ] Define H_completeness lemma signature with appropriate type constraints
- [ ] Implement proof via contrapositive: assume Hpsi not-in mcs(t)
- [ ] Use set_mcs_negation_complete to derive neg(Hpsi) in mcs(t)
- [ ] Show this leads to witness s < t with psi not-in mcs(s) (or derive contradiction)
- [ ] Handle edge cases for domain boundaries (if applicable)
- [ ] Verify proof compiles without sorry

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - add H_completeness lemma

**Verification**:
- `lake build` succeeds
- `lean_goal` shows no remaining goals
- Proof uses only forward-direction IH (no circularity)

---

### Phase 3: Prove G-completeness Lemma [NOT STARTED]

**Goal**: Establish symmetric property for universal future membership

**Tasks**:
- [ ] Define G_completeness lemma signature (symmetric to H_completeness)
- [ ] Adapt H_completeness proof structure for forward temporal direction
- [ ] Adjust for forward_G coherence instead of backward_H
- [ ] Verify symmetry with H-completeness proof
- [ ] Ensure proof compiles without sorry

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - add G_completeness lemma

**Verification**:
- `lake build` succeeds
- Proof structure mirrors H_completeness
- lean_goal shows no remaining goals

---

### Phase 4: Derive Witness Extraction Lemmas [NOT STARTED]

**Goal**: Create convenient wrapper lemmas that extract witnesses from non-membership

**Tasks**:
- [ ] Define witness_from_not_H: `Hpsi not-in mcs(t) -> exists s < t. psi not-in mcs(s)`
- [ ] Prove by contrapositive using H_completeness
- [ ] Define witness_from_not_G: `Gpsi not-in mcs(t) -> exists s > t. psi not-in mcs(s)`
- [ ] Prove by contrapositive using G_completeness
- [ ] Add doc comments explaining the relationship to Truth Lemma

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - add witness extraction lemmas

**Verification**:
- Both lemmas compile without sorry
- Proofs are short (direct contrapositive application)
- Doc comments reference TruthLemma.lean usage

---

### Phase 5: Complete Backward Truth Lemma Cases [NOT STARTED]

**Goal**: Replace sorries at lines 423 and 441 with complete proofs

**Tasks**:
- [ ] Import TemporalCompleteness into TruthLemma.lean
- [ ] At line 423 (all_past backward): apply witness_from_not_H
- [ ] Use forward IH on witness to get contradiction with h_all_past
- [ ] At line 441 (all_future backward): apply witness_from_not_G
- [ ] Use forward IH on witness to get contradiction with h_all_future
- [ ] Remove NOT REQUIRED comments and BackwardDirection.lean references

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - complete sorries at lines 423, 441

**Verification**:
- `lake build` succeeds with no sorries in TruthLemma.lean temporal cases
- Both backward cases for all_past and all_future are complete
- Forward IH is used correctly without circularity

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Ensure implementation is complete and properly integrated

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Check that truth_lemma, truth_lemma_forward, truth_lemma_backward all work
- [ ] Verify no orphaned sorries remain in TruthLemma.lean
- [ ] Update module documentation if needed
- [ ] Check if BackwardDirection.lean in Boneyard can be archived or deleted

**Timing**: 1 hour

**Files to modify**:
- Potentially update doc comments in TruthLemma.lean
- Potentially remove/archive Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean

**Verification**:
- Full project builds successfully
- No sorries in representation theorem path
- Documentation is accurate

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] No `sorry` remains in TruthLemma.lean temporal cases
- [ ] `lean_goal` at each proof position shows "no goals" (proof complete)
- [ ] truth_lemma theorem compiles and provides correct iff relationship
- [ ] representation_theorem (if dependent on truth_lemma) still works

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - new file with H/G-completeness and witness extraction
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - updated with completed backward cases
- `specs/741_witness_extraction_architecture_for_backward_truth_lemma/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If the contrapositive approach fails:
1. Preserve TemporalCompleteness.lean attempts in Boneyard
2. Document specific blocking issue (what lemma couldn't be proven)
3. Consider alternative approaches from research:
   - Direct witness construction with Int.exists_least_of_bdd
   - Semantic MCS completeness argument
   - Finite witness bounds via construction analysis
4. If all approaches fail, keep current sorries with expanded documentation explaining the gap
