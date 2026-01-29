import Bimodal.ProofSystem.Derivation
import Bimodal.Semantics.Validity
import Bimodal.Semantics.Truth
import Bimodal.Metalogic.Representation.UniversalCanonicalModel
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Theorems.Propositional

/-!
# Weak Completeness for TM Bimodal Logic

This module proves the weak completeness theorem for TM bimodal logic:
valid formulas are provable (⊨ φ → ⊢ φ).

## Overview

The completeness proof proceeds via contrapositive using the representation theorem:
1. Assume φ is not provable from []
2. Then {¬φ} is consistent (cannot derive ⊥)
3. By representation theorem, {¬φ} is satisfiable in the canonical model
4. Therefore ¬φ is true somewhere, so φ is not valid
5. Contrapositive: valid φ → provable φ

## Main Results

- `ContextDerivable`: Propositional wrapper for existence of derivation tree
- `weak_completeness`: `⊨ φ → ContextDerivable [] φ` (valid implies provable)
- `provable_iff_valid`: `ContextDerivable [] φ ↔ ⊨ φ` (equivalence)

## Dependencies

- Representation theorem: `Bimodal.Metalogic.Representation.representation_theorem`
- Soundness is axiomatized with sorry pending Boneyard fix (see `soundness` lemma)

## References

- Representation theorem: `Bimodal.Metalogic.Representation.UniversalCanonicalModel`
- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
-/

namespace Bimodal.Metalogic.Completeness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Representation
open Bimodal.Theorems.Propositional

/-!
## Context Derivability

Propositional wrapper for derivation tree existence.
-/

/--
Context-based derivability: φ is derivable from context Γ.

This is the propositional version of `DerivationTree Γ φ`, asserting existence
of a derivation tree without committing to a specific proof.
-/
def ContextDerivable (Γ : Context) (φ : Formula) : Prop :=
  Nonempty (DerivationTree Γ φ)

/-!
## Consistency Definition

Consistency is the semantic dual of derivability.
-/

/--
A context is consistent if it does not derive ⊥.
-/
def Consistent (Γ : Context) : Prop :=
  ¬Nonempty (DerivationTree Γ Formula.bot)

/-!
## Soundness (Axiomatized)

Soundness is needed for the equivalence theorem but not for weak completeness.
The full soundness proof is in Boneyard/Metalogic_v2/Soundness but has broken
lemmas due to the reflexive semantics change. We axiomatize it here.
-/

/--
Soundness for context derivability: If Γ ⊢ φ, then Γ ⊨ φ.

**Status**: Axiomatized with sorry. Full proof in Boneyard/Metalogic_v2/Soundness
requires fixing SoundnessLemmas.lean for reflexive temporal semantics.
-/
theorem soundness (Γ : Context) (φ : Formula) :
    (DerivationTree Γ φ) → semantic_consequence Γ φ := by
  sorry

/--
Soundness for empty context: If ⊢ φ, then ⊨ φ (valid).
-/
theorem derivable_implies_valid (φ : Formula) :
    ContextDerivable [] φ → valid φ := by
  intro ⟨d⟩
  intro D _ _ _ F M τ t
  have h_sem := soundness [] φ d
  exact h_sem D F M τ t (fun _ h => (List.not_mem_nil h).elim)

/-!
## Completeness via Representation Theorem

The key insight: we use the representation theorem to show that
consistent formulas are satisfiable.
-/

/--
If a formula is not derivable from empty context, then its negation is consistent.

**Proof Strategy**:
1. Assume ¬ContextDerivable [] φ and suppose ¬Consistent [φ.neg] (to derive contradiction)
2. From ¬Consistent [φ.neg], we have [φ.neg] ⊢ ⊥
3. By deduction theorem: [] ⊢ φ.neg → ⊥ = [] ⊢ φ.neg.neg
4. By double negation elimination: [] ⊢ φ
5. This contradicts ¬ContextDerivable [] φ
-/
theorem not_derivable_implies_neg_consistent {φ : Formula} :
    ¬ContextDerivable [] φ → Consistent [φ.neg] := by
  intro h_not_deriv
  -- Consistent means ¬Nonempty (DerivationTree [φ.neg] Formula.bot)
  intro ⟨d_bot⟩
  apply h_not_deriv
  -- From [φ.neg] ⊢ ⊥, by deduction theorem, [] ⊢ φ.neg → ⊥ = [] ⊢ φ.neg.neg
  have d_neg_neg : DerivationTree [] (Formula.neg φ).neg :=
    deduction_theorem [] φ.neg Formula.bot d_bot
  -- By double negation elimination: ⊢ φ.neg.neg → φ
  have dne : ⊢ φ.neg.neg.imp φ := double_negation φ
  -- Apply modus ponens: [] ⊢ φ
  have d_phi : DerivationTree [] φ :=
    DerivationTree.modus_ponens [] φ.neg.neg φ
      (DerivationTree.weakening [] [] (φ.neg.neg.imp φ) dne (List.nil_subset []))
      d_neg_neg
  exact ⟨d_phi⟩

