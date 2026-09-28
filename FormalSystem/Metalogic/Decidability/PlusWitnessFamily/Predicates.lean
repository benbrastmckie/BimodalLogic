/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Basic

/-!
# The Conditions of an L⁺ Branching Certificate

The `Formula`-side branching certificate carries five conditions: (C0) atom coherence, (C1')
local coherence across the branching, (C2') thread fulfilment, (C3) box faithfulness and (C4)
the target. This module re-indexes them at `PlusFormula` and adds the sixth, (C5) stability
faithfulness, which is the one the `Formula` side cannot state.

## The `stab` clause is deliberately absent from (C1')

`PlusLocalCoherentShare` has **five** clauses — `bot`, `imp`, `box`, `untl` across shared
successors, `snce` across shared predecessors — and no sixth. That is not an oversight.

(C1')'s temporal clauses are *one-step unfoldings*: they relate a label at `t` to labels at
`t ± 1`. (C3)'s box clause is *global*: it relates a label to a single Boolean read everywhere.
The stability modal is neither. `PlusFormula.stab φ` is **same-time and cross-index**: it relates
a label at `(i, u)` to labels at `(j, u)` for every `j` naming the same world state at `u`. A
sixth clause here modelled on `box` would be a strictly weaker, wrongly-shaped condition wearing
the right name, and stating it twice would leave the weak copy as the one a consumer reaches for.

The condition therefore lives on its own, as (C5) `StabFaithful`, further down this module.

## Why (C0) is mandatory here

The branching model's valuation is a `Quotient.lift` over `share`-classes, so without atom
coherence it is not well defined. The deterministic device could leave atoms unconstrained
because its states are index/time pairs with no quotient; this one cannot.

## Main Definitions

- `PlusSharingWitnessFamily.PlusAtomCoherent` — (C0) atoms agree across a shared state
- `PlusSharingWitnessFamily.PlusLocalCoherentShare` — (C1') local coherence across the branching
- `PlusSharingWitnessFamily.PlusThreadFulfilling` — (C2') every thread discharges its eventualities
- `PlusWitnessFamily.PlusBoxFaithful` — (C3) the box guess is exactly global label membership
- `PlusWitnessFamily.PlusTarget` — (C4) a time on the main lasso witnessing the consequence

## Main Results

- `PlusSharingWitnessFamily.plusUntl_self_of_share` — the reflexive instance of the `untl` clause
- `PlusSharingWitnessFamily.plusSnce_self_of_share` — the reflexive instance of the `snce` clause
- `PlusSharingWitnessFamily.plusLocalCoherentLab_of_share` — (C1') implies its one-position form
- `PlusSharingWitnessFamily.plusFulfillingLab_of_thread` — (C2') implies its per-lasso form
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage FormalSystem.Syntax

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/--
**(C0) Atom coherence.** Indices naming the same state at a time carry the same atoms.

Mandatory, and the reason is structural: the branching model's valuation is a `Quotient.lift`
over `share`-classes, so without this it is not well defined.
-/
def PlusAtomCoherent (S : PlusSharingWitnessFamily Γ Del) : Prop :=
  ∀ (u : ℤ) (i j : Fin S.lassos.length), S.share u i j →
    ∀ p : Atom, (PlusFormula.atom p ∈ S.L i u ↔ PlusFormula.atom p ∈ S.L j u)

/--
**(C1') Local coherence across the branching.**

Five clauses: `bot`, `imp` and `box` are one-position conditions; the `untl` unfolding is taken
against every successor index sharing the state at `t + 1`, and the `snce` unfolding against
every predecessor index sharing the state at `t`.

There is no `stab` clause, by design — see this module's header.
-/
def PlusLocalCoherentShare (S : PlusSharingWitnessFamily Γ Del) : Prop :=
  ∀ (i : Fin S.lassos.length) (t : ℤ),
    (PlusFormula.bot ∉ S.L i t) ∧
    (∀ a b : PlusFormula, PlusFormula.imp a b ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.imp a b ∈ S.L i t ↔ (a ∈ S.L i t → b ∈ S.L i t))) ∧
    (∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.box χ ∈ S.L i t ↔ S.bx χ = true)) ∧
    (∀ j : Fin S.lassos.length, S.share (t + 1) i j →
      ∀ g e : PlusFormula, PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.untl g e ∈ S.L i t ↔
          (e ∈ S.L j (t + 1) ∨ (g ∈ S.L j (t + 1) ∧ PlusFormula.untl g e ∈ S.L j (t + 1))))) ∧
    (∀ k : Fin S.lassos.length, S.share t i k →
      ∀ g e : PlusFormula, PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.snce g e ∈ S.L i t ↔
          (e ∈ S.L k (t - 1) ∨ (g ∈ S.L k (t - 1) ∧ PlusFormula.snce g e ∈ S.L k (t - 1)))))

/-- The one-position `untl` clause, as the reflexive instance of the branching one. -/
theorem plusUntl_self_of_share {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) (i : Fin S.lassos.length) (t : ℤ) (g e : PlusFormula)
    (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.untl g e ∈ S.L i t ↔
      (e ∈ S.L i (t + 1) ∨ (g ∈ S.L i (t + 1) ∧ PlusFormula.untl g e ∈ S.L i (t + 1))) :=
  (h i t).2.2.2.1 i (S.share_refl (t + 1) i) g e hc

/-- The one-position `snce` clause, as the reflexive instance of the branching one. -/
theorem plusSnce_self_of_share {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) (i : Fin S.lassos.length) (t : ℤ) (g e : PlusFormula)
    (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.snce g e ∈ S.L i t ↔
      (e ∈ S.L i (t - 1) ∨ (g ∈ S.L i (t - 1) ∧ PlusFormula.snce g e ∈ S.L i (t - 1))) :=
  (h i t).2.2.2.2 i (S.share_refl t i) g e hc

/-!
## (C2'), (C3), (C4), and the two reductions

(C3) and (C4) belong to `PlusWitnessFamily`, not to the branching extension: neither mentions
`share`. (C2') belongs to the extension, because its quantifier ranges over threads.

The two "deterministic-shaped" conditions below — `PlusLocalCoherentLab` and `PlusFulfillingLab`
— are the one-position and per-lasso forms of (C1') and (C2'). They are stated here not because
an L⁺ deterministic certificate exists (it does not; nothing on the L⁺ side ships a JSON export)
but because the reductions to them are the mechanical statement of the claim that the branching
conditions are *strengthenings* rather than replacements. Each reduction is one instantiation:
`share_refl` for (C1'), `Thread.const` for (C2'). The converses are false, and that is the point
of the branching device.
-/

/--
**(C2') Thread fulfilment.**

The per-lasso fulfilment condition with the lasso quantifier replaced by a quantifier over
**every thread** through the position: an eventuality labelled at `(i, u)` must be discharged
along every history that passes through that state, not merely along the lasso it is written
on. This is `A[g U e]` (resp. its past mirror) at the position.

Stated over all `g` and `e` rather than over closure members only: labels are subsets of the
closure anyway (`PlusWitnessFamily.subset_plusClosureOf`), so the extra generality costs nothing
and saves a side condition at every use site.
-/
def PlusThreadFulfilling (S : PlusSharingWitnessFamily Γ Del) : Prop :=
  (∀ (i : Fin S.lassos.length) (u : ℤ) (g e : PlusFormula), PlusFormula.untl g e ∈ S.L i u →
      ∀ θ : S.Thread, θ.idx u = i →
        ∃ s : ℤ, u < s ∧ e ∈ S.L (θ.idx s) s ∧
          ∀ r : ℤ, u < r → r < s → g ∈ S.L (θ.idx r) r) ∧
  (∀ (i : Fin S.lassos.length) (u : ℤ) (g e : PlusFormula), PlusFormula.snce g e ∈ S.L i u →
      ∀ θ : S.Thread, θ.idx u = i →
        ∃ s : ℤ, s < u ∧ e ∈ S.L (θ.idx s) s ∧
          ∀ r : ℤ, s < r → r < u → g ∈ S.L (θ.idx r) r)

end PlusSharingWitnessFamily

namespace PlusWitnessFamily

variable {Γ Del : PlusContext}

/--
**Local coherence on labels**, the one-position form.

The shape (C1') strengthens: every clause read at a single index rather than across the
`share`-class. Every clause is a biconditional, which is what makes a label negation-complete
over the closure with no maximal-consistent-set machinery.
-/
def PlusLocalCoherentLab (W : PlusWitnessFamily Γ Del) : Prop :=
  ∀ (i : Fin W.lassos.length) (t : ℤ),
    (PlusFormula.bot ∉ W.L i t) ∧
    (∀ a b : PlusFormula, PlusFormula.imp a b ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.imp a b ∈ W.L i t ↔ (a ∈ W.L i t → b ∈ W.L i t))) ∧
    (∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.box χ ∈ W.L i t ↔ W.bx χ = true)) ∧
    (∀ g e : PlusFormula, PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.untl g e ∈ W.L i t ↔
          (e ∈ W.L i (t + 1) ∨ (g ∈ W.L i (t + 1) ∧ PlusFormula.untl g e ∈ W.L i (t + 1))))) ∧
    (∀ g e : PlusFormula, PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.snce g e ∈ W.L i t ↔
          (e ∈ W.L i (t - 1) ∨ (g ∈ W.L i (t - 1) ∧ PlusFormula.snce g e ∈ W.L i (t - 1)))))

/-- **Fulfilment**, the per-lasso form: the shape (C2') strengthens. -/
def PlusFulfillingLab (W : PlusWitnessFamily Γ Del) : Prop :=
  (∀ (i : Fin W.lassos.length) (t : ℤ) (g e : PlusFormula), PlusFormula.untl g e ∈ W.L i t →
      ∃ s : ℤ, t < s ∧ e ∈ W.L i s ∧ ∀ r : ℤ, t < r → r < s → g ∈ W.L i r) ∧
  (∀ (i : Fin W.lassos.length) (t : ℤ) (g e : PlusFormula), PlusFormula.snce g e ∈ W.L i t →
      ∃ s : ℤ, s < t ∧ e ∈ W.L i s ∧ ∀ r : ℤ, s < r → r < t → g ∈ W.L i r)

/--
**(C3) Box faithfulness**: the box guess is exactly global label membership.

For every `□χ` in the target closure, `bx χ` is `true` precisely when `χ` is labelled at every
position of every lasso. Reused verbatim in shape from the `Formula` side, because the truth of
a boxed formula is independent of both history and time — which is exactly what is *not* true of
the stability modal, and why (C5) cannot be a Boolean guess.
-/
def PlusBoxFaithful (W : PlusWitnessFamily Γ Del) : Prop :=
  ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
    (W.bx χ = true ↔ ∀ (i : Fin W.lassos.length) (t : ℤ), χ ∈ W.L i t)

/--
**(C4) The target**: a time on the main lasso at which every premise is labelled and no
conclusion is.

Read on lasso `0` only. The other lassos exist to witness the box clause, not the consequence.
-/
def PlusTarget (W : PlusWitnessFamily Γ Del) (t : ℤ) : Prop :=
  (∀ γ ∈ Γ, γ ∈ W.main t) ∧ (∀ σ ∈ Del, σ ∉ W.main t)

end PlusWitnessFamily

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/--
**(C1') implies its one-position form.** Instantiating the successor and predecessor quantifiers
at the index itself — legitimate because `share` is reflexive — recovers the one-position
condition on the underlying family verbatim.
-/
theorem plusLocalCoherentLab_of_share {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) : S.toPlusWitnessFamily.PlusLocalCoherentLab := by
  intro i t
  obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := h i t
  exact ⟨hbot, himp, hbox, huntl i (S.share_refl (t + 1) i), hsnce i (S.share_refl t i)⟩

/--
**(C2') implies its per-lasso form.** Instantiating the thread quantifier at the constant thread
— legitimate because staying on one lasso is always a thread — recovers the per-lasso condition
on the underlying family verbatim. The converse is false, and that is the point of the branching
device.
-/
theorem plusFulfillingLab_of_thread {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusThreadFulfilling) : S.toPlusWitnessFamily.PlusFulfillingLab := by
  refine ⟨fun i t g e hmem => ?_, fun i t g e hmem => ?_⟩
  · obtain ⟨s, hs, hes, hgs⟩ := h.1 i t g e hmem (Thread.const S i) rfl
    exact ⟨s, hs, hes, hgs⟩
  · obtain ⟨s, hs, hes, hgs⟩ := h.2 i t g e hmem (Thread.const S i) rfl
    exact ⟨s, hs, hes, hgs⟩

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
