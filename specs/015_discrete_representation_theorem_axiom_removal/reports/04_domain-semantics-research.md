# Research Report: Domain Semantics Clarification for Task #15

**Task**: 15 - discrete_representation_theorem_axiom_removal
**Date**: 2026-03-21
**Status**: RESEARCHED
**Language**: lean4

---

## Executive Summary

- **CanonicalMCS** is the space of world STATES (maximal consistent sets), NOT a time index domain
- **Int** (or `TimelineQuot` for dense) is the appropriate domain for indexing world HISTORIES
- BFMCS encodes the space of all world HISTORIES via families indexed by time
- The distinction is fundamental: MCS = semantic content at an instant; D = temporal position
- Several comments and architectural patterns conflate these distinct domains
- The correct path forward requires maintaining clear separation between W (world states) and D (durations)

---

## Section 1: Correct Domain Semantics

### 1.1 What is CanonicalMCS?

`CanonicalMCS` (defined in `Bundle/CanonicalFMCS.lean`) is a **structure wrapping all maximal consistent sets**:

```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
```

**Semantically**: Each `CanonicalMCS` element represents a **possible world state** - a complete, consistent description of the world at some instant. The set of all MCS forms the space of all possible instantaneous configurations.

**Key property**: `CanonicalMCS` has a `Preorder` via the reflexive closure of `CanonicalR` (the temporal accessibility relation), NOT a group structure. It is NOT appropriate for duration arithmetic.

### 1.2 What is the Appropriate Time Index Domain?

For the discrete case: **Int** (integers)
For the dense case: **TimelineQuot** (quotient of staged timeline, isomorphic to Q)

These domains satisfy:
- `AddCommGroup` structure (for duration arithmetic: `u + d = v`)
- `LinearOrder` structure (for temporal comparison)
- `IsOrderedAddMonoid` (compatibility of addition with order)

**Semantically**: Each element of `Int` or `TimelineQuot` represents a **position in time**, not a world state.

### 1.3 FMCS and BFMCS: Families of World States

**FMCS D** (Family of MCS indexed by D):
```lean
structure FMCS where
  mcs : D -> Set Formula        -- assigns an MCS to each time point
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : ...               -- temporal coherence
  backward_H : ...
```

An FMCS is a **world history**: a mapping from time points to world states. It represents one possible trajectory through the space of world states.

**BFMCS D** (Bundle of FMCS families):
```lean
structure BFMCS where
  families : Set (FMCS D)       -- collection of world histories
  nonempty : families.Nonempty
  modal_forward : ...           -- modal coherence across histories
  modal_backward : ...
  eval_family : FMCS D          -- distinguished evaluation history
```

A BFMCS encodes **the space of all world histories** relevant to the completeness proof. The modal operators Box/Diamond quantify over histories in the bundle at the same time point.

### 1.4 The Correct Relationship

| Concept | Type | Role |
|---------|------|------|
| World state | MCS (set of formulas) | Semantic content at an instant |
| World history | FMCS D | Trajectory through state space |
| Space of histories | BFMCS D | All relevant trajectories |
| Time index | D (Int, TimelineQuot) | Position in temporal domain |
| Duration | D | Difference between time positions |

The key insight: **BFMCS is parametric in D (the time domain), not in the world state space**. The world state space is always the space of MCS.

---

## Section 2: Identified Conceptual Confusions

### 2.1 FMCS CanonicalMCS: Proof-Theoretic Technique

The construction `FMCS CanonicalMCS` (in `CanonicalFMCS.lean`) is a **proof-theoretic device**, not a standard temporal model. It uses CanonicalMCS as the indexing type, creating an "identity" family where `mcs(w) = w.world`.

**Why it exists**: This trivializes F/P witness obligations because every MCS is a domain element.

**Why it's confusing**: It conflates the world state space (MCS) with the time index domain (D).

**Correct understanding**: This is a valid proof technique, but should NOT be confused with the semantic model structure where D is a temporal domain like Int.

### 2.2 Files With Misleading Comments

