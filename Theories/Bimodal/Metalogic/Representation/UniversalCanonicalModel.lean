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

## References

- Research report: specs/654_.../reports/research-004.md
- Implementation plan: specs/654_.../plans/implementation-004.md
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
  -- G⊥ ∉ Gamma and H⊥ ∉ Gamma are required because MCS containing these formulas
  -- are only satisfiable at bounded temporal endpoints.
  -- Proof: If G⊥ ∈ Gamma, then ⊥ ∈ Gamma by T-axiom (G⊥ → ⊥), contradicting consistency.
  -- Similarly for H⊥ using the past T-axiom (H⊥ → ⊥).
  have h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma := by
    intro h_G_bot_in
    -- If G⊥ ∈ Gamma, then ⊥ ∈ Gamma by T-axiom closure
    have h_bot_in : Formula.bot ∈ Gamma :=
      mcs_closed_temp_t_future h_mcs Formula.bot h_G_bot_in
    -- But ⊥ ∈ Gamma contradicts MCS consistency
    have h_cons := h_mcs.1
    have h_bot_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
    exact h_cons [Formula.bot] (by simp [h_bot_in]) ⟨h_bot_deriv⟩
  have h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma := by
    intro h_H_bot_in
    -- If H⊥ ∈ Gamma, then ⊥ ∈ Gamma by T-axiom closure
    have h_bot_in : Formula.bot ∈ Gamma :=
      mcs_closed_temp_t_past h_mcs Formula.bot h_H_bot_in
    -- But ⊥ ∈ Gamma contradicts MCS consistency
    have h_cons := h_mcs.1
    have h_bot_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
    exact h_cons [Formula.bot] (by simp [h_bot_in]) ⟨h_bot_deriv⟩
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
  have h_cons : SetConsistent {phi} := by
    intro L hL
    intro ⟨d⟩
    -- Similar argument to above
    sorry -- Requires detailed proof about consistency
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
  -- If phi is not provable, then neg phi is consistent
  -- Apply representation theorem to neg phi
  sorry -- Requires negation consistency argument

end Bimodal.Metalogic.Representation
