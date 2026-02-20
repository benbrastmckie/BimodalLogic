import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Propositional

/-!
# Modal Saturation for BMCS

This module implements modal saturation for Bundle of Maximal Consistent Sets (BMCS),
enabling the elimination of the `modal_backward` sorry in Construction.lean.

## Overview

A **modally saturated** BMCS satisfies the property that every Diamond formula that
is true in some family has a witness family where the inner formula is true. This
enables proving `modal_backward` by contraposition:

1. Suppose phi is in ALL families' MCS at time t, but Box phi is not in fam.mcs t
2. By MCS negation completeness: (Box phi).neg = Diamond (neg phi) is in fam.mcs t
3. By modal saturation: exists witness family fam' where (neg phi) is in fam'.mcs t
4. But phi is in ALL families, including fam' - contradiction

## Main Definitions

- `is_modally_saturated`: Predicate for modal saturation of a BMCS
- `saturated_modal_backward`: Proves modal_backward for saturated BMCS
- `SaturatedBMCS`: A BMCS bundled with saturation proof

## Design Notes

The key insight is that modal saturation is a SUFFICIENT condition for modal_backward.
Rather than constructing a saturated BMCS from scratch, we define the saturation
predicate and prove that any BMCS satisfying it has the modal_backward property.

## References

- Research report: specs/827_complete_multi_family_bmcs_construction/reports/research-001.md
- Implementation plan: specs/827_complete_multi_family_bmcs_construction/plans/implementation-001.md
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Phase 1: Saturation Predicate and Supporting Infrastructure
-/

/--
Diamond formula: neg (Box (neg phi)).

This is the modal possibility operator: Diamond phi means "possibly phi",
i.e., there exists an accessible world where phi holds.

In our BMCS construction, Diamond phi in fam.mcs t means there should exist
a family fam' where phi is in fam'.mcs t.
-/
def diamondFormula (phi : Formula) : Formula := phi.diamond

/--
Check if a formula is of the form Diamond psi (= neg (Box (neg psi))).

Returns the inner formula psi if it is a Diamond formula, or none otherwise.
-/
def asDiamond : Formula → Option Formula
  | .imp (.box (.imp inner .bot)) .bot => some inner
  | _ => none

/--
A Diamond formula in a family's MCS needs a witness if no other family
in the BMCS contains the inner formula in its MCS at that time.

Specifically: needs_modal_witness B fam t psi means:
- Diamond psi is in fam.mcs t
- There is no family fam' in B.families where psi is in fam'.mcs t
-/
def needs_modal_witness (B : BMCS D) (fam : BFMCS D) (t : D) (psi : Formula) : Prop :=
  diamondFormula psi ∈ fam.mcs t ∧ ∀ fam' ∈ B.families, psi ∉ fam'.mcs t

/--
A BMCS is modally saturated if every Diamond formula that is true in some
family's MCS has a witness family in the bundle.

Formally: for every family fam, time t, and formula psi,
if Diamond psi is in fam.mcs t, then there exists fam' in families
where psi is in fam'.mcs t.
-/
def is_modally_saturated (B : BMCS D) : Prop :=
  ∀ fam ∈ B.families, ∀ t : D, ∀ psi : Formula,
    diamondFormula psi ∈ fam.mcs t → ∃ fam' ∈ B.families, psi ∈ fam'.mcs t

/--
Alternative formulation: a BMCS is modally saturated iff no Diamond formula
needs a witness.
-/
theorem is_modally_saturated_iff_no_needs_witness (B : BMCS D) :
    is_modally_saturated B ↔ ∀ fam ∈ B.families, ∀ t : D, ∀ psi : Formula,
      ¬needs_modal_witness B fam t psi := by
  constructor
  · intro h_sat fam hfam t psi ⟨h_diamond, h_no_witness⟩
    have ⟨fam', hfam', hpsi⟩ := h_sat fam hfam t psi h_diamond
    exact h_no_witness fam' hfam' hpsi
  · intro h_no_needs fam hfam t psi h_diamond
    by_contra h_no_witness
    push_neg at h_no_witness
    exact h_no_needs fam hfam t psi ⟨h_diamond, h_no_witness⟩

