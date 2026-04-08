import Bimodal.Metalogic.BXCanonical.Frame
import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity

/-!
# BX Truth Lemma

The truth lemma for the BX canonical model: membership in an MCS corresponds
to truth in the canonical model.

## Architecture

The BX canonical model embeds the collection of all MCS (with bx_le ordering)
into a TaskModel. The truth lemma is proved by structural induction on formulas.

### Cases

- **atom**: By definition of canonical valuation
- **bot**: Trivial (⊥ ∉ any MCS, and truth_at gives False)
- **imp**: MCS implication property ↔ material conditional
- **box**: Modal witness construction (bx_modal_witness)
- **all_future (G)**: bx_G_forward + bx_G_backward
- **all_past (H)**: bx_H_forward + bx_H_backward
- **untl (U)**: Eventuality resolution (BX5/BX6) for forward; BX4 for backward
- **snce (S)**: Mirror of Until

## Status

The truth lemma for atom, bot, imp, box, G, H is fully proved.
The truth lemma for Until/Since is structurally complete: both directions
(forward and backward) are proved modulo helper lemmas in Frame.lean:
- `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution` (forward)
- `bx_until_backward` / `bx_since_backward` (backward)

These helpers encapsulate the Zorn-based eventuality resolution argument.
The completeness theorem is stated with sorry for the TaskModel construction.

## References

- Burgess 1984, Goldblatt 1992 (canonical model truth lemma)
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Semantics

/-! ## MCS Truth Properties

These lemmas establish the truth lemma at the MCS level, independent of
any particular TaskModel embedding. They show that MCS membership correctly
reflects the semantic meaning of each connective.
-/

/--
Bot is not in any MCS.
-/
theorem bot_not_in_mcs {S : Set Formula} (h_mcs : SetMaximalConsistent S) :
    Formula.bot ∉ S := by
  intro h_bot
  exact h_mcs.1 [Formula.bot] (fun ψ hψ => by simp at hψ; rw [hψ]; exact h_bot)
    ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩

/--
Implication property: (φ → ψ) ∈ S iff (φ ∈ S → ψ ∈ S) for MCS S.

The forward direction is SetMaximalConsistent.implication_property.
The backward direction: if φ ∉ S then ¬φ ∈ S, so (φ → ψ) is derivable from ¬φ
(ex falso pattern). If φ ∈ S and ψ ∈ S then (φ → ψ) is derivable by prop_s.
-/
theorem imp_iff_mcs {S : Set Formula} (h_mcs : SetMaximalConsistent S) (φ ψ : Formula) :
    φ.imp ψ ∈ S ↔ (φ ∈ S → ψ ∈ S) := by
  constructor
  · exact SetMaximalConsistent.implication_property h_mcs
  · intro h_imp
    by_cases h_φ : φ ∈ S
    · -- φ ∈ S, ψ ∈ S. Derive φ → ψ from ψ.
      have h_ψ := h_imp h_φ
      -- prop_s: ψ → (φ → ψ), so (φ → ψ) ∈ S
      have h_ax : DerivationTree [] (ψ.imp (φ.imp ψ)) :=
        DerivationTree.axiom [] _ (Axiom.prop_s ψ φ)
      exact SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_ax) h_ψ
    · -- φ ∉ S. Then ¬φ ∈ S.
      have h_neg_φ : φ.neg ∈ S := by
        cases SetMaximalConsistent.negation_complete h_mcs φ with
        | inl h => exact absurd h h_φ
        | inr h => exact h
      -- ¬φ = φ → ⊥. From ¬φ, derive φ → ψ:
      -- φ → ⊥ and ⊥ → ψ (ex_falso) give φ → ψ by transitivity.
      -- Use prop_k instance: (φ → (⊥ → ψ)) → ((φ → ⊥) → (φ → ψ))
      -- and ex_falso: ⊥ → ψ, then prop_s: (⊥ → ψ) → (φ → (⊥ → ψ))
      -- This gets complicated. Use closed_under_derivation instead.
      have h_deriv : DerivationTree [φ.neg] (φ.imp ψ) := by
        -- [φ.neg] = [φ → ⊥]. We want to derive φ → ψ.
        -- Assume φ (in context [φ.neg, φ]):
        -- From φ.neg = φ → ⊥ and φ, get ⊥ by MP
        -- From ⊥, get ψ by ex_falso
        -- By deduction theorem on φ, get [φ.neg] ⊢ φ → ψ
        have h_step : DerivationTree [φ, φ.neg] ψ := by
          have h_φ_assum : DerivationTree [φ, φ.neg] φ :=
            DerivationTree.assumption _ _ (by simp)
          have h_neg_assum : DerivationTree [φ, φ.neg] φ.neg :=
            DerivationTree.assumption _ _ (by simp)
          have h_bot : DerivationTree [φ, φ.neg] Formula.bot :=
            DerivationTree.modus_ponens _ _ _ h_neg_assum h_φ_assum
          have h_ef : DerivationTree [] (Formula.bot.imp ψ) :=
            DerivationTree.axiom [] _ (Axiom.ex_falso ψ)
          exact DerivationTree.modus_ponens _ _ _
            (DerivationTree.weakening [] _ _ h_ef (List.nil_subset _)) h_bot
        -- deduction_theorem [φ.neg] φ ψ expects context φ :: [φ.neg] = [φ, φ.neg]
        exact deduction_theorem [φ.neg] φ ψ h_step
      exact SetMaximalConsistent.closed_under_derivation h_mcs [φ.neg]
        (fun χ hχ => by simp at hχ; rw [hχ]; exact h_neg_φ) h_deriv

