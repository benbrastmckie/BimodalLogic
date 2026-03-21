# Research Report: Base TM + Dense/Discrete Extension Strategy

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Focus**: Three-logic relationship and D-polymorphic extension strategy
**Session**: sess_1774024172_bb385f

## Executive Summary

This report analyzes the relationship between base TM logic and its dense/discrete extensions, focusing on:

1. **Base TM logic** uses 15 base axioms and works with ANY linearly ordered abelian group D
2. **Dense extension** adds density axiom DN, requires `DenselyOrdered D` (D ~ Rat)
3. **Discrete extension** adds discreteness axioms DF/DB + seriality, requires `SuccOrder D`/`PredOrder D` (D ~ Int)

The key insight is that DovetailedBuild **always includes** `processDensityDovetailed`, making it inherently dense. For discrete logic, use `discreteStagedBuild` which skips density processing entirely.

## 1. Three-Logic Overview

### 1.1 Base TM Logic

**Axioms** (15 base axioms from `Axioms.lean`):
- Propositional: `prop_k`, `prop_s`, `ex_falso`, `peirce`
- Modal S5: `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`
- Temporal: `temp_k_dist`, `temp_4`, `temp_a`, `temp_l`, `temp_linearity`
- Interaction: `modal_future`, `temp_future`

**Frame Conditions**: Linear order only (no density or discreteness)

**Canonical Model**: D can be ANY linearly ordered abelian group
- The codebase uses `D = Int` for base completeness (`BaseCompleteness.lean`)
- This is a **choice**, not a requirement

**Key Property**: Base TM is NEUTRAL between dense and discrete

### 1.2 Dense Extension

**Additional Axiom**: `density` (DN): `F(phi) -> F(F(phi))`

**Frame Condition**: `DenselyOrdered D` - between any two distinct times, there exists another

**Canonical Model**: D ~ Rat (or any countable dense linear order without endpoints)
- By Cantor's theorem (`Order.iso_of_countable_dense`): countable + dense + no endpoints => order-isomorphic to Rat

**Construction**: DovetailedBuild with `processDensityDovetailed` enabled

### 1.3 Discrete Extension

**Additional Axioms**:
- `discreteness_forward` (DF): `(F(top) && phi && H(phi)) -> F(H(phi))`
- `seriality_future`: `F(top)` (there is always a future)
- `seriality_past`: `P(top)` (there is always a past)

**Frame Conditions**:
- `SuccOrder D` - every element has an immediate successor
- `PredOrder D` - every element has an immediate predecessor
- `NoMaxOrder D`, `NoMinOrder D` - seriality

**Canonical Model**: D ~ Int (or any discrete linear order without endpoints)
- By characterization (`orderIsoIntOfLinearSuccPredArch`): discrete + archimedean + no endpoints => order-isomorphic to Int

**Construction**: `discreteStagedBuild` which skips density processing

## 2. DovetailedBuild Parameterization

### 2.1 Current DovetailedBuild Structure

From `DovetailedBuild.lean`, the `dovetailedStep` function:

```lean
noncomputable def dovetailedStep
    (state : DovetailedBuildState) (step : Nat) : DovetailedBuildState :=
  let obl := obligationAtStep step
  ...
  -- Process F/P obligations
  let state' := processObligationsDovetailed state point phi step
  -- Process density (ALWAYS called)
  processDensityDovetailed state' point phi step
```

**Key Observation**: DovetailedBuild ALWAYS calls `processDensityDovetailed`. This is designed for the dense case.

### 2.2 DiscreteStaged Build (Existing Alternative)

From `StagedExecution.lean`:

```lean
/-- Discrete staged construction: only F/P witnesses, NO density -/
noncomputable def discreteStagedBuild : Nat -> Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 =>
    let prev := discreteStagedBuild n
    -- Always apply evenStage for formula n (no density insertion)
    evenStage prev n
```