**`Bundle/ModallyCoherentBFMCS.lean` lines 39-52**:
```lean
/-
## Key Insight: The Domain Problem

The BFMCS modal_backward condition quantifies over families AT THE SAME TIME t:
  forall fam in families, forall phi t, (forall fam' in families, phi in fam'.mcs t) -> Box phi in fam.mcs t

For this to work without the impossible phi -> Box phi axiom, we need families with
DIFFERENT values of `mcs t` for the same t. This means families must have
different `mcs` functions that produce different MCS for the same input.

With D = CanonicalMCS and `mcs t = t.world` (identity), all families produce
the same MCS at each time, collapsing saturation.

The solution requires either:
1. Flag-based chains where different Flags give different chains (Phase 3)
2. Generalized parametric framework accepting `D = CanonicalMCS` (alternative)
3. Domain transfer from CanonicalMCS to Int (Phase 4)
-/
```

**Issue**: Option 2 "accepting `D = CanonicalMCS`" confuses the indexing type with the world state domain. CanonicalMCS can be used as a proof-theoretic indexing type but should not be understood as a semantic temporal domain.

**Correction needed**: Clarify that CanonicalMCS-as-D is a proof technique for trivializing witnesses, not a semantic model.

**`Domain/CanonicalDomain.lean` lines 167-170**:
```lean
/-
Given a root MCS from the dense axiom system, this produces a TaskFrame
where the duration type D is the dense canonical timeline (approx Q),
the world states are also D (canonical timeline worlds = times),
-/
```

**Issue**: The comment says "world states are also D" which is the W = D conflation error. The DEPRECATED annotation correctly flags this, but the comment should be clearer.

**`Domain/DurationTransfer.lean` lines 176-198**:
```lean
/-
Build a TaskFrame from a type with AddCommGroup + LinearOrder + IsOrderedAddMonoid.

The WorldState type IS the duration type T (worlds = times in the canonical timeline).
...

**DEPRECATED**: This construction sets WorldState := T (W = D), which is a fundamental
architectural error.
-/
```

**Issue**: The original design conflated W and D. Correctly marked deprecated, but the codebase still has remnants.

### 2.3 Files Potentially for Boneyard

**`Domain/DurationTransfer.lean`** (`canonicalTaskFrame`, `discreteTaskFrame`, `denseTaskFrame`):
These functions set `WorldState := T` (W = D), which is marked deprecated. Consider:
- Moving deprecated constructions to Boneyard
- Keeping only the correct `ParametricCanonicalTaskFrame`

**`Bundle/SuccChainBFMCS.lean`**:
Already marked DEPRECATED. Should be moved to Boneyard to prevent accidental usage.

**`Bundle/IntFMCSTransfer.lean`**:
Uses `singleFamilyBFMCS_Int` which has an impossible `modal_backward` sorry. Should be reviewed for boneyard candidacy.

---

## Section 3: Correct Architecture for Discrete Representation

### 3.1 The Parametric Framework (Correct Approach)

`ParametricCanonical.lean` correctly separates W from D:

```lean
-- WorldState = ParametricCanonicalWorldState (MCS-based)
-- D = duration type (Int, TimelineQuot, etc.)
abbrev ParametricCanonicalTaskFrame (D : Type*) [...] : TaskFrame D :=
  { WorldState := ParametricCanonicalWorldState
    task_rel := parametric_canonical_task_rel
    ... }
```

This is the correct pattern: W is always MCS-based, D is the temporal domain.

### 3.2 The BFMCS Construction

For a sorry-free discrete representation:

1. **BFMCS over Int** (semantic model):
   - `families : Set (FMCS Int)` - histories indexed by integer time
   - Each family `fam : FMCS Int` maps `t : Int` to an MCS
   - Different families can have different MCS at the same time t

2. **Modal saturation via CanonicalMCS domain** (proof infrastructure):
   - Build modally saturated set of MCS using `closedFlags`
   - Transfer to Int-indexed families via retraction
   - The saturation property ensures `modal_backward` is provable

### 3.3 The Proper Relationship

