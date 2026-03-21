# Research Report: D Polymorphism for Dense/Discrete Extensions

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Focus**: Polymorphic D construction accommodating both dense (Rat) and discrete (Int) extensions
**Session**: sess_1774037541_7bd927
**Domains**: math, lean4

## Executive Summary

This report analyzes how to define a polymorphic `TaskFrame D` where D can be constrained to either the dense case (D = Rat) or the discrete case (D = Int). The key findings are:

1. **The codebase already has polymorphic D infrastructure**: `ParametricCanonicalTaskFrame D` in `ParametricCanonical.lean` is fully D-parametric and works for any type with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

2. **The dichotomy theorem**: Mathlib's `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` proves that any Archimedean linearly ordered abelian group is either isomorphic to Int (discrete) or densely ordered. This is the fundamental mathematical basis.

3. **No unified typeclass for "DurationDomain"**: The constraints for Rat and Int are fundamentally different. Rather than a single typeclass, the cleanest approach is:
   - Polymorphic `TaskFrame D` with base constraints
   - Separate instantiation modules for D = Rat and D = Int
   - Separate completeness theorems using appropriate characterization theorems

4. **Recommended structure**: Two completeness modules (`DenseCompleteness.lean`, `DiscreteCompleteness.lean`) sharing the polymorphic `ParametricCanonicalTaskFrame D` infrastructure.

---

## 1. Mathlib Typeclasses Analysis

### 1.1 Common Typeclasses (Both Rat and Int)

Both Rat and Int satisfy these fundamental typeclasses:

| Typeclass | Rat | Int | Purpose |
|-----------|-----|-----|---------|
| `AddCommGroup` | Yes | Yes | Additive group structure (0, +, -) |
| `LinearOrder` | Yes | Yes | Total ordering |
| `IsOrderedAddMonoid` | Yes | Yes | Order compatibility with addition |
| `LinearOrderedAddCommGroup` | Yes | Yes | Combined linearly ordered abelian group |

**Mathlib declarations**:
```lean
-- From Mathlib.Algebra.Order.Ring.Rat
instance Rat.instLinearOrderedAddCommGroup : LinearOrderedAddCommGroup Rat

-- From Mathlib.Algebra.Order.Group.Int
instance Int.instLinearOrderedAddCommGroup : LinearOrderedAddCommGroup Int
```

### 1.2 Distinguishing Typeclasses

The two cases are distinguished by **mutually exclusive** typeclasses:

**Dense Case (D = Rat)**:
- `DenselyOrdered D`: Between any two elements exists another
- `Countable D`: Required for Cantor's theorem
- `NoMinOrder D`, `NoMaxOrder D`: No endpoints

**Discrete Case (D = Int)**:
- `SuccOrder D`: Every element has an immediate successor
- `PredOrder D`: Every element has an immediate predecessor
- `IsSuccArchimedean D`: Any two elements are finitely many steps apart
- `NoMinOrder D`, `NoMaxOrder D`: No endpoints

### 1.3 The Dichotomy Theorem

Mathlib proves the fundamental dichotomy:

```lean
-- Mathlib.GroupTheory.ArchimedeanDensely
theorem LinearOrderedAddCommGroup.discrete_or_denselyOrdered
    (G : Type*) [LinearOrderedAddCommGroup G] [Archimedean G] :
    Nonempty (G ≃+o Int) \/ DenselyOrdered G
```

This means an Archimedean linearly ordered abelian group is EITHER discrete (isomorphic to Int) OR densely ordered. The two cases are mutually exclusive.

---

## 2. Cantor Transfer Approach Analysis

### 2.1 Dense Case: T ~=o Rat

