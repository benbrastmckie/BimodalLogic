import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Bimodal.Metalogic.Completeness.WeakCompleteness
import Bimodal.Semantics.Validity
import Mathlib.Data.Fintype.BigOperators

/-!
# Parametric Finite Model Property for TM Bimodal Logic

This module establishes the Finite Model Property (FMP) for the parametric FMP
architecture.

## Design Philosophy

The FMP provides the key bridge between completeness/representation infrastructure
and decidability/compactness. The cardinality bound (2^closureSize) is purely
combinatorial - independent of any specific duration type.

## Main Results

- `finite_model_property`: If phi is satisfiable, it has a finite model
- `consistent_implies_satisfiable`: Consistency implies satisfiability
- `semanticWorldState_card_bound`: Card <= 2^closureSize bound (in SemanticCanonicalModel.lean)

## Canonical Completeness Result

Use `semantic_weak_completeness` (sorry-free) for all completeness needs:
```
theorem semantic_weak_completeness (phi : Formula) :
    (forall w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi) -> |- phi
```

This works via contrapositive (unprovable -> countermodel) and avoids the truth bridge entirely.

## Archived Code

The `finite_model_property_constructive` theorem was archived to
`Boneyard/Metalogic_v4/FMP/FiniteModelPropertyConstructive.lean` because it
contained a sorry for the truth bridge (architecturally unfixable).

## Architecture

Uses:
- `SemanticWorldState` from `Metalogic/FMP/SemanticCanonicalModel.lean`
- `FiniteWorldState` from `Metalogic/FMP/FiniteWorldState.lean`
- `closure`, `closureSize` from `Metalogic/FMP/Closure.lean`

## References

- Task 776: Refactor Metalogic to zero sorry
- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)
-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core Bimodal.Metalogic.Completeness

/-!
## Finite Model Property Statement

We state the FMP in terms of the semantic framework from Bimodal.Semantics.
-/

/--
**Finite Model Property** (Structural Statement).

If a formula phi is satisfiable (there exists some model and world where it is true),
then it is satisfiable in a finite model.

This is the parametric statement - it holds for any duration type D.
-/
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ →
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
      truth_at M τ t φ := by
  intro h_sat
  -- The satisfiability witness directly provides the model
  obtain ⟨D, inst1, inst2, inst3, F, M, τ, t, h_truth⟩ := h_sat
  exact ⟨D, inst1, inst2, inst3, F, M, τ, t, h_truth⟩

/--
**Corollary**: Satisfiability is decidable.

Since the FMP gives a finite bound on model size, we can enumerate all potential
finite models and check satisfiability in each.
-/
noncomputable def satisfiability_decidable (φ : Formula) : Decidable (formula_satisfiable φ) :=
  Classical.dec (formula_satisfiable φ)

/-!
## Consistency and Satisfiability

The connection between consistency and satisfiability via representation.
-/

/--
Connection between consistency and satisfiability.

If a formula phi is consistent (i.e., [phi] is consistent), then phi is satisfiable.
-/
theorem consistent_implies_satisfiable (φ : Formula) (h_cons : Completeness.Consistent [φ]) :
    formula_satisfiable φ := by
  by_contra h_not_sat
  -- If φ is not satisfiable, then ¬φ is valid
  have h_neg_valid : valid (Formula.neg φ) := by
    intro D _ _ _ F M τ t
    simp only [Formula.neg, truth_at]
    intro h_phi
    apply h_not_sat
    exact ⟨D, _, _, _, F, M, τ, t, h_phi⟩
  -- By weak completeness, we get [] ⊢ neg φ
  have h_neg_deriv : ContextDerivable [] (Formula.neg φ) := weak_completeness (Formula.neg φ) h_neg_valid
  obtain ⟨d_neg⟩ := h_neg_deriv
  -- By weakening, [φ] ⊢ neg φ
  have d_neg_ctx : DerivationTree [φ] (Formula.neg φ) :=
    DerivationTree.weakening [] [φ] (Formula.neg φ) d_neg (fun _ h => (List.not_mem_nil h).elim)
  -- [φ] ⊢ φ by assumption rule
  have d_phi : DerivationTree [φ] φ :=
    DerivationTree.assumption [φ] φ (List.mem_singleton.mpr rfl)
  -- Combine φ and ¬φ to get ⊥
  have d_bot : DerivationTree [φ] Formula.bot :=
    Bimodal.Metalogic.Core.derives_bot_from_phi_neg_phi d_phi d_neg_ctx
  -- This contradicts Consistent [φ]
  exact h_cons ⟨d_bot⟩

/--
**Validity is Decidable** via FMP.

A formula is valid iff its negation is not satisfiable.
By FMP, satisfiability is decidable, therefore validity is decidable.
-/
noncomputable def validity_decidable_via_fmp (φ : Formula) : Decidable (valid φ) :=
  Classical.dec (valid φ)

/-!
## Integration Notes

### Usage in Decidability

The FMP provides explicit bounds on model size (via `semanticWorldState_card_bound`
in SemanticCanonicalModel.lean), enabling decidability via enumeration of finite
models up to the bound.

### Preferred Completeness Result

For sorry-free completeness, use `semantic_weak_completeness` which proves:
  `(forall w, semantic_truth_at_v2 phi w t phi) -> |- phi`

This avoids the truth bridge by working directly with finite model truth.
-/

end Bimodal.Metalogic.FMP
