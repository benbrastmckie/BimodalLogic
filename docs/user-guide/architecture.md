# Proof-Checker Architecture Guide

_[Return to Project Overview](../../README.md)_

## Overview

This guide provides a comprehensive roadmap for developing an axiomatic proof system in LEAN, complete with model-theoretic semantics, metalogic, and axiom minimization utilities. The architecture is designed to support the full lifecycle from proof system definition to soundness verification and axiom optimization. Throughout this development, we integrate a domain-specific language (DSL) to enhance usability and provide intuitive interfaces for natural deduction theorem proving, semantic analysis, and axiom management.

For a quick start guide and usage examples, see the [Tutorial](tutorial.md) and [Examples](examples.md).

## 1. Proof System Construction in LEAN

### 1.1 Syntactic Framework

This proof-checker implements a **layered operator architecture** aligned with the Logos project's extension strategy. The architecture enables incremental expansion from a Core Layer through three semantic extensions—Explanatory, Epistemic, and Normative:

- **Layer 0 (Core Layer)**: Boolean, modal, and temporal operators with complete soundness and completeness proofs
- **Layer 1 (Explanatory Extension)**: Counterfactual, constitutive, and causal operators (future extension)
- **Layer 2 (Epistemic Extension)**: Belief, probability, and epistemic modal operators (future extension)
- **Layer 3 (Normative Extension)**: Obligation, permission, and preference operators (future extension)

The focus of this architecture guide is **Layer 0 (Core Layer)**, which provides the essential foundation for all subsequent extensions. Each extension layer can be added to the Core Layer independently or in combination before integrating into a complete system supporting all operator types. This layered approach provides conceptual clarity, enables parallel development, and allows delivery of verified reasoning capabilities incrementally while maintaining a clear path to the full Logos vision. These three extensions provide a basic methodology; future extensions may be added as needed.

The layered approach provides conceptual clarity, enables parallel development, and allows delivery of verified reasoning capabilities incrementally.

#### Layer 0 Language Definition (Core System TM)

The core language implements the bimodal logic TM (Tense and Modality) from the "Possible Worlds" paper with task semantics.

```lean
-- Layer 0: Core formula type with extensional, modal, and temporal operators
-- Language BL = ⟨SL, ⊥, →, □, allPast, allFuture⟩
inductive Formula : Type
  | atom : String → Formula                   -- Sentence letters (p_i)
  | bot : Formula                             -- Falsity (⊥)
  | imp : Formula → Formula → Formula         -- Material implication (→)
  | box : Formula → Formula                   -- Metaphysical necessity (□)
  | allPast : Formula → Formula              -- Universal past (H)
  | allFuture : Formula → Formula            -- Universal future (G)

-- Derived operators as abbreviations (not constructors)
def neg (φ : Formula) : Formula := φ.imp Formula.bot
def and (φ ψ : Formula) : Formula := neg (φ.imp (neg ψ))
def or (φ ψ : Formula) : Formula := (neg φ).imp ψ
def diamond (φ : Formula) : Formula := neg (Formula.box (neg φ))
def somePast (φ : Formula) : Formula := neg (Formula.allPast (neg φ))
def someFuture (φ : Formula) : Formula := neg (Formula.allFuture (neg φ))
-- 'always' is eternal truth: φ holds at all times (past, present, and future)
def always (φ : Formula) : Formula := (Formula.allPast φ).and (φ.and (Formula.allFuture φ))
-- 'sometimes' is dual of 'always': φ holds at some time (past, present, or future)
def sometimes (φ : Formula) : Formula := neg (always (neg φ))

-- Temporal duality: swap allPast and allFuture operators
def swapTemporal : Formula → Formula
  | Formula.atom p => Formula.atom p
  | Formula.bot => Formula.bot
  | Formula.imp φ ψ => (swapTemporal φ).imp (swapTemporal ψ)
  | Formula.box φ => (swapTemporal φ).box
  | Formula.allPast φ => (swapTemporal φ).allFuture
  | Formula.allFuture φ => (swapTemporal φ).allPast

-- DSL syntax support for more readable formula construction
syntax "atom" str : term
syntax "⊥" : term                             -- Falsity
syntax "~" term : term                        -- Negation
syntax term "&" term : term                   -- Conjunction
syntax term "|" term : term                   -- Disjunction
syntax term "->" term : term                  -- Implication
syntax "□" term : term                        -- Necessity
syntax "◇" term : term                        -- Possibility
syntax "H" term : term                        -- Universal past (allPast)
syntax "G" term : term                        -- Universal future (allFuture)
syntax "P" term : term                        -- Existential past (somePast)
syntax "F" term : term                        -- Existential future (someFuture)
syntax "always" term : term                   -- Always (at all times)
syntax "sometimes" term : term                -- Sometimes (at some time)
prefix:80 "△" => Formula.always               -- Triangle notation for always
prefix:80 "▽" => Formula.sometimes            -- Triangle notation for sometimes

-- Decidable equality for formulas
instance : DecidableEq Formula := by sorry

-- Formula complexity measure for structural induction
def Formula.complexity : Formula → Nat
  | Formula.atom _ => 1
  | Formula.bot => 1
  | Formula.imp φ ψ => φ.complexity + ψ.complexity + 1
  | Formula.box φ => φ.complexity + 1
  | Formula.allPast φ => φ.complexity + 1
  | Formula.allFuture φ => φ.complexity + 1
```

#### Layer 1 Language Extension (Future Work)

Layer 1 extends Layer 0 with counterfactual, constitutive, and causal operators requiring selection functions and grounding relations.

```lean
-- Layer 1: Extended formula type embedding Layer 0
inductive ExtendedFormula : Type
  | core : Formula → ExtendedFormula                               -- Embed Layer 0
  | boxright : ExtendedFormula → ExtendedFormula → ExtendedFormula -- Counterfactual (□→)
  | ground : ExtendedFormula → ExtendedFormula → ExtendedFormula   -- Grounding (≤)
  | cause : ExtendedFormula → ExtendedFormula → ExtendedFormula    -- Causation (○→)

-- Derived Layer 1 operators
def diamondright (φ ψ : ExtendedFormula) : ExtendedFormula :=
  neg (boxright φ (neg ψ))                                         -- Might counterfactual (◇→)
def essence (φ ψ : ExtendedFormula) : ExtendedFormula :=
  and (ground φ ψ) (neg (ground ψ φ))                              -- Essence (⊑)
def equiv_ground (φ ψ : ExtendedFormula) : ExtendedFormula :=
  and (ground φ ψ) (ground ψ φ)                                    -- Grounding equivalence (≡)

-- DSL syntax for Layer 1 operators
syntax term "□→" term : term                  -- Counterfactual
syntax term "◇→" term : term                  -- Might counterfactual
syntax term "≤" term : term                   -- Grounding
syntax term "⊑" term : term                   -- Essence
syntax term "≡" term : term                   -- Grounding equivalence
syntax term "○→" term : term                  -- Causation
```

#### Proof Context and Sequent Management
```lean
-- Proof context (theory context): set of formulas used as premises
-- Note: Throughout this file, "Context" refers specifically to proof context
-- (i.e., premises in proof theory), not semantic context or natural language context
def Context : Type := List Formula  -- Consider renaming to ProofContext for clarity

-- Sequent structure
structure Sequent :=
  (premises : Context)
  (conclusion : Formula)

notation Γ " ⊢ " φ => Sequent.mk Γ φ  -- Γ represents proof context

-- DSL support for sequent construction
syntax "sequent" "[" term,* "]" "|-" term : term
macro_rules
  | `(sequent [$premises,*] |- $conclusion) => `(Sequent.mk [$premises,*] $conclusion)
```

### 1.2 Inference Rules Definition

#### Primitive vs Derived Rules

The TM proof system uses two primitive inference rules that have unusual structure compared to standard modal logic:

**Primitive Inference Rules** (from the JPL paper):
- **MK (Modal K)**: If `Γ ⊢ φ` then `□Γ ⊢ □φ` - necessity distributes over entire derivations
- **TK (Temporal K)**: If `Γ ⊢ φ` then `FΓ ⊢ Fφ` - future distributes over entire derivations

These rules apply □ or F to the *entire context*, not just the conclusion. This is more general than the standard necessitation rule.

**Derived Rules and Axioms**:
- **Necessitation** (`⊢ φ` implies `⊢ □φ`): Derivable from MK with empty context (since `[].map box = []`)
- **Modal K Distribution** (`□(φ → ψ) → (□φ → □ψ)`): Derivable from MK + deduction theorem

