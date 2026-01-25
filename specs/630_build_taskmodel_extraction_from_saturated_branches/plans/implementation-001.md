# Implementation Plan: Task #630

- **Task**: 630 - Build TaskModel Extraction from Saturated Branches
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: Medium
- **Dependencies**: Task 623 (tableau completeness infrastructure)
- **Research Inputs**: specs/630_build_taskmodel_extraction_from_saturated_branches/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Build infrastructure to extract a proper TaskModel from saturated open tableau branches for the bimodal logic TM. The current `evalFormula` (CountermodelExtraction.lean:158-164) treats modal/temporal operators as identity, which is semantically incorrect. This task implements proper task frame extraction following the JPL paper's TaskFrame semantics where Box quantifies over ALL world histories at time t and H/G operators quantify over ALL times in the duration group D. The implementation leverages the existing `canonical_task_rel` pattern from TaskRelation.lean as a template.

### Research Integration

- Current SimpleCountermodel only extracts atom valuations; modal/temporal are treated as identity (inadequate)
- TaskFrame requires WorldState type, duration type D (Int recommended for FMP), and task relation satisfying nullity/compositionality
- Use existing `canonical_task_rel` pattern from `Metalogic/Representation/TaskRelation.lean` as template
- 5-phase approach: BranchWorldState -> BranchTaskRelation -> extractTaskFrame -> Truth Lemma -> Integration

## Goals & Non-Goals

**Goals**:
- Define `BranchWorldState` structure extracting world state from branch atoms
- Define `branch_task_rel` satisfying nullity and compositionality
- Build `extractBranchTaskFrame : Branch -> Option (TaskFrame Int)`
- Prove truth lemma connecting branch satisfaction to model satisfaction
- Update `CountermodelExtraction.lean` to use proper task frame semantics

**Non-Goals**:
- Infinite/dense time types (Int is sufficient for FMP)
- Complex multi-world extraction (single branch = single base world)
- Performance optimization (correctness first)
- Full integration with tableau decision procedure (separate task 624)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Compositionality proof complexity | Medium | High | Reuse `canonical_task_rel_comp` proof structure; use automation (simp, omega) |
| Universe level issues with TaskFrame | Medium | Medium | Fix D = Int for extraction; matches FMP finite model property |
| WorldHistory construction complexity | Medium | Medium | Use full domain (all times) following `canonical_history_family` pattern |
| Saturation assumptions may be incomplete | Low | Low | Verify expansion rules handle all modal/temporal cases |

## Implementation Phases

### Phase 1: Define BranchWorldState [NOT STARTED]

**Goal**: Create the world state type extracted from saturated branch atoms

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic_v2/Decidability/BranchTaskModel.lean`
- [ ] Define `BranchWorldState` structure containing:
  - `atoms : Finset String` - atoms true at this world state
- [ ] Derive `DecidableEq` and `Fintype` instances
- [ ] Define helper `extractBranchWorldState : Branch -> BranchWorldState`
- [ ] Define valuation function from BranchWorldState

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/BranchTaskModel.lean` (new file)

**Verification**:
- [ ] File compiles without errors
- [ ] `#check BranchWorldState` succeeds
- [ ] `#check extractBranchWorldState` succeeds

---

### Phase 2: Define BranchTaskRelation [NOT STARTED]

**Goal**: Define task relation satisfying nullity and compositionality

**Tasks**:
- [ ] Define `branch_task_rel : BranchWorldState -> Int -> BranchWorldState -> Prop`
- [ ] Implement nullity case (d = 0 requires identity)
- [ ] Implement positive duration case (forward time propagation)
- [ ] Implement negative duration case (backward time propagation)
- [ ] Prove `branch_task_rel_nullity : forall w, branch_task_rel w 0 w`
- [ ] Prove `branch_task_rel_comp : forall w u v d1 d2, branch_task_rel w d1 u -> branch_task_rel u d2 v -> branch_task_rel w (d1+d2) v`
- [ ] Add lemma `branch_task_rel_time` extracting time arithmetic

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/BranchTaskModel.lean`

**Verification**:
- [ ] `#check branch_task_rel` succeeds
- [ ] `branch_task_rel_nullity` compiles without sorry
- [ ] `branch_task_rel_comp` compiles without sorry

---

### Phase 3: Build extractTaskFrame [NOT STARTED]

**Goal**: Construct TaskFrame from saturated open branch

**Tasks**:
- [ ] Define `BranchTaskFrame : Type` as `TaskFrame Int` with `WorldState = BranchWorldState`
- [ ] Define `extractBranchTaskFrame : Branch -> BranchTaskFrame`
  - Use `branch_task_rel` as the task relation
  - Package nullity and compositionality proofs
