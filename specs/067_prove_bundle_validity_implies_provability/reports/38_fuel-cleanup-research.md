# Research Report: Fuel Approach Cleanup Before Bulldozing Implementation

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-30
**Session**: sess_1774884074_101d8e
**Focus**: Appropriateness of fuel cleanup and relationship analysis

## Executive Summary

After comprehensive analysis of the codebase, research artifacts, and ROADMAP.md, I recommend:

1. **Do NOT remove fuel-based code before implementing bulldozing** - The bulldozing approach REUSES the fuel-based termination structure
2. **The fuel parameter should be PRESERVED** - Bulldozing only adds F-persistence to close the invariant gap
3. **Update ROADMAP.md** with a "Dead Ends" section documenting why the pure fuel-invariant approach fails
4. **The actual sorries remain in fuel=0 branches** - These become provably unreachable with F-persistence, not by removing fuel

## Question 1: Appropriateness of Removing Fuel Approaches

### Answer: NO - Do Not Remove

The bulldozing plan (13_bulldozing-f-persistence.md) **does not replace the fuel-based termination structure**. Instead, it:

1. **Keeps** the `remaining_steps` parameter for termination
2. **Keeps** the fuel invariant `h_inv : remaining_steps >= (B - k) * B + 1`
3. **Adds** `f_content u` to the seed to provide F-persistence
4. **Proves** the sorries become impossible via the F-persistence + BRS cascade

The fuel approach is NOT a dead end because of the fuel mechanism itself - it's blocked because the chain construction allows F-obligations to be destroyed. Bulldozing fixes the construction while preserving the fuel-based termination proof.

**Evidence from Plan 13 (lines 35-37)**:
```
**Non-Goals**:
- Eliminating the fuel parameter entirely (it may still be useful for termination structure)
```

## Question 2: Relationship Analysis

### How Fuel Approaches Relate to Bulldozing

| Aspect | Fuel Approach (Plans 1-12) | Bulldozing (Plan 13) |
|--------|---------------------------|----------------------|
| Termination measure | `remaining_steps` | `remaining_steps` (SAME) |
| Invariant | `remaining_steps >= (B-k)*B + 1` | Same invariant (PRESERVED) |
| Chain construction | Standard `constrained_successor_seed_restricted` | Extended with `f_content u` |
| k >= B gap | Cannot prove False | Proves False via F-persistence cascade |
| fuel=0 sorry | Semantically unreachable but unprovable | Provably unreachable with cascade |

### Key Insight: They Are NOT Separate Attempts

Bulldozing is a **construction-level fix** that enables the fuel invariant to work. The relationship is:

1. **Plans 1-12**: Tried to prove `k >= B` is impossible using only the fuel invariant
2. **Root cause identified**: F-obligations can be destroyed by Lindenbaum extension (Report 34)
3. **Plan 13 (Bulldozing)**: Adds F-persistence to construction, making `k >= B` boundary impossible

The fuel infrastructure is **reused**, not replaced.

## Question 3: Fuel Element Inventory

### Elements That Should Be PRESERVED (Not Removed)

**1. Forward Bounded Witness with Fuel Invariant (SuccChainFMCS.lean)**
- `restricted_bounded_witness_wf` (lines 2890-3042) - KEEP
- `remaining_steps` parameter - KEEP
- `h_inv` hypothesis - KEEP
- Wrapper `restricted_bounded_witness` (lines 3051-3067) - KEEP

**2. Backward Bounded Witness with Fuel (SuccChainFMCS.lean)**
- `restricted_backward_bounded_witness_fueled` (lines 5596-5663) - KEEP
- `restricted_backward_bounded_witness` wrapper (lines 5672-5681) - KEEP

**3. Combined Bounded Witnesses with Fuel (SuccChainFMCS.lean)**
- `restricted_combined_bounded_witness_fueled` (lines 5754-5822) - KEEP
- `restricted_combined_bounded_witness` wrapper (lines 5830-5839) - KEEP
- `restricted_combined_bounded_witness_P_fueled` (lines 5945-6019) - KEEP
- `restricted_combined_bounded_witness_P` wrapper (lines 6025-6034) - KEEP

### Elements That Are Already Dead/Deprecated (Not Active Path)

These are marked as deprecated in the codebase and not on the completeness path:
- `g_content_union_brs_consistent` (line ~1659) - deprecated path
- `augmented_seed_consistent` (line ~1688) - deprecated path
- `constrained_successor_seed_restricted_consistent` multi-BRS variant (line ~2005) - deprecated path

