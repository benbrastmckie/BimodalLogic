import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Perpetuity
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Syntax.Context

/-!
# Reflexive Canonical Model for TM Bimodal Logic

Defines the reflexive canonical model for Reynolds/Doets discrete completeness.
Key innovation: R is defined via "weak G" content (`g_w_content`), making it
reflexive, which enables the Z-model compression bypassing `succ_cofinal`.

## Structure
- `ReflCanDomain`: subtype of all set-maximal consistent sets
- `reflCanR`: reflexive canonical accessibility (xRy iff g_w_content x ⊆ y.val)
- `tempR_fwd` / `tempR_bwd`: strict temporal relations (via g_content/h_content)
- `reflCanV`: canonical valuation
- `canS5R`: S5 box-accessibility relation
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems

/-! ## Domain -/

/-- Domain of the reflexive canonical model: all set-maximal consistent sets. -/
def ReflCanDomain : Type := { S : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) S }

namespace ReflCanDomain

instance : CoeSort ReflCanDomain (Set Formula) := ⟨fun x => x.val⟩

/-- Extract MCS proof from a domain element. -/
def mcs (x : ReflCanDomain) : SetMaximalConsistent (fc := FrameClass.Base) x.val := x.property

/-- Equality via set equality. -/
theorem ext {x y : ReflCanDomain} (h : x.val = y.val) : x = y := by
  cases x; cases y; simp_all

end ReflCanDomain

/-! ## Temporal Content -/

/-- Strong G-content: ψ such that G(ψ) ∈ x. (From Bundle.TemporalContent) -/
def g_content (x : ReflCanDomain) : Set Formula :=
  Bundle.g_content x.val

/-- Weak G-content (reflexive): ψ such that ψ ∧ G(ψ) ∈ x. -/
def g_w_content (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.and ψ (Formula.all_future ψ) ∈ x.val }

/-- Strong H-content: ψ such that H(ψ) ∈ x. (From Bundle.TemporalContent) -/
def h_content (x : ReflCanDomain) : Set Formula :=
  Bundle.h_content x.val

/-- Weak H-content (reflexive): ψ such that ψ ∧ H(ψ) ∈ x. -/
def h_w_content (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.and ψ (Formula.all_past ψ) ∈ x.val }

/-! ## Accessibility Relations -/

/-- Reflexive canonical accessibility relation: xRy iff g_w_content x ⊆ y.val. -/
def reflCanR (x y : ReflCanDomain) : Prop :=
  g_w_content x ⊆ y.val

/-- Temporal future relation: x R_fwd y iff g_content x ⊆ y.val. -/
def tempR_fwd (x y : ReflCanDomain) : Prop :=
  g_content x ⊆ y.val

/-- Temporal past relation: y R_bwd x iff h_content y ⊆ x.val. -/
def tempR_bwd (x y : ReflCanDomain) : Prop :=
  h_content y ⊆ x.val

/-! ## Temporal Relation Properties -/

/--
Transitivity of `tempR_fwd`. If `g_content x ⊆ y.val` and `g_content y ⊆ z.val`,
then `g_content x ⊆ z.val`. Proof uses the `temp_4` axiom: `G(φ) → G(G(φ))`.

Given ψ ∈ g_content x (i.e., Gψ ∈ x.val):
  1. By `temp_4` and MCS closure, GGψ ∈ x.val.
  2. Then Gψ ∈ g_content x, so by tempR_fwd x y: Gψ ∈ y.val.
  3. Hence ψ ∈ g_content y, so by tempR_fwd y z: ψ ∈ z.val.
-/
theorem tempR_fwd_trans {x y z : ReflCanDomain}
    (h_xy : tempR_fwd x y) (h_yz : tempR_fwd y z) : tempR_fwd x z := by
  intro ψ h_ψ_gx
  have h_mcs_x := x.property
  -- h_ψ_gx : ψ ∈ g_content x ↔ G(ψ) ∈ x.val
  have h_Gψ_x : Formula.all_future ψ ∈ x.val := by
    simp [g_content, Bundle.g_content] at h_ψ_gx
    exact h_ψ_gx
  -- Step 1: G(ψ) → G(G(ψ)) via temp_4
  have h_GGψ_x : Formula.all_future (Formula.all_future ψ) ∈ x.val :=
    h_mcs_x.all_future_all_future h_Gψ_x
  -- Step 2: G(ψ) ∈ g_content x (since G(G(ψ)) ∈ x.val)
  have h_Gψ_gx : Formula.all_future ψ ∈ g_content x := by
    simp [g_content, Bundle.g_content, h_GGψ_x]
  -- Step 3: By tempR_fwd x y, G(ψ) ∈ y.val
  have h_Gψ_y : Formula.all_future ψ ∈ y.val := h_xy h_Gψ_gx
  -- Step 4: ψ ∈ g_content y (since G(ψ) ∈ y.val)
  have h_ψ_gy : ψ ∈ g_content y := by
    simp [g_content, Bundle.g_content, h_Gψ_y]
  -- Step 5: By tempR_fwd y z, ψ ∈ z.val
  exact h_yz h_ψ_gy

/-! ## Burgess Lemma 1.6(b): F-membership characterization of tempR_fwd -/

/--
Burgess Lemma 1.6 direction (c)→(b): if `tempR_fwd x y` and `β ∈ y.val`,
then `F(β) ∈ x.val`. Contrapositive: if `F(β) ∉ x.val`, then `G(¬β) ∈ x.val`
(by DNE from negation completeness), so `¬β ∈ g_content(x) ⊆ y.val`,
contradicting `β ∈ y.val`.

