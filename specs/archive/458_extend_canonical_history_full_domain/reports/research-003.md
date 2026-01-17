# Research Report: Task #458 - Mixed-Sign Compositionality Resolution

**Task**: 458 - Extend canonical_history from singleton domain to full domain
**Date**: 2026-01-12
**Session ID**: sess_1768283046_c8d7c3
**Started**: 2026-01-12T22:00:00Z
**Completed**: 2026-01-12T23:30:00Z
**Effort**: Variable (see recommendations)
**Priority**: High
**Parent**: Task 257 (Completeness Proofs)
**Dependencies**: Task 464 (Strategy A implementation)
**Language**: lean
**Sources/Inputs**:
  - Completeness.lean (current implementation)
  - research-002.md (strategy analysis)
  - Task 464 research-001.md (Strategy A implementation)
  - Mathlib: LinearOrderedAddCommGroup.discrete_or_denselyOrdered
  - Goldblatt, "Logics of Time and Computation" (temporal logic completeness)
  - Stanford Encyclopedia of Philosophy - Temporal Logic
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- **Problem**: Mixed-sign compositionality gaps (x > 0, y <= 0, x+y > 0) persist after Strategy A
- **Root Cause**: Semantic/syntactic mismatch - G-formula at intermediate state T cannot bridge to U when going backward
- **Key Finding**: Mathlib provides `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` theorem
- **Most Elegant Path**: Accept the fundamental limitation and prove completeness via **relativized approach with parameterized time**
- **Mathematical Virtue**: The gap reflects a genuine semantic phenomenon, not a proof technique failure

## Context & Scope

### The Mixed-Sign Gap Explained

After Task 464 (Strategy A), the compositionality theorem has these proven cases:
- **x > 0, y > 0**: G-persistence carries Gf through T to U
- **x < 0, y < 0**: H-persistence carries Hf through T to U

But these cases remain blocked:
- **x > 0, y <= 0, x+y > 0**: Gf in S -> Gf in T, but T->U goes backward, losing the "future" direction
- **x <= 0, y > 0, x+y > 0**: Cannot transfer Gf from S to T when x <= 0
- **x < 0, y >= 0, x+y < 0**: Hf in S -> Hf in T, but T->U goes forward, losing the "past" direction
- **x >= 0, y < 0, x+y < 0**: Cannot transfer Hf from S to T when x >= 0

### Why This Is Fundamental

The gap is not a proof technique failure. Consider:
- Gf in S means "f holds at all times strictly after S"
- U is at x+y > 0 from S, so semantically f should hold at U
- But syntactically, we pass through T at distance x > 0 from S
- From T, U is at distance y <= 0 (at or before T)
- Gf in T means "f holds at all times strictly after T"
- When y <= 0, U is not strictly after T, so Gf in T does not imply f in U

**The syntactic path through the intermediate state T cannot capture the semantic fact that U is still in S's future.**

## Findings

### 1. Duration Type Structure

From Completeness.lean (lines 1779-1960):

**Construction**:
1. `PositiveDuration` = Quotient of chain segments under order-type equivalence
2. `Duration` = Grothendieck group completion of PositiveDuration
3. Ordering: d1 <= d2 iff exists positive p with d1 + p = d2

**Properties Available**:
- `AddCommGroup Duration`
- `LinearOrder Duration` (with sorries for antisymmetry, totality)
- `IsOrderedAddMonoid Duration` (partial)

**Properties NOT Available**:
- Archimedean property
- Discreteness/density axioms
- Explicit embedding Z -> Duration

### 2. Mathlib Discovery: Discrete or Dense Dichotomy

**Key Theorem Found** via `lean_leanfinder`:

```lean
theorem LinearOrderedAddCommGroup.discrete_or_denselyOrdered
    (G : Type*) [LinearOrderedAddCommGroup G] [Archimedean G] :
    Nonempty (G ≃+o Z) ∨ DenselyOrdered G
```