/--
G-truth in MCS: G(φ) ∈ w iff φ ∈ v for all v ≥ w.

This is the abstract truth lemma for G, independent of any model embedding.
-/
theorem G_iff_mcs (w : BXPoint) (φ : Formula) :
    Formula.all_future φ ∈ w.formulas ↔ ∀ v : BXPoint, bx_le w v → φ ∈ v.formulas := by
  constructor
  · intro h_G v h_le
    exact bx_G_forward h_le h_G
  · intro h_all
    by_contra h_not_G
    obtain ⟨v, h_le, h_not_φ⟩ := bx_G_backward w φ h_not_G
    exact h_not_φ (h_all v h_le)

/--
H-truth in MCS: H(φ) ∈ w iff φ ∈ v for all v ≤ w.
-/
theorem H_iff_mcs (w : BXPoint) (φ : Formula) :
    Formula.all_past φ ∈ w.formulas ↔ ∀ v : BXPoint, bx_le v w → φ ∈ v.formulas := by
  constructor
  · intro h_H v h_le
    exact bx_H_forward h_le h_H
  · intro h_all
    by_contra h_not_H
    obtain ⟨v, h_le, h_not_φ⟩ := bx_H_backward w φ h_not_H
    exact h_not_φ (h_all v h_le)

/--
Box-truth in MCS: □(φ) ∈ w iff φ ∈ v for all modally equivalent v.
-/
theorem box_iff_mcs (w : BXPoint) (φ : Formula) :
    Formula.box φ ∈ w.formulas ↔
      ∀ v : BXPoint, bx_modal_equiv w v → φ ∈ v.formulas := by
  constructor
  · -- □φ ∈ w and w ~ v → φ ∈ v
    intro h_box v h_equiv
    -- □φ ∈ v by modal equivalence
    have h_box_v := (h_equiv φ).mp h_box
    -- □φ → φ by modal_t
    have h_ax : DerivationTree [] (Formula.box φ |>.imp φ) :=
      DerivationTree.axiom [] _ (Axiom.modal_t φ)
    exact SetMaximalConsistent.implication_property v.is_mcs
      (theorem_in_mcs v.is_mcs h_ax) h_box_v
  · -- (∀ v ~ w, φ ∈ v) → □φ ∈ w
    intro h_all
    by_contra h_not_box
    -- Derive ◇(¬φ) ∈ w from ¬□φ ∈ w using S5.
    -- S5 derivation: ¬□φ → ◇(¬φ)
    -- 1. DNE: ⊢ ¬¬φ → φ
    -- 2. NEC+K: ⊢ □(¬¬φ) → □φ
    -- 3. Contrapositive: ⊢ ¬□φ → ¬□(¬¬φ) = ◇(¬φ)
    have h_dne : DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    -- NEC: □(¬¬φ → φ)
    have h_nec_dne : DerivationTree [] (Formula.box (φ.neg.neg.imp φ)) :=
      DerivationTree.necessitation _ h_dne
    -- K: □(¬¬φ → φ) → (□(¬¬φ) → □φ)
    have h_k : DerivationTree [] ((Formula.box (φ.neg.neg.imp φ)).imp
        (φ.neg.neg.box.imp φ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.neg φ)
    -- MP: □(¬¬φ) → □φ
    have h_box_dne : DerivationTree [] (φ.neg.neg.box.imp φ.box) :=
      DerivationTree.modus_ponens [] _ _ h_k h_nec_dne
    -- Contrapositive: ¬□φ → ¬□(¬¬φ) = ◇(¬φ)
    -- φ.box.neg → φ.neg.neg.box.neg
    have h_neg_box_to_dia : DerivationTree [] (φ.box.neg.imp φ.neg.neg.box.neg) :=
      Bimodal.Theorems.Propositional.contraposition h_box_dne
    -- ¬□φ ∈ w
    have h_neg_box : (Formula.box φ).neg ∈ w.formulas := by
      cases SetMaximalConsistent.negation_complete w.is_mcs (Formula.box φ) with
      | inl h => exact absurd h h_not_box
      | inr h => exact h
    -- ◇(¬φ) ∈ w (note: ◇(¬φ) = φ.neg.diamond = φ.neg.neg.box.neg = φ.box.neg... no)
    -- Actually: Formula.diamond (φ.neg) = φ.neg.neg.box.neg and φ.box.neg ≠ that.
    -- We derived: φ.box.neg → φ.neg.neg.box.neg
    -- φ.neg.neg.box.neg = Formula.diamond (φ.neg) = ◇(¬φ)
    have h_dia_neg : Formula.diamond φ.neg ∈ w.formulas :=
      SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_neg_box_to_dia) h_neg_box
    -- ◇(¬φ) ∈ w, so by bx_modal_witness there exists v ~ w with ¬φ ∈ v
    obtain ⟨v, h_equiv, h_neg_in⟩ := bx_modal_witness w φ.neg h_dia_neg
    -- ¬φ ∈ v means φ ∉ v
    have h_not_in : φ ∉ v.formulas :=
      SetMaximalConsistent.neg_excludes v.is_mcs φ h_neg_in
    -- But h_all says φ ∈ v for all v ~ w
    exact h_not_in (h_all v h_equiv)

