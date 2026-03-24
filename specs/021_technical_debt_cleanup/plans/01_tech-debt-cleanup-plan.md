# Implementation Plan: Task #21

- **Task**: 21 - Technical Debt Cleanup
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: None (standalone cleanup task)
- **Research Inputs**: reports/02_team-research.md, reports/01_tech-debt-audit.md
- **Artifacts**: plans/01_tech-debt-cleanup-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Clean up technical debt accumulated across tasks 9-20 metalogic refactoring track. The primary focus is **axiom elimination** — axioms are unacceptable technical debt in a formal verification project. Secondary focus is removing dead code, unused helpers, and marking deprecated constructions. Research identified 10 Lean axioms total: 2 trivially eliminable now, 3 medium-effort to prove, 2 on dead-code paths (mark incomplete or delete), and 3 pre-approved for task 19 scope.

### Research Integration

Key findings from 02_team-research.md:
- **F_top_propagates** and **P_top_propagates** (SuccChainFMCS.lean) are trivially derivable — already proven as theorems in the same file
- **succ_chain_forward_F_axiom** and **succ_chain_backward_P_axiom** are dovetailing gaps on dead-code paths — no downstream importers
- Deferral seed axioms (SuccExistence.lean) are derivable with medium proof effort
- **canonicalR_irreflexive_axiom** is permanently justified (modally non-definable)
- **temp_linearity** needs documentation as permanent axiom

## Goals & Non-Goals

**Goals**:
- Eliminate `F_top_propagates` and `P_top_propagates` axioms (trivial one-liners)
- Eliminate 3 deferral seed axioms in SuccExistence.lean (medium proof effort)
- Mark dovetailing gap axioms as incomplete or delete dead-code files
- Document permanent axioms appropriately
- Clean up unused helpers identified in debt audit

**Non-Goals**:
- Addressing task 19 scope axioms (discrete_Icc_finite_axiom, old pipeline axioms)
- Full dovetailing construction to eliminate succ_chain_forward_F/backward_P
- Refactoring ClosedFlagIntBFMCS.lean bridge (requires task 15 completion assessment)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof difficulty for deferral seed axioms | H | M | Start with weakening lemma approach; fallback to documenting as harder-than-expected |
| Breaking downstream code by removing axioms | H | L | Verify lake build passes after each phase |
| Dead file deletion causing import errors | M | L | Check all import chains before deletion |

## Implementation Phases

### Phase 1: Trivial Axiom Elimination [NOT STARTED]

**Goal**: Replace F_top_propagates and P_top_propagates axioms with one-liner proofs

**Tasks**:
- [ ] Replace `F_top_propagates` axiom (line 150-152) with proof using `SetMaximalConsistent.contains_F_top`
- [ ] Update `ForwardChainElement.next.has_F_top` (line 158-163) to use the proof directly
- [ ] Replace `P_top_propagates` axiom (line 206-208) with proof using `SetMaximalConsistent.contains_P_top`
- [ ] Update `BackwardChainElement.prev.has_P_top` (line 214-219) to use the proof directly
- [ ] Run `lake build` to verify no errors

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — replace 2 axioms with theorems

**Verification**:
- `lake build` passes
- `grep -r "axiom F_top_propagates\|axiom P_top_propagates" Theories/` returns nothing

---

### Phase 2: Dead-Code Path Resolution [NOT STARTED]

**Goal**: Mark dovetailing gap axioms as incomplete and handle dead-code files