This requires the double-negation bridge: `¬F(β) = F(β).neg = β.neg.all_future.neg.neg`
must be converted to `G(¬β) = β.neg.all_future` via DNE applied in the MCS.
-/
theorem tempR_fwd_mem_some_future {x y : ReflCanDomain}
    (h_fwd : tempR_fwd x y) (β : Formula) (h_β_y : β ∈ y.val) :
    Formula.some_future β ∈ x.val := by
  have h_mcs_x := x.property
  by_contra h_Fβ_nx
  -- ¬F(β) ∈ x.val by negation completeness
  -- F(β) = β.neg.all_future.neg (definition: some_future β = β.neg.all_future.neg)
  -- ¬F(β) = F(β).neg = β.neg.all_future.neg.neg
  have h_neg_Fβ : (Formula.some_future β).neg ∈ x.val :=
    (SetMaximalConsistent.negation_complete h_mcs_x (Formula.some_future β)).resolve_left h_Fβ_nx
  -- G(¬β) ∈ x.val from ¬F(β) via duality bridge
  have h_G_neg_β : (Formula.neg β).all_future ∈ x.val :=
    Bundle.neg_some_future_to_all_future_neg h_mcs_x β h_neg_Fβ
  -- ¬β ∈ g_content(x)
  have h_neg_β_gc : Formula.neg β ∈ g_content x := by
    simp [g_content, Bundle.g_content, h_G_neg_β]
  -- ¬β ∈ y.val (by tempR_fwd)
  have h_neg_β_y : Formula.neg β ∈ y.val := h_fwd h_neg_β_gc
  -- Contradiction: β ∈ y.val and ¬β ∈ y.val
  exact set_consistent_not_both y.property.1 β h_β_y h_neg_β_y

/--
Corollary: if `¬tempR_fwd y z` (i.e., `g_content y ⊄ z.val`), then there exists
a formula `γ₀ ∈ z.val` with `F(γ₀) ∉ y.val`. This is the contrapositive of
Lemma 1.6(b) applied to the (y,z) pair.
-/
theorem not_tempR_fwd_witness_F {y z : ReflCanDomain}
    (h_not : ¬tempR_fwd y z) :
    ∃ γ₀ : Formula, γ₀ ∈ z.val ∧ Formula.some_future γ₀ ∉ y.val := by
  by_contra h_all
  push_neg at h_all
  -- h_all : ∀ γ₀, γ₀ ∈ z.val → F(γ₀) ∈ y.val
  -- Show tempR_fwd y z, contradicting h_not
  apply h_not
  intro ψ h_ψ_gc
  -- ψ ∈ g_content y means G(ψ) ∈ y.val
  have h_Gψ_y : Formula.all_future ψ ∈ y.val := by
    simp [g_content, Bundle.g_content] at h_ψ_gc; exact h_ψ_gc
  -- Need ψ ∈ z.val. By contradiction: if ψ ∉ z.val, then ¬ψ ∈ z.val
  by_contra h_ψ_nz
  have h_mcs_z := z.property
  have h_mcs_y := y.property
  have h_neg_ψ_z : Formula.neg ψ ∈ z.val :=
    (SetMaximalConsistent.negation_complete h_mcs_z ψ).resolve_left h_ψ_nz
  -- F(¬ψ) ∈ y.val (by h_all applied to ¬ψ ∈ z.val)
  have h_F_neg_ψ_y : Formula.some_future (Formula.neg ψ) ∈ y.val := h_all _ h_neg_ψ_z
  -- F(¬ψ) = (¬ψ).neg.all_future.neg = ψ.neg.neg.all_future.neg = ¬G(¬¬ψ)
  -- G(ψ) ∈ y.val. Need G(ψ) and F(¬ψ) to be contradictory.
  -- F(¬ψ) = ¬G(¬¬ψ). We need G(ψ) → G(¬¬ψ) to get a contradiction.
  -- From ψ → ¬¬ψ (dni) via temp_k_dist + temporal_necessitation: G(ψ) → G(¬¬ψ)
  have h_dni : [] ⊢ ψ.imp ψ.neg.neg := Combinators.dni ψ
  have h_G_dni : [] ⊢ Formula.all_future (ψ.imp ψ.neg.neg) :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_kd : [] ⊢ (ψ.imp ψ.neg.neg).all_future.imp (ψ.all_future.imp ψ.neg.neg.all_future) :=
    Bimodal.Theorems.TemporalDerived.temp_k_dist_derived ψ ψ.neg.neg
  have h_Gψ_imp_Gnn : [] ⊢ ψ.all_future.imp ψ.neg.neg.all_future :=
    Combinators.mp h_G_dni h_kd
  -- G(¬¬ψ) ∈ y.val
  have h_Gnn_y : ψ.neg.neg.all_future ∈ y.val :=
    h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_Gψ_imp_Gnn) h_Gψ_y
  -- F(¬ψ) and G(¬¬ψ) = G(¬(¬ψ).neg) are contradictory in MCS y
  exact Bundle.some_future_all_future_neg_absurd h_mcs_y (Formula.neg ψ) h_F_neg_ψ_y h_Gnn_y

