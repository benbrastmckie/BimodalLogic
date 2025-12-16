# Kripke Semantics for Bimodal Logic

## Overview
Semantic foundations for bimodal logic using Kripke models with two accessibility relations. This file covers model theory, satisfaction, and validity.

## Kripke Models

### Model Structure
A bimodal Kripke model M = (W, R₁, R₂, V) where:
- **W**: Set of possible worlds
- **R₁**: First accessibility relation (for □₁)
- **R₂**: Second accessibility relation (for □₂)
- **V**: Valuation function (assigns truth values to propositions at worlds)

### LEAN 4 Definition
```lean
import Mathlib.Data.Set.Basic
import Mathlib.Logic.Relation

-- Kripke model for bimodal logic
structure KripkeModel where
  World : Type
  R1 : World → World → Prop
  R2 : World → World → Prop
  V : PropVar → World → Prop

-- Pointed model (model with designated world)
structure PointedModel extends KripkeModel where
  point : World
```

## Satisfaction Relation

### Definition
```lean
-- Satisfaction relation: M, w ⊨ φ
def satisfies (M : KripkeModel) (w : M.World) : Formula → Prop
  | Formula.var p => M.V p w
  | Formula.bot => False
  | Formula.imp φ ψ => satisfies M w φ → satisfies M w ψ
  | Formula.box1 φ => ∀ w', M.R1 w w' → satisfies M w' φ
  | Formula.box2 φ => ∀ w', M.R2 w w' → satisfies M w' φ

-- Notation
notation:50 M ", " w " ⊨ " φ => satisfies M w φ
```

### Derived Connectives
```lean
-- Negation
theorem satisfies_neg (M : KripkeModel) (w : M.World) (φ : Formula) :
    M, w ⊨ neg φ ↔ ¬(M, w ⊨ φ) := by
  unfold neg satisfies
  simp

-- Conjunction
theorem satisfies_and (M : KripkeModel) (w : M.World) (φ ψ : Formula) :
    M, w ⊨ and φ ψ ↔ (M, w ⊨ φ) ∧ (M, w ⊨ ψ) := by
  unfold and satisfies
  simp [satisfies_neg]
  tauto

-- Disjunction
theorem satisfies_or (M : KripkeModel) (w : M.World) (φ ψ : Formula) :
    M, w ⊨ or φ ψ ↔ (M, w ⊨ φ) ∨ (M, w ⊨ ψ) := by
  unfold or satisfies
  simp [satisfies_neg]
  tauto

-- Diamond (possibility)
theorem satisfies_diamond1 (M : KripkeModel) (w : M.World) (φ : Formula) :
    M, w ⊨ diamond1 φ ↔ ∃ w', M.R1 w w' ∧ M, w' ⊨ φ := by
  unfold diamond1 satisfies
  simp [satisfies_neg]
  push_neg
  rfl

theorem satisfies_diamond2 (M : KripkeModel) (w : M.World) (φ : Formula) :
    M, w ⊨ diamond2 φ ↔ ∃ w', M.R2 w w' ∧ M, w' ⊨ φ := by
  unfold diamond2 satisfies
  simp [satisfies_neg]
  push_neg
  rfl
```

## Validity and Satisfiability

### Definitions
```lean
-- Valid in a model
def validInModel (M : KripkeModel) (φ : Formula) : Prop :=
  ∀ w : M.World, M, w ⊨ φ

-- Satisfiable in a model
def satisfiableInModel (M : KripkeModel) (φ : Formula) : Prop :=
  ∃ w : M.World, M, w ⊨ φ

-- Valid (true in all models at all worlds)
def valid (φ : Formula) : Prop :=
  ∀ (M : KripkeModel), validInModel M φ

-- Satisfiable (true in some model at some world)
def satisfiable (φ : Formula) : Prop :=
  ∃ (M : KripkeModel), satisfiableInModel M φ

-- Notation
notation:50 "⊨ " φ => valid φ
```

### Theorems
```lean
-- Validity implies satisfiability
theorem valid_implies_satisfiable (φ : Formula) :
    valid φ → satisfiable φ := by
  intro h
  -- Construct trivial model
  sorry

-- Unsatisfiability of negation implies validity
theorem unsat_neg_implies_valid (φ : Formula) :
    ¬satisfiable (neg φ) → valid φ := by
  intro h
  unfold valid validInModel
  intros M w
  by_contra h_contra
  apply h
  use M
  unfold satisfiableInModel
  use w
  exact h_contra
```

