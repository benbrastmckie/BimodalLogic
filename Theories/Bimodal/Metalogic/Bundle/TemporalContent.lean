import Bimodal.Syntax.Formula
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.TemporalDerived

/-!
# Temporal Content Definitions

Shared definitions for g_content, h_content, f_content, p_content, x_content, y_content
used by canonical model constructions.

## Universal Content Extractors
- `g_content(M)` = {φ | Gφ ∈ M} - formulas under universal future (G)
- `h_content(M)` = {φ | Hφ ∈ M} - formulas under universal past (H)

## Existential Content Extractors
- `f_content(M)` = {φ | Fφ ∈ M} - formulas under existential future (F)
- `p_content(M)` = {φ | Pφ ∈ M} - formulas under existential past (P)

## Next/Previous Content Extractors
- `x_content(M)` = {φ | X(φ) ∈ M} where X(φ) = ⊥ U φ
- `y_content(M)` = {φ | Y(φ) ∈ M} where Y(φ) = ⊥ S φ

## Key Results
- `x_content_mcs`: x_content(M) is MCS when M is MCS (using X-K + X-Det axioms)
- `y_content_mcs`: y_content(M) is MCS when M is MCS (using Y-K + Y-Det axioms)

## Duality
The existential operators are defined as duals of the universal operators:
- Fφ = ¬G¬φ (some future = not always not)
- Pφ = ¬H¬φ (some past = not always not)

This induces a relationship between the content extractors via MCS properties:
- φ ∈ f_content(M) ↔ ¬φ ∉ g_content(M)
- φ ∈ p_content(M) ↔ ¬φ ∉ h_content(M)

## Usage
- g_content and h_content: used in `TemporalCoherentConstruction.lean` and `DovetailingChain.lean`
- f_content: foundation for Succ relation (discrete track, tasks 10-15)
- p_content: foundation for DenseTask relation (dense track, tasks 16-18)
- x_content and y_content: deterministic chain construction for completeness_over_Int
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax

/--
g_content of an MCS: the set of all formulas phi where G phi appears in the MCS.

**Important**: g_content strips F-formulas. If F(psi) is in M, psi will NOT
appear in g_content(M) unless G(psi) is also in M. This means F-formulas do NOT
persist through g_content seeds in chain constructions. Resolution of F-obligations
requires a non-linear construction (e.g., omega-squared) rather than relying on
linear g_content propagation. See DovetailingChain.lean for details.
-/
def g_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

/--
h_content of an MCS: the set of all formulas phi where H phi appears in the MCS.

**Important**: h_content strips P-formulas. If P(psi) is in M, psi will NOT
appear in h_content(M) unless H(psi) is also in M. This means P-formulas do NOT
persist through h_content seeds in chain constructions. Symmetric to g_content.
-/
def h_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}

/--
f_content of an MCS: the set of all formulas phi where F phi (some_future phi) appears in the MCS.

This extracts formulas under the existential future operator F.
Used in the Succ relation construction (tasks 10-15) for discrete temporal frames.

**Duality**: f_content relates to g_content via `Fφ = ¬G¬φ`.
See `f_content_iff_not_neg_in_g_content` for the formal relationship.
-/
def f_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_future phi ∈ M}

/--
p_content of an MCS: the set of all formulas phi where P phi (some_past phi) appears in the MCS.

This extracts formulas under the existential past operator P.
Used in the DenseTask relation construction (tasks 16-18) for dense temporal frames.

**Duality**: p_content relates to h_content via `Pφ = ¬H¬φ`.
See `p_content_iff_not_neg_in_h_content` for the formal relationship.
-/
def p_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_past phi ∈ M}

/--
u_content of an MCS: the set of all formula pairs (phi, psi) where `phi U psi` appears in the MCS.

**Usage**: Used in the Succ relation U-step condition (Phase 5) and dovetailed chain
construction (Phase 6). The U-step ensures that for each `(phi U psi) ∈ u`, the
successor v either contains psi (resolved) or contains both phi and `phi U psi` (deferred).
-/
def u_content (M : Set Formula) : Set (Formula × Formula) :=
  { p | Formula.untl p.1 p.2 ∈ M }

/--
s_content of an MCS: the set of all formula pairs (phi, psi) where `phi S psi` appears in the MCS.

**Usage**: Used in the backward Succ relation S-step condition (Phase 5) and dovetailed
chain construction (Phase 6). Symmetric to u_content.
-/
def s_content (M : Set Formula) : Set (Formula × Formula) :=
  { p | Formula.snce p.1 p.2 ∈ M }

