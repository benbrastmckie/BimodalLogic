# ProofChecker API Reference

**Version**: 1.1.0
**Last Updated**: 2026-01-11
**Status**: Complete

This document provides a centralized API reference for all Bimodal modules, generated from inline docstrings.

## Table of Contents

1. [Syntax](#syntax)
2. [Semantics](#semantics)
3. [Proof System](#proof-system)
4. [Automation](#automation)
5. [Theorems](#theorems)
6. [Metalogic](#metalogic)

---

## Syntax

### Formula (`FormalSystem.Syntax.Formula`)

**Module**: `FormalSystem/Syntax/Formula.lean`

The core syntax for bimodal logic TM (Tense and Modality), combining S5 modal logic with linear temporal logic.

#### Type Definition

```lean
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | allPast : Formula → Formula
  | allFuture : Formula → Formula
```

#### Primitive Operators

| Operator | Syntax | Description |
|----------|--------|-------------|
| `atom` | `Formula.atom "p"` | Propositional atom (variable) |
| `bot` | `Formula.bot` | Bottom (⊥, falsum, contradiction) |
| `imp` | `φ.imp ψ` | Implication (φ → ψ) |
| `box` | `φ.box` | Modal necessity (□φ, "necessarily φ") |
| `allPast` | `φ.allPast` | Universal past (Hφ, "φ has always been true") |
| `allFuture` | `φ.allFuture` | Universal future (Gφ, "φ will always be true") |

#### Derived Operators

| Operator | Definition | Description |
|----------|------------|-------------|
| `neg` | `φ.imp bot` | Negation (¬φ) |
| `and` | `(φ.imp ψ.neg).neg` | Conjunction (φ ∧ ψ) |
| `or` | `φ.neg.imp ψ` | Disjunction (φ ∨ ψ) |
| `diamond` | `φ.neg.box.neg` | Modal possibility (◇φ) |
| `always` | `φ.allPast.and (φ.and φ.allFuture)` | Eternal truth (△φ) |
| `sometimes` | `φ.neg.always.neg` | Sometime (▽φ) |
| `somePast` | `φ.neg.allPast.neg` | Existential past (Pφ) |
| `someFuture` | `φ.neg.allFuture.neg` | Existential future (Fφ) |

#### Key Functions

##### `complexity : Formula → Nat`

Structural complexity of a formula (number of connectives + 1). Useful for well-founded recursion and proof complexity analysis.

**Example**:
```lean
complexity (atom "p") = 1
complexity (p.imp q) = 1 + complexity p + complexity q
```

##### `swapTemporal : Formula → Formula`

Swap temporal operators (past ↔ future) in a formula. Used in the temporal duality inference rule (TD).

**Theorem**: `swap_temporal_involution` - Applying twice gives identity.

**Example**:
```lean
swapTemporal (p.allPast) = p.allFuture
swapTemporal (p.allFuture) = p.allPast
```

---

### Context (`FormalSystem.Syntax.Context`)

**Module**: `FormalSystem/Syntax/Context.lean`

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

### TaskFrame (`FormalSystem.Semantics.TaskFrame`)

**Module**: `FormalSystem/Semantics/TaskFrame.lean`

Task frame structure for TM semantics, defining the fundamental semantic structures.

#### Structure Definition

```lean
structure TaskFrame (T : Type*) [LinearOrderedAddCommGroup T] where
  WorldState : Type
  TaskRel : WorldState → T → WorldState → Prop
  nullity : ∀ w, TaskRel w 0 w
  compositionality : ∀ w u v x y, TaskRel w x u → TaskRel u y v → TaskRel w (x + y) v
```

**Type Parameters**:
- `T`: Temporal duration type with totally ordered abelian group structure

**Fields**:
- `WorldState`: Type of world states
- `TaskRel w x u`: World state `u` is reachable from `w` by task of duration `x`
- `nullity`: Zero-duration task is identity (reflexivity)
- `compositionality`: Tasks compose with time addition (transitivity)

**Paper Alignment**: Matches JPL paper definition exactly (app:TaskSemantics, def:frame, line 1835).

---

### TaskModel (`FormalSystem.Semantics.TaskModel`)

**Module**: `FormalSystem/Semantics/TaskModel.lean`

Task models extending task frames with valuation functions for propositional atoms.

#### Structure Definition

```lean
structure TaskModel (F : TaskFrame T) where
  valuation : String → Set F.WorldState
```

**Fields**:
- `valuation p`: Set of world states where atom `p` is true

---

### WorldHistory (`FormalSystem.Semantics.WorldHistory`)

**Module**: `FormalSystem/Semantics/WorldHistory.lean`

World histories representing functions from convex time intervals to world states.

#### Structure Definition

```lean
structure WorldHistory (F : TaskFrame T) where
  domain : ConvexSet T
  history : ∀ t ∈ domain, F.WorldState
  task_coherence : ∀ t s ∈ domain, F.TaskRel (history t) (s - t) (history s)
```

**Fields**:
- `domain`: Convex set of times (interval)
- `history t`: World state at time `t`
- `task_coherence`: History respects task relation

---

### Truth (`FormalSystem.Semantics.Truth`)

**Module**: `FormalSystem/Semantics/Truth.lean`

Truth definition for formulas at world histories and times.

**Note**: Currently has build errors (type mismatch with `swap_past_future`).

---

### Validity (`FormalSystem.Semantics.Validity`)

**Module**: `FormalSystem/Semantics/Validity.lean`

Semantic validity and consequence relations for TM logic.

---

## Proof System

### Axioms (`FormalSystem.ProofSystem.Axioms`)

**Module**: `FormalSystem/ProofSystem/Axioms.lean`

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

### Derivation (`FormalSystem.ProofSystem.Derivation`)

**Module**: `FormalSystem/ProofSystem/Derivation.lean`

Derivability relation and inference rules for TM logic.

#### Derivation Tree Type

```lean
inductive DerivationTree : Context → Formula → Prop where
  | axiom : Axiom φ → DerivationTree Γ φ
  | assumption : φ ∈ Γ → DerivationTree Γ φ
  | modus_ponens : DerivationTree Γ (φ.imp ψ) → DerivationTree Γ φ → DerivationTree Γ ψ
  | modal_k : DerivationTree (Γ.map box) φ → DerivationTree Γ (φ.box)
  | temporal_k : DerivationTree (Γ.map allFuture) φ → DerivationTree Γ (φ.allFuture)
  | temporal_dual : DerivationTree Γ φ → DerivationTree Γ (φ.swapTemporal)
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

### Tactics (`FormalSystem.Automation.Tactics`)

**Module**: `FormalSystem/Automation/Tactics.lean`

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

### ProofSearch (`FormalSystem.Automation.ProofSearch`)

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

##### `searchWithLearning : Context → Formula → SearchStrategy → PatternDatabase → LearningSearchResult`

Search with pattern learning for repeated proofs.

**Returns**: `LearningSearchResult` with updated `patternDb` for future searches.

##### `bestFirstSearch : Context → Formula → Nat → HeuristicWeights → PatternDatabase → SearchResult`

Priority queue-based best-first search with pattern-aware heuristics.

**Algorithm**:
1. Initialize priority queue with goal node (f-score = 0 + h(goal))
2. Extract minimum f-score node
3. Expand by trying all strategies (axiom, assumption, MP, modal K, temporal K)
4. Add child nodes with updated costs
5. Repeat until goal proven or expansion limit reached

##### `batchSearchWithLearning : List (String × Context × Formula) → PatternDatabase → LearningSearchResult`

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

### SuccessPatterns (`FormalSystem.Automation.SuccessPatterns`)

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
let result := searchWithLearning Γ φ (.IDDFS 100)
let db' := result.patternDb  -- Updated pattern database

-- Query patterns for hints
match db'.queryPatterns φ with
| some data => data.bestStrategy  -- Most successful strategy
| none => none  -- No history for this pattern
```

---

### AesopRules (`FormalSystem.Automation.AesopRules`)

**Module**: `FormalSystem/Automation/AesopRules.lean`

Aesop rule registration for TM automation.

**Rules Registered**:
- Forward chaining for proven axioms (MT, M4, MB, T4, TA, prop_k, prop_s)
- Safe apply rules for core inference (modus_ponens, modal_k, temporal_k)
- Normalization for derived operators (diamond, always, sometimes)

---

## Theorems

### Propositional (`FormalSystem.Theorems.Propositional`)

**Module**: `FormalSystem/Theorems/Propositional.lean`

Key propositional theorems in Hilbert-style proof calculus.

#### Main Theorems

| Theorem | Statement | Description |
|---------|-----------|-------------|
| `botOfAndNeg` | `[A, ¬A] ⊢ B` | Ex Contradictione Quodlibet |
| `impNegImp` | `⊢ A → (¬A → B)` | Reductio ad Absurdum |
| `negImp` | `⊢ ¬A → (A → B)` | Ex Falso Quodlibet |
| `andLeft` | `[A ∧ B] ⊢ A` | Left Conjunction Elimination |
| `andRight` | `[A ∧ B] ⊢ B` | Right Conjunction Elimination |
| `orInl` | `[A] ⊢ A ∨ B` | Left Disjunction Introduction |
| `orInr` | `[B] ⊢ A ∨ B` | Right Disjunction Introduction |
| `impOfNegImpNeg` | `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)` | Reverse Contraposition |
| `em` | `⊢ A ∨ ¬A` | Law of Excluded Middle |
| `doubleNegation` | `⊢ ¬¬φ → φ` | Double Negation Elimination |

**Status**: Phase 1 complete (8 theorems proven, zero sorry)

---

### ModalS4 (`FormalSystem.Theorems.ModalS4`)

**Module**: `FormalSystem/Theorems/ModalS4.lean`

S4 modal logic theorems (reflexivity + transitivity).

---

### ModalS5 (`FormalSystem.Theorems.ModalS5`)

**Module**: `FormalSystem/Theorems/ModalS5.lean`

S5 modal logic theorems (reflexivity + transitivity + symmetry).

---

### GeneralizedNecessitation (`FormalSystem.Theorems.GeneralizedNecessitation`)

**Module**: `FormalSystem/Theorems/GeneralizedNecessitation.lean`

Generalized necessitation rules for modal and temporal operators.

---

### Combinators (`FormalSystem.Theorems.Combinators`)

**Module**: `FormalSystem/Theorems/Combinators.lean`

Combinator infrastructure for proof construction.

#### Key Combinators

| Combinator | Statement | Description |
|------------|-----------|-------------|
| `identity` | `⊢ φ → φ` | Identity combinator |
| `impTrans` | `(Γ ⊢ φ → ψ) → (Γ ⊢ ψ → χ) → (Γ ⊢ φ → χ)` | Implication transitivity |
| `bCombinator` | `⊢ (ψ → χ) → ((φ → ψ) → (φ → χ))` | B combinator |
| `theoremFlip` | `(Γ ⊢ φ → (ψ → χ)) → (Γ ⊢ ψ → (φ → χ))` | Flip arguments |
| `pairing` | `(Γ ⊢ φ) → (Γ ⊢ ψ) → (Γ ⊢ φ ∧ ψ)` | Conjunction introduction |
| `notNotIntro` | `⊢ φ → ¬¬φ` | Double negation introduction |

---

### Perpetuity (`FormalSystem.Theorems.Perpetuity`)

**Module**: `FormalSystem/Theorems/Perpetuity.lean`

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

### Soundness (`FormalSystem.Metalogic.Soundness`)

**Module**: `FormalSystem/Metalogic/Soundness.lean`

Soundness theorem: derivability implies semantic consequence.

**Main Theorem**: `soundness : Γ ⊢ φ → Γ ⊨ φ`

---

### DeductionTheorem (`FormalSystem.Metalogic.Core.DeductionTheorem`)

**Module**: `FormalSystem/Metalogic/Core/DeductionTheorem.lean`

Deduction theorem for TM logic.

**Main Theorem**: `deductionTheorem : (φ :: Γ) ⊢ ψ → Γ ⊢ (φ → ψ)`

**Note**: Currently has build errors (type class instance problems).

---

### Completeness (`FormalSystem.Metalogic.BXCanonical`)

**Module**: `FormalSystem/Metalogic/BXCanonical.lean`

Completeness theorem: semantic consequence implies derivability. The chronicle
construction under `BXCanonical/` carries the flagship results (`completeness`,
`completeness_dense`, `completeness_discrete`); `WeakCanonical/` and `Algebraic/`
are the two alternative routes. The former top-level `Metalogic/Completeness.lean`
had no live importer and is archived under
`FormalSystem/Boneyard/SupersededCompleteness/`.

**Main Theorem**: `completeness : Γ ⊨ φ → Γ ⊢ φ`

---

## Usage Examples

### Basic Proof Construction

```lean
import Bimodal

open FormalSystem.Syntax FormalSystem.ProofSystem

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
import FormalSystem.Automation.ProofSearch

open FormalSystem.Automation

-- Bounded search for derivation
def search_example : Bool :=
  boundedSearch [] (p.box.imp p) 5

-- Search with heuristics
def heuristic_example : Bool :=
  searchWithHeuristics [] (p.box.imp p) 10
```

### Semantic Evaluation

```lean
import FormalSystem.Semantics

open FormalSystem.Semantics

-- Define a task frame
def example_frame : TaskFrame Int := {
  WorldState := Nat
  TaskRel := fun w x u => u = w + x.natAbs
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

All Bimodal modules follow these documentation standards:

1. **Module Docstrings** (`/-! ... -/`): Every file has comprehensive module docstring
2. **Declaration Docstrings** (`/-- ... -/`): All public definitions documented
3. **Formal Symbols**: Wrapped in backticks (e.g., `□φ`, `Γ ⊢ φ`)
4. **Examples**: Complex functions include usage examples
5. **Line Limit**: 100 characters per line
6. **References**: Cross-references to related modules and papers

---

## References

- **Lean Style Guide**: `docs/development/LEAN_STYLE_GUIDE.md`
- **JPL Paper**: "The Perpetuity Calculus of Agency" (task semantics specification)

---

## Version History

- **1.1.0** (2026-01-11): Task 176 - Enhanced proof search documentation
  - Added `FormalSystem.Automation.ProofSearch` with multiple strategies
  - Added `FormalSystem.Automation.SuccessPatterns` for pattern learning
  - Updated search function signatures and benchmark results
  - Added strategy selection guide and heuristic configuration

- **1.0.0** (2025-12-24): Initial API reference generated from docstrings
  - Complete coverage of Bimodal modules
  - Comprehensive examples and cross-references
  - Aligned with DOC_QUALITY_CHECKLIST.md standards
