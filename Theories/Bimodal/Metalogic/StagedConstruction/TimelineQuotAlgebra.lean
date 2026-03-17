import Bimodal.Metalogic.StagedConstruction.CantorApplication
import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.FrameConditions.FrameClass

/-!
# TimelineQuot Algebraic Structure

This module establishes the algebraic structure required for `TimelineQuot` to serve
as the temporal domain in the dense completeness theorem.

## Overview

`TimelineQuot` is the Antisymmetrization of the dense staged timeline, proven to be
order-isomorphic to Q via Cantor's theorem. This module uses `DurationTransfer` to
lift `AddCommGroup` and `IsOrderedAddMonoid` from Q to TimelineQuot.

## Main Results

- `timelineQuotAddCommGroup`: AddCommGroup structure on TimelineQuot
- `timelineQuotIsOrderedAddMonoid`: Order-compatible monoid structure
- `timelineQuot_satisfies_dense_constraints`: TimelineQuot satisfies all DenseCompletenessStatement constraints

## Design Notes

The AddCommGroup structure is purely derived from the Cantor isomorphism. The
actual addition operation on TimelineQuot is: `a + b := iso.symm (iso a + iso b)`.
This is artificial from the syntactic perspective (TimelineQuot elements are
equivalence classes of MCSs, not numbers), but mathematically sound for
completeness purposes since we only need the group structure for validity
quantification.

## References

- Task 982: Wire dense completeness domain connection
- Task 956: D construction via Cantor
- DurationTransfer.lean: Generic algebra transfer infrastructure
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Domain
open Bimodal.FrameConditions

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## AddCommGroup on TimelineQuot

We use `DurationTransfer.ratAddCommGroup` which requires:
- LinearOrder (have)
- Countable (have)
- DenselyOrdered (have)
- NoMaxOrder (have)
- NoMinOrder (have)
- Nonempty (have)

All these instances are established in CantorApplication.lean.
-/

/--
AddCommGroup structure on TimelineQuot, transferred from Q via the Cantor isomorphism.

The addition is defined as: `a + b := iso.symm (iso a + iso b)` where `iso : TimelineQuot ≃o Q`.
-/
noncomputable def timelineQuotAddCommGroup :
    AddCommGroup (TimelineQuot root_mcs root_mcs_proof) :=
  ratAddCommGroup (TimelineQuot root_mcs root_mcs_proof)

/--
IsOrderedAddMonoid structure on TimelineQuot, transferred from Q.

This ensures the addition is compatible with the linear order.
-/
theorem timelineQuotIsOrderedAddMonoid :
    @IsOrderedAddMonoid (TimelineQuot root_mcs root_mcs_proof)
      (timelineQuotAddCommGroup root_mcs root_mcs_proof).toAddCommMonoid
      (inferInstance : PartialOrder (TimelineQuot root_mcs root_mcs_proof)) :=
  ratIsOrderedAddMonoid (TimelineQuot root_mcs root_mcs_proof)

/-!
## Nontrivial Instance

TimelineQuot is nontrivial because it has distinct elements (no max/min means at least 2).
-/

/--
TimelineQuot is nontrivial: it has at least two distinct elements.

Proof: By NoMaxOrder, any element `a` has some `b > a`. Since `b > a`, they are distinct.
-/
instance timelineQuotNontrivial : Nontrivial (TimelineQuot root_mcs root_mcs_proof) := by
  obtain ⟨a⟩ : Nonempty (TimelineQuot root_mcs root_mcs_proof) := inferInstance
  obtain ⟨b, hab⟩ := NoMaxOrder.exists_gt a
  exact ⟨⟨a, b, ne_of_lt hab⟩⟩

/-!
## Instantiation Lemma

This section provides a lemma showing that TimelineQuot can instantiate universal
quantifications over dense temporal domains.
-/

/--
TimelineQuot satisfies all constraints required for dense validity quantification.

Given any property P that holds for all dense temporal domains D, we can instantiate
P at D = TimelineQuot by providing the required typeclass instances.

This is the key lemma for wiring the completeness proof: if `valid_over D φ` holds
for all D satisfying the dense constraints, then it holds for TimelineQuot.
-/
theorem timelineQuot_instantiate_dense {P : Type → Prop}
    (h : ∀ (D : Type)
      [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
      [DenseTemporalFrame D], P D) :
    P (TimelineQuot root_mcs root_mcs_proof) := by
  letI acg := timelineQuotAddCommGroup root_mcs root_mcs_proof
  letI oam := timelineQuotIsOrderedAddMonoid root_mcs root_mcs_proof
  letI : DenseTemporalFrame (TimelineQuot root_mcs root_mcs_proof) := {}
  exact h (TimelineQuot root_mcs root_mcs_proof)

end Bimodal.Metalogic.StagedConstruction