/-!
## Diamond Formula Properties

These lemmas connect Diamond formulas with MCS properties.
-/

/--
The Diamond formula unfolds to: neg (Box (neg phi)).
-/
lemma diamondFormula_eq (phi : Formula) :
    diamondFormula phi = Formula.neg (Formula.box (Formula.neg phi)) := rfl

/--
If Diamond psi is in an MCS, then Box (neg psi) is not in that MCS.

This follows from MCS consistency: Diamond psi = neg (Box (neg psi)),
so having both would violate consistency.
-/
lemma diamond_excludes_box_neg {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ S) :
    Formula.box (Formula.neg psi) ∉ S := by
  intro h_box
  have h_eq : diamondFormula psi = Formula.neg (Formula.box (Formula.neg psi)) := rfl
  rw [h_eq] at h_diamond
  exact set_consistent_not_both h_mcs.1 (Formula.box (Formula.neg psi)) h_box h_diamond

/--
If Diamond psi is in an MCS and psi is not in that MCS, then neg psi is in the MCS.

This is by MCS negation completeness.
-/
lemma diamond_and_not_psi_implies_neg {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ S) (h_not_psi : psi ∉ S) :
    Formula.neg psi ∈ S := by
  rcases set_mcs_negation_complete h_mcs psi with h_psi | h_neg
  · exact absurd h_psi h_not_psi
  · exact h_neg

/-!
## MCS Existence for Consistent Formulas

We need to show that if Diamond psi is in an MCS, then psi is consistent
(can be extended to an MCS).
-/

/--
If Diamond psi is in a SetMaximalConsistent S, then psi is set-consistent
(i.e., {psi} is consistent).

**Proof Sketch**:
If {psi} is inconsistent, then psi derives bot, so neg psi is a theorem.
Then Box (neg psi) is a theorem (by necessitation). Then Box (neg psi)
is in S (theorems are in MCS). But Diamond psi = neg (Box (neg psi)) is
in S, contradicting consistency.
-/
lemma diamond_implies_psi_consistent {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ S) :
    SetConsistent {psi} := by
  intro L hL ⟨d⟩
  by_cases h_psi_in_L : psi ∈ L
  · -- Derive [psi] ⊢ ⊥ by weakening
    have h_weak : ∀ x ∈ L, x ∈ [psi] := by
      intro x hx
      have := hL x hx
      simp only [Set.mem_singleton_iff] at this
      simp [this]
    have d_psi : DerivationTree [psi] Formula.bot :=
      DerivationTree.weakening L [psi] _ d h_weak
    -- By deduction theorem: ⊢ psi → ⊥ = ⊢ neg psi
    have d_neg : DerivationTree [] (Formula.neg psi) :=
      Bimodal.Metalogic.Core.deduction_theorem [] psi Formula.bot d_psi
    -- By necessitation: ⊢ Box (neg psi)
    have d_box : DerivationTree [] (Formula.box (Formula.neg psi)) :=
      DerivationTree.necessitation (Formula.neg psi) d_neg
    -- Box (neg psi) is in S since it's a theorem
    have h_box_in_S : Formula.box (Formula.neg psi) ∈ S := theorem_in_mcs h_mcs d_box
    -- But Diamond psi = neg (Box (neg psi)) is also in S
    have h_eq : diamondFormula psi = Formula.neg (Formula.box (Formula.neg psi)) := rfl
    rw [h_eq] at h_diamond
    -- Contradiction with consistency
    exact set_consistent_not_both h_mcs.1 _ h_box_in_S h_diamond
  · -- psi ∉ L, so L ⊆ {psi} means L = []
    have h_L_empty : L = [] := by
      cases L with
      | nil => rfl
      | cons x xs =>
        exfalso
        have hx := hL x List.mem_cons_self
        simp only [Set.mem_singleton_iff] at hx
        rw [hx] at h_psi_in_L
        exact h_psi_in_L List.mem_cons_self
    -- [] ⊢ ⊥ means bot is a theorem
    rw [h_L_empty] at d
    have h_bot_in_S : Formula.bot ∈ S := theorem_in_mcs h_mcs d
    have h_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
    have h_sub : ∀ x ∈ [Formula.bot], x ∈ S := by simp [h_bot_in_S]
    exact h_mcs.1 [Formula.bot] h_sub ⟨h_deriv⟩