**Key Property**: `discreteStagedBuild` skips density entirely, giving a discrete timeline.

### 2.3 Parameterization Strategy

Rather than parameterizing DovetailedBuild, use **separate constructions**:

| Logic | Construction | Density Processing | Result |
|-------|--------------|-------------------|--------|
| Base | Either (user choice) | Optional | D = Int (default) |
| Dense | DovetailedBuild | Yes (`processDensityDovetailed`) | D ~ Rat |
| Discrete | discreteStagedBuild | No | D ~ Int |

## 3. Canonical Model Structure Per Logic

### 3.1 Base TM Canonical Model

**Construction**: `BFMCS Int` with temporal coherent families

**Order Type**: Int (by choice, any LOAG works)

**Domain**: Full (`domain = True` via `parametric_to_history`)

**Key Files**:
- `BaseCompleteness.lean`: Truth lemma for Int
- `ParametricHistory.lean`: `parametric_to_history` with full domain

### 3.2 Dense Canonical Model

**Construction**: DovetailedBuild -> TimelineQuot -> Rat

**Order Type**: Rat (via `Order.iso_of_countable_dense`)

**Properties Required**:
- `Countable TimelineQuot` - from countable dovetailed union
- `DenselyOrdered TimelineQuot` - from density processing
- `NoMaxOrder TimelineQuot` - from seriality
- `NoMinOrder TimelineQuot` - from seriality
- `Nonempty TimelineQuot` - from root point

**Key Files**:
- `CantorApplication.lean`: `TimelineQuot ≃o Rat`
- `DenseTimeline.lean`: Density witnesses
- `DovetailedBuild.lean`: Full dovetailed construction

### 3.3 Discrete Canonical Model

**Construction**: discreteStagedBuild -> DiscreteTimelineQuot -> Int

**Order Type**: Int (via `orderIsoIntOfLinearSuccPredArch`)

**Properties Required**:
- `LinearOrder DiscreteTimelineQuot`
- `SuccOrder DiscreteTimelineQuot` - from discreteness axiom
- `PredOrder DiscreteTimelineQuot` - from backward discreteness
- `IsSuccArchimedean DiscreteTimelineQuot` - from LocallyFiniteOrder
- `NoMaxOrder DiscreteTimelineQuot` - from seriality
- `NoMinOrder DiscreteTimelineQuot` - from seriality
- `Nonempty DiscreteTimelineQuot` - from root point

**Key Files**:
- `DiscreteTimeline.lean`: Full discrete construction
- `DurationTransfer.lean`: `intOrderIso`, `intAddCommGroup`

## 4. D-Polymorphic Strategy

### 4.1 Generic FMCS Structure

The `FMCS D` structure (from `FMCS.lean`) is already D-polymorphic:

```lean
structure FMCS (D : Type*) [LinearOrder D] where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall s t phi, s < t -> all_future phi ∈ mcs s -> phi ∈ mcs t
  backward_H : forall s t phi, s < t -> all_past phi ∈ mcs t -> phi ∈ mcs s
  forward_F : forall t phi, some_future phi ∈ mcs t -> exists s, t < s && phi ∈ mcs s
  backward_P : forall t phi, some_past phi ∈ mcs t -> exists s, s < t && phi ∈ mcs s
```

### 4.2 ParametricCanonicalTaskFrame

From `ParametricCanonical.lean`:

```lean
def ParametricCanonicalTaskFrame (D : Type*)
    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame where
  WorldState := ParametricCanonicalWorldState
  Duration := D
  ...
```

This is fully D-polymorphic - instantiate with:
- `D = Int` for base/discrete
- `D = Rat` for dense

### 4.3 Extension Strategy

**Base -> Dense Extension**:
1. Start with `FMCS D` for arbitrary D
2. Add `[DenselyOrdered D]` constraint
3. Use DovetailedBuild to construct D ~ Rat
4. Transfer group structure via `ratAddCommGroup`

