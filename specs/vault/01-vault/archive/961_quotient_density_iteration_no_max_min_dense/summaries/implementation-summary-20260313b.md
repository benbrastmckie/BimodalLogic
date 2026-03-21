# Implementation Summary: Task 961

**Date**: 2026-03-13
**Session**: sess_1773437400_4f9e56
**Plan Version**: v004
**Status**: BLOCKED

## Objective

Prove NoMaxOrder, NoMinOrder, and DenselyOrdered for TimelineQuot using bounded iteration (depth 2) + Classical existence fallback.

## Investigation Summary

### Sorries Analyzed

| Line | Location | Issue | Status |
|------|----------|-------|--------|
| 226 | strict_intermediate_aux | d ~ c ~ a, goal is False (by_contra) | BLOCKED |
| 248 | strict_intermediate_aux | e ~ a, need strict intermediate | BLOCKED |
| 253 | strict_intermediate_aux | e NOT ~ a, e ~ b, need iteration | BLOCKED |
| 274 | strict_intermediate_aux | d ~ a, d NOT ~ b | BLOCKED |
| 278 | strict_intermediate_aux | d NOT ~ a, d ~ b | BLOCKED |
| 423 | NoMaxOrder | reflexive case | BLOCKED |
| 482 | NoMinOrder | reflexive case | BLOCKED |

### Key Finding: Bounded Iteration Insufficient

The v004 plan proposed bounded iteration (depth 2) with Classical fallback. Investigation revealed:

1. **Iteration Pattern**: Density iteration produces intermediates that fall into one of two equivalence classes [a] or [b]
2. **Swing Behavior**: Each intermediate is either ~ a or ~ b, causing the iteration to "swing" between sides
3. **No Termination Guarantee**: The swing can continue indefinitely since equivalence classes can contain infinitely many distinct MCSs
4. **h_none Limitation**: The `by_contra h_none` hypothesis only applies to strict-above-a witnesses, not to those ~ a

### Mathematical Gap Identified

The proof requires showing that density iteration MUST eventually produce a strict intermediate. This requires proving that:

- The sequence of intermediates cannot ALL be in [a] union [b]
- Eventually, some intermediate escapes both equivalence classes

This is equivalent to proving `density_frame_condition_strict`, which was attempted in Boneyard but has 18+ sorries.

### Attempted Approaches

1. **Direct iteration**: Case-split on each intermediate's equivalence. Produces unbounded case tree.
2. **by_contra pattern**: Assume no strict intermediate exists. Could not derive direct contradiction.
3. **intermediate_not_both_equiv**: Used successfully to show c cannot be ~ BOTH endpoints, but doesn't prove c is strict.
4. **Depth-limited recursion**: Current `strict_intermediate_aux` takes depth parameter but doesn't use it effectively.

### Code Understanding

The `density_frame_condition` theorem in DensityFrameCondition.lean:
- Case A: Uses F(neg delta) to construct intermediate
- Case B1: Returns W = M' (one of the endpoints!) when M' is reflexive
- Case B2: Uses gamma with G(gamma) in M' and gamma not in M'

Case B1 is the issue: density can return an endpoint itself, not a strict intermediate.

## Recommendation

This task requires one of:

1. **Complete the Boneyard `density_frame_condition_strict` proof**: Show that density produces strict intermediates directly
2. **Alternative approach**: Use a well-founded measure on distinguishing formulas
3. **Structural change**: Modify the quotient construction to guarantee strict density

## Technical Details

### Why h_none Doesn't Give Contradiction

At line 226:
```
h_none : forall c, a -> c -> NOT c -> a -> c -> b -> b -> c
```

This says: if c is strictly above a AND reaches b, then c ~ b.

The issue is that our candidates (c, d, e, ...) produced by density are often NOT strictly above a (they have c -> a), so h_none doesn't apply to them.

### Why Reflexive Case is Hard (line 423)

When p.mcs is reflexive:
- All futures via seriality might also be reflexive
- Reflexive MCSs form equivalence clusters
- Need to show cluster is NOT a maximum in the quotient
- Requires showing unboundedness at quotient level, not just MCS level

## Files Examined

- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` (main file)
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` (density construction)
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` (timeline lemmas)
- `Theories/Bimodal/Boneyard/Task956_StrictDensity/` (failed strict density attempt)

## Artifacts

- Plan: `specs/961_quotient_density_iteration_no_max_min_dense/plans/implementation-004.md`
- This summary: `specs/961_quotient_density_iteration_no_max_min_dense/summaries/implementation-summary-20260313b.md`

## Next Steps

User decision required:
1. Attempt to complete `density_frame_condition_strict` (significant effort)
2. Explore alternative proof strategy (research needed)
3. Accept sorry as technical debt (not recommended for core theorem)
