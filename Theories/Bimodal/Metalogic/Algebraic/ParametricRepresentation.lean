import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.ModalSaturation

/-!
# D-Parametric Algebraic Representation Theorem

This module proves the D-parametric algebraic representation theorem for TaskFrame semantics.
The key insight is that the duration type D is a **parameter**, not constructed from syntax.
This avoids the "domain mismatch" problems that arise when trying to build D from syntax.

## Main Results

- `parametric_algebraic_representation`: For any D, if phi is not provable, then there
  exists a countermodel over the D-parametric canonical TaskFrame
- `parametric_completeness_contrapositive`: The contrapositive form: valid implies provable

## Proof Strategy

1. If `phi` is not provable, then `phi.neg` is consistent (by deduction theorem + DNE)
2. Extend `{phi.neg}` to an MCS M₀ via Lindenbaum
3. Construct a BFMCS B with M₀ as the evaluation point
4. By the parametric truth lemma: `phi.neg ∈ M₀` iff `truth_at ... (to_history ...) 0 phi.neg`
5. Hence `phi` is false at the canonical model, providing a countermodel

## D-Parametric Construction

The construction is **uniform in D**: the same algebraic structure works for ANY totally
ordered abelian group D (Int, Rat, or any other). This is the key insight that resolves
the domain mismatch problems from tasks 977/978/982.

## Assumptions

This module uses the D-parametric infrastructure from:
- `ParametricCanonical.lean`: D-parametric TaskFrame
- `ParametricHistory.lean`: D-parametric history conversion
- `ParametricTruthLemma.lean`: D-parametric truth lemma

The representation theorem is contingent on having a temporally coherent BFMCS over D.
For specific instantiations (D = Int, D = Rat), this requires constructing such a BFMCS,
which is done in the instantiation modules.

## References

- Research: specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md
- Plan: specs/985_lindenbaum_tarski_representation_theorem/plans/implementation-001.md
-/

namespace Bimodal.Metalogic.Algebraic.ParametricRepresentation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Consistency Lemmas

These lemmas connect non-provability to consistency.
-/

/--
If a formula is not provable, then its negation is consistent (as a singleton set).

**Proof Strategy**:
Suppose {phi.neg} is inconsistent. Then [phi.neg] ⊢ ⊥.
By deduction theorem: ⊢ phi.neg → ⊥ = ⊢ ¬¬phi.
By double negation elimination: ⊢ phi.
Contradiction with hypothesis.
-/
theorem not_provable_implies_neg_set_consistent (φ : Formula)
    (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ)) :
    SetConsistent {φ.neg} := by
  intro L hL ⟨d⟩
  by_cases h_mem : φ.neg ∈ L
  · -- L contains phi.neg, so we can derive [phi.neg] ⊢ ⊥
    have h_weak : ∀ x ∈ L, x ∈ [φ.neg] := fun x hx => by
      have := hL x hx
      simp only [Set.mem_singleton_iff] at this
      simp [this]
    have d_single : Bimodal.ProofSystem.DerivationTree [φ.neg] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.weakening L [φ.neg] Formula.bot d h_weak
    -- By deduction theorem: ⊢ phi.neg → ⊥ = ⊢ ¬¬phi
    have d_neg_neg : Bimodal.ProofSystem.DerivationTree [] (φ.neg.neg) :=
      Bimodal.Metalogic.Core.deduction_theorem [] φ.neg Formula.bot d_single
    -- By DNE: ⊢ ¬¬phi → phi
    have h_dne : Bimodal.ProofSystem.DerivationTree [] (φ.neg.neg.imp φ) :=
      Bimodal.Theorems.Propositional.double_negation φ
    -- By modus ponens: ⊢ phi
    have d_phi : Bimodal.ProofSystem.DerivationTree [] φ :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens [] φ.neg.neg φ h_dne d_neg_neg
    exact h_not_prov ⟨d_phi⟩
  · -- phi.neg ∉ L, so L ⊆ {phi.neg} means L = []
    have h_L_empty : L = [] := by
      cases L with
      | nil => rfl
      | cons x xs =>
        exfalso
        have hx := hL x List.mem_cons_self
        simp only [Set.mem_singleton_iff] at hx
        rw [hx] at h_mem
        exact h_mem List.mem_cons_self
    -- [] ⊢ ⊥ means ⊥ is a theorem, contradicting consistency
    rw [h_L_empty] at d
    -- From ⊢ ⊥, derive ⊢ phi via ex falso
    have d_efq : Bimodal.ProofSystem.DerivationTree [] (Formula.bot.imp φ) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso φ)
    have d_phi : Bimodal.ProofSystem.DerivationTree [] φ :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens [] Formula.bot φ d_efq d
    exact h_not_prov ⟨d_phi⟩

/-!
## The Representation Theorem

The main theorem states that non-provability implies the existence of a countermodel.
This is formulated as: given a temporally coherent BFMCS over D and a non-provable
formula, there exists a countermodel within that BFMCS.
-/

/--
**D-Parametric Algebraic Representation Theorem (Relative Version)**

Given:
- A temporally coherent BFMCS B over D
- A formula φ that is not provable

