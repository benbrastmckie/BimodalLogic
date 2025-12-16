# Logos Tutorial

This tutorial guides you through using Logos, a LEAN 4 proof system for the bimodal logic TM (Tense and Modality).

## 1. Getting Started

### Installation

#### Prerequisites
- LEAN 4 v4.14.0 or later
- Lake (included with LEAN 4)
- VS Code with lean4 extension (recommended)

#### Installing LEAN 4

```bash
# Install elan (LEAN version manager)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Verify installation
lean --version
lake --version
```

#### Setup Logos

```bash
# Clone the repository
git clone https://github.com/yourusername/Logos.git
cd Logos

# Build the project
lake build

# Verify with tests
lake test
```

#### VS Code Setup

1. Install the "lean4" extension from VS Code marketplace
2. Open the Logos directory in VS Code
3. Wait for Lake to build dependencies
4. You should see syntax highlighting and type information

### First Proof

Create a new file `MyFirstProof.lean`:

```lean
import Logos

open Logos.Syntax
open Logos.ProofSystem

-- Define a simple formula: □p → p
def my_formula : Formula := (Formula.atom "p").box.imp (Formula.atom "p")

-- Prove it using axiom MT
example : ⊢ my_formula := by
  apply Derivable.axiom
  apply Axiom.modal_t
```

Run `lake build` to verify the proof type-checks.

## 2. Basic Formulas

### Formula Construction

Formulas in TM logic are built from:

```lean
-- Atomic propositions
def p : Formula := Formula.atom "p"
def q : Formula := Formula.atom "q"

-- Falsity
def falsum : Formula := Formula.bot

-- Implication
def impl : Formula := p.imp q  -- `p → q`

-- Modal operators
def necessary_p : Formula := Formula.box p      -- `□p`
def possible_p : Formula := diamond p           -- `◇p` (defined as `¬□¬p`)

-- Temporal operators
def always_past : Formula := Formula.all_past p     -- Hφ (always in past)
def always_future : Formula := Formula.all_future p -- Gφ (always in future)
def always_p : Formula := p.always                  -- △φ (at all times: H ∧ present ∧ G)
def sometimes_p : Formula := p.sometimes            -- ▽φ (at some time: P ∨ present ∨ F)
def sometime_past_p : Formula := some_past p        -- Pφ (some time in past)
def sometime_future_p : Formula := some_future p    -- Fφ (some time in future)
```

### Derived Operators

```lean
-- Negation: `¬φ ≡ φ → ⊥`
def not_p : Formula := neg p

-- Conjunction: `φ ∧ ψ ≡ ¬(φ → ¬ψ)`
def p_and_q : Formula := and p q

-- Disjunction: `φ ∨ ψ ≡ ¬φ → ψ`
def p_or_q : Formula := or p q

-- Always (at all times): `△φ ≡ Hφ ∧ φ ∧ Gφ`
def always_φ : Formula := always p
def triangle_always : Formula := △p  -- Unicode triangle notation

-- Sometimes (at some time): `▽φ ≡ ¬△¬φ ≡ Pφ ∨ φ ∨ Fφ`
def sometimes_φ : Formula := sometimes p
def triangle_sometimes : Formula := ▽p  -- Unicode triangle notation
```

### Using DSL Syntax

With DSL macros enabled:

```lean
-- More readable formula construction
example : Formula := □"p"           -- `□p` (necessary p)
example : Formula := ◇"p"           -- `◇p` (possible p)
example : Formula := "p" → "q"      -- `p → q` (p implies q)
example : Formula := H "p"          -- Hφ (always in past)
example : Formula := G "p"          -- Gφ (always in future)
example : Formula := P "p"          -- Pφ (some past time)
example : Formula := F "p"          -- Fφ (some future time)
example : Formula := △"p"           -- `△p` (always p, at all times)
example : Formula := ▽"p"           -- `▽p` (sometimes p, at some time)
```

## 3. Proof Basics

### Proof Contexts

A proof context (premises) is a list of formulas:

```lean
-- Empty context (prove from axioms only)
def empty_ctx : Context := []

-- Context with premises
def with_premises : Context := [p, p.imp q]
```

### Derivability

The notation `Γ ⊢ φ` means "`φ` is derivable from premises `Γ`":

```lean
-- Derive from axioms (empty context)
example : [] ⊢ (p.box.imp p) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Derive from assumptions
example : [p] ⊢ p := by
  apply Derivable.assumption
  simp

-- Derive using modus ponens
example : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp
```

### Axiom Application

TM logic axioms can be applied directly:

```lean
-- S5 Modal Axioms
-- MT: `□φ → φ` (reflexivity)
example (φ : Formula) : ⊢ (φ.box.imp φ) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- M4: `□φ → □□φ` (transitivity)
example (φ : Formula) : ⊢ (φ.box.imp φ.box.box) := by
  apply Derivable.axiom
  apply Axiom.modal_4

-- MB: `φ → □◇φ` (symmetry)
example (φ : Formula) : ⊢ (φ.imp (diamond φ).box) := by
  apply Derivable.axiom
  apply Axiom.modal_b
```

### Inference Rules

