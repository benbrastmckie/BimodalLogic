# Logos API Reference

**Version**: 1.1.0
**Last Updated**: 2026-01-11
**Status**: Complete

This document provides a centralized API reference for all Logos/Core modules, generated from inline docstrings.

## Table of Contents

1. [Syntax](#syntax)
2. [Semantics](#semantics)
3. [Proof System](#proof-system)
4. [Automation](#automation)
5. [Theorems](#theorems)
6. [Metalogic](#metalogic)

---

## Syntax

### Formula (`Logos.Core.Syntax.Formula`)

**Module**: `Logos/Core/Syntax/Formula.lean`

The core syntax for bimodal logic TM (Tense and Modality), combining S5 modal logic with linear temporal logic.

#### Type Definition

```lean
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
```

#### Primitive Operators

| Operator | Syntax | Description |
|----------|--------|-------------|
| `atom` | `Formula.atom "p"` | Propositional atom (variable) |
| `bot` | `Formula.bot` | Bottom (⊥, falsum, contradiction) |
| `imp` | `φ.imp ψ` | Implication (φ → ψ) |
| `box` | `φ.box` | Modal necessity (□φ, "necessarily φ") |
| `all_past` | `φ.all_past` | Universal past (Hφ, "φ has always been true") |
| `all_future` | `φ.all_future` | Universal future (Gφ, "φ will always be true") |

#### Derived Operators

| Operator | Definition | Description |
|----------|------------|-------------|
| `neg` | `φ.imp bot` | Negation (¬φ) |
| `and` | `(φ.imp ψ.neg).neg` | Conjunction (φ ∧ ψ) |
| `or` | `φ.neg.imp ψ` | Disjunction (φ ∨ ψ) |
| `diamond` | `φ.neg.box.neg` | Modal possibility (◇φ) |
| `always` | `φ.all_past.and (φ.and φ.all_future)` | Eternal truth (△φ) |
| `sometimes` | `φ.neg.always.neg` | Sometime (▽φ) |
| `some_past` | `φ.neg.all_past.neg` | Existential past (Pφ) |
| `some_future` | `φ.neg.all_future.neg` | Existential future (Fφ) |

#### Key Functions

##### `complexity : Formula → Nat`

Structural complexity of a formula (number of connectives + 1). Useful for well-founded recursion and proof complexity analysis.

**Example**:
```lean
complexity (atom "p") = 1
complexity (p.imp q) = 1 + complexity p + complexity q
```

##### `swap_temporal : Formula → Formula`

Swap temporal operators (past ↔ future) in a formula. Used in the temporal duality inference rule (TD).

**Theorem**: `swap_temporal_involution` - Applying twice gives identity.

**Example**:
```lean
swap_temporal (p.all_past) = p.all_future
swap_temporal (p.all_future) = p.all_past
```

---

### Context (`Logos.Core.Syntax.Context`)

**Module**: `Logos/Core/Syntax/Context.lean`

Formula lists for proof contexts representing assumptions in derivations.

#### Type Definition

```lean
abbrev Context := List Formula
```

#### Key Functions

##### `map : (Formula → Formula) → Context → Context`

Apply a transformation to all formulas in a context. Used in inference rules like Modal K and Temporal K.

**Example**:
```lean
Context.map Formula.box [p, q] = [□p, □q]
```

**Theorems**:
- `map_length`: Mapping preserves length
- `map_comp`: Mapping functions compose
- `mem_map_iff`: Membership in mapped context

---

## Semantics

### TaskFrame (`Logos.Core.Semantics.TaskFrame`)

**Module**: `Logos/Core/Semantics/TaskFrame.lean`

Task frame structure for TM semantics, defining the fundamental semantic structures.

#### Structure Definition

```lean
structure TaskFrame (T : Type*) [LinearOrderedAddCommGroup T] where
  WorldState : Type
  task_rel : WorldState → T → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Type Parameters**:
- `T`: Temporal duration type with totally ordered abelian group structure

**Fields**:
- `WorldState`: Type of world states
- `task_rel w x u`: World state `u` is reachable from `w` by task of duration `x`
- `nullity`: Zero-duration task is identity (reflexivity)
- `compositionality`: Tasks compose with time addition (transitivity)

**Paper Alignment**: Matches JPL paper definition exactly (app:TaskSemantics, def:frame, line 1835).

---

### TaskModel (`Logos.Core.Semantics.TaskModel`)

**Module**: `Logos/Core/Semantics/TaskModel.lean`

Task models extending task frames with valuation functions for propositional atoms.

#### Structure Definition

```lean
structure TaskModel (F : TaskFrame T) where
  valuation : String → Set F.WorldState
```

**Fields**:
- `valuation p`: Set of world states where atom `p` is true

---

### WorldHistory (`Logos.Core.Semantics.WorldHistory`)

**Module**: `Logos/Core/Semantics/WorldHistory.lean`

World histories representing functions from convex time intervals to world states.

#### Structure Definition

```lean
structure WorldHistory (F : TaskFrame T) where
  domain : ConvexSet T
  history : ∀ t ∈ domain, F.WorldState
  task_coherence : ∀ t s ∈ domain, F.task_rel (history t) (s - t) (history s)
```

**Fields**:
- `domain`: Convex set of times (interval)
- `history t`: World state at time `t`
- `task_coherence`: History respects task relation

---

### Truth (`Logos.Core.Semantics.Truth`)

**Module**: `Logos/Core/Semantics/Truth.lean`

Truth definition for formulas at world histories and times.

**Note**: Currently has build errors (type mismatch with `swap_past_future`).

---

### Validity (`Logos.Core.Semantics.Validity`)

**Module**: `Logos/Core/Semantics/Validity.lean`

Semantic validity and consequence relations for TM logic.

---

## Proof System

### Axioms (`Logos.Core.ProofSystem.Axioms`)

**Module**: `Logos/Core/ProofSystem/Axioms.lean`

The 14 axiom schemata for bimodal logic TM.

#### Axiom Type

```lean
inductive Axiom : Formula → Prop where
  | prop_k (φ ψ χ : Formula) : Axiom ((φ → (ψ → χ)) → ((φ → ψ) → (φ → χ)))
  | prop_s (φ ψ : Formula) : Axiom (φ → (ψ → φ))
  | ex_falso (φ : Formula) : Axiom (⊥ → φ)
  | peirce (φ ψ : Formula) : Axiom (((φ → ψ) → φ) → φ)
  | modal_t (φ : Formula) : Axiom (□φ → φ)
  | modal_4 (φ : Formula) : Axiom (□φ → □□φ)
  | modal_b (φ : Formula) : Axiom (φ → □◇φ)
  | modal_5_collapse (φ : Formula) : Axiom (◇□φ → □φ)
  | modal_k_dist (φ ψ : Formula) : Axiom (□(φ → ψ) → (□φ → □ψ))
  | temp_k_dist (φ ψ : Formula) : Axiom (G(φ → ψ) → (Gφ → Gψ))
  | temp_4 (φ : Formula) : Axiom (Gφ → GGφ)
  | temp_a (φ : Formula) : Axiom (φ → GPφ)
  | temp_l (φ : Formula) : Axiom (△φ → GPφ)
  | modal_future (φ : Formula) : Axiom (□φ → □Gφ)
  | temp_future (φ : Formula) : Axiom (□φ → G□φ)
```

#### Axiom Categories

**Propositional Axioms**:
- **K** (Distribution): `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
- **S** (Weakening): `φ → (ψ → φ)`
- **EFQ** (Ex Falso): `⊥ → φ`
- **Peirce**: `((φ → ψ) → φ) → φ`

**S5 Modal Axioms**:
- **MT** (Modal T): `□φ → φ` (reflexivity)
- **M4** (Modal 4): `□φ → □□φ` (transitivity)
- **MB** (Modal B): `φ → □◇φ` (symmetry)
- **MK** (Modal K): `□(φ → ψ) → (□φ → □ψ)` (distribution)

**Temporal Axioms**:
- **TK** (Temporal K): `G(φ → ψ) → (Gφ → Gψ)` (distribution)
- **T4** (Temporal 4): `Gφ → GGφ` (transitivity)
- **TA** (Temporal A): `φ → GPφ` (recurrence)
- **TL** (Temporal L): `△φ → GPφ` (perpetuity)

**Modal-Temporal Interaction**:
- **MF** (Modal-Future): `□φ → □Gφ`
- **TF** (Temporal-Future): `□φ → G□φ`

---

### Derivation (`Logos.Core.ProofSystem.Derivation`)

**Module**: `Logos/Core/ProofSystem/Derivation.lean`

Derivability relation and inference rules for TM logic.

#### Derivation Tree Type

```lean
inductive DerivationTree : Context → Formula → Prop where
  | axiom : Axiom φ → DerivationTree Γ φ
  | assumption : φ ∈ Γ → DerivationTree Γ φ
  | modus_ponens : DerivationTree Γ (φ.imp ψ) → DerivationTree Γ φ → DerivationTree Γ ψ
  | modal_k : DerivationTree (Γ.map box) φ → DerivationTree Γ (φ.box)
  | temporal_k : DerivationTree (Γ.map all_future) φ → DerivationTree Γ (φ.all_future)
  | temporal_dual : DerivationTree Γ φ → DerivationTree Γ (φ.swap_temporal)
```

**Notation**: `Γ ⊢ φ` means `DerivationTree Γ φ`

#### Inference Rules

| Rule | Description |
|------|-------------|
| `axiom` | Apply axiom schema |
| `assumption` | Use assumption from context |
| `modus_ponens` | From `φ → ψ` and `φ`, derive `ψ` |
| `modal_k` | From `□Γ ⊢ φ`, derive `Γ ⊢ □φ` |
| `temporal_k` | From `GΓ ⊢ φ`, derive `Γ ⊢ Gφ` |
| `temporal_dual` | From `⊢ φ`, derive `⊢ swap(φ)` |

---

## Automation

### Tactics (`Logos.Core.Automation.Tactics`)

**Module**: `Logos/Core/Automation/Tactics.lean`

Custom tactics for modal and temporal reasoning.

#### Core Tactics

##### `apply_axiom`

Apply a TM axiom by matching the goal against axiom patterns.

**Example**:
```lean
example : ⊢ (□p → p) := by
  apply_axiom  -- Finds and applies Axiom.modal_t
```

##### `modal_t`

Automatically apply modal T axiom (`□φ → φ`).

**Example**:
```lean
example (p : Formula) : [p.box] ⊢ p := by
  modal_t
  assumption
```

##### `tm_auto`

Aesop-powered TM automation with forward chaining and safe apply rules.

**Example**:
```lean
example : ⊢ (□p → p) := by
  tm_auto  -- Uses Aesop with TM-specific rules
```

##### `assumption_search`

Search local context for assumption matching the goal.

**Example**:
```lean
example (h : p → q) : p → q := by
  assumption_search  -- Finds h
```

#### Operator-Specific Tactics

| Tactic | Description |
|--------|-------------|
| `modal_k_tactic` | Apply modal K inference rule |
| `temporal_k_tactic` | Apply temporal K inference rule |
| `modal_4_tactic` | Apply modal 4 axiom |
| `modal_b_tactic` | Apply modal B axiom |
| `temp_4_tactic` | Apply temporal 4 axiom |
| `temp_a_tactic` | Apply temporal A axiom |

#### Proof Search Tactics

| Tactic | Description |
|--------|-------------|
| `modal_search depth` | Bounded proof search for modal formulas |
| `temporal_search depth` | Bounded proof search for temporal formulas |

---

### ProofSearch (`Bimodal.Automation.ProofSearch`)

**Module**: `Bimodal/Automation/ProofSearch.lean`

Advanced proof search with multiple strategies, heuristics, caching, and pattern learning.

#### Search Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| `IDDFS n` | Iterative deepening DFS, complete and optimal | Axiom goals, shallow proofs |
| `BoundedDFS n` | Depth-limited DFS, fast but incomplete | Known-depth goals |
| `BestFirst n` | Priority queue-based, heuristic-guided | Context-based goals, MP chains |

#### Key Functions

##### `search : Context → Formula → SearchStrategy → Nat → HeuristicWeights → SearchResult`

Unified search interface with configurable strategy.

**Parameters**:
- `Γ`: Proof context (assumptions)
- `φ`: Goal formula
- `strategy`: Search strategy (default: `.IDDFS 100`)
- `visitLimit`: Maximum node visits (default: 10000)
- `weights`: Heuristic weights for branch ordering

**Returns**: `(found, cache, visited, stats, visits)`

##### `search_with_learning : Context → Formula → SearchStrategy → PatternDatabase → LearningSearchResult`

Search with pattern learning for repeated proofs.

**Returns**: `LearningSearchResult` with updated `patternDb` for future searches.

##### `bestFirst_search : Context → Formula → Nat → HeuristicWeights → PatternDatabase → SearchResult`

Priority queue-based best-first search with pattern-aware heuristics.

**Algorithm**:
1. Initialize priority queue with goal node (f-score = 0 + h(goal))
2. Extract minimum f-score node
3. Expand by trying all strategies (axiom, assumption, MP, modal K, temporal K)
4. Add child nodes with updated costs
5. Repeat until goal proven or expansion limit reached

##### `batch_search_with_learning : List (String × Context × Formula) → PatternDatabase → LearningSearchResult`

Batch search that accumulates patterns across multiple goals.

#### Heuristic Configuration

| Weight | Default | Effect |
|--------|---------|--------|
| `axiomWeight` | 0 | Priority for axiom matching |
| `assumptionWeight` | 1 | Priority for context lookup |
| `mpBase` | 3 | Base cost for modus ponens |
| `modalKWeight` | 5 | Cost for modal K rule |
| `temporalKWeight` | 5 | Cost for temporal K rule |

#### Benchmark Results (Task 176)

| Category | IDDFS | BestFirst | Winner |
|----------|-------|-----------|--------|
| Modal axioms | 5/5 | 5/5 | Tie |
| Temporal axioms | 3/3 | 3/3 | Tie |
| Context-based | 1/3, 39 visits | 3/3, 6 visits | **BestFirst** |

---

### SuccessPatterns (`Bimodal.Automation.SuccessPatterns`)

**Module**: `Bimodal/Automation/SuccessPatterns.lean`

Pattern learning for proof search optimization.

#### Key Types

##### `PatternKey`

Formula structural features for pattern matching:
- `modalDepth`: Nesting depth of modal operators
- `temporalDepth`: Nesting depth of temporal operators
- `impCount`: Number of implications
- `complexity`: Total connective count
- `topOperator`: Top-level operator category

##### `ProofStrategy`

Strategies tracked for learning:
- `Axiom name`: Direct axiom match
- `Assumption`: Context assumption
- `ModusPonens`: Modus ponens application
- `ModalK`: Modal K rule
- `TemporalK`: Temporal K rule

##### `PatternDatabase`

Database of successful proof patterns with methods:
- `recordSuccess φ info`: Record successful proof pattern
- `queryPatterns φ`: Query for matching patterns
- `heuristicBonus φ strategy`: Get priority boost from history
- `suggestedDepth φ`: Get suggested depth from history

#### Usage Example

```lean
-- Search with pattern learning
let result := search_with_learning Γ φ (.IDDFS 100)
let db' := result.patternDb  -- Updated pattern database

-- Query patterns for hints
match db'.queryPatterns φ with
| some data => data.bestStrategy  -- Most successful strategy
| none => none  -- No history for this pattern
```

---

### AesopRules (`Bimodal.Automation.AesopRules`)

**Module**: `Logos/Core/Automation/AesopRules.lean`

Aesop rule registration for TM automation.

**Rules Registered**:
- Forward chaining for proven axioms (MT, M4, MB, T4, TA, prop_k, prop_s)
- Safe apply rules for core inference (modus_ponens, modal_k, temporal_k)
- Normalization for derived operators (diamond, always, sometimes)

---

## Theorems

### Propositional (`Logos.Core.Theorems.Propositional`)

**Module**: `Logos/Core/Theorems/Propositional.lean`

Key propositional theorems in Hilbert-style proof calculus.

#### Main Theorems

| Theorem | Statement | Description |
|---------|-----------|-------------|
| `ecq` | `[A, ¬A] ⊢ B` | Ex Contradictione Quodlibet |
| `raa` | `⊢ A → (¬A → B)` | Reductio ad Absurdum |
| `efq` | `⊢ ¬A → (A → B)` | Ex Falso Quodlibet |
| `lce` | `[A ∧ B] ⊢ A` | Left Conjunction Elimination |
| `rce` | `[A ∧ B] ⊢ B` | Right Conjunction Elimination |
| `ldi` | `[A] ⊢ A ∨ B` | Left Disjunction Introduction |
| `rdi` | `[B] ⊢ A ∨ B` | Right Disjunction Introduction |
| `rcp` | `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)` | Reverse Contraposition |
| `lem` | `⊢ A ∨ ¬A` | Law of Excluded Middle |
| `double_negation` | `⊢ ¬¬φ → φ` | Double Negation Elimination |

**Status**: Phase 1 complete (8 theorems proven, zero sorry)

---

### ModalS4 (`Logos.Core.Theorems.ModalS4`)

**Module**: `Logos/Core/Theorems/ModalS4.lean`

S4 modal logic theorems (reflexivity + transitivity).

---

### ModalS5 (`Logos.Core.Theorems.ModalS5`)

**Module**: `Logos/Core/Theorems/ModalS5.lean`

S5 modal logic theorems (reflexivity + transitivity + symmetry).

---

### GeneralizedNecessitation (`Logos.Core.Theorems.GeneralizedNecessitation`)

**Module**: `Logos/Core/Theorems/GeneralizedNecessitation.lean`

Generalized necessitation rules for modal and temporal operators.

---

### Combinators (`Logos.Core.Theorems.Combinators`)

**Module**: `Logos/Core/Theorems/Combinators.lean`

Combinator infrastructure for proof construction.

#### Key Combinators

| Combinator | Statement | Description |
|------------|-----------|-------------|
| `identity` | `⊢ φ → φ` | Identity combinator |
| `imp_trans` | `(Γ ⊢ φ → ψ) → (Γ ⊢ ψ → χ) → (Γ ⊢ φ → χ)` | Implication transitivity |
| `b_combinator` | `⊢ (ψ → χ) → ((φ → ψ) → (φ → χ))` | B combinator |
| `theorem_flip` | `(Γ ⊢ φ → (ψ → χ)) → (Γ ⊢ ψ → (φ → χ))` | Flip arguments |
| `pairing` | `(Γ ⊢ φ) → (Γ ⊢ ψ) → (Γ ⊢ φ ∧ ψ)` | Conjunction introduction |
| `dni` | `⊢ φ → ¬¬φ` | Double negation introduction |

---

### Perpetuity (`Logos.Core.Theorems.Perpetuity`)

**Module**: `Logos/Core/Theorems/Perpetuity.lean`

Perpetuity principles connecting modal and temporal operators.

#### Perpetuity Principles

| Principle | Statement | Description |
|-----------|-----------|-------------|
| P1 | `⊢ □φ → △φ` | Necessity implies eternal truth |
| P2 | `⊢ ▽φ → ◇φ` | Sometime implies possibility |
| P3 | `⊢ □φ → Gφ` | Necessity implies always future |
| P4 | `⊢ Pφ → ◇φ` | Past implies possibility |
| P5 | `⊢ □φ → Hφ` | Necessity implies always past |
| P6 | `⊢ Fφ → ◇φ` | Future implies possibility |

**Status**: P1-P3 proven, P4-P6 have sorry placeholders

---

## Metalogic

### Soundness (`Logos.Core.Metalogic.Soundness`)

**Module**: `Logos/Core/Metalogic/Soundness.lean`

Soundness theorem: derivability implies semantic consequence.

**Main Theorem**: `soundness : Γ ⊢ φ → Γ ⊨ φ`

---

### DeductionTheorem (`Logos.Core.Metalogic.DeductionTheorem`)

**Module**: `Logos/Core/Metalogic/DeductionTheorem.lean`

Deduction theorem for TM logic.

**Main Theorem**: `deduction_theorem : (φ :: Γ) ⊢ ψ → Γ ⊢ (φ → ψ)`

**Note**: Currently has build errors (type class instance problems).

---

### Completeness (`Logos.Core.Metalogic.Completeness`)

**Module**: `Logos/Core/Metalogic/Completeness.lean`

Completeness theorem: semantic consequence implies derivability.

**Main Theorem**: `completeness : Γ ⊨ φ → Γ ⊢ φ`

---

## Usage Examples

### Basic Proof Construction

```lean
import Logos.Core

open Logos.Core.Syntax Logos.Core.ProofSystem

-- Prove modal T axiom
example (p : Formula) : ⊢ (p.box.imp p) := by
  apply_axiom

-- Prove using modus ponens
example (p q : Formula) (h1 : ⊢ p.imp q) (h2 : ⊢ p) : ⊢ q := by
  apply DerivationTree.modus_ponens h1 h2

-- Use tm_auto for automatic proof
example (p : Formula) : ⊢ (p.box.imp p) := by
  tm_auto
```

### Proof Search

```lean
import Logos.Core.Automation.ProofSearch

open Logos.Core.Automation

-- Bounded search for derivation
def search_example : Bool :=
  bounded_search [] (p.box.imp p) 5

-- Search with heuristics
def heuristic_example : Bool :=
  search_with_heuristics [] (p.box.imp p) 10
```

### Semantic Evaluation

```lean
import Logos.Core.Semantics

open Logos.Core.Semantics

-- Define a task frame
def example_frame : TaskFrame Int := {
  WorldState := Nat
  task_rel := fun w x u => u = w + x.natAbs
  nullity := by simp
  compositionality := by simp [Int.natAbs_add]
}

-- Define a task model
def example_model : TaskModel example_frame := {
  valuation := fun p => {w | w % 2 = 0}  -- Even world states
}
```

---

## Documentation Standards

All Logos modules follow these documentation standards:

1. **Module Docstrings** (`/-! ... -/`): Every file has comprehensive module docstring
2. **Declaration Docstrings** (`/-- ... -/`): All public definitions documented
3. **Formal Symbols**: Wrapped in backticks (e.g., `□φ`, `Γ ⊢ φ`)
4. **Examples**: Complex functions include usage examples
5. **Line Limit**: 100 characters per line
6. **References**: Cross-references to related modules and papers

---

## References

- **Architecture Guide**: `Documentation/UserGuide/ARCHITECTURE.md`
- **Lean Style Guide**: `Documentation/Development/LEAN_STYLE_GUIDE.md`
- **Tactic Development**: `Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md`
- **JPL Paper**: "The Perpetuity Calculus of Agency" (task semantics specification)

---

## Version History

- **1.1.0** (2026-01-11): Task 176 - Enhanced proof search documentation
  - Added `Bimodal.Automation.ProofSearch` with multiple strategies
  - Added `Bimodal.Automation.SuccessPatterns` for pattern learning
  - Updated search function signatures and benchmark results
  - Added strategy selection guide and heuristic configuration

- **1.0.0** (2025-12-24): Initial API reference generated from docstrings
  - Complete coverage of Logos/Core modules
  - Comprehensive examples and cross-references
  - Aligned with DOC_QUALITY_CHECKLIST.md standards
