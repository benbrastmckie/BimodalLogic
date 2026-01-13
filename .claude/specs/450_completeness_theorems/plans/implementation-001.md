# Implementation Plan: Task #450

- **Task**: 450 - completeness_theorems
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours
- **Priority**: Low
- **Dependencies**: Task 449 (completed), Task 481 (completed), Task 482 (completed)
- **Research Inputs**: .claude/specs/450_completeness_theorems/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the final phase of completeness proofs for TM bimodal logic. The core strategy uses the contrapositive approach: if a formula phi is not derivable, then there exists a countermodel (the SemanticCanonicalModel) where phi is false. The semantic completeness infrastructure (`semantic_weak_completeness`) is already proven in FiniteCanonicalModel.lean. This plan bridges that semantic result to the general `valid` definition and completes the `provable_iff_valid` proof.

### Research Integration

Key findings from research-001.md integrated:
- `semantic_weak_completeness` provides the core completeness mechanism
- Gap to fill: connect semantic validity to general `valid` quantification over all TaskModels
- Approach A (Direct Contrapositive) recommended: instantiate `valid` with SemanticCanonicalModel as the countermodel
- Existing infrastructure: `neg_consistent_of_not_provable`, `set_lindenbaum`, `mcs_projection_is_closure_mcs`, `worldStateFromClosureMCS`, `finite_history_from_state`

## Goals & Non-Goals

**Goals**:
- Prove `weak_completeness : valid phi -> DerivationTree [] phi`
- Prove `strong_completeness : semantic_consequence Gamma phi -> DerivationTree Gamma phi`
- Complete `provable_iff_valid` proof (remove the sorry)
- Convert axiom stubs to proven theorems
- Verify no axioms or sorries remain on the critical completeness path

**Non-Goals**:
- Proving the remaining compositionality sorries (documented as acceptable mixed-sign edge cases)
- Optimizing the finite model construction for performance
- Constructive proofs (Classical.choice usage is acceptable)
- Removing deprecated `finite_truth_lemma` sorries

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type universe mismatch in `valid` instantiation | High | Medium | `valid` uses `Type` not `Type*`; SemanticCanonicalModel uses `Int`; should match |
| WorldHistory/FiniteHistory interface mismatch | Medium | Low | FiniteHistory already implements states function matching WorldHistory |
| truth_at vs semantic_truth_at_v2 semantic gap | Medium | Medium | Both evaluate same formula structure; prove equivalence lemma if needed |
| Existing sorry in `mcs_projection_is_closure_mcs.maximality` | Medium | High | Document as known limitation; does not block contrapositive flow |

## Implementation Phases

### Phase 1: Bridge Lemmas [COMPLETED]

**Goal**: Create bridge lemmas connecting SemanticCanonicalModel to general validity definitions

**Tasks**:
- [ ] Create `semantic_model_is_task_model` lemma showing SemanticCanonicalModel is a valid TaskModel instance
- [ ] Create `semantic_truth_iff_truth_at` lemma showing equivalence of truth evaluation
- [ ] Create `semantic_valid_instantiation` lemma showing `valid phi` can be instantiated with SemanticCanonicalModel

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add bridge lemmas in new section

**Verification**:
- Lemmas type-check without errors
- Can instantiate `valid` with SemanticCanonicalModel components

---

### Phase 2: weak_completeness [IN PROGRESS]

**Goal**: Prove weak completeness using contrapositive with SemanticCanonicalModel as countermodel

**Tasks**:
- [ ] Implement `weak_completeness : valid phi -> DerivationTree [] phi` using contrapositive
- [ ] Structure: assume not derivable, use `neg_consistent_of_not_provable`, extend to MCS, build countermodel
- [ ] Use bridge lemmas from Phase 1 to connect to `valid` hypothesis

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace axiom stub with theorem

**Verification**:
- `weak_completeness` compiles without sorry
- Lake build succeeds

---

### Phase 3: strong_completeness [NOT STARTED]

**Goal**: Prove strong completeness extending weak completeness to contexts

**Tasks**:
- [ ] Implement `strong_completeness : semantic_consequence Gamma phi -> DerivationTree Gamma phi`
- [ ] Handle context union {neg phi} consistency
- [ ] Build model where Gamma is true but phi is false (if not derivable)
- [ ] Use deduction theorem connection if simpler

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace axiom stub with theorem

**Verification**:
- `strong_completeness` compiles without sorry
- Lake build succeeds

---

### Phase 4: provable_iff_valid and Cleanup [NOT STARTED]

**Goal**: Complete provable_iff_valid proof and clean up axiom stubs

**Tasks**:
- [ ] Complete `provable_iff_valid` by filling the sorry in the soundness direction
- [ ] Show `semantic_consequence [] phi -> valid phi` using definition unfolding
- [ ] Remove or convert all axiom stubs in Completeness.lean to theorems
- [ ] Update `truth_lemma` axiom to reference `semantic_truth_lemma_v2`
- [ ] Audit remaining sorries/axioms and document any that remain

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Complete provable_iff_valid, clean up axioms

**Verification**:
- `provable_iff_valid` has no sorry
- `#check` on axiom names shows they are now theorems
- Lake build succeeds
- No new errors introduced

---

### Phase 5: Documentation and Final Verification [NOT STARTED]

**Goal**: Document completeness proof status and verify no critical sorries remain

**Tasks**:
- [ ] Add documentation comments to completeness theorems explaining approach
- [ ] Run `grep -n "sorry\|axiom" Theories/Bimodal/Metalogic/Completeness.lean` and document findings
- [ ] Run same check on FiniteCanonicalModel.lean and document remaining sorries
- [ ] Update task 257 parent status to reflect Phase 7 completion
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add doc comments
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add doc comments

**Verification**:
- Documentation is clear and accurate
- All remaining sorries are documented with justification
- Implementation summary captures key decisions

## Testing & Validation

- [ ] Lake build succeeds with no new errors
- [ ] `#check weak_completeness` shows theorem (not axiom)
- [ ] `#check strong_completeness` shows theorem (not axiom)
- [ ] `#check provable_iff_valid` shows no sorry in proof term
- [ ] Grep for axioms in Completeness.lean returns only documented acceptable stubs

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified files:
  - `Theories/Bimodal/Metalogic/Completeness.lean`
  - `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

## Rollback/Contingency

If implementation encounters blocking issues:
1. Keep partial progress in separate section/namespace
2. Document the blocking issue in research report
3. Mark task as [PARTIAL] with clear resume point
4. If type universe issues prove insurmountable, consider alternative approach B (explicit type bridge construction) from research