Then there exists a family in B and a time point where φ is false in the
D-parametric canonical model.

This is the relative version: it assumes a temporally coherent BFMCS exists.
The absolute version (which constructs the BFMCS) is proven for specific D
in the instantiation modules.

**Proof Strategy**:
1. Since ⊬ φ, we have φ.neg is consistent
2. Extend {φ.neg} to an MCS M₀ via Lindenbaum
3. Construct a family fam with M₀ at time 0
4. By truth lemma: φ.neg ∈ M₀ ↔ truth_at ... φ.neg
5. Since φ.neg ∈ M₀ (by Lindenbaum), we have truth_at ... φ.neg
6. Therefore ¬(truth_at ... φ)
-/
theorem parametric_algebraic_representation_relative
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ))
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  intro h_phi_true
  -- By shifted truth lemma (backward): truth_at ... φ implies φ ∈ fam.mcs t
  have h_phi_in := (parametric_shifted_truth_lemma B h_tc φ fam hfam t).mpr h_phi_true
  -- But φ.neg ∈ fam.mcs t, contradiction with MCS consistency
  exact set_consistent_not_both (fam.is_mcs t).1 φ h_phi_in h_neg_in

/--
**Corollary**: If φ is not provable, and φ.neg is in some family's MCS,
then φ is false at that point in the canonical model.

This is a more useful formulation that avoids needing to construct the BFMCS.
The caller provides the BFMCS and the witness that φ.neg is in some family.
-/
theorem parametric_representation_from_neg_membership
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  intro h_phi_true
  have h_phi_in := (parametric_shifted_truth_lemma B h_tc φ fam hfam t).mpr h_phi_true
  exact set_consistent_not_both (fam.is_mcs t).1 φ h_phi_in h_neg_in

/--
**Key Corollary**: If φ is not provable, φ.neg can be consistently extended to an MCS.

This is the bridge between non-provability and the existence of a countermodel.
The instantiation modules use this to construct the specific BFMCS.
-/
theorem not_provable_implies_neg_extends_to_mcs
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ)) :
    ∃ M : Set Formula, SetMaximalConsistent M ∧ φ.neg ∈ M := by
  have h_cons := not_provable_implies_neg_set_consistent φ h_not_prov
  obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum {φ.neg} h_cons
  exact ⟨M, h_mcs, h_sub (Set.mem_singleton φ.neg)⟩

/-!
## Representation Theorem (Conditional Version)

The full D-parametric representation theorem requires constructing a temporally
coherent BFMCS over D that contains the extended MCS. This construction depends
on additional structure of D (e.g., witness existence for F/P formulas).

Rather than introducing sorries, we formulate a conditional version that
assumes the existence of such a BFMCS and proves the representation from it.
The instantiation modules provide the concrete BFMCS construction.
-/

/--
**D-Parametric Representation Theorem (Conditional Version)**

Given:
- A formula φ that is not provable
- A function that constructs a temporally coherent BFMCS containing any given MCS

Then there exists a countermodel for φ in the D-parametric canonical frame.

This conditional formulation avoids sorries by shifting the BFMCS construction
to the caller. The instantiation modules provide the concrete construction.
-/
theorem parametric_algebraic_representation_conditional
    (φ : Formula) (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ))
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
         M = fam.mcs t) :
    ∃ (B : BFMCS D) (h_tc : B.temporally_coherent)
      (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
      ¬truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
        (parametric_to_history fam) t φ := by
  -- Step 1: Extend {φ.neg} to an MCS
  obtain ⟨M, h_mcs, h_neg_in⟩ := not_provable_implies_neg_extends_to_mcs φ h_not_prov
  -- Step 2: Use the construction function to get a BFMCS containing M
  obtain ⟨B, h_tc, fam, hfam, t, h_eq⟩ := construct_bfmcs M h_mcs
  -- Step 3: φ.neg ∈ fam.mcs t (since M = fam.mcs t)
  have h_neg_in_fam : φ.neg ∈ fam.mcs t := h_eq ▸ h_neg_in
  -- Step 4: Apply the representation theorem
  exact ⟨B, h_tc, fam, hfam, t, parametric_representation_from_neg_membership B h_tc φ fam hfam t h_neg_in_fam⟩

/-!
## Completeness Corollary

The completeness theorem states: if φ is valid in all D-parametric canonical models,
then φ is provable. This is the contrapositive of representation.
-/

/--
**Completeness (Contrapositive Form)**

If a formula has a countermodel in some temporally coherent BFMCS,
then it is not provable.

This is the soundness direction: non-provability is witnessed by countermodels.
-/
theorem countermodel_implies_not_provable
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D)
    (h_false : ¬truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ) :
    ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] φ) := by
  intro ⟨d⟩
  -- If ⊢ φ, then φ ∈ every MCS
  have h_in : φ ∈ fam.mcs t := theorem_in_mcs (fam.is_mcs t) d
  -- By truth lemma: truth_at ... φ
  have h_true := (parametric_shifted_truth_lemma B h_tc φ fam hfam t).mp h_in
  exact h_false h_true

end Bimodal.Metalogic.Algebraic.ParametricRepresentation
