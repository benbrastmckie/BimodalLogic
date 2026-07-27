/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Core.MCSProperties
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Metalogic.Bundle.TemporalContent
import FormalSystem.Metalogic.BXCanonical.OrderedSeedConsistency
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Syntax.Context

/-!
# Reflexive Canonical Model for TM Bimodal Logic

Defines the reflexive canonical model for Reynolds/Doets discrete completeness.
Key innovation: R is defined via "weak G" content (`g_w_content`), making it
reflexive, which enables the Z-model compression bypassing `succ_cofinal`
(archived — see `Boneyard/DeadChronicleGapElimination/`).

## Structure
- `ReflCanDomain`: subtype of all set-maximal consistent sets
- `reflCanR`: reflexive canonical accessibility (xRy iff g_w_content x ⊆ y.val)
- `tempR_fwd` / `tempR_bwd`: strict temporal relations (via g_content/h_content)
- `reflCanV`: canonical valuation
- `canS5R`: S5 box-accessibility relation
-/
namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems

/-! ## Domain -/

/-- Domain of the reflexive canonical model: all set-maximal consistent sets. -/
def ReflCanDomain (fc : FrameClass := FrameClass.Base) : Type :=
    { S : Set Formula // SetMaximalConsistent (fc := fc) S }

namespace ReflCanDomain

instance : CoeSort ReflCanDomain (Set Formula) := ⟨fun x => x.val⟩

/-- Extract MCS proof from a domain element. -/
theorem mcs (x : ReflCanDomain) : SetMaximalConsistent (fc := FrameClass.Base) x.val := x.property

/-- Equality via set equality. -/
theorem ext {x y : ReflCanDomain} (h : x.val = y.val) : x = y :=
  Subtype.ext h

end ReflCanDomain

/-! ## Temporal Content -/

/-- Strong G-content: ψ such that G(ψ) ∈ x. (From Bundle.TemporalContent) -/
def GContent (x : ReflCanDomain) : Set Formula :=
  Bundle.GContent x.val

/-- Weak G-content (reflexive): ψ such that ψ ∧ G(ψ) ∈ x. -/
def GWContent (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.and ψ (Formula.allFuture ψ) ∈ x.val }

/-- Strong H-content: ψ such that H(ψ) ∈ x. (From Bundle.TemporalContent) -/
def HContent (x : ReflCanDomain) : Set Formula :=
  Bundle.HContent x.val

/-- Weak H-content (reflexive): ψ such that ψ ∧ H(ψ) ∈ x. -/
def HWContent (x : ReflCanDomain) : Set Formula :=
  { ψ | Formula.and ψ (Formula.allPast ψ) ∈ x.val }

/-! ## Accessibility Relations -/

/-- Reflexive canonical accessibility relation: xRy iff g_w_content x ⊆ y.val. -/
def reflCanR (x y : ReflCanDomain) : Prop :=
  GWContent x ⊆ y.val

/-- Temporal future relation: x R_fwd y iff g_content x ⊆ y.val. -/
def TempRFwd (x y : ReflCanDomain) : Prop :=
  GContent x ⊆ y.val

/-- Temporal past relation: y R_bwd x iff h_content y ⊆ x.val. -/
def TempRBwd (x y : ReflCanDomain) : Prop :=
  HContent y ⊆ x.val

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
    (h_xy : TempRFwd x y) (h_yz : TempRFwd y z) : TempRFwd x z := by
  intro ψ h_ψ_gx
  have h_mcs_x := x.property
  -- h_ψ_gx : ψ ∈ g_content x ↔ G(ψ) ∈ x.val
  have h_Gψ_x : Formula.allFuture ψ ∈ x.val := by
    simp only [GContent, Bundle.GContent, Set.mem_setOf_eq] at h_ψ_gx
    exact h_ψ_gx
  -- Step 1: G(ψ) → G(G(ψ)) via temp_4
  have h_GGψ_x : Formula.allFuture (Formula.allFuture ψ) ∈ x.val :=
    h_mcs_x.all_future_all_future h_Gψ_x
  -- Step 2: G(ψ) ∈ g_content x (since G(G(ψ)) ∈ x.val)
  have h_Gψ_gx : Formula.allFuture ψ ∈ GContent x := by
    simp [GContent, Bundle.GContent, h_GGψ_x]
  -- Step 3: By tempR_fwd x y, G(ψ) ∈ y.val
  have h_Gψ_y : Formula.allFuture ψ ∈ y.val := h_xy h_Gψ_gx
  -- Step 4: ψ ∈ g_content y (since G(ψ) ∈ y.val)
  have h_ψ_gy : ψ ∈ GContent y := by
    simp [GContent, Bundle.GContent, h_Gψ_y]
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
    (h_fwd : TempRFwd x y) (β : Formula) (h_β_y : β ∈ y.val) :
    Formula.someFuture β ∈ x.val := by
  have h_mcs_x := x.property
  by_contra h_Fβ_nx
  -- ¬F(β) ∈ x.val by negation completeness
  -- F(β) = β.neg.all_future.neg (definition: some_future β = β.neg.all_future.neg)
  -- ¬F(β) = F(β).neg = β.neg.all_future.neg.neg
  have h_neg_Fβ : (Formula.someFuture β).neg ∈ x.val :=
    (SetMaximalConsistent.negation_complete h_mcs_x (Formula.someFuture β)).resolve_left h_Fβ_nx
  -- G(¬β) ∈ x.val from ¬F(β) via duality bridge
  have h_G_neg_β : (Formula.neg β).allFuture ∈ x.val :=
    Bundle.neg_some_future_to_all_future_neg h_mcs_x β h_neg_Fβ
  -- ¬β ∈ g_content(x)
  have h_neg_β_gc : Formula.neg β ∈ GContent x := by
    simp [GContent, Bundle.GContent, h_G_neg_β]
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
    (h_not : ¬TempRFwd y z) :
    ∃ γ₀ : Formula, γ₀ ∈ z.val ∧ Formula.someFuture γ₀ ∉ y.val := by
  by_contra h_all
  push Not at h_all
  -- h_all : ∀ γ₀, γ₀ ∈ z.val → F(γ₀) ∈ y.val
  -- Show tempR_fwd y z, contradicting h_not
  apply h_not
  intro ψ h_ψ_gc
  -- ψ ∈ g_content y means G(ψ) ∈ y.val
  have h_Gψ_y : Formula.allFuture ψ ∈ y.val := by
    simp only [GContent, Bundle.GContent, Set.mem_setOf_eq] at h_ψ_gc; exact h_ψ_gc
  -- Need ψ ∈ z.val. By contradiction: if ψ ∉ z.val, then ¬ψ ∈ z.val
  by_contra h_ψ_nz
  have h_mcs_z := z.property
  have h_mcs_y := y.property
  have h_neg_ψ_z : Formula.neg ψ ∈ z.val :=
    (SetMaximalConsistent.negation_complete h_mcs_z ψ).resolve_left h_ψ_nz
  -- F(¬ψ) ∈ y.val (by h_all applied to ¬ψ ∈ z.val)
  have h_F_neg_ψ_y : Formula.someFuture (Formula.neg ψ) ∈ y.val := h_all _ h_neg_ψ_z
  -- F(¬ψ) = (¬ψ).neg.all_future.neg = ψ.neg.neg.all_future.neg = ¬G(¬¬ψ)
  -- G(ψ) ∈ y.val. Need G(ψ) and F(¬ψ) to be contradictory.
  -- F(¬ψ) = ¬G(¬¬ψ). We need G(ψ) → G(¬¬ψ) to get a contradiction.
  -- From ψ → ¬¬ψ (dni) via temp_k_dist + temporal_necessitation: G(ψ) → G(¬¬ψ)
  have h_dni : [] ⊢ ψ.imp ψ.neg.neg := Combinators.notNotIntro ψ
  have h_G_dni : [] ⊢ Formula.allFuture (ψ.imp ψ.neg.neg) :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_kd : [] ⊢ (ψ.imp ψ.neg.neg).allFuture.imp (ψ.allFuture.imp ψ.neg.neg.allFuture) :=
    FormalSystem.Theorems.TemporalDerived.temporalKDistDerived ψ ψ.neg.neg
  have h_Gψ_imp_Gnn : [] ⊢ ψ.allFuture.imp ψ.neg.neg.allFuture :=
    Combinators.mp h_G_dni h_kd
  -- G(¬¬ψ) ∈ y.val
  have h_Gnn_y : ψ.neg.neg.allFuture ∈ y.val :=
    h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_Gψ_imp_Gnn) h_Gψ_y
  -- F(¬ψ) and G(¬¬ψ) = G(¬(¬ψ).neg) are contradictory in MCS y
  exact Bundle.some_future_all_future_neg_absurd h_mcs_y (Formula.neg ψ) h_F_neg_ψ_y h_Gnn_y

