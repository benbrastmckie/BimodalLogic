# Implementation Plan: Task #779

- **Task**: 779 - prove_weak_completeness_sorry_free
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: High
- **Dependencies**: None (builds on existing FMP infrastructure)
- **Research Inputs**: specs/779_archive_weak_completeness_for_sorry_free_metalogic/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove the architectural sorry from `weak_completeness` by building a TaskModel from the SemanticWorldState construction and proving truth correspondence within that specific model. This avoids the failed forward truth lemma approach by not trying to relate arbitrary models to semantic truth - instead we construct ONE model with guaranteed truth correspondence and instantiate the universal `valid` quantification with it.

### Research Integration

Key findings from research-002.md:
- The gap IS bridgeable via model embedding (not forward truth lemma)
- Use `Int` as the time domain (BoundedTime is not a group)
- Box case works because finite world states make history quantification finite
- Temporal operators reduce to propositional outside bounded range

## Goals & Non-Goals

**Goals**:
- Prove `weak_completeness : valid phi -> ContextDerivable [] phi` without sorry
- Create `SemanticTaskFrame` and `SemanticTaskModel` structures
- Prove truth correspondence theorem for formulas in closure
- Bridge `valid` to `semantic_weak_completeness` hypothesis

**Non-Goals**:
- Changing the definition of `valid` (would alter theorem meaning)
- Proving forward truth lemma for arbitrary models (known to be impossible)
- Optimizing existing sorry-free `semantic_weak_completeness` proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| WorldHistory construction complexity | H | M | Start with simple constant histories, extend as needed |
| Box case requires infinite history handling | H | L | Finite world states bound history space; document carefully |
| Temporal depth argument too complex | M | M | Use existing temporalBound machinery; break into small lemmas |
| Type class issues with Int as time domain | M | L | Int already satisfies required instances; verify early |

## Implementation Phases

### Phase 1: Define SemanticTaskFrame and SemanticTaskModel [NOT STARTED]

**Goal**: Create the model construction infrastructure in a new module.

**Tasks**:
- [ ] Create `Metalogic/FMP/SemanticTaskFrame.lean` module
- [ ] Define `SemanticTaskFrame` with `Int` as time domain and `FiniteWorldState` as world type
- [ ] Define `SemanticTaskModel` with valuation from `FiniteWorldState.models`
- [ ] Define `worldStateToHistory` mapping SemanticWorldState to WorldHistory
- [ ] Prove basic frame axioms (nullity, additivity) for SemanticTaskFrame
- [ ] Add module to FMP.lean imports

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticTaskFrame.lean` - New file
- `Theories/Bimodal/Metalogic/FMP.lean` - Add import

**Verification**:
- `lake build` succeeds with no errors
- `SemanticTaskFrame` and `SemanticTaskModel` type-check
- Frame axioms proven without sorry

---

### Phase 2: Prove Atom and Propositional Truth Correspondence [NOT STARTED]

**Goal**: Prove truth_at corresponds to semantic_truth_at_v2 for atoms, bot, and imp cases.

**Tasks**:
- [ ] Create `Metalogic/FMP/SemanticTruthCorrespondence.lean` module
- [ ] Prove atom case: `truth_at` queries valuation which queries `FiniteWorldState.models`
- [ ] Prove bot case: both sides are `False`
- [ ] Prove imp case: by induction hypothesis on subformulas
- [ ] Prove helper lemmas for closure membership propagation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean` - New file
- `Theories/Bimodal/Metalogic/FMP.lean` - Add import

**Verification**:
- `lake build` succeeds
- Atom/bot/imp cases proven without sorry
- Helper lemmas for closure membership work

---

### Phase 3: Prove Box Case Truth Correspondence [NOT STARTED]

**Goal**: Handle the critical Box case where truth_at quantifies over all histories.

**Tasks**:
- [ ] Analyze Box semantics in SemanticTaskFrame context
- [ ] Prove that histories in SemanticTaskFrame are determined by FiniteWorldState sequences
- [ ] Show Box quantification over all histories equals quantification over SemanticWorldStates
- [ ] Prove `truth_at M (worldStateToHistory w) t (box psi) <-> forall v, semantic_truth_at_v2 phi v t psi`
- [ ] Handle edge cases for histories outside bounded domain

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean` - Extend

**Verification**:
- Box case compiles without sorry
- Quantifier correspondence is mathematically correct
- Edge cases documented

---

### Phase 4: Prove Temporal Cases Truth Correspondence [NOT STARTED]

**Goal**: Handle all_past and all_future cases using temporal depth bounds.

**Tasks**:
- [ ] Prove all_past case using bounded time domain
- [ ] Prove all_future case using bounded time domain
- [ ] Show that times outside `[-k, k]` don't affect truth for closure formulas
- [ ] Use temporalBound to limit quantification scope
- [ ] Complete the full truth_correspondence theorem by induction on formula structure

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean` - Complete

**Verification**:
- `truth_correspondence` theorem fully proven without sorry
- All temporal cases handled
- Temporal depth argument is sound

---

### Phase 5: Complete the Bridge and Remove Sorry [NOT STARTED]

**Goal**: Connect truth_correspondence to weak_completeness and remove the sorry.

**Tasks**:
- [ ] Prove `valid_implies_semantic_validity`: `valid phi -> forall w, semantic_truth_at_v2 phi w origin phi`
- [ ] Update `weak_completeness` in WeakCompleteness.lean to use the bridge
- [ ] Remove the sorry from `weak_completeness`
- [ ] Update `provable_iff_valid` to reflect sorry-free status
- [ ] Update module documentation to reflect sorry-free status
- [ ] Update README.md in Metalogic/Completeness/ if needed

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Update theorem
- `Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean` - Add bridge theorem

**Verification**:
- `lake build` succeeds with no sorry markers in WeakCompleteness.lean
- `weak_completeness` and `provable_iff_valid` are fully proven
- Documentation updated to reflect sorry-free completeness

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] No `sorry` markers remain in WeakCompleteness.lean
- [ ] No `sorry` markers in new SemanticTaskFrame.lean or SemanticTruthCorrespondence.lean
- [ ] `#check weak_completeness` shows fully proven theorem
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/Completeness/` returns nothing
- [ ] Module documentation accurately describes the proof approach

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/FMP/SemanticTaskFrame.lean` - New module with frame/model construction
- `Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean` - New module with truth correspondence
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Updated (sorry removed)
- `Theories/Bimodal/Metalogic/FMP.lean` - Updated imports
- `specs/779_archive_weak_completeness_for_sorry_free_metalogic/summaries/implementation-summary-YYYYMMDD.md` - Summary

## Rollback/Contingency

If the truth correspondence for Box or temporal operators proves more complex than expected:
1. Preserve partial progress in SemanticTaskFrame.lean and SemanticTruthCorrespondence.lean
2. Mark unproven lemmas with `sorry` and detailed comments explaining the gap
3. Document findings in a research note for future reference
4. Keep the existing `weak_completeness` sorry as fallback
5. Create follow-up task for completing the remaining cases