**Theorem**: `Order.iso_of_countable_dense` (Cantor's theorem)
```lean
-- Mathlib.Order.CountableDenseLinearOrder
theorem Order.iso_of_countable_dense
    (alpha : Type*) (beta : Type*)
    [LinearOrder alpha] [LinearOrder beta]
    [Countable alpha] [DenselyOrdered alpha] [NoMinOrder alpha] [NoMaxOrder alpha] [Nonempty alpha]
    [Countable beta] [DenselyOrdered beta] [NoMinOrder beta] [NoMaxOrder beta] [Nonempty beta] :
    Nonempty (alpha ≃o beta)
```

**Instances needed on T** (DovetailedTimelineQuot):
1. `LinearOrder T` - from Antisymmetrization
2. `Countable T` - from countable dovetailed construction
3. `DenselyOrdered T` - from `processDensityDovetailed`
4. `NoMinOrder T`, `NoMaxOrder T` - from seriality (F/P witnesses)
5. `Nonempty T` - from root point

**Current codebase status**: `DurationTransfer.lean` provides `ratOrderIso` and `ratAddCommGroup` that use exactly this construction.

### 2.2 Discrete Case: T ~=o Int

**Theorem**: `orderIsoIntOfLinearSuccPredArch`
```lean
-- Mathlib.Order.SuccPred.LinearLocallyFinite
def orderIsoIntOfLinearSuccPredArch
    {iota : Type*} [LinearOrder iota] [SuccOrder iota] [PredOrder iota]
    [IsSuccArchimedean iota] [NoMaxOrder iota] [NoMinOrder iota] [Nonempty iota] :
    iota ≃o Int
```

**Instances needed on T** (DiscreteTimelineQuot):
1. `LinearOrder T` - from Antisymmetrization
2. `SuccOrder T` - from discreteness axiom (DF)
3. `PredOrder T` - from backward discreteness (DB)
4. `IsSuccArchimedean T` - from LocallyFiniteOrder
5. `NoMinOrder T`, `NoMaxOrder T` - from seriality
6. `Nonempty T` - from root point

**Current codebase status**: `DurationTransfer.lean` provides `intOrderIso` and `intAddCommGroup` that use exactly this construction. `DiscreteTimeline.lean` provides the instances.

---

## 3. Existing Polymorphic Infrastructure

### 3.1 ParametricCanonicalTaskFrame (Already D-Polymorphic)

The codebase already has D-polymorphic infrastructure in `ParametricCanonical.lean`:

```lean
/-- The D-parametric canonical task frame. -/
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState
  task_rel := parametric_canonical_task_rel
  nullity_identity := parametric_task_rel_nullity_identity
  forward_comp := fun M U V x y hx hy h1 h2 =>
    parametric_task_rel_forward_comp M U V x y hx hy h1 h2
  converse := parametric_task_rel_converse
```

This is **uniform in D** - instantiate with D = Int for discrete, D = Rat for dense.

### 3.2 Dense and Discrete Instantiation Modules

The codebase already has instantiation modules:

**DenseInstantiation.lean**:
```lean
abbrev DenseCanonicalTaskFrame : TaskFrame Rat :=
  ParametricCanonicalTaskFrame Rat
```

**DiscreteInstantiation.lean**:
```lean
abbrev DiscreteCanonicalTaskFrame : TaskFrame Int :=
  ParametricCanonicalTaskFrame Int
```

### 3.3 DurationTransfer.lean

This module provides the transfer infrastructure:
- `transferAddCommGroup`: Transfer AddCommGroup along OrderIso
- `transferIsOrderedAddMonoid`: Transfer IsOrderedAddMonoid along OrderIso
- `intOrderIso`, `intAddCommGroup`, `intIsOrderedAddMonoid`: Discrete case
- `ratOrderIso`, `ratAddCommGroup`, `ratIsOrderedAddMonoid`: Dense case

---

## 4. Polymorphic TaskFrame Design Options

### 4.1 Option A: Current Approach (Recommended)

**Structure**: Keep separate modules, share polymorphic infrastructure.

```
ParametricCanonicalTaskFrame D  -- Polymorphic base
    |
    +-- DenseCanonicalTaskFrame (D = Rat)
    |       Uses: Order.iso_of_countable_dense
    |       Constraints: Countable, DenselyOrdered, NoMinOrder, NoMaxOrder
    |
    +-- DiscreteCanonicalTaskFrame (D = Int)
            Uses: orderIsoIntOfLinearSuccPredArch
            Constraints: SuccOrder, PredOrder, IsSuccArchimedean, NoMinOrder, NoMaxOrder
```

**Pros**:
- Already implemented in codebase
- Clean separation of concerns
- Each case uses appropriate characterization theorem

**Cons**:
- Two separate completeness proofs
- No unified "DurationDomain" typeclass

### 4.2 Option B: Unified Typeclass (Not Recommended)

**Structure**: Define a single `DurationDomain D` typeclass.

```lean
-- Hypothetical unified typeclass
class DurationDomain (D : Type*) extends AddCommGroup D, LinearOrder D, IsOrderedAddMonoid D where
  -- But what goes here? The dense/discrete constraints are mutually exclusive.
```

**Problem**: There is no meaningful unified constraint. The dense and discrete cases require **different** typeclasses:
- Dense: `DenselyOrdered D`
- Discrete: `SuccOrder D`, `PredOrder D`

These are mutually exclusive by the dichotomy theorem. A unified typeclass would be vacuous or require choice.

**Not recommended** because it adds complexity without benefit.

### 4.3 Option C: Polymorphic with Explicit Choice Parameter

**Structure**: Parameterize by a choice type.

```lean
inductive DurationChoice
  | dense
  | discrete

def DurationDomain (choice : DurationChoice) : Type :=
  match choice with
  | .dense => Rat
  | .discrete => Int
```

**Pros**:
- Explicit choice at definition site
- Could enable meta-programming

**Cons**:
- More complex than Option A
- No real benefit over separate modules
- Lean 4 dependent types make this awkward

---

## 5. AddTorsor Considerations

### 5.1 Self-Torsor Structure

Both Rat and Int are self-torsors:
```lean
-- Mathlib.Algebra.AddTorsor.Defs
instance addGroupIsAddTorsor : AddTorsor G G -- For any AddGroup G
```

This means:
- Rat is an AddTorsor over itself: `AddTorsor Rat Rat`
- Int is an AddTorsor over itself: `AddTorsor Int Int`

### 5.2 Torsor Transfer Along OrderIso

The Cantor transfer approach from report 13 proposed transferring torsor structure along the order isomorphism phi : T ~=o D.

**Pattern**:
```lean
-- Given phi : T ≃o D and D has AddTorsor G D
-- Define AddTorsor G T via:
-- d +v t := phi.symm (d + phi t)
-- t1 -v t2 := phi t1 - phi t2
```

**Mathlib support**:
- `Equiv.vadd` transfers VAdd along equivalence
- `Equiv.addAction` transfers AddAction along equivalence
- No direct `Equiv.addTorsor` but can be constructed

### 5.3 Is AddTorsor Needed for Completeness?

**Analysis of current infrastructure**:
- `ParametricCanonicalTaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- **No AddTorsor requirement** in the current TaskFrame definition
- The task relation `parametric_canonical_task_rel` uses CanonicalR (MCS accessibility), not torsor operations

**Conclusion**: AddTorsor is **not required** for the current completeness construction. The D-polymorphic TaskFrame works without torsor structure.

---

## 6. Codebase Structure Recommendation

### 6.1 Recommended File Organization

Keep the current structure with minor clarifications:

```
Theories/Bimodal/Metalogic/
├── Algebraic/
│   ├── ParametricCanonical.lean       # D-polymorphic TaskFrame (shared)
│   ├── ParametricHistory.lean         # D-polymorphic WorldHistory (shared)
│   ├── ParametricTruthLemma.lean      # D-polymorphic truth lemma (shared)
│   ├── DenseInstantiation.lean        # D = Rat instantiation
│   └── DiscreteInstantiation.lean     # D = Int instantiation
├── Domain/
│   ├── DurationTransfer.lean          # Group structure transfer (shared)
│   └── DiscreteTimeline.lean          # Discrete instances
├── StagedConstruction/
│   ├── DovetailedBuild.lean           # Dense timeline construction
│   ├── CantorApplication.lean         # Cantor isomorphism for dense
│   └── StagedExecution.lean           # Discrete timeline construction
└── Completeness/
    ├── DenseCompleteness.lean         # Dense completeness theorem
    └── DiscreteCompleteness.lean      # Discrete completeness theorem
```

### 6.2 Shared vs. Separate Components

| Component | Shared/Separate | Reason |
|-----------|-----------------|--------|
| `ParametricCanonicalTaskFrame D` | Shared | Works for any D with AddCommGroup + LinearOrder + IsOrderedAddMonoid |
| `parametric_to_history` | Shared | Full domain, works for any D |
| `parametric_shifted_truth_lemma` | Shared | MCS membership, D-independent |
| `DurationTransfer` | Shared | Generic transfer infrastructure |
| Cantor isomorphism (T ~=o Rat) | Dense only | Requires DenselyOrdered T |
| Int characterization (T ~=o Int) | Discrete only | Requires SuccOrder T etc. |
| Timeline construction | Separate | DovetailedBuild vs. discreteStagedBuild |
| Completeness theorem | Separate | Different axiom systems |

---

## 7. Implementation Effort Estimate

### 7.1 What Already Exists (No Work Needed)

- `ParametricCanonicalTaskFrame D` - fully D-polymorphic
- `DenseCanonicalTaskFrame`, `DiscreteCanonicalTaskFrame` - instantiations
- `transferAddCommGroup`, `transferIsOrderedAddMonoid` - group transfer
- `ratOrderIso`, `intOrderIso` - order isomorphisms
- `ratAddCommGroup`, `intAddCommGroup` - transferred group structures

### 7.2 What Needs Work (From Plan v4)

| Task | Effort | Description |
|------|--------|-------------|
| Phase 1: F/P infrastructure | 3 hours | Verify dovetailed coverage gives in-timeline witnesses |
| Phase 2: Base completeness | 3 hours | Wire dovetailed chain to Int or reuse dense |
| Phase 3: Dense completeness | 4 hours | Cantor + parametric pipeline |
| Phase 4: Discrete completeness | 3 hours | Characterization + parametric pipeline |
| Phase 5: Cleanup | 2 hours | Deprecate blocked code, update exports |

**Total**: 15 hours (estimate from plan v4)

### 7.3 Critical Blockers

From plan v4, Phase 1 is [BLOCKED]:
- F/P witness infrastructure needs verification
- `dovetailedTimeline_has_future/past` must give **in-timeline** witnesses

---

## 8. Concrete Lean 4 Code Sketch

### 8.1 Polymorphic TaskFrame (Already Exists)

```lean
-- ParametricCanonical.lean (already implemented)
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState
  task_rel := parametric_canonical_task_rel
  ...
```

### 8.2 Dense Completeness Wiring (Sketch)

```lean
-- DenseCompleteness.lean (to be implemented)
import Bimodal.Metalogic.Algebraic.DenseInstantiation
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.StagedConstruction.CantorApplication

-- The dovetailed timeline quotient
def DovetailedTimelineQuot := Antisymmetrization DovetailedTimelineElem (· <= ·)

-- Cantor isomorphism (using existing ratOrderIso pattern)
noncomputable def dovetailedRatOrderIso : DovetailedTimelineQuot ≃o Rat :=
  (Order.iso_of_countable_dense DovetailedTimelineQuot Rat).some

-- Dense completeness theorem
theorem dense_completeness (phi : Formula) :
    valid_dense phi -> Nonempty (DerivationTree_dense [] phi) := by
  intro h_valid
  -- Use contrapositive: not provable -> not valid
  by_contra h_not_prov
  -- Build countermodel via DenseCanonicalTaskFrame
  -- Wire through parametric_to_history and parametric_shifted_truth_lemma
  sorry
```

### 8.3 Discrete Completeness Wiring (Sketch)

```lean
-- DiscreteCompleteness.lean (to be implemented)
import Bimodal.Metalogic.Algebraic.DiscreteInstantiation
import Bimodal.Metalogic.Domain.DiscreteTimeline

-- Int characterization (using existing intOrderIso)
noncomputable def discreteIntOrderIso : DiscreteTimelineQuot ≃o Int :=
  orderIsoIntOfLinearSuccPredArch

-- Discrete completeness theorem
theorem discrete_completeness (phi : Formula) :
    valid_discrete phi -> Nonempty (DerivationTree_discrete [] phi) := by
  intro h_valid
  -- Use contrapositive
  by_contra h_not_prov
  -- Build countermodel via DiscreteCanonicalTaskFrame
  -- Wire through parametric_to_history and parametric_shifted_truth_lemma
  sorry
```

---

## 9. Recommendations

### 9.1 Primary Recommendation

**Keep the current codebase structure** with separate dense/discrete modules sharing polymorphic infrastructure. This is:
- Already partially implemented
- Mathematically clean (reflects the dichotomy theorem)
- Avoids artificial unification

### 9.2 Do Not Attempt

- **Unified "DurationDomain" typeclass**: The constraints are mutually exclusive
- **Single completeness theorem for both**: The axiom systems differ
- **AddTorsor-based construction**: Not needed for current completeness approach

### 9.3 Specific Next Steps

1. **Resolve Phase 1 blocker**: Verify F/P coverage theorems give in-timeline witnesses
2. **Wire dense completeness**: Use existing `ratOrderIso` + `parametric_to_history`
3. **Wire discrete completeness**: Use existing `intOrderIso` + `parametric_to_history`
4. **Keep parallel structure**: Both use same `parametric_shifted_truth_lemma`

---

## 10. Summary Table

| Aspect | Dense (D = Rat) | Discrete (D = Int) |
|--------|-----------------|-------------------|
| **Axiom system** | Base + DN (density) | Base + DF/DB + seriality |
| **Timeline construction** | DovetailedBuild | discreteStagedBuild |
| **Characterization theorem** | Order.iso_of_countable_dense | orderIsoIntOfLinearSuccPredArch |
| **Key instances on T** | Countable, DenselyOrdered | SuccOrder, PredOrder, IsSuccArchimedean |
| **Group transfer** | ratAddCommGroup | intAddCommGroup |
| **TaskFrame** | ParametricCanonicalTaskFrame Rat | ParametricCanonicalTaskFrame Int |
| **Completeness theorem** | dense_completeness | discrete_completeness |

---

## References

### Mathlib Theorems
- `Order.iso_of_countable_dense` - Cantor's theorem for DLOs
- `orderIsoIntOfLinearSuccPredArch` - Discrete characterization
- `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` - Dichotomy theorem
- `Equiv.addCommGroup` - Group transfer along equivalence
- `addGroupIsAddTorsor` - Self-torsor structure

### Codebase Files
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` - D-polymorphic TaskFrame
- `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` - Group transfer infrastructure
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - Rat instantiation
- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` - Int instantiation
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - Discrete instances

### Prior Reports
- Report 13 (rigidity-counterexample-analysis.md) - Cantor transfer recommendation
- Report 08 (base-dense-discrete-strategy.md) - Three-logic strategy
- Plan v4 (04_three-completeness-plan.md) - Current implementation plan

## Context Extension Recommendations

- **Topic**: D-polymorphic TaskFrame and duration domain constraints
- **Gap**: No context file documents the relationship between dense/discrete characterization theorems and completeness proofs
- **Recommendation**: Create `project/math/order-theory/duration-domains.md` covering the Rat/Int dichotomy for temporal logics