The LEAN implementation includes both necessitation (as a constructor) and modal_k_dist (as an axiom) for convenience, but both are formally derivable from MK. This is documented in `Derivation.lean` with the `necessitation_from_modal_k` theorem.

#### Layer 1 Axiom System TM (Tense and Modality)

The proof system TM extends classical propositional logic with S5 modal axioms, temporal axioms, and bimodal interaction axioms.

```lean
-- Layer 1 Axiom schemata for system TM
inductive Axiom : Formula → Prop
  -- Note: Propositional tautologies assumed as base (classical propositional logic)

  -- S5 Modal Axioms
  | modal_t (φ : Formula) : Axiom (φ.box.imp φ)                    -- MT: `□φ → φ` (reflexivity)
  | modal_4 (φ : Formula) : Axiom (φ.box.imp φ.box.box)            -- M4: `□φ → □□φ` (transitivity)
  | modal_b (φ : Formula) : Axiom (φ.imp (diamond φ).box)          -- MB: `φ → □◇φ` (symmetry)

  -- Temporal Axioms
  | temp_4 (φ : Formula) :
      Axiom ((Formula.allFuture φ).imp (Formula.allFuture (Formula.allFuture φ)))  -- T4: `Gφ → GGφ`
  | temp_a (φ : Formula) :
      Axiom (φ.imp (Formula.allFuture (somePast φ)))                    -- TA: `φ → G(Pφ)`
  | temp_l (φ : Formula) :
      Axiom ((always φ).imp (Formula.allFuture (Formula.allPast φ)))    -- TL: `△φ → G(Hφ)`

  -- Bimodal Interaction Axioms
  | modal_future (φ : Formula) :
      Axiom (φ.box.imp (Formula.box (Formula.allFuture φ)))              -- MF: `□φ → □Gφ`
  | temp_future (φ : Formula) :
      Axiom (φ.box.imp (Formula.allFuture φ.box))                        -- TF: `□φ → G□φ`

-- Layer 1 Derivation trees for system TM
-- Note: DerivationTree is a Type (not Prop), enabling pattern matching and computable functions
inductive DerivationTree : Context → Formula → Type
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : DerivationTree Γ φ
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree Γ φ
  | modusPonens (Γ : Context) (φ ψ : Formula)
      (h1 : DerivationTree Γ (φ.imp ψ)) (h2 : DerivationTree Γ φ) : DerivationTree Γ ψ   -- MP
  | necessitation (Γ : Context) (φ : Formula)
      (h : DerivationTree (Γ.map Formula.box) φ) : DerivationTree Γ (φ.box)         -- MK: If `□Γ ⊢ φ` then `Γ ⊢ □φ`
  | temporalNecessitation (Γ : Context) (φ : Formula)
      (h : DerivationTree (Γ.map Formula.allFuture) φ) :
      DerivationTree Γ (Formula.allFuture φ)                                   -- TK: If `GΓ ⊢ φ` then `Γ ⊢ Gφ`
  | temporalDuality (φ : Formula)
      (h : DerivationTree [] φ) : DerivationTree [] (swapTemporal φ)               -- TD: If `⊢ φ` then `⊢ φ_{⟨H|G⟩}`
  | weakening (Γ Δ : Context) (φ : Formula)
      (h1 : DerivationTree Γ φ) (h2 : Γ ⊆ Δ) : DerivationTree Δ φ

-- Notation for derivation trees
notation Γ " ⊢ " φ => DerivationTree Γ φ
notation " ⊢ " φ => DerivationTree [] φ

-- Computable height function (enabled by Type vs Prop)
def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modusPonens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporalNecessitation _ d => 1 + d.height
  | .temporalDuality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

-- Perpetuity Principles (derived theorems in TM)
-- P1: `□φ → always φ` (what is necessary is always the case)
theorem perpetuity_1 (φ : Formula) : ⊢ (φ.box.imp (always φ)) := by sorry

-- P2: `sometimes φ → ◇φ` (what is sometimes the case is possible)
theorem perpetuity_2 (φ : Formula) : ⊢ ((sometimes φ).imp (diamond φ)) := by sorry

-- P3: `□φ → □always φ` (necessity of perpetuity)
theorem perpetuity3 (φ : Formula) : ⊢ (φ.box.imp ((always φ).box)) := by sorry

-- P4: `◇sometimes φ → ◇φ` (possibility of occurrence)
theorem perpetuity4 (φ : Formula) : ⊢ ((diamond (sometimes φ)).imp (diamond φ)) := by sorry

-- P5: `◇sometimes φ → always ◇φ` (persistent possibility)
theorem perpetuity5 (φ : Formula) : ⊢ ((diamond (sometimes φ)).imp (always (diamond φ))) := by sorry

-- P6: `sometimes □φ → □always φ` (occurrent necessity is perpetual)
theorem perpetuity6 (φ : Formula) : ⊢ ((sometimes φ.box).imp ((always φ).box)) := by sorry
```

**Status note**: This section sketches the target proof system from scratch for pedagogical
purposes; the `sorry` placeholders above are illustrative, not a live status report. This file is
a self-declared roadmap whose `Formula` type (6 constructors, `String` atoms) diverges from the
real `Syntax/Formula.lean` type, which is what makes this block schematic rather than stale. In
the actual implementation, all six perpetuity principles are complete and sorry-free — see
`FormalSystem/Theorems/Perpetuity/Principles.lean` (P1–P5) and
`FormalSystem/Theorems/Perpetuity/Principles.lean` (P6).

#### Derivation Trees: Type vs Prop

The TM proof system uses `DerivationTree : Context → Formula → Type` rather than a propositional 
`Derivable : Context → Formula → Prop`. This fundamental design choice provides several key advantages:

**Benefits of Type-Based Derivations:**

1. **Pattern Matching**: Structural induction on derivation trees is directly supported
2. **Computable Functions**: Functions like `height : DerivationTree Γ φ → Nat` can be defined
3. **Well-Founded Recursion**: Metalogical proofs can use derivation height as a termination measure
4. **Computational Content**: Derivation trees are data structures, not just existence proofs
5. **Proof Extraction**: Derivations can be analyzed, transformed, and optimized

**Example - Computing Derivation Height:**

The `height` function computes the depth of a derivation tree, which is impossible with `Prop`:

```lean
def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modusPonens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporalNecessitation _ d => 1 + d.height
  | .temporalDuality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height
```

**Example - Well-Founded Recursion:**

The deduction theorem uses well-founded recursion on derivation height:

```lean
theorem deductionTheorem (Γ : Context) (φ ψ : Formula) :
  (φ :: Γ) ⊢ ψ → Γ ⊢ (φ.imp ψ) := by
  intro d
  -- Induction on height of d (enabled by Type-based derivations)
  induction d using height.induct with
  | axiom => sorry
  | assumption => sorry
  | modusPonens => sorry
  -- ... other cases
```

**Trade-offs:**

- **Proof Irrelevance Lost**: Two derivations of the same formula are not automatically equal
- **Complexity**: Type-based derivations require more careful handling than Props
- **Benefits Outweigh Costs**: The ability to perform structural induction and compute properties 
  is essential for metalogical proofs

#### Layer 2 Axiom System (Future Work)

Layer 2 will extend TM with axioms for counterfactual, constitutive, and causal operators. The specific axiom schemata are to be determined based on the selection function and grounding relation semantics.

```lean
-- Layer 2 Extended axiom system (placeholder)
inductive ExtendedAxiom : ExtendedFormula → Prop
  -- Embed Layer 1 axioms
  | embed_core (φ : Formula) (h : Axiom φ) : ExtendedAxiom (ExtendedFormula.core φ)

  -- Counterfactual axioms (to be specified)
  | counterfactual_id (φ : ExtendedFormula) :
      ExtendedAxiom (boxright φ φ)                                         -- Counterfactual identity

  -- Grounding axioms (to be specified)
  -- Causal axioms (to be specified)
```

### 1.3 Basic Proof Infrastructure

#### Derived Rules and Tactics
```lean
-- Derived inference rules
theorem deductionTheorem (Γ : Context) (φ ψ : Formula) :
  (φ :: Γ) ⊢ ψ → Γ ⊢ (φ.imp ψ) := by
  sorry -- Implementation

theorem cut_rule (Γ : Context) (φ ψ : Formula) :
  Γ ⊢ φ → (φ :: Γ) ⊢ ψ → Γ ⊢ ψ := by
  sorry -- Implementation

-- Custom tactics for proof automation (DSL integration)
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply DerivationTree.axiom; apply $ax)

macro "mp" h1:ident h2:ident : tactic =>
  `(tactic| apply DerivationTree.modusPonens <;> [exact $h1; exact $h2])