/--
Helper: From `⊢ A → B`, derive `⊢ F(A) → F(B)` (F-monotonicity).
Uses BX3 (right_mono_until): G(A → B) → (U(A, ⊤) → U(B, ⊤)), i.e., G(A → B) → (F(A) → F(B)).
-/
noncomputable def someFutureMono {A B : Formula}
    (h : [] ⊢ A.imp B) : [] ⊢ (Formula.someFuture A).imp (Formula.someFuture B) := by
  -- G(A → B) via temporal necessitation
  have h_G : [] ⊢ Formula.allFuture (A.imp B) :=
    DerivationTree.temporal_necessitation _ h
  -- BX3: G(A → B) → (U(A, ⊤) → U(B, ⊤)) = G(A → B) → (F(A) → F(B))
  have h_bx3 : [] ⊢ (A.imp B).allFuture.imp
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
    (h_xy : TempRFwd x y) (h_xz : TempRFwd x z) :
    TempRFwd y z ∨ y = z ∨ TempRFwd z y := by
  -- By contradiction: assume none of the three holds
  by_contra h_none
  push Not at h_none
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
    have h_nFγ₀_y : (Formula.someFuture γ₀).neg ∈ y.val :=
      (SetMaximalConsistent.negation_complete h_mcs_y _).resolve_left h_Fγ₀_ny
    -- ¬F(β₀) ∈ z.val (negation completeness)
    have h_nFβ₀_z : (Formula.someFuture β₀).neg ∈ z.val :=
      (SetMaximalConsistent.negation_complete h_mcs_z _).resolve_left h_Fβ₀_nz
    -- ¬δ ∈ z.val (negation completeness)
    have h_nδ_z : δ.neg ∈ z.val :=
      (SetMaximalConsistent.negation_complete h_mcs_z _).resolve_left h_δ_nz
    -- β = (β₀ ∧ ¬Fγ₀) ∧ δ ∈ y.val
    let β := Formula.and (Formula.and β₀ (Formula.someFuture γ₀).neg) δ
    have h_β_y : β ∈ y.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing β₀ (Formula.someFuture γ₀).neg
      have h_inner : Formula.and β₀ (Formula.someFuture γ₀).neg ∈ y.val :=
        h_mcs_y.implication_property
          (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p1) h_β₀_y) h_nFγ₀_y
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing
          (Formula.and β₀ (Formula.someFuture γ₀).neg) δ
      exact h_mcs_y.implication_property
        (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p2) h_inner) h_δ_y
    -- γ = (γ₀ ∧ ¬Fβ₀) ∧ ¬δ ∈ z.val
    let γ := Formula.and (Formula.and γ₀ (Formula.someFuture β₀).neg) δ.neg
    have h_γ_z : γ ∈ z.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing γ₀ (Formula.someFuture β₀).neg
      have h_inner : Formula.and γ₀ (Formula.someFuture β₀).neg ∈ z.val :=
        h_mcs_z.implication_property
          (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p1) h_γ₀_z) h_nFβ₀_z
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing
          (Formula.and γ₀ (Formula.someFuture β₀).neg) δ.neg
      exact h_mcs_z.implication_property
        (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p2) h_inner) h_nδ_z
    -- F(β) ∈ x.val and F(γ) ∈ x.val (by Lemma 1.6(b))
    have h_Fβ_x : Formula.someFuture β ∈ x.val :=
      tempR_fwd_mem_some_future h_xy β h_β_y
    have h_Fγ_x : Formula.someFuture γ ∈ x.val :=
      tempR_fwd_mem_some_future h_xz γ h_γ_z
    -- BX11 case analysis
    rcases BXCanonical.temp_linearity_mcs h_mcs_x β γ h_Fβ_x h_Fγ_x with
      h_c1 | h_c2 | h_c3
    · -- Case 1: F(β ∧ γ) ∈ x.val. β∧γ contains δ and ¬δ → inconsistent.
      have h1 : [] ⊢ (β.and γ).imp δ :=
        Combinators.impTrans (lceImp β γ) (rceImp _ δ)
      have h2 : [] ⊢ (β.and γ).imp δ.neg :=
        Combinators.impTrans (rceImp β γ) (rceImp _ δ.neg)
      have h_bot : [] ⊢ (β.and γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
            (Axiom.prop_k (β.and γ) δ Formula.bot) trivial
        exact Combinators.mp h1 (Combinators.mp h2 hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x (β.and γ) h_c1
        (theorem_in_mcs h_mcs_x hG)
    · -- Case 2: F(β ∧ F(γ)) ∈ x.val. F(γ)→F(γ₀) (mono), β→¬F(γ₀) → inconsistent.
      have h_γ_to_γ₀ : [] ⊢ γ.imp γ₀ :=
        Combinators.impTrans (lceImp _ δ.neg) (lceImp γ₀ _)
      have h_Fγ_to_Fγ₀ : [] ⊢ (Formula.someFuture γ).imp (Formula.someFuture γ₀) :=
        someFutureMono h_γ_to_γ₀
      have h_β_to_nFγ₀ : [] ⊢ β.imp (Formula.someFuture γ₀).neg :=
        Combinators.impTrans (lceImp _ δ) (rceImp β₀ _)
      have h_l : [] ⊢ (Formula.and β (Formula.someFuture γ)).imp (Formula.someFuture γ₀).neg :=
        Combinators.impTrans (lceImp β _) h_β_to_nFγ₀
      have h_r : [] ⊢ (Formula.and β (Formula.someFuture γ)).imp (Formula.someFuture γ₀) :=
        Combinators.impTrans (rceImp β _) h_Fγ_to_Fγ₀
      have h_bot : [] ⊢ (Formula.and β (Formula.someFuture γ)).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and β (Formula.someFuture γ)) (Formula.someFuture γ₀)
              Formula.bot) trivial
        exact Combinators.mp h_r (Combinators.mp h_l hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and β (Formula.someFuture γ)) h_c2 (theorem_in_mcs h_mcs_x hG)
    · -- Case 3: F(F(β) ∧ γ) ∈ x.val. F(β)→F(β₀) (mono), γ→¬F(β₀) → inconsistent.
      have h_β_to_β₀ : [] ⊢ β.imp β₀ :=
        Combinators.impTrans (lceImp _ δ) (lceImp β₀ _)
      have h_Fβ_to_Fβ₀ : [] ⊢ (Formula.someFuture β).imp (Formula.someFuture β₀) :=
        someFutureMono h_β_to_β₀
      have h_γ_to_nFβ₀ : [] ⊢ γ.imp (Formula.someFuture β₀).neg :=
        Combinators.impTrans (lceImp _ δ.neg) (rceImp γ₀ _)
      have h_l : [] ⊢ (Formula.and (Formula.someFuture β) γ).imp (Formula.someFuture β₀) :=
        Combinators.impTrans (lceImp _ γ) h_Fβ_to_Fβ₀
      have h_r : [] ⊢ (Formula.and (Formula.someFuture β) γ).imp (Formula.someFuture β₀).neg :=
        Combinators.impTrans (rceImp _ γ) h_γ_to_nFβ₀
      have h_bot : [] ⊢ (Formula.and (Formula.someFuture β) γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and (Formula.someFuture β) γ) (Formula.someFuture β₀)
              Formula.bot) trivial
        exact Combinators.mp h_l (Combinators.mp h_r hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and (Formula.someFuture β) γ) h_c3 (theorem_in_mcs h_mcs_x hG)
  · -- Case: z.val ⊄ y.val. Symmetric: δ ∈ z.val with δ ∉ y.val.
    obtain ⟨δ, h_δ_z, h_δ_ny⟩ := Set.not_subset.mp h_z_nsub
    have h_nFγ₀_y : (Formula.someFuture γ₀).neg ∈ y.val :=
      (SetMaximalConsistent.negation_complete h_mcs_y _).resolve_left h_Fγ₀_ny
    have h_nFβ₀_z : (Formula.someFuture β₀).neg ∈ z.val :=
      (SetMaximalConsistent.negation_complete h_mcs_z _).resolve_left h_Fβ₀_nz
    have h_nδ_y : δ.neg ∈ y.val :=
      (SetMaximalConsistent.negation_complete h_mcs_y _).resolve_left h_δ_ny
    -- β = (β₀ ∧ ¬Fγ₀) ∧ ¬δ ∈ y.val
    let β := Formula.and (Formula.and β₀ (Formula.someFuture γ₀).neg) δ.neg
    have h_β_y : β ∈ y.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing β₀ (Formula.someFuture γ₀).neg
      have h_inner : Formula.and β₀ (Formula.someFuture γ₀).neg ∈ y.val :=
        h_mcs_y.implication_property
          (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p1) h_β₀_y) h_nFγ₀_y
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing
          (Formula.and β₀ (Formula.someFuture γ₀).neg) δ.neg
      exact h_mcs_y.implication_property
        (h_mcs_y.implication_property (theorem_in_mcs h_mcs_y h_p2) h_inner) h_nδ_y
    -- γ = (γ₀ ∧ ¬Fβ₀) ∧ δ ∈ z.val
    let γ := Formula.and (Formula.and γ₀ (Formula.someFuture β₀).neg) δ
    have h_γ_z : γ ∈ z.val := by
      have h_p1 : DerivationTree FrameClass.Base [] _ := pairing γ₀ (Formula.someFuture β₀).neg
      have h_inner : Formula.and γ₀ (Formula.someFuture β₀).neg ∈ z.val :=
        h_mcs_z.implication_property
          (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p1) h_γ₀_z) h_nFβ₀_z
      have h_p2 : DerivationTree FrameClass.Base [] _ := pairing
          (Formula.and γ₀ (Formula.someFuture β₀).neg) δ
      exact h_mcs_z.implication_property
        (h_mcs_z.implication_property (theorem_in_mcs h_mcs_z h_p2) h_inner) h_δ_z
    have h_Fβ_x : Formula.someFuture β ∈ x.val :=
      tempR_fwd_mem_some_future h_xy β h_β_y
    have h_Fγ_x : Formula.someFuture γ ∈ x.val :=
      tempR_fwd_mem_some_future h_xz γ h_γ_z
    -- BX11: symmetric case. β has ¬δ, γ has δ.
    rcases BXCanonical.temp_linearity_mcs h_mcs_x β γ h_Fβ_x h_Fγ_x with
      h_c1 | h_c2 | h_c3
    · -- F(β∧γ): β→¬δ and γ→δ → inconsistent
      have h1 : [] ⊢ (β.and γ).imp δ.neg :=
        Combinators.impTrans (lceImp β γ) (rceImp _ δ.neg)
      have h2 : [] ⊢ (β.and γ).imp δ :=
        Combinators.impTrans (rceImp β γ) (rceImp _ δ)
      have h_bot : [] ⊢ (β.and γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
            (Axiom.prop_k (β.and γ) δ Formula.bot) trivial
        exact Combinators.mp h2 (Combinators.mp h1 hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x (β.and γ) h_c1
        (theorem_in_mcs h_mcs_x hG)
    · -- F(β∧Fγ): Fγ→Fγ₀, β→¬Fγ₀ → inconsistent
      have h_γ_to_γ₀ : [] ⊢ γ.imp γ₀ :=
        Combinators.impTrans (lceImp _ δ) (lceImp γ₀ _)
      have h_Fγ_to_Fγ₀ := someFutureMono h_γ_to_γ₀
      have h_β_to_nFγ₀ : [] ⊢ β.imp (Formula.someFuture γ₀).neg :=
        Combinators.impTrans (lceImp _ δ.neg) (rceImp β₀ _)
      have h_l : [] ⊢ (Formula.and β (Formula.someFuture γ)).imp (Formula.someFuture γ₀).neg :=
        Combinators.impTrans (lceImp β _) h_β_to_nFγ₀
      have h_r : [] ⊢ (Formula.and β (Formula.someFuture γ)).imp (Formula.someFuture γ₀) :=
        Combinators.impTrans (rceImp β _) h_Fγ_to_Fγ₀
      have h_bot : [] ⊢ (Formula.and β (Formula.someFuture γ)).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and β (Formula.someFuture γ)) (Formula.someFuture γ₀)
              Formula.bot) trivial
        exact Combinators.mp h_r (Combinators.mp h_l hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and β (Formula.someFuture γ)) h_c2 (theorem_in_mcs h_mcs_x hG)
    · -- F(Fβ∧γ): Fβ→Fβ₀, γ→¬Fβ₀ → inconsistent
      have h_β_to_β₀ : [] ⊢ β.imp β₀ :=
        Combinators.impTrans (lceImp _ δ.neg) (lceImp β₀ _)
      have h_Fβ_to_Fβ₀ := someFutureMono h_β_to_β₀
      have h_γ_to_nFβ₀ : [] ⊢ γ.imp (Formula.someFuture β₀).neg :=
        Combinators.impTrans (lceImp _ δ) (rceImp γ₀ _)
      have h_l : [] ⊢ (Formula.and (Formula.someFuture β) γ).imp (Formula.someFuture β₀) :=
        Combinators.impTrans (lceImp _ γ) h_Fβ_to_Fβ₀
      have h_r : [] ⊢ (Formula.and (Formula.someFuture β) γ).imp (Formula.someFuture β₀).neg :=
        Combinators.impTrans (rceImp _ γ) h_γ_to_nFβ₀
      have h_bot : [] ⊢ (Formula.and (Formula.someFuture β) γ).imp Formula.bot := by
        have hk := DerivationTree.axiom (fc := FrameClass.Base) [] _
          (Axiom.prop_k (Formula.and (Formula.someFuture β) γ) (Formula.someFuture β₀)
              Formula.bot) trivial
        exact Combinators.mp h_l (Combinators.mp h_r hk)
      have hG := DerivationTree.temporal_necessitation _ h_bot
      exact Bundle.some_future_all_future_neg_absurd h_mcs_x
        (Formula.and (Formula.someFuture β) γ) h_c3 (theorem_in_mcs h_mcs_x hG)

