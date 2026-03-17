# Research Report: Task #986

**Task**: 986 - bfmcs_construction_for_int
**Started**: 2026-03-16T12:00:00Z
**Completed**: 2026-03-16T12:45:00Z
**Effort**: 4-6 hours estimated
**Dependencies**: None (Task 985 completed, provides algebraic infrastructure)
**Sources/Inputs**: Codebase exploration (Lean source files), context files, ROAD_MAP.md
**Artifacts**: specs/986_bfmcs_construction_for_int/reports/research-001.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Current State**: CanonicalFMCS.lean provides a sorry-free BFMCS construction for `D = CanonicalMCS` with forward_F and backward_P. However, CanonicalMCS lacks `AddCommGroup` structure required for algebraic completeness.
- **Core Blocker**: DovetailingChain.lean (Int-indexed) has 2 sorries: `forward_F` and `backward_P` witness construction. It's also DEPRECATED per ROAD_MAP.md.
- **Recommended Approach**: Direct construction of temporally coherent BFMCS over Int using the CanonicalMCS construction as a template, with CanonicalR-based witness existence.

## Context & Scope

### Task Goal

Prove a sorry-free BFMCS construction for D = Int: given any MCS M, construct a temporally coherent BFMCS over Int containing M. This is the core blocker for algebraic base completeness (task 987).

### Key Definitions

1. **BFMCS** (Bundle of Family of MCS): A collection of indexed MCS families (`FMCS D`) with modal coherence conditions. Defined in `BFMCS.lean:88-119`.

2. **FMCS** (Family of MCS): A single time-indexed family of MCS with forward_G, backward_H coherence. Defined in `FMCSDef.lean`.

3. **TemporalCoherentFamily**: FMCS extended with `forward_F` and `backward_P` properties. Defined in `TemporalCoherence.lean:147-153`:
   - `forward_F`: If F(phi) in mcs(t), then exists s > t with phi in mcs(s)
   - `backward_P`: If P(phi) in mcs(t), then exists s < t with phi in mcs(s)

4. **BFMCS.temporally_coherent**: All families in the BFMCS have forward_F and backward_P. Defined in `TemporalCoherence.lean:217-220`.

## Findings

### Codebase Patterns

#### Sorry-Free CanonicalMCS Construction (Active Code)

File: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

The sorry-free construction uses `D = CanonicalMCS` (the type of ALL maximal consistent sets). Key insight from line 22-40:

```lean
-- The v5 plan originally proposed using CanonicalReachable (future-reachable from M₀).
-- This works for forward_F (future witnesses are future-reachable by transitivity),
-- but FAILS for backward_P because:
-- - `canonical_backward_P` gives witness W with `h_content(w.world) ⊆ W`
-- - For W to be in CanonicalReachable, we need `CanonicalR M₀ W` (= `g_content(M₀) ⊆ W`)
-- - There is no TM axiom that derives `g_content(M₀) ⊆ W` from the available hypotheses
--
-- The all-MCS approach sidesteps this entirely:
-- - Every MCS is in the domain by construction
-- - No reachability requirement for witnesses
-- - forward_F and backward_P are genuinely trivial
```

This construction proves `temporal_coherent_family_exists_CanonicalMCS` (line 293-311) without sorries.

**Why CanonicalMCS Can't Be Used Directly for Algebraic Completeness**:
- The algebraic infrastructure (`ParametricRepresentation.lean`, `DiscreteInstantiation.lean`) requires `D : Type*` with `[AddCommGroup D]`, `[LinearOrder D]`, `[IsOrderedAddMonoid D]`.
- CanonicalMCS is a Preorder (partial order from reflexive closure of CanonicalR), but it lacks:
  - Addition operation (`(+)`)
  - Negation operation (`(-)`)
  - Group identity (`0`)
- The algebraic representation theorem uses D as a translation group for task semantics.

#### Deprecated DovetailingChain (Int-indexed, 2 Sorries)

File: `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean`

The DovetailingChain approach was an attempt to build `FMCS Int` with temporal coherence. It has 2 sorries at lines 1893 and 1905:
- `buildDovetailingChainFamily_forward_F`: sorry
- `buildDovetailingChainFamily_backward_P`: sorry

Per ROAD_MAP.md (lines 541-542), this file is DEPRECATED (marked 2026-03-11, Task 959).

### Algebraic Infrastructure (Task 985)

Task 985 created the D-parametric algebraic representation infrastructure:

1. **ParametricRepresentation.lean**: Conditional representation theorem that takes a `construct_bfmcs` function as argument:
   ```lean
   theorem parametric_algebraic_representation_conditional
       (φ : Formula) (h_not_prov : ...)
       (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
         Σ' (B : BFMCS D) (h_tc : B.temporally_coherent) ...)
   ```

2. **DiscreteInstantiation.lean**: Provides `DiscreteCanonicalTaskFrame : TaskFrame Int` and `discrete_representation_conditional`, but notes (lines 26-34):
   ```
   The full representation theorem for D = Int requires constructing a temporally
   coherent BFMCS over Int. This construction is non-trivial and depends on:
   1. The existence of F-witnesses (temporal forward coherence)
   2. The existence of P-witnesses (temporal backward coherence)
   ```

### Context File Review

#### ROAD_MAP.md Dead Ends (Lines 515-542)

All Int/Rat import approaches are FORBIDDEN. However, the algebraic approach (D = Int) is different from the "D-from-syntax" constraint:
- The constraint applies to **standard completeness** where D must emerge from canonical timeline properties.
- The algebraic approach uses D as a **parameter** and proves conditional results.
- Task 985's approach explicitly notes D is a parameter, not constructed from syntax.

