/-
Compiled probe for the FrameClass-indexed compactness / strong-completeness family.
Run with:  lake env lean specs/509_.../reports/probe_509.lean
Nothing under FormalSystem/ is modified by this file.
-/
import FormalSystem.Metalogic.Compactness
import FormalSystem.Metalogic.DiscreteNonCompactness

namespace FormalSystem.Metalogic
namespace Probe509

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/-! ## Part A — the indexed family, defined once -/

def SatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  ∃ (F : TaskFrame) (_ : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

def ModelExistence (fc : FrameClass) : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableSet fc {ψ | ψ ∈ L}) →
    SatisfiableSet fc Γ

def Compact (fc : FrameClass) : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceOn fc Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidIn fc (L.foldr Formula.imp φ)

def StrongCompleteness (fc : FrameClass) : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceOn fc Γ φ → SetDerivable fc Γ φ

/-! ## Part B — definitional-equality audit against today's hand-copied names -/

-- Compact: all three per-class names are DEFEQ to the indexed form.
example : Compact FrameClass.Base = CompactBase := rfl
example : Compact FrameClass.Dense = CompactDense := rfl
example : Compact FrameClass.Discrete = CompactDiscrete := rfl

-- StrongCompleteness: all three per-class names are DEFEQ to the indexed form.
example : StrongCompleteness FrameClass.Base = StrongCompletenessBase := rfl
example : StrongCompleteness FrameClass.Dense = StrongCompletenessDense := rfl
example : StrongCompleteness FrameClass.Discrete = StrongCompletenessDiscrete := rfl

-- SatisfiableSet at .Dense is DEFEQ (IsDense F unfolds to DenselyOrdered F.Duration).
example : SatisfiableSet FrameClass.Dense = SatisfiableDenseSet := rfl
example : ModelExistence FrameClass.Dense = ModelExistenceDense := rfl

-- SatisfiableSet at .Base / .Discrete: propositionally equivalent, NOT defeq.
example (Γ : Set Formula) : SatisfiableSet FrameClass.Base Γ ↔ SatisfiableBaseSet Γ :=
  ⟨fun ⟨F, _, M, τ, hτ, t, h⟩ => ⟨F, M, τ, hτ, t, h⟩,
   fun ⟨F, M, τ, hτ, t, h⟩ => ⟨F, trivial, M, τ, hτ, t, h⟩⟩

example (Γ : Set Formula) : SatisfiableSet FrameClass.Discrete Γ ↔ SatisfiableDiscreteSet Γ :=
  ⟨fun ⟨F, ⟨so, po, hsa, hpa⟩, M, τ, hτ, t, h⟩ => ⟨F, so, po, hsa, hpa, M, τ, hτ, t, h⟩,
   fun ⟨F, so, po, hsa, hpa, M, τ, hτ, t, h⟩ => ⟨F, ⟨so, po, hsa, hpa⟩, M, τ, hτ, t, h⟩⟩

/-! ## Part C — the ONE strong-completeness reduction -/

theorem strongCompleteness_of_compact {fc : FrameClass} (hc : Compact fc)
    (engine : ∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ) :
    StrongCompleteness fc := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩

/-! ## Part D — the missing generic `of_not`, and the ONE model-existence bridge -/

theorem ValidIn_of_not {fc : FrameClass} {φ : Formula} (h : ¬ ValidIn fc φ) :
    ¬ ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
        τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidIn.of_forall_total h')

