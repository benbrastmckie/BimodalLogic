import Bimodal.Metalogic.Representation.TruthLemma
import Bimodal.Metalogic.Representation.IndexedMCSFamily
import Bimodal.Metalogic.Representation.CoherentConstruction

/-!
# Universal Canonical Model and Representation Theorem

This module assembles the canonical model from an indexed MCS family and
proves the representation theorem: every consistent formula is satisfiable.

## Overview

**Main Theorem (Representation Theorem)**:
```
theorem representation_theorem (phi : Formula) (h_cons : SetConsistent {phi}) :
    exists (family : IndexedMCSFamily D) (t : D),
      phi in family.mcs t /\
      truth_at (canonical_model family) (canonical_history_family family) t phi
```

**Proof Outline**:
1. Extend {phi} to an MCS Gamma using Lindenbaum's lemma
2. Construct an indexed family with Gamma at the origin (time 0)
3. By construction, phi in family.mcs 0
4. By truth lemma, truth_at ... 0 phi

## Design Notes

The canonical model is already defined in TruthLemma.lean as `canonical_model`.
This module focuses on the representation theorem that ties everything together.

-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Core
open Bimodal.Semantics

variable (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Representation Theorem

The main theorem connecting syntactic consistency to semantic satisfiability.
-/

/--
Representation Theorem: Every consistent formula is satisfiable in the canonical model.

**Statement**: If phi is consistent (i.e., {phi} doesn't derive bot), then there exists:
1. An indexed MCS family
2. A time point t
3. phi is in the MCS at t
4. phi is true at the canonical model/history at time t

**Proof**:
1. Since {phi} is consistent, extend it to an MCS Gamma via Lindenbaum's lemma
2. Construct the indexed family with Gamma at origin 0
3. By construction of the family, phi in family.mcs 0
4. By the truth lemma, phi is true at (canonical_model family, canonical_history_family family, 0)

**Note**: This theorem uses the indexed family approach to avoid the T-axiom requirement
that blocked the same-MCS-at-all-times approach.
-/
theorem representation_theorem (phi : Formula) (h_cons : SetConsistent {phi}) :
    ∃ (family : IndexedMCSFamily ℤ) (t : ℤ),
      phi ∈ family.mcs t ∧
      truth_at (canonical_model ℤ family) (canonical_history_family ℤ family) t phi := by
  -- Step 1: Extend {phi} to an MCS
  obtain ⟨Gamma, h_extends, h_mcs⟩ := set_lindenbaum {phi} h_cons
  -- Step 2: Prove the temporal boundary conditions
  -- These hypotheses ensure the MCS can be extended temporally in both directions.
  -- G⊥ ∉ Gamma and H⊥ ∉ Gamma follow from MCS consistency via T-axioms:
  -- If G⊥ ∈ Gamma, then by T-axiom (Gφ → φ), ⊥ ∈ Gamma, contradicting consistency.
  have h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma := by
    -- If G⊥ ∈ Gamma, then by T-axiom (Gφ → φ), ⊥ ∈ Gamma
    -- But ⊥ ∈ Gamma contradicts MCS consistency
    intro h_G_bot_in
    -- T-axiom: G⊥ ∈ Gamma implies ⊥ ∈ Gamma
    have h_bot_in : Formula.bot ∈ Gamma := mcs_closed_temp_t_future h_mcs Formula.bot h_G_bot_in
    -- But [⊥] ⊢ ⊥, so Gamma is inconsistent
    apply h_mcs.1 [Formula.bot]
    · intro ψ hψ; simp at hψ; rw [hψ]; exact h_bot_in
    · constructor
      exact Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
  have h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma := by
    -- If H⊥ ∈ Gamma, then by T-axiom (Hφ → φ), ⊥ ∈ Gamma
    -- But ⊥ ∈ Gamma contradicts MCS consistency
    intro h_H_bot_in
    -- T-axiom: H⊥ ∈ Gamma implies ⊥ ∈ Gamma
    have h_bot_in : Formula.bot ∈ Gamma := mcs_closed_temp_t_past h_mcs Formula.bot h_H_bot_in
    -- But [⊥] ⊢ ⊥, so Gamma is inconsistent
    apply h_mcs.1 [Formula.bot]
    · intro ψ hψ; simp at hψ; rw [hψ]; exact h_bot_in
    · constructor
      exact Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
  -- Step 3: Construct the coherent family with Gamma at origin 0
  let coherent := construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot
  let family := coherent.toIndexedMCSFamily
  -- Step 4: phi ∈ family.mcs 0
  have h_phi_in : phi ∈ family.mcs 0 := by
    -- family.mcs 0 = coherent.mcs 0 by toIndexedMCSFamily definition
    -- coherent.mcs 0 = Gamma (origin preservation)
    -- And h_extends says phi ∈ Gamma
    apply construct_coherent_family_origin Gamma h_mcs h_no_G_bot h_no_H_bot phi
    exact h_extends (Set.mem_singleton phi)
  -- Step 5: By truth lemma, phi is true at the canonical configuration
  have h_true : truth_at (canonical_model ℤ family) (canonical_history_family ℤ family) 0 phi := by
    exact (truth_lemma ℤ family 0 phi).mp h_phi_in
  -- Package the result
  exact ⟨family, 0, h_phi_in, h_true⟩

/--
Representation Theorem (alternate form): Consistent formulas are satisfiable.

This version uses list-based consistency which is more common in some contexts.
-/
theorem representation_theorem' (phi : Formula) (h_cons : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [phi] Formula.bot)) :
    ∃ (family : IndexedMCSFamily ℤ) (t : ℤ),
      phi ∈ family.mcs t ∧
      truth_at (canonical_model ℤ family) (canonical_history_family ℤ family) t phi := by
  -- Convert list-based consistency to set-based
  have h_set_cons : SetConsistent {phi} := by
    intro L hL
    intro ⟨d⟩
    -- If L ⊆ {phi}, then L is either [] or [phi]
    cases L with
    | nil =>
      -- Empty context derives bot - but [] doesn't derive bot in consistent logic
      -- Actually we need to show Consistent []
      apply h_cons
      constructor
      -- Need derivation of bot from [phi] using derivation from []
      exact Bimodal.ProofSystem.DerivationTree.weakening [] [phi] Formula.bot d (by simp)
    | cons psi L' =>
      -- psi :: L' ⊆ {phi} means all elements are phi
      have hpsi : psi ∈ ({phi} : Set Formula) := hL psi (by simp)
      simp at hpsi
      -- So L is a list of phis
      apply h_cons
      constructor
      -- Weaken derivation to [phi]
      exact Bimodal.ProofSystem.DerivationTree.weakening (psi :: L') [phi] Formula.bot d
        (fun ψ hψ => by
          simp
          have h := hL ψ hψ
          simp at h
          exact h)
  exact representation_theorem phi h_set_cons

/-!
## Corollaries

Some useful consequences of the representation theorem.
-/

/--
Non-provable formulas are satisfiable.

If phi is not provable (from empty context), then phi is satisfiable.

**Note**: This uses the contrapositive of soundness. If phi were unsatisfiable,
then by soundness, phi would be refutable (neg phi provable).
-/
theorem non_provable_satisfiable (phi : Formula)
    (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] (Formula.neg phi))) :
    ∃ (family : IndexedMCSFamily ℤ) (t : ℤ),
      phi ∈ family.mcs t := by
  -- If neg phi is not provable, then {phi} is consistent
  -- Proof: If {phi} is inconsistent, L ⊆ {phi} derives bot.
  --        Since L can only contain phi, [phi] ⊢ bot (by weakening).
  --        By deduction theorem, [] ⊢ phi -> bot = neg phi. Contradiction.
  have h_cons : SetConsistent {phi} := by
    intro L hL
    intro ⟨d⟩
    apply h_not_prov
    -- L ⊆ {phi} means L contains only phi (or is empty)
    -- Weaken to [phi]
    have h_weak : L ⊆ [phi] := fun ψ hψ => by
      simp
      have h := hL ψ hψ
      simp at h
      exact h
    have d_bot : Bimodal.ProofSystem.DerivationTree [phi] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.weakening L [phi] Formula.bot d h_weak
    -- By deduction theorem: [] ⊢ phi -> bot = neg phi
    have d_neg : Bimodal.ProofSystem.DerivationTree [] (Formula.neg phi) :=
      Bimodal.Metalogic.Core.deduction_theorem [] phi Formula.bot d_bot
    exact ⟨d_neg⟩
  obtain ⟨family, t, h_mem, _⟩ := representation_theorem phi h_cons
  exact ⟨family, t, h_mem⟩

/--
Completeness direction: Valid formulas are provable.

**Contrapositive**: If phi is not provable, phi is not valid (i.e., has a countermodel).

This is the contrapositive of soundness composed with the representation theorem.
Full completeness (provable iff valid) requires soundness, which is in a separate module.
-/
theorem completeness_contrapositive (phi : Formula)
    (h_not_prov : ¬Nonempty (Bimodal.ProofSystem.DerivationTree [] phi)) :
    ∃ (family : IndexedMCSFamily ℤ) (t : ℤ),
      ¬truth_at (canonical_model ℤ family) (canonical_history_family ℤ family) t phi := by
  -- If phi is not provable, then {neg phi} is consistent
  -- Proof: If {neg phi} is inconsistent, [neg phi] ⊢ bot.
  --        By deduction theorem, [] ⊢ neg phi -> bot = neg (neg phi).
  --        By double negation elimination, [] ⊢ phi. Contradiction.
  have h_cons : SetConsistent {phi.neg} := by
    intro L hL
    intro ⟨d⟩
    apply h_not_prov
    -- L ⊆ {phi.neg} means L contains only phi.neg
    have h_weak : L ⊆ [phi.neg] := fun ψ hψ => by
      simp
      have h := hL ψ hψ
      simp at h
      exact h
    have d_bot : Bimodal.ProofSystem.DerivationTree [phi.neg] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.weakening L [phi.neg] Formula.bot d h_weak
    -- By deduction theorem: [] ⊢ phi.neg -> bot = neg (neg phi)
    have d_neg_neg : Bimodal.ProofSystem.DerivationTree [] phi.neg.neg :=
      Bimodal.Metalogic.Core.deduction_theorem [] phi.neg Formula.bot d_bot
    -- By double negation elimination: ⊢ neg neg phi -> phi
    have dne : [] ⊢ phi.neg.neg.imp phi := Bimodal.Theorems.Propositional.double_negation phi
    -- Apply modus ponens: [] ⊢ phi
    have d_phi : Bimodal.ProofSystem.DerivationTree [] phi :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens [] phi.neg.neg phi
        (Bimodal.ProofSystem.DerivationTree.weakening [] [] (phi.neg.neg.imp phi) dne (by simp))
        d_neg_neg
    exact ⟨d_phi⟩
  -- Apply representation theorem to neg phi
  obtain ⟨family, t, h_mem, h_true⟩ := representation_theorem phi.neg h_cons
  -- h_true : truth_at ... t phi.neg
  -- phi.neg = phi -> bot, so truth_at phi.neg means: truth_at phi -> truth_at bot
  use family, t
  simp only [Formula.neg, truth_at] at h_true
  exact h_true

end Bimodal.Metalogic.Representation