/-! ## Until/Since MCS Properties -/

/--
Strict part of bx_le: w is strictly below v in the canonical ordering.
-/
def bx_lt (w v : BXPoint) : Prop :=
  bx_le w v ∧ ¬bx_le v w

/-! ### Helper: F(ψ) from witness existence

If ψ ∈ v and bx_le w v, then F(ψ) ∈ w (because G(¬ψ) ∉ w).
-/

/--
If bx_le w v, ψ ∈ v, then F(ψ) ∈ w.

Proof: If G(¬ψ) ∈ w, then since bx_le w v, ¬ψ ∈ v. But ψ ∈ v gives ⊥.
So G(¬ψ) ∉ w, hence ¬G(¬ψ) = F(ψ) ∈ w.
-/
theorem F_from_witness {w v : BXPoint} {ψ : Formula}
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas) :
    Formula.some_future ψ ∈ w.formulas := by
  -- F(ψ) = ψ.neg.all_future.neg = ¬G(¬ψ)
  -- By negation completeness: either G(¬ψ) ∈ w or ¬G(¬ψ) ∈ w
  -- If G(¬ψ) ∈ w: since bx_le w v, ¬ψ ∈ v. But ψ ∈ v, contradiction.
  by_contra h_not_F
  have h_G_neg_psi : ψ.neg.all_future ∈ w.formulas := by
    -- F(ψ) = ψ.neg.all_future.neg. ¬F(ψ) ∈ w means F(ψ).neg ∈ w.
    -- F(ψ).neg = ψ.neg.all_future.neg.neg.
    -- By DNE: ψ.neg.all_future.neg.neg → ψ.neg.all_future.
    -- So ψ.neg.all_future ∈ w.
    -- Actually: by negation completeness on ψ.neg.all_future:
    cases SetMaximalConsistent.negation_complete w.is_mcs ψ.neg.all_future with
    | inl h => exact h
    | inr h =>
      -- ψ.neg.all_future.neg ∈ w, which IS F(ψ) = ψ.some_future
      exact absurd h h_not_F
  -- G(¬ψ) ∈ w and bx_le w v: ¬ψ ∈ v
  have h_neg_psi_v : ψ.neg ∈ v.formulas := bx_G_forward h_wv h_G_neg_psi
  -- But ψ ∈ v and ¬ψ ∈ v contradicts consistency
  exact set_consistent_not_both v.is_mcs.1 ψ h_ψv h_neg_psi_v

