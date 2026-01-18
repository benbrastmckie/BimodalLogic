# Implementation Plan: Task #566

- **Task**: 566 - Complete Semantic Embedding for Completeness Proof
- **Status**: [PARTIAL]
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: Task 560 (partial), Task 558 (TruthLemma)
- **Research Inputs**: specs/566_complete_semantic_embedding_for_completeness_proof/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace the `representation_theorem_backward_empty` axiom in `ContextProvability.lean` with a proven theorem by completing the semantic embedding that bridges canonical model truth (set membership in MCS) to polymorphic semantic validity (quantified over all temporal types). The research identifies that `semantic_weak_completeness` in `FiniteCanonicalModel.lean` is PROVEN and can be leveraged via direct instantiation with `D = Int` and `SemanticCanonicalFrame`.

### Research Integration

From research-001.md:
- Core insight: `semantic_weak_completeness` IS PROVEN (lines 3280-3349)
- Key infrastructure: `SemanticCanonicalFrame phi` provides concrete `TaskFrame Int`
- Bridge gap: `finiteHistoryToWorldHistory.respects_task` has 1 sorry
- Recommended approach: Contrapositive with direct instantiation (3-4 hours estimate)

## Goals and Non-Goals

**Goals**:
- Eliminate `representation_theorem_backward_empty` axiom completely
- Prove the backward direction: `semantic_consequence [] phi -> ContextDerivable [] phi`
- Use existing proven infrastructure from FiniteCanonicalModel.lean
- Keep proof maintainable and well-documented

**Non-Goals**:
- Proving general completeness for non-empty contexts (separate task)
- Refactoring FiniteCanonicalModel.lean structure
- Optimizing performance of the completeness proof
- Proving the bridge sorries in FiniteCanonicalModel.lean (use alternative approach)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Universe level issues when instantiating polymorphic types | Medium | Low | Use explicit type annotations; verify `semantic_consequence` uses `Type` not `Type*` |
| Bridge lemmas from FiniteCanonicalModel.lean have sorries | High | Confirmed | Use contrapositive approach that avoids needing those sorries |
| Import cycles when adding FiniteCanonicalModel dependency | Medium | Low | Add import at ContextProvability level only |
| Type mismatches between FiniteTime and Int | Low | Low | Use `FiniteTime.toInt` conversion; temporal bound provides range |

## Implementation Phases

### Phase 1: Import and Infrastructure Setup [COMPLETED]

**Goal**: Add necessary imports and verify FiniteCanonicalModel integrates cleanly

**Tasks**:
- [ ] Add import `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` to ContextProvability.lean
- [ ] Verify no import cycles by running `lake build Bimodal.Metalogic_v2.Representation.ContextProvability`
- [ ] Check that `SemanticWorldState`, `SemanticCanonicalFrame`, `semantic_weak_completeness` are accessible

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Add imports

**Verification**:
- File compiles without errors after import addition
- Can reference `Bimodal.Metalogic.Completeness.FiniteCanonicalModel.semantic_weak_completeness` in a test #check

---

### Phase 2: Implement Helper Lemma for neg_consistent [COMPLETED]

**Goal**: Create a variant of `not_derivable_implies_neg_consistent` that produces the form needed for `semantic_weak_completeness`

**Tasks**:
- [x] Review `semantic_weak_completeness` input requirements: needs `FormulaSet` that is consistent
- [x] Verify that `[phi.neg]` (List) can be converted to the expected form
- [x] Create helper lemma `neg_consistent_of_not_provable` that bridges list-based consistency to set-based consistency if needed

**Outcome**: No additional helper lemma needed. The `semantic_weak_completeness` already contains the required `neg_consistent_of_not_provable` internally (line 3298). It uses `by_cases h_prov : Nonempty (⊢ phi)` pattern to handle the contrapositive automatically.

**Timing**: 15 minutes

**Files to modify**:
- None

**Verification**:
- N/A - no changes needed

---

### Phase 3: Implement Contrapositive Core [PARTIAL]

**Goal**: Prove the contrapositive: `not ContextDerivable [] phi -> not semantic_consequence [] phi`

**Proof Structure**:
```lean
theorem not_derivable_implies_not_valid {phi : Formula} :
    ¬ContextDerivable [] phi → ¬semantic_consequence [] phi := by
  intro h_not_deriv
  -- Step 1: {phi.neg} is consistent
  have h_neg_cons : Consistent [phi.neg] := not_derivable_implies_neg_consistent h_not_deriv

  -- Step 2: By semantic_weak_completeness contrapositive,
  -- there exists SemanticWorldState where phi is false
  -- (semantic_weak_completeness says: if phi true at all sw then derivable
  --  contrapositive: if not derivable then exists sw where phi false)

  -- Step 3: Construct countermodel for semantic_consequence
  intro h_sem_cons
  -- Instantiate with D = Int, F = SemanticCanonicalFrame phi
  -- Get contradiction: phi should be true (by h_sem_cons) but false (by step 2)
  sorry
```

