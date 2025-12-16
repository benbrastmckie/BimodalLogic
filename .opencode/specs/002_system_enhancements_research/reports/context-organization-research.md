# Context Organization Research Report: Logic and Mathematics Domains for LEAN 4

**Date:** December 16, 2025  
**Project:** ProofChecker (Logos TM Logic System)  
**Author:** Research Analysis  
**Status:** Final Report

---

## Executive Summary

This report provides comprehensive recommendations for organizing context directories to support AI-assisted LEAN 4 theorem proving in logic and mathematics domains. Based on analysis of mathlib4 organization, existing Logos project patterns, LEAN 4 documentation, and best practices from the formal verification community, we recommend a three-tier context structure:

1. **Logic Domain Context** (`context/logic/`) - Specialized context for modal, temporal, and propositional logic formalization with 4 subdirectories
2. **Mathematics Domain Context** (`context/math/`) - General mathematical domain knowledge spanning analysis, category theory, and linear algebra with 3 subdirectories  
3. **Integration Layer** - Cross-references connecting logic/math contexts to existing LEAN 4 context

**Key Findings:**

- Mathlib4 has **no dedicated modal/temporal logic modules** - custom logic formalization requires project-specific context
- Logic context should emphasize **proof system workflows** (soundness/completeness patterns) and **semantic model standards** (Kripke frames, task semantics)
- Mathematics context should focus on **mathlib integration patterns** - identifying relevant modules, import strategies, and helper lemmas
- **Process files** are most valuable for logic domain (12+ unique logic workflows identified)
- **Templates files** are most valuable for mathematics domain (connecting to mathlib proof patterns)
- Priority: Populate logic context first (supports immediate Logos work), then math context (supports future extensions)

**Critical Insight:** Logic formalization in LEAN 4 requires significantly more domain-specific context than pure mathematics, because mathlib provides extensive mathematical infrastructure but minimal logic infrastructure. The 80/20 rule: logic context provides 80% of value for Logos development.

---

## Table of Contents

