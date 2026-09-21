/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ConvexTruth
import FormalSystem.Metalogic.SoundnessLemmas.Separability

/-!
# FrameClassSurvival - The Frame-Class Axioms of TM Survive C3

TM's six frame-class axioms — `prior_UZ` and `z1` for ℤ-time, `density` and `dense_indicator`
for dense time, `prior_U_gap` and `sep` for ℝ-time — are each C3-valid on the frame class that
validates them under the library's own semantics. None fails.

That is not obvious in advance. Each of these axioms is about the *order type* of time, and a C3
index sees only a bounded convex piece of it. They survive because each is, in effect, a
statement about a bounded stretch between two times the antecedent has already placed in the
domain, and convexity returns every point of that stretch to the domain:

- `c3_density`, `c3_dense_indicator` — density interpolates between two domain times, and
  convexity puts the interpolant in the domain.
- `c3_prior_UZ`, `c3_z1` — iteration of the predecessor from a domain witness back toward the
  evaluation time never leaves the convex domain.
- `c3_prior_U_gap` — the supremum is taken of a set capped at the refuting witness, so it lands
  between two domain times. Completeness alone is used, not density.
- `c3_sep` — Reynolds' order argument `SoundnessLemmas.sep_order` is applied to the set of
  domain points satisfying the formula.

## The endpoint behaviour of `K⁺`

`K⁺φ` is itself a restricted `U`-formula, `¬U(¬φ, ⊤)`, so its meaning changes under C3: by
`TruthAtConvex.kPlus_iff` it says that `φ` holds arbitrarily soon after `t` *within the domain*.
At a right endpoint of the domain there is no later domain time and `K⁺φ` is **vacuously true**.
That only helps the two Reynolds rows. In `prior_U_gap` it occurs positively in the consequent.
In `sep` it occurs in the antecedent as `K⁺φ ∧ ¬K⁺(…)`, and the negated conjunct already forces
a later domain time to exist, so the vacuous case never arises there; in the consequent it
occurs positively.

## Main Results

- `c3_prior_UZ`, `c3_z1` (ℤ-time); `c3_density`, `c3_dense_indicator` (dense);
  `c3_prior_U_gap` (complete); `c3_sep` (ℝ-time)
- `validC3In_priorUZ`, `validC3In_z1`, `validC3In_density`, `validC3In_denseIndicator`,
  `validC3In_priorUGap`, `validC3In_sep`: the class-level corollaries at `ValidC3In`

## References

* `FormalSystem/ProofSystem/Axioms.lean` — the six frame-class `Axiom` constructors
* `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` — `sep_order`,
  `exists_countable_order_dense`
* `FormalSystem/Semantics/FrameProperty.lean` — `IsZTime`, `IsDense`, `IsComplete`, `IsRTime`

## Tags

convex-history · consequence-relation · axiom-survival · frame-class · separability
-/

namespace FormalSystem.Metalogic.ConvexConsequence

open FormalSystem.Syntax FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## ℤ-time rows -/

/--
`prior_UZ` survives C3 on every ℤ-time frame: `Fφ → U(¬φ, φ)`.

The least witness is found by iterating the predecessor from the given witness `s₀` back toward
`x`. Every point of `(x, s₀]` is in the domain by convexity, so the least witness is a domain
point and the `untl` clause's domain restriction costs nothing.
-/
theorem c3_prior_UZ (hZ : F.IsZTime) (φ : Formula) :
    ValidC3 F (φ.someFuture.imp (Formula.untl φ.neg φ)) := by
  obtain ⟨_, _, _, _⟩ := hZ
  intro M τ hconv x hx hF
  obtain ⟨s₀, hs₀d, hxs₀, hφs₀⟩ := (TruthAtConvex.someFuture_iff M τ x φ).mp hF
  have least : ∀ n : ℕ, ∀ s, Order.pred^[n] s = x → s ≤ s₀ →
      (∃ w, x < w ∧ w ≤ s ∧ TruthAtConvex M τ w φ) →
      ∃ u, x < u ∧ u ≤ s₀ ∧ TruthAtConvex M τ u φ ∧
        ∀ r, x < r → r < u → ¬ TruthAtConvex M τ r φ := by
    intro n
    induction n with
    | zero =>
      rintro s hs - ⟨w, hxw, hws, -⟩
      exact absurd (lt_of_lt_of_le hxw hws) (by rw [Function.iterate_zero, id] at hs; simp [hs])
    | succ n ih =>
      intro s hs hss₀ hw
      rw [Function.iterate_succ_apply] at hs
      by_cases hlow : ∃ w, x < w ∧ w ≤ Order.pred s ∧ TruthAtConvex M τ w φ
      · exact ih (Order.pred s) hs (le_trans (Order.pred_le s) hss₀) hlow
      · obtain ⟨w, hxw, hws, hφw⟩ := hw
        have hweq : w = s := by
          rcases eq_or_lt_of_le hws with h | h
          · exact h
          · exact absurd ⟨w, hxw, Order.le_pred_of_lt h, hφw⟩ hlow
        subst hweq
        exact ⟨w, hxw, hss₀, hφw, fun r hxr hrw hφr =>
          hlow ⟨r, hxr, Order.le_pred_of_lt hrw, hφr⟩⟩
  obtain ⟨n, hn⟩ := IsPredArchimedean.exists_pred_iterate_of_le hxs₀.le
  obtain ⟨u, hxu, hus₀, hφu, hmin⟩ := least n s₀ hn (le_refl s₀) ⟨s₀, hxs₀, le_refl s₀, hφs₀⟩
  exact ⟨u, hconv x s₀ hx hs₀d u hxu.le hus₀, hxu, hφu, fun r _ hxr hru => hmin r hxr hru⟩

