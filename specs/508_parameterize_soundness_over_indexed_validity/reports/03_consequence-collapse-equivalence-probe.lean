/-
Task 508, Phase 7 evidence artifact.

Each of the four collapsed `SemanticConsequence*` definitions is proved propositionally
equivalent to the hand-written binder list it replaced. The right-hand sides below are the
pre-collapse bodies, transcribed verbatim from commit bee03a881.

Checked with:

    lake env lean specs/508_parameterize_soundness_over_indexed_validity/reports/03_consequence-collapse-equivalence-probe.lean

which exits 0 with no output. Kept out of `FormalSystem/` deliberately: it is a one-shot
verification record, not library content.
-/

import FormalSystem.Metalogic.StrongCompleteness
open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.Metalogic
open FormalSystem.ProofSystem

/- Each collapsed definition is propositionally equivalent to the hand-written binder list it
   replaced.  These are the pre-collapse bodies, transcribed verbatim from commit bee03a881. -/

example (Γ : Context) (φ : Formula) :
    SemanticConsequence Γ φ ↔
      (∀ (F : TaskFrame) (M : TaskModel F)
        (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
        (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :=
  ⟨fun h F M τ hτ t hall => h.apply F M τ hτ t hall,
   fun h => SemanticConsequence.of_forall fun F M τ hτ t hall => h F M τ hτ t hall⟩

example (Γ : Context) (φ : Formula) :
    SemanticConsequenceDense Γ φ ↔
      (∀ (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
        (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
        (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :=
  ⟨fun h F _ M τ hτ t hall => h.apply F M τ hτ t hall,
   fun h => SemanticConsequenceDense.of_forall fun F _ M τ hτ t hall => h F M τ hτ t hall⟩

example (Γ : Context) (φ : Formula) :
    SemanticConsequenceDiscrete Γ φ ↔
      (∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
        [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
        (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
        (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :=
  ⟨fun h F _ _ _ _ M τ hτ t hall => h.apply F M τ hτ t hall,
   fun h => SemanticConsequenceDiscrete.of_forall
     fun F _ _ _ _ M τ hτ t hall => h F M τ hτ t hall⟩

example (Γ : Context) (φ : Formula) :
    SemanticConsequenceDedekindDense Γ φ ↔
      (∀ (F : TaskFrame) [DenselyOrdered F.Duration]
        (_ : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
        (M : TaskModel F)
        (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
        (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) :=
  ⟨fun h F _ hlub M τ hτ t hall => h.apply F hlub M τ hτ t hall,
   fun h => SemanticConsequenceDedekindDense.of_forall
     fun F _ hlub M τ hτ t hall => h F hlub M τ hτ t hall⟩
