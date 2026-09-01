/-
NEGATIVE CONTROL — THIS FILE IS EXPECTED TO FAIL TO COMPILE.

It records the four call-site shapes that do NOT survive the redefinition
  `SatisfiableDiscreteSet := SatisfiableSet .Discrete`
  `SatisfiableDenseSet   := SatisfiableSet .Dense`
unchanged, together with the exact errors Lean reports.  The verified repairs are in
`probe_509c.lean`, which compiles clean.

Recorded errors (lake env lean, Lean v4.33.0-rc1):

  B1 :29:12  Application type mismatch: `so : SuccOrder F.Duration.carrier` (Type) but expected
             `FrameClass.Discrete.Sat F` (Prop).  The anonymous constructor does NOT unfold the
             plain `def TaskFrame.IsSuccArchDiscrete` to find the nested `Exists`, so the flat
             10-component tuple no longer elaborates.
  B2 :33:9   rcases failed: same cause, on the `rintro ⟨F, _, _, _, _, M, τ, hτ, t, h⟩` pattern.
  B3 :43     three `type class instance expected` errors, same cause.
  B5 :70:4   `type class instance expected  FrameClass.Dense.Sat (...).frame` — a bare
             `inferInstance` cannot discharge `Sat .Dense F`, because that unfolds to
             `TaskFrame.IsDense F`, whose head symbol is not `DenselyOrdered`.  (This is the same
             invisibility already documented on `SetSemanticConsequenceDense.of_forall`.)

  B4 (the `modelExistenceBase` ultraproduct proof with a single `trivial` inserted) SUCCEEDS,
  with axioms exactly [propext, Classical.choice, Quot.sound].
-/
/- Probe B: do today's call-site tuple shapes survive the redefinition
   `SatisfiableDiscreteSet := SatisfiableSet .Discrete` and
   `SatisfiableBaseSet    := SatisfiableSet .Base`?  Nothing under FormalSystem/ is modified. -/
import FormalSystem.Metalogic.Compactness
import FormalSystem.Metalogic.DiscreteNonCompactness

namespace FormalSystem.Metalogic
namespace Probe509B

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

/-! ### B1: `archWitness_finitely_satisfiable`'s introduction tuple, verbatim. -/
example (p : Atom) (L : List Formula) (hL : ∀ ψ ∈ L, ψ ∈ archWitness p) :
    SatisfiableSet FrameClass.Discrete {ψ | ψ ∈ L} := by
  have h := archWitness_finitely_satisfiable p L hL
  -- today's shape, re-offered against the indexed definition with NO extra nesting
  obtain ⟨F, so, po, hsa, hpa, M, τ, hτ, t, hsat⟩ := h
  exact ⟨F, so, po, hsa, hpa, M, τ, hτ, t, hsat⟩

/-! ### B2: `archWitness_not_satisfiable`'s `rintro` pattern, verbatim. -/
example (p : Atom) : ¬ SatisfiableSet FrameClass.Discrete (archWitness p) := by
  rintro ⟨F, _, _, _, _, M, τ, hτ, t, h⟩
  exact archWitness_not_satisfiable p ⟨F, inferInstance, inferInstance, inferInstance,
    inferInstance, M, τ, hτ, t, h⟩

/-! ### B3: `discrete_consequence_not_compact`'s inline `absurd` tuple, verbatim. -/
example (p : Atom) (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
    [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (hall : ∀ ψ ∈ archWitness p, TruthAt M τ t ψ) :
    SatisfiableSet FrameClass.Discrete (archWitness p) :=
  ⟨F, inferInstance, inferInstance, inferInstance, inferInstance, M, τ, hτ, t, hall⟩

/-! ### B4: the ultraproduct proof of `modelExistenceBase`, verbatim except one `trivial`. -/
theorem modelExistenceBase' : ModelExistence FrameClass.Base := by
  classical
  intro Γ hfin
  choose F hF M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    trivial,
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

/-! ### B5: the ultraproduct proof of `modelExistenceDense`, verbatim (nothing to change). -/
theorem modelExistenceDense' : ModelExistence FrameClass.Dense := by
  classical
  intro Γ hfin
  choose F hd M τ hτ t ht using fun (i : Idx Γ) => hfin i.val i.property
  haveI : ∀ i, DenselyOrdered ((F i).Duration : Type) := hd
  refine ⟨(uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame,
    inferInstance,
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

/-! ### B6: Dedekind adapters — `IsDedekind = IsDense ∧ IsComplete`. -/
theorem satisfiableDedekind_of_forall {Γ : Set Formula} (F : TaskFrame)
    [inst : DenselyOrdered F.Duration]
    (hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration)
    (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : SatisfiableSet FrameClass.Dedekind Γ :=
  ⟨F, ⟨inst, hlub⟩, M, τ, hτ, t, h⟩

#print axioms modelExistenceBase'
#print axioms modelExistenceDense'

end Probe509B
end FormalSystem.Metalogic
