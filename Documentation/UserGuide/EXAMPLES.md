# Logos Examples

This document provides comprehensive examples of modal, temporal, and bimodal reasoning using Logos.

## 1. Modal Logic Examples

### S5 Axiom Proofs

#### Axiom MT: `□φ → φ` (Reflexivity)

```lean
/-- Prove the reflexivity axiom MT: what is necessary is actual -/
example (P : Formula) : ⊢ (P.box.imp P) := by
  apply Derivable.axiom
  apply Axiom.modal_t

/-- Using DSL syntax -/
example : ⊢ (□"p" → "p") := by
  apply Derivable.axiom
  apply Axiom.modal_t
```

#### Axiom M4: `□φ → □□φ` (Transitivity)

```lean
/-- Prove the transitivity axiom M4: necessity iterates -/
example (P : Formula) : ⊢ (P.box.imp P.box.box) := by
  apply Derivable.axiom
  apply Axiom.modal_4

/-- Chain of necessities -/
example (P : Formula) : [P.box] ⊢ P.box.box.box := by
  apply Derivable.modus_ponens
  · apply Derivable.axiom; apply Axiom.modal_4
  · apply Derivable.modus_ponens
    · apply Derivable.axiom; apply Axiom.modal_4
    · apply Derivable.assumption; simp
```

#### Axiom MB: `φ → □◇φ` (Symmetry)

```lean
/-- Prove the symmetry axiom MB: actuality implies necessary possibility -/
example (P : Formula) : ⊢ (P.imp (diamond P).box) := by
  apply Derivable.axiom
  apply Axiom.modal_b

/-- Using the axiom to derive a fact -/
example (P : Formula) : [P] ⊢ (diamond P).box := by
  apply Derivable.modus_ponens
  · apply Derivable.axiom; apply Axiom.modal_b
  · apply Derivable.assumption; simp
```

### Diamond as Derived Operator

```lean
/-- Diamond is defined as `¬□¬` -/
example (P : Formula) : diamond P = neg (Formula.box (neg P)) := rfl

/-- Prove `◇p` from `p` using MB -/
example (P : Formula) : [P] ⊢ diamond P := by
  -- From P, we can derive `□◇P` (by MB)
  -- From `□◇P`, we get `◇P` (by MT on `◇P`)
  sorry -- Full proof requires intermediate steps
```

### Key S5 Theorems

```lean
/-- In S5, `□φ ↔ □□φ` -/
theorem box_idempotent (P : Formula) :
  (⊢ P.box.imp P.box.box) ∧ (⊢ P.box.box.imp P.box) := by
  constructor
  · apply Derivable.axiom; apply Axiom.modal_4
  · -- `□□φ → □φ` is derivable using MT on `□φ`
    sorry

/-- In S5, `◇φ ↔ ◇◇φ` -/
theorem diamond_idempotent (P : Formula) :
  (⊢ (diamond P).imp (diamond (diamond P))) ∧
  (⊢ (diamond (diamond P)).imp (diamond P)) := by
  sorry

/-- In S5, `□◇φ ↔ ◇φ` -/
theorem box_diamond_collapse (P : Formula) :
  ⊢ ((diamond P).box.imp (diamond P)) := by
  apply Derivable.axiom
  apply Axiom.modal_t

/-- In S5, `◇□φ ↔ □φ` -/
theorem diamond_box_collapse (P : Formula) :
  ⊢ ((diamond P.box).imp P.box) := by
  sorry
```

## 2. Temporal Logic Examples

### Temporal Axiom Proofs

#### Axiom T4: Gφ → GGφ

```lean
/-- All-future iterates: what will always be will always always be -/
example (P : Formula) : ⊢ ((Formula.all_future P).imp (Formula.all_future (Formula.all_future P))) := by
  apply Derivable.axiom
  apply Axiom.temp_4
```

#### Axiom TA: φ → G(Pφ)

```lean
/-- Present implies future past: now will have been -/
example (P : Formula) : ⊢ (P.imp (Formula.all_future (some_past P))) := by
  apply Derivable.axiom
  apply Axiom.temp_a
```

#### Axiom TL: △φ → G(Hφ)

