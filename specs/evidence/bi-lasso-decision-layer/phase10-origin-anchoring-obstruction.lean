/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.SmallModel

/-!
# Phase 10 Blocker: the Extracted Lasso Cannot Be Anchored at the Point of Interest

This file records, machine-checked, the obstruction that blocks Phase 10 of
`plans/05_annotated-bi-lasso-decision-layer.md` as written, together with the exact statements
involved. It contains **no `sorry`** and asserts nothing it does not prove.

## What the plan asks for

Phase 10 asks for `exists_annot_of_truth`, and Phase 12 consumes it through

```
check P w φ := decide (∃ A ∈ boundedAnnots P φ (bound P φ), A.lasso.unroll 0 = w ∧ φ ∈ A.label 0)
```

so the extracted annotated bi-lasso must carry the satisfied formula **at lasso position `0`**.

## What the planned construction produces

The construction the plan specifies is a two-sided pigeonhole on `(state, type, pending)`:
a backward repeat `c₁ < c₂ ≤ 0` and a forward repeat `0 ≤ a₁ < a₂`, assembled as
`back := path[c₁, c₂)`, `mid := path[c₂, a₁)`, `fwd := path[a₁, a₂)`.

A `BiLasso`'s decoding is periodic **immediately** to the left of its origin — there is no left
prefix, only `back` repeated — so the lasso's origin necessarily sits at the source time `c₂`.
The point of interest, source time `0`, therefore lands at lasso position `-c₂ ≥ 0`, inside the
`mid` window, and at position `0` only when `c₂ = 0`.

`origin_past_periodic` below is the structural half: **every** annotated bi-lasso has a
`|back|`-periodic past, in both its labels and its states, from the very first step left of the
origin.

## Why `c₂ = 0` cannot be demanded

`c₂ = 0` requires a source time `c₁ < 0` with the same pigeonhole datum as time `0`, i.e. a
**recurrence of the type at the point of interest**. `type_at_origin_never_recurs` exhibits a
total history of a two-state presentation and a formula in the closure whose truth set along that
history is exactly `{0}`. So the type at `0` occurs at no earlier time, no backward repeat can be
anchored at `0`, and the planned construction cannot deliver a lasso carrying the formula at
position `0`.

## What this does and does not establish

It does **not** refute `exists_annot_of_truth`. A different *history* — one whose past is built
periodically with a long enough period rather than inherited from `τ` — plausibly does satisfy
the formula at the origin of a lasso. Constructing such a history is exactly the
effective-periodic-extension problem that the concurrent frame-periodicity work is chartered for,
which plan 05 records as a coordination dependency gating nothing. On this evidence it gates
Phase 10.

Two repairs are available, and choosing between them is a planning decision, not an
implementation one:

1. **Re-shape the consumer.** Let `check` range over a position in the (already derived) finite
   window rather than only position `0`:
   `∃ A ∈ boundedAnnots …, ∃ i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A),
      A.lasso.unroll i = w ∧ φ ∈ A.label i`.
   This is decidable with the instances already landed, and `truth_along_annot` discharges the
   soundness direction at `i` exactly as it would at `0`. Phase 10 then delivers the witness at
   `-c₂` and nothing is weakened.
2. **Import periodic extension.** Establish that a satisfiable formula has a satisfying history
   whose type at the point of interest recurs in its past, and keep `check` anchored at `0`.

## The second, independent gap

Even with the anchoring repaired, Phase 10 still owes an **explicit bound**. The good-cycle
condition the extraction needs — that every eventuality carried anywhere in the extracted cycle
is discharged inside it — follows from a recurrence argument that yields existence without any
bound on `a₂ - a₁`. Recovering the plan's asserted `P.card · 2^k · 2^k` requires the Büchi
degeneralisation with a genuine `pending` component, which is not built here. `Phase10Target`
below states what remains to be proved.
-/

namespace FormalSystem.Metalogic.Decidability.Phase10Evidence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The structural half: every lasso's past is periodic from the first step -/

/--
**Every annotated bi-lasso has a `|back|`-periodic past, immediately.**

Labels and states alike, at every position strictly left of the origin and at every multiple of
the backward period. There is no prefix region on the left: a `BiLasso` is `back` repeated, then
`mid` on `[0, |mid|)`, then `fwd` repeated. This is why the extraction's origin is forced to the
backward repeat.
-/
theorem origin_past_periodic {P : IntPresentation} {φ : Formula} (A : Annot P φ) :
    ∀ t : ℤ, t < 0 →
      A.label (t - A.nb) = A.label t ∧ A.lasso.unroll (t - A.nb) = A.lasso.unroll t := by
  intro t ht
  exact ⟨A.label_sub_back_length ht, A.lasso.unroll_sub_back_length ht⟩

/-! ## The arithmetic half: a type at the origin that never recurs in the past -/

/-- The atom used by the witness. -/
def pw : Atom := Atom.mkBase "w"

/--
A two-state presentation whose adjacency relation is complete, so that **every** function
`ℤ → Fin 2` is a step path. The atom `w` holds exactly at state `1`.

Completeness of the adjacency is what lets the witness below choose a deliberately
non-recurrent path; the obstruction is about the history, not about any constraint the frame
imposes.
-/
def freePresentation : IntPresentation where
  card := 2
  card_pos := by omega
  step := fun _ _ => true
  val := fun a w => (a == pw) && (w == 1)
  fwd := fun w => ⟨w, rfl⟩
  bwd := fun w => ⟨w, rfl⟩

/-- The path that visits state `1` exactly once, at time `-5`. -/
def spikePath : ℤ → Fin freePresentation.card := fun u => if u = -5 then 1 else 0