/--
Helper: From `⊢ A → B`, derive `⊢ F(A) → F(B)` (F-monotonicity).
Uses BX3 (right_mono_until): G(A → B) → (U(A, ⊤) → U(B, ⊤)), i.e., G(A → B) → (F(A) → F(B)).
-/
noncomputable def some_future_mono {A B : Formula}
    (h : [] ⊢ A.imp B) : [] ⊢ (Formula.some_future A).imp (Formula.some_future B) := by
  -- G(A → B) via temporal necessitation
  have h_G : [] ⊢ Formula.all_future (A.imp B) :=
    DerivationTree.temporal_necessitation _ h
  -- BX3: G(A → B) → (U(A, ⊤) → U(B, ⊤)) = G(A → B) → (F(A) → F(B))
  have h_bx3 : [] ⊢ (A.imp B).all_future.imp
      ((Formula.untl A Formula.top).imp (Formula.untl B Formula.top)) :=
    DerivationTree.axiom [] _ (Axiom.right_mono_until A B Formula.top) trivial
  -- F(A) → F(B) by MP
  exact DerivationTree.modus_ponens [] _ _ h_bx3 h_G

/--
Forward linearity of the canonical temporal cone (Burgess 1984, Section 2.2).

If `tempR_fwd x y` and `tempR_fwd x z`, then either `tempR_fwd y z`, `y = z`,
or `tempR_fwd z y`. This three-way disjunction correctly handles the strict
temporal relation: `tempR_fwd` uses strong g_content (G(ψ) ∈ x → ψ ∈ y),
which is irreflexive (tempR_fwd y y does not generally hold).