## Frame Properties

### Common Frame Conditions
```lean
-- Reflexivity
def Reflexive (R : α → α → Prop) : Prop :=
  ∀ x, R x x

-- Transitivity
def Transitive (R : α → α → Prop) : Prop :=
  ∀ x y z, R x y → R y z → R x z

-- Symmetry
def Symmetric (R : α → α → Prop) : Prop :=
  ∀ x y, R x y → R y x

-- Euclidean property
def Euclidean (R : α → α → Prop) : Prop :=
  ∀ x y z, R x y → R x z → R y z

-- Seriality
def Serial (R : α → α → Prop) : Prop :=
  ∀ x, ∃ y, R x y

-- Functionality
def Functional (R : α → α → Prop) : Prop :=
  ∀ x y z, R x y → R x z → y = z
```

### Frame Classes
```lean
-- Frame (just the relational structure)
structure Frame where
  World : Type
  R1 : World → World → Prop
  R2 : World → World → Prop

-- Frame with properties
structure ReflexiveFrame extends Frame where
  refl1 : Reflexive R1
  refl2 : Reflexive R2

structure TransitiveFrame extends Frame where
  trans1 : Transitive R1
  trans2 : Transitive R2

structure S4Frame extends Frame where
  refl1 : Reflexive R1
  refl2 : Reflexive R2
  trans1 : Transitive R1
  trans2 : Transitive R2

structure S5Frame extends Frame where
  refl1 : Reflexive R1
  refl2 : Reflexive R2
  trans1 : Transitive R1
  trans2 : Transitive R2
  eucl1 : Euclidean R1
  eucl2 : Euclidean R2
```

### Correspondence Theory
```lean
-- T axiom corresponds to reflexivity
theorem T_axiom_iff_reflexive :
    (∀ (M : KripkeModel), validInModel M (Formula.box1 (Formula.var p) .imp (Formula.var p))) ↔
    (∀ (F : Frame), Reflexive F.R1) := by
  sorry

-- 4 axiom corresponds to transitivity
theorem four_axiom_iff_transitive :
    (∀ (M : KripkeModel), validInModel M 
      (Formula.box1 (Formula.var p) .imp (Formula.box1 (Formula.box1 (Formula.var p))))) ↔
    (∀ (F : Frame), Transitive F.R1) := by
  sorry

-- 5 axiom corresponds to Euclidean property
theorem five_axiom_iff_euclidean :
    (∀ (M : KripkeModel), validInModel M 
      (diamond1 (Formula.var p) .imp (Formula.box1 (diamond1 (Formula.var p))))) ↔
    (∀ (F : Frame), Euclidean F.R1) := by
  sorry
```

## Bisimulation

### Definition
```lean
-- Bisimulation between two models
def Bisimulation (M1 M2 : KripkeModel) (Z : M1.World → M2.World → Prop) : Prop :=
  -- Atomic harmony
  (∀ w1 w2 p, Z w1 w2 → (M1.V p w1 ↔ M2.V p w2)) ∧
  -- Zig (R1)
  (∀ w1 w2 w1', Z w1 w2 → M1.R1 w1 w1' → 
    ∃ w2', M2.R1 w2 w2' ∧ Z w1' w2') ∧
  -- Zag (R1)
  (∀ w1 w2 w2', Z w1 w2 → M2.R1 w2 w2' → 
    ∃ w1', M1.R1 w1 w1' ∧ Z w1' w2') ∧
  -- Zig (R2)
  (∀ w1 w2 w1', Z w1 w2 → M1.R2 w1 w1' → 
    ∃ w2', M2.R2 w2 w2' ∧ Z w1' w2') ∧
  -- Zag (R2)
  (∀ w1 w2 w2', Z w1 w2 → M2.R2 w2 w2' → 
    ∃ w1', M1.R2 w1 w1' ∧ Z w1' w2')

-- Bisimilar worlds satisfy the same formulas
theorem bisimulation_invariance (M1 M2 : KripkeModel) (Z : M1.World → M2.World → Prop)
    (h : Bisimulation M1 M2 Z) (w1 : M1.World) (w2 : M2.World) (h_Z : Z w1 w2) :
    ∀ φ : Formula, M1, w1 ⊨ φ ↔ M2, w2 ⊨ φ := by
  intro φ
  induction φ with
  | var p => exact h.1 w1 w2 p h_Z
  | bot => rfl
  | imp φ ψ ih_φ ih_ψ => 
      simp [satisfies]
      constructor <;> intro h_imp h_φ
      · exact ih_ψ.mp (h_imp (ih_φ.mpr h_φ))
      · exact ih_ψ.mpr (h_imp (ih_φ.mp h_φ))
  | box1 φ ih =>
      simp [satisfies]
      constructor <;> intro h_box w' h_R
      · obtain ⟨w1', h_R1, h_Z'⟩ := h.2.2.1 w1 w2 w' h_Z h_R
        exact ih.mp (h_box w1' h_R1)
      · obtain ⟨w2', h_R2, h_Z'⟩ := h.2.1 w1 w2 w' h_Z h_R
        exact ih.mpr (h_box w2' h_R2)
  | box2 φ ih =>
      simp [satisfies]
      constructor <;> intro h_box w' h_R
      · obtain ⟨w1', h_R1, h_Z'⟩ := h.2.2.2.2 w1 w2 w' h_Z h_R
        exact ih.mp (h_box w1' h_R1)
      · obtain ⟨w2', h_R2, h_Z'⟩ := h.2.2.2.1 w1 w2 w' h_Z h_R
        exact ih.mpr (h_box w2' h_R2)
```

