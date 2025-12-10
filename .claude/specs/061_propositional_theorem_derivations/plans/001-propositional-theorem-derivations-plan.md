# Lean Implementation Plan: Remaining Medium Priority Propositional Theorem Derivations

## Metadata
- **Date**: 2025-12-09
- **Feature**: Complete remaining propositional theorem derivations (Tasks 27-29)
- **Scope**: Derive NI, NE, DE, and BI_IMP theorems in Hilbert-style propositional logic using deduction theorem and classical reasoning
- **Status**: [COMPLETE]
- **Estimated Hours**: 12-18 hours
- **Complexity Score**: 24
- **Structure Level**: 0
- **Estimated Phases**: 5
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Lean Plan Format Alignment](../reports/4-lean_plan_format_alignment.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Executive Summary

This plan addresses the remaining medium priority propositional theorem derivations from TODO.md. Research reveals that Tasks 21-26 are **already complete** in the codebase. This plan focuses on completing:

- **Task 27**: NE (Negation Elimination) and NI (Negation Introduction)
- **Task 28**: DE (Disjunction Elimination)
- **Task 29**: BI (Biconditional Introduction) - implication form only (context versions exist)

## Pre-Implementation Verification

### Tasks Already Complete (Research Finding)

The following theorems are **already proven** in `Propositional.lean`:

| Task | Theorem | Signature | Status |
|------|---------|-----------|--------|
| 21 | `raa` | `⊢ A → (¬A → B)` | Complete |
| 22 | `efq` | `⊢ ¬A → (A → B)` | Complete |
| 23 | `lce`, `rce` | `[A ∧ B] ⊢ A`, `[A ∧ B] ⊢ B` | Complete |
| 24 | `ldi`, `rdi` | `[A] ⊢ A ∨ B`, `[B] ⊢ A ∨ B` | Complete |
| 25 | `rcp` | `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)` | Complete |
| 26 | `ecq` | `[A, ¬A] ⊢ B` | Complete |

**Additional theorems** beyond TODO scope also implemented:
- `lce_imp`, `rce_imp` (implication forms)
- `lem` (Law of Excluded Middle)
- `classical_merge` (case analysis)
- `contrapose_imp`, `contrapose_iff` (contraposition)
- `iff_intro`, `iff_elim_left`, `iff_elim_right` (biconditional)
- `demorgan_conj_neg`, `demorgan_disj_neg` (De Morgan laws)

### Tasks Remaining

| Task | Theorems | Description | Status |
|------|----------|-------------|--------|
| 27 | `ne`, `ni` | Negation Introduction/Elimination (proof by contradiction) | NOT STARTED |
| 28 | `de` | Disjunction Elimination (case analysis) | NOT STARTED |
| 29 | `bi_imp` | Biconditional Introduction (implication form) | NOT STARTED |

## Success Criteria

### Module Completion
- [ ] `ni` theorem proven with zero sorry
- [ ] `ne` theorem proven with zero sorry
- [ ] `de` theorem proven with zero sorry
- [ ] `bi_imp` theorem proven with zero sorry

### Quality Standards
- [ ] Zero `#lint` warnings in modified modules
- [ ] Build time <3 minutes total
- [ ] All new theorems have docstrings with mathematical statements
- [ ] All theorems include complexity classification (Simple/Medium/Complex)

### Documentation
- [ ] IMPLEMENTATION_STATUS.md updated
- [ ] TODO.md updated (Tasks 21-29 marked complete)

---

## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | software | implementer-coordinator |

---

### Phase 1: Negation Introduction (NI) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: []

**Effort**: 4-5 hours

**Objective**: Prove `ni`: if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`

**Background**:
Negation Introduction (NI) is the standard proof-by-contradiction pattern. If assuming A leads to a contradiction (both B and ¬B), then ¬A holds.

**Theorems**:

- [x] `ni`: Negation Introduction
  - Goal: `(A B : Formula) → (h1 : (A :: Γ) ⊢ B.neg) → (h2 : (A :: Γ) ⊢ B) → Γ ⊢ A.neg`
  - Strategy:
    1. From `h1` and `h2`, derive `(A :: Γ) ⊢ ⊥` using modus_ponens (¬B = B → ⊥)
    2. Apply deduction_theorem: `Γ ⊢ A → ⊥` = `Γ ⊢ ¬A`
  - Complexity: Medium
  - Dependencies: `Derivable.modus_ponens`, `deduction_theorem`
  - Estimated: 4-5 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Propositional.lean
# Expected: no increase in sorry count
```

**Expected Duration**: 4-5 hours

---

### Phase 2: Negation Elimination (NE) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: [1]

**Effort**: 4-5 hours

**Objective**: Prove `ne`: if `Γ, ¬A ⊢ ¬B` and `Γ, ¬A ⊢ B`, then `Γ ⊢ A`

**Background**:
Negation Elimination (NE) is classical proof by contradiction (indirect proof). If assuming ¬A leads to a contradiction, then A holds.

**Theorems**:

- [x] `ne`: Negation Elimination
  - Goal: `(A B : Formula) → (h1 : (A.neg :: Γ) ⊢ B.neg) → (h2 : (A.neg :: Γ) ⊢ B) → Γ ⊢ A`
  - Strategy:
    1. From `h1` and `h2`, derive `(A.neg :: Γ) ⊢ ⊥` using modus_ponens
    2. Apply deduction_theorem: `Γ ⊢ ¬A → ⊥` = `Γ ⊢ ¬¬A`
    3. Apply DNE (double_negation axiom): `Γ ⊢ A`
  - Complexity: Medium
  - Dependencies: `Derivable.modus_ponens`, `Derivable.weakening`, `Axiom.double_negation`, `deduction_theorem`
  - Estimated: 4-5 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Propositional.lean
```

**Expected Duration**: 4-5 hours

---

### Phase 3: Disjunction Elimination (DE) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: [1, 2]

**Effort**: 5-7 hours

**Objective**: Prove `de`: if `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`

**Background**:
Disjunction Elimination (DE) is case analysis. If we can derive C from either A or B (separately), then from A ∨ B we can derive C.

Recall: `A ∨ B = ¬A → B` (defined via implication and negation)

**Theorems**:

- [x] `de`: Disjunction Elimination
  - Goal: `(A B C : Formula) → (h1 : (A :: Γ) ⊢ C) → (h2 : (B :: Γ) ⊢ C) → ((A.or B) :: Γ) ⊢ C`
  - Strategy:
    1. Apply deduction_theorem to get `Γ ⊢ A → C` and `Γ ⊢ B → C`
    2. Weaken both to `((A.or B) :: Γ)`
    3. Get `A ∨ B = ¬A → B` from context via assumption
    4. Apply `classical_merge`: `(A → C) → ((¬A → C) → C)`
    5. Compose `A ∨ B` with `B → C` via b_combinator to get `¬A → C`
    6. Apply modus_ponens chain to derive C
  - Complexity: Complex
  - Dependencies: `deduction_theorem`, `Derivable.weakening`, `classical_merge`, `b_combinator`, `Derivable.assumption`
  - Estimated: 5-7 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Propositional.lean
```

**Expected Duration**: 5-7 hours

---

### Phase 4: Biconditional Introduction (Implication Form) [COMPLETE]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: []

**Effort**: 2-3 hours

**Objective**: Prove `bi_imp`: `⊢ (A → B) → ((B → A) → (A ↔ B))`

**Background**:
This is the curried form of biconditional introduction for compositional proofs. The context-based `iff_intro` already exists; this provides the implication form.

**Theorems**:

- [x] `bi_imp`: Biconditional Introduction (Implication Form)
  - Goal: `(A B : Formula) → ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A)))`
  - Strategy:
    1. From `[(A → B), (B → A)]`, derive both by assumption
    2. Apply `pairing` to get `(A → B) ∧ (B → A)`
    3. Apply deduction_theorem twice to lift to pure implication form
  - Complexity: Medium
  - Dependencies: `deduction_theorem`, `pairing`, `Derivable.assumption`, `Derivable.weakening`
  - Estimated: 2-3 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Propositional.lean
```

**Expected Duration**: 2-3 hours

---

### Phase 5: Documentation and Testing [COMPLETE]
implementer: software
dependencies: [1, 2, 3, 4]

**Effort**: 1-2 hours

**Objective**: Update documentation and verify all theorems

**Tasks**:

- [x] Update TODO.md to mark Tasks 21-29 as complete
- [x] Update IMPLEMENTATION_STATUS.md with new theorem count
- [x] Verify `lake build` passes
- [x] Run `lake test` to ensure no regressions

**Testing**:
```bash
lake build
lake test
```

**Expected Duration**: 1-2 hours

---

## Risk Assessment

### Low Risk
- **NI (Phase 1)**: Direct application of modus ponens + deduction theorem
- **BI_IMP (Phase 4)**: Simple deduction theorem application

### Medium Risk
- **NE (Phase 2)**: Requires DNE composition; well-understood pattern from `rcp`

### Higher Risk
- **DE (Phase 3)**: Most complex proof; requires composing `classical_merge`, `b_combinator`, and disjunction definition. May require additional helper lemmas.

### Mitigation
- DE proof can leverage existing `classical_merge` which is essentially case analysis
- All required infrastructure (deduction theorem, combinators, DNE) is already proven
- Fallback: If DE is blocked, document the gap and continue with other tasks

---

## Appendix A: Available Infrastructure

### From Perpetuity.lean
- `identity`: `⊢ A → A`
- `b_combinator`: `⊢ (B → C) → (A → B) → (A → C)`
- `theorem_flip`: `⊢ (A → B → C) → (B → A → C)`
- `imp_trans`: `(⊢ A → B) → (⊢ B → C) → (⊢ A → C)`
- `pairing`: `⊢ A → B → (A ∧ B)`
- `dni`: `⊢ A → ¬¬A`
- `contraposition`: `(⊢ A → B) → (⊢ ¬B → ¬A)`

### From Propositional.lean
- `classical_merge`: `⊢ (P → Q) → ((¬P → Q) → Q)`
- `contrapose_imp`: `⊢ (A → B) → (¬B → ¬A)`
- `efq`: `⊢ ¬A → (A → B)`
- `rcp`: `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)`

### From DeductionTheorem.lean
- `deduction_theorem`: `(A :: Γ) ⊢ B → Γ ⊢ A → B`

---

## Appendix B: Post-Plan Actions

After completing this plan:

1. **Update TODO.md**: Mark Tasks 21-29 as COMPLETE
2. **Consider New Tasks**:
   - Tactic automation for propositional reasoning
   - Additional derived theorems (material conditional, etc.)
   - Integration tests for proof patterns
3. **Documentation**: Update PROPOSITIONAL_THEOREMS_GUIDE.md if it exists

---

**Plan Created**: 2025-12-09
**Plan Version**: 2.0 (Revised to lean-plan format)
**Research Reports**: 4-lean_plan_format_alignment.md