**Base -> Discrete Extension**:
1. Start with `FMCS D` for arbitrary D
2. Add `[SuccOrder D]`, `[PredOrder D]`, `[IsSuccArchimedean D]` constraints
3. Use `discreteStagedBuild` to construct D ~ Int
4. Transfer group structure via `intAddCommGroup`

## 5. Shared Infrastructure

### 5.1 Common Components (All Three Logics)

| Component | Location | Purpose |
|-----------|----------|---------|
| `FMCS D` | `Bundle/FMCS.lean` | D-indexed family of MCSs |
| `BFMCS D` | `Bundle/BFMCS.lean` | Bundle of FMCS families |
| `parametric_to_history` | `Algebraic/ParametricHistory.lean` | FMCS -> WorldHistory with full domain |
| `ParametricCanonicalTaskFrame D` | `Algebraic/ParametricCanonical.lean` | D-parametric TaskFrame |
| `ShiftClosedParametricCanonicalOmega` | `Algebraic/ParametricHistory.lean` | Shift-closed Omega |
| `canonical_truth_lemma` | `Bundle/CanonicalConstruction.lean` | MCS membership <-> semantic truth |

### 5.2 Dense-Specific Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `DovetailedBuild` | `StagedConstruction/DovetailedBuild.lean` | Dense timeline construction |
| `processDensityDovetailed` | `StagedConstruction/DovetailedBuild.lean` | Density witness insertion |
| `TimelineQuot ≃o Rat` | `StagedConstruction/CantorApplication.lean` | Cantor isomorphism |
| `ratAddCommGroup` | `Domain/DurationTransfer.lean` | Group structure from Rat |

### 5.3 Discrete-Specific Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `discreteStagedBuild` | `StagedConstruction/StagedExecution.lean` | Discrete timeline construction |
| `DiscreteTimelineQuot` | `Domain/DiscreteTimeline.lean` | Discrete quotient |
| `SuccOrder`, `PredOrder` instances | `Domain/DiscreteTimeline.lean` | Discrete structure |
| `intAddCommGroup` | `Domain/DurationTransfer.lean` | Group structure from Int |

## 6. Extension Strategy Diagram

```
                     Base TM Logic (15 axioms)
                     D = Any LOAG (default: Int)
                            |
              +-------------+-------------+
              |                           |
              v                           v
    +------------------+        +-------------------+
    | + Density (DN)   |        | + Discreteness    |
    | DenselyOrdered D |        | SuccOrder D       |
    +------------------+        | PredOrder D       |
              |                 | + Seriality       |
              v                 +-------------------+
    DovetailedBuild                    |
    D ~ Rat (Cantor)                   v
              |                 discreteStagedBuild
              v                 D ~ Int (characterization)
    Dense Completeness                 |
                                       v
                              Discrete Completeness
```

## 7. Key Insights for Task 1006

### 7.1 The Current Blocker

The prior report (07_dovetailed-z-detailed.md) identified that:
1. `shiftedFlagWorldHistory` uses restricted domain (non-convex in Rat)
2. `parametric_to_history` uses full domain (trivially convex)

The fix is to use `parametric_to_history` which has `domain = True`.

### 7.2 DovetailedBuild is Dense

DovetailedBuild inherently produces a dense timeline because it always calls `processDensityDovetailed`. If task 1006 is about dense completeness, this is correct.

### 7.3 For Discrete Completeness

If discrete completeness is also needed:
1. Use `discreteStagedBuild` (not DovetailedBuild)
2. Wire through `DiscreteTimeline.lean` infrastructure
3. Apply `orderIsoIntOfLinearSuccPredArch` for Int isomorphism

### 7.4 For Base Completeness

Base completeness is already working with `D = Int`:
- `BaseCompleteness.lean` provides `base_truth_lemma`
- `base_shifted_truth_lemma` for shift-closed Omega
- No Cantor isomorphism needed (Int is chosen, not derived)