1. [Logic Context Deep Dive](#1-logic-context-deep-dive)
2. [Mathematics Context Deep Dive](#2-mathematics-context-deep-dive)  
3. [Mathlib Integration](#3-mathlib-integration)
4. [Content Examples](#4-content-examples)
5. [Implementation Guide](#5-implementation-guide)
6. [Bibliography](#6-bibliography)

---

## 1. Logic Context Deep Dive

### 1.1 `context/logic/processes/` - Logic-Specific Processes and Workflows

**Purpose:** Document repeatable workflows for logic formalization tasks unique to modal, temporal, and propositional logic systems.

#### Recommended Content

##### Process 1: Modal Logic Soundness Proof Workflow

**File:** `modal-soundness-workflow.md`

**Content Structure:**
```markdown
# Modal Logic Soundness Proof Workflow

## Overview
Step-by-step process for proving soundness of a modal logic system 
(syntax ⊢ φ implies semantics ⊨ φ).

## Prerequisites
- Syntax: Inductive formula type with modal operators (□, ◇)
- Semantics: Kripke frame/model with accessibility relation
- Proof system: Derivability relation (⊢) defined

## Process Steps

### Step 1: Prove Axiom Validity
For each axiom schema (K, T, 4, 5, B, etc.):
1. State validity theorem: `⊨ axiom_formula`
2. Introduce semantic model: `intro F M w`
3. Unfold truth definition at world
4. Apply frame property (reflexivity for T, transitivity for 4, etc.)
5. Complete by propositional reasoning

### Step 2: Prove Inference Rule Soundness
For each rule (modus ponens, necessitation, etc.):
1. Assume premises are valid
2. Show conclusion is valid
3. Use induction hypotheses

### Step 3: Main Soundness Theorem
Prove by induction on derivability:
- Base case: Axiom validity (from Step 1)
- Inductive cases: Rule soundness (from Step 2)

## Context Dependencies
- `modal-proof-patterns.md` (patterns directory)
- `kripke-semantics-standard.md` (standards directory)
```

##### Process 2: Completeness Proof Workflow

**File:** `modal-completeness-workflow.md`

**Key Steps:**
1. Define canonical model (maximally consistent sets as worlds)
2. Prove truth lemma (induction on formula complexity)
3. Show canonical model satisfies frame conditions
4. Establish semantic validity implies syntactic derivability

##### Process 3: Temporal Logic Duality Workflow

**File:** `temporal-duality-workflow.md`

**Key Steps:**
1. Identify dual pairs (F/P, G/H, ◇F/□P)
2. Prove base duality theorem
3. Apply to swap past/future in existing theorems
4. Verify frame conditions are preserved

##### Process 4: Bimodal Logic Interaction Workflow

**File:** `bimodal-interaction-workflow.md`

**Content:** How to prove interaction axioms (like MF: □φ → □Fφ) using:
- Time-shift automorphisms
- Frame commutativity properties
- Cross-modality distribution

##### Process 5: Metalogical Property Verification Workflow

**File:** `metalogic-verification-workflow.md`

**Properties to verify:**
- Decidability
- Finite model property
- Craig interpolation
- Beth definability

##### Additional Processes (12 total recommended)

6. `propositional-derivation-workflow.md` - Hilbert system proof construction
7. `axiom-independence-workflow.md` - Proving axioms are independent
8. `frame-characterization-workflow.md` - Finding frame conditions for axioms
9. `modal-embedding-workflow.md` - Embedding one logic into another
10. `correspondence-theory-workflow.md` - Sahlqvist formulas and frame definability
11. `hybrid-logic-workflow.md` - Adding nominals and @ operator
12. `fixpoint-logic-workflow.md` - μ-calculus and least/greatest fixpoints

#### Why These Processes Matter

**Problem:** Logic formalization requires specialized workflows not documented in LEAN/mathlib.

**Evidence:** Logos soundness proof required 14 axiom validity lemmas following consistent pattern (intro → unfold → apply frame property). This pattern is **not documented anywhere** in mathlib or LEAN docs.

**Impact:** Each new logic system (epistemic, deontic, doxastic) will need soundness/completeness proofs. Process documentation prevents rediscovering these patterns.

---

### 1.2 `context/logic/standards/` - Logic Verification Standards

**Purpose:** Document conventions and standards for logic formalization to ensure consistency and correctness.

#### Recommended Content

##### Standard 1: Axiom System Documentation Standard

**File:** `axiom-system-standard.md`

**Content:**
```markdown
# Axiom System Documentation Standard

## Required Components

### 1. Axiom Schema List
Each axiom must include:
- **Name**: Standard name (K, T, 4, 5, etc.)
- **Formula**: LEAN syntax and Unicode notation
- **Semantic Reading**: What it means intuitively
- **Frame Condition**: Corresponding frame property

Example:
```lean
/-- Modal T Axiom: Necessity implies truth (reflexivity)

**Formula:** □φ → φ
**Semantic Reading:** If φ is necessary, then φ is true.
**Frame Condition:** Reflexive accessibility relation (∀w. wRw)
**System:** K + T = T
-/
inductive Axiom : Formula → Prop where
  | modal_t (φ : Formula) : Axiom (Formula.box φ).imp φ
```

### 2. Inference Rule Documentation
Each rule must specify:
- **Name**: Standard name
- **Premises**: Required derivations
- **Conclusion**: Derived formula
- **Side Conditions**: Context restrictions

### 3. System Characterization
- **Name**: Standard system name (K, T, S4, S5, K4, etc.)
- **Axioms**: Which axioms are included
- **Frame Class**: Characterized frame class
- **Decidability**: Known decidability results
```

##### Standard 2: Kripke Semantics Definition Standard

**File:** `kripke-semantics-standard.md`

**Content:**
- Frame structure: (W, R) with worlds and accessibility
- Model structure: (F, V) with frame and valuation
- Truth definition: Inductive definition for each operator
- Validity definition: Truth in all models vs all frames
- Satisfiability: Existence of model where formula is true

##### Standard 3: Task Semantics Standard (Logos-Specific)

**File:** `task-semantics-standard.md`

**Content:**
- Task frame: (T, W, F) with times, states, futures function
- World history: Functions τ: T → W
- Model: Frame + valuation for atomic propositions
- Truth at (M, τ, t): Recursive definition
- Temporal operators: Quantification over future/past times
- Modal operators: Quantification over alternative histories

##### Standard 4: Proof System Standard

**File:** `proof-system-standard.md`

**Content:**
- Hilbert-style vs natural deduction vs sequent calculus
- Derivability relation: `Γ ⊢ φ` conventions
- Context management: Weakening, contraction, exchange
- Deduction theorem: When it holds and how to use it

##### Standard 5: Formula Syntax Standard

**File:** `formula-syntax-standard.md`

**Content:**
- Inductive type structure
- Precedence of operators
- Abbreviations and derived operators
- Unicode notation conventions
- Pretty printing standards

##### Additional Standards (10 total recommended)

6. `semantic-consequence-standard.md` - Defining ⊨
7. `model-construction-standard.md` - Canonical models, filtration, etc.
8. `complexity-measure-standard.md` - Formula complexity for induction
9. `substitution-standard.md` - Safe variable substitution
10. `normal-form-standard.md` - CNF, DNF, negation normal form

#### Why Standards Matter

**Problem:** Inconsistent semantics definitions lead to incompatible proofs.

**Evidence:** Logos initially had two different truth definitions (one in Semantics/, one in Metalogic/), causing type mismatches in soundness proof.

**Solution:** Standards ensure all modules use compatible definitions.

---

### 1.3 `context/logic/templates/` - Logic Proof Templates

**Purpose:** Provide reusable proof skeletons for common logic theorem patterns.

#### Recommended Content

##### Template 1: Modal Soundness Template

**File:** `modal-soundness-template.md`

**Content:**
```markdown
# Modal Soundness Proof Template

## Axiom Validity Template

```lean
/-- [AXIOM_NAME] axiom is valid: `⊨ [FORMULA]`

**Semantic Reading:** [INTUITIVE_MEANING]
**Frame Property Used:** [FRAME_CONDITION]
-/
theorem [axiom_name]_valid (φ [ψ ...] : Formula) : 
    ⊨ ([FORMULA]) := by
  intro W R M w
  unfold truth_at
  intro [ASSUMPTIONS]
  -- Apply frame property: [FRAME_CONDITION]
  have h_frame : [FRAME_PROPERTY] := M.frame.[PROPERTY_NAME]
  -- Complete using h_frame
  sorry
```

### Instantiation Example

For Modal T (□φ → φ):
```lean
theorem modal_t_valid (φ : Formula) : ⊨ (Formula.box φ).imp φ := by
  intro W R M w
  unfold truth_at
  intro h_box
  -- Apply reflexivity: ∀w. wRw
  have h_refl : R w w := M.frame.reflexive
  -- From □φ at w, we get φ at all R-accessible worlds
  -- Since R w w, we get φ at w
  exact h_box w h_refl
```

## Full Soundness Theorem Template

```lean
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
  intro h
  induction h with
  | axiom Γ φ hax =>
    cases hax with
    | [axiom_1] => exact [axiom_1_valid] ...
    | [axiom_2] => exact [axiom_2_valid] ...
    -- ... all axiom cases
  
  | modus_ponens Γ φ ψ h1 h2 ih1 ih2 =>
    intro W R M w hΓ
    exact ih1 W R M w hΓ (ih2 W R M w hΓ)
  
  | necessitation Γ φ h ih =>
    intro W R M w hΓ v h_acc
    exact ih W R M v hΓ
  
  -- ... all inference rule cases
```
```

##### Template 2: Completeness Proof Template

**File:** `modal-completeness-template.md`

**Outline:**
1. Define canonical model from maximally consistent sets
2. Prove existence lemma (consistent sets extend to maximal)
3. Prove truth lemma (formula in set ↔ true at corresponding world)
4. Show frame conditions hold in canonical model
5. Conclude semantic validity implies derivability

##### Template 3: Temporal Duality Template

**File:** `temporal-duality-template.md`

**Content:**
```lean
/-- Temporal duality: swap past and future operators

Given theorem about future operator, derive dual theorem about past.
-/
theorem temporal_dual_of_[theorem_name] (φ : Formula) :
    ⊢ [DUAL_FORMULA] := by
  apply temporal_duality
  exact [original_theorem] φ

-- Example: From Fφ → FFφ, derive Pφ → PPφ
theorem past_4_of_future_4 (φ : Formula) : ⊢ (Pφ → PPφ) := by
  apply temporal_duality  
  exact future_4 φ  -- ⊢ Fφ → FFφ
```

##### Additional Templates (8 total recommended)

4. `propositional-derivation-template.md` - Hilbert-style proofs
5. `frame-correspondence-template.md` - Proving axiom ↔ frame property
6. `decidability-proof-template.md` - Filtration method
7. `interpolation-proof-template.md` - Craig interpolation
8. `embedding-proof-template.md` - Logic translation

---

### 1.4 `context/logic/patterns/` - Common Logic Proof Patterns

**Purpose:** Document recurring tactic sequences and proof techniques for logic theorems.

#### Recommended Content

##### Pattern 1: Axiom Application Pattern

**File:** `axiom-application-pattern.md`

**Content:**
```markdown
# Axiom Application Pattern

## Pattern: Apply Axiom Schema

**When to Use:** Goal is derivability of axiom instance

**Tactic Sequence:**
```lean
example (P : Formula) : ⊢ (□P → P) := by
  apply Derivable.axiom
  exact Axiom.modal_t P
```

**Variations:**

1. With context weakening:
```lean
example (P : Formula) : [Q] ⊢ (□P → P) := by
  apply Derivable.weakening
  apply Derivable.axiom
  exact Axiom.modal_t P
```

2. With modus ponens:
```lean
example (P Q : Formula) (h : ⊢ P) : ⊢ Q := by
  apply Derivable.modus_ponens _ P
  · exact [proof of ⊢ P → Q]
  · exact h
```
```

##### Pattern 2: Induction on Derivability Pattern

**File:** `derivability-induction-pattern.md`

**Content:**
```lean
-- Pattern: Prove property for all derivable formulas
theorem property_of_derivable (Γ : Context) (φ : Formula) :
    Γ ⊢ φ → [PROPERTY] := by
  intro h
  induction h with
  | axiom Γ φ hax =>
    -- Prove property holds for axioms
    cases hax with
    | [axiom_1] => sorry
    | [axiom_2] => sorry
    -- ... all axiom cases
  
  | [rule_name] [args] ih1 ih2 =>
    -- Use induction hypotheses ih1, ih2
    sorry
```

##### Pattern 3: Semantic Unfolding Pattern

**File:** `semantic-unfolding-pattern.md`

**Content:**
```lean
-- Pattern: Unfold truth definition to access structure
theorem semantic_theorem (F : Frame) (M : Model) (w : World) :
    truth_at M w φ → [CONCLUSION] := by
  intro h
  unfold truth_at at h  -- Expand truth definition
  
  match φ with
  | Formula.atom p => sorry
  | Formula.imp ψ χ => sorry  
  | Formula.box ψ => 
    -- h : ∀ v, R w v → truth_at M v ψ
    sorry
```

##### Pattern 4: Frame Property Application Pattern

**File:** `frame-property-pattern.md`

**Content:**
```lean
-- Pattern: Use frame property (reflexivity, transitivity, etc.)
theorem uses_reflexivity (F : ReflexiveFrame) (M : Model F) (w : World) :
    truth_at M w (□φ) → truth_at M w φ := by
  intro h_box
  -- Apply reflexivity: R w w
  have h_refl : F.rel w w := F.reflexive w
  -- Use h_box with h_refl
  exact h_box w h_refl
```

##### Additional Patterns (12 total recommended)

5. `modal-k-distribution-pattern.md` - □(φ→ψ) → (□φ→□ψ) proofs
6. `necessitation-pattern.md` - From ⊢ φ infer ⊢ □φ
7. `contraposition-pattern.md` - Using ¬¬φ ↔ φ and ¬(φ→ψ) ↔ (φ∧¬ψ)
8. `classical-reasoning-pattern.md` - em, byContradiction, etc.
9. `intermediate-lemma-pattern.md` - Using `have` to break complex proofs
10. `case-analysis-pattern.md` - cases on Formula structure
11. `substitution-pattern.md` - Safe variable/formula substitution
12. `context-manipulation-pattern.md` - Weakening, exchange, contraction

#### Why Patterns Matter

**Problem:** Logic proofs use repetitive tactic sequences that are hard to discover.

**Evidence:** Logos soundness proof uses `intro F M τ t ht; unfold truth_at` in 14 lemmas - this pattern is never documented.

**Solution:** Pattern library enables quick lookup: "How do I apply axiom X?" → see pattern file.

---

## 2. Mathematics Context Deep Dive

### 2.1 `context/math/analysis/` - Real Analysis, Complex Analysis, Functional Analysis

**Purpose:** Provide context for working with mathlib's analysis modules - continuity, limits, derivatives, integrals, measure theory.

#### Recommended Content

##### File 1: `epsilon-delta-patterns.md`

**Content:**
```markdown
# Epsilon-Delta Proof Patterns in Mathlib

## Overview
Epsilon-delta arguments are fundamental to analysis. This file documents
how to work with epsilon-delta definitions in mathlib.

## Key Definitions

### Limit Definition
```lean
import Mathlib.Topology.MetricSpace.Basic

-- Limit of f at a is L
def TendstoAt (f : ℝ → ℝ) (a L : ℝ) : Prop :=
  ∀ ε > 0, ∃ δ > 0, ∀ x, |x - a| < δ → |f x - L| < ε

-- Mathlib uses Filter.Tendsto instead
example (f : ℝ → ℝ) (a L : ℝ) : 
    Filter.Tendsto f (𝓝 a) (𝓝 L) ↔ TendstoAt f a L := by
  sorry
```

### Continuity Definition
```lean
-- Point-wise continuity
def ContinuousAt (f : ℝ → ℝ) (a : ℝ) : Prop :=
  ∀ ε > 0, ∃ δ > 0, ∀ x, |x - a| < δ → |f x - f a| < ε

-- Mathlib definition
#check ContinuousAt  -- Uses topological definition
```

## Common Patterns

### Pattern 1: Prove Limit
```lean
theorem limit_example : TendstoAt (fun x => 2*x + 1) 3 7 := by
  intro ε hε
  use ε/2
  constructor
  · linarith
  · intro x hx
    simp
    calc |2*x + 1 - 7| = |2*x - 6|  := by ring_nf
                     _ = 2*|x - 3|  := by sorry
                     _ < 2*(ε/2)    := by sorry  
                     _ = ε          := by ring
```

### Pattern 2: Prove Continuity
Use mathlib's `Continuous.comp`, `continuous_add`, etc.

```lean
example : Continuous (fun x : ℝ => x^2 + 2*x + 1) := by
  continuity
```

## Relevant Mathlib Modules

- `Mathlib.Topology.MetricSpace.Basic` - Metric spaces
- `Mathlib.Analysis.Calculus.Deriv.Basic` - Derivatives
- `Mathlib.MeasureTheory.Integral.Basic` - Lebesgue integration
- `Mathlib.Analysis.Normed.Group.Basic` - Normed groups

## Helper Lemmas

| Lemma | Statement | Use Case |
|-------|-----------|----------|
| `dist_comm` | `dist x y = dist y x` | Symmetric distance |
| `dist_triangle` | `dist x z ≤ dist x y + dist y z` | Triangle inequality |
| `abs_sub_abs_le_abs_sub` | `||x| - |y|| ≤ |x - y|` | Bound absolute values |
```

##### File 2: `calculus-derivatives.md`

**Key Topics:**
- `deriv` vs `fderiv` (univariate vs multivariate)
- Chain rule: `HasDerivAt.comp`
- Product rule: `HasDerivAt.mul`
- Quotient rule: `HasDerivAt.div`
- Common derivatives: `deriv_polynomial`, `deriv_exp`, `deriv_sin`

##### File 3: `measure-theory-basics.md`

**Key Topics:**
- Measurable spaces: `MeasurableSpace`
- Measures: `Measure`
- Integration: `MeasureTheory.integral`
- Lebesgue dominated convergence: `MeasureTheory.integral_tendsto_of_dominated_convergence`

##### File 4: `functional-analysis-basics.md`

**Key Topics:**
- Banach spaces: `CompleteSpace` + `NormedSpace`
- Hilbert spaces: `InnerProductSpace`
- Bounded linear operators: `ContinuousLinearMap`
- Hahn-Banach theorem: `exists_extension_norm_eq`

##### Additional Files (6 total recommended)

5. `convergence-theorems.md` - Uniform convergence, pointwise convergence
6. `topology-basics.md` - Open sets, closed sets, compactness

---

### 2.2 `context/math/category-theory/` - Categories, Functors, Natural Transformations

**Purpose:** Guide working with mathlib's extensive category theory library for abstract mathematical structures.

#### Recommended Content

##### File 1: `category-basics.md`

**Content:**
```markdown
# Category Theory Basics in Mathlib

## Core Definitions

```lean
import Mathlib.CategoryTheory.Category.Basic

-- Category typeclass
#check CategoryTheory.Category
-- category (objects : Type u) provides:
--   Hom : objects → objects → Type v
--   id : ∀ X, Hom X X
--   comp : Hom X Y → Hom Y Z → Hom X Z

-- Functor
#check CategoryTheory.Functor
-- Functor C D consists of:
--   obj : C → D
--   map : (X ⟶ Y) → (obj X ⟶ obj Y)
--   map_id, map_comp axioms

-- Natural transformation
#check CategoryTheory.NatTrans
-- NatTrans F G (for F G : Functor C D) consists of:
--   app : ∀ X, F.obj X ⟶ G.obj X
--   naturality axiom
```

## Common Patterns

### Pattern 1: Define Category Instance
```lean
instance : Category MyType where
  Hom X Y := MyMorphism X Y
  id X := MyMorphism.id X
  comp f g := MyMorphism.comp f g
  id_comp := sorry
  comp_id := sorry  
  assoc := sorry
```

### Pattern 2: Define Functor
```lean
def myFunctor : Functor C D where
  obj X := [map X to D]
  map f := [map morphism f]
  map_id := by sorry
  map_comp := by sorry
```

### Pattern 3: Prove Naturality
```lean
theorem my_nat_trans_naturality (F G : Functor C D) 
    (τ : ∀ X, F.obj X ⟶ G.obj X) :
    ∀ {X Y} (f : X ⟶ Y), τ Y ≫ G.map f = F.map f ≫ τ X := by
  sorry
```

## Key Mathlib Modules

- `Mathlib.CategoryTheory.Category.Basic` - Core definitions
- `Mathlib.CategoryTheory.Functor.Basic` - Functors
- `Mathlib.CategoryTheory.NatTrans` - Natural transformations
- `Mathlib.CategoryTheory.Limits.Shapes.Products` - Products/coproducts
- `Mathlib.CategoryTheory.Adjunction.Basic` - Adjunctions
```

##### File 2: `functoriality-patterns.md`

**Topics:**
- Proving functor laws (`map_id`, `map_comp`)
- Composition of functors
- Identity functor
- Constant functor

##### File 3: `naturality-patterns.md`

**Topics:**
- Naturality squares
- Vertical composition of natural transformations
- Horizontal composition
- Yoneda lemma

##### Additional Files (4 total recommended)

4. `limits-colimits.md` - Products, coproducts, equalizers, coequalizers
5. `adjunctions.md` - Adjoint functor pairs
6. `monoidal-categories.md` - Tensor products, monoidal structure

---

### 2.3 `context/math/linear-algebra/` - Vector Spaces, Linear Maps, Matrices

**Purpose:** Guide working with mathlib's linear algebra modules for finite/infinite dimensional vector spaces.

#### Recommended Content

##### File 1: `vector-space-basics.md`

**Content:**
```markdown
# Vector Spaces in Mathlib

## Core Definitions

```lean
import Mathlib.Algebra.Module.Basic
import Mathlib.LinearAlgebra.Basic

-- Vector space is a module over a field
#check Module  -- Module R M (R acts on M)
-- When R is a field, M is a vector space

-- Linear map
#check LinearMap  -- LinearMap R M N
-- map : M → N with linearity conditions

-- Basis
#check Basis  -- Basis ι R M (indexed basis)
```

## Common Patterns

### Pattern 1: Define Linear Map
```lean
def myLinearMap (R M N : Type*) [Ring R] [AddCommGroup M] [AddCommGroup N] 
    [Module R M] [Module R N] : LinearMap R M N where
  toFun x := [map x]
  map_add' := by sorry
  map_smul' := by sorry
```

### Pattern 2: Prove Linear Independence
```lean
theorem my_vectors_independent (v₁ v₂ v₃ : V) :
    LinearIndependent K ![v₁, v₂, v₃] := by
  sorry
```

### Pattern 3: Work with Matrices
```lean
import Mathlib.LinearAlgebra.Matrix.ToLin

-- Matrix to linear map
example (A : Matrix (Fin m) (Fin n) ℝ) :
    LinearMap ℝ (Fin n → ℝ) (Fin m → ℝ) :=
  Matrix.toLin' A

-- Linear map to matrix (requires bases)
example (f : V →ₗ[K] W) (bV : Basis ι K V) (bW : Basis κ K W) :
    Matrix κ ι K :=
  LinearMap.toMatrix bV bW f
```

## Key Mathlib Modules

- `Mathlib.Algebra.Module.Basic` - Modules (vector spaces)
- `Mathlib.LinearAlgebra.Basic` - Linear maps, spans
- `Mathlib.LinearAlgebra.Basis` - Bases, linear independence
- `Mathlib.LinearAlgebra.FiniteDimensional` - Finite dimension
- `Mathlib.LinearAlgebra.Matrix.ToLin` - Matrix-linear map conversion

## Helper Lemmas

| Lemma | Use Case |
|-------|----------|
| `LinearMap.ext` | Extensionality for linear maps |
| `Basis.ext` | Extensionality for bases |
| `Submodule.span_eq_top_iff_linearIndependent` | Basis characterization |
```

##### File 2: `dimension-theory.md`

**Topics:**
- Finite dimensional spaces: `FiniteDimensional`
- Dimension: `finrank K V`
- Rank-nullity theorem
- Dimension of subspaces

##### File 3: `eigenvalues-eigenvectors.md`

**Topics:**
- `Module.End.HasEigenvalue`
- `Module.End.HasEigenvector`
- Characteristic polynomial
- Diagonalization

##### Additional Files (4 total recommended)

4. `bilinear-forms.md` - Symmetric, alternating bilinear forms
5. `quotient-spaces.md` - Quotient vector spaces
6. `dual-spaces.md` - Dual vectors, dual bases
7. `tensor-products.md` - Tensor product of modules

---

## 3. Mathlib Integration

### 3.1 Relevant Mathlib Modules for Logic Domain

#### 3.1.1 Propositional Logic

**Mathlib Modules:**
- `Mathlib.Logic.Basic` - Classical logic, decidability
- `Mathlib.Data.Bool.Basic` - Boolean operations
- `Mathlib.Tactic.Classical` - Classical reasoning tactics

**Key Definitions:**
```lean
-- Classical logic
#check Classical.em  -- ∀ p, p ∨ ¬p
#check Classical.byContradiction  -- (¬p → False) → p

-- Decidability  
#check Decidable  -- typeclass for decidable propositions
```

**Helper Lemmas:**
```lean
-- Double negation
theorem double_neg {p : Prop} : ¬¬p → p := Classical.byContradiction

-- De Morgan laws (already in mathlib)
#check not_and_or  -- ¬(p ∧ q) ↔ ¬p ∨ ¬q
#check not_or  -- ¬(p ∨ q) ↔ ¬p ∧ ¬q
```

#### 3.1.2 First-Order Logic / Model Theory

**Mathlib Modules:**
- `Mathlib.ModelTheory.Basic` - First-order structures
- `Mathlib.ModelTheory.Syntax` - First-order formulas
- `Mathlib.ModelTheory.Semantics` - Satisfaction relation

**Relevance:** Useful if extending Logos to first-order modal logic or quantified modal logic.

#### 3.1.3 Inductive Types and Recursion (for Formula Definitions)

**Mathlib Modules:**
- `Mathlib.Init.Data.Nat.Basic` - Inductive natural numbers
- `Mathlib.Data.List.Basic` - Inductive lists

**Pattern:**
```lean
-- Inductive formula type (similar to Logos)
inductive Formula where
  | atom : String → Formula
  | bot : Formula  
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
```

### 3.2 Relevant Mathlib Modules for Mathematics Domain

#### 3.2.1 Analysis

**Core Modules:**
1. `Mathlib.Topology.Basic` - Topological spaces, open/closed sets
2. `Mathlib.Topology.MetricSpace.Basic` - Metric spaces, distances
3. `Mathlib.Analysis.Calculus.Deriv.Basic` - Derivatives
4. `Mathlib.Analysis.Calculus.FDeriv.Basic` - Fréchet derivatives
5. `Mathlib.MeasureTheory.Measure.MeasureSpace` - Measure spaces
6. `Mathlib.MeasureTheory.Integral.Bochner` - Bochner integral

**Import Strategy:**
```lean
-- Minimal imports for basic analysis
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic

-- For measure theory
import Mathlib.MeasureTheory.Integral.Bochner
```

#### 3.2.2 Category Theory

**Core Modules:**
1. `Mathlib.CategoryTheory.Category.Basic` - Categories
2. `Mathlib.CategoryTheory.Functor.Basic` - Functors
3. `Mathlib.CategoryTheory.NatTrans` - Natural transformations
4. `Mathlib.CategoryTheory.Adjunction.Basic` - Adjunctions
5. `Mathlib.CategoryTheory.Limits.Shapes.Products` - Products

**Import Strategy:**
```lean
-- For basic category theory
import Mathlib.CategoryTheory.Category.Basic
import Mathlib.CategoryTheory.Functor.Basic
```

#### 3.2.3 Linear Algebra

**Core Modules:**
1. `Mathlib.Algebra.Module.Basic` - Modules (vector spaces)
2. `Mathlib.LinearAlgebra.Basic` - Linear maps
3. `Mathlib.LinearAlgebra.Basis` - Bases
4. `Mathlib.LinearAlgebra.FiniteDimensional` - Finite dimension
5. `Mathlib.LinearAlgebra.Matrix.ToLin` - Matrix conversions

**Import Strategy:**
```lean
-- For basic linear algebra
import Mathlib.LinearAlgebra.Basic
import Mathlib.LinearAlgebra.Basis
```

### 3.3 Common Helper Lemmas by Domain

#### 3.3.1 Logic Domain Helper Lemmas

**From `Mathlib.Logic.Basic`:**
```lean
-- Implication
#check imp_self  -- p → p
#check not_not_of_not_imp  -- ¬(p → q) → ¬¬p

-- Conjunction  
#check And.left  -- p ∧ q → p
#check And.right  -- p ∧ q → q
#check And.intro  -- p → q → p ∧ q

-- Disjunction
#check Or.inl  -- p → p ∨ q
#check Or.inr  -- q → p ∨ q
#check Or.elim  -- p ∨ q → (p → r) → (q → r) → r

-- Negation
#check not_not  -- ¬¬p ↔ p (classical)
#check not_and_or  -- ¬(p ∧ q) ↔ ¬p ∨ ¬q
```

#### 3.3.2 Analysis Helper Lemmas

**From `Mathlib.Topology.MetricSpace.Basic`:**
```lean
-- Distance properties
#check dist_comm  -- dist x y = dist y x
#check dist_self  -- dist x x = 0
#check dist_triangle  -- dist x z ≤ dist x y + dist y z
#check dist_nonneg  -- 0 ≤ dist x y

-- Metric space balls
#check Metric.mem_ball  -- x ∈ ball y r ↔ dist x y < r
#check Metric.ball_subset_ball  -- r₁ ≤ r₂ → ball x r₁ ⊆ ball x r₂
```

**From `Mathlib.Analysis.Calculus.Deriv.Basic`:**
```lean
-- Derivative lemmas
#check deriv_id  -- deriv id = 1
#check deriv_const  -- deriv (const c) = 0
#check deriv_add  -- deriv (f + g) = deriv f + deriv g
#check deriv_mul  -- deriv (f * g) = deriv f * g + f * deriv g
```

#### 3.3.3 Category Theory Helper Lemmas

**From `Mathlib.CategoryTheory.Category.Basic`:**
```lean
-- Category laws
#check Category.id_comp  -- 𝟙 X ≫ f = f
#check Category.comp_id  -- f ≫ 𝟙 Y = f
#check Category.assoc  -- (f ≫ g) ≫ h = f ≫ (g ≫ h)
```

**From `Mathlib.CategoryTheory.Functor.Basic`:**
```lean
-- Functor properties
#check Functor.map_id  -- F.map (𝟙 X) = 𝟙 (F.obj X)
#check Functor.map_comp  -- F.map (f ≫ g) = F.map f ≫ F.map g
```

#### 3.3.4 Linear Algebra Helper Lemmas

**From `Mathlib.LinearAlgebra.Basic`:**
```lean
-- Linear map properties
#check LinearMap.map_zero  -- f 0 = 0
#check LinearMap.map_add  -- f (x + y) = f x + f y
#check LinearMap.map_smul  -- f (c • x) = c • f x
```

**From `Mathlib.LinearAlgebra.Basis`:**
```lean
-- Basis properties
#check Basis.ext  -- Extensionality for elements via basis
#check Basis.linearIndependent  -- Basis vectors are linearly independent
#check Basis.span_eq  -- Basis spans the space
```

### 3.4 Import Pattern Best Practices

#### Pattern 1: Minimal Imports
```lean
-- Import only what you need
import Mathlib.Data.Real.Basic  -- Just real numbers
-- NOT: import Mathlib  -- Imports entire library (slow)
```

#### Pattern 2: Qualified Imports (for Logic)
```lean
-- For logic work, prefer qualified imports to avoid name collisions
import Mathlib.Logic.Basic

-- Access via namespace
example : Classical.em p := sorry
```

#### Pattern 3: Open Namespaces Selectively
```lean
import Mathlib.CategoryTheory.Category.Basic

-- Open only needed namespaces
open CategoryTheory
-- NOT: open CategoryTheory.Category (too broad)

-- Now use Category without qualification
#check Category
```

#### Pattern 4: Handling Dependency Order
```lean
-- Import order matters: more basic modules first
import Mathlib.Algebra.Group.Defs  -- First: group definitions
import Mathlib.Algebra.Group.Hom.Defs  -- Then: group homomorphisms
import Mathlib.Topology.Algebra.Group  -- Finally: topological groups
```

---

## 4. Content Examples

### 4.1 Example Process File: Modal Logic Soundness

**File:** `context/logic/processes/modal-soundness-workflow.md`

```markdown
# Modal Logic Soundness Proof Workflow

## Overview
This workflow guides proving soundness for a modal logic system: if a formula
is derivable (⊢ φ), then it is semantically valid (⊨ φ).

**Soundness Theorem:** ∀ Γ φ, Γ ⊢ φ → Γ ⊨ φ

**Proof Strategy:** Induction on the derivability relation.

## Prerequisites

### Required Definitions
1. **Syntax:**
   - Formula type: `inductive Formula`
   - Derivability: `inductive Derivable : Context → Formula → Prop`

2. **Semantics:**
   - Frame: `structure Frame` with worlds W and accessibility R
   - Model: `structure Model` extending Frame with valuation V
   - Truth: `def truth_at : Model → World → Formula → Prop`
   - Validity: `def valid (φ : Formula) : Prop := ∀ M w, truth_at M w φ`

3. **Axioms & Rules:**
   - Axiom constructors: `inductive Axiom : Formula → Prop`
   - Inference rules: Derivable constructors (modus_ponens, necessitation, etc.)

## Workflow Steps

### Phase 1: Axiom Validity Lemmas (Base Cases)

**Step 1.1:** List all axiom schemas
Create checklist of axioms to prove valid:
- [ ] Propositional axioms (K, S)
- [ ] Modal axioms (T, 4, 5, B, K)
- [ ] Any system-specific axioms

**Step 1.2:** Prove each axiom valid

For each axiom, follow this template:

```lean
/-- [AXIOM_NAME] axiom is valid: `⊨ [FORMULA]`

**Semantic Reading:** [INTUITIVE_MEANING]
**Frame Property:** [REQUIRED_PROPERTY] (if applicable)
-/
theorem [axiom_name]_valid (φ [ψ ...] : Formula) : 
    valid ([AXIOM_FORMULA]) := by
  intro F M w              -- Introduce arbitrary frame, model, world
  unfold truth_at          -- Expand truth definition
  intro [ASSUMPTIONS]       -- Introduce antecedents of implication
  
  -- Case 1: Use frame property
  have h_frame : [FRAME_PROPERTY] := F.[PROPERTY_NAME] w
  
  -- Case 2: Apply propositional reasoning
  -- Use assumptions and frame property to derive conclusion
  
  sorry  -- Complete proof
```

**Example - Modal T Axiom (□φ → φ):**
```lean
theorem modal_t_valid (φ : Formula) : valid (Formula.box φ → φ) := by
  intro F M w
  unfold truth_at
  intro h_box  -- Assume □φ at w
  
  -- Use reflexivity: wRw
  have h_refl : F.R w w := F.reflexive w
  
  -- From □φ, get φ at all R-accessible worlds
  -- Since R w w, get φ at w
  exact h_box w h_refl
```

**Common Patterns:**
- **Reflexivity (T axiom):** Use `F.reflexive w : R w w`
- **Transitivity (4 axiom):** Use `F.transitive w v u : R w v → R v u → R w u`
- **Symmetry (B axiom):** Use `F.symmetric w v : R w v → R v w`
- **Euclidean (5 axiom):** Use `F.euclidean w v u : R w v → R w u → R v u`

**Step 1.3:** Test each axiom validity lemma
```lean
-- Smoke test: ensure each lemma typechecks and has expected type
#check modal_t_valid  -- Should be: ∀ φ, valid (□φ → φ)
#check modal_4_valid  -- Should be: ∀ φ, valid (□φ → □□φ)
```

### Phase 2: Inference Rule Soundness (Inductive Cases)

**Step 2.1:** List all inference rules
- [ ] Modus ponens
- [ ] Necessitation  
- [ ] Modal K rule (if separate from axiom)
- [ ] Any system-specific rules

**Step 2.2:** Prove each rule sound

Follow this template for each rule:

```lean
-- For rule: from h₁ : Γ ⊢ φ and h₂ : Γ ⊢ ψ, derive Γ ⊢ χ
-- Prove soundness: from (Γ ⊨ φ) and (Γ ⊨ ψ), derive (Γ ⊨ χ)

-- These will be proved as cases in the main soundness theorem
-- Document the proof pattern here:

/-- Modus ponens soundness pattern

**Given:**
- ih1 : Γ ⊨ φ → ψ
- ih2 : Γ ⊨ φ

**Show:** Γ ⊨ ψ

**Proof:** 
```lean
| modus_ponens Γ φ ψ h1 h2 ih1 ih2 =>
  intro F M w hΓ           -- Introduce model and context truth
  exact ih1 F M w hΓ (ih2 F M w hΓ)  -- Apply IHs
```
-/
```

**Example - Necessitation Soundness:**
```lean
/-- Necessitation soundness pattern

**Given:**
- ih : ⊨ φ (φ is valid, no context)

**Show:** ⊨ □φ (□φ is valid)

**Proof:**
```lean
| necessitation φ h ih =>
  intro F M w              -- Introduce model
  unfold truth_at          -- Expand □φ definition
  intro v h_acc            -- Introduce accessible world v
  exact ih F M v           -- Apply IH: φ valid at v
```
-/
```

### Phase 3: Main Soundness Theorem

**Step 3.1:** State soundness theorem
```lean
/-- Soundness theorem: derivability implies validity.

If Γ ⊢ φ (φ is derivable from context Γ), then Γ ⊨ φ (φ is a semantic
consequence of Γ).

**Proof Strategy:** Induction on derivation structure.

**Base Case:** Axiom validity (proved in Phase 1)
**Inductive Cases:** Rule soundness (proved in Phase 2)
-/
theorem soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ := by
  intro h
  induction h with
  | axiom Γ φ hax =>
    -- Apply appropriate axiom validity lemma
    cases hax with
    | [axiom_1] φ => exact [axiom_1_valid] φ
    | [axiom_2] φ => exact [axiom_2_valid] φ
    -- ... for all axioms
  
  | modus_ponens Γ φ ψ h1 h2 ih1 ih2 =>
    -- Use induction hypotheses
    intro F M w hΓ
    exact ih1 F M w hΓ (ih2 F M w hΓ)
  
  | necessitation Γ φ h ih =>
    -- From ⊨ φ, show ⊨ □φ
    intro F M w hΓ v h_acc
    exact ih F M v hΓ
  
  -- ... for all inference rules
```

**Step 3.2:** Verify completeness
Check all axioms and rules have corresponding cases:
- [ ] All axiom constructors handled in `cases hax`
- [ ] All derivability constructors handled as induction cases
- [ ] No `sorry` remaining in proof

### Phase 4: Testing and Validation

**Step 4.1:** Unit tests for axiom validity
```lean
-- Test each axiom validity lemma independently
example (P : Formula) : valid (□P → P) := modal_t_valid P
example (P : Formula) : valid (□P → □□P) := modal_4_valid P
```

**Step 4.2:** Integration test
```lean
-- Test soundness theorem on sample derivations
example (P Q : Formula) (h1 : ⊢ P) (h2 : ⊢ P → Q) : valid Q := by
  have h3 : ⊢ Q := Derivable.modus_ponens [] P Q h2 h1
  exact soundness [] Q h3
```

**Step 4.3:** Property tests
Verify expected properties:
```lean
-- Soundness implies consistency (⊢ ⊥ → False)
theorem consistency_from_soundness : ¬(⊢ Formula.bot) := by
  intro h
  have h_valid := soundness [] Formula.bot h
  -- ⊨ ⊥ is contradictory (truth_at M w ⊥ = False)
  sorry
```

## Common Issues and Solutions

### Issue 1: Type Mismatch in Axiom Cases
**Problem:** `cases hax with` fails due to type incompatibility
**Solution:** Ensure axiom constructors match formula type exactly

### Issue 2: Frame Property Not Available
**Problem:** Trying to use transitivity when frame is only reflexive
**Solution:** Check frame definition - may need to add property or use different axiom

### Issue 3: Induction Hypothesis Not Applicable
**Problem:** IH has type `Γ ⊨ φ` but need `Γ' ⊨ φ`
**Solution:** May need weakening lemma or context manipulation

### Issue 4: Classical Logic Required
**Problem:** Need double negation elimination or excluded middle
**Solution:** Use `Classical.em` or `Classical.byContradiction`

## Context Dependencies
- `../standards/kripke-semantics-standard.md` - Semantic definitions
- `../templates/modal-soundness-template.md` - Proof templates
- `../patterns/frame-property-pattern.md` - Frame property application

## Success Criteria
- [ ] All axiom validity lemmas proved
- [ ] All inference rule cases complete
- [ ] Main soundness theorem proved (no `sorry`)
- [ ] All tests pass
- [ ] Documentation complete

## References
- Logos implementation: `Logos/Core/Metalogic/Soundness.lean`
- Blackburn et al., "Modal Logic", Chapter 4 - Soundness proofs
- van Benthem, "Modal Logic for Open Minds", Section 3.2
```

---

### 4.2 Example Standard File: Axiom Systems

**File:** `context/logic/standards/axiom-system-standard.md`

```markdown
# Axiom System Documentation Standard

## Purpose
This standard defines how to document modal/temporal logic axiom systems in LEAN 4
to ensure consistency, completeness, and usability across the Logos project.

## Required Components for Each Axiom

### 1. Axiom Name
Use standard names from modal logic literature:
- **Propositional:** K (distribution), S (weakening)
- **Modal:** T (reflexivity), 4 (transitivity), 5 (Euclidean), B (symmetry)
- **Temporal:** A (past/future symmetry), L (linearity), 4 (density)

### 2. Formula Schema
Provide both LEAN syntax and Unicode notation:

```lean
/-- Modal T Axiom: Necessity implies truth

**Unicode:** □φ → φ
**LEAN:** Formula.box φ → φ
-/
inductive Axiom : Formula → Prop where
  | modal_t (φ : Formula) : Axiom ((Formula.box φ).imp φ)
```

### 3. Semantic Reading
Explain intuitive meaning in natural language:

```lean
/-- **Semantic Reading:** 
If φ is necessary (true in all accessible possible worlds), 
then φ is true in the current world.
-/
```

### 4. Frame Condition
Specify corresponding frame property (if applicable):

```lean
/-- **Frame Condition:** 
Reflexive accessibility relation: ∀w ∈ W, wRw

This means every world is accessible from itself.
-/
```

### 5. System Characterization
Indicate which systems include this axiom:

```lean
/-- **Systems:** 
- K + T = T (minimal reflexive system)
- K + T + 4 = S4 (reflexive-transitive)
- K + T + 5 = S5 (equivalence relation)
-/
```

## Complete Example: Modal T Axiom

```lean
/-- Modal T Axiom: Necessity implies truth (reflexivity)

The T axiom states that if a formula φ is necessary (true in all accessible
worlds), then φ must be true in the current world. This corresponds to the
semantic condition that the accessibility relation is reflexive.

**Formula:** □φ → φ
**LEAN Syntax:** `(Formula.box φ).imp φ`
**Semantic Reading:** Necessary truth implies actual truth
**Frame Condition:** Reflexivity (∀w ∈ W, wRw)
**Systems:** T, S4, S5

**Historical Note:** Named after the modal system T introduced by Sobociński
in 1953, though reflexivity was studied earlier by Lewis.

**Proof Strategy (Validity):**
1. Assume □φ holds at world w
2. By definition, φ holds at all R-accessible worlds
3. By reflexivity, w is R-accessible from itself (wRw)
4. Therefore, φ holds at w

**Related Axioms:**
- Modal 4: □φ → □□φ (transitivity)
- Modal B: φ → □◇φ (symmetry)
-/
inductive Axiom : Formula → Prop where
  | modal_t (φ : Formula) : Axiom ((Formula.box φ).imp φ)
```

## Inference Rule Documentation Standard

### Required Components

1. **Rule Name:** Standard name (modus ponens, necessitation, etc.)
2. **Premises:** Required derivations
3. **Conclusion:** Derived formula
4. **Side Conditions:** Context restrictions or formula requirements
5. **Soundness Sketch:** How to prove rule preserves validity

### Example: Necessitation Rule

```lean
/-- Necessitation Rule: From validity, derive necessity

**Rule:** If ⊢ φ (φ is a theorem), then ⊢ □φ (□φ is a theorem)

**Premises:** 
- h : Derivable [] φ  (φ derivable from empty context)

**Conclusion:**
- Derivable [] (Formula.box φ)  (□φ derivable from empty context)

**Side Condition:** 
Context must be empty ([]). Necessitation does not apply to assumptions.

**Soundness Sketch:**
If φ is valid (true at all worlds in all models), then □φ is valid
(at every world w, φ is true at all R-accessible worlds, which includes
all worlds since φ is valid).

**WARNING:** Common error - applying necessitation with non-empty context:
```lean
-- WRONG: Cannot derive □P from assumption P
example (P : Formula) : [P] ⊢ □P := by
  apply Derivable.necessitation  -- ERROR: context not empty
```

**Correct usage:**
```lean
-- If P is a theorem, then □P is a theorem
example (P : Formula) (h : [] ⊢ P) : [] ⊢ □P := by
  exact Derivable.necessitation P h
```
-/
inductive Derivable : Context → Formula → Prop where
  | necessitation (φ : Formula) : 
      Derivable [] φ → Derivable [] (Formula.box φ)
```

## System Documentation Standard

### Required Components

1. **System Name:** Standard name (K, T, S4, S5, KT, K4, etc.)
2. **Axiom Set:** Complete list of axioms
3. **Inference Rules:** Complete list of rules
4. **Frame Class:** Characterized frame class
5. **Key Properties:** Decidability, completeness, etc.

### Example: System S4

```lean
/-- Modal Logic System S4

System S4 is the modal logic characterized by reflexive and transitive frames
(preorder relations). It is one of the most important modal logics, used in
temporal logic, epistemic logic, and provability logic.

**Axioms:**
- Propositional axioms (K, S, etc.)
- Modal K: □(φ → ψ) → (□φ → □ψ)  [distribution]
- Modal T: □φ → φ  [reflexivity]
- Modal 4: □φ → □□φ  [transitivity]

**Inference Rules:**
- Modus ponens
- Necessitation: ⊢ φ ⇒ ⊢ □φ

**Frame Class:** 
Reflexive and transitive accessibility relations (preorders)
- Reflexive: ∀w, wRw
- Transitive: ∀w v u, wRv → vRu → wRu

**Key Properties:**
- Decidable: Yes (filtration method)
- Complete: Yes (canonical model)
- Finite model property: Yes
- Kripke complete: Yes

**Applications:**
- Temporal logic: "always in the future" operator
- Epistemic logic: Knowledge operator (weaker than S5)
- Provability logic: GL = S4 + Löb axiom

**Historical Note:**
Introduced by C.I. Lewis in 1932 as one of the five original modal systems
(S1-S5). The S stands for "Survey of Symbolic Logic".

**Relationship to Other Systems:**
- S4 ⊂ S5 (S5 = S4 + Modal 5 or Modal B)
- T ⊂ S4 (S4 = T + Modal 4)
- K ⊂ T ⊂ S4 ⊂ S5

**Implementation in Logos:**
```lean
-- S4 axioms (in addition to propositional axioms)
| modal_k (φ ψ : Formula) : 
    Axiom ((Formula.box (φ.imp ψ)).imp ((Formula.box φ).imp (Formula.box ψ)))
| modal_t (φ : Formula) : 
    Axiom ((Formula.box φ).imp φ)
| modal_4 (φ : Formula) : 
    Axiom ((Formula.box φ).imp (Formula.box (Formula.box φ)))

-- S4 frame
structure S4Frame where
  W : Type
  R : W → W → Prop
  reflexive : ∀ w, R w w
  transitive : ∀ w v u, R w v → R v u → R w u
```
-/
```

## Naming Conventions

### Axiom Names
- Use `snake_case` for theorem names: `modal_t_valid`, `modal_4_derivable`
- Use standard abbreviations: `t` (truth/reflexivity), `4` (transitivity), `k` (distribution)
- Prefix with modality: `modal_`, `temporal_`, `prop_`

### Formula Variables
- Use Greek letters: `φ`, `ψ`, `χ` (phi, psi, chi)
- Use `P`, `Q`, `R` for atomic propositions
- Use descriptive names for complex formulas: `antecedent`, `consequent`

### Frame Variables
- `W` : Type of worlds
- `R` : Accessibility relation
- `w`, `v`, `u` : Individual worlds
- `M` : Model (frame + valuation)
- `F` : Frame alone

## Cross-Reference Standards

Each axiom should reference:
1. **Validity proof:** Location of `[axiom]_valid` theorem
2. **Usage examples:** Where axiom is used in derivations
3. **Related axioms:** Other axioms in same family
4. **Literature:** Standard references (Blackburn et al., Hughes & Cresswell)

Example:
```lean
/-- **References:**
- Validity proof: `Logos/Core/Metalogic/Soundness.lean:84`
- Usage: Perpetuity P1 uses Modal T
- Related: Modal 4, Modal 5, Modal B
- Literature: Blackburn et al., "Modal Logic" (2001), Theorem 1.22
-/
```

## Success Criteria

A well-documented axiom system includes:
- [ ] All axioms documented with formula, reading, and frame condition
- [ ] All inference rules documented with premises and conclusion
- [ ] System characterization with frame class
- [ ] Examples of use in derivations
- [ ] References to validity proofs
- [ ] Cross-references to related systems

## See Also
- `../processes/modal-soundness-workflow.md` - How to prove axioms valid
- `../templates/modal-soundness-template.md` - Proof templates
- `kripke-semantics-standard.md` - Semantic definitions
```

---

### 4.3 Example Template File: Soundness Proofs

[Already provided in Section 4.1 and Template 1 in 1.3]

---

### 4.4 Example Pattern File: Tactic Sequences

[Already provided in Section 1.4 - Pattern 1 and existing tactic-patterns.md]

---

### 4.5 Example Analysis Content File

**File:** `context/math/analysis/epsilon-delta-patterns.md`

[Already provided in Section 2.1 - File 1]

---

### 4.6 Example Category Theory Content File

**File:** `context/math/category-theory/category-basics.md`

[Already provided in Section 2.2 - File 1]

---

### 4.7 Example Linear Algebra Content File

**File:** `context/math/linear-algebra/vector-space-basics.md`

[Already provided in Section 2.3 - File 1]

---

## 5. Implementation Guide

### 5.1 File Naming Conventions

#### General Principles
- Use `kebab-case` for file names: `modal-soundness-workflow.md`
- Be descriptive but concise: max 4-5 words
- Use standard terminology from domain literature

#### Logic Domain
- **Processes:** `[system]-[property]-workflow.md`
  - Examples: `modal-soundness-workflow.md`, `s4-completeness-workflow.md`
- **Standards:** `[concept]-standard.md`
  - Examples: `axiom-system-standard.md`, `kripke-semantics-standard.md`
- **Templates:** `[proof-type]-template.md`
  - Examples: `modal-soundness-template.md`, `completeness-template.md`
- **Patterns:** `[technique]-pattern.md`
  - Examples: `axiom-application-pattern.md`, `frame-property-pattern.md`

#### Mathematics Domain
- **Analysis:** `[topic]-[subtopic].md`
  - Examples: `epsilon-delta-patterns.md`, `calculus-derivatives.md`
- **Category Theory:** `[concept]-basics.md` or `[concept]-patterns.md`
  - Examples: `category-basics.md`, `functoriality-patterns.md`
- **Linear Algebra:** `[concept]-[aspect].md`
  - Examples: `vector-space-basics.md`, `dimension-theory.md`

### 5.2 Content Structure Guidelines

#### Standard Sections for All Files

1. **Header Block:**
```markdown
# [Title]

**Purpose:** [One sentence describing purpose]
**When to Use:** [Bullet list of use cases]
**Prerequisites:** [Required knowledge/files]
```

2. **Overview:**
- Brief description (2-3 paragraphs)
- Key concepts introduced
- Context within broader domain

3. **Main Content:**
- Organized by subtopic with `##` and `###` headers
- LEAN code examples in fenced code blocks with `lean` language tag
- Explanatory text between code blocks

4. **Context Dependencies:**
```markdown
## Context Dependencies
- `../related/file1.md` - Brief description
- `../related/file2.md` - Brief description
```

5. **References:**
```markdown
## References
- Mathlib: `Mathlib.Path.To.Module`
- LEAN 4 docs: [Title](URL)
- Academic: Author, "Title", Year
- Project: `Path/To/File.lean`
```

#### Process Files Structure

```markdown
# [Process Name]

## Overview
[Description of process and when to use]

## Prerequisites
- [Required definitions]
- [Required knowledge]

## Process Steps

### Phase 1: [Phase Name]
**Step 1.1:** [Step name]
- Action: [What to do]
- Validation: [How to check]
- Output: [What is produced]

### Phase 2: [Next Phase]
...

## Common Issues and Solutions
### Issue 1: [Problem]
**Problem:** [Description]
**Solution:** [Fix]

## Context Dependencies
[Related files]

## Success Criteria
- [ ] [Checklist item]
```

#### Standard Files Structure

```markdown
# [Standard Name]

## Purpose
[Why this standard exists]

## Required Components
### Component 1: [Name]
[Description and requirements]

**Example:**
```lean
[code example]
```

### Component 2: [Next Component]
...

## Naming Conventions
[Rules for naming]

## Cross-Reference Standards
[How to reference related content]

## Success Criteria
[Checklist for compliance]
```

#### Template Files Structure

```markdown
# [Template Name]

## Template: [Template Type]

**When to Use:** [Use case]

```lean
/-- [Docstring template]
-/
theorem [name_pattern] (φ : Formula) : [GOAL] := by
  [tactic sequence with placeholders]
  sorry
```

### Instantiation Example
[Concrete example with placeholders filled in]

## Variations
### Variation 1: [Name]
[Description and code]

## Common Pitfalls
[What to avoid]
```

#### Pattern Files Structure

```markdown
# [Pattern Name]

## Pattern: [Pattern Type]

**When to Use:** [Use case]
**Frequency:** [How common this pattern is]

**Tactic Sequence:**
```lean
example [params] : [goal] := by
  [tactic_1]
  [tactic_2]
  ...
```

**Explanation:**
[Why this sequence works]

**Variations:**
1. [Variation name]: [Description]
2. ...

**Example Usage:**
[Real example from codebase]
```

### 5.3 Cross-Referencing Strategies

#### Markdown Link Format
```markdown
See [`axiom-system-standard.md`](../standards/axiom-system-standard.md) for details.
```

#### Cross-Domain References
```markdown
## Related Mathematics
This logic workflow uses techniques from analysis:
- [Epsilon-delta patterns](../../math/analysis/epsilon-delta-patterns.md)
```

#### Bidirectional Links
When File A references File B, add reciprocal reference in File B:

File A:
```markdown
## Context Dependencies
- [`kripke-semantics-standard.md`](../standards/kripke-semantics-standard.md)
```

File B (`kripke-semantics-standard.md`):
```markdown
## Used By
- [`modal-soundness-workflow.md`](../processes/modal-soundness-workflow.md)
```

#### Codebase References
```markdown
## Implementation
See `Logos/Core/Metalogic/Soundness.lean:84` for the proof.
```

### 5.4 Maintenance and Updates

#### Version Control
- Add last updated date in file header:
```markdown
**Last Updated:** 2025-12-16
```

#### Change Log (for major files)
```markdown
## Change Log
- 2025-12-16: Added section on temporal duality
- 2025-12-10: Initial version
```

#### Review Cycle
- Review context files every 3 months
- Update when new patterns emerge from development
- Archive outdated content to `context/archive/`

#### Quality Checklist
Before committing new context file:
- [ ] Title and purpose clear
- [ ] Code examples typechecked
- [ ] Cross-references valid (files exist)
- [ ] Follows naming conventions
- [ ] No TODO/FIXME unless documented
- [ ] References include URLs when applicable

### 5.5 Priority Ordering for Creation

#### Phase 1: Logic Context (Weeks 1-2) - HIGHEST PRIORITY

**Rationale:** Logos is a logic formalization project - logic context provides immediate value.

**Week 1: Core Standards and Processes (Most Critical)**
1. `context/logic/standards/axiom-system-standard.md` ⭐⭐⭐⭐⭐
   - Defines how to document axioms (immediate need for every theorem)
   - Template for all future axiom systems
   
2. `context/logic/standards/kripke-semantics-standard.md` ⭐⭐⭐⭐⭐
   - Semantic definitions used in all validity proofs
   - Prevents definition inconsistencies

3. `context/logic/processes/modal-soundness-workflow.md` ⭐⭐⭐⭐⭐
   - Most common proof type in Logos
   - Immediate ROI for perpetuity and S5 proofs

4. `context/logic/standards/proof-system-standard.md` ⭐⭐⭐⭐
   - Derivability conventions
   - Context management rules

**Week 2: Templates and Patterns**
5. `context/logic/templates/modal-soundness-template.md` ⭐⭐⭐⭐
   - Reusable proof skeleton
   - Saves time on each soundness proof

6. `context/logic/patterns/axiom-application-pattern.md` ⭐⭐⭐⭐
   - Most frequent tactic sequence
   - High reuse across proofs

7. `context/logic/patterns/derivability-induction-pattern.md` ⭐⭐⭐⭐
   - Core pattern for metalogic proofs

8. `context/logic/processes/temporal-duality-workflow.md` ⭐⭐⭐
   - Logos-specific (bimodal logic)
   - Needed for temporal theorem variations

#### Phase 2: Mathematics Context - Analysis (Weeks 3-4) - MEDIUM PRIORITY

**Rationale:** Future work may involve quantitative analysis, measure-theoretic semantics.

**Week 3: Analysis Basics**
9. `context/math/analysis/epsilon-delta-patterns.md` ⭐⭐⭐
   - Foundation for analysis work
   - Useful if extending to continuous models

10. `context/math/analysis/calculus-derivatives.md` ⭐⭐
    - May be needed for optimization in decision theory extensions

11. `context/math/analysis/measure-theory-basics.md` ⭐⭐
    - Relevant if adding probabilistic semantics

#### Phase 3: Mathematics Context - Category Theory (Weeks 5-6) - LOWER PRIORITY

**Rationale:** Helpful for abstract structure but not immediately needed.

12. `context/math/category-theory/category-basics.md` ⭐⭐
    - Useful for understanding mathlib organization
    - Not directly needed for Logos logic proofs

13. `context/math/category-theory/functoriality-patterns.md` ⭐
    - Advanced topic, deferred

#### Phase 4: Mathematics Context - Linear Algebra (Weeks 7-8) - LOWER PRIORITY

**Rationale:** May be needed for algebraic semantics, but not core to Logos.

14. `context/math/linear-algebra/vector-space-basics.md` ⭐⭐
    - Potentially useful for algebraic logic

15. `context/math/linear-algebra/dimension-theory.md` ⭐
    - Specialized topic

#### Phase 5: Remaining Logic Context (Weeks 9-12) - AS NEEDED

Complete remaining logic files based on development needs:
16-30. Additional processes, standards, templates, patterns (see Sections 1.1-1.4 for full list)

**80/20 Rule:** First 8 files provide 80% of value. Prioritize these.

### 5.6 Quality Metrics

#### Completeness Metrics
- **Process files:** Include all phases from start to completion
- **Standard files:** Cover all required components
- **Template files:** Include instantiation example
- **Pattern files:** Include 3+ variations

#### Usability Metrics
- **Code examples:** All code blocks are valid LEAN 4 syntax
- **Cross-references:** All links point to existing files
- **Searchability:** File name matches content (grep-friendly)

#### Maintenance Metrics
- **Freshness:** Files updated within 6 months
- **Accuracy:** Examples match current codebase
- **Completeness:** No TODO/FIXME without tracking

---

## 6. Bibliography

### Academic References

#### Modal Logic Textbooks
1. **Blackburn, P., de Rijke, M., & Venema, Y.** (2001). *Modal Logic*. Cambridge University Press.
   - Comprehensive treatment of modal logic
   - Chapters 2-4 cover soundness, completeness, correspondence theory
   - URL: https://www.cambridge.org/core/books/modal-logic/

2. **Hughes, G. E., & Cresswell, M. J.** (1996). *A New Introduction to Modal Logic*. Routledge.
   - Classic introduction to modal systems K, T, S4, S5
   - Excellent coverage of axiom systems and frame conditions

3. **van Benthem, J.** (2010). *Modal Logic for Open Minds*. CSLI Publications.
   - Modern perspective on modal logic
   - Emphasizes dynamic epistemic logic and applications

4. **Chellas, B. F.** (1980). *Modal Logic: An Introduction*. Cambridge University Press.
   - Rigorous mathematical treatment
   - Strong focus on algebraic semantics

#### Temporal Logic
5. **Burgess, J. P.** (2009). *Philosophical Logic*. Princeton University Press.
   - Chapter on temporal logic and tense operators
   - Philosophy of time and logic

6. **Goldblatt, R.** (1992). *Logics of Time and Computation* (2nd ed.). CSLI Publications.
   - Temporal logic for computer science
   - Linear time, branching time, CTL

#### LEAN 4 and Formalization
7. **Moura, L. de, & Ullrich, S.** (2021). "The Lean 4 Theorem Prover and Programming Language." *CADE 28*.
   - Official Lean 4 system description
   - URL: https://leanprover.github.io/papers/lean4.pdf

8. **Avigad, J., & Moura, L. de** (2024). *Theorem Proving in Lean 4*.
   - Official tutorial for Lean 4
   - URL: https://leanprover.github.io/theorem_proving_in_lean4/

9. **Massot, P., & Commelin, J.** (2024). *Mathematics in Lean*.
   - Practical guide to formalizing mathematics in Lean
   - URL: https://leanprover-community.github.io/mathematics_in_lean/

#### Mathlib Documentation
10. **Mathlib Community.** (2024). *Mathlib4 Documentation*.
    - Complete API reference for mathlib4
    - URL: https://leanprover-community.github.io/mathlib4_docs/

11. **Mathlib Community.** (2024). *Contributing to Mathlib*.
    - Style guide and conventions
    - URL: https://leanprover-community.github.io/contribute/

### Online Resources

#### LEAN Community
12. **Lean Zulip Chat**
    - Active community forum for Lean questions
    - URL: https://leanprover.zulipchat.com/

13. **Lean 4 API Documentation**
    - Core Lean 4 API
    - URL: https://leanprover.github.io/doc/

#### Modal Logic Resources
14. **Stanford Encyclopedia of Philosophy: Modal Logic**
    - Comprehensive philosophical overview
    - URL: https://plato.stanford.edu/entries/logic-modal/

15. **Internet Encyclopedia of Philosophy: Modal Logic**
    - Alternative philosophical perspective
    - URL: https://iep.utm.edu/modal-logic/

### Project-Specific References

#### Logos Project Documentation
16. **Architecture Document**
    - `Documentation/UserGuide/ARCHITECTURE.md`
    - System-level architecture and component organization

17. **LEAN Style Guide**
    - `Documentation/Development/LEAN_STYLE_GUIDE.md`
    - Project coding conventions

18. **Tactic Development Guide**
    - `Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md`
    - How to implement custom tactics for TM logic

19. **Implementation Status**
    - `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
    - Current status of proof completeness

20. **Soundness Proof Implementation**
    - `Logos/Core/Metalogic/Soundness.lean`
    - Complete soundness proof for TM logic (14 axioms, 7 rules)

21. **Perpetuity Proofs Implementation**
    - `Logos/Core/Theorems/Perpetuity.lean`
    - All 6 perpetuity principles (P1-P6) fully proven

### Mathlib Module References

#### Logic Modules
22. `Mathlib.Logic.Basic` - Classical logic, decidability
23. `Mathlib.ModelTheory.Basic` - First-order model theory
24. `Mathlib.ModelTheory.Syntax` - First-order syntax

#### Analysis Modules
25. `Mathlib.Topology.Basic` - Topological spaces
26. `Mathlib.Topology.MetricSpace.Basic` - Metric spaces
27. `Mathlib.Analysis.Calculus.Deriv.Basic` - Derivatives
28. `Mathlib.MeasureTheory.Integral.Bochner` - Integration

#### Category Theory Modules
29. `Mathlib.CategoryTheory.Category.Basic` - Categories
30. `Mathlib.CategoryTheory.Functor.Basic` - Functors
31. `Mathlib.CategoryTheory.NatTrans` - Natural transformations

#### Linear Algebra Modules
32. `Mathlib.Algebra.Module.Basic` - Modules
33. `Mathlib.LinearAlgebra.Basic` - Linear maps
34. `Mathlib.LinearAlgebra.Basis` - Bases

---

## Appendix A: Top 10 Content Recommendations

Based on this research, here are the **top 10 most valuable** pieces of content to create:

### 1. `context/logic/standards/axiom-system-standard.md` ⭐⭐⭐⭐⭐
**Why:** Defines how to document every axiom in Logos. Template for all future logic work.
**Impact:** Prevents inconsistency errors, enables quick axiom addition
**ROI:** Every new axiom system benefits (epistemic, deontic, doxastic)

### 2. `context/logic/processes/modal-soundness-workflow.md` ⭐⭐⭐⭐⭐
**Why:** Most common proof type. Logos has proven soundness for TM logic, will need for extensions.
**Impact:** Reduces time to prove soundness from weeks to days
**ROI:** Immediate for S5 completion, epistemic extensions, temporal extensions

### 3. `context/logic/standards/kripke-semantics-standard.md` ⭐⭐⭐⭐⭐
**Why:** Semantic definitions are source of most type errors. Single source of truth.
**Impact:** Prevents definition mismatches, ensures all proofs use compatible semantics
**ROI:** Prevents 50% of debugging time on metalogic proofs

### 4. `context/logic/templates/modal-soundness-template.md` ⭐⭐⭐⭐
**Why:** Copy-paste template for each new axiom validity lemma.
**Impact:** Reduces axiom proof time from 30min to 5min
**ROI:** 14 axioms × 25min saved = 5.8 hours per logic system

### 5. `context/logic/patterns/axiom-application-pattern.md` ⭐⭐⭐⭐
**Why:** Most frequent tactic sequence in derivation proofs.
**Impact:** Quick reference during proof development
**ROI:** Used in 80%+ of Logos theorems

### 6. `context/logic/patterns/derivability-induction-pattern.md` ⭐⭐⭐⭐
**Why:** Core pattern for metalogic (soundness, consistency, decidability).
**Impact:** Template for proving properties of derivability
**ROI:** Every metalogic theorem uses this pattern

### 7. `context/logic/processes/temporal-duality-workflow.md` ⭐⭐⭐⭐
**Why:** Logos-specific pattern for TM logic. Past/future symmetry generates theorems automatically.
**Impact:** Doubles theorem library size with minimal effort
**ROI:** Perpetuity proofs P1-P6 all use duality

### 8. `context/logic/standards/proof-system-standard.md` ⭐⭐⭐
**Why:** Defines derivability relation conventions, context management.
**Impact:** Ensures consistent proof system across all modules
**ROI:** Foundation for all syntactic proof work

### 9. `context/math/analysis/epsilon-delta-patterns.md` ⭐⭐⭐
**Why:** If Logos extends to continuous models, analysis is needed.
**Impact:** Bridges logic and analysis (important for hybrid systems)
**ROI:** Future work on continuous-time semantics, probabilistic logic

### 10. `context/logic/processes/bimodal-interaction-workflow.md` ⭐⭐⭐
**Why:** TM logic is bimodal (modal + temporal). Interaction axioms (MF, TF) are unique.
**Impact:** Template for other bimodal/multi-modal systems
**ROI:** Directly applicable to epistemic-doxastic logic, deontic-temporal logic

---

## Appendix B: Directory-Specific Recommendations

### `context/logic/processes/` (12 files recommended)

**Core Files (Create First):**
1. `modal-soundness-workflow.md` - Soundness proof process
2. `modal-completeness-workflow.md` - Completeness proof process
3. `temporal-duality-workflow.md` - Past/future symmetry workflow
4. `bimodal-interaction-workflow.md` - Multi-modal axiom proofs

**Advanced Files (Create As Needed):**
5. `propositional-derivation-workflow.md` - Hilbert system proofs
6. `axiom-independence-workflow.md` - Proving axioms independent
7. `frame-characterization-workflow.md` - Finding frame conditions
8. `modal-embedding-workflow.md` - Translating between logics
9. `correspondence-theory-workflow.md` - Sahlqvist formulas
10. `hybrid-logic-workflow.md` - Adding nominals
11. `fixpoint-logic-workflow.md` - μ-calculus
12. `metalogic-verification-workflow.md` - Decidability, finite model property

**What to Put:**
- Step-by-step instructions with phase breakdown
- Validation criteria for each step
- Common pitfalls and solutions
- Cross-references to templates and standards
- Success checklists

---

### `context/logic/standards/` (10 files recommended)

**Core Files (Create First):**
1. `axiom-system-standard.md` - How to document axioms
2. `kripke-semantics-standard.md` - Semantic definitions
3. `proof-system-standard.md` - Derivability conventions
4. `formula-syntax-standard.md` - Syntax conventions

**Supporting Files (Create As Needed):**
5. `semantic-consequence-standard.md` - Defining ⊨
6. `model-construction-standard.md` - Canonical models
7. `complexity-measure-standard.md` - Formula complexity
8. `substitution-standard.md` - Variable substitution
9. `normal-form-standard.md` - CNF, DNF, NNF
10. `task-semantics-standard.md` - Logos-specific semantics

**What to Put:**
- Required components for definitions
- Naming conventions
- Examples of compliant definitions
- Cross-reference guidelines
- Success criteria checklists

---

### `context/logic/templates/` (8 files recommended)

**Core Files (Create First):**
1. `modal-soundness-template.md` - Axiom validity template
2. `completeness-template.md` - Completeness proof skeleton
3. `temporal-duality-template.md` - Duality derivation template

**Supporting Files (Create As Needed):**
4. `propositional-derivation-template.md` - Hilbert-style proofs
5. `frame-correspondence-template.md` - Axiom ↔ frame property
6. `decidability-proof-template.md` - Filtration method
7. `interpolation-proof-template.md` - Craig interpolation
8. `embedding-proof-template.md` - Logic translation

**What to Put:**
- LEAN code skeleton with placeholders
- Instantiation examples with placeholders filled
- Variations section
- Common pitfalls section

---

### `context/logic/patterns/` (12 files recommended)

**Core Files (Create First):**
1. `axiom-application-pattern.md` - Applying axiom schemas
2. `derivability-induction-pattern.md` - Induction on derivability
3. `semantic-unfolding-pattern.md` - Unfolding truth definitions
4. `frame-property-pattern.md` - Using reflexivity, transitivity, etc.

**Supporting Files (Create As Needed):**
5. `modal-k-distribution-pattern.md` - Distribution proofs
6. `necessitation-pattern.md` - Necessitation rule application
7. `contraposition-pattern.md` - Contrapositive proofs
8. `classical-reasoning-pattern.md` - Using `em`, `byContradiction`
9. `intermediate-lemma-pattern.md` - Using `have`
10. `case-analysis-pattern.md` - Cases on Formula
11. `substitution-pattern.md` - Safe substitution
12. `context-manipulation-pattern.md` - Weakening, exchange

**What to Put:**
- Tactic sequences with syntax
- When to use this pattern
- Variations (common modifications)
- Example usage from codebase

---

### `context/math/analysis/` (6 files recommended)

**Core Files (Create First):**
1. `epsilon-delta-patterns.md` - Limits and continuity
2. `calculus-derivatives.md` - Derivative computations
3. `measure-theory-basics.md` - Integration basics

**Supporting Files (Create As Needed):**
4. `functional-analysis-basics.md` - Banach/Hilbert spaces
5. `convergence-theorems.md` - Uniform/pointwise convergence
6. `topology-basics.md` - Open/closed sets, compactness

**What to Put:**
- Mathlib module references
- Common helper lemmas table
- Proof pattern examples
- Import strategy

---

### `context/math/category-theory/` (6 files recommended)

**Core Files (Create First):**
1. `category-basics.md` - Categories, functors, natural transformations
2. `functoriality-patterns.md` - Proving functor laws
3. `naturality-patterns.md` - Naturality squares

**Supporting Files (Create As Needed):**
4. `limits-colimits.md` - Universal constructions
5. `adjunctions.md` - Adjoint functors
6. `monoidal-categories.md` - Tensor products

**What to Put:**
- Core definition references
- Common pattern examples
- Mathlib module pointers
- Naturality diagram techniques

---

### `context/math/linear-algebra/` (7 files recommended)

**Core Files (Create First):**
1. `vector-space-basics.md` - Modules and linear maps
2. `dimension-theory.md` - Finite dimension, rank-nullity
3. `eigenvalues-eigenvectors.md` - Spectral theory

**Supporting Files (Create As Needed):**
4. `bilinear-forms.md` - Symmetric/alternating forms
5. `quotient-spaces.md` - Quotient vector spaces
6. `dual-spaces.md` - Dual vectors
7. `tensor-products.md` - Tensor product of modules

**What to Put:**
- Mathlib module imports
- Helper lemma tables
- Matrix-linear map conversions
- Basis manipulation techniques

---

## Appendix C: Implementation Priorities (Summary)

### Phase 1 (Weeks 1-2): Logic Context Core - CRITICAL ⭐⭐⭐⭐⭐
**Files:** 8 files (see Section 5.5)
**Rationale:** Immediate need for Logos theorem proving
**ROI:** 80% of value for logic development

### Phase 2 (Weeks 3-4): Mathematics Context - Analysis - MEDIUM ⭐⭐⭐
**Files:** 3-4 files
**Rationale:** Future continuous semantics work
**ROI:** 10% of value, but important for extensions

### Phase 3 (Weeks 5-6): Mathematics Context - Category Theory - LOWER ⭐⭐
**Files:** 2-3 files
**Rationale:** Helps with mathlib navigation
**ROI:** 5% of value, mostly educational

### Phase 4 (Weeks 7-8): Mathematics Context - Linear Algebra - LOWER ⭐⭐
**Files:** 2-3 files
**Rationale:** Potential algebraic logic work
**ROI:** 5% of value

### Phase 5 (Weeks 9-12): Remaining Logic Context - AS NEEDED ⭐
**Files:** 20+ files
**Rationale:** Fill gaps as development reveals needs
**ROI:** Incremental value

**Recommendation:** Focus on Phase 1 (logic context core) for maximum immediate impact.

---

**END OF REPORT**
