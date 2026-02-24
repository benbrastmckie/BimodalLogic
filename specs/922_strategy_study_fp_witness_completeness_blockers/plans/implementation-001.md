# Implementation Plan: Task #922 - Canonical Quotient Completeness Proof

- **Task**: 922 - strategy_study_fp_witness_completeness_blockers
- **Status**: [IMPLEMENTING]
- **Effort**: 24-36 hours
- **Dependencies**: Task 916 (partial infrastructure in DovetailingChain.lean, WitnessGraph.lean)
- **Research Inputs**: specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-001.md, research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the **Canonical Quotient** approach for proving bimodal completeness, as recommended by the strategy study research. The approach inverts the construction order from all 12 failed prior plans: instead of building a linear chain and proving forward_F, we build the canonical model where forward_F is trivial, then embed into Int. The critical risk is the linearity proof from TM axioms (research-002 estimates 60-70% confidence). Phase 1 is designed as a fail-fast validation of the linearity argument.

### Research Integration

**From research-001**:
- The root cause of all 12 prior plan failures is the "linear chain topology constraint" - forcing all F-obligations to share a single future sequence
- The Canonical Quotient avoids this by giving each F-obligation its own fresh Lindenbaum witness
- forward_F becomes trivial: `F(psi) in M` -> `{psi} union GContent(M)` is consistent -> Lindenbaum -> witness MCS

**From research-002**:
- The linearity proof from temp_a axiom is the critical risk (revised confidence: 60-70%)
- If linearity cannot be proven from existing TM axioms, fallback is adding an explicit linearity axiom (sound for linear integer time semantics)
- Mathlib provides `Order.embedding_from_countable_to_dense` for the Int embedding step

## Goals & Non-Goals

**Goals**:
- Prove forward_F and backward_P for bimodal completeness with zero sorries
- Implement the Canonical Quotient approach from research-001
- Validate the linearity argument from TM axioms early (fail-fast)
- Reuse existing infrastructure: `forward_temporal_witness_seed_consistent`, `set_lindenbaum`, `GContent_mono`, `GContent_path_propagates`
- Produce a BFMCS Int satisfying the TemporalCoherentFamily interface

**Non-Goals**:
- Modify the existing TruthLemma, BMCSTruth, or Completeness modules (only provide a new BFMCS Int construction)
- Preserve or use the WitnessGraph.lean infrastructure (kept for reference but not built upon)
- Introduce any axioms (though Phase 1 fallback permits adding a linearity axiom if mathematically necessary)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Linearity not derivable from TM axioms | High | 30-40% | Phase 1 fail-fast; fallback to adding linearity axiom (sound for linear time) |
| Mathlib embedding theorem API incompatibility | Medium | 10-20% | Phase 3 can construct embedding manually (~4 extra hours) |
| GContent transitivity across canonical frame | Low | 10% | Existing `GContent_path_propagates` should transfer directly |
| BFMCS Int interface incompatibility | Low | 5% | Interface is well-defined; only `mcs : Int -> Set Formula` with forward_G/backward_H needed |
| Formula countability proof missing | Low | 5% | Formula derives Countable; verify early in Phase 2 |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `DovetailingChain.lean`: `dovetailingChain_forward_F`, `dovetailingChain_backward_P`
- These are the completeness blockers this plan addresses

### Expected Resolution
- Phase 4 provides an alternative BFMCS Int construction (not using DovetailingChain)
- The sorries in DovetailingChain remain but become dead code
- Completeness theorem uses the new CanonicalQuotient construction

### New Sorries
- None expected. The Canonical Quotient approach has trivial forward_F/backward_P proofs.
- If Phase 1 linearity fails, a new axiom may be added (not a sorry, but declared technical debt requiring future derivation).

### Remaining Debt
After this implementation:
- 0 sorries in the active completeness proof chain
- DovetailingChain.lean sorries become inert (not in dependency graph)
- Publication readiness achieved for completeness theorem

---

## Implementation Phases

### Phase 1: Linearity Validation (Fail-Fast) [COMPLETED]

- **Dependencies:** None
- **Goal:** Determine whether the linearity schema is derivable from TM axioms. This is the highest-risk step and MUST be resolved before proceeding.

**Tasks**:
- [ ] Analyze TM axioms in `Theories/Bimodal/ProofSystem/Axioms.lean` for linearity content
- [ ] Attempt to prove the linearity schema: `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`
- [ ] If derivable: document derivation, proceed to Phase 2
- [ ] If NOT derivable: evaluate adding linearity axiom to TM (sound for linear integer time semantics)
- [ ] Decision checkpoint: proceed with canonical quotient OR escalate for review

**Timing**: 4-6 hours (research indicates this is the bottleneck)

