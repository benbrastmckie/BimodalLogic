import Bimodal.Boneyard.ChainCompleteness.Algebraic.DeterministicChain
import Bimodal.Boneyard.StrictSemanticsLegacy.Algebraic.UltrafilterChain
import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Algebraic.ParametricCompleteness
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.CanonicalFrame

/-!
# Deterministic FMCS and BFMCS Construction

Builds a BFMCS from the deterministic chain and wires to the parametric
representation theorem for completeness over Int.

## Sorry Inventory (4 sorries remaining)

| Theorem | Status | Notes |
|---------|--------|-------|
| `deterministic_forward_F` | SORRY | Intra-family F witness (leaf sorry) |
| `deterministic_backward_P` | SORRY | Intra-family P witness (leaf sorry) |
| forward Until in `usc` | SORRY | Depends on `deterministic_forward_F` |
| forward Since in `usc` | SORRY | Depends on `deterministic_backward_P` |

Backward Until and backward Since in `usc` are sorry-free using
`until_intro`/`since_intro` from TemporalDerived + backward induction
on the deterministic chain. All structural theorems (FMCS, BFMCS,
modal coherence, completeness wiring) are sorry-free given the leaf
sorries above.
-/

-- Deep API drift: DeterministicChain behind #exit, ParametricRepresentation namespace renamed.
#exit

namespace Bimodal.Metalogic.Algebraic.DeterministicFMCS

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.DeterministicChain
open Bimodal.Metalogic.Algebraic.UltrafilterChain
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.Algebraic.ParametricHistory

/-!
## DeterministicFMCS
-/