/--
Backward bridge lemma: if `tempR_bwd y x`, then `h_w_content x ⊆ y.val`.

This is the mirror of `tempR_fwd_imp_reflCanR` for the past direction:
h_w_content x ⊆ h_content x, and tempR_bwd y x gives h_content x ⊆ y.val.
-/
theorem tempR_bwd_imp_reflCanR_bwd {x y : ReflCanDomain}
    (h_temp : TempRBwd y x) : HWContent x ⊆ y.val := by
  intro ψ hψ_hwx
  have h_mcs_x := x.property
  -- hψ_hwx : ψ ∈ h_w_content x → ψ ∧ H(ψ) ∈ x.val
  have h_psi_and_H : Formula.and ψ (Formula.allPast ψ) ∈ x.val := hψ_hwx
  -- From ψ∧Hψ ∈ x, derive Hψ ∈ x (using rce)
  have h_Hpsi : Formula.allPast ψ ∈ x.val := by
    have h_rce : [Formula.and ψ (Formula.allPast ψ)] ⊢ Formula.allPast ψ :=
      andRight ψ (Formula.allPast ψ)
    have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.allPast ψ)], χ ∈ x.val := by
      intro χ hχ; simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ; subst hχ; exact
          h_psi_and_H
    exact h_mcs_x.closed_under_derivation
      [Formula.and ψ (Formula.allPast ψ)] h_sub h_rce
  -- So ψ ∈ h_content x, and tempR_bwd y x means h_content x ⊆ y.val
  have h_ψ_hx : ψ ∈ HContent x := by
    simp [HContent, Bundle.HContent, h_Hpsi]
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
  have h_psi_and_G_in_x : Formula.and ψ (Formula.allFuture ψ) ∈ x.val := hψ_in_gw
  -- lce: from ψ∧Gψ derive ψ
  have h_lce : [Formula.and ψ (Formula.allFuture ψ)] ⊢ ψ :=
    andLeft ψ (Formula.allFuture ψ)
  have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.allFuture ψ)], χ ∈ x.val := by
    intro χ hχ
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ
    subst hχ
    exact h_psi_and_G_in_x
  exact h_mcs.closed_under_derivation
    [Formula.and ψ (Formula.allFuture ψ)] h_sub h_lce

