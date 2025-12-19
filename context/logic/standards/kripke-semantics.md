# Kripke Semantics Best Practices

## Overview

This document defines best practices for working with Kripke semantics and task semantics in the ProofChecker LEAN 4 codebase. It covers task frames, task models, world histories, and truth evaluation.

## When to Use

- When defining semantic structures (frames, models, histories)
- When proving soundness or completeness theorems
- When working with truth evaluation functions
- When reasoning about accessibility relations

## Prerequisites

- Understanding of Kripke semantics for modal logic
- Understanding of task semantics from the JPL paper
- Familiarity with LEAN 4 structures and type classes
- Knowledge of linear ordered groups and temporal structures

## Context Dependencies

- `logic/standards/notation-standards.md` - Notation conventions
- `logic/standards/proof-conventions.md` - Proof style conventions
- `lean4/domain/key-mathematical-concepts.md` - Mathematical foundations
- `logic/processes/proof-construction.md` - Proof workflow

---

## Task Frame Structure

### Definition Pattern

**Standard Form**: Task frames are parameterized by a temporal type `T` with `LinearOrderedAddCommGroup` structure.

```lean
structure TaskFrame (T : Type*) [LinearOrderedAddCommGroup T] where
  /-- Type of world states -/
  WorldState : Type
  
  /-- Task relation: `task_rel w x u` means u is reachable from w by task of duration x -/
  task_rel : WorldState → T → WorldState → Prop
  
  /-- Nullity: zero-duration task is identity -/
  nullity : ∀ w, task_rel w 0 w
  
  /-- Compositionality: tasks compose with time addition -/
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

### Type Parameter Conventions

**Explicit vs Implicit**:
- `(T : Type*)` - Explicit type parameter (user specifies)
- `[LinearOrderedAddCommGroup T]` - Implicit typeclass instance (inferred)

**Example**:
```lean
-- Good: Explicit T, implicit typeclass
def my_frame {T : Type*} [LinearOrderedAddCommGroup T] : TaskFrame T := ...

-- Avoid: Both implicit (ambiguous)
def my_frame [T : Type*] [LinearOrderedAddCommGroup T] : TaskFrame T := ...
```

### Temporal Type Choices

| Type | Use Case | Properties |
|------|----------|------------|
| `Int` | Discrete time | Standard temporal logic, countable |
| `Rat` | Dense time | Fine-grained reasoning, dense order |
| `Real` | Continuous time | Physical systems, complete order |

**Example**:
```lean
-- Discrete integer time
def discrete_frame : TaskFrame Int := ...

-- Dense rational time
def dense_frame : TaskFrame Rat := ...

-- Continuous real time
def continuous_frame : TaskFrame Real := ...
```

---

## Task Relation Properties

### Nullity (Reflexivity)

**Semantic Interpretation**: Zero-duration task is identity - executing no task leaves the world state unchanged.

```lean
-- Pattern: Prove nullity for custom frames
def custom_frame : TaskFrame Int where
  WorldState := Nat
  task_rel := fun w x u => w + x.natAbs = u
  nullity := by
    intro w
    simp [Int.natAbs_zero]
  compositionality := by sorry
```

### Compositionality (Transitivity)

**Semantic Interpretation**: Sequential task composition - if task of duration `x` takes `w` to `u`, and task of duration `y` takes `u` to `v`, then task of duration `x + y` takes `w` to `v`.

```lean
-- Pattern: Prove compositionality using additive structure
def custom_frame : TaskFrame Int where
  WorldState := Nat
  task_rel := fun w x u => w + x.natAbs = u
  nullity := by sorry
  compositionality := by
    intros w u v x y h_wu h_uv
    -- h_wu : w + x.natAbs = u
    -- h_uv : u + y.natAbs = v
    -- Goal: w + (x + y).natAbs = v
    sorry  -- Requires natAbs additivity properties
```

### Accessibility Relation

**Modal Accessibility**: In task semantics, modal accessibility is universal - all world histories are accessible from any world history.

```lean
-- Pattern: Modal accessibility is trivial in task semantics
theorem modal_accessibility_universal (F : TaskFrame T) (τ σ : WorldHistory F) :
  accessible τ σ := by
  -- In S5 task semantics, all histories are accessible
  trivial
