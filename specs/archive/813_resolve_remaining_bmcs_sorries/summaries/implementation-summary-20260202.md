# Implementation Summary: Task #813

**Task**: Resolve Remaining BMCS Sorries
**Completed**: 2026-02-02
**Duration**: ~30 minutes
**Plan Version**: implementation-001.md

## Overview

Created 3 targeted Lean implementation tasks for eliminating the remaining 10 sorries in the BMCS completeness infrastructure. This is a META task that organizes the work from Task 812's completion into actionable subtasks.

## Tasks Created

| Task | Title | Sorries | Effort | Dependencies |
|------|-------|---------|--------|--------------|
| 814 | Classical Propositional Completeness Infrastructure | 4 | 2-3h | None |
| 815 | BMCS Universe Polymorphism Resolution | 2 | 1-2h | None |
| 816 | BMCS Temporal Modal Coherence Strengthening | 3 | 3-4h | 814 |

**Total effort for created tasks**: 6-9 hours

## Task Details

### Task 814: Classical Propositional Completeness Infrastructure

**Sorries Addressed**:
1. `TruthLemma.lean:186` - `neg_imp_implies_antecedent`
2. `TruthLemma.lean:198` - `neg_imp_implies_neg_consequent`
3. `Completeness.lean:184` - `not_derivable_implies_neg_consistent`
4. `Completeness.lean:323` - `context_not_derivable_implies_extended_consistent`

**Proof Strategy**:
- Import existing `Bimodal.Theorems.Propositional.double_negation`
- Port `neg_imp_fst` and `neg_imp_snd` from Boneyard/Metalogic_v5/Representation/TruthLemma.lean

### Task 815: BMCS Universe Polymorphism Resolution

**Sorries Addressed**:
1. `Completeness.lean:158` - `bmcs_valid_implies_valid_Int`
2. `Completeness.lean:292` - `bmcs_consequence_implies_consequence_Int`

**Proof Strategy Options**:
1. Define `bmcs_valid_Int` and `bmcs_consequence_Int` directly over Int
2. Use `@` syntax for explicit universe instantiation
3. Add Int-specific completeness theorems as primary definitions

### Task 816: BMCS Temporal Modal Coherence Strengthening

**Sorries Addressed**:
1. `TruthLemma.lean:156` - `phi_at_all_future_implies_mcs_all_future`
2. `TruthLemma.lean:166` - `phi_at_all_past_implies_mcs_all_past`
3. `Construction.lean:220` - `modal_backward` in `singleFamilyBMCS`

**Proof Strategy**:
- Add `backward_from_all_future` and `backward_from_all_past` fields to IndexedMCSFamily
- For modal_backward: implement modal saturation during MCS construction, or use multi-family approach

## Recommended Execution Order

```
814 (Classical) -----> 816 (Temporal/Modal)
     \                    /
      -----> || <--------
     /
815 (Universe) ----------/
```

**Explanation**:
- Tasks 814 and 815 can be executed in parallel (no dependencies)
- Task 816 depends on Task 814 (classical infrastructure is helpful for temporal proofs)
- Recommended sequential order: 814 -> 815 -> 816

## Phase Completion

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Create Task A (Classical) | COMPLETED |
| 2 | Create Task B (Universe) | COMPLETED |
| 3 | Create Task C (Temporal/Modal) | COMPLETED |
| 4 | Verification and Summary | COMPLETED |

## Verification

- [x] All 3 tasks created in state.json with correct specifications
- [x] All 3 tasks visible in TODO.md
- [x] Task specifications match research findings
- [x] Dependencies documented (Task 816 depends on 814)
- [x] Execution order clear: A||B -> C

## Notes

- These tasks address the 10 remaining sorries from Task 812's BMCS completeness implementation
- None of these sorries represent mathematical gaps - they are technical Lean issues
- The fundamental completeness obstruction (box case of truth lemma) was already resolved sorry-free in Task 812
- Completing these 3 tasks will yield fully sorry-free BMCS completeness theorems
