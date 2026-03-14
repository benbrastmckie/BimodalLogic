import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.Metalogic.Domain.DiscreteTimeline
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

**Status**: `cantor_iso` compiles. All Cantor prerequisites (NoMaxOrder,
NoMinOrder, DenselyOrdered) are proved via the `canonicalR_irreflexive` axiom
(see `Canonical/CanonicalIrreflexivityAxiom.lean`).

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

**Status**: NoMaxOrder and NoMinOrder proved via `canonicalR_irreflexive` axiom.
SuccOrder/PredOrder/IsSuccArchimedean have sorries (DF coverness extraction).

### 3. Base Case (D = ℤ)
Base axiom system without density or discreteness.
Uses D = ℤ directly with `canonicalTaskFrame` from `DurationTransfer.lean`.

**Status**: Complete.

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

## Algebraic/Categorical Perspective

The D-from-syntax pipeline can be understood through the lens of natural
transformations between functors on ordered algebraic categories:

1. **Forgetful functor** U : OrderedAbelianGroup → LinearOrder
   Forgets the group structure, keeping only the order.

2. **Characterization functors** (Cantor / ℤ-characterization)
   These are equivalences *within* LinearOrder:
   - Cantor: {countable, dense, no-endpoint linear orders} ≃ {ℚ}
   - ℤ-char: {linear, succ-pred-archimedean, no-endpoint} ≃ {ℤ}

3. **Transfer functor** T : LinearOrder × OrderIso → OrderedAbelianGroup
   Given T ≃o Q (where Q ∈ {ℚ, ℤ} already has a group), transfers the group
   structure back along the isomorphism: `(a + b) := iso⁻¹(iso(a) + iso(b))`.

The full pipeline is: MCS construction produces a LinearOrder (step 1 of U⁻¹),
characterization identifies it as ℚ or ℤ (step 2), and transfer reconstructs
the group (step 3 = T). The composition T ∘ Char ∘ MCS is the "section" that
lifts a set of temporal axioms to an OrderedAbelianGroup.

The key insight is that **transfer along OrderIso preserves all algebraic
identities** — this is why `transferAddCommGroup` and `transferIsOrderedAddMonoid`
work without additional proof obligations. The OrderIso is the natural
isomorphism component that makes the square commute:

```
  MCS(Axioms) ──Char──→ ℚ or ℤ
       │                    │
    U  │                    │ U
       ▼                    ▼
  LinearOrder ──Char──→ LinearOrder
```

This perspective suggests that the construction generalizes: any temporal axiom
system whose canonical timeline satisfies a characterization theorem (Cantor,
ℤ-char, or potentially others like ℝ via Dedekind completeness) automatically
yields a TaskFrame with the appropriate duration group.

## Axiom Dependencies

The construction depends on one axiom with high mathematical confidence:

- **`canonicalR_irreflexive`** (in `Canonical/CanonicalIrreflexivityAxiom.lean`):
  `¬CanonicalR M M` for all MCSs M. Standard in the literature (Goldblatt 1992,
  BdRV 2001), blocked only by String atom freshness. Resolution: change atom type.

From this axiom, NoMaxOrder, NoMinOrder, and DenselyOrdered are proved (not sorry'd).
The remaining sorries are in the discrete case (SuccOrder/PredOrder coverness from DF).

## References

- Task 960: Duration Group Construction from Pure Syntax
- `DurationTransfer.lean`: Group transfer along OrderIso
- `CantorApplication.lean`: Dense timeline → ℚ isomorphism
- `DiscreteTimeline.lean`: Discrete timeline → ℤ characterization
- `Canonical/CanonicalIrreflexivityAxiom.lean`: Irreflexivity axiom
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

All prerequisites proved (NoMaxOrder, NoMinOrder, DenselyOrdered via
`canonicalR_irreflexive` axiom). Depends on axiom only.
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

**Axiom dependency**: All Cantor prerequisites (NoMaxOrder, NoMinOrder,
DenselyOrdered) are proved via the `canonicalR_irreflexive` axiom from
`Canonical/CanonicalIrreflexivityAxiom.lean`. No sorry dependencies remain
in the dense case pipeline.
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
## Discrete Case: Complete Pipeline (Partially Sorry-Dependent)

The discrete case follows the same transfer pattern but uses
`orderIsoIntOfLinearSuccPredArch` instead of Cantor's theorem.

NoMaxOrder and NoMinOrder are proved via `canonicalR_irreflexive` axiom
(same pattern as the dense case). The remaining sorry dependencies are
SuccOrder, PredOrder, and IsSuccArchimedean, which require extracting
the DF coverness frame condition at the MCS level.

See `DiscreteTimeline.lean` for details.
-/

/-!
## Base Case

The base case uses D = ℤ directly via `canonicalTaskFrame` from
`DurationTransfer.lean`. No characterization theorem is needed since ℤ
already has `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid`.
-/

/--
Base case TaskFrame: D = ℤ.

This is a special case where we don't need to transfer the group structure —
ℤ already has `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid`.
-/
noncomputable def baseTaskFrame : TaskFrame ℤ :=
  canonicalTaskFrame ℤ

end Bimodal.Metalogic.Domain