### Active Sorries to Be Closed by Bulldozing

| Location | Function | Type | Bulldozing Resolution |
|----------|----------|------|----------------------|
| Line 3006 | `restricted_bounded_witness_wf` | k >= B case, resolved branch | F-persistence + BRS cascade proves False |
| Line 3037 | `restricted_bounded_witness_wf` | k >= B case, deferred branch | F-persistence + BRS cascade proves False |
| Line 5610 | `restricted_backward_bounded_witness_fueled` | fuel=0 case | Becomes unreachable with sufficient fuel |
| Line 5768 | `restricted_combined_bounded_witness_fueled` | fuel=0 case | Becomes unreachable with sufficient fuel |
| Line 5964 | `restricted_combined_bounded_witness_P_fueled` | fuel=0 case | Becomes unreachable with sufficient fuel |

### References in Other Files

**Completeness.lean (lines 207-248, 375-376)** - Documentation comments referencing fuel approach:
- These explain the current state (fuel-exhaustion sorry pending)
- Should be updated AFTER bulldozing succeeds to reflect the complete proof

## Question 4: ROADMAP.md Update Recommendation

### Current State

ROADMAP.md (checked as `/home/benjamin/Projects/ProofChecker/ROADMAP.md`) discusses:
- Class A and Class B sorries
- The stabilization gap in Class B
- Strategies for resolution

### Recommended Update: Add "Dead Ends" Section

Add a new section documenting what was learned from Plans 1-12:

```markdown
## Dead Ends (Documented for Future Reference)

### Pure Fuel-Invariant Termination (Plans 1-12)

**Approach**: Thread a fuel invariant `remaining_steps >= (B-k)*B + 1` through the bounded
witness recursion to prove termination and refute the fuel=0 case.

**Why It Fails**: The invariant cannot prove `k >= B` is impossible because:
1. The chain construction via Lindenbaum extension can destroy F-obligations
2. `boundary_resolution_set` only forces resolution at max depth (B-1)
3. Sub-maximal F-formulas can be deferred indefinitely
4. The invariant collapses to `remaining_steps >= 1` when k >= B, insufficient for recursion

**Lesson Learned**: The fuel structure is sound, but the chain construction lacks F-persistence.
The solution is not to abandon fuel, but to strengthen the construction.

**Resolution**: Plan 13 (Bulldozing) adds `f_content u` to the seed, providing F-persistence
by construction. This makes the `k >= B` case impossible, closing the gap.

**References**:
- Report 34: specs/067_prove_bundle_validity_implies_provability/reports/34_team-research.md
- Report 37: specs/067_prove_bundle_validity_implies_provability/reports/37_team-research.md
- Summary 12: specs/067_prove_bundle_validity_implies_provability/summaries/12_chain-resolution-summary.md
```

## Recommended Approach

### Phase 0: Documentation Update (BEFORE Implementation)

1. Update ROADMAP.md with Dead Ends section (above)
2. Add comments in SuccChainFMCS.lean at lines 3006/3037:
   ```lean
   -- NOTE: This sorry is closed by F-persistence from bulldozing.
   -- The pure fuel invariant cannot prove k >= B impossible because F-obligations
   -- can be destroyed by Lindenbaum extension. With f_content in seed, F-formulas
   -- persist, and the BRS cascade ensures all resolve within B steps.
   ```

### Phase 1-6: Follow Plan 13 (Bulldozing)

Execute Plan 13 exactly as written. The fuel infrastructure remains in place.

### Phase Final: Cleanup Documentation

After bulldozing succeeds:
1. Update Completeness.lean comments to reflect the complete proof
2. Update ROADMAP.md to mark Class B as resolved
3. Remove "BLOCKED" annotations from plans

## Summary

| Question | Answer |
|----------|--------|
| Remove fuel before bulldozing? | **NO** - bulldozing reuses fuel structure |
| Are they separate attempts? | **NO** - bulldozing extends/fixes the fuel approach |
| What to remove? | **NOTHING** - deprecated code is separate from active path |
| Update ROADMAP.md? | **YES** - add Dead Ends section documenting the learning |

The fuel-based termination is the RIGHT approach; it just needs F-persistence from the construction to close the invariant gap in the `k >= B` case.
