# Implementation Plan: Task #596

- **Task**: 596 - Constructive Finite Model Bounds
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: Medium
- **Dependencies**: Task 597 (main_provable_iff_valid in Metalogic_v2)
- **Research Inputs**: specs/596_constructive_finite_model_bounds/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace the trivial identity-based Finite Model Property proof in `Metalogic_v2/Representation/FiniteModelProperty.lean` with a constructive implementation that provides explicit finite model bounds of `2^|closure(phi)|`. The approach uses the existing `SemanticWorldState` and `SemanticCanonicalModel` infrastructure, requiring resolution of approximately 15-20 sorries in the semantic infrastructure before connecting it to a proper constructive FMP statement. Once proven with zero sorries, the old trivial implementation will be archived to `Bimodal/Boneyard/`.

### Research Integration

Key findings from research-001.md:
- Current trivial witness at FiniteModelProperty.lean lines 176-187 simply unpacks/repacks satisfiability
- Extensive infrastructure exists in FiniteCanonicalModel.lean (4000+ lines)
- SemanticWorldState provides filtration-based finite quotient
- `semantic_truth_lemma_v2` and `semantic_weak_completeness` are already proven
- Approximately 15-20 sorries in semantic infrastructure need resolution
- Target: `Fintype.card (SemanticWorldState phi) <= 2^(closureSize phi)`

## Goals & Non-Goals

**Goals**:
- Resolve blocking sorries in semantic infrastructure (closure_lindenbaum_via_projection, closureSize_le_complexity, history gluing)
- Prove constructive FMP theorem with explicit `Fintype W` witness and cardinality bound
- Archive old trivial implementation to Boneyard with documentation
- Achieve zero sorries in the final constructive FMP implementation

**Non-Goals**:
- Rewriting the entire FiniteCanonicalModel.lean (use existing infrastructure)
- Optimizing the bound (2^|closure| is standard, not tight)
- Implementing decision procedures beyond what FMP provides

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| History gluing sorries cascade to other proofs | High | Medium | Focus on same-history compositionality first; isolate edge cases |
| Cardinality bounds hard to prove | Medium | Low | Leverage Mathlib Fintype.card lemmas; bound already partially established |
| Old code has hidden dependencies | Low | Low | Check imports thoroughly before archiving |
| closure_lindenbaum_via_projection fundamentally broken | High | Low | If blocked, document and mark phase partial |

## Implementation Phases

### Phase 1: Complete Semantic Infrastructure Sorries [NOT STARTED]

**Goal**: Resolve the core sorries that block constructive FMP proof

**Tasks**:
- [ ] Prove `closureSize_le_complexity` via structural induction on formula complexity
- [ ] Complete `closure_lindenbaum_via_projection` (inconsistency projection to closure)
- [ ] Resolve `closure_consistent_empty` (empty context consistency)
- [ ] Fix `finite_history_from_state` sorries (history construction from state)
- [ ] Complete `finiteHistoryToWorldHistory.respects_task` (clamping proof)

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - resolve sorries in closure infrastructure
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - if sorries exist here

**Verification**:
- Run `lake build` on modified files with no errors
- Count remaining sorries in FiniteCanonicalModel.lean (should decrease by 5+)
- `lean_diagnostic_messages` shows no new warnings

---

### Phase 2: Complete History Gluing [NOT STARTED]

**Goal**: Resolve the history gluing sorries that enable compositionality

**Tasks**:
- [ ] Fix `glue_histories.forward_rel` (4 sorries for edge cases)
- [ ] Fix `glue_histories.backward_rel` (1 sorry)
- [ ] Verify `SemanticTaskRelV2.compositionality` now works
- [ ] Handle boundary cases when shifted time is out of bounds

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - glue_histories section

**Verification**:
- `glue_histories` compiles with zero sorries
- `SemanticTaskRelV2.compositionality` has no sorries
- No regression in `semantic_weak_completeness`

---

### Phase 3: Constructive FMP Statement and Proof [NOT STARTED]

**Goal**: Define and prove the constructive FMP theorem with explicit bounds

**Tasks**:
- [ ] Define `finite_model_property_constructive` with Fintype witness and cardinality bound
- [ ] Prove `semanticWorldState_card_bound : Fintype.card (SemanticWorldState phi) <= 2^(closureSize phi)`
- [ ] Connect SemanticCanonicalModel to formula_satisfiable via contrapositive of semantic_weak_completeness
- [ ] Verify the full proof chain has zero sorries
- [ ] Update or replace `finite_model_size_bound`, `satisfiability_decidable`, `validity_decidable_via_fmp`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - new constructive theorem

**Verification**:
- `finite_model_property_constructive` compiles with no sorries
- `#check @finite_model_property_constructive` shows expected type signature
- Related decidability theorems updated or marked deprecated

---

### Phase 4: Archive Old Implementation [NOT STARTED]

**Goal**: Move trivial FMP to Boneyard with documentation

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/TrivialFMP.lean` with old theorems
- [ ] Add documentation explaining why replaced (follows SyntacticApproach.lean pattern)
- [ ] Check no external files import the old trivial proofs
- [ ] Update `Metalogic_v2.lean` imports to use constructive version
- [ ] Verify full build succeeds

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Boneyard/TrivialFMP.lean` - new archive file
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - remove old theorems
- `Theories/Bimodal/Metalogic_v2.lean` - update imports

**Verification**:
- `lake build` succeeds with no errors
- Boneyard file includes rationale for deprecation
- No imports reference old trivial theorems

## Testing & Validation

- [ ] `lake build Theories/Bimodal/Metalogic_v2` succeeds with zero errors
- [ ] `lean_diagnostic_messages` on FiniteModelProperty.lean shows no sorries
- [ ] `lean_diagnostic_messages` on FiniteCanonicalModel.lean shows reduced sorry count
- [ ] `#check @finite_model_property_constructive` displays correct signature with Fintype instance
- [ ] Cardinality bound `2^(closureSize phi)` is explicit in the statement
- [ ] All decidability theorems using FMP compile without sorries

## Artifacts & Outputs

- `specs/596_constructive_finite_model_bounds/plans/implementation-001.md` (this file)
- `specs/596_constructive_finite_model_bounds/summaries/implementation-summary-{DATE}.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- Modified: `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
- Created: `Theories/Bimodal/Boneyard/TrivialFMP.lean`

## Rollback/Contingency

If phases 1-2 prove intractable due to fundamental issues in the semantic approach:
1. Document blocking issues in research report
2. Keep old trivial FMP in place (do not archive)
3. Mark task as blocked pending resolution of underlying infrastructure
4. Create follow-up task for alternative approach (e.g., syntactic filtration)

Git provides full rollback capability: `git checkout HEAD -- Theories/Bimodal/` reverts all changes.