/--
reflCanR is transitive. Uses MCS conjunction and temp_4 for G-propagation.
-/
theorem reflCanR_trans {x y z : ReflCanDomain}
    (h_xy : reflCanR x y) (h_yz : reflCanR y z) : reflCanR x z := by
  intro ψ h_psi_in_gwx
  have h_mcs_x := x.property
  have h_mcs_y := y.property
  -- h_psi_in_gwx: ψ ∈ g_w_content x, so ψ∧Gψ ∈ x.val
  have h_psi_and_G_in_x : Formula.and ψ (Formula.allFuture ψ) ∈ x.val := h_psi_in_gwx
  -- Step 1: ψ ∈ y.val (h_xy applied to ψ ∈ g_w_content x)
  have h_psi_in_y : ψ ∈ y.val := h_xy h_psi_in_gwx
  -- Step 2: Extract G(ψ) ∈ x.val from ψ∧Gψ ∈ x (using rce)
  have h_Gpsi_in_x : Formula.allFuture ψ ∈ x.val := by
    have h_rce : [Formula.and ψ (Formula.allFuture ψ)] ⊢ Formula.allFuture ψ :=
      andRight ψ (Formula.allFuture ψ)
    have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.allFuture ψ)], χ ∈ x.val := by
      intro χ hχ
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ
      subst hχ
      exact h_psi_and_G_in_x
    exact h_mcs_x.closed_under_derivation
      [Formula.and ψ (Formula.allFuture ψ)] h_sub h_rce
  -- Step 3: G(G(ψ)) ∈ x.val (temp_4)
  have h_GGpsi_in_x : Formula.allFuture (Formula.allFuture ψ) ∈ x.val :=
    h_mcs_x.all_future_all_future h_Gpsi_in_x
  -- Step 4: G(ψ) ∧ G(G(ψ)) ∈ x.val (MCS conjunction via theorem_in_mcs + pairing)
  let A := Formula.allFuture ψ
  let B := Formula.allFuture (Formula.allFuture ψ)
  let conj_term : Formula := Formula.and A B
  have h_conj_in_x : conj_term ∈ x.val := by
    have h_pairing : [] ⊢ A.imp (B.imp conj_term) := pairing A B
    have h_pairing_in : A.imp (B.imp conj_term) ∈ x.val := theorem_in_mcs h_mcs_x h_pairing
    have h_B_imp_conj : B.imp conj_term ∈ x.val :=
      h_mcs_x.implication_property h_pairing_in h_Gpsi_in_x
    exact h_mcs_x.implication_property h_B_imp_conj h_GGpsi_in_x
  -- Step 5: G(ψ) ∈ g_w_content x (since Gψ ∧ GGψ ∈ x)
  have h_Gpsi_in_gwx : Formula.allFuture ψ ∈ GWContent x := h_conj_in_x
  -- Step 6: G(ψ) ∈ y.val (by h_xy)
  have h_Gpsi_in_y : Formula.allFuture ψ ∈ y.val := h_xy h_Gpsi_in_gwx
  -- Step 7: ψ ∧ G(ψ) ∈ y.val (MCS conjunction)
  let A' := ψ
  let B' := Formula.allFuture ψ
  let conj_term' : Formula := Formula.and A' B'
  have h_psi_and_G_in_y : conj_term' ∈ y.val := by
    have h_pairing : [] ⊢ A'.imp (B'.imp conj_term') := pairing A' B'
    have h_pairing_in : A'.imp (B'.imp conj_term') ∈ y.val := theorem_in_mcs h_mcs_y h_pairing
    have h_B_imp_conj : B'.imp conj_term' ∈ y.val :=
      h_mcs_y.implication_property h_pairing_in h_psi_in_y
    exact h_mcs_y.implication_property h_B_imp_conj h_Gpsi_in_y
  -- Step 8: ψ ∈ g_w_content y, then ψ ∈ z.val by h_yz
  have h_psi_in_gwy : ψ ∈ GWContent y := h_psi_and_G_in_y
  exact h_yz h_psi_in_gwy