**Proof** (following Burgess 1984 Lemma, p.103): By contradiction assuming
none of the three holds. Using Lemma 1.6(b), get witnesses β₀ ∈ y with
Fβ₀ ∉ z, γ₀ ∈ z with Fγ₀ ∉ y, and δ ∈ y\z (from y ≠ z).
Construct β = β₀ ∧ ¬Fγ₀ ∧ δ ∈ y and γ = γ₀ ∧ ¬Fβ₀ ∧ ¬δ ∈ z.
By Lemma 1.6(b) on x: Fβ ∈ x and Fγ ∈ x.
BX11 gives F(β∧γ) ∨ F(Fβ∧γ) ∨ F(β∧Fγ) in x.
Each case leads to a provable inconsistency:
- F(β∧γ) contains δ∧¬δ
- F(Fβ∧γ): Fβ→Fβ₀ (monotonicity), γ contains ¬Fβ₀
- F(β∧Fγ): Fγ→Fγ₀ (monotonicity), β contains ¬Fγ₀
-/
theorem reflCanR_linear (x y z : ReflCanDomain)
    (h_xy : tempR_fwd x y) (h_xz : tempR_fwd x z) :
    tempR_fwd y z ∨ y = z ∨ tempR_fwd z y := by
  -- By contradiction: assume none of the three holds
  by_contra h_none
  push_neg at h_none
  obtain ⟨h_not_yz, h_ne, h_not_zy⟩ := h_none
  have h_mcs_x := x.property
  have h_mcs_y := y.property
  have h_mcs_z := z.property
  -- From ¬tempR_fwd z y: ∃ β₀ ∈ y.val with F(β₀) ∉ z.val (Lemma 1.6(b) contrapositive)
  obtain ⟨β₀, h_β₀_y, h_Fβ₀_nz⟩ := not_tempR_fwd_witness_F h_not_zy
  -- From ¬tempR_fwd y z: ∃ γ₀ ∈ z.val with F(γ₀) ∉ y.val
  obtain ⟨γ₀, h_γ₀_z, h_Fγ₀_ny⟩ := not_tempR_fwd_witness_F h_not_yz
  -- From y ≠ z: ∃ δ ∈ y.val with δ ∉ z.val (or vice versa)
  have h_val_ne : y.val ≠ z.val := by
    intro h_eq; exact h_ne (ReflCanDomain.ext h_eq)
  -- Either y.val ⊄ z.val or z.val ⊄ y.val (since y.val ≠ z.val)
  have h_not_both_sub : ¬(y.val ⊆ z.val ∧ z.val ⊆ y.val) := by
    intro ⟨h1, h2⟩; exact h_val_ne (Set.Subset.antisymm h1 h2)
  -- We handle both cases. The proof is symmetric modulo swapping δ/¬δ placement.
  -- First, pick any δ witnessing y.val ≠ z.val. We can assume WLOG y.val ⊄ z.val
  -- (the other case is symmetric with δ placed on the γ side).
  -- Since ¬(y.val ⊆ z.val ∧ z.val ⊆ y.val), by De Morgan:
  -- ¬(y.val ⊆ z.val) ∨ ¬(z.val ⊆ y.val)
  rcases not_and_or.mp h_not_both_sub with h_y_nsub | h_z_nsub
  · -- Case: y.val ⊄ z.val. Get δ ∈ y.val with δ ∉ z.val.
    obtain ⟨δ, h_δ_y, h_δ_nz⟩ := Set.not_subset.mp h_y_nsub
    -- ¬F(γ₀) ∈ y.val (negation completeness)
    have h_nFγ₀_y : (Formula.some_future γ₀).neg ∈ y.val :=
      (SetMaximalConsistent.negation_complete h_mcs_y _).resolve_left h_Fγ₀_ny
    -- ¬F(β₀) ∈ z.val (negation completeness)
    have h_nFβ₀_z : (Formula.some_future β₀).neg ∈ z.val :=
      (SetMaximalConsistent.negation_complete h_mcs_z _).resolve_left h_Fβ₀_nz
    -- ¬δ ∈ z.val (negation completeness)
    have h_nδ_z : δ.neg ∈ z.val :=
      (SetMaximalConsistent.negation_complete h_mcs_z _).resolve_left h_δ_nz
    -- β = (β₀ ∧ ¬Fγ₀) ∧ δ ∈ y.val
    let β := Formula.and (Formula.and β₀ (Formula.some_future γ₀).neg) δ
    have h_β_y : β ∈ y.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing β₀ (Formula.some_future γ₀).neg
      have h_inner : Formula.and β₀ (Formula.some_future γ₀).neg ∈ y.val :=
        h_mcs_y.implication_property
          (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p1) h_β₀_y) h_nFγ₀_y
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing (Formula.and β₀ (Formula.some_future γ₀).neg) δ
      exact h_mcs_y.implication_property
        (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p2) h_inner) h_δ_y
    -- γ = (γ₀ ∧ ¬Fβ₀) ∧ ¬δ ∈ z.val
    let γ := Formula.and (Formula.and γ₀ (Formula.some_future β₀).neg) δ.neg
    have h_γ_z : γ ∈ z.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing γ₀ (Formula.some_future β₀).neg
      have h_inner : Formula.and γ₀ (Formula.some_future β₀).neg ∈ z.val :=
        h_mcs_z.implication_property
          (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p1) h_γ₀_z) h_nFβ₀_z
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing (Formula.and γ₀ (Formula.some_future β₀).neg) δ.neg
      exact h_mcs_z.implication_property
        (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p2) h_inner) h_nδ_z
    -- F(β) ∈ x.val and F(γ) ∈ x.val (by Lemma 1.6(b))
    have h_Fβ_x : Formula.some_future β ∈ x.val :=
      tempR_fwd_mem_some_future h_xy β h_β_y
    have h_Fγ_x : Formula.some_future γ ∈ x.val :=
      tempR_fwd_mem_some_future h_xz γ h_γ_z
    -- BX11 case analysis
    rcases BXCanonical.temp_linearity_mcs h_mcs_x β γ h_Fβ_x h_Fγ_x with
      h_c1 | h_c2 | h_c3
    · -- Case 1: F(β ∧ γ) ∈ x.val. β∧γ contains δ and ¬δ → inconsistent.
      have h1 : [] ⊢ (β.and γ).imp δ :=
        Combinators.imp_trans (lce_imp β γ) (rce_imp _ δ)
      have h2 : [] ⊢ (β.and γ).imp δ.neg :=
        Combinators.imp_trans (rce_imp β γ) (rce_imp _ δ.neg)
      have h_bot : [] ⊢ (β.and γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.prop_k (β.and γ) δ Formula.bot) trivial
        exact Combinators.mp h1 (Combinators.mp h2 hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x (β.and γ) h_c1
        (theorem_in_mcs h_mcs_x hG)
    · -- Case 2: F(β ∧ F(γ)) ∈ x.val. F(γ)→F(γ₀) (mono), β→¬F(γ₀) → inconsistent.
      have h_γ_to_γ₀ : [] ⊢ γ.imp γ₀ :=
        Combinators.imp_trans (lce_imp _ δ.neg) (lce_imp γ₀ _)
      have h_Fγ_to_Fγ₀ : [] ⊢ (Formula.some_future γ).imp (Formula.some_future γ₀) :=
        some_future_mono h_γ_to_γ₀
      have h_β_to_nFγ₀ : [] ⊢ β.imp (Formula.some_future γ₀).neg :=
        Combinators.imp_trans (lce_imp _ δ) (rce_imp β₀ _)
      have h_l : [] ⊢ (Formula.and β (Formula.some_future γ)).imp (Formula.some_future γ₀).neg :=
        Combinators.imp_trans (lce_imp β _) h_β_to_nFγ₀
      have h_r : [] ⊢ (Formula.and β (Formula.some_future γ)).imp (Formula.some_future γ₀) :=
        Combinators.imp_trans (rce_imp β _) h_Fγ_to_Fγ₀
      have h_bot : [] ⊢ (Formula.and β (Formula.some_future γ)).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and β (Formula.some_future γ)) (Formula.some_future γ₀) Formula.bot) trivial
        exact Combinators.mp h_r (Combinators.mp h_l hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and β (Formula.some_future γ)) h_c2 (theorem_in_mcs h_mcs_x hG)
    · -- Case 3: F(F(β) ∧ γ) ∈ x.val. F(β)→F(β₀) (mono), γ→¬F(β₀) → inconsistent.
      have h_β_to_β₀ : [] ⊢ β.imp β₀ :=
        Combinators.imp_trans (lce_imp _ δ) (lce_imp β₀ _)
      have h_Fβ_to_Fβ₀ : [] ⊢ (Formula.some_future β).imp (Formula.some_future β₀) :=
        some_future_mono h_β_to_β₀
      have h_γ_to_nFβ₀ : [] ⊢ γ.imp (Formula.some_future β₀).neg :=
        Combinators.imp_trans (lce_imp _ δ.neg) (rce_imp γ₀ _)
      have h_l : [] ⊢ (Formula.and (Formula.some_future β) γ).imp (Formula.some_future β₀) :=
        Combinators.imp_trans (lce_imp _ γ) h_Fβ_to_Fβ₀
      have h_r : [] ⊢ (Formula.and (Formula.some_future β) γ).imp (Formula.some_future β₀).neg :=
        Combinators.imp_trans (rce_imp _ γ) h_γ_to_nFβ₀
      have h_bot : [] ⊢ (Formula.and (Formula.some_future β) γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and (Formula.some_future β) γ) (Formula.some_future β₀) Formula.bot) trivial
        exact Combinators.mp h_l (Combinators.mp h_r hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and (Formula.some_future β) γ) h_c3 (theorem_in_mcs h_mcs_x hG)
  · -- Case: z.val ⊄ y.val. Symmetric: δ ∈ z.val with δ ∉ y.val.
    obtain ⟨δ, h_δ_z, h_δ_ny⟩ := Set.not_subset.mp h_z_nsub
    have h_nFγ₀_y : (Formula.some_future γ₀).neg ∈ y.val :=
      (SetMaximalConsistent.negation_complete h_mcs_y _).resolve_left h_Fγ₀_ny
    have h_nFβ₀_z : (Formula.some_future β₀).neg ∈ z.val :=
      (SetMaximalConsistent.negation_complete h_mcs_z _).resolve_left h_Fβ₀_nz
    have h_nδ_y : δ.neg ∈ y.val :=
      (SetMaximalConsistent.negation_complete h_mcs_y _).resolve_left h_δ_ny
    -- β = (β₀ ∧ ¬Fγ₀) ∧ ¬δ ∈ y.val
    let β := Formula.and (Formula.and β₀ (Formula.some_future γ₀).neg) δ.neg
    have h_β_y : β ∈ y.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing β₀ (Formula.some_future γ₀).neg
      have h_inner : Formula.and β₀ (Formula.some_future γ₀).neg ∈ y.val :=
        h_mcs_y.implication_property
          (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p1) h_β₀_y) h_nFγ₀_y
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing (Formula.and β₀ (Formula.some_future γ₀).neg) δ.neg
      exact h_mcs_y.implication_property
        (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p2) h_inner) h_nδ_y
    -- γ = (γ₀ ∧ ¬Fβ₀) ∧ δ ∈ z.val
    let γ := Formula.and (Formula.and γ₀ (Formula.some_future β₀).neg) δ
    have h_γ_z : γ ∈ z.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing γ₀ (Formula.some_future β₀).neg
      have h_inner : Formula.and γ₀ (Formula.some_future β₀).neg ∈ z.val :=
        h_mcs_z.implication_property
          (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p1) h_γ₀_z) h_nFβ₀_z
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing (Formula.and γ₀ (Formula.some_future β₀).neg) δ
      exact h_mcs_z.implication_property
        (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p2) h_inner) h_δ_z
    have h_Fβ_x : Formula.some_future β ∈ x.val :=
      tempR_fwd_mem_some_future h_xy β h_β_y
    have h_Fγ_x : Formula.some_future γ ∈ x.val :=
      tempR_fwd_mem_some_future h_xz γ h_γ_z
    -- BX11: symmetric case. β has ¬δ, γ has δ.
    rcases BXCanonical.temp_linearity_mcs h_mcs_x β γ h_Fβ_x h_Fγ_x with
      h_c1 | h_c2 | h_c3
    · -- F(β∧γ): β→¬δ and γ→δ → inconsistent
      have h1 : [] ⊢ (β.and γ).imp δ.neg :=
        Combinators.imp_trans (lce_imp β γ) (rce_imp _ δ.neg)
      have h2 : [] ⊢ (β.and γ).imp δ :=
        Combinators.imp_trans (rce_imp β γ) (rce_imp _ δ)
      have h_bot : [] ⊢ (β.and γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _ (Axiom.prop_k (β.and γ) δ Formula.bot) trivial
        exact Combinators.mp h2 (Combinators.mp h1 hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x (β.and γ) h_c1
        (theorem_in_mcs h_mcs_x hG)
    · -- F(β∧Fγ): Fγ→Fγ₀, β→¬Fγ₀ → inconsistent
      have h_γ_to_γ₀ : [] ⊢ γ.imp γ₀ :=
        Combinators.imp_trans (lce_imp _ δ) (lce_imp γ₀ _)
      have h_Fγ_to_Fγ₀ := some_future_mono h_γ_to_γ₀
      have h_β_to_nFγ₀ : [] ⊢ β.imp (Formula.some_future γ₀).neg :=
        Combinators.imp_trans (lce_imp _ δ.neg) (rce_imp β₀ _)
      have h_l : [] ⊢ (Formula.and β (Formula.some_future γ)).imp (Formula.some_future γ₀).neg :=
        Combinators.imp_trans (lce_imp β _) h_β_to_nFγ₀
      have h_r : [] ⊢ (Formula.and β (Formula.some_future γ)).imp (Formula.some_future γ₀) :=
        Combinators.imp_trans (rce_imp β _) h_Fγ_to_Fγ₀
      have h_bot : [] ⊢ (Formula.and β (Formula.some_future γ)).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and β (Formula.some_future γ)) (Formula.some_future γ₀) Formula.bot) trivial
        exact Combinators.mp h_r (Combinators.mp h_l hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and β (Formula.some_future γ)) h_c2 (theorem_in_mcs h_mcs_x hG)
    · -- F(Fβ∧γ): Fβ→Fβ₀, γ→¬Fβ₀ → inconsistent
      have h_β_to_β₀ : [] ⊢ β.imp β₀ :=
        Combinators.imp_trans (lce_imp _ δ.neg) (lce_imp β₀ _)
      have h_Fβ_to_Fβ₀ := some_future_mono h_β_to_β₀
      have h_γ_to_nFβ₀ : [] ⊢ γ.imp (Formula.some_future β₀).neg :=
        Combinators.imp_trans (lce_imp _ δ) (rce_imp γ₀ _)
      have h_l : [] ⊢ (Formula.and (Formula.some_future β) γ).imp (Formula.some_future β₀) :=
        Combinators.imp_trans (lce_imp _ γ) h_Fβ_to_Fβ₀
      have h_r : [] ⊢ (Formula.and (Formula.some_future β) γ).imp (Formula.some_future β₀).neg :=
        Combinators.imp_trans (rce_imp _ γ) h_γ_to_nFβ₀
      have h_bot : [] ⊢ (Formula.and (Formula.some_future β) γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and (Formula.some_future β) γ) (Formula.some_future β₀) Formula.bot) trivial
        exact Combinators.mp h_l (Combinators.mp h_r hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and (Formula.some_future β) γ) h_c3 (theorem_in_mcs h_mcs_x hG)