```lean
/-- Linearity: if always, then future has past -/
example (P : Formula) : ⊢ ((always P).imp (Formula.all_future (Formula.all_past P))) := by
  apply Derivable.axiom
  apply Axiom.temp_l
```

### Past and Future Operators

```lean
/-- Universal past (H): P holds at all past times -/
example (P : Formula) : Formula := Formula.all_past P

/-- Universal future (G): P holds at all future times -/
example (P : Formula) : Formula := Formula.all_future P

/-- Existential past (P): P held at some past time -/
example (P : Formula) : Formula := some_past P  -- ¬H¬P

/-- Existential future (F): P will hold at some future time -/
example (P : Formula) : Formula := some_future P  -- ¬G¬P
```

### Temporal Properties

```lean
/-- Always operator: Hφ ∧ φ ∧ Gφ -/
example (P : Formula) : always P = and (and (Formula.all_past P) P) (Formula.all_future P) := rfl

/-- Sometimes operator: Pφ ∨ φ ∨ Fφ -/
example (P : Formula) : sometimes P = or (or (some_past P) P) (some_future P) := rfl

/-- From always, derive present -/
example (P : Formula) : [always P] ⊢ P := by
  -- always P = Hφ ∧ φ ∧ Gφ
  -- Extract φ from the conjunction
  sorry

/-- From always, derive all_past -/
example (P : Formula) : [always P] ⊢ Formula.all_past P := by
  sorry

/-- From always, derive all_future -/
example (P : Formula) : [always P] ⊢ Formula.all_future P := by
  sorry
```

## 3. Bimodal Interaction Examples

### MF Axiom: □φ → □Gφ

```lean
/-- What is necessary will always be necessary -/
example (P : Formula) : ⊢ (P.box.imp (Formula.box (Formula.all_future P))) := by
  apply Derivable.axiom
  apply Axiom.modal_future

/-- Derive □Gp from □p -/
example (P : Formula) : [P.box] ⊢ Formula.box (Formula.all_future P) := by
  apply Derivable.modus_ponens
  · apply Derivable.axiom; apply Axiom.modal_future
  · apply Derivable.assumption; simp
```

### TF Axiom: □φ → G□φ

```lean
/-- What is necessary will remain necessary -/
example (P : Formula) : ⊢ (P.box.imp (Formula.all_future P.box)) := by
  apply Derivable.axiom
  apply Axiom.temp_future

/-- Derive G□p from □p -/
example (P : Formula) : [P.box] ⊢ Formula.all_future P.box := by
  apply Derivable.modus_ponens
  · apply Derivable.axiom; apply Axiom.temp_future
  · apply Derivable.assumption; simp
```

### Combined Modal-Temporal Reasoning

```lean
/-- From `□p`, derive both `□Gp` and `G□p` -/
example (P : Formula) : [P.box] ⊢ and (Formula.box (Formula.all_future P)) (Formula.all_future P.box) := by
  -- Use MF for first conjunct, TF for second
  sorry

/-- Modal necessity implies temporal persistence -/
example (P : Formula) : [P.box] ⊢ always P := by
  -- This is essentially P1: `□φ → △φ`
  -- Requires proving from MF, TF, MT, and temporal duality
  sorry
```

## 4. Perpetuity Principles

### P1: `□φ → △φ`

```lean
/-- What is necessary is always the case -/
theorem perpetuity_1_example (P : Formula) : ⊢ (P.box.imp (△P)) := by
  -- Proof sketch:
  -- 1. `□P → □Future P` (MF)
  -- 2. `□Future P → Future P` (MT)
  -- 3. `□P → Future P` (transitivity)
  -- 4. By TD (temporal duality), `□P → Past P`
  -- 5. `□P → P` (MT)
  -- 6. Combine: `□P → Past P ∧ P ∧ Future P = always P`
  sorry

/-- Using P1 -/
example (P : Formula) : [P.box] ⊢ always P := by
  apply Derivable.modus_ponens
  · exact perpetuity_1 P
  · apply Derivable.assumption; simp
```

### P2: `▽φ → ◇φ`

```lean
/-- What is sometimes the case is possible -/
theorem perpetuity_2_example (P : Formula) : ⊢ ((▽P).imp (diamond P)) := by
  -- Proof by contraposition of P1
  -- If `¬◇P` (= `□¬P`), then `always ¬P`
  -- Contrapositive: `sometimes P → ◇P`
  sorry
```

