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

## Main Results

- `PlusSharingWitnessFamily.plusUntl_self_of_share` — the reflexive instance of the `untl` clause
- `PlusSharingWitnessFamily.plusSnce_self_of_share` — the reflexive instance of the `snce` clause
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

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
