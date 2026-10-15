/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TruthTransport

/-!
# Reversal — the reflected model, the reflected world, and `lem:time-reflection`

`lem:time-reflection` passes from a task frame to its **converse frame** `F⁻`
(`Semantics/TaskFrame.lean`), from a model to the model over `F⁻` with the same valuation, and
from a possible world `τ` to the world `τ⁻ : x ↦ τ(-x)` over `F⁻`. The lemma itself is the
transport

```
M, τ, t ⊨ φ     iff     M⁻, τ⁻, -t ⊨ φ_{S|U}
```

for every sentence of the base language, where `φ_{S|U}` is `Formula.reflectTime`.

**This is an instance, not a new induction.** `Semantics/TruthTransport.lean` already carries the
generic order-reversing transport `Truth.truthAt_of_truthAntiIso`, which asks for an
order-reversing equivalence of durations, an equivalence of world histories, and atomic
agreement. Negation, `WorldHistory.rev` and `TaskModel.rev` supply exactly those three, so
`truthAt_rev` is `truthAt_of_truthAntiIso` at `revAntiIso` and nothing more.

The open language L^▷ gets its own induction instead (`OpenLanguage/OpenReversal.lean`): the
`▷`, `◁` and `⊡` clauses quantify over a *class* of histories, and transporting a class is not
what an atom-level `TruthAntiIso` does.

## Main Definitions

- `TaskModel.rev`, `WorldHistory.rev` — the reflected model and the reflected world
- `revHistEquiv` — the paper's bijection `H_F → H_{F⁻}`, as an `Equiv`
- `revAntiIso` — the reversal packaged as a `TruthAntiIso`

## Main Results

- `TaskModel.rev_rev` — reversal of models is an involution, by `rfl`
- `WorldHistory.rev_rev_hist` — reversal of worlds is an involution (propositional, not `rfl`),
  whence `WorldHistory.rev_surjective`
- `sameState_rev_iff` — reversal fixes the state-local class `⟨τ⟩_x`, the one extra fact the
  class-quantifying clauses need beyond atom-level agreement
- `truthAt_rev` — `lem:time-reflection` for the base language

## References

* JPL paper `lem:time-reflection` — the converse frame, the reflected world, and the transport
* JPL paper `def:time-reflection` — `Formula.reflectTime` (`Syntax/Formula.lean`)
* `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver.rev`, `TaskFrame.rev` and the converse
  frame's regularity
* `FormalSystem/Semantics/TruthTransport.lean` — `TruthAntiIso`, `truthAt_of_truthAntiIso`
* `FormalSystem/Semantics/Validity.lean` — the validity-level consequence (`thm:TR-valid`)
* `FormalSystem/Semantics/Presheaf/` — the categorical packaging of the same involution, as the
  Reflection clause on the frame presheaf; independent of this module

## Tags

time-reflection · converse-frame · anti-isomorphism · truth-transport
-/

-- Lower semantic layer: must not reach the proof system (G-15). `FrameClassValidity.lean`
-- is the one documented seam that imports `ProofSystem.Axioms`; nothing below it may.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/-! ## The reflected model and the reflected world -/

/-- A model over the converse frame: the same world states, so the same valuation. -/
def TaskModel.rev {F : TaskFrame} (M : TaskModel F) : TaskModel F.rev := ⟨M.valuation⟩

/-- Reversal of models is an involution, definitionally. -/
theorem TaskModel.rev_rev {F : TaskFrame} (M : TaskModel F) : M.rev.rev = M := rfl

/-- **The reflected world**: `τ⁻(t) = τ(-t)`, a possible world over the converse frame. -/
def WorldHistory.rev {F : TaskFrame} (τ : WorldHistory F) : WorldHistory F.rev :=
  WorldHistory.ofTotal F.rev (fun t => τ.state (-t)) (fun s t => by
    change F.TaskRel (τ.state (-t)) (t - s) (τ.state (-s))
    have := τ.respects_task (-t) (-s)
    rwa [neg_sub_neg] at this)

@[simp] theorem WorldHistory.rev_state {F : TaskFrame} (τ : WorldHistory F) (t : F.Duration) :
    τ.rev.state t = τ.state (-t) := rfl

