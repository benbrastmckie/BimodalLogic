# Research Report: Task #987 - TaskFrame Semantics for Algebraic Base Completeness

**Task**: 987 - algebraic_base_completeness
**Date**: 2026-03-17
**Focus**: TaskFrame semantics, pure syntactic construction, correct D parameter
**Language**: math

## Executive Summary

The task asks to wire algebraic base completeness using the BFMCS construction from task 986 with D = Int. However, the focus prompt raises critical questions:

1. **D = CanonicalMCS is NOT correct** - This approach confuses the domain type with the time/duration type
2. **Pure syntactic construction** - The duration type D should NOT be imported from Int or Rat literals, but D = Int is the correct mathematical choice for discrete time
3. **TaskFrame semantics** - The key insight is that D is a parameter for the *temporal duration*, not the *world state domain*

## Core Mathematical Structure

### TaskFrame Definition

From `Theories/Bimodal/Semantics/TaskFrame.lean` (lines 93-122):

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

**Key Requirements for D**:
- `[AddCommGroup D]` - Addition, negation, identity (0)
- `[LinearOrder D]` - Total ordering
- `[IsOrderedAddMonoid D]` - Order compatibility with addition

### Why D = CanonicalMCS is WRONG

**CanonicalMCS** (from `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`) is:
- The type of ALL maximal consistent sets
- Has `[Preorder]` structure (reflexive closure of CanonicalR)
- Does NOT have `[AddCommGroup]` - there is no group operation on MCSs
- Does NOT have `[LinearOrder]` - the preorder is not total

**The confusion**: CanonicalMCS is used as the *domain type* in `FMCS CanonicalMCS` and `BFMCS CanonicalMCS`, but this is NOT the same as being the *duration type* D in TaskFrame.

In `CanonicalFMCS.lean`:
```lean
-- CanonicalMCS is the INDEX TYPE for the FMCS family
noncomputable def canonicalMCSBFMCS : FMCS CanonicalMCS where
  mcs := canonicalMCS_mcs   -- CanonicalMCS -> Set Formula
  is_mcs := canonicalMCS_is_mcs
  forward_G := ...
  backward_H := ...
```

The FMCS over CanonicalMCS means: "each element of CanonicalMCS maps to an MCS". This is NOT a TaskFrame with D = CanonicalMCS.

### Why D = Int IS Correct

The D parameter in TaskFrame represents **temporal duration** - the time between world states in a trajectory. The mathematical requirements are:

1. **Additive structure** - Durations compose: 3 time units + 2 time units = 5 time units
2. **Negation** - Going backward: -d represents the reverse direction
3. **Total order** - Times are linearly ordered (past < future)
4. **Discrete** - For the base logic, discrete time (integers) is sufficient

Int satisfies all these requirements and is the natural choice for discrete temporal logic.

### The "Pure Syntax" Clarification

The focus prompt warns against "importing Int or Rat". This likely refers to avoiding:
- Concrete numeric literals in proofs (e.g., proving specific cases for 1, 2, 3...)
- Implementation-specific details that would not generalize

The **parametric approach** already achieves this. From `ParametricRepresentation.lean`:
```lean
theorem parametric_algebraic_representation_conditional
    (phi : Formula) (h_not_prov : ...)
    (construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M -> ...) :
    ...
```

This theorem is **parametric in D** - it works for ANY totally ordered abelian group D. The completeness proof does not depend on specific properties of Int; it only needs the algebraic structure.

## The Correct Architecture

### Three Distinct Concepts

1. **D (Duration Type)**: Int, Rat, or any ordered abelian group
   - Used in TaskFrame, FMCS, BFMCS as the time index
   - Requires AddCommGroup + LinearOrder + IsOrderedAddMonoid

2. **WorldState (World State Type)**: ParametricCanonicalWorldState
   - Defined as `{ M : Set Formula // SetMaximalConsistent M }`
   - The carrier of the TaskFrame
   - Independent of D

3. **Index Type for FMCS**: Can be D (for parametric) OR CanonicalMCS (for all-MCS)
   - `FMCS D` means: function from D to MCS
   - `FMCS CanonicalMCS` means: function from CanonicalMCS to MCS (identity)

### The Existing Sorry-Free Infrastructure

From `CanonicalFMCS.lean`, there EXISTS a sorry-free construction:

```lean
theorem temporal_coherent_family_exists_CanonicalMCS
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
      (forall gamma in Gamma, gamma in fam.mcs root) /\
      (forall t : CanonicalMCS, forall phi : Formula,
        Formula.some_future phi in fam.mcs t -> exists s : CanonicalMCS, t <= s /\ phi in fam.mcs s) /\
      (forall t : CanonicalMCS, forall phi : Formula,
        Formula.some_past phi in fam.mcs t -> exists s : CanonicalMCS, s <= t /\ phi in fam.mcs s)
```

This is SORRY-FREE because:
- Every witness MCS is in CanonicalMCS by construction
- No need for dovetailing (the domain contains ALL MCSs)

### The Task 986 Construction (Has Sorries)

From `IntBFMCS.lean`:
```lean
-- Status: 2 sorries (intFMCS_forward_F, intFMCS_backward_P)
```