/--
If tempR_fwd x y, then reflCanR x y.
Since g_w_content x = {ψ | ψ∧Gψ∈x} ⊆ g_content x = {ψ | Gψ∈x},
we have g_content x ⊆ y.val implies g_w_content x ⊆ y.val.
-/
theorem tempR_fwd_imp_reflCanR {x y : ReflCanDomain}
    (h_temp : TempRFwd x y) : reflCanR x y := by
  intro ψ hψ_gwx
  have h_mcs_x := x.property
  -- hψ_gwx : ψ ∈ g_w_content x → ψ ∧ Gψ ∈ x.val
  have h_psi_and_G : Formula.and ψ (Formula.allFuture ψ) ∈ x.val := hψ_gwx
  -- From ψ∧Gψ ∈ x, derive Gψ ∈ x (using rce)
  have h_Gpsi : Formula.allFuture ψ ∈ x.val := by
    have h_rce : [Formula.and ψ (Formula.allFuture ψ)] ⊢ Formula.allFuture ψ :=
      andRight ψ (Formula.allFuture ψ)
    have h_sub : ∀ χ ∈ [Formula.and ψ (Formula.allFuture ψ)], χ ∈ x.val := by
      intro χ hχ; simp only [List.mem_cons, List.not_mem_nil, or_false] at hχ; subst hχ; exact
          h_psi_and_G
    exact h_mcs_x.closed_under_derivation [Formula.and ψ (Formula.allFuture ψ)] h_sub h_rce
  -- So ψ ∈ g_content x, and tempR_fwd x y means g_content x ⊆ y.val
  have h_psi_gx : ψ ∈ GContent x := by
    simp [GContent, Bundle.GContent, h_Gpsi]
  exact h_temp h_psi_gx

