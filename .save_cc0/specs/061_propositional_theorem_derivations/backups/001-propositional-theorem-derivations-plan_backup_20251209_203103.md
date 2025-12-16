# Implementation Plan: Remaining Medium Priority Propositional Theorem Derivations

- **Status**: [NOT STARTED]
- **Created**: 2025-12-09
- **Workflow**: /lean-plan
- **Feature**: Complete remaining propositional theorem derivations (Tasks 27-29)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Executive Summary

This plan addresses the remaining medium priority propositional theorem derivations from TODO.md. Research reveals that Tasks 21-26 are **already complete** in the codebase. This plan focuses on completing:

- **Task 27**: NE (Negation Elimination) and NI (Negation Introduction)
- **Task 28**: DE (Disjunction Elimination)
- **Task 29**: BI (Biconditional Introduction) - implication form only (context versions exist)

**Total Effort**: 12-18 hours (reduced from original 17-22 hours estimate due to existing infrastructure)

## Pre-Implementation Verification

### Tasks Already Complete (Research Finding)

The following theorems are **already proven** in `Propositional.lean`:

| Task | Theorem | Signature | Status |
|------|---------|-----------|--------|
| 21 | `raa` | `⊢ A → (¬A → B)` | ✓ Complete |
| 22 | `efq` | `⊢ ¬A → (A → B)` | ✓ Complete |
| 23 | `lce`, `rce` | `[A ∧ B] ⊢ A`, `[A ∧ B] ⊢ B` | ✓ Complete |
| 24 | `ldi`, `rdi` | `[A] ⊢ A ∨ B`, `[B] ⊢ A ∨ B` | ✓ Complete |
| 25 | `rcp` | `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)` | ✓ Complete |
| 26 | `ecq` | `[A, ¬A] ⊢ B` | ✓ Complete |

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

---

## Phase 1: Negation Introduction (NI) [NOT STARTED]

**Goal**: Prove `ni`: if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`

**Estimated Hours**: 4-5 hours

### Theorem Specification

```lean
/--
Negation Introduction: if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`.

If assuming A leads to a contradiction (both B and ¬B), then ¬A holds.
This is the standard proof-by-contradiction pattern.

**Proof Strategy**:
1. From `Γ, A ⊢ B` and `Γ, A ⊢ ¬B`, derive `Γ, A ⊢ ⊥` using modus ponens
2. Apply deduction theorem: `Γ ⊢ A → ⊥` = `Γ ⊢ ¬A`
-/
theorem ni (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg
```

### Implementation Steps

- [ ] `theorem_ni_step1`: Derive `(A :: Γ) ⊢ ⊥` from `h1` and `h2` using modus ponens
  - Goal: `(A :: Γ) ⊢ Formula.bot`
  - Strategy: `Derivable.modus_ponens (A :: Γ) B Formula.bot h1 h2`

- [ ] `theorem_ni`: Apply deduction theorem to lift to `Γ ⊢ A.neg`
  - Goal: `Γ ⊢ A.neg` where `A.neg = A → ⊥`
  - Strategy: `deduction_theorem Γ A Formula.bot step1`

### Success Criteria

- [ ] `ni` theorem compiles without error
- [ ] `ni` has zero `sorry` markers
- [ ] Docstring explains proof strategy
- [ ] Test case: `ni` applied to derive `⊢ ¬(A ∧ ¬A)` (contradiction is false)

### Dependencies

- `Derivable.modus_ponens`
- `deduction_theorem` (from DeductionTheorem.lean)

---

## Phase 2: Negation Elimination (NE) [NOT STARTED]

**Goal**: Prove `ne`: if `Γ, ¬A ⊢ ¬B` and `Γ, ¬A ⊢ B`, then `Γ ⊢ A`

**Estimated Hours**: 4-5 hours

### Theorem Specification