/--
`z1` survives C3 on every ℤ-time frame: `G(Gφ → φ) → (FGφ → Gφ)`. This closes a verdict the
source survey left conditional.

Backward induction along the iterated predecessor from the `Gφ` witness `s₀`: `Gφ` at `t` gives
`φ` at `t` by the step hypothesis, hence `Gφ` at `pred t`. Every point visited lies in
`(x, s₀]`, which is inside the domain by convexity, so the restricted `G` loses nothing.
-/
theorem c3_z1 (hZ : F.IsZTime) (φ : Formula) :
    ValidC3 F ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  obtain ⟨_, _, _, _⟩ := hZ
  intro M τ hconv x hx hstep hF
  rw [TruthAtConvex.allFuture_iff] at hstep
  obtain ⟨s0, hs0d, hxs0, hG0⟩ := (TruthAtConvex.someFuture_iff M τ x _).mp hF
  have hdom : ∀ u, x < u → u ≤ s0 → τ.domain u :=
    fun u hxu hus => hconv x s0 hx hs0d u hxu.le hus
  have back : ∀ t, x < Order.pred t → t ≤ s0 →
      TruthAtConvex M τ t φ.allFuture → TruthAtConvex M τ (Order.pred t) φ.allFuture := by
    intro t hxp hts hGt
    have hxt : x < t := lt_of_lt_of_le hxp (Order.pred_le t)
    have hφt : TruthAtConvex M τ t φ := hstep t (hdom t hxt hts) hxt hGt
    rw [TruthAtConvex.allFuture_iff] at hGt ⊢
    intro u hud hpu
    rcases eq_or_lt_of_le (Order.le_of_pred_lt hpu) with h | h
    · exact h ▸ hφt
    · exact hGt u hud h
  have iter : ∀ n : ℕ, x < Order.pred^[n] s0 →
      TruthAtConvex M τ (Order.pred^[n] s0) φ.allFuture := by
    intro n
    induction n with
    | zero => intro _; exact hG0
    | succ n ih =>
      intro hx'
      rw [Function.iterate_succ_apply'] at hx' ⊢
      exact back _ hx' (Order.pred_iterate_le _ _)
        (ih (lt_of_lt_of_le hx' (Order.pred_le _)))
  rw [TruthAtConvex.allFuture_iff]
  intro t htd hxt
  rcases le_or_gt t s0 with hts | hts
  · obtain ⟨n, hn⟩ := IsPredArchimedean.exists_pred_iterate_of_le hts
    have hG : TruthAtConvex M τ t φ.allFuture := hn ▸ iter n (hn ▸ hxt)
    exact hstep t htd hxt hG
  · exact (TruthAtConvex.allFuture_iff M τ s0 φ).mp hG0 t htd hts

/-! ## Dense rows -/

/-- `density` survives C3 on every dense frame: `GGφ → Gφ`. Density interpolates between the
evaluation time and the target, and convexity returns the interpolant to the domain. -/
theorem c3_density (hd : F.IsDense) (φ : Formula) :
    ValidC3 F (φ.allFuture.allFuture.imp φ.allFuture) := by
  have : DenselyOrdered F.Duration := hd
  intro M τ hconv x hx hGG
  rw [TruthAtConvex.allFuture_iff] at hGG ⊢
  intro s hs hxs
  obtain ⟨r, hxr, hrs⟩ := exists_between hxs
  exact (TruthAtConvex.allFuture_iff M τ r φ).mp
    (hGG r (hconv x s hx hs r hxr.le hrs.le) hxr) s hs hrs

/-- `dense_indicator` survives C3 on every dense frame: `¬U(⊥, ⊤)`. A forward gap between two
domain times would contain an interpolant, which convexity puts in the domain. -/
theorem c3_dense_indicator (hd : F.IsDense) :
    ValidC3 F (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg := by
  have : DenselyOrdered F.Duration := hd
  rintro M τ hconv x hx ⟨s, hs, hxs, -, hgap⟩
  obtain ⟨r, hxr, hrs⟩ := exists_between hxs
  exact hgap r (hconv x s hx hs r hxr.le hrs.le) hxr hrs

/-! ## ℝ-time rows -/

/--
`prior_U_gap` survives C3 on every complete frame — no density hypothesis. This closes a verdict
the source survey left unresolved.

The supremum is taken of the set of `u ∈ (t, v]` below which `φ` holds throughout, where `v` is
the refuting witness of `F¬φ`. Capping the set at `v` is what makes the supremum land between
the two domain times `t` and `v`, hence in the domain by convexity.
-/
theorem c3_prior_U_gap (hc : F.IsComplete) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
      (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) := by
  intro M τ hconv t ht h_ant
  obtain ⟨⟨s0, hs0d, hts0, -, hp0⟩, ⟨v, hvd, htv, hnpv, -⟩⟩ :=
    (TruthAtConvex.and_iff M τ t _ _).mp h_ant
  let A : Set F.Duration := {u | t < u ∧ u ≤ v ∧
    ∀ r, t < r → r < u → TruthAtConvex M τ r φ}
  have hmem : min s0 v ∈ A := by
    refine ⟨lt_min hts0 htv, min_le_right _ _, fun r htr hr => ?_⟩
    have hrs0 : r < s0 := lt_of_lt_of_le hr (min_le_left _ _)
    exact hp0 r (hconv t s0 ht hs0d r htr.le hrs0.le) htr hrs0
  obtain ⟨s, hs⟩ := hc A ⟨_, hmem⟩ ⟨v, fun u hu => hu.2.1⟩
  have hts : t < s := lt_of_lt_of_le hmem.1 (hs.1 hmem)
  have hsv : s ≤ v := hs.2 fun u hu => hu.2.1
  have hsd : τ.domain s := hconv t v ht hvd s hts.le hsv
  have hguard : ∀ r, t < r → r < s → TruthAtConvex M τ r φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2.2 r htr hru
  refine ⟨s, hsd, hts, ?_, fun r _ htr hrs => hguard r htr hrs⟩
  intro hnn
  have hps : TruthAtConvex M τ s φ := Classical.byContradiction hnn
  rintro ⟨w, hwd, hsw, -, hw⟩
  have hsv' : s < v := by
    rcases lt_or_eq_of_le hsv with h | h
    · exact h
    · exact absurd (h ▸ hps) hnpv
  have hwA : min w v ∈ A := by
    refine ⟨lt_trans hts (lt_min hsw hsv'), min_le_right _ _, fun r htr hr => ?_⟩
    have hrw : r < w := lt_of_lt_of_le hr (min_le_left _ _)
    rcases lt_trichotomy r s with h | h | h
    · exact hguard r htr h
    · exact h ▸ hps
    · exact Classical.byContradiction
        (hw r (hconv s w hsd hwd r h.le hrw.le) h hrw)
  exact absurd (hs.1 hwA) (not_le_of_gt (lt_min hsw hsv'))

/--
`sep` survives C3 on every ℝ-time frame. This closes a verdict the source survey left
unresolved.

Reynolds' order argument `SoundnessLemmas.sep_order` is reused verbatim, at the set `P` of
*domain* points satisfying `φ`. Its three hypotheses are discharged from the C3 clauses, with
convexity returning each interpolated point to the domain.
-/
theorem c3_sep (hR : F.IsRTime) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
      (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  obtain ⟨hdense, h_lub⟩ := hR
  have : DenselyOrdered F.Duration := hdense
  intro M τ hconv t ht h_ant
  obtain ⟨Q, hQc, hQd⟩ := SoundnessLemmas.exists_countable_order_dense h_lub
  obtain ⟨h1, h2⟩ := (TruthAtConvex.and_iff M τ t _ _).mp h_ant
  rw [TruthAtConvex.kPlus_iff] at h1
  have h2' : ∃ s₁, τ.domain s₁ ∧ t < s₁ ∧ ∀ r, τ.domain r → t < r → r < s₁ →
      ¬ (TruthAtConvex M τ r φ ∧ TruthAtConvex M τ r (Formula.untl φ.neg φ)) := by
    by_contra hc
    apply h2
    rw [TruthAtConvex.kPlus_iff]
    intro s hs hts
    by_contra hc2
    exact hc ⟨s, hs, hts, fun r hr h1 h2 hr' =>
      hc2 ⟨r, hr, h1, h2, (TruthAtConvex.and_iff M τ r _ _).mpr hr'⟩⟩
  obtain ⟨s₁, hs₁d, hts₁, hstart⟩ := h2'
  rw [TruthAtConvex.kPlus_iff]
  intro s₂ hs₂d hts₂
  by_contra hno
  have hno' : ∀ r, τ.domain r → t < r → r < s₂ →
      ¬ (TruthAtConvex M τ r φ.kPlus ∧ TruthAtConvex M τ r φ.kMinus) :=
    fun r hr a b hab => hno ⟨r, hr, a, b, (TruthAtConvex.and_iff M τ r _ _).mpr hab⟩
  let P : Set F.Duration := {u | ∃ _ : τ.domain u, TruthAtConvex M τ u φ}
  have hin : ∀ {u s}, τ.domain s → t < u → u ≤ s → τ.domain u :=
    fun {u s} hs htu hus => hconv t s ht hs u htu.le hus
  refine SoundnessLemmas.sep_order h_lub Q hQc hQd P t s₁ s₂ hts₁ hts₂ ?_ ?_ ?_
  · intro v htv
    obtain ⟨r, hr, h1', h2', hφ⟩ :=
      h1 (min v s₁) (hin hs₁d (lt_min htv hts₁) (min_le_right _ _)) (lt_min htv hts₁)
    exact ⟨r, h1', lt_of_lt_of_le h2' (min_le_left _ _), hr, hφ⟩
  · rintro u htu hus₁ ⟨hud, hφu⟩ ⟨v, huv, ⟨hvd, hφv⟩, hfree⟩
    exact hstart u hud htu hus₁ ⟨hφu, v, hvd, huv, hφv,
      fun r hr hur hrv hφr => hfree r hur hrv ⟨hr, hφr⟩⟩
  · intro u htu hus₂
    have hud : τ.domain u := hin hs₂d htu hus₂.le
    by_cases hK : TruthAtConvex M τ u φ.kPlus
    · have hKm : ¬ TruthAtConvex M τ u φ.kMinus := fun h => hno' u hud htu hus₂ ⟨hK, h⟩
      rw [TruthAtConvex.kMinus_iff] at hKm
      push Not at hKm
      obtain ⟨v, hvd, hvu, hv⟩ := hKm
      exact Or.inr ⟨v, hvu, fun w hvw hwu ⟨hwd, hφw⟩ => hv w hwd hvw hwu hφw⟩
    · rw [TruthAtConvex.kPlus_iff] at hK
      push Not at hK
      obtain ⟨v, hvd, huv, hv⟩ := hK
      exact Or.inl ⟨v, huv, fun w huw hwv ⟨hwd, hφw⟩ => hv w hwd huw hwv hφw⟩

/-! ## Class-level corollaries -/

/-- `prior_UZ` is C3-valid on the ℤ-time class. -/
theorem validC3In_priorUZ (φ : Formula) :
    ValidC3In .ZTime (φ.someFuture.imp (Formula.untl φ.neg φ)) :=
  fun _F hF => c3_prior_UZ hF φ

/-- `z1` is C3-valid on the ℤ-time class. -/
theorem validC3In_z1 (φ : Formula) :
    ValidC3In .ZTime ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) :=
  fun _F hF => c3_z1 hF φ

/-- `density` is C3-valid on the dense class. -/
theorem validC3In_density (φ : Formula) :
    ValidC3In .Dense (φ.allFuture.allFuture.imp φ.allFuture) :=
  fun _F hF => c3_density hF φ

/-- `dense_indicator` is C3-valid on the dense class. -/
theorem validC3In_denseIndicator :
    ValidC3In .Dense (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg :=
  fun _F hF => c3_dense_indicator hF

/-- `prior_U_gap` is C3-valid on the ℝ-time class. Only the completeness half of the class
condition is used. -/
theorem validC3In_priorUGap (φ : Formula) :
    ValidC3In .RTime ((Formula.and (Formula.untl φ Formula.top) φ.neg.someFuture).imp
      (Formula.untl φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) :=
  fun _F hF => c3_prior_U_gap hF.2 φ

/-- `sep` is C3-valid on the ℝ-time class. -/
theorem validC3In_sep (φ : Formula) :
    ValidC3In .RTime ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
      (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) :=
  fun _F hF => c3_sep hF φ

end FormalSystem.Metalogic.ConvexConsequence