/--
x_content of an MCS: the set of all formulas phi where X(phi) = (⊥ U phi) appears in the MCS.

**Usage**: With X-K distribution and X-Det determinism axioms, x_content(M) is itself
an MCS when M is an MCS. This enables the deterministic chain construction where
chain(n+1) = x_content(chain(n)), eliminating the need for Lindenbaum extension.
-/
def x_content (M : Set Formula) : Set Formula :=
  {phi | Formula.untl Formula.bot phi ∈ M}

/--
y_content of an MCS: the set of all formulas phi where Y(phi) = (⊥ S phi) appears in the MCS.

**Usage**: Backward direction dual of x_content. With Y-K distribution and Y-Det
determinism axioms, y_content(M) is itself an MCS when M is an MCS.
-/
def y_content (M : Set Formula) : Set Formula :=
  {phi | Formula.snce Formula.bot phi ∈ M}

/-! ## Membership Lemmas -/

@[simp]
lemma mem_g_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ g_content M ↔ Formula.all_future phi ∈ M := Iff.rfl

@[simp]
lemma mem_h_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ h_content M ↔ Formula.all_past phi ∈ M := Iff.rfl

@[simp]
lemma mem_f_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ f_content M ↔ Formula.some_future phi ∈ M := Iff.rfl

@[simp]
lemma mem_p_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ p_content M ↔ Formula.some_past phi ∈ M := Iff.rfl

@[simp]
lemma mem_x_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ x_content M ↔ Formula.untl Formula.bot phi ∈ M := Iff.rfl

@[simp]
lemma mem_y_content_iff {M : Set Formula} {phi : Formula} :
    phi ∈ y_content M ↔ Formula.snce Formula.bot phi ∈ M := Iff.rfl

@[simp]
lemma mem_u_content_iff {M : Set Formula} {p : Formula × Formula} :
    p ∈ u_content M ↔ Formula.untl p.1 p.2 ∈ M := Iff.rfl

@[simp]
lemma mem_s_content_iff {M : Set Formula} {p : Formula × Formula} :
    p ∈ s_content M ↔ Formula.snce p.1 p.2 ∈ M := Iff.rfl

/-! ## Duality Lemmas -/

open Bimodal.Metalogic.Core in
/--
Duality between f_content and g_content for MCS.

For a set-maximal consistent set M:
  φ ∈ f_content(M) ↔ ¬φ ∉ g_content(M)

This reflects the definitional duality Fφ = ¬G¬φ lifted to content extractors.

