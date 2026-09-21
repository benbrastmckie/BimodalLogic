/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.ConvexConsequence.AxiomSurvival
import FormalSystem.Metalogic.ConvexConsequence.FrameClassSurvival

/-!
# Mirrors - The Past Mirrors of TM's Axioms under C3

TM takes the future-directed Burgess–Xu axioms as primitive and derives each past mirror by the
time-reflection rule (`ProofSystem/DerivedAxioms.lean`, and the two linearity mirrors in
`Theorems/Combinators.lean`). This module gives one C3 theorem per derived mirror, stated at
exactly the formula the corresponding derivation proves.

## Why the verdicts are not inherited

Under the library's own semantics a mirror is valid because time reflection is a sound *rule*:
soundness is proved for the whole calculus, and the mirror is a theorem of it. Nothing of the
kind is available here. C3 is not known to validate TM — it refutes six of its theorems — so
derivability in TM transfers no C3 verdict, and there is no semantic time-reflection principle
on a single frame to appeal to either: reflecting a model reverses the temporal order of the
*frame*, which is a different frame. A mirror row's verdict is therefore not implied by its
forward row, and each mirror is proved here directly, by dualising the forward proof.

The two failing mirrors, `serial_past` and `discrete_symm_bwd`, are in `AxiomSurvival.lean`
beside the failures they mirror. Every mirror in this file survives.

## Main Results

- Base mirrors: `c3_left_mono_since_H`, `c3_right_mono_since`, `c3_connect_past`,
  `c3_enrichment_since`, `c3_self_accum_since`, `c3_absorb_since`, `c3_since_P`,
  `c3_P_since_equiv`, `c3_linear_since`, `c3_temp_linearity_past`
- Frame-class mirrors: `c3_prior_SZ` (ℤ-time), `c3_prior_S_gap` (complete, no density
  needed), `c3_sep_mirror` (ℝ-time)

## References

* `FormalSystem/ProofSystem/DerivedAxioms.lean` — the "Base mirrors" and "Frame-class-gated
  mirrors" sections
* `FormalSystem/Theorems/Combinators.lean` — `linearSince`, `tempLinearityPast`
* `FormalSystem/Metalogic/ConvexConsequence/AxiomSurvival.lean` — the forward rows

## Tags

convex-history · consequence-relation · axiom-survival · time-reflection
-/

namespace FormalSystem.Metalogic.ConvexConsequence

open FormalSystem.Syntax FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## Base mirrors -/

/-- The mirror of `left_mono_until_G` survives C3: `H(φ → χ) → ((φ S ψ) → (χ S ψ))`, the
formula `DerivedAxioms.leftMonoSinceH` derives. -/
theorem c3_left_mono_since_H (φ χ ψ : Formula) :
    ValidC3 F ((φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ))) := by
  intro M τ _hτ x _hx hH h
  rw [TruthAtConvex.allPast_iff] at hH
  obtain ⟨s, hs, hsx, hψ, hguard⟩ := h
  exact ⟨s, hs, hsx, hψ, fun r hr hsr hrx => hH r hr hrx (hguard r hr hsr hrx)⟩

/-- The mirror of `right_mono_until` survives C3: `H(φ → ψ) → ((χ S φ) → (χ S ψ))`, the formula
`DerivedAxioms.rightMonoSince` derives. -/
theorem c3_right_mono_since (φ ψ χ : Formula) :
    ValidC3 F ((φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ))) := by
  intro M τ _hτ x _hx hH h
  rw [TruthAtConvex.allPast_iff] at hH
  obtain ⟨s, hs, hsx, hφ, hguard⟩ := h
  exact ⟨s, hs, hsx, hH s hs hsx hφ, hguard⟩

/-- The mirror of `connect_future` survives C3: `φ → H(Fφ)`, the formula
`DerivedAxioms.connectPast` derives. -/
theorem c3_connect_past (φ : Formula) : ValidC3 F (φ.imp φ.someFuture.allPast) := by
  intro M τ _hτ x hx hφ
  refine (TruthAtConvex.allPast_iff M τ x φ.someFuture).mpr fun s _hs hsx => ?_
  exact (TruthAtConvex.someFuture_iff M τ s φ).mpr ⟨x, hx, hsx, hφ⟩

