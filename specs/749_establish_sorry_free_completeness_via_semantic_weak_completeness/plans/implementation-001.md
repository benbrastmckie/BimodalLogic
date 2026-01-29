# Implementation Plan: Task #749

- **Task**: 749 - Establish sorry-free completeness using semantic_weak_completeness
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: None (builds on existing sorry-free semantic_weak_completeness)
- **Research Inputs**: specs/749_establish_sorry_free_completeness_via_semantic_weak_completeness/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task bridges the gap between `valid` (truth in all models) and `semantic_weak_completeness` (which works with SemanticWorldState truth). The key insight from research is that we need to prove `valid phi implies semantic_truth_at_v2` for all SemanticWorldStates, then chain with the existing sorry-free `semantic_weak_completeness` to get a sorry-free completeness theorem.

### Research Integration

From research-001.md:
- `semantic_weak_completeness` at SemanticCanonicalModel.lean:448 is fully proven with no sorries
- The type gap: `valid` quantifies over all TaskModels/WorldHistories/times, while `semantic_truth_at_v2` quantifies over SemanticWorldStates
- Key existing lemma: `semantic_world_state_has_world_history` provides WorldHistory for each SemanticWorldState
- Recommended approach: Prove truth correspondence lemma then chain results

## Goals & Non-Goals

**Goals**:
- Prove `truth_at_semantic_model_iff`: truth_at in SemanticCanonicalModel equals semantic_truth_at_v2
- Prove `valid_implies_all_semantic_truth`: validity implies semantic truth at all SemanticWorldStates
- Chain with semantic_weak_completeness to get `sorry_free_weak_completeness: valid phi -> provable phi`
- All theorems must compile without `sorry`

**Non-Goals**:
- Fixing the existing truth bridge in FiniteModelProperty.lean (this approach avoids it)
- Proving soundness (separate concern, has its own sorry)
- Proving strong completeness (extension, not core goal)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth correspondence proof complexity | High | Medium | Start with simpler cases (prop variables, negation), build incrementally |
| Temporal operator cases (G, H) may need auxiliary lemmas | Medium | Medium | Use existing FiniteHistory structure which provides bounded time |
| Modal operator cases (box) may diverge from semantic model | Medium | Low | SemanticCanonicalModel valuation is designed to match; use semantic_valuation definition |
| Type universe issues with validity quantification | Medium | Low | validity uses `Type` not `Type*`; specialize carefully |

## Implementation Phases

### Phase 1: Truth Correspondence for Base Cases [IN PROGRESS]

**Goal**: Prove truth_at equals semantic_truth_at_v2 for propositional cases (variables, negation, conjunction)

**Tasks**:
- [ ] Add helper lemma `truth_at_var_iff_semantic` for propositional variables
- [ ] Add helper lemma `truth_at_neg_iff_semantic` for negation
- [ ] Add helper lemma `truth_at_conj_iff_semantic` for conjunction
- [ ] Verify each case compiles without sorry

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add helper lemmas after semantic_truth_at_v2 definition

**Verification**:
- `lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel` succeeds
- Each helper lemma has no sorry

---

### Phase 2: Truth Correspondence for Modal Cases [NOT STARTED]

**Goal**: Prove truth_at equals semantic_truth_at_v2 for box operator

**Tasks**:
- [ ] Analyze semantic_task_rel definition and how it relates to WorldHistory task relation
- [ ] Add helper lemma `truth_at_box_iff_semantic` for box modality
- [ ] Verify lemma uses semantic_task_rel correctly
- [ ] Confirm no sorry remains

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add modal case helper

**Verification**:
- `lake build` succeeds
- Box case lemma compiles without sorry

---

### Phase 3: Truth Correspondence for Temporal Cases [NOT STARTED]

**Goal**: Prove truth_at equals semantic_truth_at_v2 for G (always future) operator

**Tasks**:
- [ ] Analyze how BoundedTime constrains temporal quantification
- [ ] Add helper lemma `truth_at_G_iff_semantic` for G operator
- [ ] Verify the bounded time domain aligns with closure membership requirements
- [ ] Confirm no sorry remains

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add temporal case helper

**Verification**:
- `lake build` succeeds
- G case lemma compiles without sorry

---

### Phase 4: Main Truth Correspondence Theorem [NOT STARTED]

**Goal**: Combine cases into main `truth_at_semantic_model_iff` theorem

**Tasks**:
- [ ] Define main theorem statement with proper hypotheses (WorldHistory, domain membership, state equality)
- [ ] Prove by structural induction on formula, using helper lemmas from phases 1-3
- [ ] Handle remaining cases (H operator, disjunction if not derived)
- [ ] Verify no sorry remains

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add main theorem

**Verification**:
- `lake build` succeeds
- `truth_at_semantic_model_iff` has no sorry

---

### Phase 5: Valid Implies Semantic Truth [NOT STARTED]

**Goal**: Prove `valid_implies_all_semantic_truth` using truth correspondence

**Tasks**:
- [ ] Define theorem: `valid phi -> forall w, semantic_truth_at_v2 phi w (origin) phi`
- [ ] Use `semantic_world_state_has_world_history` to get WorldHistory for each w
- [ ] Apply validity to SemanticCanonicalModel
- [ ] Use truth correspondence to extract semantic_truth_at_v2

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add theorem after truth correspondence

**Verification**:
- `lake build` succeeds
- Theorem has no sorry

---

### Phase 6: Sorry-Free Weak Completeness [NOT STARTED]

**Goal**: Prove `sorry_free_weak_completeness: valid phi -> provable phi`

**Tasks**:
- [ ] Define theorem chaining `valid_implies_all_semantic_truth` with `semantic_weak_completeness`
- [ ] Verify the chain compiles
- [ ] Add documentation explaining this is the sorry-free completeness result
- [ ] Update module docstring to highlight this theorem

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add final theorem
- `Theories/Bimodal/Metalogic/FMP/README.md` - document new result

**Verification**:
- `lake build` succeeds
- `sorry_free_weak_completeness` has no sorry
- Documentation updated

---

## Testing & Validation

- [ ] Full `lake build` succeeds with no errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` returns no matches in new theorems
- [ ] New theorems are exported and usable from other modules
- [ ] Run `lake build Bimodal.Metalogic.FMP.FiniteModelProperty` to ensure FMP module still compiles

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- Modified: `Theories/Bimodal/Metalogic/FMP/README.md`
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the truth correspondence proof proves intractable:
1. Document the specific obstacle in implementation summary
2. Consider alternative approaches:
   - Approach C from research: Prove `decide_complete` (decidability route)
   - Partial result: Accept `semantic_weak_completeness` as the sorry-free completeness for semantic notion
3. Preserve any partial progress as commented-out code or separate helper lemmas
4. Create follow-up task for alternative approach

The existing code remains unchanged if implementation fails - all changes are additive.