```

---

## World History Structure

### Definition Pattern

**Standard Form**: World histories are functions from convex time sets to world states.

```lean
structure WorldHistory (F : TaskFrame T) where
  /-- Domain: convex set of times -/
  domain : Set T
  
  /-- Domain is convex (interval-like) -/
  domain_convex : Convex T domain
  
  /-- History function: maps times to world states -/
  history : (t : T) → t ∈ domain → F.WorldState
  
  /-- Task consistency: history respects task relation -/
  task_consistent : ∀ (t s : T) (ht : t ∈ domain) (hs : s ∈ domain),
    F.task_rel (history t ht) (s - t) (history s hs)
```

### Convexity Constraint

**Semantic Interpretation**: World histories must be defined on convex (interval-like) time sets. This ensures temporal continuity.

```lean
-- Pattern: Prove convexity for interval domains
def interval_history (F : TaskFrame Int) (a b : Int) : WorldHistory F where
  domain := {t | a ≤ t ∧ t ≤ b}
  domain_convex := by
    -- Prove interval is convex
    sorry
  history := fun t ht => sorry
  task_consistent := by sorry
```

### Task Consistency

**Semantic Interpretation**: The history function must respect the task relation - transitions between time points must be achievable via tasks.

```lean
-- Pattern: Prove task consistency using frame properties
def consistent_history (F : TaskFrame Int) : WorldHistory F where
  domain := Set.univ
  domain_convex := by sorry
  history := fun t ht => sorry  -- Define history function
  task_consistent := by
    intros t s ht hs
    -- Must show: F.task_rel (history t ht) (s - t) (history s hs)
    sorry
```

---

## Task Model Structure

### Definition Pattern

**Standard Form**: Task models extend task frames with valuation functions.

```lean
structure TaskModel (F : TaskFrame T) where
  /-- Valuation: maps atoms to sets of world states -/
  valuation : String → Set F.WorldState
```

### Valuation Function

**Semantic Interpretation**: The valuation function assigns truth values to atomic propositions at world states.

```lean
-- Pattern: Define valuation for specific models
def example_model (F : TaskFrame Int) : TaskModel F where
  valuation := fun p =>
    if p = "p" then {w | w.val > 0}  -- p is true at positive states
    else if p = "q" then {w | w.val % 2 = 0}  -- q is true at even states
    else ∅  -- All other atoms are false everywhere
```

---

## Truth Evaluation

### Truth at Model-History-Time

**Standard Form**: Truth is evaluated at a model, world history, and time point.

```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) :
  Formula → Prop
  | Formula.atom p => τ.history t ht ∈ M.valuation p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t ht φ → truth_at M τ t ht ψ
  | Formula.box φ => ∀ (σ : WorldHistory F) (hs : t ∈ σ.domain), truth_at M σ t hs φ
  | Formula.all_past φ => ∀ (s : T) (hs : s ∈ τ.domain), s < t → truth_at M τ s hs φ
  | Formula.all_future φ => ∀ (s : T) (hs : s ∈ τ.domain), s > t → truth_at M τ s hs φ
```

### Semantic Clauses

**Atoms**: True iff the world state at time `t` is in the valuation set.

```lean
-- Pattern: Atom truth evaluation
theorem atom_truth (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) (p : String) :
  truth_at M τ t ht (Formula.atom p) ↔ τ.history t ht ∈ M.valuation p := by
  rfl
```

**Bottom**: Always false.

```lean
-- Pattern: Bottom is always false
theorem bot_false (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) :
  ¬truth_at M τ t ht Formula.bot := by
  simp [truth_at]
```

**Implication**: Standard material implication.

```lean
-- Pattern: Implication truth evaluation
theorem imp_truth (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) (φ ψ : Formula) :
  truth_at M τ t ht (φ.imp ψ) ↔ (truth_at M τ t ht φ → truth_at M τ t ht ψ) := by
  rfl
```

**Box (Necessity)**: True at all accessible world histories.

```lean
-- Pattern: Box truth evaluation (S5 universal quantification)
theorem box_truth (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) (φ : Formula) :
  truth_at M τ t ht (Formula.box φ) ↔ 
    ∀ (σ : WorldHistory F) (hs : t ∈ σ.domain), truth_at M σ t hs φ := by
  rfl