## 8. Recommended Approach for Task 1006

### Option A: Focus on Dense Completeness

1. **Use DovetailedBuild** (already builds dense timeline)
2. **Apply parametric_to_history** with full domain
3. **Wire through BFMCS Rat** using Cantor isomorphism
4. **Prove truth lemma for Rat-indexed FMCS**

This requires resolving the "domain mismatch" documented in `DenseCompleteness.lean`.

### Option B: Prove All Three Completeness Theorems

1. **Base**: Already working (BaseCompleteness.lean with D = Int)
2. **Dense**: DovetailedBuild + Cantor + parametric_to_history
3. **Discrete**: discreteStagedBuild + characterization theorem

This is more comprehensive but requires more work.

### Option C: Conservative Extension Approach

From `ConservativeExtension/`:
1. Prove dense/discrete are conservative extensions of base
2. Use base completeness as foundation
3. Add axiom-specific completeness lemmas

## 9. Mathlib Theorem References

### 9.1 Cantor's Theorem (Dense Case)

```lean
-- Mathlib.Order.CountableDenseLinearOrder
theorem Order.iso_of_countable_dense
    (α : Type*) (β : Type*)
    [LinearOrder α] [LinearOrder β]
    [Countable α] [DenselyOrdered α] [NoMinOrder α] [NoMaxOrder α] [Nonempty α]
    [Countable β] [DenselyOrdered β] [NoMinOrder β] [NoMaxOrder β] [Nonempty β] :
    Nonempty (α ≃o β)
```

### 9.2 Discrete Characterization

```lean
-- Mathlib.Order.SuccPred.LinearLocallyFinite
def orderIsoIntOfLinearSuccPredArch
    {ι : Type*} [LinearOrder ι] [SuccOrder ι] [PredOrder ι]
    [IsSuccArchimedean ι] [NoMaxOrder ι] [NoMinOrder ι] [Nonempty ι] :
    ι ≃o ℤ
```

### 9.3 Group Transfer

```lean
-- Mathlib.Algebra.Group.TransferInstance
def Equiv.addCommGroup {α β : Type*} (e : α ≃ β) [AddCommGroup β] : AddCommGroup α
```

## 10. Summary Table

| Aspect | Base TM | Dense TM | Discrete TM |
|--------|---------|----------|-------------|
| **Axioms** | 15 base | 15 base + DN | 15 base + DF/DB + seriality |
| **D Constraint** | LOAG | LOAG + DenselyOrdered | LOAG + SuccOrder + PredOrder |
| **Canonical D** | Int (choice) | Rat (Cantor) | Int (characterization) |
| **Construction** | Either | DovetailedBuild | discreteStagedBuild |
| **Group Transfer** | intAddCommGroup | ratAddCommGroup | intAddCommGroup |
| **Key Theorem** | base_truth_lemma | (needs wiring) | (needs wiring) |

## 11. Next Steps

1. **Verify** `parametric_to_history` can be wired to existing BFMCS infrastructure
2. **Choose** between Option A (dense only), B (all three), or C (conservative extension)
3. **Implement** chosen approach in phases
4. **Test** with existing proof infrastructure

## References

| File | Relevance |
|------|-----------|
| `Theories/Bimodal/ProofSystem/Axioms.lean` | Axiom definitions and classification |
| `Theories/Bimodal/Metalogic/BaseCompleteness.lean` | Base completeness interface |
| `Theories/Bimodal/Metalogic/DenseCompleteness.lean` | Dense completeness (partial) |
| `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` | Dense construction |
| `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` | Discrete construction |
| `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` | Discrete quotient |
| `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` | Group transfer |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` | Full domain WorldHistory |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` | D-parametric TaskFrame |
| `Mathlib.Order.CountableDenseLinearOrder` | Cantor's theorem |
| `Mathlib.Order.SuccPred.LinearLocallyFinite` | Discrete characterization |