/-- The mirror of `enrichment_until` survives C3: `p ∧ (φ S ψ) → φ S (ψ ∧ (φ U p))`, the formula
`DerivedAxioms.enrichmentSince` derives. -/
theorem c3_enrichment_since (φ ψ p : Formula) :
    ValidC3 F ((Formula.and p (Formula.snce φ ψ)).imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))) := by
  intro M τ _hτ x hx h
  obtain ⟨hp, s, hs, hsx, hψ, hguard⟩ := (TruthAtConvex.and_iff M τ x _ _).mp h
  refine ⟨s, hs, hsx, (TruthAtConvex.and_iff M τ s _ _).mpr ⟨hψ, x, hx, hsx, hp, ?_⟩, hguard⟩
  exact fun r hr hsr hrx => hguard r hr hsr hrx

/-- The mirror of `self_accum_until` survives C3, at the formula `DerivedAxioms.selfAccumSince`
derives. -/
theorem c3_self_accum_since (φ ψ : Formula) :
    ValidC3 F ((Formula.snce φ ψ).imp
      (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ)) := by
  intro M τ _hτ x _hx h
  obtain ⟨s, hs, hsx, hψ, hguard⟩ := h
  refine ⟨s, hs, hsx, hψ, fun r hr hsr hrx => ?_⟩
  exact (TruthAtConvex.and_iff M τ r _ _).mpr ⟨hguard r hr hsr hrx, s, hs, hsr, hψ,
    fun r' hr' hsr' hr'r => hguard r' hr' hsr' (lt_trans hr'r hrx)⟩