```

**All Past**: True at all earlier times in the same history.

```lean
-- Pattern: All past truth evaluation
theorem all_past_truth (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) (φ : Formula) :
  truth_at M τ t ht (Formula.all_past φ) ↔ 
    ∀ (s : T) (hs : s ∈ τ.domain), s < t → truth_at M τ s hs φ := by
  rfl
```

**All Future**: True at all later times in the same history.

```lean
-- Pattern: All future truth evaluation
theorem all_future_truth (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) (φ : Formula) :
  truth_at M τ t ht (Formula.all_future φ) ↔ 
    ∀ (s : T) (hs : s ∈ τ.domain), s > t → truth_at M τ s hs φ := by
  rfl
```

---

## Validity and Semantic Consequence

### Validity

**Definition**: A formula is valid if it is true at all model-history-time triples.

```lean
def valid (φ : Formula) : Prop :=
  ∀ (T : Type*) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain),
    truth_at M τ t ht φ
```

**Pattern**: Prove validity by universal quantification.

```lean
-- Pattern: Prove formula is valid
theorem modal_t_valid (φ : Formula) : valid (φ.box.imp φ) := by
  intros T _ F M τ t ht
  simp [truth_at]
  intro h_box
  -- h_box : ∀ σ hs, truth_at M σ t hs φ
  -- Goal: truth_at M τ t ht φ
  exact h_box τ ht
```

### Semantic Consequence

**Definition**: `Γ ⊨ φ` means φ is true at all model-history-time triples where all formulas in Γ are true.

```lean
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (T : Type*) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain),
    (∀ ψ ∈ Γ, truth_at M τ t ht ψ) → truth_at M τ t ht φ

notation:50 Γ " ⊨ " φ => semantic_consequence Γ φ
```

**Pattern**: Prove semantic consequence by assuming all premises.

```lean
-- Pattern: Prove semantic consequence
theorem modus_ponens_valid (φ ψ : Formula) : [φ.imp ψ, φ] ⊨ ψ := by
  intros T _ F M τ t ht h_premises
  -- h_premises : ∀ χ ∈ [φ.imp ψ, φ], truth_at M τ t ht χ
  have h_imp : truth_at M τ t ht (φ.imp ψ) := h_premises (φ.imp ψ) (by simp)
  have h_φ : truth_at M τ t ht φ := h_premises φ (by simp)
  -- Goal: truth_at M τ t ht ψ
  exact h_imp h_φ
```

---

## Soundness and Completeness

### Soundness Theorem

**Statement**: If `Γ ⊢ φ` then `Γ ⊨ φ` (derivability implies validity).

```lean
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
  intro h_deriv
  induction h_deriv with
  | axiom Γ φ h_ax =>
    -- Prove axiom is valid
    sorry
  | assumption Γ φ h_mem =>
    -- Assumptions are in premises
    intros T _ F M τ t ht h_premises
    exact h_premises φ h_mem
  | modus_ponens Γ φ ψ h_imp h_φ ih_imp ih_φ =>
    -- Apply induction hypotheses
    intros T _ F M τ t ht h_premises
    have h1 := ih_imp T F M τ t ht h_premises
    have h2 := ih_φ T F M τ t ht h_premises
    exact h1 h2
  | necessitation φ h ih =>
    -- Necessitation preserves validity
    sorry
  | temporal_necessitation φ h ih =>
    -- Temporal necessitation preserves validity
    sorry
  | temporal_duality φ h ih =>
    -- Temporal duality preserves validity
    sorry
  | weakening Γ Δ φ h h_sub ih =>
    -- Weakening preserves validity
    intros T _ F M τ t ht h_premises
    apply ih T F M τ t ht
    intros ψ h_mem
    exact h_premises ψ (h_sub h_mem)
```

### Completeness Theorem

**Statement**: If `Γ ⊨ φ` then `Γ ⊢ φ` (validity implies derivability).

```lean
theorem completeness (Γ : Context) (φ : Formula) : Γ ⊨ φ → Γ ⊢ φ := by
  -- Requires canonical model construction
  sorry
