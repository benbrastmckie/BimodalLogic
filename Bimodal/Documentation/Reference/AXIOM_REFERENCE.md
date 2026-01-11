# Bimodal Axiom Reference

Complete reference for TM (Tense and Modality) axiom schemas.

## Axiom Categories

TM logic uses 14 axiom schemas organized into categories:

| Category | Count | Purpose |
|----------|-------|---------|
| Propositional | 3 | Classical propositional logic |
| Modal | 4 | Necessity and possibility |
| Temporal | 4 | Past and future operators |
| Interaction | 3 | Modal-temporal combinations |

## Propositional Axioms

### P1 (K-Axiom for Implication)

**Schema**: `⊢ φ → (ψ → φ)`

**Lean**:
```lean
theorem theorem_1 (A B : Formula) : ⊢ A.imp (B.imp A)
```

**Example**:
```lean
example (p q : Formula) : ⊢ p.imp (q.imp p) := theorem_1 p q
```

### P2 (S-Axiom)

**Schema**: `⊢ (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`

**Lean**:
```lean
theorem theorem_2 (A B C : Formula) :
    ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C))
```

### P3 (Contraposition)

**Schema**: `⊢ (¬φ → ¬ψ) → (ψ → φ)`

**Lean**:
```lean
-- Available as contraposition theorem
theorem contraposition (A B : Formula) :
    ⊢ (A.neg.imp B.neg).imp (B.imp A)
```

## Modal Axioms

### MT (Modal T)

**Schema**: `⊢ □φ → φ`
**Meaning**: What is necessary is true (reflexivity of accessibility).

**Lean**:
```lean
theorem modal_t (φ : Formula) : ⊢ φ.box.imp φ
```

**Example**:
```lean
example (p : Formula) : ⊢ p.box.imp p := modal_t p
```

### M4 (Modal 4)

**Schema**: `⊢ □φ → □□φ`
**Meaning**: Necessity iterates (transitivity of accessibility).

**Lean**:
```lean
theorem modal_4 (φ : Formula) : ⊢ φ.box.imp φ.box.box
```

### MB (Modal B)

**Schema**: `⊢ φ → □◇φ`
**Meaning**: What is true is necessarily possible (symmetry).

**Lean**:
```lean
theorem modal_b (φ : Formula) : ⊢ φ.imp φ.diamond.box
```

### MK (Modal K, Distribution)

**Schema**: `⊢ □(φ → ψ) → (□φ → □ψ)`
**Meaning**: Necessity distributes over implication.

**Lean**:
```lean
theorem modal_k (φ ψ : Formula) : ⊢ (φ.imp ψ).box.imp (φ.box.imp ψ.box)
```

## Temporal Axioms

### T4 (Future 4)

**Schema**: `⊢ △φ → △△φ`
**Meaning**: "Always future" iterates.

**Lean**:
```lean
theorem future_4 (φ : Formula) : ⊢ φ.future.imp φ.future.future
```

### TA (Temporal A)

**Schema**: `⊢ △φ → ▽△φ`
**Meaning**: What will always be was always going to always be.

**Lean**:
```lean
theorem temporal_a (φ : Formula) : ⊢ φ.future.imp φ.future.past
```

### TL (Temporal Left)

**Schema**: `⊢ ▽△φ → φ`
**Meaning**: If it was always the case that φ would always be, then φ.

**Lean**:
```lean
theorem temporal_left (φ : Formula) : ⊢ φ.future.past.imp φ
```

### TK (Temporal K, Distribution)

**Schema**: `⊢ △(φ → ψ) → (△φ → △ψ)`
**Meaning**: "Always future" distributes over implication.

**Lean**:
```lean
theorem temporal_k (φ ψ : Formula) : ⊢ (φ.imp ψ).future.imp (φ.future.imp ψ.future)
```

## Interaction Axioms

### MF (Modal-Future)

**Schema**: `⊢ □△φ ↔ △□φ`
**Meaning**: Necessity and "always future" commute.

**Lean**:
```lean
-- Left-to-right direction
theorem box_future_comm_lr (φ : Formula) : ⊢ φ.future.box.imp φ.box.future
-- Right-to-left direction
theorem box_future_comm_rl (φ : Formula) : ⊢ φ.box.future.imp φ.future.box
```

### TF (Temporal-Past Future)

**Schema**: `⊢ □▽φ ↔ ▽□φ`
**Meaning**: Necessity and "always past" commute.

**Lean**:
```lean
-- Similar structure to MF
```

### TD (Temporal Duality)

**Schema**: `⊢ △φ ↔ ¬▽¬φ`
**Meaning**: "Always future" is dual to "sometimes past negation".

## Inference Rules

### Modus Ponens (MP)

**Rule**: From `⊢ φ → ψ` and `⊢ φ`, derive `⊢ ψ`

**Lean**:
```lean
DerivationTree.modusPonens : DerivationTree Γ (φ.imp ψ) →
    DerivationTree Γ φ → DerivationTree Γ ψ
```

### Necessitation (N)

**Rule**: From `⊢ φ`, derive `⊢ □φ`

**Lean**:
```lean
DerivationTree.necessitation : DerivationTree [] φ → DerivationTree [] φ.box
```

**Note**: Only applies when `φ` is a theorem (derived from empty context).

### Temporal Necessitation (TN)

**Rule**: From `⊢ φ`, derive `⊢ △φ`

**Lean**:
```lean
DerivationTree.temporalNecessitation : DerivationTree [] φ →
    DerivationTree [] φ.future
```

## Axiom Application Examples

### Example 1: Derive `□p → ◇p`

```lean
-- Strategy: □p → p (MT), p → ◇p (from B contraposed)
example (p : Formula) : ⊢ p.box.imp p.diamond := by
  have h1 := modal_t p         -- □p → p
  have h2 := dia_intro p       -- p → ◇p (derived)
  exact imp_trans h1 h2
```

### Example 2: Derive `□(p → q) → □p → □q`

```lean
-- Direct application of Modal K
example (p q : Formula) : ⊢ (p.imp q).box.imp (p.box.imp q.box) :=
  modal_k p q
```

### Example 3: Use Necessitation

```lean
-- From theorem (p → p), derive □(p → p)
example (p : Formula) : ⊢ (p.imp p).box := by
  have h := imp_refl p           -- ⊢ p → p
  exact DerivationTree.necessitation h
```

## See Also

- [Bimodal Syntax](../../Syntax/Formula.lean) - Formula constructors
- [Bimodal ProofSystem](../../ProofSystem/Axioms.lean) - Axiom definitions
- [Proof Patterns](../UserGuide/PROOF_PATTERNS.md) - How to use axioms