**Proof Strategy**:
- Forward: If Fφ ∈ M (i.e., ¬G¬φ ∈ M), then G¬φ ∉ M by MCS consistency
- Backward: If G¬φ ∉ M, then ¬G¬φ ∈ M by negation completeness, so Fφ ∈ M
-/
theorem f_content_iff_not_neg_in_g_content {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (phi : Formula) :
    phi ∈ f_content M ↔ phi.neg ∉ g_content M := by
  simp only [mem_f_content_iff, mem_g_content_iff]
  unfold Formula.some_future
  constructor
  · intro h_neg_G_neg_in
    intro h_G_neg_in
    exact set_consistent_not_both h_mcs.1 (phi.neg.all_future) h_G_neg_in h_neg_G_neg_in
  · intro h_G_neg_not_in
    cases SetMaximalConsistent.negation_complete h_mcs (phi.neg.all_future) with
    | inl h_in => exact absurd h_in h_G_neg_not_in
    | inr h_neg_in => exact h_neg_in

open Bimodal.Metalogic.Core in
/--
Duality between p_content and h_content for MCS.

For a set-maximal consistent set M:
  φ ∈ p_content(M) ↔ ¬φ ∉ h_content(M)

This reflects the definitional duality Pφ = ¬H¬φ lifted to content extractors.
Symmetric to `f_content_iff_not_neg_in_g_content`.
-/
theorem p_content_iff_not_neg_in_h_content {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (phi : Formula) :
    phi ∈ p_content M ↔ phi.neg ∉ h_content M := by
  simp only [mem_p_content_iff, mem_h_content_iff]
  unfold Formula.some_past
  constructor
  · intro h_neg_H_neg_in h_H_neg_in
    exact set_consistent_not_both h_mcs.1 (phi.neg.all_past) h_H_neg_in h_neg_H_neg_in
  · intro h_H_neg_not_in
    cases SetMaximalConsistent.negation_complete h_mcs (phi.neg.all_past) with
    | inl h_in => exact absurd h_in h_H_neg_not_in
    | inr h_neg_in => exact h_neg_in

/-! ## x_content and y_content are MCS -/

open Bimodal.ProofSystem in
/--
X-necessitation: if ⊢ φ then ⊢ X(φ).

Derived from temporal necessitation (⊢ φ implies ⊢ G(φ)) and G_implies_X (⊢ G(φ) → X(φ)).
-/
noncomputable def x_nec {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.untl Formula.bot φ) := by
  have h_G : DerivationTree [] φ.all_future :=
    DerivationTree.temporal_necessitation _ h
  have h_GX := Bimodal.Theorems.TemporalDerived.G_implies_X φ
  exact DerivationTree.modus_ponens [] _ _ h_GX h_G

open Bimodal.ProofSystem in
/--
Y-necessitation: if ⊢ φ then ⊢ Y(φ).

Derived from past temporal necessitation and H_implies_Y.
-/
noncomputable def y_nec {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.snce Formula.bot φ) := by
  have h_H : DerivationTree [] φ.all_past :=
    Bimodal.Theorems.past_necessitation _ h
  have h_HY := Bimodal.Theorems.TemporalDerived.H_implies_Y φ
  exact DerivationTree.modus_ponens [] _ _ h_HY h_H

open Bimodal.ProofSystem Bimodal.Metalogic.Core in
/--
X-lifting lemma: from L ⊢ φ where each X(aᵢ) ∈ M, derive X(φ) ∈ M.

The proof is by induction on L:
- Base: [] ⊢ φ means φ is a theorem, so X(φ) is a theorem (X-nec), hence in M.
- Step: (a :: L') ⊢ φ. By deduction theorem: L' ⊢ a → φ.
  By IH: X(a → φ) ∈ M. By X-K axiom: X(a→φ) → (X(a) → X(φ)) ∈ M.
  With X(a) ∈ M, two applications of implication_property give X(φ) ∈ M.
-/
noncomputable def x_lift_derivation {M : Set Formula}
    (h_mcs : SetMaximalConsistent M)
    (L : List Formula) (φ : Formula)
    (d : DerivationTree L φ)
    (h_L_sub : ∀ a ∈ L, Formula.untl Formula.bot a ∈ M) :
    Formula.untl Formula.bot φ ∈ M := by
  induction L generalizing φ with
  | nil =>
    exact theorem_in_mcs h_mcs (x_nec d)
  | cons a L' ih =>
    have d_imp : DerivationTree L' (a.imp φ) :=
      deduction_theorem L' a φ d
    have h_L'_sub : ∀ b ∈ L', Formula.untl Formula.bot b ∈ M :=
      fun b hb => h_L_sub b (List.mem_cons_of_mem a hb)
    have h_X_imp : Formula.untl Formula.bot (a.imp φ) ∈ M :=
      ih (a.imp φ) d_imp h_L'_sub
    -- X-K axiom: X(a → φ) → (X(a) → X(φ)) is a theorem, hence in M
    have h_xk : (Formula.untl Formula.bot (a.imp φ)).imp
        ((Formula.untl Formula.bot a).imp (Formula.untl Formula.bot φ)) ∈ M :=
      theorem_in_mcs h_mcs (sorry /- x_k_dist removed in BX -/)
    -- X(a) → X(φ) ∈ M by modus ponens
    have h_Xa_imp_Xφ : (Formula.untl Formula.bot a).imp (Formula.untl Formula.bot φ) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs h_xk h_X_imp
    -- X(a) ∈ M
    have h_Xa : Formula.untl Formula.bot a ∈ M :=
      h_L_sub a (by simp)
    -- X(φ) ∈ M
    exact SetMaximalConsistent.implication_property h_mcs h_Xa_imp_Xφ h_Xa

open Bimodal.ProofSystem Bimodal.Metalogic.Core in
/--
Y-lifting lemma: dual of x_lift_derivation using Y-K distribution.
-/
noncomputable def y_lift_derivation {M : Set Formula}
    (h_mcs : SetMaximalConsistent M)
    (L : List Formula) (φ : Formula)
    (d : DerivationTree L φ)
    (h_L_sub : ∀ a ∈ L, Formula.snce Formula.bot a ∈ M) :
    Formula.snce Formula.bot φ ∈ M := by
  induction L generalizing φ with
  | nil =>
    exact theorem_in_mcs h_mcs (y_nec d)
  | cons a L' ih =>
    have d_imp : DerivationTree L' (a.imp φ) :=
      deduction_theorem L' a φ d
    have h_L'_sub : ∀ b ∈ L', Formula.snce Formula.bot b ∈ M :=
      fun b hb => h_L_sub b (List.mem_cons_of_mem a hb)
    have h_Y_imp : Formula.snce Formula.bot (a.imp φ) ∈ M :=
      ih (a.imp φ) d_imp h_L'_sub
    have h_yk : (Formula.snce Formula.bot (a.imp φ)).imp
        ((Formula.snce Formula.bot a).imp (Formula.snce Formula.bot φ)) ∈ M :=
      theorem_in_mcs h_mcs (sorry /- y_k_dist removed in BX -/)
    have h_Ya_imp_Yφ : (Formula.snce Formula.bot a).imp (Formula.snce Formula.bot φ) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs h_yk h_Y_imp
    have h_Ya : Formula.snce Formula.bot a ∈ M :=
      h_L_sub a (by simp)
    exact SetMaximalConsistent.implication_property h_mcs h_Ya_imp_Yφ h_Ya

open Bimodal.ProofSystem Bimodal.Metalogic.Core in
/--
x_content(M) is set-consistent when M is a set-maximal consistent set.

If L ⊆ x_content(M) and L ⊢ ⊥, then by x_lift_derivation, X(⊥) ∈ M.
But ⊢ ¬X(⊥) (X_bot_absurd), so ¬X(⊥) ∈ M, contradicting M's consistency.
-/
private noncomputable def x_content_set_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) : SetConsistent (x_content M) := by
  intro L h_L_sub ⟨d_bot⟩
  have h_X_sub : ∀ a ∈ L, Formula.untl Formula.bot a ∈ M :=
    fun a ha => (h_L_sub a ha : a ∈ x_content M)
  have h_Xbot : Formula.untl Formula.bot Formula.bot ∈ M :=
    x_lift_derivation h_mcs L Formula.bot d_bot h_X_sub
  have h_neg_Xbot : (Formula.untl Formula.bot Formula.bot).neg ∈ M :=
    theorem_in_mcs h_mcs Bimodal.Theorems.TemporalDerived.X_bot_absurd
  exact set_consistent_not_both h_mcs.1 (Formula.untl Formula.bot Formula.bot)
    h_Xbot h_neg_Xbot

open Bimodal.ProofSystem Bimodal.Metalogic.Core in
/--
x_content(M) is maximal: for any φ ∉ x_content(M), insert φ (x_content M) is inconsistent.

Since φ ∉ x_content(M) means X(φ) ∉ M, by MCS negation completeness ¬X(φ) ∈ M.
By X-Det axiom: ¬X(φ) → X(¬φ), so X(¬φ) ∈ M, hence ¬φ ∈ x_content(M).
Then [φ, ¬φ] ⊆ insert φ (x_content M) and [φ, ¬φ] ⊢ ⊥, so the set is inconsistent.
-/
private noncomputable def x_content_maximal {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) :
    ∀ φ : Formula, φ ∉ x_content M → ¬SetConsistent (insert φ (x_content M)) := by
  intro φ h_not_in h_cons
  have h_Xφ_not_in : Formula.untl Formula.bot φ ∉ M := h_not_in
  have h_neg_Xφ : (Formula.untl Formula.bot φ).neg ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.untl Formula.bot φ) with
    | inl h => exact absurd h h_Xφ_not_in
    | inr h => exact h
  have h_xdet : (Formula.untl Formula.bot φ).neg.imp
      (Formula.untl Formula.bot φ.neg) ∈ M :=
    theorem_in_mcs h_mcs (sorry /- x_det removed in BX -/)
  have h_X_neg : Formula.untl Formula.bot φ.neg ∈ M :=
    SetMaximalConsistent.implication_property h_mcs h_xdet h_neg_Xφ
  have h_neg_in_xc : φ.neg ∈ x_content M := h_X_neg
  have h_sub : ∀ ψ ∈ [φ, φ.neg], ψ ∈ insert φ (x_content M) := by
    intro ψ hψ
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
    rcases hψ with rfl | rfl
    · exact Set.mem_insert _ _
    · exact Set.mem_insert_of_mem _ h_neg_in_xc
  have h_derives_bot : Nonempty (DerivationTree [φ, φ.neg] Formula.bot) :=
    ⟨derives_bot_from_phi_neg_phi
      (DerivationTree.assumption _ φ (by simp))
      (DerivationTree.assumption _ φ.neg (by simp))⟩
  exact h_cons [φ, φ.neg] h_sub h_derives_bot

open Bimodal.Metalogic.Core in
/--
x_content(M) is a set-maximal consistent set when M is.

With X-K distribution and X-Det determinism axioms:
- **Consistency**: If x_content(M) were inconsistent, X(⊥) ∈ M, contradicting ¬X(⊥) ∈ M.
- **Maximality**: For φ ∉ x_content(M), X(φ) ∉ M, so ¬X(φ) ∈ M by MCS. By X-Det,
  X(¬φ) ∈ M, so ¬φ ∈ x_content(M). Then {φ, ¬φ} ⊆ insert φ (x_content M) is inconsistent.
-/
theorem x_content_mcs {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) : SetMaximalConsistent (x_content M) :=
  ⟨x_content_set_consistent h_mcs, x_content_maximal h_mcs⟩

open Bimodal.ProofSystem Bimodal.Metalogic.Core in
/--
y_content(M) is set-consistent when M is a set-maximal consistent set.

Symmetric to x_content_set_consistent, using Y-K + Y_bot_absurd.
-/
private noncomputable def y_content_set_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) : SetConsistent (y_content M) := by
  intro L h_L_sub ⟨d_bot⟩
  have h_Y_sub : ∀ a ∈ L, Formula.snce Formula.bot a ∈ M :=
    fun a ha => (h_L_sub a ha : a ∈ y_content M)
  have h_Ybot : Formula.snce Formula.bot Formula.bot ∈ M :=
    y_lift_derivation h_mcs L Formula.bot d_bot h_Y_sub
  have h_neg_Ybot : (Formula.snce Formula.bot Formula.bot).neg ∈ M :=
    theorem_in_mcs h_mcs Bimodal.Theorems.TemporalDerived.Y_bot_absurd
  exact set_consistent_not_both h_mcs.1 (Formula.snce Formula.bot Formula.bot)
    h_Ybot h_neg_Ybot