## Generated Submodels

### Definition
```lean
-- Generated submodel
def GeneratedSubmodel (M : KripkeModel) (w : M.World) : KripkeModel where
  World := {w' : M.World | Reachable M w w'}
  R1 := fun w1 w2 => M.R1 w1.val w2.val
  R2 := fun w1 w2 => M.R2 w1.val w2.val
  V := fun p w' => M.V p w'.val

-- Reachability
def Reachable (M : KripkeModel) (w w' : M.World) : Prop :=
  ReflTransGen (fun x y => M.R1 x y ∨ M.R2 x y) w w'

-- Generated submodel preserves satisfaction
theorem generated_submodel_preserves_satisfaction 
    (M : KripkeModel) (w : M.World) (φ : Formula) :
    M, w ⊨ φ ↔ GeneratedSubmodel M w, ⟨w, Reachable.refl⟩ ⊨ φ := by
  sorry
```

## Filtration

### Definition
```lean
-- Filtration (quotient model for finite model property)
def Filtration (M : KripkeModel) (Φ : Set Formula) : KripkeModel where
  World := Quotient (equivalenceRelation M Φ)
  R1 := filteredRelation M Φ M.R1
  R2 := filteredRelation M Φ M.R2
  V := filteredValuation M Φ

-- Equivalence relation based on formula set
def equivalenceRelation (M : KripkeModel) (Φ : Set Formula) : 
    M.World → M.World → Prop :=
  fun w w' => ∀ φ ∈ Φ, M, w ⊨ φ ↔ M, w' ⊨ φ

-- Filtration preserves satisfaction for formulas in Φ
theorem filtration_preserves_satisfaction 
    (M : KripkeModel) (Φ : Set Formula) (w : M.World) (φ : Formula) 
    (h : φ ∈ Φ) :
    M, w ⊨ φ ↔ Filtration M Φ, ⟦w⟧ ⊨ φ := by
  sorry
```

## Business Rules

1. **Use inductive satisfaction**: Define satisfaction inductively on formula structure
2. **Prove by induction**: Most semantic proofs use structural induction
3. **Check frame properties**: Verify correspondence with axioms
4. **Use bisimulation**: For model equivalence and minimization
5. **Apply filtration**: For finite model property proofs

## Common Pitfalls

1. **Confusing ⊨ and ⊢**: Semantic vs syntactic consequence
2. **Forgetting accessibility**: Modal operators quantify over accessible worlds
3. **Not checking frame properties**: Different logics need different frames
4. **Ignoring bisimulation**: Missing model equivalences
5. **Assuming finite models**: Not all logics have finite model property

## Relationships

- **Used by**: Soundness proofs, completeness proofs
- **Related**: Proof theory (soundness), metalogic (completeness)
- **Extends**: Classical semantics, possible worlds semantics

## References

- Modal Logic (Blackburn, de Rijke, Venema)
- A New Introduction to Modal Logic (Hughes & Cresswell)
- Handbook of Modal Logic (Blackburn et al.)