/-! ## Key Helper: g_content Closed Under Derivation -/

/--
If all formulas in a list L are in g_content x, and L ⊢ φ, then G(φ) ∈ x.val.
This is the same as `g_content_closed_derivation` in BXCanonical/Frame.lean
but adapted for ReflCanDomain.
-/
theorem g_content_closed_derivation {x : ReflCanDomain} {φ : Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) x.val)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ GContent x)
    (h_deriv : DerivationTree FrameClass.Base L φ) : Formula.allFuture φ ∈ x.val := by
  -- Apply generalized temporal K: L ⊢ φ gives G(L) ⊢ G(φ)
  have d_G : (Context.map Formula.allFuture L) ⊢ Formula.allFuture φ :=
    generalizedTemporalK L φ h_deriv
  -- All formulas in G(L) are in x.val (by g_content membership)
  have h_GL_in_x : ∀ f ∈ Context.map Formula.allFuture L, f ∈ x.val := by
    intro f hf
    rw [Context.mem_map_iff] at hf
    obtain ⟨ψ, hψ_in, hψ_eq⟩ := hf
    rw [← hψ_eq]
    have h_gψ : ψ ∈ GContent x := h_sub ψ hψ_in
    simp only [GContent, Bundle.GContent, Set.mem_setOf_eq] at h_gψ
    exact h_gψ
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.allFuture L) h_GL_in_x d_G

