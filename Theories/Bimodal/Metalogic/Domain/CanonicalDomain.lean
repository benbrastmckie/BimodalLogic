import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.Metalogic.StagedConstruction.CantorApplication

/-!
# Canonical Domain: Duration Type from Pure Syntax

This module connects the canonical timeline construction to the algebraic
duration type required by `TaskFrame D`. It provides the complete pipeline:

  **Axioms → MCSs → Canonical Timeline → Order Properties → Characterization → Group Transfer → TaskFrame**

## The Three Constructions

### 1. Dense Case (D ≃ ℚ)
Axiom system includes density DN: `Fφ → FFφ`.
Pipeline:
- Build MCSs from the axiom system with DN
- Construct `DenseTimelineElem` (staged timeline + density intermediates)
- Quotient by `Antisymmetrization` to get `TimelineQuot` with `LinearOrder`
- Prove Cantor prerequisites: `Countable`, `DenselyOrdered`, `NoMaxOrder`, `NoMinOrder`
- Apply `Order.iso_of_countable_dense` to get `TimelineQuot ≃o ℚ`
- Transfer `AddCommGroup` and `IsOrderedAddMonoid` via `DurationTransfer`
- Build `TaskFrame` via `canonicalTaskFrame`

**Status**: `cantor_iso` compiles modulo 3 sorry'd instances
(NoMaxOrder, NoMinOrder, DenselyOrdered in CantorApplication.lean).

### 2. Discrete Case (D ≃ ℤ)
Axiom system includes discreteness DF: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`.
Pipeline:
- Build MCSs from the axiom system with DF
- Construct bidirectional timeline (staged execution)
- Quotient by `Antisymmetrization` to get timeline with `LinearOrder`
- Prove ℤ-characterization prerequisites: `SuccOrder`, `PredOrder`, `IsSuccArchimedean`
- Apply `orderIsoIntOfLinearSuccPredArch` to get `T ≃o ℤ`
- Transfer `AddCommGroup` and `IsOrderedAddMonoid` via `DurationTransfer`
- Build `TaskFrame` via `canonicalTaskFrame`

**Status**: Pipeline architecture defined; SuccOrder/PredOrder construction pending.

### 3. Base Case (D = ℤ)
Base axiom system without density or discreteness.
Since the base logic is sound and complete w.r.t. ℤ-frames (existing
`Representation.lean`), we use D = ℤ directly with the existing
`CanonicalTaskFrame` from `Bundle/CanonicalConstruction.lean`.

**Status**: Complete (modulo existing sorry in `construct_saturated_bfmcs_int`).

## Architecture

```
                    ┌─────────────────────┐
                    │   Axiom System      │
                    │  (ProofSystem/      │
                    │   Axioms.lean)      │
                    └─────────┬───────────┘
                              │
                    ┌─────────▼───────────┐
                    │  Maximal Consistent │
                    │  Sets (MCSs)        │
                    │  (Bundle/           │
                    │   CanonicalFrame)   │
                    └─────────┬───────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
    ┌─────────▼─────┐ ┌──────▼──────┐ ┌──────▼──────┐
    │  Dense        │ │  Discrete   │ │  Base       │
    │  Timeline     │ │  Timeline   │ │  (D = ℤ)    │
    │  (Staged +    │ │  (Staged +  │ │             │
    │   Density     │ │   Succ/Pred)│ │             │
    │   Intermediates)│ │           │ │             │
    └─────────┬─────┘ └──────┬──────┘ └──────┬──────┘
              │               │               │
    ┌─────────▼─────┐ ┌──────▼──────┐        │
    │  Cantor       │ │  ℤ-Charact. │        │
    │  T ≃o ℚ       │ │  T ≃o ℤ     │        │
    └─────────┬─────┘ └──────┬──────┘        │
              │               │               │
    ┌─────────▼───────────────▼───────────────▼──────┐
    │            DurationTransfer.lean               │
    │  transferAddCommGroup + transferIsOrderedAddMonoid │
    └─────────────────────┬──────────────────────────┘
                          │
                ┌─────────▼───────────┐
                │  canonicalTaskFrame │
                │  (TaskFrame D)      │
                └─────────────────────┘
