# Research Report: TODO.md Integration and Documentation

**Topic**: TODO.md Integration for Hilbert Theorems
**Date**: 2025-12-09
**Researcher**: Claude (research-specialist)

## Executive Summary

This report documents the formatting and organization strategy for adding the 25 unproven theorems (14 propositional + 11 modal) to the Medium Priority Tasks section of TODO.md, following the project's task tracking conventions.

## Current TODO.md Structure

From `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md`:

**Medium Priority Section** (lines 60-62):
- Currently contains a placeholder path: `/home/benjamin/Documents/Philosophy/Teaching/LogicNotes/LogicNotes.tex`
- No active medium priority tasks listed
- Should contain derivation and theorem proving tasks

**Format Requirements** (from Update Instructions, lines 7-11):
1. Task description
2. Effort estimate
3. Status indicator
4. Priority level
5. Blocking/dependency information

## Proposed TODO.md Additions

### Propositional Logic Hilbert Theorems (14 tasks)

#### Simple Theorems (Immediate Priority)

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

#### Medium Complexity (Context Manipulation)

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

### Modal Logic Theorems (11 tasks)

#### Simple S5 Theorems (Immediate Priority)

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

#### Medium Complexity (Modal Reasoning)

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

#### Complex Theorems (Long-term Priority)

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

## Summary Statistics

**Total Tasks**: 21 (Tasks 21-41)
**Propositional**: 9 tasks (21-29)
**Modal**: 12 tasks (30-41)

**Effort Breakdown**:
- Simple tasks (2-5 hours): 10 tasks
- Medium tasks (5-7 hours): 6 tasks
- Complex tasks (7-9 hours): 5 tasks
- **Total estimated effort**: 95-125 hours

**Priority Distribution**:
- High priority (immediate): 7 tasks (21-24, 30-32)
- Medium priority: 9 tasks (25-29, 33-37)
- Low priority (long-term): 5 tasks (38-41)

## Key Findings

1. **File organization**: Create two new files:
   - `Logos/Core/Theorems/Propositional.lean` for propositional theorems
   - `Logos/Core/Theorems/ModalS5.lean` for modal S5 theorems
   - `Logos/Core/Theorems/ModalS4.lean` for S4-specific theorems (optional, low priority)

2. **Dependencies**: Many theorems build on each other (e.g., ECQ from RAA/EFQ, RCP from CP)

3. **Infrastructure needs**:
   - Context manipulation for NE, NI, DE, BI
   - Disjunction reasoning may need additional derived operators
   - Biconditional reasoning infrastructure

4. **Integration with existing work**: Many theorems extend Perpetuity.lean combinator work

## Recommendations

1. **Immediate focus** (Tasks 21-24, 30-32): 7 simple tasks, ~18-26 hours total
2. **Next wave** (Tasks 25-29, 33-37): 9 medium tasks, ~37-51 hours total
3. **Long-term** (Tasks 38-41): 5 complex S4/S5 tasks, ~27-35 hours total

## TODO.md Formatting Notes

- Each task follows standard format: Description, Effort, Status, Priority, Blocking, Dependencies
- Include Lean signatures for clarity
- Reference existing theorems and axioms
- Group by complexity/priority
- Link to implementation files
- Update "Active Tasks" count in Overview section
- Update "Last Updated" date after modifications