-- DSL commands for common proof patterns
macro "assume" h:ident ":" p:term : tactic =>
  `(tactic| intro $h; have : $p := $h)

macro "by_contradiction" : tactic =>
  `(tactic| by_contra; exfalso)
```

## 2. Proof Automation and Ease of Use

### 2.1 Proof Builder Framework

#### High-Level Proof Construction
```lean
-- Proof builder monad for easier proof construction
structure ProofBuilder (α : Type) :=
  (context : Context)
  (goal : Formula)
  (proof : Context → Formula → α)

-- DSL for high-level proof construction
syntax "proof" "goal" term "from" term "by" term : term
syntax "step" term "using" term : term
syntax "qed" : term

-- Proof steps with DSL support
inductive ProofStep
  | apply_axiom : String → ProofStep
  | apply_rule : String → List ProofStep → ProofStep
  | assume : Formula → ProofStep → ProofStep
  | discharge : Formula → ProofStep
  | dsl_step : String → ProofStep               -- For DSL commands

-- DSL syntax for proof step construction
syntax "apply" ident : term
syntax "assume" term : term
syntax "discharge" term : term

-- Proof verification
def verify_proof_steps (steps : List ProofStep) (Γ : Context) (φ : Formula) : 
  Option (Γ ⊢ φ) := by
  sorry -- Implementation
```

#### Tactic Library
```lean
-- Domain-specific tactics with DSL sugar
macro "modal_reasoning" : tactic =>
  `(tactic| 
    repeat (first | apply_axiom modal_k | apply_axiom modal_t | mp _ _))

macro "propositional_reasoning" : tactic =>
  `(tactic|
    repeat (first | apply_axiom prop1 | apply_axiom prop2 | apply_axiom prop3 | mp _ _))

-- DSL commands for specific logical domains
macro "solve_modal" : tactic => `(tactic| modal_reasoning; try assumption)
macro "solve_prop" : tactic => `(tactic| propositional_reasoning; try assumption)

-- Automated proof search for simple cases
def auto_prove (Γ : Context) (φ : Formula) (depth : Nat) : Option (Γ ⊢ φ) := by
  sorry -- Implement bounded proof search
```

### 2.2 Proof Database and Libraries

#### Theorem Registry
```lean
-- Theorem database
structure TheoremEntry :=
  (name : String)
  (statement : Context × Formula)
  (proof : Derivable statement.1 statement.2)
  (tags : List String)
  (dependencies : List String)

-- Global theorem registry
def theorem_registry : IO (Array TheoremEntry) := by
  sorry -- Load from file/database

-- Theorem lookup and application
def find_theorem (pattern : String) : IO (List TheoremEntry) := by
  sorry -- Pattern matching search

-- Automatic theorem application
def try_apply_theorems (Γ : Context) (φ : Formula) : 
  IO (Option (Γ ⊢ φ)) := by
  sorry -- Try applying known theorems
```

#### Proof Templates
```lean
-- Common proof patterns with DSL support
template classical_contradiction (φ : Formula) : 
  (φ.neg :: Γ) ⊢ ⊥ → Γ ⊢ φ := by
  sorry -- Proof by contradiction template

-- DSL for proof templates
syntax "template" ident "(" ident* ")" ":" term ":=" "by" tacticSeq : command
macro "proof_by_contradiction" f:ident : tactic =>
  `(tactic| apply classical_contradiction; intro; contradiction)

template induction_on_formula (P : Formula → Prop) :
  (∀ s, P (Formula.atom s)) →
  (∀ φ, P φ → P φ.neg) →
  (∀ φ ψ, P φ → P ψ → P (φ.and ψ)) →
  -- ... other cases
  (∀ φ, P φ) := by
  sorry -- Structural induction template
```

## 3. Model-Theoretic Semantics

### 3.1 Layer 1 Task Semantics

Layer 1 implements **task semantics** where possible worlds are functions from times to world states constrained by a task relation.

**Polymorphic Temporal Type**: The temporal structure is now polymorphic over any type `T` with a
`LinearOrderedAddCommGroup` instance, matching the JPL paper specification
(def:frame, possible_worlds.tex:2423-2451) that requires "a nontrivial totally ordered abelian
group T = ⟨T, +, ≤⟩". Standard instances include:
- `Int`: Discrete integer time (default, decidable)
- `Rat`: Dense rational time (infinitely divisible)
- `Real`: Continuous real time (complete, for physical systems)

#### Task Frame Structure

The temporal order is a **component of the frame**, not a type parameter — `def:frame` reads
`F = ⟨W, 𝔇, ⇒⟩`. Two structures express that: `FrameOver D` is the *fibre* over a fixed temporal
order and the sole declaration site of the frame axioms, and `TaskFrame` is the *total space*,
definitionally `Σ (D : TemporalOrder), FrameOver D`.

```lean
-- def:temporal-order, reified: a nontrivial totally ordered abelian group, as one object
structure TemporalOrder where
  carrier : Type
  [addCommGroup : AddCommGroup carrier] [linearOrder : LinearOrder carrier]
  [isOrderedAddMonoid : IsOrderedAddMonoid carrier] [nontrivial : Nontrivial carrier]

-- The fibre: frames over a FIXED temporal order. The frame axioms live here, once.
structure FrameOver (D : TemporalOrder) where
  WorldState : Type                                  -- Set of world states (W)
  TaskRel : WorldState → D → WorldState → Prop      -- Task relation (⇒)
  nullity_identity, comp, converse, serial, limit, spherical : ...

-- The total space: the temporal order is the field `Duration`
structure TaskFrame where
  Duration : TemporalOrder
  toFibre  : FrameOver Duration

-- Example: the fibre at the integers
#check FrameOver intOrder            -- frames whose duration order is ℤ
#check (FrameOver.trivialFrame : FrameOver (TemporalOrder.of Int))
```

Because `Duration` is a field, a property of the temporal order alone is an ordinary predicate on
a frame — which is what makes `def:frame-properties` (Discrete / Dense / Complete) sayable of a
frame rather than only of a carrier.

#### World Histories

A **world history** (possible world) is a function from a convex set of times to world states that respects the task relation. The convexity requirement matches JPL paper def:world-history (line 1849).

```lean
-- World history over task frame F (polymorphic over T)
structure WorldHistory (F : TaskFrame) where
  domain : F.Duration → Prop                                          -- Domain predicate X ⊆ T
  convex : ∀ x z, domain x → domain z →
    ∀ y, x ≤ y → y ≤ z → domain y                           -- X is convex (no temporal gaps)
  states : (t : F.Duration) → domain t → F.WorldState        -- τ : X → W
  respects_task : ∀ s t (hs : domain s) (ht : domain t),
    s ≤ t → F.TaskRel (states s hs) (t - s) (states t ht)  -- τ(s) ⇒_{t-s} τ(t)

-- Notation for world history evaluation
notation τ "(" t ")" => WorldHistory.states τ t
```

#### Task Model and Truth Evaluation

```lean
-- Layer 1: Task model extending task frame with valuation (polymorphic over T)
structure TaskModel (F : TaskFrame) where
  valuation : F.WorldState → String → Prop                   -- Which propositions hold at each state

-- Truth at model-history-time triple (polymorphic over T)
def TruthAt {F : TaskFrame}
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (ht : τ.domain t) : Formula → Prop
  | Formula.atom p =>
      M.valuation (τ.states t ht) p                          -- Atomic truth
  | Formula.bot =>
      False                                                   -- Falsity never true
  | Formula.imp φ ψ =>
      TruthAt M τ t ht φ → TruthAt M τ t ht ψ              -- Implication
  | Formula.box φ =>
      ∀ (σ : WorldHistory F) (hs : σ.domain t),
        TruthAt M σ t hs φ                                   -- Necessity: all histories at t
  | Formula.allPast φ =>
      ∀ (s : T) (hs : τ.domain s), s < t →
        TruthAt M τ s hs φ                                   -- Universal past (H)
  | Formula.allFuture φ =>
      ∀ (s : T) (hs : τ.domain s), t < s →
        TruthAt M τ s hs φ                                   -- Universal future (G)

notation M ", " τ ", " t " ⊨ " φ => TruthAt M τ t φ

-- Time-shift invariance (critical theorem for temporal reasoning)
theorem time_shift_preserves_truth {F : TaskFrame}
    (M : TaskModel F) (τ : WorldHistory F) (t : T) (Δ : T) (φ : Formula)
    (ht : τ.domain t) (ht' : (timeShift τ Δ).domain (t + Δ)) :
  TruthAt M τ t ht φ ↔ TruthAt M (timeShift τ Δ) (t + Δ) ht' φ := by sorry
```