- [ ] Define `BranchTaskModel : Type` extending `TaskModel BranchTaskFrame`
- [ ] Define `extractBranchTaskModel : Branch -> BranchTaskModel`
  - Include valuation from extracted atoms
- [ ] Define `BranchWorldHistory : Type` as `WorldHistory BranchTaskFrame`
- [ ] Define helper to construct world history with full Int domain

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/BranchTaskModel.lean`

**Verification**:
- [ ] `#check extractBranchTaskFrame` succeeds with correct type
- [ ] `#check extractBranchTaskModel` succeeds
- [ ] Constructed frame satisfies TaskFrame interface

---

### Phase 4: Truth Lemma [NOT STARTED]

**Goal**: Prove branch satisfaction corresponds to model satisfaction

**Tasks**:
- [ ] Define `evalFormula_taskModel : BranchTaskModel -> WorldHistory BranchTaskFrame -> Int -> Formula -> Prop`
- [ ] Prove atom case: `T(p) in branch -> evalFormula_taskModel M tau t (atom p) = true`
- [ ] Prove atom negation case: `F(p) in branch -> evalFormula_taskModel M tau t (atom p) = false`
- [ ] Prove bot case: direct from evaluation
- [ ] Prove implication case: follows from branch saturation
- [ ] Prove box case: quantifies over all histories at time t
- [ ] Prove temporal cases (G/H): quantify over all times in D
- [ ] State main theorem `branchTruthLemma_taskModel`:
  ```lean
  theorem branchTruthLemma_taskModel (b : Branch)
      (hSat : findUnexpanded b = none) (hOpen : findClosure b = none) :
      forall sf in b,
        (sf.sign = .pos -> truth_at M tau t sf.formula) ∧
        (sf.sign = .neg -> not (truth_at M tau t sf.formula))
  ```

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/BranchTaskModel.lean`

**Verification**:
- [ ] Main theorem compiles (may have sorry for complex cases initially)
- [ ] Atom cases are fully proven
- [ ] Bot case is fully proven
- [ ] Modal/temporal cases have clear structure (may have sorry for lemma dependencies)

---

### Phase 5: Integration and Testing [NOT STARTED]

**Goal**: Connect new extraction to existing countermodel infrastructure

**Tasks**:
- [ ] Update imports in `CountermodelExtraction.lean` to include `BranchTaskModel`
- [ ] Define `TaskModelCountermodel` type wrapping extracted TaskModel
- [ ] Define `extractTaskModelCountermodel : Formula -> Branch -> Option TaskModelCountermodel`
- [ ] Update `CountermodelResult` to include TaskModel variant
- [ ] Update `findCountermodel` to return proper TaskModel when applicable
- [ ] Keep SimpleCountermodel for backward compatibility / debugging
- [ ] Add display function for TaskModelCountermodel
- [ ] Test with simple formulas:
  - Invalid formula: `p -> (box q -> p)` should extract countermodel
  - Valid formula: `box (p -> q) -> (box p -> box q)` should not extract countermodel
- [ ] Verify no regressions in existing tests

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean`
- `Theories/Bimodal/Metalogic_v2/Decidability/BranchTaskModel.lean` (exports)

**Verification**:
- [ ] Both files compile without errors
- [ ] `findCountermodel` returns proper TaskModel for invalid formulas
- [ ] `lake build` succeeds for affected modules
- [ ] No regressions in tableau tests

## Testing & Validation

- [ ] All new definitions compile without errors
- [ ] `branch_task_rel_nullity` proven without sorry
- [ ] `branch_task_rel_comp` proven without sorry
- [ ] Truth lemma proven for atomic cases
- [ ] `extractBranchTaskFrame` constructs valid TaskFrame
- [ ] `findCountermodel` returns TaskModel for known invalid formulas
- [ ] No regressions in existing tableau functionality
- [ ] `lake build` succeeds for all affected modules

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Decidability/BranchTaskModel.lean` (new file)
- Updated `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean`
- `specs/630_build_taskmodel_extraction_from_saturated_branches/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation encounters blocking issues:

1. **If compositionality proof is too complex**: Implement with `sorry` initially, mark as partial completion, create follow-up task for proof completion
2. **If universe level issues arise**: Restrict to concrete `Int` type throughout, avoiding polymorphism
3. **If truth lemma requires additional infrastructure**: Complete phases 1-3, document missing lemma dependencies, create follow-up task
4. **If integration breaks existing tests**: Keep changes in BranchTaskModel.lean only, defer CountermodelExtraction.lean updates to separate task

All new code is in a new file, so rollback is simply deleting `BranchTaskModel.lean` and reverting any changes to `CountermodelExtraction.lean`.
