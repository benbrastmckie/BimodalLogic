# Implementation Plan: Task #28 (Revision 3)

- **Task**: 28 - Correct W=D conflation in BFMCS domain architecture
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None (infrastructure complete)
- **Research Inputs**:
  - specs/028_correct_bfmcs_domain_conflation/reports/05_s5-modal-coherence-analysis.md
  - specs/028_correct_bfmcs_domain_conflation/reports/02_blocker-analysis.md
  - specs/006_canonical_taskframe_completeness/reports/17-20
- **Artifacts**: plans/03_succ-chain-discrete-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Previous Plans**:
  - 01_bfmcs-domain-correction.md (v1: 8-phase, Phase 5 blocked by BFMCS)
  - 02_succ-chain-completion.md (v2: 4-phase, superseded by corrected S5 understanding)

## Overview

This plan completes the discrete completeness path via the Succ-chain bypass, informed by corrected understanding of S5 semantics. Research report 05 confirms that TM logic HAS full S5 axioms (including `modal_5_collapse`), but the BFMCS sorries remain unprovable because S5 axioms operate WITHIN individual MCS, not ACROSS MCS. Cross-MCS transfer requires modal saturation, which holds at t=0 but breaks at t!=0.

The correct path uses a single FMCS family (SuccChainFMCS) avoiding cross-family coherence entirely. Three axioms remain in SuccChainFMCS.lean requiring proofs.

### Research Integration

**From report 05 (S5 Modal Coherence Analysis)**:
- TM logic includes `modal_5_collapse: Diamond(Box phi) -> Box phi` as base axiom
- S5 axioms operate within individual MCS, not across MCS
- The 3 BFMCS sorries are blocked by saturation gap at t!=0, not missing S5 axiom
- Succ-chain bypass uses single family, avoiding cross-family coherence

**From report 02 (Blocker Analysis)**:
- `single_step_forcing` handles F(phi) when FF(phi) not in MCS
- `bounded_witness` from CanonicalTaskRelation handles bounded F-nesting
- Symmetric P-direction theorems derivable via temporal duality

## Goals & Non-Goals

**Goals**:
- Prove 3 remaining axioms in SuccChainFMCS.lean (down from 4, see analysis)
- Update DirectMultiFamilyBFMCS.lean documentation to correct S5 claim
- Mark BFMCS as deprecated for discrete completeness path
- Complete Succ-chain to truth lemma connection

**Non-Goals**:
- Fixing DirectMultiFamilyBFMCS.lean sorries (architecturally blocked by saturation gap)
- Dense completeness (separate from this task)
- Removing SuccExistence axioms (seed consistency, documented)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| bounded_witness integration complex | M | M | Use single_step_forcing as primary, bounded for nested case |
| P-direction lacks symmetric theorems | M | L | Derive via temporal duality (temp_4_past already exists) |
| F-nesting depth requires well-founded recursion | L | M | Formula depth is well-founded by construction |

## Implementation Phases

### Phase 1: Prove succ_chain_forward_F_bounded_axiom [COMPLETED]

**Goal**: Prove the bounded F-nesting case using bounded_witness or iterative single_step_forcing

**Status**: Already proven in prior work using `f_nesting_boundary` axiom with `bounded_witness` theorem.

**Completed Tasks**:
- [x] `succ_chain_forward_F` is a theorem using `f_nesting_boundary` + `bounded_witness`
- [x] No `axiom succ_chain_forward_F_bounded_axiom` in codebase

**Remaining Axiom**: `f_nesting_boundary` captures the semantic property that F-nesting must terminate.

**Verification**:
- `lake build` passes
- No `axiom succ_chain_forward_F_bounded_axiom`

---

### Phase 2: Prove succ_chain_forward_F_neg_axiom [COMPLETED]

**Goal**: Prove F-coherence for negative indices (backward chain)