#### Layer 2 Extended Task Semantics (Future Work)

Layer 2 extends task models with selection functions for counterfactuals and grounding relations for constitutive and causal operators.

```lean
-- Layer 2: Extended task model
structure ExtendedTaskModel (F : TaskFrame) extends TaskModel F where
  -- Counterfactual selection function
  counterfactual_selection : F.WorldState → Formula → Set (WorldHistory F)

  -- Grounding relation
  grounding_relation : F.WorldState → Formula → Formula → Prop

  -- Causal relation
  causal_relation : F.WorldState → Formula → Formula → Prop

  -- Selection function constraints (to be specified)
  -- Grounding relation constraints (to be specified)

-- Extended truth evaluation for Layer 2 operators
def extended_truth_at (M : ExtendedTaskModel F) (τ : WorldHistory F) (t : F.Time) :
  ExtendedFormula → Prop
  | ExtendedFormula.core φ =>
      TruthAt M.toTaskModel τ t φ                                         -- Embed Layer 1
  | ExtendedFormula.boxright φ ψ =>
      ∀ σ ∈ M.counterfactual_selection (τ(t)) (to_core_formula φ),
        extended_truth_at M σ t ψ                                          -- Counterfactual
  | ExtendedFormula.ground φ ψ =>
      M.grounding_relation (τ(t)) (to_core_formula φ) (to_core_formula ψ) -- Grounding
  | ExtendedFormula.cause φ ψ =>
      M.causal_relation (τ(t)) (to_core_formula φ) (to_core_formula ψ)    -- Causation
```

### 3.2 Logical Consequence

#### Layer 1 Validity and Consequence Relations

```lean
-- Global validity (truth at all history-time pairs in all task models)
def valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    M, τ, t ⊨ φ

-- Local validity (truth at all history-time pairs in a specific model)
def valid_in_model (M : TaskModel F) (φ : Formula) : Prop :=
  ∀ (τ : WorldHistory F) (t : F.Time), M, τ, t ⊨ φ

-- Semantic consequence
def SemanticConsequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    (∀ ψ ∈ Γ, M, τ, t ⊨ ψ) → M, τ, t ⊨ φ

notation Γ " ⊨ " φ => SemanticConsequence Γ φ
notation " ⊨ " φ => valid φ

-- Satisfiability
def satisfiable (Γ : Context) : Prop :=
  ∃ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    ∀ φ ∈ Γ, M, τ, t ⊨ φ

-- Semantic equivalence
def semantically_equivalent (φ ψ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    (M, τ, t ⊨ φ) ↔ (M, τ, t ⊨ ψ)
```

### 3.3 Semantic Model Construction

#### Layer 1 Canonical Model for Completeness

The canonical model construction uses **set-based** maximal consistent sets as world states and
the integers as times. The set-based approach is essential because maximal consistent sets are
typically infinite, while lists are finite.

```lean
-- List-based consistency (for finite derivations)
def Consistent (Γ : Context) : Prop := ¬(Γ ⊢ Formula.bot)

-- Set-based consistency (for canonical model)
def SetConsistent (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent L

def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (insert φ S)

-- Canonical world states are SET-based maximal consistent sets
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}

-- Canonical task frame for TM (set-based)
def canonical_frame : TaskFrame := {
  WorldState := CanonicalWorldState,  -- Set-based, not list-based
  Time := ℤ,
  time_group := Int.orderedAddCommGroup,
  TaskRel := λ S n T =>
    -- Define task relation via set membership
    (∀ φ, □φ ∈ S.val → φ ∈ T.val) ∧           -- Modal transfer
    (n > 0 → ∀ φ, Fφ ∈ S.val → φ ∈ T.val) ∧   -- Future transfer
    (n < 0 → ∀ φ, Pφ ∈ S.val → φ ∈ T.val),    -- Past transfer
  nullity := sorry,
  compositionality := sorry
}

-- Canonical model for completeness proof
def canonical_model : TaskModel canonical_frame := {
  valuation := λ p => {S : CanonicalWorldState | Formula.atom p ∈ S.val}
}

-- Canonical history construction from set-based maximal consistent set
def canonical_history (S : CanonicalWorldState) :
  WorldHistory canonical_frame := by
  sorry -- Construct history where each time maps to a maximal consistent set

-- Modal saturation lemma for canonical model (set-based)
lemma modal_saturation (S : CanonicalWorldState) (φ : Formula) :
  (diamond φ) ∈ S.val → ∃ T : CanonicalWorldState, φ ∈ T.val := by
  sorry

-- Temporal consistency lemma (set-based)
lemma temporal_consistency (S : CanonicalWorldState) (ψ : Formula) :
  (Formula.allFuture ψ) ∈ S.val →
  SetConsistent ({ψ} ∪ {χ | Formula.allFuture χ ∈ S.val} ∪ {φ | (somePast φ) ∈ S.val}) := by
  sorry
```