/--
Backward bridge lemma: if `tempR_bwd y x`, then `h_w_content x ⊆ y.val`.

This is the mirror of `tempR_fwd_imp_reflCanR` for the past direction:
h_w_content x ⊆ h_content x, and tempR_bwd y x gives h_content x ⊆ y.val.
-/
theorem tempR_bwd_imp_reflCanR_bwd {x y : ReflCanDomain}
    (h_temp : tempR_bwd y x) : h_w_content x ⊆ y.val := by
  intro ψ hψ_hwx
  have h_mcs_x := x.property
  -- hψ_hwx : ψ ∈ h_w_content x → ψ ∧ H(ψ) ∈ x.val
  have h_psi_and_H : Formula.and ψ (Formula.all_past ψ) ∈ x.val := hψ_hwx
  -- From ψ∧Hψ ∈ x, derive Hψ ∈ x (using rce)
  have h_Hpsi : Formula.all_past ψ ∈ x.val := by
    have h_rce : [Formula.and ψ (Formula.all_past ψ)] ⊢ Formula.all_past ψ :=
      rce ψ (Formula.all_past ψ)
    have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.all_past ψ)], χ ∈ x.val := by
      intro χ hχ; simp at hχ; subst hχ; exact h_psi_and_H
    exact h_mcs_x.closed_under_derivation
      [Formula.and ψ (Formula.all_past ψ)] h_sub h_rce
  -- So ψ ∈ h_content x, and tempR_bwd y x means h_content x ⊆ y.val
  have h_ψ_hx : ψ ∈ h_content x := by
    simp [h_content, Bundle.h_content, h_Hpsi]
  exact h_temp h_ψ_hx

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
If tempR_fwd x y, then reflCanR x y.
Since g_w_content x = {ψ | ψ∧Gψ∈x} ⊆ g_content x = {ψ | Gψ∈x},
we have g_content x ⊆ y.val implies g_w_content x ⊆ y.val.
-/
theorem tempR_fwd_imp_reflCanR {x y : ReflCanDomain}
    (h_temp : tempR_fwd x y) : reflCanR x y := by
  intro ψ hψ_gwx
  have h_mcs_x := x.property
  -- hψ_gwx : ψ ∈ g_w_content x → ψ ∧ Gψ ∈ x.val
  have h_psi_and_G : Formula.and ψ (Formula.all_future ψ) ∈ x.val := hψ_gwx
  -- From ψ∧Gψ ∈ x, derive Gψ ∈ x (using rce)
  have h_Gpsi : Formula.all_future ψ ∈ x.val := by
    have h_rce : [Formula.and ψ (Formula.all_future ψ)] ⊢ Formula.all_future ψ :=
      rce ψ (Formula.all_future ψ)
    have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.all_future ψ)], χ ∈ x.val := by
      intro χ hχ; simp at hχ; subst hχ; exact h_psi_and_G
    exact h_mcs_x.closed_under_derivation [Formula.and ψ (Formula.all_future ψ)] h_sub h_rce
  -- So ψ ∈ g_content x, and tempR_fwd x y means g_content x ⊆ y.val
  have h_psi_gx : ψ ∈ g_content x := by
    simp [g_content, Bundle.g_content, h_Gpsi]
  exact h_temp h_psi_gx

