/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.CoarsenedModels

/-!
# Paste-closed coarsened models: soundness of all of TM⁺ at `.Base`

`Metalogic/Independence/CoarsenedModels.lean` shows that every *naive* theorem of TM⁺ — every
theorem whose derivation avoids the two pasting schemata `paste` (PS) and `untl_paste` (US) — is
valid on every coarsened-state model. PS and US themselves are refutable there
(`Metalogic/Independence/PastingIndependence.lean`), because two world histories in the same
`π`-class at `t` need not pass through a common state, so there is nothing for a splice to pass
through.

This module restores exactly what those two schemata need, and no more. A coarse model is
**paste-closed** when the splice exists *at the level of `π`-images*: for world histories `ρ` and
`σ` in the same `π`-class at `t` there is a world history `η` whose `π`-image follows `ρ` up to
and including `t` and follows `σ` from `t` on. The states of `η` are unconstrained; only the image
is. Under that hypothesis PS, US and their temporal duals are coarsely valid, and since
`PlusAxiom.IsNaive` is false on exactly those two schemata, the whole of TM⁺ at `.Base` is sound
for paste-closed coarse models.

The point of the weakening is that paste-closedness is a *finitary* closure condition on the set
of `π`-images of world histories: it says that set is closed under splicing two members at a
common value. It does not say the set is closed under limits, which is what a refutation of a
limit-closure principle exploits.

## Design

`CoarseModel.PasteClosed` is a predicate on `CoarseModel`, not a structure field, so `CoarseModel`
and every consumer of it are untouched. The derivation recursion
`plus_pcValid_and_reflect_time` mirrors `naive_cValid_and_reflect_time` arm for arm, with the
`NaiveOnly` side condition deleted and the `PasteClosed` hypothesis threaded through; it is
well-founded on the derivation's height for the same reason.

## Main Definitions

- `CoarseModel.PasteClosed` — image-level splice at equal `π`-class
- `PCValid` — validity over every paste-closed coarse model

## Main Results

- `c_truth_congr_from`, `c_truth_congr_upTo` — the purity congruences for `CTruthAt`: a
  pure-future (pure-past) formula depends only on the `π`-image from (up to) the time of evaluation
- `c_paste`, `c_paste'`, `c_untl_paste`, `c_snce_paste` — PS, US and their reflected forms
- `plusAxiom_pcValid` — every `.Base` axiom of TM⁺, and its temporal dual, is `PCValid`
- `plus_pcValid_and_reflect_time` — the derivation recursion
- `not_plusDerivable_of_pcRefuted` — the contrapositive, in the shape a refutation consumes

## References

Paper: — (formalization-native; the coarsened semantics is this tree's own)
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open CTruth

variable {F : TaskFrame}

/--
A coarse model is **paste-closed** when two world histories in the same `π`-class at `t` can be
spliced *at the level of `π`-images*: some world history's image follows `ρ` up to and including
`t` and follows `σ` from `t` on. Both clauses include `t`, which is consistent because `ρ` and `σ`
agree under `π` there.
-/
def CoarseModel.PasteClosed (K : CoarseModel F) : Prop :=
  ∀ (ρ σ : WorldHistory F) (t : F.Duration), SameUnder K ρ σ t →
    ∃ η : WorldHistory F, (∀ s, s ≤ t → K.π (η.state s) = K.π (ρ.state s)) ∧
      (∀ s, t ≤ s → K.π (η.state s) = K.π (σ.state s))

/--
**Pure-future congruence.** The coarse truth of a pure-future formula at `t` depends only on the
`π`-image of the history from `t` on. The `π`-image version of `truth_congr_agreeFrom`.
-/
theorem c_truth_congr_from (K : CoarseModel F) {φ : PlusFormula} (hφ : IsPureFuture φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration),
      (∀ s, t ≤ s → K.π (τ.state s) = K.π (σ.state s)) →
      (CTruthAt K τ t φ ↔ CTruthAt K σ t φ) := by
  induction hφ with
  | atom p => intro τ σ t hag; exact K.atom_inv_iff (hag t le_rfl) p
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ => intro τ σ t hag; exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | untl _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hts =>
      and_congr (ihφ τ σ s fun r hr => hag r (le_trans hts.le hr))
        (forall_congr' fun r => imp_congr_right fun htr => imp_congr_right fun _ =>
          ihψ τ σ r fun u hu => hag u (le_trans htr.le hu))

/--
**Pure-past congruence.** The coarse truth of a pure-past formula at `t` depends only on the
`π`-image of the history up to `t`. The `π`-image version of `truth_congr_agreeUpTo`.
-/
theorem c_truth_congr_upTo (K : CoarseModel F) {φ : PlusFormula} (hφ : IsPurePast φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration),
      (∀ s, s ≤ t → K.π (τ.state s) = K.π (σ.state s)) →
      (CTruthAt K τ t φ ↔ CTruthAt K σ t φ) := by
  induction hφ with
  | atom p => intro τ σ t hag; exact K.atom_inv_iff (hag t le_rfl) p
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ => intro τ σ t hag; exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | snce _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hst =>
      and_congr (ihφ τ σ s fun r hr => hag r (le_trans hr hst.le))
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hrt =>
          ihψ τ σ r fun u hu => hag u (le_trans hu hrt.le))