**Why Set-Based?** Maximal consistent sets contain every formula or its negation.
Since there are infinitely many formulas, these sets are infinite and cannot be
represented as finite lists. The set-based `set_lindenbaum` theorem (proven using
Zorn's lemma) ensures every consistent set can be extended to a maximal one.

## 4. Metalogical Properties

### 4.1 Layer 1 Soundness

The soundness theorem proves that every TM-derivable formula is valid over all task semantic models.

#### Soundness Theorem

```lean
-- Main soundness theorem for TM
-- Proven by structural induction on derivation trees (enabled by DerivationTree being a Type)
theorem soundness (Γ : Context) (φ : Formula) :
  Γ ⊢ φ → Γ ⊨ φ := by
  intro h
  -- Pattern match on the derivation tree structure
  induction h with
  | axiom Γ φ hax =>
    intro F M τ t hΓ
    cases hax with
    | modal_t φ => sorry -- Prove MT valid: `□φ → φ`
    | modal_4 φ => sorry -- Prove M4 valid: `□φ → □□φ`
    | modal_b φ => sorry -- Prove MB valid: `φ → □◇φ`
    | temp_4 φ => sorry -- Prove T4 valid: `Future φ → Future Future φ`
    | temp_a φ => sorry -- Prove TA valid: `φ → Future past φ`
    | temp_l φ => sorry -- Prove TL valid: `always φ → Future Past φ`
    | modal_future φ => sorry -- Prove MF valid: `□φ → □Future φ`
    | temp_future φ => sorry -- Prove TF valid: `□φ → Future □φ`
  | assumption Γ φ h_in =>
    intro F M τ t hΓ
    exact hΓ φ h_in
  | modusPonens Γ φ ψ h1 h2 ih1 ih2 =>
    intro F M τ t hΓ
    have h_imp := ih1 F M τ t hΓ
    have h_ant := ih2 F M τ t hΓ
    exact h_imp h_ant
  | necessitation Γ φ h ih =>
    intro F M τ t hΓ
    intro σ
    apply ih F M σ t
    intro ψ h_in
    sorry -- Show □ψ ∈ Γ implies ψ true at σ
  | temporalNecessitation Γ φ h ih =>
    intro F M τ t hΓ
    intro s h_gt
    apply ih F M τ s
    sorry -- Show Gψ ∈ Γ implies ψ true at future times
  | temporalDuality φ h ih =>
    intro F M τ t hΓ
    sorry -- Use time-shift invariance and temporal symmetry
  | weakening Γ Δ φ h1 h2 ih =>
    intro F M τ t hΔ
    apply ih F M τ t
    intro ψ h_in
    exact hΔ ψ (h2 h_in)

-- Axiom validity lemmas (to be proven separately)
lemma modal_t_valid (φ : Formula) : valid (φ.box.imp φ) := by sorry
lemma modal_4_valid (φ : Formula) : valid (φ.box.imp φ.box.box) := by sorry
lemma modal_b_valid (φ : Formula) : valid (φ.imp (diamond φ).box) := by sorry
lemma temp_4_valid (φ : Formula) : valid ((Formula.allFuture φ).imp (Formula.allFuture (Formula.allFuture φ))) := by sorry
lemma temp_a_valid (φ : Formula) : valid (φ.imp (Formula.allFuture (somePast φ))) := by sorry
lemma temp_l_valid (φ : Formula) : valid ((always φ).imp (Formula.allFuture (Formula.allPast φ))) := by sorry
lemma modal_future_valid (φ : Formula) : valid (φ.box.imp (Formula.box (Formula.allFuture φ))) := by sorry
lemma temp_future_valid (φ : Formula) : valid (φ.box.imp (Formula.allFuture φ.box)) := by sorry

-- Derived soundness corollaries
corollary valid_if_provable (φ : Formula) : ⊢ φ → ⊨ φ := by
  intro h
  exact soundness [] φ h

corollary consistent_if_satisfiable (Γ : Context) :
  satisfiable Γ → consistent Γ := by
  sorry -- Contrapositive of soundness
```

### 4.2 Layer 1 Completeness

The completeness theorem proves that every valid formula is TM-derivable using canonical model
construction with **set-based** maximal consistent sets.

#### Completeness Theorem

```lean
-- Set-based Lindenbaum's Lemma (PROVEN using Zorn's lemma)
-- This is the key result enabling completeness
theorem set_lindenbaum (S : Set Formula) (hS : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M := by
  -- Apply Zorn's lemma to ConsistentSupersets S
  -- Chain union consistency: consistent_chain_union
  -- Upper bound exists for every chain
  -- Proven in FormalSystem/Metalogic/Core/MaximalConsistent.lean:303,
-- via consistent_chain_union (:264). NOT in an archived Completeness.lean.

-- Truth lemma for canonical model (key completeness lemma, set-based)
-- States: φ ∈ S.val ↔ TruthAt canonical_model (canonical_history S) 0 φ
lemma truth_lemma (S : CanonicalWorldState) (φ : Formula) :
  φ ∈ S.val := by  -- Placeholder for full biconditional
  -- By induction on formula structure:
  -- atom: By definition of canonical_valuation
  -- bot: ⊥ ∉ S by SetConsistent
  -- imp: By set-based maximal consistent implication property
  -- box: By modal saturation for set-based maximal consistent sets
  -- allPast/allFuture: By temporal consistency properties
  sorry

-- Weak completeness: valid implies provable
theorem weak_completeness (φ : Formula) :
  valid φ → DerivationTree [] φ := by
  -- Proof sketch:
  -- 1. Assume valid φ but ¬(⊢ φ)
  -- 2. {¬φ} is consistent (else would derive φ)
  -- 3. By set_lindenbaum, extend to SetMaximalConsistent M with ¬φ ∈ M
  -- 4. Build canonical model with world state M
  -- 5. By truth lemma, ¬φ true at M, so φ false
  -- 6. Contradicts validity of φ
  sorry

-- Strong completeness: semantic consequence implies derivability
theorem strong_completeness (Γ : Context) (φ : Formula) :
  SemanticConsequence Γ φ → DerivationTree Γ φ := by
  -- Proof sketch:
  -- 1. Assume Γ ⊨ φ but ¬(Γ ⊢ φ)
  -- 2. contextToSet(Γ) ∪ {¬φ} is SetConsistent
  -- 3. By set_lindenbaum, extend to SetMaximalConsistent M
  -- 4. Build canonical model with world state M
  -- 5. By truth lemma, all of Γ true at M but φ false
  -- 6. Contradicts semantic consequence
  sorry
```

**Key Implementation Note**: The `set_lindenbaum` theorem is fully proven using Zorn's lemma
from Mathlib, at `FormalSystem/Metalogic/Core/MaximalConsistent.lean:303`. The proof relies on
`consistent_chain_union` (`:264`), which shows that the union of a chain of consistent sets is
consistent.

### 4.2a The set-based consequence layer

The sketches above are pedagogical. The **actual** set-based consequence layer lives in
`FormalSystem/Metalogic/SetConsequence.lean`, and its shape matters because it is where the
distinction between consequence completeness and *strong* completeness is made precise.

| Item | Location | What it is |
|------|----------|------------|
| `SetConsistent` | `Core/MaximalConsistent.lean:96` | Consistency of a possibly-infinite set, **finitary**: no finite sublist derives `⊥` |
| `SetMaximalConsistent` | `Core/MaximalConsistent.lean:103` | Maximality of such a set |
| `set_lindenbaum` | `Core/MaximalConsistent.lean:303` | Every `SetConsistent` set extends to a `SetMaximalConsistent` one |
| `not_setConsistent_of_setDerivable_bot` | `SetConsequence.lean:280` | The bridge from set-derivability of `⊥` back to inconsistency |
| `StrongCompletenessBase` | `SetConsequence.lean:306` | The strong-completeness statement for Base -- **proved**, as `Compactness.lean`'s `strongCompletenessBase` |
| `CompactBase` | `SetConsequence.lean:314` | Semantic compactness of the Base consequence relation -- **proved**, as `compactBase` |
| `ModelExistenceBase` | `SetConsequence.lean:335` | Finite satisfiability lifts to satisfiability -- **proved**, as `modelExistenceBase` |
| `StrongCompletenessDense` | `SetConsequence.lean:352` | The Dense statement -- **proved**, as `strongCompletenessDense` |
| `CompactDense` | `SetConsequence.lean:359` | Semantic compactness for Dense -- **proved**, as `compactDense` |
| `ModelExistenceDense` | `SetConsequence.lean:379` | The Dense model-existence statement -- **proved**, as `modelExistenceDense` |

Two reductions sit on top: `strongCompletenessBase_of_compact` and
`strongCompletenessDense_of_compact` reduce each strong-completeness statement to its
compactness hypothesis alone. `FormalSystem/Metalogic/Compactness.lean` discharges that
hypothesis and instantiates both, so Base and Dense strong completeness hold unconditionally.
The construction runs through model existence: given a finitely satisfiable `Γ`, index the
finite sublists of `Γ`, take an ultrafilter on that index type for which each `ψ ∈ Γ` is
eventually a member, and build the ultraproduct of the models the finite fragments already
have; Łoś's theorem reads truth at the ultraproduct off eventual truth along the family.

The set-based MCS layer is therefore already in place; the missing substantive piece is a
**model-existence** theorem -- every `SetConsistent` set is satisfiable in a frame of the class
-- which does *not* follow from the single-formula countermodel engines. See
[known-limitations.md](../project-info/known-limitations.md), Limitation 1.

### 4.2b The four frame classes and their partial order

Everything above is relative to a **frame class**. There are four, and they form a partial
order rather than a flat list:

```
              Dedekind
                 ↑
    Dense --------'      Discrete
      ↑                     ↑
       \___________________/
                |
               Base
```

- **`Base`** is the bottom element: its 37 axioms are valid on all linear temporal orders.
- **`Dense`** extends Base with `density` (`GGφ → Gφ`) and `dense_indicator` (`¬U(⊤,⊥)`).
- **`Discrete`** extends Base with `prior_UZ`, `prior_SZ` and `z1`, valid on discrete
  (successor-Archimedean) frames.
- **`Dedekind`** extends **Dense** with Reynolds's definable-gap axioms `prior_U_gap`,
  `prior_S_gap` and `sep`.

**Why Dedekind sits above Dense rather than being a fourth incomparable leaf.** This is a
primary-source placement, not an intuition. Reynolds 1992 (printed p.168) lists axioms for
density and no end points as part of the axiomatization US/R for real flow. Unfolding
`K⁺⊤ = ¬U(⊤,¬⊤)` and normalising gives `¬U(⊤,⊥)` -- this tree's `dense_indicator`. So
Reynolds's real-line axiom set genuinely contains the density axiom, and a Dedekind derivation
must be allowed to use it. Making `Dedekind` a fresh incomparable leaf would render `density`
and `dense_indicator` inadmissible in a `Dedekind` derivation, and so could not host Reynolds's
system at all.

Dense and Discrete are incomparable (density contradicts discreteness); so are Discrete and
Dedekind.

**The governing invariant** is `ax.minFrameClass ≤ fc`
(`FormalSystem/ProofSystem/Axioms.lean:588`): an axiom may appear in a derivation parameterized
by frame class `fc` only when its minimum frame class is at most `fc`. This single constraint
replaces the ad-hoc predicates an earlier design used.

**The TM⁺_c gap.** The paper's TM⁺_c is completeness *simpliciter* -- no density binder -- so
its models are exactly `{ℤ, ℝ}` up to order-and-group isomorphism, and its theory is
`Th(ℤ) ∩ Th(ℝ)`. **No element of `FrameClass` picks that class out.** The two branches are
covered separately and exhaustively: the complete-but-discrete branch is exactly `ℤ` and is
handled by `Discrete`; the dense branch is `Dedekind`. But their *intersection* is not itself a
frame class, and adding one would require an axiom set for `Th(ℤ) ∩ Th(ℝ)` that this tree does
not have. `ValidDedekind` exists as a predicate matching the TM⁺_c binder set, but is
deliberately not a soundness target.

**Soundness caveat.** Because `density` and `dense_indicator` are admissible at `Dedekind` and
both are false on `ℤ` (which is nonetheless conditionally complete), the soundness theorem for
that class targets the *dense* Dedekind predicate `ValidDedekindDense`, not `ValidDedekind`.

### 4.2c Dedekind completeness and the real line

`completeness_dedekind` (`FormalSystem/Metalogic/StrongCompleteness.lean:469`) is the fourth
weak completeness theorem, and the one that reaches the real line:

| Theorem | Location |
|---------|----------|
| `completeness_dedekind` | `StrongCompleteness.lean:469` |
| `consequence_completeness_dedekind` | `StrongCompleteness.lean:450` |

The semantic target is `ValidDedekindDense`, whose binder list is a linearly ordered
`AddCommGroup` that is densely ordered, nontrivial, and Dedekind complete (every nonempty
bounded-above set has a least upper bound). Provenance is Reynolds 1992, section 9 Theorem 7 --
a *weak* completeness result for the real-line axiomatisation. The construction route runs
through `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/` (Reynolds sections 6 and 7,
supplying the two hypotheses of Doets' theorem) and
`FormalSystem/Metalogic/WeakCanonical/RealModel/` (section 8, Doets' theorem itself).

### 4.3 Additional Metalogical Properties

#### Decidability and Complexity
```lean
-- Decision procedure for specific fragments
def decide_formula (φ : Formula) (depth : Nat) : Bool := by
  sorry -- Implement decision procedure

-- Complexity bounds
theorem decision_complexity (φ : Formula) :
  ∃ n, decide_formula φ n = true ↔ valid φ := by
  sorry -- Prove decidability and complexity

-- Cut elimination
theorem cut_elimination (Γ : Context) (φ : Formula) :
  Γ ⊢ φ → ∃ (proof : Γ ⊢ φ), cut_free proof := by
  sorry -- Prove cut elimination
```

#### Interpolation
```lean
-- Craig interpolation
theorem craig_interpolation (φ ψ : Formula) :
  valid (φ.imp ψ) → 
  ∃ χ, (valid (φ.imp χ) ∧ valid (χ.imp ψ) ∧ 
        χ.atoms ⊆ φ.atoms ∩ ψ.atoms) := by
  sorry -- Prove interpolation theorem
```

## 5. Axiom System Minimization

### 5.1 Theorem Analysis Framework

#### Theorem Classification
```lean
-- Theorem dependency graph
structure DependencyGraph :=
  (theorems : Set Formula)
  (dependencies : Formula → Set Formula)
  (proves : Formula → Formula → Prop)

-- Axiom independence
def independent_of (φ : Formula) (Γ : Context) : Prop :=
  ¬(Γ.filter (· ≠ φ) ⊢ φ)

def axiom_set_independent (Γ : Context) : Prop :=
  ∀ φ ∈ Γ, independent_of φ Γ

-- Axiom set completeness for a target theory
def complete_for_theorems (axioms target_theorems : Context) : Prop :=
  ∀ φ ∈ target_theorems, axioms ⊢ φ
```

### 5.2 Minimization Algorithms

#### Base Minimization Algorithm
```lean
-- Greedy axiom removal with DSL commands
def minimize_axioms (initial_axioms target_theorems : Context) : 
  IO Context := do
  let mut current_axioms := initial_axioms
  for axiom in initial_axioms do
    let reduced := current_axioms.filter (· ≠ axiom)
    if complete_for_theorems reduced target_theorems then
      current_axioms := reduced
  return current_axioms

-- DSL for axiom minimization operations
syntax "minimize" term "for" term : term
syntax "check_minimal" term "against" term : term

-- Exhaustive search for minimal sets
def find_minimal_axiom_sets (candidates target_theorems : Context) :
  IO (List Context) := do
  let mut minimal_sets : List Context := []
  -- Try all subsets in order of increasing size
  for size in [1:candidates.length + 1] do
    for subset in candidates.choose size do
      if complete_for_theorems subset target_theorems then
        if ¬(minimal_sets.any (λ s => s ⊆ subset ∧ s ≠ subset)) then
          minimal_sets := subset :: minimal_sets.filter (λ s => ¬(subset ⊆ s))
  return minimal_sets
```

#### Advanced Minimization Techniques
```lean
-- Dependency-based reduction
def dependency_based_minimization (axioms target_theorems : Context) :
  IO Context := do
  let dep_graph := build_dependency_graph axioms target_theorems
  let essential := find_essential_axioms dep_graph target_theorems
  let reduced := remove_redundant_axioms dep_graph axioms essential
  return reduced

-- Machine learning guided search
def ml_guided_minimization (axioms target_theorems : Context) :
  IO Context := do
  let features := extract_axiom_features axioms
  let importance_scores := predict_axiom_importance features target_theorems
  let ranked_axioms := axioms.sortBy importance_scores
  return greedy_selection ranked_axioms target_theorems

-- Proof complexity optimization
def minimize_by_proof_complexity (axioms target_theorems : Context) :
  IO Context := do
  let proof_lengths := compute_average_proof_lengths axioms target_theorems
  return optimize_for_short_proofs axioms target_theorems proof_lengths
```

### 5.3 Validation and Analysis

#### Axiom Set Validation
```lean
-- Verify axiom set properties
def validate_axiom_set (axioms target_theorems : Context) : 
  IO ValidationReport := do
  let completeness_check := verify_completeness axioms target_theorems
  let independence_check := verify_independence axioms
  let minimality_check := verify_minimality axioms target_theorems
  return {
    complete := completeness_check,
    independent := independence_check,
    minimal := minimality_check,
    proof_statistics := compute_proof_statistics axioms target_theorems
  }

structure ValidationReport :=
  (complete : Bool)
  (independent : Bool) 
  (minimal : Bool)
  (proof_statistics : ProofStatistics)

structure ProofStatistics :=
  (average_proof_length : Float)
  (max_proof_length : Nat)
  (total_axiom_uses : Nat)
  (axiom_usage_distribution : List (Formula × Nat))
```

## 6. Implementation Architecture

### 6.1 Project Structure

The project structure reflects the layered operator architecture following LEAN 4 community standards with PascalCase directories:

```
FormalSystem.lean                          # Library root (re-exports public API)
FormalSystem/                              # Main source directory
├── Syntax/
│   ├── Formula.lean                       # Core formula inductive type (untl/snce primitive)
│   ├── Atom.lean                          # Atomic propositions
│   ├── Context.lean                       # Proof context management (List Formula)
│   ├── Subformulas.lean                   # Subformula extraction
│   └── SubformulaClosure/                 # Closure construction
├── ProofSystem/
│   ├── Axioms.lean                        # TM axiom schemata (45 constructors, 4 layers)
│   ├── Derivable.lean                     # Derivability relation
│   └── Derivation.lean                    # DerivationTree (7 inference rules)
├── BaseLanguage/                          # Second object language (tense-primitive)
│   ├── Formula.lean
│   ├── Axioms.lean
│   ├── Derivation.lean
│   ├── Translation.lean                   # Translation into the primary language
│   └── AxiomDischarge.lean
├── Semantics/
│   ├── TaskFrame.lean                     # Task frame structure
│   ├── WorldHistory.lean                  # World history definition
│   ├── TaskModel.lean                     # Task model with valuation
│   ├── Truth.lean                         # Truth evaluation
│   ├── BLTruth.lean                       # Native truth evaluation for the base language
│   ├── Validity.lean                      # Validity and consequence
│   ├── BLValidity.lean                    # Base-language validity predicates
│   └── Extension/                         # Semantic extension layer
├── Metalogic/
│   ├── Soundness.lean                     # Soundness theorem
│   ├── SoundnessLemmas.lean               # Bridge lemmas
│   ├── Core/                              # MCS layer, deduction theorem, Lindenbaum
│   ├── Bundle/                            # FMCS / BFMCS bundle construction
│   ├── BXCanonical/                       # Canonical model; the three completeness theorems
│   ├── WeakCanonical/                     # Countermodel engines
│   ├── Algebraic/                         # Flow-frame infrastructure
│   ├── StrongCompleteness.lean            # Dedekind completeness; terminology discipline
│   ├── SetConsequence.lean                # Set-based consequence; CompactBase/CompactDense
│   ├── Compactness.lean                   # Their ultraproduct discharge; Base/Dense strong completeness
│   ├── DiscreteNonCompactness.lean        # Refutation of Discrete strong completeness
│   ├── Conservativity.lean                # TM/TM+ backward bridge
│   ├── BaseLanguageSoundness.lean         # BL soundness by composition; the truth-transfer bridge
│   ├── Independence/                      # Independence results
│   └── Decidability/                      # Tableau decision procedure
├── Theorems/
│   ├── Perpetuity/                        # P1-P6 perpetuity principles
│   ├── ModalS4.lean, ModalS5.lean         # Modal theorem libraries
│   ├── Propositional/                     # Propositional theorem library
│   ├── TemporalDerived.lean               # Derived temporal theorems
│   └── DedekindDerived.lean
├── Automation/
│   ├── Tactics/                           # Custom tactics
│   └── ProofSearch/                       # Automated proof search
├── FrameConditions/                       # Frame condition definitions
├── Examples/                              # Pedagogical examples
└── Boneyard/                              # Archived material (excluded from all invariants)

Tests/BimodalTest/                         # Test suite
├── Syntax/, ProofSystem/, Semantics/      # Layer-aligned tests
├── Metalogic/, Theorems/, Automation/
├── Integration/                           # Integration tests
└── Property/                              # Property-based tests

docs/                                      # User documentation
lakefile.lean                              # Lake build configuration
lean-toolchain                             # Lean version pinning
```


### 6.2 Integration Points

#### Interface with Model-Checker
```lean
-- Export to model-checker format with DSL support
def export_to_model_checker (φ : Formula) : String := by
  sorry -- Convert to model-checker syntax

-- DSL command for model-checker integration
syntax "check_validity" term : command
syntax "find_countermodel" term : command

-- Import validation results
def import_validation_results (results : String) : 
  IO (List (Formula × Bool)) := by
  sorry -- Parse model-checker results

-- Coordinate proof and model checking
def verify_with_model_checker (Γ : Context) (φ : Formula) : 
  IO (Either String (Γ ⊢ φ)) := do
  if h : Γ ⊢ φ then
    return Either.right h
  else
    let model_result ← check_with_model_checker Γ φ
    if model_result.valid then
      let proof ← search_for_proof Γ φ
      return proof
    else
      return Either.left model_result.counterexample
```

#### Future Natural Language Interface

Logos's primary interface is LEAN 4 code for direct theorem proving and verification. Future work may explore natural language interfaces for making formal verification more accessible to domain experts, potentially integrating with external natural language processing systems to translate informal reasoning into formal proofs.

**Potential Interface Capabilities**:
- Natural language theorem statement translation to Formula syntax
- Informal proof sketch parsing to guide proof search
- Plain language counterexample explanations from model-checker results
- Domain-specific terminology mapping to formal operators

**Note**: Such interfaces would be external tools consuming Logos's API, not core components of the verification architecture.

```lean
-- Example: Generic inference verification API
def verify_inference (
  premises : Context)
  (conclusion : Formula) :
  IO InferenceResult := do
  if h : premises ⊢ conclusion then
    return InferenceResult.valid_proof h
  else
    let search_result ← bounded_proof_search premises conclusion
    match search_result with
    | some proof => return InferenceResult.found_proof proof
    | none =>
      let mc_result ← check_with_model_checker premises conclusion
      return InferenceResult.no_proof_found mc_result

structure InferenceResult :=
  (status : InferenceStatus)
  (proof : Option (Context → Formula → Prop))
  (counterexample : Option String)

inductive InferenceStatus
  | valid_proof
  | found_proof  
  | no_proof_found
  | invalid
```

### 6.3 Performance Optimization

#### Caching and Memoization
```lean
-- Proof cache for repeated queries
def proof_cache : IO (Cache (Context × Formula) (Option Proof)) := by
  sorry -- Initialize LRU cache

-- Memoized semantic evaluation
def memoized_truth_at : 
  Cache (Model × State × Formula) Bool → 
  Model → State → Formula → IO Bool := by
  sorry -- Memoized truth evaluation

-- Incremental proof checking
def incremental_check_derivation (
  cached_steps : List ProofStep)
  (new_steps : List ProofStep) : 
  IO ValidationResult := by
  sorry -- Only verify new steps
```

#### Parallel Processing
```lean
-- Parallel axiom independence checking
def parallel_independence_check (axioms : Context) : 
  IO (List (Formula × Bool)) := do
  let tasks := axioms.map (check_independence_async axioms)
  let results ← Task.waitAll tasks
  return results.zip axioms

-- Parallel proof search
def parallel_proof_search (Γ : Context) (φ : Formula) (strategies : List SearchStrategy) :
  IO (Option Proof) := do
  let tasks := strategies.map (λ s => search_with_strategy_async s Γ φ)
  let first_result ← Task.waitFirst tasks
  return first_result
```

## 7. Usage Examples

### 7.1 Layer 1 Basic Proof Construction

```lean
-- Example 1: Prove a modal tautology using MT axiom
example (P : Formula) : ⊢ (P.box.imp P) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Example 2: Prove a temporal tautology using TA axiom
example (P : Formula) : ⊢ (P.imp (Formula.allFuture (somePast P))) := by
  apply Derivable.axiom
  apply Axiom.temp_a

-- Example 3: Use modus ponens with assumptions
example (P Q : Formula) : [P.imp Q, P] ⊢ Q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption
    simp
  · apply Derivable.assumption
    simp
```

### 7.2 Perpetuity Principles

```lean
-- Example: Derive P1 (□φ → always φ) using MF, MT, TD
theorem derive_perpetuity_1 (φ : Formula) : ⊢ (φ.box.imp (always φ)) := by
  -- Step 1: □φ → □Gφ (from MF)
  have h1 : ⊢ (φ.box.imp (Formula.box (Formula.allFuture φ))) := by
    apply Derivable.axiom
    apply Axiom.modal_future
  -- Step 2: □Gφ → Gφ (from MT)
  have h2 : ⊢ ((Formula.box (Formula.allFuture φ)).imp (Formula.allFuture φ)) := by
    apply Derivable.axiom
    apply Axiom.modal_t
  -- Step 3: Combine to get □φ → Gφ
  have h3 : ⊢ (φ.box.imp (Formula.allFuture φ)) := by
    sorry -- Apply transitivity
  -- Step 4: By TD, get □φ → Hφ
  have h4 : ⊢ (φ.box.imp (Formula.allPast φ)) := by
    sorry -- Apply temporal duality to h3
  -- Step 5: Combine with MT to get always φ
  sorry

-- Example: Use P1 to derive consequence
example (P : Formula) : [P.box] ⊢ (always P) := by
  apply Derivable.modus_ponens
  · exact perpetuity_1 P
  · apply Derivable.assumption
    simp
```

### 7.3 Temporal Reasoning

```lean
-- Example: Reasoning with allFuture and allPast operators
example (P Q : Formula) :
  [Formula.allFuture P, Formula.allFuture Q] ⊢ Formula.allFuture (P.and Q) := by
  -- Use TK rule and propositional reasoning
  sorry

-- Example: Time-shift invariance application
example (P : Formula) (d : ℤ) :
  ⊢ (Formula.allFuture P) → ⊢ (Formula.allFuture P) := by
  intro h
  -- Apply time-shift invariance theorem
  sorry
```

### 7.4 Metalogical Analysis

```lean
-- Verify soundness for modal axiom MT
example (φ : Formula) : valid (φ.box.imp φ) := by
  apply modal_t_valid

-- Check strong completeness for example inference
example : [Formula.box (Formula.atom "P")] ⊨ Formula.atom "P" := by
  intro F M τ t h_prem
  have h_box := h_prem (Formula.box (Formula.atom "P")) (by simp)
  -- Apply MT validity
  sorry

-- Verify TM-consistency of formula set
#eval consistent [Formula.atom "P", Formula.allFuture (Formula.atom "Q")]
```

### 7.5 Layer 2 Extension Examples (Future Work)

```lean
-- Example: Counterfactual reasoning (Layer 2)
example (P Q : ExtendedFormula) :
  [ExtendedFormula.boxright P Q, ExtendedFormula.core (to_formula P)] ⊢
  ExtendedFormula.core (to_formula Q) := by
  sorry -- Requires Layer 2 axioms

-- Example: Grounding reasoning (Layer 2)
example (P Q : ExtendedFormula) :
  [ExtendedFormula.ground P Q] ⊢
  ExtendedFormula.imp (ExtendedFormula.core (to_formula P))
                      (ExtendedFormula.core (to_formula Q)) := by
  sorry -- Requires Layer 2 grounding axioms
```

## 8. Integration with Logos Architecture

Logos implements the Logos formal language of thought. For philosophical foundations and research context, see METHODOLOGY.md.

### Implementation Status

For detailed implementation status, see [implementation-status.md](../project-info/implementation-status.md).

### 8.1 Layer 0 (Core TM)

The current implementation provides Boolean, modal, and temporal operators with S5 modal logic and linear temporal logic.

### 8.2 Layers 1-3 Extensions

See Research/layer-extensions.md for specifications of planned extensions:
- Layer 1 (Explanatory): Counterfactual, constitutive, causal operators
- Layer 2 (Epistemic): Belief, probability, knowledge operators
- Layer 3 (Normative): Obligation, permission, preference operators

### 8.3 Dual Verification Architecture

See [Research/dual-verification.md](../research/DUAL_VERIFICATION.md) for RL training design combining proof-checker (syntactic verification) with model-checker (semantic verification).

### 8.4 Proof Library Architecture

See [Research/proof-library-design.md](../research/PROOF_LIBRARY_DESIGN.md) for theorem caching and pattern matching design.

### 8.5 Operator Layer Alignment

This section maps Logos operators to their Logos LEAN 4 implementations and underlying semantic systems.

**Core Layer (Layer 0) Operators**:

**Boolean Operators** (Extensional Logic):
- **Logos Operators**: `¬`, `∧`, `∨`, `→`, `↔`, `⊥`, `⊤`
- **Logos Implementation**: Defined operators from `⊥` and `→` (Formula.imp, Formula.bot)
- **Semantic System**: Classical propositional logic (base for TM)

**Modal Operators** (Metaphysical Modality):
- **Logos Operators**: `□` (necessity), `◇` (possibility)
- **Logos Implementation**: `□`, `◇` with S5 axioms (MT, M4, MB, MK) in ProofSystem/Axioms.lean
- **Semantic System**: S5 modal logic component of TM with task frame semantics

**Temporal Operators** (Linear Time):
- **Logos Operators**: `H`, `P`, `G`, `F` (past/future operators), `△` (always), `▽` (sometimes)
- **Logos Implementation**: `allPast`, `allFuture`, `somePast`, `someFuture`, `always`, `sometimes` in Syntax/Formula.lean
- **Semantic System**: Linear temporal logic component of TM with bimodal interaction axioms (MF, TF)

**Explanatory Extension (Layer 1) Operators** - Planned:

**Counterfactual Operators**:
- **Logos Operators**: `□→` (would counterfactual), `◇→` (might counterfactual)
- **Planned Implementation**: `boxright`, `diamondright` with selection functions
- **Semantic System**: Extension requiring counterfactual semantics with world similarity

**Constitutive Operators**:
- **Logos Operators**: `≤` (grounding), `⊑` (essence), `≡` (propositional identity)
- **Planned Implementation**: `ground`, `essence`, `equiv_ground` with grounding relations
- **Semantic System**: Extension requiring hyperintensional grounding semantics

**Causal Operators**:
- **Logos Operators**: `○→` (causation)
- **Planned Implementation**: `cause` with causal relations
- **Semantic System**: Extension requiring causal semantics with temporal production

#### Task Semantics Alignment

The proof-checker's task semantics provides the formal foundation for the model-checker's state-based verification:

- **World States**: Correspond to model-checker's possible states
- **Task Relation**: Models transitions between states (compatible with model-checker's task relations)
- **World Histories**: Functions from times to world states (formalize model-checker's temporal evolution)
- **Convexity**: Ensures world histories span continuous time intervals

This alignment enables **bidirectional verification**:
1. Model-checker finds satisfying models → Proof-checker verifies inference validity
2. Proof-checker derives theorems → Model-checker validates semantic correctness

### 8.6 Layered Development Strategy

The layered architecture provides clear development milestones:

**Layer 0 (Current Implementation)**:
- Complete language: Boolean + Modal + Temporal
- Complete proof system: TM with 45 axiom constructors and 7 inference rules
- Complete semantics: Task frames, world histories, truth evaluation
- Complete metalogic: full soundness proof over all 45 axiom constructors; weak completeness
  proven and sorryAx-free for all four frame classes (Base, Dense, Discrete, Dedekind).
  *Strong* completeness -- consequence from an arbitrary infinite premise set -- is a separate
  question with three distinct statuses across those classes
  (see [known-limitations.md](../project-info/known-limitations.md))
- **Delivers**: Verified reasoning for boolean, modal, and temporal logic

For current implementation status, see [implementation-status.md](../project-info/implementation-status.md).

**Layers 1-3 (Future Extensions)**:
- Extended languages: Explanatory, epistemic, normative operators
- Extended semantics: Selection functions, grounding relations, belief states
- Extended axioms: Layer-specific axiom schemata
- **Goal**: Progressive addition following phased roadmap

For extension specifications, see Research/layer-extensions.md.

**Benefits of Layered Approach**:
1. **Conceptual Clarity**: Separate core system from advanced operators
2. **Incremental Complexity**: Master simpler logic before adding complex operators
3. **Reusability**: Layer 0 serves as foundation for all extensions
4. **Debugging**: Isolate issues to specific operator layers
5. **Alignment**: Matches Logos project's phased operator introduction

## 9. Future Extensions

### 9.1 Advanced Features

- **Higher-order logic support**: Extend to quantifiers and higher-order reasoning with DSL syntax
- **Proof certificates**: Generate verifiable proof certificates for external checkers
- **Interactive theorem proving**: Web-based interface for collaborative proof development using DSL
- **Machine learning integration**: Use ML for proof strategy selection and axiom discovery
- **DSL evolution**: Continuously expand domain-specific language based on user patterns

### 9.2 Integration Enhancements

- **Real-time collaboration**: Multi-user proof development environment with shared DSL extensions
- **Version control**: Git-like versioning for proof development and DSL evolution
- **Proof visualization**: Graphical representation of proof trees with DSL command mapping
- **Educational tools**: Interactive tutorials and proof exercises using simplified DSL syntax
- **DSL customization**: User-defined syntax extensions for specific logical domains

### 9.3 Temporal Logic Extensions

The TM proof system can be extended with additional temporal axioms for specific time structures:

**Discreteness**:
- `DP` (discrete past): `(Future φ ∧ φ ∧ past ⊤) → past Future φ`
- `DF` (discrete future): `(Past φ ∧ φ ∧ future ⊤) → future Past φ`

**Boundedness**:
- `BP` (bounded past): `Past ⊥ ∨ past Past ⊥`
- `BF` (bounded future): `Future ⊥ ∨ future Future ⊥`

**Unboundedness**:
- `UP` (unbounded past): `past ⊤`
- `UF` (unbounded future): `future ⊤`

**Density**:
- `DN` (density): Axioms ensuring between any two times exists a third

These extensions allow the proof-checker to reason about different time structures (discrete vs continuous, bounded vs unbounded) while maintaining the core TM proof system.

---

This architecture provides a comprehensive foundation for developing a sophisticated axiomatic proof system in LEAN implementing the layered operator approach. Layer 0 delivers the foundational bimodal logic TM (Tense and Modality) for Boolean, modal, and temporal reasoning with task semantics and partial metalogic implementation. Layers 1-3 provide a clear extension path for counterfactual/constitutive/causal operators (Explanatory), belief/probability/knowledge operators (Epistemic), and deontic/preference/normative operators (Normative). The architecture implements progressive operator extensibility as a core principle, enabling domain-specific operator combinations while maintaining mathematical rigor. Logos integrates seamlessly with the Model-Checker component to create a comprehensive dual verification architecture for training AI systems.

---

**Related Documentation:**
- METHODOLOGY.md - Philosophical foundations
- [Tutorial](tutorial.md) - Getting started guide
- [Examples](examples.md) - Modal, temporal, and bimodal examples
- [implementation-status.md](../project-info/implementation-status.md) - Current progress
- Research/layer-extensions.md - Layers 1-3 specifications
- [Research/dual-verification.md](../research/DUAL_VERIFICATION.md) - RL training architecture
- [Research/proof-library-design.md](../research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [LEAN Style Guide](../development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Module Organization](../development/MODULE_ORGANIZATION.md) - Project structure
- [Integration Guide](INTEGRATION.md) - Model-Checker integration
- [Contributing](../development/CONTRIBUTING.md) - How to contribute

_Last updated: December 2025_