/-!
## Phase 2: Witness Family Construction

We construct witness families for Diamond formulas that need witnesses.
The key insight is that if Diamond psi is in an MCS, then psi is consistent
and can be extended to an MCS via Lindenbaum's lemma.
-/

/--
Extend a consistent singleton to an MCS using Lindenbaum's lemma.

Given that {psi} is consistent, we can extend it to a maximal consistent set.
-/
noncomputable def extendToMCS (psi : Formula) (h_cons : SetConsistent {psi}) :
    Set Formula :=
  Classical.choose (set_lindenbaum {psi} h_cons)

/--
The extended MCS contains psi.
-/
lemma extendToMCS_contains (psi : Formula) (h_cons : SetConsistent {psi}) :
    psi ∈ extendToMCS psi h_cons :=
  (Classical.choose_spec (set_lindenbaum {psi} h_cons)).1 (Set.mem_singleton psi)

/--
The extended set is a maximal consistent set.
-/
lemma extendToMCS_is_mcs (psi : Formula) (h_cons : SetConsistent {psi}) :
    SetMaximalConsistent (extendToMCS psi h_cons) :=
  (Classical.choose_spec (set_lindenbaum {psi} h_cons)).2

/--
Construct a constant witness family from an MCS.

Given an MCS M, we build an BFMCS that assigns M to every time point.
This is similar to constantBFMCS from Construction.lean.
-/
noncomputable def constantWitnessFamily (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    BFMCS D where
  mcs := fun _ => M
  is_mcs := fun _ => h_mcs
  forward_G := fun t t' phi _ hG =>
    let h_T := DerivationTree.axiom []
      (phi.all_future.imp phi) (Axiom.temp_t_future phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hG
  backward_H := fun t t' phi _ hH =>
    let h_T := DerivationTree.axiom []
      (phi.all_past.imp phi) (Axiom.temp_t_past phi)
    let h_T_in_M := theorem_in_mcs h_mcs h_T
    set_mcs_implication_property h_mcs h_T_in_M hH

/--
The MCS at any time in a constant witness family is the original MCS.
-/
lemma constantWitnessFamily_mcs_eq (M : Set Formula) (h_mcs : SetMaximalConsistent M) (t : D) :
    (constantWitnessFamily M h_mcs (D := D)).mcs t = M := rfl

/--
Construct a witness family for a formula.

Given that {psi} is consistent, this constructs a new BFMCS
where psi is in the MCS at all times.
-/
noncomputable def constructWitnessFamily (psi : Formula) (h_cons : SetConsistent {psi}) :
    BFMCS D :=
  let M := extendToMCS psi h_cons
  let h_mcs := extendToMCS_is_mcs psi h_cons
  constantWitnessFamily M h_mcs

/--
The witness family contains psi in its MCS at all times.
-/
lemma constructWitnessFamily_contains (psi : Formula) (h_cons : SetConsistent {psi}) (t : D) :
    psi ∈ (constructWitnessFamily psi h_cons (D := D)).mcs t := by
  simp only [constructWitnessFamily, constantWitnessFamily_mcs_eq]
  exact extendToMCS_contains psi h_cons

/-!
## Phase 3: Helper Lemmas for Modal Backward Proof

We need to establish the connection between neg(Box phi) and Diamond(neg phi).
-/

/--
Double negation elimination theorem: ⊢ ¬¬φ → φ

This is derived using Peirce's law and Ex Falso.
-/
noncomputable def dne_theorem (phi : Formula) : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi :=
  Bimodal.Theorems.Propositional.double_negation phi

/--
Double negation introduction: ⊢ φ → ¬¬φ

Proof: Assume φ, assume ¬φ, apply to get ⊥.
So ⊢ φ → (¬φ → ⊥) = φ → ¬¬φ.
-/
noncomputable def dni_theorem (phi : Formula) : [] ⊢ phi.imp (Formula.neg (Formula.neg phi)) := by
  -- φ → ¬¬φ = φ → ((φ → ⊥) → ⊥)
  -- Using deduction theorem approach:
  -- We need: [(φ → ⊥), φ] ⊢ ⊥ (note: deduction_theorem expects added formula at head)
  -- Then apply deduction_theorem for (φ → ⊥): [φ] ⊢ (φ → ⊥) → ⊥
  -- Then apply deduction_theorem for φ: [] ⊢ φ → ((φ → ⊥) → ⊥)

  have h1 : [phi.imp Formula.bot, phi] ⊢ phi :=
    DerivationTree.assumption _ phi (by simp)
  have h2 : [phi.imp Formula.bot, phi] ⊢ phi.imp Formula.bot :=
    DerivationTree.assumption _ (phi.imp Formula.bot) (by simp)
  have h3 : [phi.imp Formula.bot, phi] ⊢ Formula.bot :=
    DerivationTree.modus_ponens _ phi Formula.bot h2 h1
  -- Deduction theorem: [φ] ⊢ (φ → ⊥) → ⊥
  have h4 : [phi] ⊢ (phi.imp Formula.bot).imp Formula.bot :=
    Bimodal.Metalogic.Core.deduction_theorem [phi] (phi.imp Formula.bot) Formula.bot h3
  -- Deduction theorem again: [] ⊢ φ → ((φ → ⊥) → ⊥)
  exact Bimodal.Metalogic.Core.deduction_theorem [] phi ((phi.imp Formula.bot).imp Formula.bot) h4

/--
Box distributes over double negation elimination: ⊢ Box(¬¬φ) → Box φ

Proof: By necessitation on DNE and modal K distribution.
-/
noncomputable def box_dne_theorem (phi : Formula) :
    [] ⊢ (Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi) := by
  -- Step 1: ⊢ ¬¬φ → φ (DNE)
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
  -- Step 2: ⊢ Box(¬¬φ → φ) (necessitation)
  have h_box_dne : [] ⊢ Formula.box ((Formula.neg (Formula.neg phi)).imp phi) :=
    DerivationTree.necessitation _ h_dne
  -- Step 3: ⊢ Box(¬¬φ → φ) → (Box(¬¬φ) → Box φ) (K distribution axiom)
  have h_K : [] ⊢ (Formula.box ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi)) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist _ _)
  -- Step 4: ⊢ Box(¬¬φ) → Box φ (modus ponens)
  exact DerivationTree.modus_ponens [] _ _ h_K h_box_dne

