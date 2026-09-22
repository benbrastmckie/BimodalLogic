/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Frames.TranslationProduct
import FormalSystem.Metalogic.Independence.PastedCoarseModels

/-!
# Coarsened models on the translation product

Coarse truth, paste-closure and coarse refutations transfer between a frame `F` and its
translation product `F.translationProduct`, in both directions where both make sense: a coarse
model `K` on `F` lifts to a coarse model `liftK F K` on the product whose coarsening forgets the
clock; coarse truth is preserved by the projection (`c_invariance`); `liftK F K` is paste-closed
iff `K` is (`pasteClosed_liftK`, `pasteClosed_of_liftK`); and a coarse refutation on `F`
transfers to a coarse refutation on the product (`c_refuted_lift`).

The translation product is a *proof device* and never an intended model — see the standing
caveat in `Semantics/Frames/TranslationProduct.lean`, which owns the construction and the
argument that clocked states are not world states. What this module adds is the route from a
coarse countermodel on an arbitrary frame to a coarse countermodel on a frame that is
recurrence-free and satisfies *Limit* for free, in the same frame class.

## Why a separate module

`PastedCoarseModels.lean` is upstream of the whole limit-closure chain
(`LimitClosureCountermodel.lean`, `PlusIncompleteness.lean`), is written over a bare `TaskFrame`,
and must not acquire `StarLanguage.StarValidity` in its import closure. The product needs a
`FrameOver D` and lives with the `L⋆` invariance; so the transfer results sit here, downstream of
both.

## Main Definitions

- `liftK` — the lift of a coarse model to the product; the coarsening ignores the clock

## Main Results

- `c_invariance` — coarse truth is preserved by the projection
- `pasteClosed_liftK`, `pasteClosed_of_liftK` — paste-closure transfers in both directions
- `c_refuted_lift` — a coarse refutation on `F` is a coarse refutation on the product

## References

Paper: — (formalization-native; the paper defines no product of task frames and the coarsened
semantics is this tree's own)
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics
open CTruth

variable {D : TemporalOrder} (F : FrameOver D)

/-- The lift of a coarse model to the translation product: the underlying model is `liftModel`,
and the coarsening forgets the clock. -/
def liftK (K : CoarseModel F.toTaskFrame) : CoarseModel F.translationProduct.toTaskFrame where
  toModel := liftModel F K.toModel
  Cls := K.Cls
  π := fun a => K.π a.1
  atom_inv := fun h p hp => K.atom_inv h p hp

/-- **Coarse truth is preserved by the projection.** The `⊡` clause consults `SameUnder`, which
compares `π`-images; since the lifted `π` ignores the clock, the lift at offset `0` of a
witnessing history is again a witness. -/
theorem c_invariance (K : CoarseModel F.toTaskFrame) :
    ∀ (φ : PlusFormula) (τ' : WorldHistory F.translationProduct.toTaskFrame) (t : ↑D),
      CTruthAt (liftK F K) τ' t φ ↔ CTruthAt K (projH F τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t; exact Iff.rfl
  | bot => intro τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t; exact imp_congr (ih1 τ' t) (ih2 τ' t)
  | box a ih =>
    intro τ' t
    constructor
    · intro h ρ
      have := (ih (liftH F ρ 0) t).1 (h _)
      rwa [projH_liftH] at this
    · intro h σ'; exact (ih σ' t).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | snce a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | stab a ih =>
    intro τ' t
    constructor
    · intro h ρ hρ
      -- `hρ : SameUnder K (projH τ') ρ t`, i.e. `K.π (τ' t).1 = K.π (ρ t)`
      have hl : SameUnder (liftK F K) τ' (liftH F ρ 0) t := hρ
      have := (ih _ t).1 (h _ hl)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t).2 (h _ he)

/-- **The lift of a paste-closed coarse model is paste-closed**: project the two histories,
splice on `F`, lift the splice at offset `0`. -/
theorem pasteClosed_liftK (K : CoarseModel F.toTaskFrame) (hK : K.PasteClosed) :
    (liftK F K).PasteClosed := by
  intro ρ' σ' t hs
  obtain ⟨η, h1, h2⟩ := hK (projH F ρ') (projH F σ') t hs
  exact ⟨liftH F η 0, fun s hst => h1 s hst, fun s hts => h2 s hts⟩

/-- Conversely, paste-closure of the lift gives paste-closure of `K`: lift the two histories at
offset `0`, splice on the product, project the splice. -/
theorem pasteClosed_of_liftK (K : CoarseModel F.toTaskFrame) (hK : (liftK F K).PasteClosed) :
    K.PasteClosed := by
  intro ρ σ t hs
  obtain ⟨η', h1, h2⟩ := hK (liftH F ρ 0) (liftH F σ 0) t hs
  exact ⟨projH F η', fun s hst => h1 s hst, fun s hts => h2 s hts⟩

/-- **Coarse refutations transfer to the product**: a coarse countermodel on `F`, over any
temporal order, is a coarse countermodel on the clocked frame, which is recurrence-free and
satisfies *Limit* for free. -/
theorem c_refuted_lift (K : CoarseModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ↑D) (φ : PlusFormula) (h : ¬ CTruthAt K τ t φ) :
    ¬ CTruthAt (liftK F K) (liftH F τ 0) t φ := by
  intro h'
  have := (c_invariance F K φ (liftH F τ 0) t).1 h'
  rw [projH_liftH] at this
  exact h this

end FormalSystem.Metalogic.Independence