**Key Distinction**: Task 986 is NOT attempting D-from-syntax completeness. It's providing the `construct_bfmcs` argument for the algebraic representation theorem, which is valid for any D with the required typeclasses.

### External Resources

The mathematical pattern for F/P witness construction is standard in modal logic literature:
- F(phi) in MCS M implies there exists MCS W containing phi with CanonicalR M W
- This is proven via `canonical_forward_F` in the codebase (line 219-228 of CanonicalFMCS.lean)

The challenge is **embedding** this into an Int-indexed structure while maintaining coherence.

### Recommendations

#### Approach 1: Order-Embedding Transfer (Recommended)

**Strategy**: Build FMCS over Int using an order-preserving map from Int to CanonicalMCS.

1. Given root MCS M₀, construct the CanonicalMCS Preorder.
2. Select a countable chain `c : Int → CanonicalMCS` with `c(0) = ⟨M₀, h_mcs₀⟩`.
3. Define `mcs_int : Int → Set Formula` as `mcs_int t := (c t).world`.
4. Forward_G and backward_H follow from the chain being order-preserving.
5. Forward_F and backward_P use `canonical_forward_F`/`canonical_backward_P` on CanonicalMCS, then show the witness is in the chain's range.

**Challenge**: Ensuring the witness from `canonical_forward_F` lands in the chain's range. This may require:
- Using a sufficiently "dense" chain (hitting all future/past-reachable MCSs)
- Or accepting a weaker result where witnesses are found within the Int-indexed structure

**Estimated Complexity**: Medium (3-4 hours)

#### Approach 2: Dovetailing Fix

**Strategy**: Fix the sorries in DovetailingChain.lean.

The issue is constructing witnesses for F(phi) and P(phi). The dovetailing approach was designed to interleave forward and backward chains, but the witness construction was never completed.

**Challenge**: The dovetailing approach is complex and was abandoned. The sorries are in lines 1893 and 1905.

**Estimated Complexity**: High (6+ hours), with uncertain success.

#### Approach 3: Direct Construction

**Strategy**: Build FMCS Int directly without using CanonicalMCS as an intermediate.

1. Start from MCS M₀ at time 0.
2. For positive times: build forward chain using G-persistence.
3. For negative times: build backward chain using H-persistence.
4. For forward_F: given F(phi) at time t, construct witness MCS at some s > t using `canonical_forward_F`, then map it to the chain.
5. For backward_P: similar using `canonical_backward_P`.

**Challenge**: Similar to Approach 1 - ensuring witnesses land in the Int-indexed structure.

**Estimated Complexity**: Medium-High (4-5 hours)

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | LOW | Task 986 is NOT D-from-syntax completeness; it's parametric algebraic approach which is explicitly allowed |
| DovetailingChain | MEDIUM | Confirms DovetailingChain is deprecated; fixing it is not recommended |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Algebraic Verification Path | PAUSED | Task 986 contributes to this strategy by providing BFMCS construction |
| Indexed MCS Family Approach | ACTIVE | Task 986's FMCS construction aligns with this approach |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| D-parametric vs D-from-syntax distinction | ROAD_MAP.md Reflection | Partial | extension |
| BFMCS temporal coherence requirements | Key Definitions | Yes (in code) | N/A |

### New Context File Recommendations

None needed - the existing context is adequate.

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| ROAD_MAP.md | Algebraic Verification Path | Clarify that D-parametric approach is different from D-from-syntax constraint | Medium | No |

### Summary

- **New files needed**: 0
- **Extensions needed**: 1 (optional clarification in ROAD_MAP.md)
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **Approach**: Recommend Order-Embedding Transfer (Approach 1) as primary strategy.
2. **DovetailingChain**: Do NOT attempt to fix; it's deprecated and complex.
3. **Scope**: Focus on providing the `construct_bfmcs` function for `parametric_algebraic_representation_conditional`.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Witness may not land in Int-indexed chain | High | Use all-MCS approach for witnesses, then project back to Int |
| Preorder on CanonicalMCS is not total | Medium | Int structure is total; use embedding that preserves order |
| Construction may be complex | Medium | Start with simplest case; iterate |

## Appendix

### Search Queries Used

- `Glob: **/*BFMCS*.lean`, `**/*CanonicalFMCS*.lean`
- `Grep: BFMCS`, `temporal_coherent_family_exists`, `forward_F.*sorry`
- `lean_local_search: temporal_coherent`, `BFMCS`, `forward_F`, `CanonicalMCS`

### Key Files

| File | Purpose | Lines of Interest |
|------|---------|-------------------|
| `CanonicalFMCS.lean` | Sorry-free CanonicalMCS construction | 219-251 (forward_F, backward_P) |
| `BFMCS.lean` | BFMCS definition | 88-119 |
| `TemporalCoherence.lean` | TemporalCoherentFamily definition | 147-153, 217-220 |
| `ParametricRepresentation.lean` | Conditional representation theorem | 215-232 |
| `DiscreteInstantiation.lean` | Int typeclass verification | 59-62 |
| `ROAD_MAP.md` | Dead ends, strategies | 515-542, 110-134 |

### References

- CanonicalFMCS.lean module header (lines 7-54)
- ROAD_MAP.md Dead End: All Int/Rat Import Approaches (lines 515-542)
- Task 985 completion: D-parametric algebraic representation theorem
