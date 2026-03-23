# Task 39: Two-Layer Architecture Unification Research

**Date**: 2026-03-22
**Session**: sess_1774246740_11ad75
**Objective**: Research eliminating the two-layer architecture and unifying into a single TaskFrame-conformant construction

## Executive Summary

The two-layer architecture exists because of a fundamental mismatch:

| Property | Layer 1 (Bundle) | Layer 2 (Algebraic) |
|----------|------------------|---------------------|
| Domain | `CanonicalMCS` | `ParametricCanonicalWorldState` with D |
| Structure | Preorder only | AddCommGroup + LinearOrder |
| F/P Witnesses | Sorry-free (all MCS in domain) | Sorry-backed (chain gap) |
| TaskFrame | NOT conformant | Conformant |
| Purpose | TruthLemma proof | Semantic completeness |

**Key Finding**: Unification is NOT simply possible by "replacing Preorder with TaskFrame." The sorry-free F/P witnesses in `FMCS CanonicalMCS` work BECAUSE the domain is all MCS. Moving to Int/Rat indexed chains loses this property.

## Current Architecture Analysis

### Layer 1: Bundle/ (Preorder-Only)

**Core Files**:
- `FMCSDef.lean`: `FMCS D` requires only `[Preorder D]`
- `CanonicalFMCS.lean`: `FMCS CanonicalMCS` - identity mapping where `mcs(w) = w.world`
- `SuccChainFMCS.lean`: Int-indexed Succ chains with F/P sorries

**Key Achievement**: `canonicalMCS_forward_F` and `canonicalMCS_backward_P` are **sorry-free** because:
```lean
-- Every MCS is in the domain by construction
let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
exact ⟨s, CanonicalMCS.le_of_canonicalR w s h_R, h_phi_W⟩
```

**Limitation**: `CanonicalMCS` has only Preorder (reflexive closure of CanonicalR), NOT:
- `AddCommGroup` (no group operation on MCS)
- `LinearOrder` (CanonicalR is NOT total)

### Layer 2: Algebraic/ (TaskFrame Conformant)

**Core Files**:
- `ParametricCanonical.lean`: `ParametricCanonicalTaskFrame D` with full TaskFrame structure
- `ParametricTruthLemma.lean`: Truth lemma requiring `BFMCS D` with temporal coherence
- `IntBFMCS.lean`: Int-indexed chains with F/P sorries

**WorldState Definition**:
```lean
def ParametricCanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }
```

**Task Relation** (D-parametric):
```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0
```

**Limitation**: The Int/Rat-indexed chains have F/P witness sorries because the witness MCS may not be in the chain.

### Current Completeness Paths

1. **Succ-Chain Completeness** (`SuccChainCompleteness.lean`):
   - Uses `FMCS Int` via Succ chains
   - Uses `CanonicalTaskTaskFrame` (TaskFrame Int)
   - Has 1 sorry: Box backward in truth lemma (not needed for completeness forward direction)
   - Has F/P sorries deferred to SuccChainFMCS

2. **Algebraic Base Completeness** (`AlgebraicBaseCompleteness.lean`):
   - Uses `BFMCS Int` with modal coherence
   - Has modal_backward sorry (single-family approach blocked)
   - Has F/P sorries from IntBFMCS

## Why Unification is Blocked

### The Core Tension

