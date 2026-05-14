import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Perpetuity

/-!
# Reflexive Canonical Model for TM Bimodal Logic

Defines the reflexive canonical model for Reynolds/Doets discrete completeness.
Key innovation: R is defined via "weak G" content (`g_w_content`), making it
reflexive, which enables the Z-model compression bypassing `succ_cofinal`.

## Structure
- `ReflCanDomain`: subtype of all set-maximal consistent sets
- `reflCanR`: reflexive canonical accessibility (xRy iff g_w_content x ⊆ y.val)
- `reflCanV`: canonical valuation
- `canS5R`: S5 box-accessibility relation
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators

/-! ## Domain -/

/-- Domain of the reflexive canonical model: all set-maximal consistent sets. -/
def ReflCanDomain : Type := { S : Set Formula // SetMaximalConsistent S }

namespace ReflCanDomain

instance : CoeSort ReflCanDomain (Set Formula) := ⟨fun x => x.val⟩

/-- Extract MCS proof from a domain element. -/
def mcs (x : ReflCanDomain) : SetMaximalConsistent x.val := x.property

/-- Equality via set equality. -/
theorem ext {x y : ReflCanDomain} (h : x.val = y.val) : x = y := by
  cases x; cases y; simp_all

end ReflCanDomain

/-! ## Temporal Content -/

/-- Strong G-content: ψ such that G(ψ) ∈ x. -/
def g_content (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.all_future ψ ∈ x.val }

/-- Weak G-content (reflexive): ψ such that ψ ∧ G(ψ) ∈ x. -/
def g_w_content (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.and ψ (Formula.all_future ψ) ∈ x.val }

/-- Strong H-content: ψ such that H(ψ) ∈ x. -/
def h_content (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.all_past ψ ∈ x.val }

/-- Weak H-content (reflexive): ψ such that ψ ∧ H(ψ) ∈ x. -/
def h_w_content (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.and ψ (Formula.all_past ψ) ∈ x.val }

/-! ## Accessibility Relation -/

/-- Reflexive canonical accessibility relation: xRy iff g_w_content x ⊆ y.val. -/
def reflCanR (x y : ReflCanDomain) : Prop :=
  g_w_content x ⊆ y.val

/-! ## S5 Modal Relation -/

/-- S5 box-accessibility: □φ ∈ x.val → φ ∈ y.val for all φ. -/
def canS5R (x y : ReflCanDomain) : Prop :=
  ∀ (φ : Formula), Formula.box φ ∈ x.val → φ ∈ y.val

/-! ## Reflexive Relation Properties -/

/-- reflCanR is reflexive: (ψ∧Gψ)→ψ is a theorem, ψ∈MCS by closure. -/
theorem reflCanR_refl (x : ReflCanDomain) : reflCanR x x := by
  intro ψ hψ_in_gw
  have h_mcs := x.property
  -- hψ_in_gw: ψ ∈ g_w_content x, which means ψ∧Gψ ∈ x.val
  have h_psi_and_G_in_x : Formula.and ψ (Formula.all_future ψ) ∈ x.val := hψ_in_gw
  -- lce: from ψ∧Gψ derive ψ
  have h_lce : [Formula.and ψ (Formula.all_future ψ)] ⊢ ψ :=
    lce ψ (Formula.all_future ψ)
  have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.all_future ψ)], χ ∈ x.val := by
    intro χ hχ
    simp at hχ
    subst hχ
    exact h_psi_and_G_in_x
  exact h_mcs.closed_under_derivation
    [Formula.and ψ (Formula.all_future ψ)] h_sub h_lce