**Interpretation**: An Archimedean linearly ordered additive group is either:
1. Order-isomorphic to Z (discrete), or
2. Densely ordered (between any two elements lies another)

**Applicability to Duration**:
- Duration is LinearOrderedAddCommGroup (with sorries)
- Would need to prove Archimedean property
- If proven, Duration is either discrete (isomorphic to Z) or dense

### 3. Strategy D Analysis: Duration Discreteness

**Approach**: Prove Duration is isomorphic to Z via chain_step.

**Path**:
1. Show `chain_step > 0` (has sorry placeholder)
2. Show `chain_step` is the least positive element
3. Apply `int_orderAddMonoidIso_of_isLeast_pos`

**Viability Assessment**:

| Aspect | Assessment |
|--------|------------|
| Technical Feasibility | Medium - requires proving Archimedean property |
| Mathematical Elegance | Low - contradicts "agnostic" design goal |
| Implementation Effort | High - significant proofs needed |
| Semantic Alignment | Mixed - Duration construction suggests discreteness |

**The Problem**: The Duration type was designed to be agnostic about discreteness. Proving it's isomorphic to Z would be a strong commitment that may not reflect the intended semantics.

### 4. Alternative: Relativized Completeness (from research-004.md)

**Key Insight**: The polymorphic validity definition already quantifies over ALL time types:

```lean
def valid (f : Formula) : Prop :=
  forall (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (F : TaskFrame T) (M : TaskModel F) ...
```

**Revised Completeness Statement**:

```lean
theorem weak_completeness (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (f : Formula) :
    (forall (F : TaskFrame T) ..., truth_at ... f) ->
    DerivationTree [] f
```

**How This Resolves the Gap**:
1. **Do not construct Duration from syntax** - use T as parameter
2. **Do construct worlds (MCS) from syntax** - this is standard
3. **Canonical frame is parameterized by T**
4. **Completeness holds for each T separately**
5. **Polymorphic completeness follows by instantiation**

**Mathematical Virtue**: This matches standard practice in temporal logic (Goldblatt, Blackburn et al.).

### 5. Why Relativized Completeness Is Superior

| Criterion | Constructive Duration | Relativized T |
|-----------|----------------------|---------------|
| Time Construction | From syntax (complex) | Parameter (simple) |
| Agnosticism | Must prove structure | Inherently agnostic |
| Literature Alignment | Non-standard | Standard approach |
| Implementation | Complex, many sorries | Cleaner proofs |
| Mixed-Sign Issue | Must be resolved | Bypassed entirely |

**The Gap Dissolves**: With T as a parameter, there's no need to prove compositionality for a constructed Duration type. The canonical_task_rel is defined over T, and the chain construction simply uses T directly.

### 6. Step-by-Step Construction Alternative

If we insist on constructing Duration:

**Idea**: Build states step-by-step through t=0 for mixed-sign cases.

For x > 0, y <= 0, x+y > 0:
1. From S to T (forward, x > 0): canonical_task_rel S x T
2. From T to S' at t=0 (backward, going through origin)
3. From S' to U (forward, x+y > 0)

**Problem**: This requires:
- S' = S (same origin state)
- Coherence from S through T back to S
- Then forward to U

But the independent Classical.choose calls don't guarantee S' = S when going backward from T to origin.

**Assessment**: Adds complexity without solving the fundamental issue.

### 7. Accepting the Gap as Limitation

**Option**: Mark mixed-sign cases as known limitation.

**Rationale**:
1. Uniform-sign cases (positive-positive, negative-negative) ARE proven
2. Mixed-sign cases represent a genuine semantic/syntactic mismatch
3. The gap reflects the difficulty of "going backward through an intermediate point"
4. Many practical applications only need uniform-sign compositionality

**Documentation Required**:
- Clear explanation of which cases work
- Semantic justification for the gap
- Note that this doesn't invalidate the completeness proof for restricted domains

