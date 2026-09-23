/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Int.LeastGreatest
import Mathlib.Order.SuccPred.Archimedean
import FormalSystem.Semantics.Extension.Step
import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.PartialHistoryOrder

/-!
# *Completion* — the exact frame-level condition `thm:extension` consumes

`def:frame`'s *Saturation* is eliminated at exactly one site in the whole development,
`lem:step` (`FormalSystem.Semantics.PartialHistory.step`). This module isolates the condition that
site actually needs, shows *Saturation* implies it, and shows it is **equivalent** to the one-point
extension property — so it is exactly as strong as `thm:extension` requires, and no stronger.

The condition, stated over a bare relation and with no reference to histories:

> *Completion.* `⋂_{t ∈ X} Fib(w_t, z - t) ≠ ∅` for every nonempty `X ⊆ D`, every coherent
> family `{w_t}_{t ∈ X} ⊆ W` (`w_s ⇒_{t - s} w_t` for all `s, t ∈ X`), and every `z ∈ D`.

A coherent family indexed by a nonempty `X` **is** a partial history (`def:world-history`), so the
`PartialHistory`-shaped form `Completion` and the relation-shaped form `CoherentCompletion` are
interchangeable; both are given, and `completion_iff_coherentCompletion` bridges them.

## What this module establishes

* `completion_of_onePointExtension` — the extension property gives *Completion*, at **no** frame
  constraint whatever.
* `onePointExtension_of_completion` — *Completion* plus *Seriality* plus *Limit* gives the
  one-point extension property, with **no** *Saturation* and **no** *Compositionality*.
* `completion_iff_onePointExtension` — hence the two are the same condition at any frame
  satisfying *Seriality* and *Limit*.
* `completion_of_isRegular` — *Saturation* (through the existing `lem:step`) gives *Completion*.
  This is the sole route by which *Saturation* enters.
* `extension_of_completion` — *Completion* plus *Seriality* plus *Limit* gives `thm:extension` in
  full, through the existing Zorn scaffolding (`exists_maximal_extension`), which is itself
  constraint-free.

## Discrete time: *Saturation* is redundant over `def:BX-z`'s ℤ-time

`lem:step`'s own recorded closing remark — "When the family has a `⊆`-least member, that member
already contains a candidate and *Saturation* is not needed" — is turned into a theorem in the
second half of this module. `HasNearest` names **when** the constraint family has a `⊆`-least
member: exactly when the history's domain has a nearest time on each side of the new time `z`.
`completion_of_hasNearest` then derives *Completion* from *Compositionality* and *Seriality*
alone — and, because it excludes `z ∈ dom τ` first, with **no *Limit*** either. `hasNearest_int`
and `hasNearest_of_succPred` supply the order-side hypothesis, and `extension_of_hasNearest` and
`extension_of_isZTime` close `thm:extension` over ℤ-time with **no** *Saturation*.

## This module does **not** propose changing `def:frame`

The audit's verdict is to keep all four constraints exactly as stated. `Completion` is landed here
as a **lemma about** task frames — a sharpening of what the extension chain consumes — never as a
constraint field, and never as a replacement for *Saturation* in `def:frame`. Whether the
replacement would be a *strict* weakening is the converse `Completion → Saturation`, which is left
open; see this module's `specs/` audit report for the argument and for the one probe that would
settle it.

## References

* JPL paper `lem:step`, `lem:admissible`, `lem:constraint`, `thm:extension`, `cor:occurrence`,
  `def:frame` (its *Seriality*, *Limit*, *Compositionality* and *Saturation* clauses), `def:BX-z`

## Tags

completion · saturation · extension · one-point-extension · discrete-time · lem:step
-/

namespace FormalSystem.Semantics

open TaskFrame

namespace PartialHistory

variable {F : TaskFrame}

/-! ## The two forms of *Completion* -/

/--
*Completion*, in `PartialHistory` form: every partial history admits a state consistent with all
of its own times at any prescribed further time `z`.

This is literally `(⋂₀ Constraints τ z).Nonempty` after `PartialHistory.fibers` has rewritten
constraint membership as the fiber conditions; the segment class of `def:frame`'s *Saturation*
disappears, because a constraint segment is the intersection of its two endpoint fiber conditions
(`seg_eq_inter_fib`).
-/
def Completion (F : TaskFrame) : Prop :=
  ∀ (τ : PartialHistory F) (z : F.Duration),
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u