/--
Contraposition helper: if ⊢ A → B and B → ⊥ ∈ S, then A → ⊥ ∈ S (for MCS S).

This is used to transfer implications contrapositively through MCS membership.
-/
lemma mcs_contrapositive {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    {A B : Formula} (h_impl : [] ⊢ A.imp B) (h_negB : B.neg ∈ S) : A.neg ∈ S := by
  -- We have ⊢ A → B and ¬B ∈ S
  -- We want ¬A ∈ S, i.e., (A → ⊥) ∈ S

  -- From ⊢ A → B, we can derive ⊢ ¬B → ¬A
  -- This is: (B → ⊥) → (A → ⊥)

  -- Proof: Assume ¬B (i.e., B → ⊥). Assume A. Then B by A → B. Then ⊥ by B → ⊥.
  -- Context: A :: [B.neg] = [A, B.neg] (deduction_theorem expects formula at head)
  -- Then by deduction for A: [B.neg] ⊢ A → ⊥ = A.neg
  -- Then by deduction for B.neg: [] ⊢ B.neg → A.neg

  have h1 : [A, B.neg] ⊢ A :=
    DerivationTree.assumption _ A (by simp)
  have h2 : [A, B.neg] ⊢ A.imp B :=
    DerivationTree.weakening [] _ _ h_impl (by intro x hx; exact False.elim (List.not_mem_nil hx))
  have h3 : [A, B.neg] ⊢ B :=
    DerivationTree.modus_ponens _ A B h2 h1
  have h4 : [A, B.neg] ⊢ B.neg :=
    DerivationTree.assumption _ B.neg (by simp)
  have h5 : [A, B.neg] ⊢ Formula.bot :=
    DerivationTree.modus_ponens _ B Formula.bot h4 h3
  have h6 : [B.neg] ⊢ A.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [B.neg] A Formula.bot h5
  have h7 : [] ⊢ B.neg.imp A.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] B.neg A.neg h6

  -- Now ⊢ ¬B → ¬A is in S (as a theorem)
  have h_thm_in_S : B.neg.imp A.neg ∈ S := theorem_in_mcs h_mcs h7

  -- And ¬B ∈ S, so ¬A ∈ S by MCS implication property
  exact set_mcs_implication_property h_mcs h_thm_in_S h_negB