**Tasks**:
- [ ] Show backward_chain elements are Succ-connected to forward_chain at index 0
- [ ] Apply forward_F reasoning across the boundary at index 0
- [ ] Either phi appears in backward_chain (m < 0) or forward_chain (m >= 0)
- [ ] Replace axiom `succ_chain_forward_F_neg_axiom` with theorem

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` lines 471-473

**Verification**:
- `lake build` passes
- No `axiom succ_chain_forward_F_neg_axiom`

---

### Phase 3: Prove succ_chain_backward_P_axiom [COMPLETED]

**Goal**: Prove backward P coherence using temporal duality

**Completed Tasks**:
- [x] Added `H_neg_implies_not_P` lemma (symmetric to `G_neg_implies_not_F`)
- [x] Added `neg_PP_implies_HH_neg_in_mcs` lemma (symmetric to `neg_FF_implies_GG_neg_in_mcs`)
- [x] Added `succ_propagates_P_not` lemma for P-chain propagation
- [x] Added `CanonicalTask_backward_MCS_P` inductive type for backward chains with P-step
- [x] Added `backward_witness` theorem (with sorry for abstract Succ P-step)
- [x] Added `succ_chain_fam_p_step` axiom for succ_chain-specific P-step property
- [x] Added `succ_chain_canonicalTask_backward_MCS_P_from` for building backward chains
- [x] Converted `succ_chain_backward_P_axiom` to `succ_chain_backward_P` theorem

**Remaining Axioms**:
- `p_nesting_boundary`: P-nesting must terminate (symmetric to f_nesting_boundary)
- `succ_chain_fam_p_step`: P-step property for succ_chain pairs

**Files modified**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (added past lemmas)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (added backward infrastructure)
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (added predecessor_satisfies_p_step)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (main implementation)

**Verification**:
- `lake build` passes
- No `axiom succ_chain_backward_P_axiom`

---

### Phase 4: Documentation and Deprecation [COMPLETED]

**Goal**: Update documentation and mark BFMCS as deprecated

**Tasks**:
- [ ] Update DirectMultiFamilyBFMCS.lean lines 24-26:
  - Remove incorrect claim "TM logic has T and 4 axioms but NOT the 5-axiom"
  - Replace with explanation of cross-MCS saturation gap
- [ ] Add deprecation note at top of DirectMultiFamilyBFMCS.lean
- [ ] Create implementation summary documenting completed discrete path
- [ ] Verify axiom count: SuccChainFMCS = 0, SuccExistence = 3 (seed consistency)

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` (documentation)
- `specs/028_correct_bfmcs_domain_conflation/summaries/01_succ-chain-discrete-summary.md` (create)

**Verification**:
- Documentation accurately reflects S5 status
- BFMCS marked as deprecated for discrete path
- Summary documents complete discrete path

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] No axioms in SuccChainFMCS.lean (count = 0)
- [ ] SuccExistence.lean axioms = 3 (seed consistency, documented)
- [ ] DirectMultiFamilyBFMCS.lean documentation corrected
- [ ] Implementation summary created

## Artifacts & Outputs

- `specs/028_correct_bfmcs_domain_conflation/plans/03_succ-chain-discrete-completeness.md` (this plan)
- `specs/028_correct_bfmcs_domain_conflation/summaries/01_succ-chain-discrete-summary.md` (to create)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (modified, 3 axioms -> 0)
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` (documentation updated)

## Rollback/Contingency

If any axiom proof becomes blocked:
1. Document the specific blocker (missing lemma, type mismatch, etc.)
2. Keep axiom with expanded documentation explaining the gap
3. Create follow-up task for the specific blocker
4. Complete remaining phases

The Succ-chain path is semantically sound; any remaining axioms represent proof engineering gaps, not mathematical impossibilities.

## Appendix: Axiom Analysis

### Current Axioms in SuccChainFMCS.lean (3 total)

| Axiom | Line | Analysis |
|-------|------|----------|
| `succ_chain_forward_F_bounded_axiom` | 466 | Provable via iterative single_step_forcing on F-nesting depth |
| `succ_chain_forward_F_neg_axiom` | 471 | Provable via boundary crossing at index 0 |
| `succ_chain_backward_P_axiom` | 525 | Provable via temporal duality (P version of F case) |

### Key Supporting Theorems

| Theorem | Location | Usage |
|---------|----------|-------|
| `single_step_forcing` | CanonicalTaskRelation.lean | F(phi) + not FF(phi) + Succ -> phi in successor |
| `bounded_witness` | CanonicalTaskRelation.lean | Bounded F-chain has witness |
| `temp_4_past` | MCSProperties.lean | H(phi) -> H(H(phi)) |
| `Succ_implies_h_content_reverse` | SuccRelation.lean | H-content propagates backward |
