import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra
import Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness

/-!
# Separated TaskFrame: D = TimelineQuot, W = CanonicalMCS

This module instantiates the parametric canonical TaskFrame with D = TimelineQuot,
achieving the W/D separation required for dense completeness.

## Key Insight (Task 982, research-009)

The dense completeness blocker arose from conflating two architecturally distinct components:
- **D** (Duration/Time Domain): Needs LinearOrder + DenselyOrdered (TimelineQuot provides this)
- **W** (World States): Space of all MCSs (ParametricCanonicalWorldState provides this)

Previous approaches failed because:
1. Using TimelineQuot for BOTH D and W forced witnesses to be in Range(h)
2. The m > 2k edge case meant some witnesses weren't in the staged timeline

The W/D separation resolves this:
- Witnesses exist in W (ALL MCSs are available as world states)
- They DON'T need to be at any particular time in D

## Main Definitions

- `SeparatedCanonicalTaskFrame`: ParametricCanonicalTaskFrame instantiated at TimelineQuot
- Helper lemmas connecting TimelineQuot times to MCS world states

## References

- Task 982: Wire dense completeness domain connection
- research-009.md: Semantics architecture analysis
- implementation-007.md: W/D separation approach
-/

namespace Bimodal.Metalogic.Algebraic.SeparatedTaskFrame

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
open Bimodal.Semantics

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

-- Provide the typeclass instances for TimelineQuot as local instances
attribute [local instance] timelineQuotAddCommGroup timelineQuotIsOrderedAddMonoid

/-!
## Separated TaskFrame Definition

The separated TaskFrame uses:
- D = TimelineQuot root_mcs root_mcs_proof (the dense time domain from syntax)
- W = ParametricCanonicalWorldState (ALL MCSs)
-/

/--
The separated canonical TaskFrame: D = TimelineQuot, W = ALL MCSs.

This achieves the W/D separation where:
- D provides the dense linear order required for validity
- W provides access to ALL MCSs as world states (for witness availability)
- The task_rel uses CanonicalR between MCSs (independent of D's specific structure)

Note: The typeclass instances for TimelineQuot (AddCommGroup, IsOrderedAddMonoid)
are provided via local attributes above.
-/
noncomputable def SeparatedCanonicalTaskFrame :
    TaskFrame (TimelineQuot root_mcs root_mcs_proof) :=
  ParametricCanonicalTaskFrame (TimelineQuot root_mcs root_mcs_proof)

/-!
## WorldState Access

The WorldState of SeparatedCanonicalTaskFrame is ParametricCanonicalWorldState,
which contains ALL MCSs (not just those in TimelineQuot).
-/

/--
The WorldState of the separated TaskFrame is ParametricCanonicalWorldState.
This contains ALL MCSs, not just those appearing in the TimelineQuot timeline.
-/
theorem separatedCanonicalTaskFrame_WorldState :
    (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).WorldState =
    ParametricCanonicalWorldState := rfl

/-!
## Task Relation Properties

The task relation is parametric_canonical_task_rel, which uses CanonicalR.
-/

/--
The task relation of the separated TaskFrame.

For d > 0: CanonicalR M.val N.val (forward accessibility)
For d = 0: M = N (identity)
For d < 0: CanonicalR N.val M.val (backward accessibility)
-/
theorem separatedCanonicalTaskFrame_task_rel :
    (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel =
    parametric_canonical_task_rel := rfl

/-!
## Derived Properties

The TaskFrame axioms (nullity_identity, forward_comp, converse) are inherited
from ParametricCanonicalTaskFrame, which proves them generically for any D.
-/

/--
Nullity identity: zero-duration task relates exactly identical states.
-/
theorem separatedCanonicalTaskFrame_nullity_identity
    (M N : ParametricCanonicalWorldState) :
    (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel M 0 N ↔ M = N :=
  (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).nullity_identity M N

/--
Nullity: zero-duration task is reflexive.
-/
theorem separatedCanonicalTaskFrame_nullity (M : ParametricCanonicalWorldState) :
    (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel M 0 M :=
  (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).nullity M

/--
Forward compositionality: tasks compose for non-negative durations.
-/
theorem separatedCanonicalTaskFrame_forward_comp
    (M U V : ParametricCanonicalWorldState)
    (x y : TimelineQuot root_mcs root_mcs_proof)
    (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h1 : (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel M x U)
    (h2 : (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel U y V) :
    (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel M (x + y) V :=
  (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).forward_comp M U V x y hx hy h1 h2

/--
Converse: task relation is symmetric under duration negation.
-/
theorem separatedCanonicalTaskFrame_converse
    (M : ParametricCanonicalWorldState)
    (d : TimelineQuot root_mcs root_mcs_proof)
    (N : ParametricCanonicalWorldState) :
    (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel M d N ↔
    (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).task_rel N (-d) M :=
  (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof).converse M d N

/-!
## Connection to TimelineQuot MCS

Each time t in TimelineQuot has an associated MCS (via timelineQuotMCS).
This MCS can be lifted to a ParametricCanonicalWorldState.
-/

/--
Lift a TimelineQuot time to its corresponding ParametricCanonicalWorldState.

This wraps the MCS at time t into the WorldState type of the separated TaskFrame.
-/
noncomputable def timelineQuotToWorldState
    (t : TimelineQuot root_mcs root_mcs_proof) : ParametricCanonicalWorldState :=
  ⟨timelineQuotMCS root_mcs root_mcs_proof t,
   timelineQuotMCS_is_mcs root_mcs root_mcs_proof t⟩

/--
The underlying set of the lifted world state equals the timelineQuotMCS.
-/
theorem timelineQuotToWorldState_val (t : TimelineQuot root_mcs root_mcs_proof) :
    (timelineQuotToWorldState root_mcs root_mcs_proof t).val =
    timelineQuotMCS root_mcs root_mcs_proof t := rfl

/-!
## Summary

This module establishes that the parametric canonical TaskFrame can be instantiated
at D = TimelineQuot while keeping W = ParametricCanonicalWorldState (all MCSs).

**Key property**: WorldState contains ALL MCSs, not just those in TimelineQuot.
This means witnesses for F(φ)/P(φ) exist in W even if they're not in the timeline.

**Next phase**: Build WorldHistories mapping TimelineQuot → ParametricCanonicalWorldState.
-/

end Bimodal.Metalogic.Algebraic.SeparatedTaskFrame