/--
Convert list-based consistency to set-based consistency.

This bridges the context-based consistency used in proof theory
to the set-based consistency used in the representation theorem.
-/
theorem list_consistent_implies_set_consistent {φ : Formula}
    (h_cons : Consistent [φ]) : SetConsistent {φ} := by
  intro L hL
  intro ⟨d⟩
  -- L ⊆ {φ} means L is either [] or has only φ as elements
  cases L with
  | nil =>
    -- Empty context derives bot - but [] doesn't derive bot in consistent logic
    -- Since [φ] is consistent and [] ⊆ [φ], we can weaken
    apply h_cons
    constructor
    exact DerivationTree.weakening [] [φ] Formula.bot d (by simp)
  | cons psi L' =>
    -- psi :: L' ⊆ {φ} means all elements are φ
    apply h_cons
    constructor
    -- Weaken derivation to [φ]
    exact DerivationTree.weakening (psi :: L') [φ] Formula.bot d
      (fun ψ hψ => by
        simp
        have h := hL ψ hψ
        simp at h
        exact h)

/--
**Weak Completeness**: Valid formulas are provable from the empty context.

**Statement**: `⊨ φ → ContextDerivable [] φ`

**Proof Strategy** (via contrapositive):
1. Assume φ is not provable from []
2. By `not_derivable_implies_neg_consistent`, [¬φ] is consistent
3. Convert to set-based consistency: {¬φ} is SetConsistent
4. By representation theorem, {¬φ} is satisfiable: there exists a model
   where ¬φ is true at some point
5. Therefore φ is not valid (has a countermodel)
6. Contrapositive: valid φ → ContextDerivable [] φ
-/
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  -- Prove by contrapositive: ¬ContextDerivable [] φ → ¬valid φ
  by_contra h_not_impl
  push_neg at h_not_impl
  obtain ⟨h_valid, h_not_deriv⟩ := h_not_impl
  -- Step 1: Since φ is not derivable, ¬φ is consistent (as a list context)
  have h_neg_cons : Consistent [φ.neg] := not_derivable_implies_neg_consistent h_not_deriv
  -- Step 2: Convert to set-based consistency
  have h_set_cons : SetConsistent {φ.neg} := list_consistent_implies_set_consistent h_neg_cons
  -- Step 3: By representation theorem, {¬φ} is satisfiable
  obtain ⟨family, t, h_mem, h_truth⟩ := representation_theorem φ.neg h_set_cons
  -- Step 4: h_truth says ¬φ is true at (canonical_model, canonical_history, t)
  -- This means φ is false there, contradicting validity
  -- But validity says φ is true everywhere, including here
  have h_phi_valid := h_valid ℤ (UniversalCanonicalFrame ℤ)
    (canonical_model ℤ family) (canonical_history_family ℤ family) t
  -- Now we have: h_truth : truth_at ... t φ.neg and h_phi_valid : truth_at ... t φ
  -- φ.neg = φ → ⊥, so h_truth is: truth_at φ → truth_at ⊥
  -- Applying h_truth to h_phi_valid gives truth_at ⊥, which is False
  simp only [Formula.neg, truth_at] at h_truth
  exact h_truth h_phi_valid

/--
**Soundness-Completeness Equivalence**: Provability and validity are equivalent.

**Statement**: `ContextDerivable [] φ ↔ ⊨ φ`

This combines soundness (derivable → valid) with weak completeness (valid → derivable).
-/
theorem provable_iff_valid (φ : Formula) : ContextDerivable [] φ ↔ valid φ := by
  constructor
  · -- Soundness: derivable implies valid
    exact derivable_implies_valid φ
  · -- Completeness: valid implies derivable
    exact weak_completeness φ

end Bimodal.Metalogic.Completeness
