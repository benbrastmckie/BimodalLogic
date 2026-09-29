/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Extract

/-!
# The (C5) Demand

(C5) `StabFaithful` asks that `⊡φ` be labelled at `(i, u)` exactly when `φ` is labelled at every
index naming the same world state at `u`. Neither direction is free on a compressed family, and
the two directions are not symmetric in cost:

- the **`→`** direction is a *fact about the countermodel*: `⊡` is state-determined, so any two
  positions naming one world state agree on every stability modal and on every atom, and a `⊡φ`
  that holds at one of them puts `φ` at the other. `plusTypeAtM_mem_of_stab_of_state_eq` and the
  two congruences below are that fact, in the form the assembly reads it.
- the **`←`** direction is a *demand on the index set*: a position at which `⊡φ` fails must be
  accompanied, in the family, by an index naming the same state at the same time whose label
  omits `φ`. `plusTypeAtM_stab_demand` is where that witness comes from — the countermodel always
  supplies one — and the saturation is the process of putting every such witness into the list.

This module lands the first half: the semantics of the demand, stated on `plusTypeAtM` labels so
that the family-level conditions read it directly. It is deliberately independent of *how* the
witnesses are organised into a list, because the demand is the same whichever organisation the
saturation ends up taking.

## The state signature

Two positions of the countermodel that name the same world state at the same time are
interchangeable for exactly the two conditions that quantify across a `share`-class: they carry
the same atoms (C0) and the same stability modals (C5's `→`). `plusSameState` names that relation
and the two congruences below are its content. Everything the saturation needs to know about a
position, beyond its label, is its signature in this sense.

## Main Definitions

- `plusSameState` — two histories name one world state at one time

## Main Results

- `exists_history_state_eq_of_not_stab` — the countermodel supplies the (C5) witness history
- `plusTypeAtM_stab_demand` — the same, read on labels: the `←` direction's obligation
- `plusTypeAtM_mem_of_stab_of_state_eq` — the `→` direction, on labels
- `plusTypeAtM_stab_congr_state` — stability modals are constant on a state
- `plusTypeAtM_atom_congr_state` — atoms are constant on a state

Argument order is **guard first**: `PlusFormula.untl g e`, `PlusFormula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics
open FormalSystem.Syntax

variable {F : FrameOver intOrder}

/-! ## Naming one world state -/

/--
**Two histories name the same world state at a time.**

The relation the family's `share` is built to present. It is an equivalence with nothing to
prove, being the kernel of `fun τ => τ.state w`, and it is the *only* thing about a pair of
positions that (C0) and (C5)'s `→` direction read.
-/
def plusSameState (τ σ : WorldHistory F.toTaskFrame) (w : ℤ) : Prop :=
  τ.state w = σ.state w

theorem plusSameState_refl (τ : WorldHistory F.toTaskFrame) (w : ℤ) : plusSameState τ τ w := rfl

theorem plusSameState_symm {τ σ : WorldHistory F.toTaskFrame} {w : ℤ}
    (h : plusSameState τ σ w) : plusSameState σ τ w := h.symm

theorem plusSameState_trans {τ σ ρ : WorldHistory F.toTaskFrame} {w : ℤ}
    (h₁ : plusSameState τ σ w) (h₂ : plusSameState σ ρ w) : plusSameState τ ρ w := h₁.trans h₂

/-! ## The `→` direction: `⊡` and atoms are state-determined -/

/--
**A stability modal that holds at a position holds at every position naming the same state.**

Immediate from `PlusTruth.stab_iff`: the clause quantifies over the histories through the state,
and naming the same state means the two quantifications are over the same collection.
-/
theorem plusTruthAt_stab_of_sameState (M : TaskModel F.toTaskFrame)
    {τ σ : WorldHistory F.toTaskFrame} {w : ℤ} (hs : plusSameState τ σ w) (φ : PlusFormula) :
    PlusTruthAt M τ w (PlusFormula.stab φ) ↔ PlusTruthAt M σ w (PlusFormula.stab φ) :=
  stab_state_only M τ σ w w hs φ

/--
**The `→` direction of (C5), on labels.**

If `⊡φ` is in the type of one position, then `φ` is in the type of every position naming the same
world state at the same time. `plusClosureOf_stab` supplies the closure side, so no separate
membership hypothesis on `φ` is needed.
-/
theorem plusTypeAtM_mem_of_stab_of_state_eq (M : TaskModel F.toTaskFrame) (Γ Del : PlusContext)
    {τ σ : WorldHistory F.toTaskFrame} {w : ℤ} (hs : plusSameState τ σ w) {φ : PlusFormula}
    (h : PlusFormula.stab φ ∈ plusTypeAtM M Γ Del τ w) : φ ∈ plusTypeAtM M Γ Del σ w := by
  obtain ⟨hc, ht⟩ := mem_plusTypeAtM.mp h
  refine mem_plusTypeAtM.mpr ⟨plusClosureOf_stab hc, ?_⟩
  exact (PlusTruth.stab_iff (M := M) (τ := τ) (t := w) φ).mp ht σ hs

/-- **Stability modals are constant on a world state**, read on labels. This is what makes the
left-hand side of (C5) constant on a `share`-class, which (C5) itself demands. -/
theorem plusTypeAtM_stab_congr_state (M : TaskModel F.toTaskFrame) (Γ Del : PlusContext)
    {τ σ : WorldHistory F.toTaskFrame} {w : ℤ} (hs : plusSameState τ σ w) (φ : PlusFormula) :
    (PlusFormula.stab φ ∈ plusTypeAtM M Γ Del τ w ↔
      PlusFormula.stab φ ∈ plusTypeAtM M Γ Del σ w) := by
  rw [mem_plusTypeAtM, mem_plusTypeAtM]
  exact and_congr_right fun _ => plusTruthAt_stab_of_sameState M hs φ

/-- **Atoms are constant on a world state**, read on labels. This is (C0) at the level of the
countermodel: the valuation reads the state and nothing else. -/
theorem plusTypeAtM_atom_congr_state (M : TaskModel F.toTaskFrame) (Γ Del : PlusContext)
    {τ σ : WorldHistory F.toTaskFrame} {w : ℤ} (hs : plusSameState τ σ w) (p : Atom) :
    (PlusFormula.atom p ∈ plusTypeAtM M Γ Del τ w ↔
      PlusFormula.atom p ∈ plusTypeAtM M Γ Del σ w) := by
  rw [mem_plusTypeAtM, mem_plusTypeAtM]
  refine and_congr_right fun _ => ?_
  rw [PlusTruth.atom_iff, PlusTruth.atom_iff, show τ.state w = σ.state w from hs]

/-! ## The `←` direction: the demand and its witness -/

/--
**The countermodel supplies the (C5) witness history.**

A failure of `⊡φ` at `(τ, w)` is, by the `stab` clause read contrapositively, a history through
the same world state at the same time at which `φ` fails. Nothing here is about the certificate:
this is the semantic content the saturation is obliged to reflect in the index list.
-/
theorem exists_history_state_eq_of_not_stab (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (w : ℤ) (φ : PlusFormula)
    (h : ¬ PlusTruthAt M τ w (PlusFormula.stab φ)) :
    ∃ σ : WorldHistory F.toTaskFrame, plusSameState τ σ w ∧ ¬ PlusTruthAt M σ w φ := by
  rw [PlusTruth.stab_iff] at h
  push Not at h
  obtain ⟨σ, hs, hφ⟩ := h
  exact ⟨σ, hs, hφ⟩

/--
**The (C5) demand, read on labels.**

A position whose type omits a closure member `⊡φ` is accompanied, in the countermodel, by a
position naming the same world state at the same time whose type omits `φ`. This is precisely the
obligation the `←` direction of (C5) places on the index list, and it is always dischargeable —
the difficulty of the saturation is not *finding* a witness but *bounding* how many witnesses the
list needs before it closes.

No closure hypothesis on `φ` is needed: non-membership in a type is implied by falsity alone.
-/
theorem plusTypeAtM_stab_demand (M : TaskModel F.toTaskFrame) (Γ Del : PlusContext)
    (τ : WorldHistory F.toTaskFrame) (w : ℤ) (φ : PlusFormula)
    (hc : PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Del))
    (h : PlusFormula.stab φ ∉ plusTypeAtM M Γ Del τ w) :
    ∃ σ : WorldHistory F.toTaskFrame, plusSameState τ σ w ∧
      φ ∉ plusTypeAtM M Γ Del σ w := by
  have hnt : ¬ PlusTruthAt M τ w (PlusFormula.stab φ) := fun ht =>
    h (mem_plusTypeAtM.mpr ⟨hc, ht⟩)
  obtain ⟨σ, hs, hφ⟩ := exists_history_state_eq_of_not_stab M τ w φ hnt
  exact ⟨σ, hs, fun hm => hφ (mem_plusTypeAtM.mp hm).2⟩

/--
**The demand and its witness, bundled as the biconditional (C5) will have to match.**

Read at a single position: `⊡φ` is in the type exactly when `φ` is in the type of *every*
position naming the same state at the same time. This is (C5) stated over the countermodel's own
positions rather than over a finite index list, and it is the statement the saturation has to
reproduce with the quantifier restricted to the list.
-/
theorem plusTypeAtM_stab_iff_forall_sameState (M : TaskModel F.toTaskFrame) (Γ Del : PlusContext)
    (τ : WorldHistory F.toTaskFrame) (w : ℤ) (φ : PlusFormula)
    (hc : PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Del)) :
    (PlusFormula.stab φ ∈ plusTypeAtM M Γ Del τ w ↔
      ∀ σ : WorldHistory F.toTaskFrame, plusSameState τ σ w →
        φ ∈ plusTypeAtM M Γ Del σ w) := by
  constructor
  · intro h σ hs
    exact plusTypeAtM_mem_of_stab_of_state_eq M Γ Del hs h
  · intro h
    by_contra hnm
    obtain ⟨σ, hs, hφ⟩ := plusTypeAtM_stab_demand M Γ Del τ w φ hc hnm
    exact hφ (h σ hs)

end FormalSystem.Metalogic.Decidability
