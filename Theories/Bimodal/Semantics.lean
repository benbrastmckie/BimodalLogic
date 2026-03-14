import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.WorldHistory
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity

/-!
# Bimodal.Semantics - Task Frame Semantics

Aggregates all semantic components for bimodal logic TM (Tense and Modality). Provides
task frame semantics with world histories, truth evaluation, and validity definitions
polymorphic over temporal types.

## Submodules

- `TaskFrame`: Task frame structure `F = (W, T, ·)` with world states, temporal type,
  and task relation satisfying nullity and compositionality constraints
- `WorldHistory`: World histories `τ: X → W` as functions from convex time domains to
  world states, respecting the task relation
- `TaskModel`: Task models extending frames with valuation functions `V: W × String → Prop`
- `Truth`: Recursive truth evaluation `M,τ,t ⊨ φ` for formulas at model-history-time triples
- `Validity`: Semantic validity `⊨ φ` and consequence `Γ ⊨ φ` quantifying over all temporal types

## Semantic Structure

The semantics follows the JPL paper "The Perpetuity Calculus of Agency":

| Component | Paper Definition | Implementation |
|-----------|------------------|----------------|
| Task Frame | `F = (W, G, ·)` | `TaskFrame T` with `task_rel` |
| Nullity | `w ∈ w · 0` | `nullity : ∀ w, task_rel w 0 w` |
| Compositionality | `u ∈ w·d, v ∈ u·e ⟹ v ∈ w·(d+e)` | `compositionality` constraint |
| World History | `τ: X → W` convex | `WorldHistory F` with `convex` proof |
| Truth | `M,τ,x ⊨ φ` | `truth_at M τ t ht φ` |
| Validity | True in all models | `valid φ` (polymorphic over `T`) |

## Temporal Polymorphism

The semantics is polymorphic over temporal type `T : Type*` with
`LinearOrderedAddCommGroup T`:

- `Int`: Discrete integer time (standard temporal logic)
- `Rat`: Dense rational time (fine-grained reasoning)
- `Real`: Continuous real time (physical systems)
- Custom bounded or modular time structures

## Truth Clauses

| Formula | Truth Condition |
|---------|-----------------|
| `atom p` | `M.valuation (τ.states t ht) p` |
| `⊥` | `False` |
| `φ → ψ` | `truth_at ... φ → truth_at ... ψ` |
| `□φ` | `∀ σ, σ.domain t → truth_at M σ t hs φ` |
| `Hφ` | `∀ s < t, s ∈ τ.domain → truth_at M τ s hs φ` |
| `Gφ` | `∀ s > t, s ∈ τ.domain → truth_at M τ s hs φ` |

## Usage

```lean
import Bimodal.Semantics

open Bimodal.Semantics
open Bimodal.Syntax

-- Validity notation
#check (⊨ Formula.atom_s "p" : Prop)  -- Not valid

-- Semantic consequence
#check ([Formula.atom_s "p"] ⊨ Formula.atom_s "p" : Prop)  -- Valid

-- Work with specific temporal type
variable {F : TaskFrame Int} (M : TaskModel F) (τ : WorldHistory F)
variable (t : Int) (ht : τ.domain t)

#check truth_at M τ t ht (Formula.box (Formula.atom_s "p"))
```

## References

* [TaskFrame.lean](Semantics/TaskFrame.lean) - Task frame structure
* [WorldHistory.lean](Semantics/WorldHistory.lean) - World history definition
* [TaskModel.lean](Semantics/TaskModel.lean) - Task model with valuation
* [Truth.lean](Semantics/Truth.lean) - Truth evaluation
* [Validity.lean](Semantics/Validity.lean) - Validity and semantic consequence
-/