/--
*Completion*, in bare-relation form: no notion of history is used, only a coherent family.

This is the shape in which the condition could be stated inside `def:frame` itself, were the
replacement option ever taken. It is landed here precisely so that option is expressible without
re-deriving it; the library does **not** take it.
-/
def CoherentCompletion (F : TaskFrame) : Prop :=
  ∀ (X : F.Duration → Prop), (∃ t, X t) →
    ∀ (w : (t : F.Duration) → X t → F.WorldState),
      (∀ (s t : F.Duration) (hs : X s) (ht : X t), F.TaskRel (w s hs) (t - s) (w t ht)) →
      ∀ z : F.Duration, ∃ u : F.WorldState,
        ∀ (t : F.Duration) (ht : X t), F.TaskRel (w t ht) (z - t) u

/-- The two forms are the same condition: a coherent family on a nonempty index set *is* a
partial history. -/
theorem completion_iff_coherentCompletion : Completion F ↔ CoherentCompletion F := by
  constructor
  · intro h X hX w hw z
    exact h ⟨X, hX, w, hw⟩ z
  · intro h τ z
    exact h τ.domain τ.nonempty_domain τ.states τ.respects_task z

/-! ## The one-point extension property -/

/-- The conclusion of `lem:step`, read as a property of the frame rather than as a lemma. -/
def OnePointExtension (F : TaskFrame) : Prop :=
  ∀ (τ : PartialHistory F) (z : F.Duration), ∃ σ : PartialHistory F, Extends σ τ ∧ σ.domain z

/-! ## `OnePointExtension → Completion`, with no constraint at all -/

/--
The extension property yields *Completion* **unconditionally** — no frame constraint is used.

The witness is the extending history's own state at `z`, and coherence is that history's
`respects_task` field.
-/
theorem completion_of_onePointExtension (h : OnePointExtension F) : Completion F := by
  intro τ z
  obtain ⟨σ, hext, hσz⟩ := h τ z
  refine ⟨σ.states z hσz, fun t ht => ?_⟩
  have := σ.respects_task t z (hext.subset t ht) hσz
  rwa [hext.agree t ht] at this

/-! ## `Completion → OnePointExtension`, from *Seriality* and *Limit* only -/

/--
*Completion* plus *Seriality* plus *Limit* gives the one-point extension property.

**No *Saturation*, and no *Compositionality*.** This is the `lem:admissible` argument run with the
*Completion* witness in place of the *Saturation* witness: the four pair-cases of `AdjoinRespects`
are `τ`'s own task-respect, the *Completion* fiber condition, that same condition through the
reflection law (`FrameOver.reflection_of_limit`, which costs *Limit* alone), and `lem:nullity`
(`TaskFrame.nullity_of_serial_limit`) at the new time.
-/
theorem onePointExtension_of_completion (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : Completion F) : OnePointExtension F := by
  intro τ z
  by_cases hz : τ.domain z
  · exact ⟨τ, ⟨fun _ ht => ht, fun _ _ => rfl⟩, hz⟩
  obtain ⟨u, hu⟩ := hC τ z
  have hadm : AdjoinRespects τ z u := by
    intro s t hs ht
    by_cases hsd : τ.domain s <;> by_cases htd : τ.domain t
    · rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_domain τ u htd]
      exact τ.respects_task s t hsd htd
    · obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_not_domain τ u htd]
      exact hu s hsd
    · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      rw [adjoinFun_of_not_domain τ u hsd, adjoinFun_of_domain τ u htd]
      have hconv :=
        (F.toFibre.reflection_of_limit hlim (τ.states t htd) (z - t) u).mp (hu t htd)
      rwa [neg_sub] at hconv
    · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_not_domain τ u hsd, sub_self]
      exact TaskFrame.nullity_of_serial_limit hser hlim u
  exact ⟨adjoin τ z u hadm, adjoin_extends τ z u hadm, adjoin_domain_self τ z u hadm⟩