**To use CanonicalMCS (sorry-free F/P)**:
- Domain = all MCS
- No AddCommGroup structure (can't add MCS)
- No LinearOrder (CanonicalR not total)
- Cannot instantiate `TaskFrame D` for any meaningful D

**To have TaskFrame conformance (AddCommGroup + LinearOrder)**:
- Must use Int, Rat, or similar domain
- F/P witnesses must be chain elements
- Chain construction has dovetailing gap sorries

### The Mathematical Impossibility

The F/P sorries in Int-indexed chains are NOT just engineering gaps - they represent a fundamental construction challenge:

From `IntBFMCS.lean`:
```lean
-- Dovetailing requires processing F-obligations IMMEDIATELY when they appear,
-- before Lindenbaum extension. See Task 916 analysis.
sorry  -- forward_F for Int chains
sorry  -- backward_P for Int chains
```

The issue: When building a chain step-by-step, encountering `F(phi) in M_n` means we need a witness `M_k` with `k > n` and `phi in M_k`. But the chain construction via Lindenbaum extension doesn't guarantee this witness appears in the chain.

### Transfer Approach (Partial)

`FMCSTransfer.lean` attempts to transfer sorry-free F/P from CanonicalMCS to other domains:
```lean
-- The key insight is that CanonicalMCS has sorry-free proofs of forward_F and backward_P
-- because every MCS is in the domain by construction.
```

But this transfer still requires proving the domain relationship, and the transferred FMCS doesn't automatically give TaskFrame conformance.

## Sorries Inventory

### Bundle/ Sorries

| File | Sorry | Description | Removable? |
|------|-------|-------------|------------|
| `SuccChainTruth.lean:254` | Box backward | `psi in MCS -> Box psi in MCS` | NO (mathematically impossible for singleton Omega) |
| `SuccChainFMCS.lean:350` | P-step propagation | Temporal duality infrastructure | YES (with work) |
| `DirectMultiFamilyBFMCS.lean:308,311,421` | Modal forward cross-family | Structural limitation | NO (wrong approach) |

### Algebraic/ Sorries

| File | Sorry | Description | Removable? |
|------|-------|-------------|------------|
| `IntBFMCS.lean:1175,1177,1199,1213` | F/P witnesses | Dovetailing gap | HARD (fundamental) |
| `CanonicalEmbedding.lean:181,192,231,280,299` | Rat embedding | Incomplete construction | YES (with work) |
| `MultiFamilyBFMCS.lean:325,610` | Modal backward | Singleton approach blocked | NO (mathematically impossible) |
| `AlgebraicBaseCompleteness.lean:115,142` | BFMCS construction | Deferred to IntBFMCS | Depends on IntBFMCS |

## Possible Unification Paths

### Path A: Accept Two Layers (Recommended)

**Rationale**: The two-layer architecture reflects a genuine mathematical distinction:
- Proof-theoretic completeness (any domain works, use CanonicalMCS)
- Semantic TaskFrame models (need AddCommGroup + LinearOrder)

**Action Items**:
1. Document the architecture clearly in a design doc
2. Ensure the Succ-chain completeness is fully sorry-free
3. Provide transfer theorems connecting the layers

### Path B: W/D Separation with Embedding

**Idea**: Keep W = MCS (world states) separate from D = Int (duration type), but use an embedding to map CanonicalMCS into an Int-indexed structure.

**Requirements**:
1. Define `embed : CanonicalMCS -> Int` (injection into countable domain)
2. Show the embedding preserves CanonicalR
3. Transfer F/P proofs via the embedding

**Challenges**:
- CanonicalMCS may be uncountable
- Embedding may not preserve totality
- Still need to close the F/P sorries somehow

### Path C: Dovetailing Chain Fix

**Idea**: Solve the dovetailing gap directly at the Int chain level.

**Requirements** (from IntBFMCS analysis):
1. Process F-obligations immediately when they appear
2. Use "enriched seeds" that include all F-witnesses
3. Careful ordering to ensure witnesses precede their use

**Status**: Task 916 analyzed this extensively. The approach is complex and may not work for all temporal logics.

### Path D: Dense Domain (Rat/TimelineQuot)

**Idea**: Use a dense domain where between any two points, we can insert new witnesses.

**Current Status**:
- `CanonicalEmbedding.lean` has 5 sorries
- `DenseInstantiation.lean` inherits modal_backward sorry
- Not a complete solution

## Implementation Roadmap

### Phase 1: Stabilize Current Completeness (Task 35)

**Goal**: Eliminate sorries from Succ-chain completeness path

**Files**:
- `SuccChainFMCS.lean`: Fix P-step propagation sorry
- `SuccChainTruth.lean`: Document Box backward as acceptable (only forward direction needed)

**Outcome**: Working sorry-free completeness for discrete TM logic

### Phase 2: Document Architecture

**Goal**: Clear documentation of the two-layer architecture

**Deliverables**:
1. Architecture diagram showing data flow
2. Explanation of why two layers are necessary
3. Transfer theorem documentation

### Phase 3: F/P Witness Resolution (Optional)

**Goal**: Close the fundamental F/P sorries

**Approach**: Investigate dovetailing chain construction from Task 916

**Risk**: High complexity, may not succeed

### Phase 4: True Unification (Future)

**Prerequisite**: Phase 3 success

**Goal**: Single construction providing both Preorder and TaskFrame

**Design**: TBD based on Phase 3 findings

## Specific File Changes Needed

### For Phase 1 (Task 35)

1. **SuccChainFMCS.lean**:
   - Line ~350: Prove P-step propagation via temporal duality
   - Requires infrastructure from TemporalCoherence.lean

2. **CanonicalTaskRelation.lean**:
   - Verify backward_witness is no longer blocking

3. **SuccChainTruth.lean**:
   - Line 254: Document as non-blocking (completeness uses forward only)

### For Phase 2 (Documentation)

1. Create `.claude/context/project/architecture/two-layer-architecture.md`
2. Update existing module docstrings

### Not Recommended Changes

1. DO NOT try to add AddCommGroup to CanonicalMCS (mathematically impossible)
2. DO NOT remove the ParametricCanonical infrastructure (needed for semantic models)
3. DO NOT try to prove Box backward for singleton Omega (mathematically impossible)

## Conclusion

The two-layer architecture is NOT a bug to be fixed but reflects genuine mathematical structure:

1. **Layer 1 (Bundle/FMCS CanonicalMCS)**: Proof-theoretic construction, sorry-free F/P, Preorder only
2. **Layer 2 (Algebraic/ParametricCanonicalTaskFrame)**: Semantic construction, TaskFrame conformant, F/P sorries

**Recommended Path**: Accept the two-layer architecture, stabilize Succ-chain completeness (Task 35), and document the design clearly. True unification would require solving the dovetailing gap, which is a significant research problem.

## References

- Task 35 plan: `specs/035_prove_succ_chain_remaining_sorries/plans/01_prove-sorries-plan.md`
- Task 916 analysis: Dovetailing gap (archived in Boneyard)
- Task 1009: CanonicalMCS documentation
