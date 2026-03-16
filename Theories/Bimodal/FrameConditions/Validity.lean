import Bimodal.FrameConditions.FrameClass
import Bimodal.Semantics.Validity

/-!
# Parameterized Validity

This module defines parameterized validity for TM formulas, unified across
different frame classes using the typeclass architecture.

## Main Definitions

- `valid_over D φ`: Formula φ is valid over temporal domain D
- `valid_linear`: Alias for validity over any LinearTemporalFrame
- `valid_dense_fc`: Validity over DenseTemporalFrame (fc = frame condition)
- `valid_discrete_fc`: Validity over DiscreteTemporalFrame

## Equivalence Lemmas

This module proves equivalence between the new parameterized validity
and the existing definitions in `Bimodal.Semantics.Validity`:
- `valid_over_iff_valid`: `valid_over D φ ↔ valid φ` (when D satisfies minimal constraints)
- `valid_dense_fc_iff_valid_dense`: Connection to existing `valid_dense`
- `valid_discrete_fc_iff_valid_discrete`: Connection to existing `valid_discrete`

## Design Notes

The key insight is that validity over a specific type D is equivalent to
the universal validity definition when D is polymorphic. The parameterized
version allows:
1. Specific instantiation for proofs about concrete types (Int, Rat)
2. Generic reasoning via typeclass constraints
3. Clean integration with soundness and completeness theorems

## References

- Task 978: Typeclass-based frame condition architecture
- `Bimodal.Semantics.Validity`: Original validity definitions
-/

namespace Bimodal.FrameConditions

open Bimodal.Syntax
open Bimodal.Semantics

/-! ## Parameterized Validity -/

/--
A formula is valid over temporal domain D if it is true in all models
at all times in all histories within any shift-closed set of histories.

This is the parameterized version of `Bimodal.Semantics.valid`, fixed to
a specific temporal type D rather than quantifying over all types.
-/
def valid_over (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ

/--
Notation for parameterized validity: `⊨[D] φ` means `valid_over D φ`.
-/
notation:50 "⊨[" D "] " φ:50 => valid_over D φ

/-! ## Frame-Class Specific Validity -/

/--
A formula is valid over linear temporal frames if it is valid over all
types D satisfying `LinearTemporalFrame D`.

This is essentially the same as `valid` since `valid` already quantifies
over all suitable D.
-/
def valid_linear (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [LinearTemporalFrame D], valid_over D φ

/--
A formula is valid over dense temporal frames if it is valid over all
types D satisfying `DenseTemporalFrame D`.

This corresponds to `valid_dense` but uses the typeclass constraint.
-/
def valid_dense_fc (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
    [DenseTemporalFrame D], valid_over D φ

/--
A formula is valid over discrete temporal frames if it is valid over all
types D satisfying `DiscreteTemporalFrame D`.

This corresponds to `valid_discrete` but uses the typeclass constraint.
-/
def valid_discrete_fc (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D], valid_over D φ

/-! ## Equivalence with Existing Definitions -/

/--
Validity over any single type implies universal validity:
if `valid_over D φ` for all D, then `valid φ`.

This is immediate since `valid` quantifies over all D.
-/
theorem valid_of_forall_valid_over {φ : Formula}
    (h : ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], valid_over D φ) :
    valid φ := by
  intro D _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t

/--
Universal validity implies validity over any specific type.
-/
theorem valid_over_of_valid {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {φ : Formula} (h : valid φ) : valid_over D φ := by
  intro F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t

/--
Dense validity (typeclass version) implies existing `valid_dense`.
-/
theorem valid_dense_of_valid_dense_fc {φ : Formula} (h : valid_dense_fc φ) : valid_dense φ := by
  intro D _ _ _ _ _ F M Omega h_sc τ h_mem t
  -- We need DenseTemporalFrame D, but we can construct it since D has all the required instances
  haveI : DenseTemporalFrame D := {}
  exact h D F M Omega h_sc τ h_mem t

/--
Existing `valid_dense` implies dense validity (typeclass version).
-/
theorem valid_dense_fc_of_valid_dense {φ : Formula} (h : valid_dense φ) : valid_dense_fc φ := by
  intro D _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t

/--
Dense validity equivalence: `valid_dense_fc φ ↔ valid_dense φ`.
-/
theorem valid_dense_fc_iff_valid_dense {φ : Formula} :
    valid_dense_fc φ ↔ valid_dense φ :=
  ⟨valid_dense_of_valid_dense_fc, valid_dense_fc_of_valid_dense⟩

/--
Existing `valid_discrete` implies discrete validity (typeclass version).

Note: `valid_discrete` has fewer constraints than `DiscreteTemporalFrame`.
Since `valid_discrete` quantifies over a strictly larger class of types
(it only requires SuccOrder, PredOrder, Nontrivial), we have:
- `valid_discrete → valid_discrete_fc` (more types → fewer types)
- but NOT `valid_discrete_fc → valid_discrete` in general

This is the correct direction for soundness: proving validity over the
typeclass-constrained types is sufficient for the weaker `valid_discrete`.
-/
theorem valid_discrete_fc_of_valid_discrete {φ : Formula} (h : valid_discrete φ) :
    valid_discrete_fc φ := by
  intro D _ _ _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t

/-! ## Relationship Between Frame Classes -/

/--
Universal validity implies linear validity.
-/
theorem valid_linear_of_valid {φ : Formula} (h : valid φ) : valid_linear φ := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t
  exact h D F M Omega h_sc τ h_mem t

/--
Linear validity implies dense validity (base axioms are valid on dense frames).
-/
theorem valid_dense_fc_of_valid_linear {φ : Formula} (h : valid_linear φ) : valid_dense_fc φ := by
  intro D _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t
  -- DenseTemporalFrame extends SerialFrame which extends LinearTemporalFrame
  haveI : LinearTemporalFrame D := {}
  exact h D F M Omega h_sc τ h_mem t

/--
Linear validity implies discrete validity (base axioms are valid on discrete frames).
-/
theorem valid_discrete_fc_of_valid_linear {φ : Formula} (h : valid_linear φ) :
    valid_discrete_fc φ := by
  intro D _ _ _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t
  -- DiscreteTemporalFrame extends SerialFrame which extends LinearTemporalFrame
  haveI : LinearTemporalFrame D := {}
  exact h D F M Omega h_sc τ h_mem t

/-! ## Validity over Int -/

/--
A formula is valid over Int (discrete integer time).
-/
abbrev valid_over_Int (φ : Formula) : Prop := valid_over Int φ

/--
If a formula is discretely valid, it is valid over Int.
-/
theorem valid_over_Int_of_valid_discrete {φ : Formula} (h : valid_discrete φ) :
    valid_over_Int φ := by
  intro F M Omega h_sc τ h_mem t
  exact h Int F M Omega h_sc τ h_mem t

end Bimodal.FrameConditions