The sorries exist because for `FMCS Int`:
- Building an Int-indexed chain from a root MCS
- The F/P witnesses from `canonical_forward_F`/`canonical_backward_P` may not be in the chain
- Dovetailing is needed to ensure all witnesses eventually appear

## The Correct Approach for Task 987

### Option 1: Complete Task 986 First (Direct Path)

If task 986 completes the dovetailing construction:
```lean
def construct_bfmcs_int (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent)
           (fam : FMCS Int) (hfam : fam in B.families) (t : Int),
           M = fam.mcs t := ...

theorem algebraic_base_completeness (phi : Formula) :
    valid phi -> Nonempty (DerivationTree [] phi) :=
  fun h_valid => by
    by_contra h_not_prov
    push_neg at h_not_prov
    obtain <B, h_tc, fam, hfam, t, h_false> :=
      parametric_algebraic_representation_conditional phi (fun d => d h_not_prov) construct_bfmcs_int
    exact h_false (h_valid ...)  -- h_valid gives truth at all models
```

### Option 2: Semantic Equivalence (Indirect Path)

Use the fact that completeness over CanonicalMCS implies completeness over Int:

**Key Insight**: The derivability judgment `Nonempty (DerivationTree [] phi)` is D-independent.

If phi is valid over ALL TaskFrames (including the CanonicalMCS-based one), and we can show:
- CanonicalMCS provides a countermodel for any non-provable phi
- Then phi is provable

This avoids the Int-specific dovetailing problem entirely.

### Option 3: Use CanonicalMCS as FMCS Index, Map to Int (Hybrid)

Define an embedding from Int to CanonicalMCS to use the sorry-free construction:
```lean
-- Embed Int positions into the CanonicalMCS domain
-- Use the Int-indexed path through CanonicalMCS
```

This approach is explored in `SeparatedTaskFrame.lean` with TimelineQuot.

## Recommendations

### Immediate Actions

1. **Reject D = CanonicalMCS for TaskFrame** - This is mathematically incorrect. D must have AddCommGroup structure.

2. **Understand the separation**:
   - TaskFrame D requires D with group structure (Int, Rat)
   - FMCS indexing can use any Preorder (including CanonicalMCS)
   - The CanonicalFMCS construction uses CanonicalMCS as index, not as TaskFrame D

3. **For sorry-free completeness**: Use Option 2 (semantic equivalence) or wait for task 986 completion.

### The Key Mathematical Statement

The algebraic base completeness theorem should state:

```lean
theorem algebraic_base_completeness (phi : Formula) :
    valid phi -> Nonempty (DerivationTree [] phi)
```

Where `valid phi` means phi is true in ALL TaskModels over ALL TaskFrames.

Since the CanonicalMCS-based construction provides a countermodel for any non-provable phi, and this countermodel is a valid TaskModel (even if not over D = Int specifically), we have the completeness direction.

## Key Findings Summary

| Concept | Correct Understanding | Incorrect Understanding |
|---------|----------------------|------------------------|
| D in TaskFrame | Duration type (Int, Rat) | NOT CanonicalMCS |
| CanonicalMCS | FMCS index type | NOT TaskFrame duration |
| FMCS D | D-indexed family of MCS | - |
| FMCS CanonicalMCS | Identity family (sorry-free) | - |
| Pure syntax | Parametric in D | NOT avoiding Int entirely |

## References

### Files Consulted

| File | Lines | Key Content |
|------|-------|-------------|
| TaskFrame.lean | 303 | TaskFrame structure definition |
| CanonicalFMCS.lean | 313 | Sorry-free CanonicalMCS construction |
| ParametricRepresentation.lean | 263 | D-parametric representation theorem |
| ParametricCanonical.lean | 245 | D-parametric TaskFrame |
| IntBFMCS.lean | ~600 | Int-indexed BFMCS (2 sorries) |
| TemporalCoherence.lean | 222 | Temporal coherence definitions |
| BFMCS.lean | 232 | Bundle structure |
| FMCSDef.lean | 110 | FMCS structure |

### Mathematical Hierarchy

```
TaskFrame D
    requires: [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    contains: WorldState, task_rel

TaskModel F (for TaskFrame F)
    extends: TaskFrame
    adds: valuation

FMCS D (Family of MCS indexed by D)
    requires: [Preorder D]
    contains: mcs : D -> Set Formula, is_mcs, forward_G, backward_H

BFMCS D (Bundle of FMCS)
    requires: [Preorder D]
    contains: families : Set (FMCS D), modal coherence

TemporalCoherentFamily D
    extends: FMCS D
    adds: forward_F, backward_P

BFMCS.temporally_coherent B
    predicate: all families have forward_F and backward_P
```

## Next Steps

1. **If pursuing Option 2 (recommended)**:
   - Prove that validity over CanonicalMCS-based model implies provability
   - This avoids the task 986 blocking dependency

2. **If pursuing Option 1**:
   - Wait for task 986 to complete the dovetailing construction
   - Then wire the construct_bfmcs_int argument

3. **Create AlgebraicBaseCompleteness.lean**:
   - Import the appropriate modules
   - State the closed completeness theorem
   - Connect to the parametric infrastructure
