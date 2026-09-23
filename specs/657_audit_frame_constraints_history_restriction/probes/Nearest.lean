import Mathlib.Data.Int.LeastGreatest
import Mathlib.Order.SuccPred.Archimedean
import FormalSystem.Semantics.Extension
import FormalSystem.Semantics.FrameProperty

/-!
# Probe: `lem:step`'s own closing remark, formalized — when *Saturation* is not needed

`lem:step`'s recorded closing remark (verbatim): "When the family has a $\subseteq$-least member,
that member already contains a candidate and \textit{Saturation} is not needed."

This probe turns that remark into a theorem by identifying **when** the constraint family has a
`⊆`-least member: exactly when the history's domain has a nearest time on each side of the new
time `z`. The least member is then the straddling segment `[τ(t⁻), τ(t⁺)]_{z - t⁻}^{t⁺ - z}`, and
every other constraint contains it by *Compositionality* alone.

## What this probe settles

* `HasNearest` — a condition on the **temporal order alone**, not on the frame: every subset of
  `D` with a member on one side of `z` has a nearest such member.
* `completion_of_hasNearest` — *Compositionality* plus *Seriality* plus `HasNearest` gives
  `Completion` (the exact condition `thm:extension` needs; see the `Completion` probe). **No
  *Saturation*, and no *Limit*.**
* `hasNearest_int` — `ℤ` satisfies `HasNearest`.

Consequence: over a discrete temporal order, *Saturation* is **redundant** — it is derivable for
the only purpose the development puts it to. *Saturation* earns its place only over temporal
orders where a subset can approach a time without reaching a nearest point, i.e. dense ones.
-/

namespace FormalSystem.Semantics

open TaskFrame

namespace PartialHistory

/-! ## Local copy of the `Completion` apparatus

Probe files are checked standalone with `lake env lean`, so they cannot import one another. The
three declarations below are verbatim copies from `probes/Completion.lean`, reproduced here only
so that this file's headline can be stated; they are proved there and are not re-proved here
beyond what is written.
-/

/-- Copy of `probes/Completion.lean`'s `Completion`. -/
def Completion (F : TaskFrame) : Prop :=
  ∀ (τ : PartialHistory F) (z : F.Duration),
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u

/-- Copy of `probes/Completion.lean`'s `reflection_of_limit`. -/
theorem reflection_of_limit {F : TaskFrame} (hlim : TaskFrame.Limit F.TaskRel)
    (w : F.WorldState) (d : F.Duration) (u : F.WorldState) :
    F.TaskRel w d u ↔ F.TaskRel u (-d) w := by
  rcases eq_or_ne d 0 with rfl | hd
  · rw [neg_zero]
    constructor
    · intro hR
      obtain rfl := F.toFibre.eq_of_taskRel_zero_of_limit hlim hR
      exact hR
    · intro hR
      obtain rfl := F.toFibre.eq_of_taskRel_zero_of_limit hlim hR
      exact hR
  · exact TaskFrame.reflect_reflection_of_ne hd

/-- Copy of `probes/Completion.lean`'s `extension_of_completion`. -/
theorem extension_of_completion {F : TaskFrame} (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : Completion F) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ := by
  have hstep : ∀ (μ : PartialHistory F) (z : F.Duration),
      ∃ σ : PartialHistory F, Extends σ μ ∧ σ.domain z := by
    intro μ z
    by_cases hz : μ.domain z
    · exact ⟨μ, ⟨fun _ ht => ht, fun _ _ => rfl⟩, hz⟩
    obtain ⟨u, hu⟩ := hC μ z
    have hadm : AdjoinRespects μ z u := by
      intro s t hs ht
      by_cases hsd : μ.domain s <;> by_cases htd : μ.domain t
      · rw [adjoinFun_of_domain μ u hsd, adjoinFun_of_domain μ u htd]
        exact μ.respects_task s t hsd htd
      · obtain rfl : z = t := (Or.resolve_left ht htd).symm
        rw [adjoinFun_of_domain μ u hsd, adjoinFun_of_not_domain μ u htd]
        exact hu s hsd
      · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
        rw [adjoinFun_of_not_domain μ u hsd, adjoinFun_of_domain μ u htd]
        have hconv := (reflection_of_limit hlim (μ.states t htd) (z - t) u).mp (hu t htd)
        rwa [neg_sub] at hconv
      · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
        obtain rfl : z = t := (Or.resolve_left ht htd).symm
        rw [adjoinFun_of_not_domain μ u hsd, sub_self]
        exact TaskFrame.nullity_of_serial_limit hser hlim u
    exact ⟨adjoin μ z u hadm, adjoin_extends μ z u hadm, adjoin_domain_self μ z u hadm⟩
  obtain ⟨μ, hle, hmax⟩ := exists_maximal_extension τ
  have htot : μ.IsTotal := by
    intro z
    obtain ⟨σ, hext, hσz⟩ := hstep μ z
    exact (le_def.mp (hmax (le_def.mpr hext))).subset z hσz
  exact ⟨⟨μ, htot⟩, le_def.mp hle⟩

/-! ## Nearest times: a condition on the temporal order alone -/

/--
Every nonempty one-sided part of a subset of `D` has a nearest member.

This is a property of the linear order `D`, with no reference to any frame. `ℤ` has it
(`hasNearest_int`); `ℚ` and `ℝ` do not.
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
**Every discrete temporal order has nearest times.** This is `HasNearest` at the successor /
predecessor-Archimedean orders — exactly the class `TaskFrame.IsZTime`
(`Semantics/FrameProperty.lean`) picks out, which is `def:BX-z`'s `ℤ`-time. `hasNearest_int` is
the concrete instance.
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

/-! ## *Completion* from nearest times -/

variable {F : TaskFrame}

/--
*Completion* holds as soon as the temporal order has nearest times, given *Compositionality* and
*Seriality*.

**No *Saturation* and no *Limit*.** This is `lem:step`'s closing remark: the `⊆`-least constraint
is the one imposed by the nearest domain time on each side, and *Compositionality* shows every
other constraint contains it.
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
The headline: over a temporal order with nearest times, the one-point extension property — and
hence `thm:extension` — follows from *Compositionality*, *Seriality* and *Limit*, with
**no *Saturation***.
-/
theorem extension_of_hasNearest (hN : HasNearest F.Duration)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ :=
  extension_of_completion hser hlim (completion_of_hasNearest hN hcomp hser) τ

/--
**The headline, at the tree's own discreteness predicate.** Over `ℤ`-time
(`TaskFrame.IsZTime`, which is `def:BX-z`'s class), `thm:extension` holds from
*Compositionality*, *Seriality* and *Limit* alone: **`def:frame`'s *Saturation* is redundant
there.**
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

section AxiomCheck
open FormalSystem.Semantics.PartialHistory
#print axioms hasNearest_int
#print axioms hasNearest_of_succPred
#print axioms completion_of_hasNearest
#print axioms extension_of_hasNearest
#print axioms extension_of_isZTime
end AxiomCheck