```lean
/--
Negation Elimination: if `Γ, ¬A ⊢ ¬B` and `Γ, ¬A ⊢ B`, then `Γ ⊢ A`.

If assuming ¬A leads to a contradiction, then A holds.
This is classical proof by contradiction (indirect proof).

**Proof Strategy**:
1. From `Γ, ¬A ⊢ B` and `Γ, ¬A ⊢ ¬B`, derive `Γ, ¬A ⊢ ⊥` using modus ponens
2. Apply deduction theorem: `Γ ⊢ ¬A → ⊥` = `Γ ⊢ ¬¬A`
3. Apply DNE: `Γ ⊢ A`
-/
theorem ne (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A
```

### Implementation Steps

- [ ] `theorem_ne_step1`: Derive `(A.neg :: Γ) ⊢ ⊥` from `h1` and `h2`
  - Goal: `(A.neg :: Γ) ⊢ Formula.bot`
  - Strategy: `Derivable.modus_ponens (A.neg :: Γ) B Formula.bot h1 h2`

- [ ] `theorem_ne_step2`: Apply deduction theorem to get `Γ ⊢ ¬¬A`
  - Goal: `Γ ⊢ A.neg.neg`
  - Strategy: `deduction_theorem Γ A.neg Formula.bot step1`

- [ ] `theorem_ne`: Apply DNE to get `Γ ⊢ A`
  - Goal: `Γ ⊢ A`
  - Strategy:
    1. Weaken `Derivable.axiom [] _ (Axiom.double_negation A)` to `Γ`
    2. Apply modus ponens with `step2`

### Success Criteria

- [ ] `ne` theorem compiles without error
- [ ] `ne` has zero `sorry` markers
- [ ] Docstring explains proof strategy
- [ ] Test case: Derive `⊢ ¬¬A → A` using `ne` as indirect method

### Dependencies

- `Derivable.modus_ponens`
- `Derivable.weakening`
- `Axiom.double_negation`
- `deduction_theorem`

---

## Phase 3: Disjunction Elimination (DE) [NOT STARTED]

**Goal**: Prove `de`: if `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`

**Estimated Hours**: 5-7 hours

### Theorem Specification

```lean
/--
Disjunction Elimination (Case Analysis): if `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`.

If we can derive C from either A or B (separately), then from A ∨ B we can derive C.
This is the standard case-split reasoning pattern.

**Recall**: `A ∨ B = ¬A → B`

**Proof Strategy**:
1. Apply deduction theorem to get `Γ ⊢ A → C` and `Γ ⊢ B → C`
2. Contrapose `Γ ⊢ A → C` to get `Γ ⊢ ¬C → ¬A`
3. From `A ∨ B = ¬A → B` and `Γ ⊢ ¬C → ¬A`, compose to get `Γ, A ∨ B ⊢ ¬C → B`
4. From `Γ ⊢ B → C`, contrapose to `Γ ⊢ ¬C → ¬B`
5. Build contradiction: `Γ, A ∨ B ⊢ ¬C → B` and `Γ ⊢ ¬C → ¬B`
6. Use classical_merge or NI pattern to derive `Γ, A ∨ B ⊢ C`
-/
theorem de (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) :
    ((A.or B) :: Γ) ⊢ C
```

### Implementation Steps

- [ ] `theorem_de_lemma1`: Apply deduction theorem to `h1` to get `Γ ⊢ A → C`
  - Goal: `Γ ⊢ A.imp C`
  - Strategy: `deduction_theorem Γ A C h1`

- [ ] `theorem_de_lemma2`: Apply deduction theorem to `h2` to get `Γ ⊢ B → C`
  - Goal: `Γ ⊢ B.imp C`
  - Strategy: `deduction_theorem Γ B C h2`

- [ ] `theorem_de_lemma3`: Weaken both to `((A.or B) :: Γ)`
  - Goal: `((A.or B) :: Γ) ⊢ A.imp C` and `((A.or B) :: Γ) ⊢ B.imp C`
  - Strategy: `Derivable.weakening Γ ((A.or B) :: Γ) _ lemma1/2 subset_proof`

