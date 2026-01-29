# Implementation Plan: Task #741

- **Task**: 741 - Witness extraction architecture for backward Truth Lemma
- **Status**: [PARTIAL]
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

### Phase 2: Prove H-completeness Lemma [PARTIAL]

**Goal**: Establish that universal past membership implies Hpsi membership

**Status**: BLOCKED by omega-rule limitation. The proof requires deriving H psi from
infinitely many psi instances, which TM logic cannot express. The lemma signature
and partial proof structure are in place, but the core derivation is `sorry`.

**Tasks**:
- [x] Define H_completeness lemma signature with appropriate type constraints
- [x] Implement proof structure via contrapositive: assume Hpsi not-in mcs(t)
- [x] Use set_mcs_negation_complete to derive neg(Hpsi) in mcs(t)
- [ ] BLOCKED: Show this leads to contradiction (requires omega-rule)
- [N/A] Handle edge cases for domain boundaries (blocked by main proof)
- [ ] BLOCKED: Verify proof compiles without sorry

**Timing**: 3 hours (actual: 1.5 hours to analyze and document blocker)

**Files modified**:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - lemma with sorry

**Blocker Analysis**:
The IndexedMCSFamily coherence provides `backward_H: H psi in mcs(t) -> psi in mcs(s)`,
but we need the converse. The converse requires an omega-rule: deriving H psi from
{psi at time s : s < t}, which is an infinite set. Standard proof systems lack this.

**Future Options**:
1. Add H/G-completeness as axioms to IndexedMCSFamily structure
2. Prove for specific constructions (e.g., CoherentConstruction over Z with finite bounds)
3. Accept this as a limitation and document that backward Truth Lemma is not required

---

### Phase 3: Prove G-completeness Lemma [PARTIAL]

**Goal**: Establish symmetric property for universal future membership

**Status**: BLOCKED by same omega-rule limitation as H_completeness.

**Tasks**:
- [x] Define G_completeness lemma signature (symmetric to H_completeness)
- [x] Adapt H_completeness proof structure for forward temporal direction
- [ ] BLOCKED: Core proof (same omega-rule issue)

**Timing**: 0.5 hours (structure only)

**Files modified**:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - lemma with sorry

---

### Phase 4: Derive Witness Extraction Lemmas [COMPLETED]

**Goal**: Create convenient wrapper lemmas that extract witnesses from non-membership

**Status**: COMPLETED. The lemmas are defined and proven (by contrapositive), but they
inherit the sorries from H/G_completeness.

**Tasks**:
- [x] Define witness_from_not_H: `Hpsi not-in mcs(t) -> exists s < t. psi not-in mcs(s)`
- [x] Prove by contrapositive using H_completeness (proof complete, inherits sorry)
- [x] Define witness_from_not_G: `Gpsi not-in mcs(t) -> exists s > t. psi not-in mcs(s)`
- [x] Prove by contrapositive using G_completeness (proof complete, inherits sorry)
- [x] Add doc comments explaining the relationship to Truth Lemma

**Timing**: 0.5 hours

**Files modified**:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean`

**Note**: The witness extraction proofs are COMPLETE - they correctly invoke the
contrapositive of H/G_completeness. The sorries are in the underlying completeness lemmas.

---

### Phase 5: Complete Backward Truth Lemma Cases [BLOCKED]

**Goal**: Replace sorries at lines 423 and 441 with complete proofs

**Status**: BLOCKED - depends on Phase 2-3 (H/G-completeness). Cannot proceed without
resolving the omega-rule limitation.

**Alternative**: Document that the backward Truth Lemma cases are NOT REQUIRED for
the completeness theorem and update TruthLemma.lean comments to reference this task's
analysis.

**Tasks** (if proceeding with documentation-only approach):
- [ ] Update TruthLemma.lean comments at lines 423, 441 to reference task 741 analysis
- [ ] Add import of TemporalCompleteness to document the infrastructure exists
- [ ] Keep sorries with clearer documentation of why they're blocked

---

### Phase 6: Verification and Documentation [COMPLETED]

**Goal**: Ensure infrastructure is properly documented and integrated

**Tasks**:
- [x] Run full `lake build` to verify no regressions
- [x] Created TemporalCompleteness.lean with infrastructure
- [x] Update TruthLemma.lean to import and reference TemporalCompleteness
- [x] Update BackwardDirection.lean in Boneyard to reference task 741 findings
- [x] Create implementation summary documenting the omega-rule limitation

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