**Tasks**:
- [ ] Add docstring to `succ_chain_forward_F_axiom` (line 417) explaining dovetailing gap
- [ ] Add docstring to `succ_chain_backward_P_axiom` (line 427) explaining dovetailing gap
- [ ] Add comment to `SuccChainTemporalCoherent` (line 448-451) noting incomplete proof path
- [ ] Assess whether to move SuccChainTaskFrame.lean and SuccChainWorldHistory.lean to Boneyard or add incomplete markers
- [ ] If moving to Boneyard: update import in SuccChainWorldHistory.lean, then move both files
- [ ] Run `lake build` to verify

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — add documentation
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean` — mark/move
- `Theories/Bimodal/Metalogic/Bundle/SuccChainWorldHistory.lean` — mark/move

**Verification**:
- Dovetailing gap clearly documented
- Dead files either in Boneyard or have clear incomplete markers
- `lake build` passes

---

### Phase 3: Deferral Seed Axiom - Successor [NOT STARTED]

**Goal**: Prove `successor_deferral_seed_consistent_axiom` using weakening approach

**Tasks**:
- [ ] Create helper lemma: weakening preserves consistency (`{ψ} ∪ S` consistent → `{ψ ∨ χ} ∪ S` consistent)
- [ ] Apply weakening to `forward_temporal_witness_seed_consistent` from WitnessSeed.lean
- [ ] Show that deferral disjunctions are weakenings of F-obligations
- [ ] Prove `successor_deferral_seed_consistent_axiom` using the helper
- [ ] Convert axiom to theorem
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — lines 266-269, add proof

**Verification**:
- `successor_deferral_seed_consistent_axiom` replaced by theorem
- `lake build` passes
- No downstream breakage

---

### Phase 4: Deferral Seed Axiom - Predecessor [NOT STARTED]

**Goal**: Prove `predecessor_deferral_seed_consistent_axiom` using symmetric approach

**Tasks**:
- [ ] Apply symmetric weakening argument to h_content and P-obligations
- [ ] Leverage duality with successor proof
- [ ] Prove `predecessor_deferral_seed_consistent_axiom`
- [ ] Convert axiom to theorem
- [ ] Run `lake build` to verify

**Timing**: 45 minutes (incremental from Phase 3)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — lines 311-314, add proof

**Verification**:
- `predecessor_deferral_seed_consistent_axiom` replaced by theorem
- `lake build` passes

---

### Phase 5: Predecessor F-Step Axiom [NOT STARTED]

**Goal**: Prove `predecessor_f_step_axiom` using g/h duality

**Tasks**:
- [ ] Review g/h duality lemmas in MCSProperties.lean and SuccRelation.lean
- [ ] Construct proof using `h_content_subset_implies_g_content_reverse` and seed structure
- [ ] Fix circularity note in docstring (line 505-514) — justification is correct but wording is circular
- [ ] Prove `predecessor_f_step_axiom`
- [ ] Convert axiom to theorem
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — lines 516-519, add proof

**Verification**:
- `predecessor_f_step_axiom` replaced by theorem
- Docstring circularity fixed
- `lake build` passes

---

### Phase 6: Documentation and Final Cleanup [NOT STARTED]

**Goal**: Document permanent axioms and clean up dead code helpers

**Tasks**:
- [ ] Add documentation to `temp_linearity` axiom (Axioms.lean) noting it is permanent (linearity not derivable from other axioms)
- [ ] Document `canonicalR_irreflexive_axiom` as permanently justified (modally non-definable per Gabbay 1981)
- [ ] Review CanonicalTaskRelation.lean for 3 redundant lemmas mentioned in audit (lines 183-187, 439, 457-479)
- [ ] Delete redundant lemmas if confirmed unused
- [ ] Run `lake build` to verify
- [ ] Run final axiom count check

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` — temp_linearity documentation
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` — canonicalR_irreflexive_axiom documentation
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — delete redundant lemmas

**Verification**:
- Permanent axioms clearly documented
- `grep -c "^axiom" Theories/` shows reduced count
- `lake build` passes

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Axiom count reduced from 10 to 5 (2 trivial + 3 deferral eliminated, 2 dovetailing documented, 3 deferred to task 19)
- [ ] No downstream imports broken
- [ ] All eliminated axioms converted to theorems with complete proofs
- [ ] Permanent axioms have clear documentation justifying their retention

## Artifacts & Outputs

- `plans/01_tech-debt-cleanup-plan.md` (this file)
- `summaries/01_tech-debt-cleanup-summary.md` (upon completion)

## Rollback/Contingency

If proofs for deferral seed axioms prove harder than expected:
1. Document proof difficulty in axiom docstrings
2. Mark as "medium effort, justified semantically" rather than leaving as unexplained axioms
3. Create follow-up task for proof completion
4. Proceed with other phases (trivial eliminations, documentation, dead code cleanup)

The trivial axiom elimination (Phase 1) and documentation (Phase 6) can proceed regardless of proof difficulty in Phases 3-5.