/-! ## Key Helper: g_content Closed Under Derivation -/

/--
If all formulas in a list L are in g_content x, and L ⊢ φ, then G(φ) ∈ x.val.
This is the same as `g_content_closed_derivation` in BXCanonical/Frame.lean
but adapted for ReflCanDomain.
-/
noncomputable def g_content_closed_derivation {x : ReflCanDomain} {φ : Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) x.val)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ g_content x)
    (h_deriv : DerivationTree FrameClass.Base L φ) : Formula.all_future φ ∈ x.val := by
  -- Apply generalized temporal K: L ⊢ φ gives G(L) ⊢ G(φ)
  have d_G : (Context.map Formula.all_future L) ⊢ Formula.all_future φ :=
    generalized_temporal_k L φ h_deriv
  -- All formulas in G(L) are in x.val (by g_content membership)
  have h_GL_in_x : ∀ f ∈ Context.map Formula.all_future L, f ∈ x.val := by
    intro f hf
    rw [Context.mem_map_iff] at hf
    obtain ⟨ψ, hψ_in, hψ_eq⟩ := hf
    rw [← hψ_eq]
    have h_gψ : ψ ∈ g_content x := h_sub ψ hψ_in
    simp [g_content, Bundle.g_content] at h_gψ
    exact h_gψ
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.all_future L) h_GL_in_x d_G