theorem spikePath_isStepPath : IsStepPath freePresentation.toTaskFrame spikePath := by
  rw [freePresentation.isStepPath_iff]
  intro t
  rfl

/-- The total history determined by that path. -/
def spikeHF : freePresentation.toTaskFrame.HF :=
  TaskFrame.HFofStepPath freePresentation.toTaskFrame spikePath spikePath_isStepPath

/-- `prev ψ`, in the live guard-first order: guard `⊥`, event `ψ`. -/
def prev (ψ : Formula) : Formula := Formula.snce Formula.bot ψ

/-- `prev` steps truth back exactly one tick. The guard is `⊥`, so the propagation disjunct of
the one-step unfolding is dead and only the immediate-event disjunct survives. -/
theorem truth_prev {τ : WorldHistory freePresentation.toTaskFrame} (t : ℤ) (ψ : Formula) :
    TruthAt freePresentation.toModel τ t (prev ψ) ↔
      TruthAt freePresentation.toModel τ (t - 1) ψ := by
  rw [prev, truth_snce_pred]
  constructor
  · rintro (h | ⟨hb, _⟩)
    · exact h
    · exact absurd hb Truth.bot_false
  · exact fun h => Or.inl h

/-- `prev⁵ w`: true at a time exactly when `w` holds five ticks earlier. -/
def prev5 : Formula := prev (prev (prev (prev (prev (Formula.atom pw)))))

/-- The atom `w` is true along the spike history exactly at time `-5`. -/
theorem truth_atom_spike (t : ℤ) :
    TruthAt freePresentation.toModel spikeHF.val t (Formula.atom pw) ↔ t = -5 := by
  constructor
  · rintro ⟨ht, hval⟩
    by_cases h : t = -5
    · exact h
    · exfalso
      have : spikePath t = 0 := by simp [spikePath, h]
      have hv : freePresentation.val pw (spikePath t) = true := hval
      rw [this] at hv
      simp [freePresentation, pw] at hv
  · intro h
    refine ⟨trivial, ?_⟩
    have : spikePath t = 1 := by simp [spikePath, h]
    show freePresentation.val pw (spikePath t) = true
    rw [this]
    simp [freePresentation, pw]

/--
**`prev⁵ w` is true along the spike history at time `0` and at no other time.**

Five applications of `truth_prev` reduce truth at `t` to truth of the atom at `t - 5`, and the
atom holds only at `-5`.
-/
theorem truth_prev5_spike (t : ℤ) :
    TruthAt freePresentation.toModel spikeHF.val t prev5 ↔ t = 0 := by
  rw [prev5, truth_prev, truth_prev, truth_prev, truth_prev, truth_prev, truth_atom_spike]
  omega

/--
**The type at the origin recurs at no earlier time.**

`prev⁵ w` distinguishes time `0` from every strictly earlier time along this history. Since it
lies in its own subformula closure, any pigeonhole datum containing the type separates `0` from
every `u < 0`, so no backward repeat can be anchored at the point of interest.
-/
theorem type_at_origin_never_recurs :
    ∀ u : ℤ, u < 0 →
      ¬ (TruthAt freePresentation.toModel spikeHF.val u prev5 ↔
         TruthAt freePresentation.toModel spikeHF.val 0 prev5) := by
  intro u hu hiff
  have h0 : TruthAt freePresentation.toModel spikeHF.val 0 prev5 :=
    (truth_prev5_spike 0).mpr rfl
  have hu' := (truth_prev5_spike u).mp (hiff.mpr h0)
  omega

/-- The distinguishing formula is in its own closure, so it really is part of every type over
that closure. -/
theorem prev5_mem_closure : prev5 ∈ subformulaClosure prev5 :=
  self_mem_subformulaClosure prev5

/-- Stated at the level of `typeAt`: the type at the origin differs from the type at every
strictly earlier time. -/
theorem typeAt_origin_never_recurs :
    ∀ u : ℤ, u < 0 →
      typeAt freePresentation prev5 spikeHF.val u ≠
        typeAt freePresentation prev5 spikeHF.val 0 := by
  intro u hu heq
  refine type_at_origin_never_recurs u hu ?_
  constructor
  · intro h
    have : prev5 ∈ typeAt freePresentation prev5 spikeHF.val u :=
      mem_typeAt.mpr ⟨prev5_mem_closure, h⟩
    rw [heq] at this
    exact (mem_typeAt.mp this).2
  · intro h
    have : prev5 ∈ typeAt freePresentation prev5 spikeHF.val 0 :=
      mem_typeAt.mpr ⟨prev5_mem_closure, h⟩
    rw [← heq] at this
    exact (mem_typeAt.mp this).2

/-! ## What remains to be proved

`Phase10Target` is the deliverable, stated in the position-indexed shape that repair option 1
makes available. It is deliberately a `def` naming a proposition, not a theorem: nothing here
claims it.
-/

/-- The Phase 10 deliverable, in the shape that survives the anchoring obstruction. -/
def Phase10Target (P : IntPresentation) (φ : Formula) (bx : Formula → Bool) (bound : ℕ) : Prop :=
  ∀ (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ),
    TruthAt P.toModel τ t φ →
      ∃ A ∈ boundedAnnots P φ bx bound, ∃ i : ℤ,
        A.lasso.unroll i = τ.states t (hτ t) ∧ φ ∈ A.label i

/-! ## Axiom audit

No `sorryAx` in any of the four load-bearing results.
-/

#print axioms origin_past_periodic
#print axioms truth_prev5_spike
#print axioms type_at_origin_never_recurs
#print axioms typeAt_origin_never_recurs

end FormalSystem.Metalogic.Decidability.Phase10Evidence