/--
g_content of an MCS is consistent.
-/
theorem g_content_set_consistent (x : ReflCanDomain) :
    SetConsistent (fc := FrameClass.Base) (GContent x) := by
  have h_mcs := x.property
  intro L hL ⟨d⟩
  -- From L ⊆ g_content(x) and L ⊢ ⊥, get G(⊥) ∈ x.val
  have h_G_bot : Formula.allFuture Formula.bot ∈ x.val :=
    g_content_closed_derivation h_mcs L hL d
  -- From G(⊥), derive G(⊤ → ⊥) using ex_falso + temp_k_dist
  let neg_top := (Formula.bot.imp Formula.bot).imp Formula.bot
  have h_ef : DerivationTree FrameClass.Base [] (Formula.bot.imp neg_top) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso neg_top) trivial
  have h_G_ef : DerivationTree FrameClass.Base [] (Formula.allFuture (Formula.bot.imp neg_top)) :=
    DerivationTree.temporal_necessitation _ h_ef
  have h_kd : DerivationTree FrameClass.Base [] ((Formula.bot.imp neg_top).allFuture.imp
    (Formula.bot.allFuture.imp neg_top.allFuture)) :=
    FormalSystem.Theorems.TemporalDerived.temporalKDistDerived Formula.bot neg_top
  have h1 := theorem_in_mcs h_mcs h_G_ef
  have h2 := theorem_in_mcs h_mcs h_kd
  have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
  have h_G_neg_top : neg_top.allFuture ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h3 h_G_bot
  -- Seriality: ⊤ → F(⊤) is a theorem, where F(⊤) = ¬G(¬⊤) = ¬G(neg_top)
  have h_serial : DerivationTree FrameClass.Base [] ((Formula.bot.imp Formula.bot).imp
    (Formula.someFuture (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ Axiom.serial_future trivial
  have h_serial_in := theorem_in_mcs h_mcs h_serial
  have h_top : DerivationTree FrameClass.Base [] (Formula.bot.imp Formula.bot) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso Formula.bot) trivial
  have h_top_in := theorem_in_mcs h_mcs h_top
  have h_F_top : Formula.someFuture (Formula.bot.imp Formula.bot) ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h_serial_in h_top_in
  -- F(⊤) and G(¬⊤) are contradictory in MCS
  exact Bundle.some_future_all_future_neg_absurd h_mcs (Formula.bot.imp Formula.bot)
    h_F_top h_G_neg_top

/--
If all formulas in a list L are in h_content x, and L ⊢ φ, then H(φ) ∈ x.val.
-/
theorem h_content_closed_derivation {x : ReflCanDomain} {φ : Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) x.val)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ HContent x)
    (h_deriv : DerivationTree FrameClass.Base L φ) : Formula.allPast φ ∈ x.val := by
  have d_H : (Context.map Formula.allPast L) ⊢ Formula.allPast φ :=
    generalizedPastK L φ h_deriv
  have h_HL_in_x : ∀ f ∈ Context.map Formula.allPast L, f ∈ x.val := by
    intro f hf
    rw [Context.mem_map_iff] at hf
    obtain ⟨ψ, hψ_in, hψ_eq⟩ := hf
    rw [← hψ_eq]
    have h_hψ : ψ ∈ HContent x := h_sub ψ hψ_in
    simp only [HContent, Bundle.HContent, Set.mem_setOf_eq] at h_hψ
    exact h_hψ
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.allPast L) h_HL_in_x d_H

