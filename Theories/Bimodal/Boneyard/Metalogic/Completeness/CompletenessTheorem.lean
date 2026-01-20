import Bimodal.Boneyard.Metalogic.Completeness

/-!
# CompletenessTheorem - Re-export Module

This module re-exports the main completeness theorems from `Bimodal.Boneyard.Metalogic.Completeness`.

## Purpose

Provides a stable API for accessing the key completeness results without exposing
the internal infrastructure of the parent module.

## Exported Theorems

- `weak_completeness`: `valid phi -> DerivationTree [] phi`
- `strong_completeness`: `semantic_consequence Gamma phi -> DerivationTree Gamma phi`
- `provable_iff_valid`: `Nonempty (DerivationTree [] phi) <-> valid phi`
- `consistency_satisfiability`: Consistency implies satisfiability (corollary)

## References

See `Bimodal.Boneyard.Metalogic.Completeness` for the canonical model construction and
supporting infrastructure.
-/

namespace Bimodal.Boneyard.Metalogic.Completeness.Theorems

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics Bimodal.Boneyard.Metalogic

/-!
## Completeness Theorems

Re-exports from the parent Completeness module.
-/

/--
**Weak Completeness**: Every valid formula is provable.

This is the fundamental bridge from semantics to syntax: if a formula is
true in all models, then it has a derivation.
-/
noncomputable def weak_completeness' (phi : Formula) : valid phi -> DerivationTree [] phi :=
  weak_completeness phi

/--
**Strong Completeness**: Semantic consequence implies syntactic derivability.

If phi is semantically entailed by Gamma (true in all models where Gamma holds),
then phi can be derived from Gamma.
-/
noncomputable def strong_completeness' (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> DerivationTree Gamma phi :=
  strong_completeness Gamma phi

/--
**Provability-Validity Equivalence**: A formula is provable iff it is valid.

This combines soundness (provable implies valid) and completeness (valid implies provable)
into a biconditional.
-/
theorem provable_iff_valid' (phi : Formula) : Nonempty (DerivationTree [] phi) <-> valid phi :=
  provable_iff_valid phi

/-!
## Consistency and Satisfiability

Additional theorems derived from completeness.
-/

/--
**Consistency Implies Satisfiability (Semantic)**

If a context is consistent (cannot derive bottom), then it is satisfiable
in some model. This is a consequence of the representation theorem.

Note: This uses a semantic notion of satisfiability. For the canonical model
version, see `Representation.representation_theorem`.
-/
theorem consistency_implies_satisfiability {Gamma : Context}
    (h_cons : Consistent Gamma) : satisfiable_abs Gamma := by
  -- By contrapositive: if unsatisfiable, then can derive anything, including bottom
  by_contra h_not_sat
  -- If not satisfiable_abs, then semantic_consequence Gamma bot
  have h_conseq : semantic_consequence Gamma Formula.bot := by
    intro D _ _ _ F M tau t h_all_true
    -- If Gamma is unsatisfiable, the antecedent (all of Gamma true) is false
    exfalso
    apply h_not_sat
    exact ⟨D, inferInstance, inferInstance, inferInstance, F, M, tau, t, h_all_true⟩
  -- By strong completeness, Gamma |- bot
  have h_deriv := strong_completeness Gamma Formula.bot h_conseq
  -- But this contradicts consistency
  exact h_cons ⟨h_deriv⟩

/--
**Satisfiability Implies Consistency**

If a context is satisfiable, then it is consistent.
This is actually a consequence of soundness: if Gamma is satisfiable and
we could derive bottom from it, soundness would give a contradiction.
-/
theorem satisfiability_implies_consistency {Gamma : Context}
    (h_sat : satisfiable_abs Gamma) : Consistent Gamma := by
  intro ⟨h_deriv⟩
  -- By soundness, Gamma semantically entails bot
  have h_conseq := Soundness.soundness Gamma Formula.bot h_deriv
  -- Get the model witnessing satisfiability
  obtain ⟨D, _, _, _, F, M, tau, t, h_all_true⟩ := h_sat
  -- All of Gamma is true at this model, so by h_conseq, bot is true
  have h_bot := h_conseq D F M tau t h_all_true
  -- But bot is never true (by definition of truth_at)
  exact h_bot

/--
**Consistency-Satisfiability Equivalence**

A context is consistent if and only if it is satisfiable.
-/
theorem consistency_iff_satisfiability (Gamma : Context) :
    Consistent Gamma <-> satisfiable_abs Gamma :=
  ⟨consistency_implies_satisfiability, satisfiability_implies_consistency⟩

end Bimodal.Boneyard.Metalogic.Completeness.Theorems