**Tasks**:
- [ ] Define the theorem statement `not_derivable_implies_not_valid`
- [ ] Use `not_derivable_implies_neg_consistent` to establish consistency
- [ ] Extract the countermodel from `semantic_weak_completeness` construction
- [ ] Use `semantic_world_state_has_world_history` to get a WorldHistory for the counterexample

**Outcome**: Converted axiom to theorem with clear proof structure. Added helper theorem `semantic_world_validity_implies_provable` wrapping `semantic_weak_completeness`. Main theorem `representation_theorem_backward_empty` now shows explicit proof strategy using forward direction (not contrapositive as initially planned).

**Remaining gap**: Bridge lemma `semantic_consequence_implies_semantic_world_truth` has one sorry. This gap requires showing that general polymorphic validity implies truth at all SemanticWorldStates, which depends on `semantic_world_state_has_world_history` from FiniteCanonicalModel.lean (which itself has a sorry due to time shift complexity).

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Add contrapositive theorem

**Verification**:
- ✓ Theorem compiles
- ✓ Types align at each step
- ✓ Axiom replaced with theorem
- ✗ One sorry remains in bridge lemma

---

### Phase 4: Complete Bridge to semantic_consequence [BLOCKED]

**Goal**: Complete the proof by showing the constructed countermodel falsifies `semantic_consequence [] phi`

**Key Insight**: `semantic_consequence [] phi` quantifies over ALL `D`, `TaskFrame D`, `TaskModel`. We instantiate with:
- `D = Int`
- `F = SemanticCanonicalFrame phi`
- `M = SemanticCanonicalModel phi`
- `tau` from `semantic_world_state_has_world_history`

**Tasks**:
- [ ] Use `semantic_world_state_has_world_history` to get `tau : WorldHistory (SemanticCanonicalFrame phi)`
- [ ] Show `truth_at M tau 0 phi` is false using the semantic world state where phi.neg holds
- [ ] Handle the bridge between `semantic_truth_at_v2` and `truth_at` (this is where we may need to work around the sorries)
- [ ] If direct bridge is blocked by sorries, use the proven `finite_model_property_contrapositive` as alternative

**Blocker**: Requires completing `semantic_world_state_has_world_history` in FiniteCanonicalModel.lean, which has complex time shift arithmetic issues. This is a prerequisite for the bridge lemma.

**Alternative**: Could try to prove `semantic_world_state_has_world_history` by constructing a history that specifically places the world state at time 0, rather than using `Quotient.out` which gives an arbitrary representative.

**Timing**: 2-3 hours (estimated)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Complete `semantic_world_state_has_world_history`
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Complete bridge lemma

**Verification**:
- All lemmas compile without sorry
- `#print axioms representation_theorem_backward_empty` shows only Lean core axioms

---

### Phase 5: Replace Axiom with Theorem [COMPLETED]

**Goal**: Convert the axiom to a proven theorem using the contrapositive

**Tasks**:
- [x] Replace `axiom representation_theorem_backward_empty` with `theorem representation_theorem_backward_empty`
- [x] Show proof structure using `semantic_weak_completeness`
- [x] Verify all downstream theorems (`representation_theorem_empty`, `valid_implies_derivable`, `representation_validity`) still compile
- [x] Run `lake build` to verify no regressions

**Outcome**: Axiom successfully replaced with theorem. The theorem has a clear proof structure but depends on one bridge lemma (`semantic_consequence_implies_semantic_world_truth`) that has a sorry.

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Replace axiom with theorem

**Verification**:
- ✓ Axiom declaration removed
- ✓ `lake build Bimodal.Metalogic_v2.Representation.ContextProvability` succeeds
- ✓ All dependent modules compile
- ✗ `#print axioms representation_theorem_backward_empty` will show one additional axiom (from the sorry in bridge lemma)

---

## Testing and Validation

- [ ] `lake build` succeeds with no errors
- [ ] `#print axioms representation_theorem_backward_empty` shows no custom axioms
- [ ] `#print axioms representation_theorem_empty` shows no custom axioms
- [ ] Grep for `axiom` in ContextProvability.lean returns zero matches
- [ ] All theorems that depend on `representation_theorem_backward_empty` still compile
- [ ] Run any existing tests in Metalogic_v2 test suite

## Artifacts and Outputs

- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Modified (axiom replaced with theorem)
- `specs/566_complete_semantic_embedding_for_completeness_proof/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the direct approach via `semantic_weak_completeness` proves too complex due to the bridge sorries:

1. **Alternative A**: Use `finite_model_property_contrapositive` (line ~4060) which is marked as proven
2. **Alternative B**: Complete the bridge sorries in FiniteCanonicalModel.lean first (extends scope)
3. **Alternative C**: Document the gap and keep axiom with enhanced documentation explaining exactly what remains

If build fails after modifications:
- Revert to git HEAD
- Preserve working changes in a separate branch for investigation
