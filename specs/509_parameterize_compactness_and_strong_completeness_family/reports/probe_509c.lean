/- Probe C: the exact call-site repairs the two friction points need. -/
import FormalSystem.Metalogic.Compactness
import FormalSystem.Metalogic.DiscreteNonCompactness

namespace FormalSystem.Metalogic
namespace Probe509C

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.Semantics.Ultraproduct Filter

def SatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  ∃ (F : TaskFrame) (_ : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

def ModelExistence (fc : FrameClass) : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableSet fc {ψ | ψ ∈ L}) →
    SatisfiableSet fc Γ

/-! ### C0: the binder-shape adapters, mirroring `SetSemanticConsequence*.of_forall/apply`. -/

theorem SatisfiableSet.base_of_forall {Γ : Set Formula} (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Base Γ := ⟨F, trivial, M, τ, hτ, t, h⟩

theorem SatisfiableSet.dense_of_forall {Γ : Set Formula} (F : TaskFrame)
    [inst : DenselyOrdered F.Duration] (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Dense Γ := ⟨F, inst, M, τ, hτ, t, h⟩

theorem SatisfiableSet.discrete_of_forall {Γ : Set Formula} (F : TaskFrame)
    [so : SuccOrder F.Duration] [po : PredOrder F.Duration]
    [hsa : IsSuccArchimedean F.Duration] [hpa : IsPredArchimedean F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Discrete Γ := ⟨F, ⟨so, po, hsa, hpa⟩, M, τ, hτ, t, h⟩

/-! ### C1: `archWitness_finitely_satisfiable`, repaired by ONE nesting pair. -/
example (p : Atom) (L : List Formula) (hL : ∀ ψ ∈ L, ψ ∈ archWitness p) :
    SatisfiableSet FrameClass.Discrete {ψ | ψ ∈ L} := by
  obtain ⟨F, so, po, hsa, hpa, M, τ, hτ, t, hsat⟩ := archWitness_finitely_satisfiable p L hL
  exact ⟨F, ⟨so, po, hsa, hpa⟩, M, τ, hτ, t, hsat⟩

/-! ### C1': …and via the adapter, so the original `refine` needs no reshaping at all. -/
example (p : Atom) (L : List Formula) (hL : ∀ ψ ∈ L, ψ ∈ archWitness p) :
    SatisfiableSet FrameClass.Discrete {ψ | ψ ∈ L} := by
  obtain ⟨F, _, _, _, _, M, τ, hτ, t, hsat⟩ := archWitness_finitely_satisfiable p L hL
  exact SatisfiableSet.discrete_of_forall F M τ hτ t hsat

/-! ### C2: the `rintro` pattern, repaired by ONE nesting pair. -/
example (p : Atom) : ¬ SatisfiableSet FrameClass.Discrete (archWitness p) := by
  rintro ⟨F, ⟨_, _, _, _⟩, M, τ, hτ, t, h⟩
  exact archWitness_not_satisfiable p ⟨F, inferInstance, inferInstance, inferInstance,
    inferInstance, M, τ, hτ, t, h⟩

/-! ### C3: `modelExistenceDense`, repaired by an ascribed `inferInstance`. -/
theorem modelExistenceDense' : ModelExistence FrameClass.Dense := by
  classical
  intro Γ hfin
  choose F hd M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  haveI : ∀ i, DenselyOrdered ((F i).Duration : Type) := hd
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    (inferInstance : DenselyOrdered
      (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame.Duration),
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).model,
    (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).hist
      (omk (fun i => (⟨τ i, hτ i⟩ : (F i).HF))),
    ShiftSet.hist_isTotal _ _, Ultraproduct.mk (fun i => t i), ?_⟩
  intro ψ hψ
  refine (los_truthAt (fun i => ShiftSet.ofModel (F i) (M i)) _ _ ψ).mpr ?_
  refine (eventually_mem Γ hψ).mono ?_
  intro i hi
  exact (ShiftSet.forward_repr _ _ _ ψ).mpr
    ((ShiftSet.reverse_repr (F i) (M i) ⟨τ i, hτ i⟩ (t i) ψ).mpr (ht i ψ hi))

/-! ### C4: `choose` still splits `SatisfiableSet fc` uniformly (the Dense hypothesis lands
    as `hd i : Sat .Dense (F i)`, which `haveI` above accepts). -/
example (Γ : Set Formula) (h : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) →
    SatisfiableSet FrameClass.Dense {ψ | ψ ∈ L}) : True := by
  choose F hd M τ hτ t ht using fun (i : Idx Γ) => h i.val i.property
  haveI : ∀ i, DenselyOrdered ((F i).Duration : Type) := hd
  trivial

#print axioms modelExistenceDense'

end Probe509C
end FormalSystem.Metalogic