/--
g_content of an MCS is consistent.
-/
theorem g_content_set_consistent (x : ReflCanDomain) :
    SetConsistent (fc := FrameClass.Base) (g_content x) := by
  have h_mcs := x.property
  intro L hL ⟨d⟩
  -- From L ⊆ g_content(x) and L ⊢ ⊥, get G(⊥) ∈ x.val
  have h_G_bot : Formula.all_future Formula.bot ∈ x.val :=
    g_content_closed_derivation h_mcs L hL d
  -- From G(⊥), derive G(⊤ → ⊥) using ex_falso + temp_k_dist
  let neg_top := (Formula.bot.imp Formula.bot).imp Formula.bot
  have h_ef : DerivationTree FrameClass.Base [] (Formula.bot.imp neg_top) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso neg_top) trivial
  have h_G_ef : DerivationTree FrameClass.Base [] (Formula.all_future (Formula.bot.imp neg_top)) :=
    DerivationTree.temporal_necessitation _ h_ef
  have h_kd : DerivationTree FrameClass.Base [] ((Formula.bot.imp neg_top).all_future.imp
    (Formula.bot.all_future.imp neg_top.all_future)) :=
    Bimodal.Theorems.TemporalDerived.temp_k_dist_derived Formula.bot neg_top
  have h1 := theorem_in_mcs h_mcs h_G_ef
  have h2 := theorem_in_mcs h_mcs h_kd
  have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
  have h_G_neg_top : neg_top.all_future ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h3 h_G_bot
  -- Seriality: ⊤ → F(⊤) is a theorem, where F(⊤) = ¬G(¬⊤) = ¬G(neg_top)
  have h_serial : DerivationTree FrameClass.Base [] ((Formula.bot.imp Formula.bot).imp
    (Formula.some_future (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ Axiom.serial_future trivial
  have h_serial_in := theorem_in_mcs h_mcs h_serial
  have h_top : DerivationTree FrameClass.Base [] (Formula.bot.imp Formula.bot) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso Formula.bot) trivial
  have h_top_in := theorem_in_mcs h_mcs h_top
  have h_F_top : Formula.some_future (Formula.bot.imp Formula.bot) ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h_serial_in h_top_in
  -- F(⊤) and G(¬⊤) are contradictory in MCS
  exact Bundle.some_future_all_future_neg_absurd h_mcs (Formula.bot.imp Formula.bot)
    h_F_top h_G_neg_top

/--
If all formulas in a list L are in h_content x, and L ⊢ φ, then H(φ) ∈ x.val.
-/
noncomputable def h_content_closed_derivation {x : ReflCanDomain} {φ : Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) x.val)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ h_content x)
    (h_deriv : DerivationTree FrameClass.Base L φ) : Formula.all_past φ ∈ x.val := by
  have d_H : (Context.map Formula.all_past L) ⊢ Formula.all_past φ :=
    generalized_past_k L φ h_deriv
  have h_HL_in_x : ∀ f ∈ Context.map Formula.all_past L, f ∈ x.val := by
    intro f hf
    rw [Context.mem_map_iff] at hf
    obtain ⟨ψ, hψ_in, hψ_eq⟩ := hf
    rw [← hψ_eq]
    have h_hψ : ψ ∈ h_content x := h_sub ψ hψ_in
    simp [h_content, Bundle.h_content] at h_hψ
    exact h_hψ
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.all_past L) h_HL_in_x d_H