```

---

## Common Patterns

### Pattern 1: Axiom Validity Proofs

```lean
-- Pattern: Prove axiom is valid by case analysis
theorem axiom_valid (φ : Formula) (h : Axiom φ) : valid φ := by
  cases h with
  | modal_t φ =>
    -- Prove □φ → φ is valid
    intros T _ F M τ t ht
    simp [truth_at]
    intro h_box
    exact h_box τ ht
  | modal_4 φ =>
    -- Prove □φ → □□φ is valid
    sorry
  | modal_b φ =>
    -- Prove φ → □◇φ is valid
    sorry
  -- ... other axioms
```

### Pattern 2: Truth Preservation

```lean
-- Pattern: Prove truth is preserved under formula transformation
theorem truth_preserved (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain)
    (φ ψ : Formula) (h : φ = ψ) :
  truth_at M τ t ht φ ↔ truth_at M τ t ht ψ := by
  subst h
  rfl
```

### Pattern 3: Semantic Substitution

```lean
-- Pattern: Substitute equivalent formulas in semantic contexts
theorem semantic_substitution (Γ : Context) (φ ψ χ : Formula)
    (h_equiv : ∀ M τ t ht, truth_at M τ t ht φ ↔ truth_at M τ t ht ψ)
    (h_sem : Γ ⊨ φ.imp χ) :
  Γ ⊨ ψ.imp χ := by
  intros T _ F M τ t ht h_premises
  simp [truth_at]
  intro h_ψ
  have h_φ : truth_at M τ t ht φ := (h_equiv M τ t ht).mpr h_ψ
  exact h_sem T F M τ t ht h_premises h_φ
```

---

## Best Practices

### 1. Explicit Type Parameters

**Good**: Make temporal type explicit when defining frames.

```lean
-- Good: Explicit temporal type
def my_frame : TaskFrame Int := ...

-- Avoid: Implicit temporal type (ambiguous)
def my_frame {T : Type*} [LinearOrderedAddCommGroup T] : TaskFrame T := ...
```

### 2. Prove Frame Properties

**Good**: Prove nullity and compositionality explicitly.

```lean
def my_frame : TaskFrame Int where
  WorldState := Nat
  task_rel := fun w x u => w + x.natAbs = u
  nullity := by
    intro w
    simp [Int.natAbs_zero]
  compositionality := by
    intros w u v x y h_wu h_uv
    -- Explicit proof steps
    sorry
```

### 3. Use Semantic Lemmas

**Good**: Factor out common semantic reasoning into lemmas.

```lean
-- Good: Reusable semantic lemma
lemma box_intro (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) (φ : Formula)
    (h : ∀ σ hs, truth_at M σ t hs φ) :
  truth_at M τ t ht (Formula.box φ) := by
  exact h

-- Use in proofs
theorem example : valid (φ.box) := by
  intros T _ F M τ t ht
  apply box_intro
  intros σ hs
  sorry
```

### 4. Document Semantic Interpretations

**Good**: Include semantic interpretation in docstrings.

```lean
/--
Modal T axiom validity: `□φ → φ`.

**Semantic Interpretation**: If φ holds at all accessible worlds, it holds at the
current world. In S5 task semantics, all worlds are accessible (including the current
world), so this is trivially valid.
-/
theorem modal_t_valid (φ : Formula) : valid (φ.box.imp φ) := by
  sorry
```

---

## Success Criteria

You've successfully applied these Kripke semantics best practices when:
- [ ] Task frames are properly parameterized by temporal type
- [ ] Nullity and compositionality are proven explicitly
- [ ] World histories satisfy convexity and task consistency
- [ ] Truth evaluation follows standard semantic clauses
- [ ] Validity and semantic consequence are defined correctly
- [ ] Soundness proofs use induction on derivations
- [ ] Semantic interpretations are documented in docstrings
- [ ] Common semantic patterns are factored into reusable lemmas

---

## Related Documentation

- **Notation Standards**: `logic/standards/notation-standards.md`
- **Proof Conventions**: `logic/standards/proof-conventions.md`
- **Naming Conventions**: `logic/standards/naming-conventions.md`
- **Task Frame Definition**: `Logos/Core/Semantics/TaskFrame.lean`
- **Task Model Definition**: `Logos/Core/Semantics/TaskModel.lean`
- **Truth Evaluation**: `Logos/Core/Semantics/Truth.lean`
- **Soundness Proof**: `Logos/Core/Metalogic/Soundness.lean`