/--
h_content of an MCS is consistent.
-/
theorem h_content_set_consistent (x : ReflCanDomain) :
    SetConsistent (fc := FrameClass.Base) (HContent x) := by
  have h_mcs := x.property
  intro L hL ⟨d⟩
  have h_H_bot : Formula.allPast Formula.bot ∈ x.val :=
    h_content_closed_derivation h_mcs L hL d
  let neg_top := (Formula.bot.imp Formula.bot).imp Formula.bot
  have h_ef : DerivationTree FrameClass.Base [] (Formula.bot.imp neg_top) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso neg_top) trivial
  have h_H_ef : DerivationTree FrameClass.Base [] (Formula.allPast (Formula.bot.imp neg_top)) :=
    FormalSystem.Theorems.pastNecessitation _ h_ef
  have h_kd : DerivationTree FrameClass.Base [] ((Formula.bot.imp neg_top).allPast.imp
    (Formula.bot.allPast.imp neg_top.allPast)) :=
    FormalSystem.Theorems.pastKDist Formula.bot neg_top
  have h1 := theorem_in_mcs h_mcs h_H_ef
  have h2 := theorem_in_mcs h_mcs h_kd
  have h3 := SetMaximalConsistent.implication_property h_mcs h2 h1
  have h_H_neg_top : neg_top.allPast ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h3 h_H_bot
  have h_serial : DerivationTree FrameClass.Base [] ((Formula.bot.imp Formula.bot).imp
    (Formula.somePast (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ Axiom.serial_past trivial
  have h_serial_in := theorem_in_mcs h_mcs h_serial
  have h_top : DerivationTree FrameClass.Base [] (Formula.bot.imp Formula.bot) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso Formula.bot) trivial
  have h_top_in := theorem_in_mcs h_mcs h_top
  have h_P_top : Formula.somePast (Formula.bot.imp Formula.bot) ∈ x.val :=
    SetMaximalConsistent.implication_property h_mcs h_serial_in h_top_in
  exact Bundle.some_past_all_past_neg_absurd h_mcs (Formula.bot.imp Formula.bot)
    h_P_top h_H_neg_top

/-! ## Valuation -/

/-- Canonical valuation: atom p true at x iff p ∈ x.val. -/
def reflCanV (x : ReflCanDomain) (p : Atom) : Prop :=
  Formula.atom p ∈ x.val

/-! ## Discreteness -/

/-- U(⊤,⊥): asserts existence of immediate successor (guard ⊥ is vacuous). -/
def nextTop : Formula := Formula.untl (Formula.bot.imp Formula.bot) Formula.bot

/-- If □(next_top) ∈ A, then next_top ∈ x.val for all x box-accessible from A. -/
theorem next_top_in_box_class (A : ReflCanDomain) (x : ReflCanDomain)
    (h_box : Formula.box nextTop ∈ A.val) (h_S5 : canS5R A x) :
    nextTop ∈ x.val :=
  h_S5 nextTop h_box

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
  have h_dni : [] ⊢ φ.imp φ.neg.neg := Combinators.notNotIntro φ
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

end FormalSystem.Metalogic.WeakCanonical