## Decisions

1. **Relativized completeness is the most mathematically elegant path**
2. **The mixed-sign gap is fundamental, not a proof technique failure**
3. **Duration construction should be revisited with parameter approach in mind**
4. **Proving Duration discreteness would work but contradicts design goals**

## Recommendations

### Primary Recommendation: Adopt Relativized Completeness

**Refactor** the completeness proof to:

```lean
-- Parameterize canonical frame by arbitrary time type T
def canonical_frame (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    : TaskFrame T where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel  -- Now defined over T, not Duration
  nullity := canonical_nullity
  compositionality := canonical_compositionality_for_T

-- State completeness with T parameter
theorem weak_completeness (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (f : Formula) :
    (forall (F : TaskFrame T) (M : TaskModel F) (t : WorldHistory F) (t : T) (ht : t.domain t),
      truth_at M t t ht f) ->
    DerivationTree [] f
```

**Benefits**:
1. Eliminates the Duration construction entirely
2. Mixed-sign issue becomes moot (compositionality is over T, which is given)
3. Matches standard temporal logic literature
4. Cleaner, more maintainable proofs

**Estimated Effort**: 8-12 hours (significant refactoring)

### Alternative Recommendation: Accept Partial Result

If full refactoring is not desired:

1. **Document** the mixed-sign gap clearly in code comments
2. **Mark** specific sorries with explanatory notes
3. **Use** chain construction for uniform-sign cases only
4. **State** a weaker completeness theorem that's fully proven

**Estimated Effort**: 2-4 hours (documentation and cleanup)

### Not Recommended: Duration Discreteness Proof

Proving Duration is isomorphic to Z:
- Contradicts the agnostic design philosophy
- Requires significant additional proofs (Archimedean, least element)
- Doesn't align with standard temporal logic practice

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Refactoring breaks other proofs | High | Medium | Incremental changes, test after each |
| T-parameterized approach has hidden issues | Medium | Low | Follow Goldblatt's proven approach |
| Team objects to architectural change | Medium | Medium | Present mathematical justification |
| Time constraints prevent full refactor | High | Medium | Fall back to partial result option |

## Appendix

### Key Code Locations

| Component | Lines | Status |
|-----------|-------|--------|
| Duration construction | 1779-1960 | Multiple sorries |
| canonical_task_rel | 2048-2051 | Strengthened in Task 464 |
| canonical_compositionality | 2190-2420 | Mixed-sign cases have sorry |
| chain construction | 2760-3000 | Works for uniform signs |
| canonical_history | 3397-3530 | respects_task has sorry |

### References

1. [Goldblatt, Logics of Time and Computation](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation) - Standard canonical model approach
2. [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/) - Frame class completeness
3. Mathlib `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` - Dichotomy theorem
4. Mathlib `int_orderAddMonoidIso_of_isLeast_pos` - Integer isomorphism
5. Task 257 research-004.md - Relativized completeness proposal
6. Task 464 research-001.md - Strategy A analysis

### Mathematical Virtue Assessment

| Approach | Elegance | Simplicity | Rigor | Alignment |
|----------|----------|------------|-------|-----------|
| Relativized T | High | High | High | Standard |
| Duration Discreteness | Medium | Low | High | Non-standard |
| Accept Gap | Low | High | Medium | Pragmatic |
| Step Construction | Low | Low | Medium | Novel |

**Conclusion**: Relativized completeness with T as parameter is the most mathematically virtuous path. It aligns with established literature, simplifies the proof structure, and naturally sidesteps the mixed-sign issue by not requiring a constructed Duration type to satisfy compositionality.

## Next Steps

1. Review this analysis with project stakeholders
2. Decide between full refactor vs. partial result
3. If refactoring: Begin with canonical_frame parameterization
4. If accepting gap: Document limitations clearly
5. Update Task 458 plan based on decision