theorem compact_of_modelExistence {fc : FrameClass} (h : ModelExistence fc) : Compact fc := by
  classical
  intro Γ φ hcons
  by_contra hno
  push Not at hno
  have hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ insert φ.neg Γ) →
      SatisfiableSet fc {ψ | ψ ∈ L} := by
    intro L hL
    have hsub : ∀ ψ ∈ L.filter (fun ψ => decide (ψ ∈ Γ)), ψ ∈ Γ := by
      intro ψ hψ
      exact of_decide_eq_true (List.mem_filter.mp hψ).2
    have hnv := ValidIn_of_not (hno _ hsub)
    push Not at hnv
    obtain ⟨F, hF, M, τ, hτ, t, hfalse⟩ := hnv
    rw [truthAt_foldr_imp] at hfalse
    push Not at hfalse
    obtain ⟨hall, hnφ⟩ := hfalse
    refine ⟨F, hF, M, τ, hτ, t, ?_⟩
    intro ψ hψ
    by_cases hg : ψ ∈ Γ
    · exact hall ψ (List.mem_filter.mpr ⟨hψ, decide_eq_true hg⟩)
    · rcases hL ψ hψ with rfl | hmem
      · exact fun hp => hnφ hp
      · exact absurd hmem hg
  obtain ⟨F, hF, M, τ, hτ, t, hsat⟩ := h _ hfin
  exact hsat φ.neg (Set.mem_insert _ _)
    (hcons F hF M τ hτ t (fun ψ hψ => hsat ψ (Set.mem_insert_of_mem _ hψ)))

/-! ## Part E — the existing results recovered as instantiations -/

-- Dense: everything is defeq, so the instantiation is direct.
theorem compactDense' : CompactDense := compact_of_modelExistence (fc := FrameClass.Dense)
  modelExistenceDense

theorem strongCompletenessDense' : StrongCompletenessDense :=
  strongCompleteness_of_compact (fc := FrameClass.Dense) compactDense' completeness_dense

-- Base: `ModelExistence .Base` reached from today's `modelExistenceBase` by the Part B iso.
-- In the real implementation `ModelExistenceBase := ModelExistence .Base` and the ultraproduct
-- proof gains a single `trivial`; this transport exists only so the probe needs no tree edit.
theorem modelExistenceBase' : ModelExistence FrameClass.Base := by
  intro Γ hfin
  obtain ⟨F, M, τ, hτ, t, h⟩ := modelExistenceBase Γ (fun L hL => by
    obtain ⟨F, _, M, τ, hτ, t, h⟩ := hfin L hL
    exact ⟨F, M, τ, hτ, t, h⟩)
  exact ⟨F, trivial, M, τ, hτ, t, h⟩

theorem compactBase' : CompactBase := compact_of_modelExistence (fc := FrameClass.Base)
  modelExistenceBase'

theorem strongCompletenessBase' : StrongCompletenessBase :=
  strongCompleteness_of_compact (fc := FrameClass.Base) compactBase' completeness_base

-- Discrete: the reduction still applies; only the antecedents are unavailable (and refuted).
theorem strongCompletenessDiscrete_of_compact (hc : CompactDiscrete) :
    StrongCompletenessDiscrete :=
  strongCompleteness_of_compact (fc := FrameClass.Discrete) hc completeness_discrete

-- Dedekind: the fourth row, free. This is the whole of what the follow-on task's Part 1 needs.
abbrev SatisfiableDedekindDenseSet : Set Formula → Prop := SatisfiableSet FrameClass.Dedekind
abbrev ModelExistenceDedekindDense : Prop := ModelExistence FrameClass.Dedekind
abbrev CompactDedekindDense : Prop := Compact FrameClass.Dedekind
abbrev StrongCompletenessDedekindDense : Prop := StrongCompleteness FrameClass.Dedekind

theorem compactDedekindDense_of_modelExistence (h : ModelExistenceDedekindDense) :
    CompactDedekindDense := compact_of_modelExistence h

theorem strongCompletenessDedekindDense_of_compact (hc : CompactDedekindDense) :
    StrongCompletenessDedekindDense :=
  strongCompleteness_of_compact hc (fun ψ hψ => completeness_dedekind ψ hψ)

/-! ## Part F — axiom profiles unchanged -/

#print axioms compactBase'
#print axioms compactDense'
#print axioms strongCompletenessBase'
#print axioms strongCompletenessDense'
#print axioms compact_of_modelExistence
#print axioms strongCompleteness_of_compact

end Probe509
end FormalSystem.Metalogic
