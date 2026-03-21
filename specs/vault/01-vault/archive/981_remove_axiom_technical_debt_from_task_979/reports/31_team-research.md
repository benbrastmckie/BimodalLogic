# Research Report: Task #981

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-18
**Mode**: Team Research (2 teammates)
**Focus**: Study the termination blocker carefully to identify the most mathematically correct path forward
**Session ID**: sess_1773898120_b61263

## Summary

Two parallel research teammates analyzed the forward_F termination blocker from complementary angles: (A) deep mathematical structure analysis and (B) big-picture architectural analysis. Both converge on the same diagnosis: **the gap is real, not a proof technique failure**. The density argument produces witnesses for the wrong formula, and there is no well-founded measure that bounds the recursion. The construction itself has a coverage gap for late-arriving obligations.

## Key Findings

### Finding 1: The Density Argument Produces the Wrong Formula (Both Teammates)

When `pair(p.point_index, encode(phi)) <= n` (small-step case), density finds j such that `pair(p.point_index, encode(F^j(phi))) > n`. Then `witness_at_large_step` adds a witness `w` with `F^j(phi) in w.mcs` -- **NOT** `phi in w.mcs`.

Peeling off j layers of F requires j recursive calls, each of which may hit the small-step case again and introduce new j' layers. The accumulated depth is unbounded.

### Finding 2: All Proposed Well-Founded Measures Fail (Teammate A)

| Measure | Failure Mode |
|---------|--------------|
| Formula depth | INCREASES due to density (F^j(phi) > phi) |
| Density index j | Chosen fresh at each recursive call; not bounded |
| Build stage | Unbounded; timeline grows infinitely |
| Large-step propagation | w.point_index < m is possible (sparse build) |
| Lexicographic combinations | All components can increase simultaneously |

**Conclusion**: There is no finite descent argument. The termination is infinitary (every pair is eventually processed) but cannot be expressed as a well-founded recursion.

### Finding 3: The Coverage Theorem Has Its Own Gap (Teammate B)

Plan v13's `dovetailed_covers_reachable` theorem requires proving: "If M is in the timeline and CanonicalR M W, then W is in the timeline."

Two obstacles:
1. **Missed obligations**: When `pair(M.index, encode(phi)) <= entry_stage(M)`, the obligation was processed before M existed. The dovetailed step at that pair saw M as out-of-range and did nothing. The obligation is **permanently missed**.

2. **MCS non-uniqueness**: The dovetailed witness and the canonical `forward_F` witness may be different MCSs (Lindenbaum extensions are not unique in propositional logic).

### Finding 4: The Build Design Is the Root Cause (Teammate B)

The dovetailed construction, as currently implemented, **may genuinely fail** to cover F-obligations for points that arrive after their obligation step was processed. This is not a proof artifact -- it is a construction completeness issue.

The density workaround produces witnesses for larger-encoded formulas, not for phi directly. The construction would need redesign to:
- Re-process obligations retroactively when new points arrive, OR
- Use a pairing function that guarantees `pair(p.index, k) > entry_stage(p)` for all relevant k

### Finding 5: The j > 0 Sorry Is THE ONLY BLOCKER (Teammate A)

In `forward_F_core` (DovetailedTimelineQuot.lean:806), the structure is:
- Large step case: **PROVED** (witness_at_large_step gives phi directly)
- Small step, j = 0 case: **PROVED** (iteratedFuture 0 phi = phi)
- Small step, j > 0 case: **SORRY** (line 806)

Everything else is proved. The broken `forward_F_chain_witness` (lines 813-959) is misleading dead code.

## Synthesis

### Why All Approaches Hit the Same Wall

The fundamental issue is a **category mismatch** between what the construction provides and what the proof needs:

- **Need**: phi in witness.mcs
- **Get**: F^j(phi) in witness.mcs (where j > 0 in small-step case)

The density argument is essential for the construction (ensures large-step guarantee) but breaks the proof (changes the formula). This is why:
- Induction on formula depth fails (depth increases)
- Coverage theorem fails (witness has wrong formula)
- Large-step propagation fails (build is sparse)

### The Mathematical Truth vs Lean Provability

**Mathematical truth**: The dovetailed construction is exhaustive. Every (point_index, formula_encoding) pair is eventually processed. If the construction were redesigned to re-process missed obligations, forward_F would be provable.

**Lean provability**: The current infrastructure lacks:
1. A re-processing mechanism for missed obligations
2. A well-founded measure for the density recursion
3. A coverage theorem for late-arriving points

## Conflicts Resolved

No conflicts -- both teammates converge on identical diagnosis with complementary emphases.

## Recommendations

### Immediate Action (This Task)

**Replace broken proof structure with clean sorry**:

1. Remove `forward_F_chain_witness` (lines 813-959) -- it's broken dead code
2. Keep `forward_F_core` structure, place sorry at line 806 (j > 0 case)
3. Add comprehensive documentation of the mathematical gap
4. Apply symmetric cleanup to `backward_P_chain_witness`

The sorry should document:
```lean
-- FORMALIZATION GAP (Task 981):
-- Mathematically true: the dovetailed construction eventually processes all obligations.
-- Lean gap: there is no well-founded measure for this recursion.
-- The termination argument is infinitary (requires knowing the timeline is complete).
-- Fix requires: redesigning DovetailedBuild.lean to guarantee retroactive coverage.
```

### Long-Term Fix (New Task)

**Redesign DovetailedBuild.lean** to guarantee that every F-obligation is addressed, including late-arriving obligations. Options:

A. **Retroactive re-processing**: When a new point arrives, queue all its missed obligation pairs
B. **Entry-stage-aware pairing**: Use a pairing function where `pair(p.index, k) > entry_stage(p)` always

Estimated effort: 2-4 days of Lean formalization work.

### Non-Viable Approaches

- Well-founded recursion on any proposed measure
- Large-step propagation claim (`w.point_index >= m`)
- MCS uniqueness argument

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Termination structure | completed | high |
| B | Alternative approaches | completed | high |

## References

- DovetailedTimelineQuot.lean:652-960 - forward_F_core and broken chain witness
- DovetailedCoverage.lean:231 - witness_at_large_step (what it produces)
- DovetailedCoverageReach.lean - CanonicalR_chain definitions
- CanonicalTimeline.lean:183 - density_of_canonicalR sorry (separate issue)
- ClosureSaturation.lean:641-651 - previous analysis of same gap
- specs/981_*/reports/29_teammate-a-findings.md - Full Teammate A analysis
- specs/981_*/reports/29_teammate-b-findings.md - Full Teammate B analysis

## Next Steps

1. **This task**: Accept recommendation to clean up proof structure with documented sorry
2. **Follow-up task**: Redesign DovetailedBuild.lean with retroactive obligation processing
3. **Alternative**: Investigate full canonical model approach (requires `density_of_canonicalR` first)