### P3: `□φ → □△φ`

```lean
/-- Necessity of perpetuity: necessary implies necessarily always -/
theorem perpetuity_3_example (P : Formula) : ⊢ (P.box.imp ((△P).box)) := by
  -- Proof sketch:
  -- 1. □P → always P (P1)
  -- 2. Need to show □P → □always P
  -- 3. Use MK: from premises derive □(always P)
  sorry
```

### P4: `◇▽φ → ◇φ`

```lean
/-- Possibility of occurrence -/
theorem perpetuity_4_example (P : Formula) : ⊢ ((diamond (▽P)).imp (diamond P)) := by
  -- Contrapositive of P3 applied to ¬P
  sorry
```

### P5: `◇▽φ → △◇φ`

```lean
/-- Persistent possibility: if possibly sometimes, then always possible -/
theorem perpetuity_5_example (P : Formula) : ⊢ ((diamond (▽P)).imp (△(diamond P))) := by
  -- Key theorem showing modal-temporal interaction
  sorry
```

### P6: `▽□φ → □△φ`

```lean
/-- Occurrent necessity is perpetual -/
theorem perpetuity_6_example (P : Formula) : ⊢ ((▽P.box).imp ((△P).box)) := by
  -- If necessity holds at some time, it holds always necessarily
  sorry
```

## 5. Advanced Examples

### Soundness Example

```lean
/-- Verify soundness for a specific derivation -/
example (P : Formula) : valid (P.box.imp P) := by
  -- Show MT is valid in all task semantic models
  intro F M τ t
  intro h_box_p
  -- □P means P holds in all histories at t
  -- In particular, P holds in τ at t
  exact h_box_p τ
```

### Consistency Example

```lean
/-- Show {□P, ◇¬P} is inconsistent -/
example (P : Formula) : ¬consistent [P.box, diamond (neg P)] := by
  -- □P implies P (MT)
  -- ◇¬P = ¬□¬¬P = ¬□P (by double negation)
  -- We have □P and ¬□P, contradiction
  sorry
```

### Temporal Duality Example

```lean
/-- Temporal duality: swapping all_past and all_future preserves provability -/
example (P : Formula) (h : ⊢ P) : ⊢ (swap_temporal P) := by
  apply Derivable.temporal_duality
  exact h

/-- Example: if ⊢ Gp → GGp, then ⊢ Hp → HHp -/
example (P : Formula) : ⊢ (Formula.all_past P).imp (Formula.all_past (Formula.all_past P)) := by
  -- By TD applied to T4
  apply Derivable.temporal_duality
  apply Derivable.axiom
  apply Axiom.temp_4
```

### Custom Tactic Usage

```lean
/-- Using modal_auto for complex proofs -/
example (P Q : Formula) :
  [P.box, Q.box] ⊢ (and P Q).box := by
  tm_auto

/-- Using modal_search with depth limit -/
example (P : Formula) : [P.box.box.box] ⊢ P := by
  modal_search 5
```

## 6. Exercise Problems

### Basic Exercises

1. Prove `⊢ □(P → Q) → (□P → □Q)` (K axiom for necessity)
2. Prove `[P, P → Q] ⊢ Q` using modus ponens
3. Prove `⊢ □P → ◇P` from MT and MB

### Intermediate Exercises

4. Prove `⊢ ◇◇P → ◇P` in S5
5. Prove `[always P] ⊢ P` by extracting from conjunction
6. Show `{□P, □Q}` entails `□(P ∧ Q)`

### Advanced Exercises

7. Prove perpetuity principle P1: `⊢ □P → always P`
8. Prove `⊢ always □P ↔ □P` in TM
9. Construct a canonical model proof for a specific formula

### Solutions

Solutions are available in the `Archive/` directory:
- `Archive/ModalProofs.lean`
- `Archive/TemporalProofs.lean`
- `Archive/BimodalProofs.lean`

## References

- [Tutorial](TUTORIAL.md) - Getting started guide
- [Architecture](ARCHITECTURE.md) - Full TM logic specification
- [Tactic Development](../ProjectInfo/TACTIC_DEVELOPMENT.md) - Custom tactics
