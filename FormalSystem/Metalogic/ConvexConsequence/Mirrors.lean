/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.ConvexConsequence.AxiomSurvival

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

end FormalSystem.Metalogic.ConvexConsequence
