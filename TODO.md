# TODO.md - Logos Task Tracking

## Update Instructions

**When to Update**: After completing tasks, discovering new work, or changing priorities.

**How to Update**:
1. Mark completed tasks by removing them from active sections (history tracked via git)
2. Add new tasks with: description, effort estimate, status, priority, blocking/dependencies
3. Update the "Active Tasks" count in Overview
4. Update "Last Updated" date at bottom
5. Run `/todo` command to sync with .claude/TODO.md specs tracking

**What NOT to Track Here**:
- Completed task details (use git history: `git log --grep="Task"`)
- Implementation plans (use `.claude/specs/` directories)
- Module-by-module status (use IMPLEMENTATION_STATUS.md)
- Technical debt details (use SORRY_REGISTRY.md)

---

## Overview

This file tracks active development tasks for Logos. Completed tasks are removed from this file - see git history and spec summaries for completion records.

**Layer 0 Completion Progress**:
- High Priority: COMPLETE (all blocking tasks done)
- Medium Priority: 21 tasks active (Tasks 21-41: Hilbert theorem derivations - 8 of 12 complete, 3 blocked)
- Low Priority: 3 tasks (9-11 pending)
- **Active Tasks**: 24

**Milestone Achievement**: ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN (100%) + PHASE 4 MODAL THEOREMS PARTIAL (5/8 complete)
**Next Milestone**: Phase 6 - Infrastructure Extension (De Morgan laws, conditional monotonicity, S5 distribution) to unblock remaining 3 theorems

---

## Quick Links

