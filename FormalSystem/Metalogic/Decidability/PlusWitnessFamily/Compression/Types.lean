/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Predicates
import FormalSystem.PlusLanguage.PlusTruth

/-!
# The Presentation-Free L⁺ Type of a Model Position

The L⁺ twin of `WitnessFamily/Compression/Types.lean`. The compression half of the L⁺ witness
family route starts from an arbitrary `FrameOver intOrder` countermodel, so there is no
`IntPresentation` to read a type through: the type map is stated at that model directly and
filtered through `plusClosureOf (Γ ++ Del)`.

## What the model side does *not* need

The model layer is shared verbatim with the `Formula` side and nothing is re-indexed there.
`PlusValidInt` quantifies over the same `FrameOver intOrder`, the same `TaskModel` and the same
`WorldHistory` the `Formula` side uses; only the truth predicate differs, `PlusTruthAt` in place
of `TruthAt`. So this module re-indexes a *filter predicate*, not a semantics.

## The two sequence-level predicates carry no `stab` clause

`PlusLocalCoherentSeqLab` and `PlusFulfillingSeqLab` are `PlusWitnessFamily.PlusLocalCoherentLab`
and `PlusFulfillingLab` with the `Fin W.lassos.length` index dropped, stated at a bare
`ℤ → Finset PlusFormula` because the compression assembles label sequences long before any
`PlusWitnessFamily` exists to index them.