- [ ] `theorem_de_lemma4`: Build case analysis using `classical_merge` pattern
  - Goal: `((A.or B) :: Γ) ⊢ C`
  - Strategy: Use `A.or B = ¬A → B`:
    1. Get `A ∨ B` from context
    2. Apply classical_merge: `(A → C) → ((¬A → C) → C)`
    3. Need `¬A → C` from `(¬A → B) → (B → C) → (¬A → C)`
    4. Compose `A ∨ B` with `B → C` to get `¬A → C`

- [ ] `theorem_de`: Final composition
  - Goal: `((A.or B) :: Γ) ⊢ C`
  - Strategy: Apply modus ponens with classical_merge and composed arguments

### Success Criteria

- [ ] `de` theorem compiles without error
- [ ] `de` has zero `sorry` markers
- [ ] Docstring explains case analysis proof strategy
- [ ] Test case: From `[A] ⊢ A ∨ B` and `[B] ⊢ A ∨ B`, derive `[A ∨ B] ⊢ A ∨ B`

### Dependencies

- `deduction_theorem`
- `Derivable.weakening`
- `classical_merge`
- `b_combinator` (for composition)
- `Derivable.assumption`

---

## Phase 4: Biconditional Introduction (Implication Form) [NOT STARTED]

**Goal**: Prove `bi_imp`: `⊢ (A → B) → ((B → A) → (A ↔ B))`

**Estimated Hours**: 2-3 hours

### Theorem Specification

```lean
/--
Biconditional Introduction (Implication Form): `⊢ (A → B) → ((B → A) → (A ↔ B))`.

Curried form of biconditional introduction for compositional proofs.

**Note**: The context-based `iff_intro` already exists. This provides the
implication form for compositional reasoning without context manipulation.

**Proof Strategy**: Use deduction theorem twice on `iff_intro`.
-/
theorem bi_imp (A B : Formula) : ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A)))
```

### Implementation Steps

- [ ] `theorem_bi_imp_inner`: From `[(A → B), (B → A)]`, derive `(A → B) ∧ (B → A)`
  - Goal: `[(A.imp B), (B.imp A)] ⊢ (A.imp B).and (B.imp A)`
  - Strategy: Get assumptions, apply `pairing`

- [ ] `theorem_bi_imp_step1`: Apply deduction theorem for `(B → A)`
  - Goal: `[(A.imp B)] ⊢ (B.imp A).imp ((A.imp B).and (B.imp A))`
  - Strategy: `deduction_theorem [(A.imp B)] (B.imp A) _ inner`

- [ ] `theorem_bi_imp`: Apply deduction theorem for `(A → B)`
  - Goal: `⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A)))`
  - Strategy: `deduction_theorem [] (A.imp B) _ step1`

### Success Criteria

- [ ] `bi_imp` theorem compiles without error
- [ ] `bi_imp` has zero `sorry` markers
- [ ] Docstring explains currying strategy
- [ ] Test case: Derive `⊢ A ↔ A` using `bi_imp` and `identity`

### Dependencies

- `deduction_theorem`
- `pairing`
- `Derivable.assumption`
- `Derivable.weakening`

---

## Phase 5: Documentation and Testing [NOT STARTED]

**Goal**: Update documentation and verify all theorems

**Estimated Hours**: 1-2 hours

### Implementation Steps

- [ ] Update TODO.md to mark Tasks 21-29 as complete
- [ ] Update IMPLEMENTATION_STATUS.md with new theorem count
- [ ] Verify `lake build` passes
- [ ] Run `lake test` to ensure no regressions

### Success Criteria

- [ ] TODO.md updated with completion status
- [ ] IMPLEMENTATION_STATUS.md reflects accurate theorem counts
- [ ] `lake build` succeeds
- [ ] `lake test` passes (if tests exist)

---

## Risk Assessment

### Low Risk
- **NI (Task 27)**: Direct application of modus ponens + deduction theorem
- **BI_IMP (Task 29)**: Simple deduction theorem application

### Medium Risk
- **NE (Task 27)**: Requires DNE composition; well-understood pattern from `rcp`

### Higher Risk
- **DE (Task 28)**: Most complex proof; requires composing `classical_merge`, `b_combinator`, and disjunction definition. May require additional helper lemmas.

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