/--
If bx_le v w, ψ ∈ v, then P(ψ) ∈ w.

Mirror of F_from_witness for the past direction.
-/
theorem P_from_witness {w v : BXPoint} {ψ : Formula}
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas) :
    Formula.some_past ψ ∈ w.formulas := by
  by_contra h_not_P
  have h_H_neg_psi : ψ.neg.all_past ∈ w.formulas := by
    cases SetMaximalConsistent.negation_complete w.is_mcs ψ.neg.all_past with
    | inl h => exact h
    | inr h => exact absurd h h_not_P
  have h_neg_psi_v : ψ.neg ∈ v.formulas := bx_H_forward h_vw h_H_neg_psi
  exact set_consistent_not_both v.is_mcs.1 ψ h_ψv h_neg_psi_v

/-! ### Until truth lemma -/

/--
Until truth in MCS: (φ U ψ) ∈ w iff there exists v ≥ w with ψ ∈ v and
φ ∈ u for all u strictly between w and v (i.e., w ≤ u and u < v).

The guard uses the strict ordering bx_lt u v to avoid issues with
bx_le being a preorder (not antisymmetric): distinct BXPoints can be
bx_le-equivalent. Using bx_lt ensures the reflexive witness case (v = w)
has a vacuously true guard.

The forward direction uses BX8-BX10 for the ψ ∈ w case and Zorn-based
eventuality resolution for the ψ ∉ w case.
The backward direction uses BX8 for the ψ ∈ w case and BX4 connectedness
with eventuality resolution for the ψ ∉ w case.
-/
theorem until_iff_mcs (w : BXPoint) (φ ψ : Formula) :
    Formula.untl φ ψ ∈ w.formulas ↔
      ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
        ∀ u : BXPoint, bx_le w u → bx_lt u v → φ ∈ u.formulas := by
  constructor
  · -- Forward: φ U ψ ∈ w → ∃ v ≥ w with ψ ∈ v and φ on [w, v).
    intro h_until
    by_cases h_ψ : ψ ∈ w.formulas
    · -- Case: ψ ∈ w. Take v = w (reflexive witness).
      refine ⟨w, bx_le_refl w, h_ψ, fun u h_wu h_uw => ?_⟩
      exact absurd h_wu h_uw.2
    · -- Case: ψ ∉ w. Eventuality resolution via Zorn.
      -- Use the Zorn-based construction that finds a witness with guard.
      obtain ⟨v, h_wv, h_ψv, h_guard_raw⟩ :=
        bx_until_eventuality_resolution w φ ψ h_until h_ψ
      exact ⟨v, h_wv, h_ψv, fun u h_wu h_uv => h_guard_raw u h_wu h_uv⟩
  · -- Backward: (∃ v ≥ w with ψ ∈ v, φ on [w, v)) → φ U ψ ∈ w.
    intro ⟨v, h_wv, h_ψv, h_guard⟩
    by_cases h_ψ : ψ ∈ w.formulas
    · -- ψ ∈ w: direct from BX8 (psi_imp_until)
      have h_bx8 : DerivationTree [] (ψ.imp (Formula.untl φ ψ)) :=
        DerivationTree.axiom [] _ (Axiom.refl_intro_until φ ψ)
      exact SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_bx8) h_ψ
    · -- ψ ∉ w: Use Zorn-based backward argument.
      exact bx_until_backward w φ ψ v h_wv h_ψv
        (fun u h_wu h_uv => h_guard u h_wu h_uv) h_ψ