```
                CanonicalMCS (all world states)
                       |
                       | mcs : D -> Set Formula (FMCS)
                       v
              FMCS Int (world history)
                       |
                       | families : Set (FMCS Int)
                       v
              BFMCS Int (space of histories)
                       |
                       | used by
                       v
      DiscreteCanonicalTaskFrame / ParametricCanonicalTaskFrame
```

---

## Section 4: Path Forward for Task 15

### 4.1 What ModallyCoherentBFMCS.lean Accomplishes (Phase 2)

The file correctly establishes:
- `discreteClosedMCS M0` - the set of all MCS in closed Flags (modal saturation content)
- `discreteClosedMCS_modally_saturated` - sorry-free saturation proof
- `discreteMCS_modal_forward` - T-axiom (sorry-free)
- `discreteMCS_modal_backward` - via saturation contraposition (sorry-free)

**What's still missing**: Wiring this to `BFMCS Int` structure with temporal coherence.

### 4.2 Phase 4 Completion (The Gap)

The current blocker from plan v2:
- `discrete_representation_conditional` requires `BFMCS Int`
- Modal saturation is proven at MCS level, not BFMCS level
- Need to either:
  a. Construct multi-family `BFMCS Int` from saturation content
  b. Generalize parametric framework to work with MCS-level saturation directly

### 4.3 Recommended Implementation Approach

**Option A (Direct BFMCS Int construction)**:
1. For each flag in `closedFlags M0`, create an Int-indexed FMCS via `intChainMCS`
2. Bundle these into `BFMCS Int` with modal saturation
3. Use `saturated_modal_backward` for sorry-free `modal_backward`
4. F/P witnesses remain sorry-backed (dovetailing gap)

**Option B (Direct MCS-level completeness)**:
1. Bypass the BFMCS structure entirely for discrete completeness
2. Use `discreteMCS_modal_backward` directly in a simplified truth lemma
3. This avoids the domain transfer complexity entirely
4. Requires restructuring `DiscreteCompleteness.lean`

### 4.4 Comments/Code Needing Fixes

| File | Location | Issue | Fix |
|------|----------|-------|-----|
| `ModallyCoherentBFMCS.lean` | Lines 39-52 | "D = CanonicalMCS" conflation | Clarify CanonicalMCS-as-D is proof technique |
| `CanonicalDomain.lean` | denseCanonicalTaskFrame | "world states are also D" | Already deprecated; add boneyard note |
| `DurationTransfer.lean` | canonicalTaskFrame | W = D conflation | Already deprecated; consider boneyard |
| `FMCSDef.lean` | Lines 20-31 | Correct explanation but could be clearer | Add explicit "D != CanonicalMCS for semantics" |

---

## Section 5: Summary

### Correct Understanding

| Component | Type | Domain | Purpose |
|-----------|------|--------|---------|
| MCS | `Set Formula` | World states | Instantaneous semantic content |
| CanonicalMCS | Structure wrapping MCS | World states | Proof-theoretic universe |
| Int | `Int` | Time indices | Discrete temporal position |
| TimelineQuot | Quotient type | Time indices | Dense temporal position |
| FMCS D | `D -> MCS` | World history | Trajectory through state space |
| BFMCS D | `Set (FMCS D)` | Space of histories | Bundle for completeness proof |

### Key Distinction

**CanonicalMCS is NOT a time index domain.** It is the space of world states. Using it as the D parameter in `FMCS CanonicalMCS` is a proof technique that trivializes F/P witnesses but should not be confused with semantic modeling.

### Boneyard Candidates

1. `Bundle/SuccChainBFMCS.lean` - deprecated singleton approach
2. `Domain/DurationTransfer.lean` deprecated functions - W = D conflation
3. `Bundle/IntFMCSTransfer.lean` `singleFamilyBFMCS_Int` - impossible sorry

### Path Forward

The correct completion of Task 15 Phase 4 requires maintaining the separation between:
- **D** (Int for discrete, TimelineQuot for dense) - time domain
- **W** (ParametricCanonicalWorldState based on MCS) - state space

The modal saturation infrastructure in `ModallyCoherentBFMCS.lean` is correct and sorry-free. The remaining work is connecting it to the `BFMCS Int` structure required by `DiscreteInstantiation.lean` while preserving the domain separation.