variable {K : CoarseModel F}

/-- **PS on a paste-closed coarse model**: `⟐φ → (⟐ψ → ⟐(φ ∧ ψ))` for `φ` pure-future and `ψ`
pure-past. The image-level splice of the two witnesses carries both conjuncts. -/
theorem c_paste (hK : K.PasteClosed) (τ : WorldHistory F) (t : F.Duration)
    {φ ψ : PlusFormula} (hφ : IsPureFuture φ) (hψ : IsPurePast ψ) :
    CTruthAt K τ t (.imp (dstab φ) (.imp (dstab ψ) (dstab (φ.and ψ)))) := by
  intro h1 h2
  rw [dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hτρ, hψρ⟩ := h2
  obtain ⟨η, hup, hfrom⟩ := hK ρ σ t (hτρ.symm.trans hτσ)
  refine ⟨η, hτρ.trans (hup t le_rfl).symm, ?_⟩
  rw [and_iff]
  exact ⟨(c_truth_congr_from K hφ η σ t hfrom).mpr hφσ,
    (c_truth_congr_upTo K hψ η ρ t hup).mpr hψρ⟩

/-- **The temporal dual of PS**: `⟐ψ → (⟐φ → ⟐(ψ ∧ φ))` for `ψ` pure-past and `φ`
pure-future. -/
theorem c_paste' (hK : K.PasteClosed) (τ : WorldHistory F) (t : F.Duration)
    {ψ φ : PlusFormula} (hψ : IsPurePast ψ) (hφ : IsPureFuture φ) :
    CTruthAt K τ t (.imp (dstab ψ) (.imp (dstab φ) (dstab (ψ.and φ)))) := by
  intro h2 h1
  rw [dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hτρ, hψρ⟩ := h2
  obtain ⟨η, hup, hfrom⟩ := hK ρ σ t (hτρ.symm.trans hτσ)
  refine ⟨η, hτρ.trans (hup t le_rfl).symm, ?_⟩
  rw [and_iff]
  exact ⟨(c_truth_congr_upTo K hψ η ρ t hup).mpr hψρ,
    (c_truth_congr_from K hφ η σ t hfrom).mpr hφσ⟩

/-- **US on a paste-closed coarse model**: `(α U ⟐φ) → ⟐(α U φ)` for `α` pure-past and `φ`
pure-future. Splice the evaluation history into the witness at the `untl` point. -/
theorem c_untl_paste (hK : K.PasteClosed) (τ : WorldHistory F) (t : F.Duration)
    {α φ : PlusFormula} (hα : IsPurePast α) (hφ : IsPureFuture φ) :
    CTruthAt K τ t (.imp (.untl α (dstab φ)) (dstab (.untl α φ))) := by
  rintro ⟨y, hty, hy, hguard⟩
  rw [dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  obtain ⟨η, hup, hfrom⟩ := hK τ ρ y hτρ
  rw [dstab_iff]
  refine ⟨η, (hup t hty.le).symm, y, hty, (c_truth_congr_from K hφ η ρ y hfrom).mpr hφρ, ?_⟩
  intro r htr hry
  exact (c_truth_congr_upTo K hα η τ r fun s hs => hup s (le_trans hs hry.le)).mpr
    (hguard r htr hry)

/-- **The temporal dual of US**: `(α S ⟐φ) → ⟐(α S φ)` for `α` pure-future and `φ` pure-past. -/
theorem c_snce_paste (hK : K.PasteClosed) (τ : WorldHistory F) (t : F.Duration)
    {α φ : PlusFormula} (hα : IsPureFuture α) (hφ : IsPurePast φ) :
    CTruthAt K τ t (.imp (.snce α (dstab φ)) (dstab (.snce α φ))) := by
  rintro ⟨y, hyt, hy, hguard⟩
  rw [dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  obtain ⟨η, hup, hfrom⟩ := hK ρ τ y hτρ.symm
  rw [dstab_iff]
  refine ⟨η, (hfrom t hyt.le).symm, y, hyt, (c_truth_congr_upTo K hφ η ρ y hup).mpr hφρ, ?_⟩
  intro r hyr hrt
  exact (c_truth_congr_from K hα η τ r fun s hs => hfrom s (le_trans hyr.le hs)).mpr
    (hguard r hyr hrt)

/-- Validity over every paste-closed coarse model, at every world history and time. -/
def PCValid (φ : PlusFormula) : Prop :=
  ∀ (F : TaskFrame) (K : CoarseModel F), K.PasteClosed →
    ∀ (τ : WorldHistory F) (t : F.Duration), CTruthAt K τ t φ

/--
Every `.Base` axiom of TM⁺ is valid on every paste-closed coarse model, and so is its temporal
dual. The naive schemata are taken from `naiveAxiom_cValid` and `naiveAxiom_cValid_reflect_time`,
which need no closure hypothesis; the two non-naive schemata are `c_paste` and `c_untl_paste`,
with reflected forms `c_paste'` and `c_snce_paste`.
-/
theorem plusAxiom_pcValid {φ : PlusFormula} (ax : PlusAxiom φ)
    (hb : ax.minFrameClass ≤ FrameClass.Base) : PCValid φ ∧ PCValid φ.reflectTime := by
  by_cases hn : PlusAxiom.IsNaive ax
  · exact ⟨fun F K _ => naiveAxiom_cValid ax hn hb F K,
      fun F K _ => naiveAxiom_cValid_reflect_time ax hn hb F K⟩
  · cases ax
    case paste a0 a1 h0 h1 =>
      refine ⟨fun F K hK τ t => c_paste hK τ t h0 h1, ?_⟩
      simp only [PlusFormula.reflectTime, reflect_time_dstab, reflect_time_and]
      exact fun F K hK τ t => c_paste' hK τ t h0.reflectTime h1.reflectTime
    case untl_paste a0 a1 h0 h1 =>
      refine ⟨fun F K hK τ t => c_untl_paste hK τ t h0 h1, ?_⟩
      simp only [PlusFormula.reflectTime, reflect_time_dstab]
      exact fun F K hK τ t => c_snce_paste hK τ t h0.reflectTime h1.reflectTime
    all_goals exact absurd trivial hn

/--
**The companion recursion for paste-closed soundness.** A theorem of TM⁺ at `.Base` is valid on
every paste-closed coarse model, and so is its temporal dual. Mirror of
`naive_cValid_and_reflect_time`, arm for arm, with the `NaiveOnly` side condition deleted;
well-founded on the derivation's height for the same reason.
-/
theorem plus_pcValid_and_reflect_time {φ : PlusFormula}
    (d : PlusDerivationTree FrameClass.Base [] φ) : PCValid φ ∧ PCValid φ.reflectTime := by
  match d with
  | .axiom _ _ h_ax h_fc => exact plusAxiom_pcValid h_ax h_fc
  | .assumption _ _ h_mem => exact absurd h_mem List.not_mem_nil
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := plus_pcValid_and_reflect_time d1
    have h2 := plus_pcValid_and_reflect_time d2
    exact ⟨fun F K hK τ t => (h1.1 F K hK τ t) (h2.1 F K hK τ t),
      fun F K hK τ t => (h1.2 F K hK τ t) (h2.2 F K hK τ t)⟩
  | .necessitation psi' d' =>
    have h := plus_pcValid_and_reflect_time d'
    exact ⟨fun F K hK _ t σ => h.1 F K hK σ t, fun F K hK _ t σ => h.2 F K hK σ t⟩
  | .temporal_necessitation psi' d' =>
    have h := plus_pcValid_and_reflect_time d'
    constructor
    · intro F K hK τ t
      rw [CTruth.allFuture_iff]
      intro s _
      exact h.1 F K hK τ s
    · intro F K hK τ t
      rw [reflect_time_all_future, CTruth.allPast_iff]
      intro s _
      exact h.2 F K hK τ s
  | .time_reflection psi' d' =>
    have h := plus_pcValid_and_reflect_time d'
    refine ⟨h.2, ?_⟩
    rw [reflect_time_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_term := PlusDerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact plus_pcValid_and_reflect_time (d'.ofWeakeningNil h_sub)
termination_by d.height
decreasing_by
  all_goals first
    | exact PlusDerivationTree.mp_height_gt_left _ _
    | exact PlusDerivationTree.mp_height_gt_right _ _
    | omega
    | simp only [PlusDerivationTree.height]; omega

/--
**Refutation to non-derivability.** A formula refuted at one point of one paste-closed coarse
model is not a `.Base` theorem of TM⁺.

Paper: — (formalization-native)
-/
theorem not_plusDerivable_of_pcRefuted {φ : PlusFormula} (F : TaskFrame) (K : CoarseModel F)
    (hK : K.PasteClosed) (τ : WorldHistory F) (t : F.Duration) (h : ¬ CTruthAt K τ t φ) :
    ¬ PlusDerivable FrameClass.Base [] φ :=
  fun ⟨d⟩ => h ((plus_pcValid_and_reflect_time d).1 F K hK τ t)

end FormalSystem.Metalogic.Independence
