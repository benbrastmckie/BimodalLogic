# Implementation Plan: Task #813

- **Task**: 813 - Resolve Remaining BMCS Sorries
- **Status**: [NOT STARTED]
- **Effort**: 2 hours (meta task creating 3 implementation tasks)
- **Dependencies**: Task 812 (BMCS Completeness - COMPLETED)
- **Research Inputs**: specs/813_resolve_remaining_bmcs_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This is a META task that creates targeted implementation tasks for eliminating the remaining 10 sorries in the BMCS completeness infrastructure. Research identified 4 categories: classical propositional tautologies (4 unique sorries), temporal omega-saturation (2 sorries), universe polymorphism (2 sorries), and multi-family construction (1 sorry). The implementation approach is to create 3 focused tasks with clear dependencies and proof strategies.

### Research Integration

Key findings from research-001.md:
- Task 812 reduced sorries from 30+ to 10
- Box case of truth lemma is SORRY-FREE (fundamental obstruction resolved)
- Remaining sorries are technical, not mathematical gaps
- Existing proven infrastructure available: `double_negation`, `neg_imp_fst`, `neg_imp_snd` in Boneyard

## Goals & Non-Goals

**Goals**:
- Create 3 well-defined implementation tasks for sorry elimination
- Specify exact file paths, line numbers, and proof strategies
- Establish clear execution order and dependencies
- Enable parallel work if desired (Task A and B are independent)

**Non-Goals**:
- Directly implementing sorry elimination (that is the job of created tasks)
- Modifying Lean files in this task
- Changing the BMCS architecture or approach

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task scope creep | Medium | Low | Each task addresses specific sorries by line number |
| Dependency ordering wrong | Medium | Low | Task C depends on A; A and B are independent |
| Effort estimates off | Low | Medium | Built-in buffer in estimates; can adjust later |

## Implementation Phases

### Phase 1: Create Task A - Classical Propositional Completeness [NOT STARTED]

**Goal**: Create a task for resolving the 4 classical tautology sorries

**Tasks**:
- [ ] Create task via /task command with full specification
- [ ] Verify task created in state.json and TODO.md

**Task Specification**:
- **Title**: Classical Propositional Completeness Infrastructure
- **Language**: lean
- **Effort**: 2-3 hours
- **Description**: Resolve 4 classical propositional sorries in BMCS infrastructure by importing existing `double_negation` theorem and porting `neg_imp_fst`/`neg_imp_snd` from Boneyard.

**Sorries Addressed**:
1. `TruthLemma.lean:186` - `neg_imp_implies_antecedent` (proof exists at Boneyard/Metalogic_v5/Representation/TruthLemma.lean:153)
2. `TruthLemma.lean:198` - `neg_imp_implies_neg_consequent` (proof exists at Boneyard/Metalogic_v5/Representation/TruthLemma.lean:216)
3. `Completeness.lean:184` - `not_derivable_implies_neg_consistent` (requires DNE + deduction theorem)
4. `Completeness.lean:323` - `context_not_derivable_implies_extended_consistent` (requires same infrastructure)

**Note**: `double_negation_elim` at Completeness.lean:197 is a duplicate of existing `Bimodal.Theorems.Propositional.double_negation`

**Proof Strategy**:
1. Import `Bimodal.Theorems.Propositional.double_negation`
2. Port `neg_imp_fst` and `neg_imp_snd` from Boneyard (adapt namespaces/types)
3. Derive `not_derivable_implies_neg_consistent` using DNE + deduction theorem
4. Derive `context_not_derivable_implies_extended_consistent` using same pattern

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

**Timing**: 15 minutes

**Verification**:
- Task appears in state.json with status "not_started" and language "lean"
- Task appears in TODO.md with full description
- Task number recorded for dependency tracking

---

### Phase 2: Create Task B - Universe Polymorphism Resolution [NOT STARTED]

**Goal**: Create a task for resolving the 2 universe polymorphism sorries

**Tasks**:
- [ ] Create task via /task command with full specification
- [ ] Verify task created in state.json and TODO.md

**Task Specification**:
- **Title**: BMCS Universe Polymorphism Resolution
- **Language**: lean
- **Effort**: 1-2 hours
- **Description**: Resolve 2 universe polymorphism sorries by specializing completeness theorems to Int or using explicit universe instantiation.