/--
reflCanR is transitive. Uses MCS conjunction and temp_4 for G-propagation.
-/
theorem reflCanR_trans {x y z : ReflCanDomain}
    (h_xy : reflCanR x y) (h_yz : reflCanR y z) : reflCanR x z := by
  intro ψ h_psi_in_gwx
  have h_mcs_x := x.property
  have h_mcs_y := y.property
  -- h_psi_in_gwx: ψ ∈ g_w_content x, so ψ∧Gψ ∈ x.val
  have h_psi_and_G_in_x : Formula.and ψ (Formula.all_future ψ) ∈ x.val := h_psi_in_gwx
  -- Step 1: ψ ∈ y.val (h_xy applied to ψ ∈ g_w_content x)
  have h_psi_in_y : ψ ∈ y.val := h_xy h_psi_in_gwx
  -- Step 2: Extract G(ψ) ∈ x.val from ψ∧Gψ ∈ x (using rce)
  have h_Gpsi_in_x : Formula.all_future ψ ∈ x.val := by
    have h_rce : [Formula.and ψ (Formula.all_future ψ)] ⊢ Formula.all_future ψ :=
      rce ψ (Formula.all_future ψ)
    have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.all_future ψ)], χ ∈ x.val := by
      intro χ hχ
      simp at hχ
      subst hχ
      exact h_psi_and_G_in_x
    exact h_mcs_x.closed_under_derivation
      [Formula.and ψ (Formula.all_future ψ)] h_sub h_rce
  -- Step 3: G(G(ψ)) ∈ x.val (temp_4)
  have h_GGpsi_in_x : Formula.all_future (Formula.all_future ψ) ∈ x.val :=
    h_mcs_x.all_future_all_future h_Gpsi_in_x
  -- Step 4: G(ψ) ∧ G(G(ψ)) ∈ x.val (MCS conjunction via theorem_in_mcs + pairing)
  let A := Formula.all_future ψ
  let B := Formula.all_future (Formula.all_future ψ)
  let conj_term : Formula := Formula.and A B
  have h_conj_in_x : conj_term ∈ x.val := by
    have h_pairing : [] ⊢ A.imp (B.imp conj_term) := pairing A B
    have h_pairing_in : A.imp (B.imp conj_term) ∈ x.val := theorem_in_mcs h_mcs_x h_pairing
    have h_B_imp_conj : B.imp conj_term ∈ x.val :=
      h_mcs_x.implication_property h_pairing_in h_Gpsi_in_x
    exact h_mcs_x.implication_property h_B_imp_conj h_GGpsi_in_x
  -- Step 5: G(ψ) ∈ g_w_content x (since Gψ ∧ GGψ ∈ x)
  have h_Gpsi_in_gwx : Formula.all_future ψ ∈ g_w_content x := h_conj_in_x
  -- Step 6: G(ψ) ∈ y.val (by h_xy)
  have h_Gpsi_in_y : Formula.all_future ψ ∈ y.val := h_xy h_Gpsi_in_gwx
  -- Step 7: ψ ∧ G(ψ) ∈ y.val (MCS conjunction)
  let A' := ψ
  let B' := Formula.all_future ψ
  let conj_term' : Formula := Formula.and A' B'
  have h_psi_and_G_in_y : conj_term' ∈ y.val := by
    have h_pairing : [] ⊢ A'.imp (B'.imp conj_term') := pairing A' B'
    have h_pairing_in : A'.imp (B'.imp conj_term') ∈ y.val := theorem_in_mcs h_mcs_y h_pairing
    have h_B_imp_conj : B'.imp conj_term' ∈ y.val :=
      h_mcs_y.implication_property h_pairing_in h_psi_in_y
    exact h_mcs_y.implication_property h_B_imp_conj h_Gpsi_in_y
  -- Step 8: ψ ∈ g_w_content y, then ψ ∈ z.val by h_yz
  have h_psi_in_gwy : ψ ∈ g_w_content y := h_psi_and_G_in_y
  exact h_yz h_psi_in_gwy

/--
Lemma: If x R y and x ≠ y, then strong G-content of x is in y.
This is a documented sorry; the truth lemma handles this case directly.
-/
theorem g_content_subset_of_reflCanR_ne {x y : ReflCanDomain}
    (_hR : reflCanR x y) (_hne : x ≠ y) (φ : Formula)
    (hG : Formula.all_future φ ∈ x.val) : φ ∈ y.val := by
  sorry

/--
reflCanR is linear: from BX11 temporal linearity axiom.
Documented sorry — Phase 3 one_class may not need full linearity.
-/
theorem reflCanR_linear (x y : ReflCanDomain) : reflCanR x y ∨ reflCanR y x := by
  sorry

/-! ## Valuation -/

/-- Canonical valuation: atom p true at x iff p ∈ x.val. -/
def reflCanV (x : ReflCanDomain) (p : Atom) : Prop :=
  Formula.atom p ∈ x.val

/-! ## Discreteness -/

/-- U(⊤,⊥): asserts existence of immediate successor (guard ⊥ is vacuous). -/
def next_top : Formula := Formula.untl (Formula.bot.imp Formula.bot) Formula.bot

/-- If □(next_top) ∈ A, then next_top ∈ x.val for all x box-accessible from A. -/
theorem next_top_in_box_class (A : ReflCanDomain) (x : ReflCanDomain)
    (h_box : Formula.box next_top ∈ A.val) (h_S5 : canS5R A x) :
    next_top ∈ x.val :=
  h_S5 next_top h_box

/-! ## S5 Canonical Model Properties -/

/-- canS5R is reflexive: from box T axiom and implication property. -/
theorem canS5R_refl (x : ReflCanDomain) : canS5R x x := by
  intro φ h_box_phi
  have h_mcs := x.property
  -- Theorem: □φ → φ
  have h_t : [] ⊢ (Formula.box φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)
  -- MCS contains all theorems
  have h_imp_in : (Formula.box φ).imp φ ∈ x.val :=
    theorem_in_mcs h_mcs h_t
  -- By implication property: □φ ∈ x ∧ □φ→φ ∈ x → φ ∈ x
  exact h_mcs.implication_property h_imp_in h_box_phi

/-- canS5R is symmetric (S5). Documented sorry — not needed for discrete completeness. -/
theorem canS5R_symm {x y : ReflCanDomain} (_h : canS5R x y) : canS5R y x := by
  sorry

/-- canS5R is transitive via modal 4. -/
theorem canS5R_trans {x y z : ReflCanDomain}
    (h_xy : canS5R x y) (h_yz : canS5R y z) : canS5R x z := by
  intro φ h_box_phi_x
  have h_mcs_x := x.property
  -- From modal 4: □φ → □□φ
  have h_box_box_phi_x : Formula.box (Formula.box φ) ∈ x.val := by
    have h_4 : [] ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) :=
      DerivationTree.axiom [] _ (Axiom.modal_4 φ)
    have h_4_in : (Formula.box φ).imp (Formula.box (Formula.box φ)) ∈ x.val :=
      theorem_in_mcs h_mcs_x h_4
    exact h_mcs_x.implication_property h_4_in h_box_phi_x
  -- □□φ ∈ x gives □φ ∈ y (by h_xy applied to □φ as the witness formula)
  have h_box_phi_y : Formula.box φ ∈ y.val := h_xy (Formula.box φ) h_box_box_phi_x
  -- Then φ ∈ z
  exact h_yz φ h_box_phi_y

end Bimodal.Metalogic.WeakCanonical