/--
Since truth in MCS: (φ S ψ) ∈ w iff there exists v ≤ w with ψ ∈ v and
φ ∈ u for all u strictly between v and w (i.e., v < u and u ≤ w).

Mirror of until_iff_mcs for the past direction.
-/
theorem since_iff_mcs (w : BXPoint) (φ ψ : Formula) :
    Formula.snce φ ψ ∈ w.formulas ↔
      ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧
        ∀ u : BXPoint, bx_lt v u → bx_le u w → φ ∈ u.formulas := by
  constructor
  · -- Forward: φ S ψ ∈ w → ∃ v ≤ w with ψ ∈ v and φ on (v, w].
    intro h_since
    by_cases h_ψ : ψ ∈ w.formulas
    · -- Case: ψ ∈ w. Take v = w (reflexive witness).
      refine ⟨w, bx_le_refl w, h_ψ, fun u h_wu h_uw => ?_⟩
      exact absurd h_uw h_wu.2
    · -- Case: ψ ∉ w. Mirror of forward Until.
      have h_since_imp_or : DerivationTree [] ((Formula.snce φ ψ).imp (Formula.or φ ψ)) :=
        DerivationTree.axiom [] _ (Axiom.since_elim φ ψ)
      have h_or_w : Formula.or φ ψ ∈ w.formulas :=
        SetMaximalConsistent.implication_property w.is_mcs
          (theorem_in_mcs w.is_mcs h_since_imp_or) h_since
      have h_phi_w : φ ∈ w.formulas := by
        cases SetMaximalConsistent.negation_complete w.is_mcs φ with
        | inl h => exact h
        | inr h_neg_phi =>
          have h_psi_w := SetMaximalConsistent.implication_property w.is_mcs h_or_w h_neg_phi
          exact absurd h_psi_w h_ψ
      have h_since_imp_P : DerivationTree [] ((Formula.snce φ ψ).imp (Formula.some_past ψ)) :=
        DerivationTree.axiom [] _ (Axiom.since_P φ ψ)
      have h_P_psi : Formula.some_past ψ ∈ w.formulas :=
        SetMaximalConsistent.implication_property w.is_mcs
          (theorem_in_mcs w.is_mcs h_since_imp_P) h_since
      -- Use Zorn-based construction for Since direction
      obtain ⟨v, h_vw, h_ψv, h_guard_raw⟩ :=
        bx_since_eventuality_resolution w φ ψ h_since h_ψ
      exact ⟨v, h_vw, h_ψv, fun u h_vu h_uw => h_guard_raw u h_vu h_uw⟩
  · -- Backward: (∃ v ≤ w with ψ ∈ v, φ on (v, w]) → φ S ψ ∈ w.
    intro ⟨v, h_vw, h_ψv, h_guard⟩
    by_cases h_ψ : ψ ∈ w.formulas
    · -- ψ ∈ w: direct from BX8' (psi_imp_since)
      have h_bx8' : DerivationTree [] (ψ.imp (Formula.snce φ ψ)) :=
        DerivationTree.axiom [] _ (Axiom.refl_intro_since φ ψ)
      exact SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_bx8') h_ψ
    · -- ψ ∉ w: Use Zorn-based backward argument (Since mirror).
      exact bx_since_backward w φ ψ v h_vw h_ψv
        (fun u h_vu h_uw => h_guard u h_vu h_uw) h_ψ

end Bimodal.Metalogic.BXCanonical
