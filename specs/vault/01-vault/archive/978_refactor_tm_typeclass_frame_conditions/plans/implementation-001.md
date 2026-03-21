# Implementation Plan: Task #978 - Refactor TM Typeclass Frame Condition Architecture

- **Task**: 978 - refactor_tm_typeclass_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours
- **Dependencies**: Task 977 (COMPLETED)
- **Research Inputs**: specs/978_refactor_tm_typeclass_frame_conditions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true

## Overview

Refactor the TM proof system from enum-based frame classification (FrameClass with Base/Dense/Discrete) to a typeclass-based architecture. The new design defines frame condition typeclasses (`LinearTemporalFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`, `SerialFrame`) that wrap Mathlib's order typeclasses, enabling parameterized derivation, soundness, and completeness. This is a clean-break refactor: new modules are created in `FrameConditions/` while existing infrastructure remains stable.

### Research Integration

The research report (research-001.md) identified:
- Current architecture has 21 axioms organized via `FrameClass` enum (task 977)
- Task 979 is blocked on the covering lemma (syntactic DF membership vs structural property gap)
- Mathlib provides relevant typeclasses: `DenselyOrdered`, `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`
- Clean-break approach recommended: new `FrameConditions/` module hierarchy

## Goals & Non-Goals

**Goals**:
- Define frame condition typeclasses wrapping Mathlib's order typeclasses
- Create parameterized validity definition (`valid_over`)
- Parameterize soundness proofs by frame class
- Define axiom compatibility typeclass with instances for all 21 axioms
- Establish clean module structure in `FrameConditions/`