/-- Reversal of world histories is an involution. Propositional, not `rfl`: the two histories
have the states `τ(- -t)` and `τ(t)`. -/
theorem WorldHistory.rev_rev_hist {F : TaskFrame} (τ : WorldHistory F) :
    (τ.rev.rev : WorldHistory F) = τ := by
  apply WorldHistory.ext_state
  intro t
  change τ.state (- -t) = τ.state t
  rw [neg_neg]

/-- Every world over the converse frame is the reflection of a world over the original: with
`rev_rev_hist`, the manuscript's bijection `H_F → H_{F⁻}`. -/
theorem WorldHistory.rev_surjective {F : TaskFrame} (σ : WorldHistory F.rev) :
    ∃ τ : WorldHistory F, τ.rev = σ :=
  ⟨(σ.rev : WorldHistory F), WorldHistory.rev_rev_hist (F := F.rev) σ⟩

/-- **Reversal fixes the state-local class.** `⟨τ⟩_x` is defined by a same-time condition, so
`σ ∈ ⟨τ⟩_x` exactly when `σ⁻ ∈ ⟨τ⁻⟩_{-x}`: this is the paper's "`τ ↦ τ⁻` carries `⟨τ⟩_x` onto
`⟨τ⁻⟩_{n(x)}`", in its pointwise form.

It sits at this layer, below every object language, because it is a statement about
`WorldHistory.state` alone. It is the one extra fact the `⊡`, `▷` and `◁` clauses need beyond an
atom-level `TruthAntiIso`: those clauses quantify over a class of histories, and a class has to
be transported, which is why neither language layer owns this lemma. -/
theorem sameState_rev_iff {F : TaskFrame} (τ σ : WorldHistory F) (t : F.Duration) :
    τ.state t = σ.state t ↔ τ.rev.state (-t) = σ.rev.state (-t) := by
  change _ ↔ τ.state (- -t) = σ.state (- -t)
  rw [neg_neg]

/-! ## The reversal anti-isomorphism, and `lem:time-reflection` -/

/-- Reversal of world histories as an equivalence `H_F ≃ H_{F⁻}` — the paper's bijection
`τ ↦ τ⁻`, packaged in the form `TruthAntiIso.hist` requires.

`invFun` type-checks only because `TaskFrame.rev` is `@[reducible]`: the reflected world of a
world over `F⁻` lives over `F⁻⁻`, and that is `F` by `rfl` at reducible transparency. -/
def revHistEquiv (F : TaskFrame) : WorldHistory F ≃ WorldHistory F.rev where
  toFun := WorldHistory.rev
  invFun := fun σ => (σ.rev : WorldHistory F)
  left_inv := WorldHistory.rev_rev_hist
  right_inv := fun σ => WorldHistory.rev_rev_hist (F := F.rev) σ

/-- **The reversal anti-isomorphism.** `dur` is negation, which reverses the order by
`neg_lt_neg_iff`; `hist` is the reversal involution of `revHistEquiv`; `atom` holds because the
two models share their valuation — the goal sits at `t` on one side and `- -t` on the other, so
it is `change` plus `neg_neg`, not `rfl`. -/
def revAntiIso {F : TaskFrame} (M : TaskModel F) : TruthAntiIso M M.rev where
  dur := Equiv.neg F.Duration
  dur_rev := fun _ _ => neg_lt_neg_iff
  hist := revHistEquiv F
  atom := by
    intro τ t p
    change M.valuation (τ.state t) p ↔ M.valuation (τ.state (- -t)) p
    rw [neg_neg]

/--
**`lem:time-reflection` for the base language.** A sentence is true at `(M, τ, t)` exactly when
its time reflection is true at the reflected point `(M⁻, τ⁻, -t)` of the converse frame.

No induction of its own: this is the generic order-reversing transport
`Truth.truthAt_of_truthAntiIso` at `revAntiIso M`. The validity-level consequence
(`thm:TR-valid`) is `Semantics.validOn_rev_iff` and the `reflectTime` family in
`Semantics/Validity.lean`.

Paper: `lem:time-reflection`
-/
theorem truthAt_rev {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : Formula) : TruthAt M τ t φ ↔ TruthAt M.rev τ.rev (-t) φ.reflectTime :=
  Truth.truthAt_of_truthAntiIso (revAntiIso M) φ τ t

end FormalSystem.Semantics
