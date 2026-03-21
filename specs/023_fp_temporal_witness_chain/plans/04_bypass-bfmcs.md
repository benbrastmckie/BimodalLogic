# Implementation Plan: Task #23 (Revision 4)

- **Task**: 23 - F/P Temporal Witness Chain Construction
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (infrastructure exists)
- **Research Inputs**: specs/023_fp_temporal_witness_chain/reports/09_blocker-analysis.md
- **Artifacts**: plans/04_bypass-bfmcs.md (this file)
- **Standards**: plan-format.md, status-markers.md
- **Type**: lean4
- **Lean Intent**: false

## Revision Notes

**Previous Plans**:
- `01_succ-based-fp-witnesses.md`: Initial Succ approach
- `02_no-axioms-fp-witnesses.md`: NO AXIOMS constraint (Path A/B)
- `03_succ-chain-construction.md`: SuccChain construction, blocked on BFMCS

**Key Finding from Report 09**:
- **BFMCS is wrong abstraction** for TM logic (T4)
- BFMCS `modal_forward` requires S5 cross-family coherence
- **Bypass BFMCS entirely** using SuccChainFMCS + TaskFrame + WorldHistory
- Both `SuccChainTaskFrame.lean` and `SuccChainWorldHistory.lean` are **sorry-free**

## Overview

This plan eliminates the BFMCS dependency by:
1. Proving the 3 SuccChainFMCS axioms using `bounded_witness`
2. Wiring completeness through SuccChainTaskFrame + SuccChainWorldHistory
3. Marking BFMCS as deprecated for discrete case

**Critical Architecture Insight**:
TM logic has T and 4 axioms but NOT the 5-axiom (Euclidean). BFMCS requires `Box phi in fam.mcs t -> phi in fam'.mcs t` for ALL families - this is S5 universal accessibility. Single-family FMCS + TaskFrame is correct.

## Goals & Non-Goals

**Goals**:
- Prove 3 SuccChainFMCS axioms (convert to theorems)
- Wire completeness via TaskFrame + WorldHistory path
- Eliminate dependency on IntBFMCS/DirectMultiFamilyBFMCS for F/P
- Document BFMCS as not needed for discrete completeness

**Non-Goals**:
- Fixing BFMCS (architectural mismatch, not a bug)
- Creating SuccChainBFMCS (would inherit same S5 problem)
- Modifying IntBFMCS (deprecated for F/P)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| bounded_witness application harder than expected | M | L | Core math proven; this is wiring |
| Symmetric past infrastructure complex | M | M | Follow forward pattern exactly |
| TaskFrame wiring unclear | M | L | Files exist and are sorry-free |

## Implementation Phases

### Phase 1: Prove Forward F Axioms [COMPLETED]

**Goal**: Convert `succ_chain_forward_F_bounded_axiom` and `succ_chain_forward_F_neg_axiom` to theorems.

**Tasks**:
- [ ] Implement `F_nesting_boundary`: Prove existence of F-depth in MCS
  ```lean
  theorem F_nesting_boundary (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
      ∃ n, iter_F n phi ∈ M ∧ iter_F (n + 1) phi ∉ M
  ```
- [ ] Prove `succ_chain_forward_F_bounded_axiom` using:
  - `bounded_witness` from CanonicalTaskRelation.lean
  - `forward_chain_canonicalTask_forward_MCS_from` from SuccChainFMCS.lean
  - `F_nesting_boundary` for finding the depth
- [ ] Prove `succ_chain_forward_F_neg_axiom` (same approach, negative indices)
- [ ] Run `lake build` to verify

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Files to reference**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - bounded_witness

**Verification**:
- 2 axioms converted to theorems
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds

---

### Phase 2: Build Symmetric Past Infrastructure [PARTIAL]

**Goal**: Prove `succ_chain_backward_P_axiom` by building symmetric infrastructure.

**Tasks**:
- [ ] Define `iter_P` (symmetric to `iter_F`)
- [ ] Define/verify `CanonicalTask_backward_MCS` structure
- [ ] Prove `bounded_witness_past` theorem (symmetric to bounded_witness)
- [ ] Prove `succ_chain_backward_P_axiom` using bounded_witness_past
- [ ] Run `lake build` to verify

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - add iter_P, bounded_witness_past
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - prove axiom

**Verification**:
- All 3 axioms converted to theorems
- `lake build` succeeds
- `grep -c "^axiom" SuccChainFMCS.lean` returns 0

---

### Phase 3: Wire Completeness via TaskFrame [COMPLETED]

**Goal**: Connect SuccChainFMCS to completeness using sorry-free TaskFrame/WorldHistory.

**Tasks**:
- [ ] Verify `SuccChainTaskFrame.lean` exports `CanonicalTaskTaskFrame : TaskFrame Int`
- [ ] Verify `SuccChainWorldHistory.lean` exports `succ_chain_history`
- [ ] Create `SuccChainDiscreteCompleteness.lean` wiring:
  - SuccChainTemporalCoherent (wraps SuccChainFMCS)
  - CanonicalTaskTaskFrame
  - succ_chain_history
  - Completeness theorem connection
- [ ] Mark IntBFMCS forward_F/backward_P as deprecated in documentation

**Timing**: 1-2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainDiscreteCompleteness.lean` (optional - may wire in existing file)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - add deprecation comment

**Verification**:
- Discrete completeness compiles without IntBFMCS F/P
- `lake build` succeeds

---

### Phase 4: Cleanup and Documentation [COMPLETED]

**Goal**: Document architectural decision and create summary.

**Tasks**:
- [ ] Add header comment to DirectMultiFamilyBFMCS.lean explaining S5 vs T4 issue
- [ ] Create implementation summary documenting:
  - BFMCS bypass rationale
  - TaskFrame + WorldHistory path
  - Axiom elimination results
- [ ] Final verification: `lake build` on full project

**Timing**: 30 min

**Files to create**:
- `specs/023_fp_temporal_witness_chain/summaries/03_bypass-bfmcs-summary.md`

**Verification**:
- All documentation complete
- Full project builds

## Files Summary

| File | Status | Action |
|------|--------|--------|
| `SuccChainFMCS.lean` | EXISTS (3 axioms) | Prove all 3 axioms |
| `CanonicalTaskRelation.lean` | EXISTS | Add iter_P, bounded_witness_past |
| `SuccChainTaskFrame.lean` | EXISTS (sorry-free) | Reference only |
| `SuccChainWorldHistory.lean` | EXISTS (sorry-free) | Reference only |
| `IntBFMCS.lean` | EXISTS | Add deprecation comment |
| `DirectMultiFamilyBFMCS.lean` | EXISTS | Add architectural note |

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -rn "^axiom" SuccChainFMCS.lean` shows 0 matches after Phase 2
- [ ] TaskFrame + WorldHistory path compiles
- [ ] IntBFMCS F/P sorries no longer block completeness

## Artifacts & Outputs

- `specs/023_fp_temporal_witness_chain/plans/04_bypass-bfmcs.md` - this plan
- `specs/023_fp_temporal_witness_chain/summaries/03_bypass-bfmcs-summary.md` - implementation summary
- Modified Lean files as listed

## Rollback/Contingency

**If axiom proofs too complex**:
- Accept 3 axioms as semantic (still better than 4 sorries + 1 axiom)
- Document as "minimal axiom set for discrete completeness"

**If TaskFrame wiring unclear**:
- Examine DovetailedTimelineQuot pattern (task 30) for guidance
- Both use TaskFrame + WorldHistory structure