**Non-Goals**:
- Completeness wiring (depends on task 979 resolution)
- Removing existing `FrameClass` enum (deprecate but preserve for now)
- Resolving the covering lemma gap (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Typeclass inference issues | High | Medium | Use explicit instances; test inference in isolation |
| Universe level mismatches | Medium | Low | Use `Type` consistently as in existing code |
| Large file sizes | Medium | Medium | Split into multiple focused modules |
| Interaction with existing `valid_dense`/`valid_discrete` | Medium | Low | Prove equivalence lemmas between old and new definitions |

## Implementation Phases

### Phase 1: Define Frame Condition Typeclasses [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create the core typeclass hierarchy for frame conditions

**Tasks:**
- [ ] Create `Theories/Bimodal/FrameConditions/FrameClass.lean`
- [ ] Define `LinearTemporalFrame` typeclass extending `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`
- [ ] Define `DenseTemporalFrame` extending `LinearTemporalFrame` with `DenselyOrdered`, `Nontrivial`, `NoMaxOrder`, `NoMinOrder`
- [ ] Define `DiscreteTemporalFrame` extending `LinearTemporalFrame` with `SuccOrder`, `PredOrder`, `Nontrivial`, `NoMaxOrder`, `NoMinOrder`, `IsSuccArchimedean`
- [ ] Define `SerialFrame` extending `LinearTemporalFrame` with `NoMaxOrder`, `NoMinOrder`
- [ ] Add standard instances: `Int` is `DiscreteTemporalFrame`, `Rat` is `DenseTemporalFrame`
- [ ] Prove instance relationships (Discrete implies Serial, Dense implies Serial)
- [ ] Create `Theories/Bimodal/FrameConditions.lean` root module with imports

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/FrameClass.lean` (new)
- `Theories/Bimodal/FrameConditions.lean` (new)
- `Theories/Bimodal.lean` (add import)

**Verification**:
- `lake build` passes
- All typeclasses and instances defined
- `#check (inferInstance : LinearTemporalFrame Int)` succeeds
- `#check (inferInstance : DiscreteTemporalFrame Int)` succeeds

---

### Phase 2: Parameterized Validity Definition [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Create unified validity definition parameterized by frame class

**Tasks:**
- [ ] Create `Theories/Bimodal/FrameConditions/Validity.lean`
- [ ] Define `valid_over (D : Type*) [LinearTemporalFrame D]` parameterized validity
- [ ] Define specialized aliases: `valid_linear`, `valid_dense_fc`, `valid_discrete_fc`
- [ ] Prove equivalence with existing `valid`, `valid_dense`, `valid_discrete` from `Validity.lean`
- [ ] Export unified validity API

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Validity.lean` (new)
- `Theories/Bimodal/FrameConditions.lean` (add import)

**Verification**:
- `lake build` passes
- Equivalence lemmas proven (no sorries)
- `#check valid_over Int` shows correct type

---

### Phase 3: Parameterized Soundness [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Refactor soundness proofs to use typeclass constraints

**Tasks:**
- [ ] Create `Theories/Bimodal/FrameConditions/Soundness.lean`
- [ ] Define `soundness_over D [LinearTemporalFrame D]` for base axioms
- [ ] Define `soundness_dense D [DenseTemporalFrame D]` including density axiom
- [ ] Define `soundness_discrete D [DiscreteTemporalFrame D]` including discrete axioms
- [ ] Prove soundness theorems using typeclass constraints instead of boolean predicates
- [ ] Verify all 21 axioms covered

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Soundness.lean` (new)
- `Theories/Bimodal/FrameConditions.lean` (add import)

**Verification**:
- `lake build` passes
- All 21 axioms have soundness proofs
- No sorries in soundness module
- `grep -rn "\bsorry\b" Theories/Bimodal/FrameConditions/Soundness.lean` returns empty

---

### Phase 4: Axiom Compatibility Typeclass [NOT STARTED]

- **Dependencies:** Phase 1, Phase 3
- **Goal:** Define typeclass for axiom-frame compatibility with instances

**Tasks:**
- [ ] Create `Theories/Bimodal/FrameConditions/Compatibility.lean`
- [ ] Define `AxiomCompatible` typeclass relating axioms to frame classes
- [ ] Create instances for all 18 base axioms (compatible with LinearTemporalFrame)
- [ ] Create instance for density axiom (compatible with DenseTemporalFrame)
- [ ] Create instances for 3 discrete axioms (compatible with DiscreteTemporalFrame)
- [ ] Prove that base axiom compatibility implies dense/discrete compatibility (monotonicity)

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Compatibility.lean` (new)
- `Theories/Bimodal/FrameConditions.lean` (add import)

**Verification**:
- `lake build` passes
- 21 compatibility instances defined
- Monotonicity lemmas proven
- No sorries in compatibility module

---

### Phase 5: Integration and Documentation [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4
- **Goal:** Integrate new modules, update documentation, verify build

**Tasks:**
- [ ] Update `Theories/Bimodal/Metalogic/LogicVariants.lean` to reference new typeclasses
- [ ] Add deprecation comments to `FrameClass` enum noting typeclass alternative
- [ ] Update `Theories/Bimodal/README.md` with new architecture description
- [ ] Create summary in `specs/978_refactor_tm_typeclass_frame_conditions/summaries/`
- [ ] Verify full `lake build` with no warnings
- [ ] Run `grep -rn "\bsorry\b"` on all new files to confirm zero-debt

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/LogicVariants.lean` (update)
- `Theories/Bimodal/Syntax/Axioms.lean` (add deprecation comment)
- `Theories/Bimodal/README.md` (update)
- Summary artifact (new)

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/FrameConditions/` returns empty
- `grep -n "^axiom " Theories/Bimodal/FrameConditions/*.lean` shows no new axioms
- All new files properly imported

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/FrameConditions/` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/FrameConditions/*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Typeclass inference works correctly for `Int` and `Rat`
- [ ] New validity definitions equivalent to existing ones
- [ ] All 21 axioms have soundness and compatibility instances
- [ ] Module imports resolve correctly

## Artifacts & Outputs

- `Theories/Bimodal/FrameConditions/FrameClass.lean` - Typeclass definitions
- `Theories/Bimodal/FrameConditions/Validity.lean` - Parameterized validity
- `Theories/Bimodal/FrameConditions/Soundness.lean` - Parameterized soundness
- `Theories/Bimodal/FrameConditions/Compatibility.lean` - Axiom compatibility
- `Theories/Bimodal/FrameConditions.lean` - Root module
- `specs/978_refactor_tm_typeclass_frame_conditions/plans/implementation-001.md` - This plan
- `specs/978_refactor_tm_typeclass_frame_conditions/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the typeclass approach causes significant issues:
1. All new code is in `FrameConditions/` - can be deleted without affecting existing code
2. Existing `FrameClass` enum and `valid_dense`/`valid_discrete` remain functional
3. The refactor is purely additive until Phase 5 integration
4. Git revert to pre-task state if necessary

If typeclass inference fails:
- Use explicit instances instead of inference
- Add `@` prefix to force explicit instantiation
- Consider bundled typeclass approach as fallback
