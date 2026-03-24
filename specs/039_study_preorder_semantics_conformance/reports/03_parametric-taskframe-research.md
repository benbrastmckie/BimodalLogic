# Research: ParametricCanonicalTaskFrame and W/D Separation

**Task 39**: Study preorder semantics conformance with Task Semantics specifications
**Focus**: Understanding the mathematically correct way to unify the two-layer architecture
**Date**: 2026-03-22
**Session**: sess_1774245907_103ed8

---

## Executive Summary

The `ParametricCanonicalTaskFrame` construction provides the mathematically elegant solution to unify the two-layer architecture (proof-theoretic FMCS vs semantic TaskFrame). The key insight is **W/D separation**: the world-state space W (all MCSs) is kept distinct from the duration type D (timeline). This avoids the W=D conflation error that blocked earlier approaches.

---

## Core Answer: What is ParametricCanonicalTaskFrame?

### Definition (from `ParametricCanonical.lean` lines 199-206)

```lean
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState  -- ALL MCSs
  task_rel := parametric_canonical_task_rel    -- Uses CanonicalR
  nullity_identity := parametric_task_rel_nullity_identity
  forward_comp := ...
  converse := parametric_task_rel_converse
```

### Key Properties

| Aspect | ParametricCanonicalTaskFrame | Old W=D Construction |
|--------|------------------------------|---------------------|
| WorldState (W) | All MCSs (`ParametricCanonicalWorldState`) | TimelineQuot (= D) |
| Duration (D) | Parameter: Int, Rat, TimelineQuot, etc. | TimelineQuot |
| W = D? | **NO** (distinct types) | **YES** (conflation error) |
| Witnesses | Always exist (ALL MCSs in W) | May not exist in Range(h) |

---

## The W/D Separation Principle

### The Problem with W=D (Dead End)

The deprecated `denseCanonicalTaskFrame` (see `CanonicalDomain.lean` lines 221-229) committed a fundamental error:

> **DEPRECATED**: This construction inherits the W = D error from `canonicalTaskFrame`.
> WorldState = DenseCanonicalTimeline = D, but W and D must be DISTINCT types.
> W should be MCSs (semantic content), D should be the timeline (temporal duration).

This caused the "m > 2k edge case" blocker (Task 982): witnesses for F(phi)/P(phi) might not exist in the staged timeline (Range(h)), because not all MCSs appear at positions in the timeline.

### The Solution: Separated W and D

The `ParametricCanonicalTaskFrame` construction separates:

1. **W = ParametricCanonicalWorldState** (D-independent)
   - Contains ALL maximal consistent sets
   - Witnesses for F(phi)/P(phi) always exist because every MCS is a valid world-state
   - Defined as: `{ M : Set Formula // SetMaximalConsistent M }`

2. **D = Parameter** (provided externally)
   - Any totally ordered abelian group: Int, Rat, TimelineQuot, etc.
   - Duration structure comes from the parameter, not from syntax
   - Must satisfy `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

### Mathematical Justification

The separation is mathematically correct because:

1. **World-states are semantic objects**: MCSs represent "possible worlds" with formula membership
2. **Durations are temporal objects**: D represents "how much time passes between states"
3. **The task relation bridges them**: `task_rel M d N` relates MCSs via temporal displacement

The task relation `parametric_canonical_task_rel` is defined (lines 85-89):

```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val      -- Forward: g_content(M) subseteq N
  else if d < 0 then CanonicalR N.val M.val  -- Backward: converse
  else M = N                                  -- d = 0: identity
```

This is **uniform in D**: the same definition works for any ordered abelian group because the CanonicalR relation is defined purely in terms of formula membership, independent of D's structure.

---

## How SeparatedTaskFrame Uses W/D Separation

The `SeparatedTaskFrame.lean` module instantiates `ParametricCanonicalTaskFrame` with `D = TimelineQuot`:

```lean
noncomputable def SeparatedCanonicalTaskFrame :
    TaskFrame (TimelineQuot root_mcs root_mcs_proof) :=
  ParametricCanonicalTaskFrame (TimelineQuot root_mcs root_mcs_proof)
```

Key insight from lines 20-23:

> The W/D separation resolves this:
> - Witnesses exist in W (ALL MCSs are available as world states)
> - They DON'T need to be at any particular time in D

### The `timelineQuotToWorldState` Bridge

To connect times in D to world-states in W, a lifting function is provided (lines 163-166):

```lean
noncomputable def timelineQuotToWorldState
    (t : TimelineQuot root_mcs root_mcs_proof) : ParametricCanonicalWorldState :=
  ⟨timelineQuotMCS root_mcs root_mcs_proof t,
   timelineQuotMCS_is_mcs root_mcs root_mcs_proof t⟩
```

This maps each time `t : TimelineQuot` to its corresponding MCS, viewed as an element of W. The map is NOT surjective: W contains ALL MCSs, while only some MCSs appear at times in TimelineQuot.

---

## Comparison: Three Approaches to Canonical TaskFrame

### 1. ParametricCanonicalTaskFrame (Recommended)

- **W**: All MCSs (D-independent)
- **D**: Parameter (Int, Rat, TimelineQuot, etc.)
- **Status**: Active, sorry-free for TaskFrame axioms
- **Location**: `Algebraic/ParametricCanonical.lean`

### 2. CanonicalTaskTaskFrame (SuccChain Track)

- **W**: `Set Formula` (MCSs as raw sets)
- **D**: `Int` (fixed)
- **Status**: Active, discrete-only, sorry-free for TaskFrame axioms
- **Location**: `Completeness/SuccChainTaskFrame.lean`

### 3. denseCanonicalTaskFrame (Deprecated)

- **W**: `DenseCanonicalTimeline` (= D, conflation error)
- **D**: TimelineQuot
- **Status**: DEPRECATED - "Use ParametricCanonicalTaskFrame with D = TimelineQuot instead"
- **Location**: `Domain/CanonicalDomain.lean`

---

## Architecture: How the Pieces Fit Together

### The Completeness Pipeline

```
Layer 1 (Proof-theoretic)          Layer 2 (Semantic)
========================          ==================