`PlusLocalCoherentSeqLab` has the same **five** clauses the `Formula`-side
`LocalCoherentSeqLab` has, and for the same reason (C1') has five: `⊡` is not an eventuality and
has no one-step unfolding, so it contributes no clause here. (C5) is where the stability modal is
discharged, and (C5) is a *family* condition — it quantifies across the `share`-class at one
time — so it cannot be stated at a bare label sequence at all. This is the Phase 2 scope
hypothesis confirmed rather than assumed: the L⁺ transcription adds no clause to either
predicate.

## Three supporting truth lemmas, added here

The `Formula`-side transcription consumes `Truth.box_const`, `truth_untl_succ` and
`truth_snce_pred`. None has an L⁺ counterpart anywhere in the tree, so the three are proved here
rather than silently worked around:

- `plusBox_const` — box truth is independent of both history and time
- `plusTruth_untl_succ` / `plusTruth_snce_pred` — the exact one-step unfoldings over ℤ

They are stated at the L⁺ semantics and at the same generality their `Formula` counterparts have.
`plusBox_const` is general in the frame, because `plusTruthAt_timeShift` already is; the two
unfoldings are stated over `FrameOver intOrder`, exactly as `BiLasso/Unfold.lean` states theirs.

## Main Definitions

- `plusTypeAtM` — the L⁺ type of a position of an arbitrary ℤ-frame model
- `PlusLocalCoherentSeqLab` — `PlusLocalCoherentLab` at a bare label sequence
- `PlusFulfillingSeqLab` — `PlusFulfillingLab` at a bare label sequence

## Main Results

- `mem_plusTypeAtM` — membership unfolds to closure membership plus L⁺ truth
- `plusTypeAtM_subset` — every type is a closure subset
- `plusTypeAtM_localCoherentSeqLab` — a genuine history's type sequence is locally coherent
- `plusTypeAtM_fulfillingSeqLab` — a genuine history's type sequence is fulfilling

Argument order is **guard first** throughout: `PlusFormula.untl g e` and `PlusFormula.snce g e`
have guard `g` and event `e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage FormalSystem.Semantics

variable {Γ Del : PlusContext}

/-! ## Three supporting L⁺ truth lemmas -/

/--
**L⁺ box truth is independent of both history and time.**

The L⁺ twin of `Truth.box_const`, and it splits the same way. History-independence is
definitional: `PlusTruthAt`'s `box` clause is `∀ σ, PlusTruthAt M σ t φ` and simply does not
mention `τ`. Time-independence is time-homogeneity, transported by `plusTruthAt_timeShift`.

This is what makes the box clause of the compression's local-coherence lemma routine: the box
guess `bx` is a single Boolean per formula, and it can be because the box predicate is constant
across the whole model.
-/
theorem plusBox_const {F : TaskFrame} (M : TaskModel F) (τ σ : WorldHistory F)
    (t s : F.Duration) (χ : PlusFormula) :
    PlusTruthAt M τ t (.box χ) ↔ PlusTruthAt M σ s (.box χ) := by
  constructor
  · intro h ρ
    have h1 := (plusTruthAt_timeShift M χ ρ t (s - t)).mp (h (ρ.timeShift (s - t)))
    rwa [add_sub_cancel] at h1
  · intro h ρ
    have h1 := (plusTruthAt_timeShift M χ ρ s (t - s)).mp (h (ρ.timeShift (t - s)))
    rwa [add_sub_cancel] at h1

section Unfolding

variable {F : FrameOver intOrder} {M : TaskModel F} {τ : WorldHistory F}

/--
**The exact one-step unfolding of L⁺ `untl` over ℤ**, the twin of `truth_untl_succ`.

`untl g e` holds at `t` exactly when either the event `e` is already true at `t + 1`, or the
guard `g` holds at `t + 1` and the eventuality is passed on to `t + 1`. `PlusTruthAt`'s `untl`
clause is `TruthAt`'s verbatim, so the argument is the `Formula`-side one with the truth
predicate changed.
-/
theorem plusTruth_untl_succ (t : ℤ) (g e : PlusFormula) :
    PlusTruthAt M τ t (PlusFormula.untl g e) ↔
      PlusTruthAt M τ (t + 1) e ∨
        (PlusTruthAt M τ (t + 1) g ∧ PlusTruthAt M τ (t + 1) (PlusFormula.untl g e)) := by
  constructor
  · rintro ⟨s, hts, hse, hguard⟩
    have hts' : @LT.lt ℤ _ t s := hts
    replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → @LT.lt ℤ _ r s → PlusTruthAt M τ r g := hguard
    rcases eq_or_lt_of_le (show @LE.le ℤ _ (t + 1) s by omega) with heq | hlt
    · exact Or.inl (heq ▸ hse)
    · refine Or.inr ⟨hguard (t + 1) (by omega) hlt, s, hlt, hse, ?_⟩
      intro r hr1 hr2
      have h1 : @LT.lt ℤ _ (t + 1) r := hr1
      have h2 : @LT.lt ℤ _ r s := hr2
      exact hguard r (by omega) h2
  · rintro (h | ⟨hg, s, hts, hse, hguard⟩)
    · refine ⟨t + 1, ?_, h, ?_⟩
      · change @LT.lt ℤ _ t (t + 1)
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ t r := hr1
        have h2 : @LT.lt ℤ _ r (t + 1) := hr2
        exact absurd (show False by omega) not_false
    · have hts' : @LT.lt ℤ _ (t + 1) s := hts
      replace hguard :
          ∀ r : ℤ, @LT.lt ℤ _ (t + 1) r → @LT.lt ℤ _ r s → PlusTruthAt M τ r g := hguard
      refine ⟨s, ?_, hse, ?_⟩
      · change @LT.lt ℤ _ t s
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ t r := hr1
        have h2 : @LT.lt ℤ _ r s := hr2
        rcases eq_or_lt_of_le (show @LE.le ℤ _ (t + 1) r by omega) with heq | hlt
        · exact heq ▸ hg
        · exact hguard r hlt h2

/--
**The exact one-step unfolding of L⁺ `snce` over ℤ**, the leftward mirror.

Proved directly rather than by a duality transport, for the same reason the `Formula`-side
mirror is: `time_reflection` is a statement about derivability, not about `PlusTruthAt`, so it
does not apply, and "by symmetry" is not a proof.
-/
theorem plusTruth_snce_pred (t : ℤ) (g e : PlusFormula) :
    PlusTruthAt M τ t (PlusFormula.snce g e) ↔
      PlusTruthAt M τ (t - 1) e ∨
        (PlusTruthAt M τ (t - 1) g ∧ PlusTruthAt M τ (t - 1) (PlusFormula.snce g e)) := by
  constructor
  · rintro ⟨s, hst, hse, hguard⟩
    have hst' : @LT.lt ℤ _ s t := hst
    replace hguard : ∀ r : ℤ, @LT.lt ℤ _ s r → @LT.lt ℤ _ r t → PlusTruthAt M τ r g := hguard
    rcases eq_or_lt_of_le (show @LE.le ℤ _ s (t - 1) by omega) with heq | hlt
    · exact Or.inl (heq ▸ hse)
    · refine Or.inr ⟨hguard (t - 1) hlt (by omega), s, hlt, hse, ?_⟩
      intro r hr1 hr2
      have h1 : @LT.lt ℤ _ s r := hr1
      have h2 : @LT.lt ℤ _ r (t - 1) := hr2
      exact hguard r h1 (by omega)
  · rintro (h | ⟨hg, s, hst, hse, hguard⟩)
    · refine ⟨t - 1, ?_, h, ?_⟩
      · change @LT.lt ℤ _ (t - 1) t
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ (t - 1) r := hr1
        have h2 : @LT.lt ℤ _ r t := hr2
        exact absurd (show False by omega) not_false
    · have hst' : @LT.lt ℤ _ s (t - 1) := hst
      replace hguard :
          ∀ r : ℤ, @LT.lt ℤ _ s r → @LT.lt ℤ _ r (t - 1) → PlusTruthAt M τ r g := hguard
      refine ⟨s, ?_, hse, ?_⟩
      · change @LT.lt ℤ _ s t
        omega
      · intro r hr1 hr2
        have h1 : @LT.lt ℤ _ s r := hr1
        have h2 : @LT.lt ℤ _ r t := hr2
        rcases eq_or_lt_of_le (show @LE.le ℤ _ r (t - 1) by omega) with heq | hlt
        · exact heq ▸ hg
        · exact hguard r h1 hlt

end Unfolding

/-! ## The L⁺ type map -/

/--
The L⁺ type of a position of an arbitrary ℤ-frame model, at the `PlusWitnessFamily` closure.

`typeAtM` with `TruthAt` replaced by `PlusTruthAt` and `closureOf` by `plusClosureOf`.
Noncomputable because the filter predicate is truth in an arbitrary model; that costs nothing,
because no enumerated object is ever built from this map — only the *bounds* it justifies are.
-/
noncomputable def plusTypeAtM {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : PlusContext) (τ : WorldHistory F.toTaskFrame) (u : ℤ) : Finset PlusFormula :=
  @Finset.filter PlusFormula (fun ψ => PlusTruthAt M τ u ψ) (Classical.decPred _)
    (plusClosureOf (Γ ++ Del))

theorem mem_plusTypeAtM {F : FrameOver intOrder} {M : TaskModel F.toTaskFrame}
    {τ : WorldHistory F.toTaskFrame} {u : ℤ} {ψ : PlusFormula} :
    ψ ∈ plusTypeAtM M Γ Del τ u ↔ ψ ∈ plusClosureOf (Γ ++ Del) ∧ PlusTruthAt M τ u ψ := by
  simp only [plusTypeAtM, Finset.mem_filter]

/-- Every L⁺ type is a subset of the target closure — the `PlusLabelledLasso.label_sub`
obligation. -/
theorem plusTypeAtM_subset {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : PlusContext) (τ : WorldHistory F.toTaskFrame) (u : ℤ) :
    plusTypeAtM M Γ Del τ u ⊆ plusClosureOf (Γ ++ Del) :=
  fun _ hψ => (mem_plusTypeAtM.mp hψ).1

/-! ## The two sequence-level predicates -/

/--
`PlusWitnessFamily.PlusLocalCoherentLab` at a bare label sequence, with the lasso index dropped.

The five clauses are verbatim those of `PlusLocalCoherentLab`, with `W.L i t` replaced by
`lab t`. The closure guard `plusClosureOf (Γ ++ Del)` is kept, so the predicate is stated against
the same target a family is. There is no sixth clause: see this module's header.
-/
def PlusLocalCoherentSeqLab (Γ Del : PlusContext) (bx : PlusFormula → Bool)
    (lab : ℤ → Finset PlusFormula) : Prop :=
  ∀ t : ℤ,
    (PlusFormula.bot ∉ lab t) ∧
    (∀ a b : PlusFormula, PlusFormula.imp a b ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.imp a b ∈ lab t ↔ (a ∈ lab t → b ∈ lab t))) ∧
    (∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.box χ ∈ lab t ↔ bx χ = true)) ∧
    (∀ g e : PlusFormula, PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.untl g e ∈ lab t ↔
          (e ∈ lab (t + 1) ∨ (g ∈ lab (t + 1) ∧ PlusFormula.untl g e ∈ lab (t + 1))))) ∧
    (∀ g e : PlusFormula, PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.snce g e ∈ lab t ↔
          (e ∈ lab (t - 1) ∨ (g ∈ lab (t - 1) ∧ PlusFormula.snce g e ∈ lab (t - 1)))))

/--
`PlusWitnessFamily.PlusFulfillingLab` at a bare label sequence, with the lasso index dropped.

As there, stated over **all** `g` and `e` rather than over closure members only: labels are
closure subsets anyway, so the extra generality costs nothing and saves a side condition at
every use site.
-/
def PlusFulfillingSeqLab (lab : ℤ → Finset PlusFormula) : Prop :=
  (∀ (t : ℤ) (g e : PlusFormula), PlusFormula.untl g e ∈ lab t →
      ∃ s : ℤ, t < s ∧ e ∈ lab s ∧ ∀ r : ℤ, t < r → r < s → g ∈ lab r) ∧
  (∀ (t : ℤ) (g e : PlusFormula), PlusFormula.snce g e ∈ lab t →
      ∃ s : ℤ, s < t ∧ e ∈ lab s ∧ ∀ r : ℤ, s < r → r < t → g ∈ lab r)

/-! ## A genuine history's L⁺ type sequence satisfies both -/

/--
**The five local-coherence clauses hold of the L⁺ type sequence of a genuine history.**

The box clause is where the model's globality enters: `plusBox_const` makes the truth of a boxed
L⁺ formula independent of both history and time, so "`□χ` is in the type here" and "`χ` is true
everywhere" are the same statement, which is exactly what the box guess `bx` is required to
report.
-/
theorem plusTypeAtM_localCoherentSeqLab {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Γ Del : PlusContext) (bx : PlusFormula → Bool)
    (hbx : ∀ χ : PlusFormula, bx χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), PlusTruthAt M σ v χ)
    (τ : WorldHistory F.toTaskFrame) :
    PlusLocalCoherentSeqLab Γ Del bx (plusTypeAtM M Γ Del τ) := by
  intro t
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro h
    exact PlusTruth.bot_false M τ t (mem_plusTypeAtM.mp h).2
  · intro a b hab
    rw [mem_plusTypeAtM]
    constructor
    · rintro ⟨-, himp⟩ ha
      exact mem_plusTypeAtM.mpr ⟨plusClosureOf_imp_right hab,
        (PlusTruth.imp_iff M τ t a b).mp himp (mem_plusTypeAtM.mp ha).2⟩
    · intro h
      refine ⟨hab, (PlusTruth.imp_iff M τ t a b).mpr ?_⟩
      intro hta
      exact (mem_plusTypeAtM.mp (h (mem_plusTypeAtM.mpr ⟨plusClosureOf_imp_left hab, hta⟩))).2
  · intro χ hχ
    rw [mem_plusTypeAtM]
    constructor
    · rintro ⟨-, hb⟩
      refine (hbx χ).mpr ?_
      intro σ v
      have h2 : PlusTruthAt M σ v (PlusFormula.box χ) := (plusBox_const M τ σ t v χ).mp hb
      exact (PlusTruth.box_iff M σ v χ).mp h2 σ
    · intro hb
      exact ⟨hχ, (PlusTruth.box_iff M τ t χ).mpr (fun σ => (hbx χ).mp hb σ t)⟩
  · intro g e hge
    rw [mem_plusTypeAtM, mem_plusTypeAtM, mem_plusTypeAtM, mem_plusTypeAtM]
    constructor
    · rintro ⟨-, hu⟩
      rcases (plusTruth_untl_succ (M := M) (τ := τ) t g e).mp hu with h | ⟨hg, hu'⟩
      · exact Or.inl ⟨plusClosureOf_untl_left hge, h⟩
      · exact Or.inr ⟨⟨plusClosureOf_untl_right hge, hg⟩, ⟨hge, hu'⟩⟩
    · intro h
      refine ⟨hge, (plusTruth_untl_succ (M := M) (τ := τ) t g e).mpr ?_⟩
      rcases h with ⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hu⟩⟩
      · exact Or.inl he
      · exact Or.inr ⟨hg, hu⟩
  · intro g e hge
    rw [mem_plusTypeAtM, mem_plusTypeAtM, mem_plusTypeAtM, mem_plusTypeAtM]
    constructor
    · rintro ⟨-, hs⟩
      rcases (plusTruth_snce_pred (M := M) (τ := τ) t g e).mp hs with h | ⟨hg, hs'⟩
      · exact Or.inl ⟨plusClosureOf_snce_left hge, h⟩
      · exact Or.inr ⟨⟨plusClosureOf_snce_right hge, hg⟩, ⟨hge, hs'⟩⟩
    · intro h
      refine ⟨hge, (plusTruth_snce_pred (M := M) (τ := τ) t g e).mpr ?_⟩
      rcases h with ⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hs⟩⟩
      · exact Or.inl he
      · exact Or.inr ⟨hg, hs⟩

/--
**Fulfilment of the L⁺ type sequence of a genuine history.**

Both halves come straight from the truth clause for the corresponding connective: a genuine
model discharges its own eventualities, with the interval guard already in the clause.
-/
theorem plusTypeAtM_fulfillingSeqLab {F : FrameOver intOrder} {M : TaskModel F.toTaskFrame}
    (Γ Del : PlusContext) (τ : WorldHistory F.toTaskFrame) :
    PlusFulfillingSeqLab (plusTypeAtM M Γ Del τ) := by
  constructor
  · intro t g e hmem
    obtain ⟨hcl, hu⟩ := mem_plusTypeAtM.mp hmem
    obtain ⟨s, hts, hse, hguard⟩ := hu
    refine ⟨s, hts, mem_plusTypeAtM.mpr ⟨plusClosureOf_untl_left hcl, hse⟩, ?_⟩
    intro r hr1 hr2
    exact mem_plusTypeAtM.mpr ⟨plusClosureOf_untl_right hcl, hguard r hr1 hr2⟩
  · intro t g e hmem
    obtain ⟨hcl, hs⟩ := mem_plusTypeAtM.mp hmem
    obtain ⟨s, hst, hse, hguard⟩ := hs
    refine ⟨s, hst, mem_plusTypeAtM.mpr ⟨plusClosureOf_snce_left hcl, hse⟩, ?_⟩
    intro r hr1 hr2
    exact mem_plusTypeAtM.mpr ⟨plusClosureOf_snce_right hcl, hguard r hr1 hr2⟩

end FormalSystem.Metalogic.Decidability
