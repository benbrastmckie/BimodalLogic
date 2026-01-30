import Bimodal.ProofSystem.Derivation
import Bimodal.Semantics.Validity
import Bimodal.Semantics.Truth
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Theorems.Propositional
import Bimodal.Metalogic.Soundness.Soundness
import Bimodal.Metalogic.FMP.SemanticCanonicalModel

/-!
# Weak Completeness for TM Bimodal Logic

This module provides completeness-related theorems for TM bimodal logic.

## Overview

### Sorry-Free Completeness (Recommended)

The canonical sorry-free completeness result is `semantic_weak_completeness` in
`FMP/SemanticCanonicalModel.lean`:

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

This theorem works via contrapositive (unprovable -> countermodel exists) and is
completely sorry-free.

### Universal Validity (Architectural Limitation)

The theorem `weak_completeness : valid phi -> ContextDerivable [] phi` has an
**architectural sorry** because bridging "valid in ALL models" to "true at all
SemanticWorldStates" requires the forward truth lemma, which is impossible due
to Box semantics quantifying over ALL histories.

Use `semantic_weak_completeness` for sorry-free proofs.

## Main Results

- `ContextDerivable`: Propositional wrapper for existence of derivation tree
- `derivable_implies_valid`: Soundness (fully proven)
- `weak_completeness`: Completeness with architectural sorry (see note above)

## References

- Task 776: Refactor Metalogic to zero sorry
- Task 750: Research on truth lemma gap
- `Boneyard/Metalogic_v4/FMP/` - Archived code with full documentation
-/

namespace Bimodal.Metalogic.Completeness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.FMP
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
## Soundness

Soundness is proven in Bimodal.Metalogic.Soundness.Soundness which contains the
fully proven soundness theorem for TM bimodal logic.
-/

/--
Soundness for context derivability: If Gamma derives phi, then Gamma entails phi.

**Status**: Proven via `Bimodal.Metalogic.Soundness.soundness`.
The soundness theorem handles all derivation rules including
temporal_duality via derivation-indexed induction.
-/
theorem soundness (Gamma : Context) (φ : Formula) :
    (DerivationTree Gamma φ) → semantic_consequence Gamma φ := by
  intro h_deriv
  -- Use the proven soundness theorem
  exact Bimodal.Metalogic.Soundness.soundness Gamma φ (by exact h_deriv)

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
## Completeness via Semantic Canonical Model

The key insight: we use the sorry-free `semantic_weak_completeness` theorem
from FMP/SemanticCanonicalModel.lean.
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
to the set-based consistency used in the semantic completeness proof.
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

**Statement**: `valid phi -> ContextDerivable [] phi`

**ARCHITECTURAL LIMITATION (Task 776)**:
This theorem has a sorry because bridging "valid in ALL models" to "provable"
requires the forward truth lemma `truth_at_implies_semantic_truth`, which is
architecturally impossible due to Box semantics.

The fundamental gap:
- `valid phi` quantifies over ALL models (all D, F, M, tau, t)
- `semantic_weak_completeness` only needs truth at SemanticWorldStates
- Bridging requires showing: if phi is true in ALL models, then it's true at
  all SemanticWorldStates under their finite model semantics
- This requires the forward truth lemma, which fails because Box quantifies
  over ALL histories but MCS constructions only have one world state

**Sorry-Free Alternative**:
Use `semantic_weak_completeness` from FMP/SemanticCanonicalModel.lean:
```lean
(forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w origin phi) -> |- phi
```

See `Boneyard/Metalogic_v4/FMP/` for full documentation of the architectural gap.
-/
-- ARCHITECTURAL SORRY (Task 776): Use semantic_weak_completeness for sorry-free proofs
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  intro _h_valid
  -- The gap: We need to show that if phi is valid in ALL models, it is true
  -- at all SemanticWorldStates under semantic_truth_at_v2. This requires
  -- the forward truth lemma which is architecturally impossible.
  -- See Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean for full explanation.
  sorry

/--
**Soundness-Completeness Equivalence**: Provability and validity are equivalent.

**Statement**: `ContextDerivable [] phi <-> valid phi`

**Note**: The completeness direction inherits the architectural sorry from
`weak_completeness`. For sorry-free proofs, use `semantic_weak_completeness`.
-/
-- ARCHITECTURAL SORRY (via weak_completeness)
theorem provable_iff_valid (φ : Formula) : ContextDerivable [] φ ↔ valid φ := by
  constructor
  · -- Soundness: derivable implies valid (sorry-free)
    exact derivable_implies_valid φ
  · -- Completeness: valid implies derivable (has sorry)
    exact weak_completeness φ

end Bimodal.Metalogic.Completeness