```

## References

- Task 960: Duration Group Construction from Pure Syntax
- `DurationTransfer.lean`: Group transfer along OrderIso
- `CantorApplication.lean`: Dense timeline → ℚ isomorphism
- `Bundle/CanonicalConstruction.lean`: Base case TaskFrame
-/

namespace Bimodal.Metalogic.Domain

open Bimodal.Semantics
open Bimodal.Metalogic.StagedConstruction

/-!
## Dense Case: Complete Pipeline

Given a root MCS from the dense axiom system, construct a TaskFrame
with D = TimelineQuot (the quotient of the dense timeline).
-/

/--
The dense canonical timeline type: quotient of the density-enriched
staged timeline by mutual CanonicalR-accessibility.

This is the type T in the pipeline `T ≃o ℚ → AddCommGroup T → TaskFrame T`.
-/
noncomputable def DenseCanonicalTimeline
    (root_mcs : Set Bimodal.Syntax.Formula)
    (root_mcs_proof : Bimodal.Metalogic.Core.SetMaximalConsistent root_mcs) :=
  TimelineQuot root_mcs root_mcs_proof

/--
The Cantor isomorphism for the dense canonical timeline.
Requires: Countable, DenselyOrdered, NoMaxOrder, NoMinOrder, Nonempty.

**Proof debt**: The instances NoMaxOrder, NoMinOrder, DenselyOrdered
have sorries in CantorApplication.lean (reflexive MCS obstacle).
-/
noncomputable def denseCanonicalIso
    (root_mcs : Set Bimodal.Syntax.Formula)
    (root_mcs_proof : Bimodal.Metalogic.Core.SetMaximalConsistent root_mcs) :
    DenseCanonicalTimeline root_mcs root_mcs_proof ≃o ℚ :=
  (cantor_iso root_mcs root_mcs_proof).some

/--
AddCommGroup on the dense canonical timeline, transferred from ℚ.
-/
noncomputable def denseCanonicalAddCommGroup
    (root_mcs : Set Bimodal.Syntax.Formula)
    (root_mcs_proof : Bimodal.Metalogic.Core.SetMaximalConsistent root_mcs) :
    AddCommGroup (DenseCanonicalTimeline root_mcs root_mcs_proof) :=
  transferAddCommGroup (denseCanonicalIso root_mcs root_mcs_proof)

/--
IsOrderedAddMonoid on the dense canonical timeline, transferred from ℚ.
-/
theorem denseCanonicalIsOrderedAddMonoid
    (root_mcs : Set Bimodal.Syntax.Formula)
    (root_mcs_proof : Bimodal.Metalogic.Core.SetMaximalConsistent root_mcs) :
    @IsOrderedAddMonoid (DenseCanonicalTimeline root_mcs root_mcs_proof)
      (denseCanonicalAddCommGroup root_mcs root_mcs_proof).toAddCommMonoid.toAddZeroClass.toAdd
      (inferInstance : Preorder _) :=
  transferIsOrderedAddMonoid (denseCanonicalIso root_mcs root_mcs_proof)

/--
Complete TaskFrame for the dense case.

Given a root MCS from the dense axiom system, this produces a TaskFrame
where the duration type D is the dense canonical timeline (≃o ℚ),
the world states are also D (canonical timeline worlds = times),
and the task relation is deterministic: `task_rel w d w'` iff `w + d = w'`.

**Proof debt**: Depends on 3 sorry'd instances in CantorApplication.lean.
-/
noncomputable def denseCanonicalTaskFrame
    (root_mcs : Set Bimodal.Syntax.Formula)
    (root_mcs_proof : Bimodal.Metalogic.Core.SetMaximalConsistent root_mcs) :
    @TaskFrame (DenseCanonicalTimeline root_mcs root_mcs_proof)
      (denseCanonicalAddCommGroup root_mcs root_mcs_proof)
      (inferInstance)
      (denseCanonicalIsOrderedAddMonoid root_mcs root_mcs_proof) :=
  @canonicalTaskFrame (DenseCanonicalTimeline root_mcs root_mcs_proof)
    (denseCanonicalAddCommGroup root_mcs root_mcs_proof)
    (inferInstance)
    (denseCanonicalIsOrderedAddMonoid root_mcs root_mcs_proof)

/-!
## Discrete Case: Pipeline Stub

The discrete case follows the same transfer pattern but uses
`orderIsoIntOfLinearSuccPredArch` instead of Cantor's theorem.

The key prerequisites (SuccOrder, PredOrder, IsSuccArchimedean) need to be
proved from the discreteness axiom DF and the canonical model construction.
-/

-- The discrete pipeline would follow this pattern:
-- 1. Build DiscreteCanonicalTimeline (quotient of base staged timeline)
-- 2. Prove SuccOrder from discreteness axiom DF
-- 3. Prove PredOrder from backward discreteness
-- 4. Prove IsSuccArchimedean from linearity + no max/min
-- 5. Apply intOrderIso → intAddCommGroup → intIsOrderedAddMonoid
-- 6. Build TaskFrame via canonicalTaskFrame

/-!
## Base Case

The base case uses D = ℤ directly. The existing `CanonicalTaskFrame` in
`Bundle/CanonicalConstruction.lean` already provides this with hardcoded Int.
The `DurationTransfer` module provides the more general version.
-/

/--
Base case TaskFrame: D = ℤ.

This is a special case where we don't need to transfer the group structure —
ℤ already has `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid`.
-/
noncomputable def baseTaskFrame : TaskFrame ℤ :=
  canonicalTaskFrame ℤ

end Bimodal.Metalogic.Domain
