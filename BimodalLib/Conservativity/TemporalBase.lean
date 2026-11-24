/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Conservativity
import FormalSystem.ProofSystem.DerivedAxioms
import Mathlib.Data.Sum.Order
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Tauto
import Mathlib.Tactic.Linarith

/-!
# The temporal edge at the base class is refuted

The temporal cell at the base frame class is not conserved by the full base system: there is a
formula in Until alone that the full system derives at `FrameClass.Base` and that no derivation
within the temporal cell reaches.

## The argument

* `BimodalLib.LTruth` is truth of a formula at a point of a strict order `lt` under a valuation
  of the atoms at points. Until and Since are read over `lt`. The operator `□` is read as the
  identity. That reading is harmless here: a derivation within the temporal cell derives no
  formula in which `□` occurs, so the clause for `□` is never met by the soundness proof.
* `BimodalLib.temporalCell_sound`: a closed derivation at `FrameClass.Base` within the temporal cell
  derives only formulas true at every point of every linear order without endpoints
  (`BimodalLib.Lin`).
* The witness is `BimodalLib.nfWitness`, the formula `X⊤ → G X⊤` ("if there is a next moment,
  there always will be one"). The full system derives it at the base class
  (`FormalSystem.ProofSystem.DerivedAxioms.discretePropagateFwd`), by a proof that passes
  through `□`.
* The witness fails at a point of `ℤ ⊕ₗ ℚ`, the integers followed by the rationals
  (`BimodalLib.nfWitness_fails`): each integer has a successor, no rational has one.

So the temporal cell at the base class is sound for every linear order without endpoints, and
the full system at the base class is not.

## Main statements

* `BimodalLib.not_conservativeEdge_temporal_base`: the refutation.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalLib

/-- Truth of a formula at a point of a strict order `lt`, under a valuation `v` of the atoms at
points. `□` is read as the identity; no derivation within the temporal cell meets that clause. -/
def LTruth {T : Type} (lt : T → T → Prop) (v : T → Atom → Prop) : Formula → T → Prop
  | .atom a, t => v t a
  | .bot, _ => False
  | .imp φ ψ, t => LTruth lt v φ t → LTruth lt v ψ t
  | .box φ, t => LTruth lt v φ t
  | .untl g e, t => ∃ s, lt t s ∧ LTruth lt v e s ∧ ∀ r, lt t r → lt r s → LTruth lt v g r
  | .snce g e, t => ∃ s, lt s t ∧ LTruth lt v e s ∧ ∀ r, lt r t → lt s r → LTruth lt v g r

/-- A strict linear order without endpoints: transitive, total, with no greatest and no least
point. -/
structure Lin {T : Type} (lt : T → T → Prop) : Prop where
  /-- The order is transitive. -/
  trans : ∀ {a b c}, lt a b → lt b c → lt a c
  /-- Any two points are comparable or equal. -/
  tri : ∀ a b, lt a b ∨ a = b ∨ lt b a
  /-- Every point has a later one. -/
  noMax : ∀ a, ∃ b, lt a b
  /-- Every point has an earlier one. -/
  noMin : ∀ a, ∃ b, lt b a

/-- The converse of a linear order without endpoints is one. -/
theorem Lin.flip {T : Type} {lt : T → T → Prop} (L : Lin lt) : Lin (fun a b => lt b a) where
  trans := fun h1 h2 => L.trans h2 h1
  tri := fun a b => by rcases L.tri a b with h | h | h <;> tauto
  noMax := L.noMin
  noMin := L.noMax

variable {T : Type} {lt : T → T → Prop} {v : T → Atom → Prop}

/-- Truth of the time reflection of a formula is truth of the formula over the converse
order. -/
theorem lTruth_reflectTime (φ : Formula) (t : T) :
    LTruth lt v φ.reflectTime t ↔ LTruth (fun a b => lt b a) v φ t := by
  induction φ generalizing t with
  | atom a => simp [Formula.reflectTime, LTruth]
  | bot => simp [Formula.reflectTime, LTruth]
  | imp φ ψ ih1 ih2 => simp [Formula.reflectTime, LTruth, ih1, ih2]
  | box φ ih => simp [Formula.reflectTime, LTruth, ih]
  | untl g e ih1 ih2 => simp [Formula.reflectTime, LTruth, ih1, ih2]
  | snce g e ih1 ih2 => simp [Formula.reflectTime, LTruth, ih1, ih2]

/-- Truth of an implication. -/
@[simp] theorem lTruth_imp (φ ψ : Formula) (t : T) :
    LTruth lt v (φ.imp ψ) t ↔ (LTruth lt v φ t → LTruth lt v ψ t) := Iff.rfl
/-- Falsum is true nowhere. -/
@[simp] theorem lTruth_bot (t : T) : LTruth lt v Formula.bot t ↔ False := Iff.rfl
/-- Truth of a negation. -/
@[simp] theorem lTruth_neg (φ : Formula) (t : T) :
    LTruth lt v φ.neg t ↔ ¬ LTruth lt v φ t := Iff.rfl
/-- Verum is true everywhere. -/
@[simp] theorem lTruth_top (t : T) : LTruth lt v Formula.top t ↔ True := by simp [Formula.top]
/-- Truth of a conjunction. -/
@[simp] theorem lTruth_and (φ ψ : Formula) (t : T) :
    LTruth lt v (φ.and ψ) t ↔ (LTruth lt v φ t ∧ LTruth lt v ψ t) := by
  simp only [Formula.and, lTruth_neg, lTruth_imp]; tauto
/-- Truth of a disjunction. -/
@[simp] theorem lTruth_or (φ ψ : Formula) (t : T) :
    LTruth lt v (φ.or ψ) t ↔ (LTruth lt v φ t ∨ LTruth lt v ψ t) := by
  simp only [Formula.or, lTruth_neg, lTruth_imp]; tauto
/-- Truth of Until: some later point satisfies the event and every point strictly between
satisfies the guard. -/
theorem lTruth_untl (g e : Formula) (t : T) : LTruth lt v (g.untl e) t ↔
    ∃ s, lt t s ∧ LTruth lt v e s ∧ ∀ r, lt t r → lt r s → LTruth lt v g r := Iff.rfl
/-- Truth of "at some later point". -/
@[simp] theorem lTruth_someFuture (φ : Formula) (t : T) :
    LTruth lt v φ.someFuture t ↔ ∃ s, lt t s ∧ LTruth lt v φ s := by
  simp [Formula.someFuture, lTruth_untl]
/-- Truth of "at every later point". -/
@[simp] theorem lTruth_allFuture (φ : Formula) (t : T) :
    LTruth lt v φ.allFuture t ↔ ∀ s, lt t s → LTruth lt v φ s := by
  simp [Formula.allFuture]

/-- Soundness of the temporal cell at the base class: a closed derivation within the cell derives
a formula true at every point of every linear order without endpoints. -/
theorem temporalCell_sound : ∀ {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Base Γ φ),
    Γ = [] → within { temporal := true } d →
    ∀ (T : Type) (lt : T → T → Prop), Lin lt → ∀ (v : T → Atom → Prop) (t : T),
      LTruth lt v φ t := by
  intro Γ φ d
  induction d with
  | «axiom» Γ φ h hfc =>
    intro _ hw T lt L v t
    simp only [within] at hw
    cases h with
    | prop_k φ ψ χ => simp only [lTruth_imp]; tauto
    | prop_s φ ψ => simp only [lTruth_imp]; tauto
    | ex_falso φ => simp
    | peirce φ ψ => simp only [lTruth_imp]; tauto
    | modal_t φ => exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | modal_5_collapse φ =>
      exact absurd hw
        (by simp [profileF, Profile.join, LE.le, Profile.le, Formula.diamond, Formula.neg])
    | modal_k_dist φ ψ => exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | serial_future => simpa using L.noMax t
    | left_mono_until_G φ χ ψ =>
      simp only [lTruth_imp, lTruth_allFuture, lTruth_untl]
      rintro hG ⟨s, hs, he, hg⟩
      exact ⟨s, hs, he, fun r h1 h2 => hG r h1 (hg r h1 h2)⟩
    | right_mono_until φ ψ χ =>
      simp only [lTruth_imp, lTruth_allFuture, lTruth_untl]
      rintro hG ⟨s, hs, he, hg⟩
      exact ⟨s, hs, hG s hs he, hg⟩
    | enrichment_until φ ψ p =>
      simp only [lTruth_imp, lTruth_and, lTruth_untl]
      rintro ⟨hp, s, hs, he, hg⟩
      exact ⟨s, hs, ⟨he, t, hs, hp, fun r h1 h2 => hg r h2 h1⟩, hg⟩
    | self_accum_until φ ψ =>
      simp only [lTruth_imp, lTruth_and, lTruth_untl]
      rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, he, fun r h1 h2 => ⟨hg r h1 h2, s, h2, he,
        fun r' h1' h2' => hg r' (L.trans h1 h1') h2'⟩⟩
    | absorb_until φ ψ =>
      simp only [lTruth_imp, lTruth_and, lTruth_untl]
      rintro ⟨s, hs, ⟨hφ, s', hs', he, hg'⟩, hg⟩
      refine ⟨s', L.trans hs hs', he, fun r h1 h2 => ?_⟩
      rcases L.tri r s with h | h | h
      · exact hg r h1 h
      · exact h ▸ hφ
      · exact hg' r h h2
    | linear_until φ ψ χ θ =>
      simp only [lTruth_imp, lTruth_and, lTruth_or, lTruth_untl]
      rintro ⟨⟨s, hs, he, hg⟩, s', hs', he', hg'⟩
      rcases L.tri s s' with h | h | h
      · exact Or.inr (Or.inl ⟨s, hs, ⟨he, hg' s hs h⟩,
          fun r h1 h2 => ⟨hg r h1 h2, hg' r h1 (L.trans h2 h)⟩⟩)
      · subst h
        exact Or.inl ⟨s, hs, ⟨he, he'⟩, fun r h1 h2 => ⟨hg r h1 h2, hg' r h1 h2⟩⟩
      · exact Or.inr (Or.inr ⟨s', hs', ⟨hg s' hs' h, he'⟩,
          fun r h1 h2 => ⟨hg r h1 (L.trans h2 h), hg' r h1 h2⟩⟩)
    | modal_future φ => exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | discrete_box_necessity =>
      exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | prior_UZ φ =>
      exact absurd hfc (by change ¬ (FrameClass.ZTime ≤ FrameClass.Base); decide)
    | dense_indicator => exact absurd hfc (by decide)
    | prior_U_gap φ =>
      exact absurd hfc (by change ¬ (FrameClass.RTime ≤ FrameClass.Base); decide)
    | sep φ => exact absurd hfc (by change ¬ (FrameClass.RTime ≤ FrameClass.Base); decide)
  | assumption Γ φ h => intro hΓ; subst hΓ; cases h
  | modus_ponens Γ φ ψ d1 d2 ih1 ih2 =>
    intro hΓ hw T lt L v t
    simp only [within] at hw
    exact ih1 hΓ hw.2.1 T lt L v t (ih2 hΓ hw.2.2 T lt L v t)
  | necessitation φ d ih =>
    intro _ hw
    simp only [within, conclOf] at hw
    exact absurd hw.1 (by simp [profileF, LE.le, Profile.le])
  | temporal_necessitation φ d ih =>
    intro _ hw T lt L v t
    simp only [within] at hw
    simp only [lTruth_allFuture]
    exact fun s _ => ih rfl hw.2 T lt L v s
  | time_reflection φ d ih =>
    intro _ hw T lt L v t
    simp only [within] at hw
    exact (lTruth_reflectTime φ t).mpr (ih rfl hw.2 T _ L.flip v t)
  | weakening Γ Δ φ d h ih =>
    intro hΔ hw T lt L v t
    subst hΔ
    simp only [within] at hw
    exact ih (List.subset_nil.mp h) hw.2 T lt L v t

/-- The witness `X⊤ → G X⊤`: if there is a next moment, there always will be one. The full base
system derives it at the base class. -/
def nfWitness : Formula := (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
  (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))

/-- The integers followed by the rationals, in the lexicographic order. -/
abbrev ZQ := ℤ ⊕ₗ ℚ

/-- The integers followed by the rationals are a linear order without endpoints. -/
theorem lin_zq : Lin (fun a b : ZQ => a < b) where
  trans := lt_trans
  tri := fun a b => lt_trichotomy a b
  noMax := exists_gt
  noMin := exists_lt

/-- The witness fails at the integer `0` of `ZQ`: `0` has the successor `1`, and no rational
later than it has a successor. -/
theorem nfWitness_fails :
    ¬ LTruth (fun a b : ZQ => a < b) (fun _ _ => False) nfWitness (toLex (Sum.inl 0)) := by
  intro h
  simp only [nfWitness, lTruth_imp, lTruth_allFuture, lTruth_untl, lTruth_bot] at h
  have h0 : ∃ s : ZQ, toLex (Sum.inl 0) < s ∧
      LTruth (fun a b : ZQ => a < b) (fun _ _ => False) (Formula.bot.imp Formula.bot) s ∧
      ∀ r : ZQ, toLex (Sum.inl 0) < r → r < s → False := by
    refine ⟨toLex (Sum.inl 1), by simp [Sum.Lex.toLex_lt_toLex], by simp, ?_⟩
    intro r h1 h2
    obtain ⟨r, rfl⟩ := toLex.surjective r
    rcases r with n | q
    · simp [Sum.Lex.toLex_lt_toLex] at h1 h2; omega
    · simp [Sum.Lex.toLex_lt_toLex] at h2
  obtain ⟨s, hs, -, hgap⟩ := h h0 (toLex (Sum.inr 0)) (by simp [Sum.Lex.toLex_lt_toLex])
  obtain ⟨s, rfl⟩ := toLex.surjective s
  rcases s with n | q
  · simp [Sum.Lex.toLex_lt_toLex] at hs
  · have hq : (0 : ℚ) < q := by simpa [Sum.Lex.toLex_lt_toLex] using hs
    exact hgap (toLex (Sum.inr (q / 2))) (by simp [Sum.Lex.toLex_lt_toLex]; linarith)
      (by simp [Sum.Lex.toLex_lt_toLex]; linarith)

/-- The temporal cell at the base class is not conserved by the full base system. The witness is
`nfWitness`. -/
theorem not_conservativeEdge_temporal_base :
    ¬ ConservativeEdge { temporal := true } FrameClass.Base := by
  intro h
  obtain ⟨d, hd⟩ := h nfWitness (by decide) ⟨DerivedAxioms.discretePropagateFwd⟩
  exact nfWitness_fails (temporalCell_sound d rfl hd ZQ _ lin_zq _ _)

end BimodalLib