/-- The equivalence, at any frame satisfying *Seriality* and *Limit*: *Completion* **is** the
one-point extension property. 
Paper: — (the equivalence is the audit's own; the manuscript has no anchor for it)
-/
theorem completion_iff_onePointExtension (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) : Completion F ↔ OnePointExtension F :=
  ⟨onePointExtension_of_completion hser hlim, completion_of_onePointExtension⟩

/-! ## *Saturation* implies *Completion* -/

/--
*Saturation* gives *Completion*, through the existing `lem:step`.

**This is where *Saturation* enters, and it enters nowhere else.** The proof routes through
`PartialHistory.step`, which is the sole site in the development where *Saturation* is eliminated
into a conclusion that does not itself mention *Saturation*; everything downstream of this lemma
consumes `Completion` instead.

Paper: `lem:step`
-/
theorem completion_of_isRegular [F.IsRegular] : Completion F :=
  completion_of_onePointExtension (fun τ z => step F τ z)

/-! ## `thm:extension` from *Completion* -/

/--
`thm:extension` in full, with *Saturation* replaced by *Completion*.

The Zorn scaffolding (`exists_maximal_extension`, `Semantics/PartialHistoryOrder.lean`) carries no
frame constraint, so the only inputs are *Completion*, *Seriality* and *Limit*.

**Orthogonality certificate.** This declaration elaborates with **no** `[F.IsRegular]` instance
binder at all. That is the machine-checked form of the claim that the Zorn layer and `def:frame`'s
four constraints meet only at `extension`: the order-theoretic half of the extension theorem is
constraint-free, and every constraint the theorem consumes is visible in this signature.

Paper: `thm:extension`
-/
theorem extension_of_completion (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : Completion F) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ := by
  obtain ⟨μ, hle, hmax⟩ := exists_maximal_extension τ
  have htot : μ.IsTotal := by
    intro z
    obtain ⟨σ, hext, hσz⟩ := onePointExtension_of_completion hser hlim hC μ z
    exact (le_def.mp (hmax (le_def.mpr hext))).subset z hσz
  exact ⟨⟨μ, htot⟩, le_def.mp hle⟩

/-! ## Discrete time: nearest times, and the redundancy of *Saturation* -/

/--
**Nearest times.** Every nonempty one-sided part of a subset of `D` has a nearest member.

This is a property of the linear order `D` **alone**, with no reference to any frame. `ℤ` has it
(`hasNearest_int`), and so does every successor/predecessor-Archimedean order
(`hasNearest_of_succPred`); `ℚ` and `ℝ` do not.
-/
def HasNearest (D : Type) [LinearOrder D] : Prop :=
  ∀ (X : D → Prop) (z : D),
    ((∃ t, X t ∧ t ≤ z) → ∃ t, X t ∧ t ≤ z ∧ ∀ t', X t' → t' ≤ z → t' ≤ t) ∧
    ((∃ t, X t ∧ z ≤ t) → ∃ t, X t ∧ z ≤ t ∧ ∀ t', X t' → z ≤ t' → t ≤ t')

/-- `ℤ` has nearest times: a set of integers bounded above has a greatest element, and dually. -/
theorem hasNearest_int : HasNearest ℤ := by
  intro X z
  constructor
  · rintro ⟨t₀, ht₀, hle⟩
    obtain ⟨b, hb, hmax⟩ :=
      Int.exists_greatest_of_bdd (P := fun t => X t ∧ t ≤ z) ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hle⟩
    exact ⟨b, hb.1, hb.2, fun t' h1 h2 => hmax t' ⟨h1, h2⟩⟩
  · rintro ⟨t₀, ht₀, hge⟩
    obtain ⟨b, hb, hmin⟩ :=
      Int.exists_least_of_bdd (P := fun t => X t ∧ z ≤ t) ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hge⟩
    exact ⟨b, hb.1, hb.2, fun t' h1 h2 => hmin t' ⟨h1, h2⟩⟩

/--
**Every discrete temporal order has nearest times.**

This is `HasNearest` at the successor/predecessor-Archimedean orders — exactly the class
`TaskFrame.IsZTime` (`Semantics/FrameProperty.lean`) picks out, which is `def:BX-z`'s ℤ-time.
`hasNearest_int` is the concrete instance.
-/
theorem hasNearest_of_succPred (D : Type) [LinearOrder D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] : HasNearest D := by
  intro X z
  constructor
  · rintro ⟨t₀, ht₀, hle⟩
    obtain ⟨b, hbmem, hbub⟩ :=
      BddAbove.exists_isGreatest_of_nonempty (S := {t | X t ∧ t ≤ z})
        ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hle⟩
    exact ⟨b, hbmem.1, hbmem.2, fun t' h1 h2 => hbub ⟨h1, h2⟩⟩
  · rintro ⟨t₀, ht₀, hge⟩
    obtain ⟨b, hbmem, hblb⟩ :=
      BddBelow.exists_isLeast_of_nonempty (S := {t | X t ∧ z ≤ t})
        ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hge⟩
    exact ⟨b, hbmem.1, hbmem.2, fun t' h1 h2 => hblb ⟨h1, h2⟩⟩

/--
*Completion* holds as soon as the temporal order has nearest times, given *Compositionality* and
*Seriality*.

**No *Saturation*, and — this is the sharp part — no *Limit* either.** This is `lem:step`'s own
recorded closing remark made precise: the `⊆`-least constraint is the one imposed by the nearest
domain time on each side, and *Compositionality* shows every other constraint contains it.

*Limit* drops out because the proof **excludes `z ∈ dom τ` first** (that case is discharged by
`τ`'s own state at `z`) and therefore never reaches `FrameOver.reflection` at duration zero: every
reflection it performs is at a provably nonzero duration, where the reflection law is definitional
(`TaskFrame.reflect_reflection_of_ne`). This is the one *Limit*-free route through the extension
chain in the whole tree; `Extension/Constraint.lean`'s `constraint` and `nonempty_fib_of_serial`
do **not** take it, and their docstrings record that.

Paper: `lem:step`
-/
theorem completion_of_hasNearest (hN : HasNearest F.Duration)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel) :
    Completion F := by
  have hfwd := TaskFrame.forward_of_comp hcomp
  have hint := TaskFrame.interpolates_of_comp hcomp
  intro τ z
  by_cases hzd : τ.domain z
  · -- `z` is already a domain time: its own state is the witness.
    exact ⟨τ.states z hzd, fun t ht => τ.respects_task t z ht hzd⟩
  -- Reflection at a nonzero duration is definitional; `z ∉ dom τ` keeps every duration nonzero.
  have hrefl : ∀ (t : F.Duration) (ht : τ.domain t) (u : F.WorldState),
      F.TaskRel u (t - z) (τ.states t ht) → F.TaskRel (τ.states t ht) (z - t) u := by
    intro t ht u h
    have hne : t - z ≠ 0 := sub_ne_zero_of_ne (fun hEq => hzd (hEq ▸ ht))
    have := (TaskFrame.reflect_reflection_of_ne (P := F.toFibre.PosRel) hne).mp h
    rwa [neg_sub] at this
  obtain ⟨hlow, hhigh⟩ := hN τ.domain z
  by_cases hbelow : ∃ t, τ.domain t ∧ t ≤ z
  · obtain ⟨tm, htm, htmz, htmax⟩ := hlow hbelow
    by_cases habove : ∃ t, τ.domain t ∧ z ≤ t
    · -- Two-sided: the straddling segment is the `⊆`-least constraint; interpolation fills it.
      obtain ⟨tp, htp, hztp, htmin⟩ := hhigh habove
      have hspan : F.TaskRel (τ.states tm htm) ((z - tm) + (tp - z)) (τ.states tp htp) := by
        have hsum : (z - tm) + (tp - z) = tp - tm := by abel
        rw [hsum]
        exact τ.respects_task tm tp htm htp
      obtain ⟨u, hu₁, hu₂⟩ :=
        hint (τ.states tm htm) (τ.states tp htp) (z - tm) (tp - z)
          (sub_nonneg.mpr htmz) (sub_nonneg.mpr hztp) hspan
      refine ⟨u, fun t ht => ?_⟩
      rcases le_total t z with htz | hzt
      · -- below: compose `τ(t) ⇒_{tm - t} τ(tm)` with `τ(tm) ⇒_{z - tm} u`
        have h1 := τ.respects_task t tm ht htm
        have := hfwd (τ.states t ht) (τ.states tm htm) u (tm - t) (z - tm)
          (sub_nonneg.mpr (htmax t ht htz)) (sub_nonneg.mpr htmz) h1 hu₁
        have hsum : (tm - t) + (z - tm) = z - t := by abel
        rwa [hsum] at this
      · -- above: compose `u ⇒_{tp - z} τ(tp)` with `τ(tp) ⇒_{t - tp} τ(t)`, then reflect
        have h1 := τ.respects_task tp t htp ht
        have := hfwd u (τ.states tp htp) (τ.states t ht) (tp - z) (t - tp)
          (sub_nonneg.mpr hztp) (sub_nonneg.mpr (htmin t ht hzt)) hu₂ h1
        have hsum : (tp - z) + (t - tp) = t - z := by abel
        rw [hsum] at this
        exact hrefl t ht u this
    · -- Domain entirely at or below `z`: *Seriality* supplies a successor of the nearest time.
      obtain ⟨u, hu⟩ := (hser (τ.states tm htm) (z - tm) (sub_nonneg.mpr htmz)).1
      refine ⟨u, fun t ht => ?_⟩
      have htz : t ≤ z := le_of_not_ge fun h => habove ⟨t, ht, h⟩
      have h1 := τ.respects_task t tm ht htm
      have := hfwd (τ.states t ht) (τ.states tm htm) u (tm - t) (z - tm)
        (sub_nonneg.mpr (htmax t ht htz)) (sub_nonneg.mpr htmz) h1 hu
      have hsum : (tm - t) + (z - tm) = z - t := by abel
      rwa [hsum] at this
  · -- Domain entirely at or above `z`: *Seriality* supplies a predecessor of the nearest time.
    have habove : ∃ t, τ.domain t ∧ z ≤ t := by
      obtain ⟨t, ht⟩ := τ.nonempty_domain
      exact ⟨t, ht, le_of_not_ge fun h => hbelow ⟨t, ht, h⟩⟩
    obtain ⟨tp, htp, hztp, htmin⟩ := hhigh habove
    obtain ⟨u, hu⟩ := (hser (τ.states tp htp) (tp - z) (sub_nonneg.mpr hztp)).2
    refine ⟨u, fun t ht => ?_⟩
    have hzt : z ≤ t := le_of_not_ge fun h => hbelow ⟨t, ht, h⟩
    have h1 := τ.respects_task tp t htp ht
    have := hfwd u (τ.states tp htp) (τ.states t ht) (tp - z) (t - tp)
      (sub_nonneg.mpr hztp) (sub_nonneg.mpr (htmin t ht hzt)) hu h1
    have hsum : (tp - z) + (t - tp) = t - z := by abel
    rw [hsum] at this
    exact hrefl t ht u this

/--
Over a temporal order with nearest times, the one-point extension property — and hence
`thm:extension` — follows from *Compositionality*, *Seriality* and *Limit*, with
**no *Saturation***.
-/
theorem extension_of_hasNearest (hN : HasNearest F.Duration)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ :=
  extension_of_completion hser hlim (completion_of_hasNearest hN hcomp hser) τ

/--
**The headline, at the tree's own discreteness predicate.**

Over ℤ-time (`TaskFrame.IsZTime`, which is `def:BX-z`'s class), `thm:extension` holds from
*Compositionality*, *Seriality* and *Limit* alone: **`def:frame`'s *Saturation* is redundant
there.**

**The job *Saturation* is left with.** It is needed only over temporal orders where a subset of
times can approach a time without reaching a nearest one — that is, only over **dense** time. Two
further classes discharge it outright rather than assuming it: `TaskFrame.saturation_of_finite`
(`cor:saturation-finite`, a finite carrier) and `TaskFrame.saturation_of_deterministic` (a
deterministic relation). And `Extension/PeriodicExtension.lean` confirms the discrete-time point
from the constructive side independently, building a doubly ultimately periodic total history over
ℤ-time with a finite carrier and no appeal to Zorn's lemma at all.

Paper: `def:BX-z`
-/
theorem extension_of_isZTime (hZ : F.IsZTime)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ := by
  obtain ⟨hsucc, hpred, harch₁, harch₂⟩ := hZ
  exact extension_of_hasNearest
    (@hasNearest_of_succPred F.Duration _ hsucc hpred harch₁ harch₂) hcomp hser hlim τ

end PartialHistory

end FormalSystem.Semantics
