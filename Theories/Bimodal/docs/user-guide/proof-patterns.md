# Bimodal Proof Patterns

Common patterns for proving theorems in Bimodal TM logic.

## Pattern 1: Direct Axiom Application

For theorems that are instances of axiom schemas:

```lean
-- Modal T: □φ → φ
example (φ : Formula) : ⊢ φ.box.imp φ := modal_t φ

-- Modal K: □(φ → ψ) → (□φ → □ψ)
example (φ ψ : Formula) : ⊢ (φ.imp ψ).box.imp (φ.box.imp ψ.box) :=
  modal_k φ ψ

-- Modal 4: □φ → □□φ
example (φ : Formula) : ⊢ φ.box.imp φ.box.box := modal_4 φ
```

## Pattern 2: Modus Ponens Chain

For proofs requiring implication elimination:

```lean
-- If we have ⊢ A → B and ⊢ A, derive ⊢ B
example (A B : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ A) : ⊢ B :=
  DerivationTree.modusPonens h1 h2

-- Chain multiple applications
example (A B C : Formula)
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) (h3 : ⊢ A) : ⊢ C :=
  DerivationTree.modusPonens h2 (DerivationTree.modusPonens h1 h3)
```

## Pattern 3: Necessitation

For deriving boxed formulas from theorems:

```lean
-- From ⊢ φ derive ⊢ □φ (Necessitation rule)
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box :=
  DerivationTree.necessitation h

-- Useful for modal reasoning chains
example (p q : Formula) : ⊢ (p.imp q).box.imp (p.box.imp q.box) := by
  exact modal_k p q
```

## Pattern 4: Temporal Necessitation

For temporal operators:

```lean
-- From ⊢ φ derive ⊢ △φ (always future)
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.future :=
  DerivationTree.temporalNecessitation h

-- From ⊢ φ derive ⊢ ▽φ (always past)
-- Use temporal necessitation with past operator
```

## Pattern 5: Transitivity Chains

For implications requiring transitivity:

```lean
-- Transitivity: (A → B) → ((B → C) → (A → C))
example (A B C : Formula) : ⊢ (A.imp B).imp ((B.imp C).imp (A.imp C)) :=
  transitivity A B C

-- Build proof chains using implication transitivity
example (A B C D : Formula)
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) (h3 : ⊢ C.imp D) : ⊢ A.imp D := by
  have h12 : ⊢ A.imp C := imp_trans h1 h2
  exact imp_trans h12 h3
```

## Pattern 6: Box-Diamond Duality

Using duality between `□` and `◇`:

```lean
-- ◇φ = ¬□¬φ (by definition)
-- □φ → ¬◇¬φ follows from contraposition

-- Use these for possibility reasoning
example (φ : Formula) : ⊢ φ.box.imp φ.diamond.neg.neg := by
  -- □φ → ¬¬◇φ via double negation and duality
  sorry  -- Implementation depends on specific helpers
```

## Pattern 7: Temporal-Modal Interaction

Combining tense and modality:

```lean
-- Modal-Future interaction (MF axiom)
-- □△φ ↔ △□φ (modality and future commute)

-- Modal-Past interaction (similar)
-- Use interaction axioms for mixed proofs
```

## Pattern 8: Weakening

Adding unused premises:

```lean
-- From Γ ⊢ φ derive (Γ ∪ {ψ}) ⊢ φ
example (φ ψ : Formula) (Γ : Context) (h : Γ ⊢ φ) :
    (ψ :: Γ) ⊢ φ :=
  DerivationTree.weakening h
```

## Pattern 9: Using Derived Theorems

Leverage proven theorems from the library:

```lean
-- From Bimodal.Theorems.Propositional
example (A B : Formula) : ⊢ A.imp (B.imp A) := theorem_1 A B
example (A B C : Formula) : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
  theorem_2 A B C

-- From Bimodal.Theorems.ModalS4
-- (Import specific theorem modules as needed)
```

## Pattern 10: Tactic-Based Proofs

Using automation for complex proofs:

```lean
-- Using modal_t tactic
example (φ : Formula) : ⊢ φ.box.imp φ := by
  modal_t

-- Using apply_axiom for specific axiom schemas
example (φ : Formula) : ⊢ φ.box.imp φ := by
  apply_axiom MT φ
```

## Common Mistakes

### Mistake 1: Wrong Operator Direction

```lean
-- WRONG: Trying to derive □φ from φ directly (only works for theorems)
-- CORRECT: Use necessitation only when premise is a theorem (⊢ φ, not Γ ⊢ φ)
```

### Mistake 2: Forgetting Imports

```lean
-- Always import appropriate modules
import Bimodal.Theorems.Propositional  -- For theorem_1, theorem_2, etc.
import Bimodal.Theorems.ModalS4        -- For S4-specific theorems
```

### Mistake 3: Type Confusion

```lean
-- WRONG: Treating Formula as Prop
-- CORRECT: Formula is a Type, proofs are DerivationTree terms
```

## See Also

- [QUICKSTART.md](QUICKSTART.md) - Getting started
- [AXIOM_REFERENCE.md](../reference/AXIOM_REFERENCE.md) - Complete axiom list
- [Examples](../../Examples/) - Full proof examples