**Sorries Addressed**:
1. `Completeness.lean:158` - `bmcs_valid_implies_valid_Int` (polymorphic validity to Int-specific)
2. `Completeness.lean:292` - `bmcs_consequence_implies_consequence_Int` (polymorphic consequence to Int-specific)

**Proof Strategy Options** (implementer chooses best):
1. **Specialize at definition**: Define `bmcs_valid_Int` and `bmcs_consequence_Int` directly over Int
2. **Explicit instantiation**: Use `@` syntax for universe level manipulation
3. **Int-specific variants**: Add Int-specific completeness theorems as primary definitions

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- Possibly `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`

**Timing**: 15 minutes

**Verification**:
- Task appears in state.json with status "not_started" and language "lean"
- Task number recorded for documentation

---

### Phase 3: Create Task C - Temporal/Modal Coherence Strengthening [NOT STARTED]

**Goal**: Create a task for resolving the 3 temporal/modal coherence sorries

**Tasks**:
- [ ] Create task via /task command with full specification
- [ ] Note dependency on Task A (classical infrastructure useful for temporal proofs)
- [ ] Verify task created in state.json and TODO.md

**Task Specification**:
- **Title**: BMCS Temporal Modal Coherence Strengthening
- **Language**: lean
- **Effort**: 3-4 hours
- **Description**: Resolve 3 temporal/modal sorries by adding backward coherence conditions to IndexedMCSFamily and implementing modal saturation for singleFamilyBMCS.

**Sorries Addressed**:
1. `TruthLemma.lean:156` - `phi_at_all_future_implies_mcs_all_future` (requires omega-saturation)
2. `TruthLemma.lean:166` - `phi_at_all_past_implies_mcs_all_past` (requires omega-saturation)
3. `Construction.lean:220` - `modal_backward` in `singleFamilyBMCS` (phi in MCS implies Box phi in MCS)

**Proof Strategy**:
1. **Temporal backward coherence**: Add fields to IndexedMCSFamily:
   - `backward_from_all_future`: All future truths implies G in MCS
   - `backward_from_all_past`: All past truths implies H in MCS
2. **Modal backward**: Three options:
   - Implement modal saturation during MCS construction
   - Prove from S5 properties if applicable
   - Use multi-family approach where modal_backward holds by design

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean`
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`

**Dependencies**: Task A (classical infrastructure) is helpful but not strictly required

**Timing**: 15 minutes

**Verification**:
- Task appears in state.json with status "not_started" and language "lean"
- Dependency on Task A noted in description if applicable

---

### Phase 4: Verification and Summary [NOT STARTED]

**Goal**: Confirm all tasks created correctly and update task 813 status

**Tasks**:
- [ ] Verify all 3 tasks exist in state.json
- [ ] Verify all 3 tasks exist in TODO.md
- [ ] Document task numbers in this plan
- [ ] Create implementation summary

**Timing**: 15 minutes

**Verification**:
- Three new tasks in state.json with correct specifications
- TODO.md updated with task entries
- Implementation summary created

---

## Testing & Validation

- [ ] All 3 tasks created in state.json
- [ ] All 3 tasks visible in TODO.md
- [ ] Task specifications match research findings
- [ ] Dependencies documented
- [ ] Execution order clear: A first (or A||B), then C

## Artifacts & Outputs

- `specs/813_resolve_remaining_bmcs_sorries/plans/implementation-001.md` (this file)
- `specs/813_resolve_remaining_bmcs_sorries/summaries/implementation-summary-YYYYMMDD.md`
- 3 new tasks in state.json and TODO.md

## Rollback/Contingency

If task creation encounters issues:
1. Manually create tasks using /task command one at a time
2. Update state.json directly if TODO.md sync fails
3. Tasks can be consolidated into single task if 3-task approach proves unwieldy

## Task Summary Table

| Task | Title | Sorries | Effort | Dependencies |
|------|-------|---------|--------|--------------|
| A | Classical Propositional Completeness Infrastructure | 4 | 2-3h | None |
| B | BMCS Universe Polymorphism Resolution | 2 | 1-2h | None |
| C | BMCS Temporal Modal Coherence Strengthening | 3 | 3-4h | Task A (helpful) |

**Total effort for created tasks**: 6-9 hours
**Recommended execution order**: A -> B (parallel possible) -> C
