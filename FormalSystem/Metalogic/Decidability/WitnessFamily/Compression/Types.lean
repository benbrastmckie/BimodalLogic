/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Predicates
import FormalSystem.Metalogic.Decidability.BiLasso.Unfold
import FormalSystem.Semantics.TruthTransport

/-!
# The Presentation-Free Type of a Model Position

`BiLasso/SmallModel.lean`'s `typeAt` reads the type of a position *through an `IntPresentation`*:
the position is a time of a history of `P.toTaskFrame`, and the label is filtered through
`subformulaClosure φ`. The compression half of the witness-family route has no presentation to
read through — the countermodel it starts from is an arbitrary `FrameOver intOrder` model — so
the type map has to be stated at that model directly, and filtered through `closureOf (Γ ++ Del)`.

That is `typeAtM` below. It is `typeAt` with the presentation removed and the closure generalised
from one formula to a context.

## Nothing is lost by dropping the atom clause

`WitnessFamily.LocalCoherentLab` is `BiLasso.LocalCoherentSeq` minus the atom clause (see
`Predicates.lean`'s clause-by-clause table), and the atom clause is **exactly** the clause that
ever needed a presentation: it reads `P.val p (stateOf x)`. Every other clause is a statement
about labels alone. So a presentation-free type map satisfies every clause the family format
demands, and the deleted clause is one the format does not have.

## The two sequence-level predicates

`LocalCoherentSeqLab` and `FulfillingSeqLab` are `WitnessFamily.LocalCoherentLab` and
`WitnessFamily.FulfillingLab` with the `Fin W.lassos.length` index dropped — stated at a bare
label sequence `ℤ → Finset Formula`, because the compression assembles label sequences long
before any `WitnessFamily` exists to index them. The lifting back across the lasso index is a
one-liner at the point of assembly.

## Deliberate duplication against `BiLasso/SmallModel.lean`

`typeAtM` duplicates `typeAt`, and `LocalCoherentSeqLab` duplicates `LocalCoherentSeq` minus its
atom clause. The duplication is recorded rather than hidden, exactly as `WitnessFamily/Basic.lean`
and `WitnessFamily/Decide.lean` record theirs. **The trigger that retires it**: once a shared
periodic-label presentation lands, both should be redefined as its two instances and the
duplicated clause list deleted. That refactor belongs to whichever task owns the shared
abstraction.

## Main Definitions

- `typeAtM` — the type of a position of an arbitrary ℤ-frame model, at the certificate closure
- `LocalCoherentSeqLab` — `LocalCoherentLab` at a bare label sequence
- `FulfillingSeqLab` — `FulfillingLab` at a bare label sequence

## Main Results

- `mem_typeAtM` — membership in a type unfolds to closure membership plus truth
- `typeAtM_subset` — every type is a closure subset
- `typeAtM_localCoherentSeqLab` — a genuine history's type sequence is locally coherent
- `typeAtM_fulfillingSeqLab` — a genuine history's type sequence is fulfilling

Argument order is **guard first** throughout: `Formula.untl g e` and `Formula.snce g e` have
guard `g` and event `e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

variable {Γ Del : Context}

/-! ## The type map -/

/--
The type of a position of an arbitrary ℤ-frame model, at the `WitnessFamily` closure.

`BiLasso/SmallModel.lean`'s `typeAt` with the presentation removed and the closure generalised
from `subformulaClosure φ` to `closureOf (Γ ++ Del)`. Noncomputable because the filter predicate
is truth in an arbitrary model; that costs nothing, because no enumerated object is ever built
from this map — only the *bounds* it justifies are enumerated.
-/
noncomputable def typeAtM {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (τ : WorldHistory F.toTaskFrame) (u : ℤ) : Finset Formula :=
  @Finset.filter Formula (fun ψ => TruthAt M τ u ψ) (Classical.decPred _)
    (closureOf (Γ ++ Del))

theorem mem_typeAtM {F : FrameOver intOrder} {M : TaskModel F.toTaskFrame}
    {τ : WorldHistory F.toTaskFrame} {u : ℤ} {ψ : Formula} :
    ψ ∈ typeAtM M Γ Del τ u ↔ ψ ∈ closureOf (Γ ++ Del) ∧ TruthAt M τ u ψ := by
  simp only [typeAtM, Finset.mem_filter]

/-- Every type is a subset of the target closure — the `LabelledLasso.label_sub` obligation. -/
theorem typeAtM_subset {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (τ : WorldHistory F.toTaskFrame) (u : ℤ) :
    typeAtM M Γ Del τ u ⊆ closureOf (Γ ++ Del) :=
  fun _ hψ => (mem_typeAtM.mp hψ).1

/-! ## The two sequence-level predicates -/

/--
`WitnessFamily.LocalCoherentLab` at a bare label sequence, with the lasso index dropped.

The five clauses are verbatim those of `LocalCoherentLab`, with `W.L i t` replaced by `lab t`.
The closure guard `closureOf (Γ ++ Del)` is kept, so the predicate is stated against the same
target a family is.
-/
def LocalCoherentSeqLab (Γ Del : Context) (bx : Formula → Bool)
    (lab : ℤ → Finset Formula) : Prop :=
  ∀ t : ℤ,
    (Formula.bot ∉ lab t) ∧
    (∀ a b : Formula, Formula.imp a b ∈ closureOf (Γ ++ Del) →
        (Formula.imp a b ∈ lab t ↔ (a ∈ lab t → b ∈ lab t))) ∧
    (∀ χ : Formula, Formula.box χ ∈ closureOf (Γ ++ Del) →
        (Formula.box χ ∈ lab t ↔ bx χ = true)) ∧
    (∀ g e : Formula, Formula.untl g e ∈ closureOf (Γ ++ Del) →
        (Formula.untl g e ∈ lab t ↔
          (e ∈ lab (t + 1) ∨ (g ∈ lab (t + 1) ∧ Formula.untl g e ∈ lab (t + 1))))) ∧
    (∀ g e : Formula, Formula.snce g e ∈ closureOf (Γ ++ Del) →
        (Formula.snce g e ∈ lab t ↔
          (e ∈ lab (t - 1) ∨ (g ∈ lab (t - 1) ∧ Formula.snce g e ∈ lab (t - 1)))))

/--
`WitnessFamily.FulfillingLab` at a bare label sequence, with the lasso index dropped.

As there, stated over **all** `g` and `e` rather than over closure members only: labels are
closure subsets anyway, so the extra generality costs nothing and saves a side condition at
every use site.
-/
def FulfillingSeqLab (lab : ℤ → Finset Formula) : Prop :=
  (∀ (t : ℤ) (g e : Formula), Formula.untl g e ∈ lab t →
      ∃ s : ℤ, t < s ∧ e ∈ lab s ∧ ∀ r : ℤ, t < r → r < s → g ∈ lab r) ∧
  (∀ (t : ℤ) (g e : Formula), Formula.snce g e ∈ lab t →
      ∃ s : ℤ, s < t ∧ e ∈ lab s ∧ ∀ r : ℤ, s < r → r < t → g ∈ lab r)

/-! ## A genuine history's type sequence satisfies both -/

/--
**The five local-coherence clauses hold of the type sequence of a genuine history.**

The box clause is where the model's globality enters: `Truth.box_const` makes the truth of a
boxed formula independent of both history and time, so "`□χ` is in the type here" and "`χ` is
true everywhere" are the same statement, which is exactly what the box guess `bx` is required to
report.
-/
theorem typeAtM_localCoherentSeqLab {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : Context) (bx : Formula → Bool)
    (hbx : ∀ χ : Formula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) :
    LocalCoherentSeqLab Γ Del bx (typeAtM M Γ Del τ) := by
  intro t
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro h
    exact Truth.bot_false (mem_typeAtM.mp h).2
  · intro a b hab
    rw [mem_typeAtM]
    constructor
    · rintro ⟨-, himp⟩ ha
      exact mem_typeAtM.mpr ⟨closureOf_imp_right hab,
        (Truth.imp_iff a b).mp himp (mem_typeAtM.mp ha).2⟩
    · intro h
      refine ⟨hab, (Truth.imp_iff a b).mpr ?_⟩
      intro hta
      exact (mem_typeAtM.mp (h (mem_typeAtM.mpr ⟨closureOf_imp_left hab, hta⟩))).2
  · intro χ hχ
    rw [mem_typeAtM]
    constructor
    · rintro ⟨-, hb⟩
      refine (hbx χ).mpr ?_
      intro σ v
      have h2 : TruthAt M σ v (Formula.box χ) := (Truth.box_const M τ σ t v χ).mp hb
      exact (Truth.box_iff χ).mp h2 σ
    · intro hb
      exact ⟨hχ, (Truth.box_iff χ).mpr (fun σ => (hbx χ).mp hb σ t)⟩
  · intro g e hge
    rw [mem_typeAtM, mem_typeAtM, mem_typeAtM, mem_typeAtM]
    constructor
    · rintro ⟨-, hu⟩
      rcases (truth_untl_succ (M := M) (τ := τ) t g e).mp hu with h | ⟨hg, hu'⟩
      · exact Or.inl ⟨closureOf_untl_left hge, h⟩
      · exact Or.inr ⟨⟨closureOf_untl_right hge, hg⟩, ⟨hge, hu'⟩⟩
    · intro h
      refine ⟨hge, (truth_untl_succ (M := M) (τ := τ) t g e).mpr ?_⟩
      rcases h with ⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hu⟩⟩
      · exact Or.inl he
      · exact Or.inr ⟨hg, hu⟩
  · intro g e hge
    rw [mem_typeAtM, mem_typeAtM, mem_typeAtM, mem_typeAtM]
    constructor
    · rintro ⟨-, hs⟩
      rcases (truth_snce_pred (M := M) (τ := τ) t g e).mp hs with h | ⟨hg, hs'⟩
      · exact Or.inl ⟨closureOf_snce_left hge, h⟩
      · exact Or.inr ⟨⟨closureOf_snce_right hge, hg⟩, ⟨hge, hs'⟩⟩
    · intro h
      refine ⟨hge, (truth_snce_pred (M := M) (τ := τ) t g e).mpr ?_⟩
      rcases h with ⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hs⟩⟩
      · exact Or.inl he
      · exact Or.inr ⟨hg, hs⟩

/--
**Fulfilment of the type sequence of a genuine history.**

Both halves come straight from the truth clause for the corresponding connective: a genuine
model discharges its own eventualities, with the interval guard already in the clause. The
`untl` half transcribes the research spike's `typeAtM_fulfilling`; the `snce` half is its
mirror, added here.
-/
theorem typeAtM_fulfillingSeqLab {F : FrameOver intOrder} {M : TaskModel F.toTaskFrame}
    (Γ Del : Context) (τ : WorldHistory F.toTaskFrame) :
    FulfillingSeqLab (typeAtM M Γ Del τ) := by
  constructor
  · intro t g e hmem
    obtain ⟨hcl, hu⟩ := mem_typeAtM.mp hmem
    obtain ⟨s, hts, hse, hguard⟩ := hu
    refine ⟨s, hts, mem_typeAtM.mpr ⟨closureOf_untl_left hcl, hse⟩, ?_⟩
    intro r hr1 hr2
    exact mem_typeAtM.mpr ⟨closureOf_untl_right hcl, hguard r hr1 hr2⟩
  · intro t g e hmem
    obtain ⟨hcl, hs⟩ := mem_typeAtM.mp hmem
    obtain ⟨s, hst, hse, hguard⟩ := hs
    refine ⟨s, hst, mem_typeAtM.mpr ⟨closureOf_snce_left hcl, hse⟩, ?_⟩
    intro r hr1 hr2
    exact mem_typeAtM.mpr ⟨closureOf_snce_right hcl, hguard r hr1 hr2⟩

end FormalSystem.Metalogic.Decidability