/--
h_content of an MCS is consistent.
-/
theorem h_content_set_consistent (x : ReflCanDomain) :
    SetConsistent (fc := FrameClass.Base) (h_content x) := by
  have h_mcs := x.property
  intro L hL ⟨d⟩
  have h_H_bot : Formula.all_past Formula.bot ∈ x.val :=
    h_content_closed_derivation h_mcs L hL d
  let neg_top := (Formula.bot.imp Formula.bot).imp Formula.bot
  have h_ef : DerivationTree FrameClass.Base [] (Formula.bot.imp neg_top) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso neg_top) trivial
  have h_H_ef : DerivationTree FrameClass.Base [] (Formula.all_past (Formula.bot.imp neg_top)) :=
    Bimodal.Theorems.past_necessitation _ h_ef
  have h_kd : DerivationTree FrameClass.Base [] ((Formula.bot.imp neg_top).all_past.imp
    (Formula.bot.all_past.imp neg_top.all_past)) :=
    Bimodal.Theorems.past_k_dist Formula.bot neg_top
  have h1 := theorem_in_mcs h_mcs h_H_ef
  have h2 := theorem_in_mcs h_mcs h_kd
  have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
  have h_H_neg_top : neg_top.all_past ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h3 h_H_bot
  have h_serial : DerivationTree FrameClass.Base [] ((Formula.bot.imp Formula.bot).imp
    (Formula.some_past (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ Axiom.serial_past trivial
  have h_serial_in := theorem_in_mcs h_mcs h_serial
  have h_top : DerivationTree FrameClass.Base [] (Formula.bot.imp Formula.bot) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso Formula.bot) trivial
  have h_top_in := theorem_in_mcs h_mcs h_top
  have h_P_top : Formula.some_past (Formula.bot.imp Formula.bot) ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h_serial_in h_top_in
  exact Bundle.some_past_all_past_neg_absurd h_mcs (Formula.bot.imp Formula.bot)
    h_P_top h_H_neg_top

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
    DerivationTree.axiom [] _ (Axiom.modal_t φ) trivial
  -- MCS contains all theorems
  have h_imp_in : (Formula.box φ).imp φ ∈ x.val :=
    theorem_in_mcs h_mcs h_t
  -- By implication property: □φ ∈ x ∧ □φ→φ ∈ x → φ ∈ x
  exact h_mcs.implication_property h_imp_in h_box_phi

/-- canS5R is symmetric (S5). Uses modal_b: φ → □◇φ. -/
theorem canS5R_symm {x y : ReflCanDomain} (h : canS5R x y) : canS5R y x := by
  intro φ h_box_y
  have h_mcs_x := x.property
  have h_mcs_y := y.property
  by_contra h_not
  -- ¬φ ∈ x.val by negation completeness
  have h_neg_phi : Formula.neg φ ∈ x.val := by
    cases SetMaximalConsistent.negation_complete h_mcs_x φ with
    | inl h => exact absurd h h_not
    | inr h => exact h
  -- modal_b on ¬φ: ⊢ ¬φ → □◇(¬φ)
  have h_mb : [] ⊢ (Formula.neg φ).imp (Formula.box (Formula.neg φ).diamond) :=
    DerivationTree.axiom [] _ (Axiom.modal_b (Formula.neg φ)) trivial
  have h_box_dia : Formula.box (Formula.neg φ).diamond ∈ x.val :=
    h_mcs_x.implication_property (theorem_in_mcs h_mcs_x h_mb) h_neg_phi
  -- canS5R x y: ◇(¬φ) ∈ y.val
  have h_dia_y : (Formula.neg φ).diamond ∈ y.val := h (Formula.neg φ).diamond h_box_dia
  -- ◇(¬φ) = ¬□(¬¬φ), so ¬□(¬¬φ) ∈ y.val
  -- diamond φ = φ.neg.box.neg, so (¬φ).diamond = (¬φ).neg.box.neg = ¬(□(¬¬φ))
  -- Now derive □(¬¬φ) ∈ y.val from □φ ∈ y.val
  -- Step: ⊢ φ → ¬¬φ (dni)
  have h_dni : [] ⊢ φ.imp φ.neg.neg := Combinators.dni φ
  -- Step: ⊢ □(φ → ¬¬φ) via modal necessitation
  have h_box_dni : [] ⊢ Formula.box (φ.imp φ.neg.neg) :=
    DerivationTree.necessitation _ h_dni
  -- Step: ⊢ □(φ → ¬¬φ) → (□φ → □(¬¬φ)) via modal_k_dist
  have h_kd : [] ⊢ (φ.imp φ.neg.neg).box.imp (φ.box.imp φ.neg.neg.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ φ.neg.neg) trivial
  -- □(φ → ¬¬φ) ∈ y.val
  have h_box_dni_y : (φ.imp φ.neg.neg).box ∈ y.val :=
    theorem_in_mcs h_mcs_y h_box_dni
  -- □φ → □(¬¬φ) ∈ y.val
  have h_imp_y : φ.box.imp φ.neg.neg.box ∈ y.val :=
    h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_kd) h_box_dni_y
  -- □(¬¬φ) ∈ y.val
  have h_box_negneg : φ.neg.neg.box ∈ y.val :=
    h_mcs_y.implication_property h_imp_y h_box_y
  -- But ◇(¬φ) = (¬φ).neg.box.neg = φ.neg.neg.box.neg = ¬□(¬¬φ)
  -- So ¬□(¬¬φ) ∈ y.val, i.e., φ.neg.neg.box.neg ∈ y.val
  -- h_dia_y : (Formula.neg φ).diamond ∈ y.val
  -- (Formula.neg φ).diamond = (Formula.neg φ).neg.box.neg = φ.neg.neg.box.neg
  have h_neg_box_negneg : φ.neg.neg.box.neg ∈ y.val := h_dia_y
  -- Contradiction: both □(¬¬φ) and ¬□(¬¬φ) in y.val
  exact set_consistent_not_both h_mcs_y.1 φ.neg.neg.box h_box_negneg h_neg_box_negneg

/-- canS5R is transitive via modal 4. -/
theorem canS5R_trans {x y z : ReflCanDomain}
    (h_xy : canS5R x y) (h_yz : canS5R y z) : canS5R x z := by
  intro φ h_box_phi_x
  have h_mcs_x := x.property
  -- From modal 4: □φ → □□φ
  have h_box_box_phi_x : Formula.box (Formula.box φ) ∈ x.val := by
    have h_4 : [] ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) :=
      DerivationTree.axiom [] _ (Axiom.modal_4 φ) trivial
    have h_4_in : (Formula.box φ).imp (Formula.box (Formula.box φ)) ∈ x.val :=
      theorem_in_mcs h_mcs_x h_4
    exact h_mcs_x.implication_property h_4_in h_box_phi_x
  -- □□φ ∈ x gives □φ ∈ y (by h_xy applied to □φ as the witness formula)
  have h_box_phi_y : Formula.box φ ∈ y.val := h_xy (Formula.box φ) h_box_box_phi_x
  -- Then φ ∈ z
  exact h_yz φ h_box_phi_y

end Bimodal.Metalogic.WeakCanonical