FMCS CanonicalMCS                 ParametricCanonicalTaskFrame D
  |                                   |
  | Preorder only                     | TaskFrame (AddCommGroup + LinearOrder)
  | Identity: mcs(w) = w.world        | W/D separated
  |                                   |
  +---> TruthLemma                    +---> Completeness Theorem
        (MCS membership               (valid phi -> provable phi)
         iff semantic truth)
```

### Key Modules

| Module | Role |
|--------|------|
| `CanonicalFMCS.lean` | Layer 1: FMCS over CanonicalMCS (Preorder) |
| `ParametricCanonical.lean` | Layer 2: D-parametric TaskFrame with W/D separation |
| `ParametricHistory.lean` | Converts FMCS to WorldHistory over ParametricCanonicalTaskFrame |
| `ParametricTruthLemma.lean` | TruthLemma for D-parametric canonical model |
| `AlgebraicBaseCompleteness.lean` | Main completeness theorem using the pipeline |

---

## Why Preorder for Layer 1 is Correct

### The Role of CanonicalMCS Preorder

The `CanonicalMCS` type has a Preorder (not LinearOrder):

```lean
noncomputable instance : Preorder CanonicalMCS where
  le a b := a = b ∨ CanonicalR a.world b.world
  le_refl a := Or.inl rfl
  le_trans a b c hab hbc := ...
```

This Preorder:
- Is **reflexive** (from T-axioms `G phi -> phi` and `H phi -> phi`)
- Is **transitive** (from `canonicalR_transitive` using temp_4: `G(phi) -> G(G(phi))`)
- Is **NOT antisymmetric** (mutual accessibility can hold for distinct MCSs)
- Is **NOT total** (incomparable MCSs exist)

### Why This Suffices

The FMCS coherence conditions only require:
- `forward_G`: `t' >= t` implies phi at t' (reflexive inequality)
- `backward_H`: `t' <= t` implies phi at t' (reflexive inequality)

Totality and antisymmetry are NOT needed for the TruthLemma. The ParametricCanonicalTaskFrame provides these properties (via D's structure) for the final completeness theorem.

---

## Instantiation Examples

### Discrete Instantiation (D = Int)

From `DiscreteInstantiation.lean`:

```lean
def DiscreteCanonicalTaskFrame : TaskFrame Int :=
  ParametricCanonicalTaskFrame Int
```

### Dense Instantiation (D = Rat)

From `DenseInstantiation.lean`:

```lean
def DenseCanonicalTaskFrame : TaskFrame Rat :=
  ParametricCanonicalTaskFrame Rat
```

### Syntax-Derived D (D = TimelineQuot)

From `SeparatedTaskFrame.lean`:

```lean
def SeparatedCanonicalTaskFrame :
    TaskFrame (TimelineQuot root_mcs root_mcs_proof) :=
  ParametricCanonicalTaskFrame (TimelineQuot root_mcs root_mcs_proof)
```

---

## Recommendations

### For Unifying the Two Layers

The ParametricCanonicalTaskFrame **already achieves** the unification elegantly:

1. **Layer 1 (FMCS CanonicalMCS)** provides the TruthLemma infrastructure
2. **Layer 2 (ParametricCanonicalTaskFrame D)** provides the TaskFrame conformance
3. **The bridge** (`parametric_to_history`, `ParametricCanonicalOmega`) connects them

### For Avoiding W/D Conflation

Always use `ParametricCanonicalTaskFrame` with explicit W/D separation:
- W = `ParametricCanonicalWorldState` (all MCSs)
- D = whatever duration type is needed (Int, Rat, TimelineQuot)

### For Understanding the Architecture

The key insight: **the two layers serve different purposes**:
- Layer 1 (Preorder): Trivializes witness existence for F/P
- Layer 2 (TaskFrame): Provides group/order structure required by semantics

The separation is mathematically necessary, not a limitation.

---

## Remaining Sorries in Completeness Pipeline

| Location | Sorry | Impact |
|----------|-------|--------|
| `DirectMultiFamilyBFMCS.lean` | `directFamilies_modal_forward` | Cross-family transfer |
| `DirectMultiFamilyBFMCS.lean` | `directFamilies_modal_backward` at t!=0 | Chain positions |
| `IntBFMCS.lean` | `intFMCS_forward_F` | F witness (dovetailing) |
| `IntBFMCS.lean` | `intFMCS_backward_P` | P witness (dovetailing) |

These sorries are in the BFMCS construction (modal saturation), not in the ParametricCanonicalTaskFrame itself. The TaskFrame axioms (nullity_identity, forward_comp, converse) are fully proven.

---

## Confidence Level: HIGH

The W/D separation in `ParametricCanonicalTaskFrame` is the mathematically correct approach. The construction is:
- Fully proven for all three TaskFrame axioms
- Uniform in the duration type D
- Explicitly designed to avoid the W=D conflation error
- Used by the active completeness pipeline (`AlgebraicBaseCompleteness.lean`)

The two-layer architecture is intentional and sound: Layer 1 (Preorder FMCS) enables the TruthLemma, Layer 2 (TaskFrame) provides semantic conformance. The gap is bridged correctly via the parametric history and omega constructions.