```lean
-- Modus Ponens: If `Γ ⊢ φ → ψ` and `Γ ⊢ φ`, then `Γ ⊢ ψ`
example (Γ : Context) (φ ψ : Formula)
  (h1 : Γ ⊢ φ.imp ψ) (h2 : Γ ⊢ φ) : Γ ⊢ ψ := by
  apply Derivable.modus_ponens
  · exact h1
  · exact h2

-- Modal K (MK): If `□Γ ⊢ φ` then `Γ ⊢ □φ`
example (φ : Formula) (h : [Formula.box (Formula.atom "p")] ⊢ φ) :
  [Formula.atom "p"] ⊢ Formula.box φ := by
  sorry -- Requires MK rule application

-- Temporal K (TK): If `GΓ ⊢ φ` then `Γ ⊢ Gφ`
example (φ : Formula) (h : [Formula.all_future (Formula.atom "p")] ⊢ φ) :
  [Formula.atom "p"] ⊢ Formula.all_future φ := by
  sorry -- Requires TK rule application
```

## 4. Automation

### Custom Tactics

Logos provides custom tactics for common proof patterns:

```lean
-- Apply modal axiom MT
example (P : Formula) : ⊢ (P.box.imp P) := by
  modal_t

-- Modal proof search
example (P : Formula) : [P.box.box] ⊢ P := by
  modal_search 3

-- Comprehensive TM automation
example (P Q : Formula) : [P.box, (P.imp Q).box] ⊢ Q.box := by
  tm_auto
```

### Using Aesop

With Aesop integration:

```lean
-- Automatic proof using marked lemmas
example (P : Formula) : ⊢ (P.box.imp P) := by
  aesop (rule_sets [TMLogic])
```

## 5. Semantics

### Task Frames

A task frame provides the semantic foundation:

```lean
-- Task frame structure
structure TaskFrame where
  WorldState : Type                    -- Set of world states
  Time : Type                          -- Set of times
  time_group : OrderedAddCommGroup Time -- Times form ordered group
  task_rel : WorldState → Time → WorldState → Prop  -- Task relation
```

### World Histories

A world history is a function from times to world states:

```lean
-- World history maps convex time interval to world states
structure WorldHistory (F : TaskFrame) where
  domain : Set F.Time
  convex : IsConvex F domain
  states : (t : F.Time) → t ∈ domain → F.WorldState
```

### Task Models

A task model adds valuation to a task frame:

```lean
-- Task model with propositional valuation
structure TaskModel (F : TaskFrame) where
  valuation : String → Set F.WorldState
```

### Truth Evaluation

Truth at a model-history-time triple:

```lean
-- Evaluate formula truth
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : F.Time) :
  Formula → Prop
  | Formula.atom p => t ∈ τ.domain ∧ τ(t) ∈ M.valuation p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t φ → truth_at M τ t ψ
  | Formula.box φ => ∀ σ : WorldHistory F, truth_at M σ t φ
  | Formula.all_past φ => ∀ s < t, truth_at M τ s φ
  | Formula.all_future φ => ∀ s > t, truth_at M τ s φ
```

### Validity

```lean
-- Global validity
def valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    M, τ, t ⊨ φ

-- Semantic consequence
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    (∀ ψ ∈ Γ, M, τ, t ⊨ ψ) → M, τ, t ⊨ φ
```

## 6. Advanced Topics

### Soundness and Completeness

The soundness theorem states derivability implies validity:

```lean
-- Soundness: Γ ⊢ φ → Γ ⊨ φ
theorem soundness (Γ : Context) (φ : Formula) :
  Γ ⊢ φ → Γ ⊨ φ := by
  sorry -- See Metalogic/Soundness.lean
```

The completeness theorem states validity implies derivability:

```lean
-- Weak completeness: ⊨ φ → ⊢ φ
theorem weak_completeness (φ : Formula) :
  ⊨ φ → ⊢ φ := by
  sorry -- See Metalogic/Completeness.lean

-- Strong completeness: Γ ⊨ φ → Γ ⊢ φ
theorem strong_completeness (Γ : Context) (φ : Formula) :
  Γ ⊨ φ → Γ ⊢ φ := by
  sorry -- See Metalogic/Completeness.lean
```

### Perpetuity Principles

The perpetuity principles P1-P6 connect modal and temporal operators:

```lean
-- P1: `□φ → △φ` (necessary implies always)
theorem perpetuity_1 (φ : Formula) : ⊢ (φ.box.imp (△φ)) := by
  sorry

-- P2: `▽φ → ◇φ` (sometimes implies possible)
theorem perpetuity_2 (φ : Formula) : ⊢ ((▽φ).imp (diamond φ)) := by
  sorry

-- P3-P6: See Theorems/Perpetuity.lean
-- P3: `□φ → □△φ`, P4: `◇▽φ → ◇φ`, P5: `◇▽φ → △◇φ`, P6: `▽□φ → □△φ`
```

### Extension Layers

Logos supports future extensions:

- **Layer 1 (Explanatory)**: Counterfactual (□→), grounding (≤), causation (○→)
- **Layer 2 (Epistemic)**: Belief, probability operators
- **Layer 3 (Normative)**: Obligation, permission operators

## 7. Next Steps

### Further Reading

- [Architecture Guide](ARCHITECTURE.md) - Full TM logic specification
- [Examples](EXAMPLES.md) - More example proofs
- [Contributing](../Development/CONTRIBUTING.md) - How to contribute
- [Integration](INTEGRATION.md) - Model-Checker integration

### Developer Resources

- [LEAN Style Guide](../Development/LEAN_STYLE_GUIDE.md)
- [Module Organization](../Development/MODULE_ORGANIZATION.md)
- [Testing Standards](../Development/TESTING_STANDARDS.md)
- [Tactic Development](TACTIC_DEVELOPMENT.md)

### External Resources

- [LEAN 4 Documentation](https://lean-lang.org/documentation/)
- [Mathlib4 Documentation](https://leanprover-community.github.io/mathlib4_docs/)
- [LEAN Zulip Chat](https://leanprover.zulipchat.com/)