- [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Current gaps and workarounds
- [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management workflow

**Active Implementation Plan**:
- [TODO Implementation Systematic Plan](.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md)
  - Wave 1-2: COMPLETE (High priority foundations, Perpetuity proofs, transport lemmas)
  - Wave 3-4: NOT STARTED (Completeness proofs, future work)

**Recently Completed**:
- [Minimal Axiom Review Plan](.claude/specs/048_minimal_axiom_review_proofs/plans/001-minimal-axiom-review-proofs-plan.md) - Documentation fixes, necessitation from MK, MK/TK documentation

---

## High Priority Tasks

*No active high priority tasks. All blocking work complete.*

---

## Medium Priority Tasks

**Task 21: Derive RAA (Reductio ad Absurdum)**
**Effort**: 2-3 hours
**Status**: Not Started
**Priority**: Medium (extends propositional reasoning)
**Blocking**: None
**Dependencies**: Uses prop_k, prop_s axioms

**Description**: Prove `⊢ A → (¬A → B)` (reductio ad absurdum). If A is true and also not-A, then anything follows. This is a fundamental ex falso principle.

**Lean Signature**:
```lean
theorem raa (A B : Formula) : [] ⊢ A.imp (A.neg.imp B)
```

**Files**: `Logos/Core/Theorems/Propositional.lean` (new file or add to Perpetuity.lean)

---

**Task 22: Derive EFQ (Ex Falso Quodlibet)**
**Effort**: 2-3 hours
**Status**: Not Started
**Priority**: Medium (extends propositional reasoning)
**Blocking**: None
**Dependencies**: Uses prop_k, prop_s, double_negation axioms

**Description**: Prove `⊢ ¬A → (A → B)` (ex falso quodlibet). From a contradiction (A and ¬A), anything can be derived. Dual form of RAA.

**Lean Signature**:
```lean
theorem efq (A B : Formula) : [] ⊢ A.neg.imp (A.imp B)
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 23: Derive LCE and RCE (Conjunction Elimination)**
**Effort**: 3-4 hours
**Status**: Not Started
**Priority**: Medium (basic conjunction reasoning)
**Blocking**: None
**Dependencies**: Uses pairing theorem (CI), derived conjunction operators

**Description**: Prove left and right conjunction elimination:
- LCE: `[A ∧ B] ⊢ A`
- RCE: `[A ∧ B] ⊢ B`

These complete the conjunction introduction/elimination rules alongside the existing `pairing` theorem.

**Lean Signatures**:
```lean
theorem lce (A B : Formula) : [A.and B] ⊢ A
theorem rce (A B : Formula) : [A.and B] ⊢ B
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 24: Derive LDI and RDI (Disjunction Introduction)**
**Effort**: 4-5 hours
**Status**: Not Started
**Priority**: Medium (basic disjunction reasoning)
**Blocking**: None
**Dependencies**: Uses prop_k, prop_s axioms, derived disjunction operator

**Description**: Prove left and right disjunction introduction:
- LDI: `[A] ⊢ A ∨ B`
- RDI: `[B] ⊢ A ∨ B`

Foundation for disjunctive reasoning in TM logic.

**Lean Signatures**:
```lean
theorem ldi (A B : Formula) : [A] ⊢ A.or B
theorem rdi (A B : Formula) : [B] ⊢ A.or B
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 25: Derive RCP (Reverse Contraposition)**
**Effort**: 3-4 hours
**Status**: Not Started
**Priority**: Medium (useful for proof automation)
**Blocking**: None
**Dependencies**: Uses contraposition theorem, double_negation, dni axioms

**Description**: Prove `¬A → ¬B ⊢ B → A` (reverse contraposition). Can be derived from existing CP + DNE + DNI theorems.

**Lean Signature**:
```lean
theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 26: Derive ECQ (Ex Contradictione Quodlibet)**
**Effort**: 2-3 hours
**Status**: Not Started
**Priority**: Medium (fundamental contradiction reasoning)
**Blocking**: None
**Dependencies**: Derives from RAA or EFQ

**Description**: Prove `[A, ¬A] ⊢ B` (ex contradictione quodlibet). From explicit contradiction in context, derive any formula. Special case of RAA/EFQ.

**Lean Signature**:
```lean
theorem ecq (A B : Formula) : [A, A.neg] ⊢ B
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 27: Derive NE and NI (Negation Introduction/Elimination)**
**Effort**: 6-8 hours
**Status**: Not Started
**Priority**: Medium (proof by contradiction infrastructure)
**Blocking**: None
**Dependencies**: Requires context manipulation, may need deduction theorem infrastructure

**Description**: Prove negation introduction and elimination rules:
- NE: if `Γ, ¬A ⊢ ¬B` and `Γ, ¬A ⊢ B`, then `Γ ⊢ A`
- NI: if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`

These enable proof by contradiction patterns. May require significant context reasoning infrastructure.

**Lean Signatures**:
```lean
theorem ne (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A
theorem ni (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 28: Derive DE (Disjunction Elimination)**
**Effort**: 5-7 hours
**Status**: Not Started
**Priority**: Medium (case analysis reasoning)
**Blocking**: None
**Dependencies**: Requires LDI, RDI; context manipulation infrastructure

**Description**: Prove disjunction elimination (case analysis):
- DE: if `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`

Enables case-by-case reasoning over disjunctions.

**Lean Signature**:
```lean
theorem de (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) : ((A.or B) :: Γ) ⊢ C
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 29: Derive BI, LBE, RBE (Biconditional Reasoning)**
**Effort**: 6-8 hours
**Status**: Not Started
**Priority**: Medium (biconditional reasoning infrastructure)
**Blocking**: None
**Dependencies**: Context manipulation, derived biconditional operator

**Description**: Prove biconditional introduction and elimination:
- BI: if `Γ, A ⊢ B` and `Γ, B ⊢ A`, then `Γ ⊢ A ↔ B`
- LBE: `[A ↔ B, A] ⊢ B`
- RBE: `[A ↔ B, B] ⊢ A`

Completes biconditional reasoning rules for TM logic.

**Lean Signatures**:
```lean
theorem bi (A B : Formula) (h1 : (A :: Γ) ⊢ B) (h2 : (B :: Γ) ⊢ A) : Γ ⊢ A.iff B
theorem lbe (A B : Formula) : [A.iff B, A] ⊢ B
theorem rbe (A B : Formula) : [A.iff B, B] ⊢ A
```

**Files**: `Logos/Core/Theorems/Propositional.lean`

---

**Task 30: Derive T-Box-Diamond (Box implies Diamond)**
**Effort**: 2-3 hours
**Status**: Not Started
**Priority**: Medium (basic S5 theorem)
**Blocking**: None
**Dependencies**: Uses modal_t axiom, S5 properties

**Description**: Prove `⊢ □A → ◇A`. In S5, if something is necessary, it is possible. Derivable from modal_t (necessity implies truth) and definition of diamond.

**Lean Signature**:
```lean
theorem t_box_to_diamond (A : Formula) : [] ⊢ A.box.imp A.diamond
```

**Files**: `Logos/Core/Theorems/ModalS5.lean` (new file or add to Perpetuity.lean)

---

**Task 31: Derive Box-Conjunction Biconditional**
**Effort**: 4-5 hours
**Status**: Not Started
**Priority**: Medium (fundamental modal reasoning)
**Blocking**: None
**Dependencies**: Uses existing box_conj_intro, needs box_conj_elim

**Description**: Prove `⊢ □(A ∧ B) ↔ (□A ∧ □B)`. Necessity distributes over conjunction bidirectionally. The introduction direction (box_conj_intro) exists; need to prove elimination direction.

**Lean Signature**:
```lean
theorem box_conj_iff (A B : Formula) : [] ⊢ (A.and B).box.iff (A.box.and B.box)
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

**Task 32: Derive Diamond-Disjunction Biconditional**
**Effort**: 4-5 hours
**Status**: Not Started
**Priority**: Medium (dual of box-conjunction)
**Blocking**: None
**Dependencies**: Dual of box_conj_iff, uses modal duality

**Description**: Prove `⊢ ◇(A ∨ B) ↔ (◇A ∨ ◇B)`. Possibility distributes over disjunction bidirectionally. Dual of box-conjunction theorem via modal duality.

**Lean Signature**:
```lean
theorem diamond_disj_iff (A B : Formula) : [] ⊢ (A.or B).diamond.iff (A.diamond.or B.diamond)
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

**Task 33: Derive S5-Diamond-Box Collapse**
**Effort**: 5-7 hours
**Status**: Not Started
**Priority**: Medium (characteristic S5 theorem)
**Blocking**: None
**Dependencies**: Uses modal_5 theorem, S5 axioms

**Description**: Prove `⊢ ◇□A ↔ □A`. In S5, possible necessity collapses to necessity. This is a characteristic theorem of S5 that distinguishes it from S4.

**Lean Signature**:
```lean
theorem s5_diamond_box (A : Formula) : [] ⊢ (A.box.diamond).iff A.box
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

**Task 34: Derive Box-Disjunction Introduction**
**Effort**: 3-4 hours
**Status**: Not Started
**Priority**: Medium (modal disjunction reasoning)
**Blocking**: None
**Dependencies**: Uses modal_k_dist axiom

**Description**: Prove `⊢ (□A ∨ □B) → □(A ∨ B)`. If either A or B is necessary, then their disjunction is necessary. Note: converse is not generally valid.

**Lean Signature**:
```lean
theorem box_disj_intro (A B : Formula) : [] ⊢ (A.box.or B.box).imp ((A.or B).box)
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

**Task 35: Derive Box-Contraposition**
**Effort**: 3-4 hours
**Status**: Not Started
**Priority**: Medium (modal + propositional interaction)
**Blocking**: None
**Dependencies**: Uses modal_k_dist, contraposition theorem

**Description**: Prove `⊢ □(A → B) → □(¬B → ¬A)`. Necessity preserves contraposition. Combines modal and propositional reasoning.

**Lean Signature**:
```lean
theorem box_contrapose (A B : Formula) : [] ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box)
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

**Task 36: Derive T-Box-Consistency**
**Effort**: 4-5 hours
**Status**: Not Started
**Priority**: Medium (consistency reasoning)
**Blocking**: None
**Dependencies**: Uses modal_t, contradiction reasoning

**Description**: Prove `⊢ ¬□(A ∧ ¬A)`. Contradictions cannot be necessary. Fundamental consistency property of modal logic with T axiom.

**Lean Signature**:
```lean
theorem t_box_consistent (A : Formula) : [] ⊢ (A.and A.neg).box.neg
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

**Task 37: Derive S5-Diamond-Box-to-Truth**
**Effort**: 4-5 hours
**Status**: Not Started
**Priority**: Medium (S5 characteristic theorem)
**Blocking**: None
**Dependencies**: Uses s5_diamond_box, modal_t

**Description**: Prove `⊢ ◇□A → A`. In S5, if necessary A is possible, then A is true. Follows from s5_diamond_box collapse + modal_t.

**Lean Signature**:
```lean
theorem s5_diamond_box_to_truth (A : Formula) : [] ⊢ (A.box.diamond).imp A
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

**Task 38: Derive S4-Diamond-Box-Conjunction**
**Effort**: 6-8 hours
**Status**: Not Started
**Priority**: Low (S4-specific, may need S4 variant of Logos)
**Blocking**: None
**Dependencies**: Uses modal_4, complex modal reasoning

**Description**: Prove `⊢ (◇A ∧ □B) → ◇(A ∧ □B)`. In S4, possibility of A conjoined with necessity of B implies possibility of their conjunction where B remains necessary. Requires significant modal interaction reasoning.

**Lean Signature**:
```lean
theorem s4_diamond_box_conj (A B : Formula) : [] ⊢ (A.diamond.and B.box).imp ((A.and B.box).diamond)
```

**Files**: `Logos/Core/Theorems/ModalS4.lean` (new file for S4-specific theorems)

---

**Task 39: Derive S4-Box-Diamond-Box**
**Effort**: 6-8 hours
**Status**: Not Started
**Priority**: Low (S4-specific)
**Blocking**: None
**Dependencies**: Uses modal_4, modal_b axioms

**Description**: Prove `⊢ □A → □◇□A`. In S4, necessity implies necessary possibility of necessity. Characteristic S4 theorem involving nested modalities.

**Lean Signature**:
```lean
theorem s4_box_diamond_box (A : Formula) : [] ⊢ A.box.imp ((A.box.diamond).box)
```

**Files**: `Logos/Core/Theorems/ModalS4.lean`

---

**Task 40: Derive S4-Diamond-Box-Diamond Equivalence**
**Effort**: 7-9 hours
**Status**: Not Started
**Priority**: Low (S4-specific, complex)
**Blocking**: None
**Dependencies**: Uses modal_4, complex nested modality reasoning

**Description**: Prove `⊢ ◇□◇A ↔ ◇A`. In S4, possible-necessary-possible collapses to possible. Requires sophisticated reasoning about nested modalities.

**Lean Signature**:
```lean
theorem s4_diamond_box_diamond (A : Formula) : [] ⊢ (A.diamond.box.diamond).iff A.diamond
```

**Files**: `Logos/Core/Theorems/ModalS4.lean`

---

**Task 41: Derive S5-Diamond-Conjunction-Diamond**
**Effort**: 7-9 hours
**Status**: Not Started
**Priority**: Low (S5-specific, complex)
**Blocking**: None
**Dependencies**: Uses modal_5 theorem, complex S5 reasoning

**Description**: Prove `⊢ ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)`. In S5, possibility distributes through conjunction even with nested possibility. Characteristic S5 theorem.

**Lean Signature**:
```lean
theorem s5_diamond_conj_diamond (A B : Formula) : [] ⊢ ((A.and B.diamond).diamond).iff (A.diamond.and B.diamond)
```

**Files**: `Logos/Core/Theorems/ModalS5.lean`

---

## Low Priority Tasks

---

### 9. Begin Completeness Proofs
**Effort**: 70-90 hours
**Status**: Not Started
**Priority**: Low (long-term metalogic goal)
**Blocking**: None
**Dependencies**: Benefits from completed soundness proofs

**Description**: Implement canonical model construction and prove completeness theorems (weak and strong). This is a major undertaking requiring significant effort.

**Phases**:
1. **Phase 1** (20-30 hours): Prove Lindenbaum lemma and maximal set properties
2. **Phase 2** (20-30 hours): Construct canonical model components
3. **Phase 3** (20-30 hours): Prove truth lemma and completeness theorems

**Files**:
- `Logos/Core/Metalogic/Completeness.lean` (11 axiom declarations requiring proofs)

**Technical Debt**: See [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) for detailed resolution guidance.

**Notes**: This is the largest remaining task for Layer 0 completion. Can be deferred to Layer 1 planning phase.

---

### 10. Create Decidability Module
**Effort**: 40-60 hours
**Status**: Not Started
**Priority**: Low (future enhancement, not in MVP)
**Blocking**: None
**Dependencies**: Requires Task 9 (completeness proofs for correctness)

**Description**: Create Logos/Core/Metalogic/Decidability.lean module with tableau method for validity checking and satisfiability decision procedures.

**Phases**:
1. **Phase 1** (15-20 hours): Design decidability architecture
2. **Phase 2** (15-20 hours): Implement tableau method
3. **Phase 3** (10-20 hours): Prove correctness and complexity

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (does not exist, planned)

**Notes**: Planned but not essential for Layer 0. Can be deferred to Layer 1 or beyond.

---

### 11. Plan Layer 1/2/3 Extensions
**Effort**: 20-40 hours (research phase)
**Status**: Not Started
**Priority**: Low (future work, after Layer 0 complete)
**Blocking**: None
**Dependencies**: Requires Layer 0 completion

**Description**: Design and plan extensions beyond Core TM (Layer 0): counterfactual operators (Layer 1), epistemic operators (Layer 2), normative operators (Layer 3).

**Action Items**:
1. **Layer 1 (Counterfactuals)**: Design `box_c` (would-counterfactual) and `diamond_m` (might-counterfactual) operators
2. **Layer 2 (Epistemic)**: Design `K` (knowledge) and `B` (belief) operators
3. **Layer 3 (Normative)**: Design `O` (obligation) and `P` (permission) operators
4. Create implementation plans for each layer
5. Update ARCHITECTURE.md with layer design

**Notes**: Strategic planning for post-MVP development. Should not begin until Layer 0 is complete and tested.

---

## Completion History

Completed tasks are tracked via git history. Query completion records:

```bash
# View all task completions
git log --all --grep="Complete Task" --oneline

# Find when specific task completed
git log --all --grep="Task 7" --oneline

# View spec summaries for detailed completion narratives
find .claude/specs -name "*summary*.md" | head -20

# Search summaries for task
grep -r "Task 5" .claude/specs/*/summaries/
```

See [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) for complete workflow documentation.

---

## Project References

- **Module Status**: [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) for detailed module-by-module tracking
- **Gap Documentation**: [IMPLEMENTATION_STATUS.md - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) for current limitations and workarounds
- **System Design**: [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md) for TM logic specification
- **Technical Debt**: [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) for sorry placeholder tracking

**Notes**:
- Priority levels reflect blocking status and estimated timeline, not importance
- Effort estimates are conservative and may vary based on implementation complexity
- Dependencies are indicated inline with each task

---

**Last Updated**: 2025-12-09 (Added 21 Hilbert theorem tasks: 14 propositional + 7 modal logic theorems from LogicNotes.tex)