open Bimodal.ProofSystem Bimodal.Metalogic.Core in
/--
y_content(M) is maximal: for any φ ∉ y_content(M), insert φ (y_content M) is inconsistent.

Symmetric to x_content_maximal, using Y-Det.
-/
private noncomputable def y_content_maximal {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) :
    ∀ φ : Formula, φ ∉ y_content M → ¬SetConsistent (insert φ (y_content M)) := by
  intro φ h_not_in h_cons
  have h_Yφ_not_in : Formula.snce Formula.bot φ ∉ M := h_not_in
  have h_neg_Yφ : (Formula.snce Formula.bot φ).neg ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.snce Formula.bot φ) with
    | inl h => exact absurd h h_Yφ_not_in
    | inr h => exact h
  have h_ydet : (Formula.snce Formula.bot φ).neg.imp
      (Formula.snce Formula.bot φ.neg) ∈ M :=
    theorem_in_mcs h_mcs (sorry /- y_det removed in BX -/)
  have h_Y_neg : Formula.snce Formula.bot φ.neg ∈ M :=
    SetMaximalConsistent.implication_property h_mcs h_ydet h_neg_Yφ
  have h_neg_in_yc : φ.neg ∈ y_content M := h_Y_neg
  have h_sub : ∀ ψ ∈ [φ, φ.neg], ψ ∈ insert φ (y_content M) := by
    intro ψ hψ
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
    rcases hψ with rfl | rfl
    · exact Set.mem_insert _ _
    · exact Set.mem_insert_of_mem _ h_neg_in_yc
  have h_derives_bot : Nonempty (DerivationTree [φ, φ.neg] Formula.bot) :=
    ⟨derives_bot_from_phi_neg_phi
      (DerivationTree.assumption _ φ (by simp))
      (DerivationTree.assumption _ φ.neg (by simp))⟩
  exact h_cons [φ, φ.neg] h_sub h_derives_bot

open Bimodal.Metalogic.Core in
/--
y_content(M) is a set-maximal consistent set when M is.

Symmetric to x_content_mcs, using Y-K distribution and Y-Det determinism axioms.
-/
theorem y_content_mcs {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) : SetMaximalConsistent (y_content M) :=
  ⟨y_content_set_consistent h_mcs, y_content_maximal h_mcs⟩

end Bimodal.Metalogic.Bundle