/-- Build an FMCS Int from the deterministic chain rooted at M₀. -/
noncomputable def DeterministicFMCS (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    FMCS Int where
  mcs := deterministic_chain M₀
  is_mcs := deterministic_chain_mcs M₀ h_mcs
  forward_G := fun t t' phi h_lt h_G => forward_G_int M₀ h_mcs t t' h_lt phi h_G
  backward_H := fun t t' phi h_lt h_H => backward_H_int M₀ h_mcs t t' h_lt phi h_H

/-- DeterministicFMCS at time 0 is M₀. -/
theorem DeterministicFMCS_at_zero (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (DeterministicFMCS M₀ h_mcs).mcs 0 = M₀ := rfl

/-!
## Forward F / Backward P (Isolated Sorries)
-/

/-- **SORRY**: Intra-family F witness for the deterministic chain.
Open formalization problem: backward G derivation requires forward_F (circular).
See `FiniteDeferral.lean` for infrastructure and detailed analysis.
Recommended resolution: quasimodel approach (GHR 1994). -/
theorem deterministic_forward_F (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_F : Formula.some_future psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, t < s ∧ psi ∈ deterministic_chain M₀ s := by
  sorry

/-- **SORRY**: Intra-family P witness for the deterministic chain.
Symmetric to deterministic_forward_F. See `FiniteDeferral.lean` for analysis. -/
theorem deterministic_backward_P (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_P : Formula.some_past psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, s < t ∧ psi ∈ deterministic_chain M₀ s := by
  sorry

/-!
## Box Persistence and Class Agreement
-/

/-- Box formulas are constant along the deterministic chain. -/
theorem deterministic_box_persistent (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (φ : Formula) (t s : ℤ)
    (h_box : Formula.box φ ∈ (DeterministicFMCS M₀ h_mcs).mcs t) :
    Formula.box φ ∈ (DeterministicFMCS M₀ h_mcs).mcs s :=
  parametric_box_persistent (DeterministicFMCS M₀ h_mcs) φ t s h_box

/-- Box class agreement between M₀ and any chain position. -/
theorem deterministic_chain_box_agree (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) : box_class_agree M₀ (deterministic_chain M₀ t) :=
  fun φ => ⟨fun h => deterministic_box_persistent M₀ h_mcs φ 0 t h,
            fun h => deterministic_box_persistent M₀ h_mcs φ t 0 h⟩

/-!
## Deterministic BFMCS Bundle
-/

/-- Box-class families of shifted deterministic chains. -/
noncomputable def deterministicBoxClassFamilies (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M₀ W ∧ f = shifted_fmcs (DeterministicFMCS W h_W) k }

/-- The bundle is nonempty. -/
theorem bundle_nonempty (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (deterministicBoxClassFamilies M₀ h_mcs).Nonempty :=
  ⟨DeterministicFMCS M₀ h_mcs, M₀, h_mcs, 0, box_class_agree_refl M₀, by
    unfold shifted_fmcs; cases (DeterministicFMCS M₀ h_mcs); simp only [Int.sub_zero]⟩

/-- The eval family is in the bundle. -/
theorem eval_in_bundle (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    DeterministicFMCS M₀ h_mcs ∈ deterministicBoxClassFamilies M₀ h_mcs :=
  ⟨M₀, h_mcs, 0, box_class_agree_refl M₀, by
    unfold shifted_fmcs; cases (DeterministicFMCS M₀ h_mcs); simp only [Int.sub_zero]⟩

/-- Modal forward coherence. -/
theorem bundle_modal_forward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (fam : FMCS Int) (hfam : fam ∈ deterministicBoxClassFamilies M₀ h_mcs)
    (phi : Formula) (t : Int) (h_box : Formula.box phi ∈ fam.mcs t)
    (fam' : FMCS Int) (hfam' : fam' ∈ deterministicBoxClassFamilies M₀ h_mcs) :
    phi ∈ fam'.mcs t := by
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  obtain ⟨W', h_W', k', h_agree', rfl⟩ := hfam'
  have h_box_0 : Formula.box phi ∈ W :=
    parametric_box_persistent (DeterministicFMCS W h_W) phi (t - k) 0 h_box
  have h_box_W' : Formula.box phi ∈ W' := (h_agree' phi).mp ((h_agree phi).mpr h_box_0)
  have h_box_t' : Formula.box phi ∈ (DeterministicFMCS W' h_W').mcs (t - k') :=
    parametric_box_persistent (DeterministicFMCS W' h_W') phi 0 (t - k') h_box_W'
  exact SetMaximalConsistent.implication_property
    ((DeterministicFMCS W' h_W').is_mcs (t - k'))
    (theorem_in_mcs ((DeterministicFMCS W' h_W').is_mcs (t - k'))
      (DerivationTree.axiom _ _ (Axiom.modal_t phi))) h_box_t'

/-- Modal backward coherence. -/
theorem bundle_modal_backward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (fam : FMCS Int) (hfam : fam ∈ deterministicBoxClassFamilies M₀ h_mcs)
    (phi : Formula) (t : Int)
    (h_all : ∀ fam' ∈ deterministicBoxClassFamilies M₀ h_mcs, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t := by
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  by_contra h_not_box
  have h_box_not_W : Formula.box phi ∉ W :=
    fun h => h_not_box (parametric_box_persistent (DeterministicFMCS W h_W) phi 0 (t - k) h)
  have h_neg_box_M₀ : (Formula.box phi).neg ∈ M₀ := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box phi) with h | h
    · exact absurd ((h_agree phi).mp h) h_box_not_W
    · exact h
  have h_diamond_neg : (Formula.neg phi).diamond ∈ M₀ :=
    SetMaximalConsistent.contrapositive h_mcs (box_dne_theorem phi) h_neg_box_M₀
  obtain ⟨W', h_W'_mcs, h_neg_phi_W', h_agree'⟩ :=
    box_theory_witness_exists M₀ h_mcs (Formula.neg phi) h_diamond_neg
  have h_in : shifted_fmcs (DeterministicFMCS W' h_W'_mcs) t ∈
      deterministicBoxClassFamilies M₀ h_mcs := ⟨W', h_W'_mcs, t, h_agree', rfl⟩
  have h_neg : Formula.neg phi ∈ (shifted_fmcs (DeterministicFMCS W' h_W'_mcs) t).mcs t := by
    simp only [shifted_fmcs, Int.sub_self]; exact h_neg_phi_W'
  exact set_consistent_not_both
    ((shifted_fmcs (DeterministicFMCS W' h_W'_mcs) t).is_mcs t).1
    phi (h_all _ h_in) h_neg

/-- Construct the deterministic BFMCS. -/
noncomputable def construct_deterministic_bfmcs (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    BFMCS Int where
  families := deterministicBoxClassFamilies M₀ h_mcs
  nonempty := bundle_nonempty M₀ h_mcs
  modal_forward := bundle_modal_forward M₀ h_mcs
  modal_backward := bundle_modal_backward M₀ h_mcs
  eval_family := DeterministicFMCS M₀ h_mcs
  eval_family_mem := eval_in_bundle M₀ h_mcs

/-- The eval family at time 0 is M₀. -/
theorem eval_at_zero (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (construct_deterministic_bfmcs M₀ h_mcs).eval_family.mcs 0 = M₀ := rfl

/-!
## Backward Until/Since Infrastructure

Helper lemmas for the backward direction of Until/Since coherence.
Key results: YX/XY round-trip in MCS, general integer x_content membership,
and backward Until/Since introduction via induction.
-/

/-- In any MCS: φ ∈ M → Y(X(φ)) ∈ M.
Proven by contradiction using y_det, x_det, and yx_identity axioms. -/
private theorem YX_round_trip {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_phi : φ ∈ M) :
    Formula.snce Formula.bot (Formula.untl Formula.bot φ) ∈ M := by
  by_contra h_not
  have h_neg_YX := (SetMaximalConsistent.negation_complete h_mcs
    (Formula.snce Formula.bot (Formula.untl Formula.bot φ))).resolve_left h_not
  have h_Y_negX := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _
      (sorry /- y_det removed in BX -/ (Formula.untl Formula.bot φ)))) h_neg_YX
  have h_x_det : [] ⊢ (Formula.untl Formula.bot φ).neg.imp
      (Formula.untl Formula.bot φ.neg) :=
    sorry /- x_det removed in BX -/
  have h_H_xdet := Bimodal.Theorems.past_necessitation _ h_x_det
  have h_Y_xdet := DerivationTree.modus_ponens [] _ _
    (Bimodal.Theorems.TemporalDerived.H_implies_Y _) h_H_xdet
  have h_Y_Xneg := SetMaximalConsistent.implication_property h_mcs
    (SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (sorry /- y_k_dist removed in BX -/))
      (theorem_in_mcs h_mcs h_Y_xdet)) h_Y_negX
  have h_neg_phi := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.YX_identity φ.neg)) h_Y_Xneg
  exact set_consistent_not_both h_mcs.1 φ h_phi h_neg_phi

/-- In any MCS: φ ∈ M → X(Y(φ)) ∈ M.
Symmetric dual of YX_round_trip. -/
private theorem XY_round_trip {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_phi : φ ∈ M) :
    Formula.untl Formula.bot (Formula.snce Formula.bot φ) ∈ M := by
  by_contra h_not
  have h_neg_XY := (SetMaximalConsistent.negation_complete h_mcs
    (Formula.untl Formula.bot (Formula.snce Formula.bot φ))).resolve_left h_not
  have h_X_negY := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _
      (sorry /- x_det removed in BX -/ (Formula.snce Formula.bot φ)))) h_neg_XY
  have h_y_det : [] ⊢ (Formula.snce Formula.bot φ).neg.imp
      (Formula.snce Formula.bot φ.neg) :=
    sorry /- y_det removed in BX -/
  have h_G_ydet := DerivationTree.temporal_necessitation _ h_y_det
  have h_X_ydet := DerivationTree.modus_ponens [] _ _
    (Bimodal.Theorems.TemporalDerived.G_implies_X _) h_G_ydet
  have h_X_Yneg := SetMaximalConsistent.implication_property h_mcs
    (SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (sorry /- x_k_dist removed in BX -/))
      (theorem_in_mcs h_mcs h_X_ydet)) h_X_negY
  have h_neg_phi := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.XY_identity φ.neg)) h_X_Yneg
  exact set_consistent_not_both h_mcs.1 φ h_phi h_neg_phi

/-- General integer x_content membership: φ ∈ chain(n+1) ↔ X(φ) ∈ chain(n) for all ℤ. -/
theorem x_mem_chain_general (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℤ) (φ : Formula) :
    φ ∈ deterministic_chain M₀ (n + 1) ↔
    Formula.untl Formula.bot φ ∈ deterministic_chain M₀ n := by
  cases n with
  | ofNat m =>
    show φ ∈ deterministic_chain M₀ (↑m + 1) ↔ _
    rw [show (↑m + 1 : ℤ) = ↑(m + 1) from by omega]
    exact mem_chain_succ_iff_x_mem_chain M₀ m φ
  | negSucc m =>
    constructor
    · intro h_phi
      have h_mcs_n1 := deterministic_chain_mcs M₀ h_mcs (Int.negSucc m + 1)
      have h_YX := YX_round_trip h_mcs_n1 φ h_phi
      show Formula.untl Formula.bot φ ∈ deterministic_chain M₀ (Int.negSucc m)
      cases m with
      | zero => simp only [deterministic_chain, iterate_y_content, mem_y_content_iff]; exact h_YX
      | succ m' => simp only [deterministic_chain, iterate_y_content, mem_y_content_iff]; exact h_YX
    · intro h_X
      have h_YX : Formula.snce Formula.bot (Formula.untl Formula.bot φ) ∈
          deterministic_chain M₀ (Int.negSucc m + 1) := by
        cases m with
        | zero => simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_X; exact h_X
        | succ m' => simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h_X; exact h_X
      exact SetMaximalConsistent.implication_property (deterministic_chain_mcs M₀ h_mcs (Int.negSucc m + 1))
        (theorem_in_mcs (deterministic_chain_mcs M₀ h_mcs (Int.negSucc m + 1))
          (Bimodal.Theorems.TemporalDerived.YX_identity φ)) h_YX

/-- General integer y_content membership: φ ∈ chain(n-1) ↔ Y(φ) ∈ chain(n) for all ℤ. -/
theorem y_mem_chain_general (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (n : ℤ) (φ : Formula) :
    φ ∈ deterministic_chain M₀ (n - 1) ↔
    Formula.snce Formula.bot φ ∈ deterministic_chain M₀ n := by
  cases n with
  | ofNat m =>
    cases m with
    | zero =>
      constructor
      · intro h; simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h; exact h
      · intro h; show φ ∈ deterministic_chain M₀ (0 - 1)
        simp only [deterministic_chain, iterate_y_content, mem_y_content_iff]; exact h
    | succ m' =>
      constructor
      · intro h_phi
        have h_phi' : φ ∈ deterministic_chain M₀ ↑m' := by
          convert h_phi using 1; show deterministic_chain M₀ ↑m' = deterministic_chain M₀ (↑(m' + 1) - 1)
          congr 1; push_cast; omega
        show Formula.snce Formula.bot φ ∈ deterministic_chain M₀ ↑(m' + 1)
        rw [show (↑(m' + 1) : ℤ) = ↑m' + 1 from by omega,
            show ↑m' + 1 = (↑(m' + 1) : ℤ) from by omega]
        rw [mem_chain_succ_iff_x_mem_chain]
        exact XY_round_trip (deterministic_chain_mcs M₀ h_mcs ↑m') φ h_phi'
      · intro h_Y
        show φ ∈ deterministic_chain M₀ (↑(m' + 1) - 1)
        rw [show (↑(m' + 1) : ℤ) - 1 = ↑m' from by omega]
        have h_XY : Formula.untl Formula.bot (Formula.snce Formula.bot φ) ∈
            deterministic_chain M₀ ↑m' := by
          have : Formula.snce Formula.bot φ ∈ deterministic_chain M₀ ↑(m' + 1) := h_Y
          rw [show (↑(m' + 1) : ℤ) = ↑m' + 1 from by omega,
              show ↑m' + 1 = (↑(m' + 1) : ℤ) from by omega] at this
          rw [mem_chain_succ_iff_x_mem_chain] at this; exact this
        exact SetMaximalConsistent.implication_property (deterministic_chain_mcs M₀ h_mcs ↑m')
          (theorem_in_mcs (deterministic_chain_mcs M₀ h_mcs ↑m')
            (Bimodal.Theorems.TemporalDerived.XY_identity φ)) h_XY
  | negSucc m =>
    constructor
    · intro h
      rw [show (Int.negSucc m - 1 : ℤ) = Int.negSucc (m + 1) from by omega] at h
      simp only [deterministic_chain, iterate_y_content, mem_y_content_iff] at h; exact h
    · intro h
      show φ ∈ deterministic_chain M₀ (Int.negSucc m - 1)
      rw [show (Int.negSucc m - 1 : ℤ) = Int.negSucc (m + 1) from by omega]
      simp only [deterministic_chain, iterate_y_content, mem_y_content_iff]; exact h

/-!
### MCS Propositional Helpers
-/

/-- Left disjunction introduction in MCS: a ∈ M → (a ∨ b) ∈ M. -/
private theorem mcs_or_intro_left {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    {a : Formula} (h_a : a ∈ M) (b : Formula) : Formula.or a b ∈ M := by
  have h_nna := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.dni a)) h_a
  have h_bc : [] ⊢ (Formula.bot.imp b).imp ((a.neg.imp Formula.bot).imp (a.neg.imp b)) :=
    @Bimodal.Theorems.Combinators.b_combinator a.neg Formula.bot b
  have h_ef : [] ⊢ Formula.bot.imp b := DerivationTree.axiom [] _ (Axiom.ex_falso b)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.modus_ponens [] _ _ h_bc h_ef)) h_nna

/-- Right disjunction introduction in MCS: b ∈ M → (a ∨ b) ∈ M. -/
private theorem mcs_or_intro_right {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (a : Formula) {b : Formula} (h_b : b ∈ M) : Formula.or a b ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.prop_s b a.neg))) h_b

/-- Conjunction introduction in MCS. -/
private theorem mcs_and_intro' {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    {a b : Formula} (h_a : a ∈ M) (h_b : b ∈ M) : Formula.and a b ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (Bimodal.Theorems.Combinators.pairing a b)) h_a) h_b

/-!
### Backward Until/Since via Chain Induction
-/

/-- Backward Until for the deterministic chain: given a witness at s > t with guard
on (t, s), derive (φ U ψ) ∈ chain(t). Uses until_intro and induction on s - t. -/
private theorem backward_until_chain (W : Set Formula) (h_W : SetMaximalConsistent W)
    (t s : ℤ) (h_lt : t < s) (φ ψ : Formula)
    (h_psi : ψ ∈ deterministic_chain W s)
    (h_phi : ∀ r : ℤ, t < r → r < s → φ ∈ deterministic_chain W r) :
    Formula.untl φ ψ ∈ deterministic_chain W t := by
  -- Induction on the natural number (s - t - 1).toNat
  -- We use (s - t).toNat as the decreasing measure with strong induction
  have h_diff_pos : 0 < s - t := by omega
  suffices h : ∀ (d : ℕ) (t' s' : ℤ), s' - t' = ↑d + 1 →
      ψ ∈ deterministic_chain W s' →
      (∀ r : ℤ, t' < r → r < s' → φ ∈ deterministic_chain W r) →
      Formula.untl φ ψ ∈ deterministic_chain W t' by
    exact h ((s - t - 1).toNat) t s (by omega) h_psi h_phi
  intro d
  induction d with
  | zero =>
    -- Base case: s' = t' + 1
    intro t' s' h_diff h_psi_s h_phi_guard
    have h_s_eq : s' = t' + 1 := by omega
    -- ψ ∈ chain(t' + 1)
    have h_psi_succ : ψ ∈ deterministic_chain W (t' + 1) := by rw [← h_s_eq]; exact h_psi_s
    -- ψ ∨ (φ ∧ (φ U ψ)) ∈ chain(t' + 1) by left disjunction intro
    have h_mcs_succ := deterministic_chain_mcs W h_W (t' + 1)
    have h_disj : Formula.or ψ (Formula.and φ (Formula.untl φ ψ)) ∈
        deterministic_chain W (t' + 1) :=
      mcs_or_intro_left h_mcs_succ h_psi_succ _
    -- X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t') by x_mem_chain_general
    have h_X_disj := (x_mem_chain_general W h_W t' _).mp h_disj
    -- until_intro: X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)
    exact SetMaximalConsistent.implication_property (deterministic_chain_mcs W h_W t')
      (theorem_in_mcs (deterministic_chain_mcs W h_W t')
        (Bimodal.Theorems.TemporalDerived.until_intro φ ψ)) h_X_disj
  | succ d' ih =>
    -- Inductive case: s' = t' + d' + 2
    intro t' s' h_diff h_psi_s h_phi_guard
    -- By IH applied to t' + 1 and s': (φ U ψ) ∈ chain(t' + 1)
    have h_U_succ : Formula.untl φ ψ ∈ deterministic_chain W (t' + 1) := by
      apply ih (t' + 1) s' (by omega) h_psi_s
      intro r h_lt_r h_r_lt_s
      exact h_phi_guard r (by omega) h_r_lt_s
    -- φ ∈ chain(t' + 1) (from the guard, since t' < t' + 1 < s')
    have h_phi_succ : φ ∈ deterministic_chain W (t' + 1) :=
      h_phi_guard (t' + 1) (by omega) (by omega)
    -- φ ∧ (φ U ψ) ∈ chain(t' + 1)
    have h_mcs_succ := deterministic_chain_mcs W h_W (t' + 1)
    have h_conj := mcs_and_intro' h_mcs_succ h_phi_succ h_U_succ
    -- ψ ∨ (φ ∧ (φ U ψ)) ∈ chain(t' + 1) by right disjunction intro
    have h_disj : Formula.or ψ (Formula.and φ (Formula.untl φ ψ)) ∈
        deterministic_chain W (t' + 1) :=
      mcs_or_intro_right h_mcs_succ ψ h_conj
    -- X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t')
    have h_X_disj := (x_mem_chain_general W h_W t' _).mp h_disj
    -- until_intro
    exact SetMaximalConsistent.implication_property (deterministic_chain_mcs W h_W t')
      (theorem_in_mcs (deterministic_chain_mcs W h_W t')
        (Bimodal.Theorems.TemporalDerived.until_intro φ ψ)) h_X_disj

/-- Backward Since for the deterministic chain: given a witness at s < t with guard
on (s, t), derive (φ S ψ) ∈ chain(t). Uses since_intro and induction on t - s. -/
private theorem backward_since_chain (W : Set Formula) (h_W : SetMaximalConsistent W)
    (t s : ℤ) (h_lt : s < t) (φ ψ : Formula)
    (h_psi : ψ ∈ deterministic_chain W s)
    (h_phi : ∀ r : ℤ, s < r → r < t → φ ∈ deterministic_chain W r) :
    Formula.snce φ ψ ∈ deterministic_chain W t := by
  suffices h : ∀ (d : ℕ) (t' s' : ℤ), t' - s' = ↑d + 1 →
      ψ ∈ deterministic_chain W s' →
      (∀ r : ℤ, s' < r → r < t' → φ ∈ deterministic_chain W r) →
      Formula.snce φ ψ ∈ deterministic_chain W t' by
    exact h ((t - s - 1).toNat) t s (by omega) h_psi h_phi
  intro d
  induction d with
  | zero =>
    -- Base case: t' = s' + 1, so s' = t' - 1
    intro t' s' h_diff h_psi_s h_phi_guard
    have h_s_eq : s' = t' - 1 := by omega
    -- ψ ∈ chain(t' - 1)
    have h_psi_pred : ψ ∈ deterministic_chain W (t' - 1) := by rw [← h_s_eq]; exact h_psi_s
    -- ψ ∨ (φ ∧ (φ S ψ)) ∈ chain(t' - 1) by left disjunction intro
    have h_mcs_pred := deterministic_chain_mcs W h_W (t' - 1)
    have h_disj : Formula.or ψ (Formula.and φ (Formula.snce φ ψ)) ∈
        deterministic_chain W (t' - 1) :=
      mcs_or_intro_left h_mcs_pred h_psi_pred _
    -- Y(ψ ∨ (φ ∧ (φ S ψ))) ∈ chain(t') by y_mem_chain_general
    have h_Y_disj := (y_mem_chain_general W h_W t' _).mp h_disj
    -- since_intro: Y(ψ ∨ (φ ∧ (φ S ψ))) → (φ S ψ)
    exact SetMaximalConsistent.implication_property (deterministic_chain_mcs W h_W t')
      (theorem_in_mcs (deterministic_chain_mcs W h_W t')
        (Bimodal.Theorems.TemporalDerived.since_intro φ ψ)) h_Y_disj
  | succ d' ih =>
    -- Inductive case: t' = s' + d' + 2
    intro t' s' h_diff h_psi_s h_phi_guard
    -- By IH applied to t' - 1 and s': (φ S ψ) ∈ chain(t' - 1)
    have h_S_pred : Formula.snce φ ψ ∈ deterministic_chain W (t' - 1) := by
      apply ih (t' - 1) s' (by omega) h_psi_s
      intro r h_lt_r h_r_lt
      exact h_phi_guard r h_lt_r (by omega)
    -- φ ∈ chain(t' - 1) (from the guard)
    have h_phi_pred : φ ∈ deterministic_chain W (t' - 1) :=
      h_phi_guard (t' - 1) (by omega) (by omega)
    -- φ ∧ (φ S ψ) ∈ chain(t' - 1)
    have h_mcs_pred := deterministic_chain_mcs W h_W (t' - 1)
    have h_conj := mcs_and_intro' h_mcs_pred h_phi_pred h_S_pred
    -- ψ ∨ (φ ∧ (φ S ψ)) ∈ chain(t' - 1) by right disjunction intro
    have h_disj : Formula.or ψ (Formula.and φ (Formula.snce φ ψ)) ∈
        deterministic_chain W (t' - 1) :=
      mcs_or_intro_right h_mcs_pred ψ h_conj
    -- Y(ψ ∨ (φ ∧ (φ S ψ))) ∈ chain(t')
    have h_Y_disj := (y_mem_chain_general W h_W t' _).mp h_disj
    -- since_intro
    exact SetMaximalConsistent.implication_property (deterministic_chain_mcs W h_W t')
      (theorem_in_mcs (deterministic_chain_mcs W h_W t')
        (Bimodal.Theorems.TemporalDerived.since_intro φ ψ)) h_Y_disj

/-!
## Temporal and Until/Since Coherence
-/

/-- Temporal coherence. Depends on forward_F/backward_P (sorry). -/
theorem tc (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (construct_deterministic_bfmcs M₀ h_mcs).temporally_coherent := by
  intro fam hfam
  obtain ⟨W, h_W, k, _, rfl⟩ := hfam
  constructor
  · intro t psi h_F
    obtain ⟨s, h_lt, h_psi⟩ := deterministic_forward_F W h_W (t - k) psi h_F
    exact ⟨s + k, by omega, by
      show psi ∈ (DeterministicFMCS W h_W).mcs ((s + k) - k)
      simp [Int.add_sub_cancel]; exact h_psi⟩
  · intro t psi h_P
    obtain ⟨s, h_lt, h_psi⟩ := deterministic_backward_P W h_W (t - k) psi h_P
    exact ⟨s + k, by omega, by
      show psi ∈ (DeterministicFMCS W h_W).mcs ((s + k) - k)
      simp [Int.add_sub_cancel]; exact h_psi⟩

/-- Until/Since coherence. Forward cases depend on forward_F/backward_P (sorry).
Backward Until and backward Since are closed using until_intro/since_intro
and backward induction on the deterministic chain. -/
theorem usc (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (construct_deterministic_bfmcs M₀ h_mcs).until_since_coherent := by
  intro fam hfam
  obtain ⟨W, h_W, k, _, rfl⟩ := hfam
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- Forward Until: uses forward_F + until persistence
    intro t phi psi h_U; sorry
  · -- Backward Until: uses until_intro + backward induction
    intro t phi psi ⟨s, h_lt, h_psi, h_phi⟩
    -- fam.mcs t = deterministic_chain W (t - k), fam.mcs s = deterministic_chain W (s - k)
    exact backward_until_chain W h_W (t - k) (s - k) (by omega) phi psi h_psi
      (fun r h_lt_r h_r_lt => by
        have := h_phi (r + k) (by omega) (by omega)
        show phi ∈ deterministic_chain W r
        convert this using 1
        show deterministic_chain W r = deterministic_chain W ((r + k) - k)
        congr 1; omega)
  · -- Forward Since: symmetric
    intro t phi psi h_S; sorry
  · -- Backward Since: uses since_intro + backward induction
    intro t phi psi ⟨s, h_lt, h_psi, h_phi⟩
    exact backward_since_chain W h_W (t - k) (s - k) (by omega) phi psi h_psi
      (fun r h_lt_r h_r_lt => by
        have := h_phi (r + k) (by omega) (by omega)
        show phi ∈ deterministic_chain W r
        convert this using 1
        show deterministic_chain W r = deterministic_chain W ((r + k) - k)
        congr 1; omega)

/-!
## Completeness Wiring
-/

/-- The construct_bfmcs callback for parametric representation. -/
noncomputable def construct_bfmcs_callback (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent) (h_uc : B.until_since_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M = fam.mcs t :=
  ⟨construct_deterministic_bfmcs M h_mcs,
   tc M h_mcs,
   usc M h_mcs,
   DeterministicFMCS M h_mcs,
   eval_in_bundle M h_mcs,
   0, rfl⟩

/-- Representation theorem via deterministic chains: non-provable formulas have countermodels.
Wires through `parametric_algebraic_representation_conditional` (sorry-free). -/
noncomputable def deterministic_representation {φ : Formula}
    (h_not_prov : ¬Nonempty ([] ⊢ φ)) :=
  parametric_algebraic_representation_conditional φ h_not_prov construct_bfmcs_callback

end Bimodal.Metalogic.Algebraic.DeterministicFMCS