/-- The mirror of `absorb_until` survives C3, at the formula `DerivedAxioms.absorbSince`
derives. -/
theorem c3_absorb_since (φ ψ : Formula) :
    ValidC3 F ((Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp
      (Formula.snce φ ψ)) := by
  intro M τ _hτ x _hx h
  obtain ⟨s, _hs, hsx, hev, hguard⟩ := h
  obtain ⟨hφs, s', hs', hs's, hψ, hguard'⟩ := (TruthAtConvex.and_iff M τ s _ _).mp hev
  refine ⟨s', hs', lt_trans hs's hsx, hψ, fun r hr hs'r hrx => ?_⟩
  rcases lt_trichotomy r s with h | h | h
  · exact hguard' r hr hs'r h
  · exact h ▸ hφs
  · exact hguard r hr h hrx

/-- The mirror of `until_F` survives C3: `(φ S ψ) → Pψ`, the formula `DerivedAxioms.sinceP`
derives. -/
theorem c3_since_P (φ ψ : Formula) :
    ValidC3 F ((Formula.snce φ ψ).imp (Formula.somePast ψ)) := by
  intro M τ _hτ x _hx h
  obtain ⟨s, hs, hsx, hψ, -⟩ := h
  exact (TruthAtConvex.somePast_iff M τ x ψ).mpr ⟨s, hs, hsx, hψ⟩

/-- The mirror of `F_until_equiv` survives C3: `Pφ → S(⊤, φ)`, the formula
`DerivedAxioms.pSinceEquiv` derives. Definitional. -/
theorem c3_P_since_equiv (φ : Formula) :
    ValidC3 F ((Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ)) :=
  fun _M _τ _hτ _x _hx h => h

/-- The mirror of `linear_until` survives C3, at the formula `Combinators.linearSince` derives —
with that derivation's left-nested disjunction. Trichotomy on the two since-witnesses. -/
theorem c3_linear_since (φ ψ χ θ : Formula) :
    ValidC3 F ((Formula.and (Formula.snce φ ψ) (Formula.snce χ θ)).imp
      (Formula.or
        (Formula.or
          (Formula.snce (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.snce (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.snce (Formula.and φ χ) (Formula.and φ θ)))) := by
  intro M τ _hτ x _hx h
  obtain ⟨⟨s₁, hs₁, hs₁x, hψ, hg₁⟩, ⟨s₂, hs₂, hs₂x, hθ, hg₂⟩⟩ :=
    (TruthAtConvex.and_iff M τ x _ _).mp h
  -- `Formula.or (Formula.or A B) C` is `¬(¬A → B) → C`.
  intro hAB
  rcases lt_trichotomy s₁ s₂ with hlt | heq | hgt
  · exact ⟨s₂, hs₂, hs₂x, (TruthAtConvex.and_iff M τ s₂ _ _).mpr ⟨hg₁ s₂ hs₂ hlt hs₂x, hθ⟩,
      fun r hr hsr hrx => (TruthAtConvex.and_iff M τ r _ _).mpr
        ⟨hg₁ r hr (lt_trans hlt hsr) hrx, hg₂ r hr hsr hrx⟩⟩
  · subst heq
    refine absurd (fun hA => absurd ?_ hA) hAB
    exact ⟨s₁, hs₁, hs₁x, (TruthAtConvex.and_iff M τ s₁ _ _).mpr ⟨hψ, hθ⟩,
      fun r hr hsr hrx => (TruthAtConvex.and_iff M τ r _ _).mpr
        ⟨hg₁ r hr hsr hrx, hg₂ r hr hsr hrx⟩⟩
  · refine absurd (fun _ => ?_) hAB
    exact ⟨s₁, hs₁, hs₁x, (TruthAtConvex.and_iff M τ s₁ _ _).mpr ⟨hψ, hg₂ s₁ hs₁ hgt hs₁x⟩,
      fun r hr hsr hrx => (TruthAtConvex.and_iff M τ r _ _).mpr
        ⟨hg₁ r hr hsr hrx, hg₂ r hr (lt_trans hgt hsr) hrx⟩⟩

/-- The mirror of `temp_linearity` survives C3, at the formula `Combinators.tempLinearityPast`
derives — with that derivation's order of disjuncts. Trichotomy on the two `P`-witnesses. -/
theorem c3_temp_linearity_past (φ ψ : Formula) :
    ValidC3 F ((Formula.and (Formula.somePast φ) (Formula.somePast ψ)).imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) := by
  intro M τ _hτ x _hx h
  obtain ⟨h₁, h₂⟩ := (TruthAtConvex.and_iff M τ x _ _).mp h
  obtain ⟨s₁, hs₁, hs₁x, hφ⟩ := (TruthAtConvex.somePast_iff M τ x φ).mp h₁
  obtain ⟨s₂, hs₂, hs₂x, hψ⟩ := (TruthAtConvex.somePast_iff M τ x ψ).mp h₂
  -- `Formula.or A (Formula.or B C)` is `¬A → ¬B → C`.
  intro hA hB
  rcases lt_trichotomy s₁ s₂ with hlt | heq | hgt
  · exact (TruthAtConvex.somePast_iff M τ x _).mpr ⟨s₂, hs₂, hs₂x,
      (TruthAtConvex.and_iff M τ s₂ _ _).mpr
        ⟨(TruthAtConvex.somePast_iff M τ s₂ φ).mpr ⟨s₁, hs₁, hlt, hφ⟩, hψ⟩⟩
  · subst heq
    refine absurd ?_ hA
    exact (TruthAtConvex.somePast_iff M τ x _).mpr ⟨s₁, hs₁, hs₁x,
      (TruthAtConvex.and_iff M τ s₁ _ _).mpr ⟨hφ, hψ⟩⟩
  · refine absurd ?_ hB
    exact (TruthAtConvex.somePast_iff M τ x _).mpr ⟨s₁, hs₁, hs₁x,
      (TruthAtConvex.and_iff M τ s₁ _ _).mpr
        ⟨hφ, (TruthAtConvex.somePast_iff M τ s₁ ψ).mpr ⟨s₂, hs₂, hgt, hψ⟩⟩⟩

/-! ## Frame-class mirrors -/

/-- The mirror of `prior_UZ` survives C3 on every ℤ-time frame: `Pφ → S(¬φ, φ)`, the formula
`DerivedAxioms.priorSZ` derives. The greatest witness is found by iterating the successor from
the given witness up toward `x`; every point visited lies in the domain by convexity. -/
theorem c3_prior_SZ (hZ : F.IsZTime) (φ : Formula) :
    ValidC3 F (φ.somePast.imp (Formula.snce φ.neg φ)) := by
  obtain ⟨_, _, _, _⟩ := hZ
  intro M τ hconv x hx hP
  obtain ⟨s₀, hs₀d, hs₀x, hφs₀⟩ := (TruthAtConvex.somePast_iff M τ x φ).mp hP
  have greatest : ∀ n : ℕ, ∀ s, Order.succ^[n] s = x → s₀ ≤ s →
      (∃ w, w < x ∧ s ≤ w ∧ TruthAtConvex M τ w φ) →
      ∃ u, u < x ∧ s₀ ≤ u ∧ TruthAtConvex M τ u φ ∧
        ∀ r, u < r → r < x → ¬ TruthAtConvex M τ r φ := by
    intro n
    induction n with
    | zero =>
      rintro s hs - ⟨w, hwx, hsw, -⟩
      exact absurd (lt_of_le_of_lt hsw hwx) (by rw [Function.iterate_zero, id] at hs; simp [hs])
    | succ n ih =>
      intro s hs hs₀s hw
      rw [Function.iterate_succ_apply] at hs
      by_cases hhigh : ∃ w, w < x ∧ Order.succ s ≤ w ∧ TruthAtConvex M τ w φ
      · exact ih (Order.succ s) hs (le_trans hs₀s (Order.le_succ s)) hhigh
      · obtain ⟨w, hwx, hsw, hφw⟩ := hw
        have hweq : s = w := by
          rcases eq_or_lt_of_le hsw with h | h
          · exact h
          · exact absurd ⟨w, hwx, Order.succ_le_of_lt h, hφw⟩ hhigh
        subst hweq
        exact ⟨s, hwx, hs₀s, hφw, fun r hsr hrx hφr =>
          hhigh ⟨r, hrx, Order.succ_le_of_lt hsr, hφr⟩⟩
  obtain ⟨n, hn⟩ := IsSuccArchimedean.exists_succ_iterate_of_le hs₀x.le
  obtain ⟨u, hux, hs₀u, hφu, hmax⟩ :=
    greatest n s₀ hn (le_refl s₀) ⟨s₀, hs₀x, le_refl s₀, hφs₀⟩
  exact ⟨u, hconv s₀ x hs₀d hx u hs₀u hux.le, hux, hφu, fun r _ hur hrx => hmax r hur hrx⟩

/--
The mirror of `prior_U_gap` survives C3 on every complete frame — no density hypothesis — at
the formula `DerivedAxioms.priorSGap` derives. This closes the last verdict the source survey
left unresolved.

The dual of `c3_prior_U_gap`: the greatest lower bound, supplied by
`SoundnessLemmas.exists_isGLB_of_lub`, of the set of `u ∈ [v, t)` above which `φ` holds
throughout, where `v` is the refuting witness of `P¬φ`. Capping the set below at `v` makes the
infimum land between the two domain times `v` and `t`, hence in the domain by convexity.
-/
theorem c3_prior_S_gap (hc : F.IsComplete) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg)))) := by
  intro M τ hconv t ht h_ant
  obtain ⟨⟨s0, hs0d, hs0t, -, hp0⟩, ⟨v, hvd, hvt, hnpv, -⟩⟩ :=
    (TruthAtConvex.and_iff M τ t _ _).mp h_ant
  let A : Set F.Duration := {u | u < t ∧ v ≤ u ∧
    ∀ r, u < r → r < t → TruthAtConvex M τ r φ}
  have hmem : max s0 v ∈ A := by
    refine ⟨max_lt hs0t hvt, le_max_right _ _, fun r hr hrt => ?_⟩
    have hs0r : s0 < r := lt_of_le_of_lt (le_max_left _ _) hr
    exact hp0 r (hconv s0 t hs0d ht r hs0r.le hrt.le) hs0r hrt
  obtain ⟨s, hs⟩ := SoundnessLemmas.exists_isGLB_of_lub hc (B := A) ⟨_, hmem⟩
    ⟨v, fun u hu => hu.2.1⟩
  have hst : s < t := lt_of_le_of_lt (hs.1 hmem) hmem.1
  have hvs : v ≤ s := hs.2 fun u hu => hu.2.1
  have hsd : τ.domain s := hconv v t hvd ht s hvs hst.le
  have hguard : ∀ r, s < r → r < t → TruthAtConvex M τ r φ := by
    intro r hsr hrt
    obtain ⟨u, huA, -, hur⟩ := hs.exists_between hsr
    exact huA.2.2 r hur hrt
  refine ⟨s, hsd, hst, ?_, fun r _ hsr hrt => hguard r hsr hrt⟩
  intro hnn
  have hps : TruthAtConvex M τ s φ := Classical.byContradiction hnn
  rintro ⟨w, hwd, hws, -, hw⟩
  have hvs' : v < s := by
    rcases lt_or_eq_of_le hvs with h | h
    · exact h
    · exact absurd (h ▸ hps) hnpv
  have hwA : max w v ∈ A := by
    refine ⟨lt_trans (max_lt hws hvs') hst, le_max_right _ _, fun r hr hrt => ?_⟩
    have hwr : w < r := lt_of_le_of_lt (le_max_left _ _) hr
    rcases lt_trichotomy r s with h | h | h
    · exact Classical.byContradiction
        (hw r (hconv w s hwd hsd r hwr.le h.le) hwr h)
    · exact h ▸ hps
    · exact hguard r h hrt
  exact absurd (hs.1 hwA) (not_le_of_gt (max_lt hws hvs'))

/--
The mirror of `sep` survives C3 on every ℝ-time frame:
`K⁻φ ∧ ¬K⁻(φ ∧ S(¬φ, φ)) → K⁻(K⁻φ ∧ K⁺φ)`, the time reflection of `sep`.

The order argument is `SoundnessLemmas.sep_order_mirror`, applied to the set of domain points
satisfying `φ`, exactly as `c3_sep` applies `SoundnessLemmas.sep_order`.
-/
theorem c3_sep_mirror (hR : F.IsRTime) (φ : Formula) :
    ValidC3 F ((Formula.and (Formula.kMinus φ)
        (Formula.kMinus (Formula.and φ (Formula.snce φ.neg φ))).neg).imp
      (Formula.kMinus (Formula.and (Formula.kMinus φ) (Formula.kPlus φ)))) := by
  obtain ⟨hdense, h_lub⟩ := hR
  have : DenselyOrdered F.Duration := hdense
  intro M τ hconv t ht h_ant
  obtain ⟨Q, hQc, hQd⟩ := SoundnessLemmas.exists_countable_order_dense h_lub
  obtain ⟨h1, h2⟩ := (TruthAtConvex.and_iff M τ t _ _).mp h_ant
  rw [TruthAtConvex.kMinus_iff] at h1
  have h2' : ∃ s₁, τ.domain s₁ ∧ s₁ < t ∧ ∀ r, τ.domain r → s₁ < r → r < t →
      ¬ (TruthAtConvex M τ r φ ∧ TruthAtConvex M τ r (Formula.snce φ.neg φ)) := by
    by_contra hc
    apply h2
    rw [TruthAtConvex.kMinus_iff]
    intro s hs hst
    by_contra hc2
    exact hc ⟨s, hs, hst, fun r hr h1 h2 hr' =>
      hc2 ⟨r, hr, h1, h2, (TruthAtConvex.and_iff M τ r _ _).mpr hr'⟩⟩
  obtain ⟨s₁, hs₁d, hs₁t, hstart⟩ := h2'
  rw [TruthAtConvex.kMinus_iff]
  intro s₂ hs₂d hs₂t
  by_contra hno
  have hno' : ∀ r, τ.domain r → s₂ < r → r < t →
      ¬ (TruthAtConvex M τ r φ.kMinus ∧ TruthAtConvex M τ r φ.kPlus) :=
    fun r hr a b hab => hno ⟨r, hr, a, b, (TruthAtConvex.and_iff M τ r _ _).mpr hab⟩
  let P : Set F.Duration := {u | ∃ _ : τ.domain u, TruthAtConvex M τ u φ}
  have hin : ∀ {u s}, τ.domain s → s ≤ u → u < t → τ.domain u :=
    fun {u s} hs hsu hut => hconv s t hs ht u hsu hut.le
  refine SoundnessLemmas.sep_order_mirror h_lub Q hQc hQd P t s₁ s₂ hs₁t hs₂t ?_ ?_ ?_
  · intro v hvt
    obtain ⟨r, hr, h1', h2', hφ⟩ :=
      h1 (max v s₁) (hin hs₁d (le_max_right _ _) (max_lt hvt hs₁t)) (max_lt hvt hs₁t)
    exact ⟨r, lt_of_le_of_lt (le_max_left _ _) h1', h2', hr, hφ⟩
  · rintro u hut hs₁u ⟨hud, hφu⟩ ⟨v, hvu, ⟨hvd, hφv⟩, hfree⟩
    exact hstart u hud hs₁u hut ⟨hφu, v, hvd, hvu, hφv,
      fun r hr hvr hru hφr => hfree r hvr hru ⟨hr, hφr⟩⟩
  · intro u hut hs₂u
    have hud : τ.domain u := hin hs₂d hs₂u.le hut
    by_cases hK : TruthAtConvex M τ u φ.kMinus
    · have hKp : ¬ TruthAtConvex M τ u φ.kPlus := fun h => hno' u hud hs₂u hut ⟨hK, h⟩
      rw [TruthAtConvex.kPlus_iff] at hKp
      push Not at hKp
      obtain ⟨v, hvd, huv, hv⟩ := hKp
      exact Or.inr ⟨v, huv, fun w huw hwv ⟨hwd, hφw⟩ => hv w hwd huw hwv hφw⟩
    · rw [TruthAtConvex.kMinus_iff] at hK
      push Not at hK
      obtain ⟨v, hvd, hvu, hv⟩ := hK
      exact Or.inl ⟨v, hvu, fun w hvw hwu ⟨hwd, hφw⟩ => hv w hwd hvw hwu hφw⟩

end FormalSystem.Metalogic.ConvexConsequence