/-!
## Phase 4: Modal Backward from Saturation

The key theorem: if a BMCS is modally saturated, then modal_backward holds.
This is proven by contraposition using MCS negation completeness.
-/

/--
**Key Theorem**: Modal backward holds for saturated BMCS.

If a BMCS is modally saturated, then for any family fam, time t, and formula phi:
if phi is in ALL families' MCS at time t, then Box phi is in fam.mcs t.

**Proof by Contraposition**:
1. Assume phi is in all families but Box phi is NOT in fam.mcs t
2. By MCS negation completeness: neg(Box phi) is in fam.mcs t
3. Use box_dne_theorem to show: neg(Box phi) implies neg(Box(neg neg phi)) = Diamond(neg phi)
4. By modal saturation: exists fam' where neg phi is in fam'.mcs t
5. But phi is in ALL families including fam' - contradiction with consistency
-/
theorem saturated_modal_backward (B : BMCS D) (h_sat : is_modally_saturated B)
    (fam : BFMCS D) (hfam : fam ∈ B.families) (phi : Formula) (t : D)
    (h_all : ∀ fam' ∈ B.families, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t := by
  -- By contradiction
  by_contra h_not_box

  -- By MCS negation completeness, neg(Box phi) is in fam.mcs t
  have h_mcs := fam.is_mcs t
  have h_neg_box : Formula.neg (Formula.box phi) ∈ fam.mcs t := by
    rcases set_mcs_negation_complete h_mcs (Formula.box phi) with h_box | h_neg
    · exact absurd h_box h_not_box
    · exact h_neg

  -- We have: ⊢ Box(¬¬φ) → Box φ (from box_dne_theorem)
  -- Contrapositive: neg(Box phi) → neg(Box(neg neg phi)) in MCS

  -- neg(Box(neg neg phi)) = Diamond(neg phi) by definition
  -- So we get Diamond(neg phi) in fam.mcs t

  have h_box_dne := box_dne_theorem phi
  have h_diamond_neg : Formula.neg (Formula.box (Formula.neg (Formula.neg phi))) ∈ fam.mcs t :=
    mcs_contrapositive h_mcs h_box_dne h_neg_box

  -- Diamond(neg phi) = neg(Box(neg(neg phi))) by definition
  have h_eq_diamond : diamondFormula (Formula.neg phi) =
                      Formula.neg (Formula.box (Formula.neg (Formula.neg phi))) := rfl

  have h_diamond_in : diamondFormula (Formula.neg phi) ∈ fam.mcs t := by
    rw [h_eq_diamond]
    exact h_diamond_neg

  -- By modal saturation, exists witness where neg phi is in MCS
  have ⟨fam', hfam', h_neg_phi_in⟩ := h_sat fam hfam t (Formula.neg phi) h_diamond_in

  -- But phi is in ALL families including fam'
  have h_phi_in := h_all fam' hfam'

  -- neg phi and phi both in fam'.mcs t contradicts consistency
  exact set_consistent_not_both (fam'.is_mcs t).1 phi h_phi_in h_neg_phi_in

/-!
## Phase 5: Saturated BMCS Structure

A SaturatedBMCS bundles a BMCS with proof of saturation and the derived modal_backward.
-/

/--
A saturated BMCS is a BMCS together with a proof that it is modally saturated.

This structure is useful because we can derive modal_backward from saturation.
-/
structure SaturatedBMCS (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- The underlying BMCS -/
  bmcs : BMCS D
  /-- Proof of modal saturation -/
  saturated : is_modally_saturated bmcs

/--
A saturated BMCS satisfies modal_backward.
-/
theorem SaturatedBMCS.modal_backward (S : SaturatedBMCS D)
    (fam : BFMCS D) (hfam : fam ∈ S.bmcs.families) (phi : Formula) (t : D)
    (h_all : ∀ fam' ∈ S.bmcs.families, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t :=
  saturated_modal_backward S.bmcs S.saturated fam hfam phi t h_all

/-!
## Axiom 5 (Negative Introspection) Derivation

This section derives negative introspection from the modal_5_collapse axiom via contraposition.
Negative introspection is required for the BoxContent preservation lemma in SaturatedConstruction.
-/

/--
Modal 5 collapse axiom instance: `⊢ ◇□φ → □φ`.

This is a wrapper around the axiom for convenience.
-/
noncomputable def modal_5_collapse_theorem (phi : Formula) :
    [] ⊢ Formula.box phi |>.diamond.imp (Formula.box phi) :=
  DerivationTree.axiom [] _ (Axiom.modal_5_collapse phi)

/--
Axiom 5 (Negative Introspection): `⊢ ¬□φ → □¬□φ`.

This derives negative introspection from modal_5_collapse via contraposition.

**Proof**:
1. `modal_5_collapse` gives `⊢ ◇□φ → □φ`
2. By contraposition: `⊢ ¬□φ → ¬◇□φ`
3. `¬◇□φ = ¬(¬□(¬□φ)) = □(¬□φ)` by definition and double negation
4. Therefore: `⊢ ¬□φ → □(¬□φ)`

The key observation is that `¬◇A = □¬A` (necessity of the negation equals
negation of possibility).
-/
noncomputable def axiom_5_negative_introspection (phi : Formula) :
    [] ⊢ (Formula.box phi).neg.imp (Formula.box (Formula.box phi).neg) := by
  -- Step 1: modal_5_collapse gives ◇□φ → □φ
  have h_collapse : [] ⊢ (Formula.box phi).diamond.imp (Formula.box phi) :=
    modal_5_collapse_theorem phi
  -- Step 2: By contraposition: ¬□φ → ¬◇□φ
  have h_contra : [] ⊢ (Formula.box phi).neg.imp (Formula.box phi).diamond.neg :=
    Bimodal.Theorems.Propositional.contraposition h_collapse
  -- Step 3: ¬◇□φ = □¬□φ by definition
  -- ◇A = ¬□¬A, so ¬◇A = ¬¬□¬A
  -- ¬◇□φ = ¬¬□(¬□φ) = □(¬□φ) (by double negation)
  --
  -- But Formula.diamond unfolds as: phi.diamond = phi.neg.box.neg
  -- So (Formula.box phi).diamond = (Formula.box phi).neg.box.neg
  -- Therefore (Formula.box phi).diamond.neg = ((Formula.box phi).neg.box.neg).neg
  --                                         = (Formula.box phi).neg.box (by DNE)
  --
  -- We need to show (Formula.box phi).diamond.neg equals Formula.box (Formula.box phi).neg
  -- This requires applying double negation elimination.
  --
  -- Expand the diamond:
  -- (Formula.box phi).diamond = (Formula.box phi).neg.box.neg
  -- So (Formula.box phi).diamond.neg = (Formula.box phi).neg.box.neg.neg
  --
  -- We have h_contra : ¬□φ → ((□φ).neg.box.neg).neg
  -- We need: ¬□φ → (□φ).neg.box
  --
  -- The gap: ((□φ).neg.box.neg).neg vs (□φ).neg.box
  -- These are syntactically different but semantically equivalent (double negation)

  -- Use double negation elimination to convert ¬¬□(¬□φ) to □(¬□φ)
  -- h_contra has conclusion: (Formula.box phi).diamond.neg
  --                        = ((Formula.box phi).neg.box.neg).neg  (expanding diamond)
  --
  -- Goal is: (Formula.box phi).neg.imp (Formula.box (Formula.box phi).neg)
  --        = (Formula.box phi).neg.imp ((Formula.box phi).neg.box)

  -- The diamond of A is: A.neg.box.neg (¬□¬A)
  -- So (Formula.box phi).diamond = (Formula.box phi).neg.box.neg

  -- The conclusion of h_contra is:
  -- ((Formula.box phi).neg.box.neg).neg = (Formula.box phi).neg.box.neg.neg

  -- We need to prove: (Formula.box phi).neg.box

  -- Use DNE: ¬¬B → B where B = (Formula.box phi).neg.box

  have h_dne : [] ⊢ ((Formula.box phi).neg.box.neg.neg).imp ((Formula.box phi).neg.box) :=
    Bimodal.Theorems.Propositional.double_negation ((Formula.box phi).neg.box)

  -- Now compose: ¬□φ → ¬¬□¬□φ → □¬□φ
  -- h_contra : ¬□φ → (diamond □φ).neg = ¬□φ → (¬□(¬□φ)).neg = ¬□φ → ¬¬□¬□φ
  -- h_dne : ¬¬□¬□φ → □¬□φ

  -- Check the types align:
  -- h_contra : (Formula.box phi).neg.imp (Formula.box phi).diamond.neg
  -- (Formula.box phi).diamond.neg = ((Formula.box phi).neg.box.neg).neg
  --                               = (Formula.box phi).neg.box.neg.neg

  -- So h_contra : (Formula.box phi).neg.imp ((Formula.box phi).neg.box.neg.neg)
  -- And h_dne : (Formula.box phi).neg.box.neg.neg.imp ((Formula.box phi).neg.box)

  -- We need: (Formula.box phi).neg.imp ((Formula.box phi).neg.box)

  -- Use imp_trans to compose them
  have h_result : [] ⊢ (Formula.box phi).neg.imp ((Formula.box phi).neg.box) := by
    -- First verify h_contra has the right form
    have h_contra_expanded :
      (Formula.box phi).diamond.neg = (Formula.box phi).neg.box.neg.neg := rfl
    rw [h_contra_expanded] at h_contra
    -- Now h_contra : (Formula.box phi).neg.imp ((Formula.box phi).neg.box.neg.neg)

    -- Compose with DNE using imp_trans
    exact Bimodal.Theorems.Combinators.imp_trans h_contra h_dne

  exact h_result

/--
Alternative name for axiom 5: `neg_box_to_box_neg_box`.

This is the form needed for BoxContent preservation: if ¬□φ is true at a world,
then □(¬□φ) is also true at that world (negative introspection).
-/
noncomputable def neg_box_to_box_neg_box (phi : Formula) :
    [] ⊢ (Formula.box phi).neg.imp (Formula.box (Formula.box phi).neg) :=
  axiom_5_negative_introspection phi

/--
If ¬□φ is in an MCS, then □(¬□φ) is also in that MCS.

This follows from axiom 5 and deductive closure of MCS.
-/
lemma mcs_neg_box_implies_box_neg_box {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (phi : Formula) (h_neg_box : (Formula.box phi).neg ∈ S) :
    Formula.box (Formula.box phi).neg ∈ S := by
  have h_ax5 := neg_box_to_box_neg_box phi
  have h_ax5_in := theorem_in_mcs h_mcs h_ax5
  exact set_mcs_implication_property h_mcs h_ax5_in h_neg_box

end Bimodal.Metalogic.Bundle