**Files to create/modify**:
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` (new) - derivation attempts
- If fallback needed: `Theories/Bimodal/ProofSystem/Axioms.lean` - add linearity axiom

**Verification**:
- Either: `TM_proves_linearity_schema` lemma proven
- Or: `temp_linearity` axiom added with soundness argument documented
- Decision documented in plan Progress subsection

**Progress:**

**Session: 2026-02-24, sess_1771960688_9a2e76**
- Added: `temp_linearity` axiom constructor to `Axiom` inductive type in `Axioms.lean`
- Added: `axiom_temp_linearity_valid` soundness proof in `SoundnessLemmas.lean` (local validity)
- Added: `temp_linearity_valid` soundness proof in `Soundness.lean` (global validity)
- Added: `axiom_swap_valid` case for `temp_linearity` in `SoundnessLemmas.lean` (past version via swap)
- Added: `LinearityDerivedFacts.lean` with non-derivability analysis and counterexample documentation
- Completed: Phase 1 fail-fast validation - linearity NOT derivable from existing TM axioms (3-point branching counterexample). Fallback path taken: added linearity axiom to TM (sound for linear integer time)
- Decision: Proceed with Canonical Quotient approach using the new linearity axiom
- Axioms: 16 -> 17 (temp_linearity added, sound for linear time, technical debt requiring documentation)

---

### Phase 2: Canonical Frame Definition [IN PROGRESS]

- **Dependencies:** Phase 1
- **Goal:** Define the canonical frame structure and prove forward_F/backward_P are trivial.

**Tasks**:
- [ ] Define `CanonicalR : Set Formula -> Set Formula -> Prop` as GContent subset inclusion
- [ ] Prove `canonical_forward_F`: `F(psi) in M` implies exists witness MCS with `psi` and GContent-reachable from M
- [ ] Prove `canonical_backward_P`: symmetric for past, using HContent
- [ ] Prove `canonical_forward_G`: `G(phi) in M` and `CanonicalR M M'` implies `phi in M'`
- [ ] Prove `canonical_backward_H`: symmetric for past
- [ ] Verify Formula is Countable (for Phase 3)

**Timing**: 4-6 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (new) - canonical frame definitions
- Import existing: `forward_temporal_witness_seed_consistent`, `set_lindenbaum`, `GContent`, `HContent`

**Verification**:
- All four temporal properties (forward_F, backward_P, forward_G, backward_H) proven for canonical frame
- No sorries in `CanonicalFrame.lean`
- `lake build` succeeds

---

### Phase 3: Linearity and Embedding [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove the reachable canonical fragment is linearly ordered and embed into Int.

**Tasks**:
- [ ] Define reachable fragment: MCSes accessible from root via CanonicalR chains
- [ ] Prove reachable fragment forms a linear order (using linearity from Phase 1)
- [ ] Prove reachable fragment is countable (Formula is countable, MCS determined by theory)
- [ ] Apply Mathlib `Order.embedding_from_countable_to_dense` or construct embedding manually
- [ ] Compose embedding with canonical MCS assignment to get `mcs : Int -> Set Formula`

**Timing**: 6-10 hours (dependent on Mathlib API compatibility)

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` (new) - linearity + embedding
- May need Mathlib import for `Order.embedding_from_countable_to_dense`

**Verification**:
- `canonical_order_linear` lemma proven
- `canonical_embedding : CanonicalFragment root ↪o Int` constructed
- No sorries in `CanonicalEmbedding.lean`

---

### Phase 4: BFMCS Int Construction [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Assemble the BFMCS Int structure satisfying TemporalCoherentFamily interface.

**Tasks**:
- [ ] Define `canonicalBFMCS : (root : Set Formula) -> SetMaximalConsistent root -> BFMCS Int`
- [ ] Prove forward_G property lifts from canonical frame through embedding
- [ ] Prove backward_H property lifts from canonical frame through embedding
- [ ] Prove MCS property for each Int position
- [ ] Wire into existing `temporal_coherent_family_exists_Int` or replace it

**Timing**: 4-6 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` (new) - BFMCS construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - wire in new construction

**Verification**:
- `canonicalBFMCS` satisfies BFMCS structure
- `temporal_coherent_family_exists_Int` uses `canonicalBFMCS` construction
- Downstream completeness proofs unchanged and still work
- No sorries introduced

---

### Phase 5: Integration and Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify full completeness proof works end-to-end with zero sorries.

**Tasks**:
- [ ] Run `lake build` and verify no errors
- [ ] Verify `Completeness.lean` compiles with new BFMCS construction
- [ ] Run `lean_verify` on completeness theorem to check axiom dependencies
- [ ] Document any remaining technical debt (DovetailingChain sorries now inert)
- [ ] Update proof architecture documentation if needed

**Timing**: 2-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - verify still compiles
- `docs/` - update architecture if needed

**Verification**:
- `lake build` succeeds with 0 errors
- Completeness theorem proven without sorries in active dependency chain
- `lean_verify` shows no unexpected axiom dependencies

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase completion
- [ ] No sorries introduced in new files
- [ ] `Completeness.lean` compiles and works with new BFMCS construction
- [ ] `lean_verify` on completeness theorem shows clean axiom dependencies
- [ ] forward_F/backward_P are proven (not sorry'd) in CanonicalFrame.lean

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` (Phase 1)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (Phase 2)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` (Phase 3)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` (Phase 4)
- `specs/922_strategy_study_fp_witness_completeness_blockers/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the Canonical Quotient approach fails:

1. **Phase 1 failure (linearity not provable)**: Evaluate adding linearity axiom. If unacceptable, escalate for review. The existing DovetailingChain infrastructure remains intact.

2. **Phase 2-4 failure (unexpected Lean 4 obstacles)**: New files can be deleted without affecting existing codebase. DovetailingChain.lean remains the active construction with its 2 sorries.

3. **Phase 5 failure (integration issues)**: Revert `TemporalCoherentConstruction.lean` changes. New CanonicalQuotient files remain as alternative construction for future use.

**Rollback command**: `git revert` commits from this task, delete new files.

## Critical Success Factors

1. **Phase 1 must succeed or have acceptable fallback**: The linearity argument is the gate. If it fails without a clean fallback (adding linearity axiom), the entire approach is blocked.

2. **Zero sorries in new code**: Every phase produces sorry-free Lean code. No sorry is ever tolerated during development (technical debt is NEVER acceptable per task constraint).

3. **Preserve existing interface**: The TemporalCoherentFamily interface remains unchanged. Only the BFMCS Int construction changes.
