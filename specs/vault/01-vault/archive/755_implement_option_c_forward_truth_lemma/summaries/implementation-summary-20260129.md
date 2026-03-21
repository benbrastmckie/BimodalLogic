# Implementation Summary: Task #755

**Task**: Implement Option C: Forward Truth Lemma via FMP Path
**Date**: 2026-01-29
**Status**: PARTIAL - Architectural blocker discovered

## Overview

Attempted to remove the sorry from `truth_at_implies_semantic_truth` in SemanticCanonicalModel.lean to achieve sorry-free weak completeness via the FMP path. Analysis revealed a fundamental architectural gap that prevents completion without significant refactoring.

## Key Findings

### The Fundamental Gap

The theorem `truth_at_implies_semantic_truth` requires proving:
```lean
truth_at (SemanticCanonicalModel phi) tau 0 phi →
semantic_truth_at_v2 phi (tau.states 0 ht) _ phi
```

This means: if the formula is true under recursive evaluation, then the assignment says it's true.

**The problem**: `semantic_truth_at_v2` just checks a boolean in a FiniteWorldState's assignment. A FiniteWorldState only needs to be `IsLocallyConsistent`, which enforces:
- `v(bot) = false`
- `v(psi.imp chi) = true AND v(psi) = true → v(chi) = true`
- `v(box psi) = true → v(psi) = true` (T-axiom)

But `truth_at_implies_semantic_truth` needs the REVERSE directions:
- `truth_at (psi.imp chi) = true → v(psi.imp chi) = true`
- `truth_at (box psi) = true → v(box psi) = true`

For MCS-derived world states, these hold by `closure_mcs_imp_iff` and MCS properties.
For arbitrary locally consistent assignments, they do NOT hold.

### Why semantic_weak_completeness Works

The existing `semantic_weak_completeness` theorem works by **contrapositive**:
1. Assume phi is NOT provable
2. Build an MCS containing phi.neg (via Lindenbaum)
3. Build a world state from this MCS where phi is FALSE in the assignment
4. This MCS-derived state IS consistent between assignment and truth

So `semantic_weak_completeness` only needs world states WHERE the assignment says phi is false, and it builds them from MCS (where assignment = truth).

### Why the Forward Direction Fails

`valid_implies_semantic_truth` starts with an arbitrary SemanticWorldState and needs to show the assignment says phi is true. But:
1. The world state might not be MCS-derived
2. Local consistency doesn't guarantee assignment matches recursive truth
3. Box semantics quantify over ALL histories (all world states), not just the current one

## Changes Made

### Files Modified

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`:
  - Added `valid_implies_neg_unsatisfiable` lemma (proven)
  - Added `set_mcs_neg_excludes_helper` lemma (proven)
  - Enhanced documentation explaining the architectural gap
  - Documented potential solutions in code comments

### New Documentation

Added detailed documentation explaining:
- The truth predicate gap (recursive vs assignment-based)
- Why local consistency is weaker than MCS properties
- Why the contrapositive direction (semantic_weak_completeness) works
- Potential architectural solutions (listed but not implemented)

## Potential Solutions (Not Implemented)

1. **Restrict to MCS-derived states**: Modify SemanticCanonicalModel to only contain MCS-derived SemanticWorldStates. This would require changes to the frame definition.

2. **Alternative model construction**: Use the coherent MCS family approach from the Representation path, which builds models entirely from MCS's.

3. **Validity-based argument**: Show that for VALID formulas specifically, the structure forces correspondence (likely requires deep changes).

4. **Accept the sorry**: The existing `semantic_weak_completeness` IS fully proven and provides completeness. The `sorry_free_weak_completeness` through the forward direction may be the wrong approach.

## Recommendations

1. **Use existing semantic_weak_completeness**: This theorem IS sorry-free and provides weak completeness. The forward direction (`truth_at_implies_semantic_truth`) may be unnecessary.

2. **Consider Option B**: The Representation path with coherent MCS families may be more tractable for sorry-free completeness.

3. **Architectural review**: The current SemanticCanonicalModel allows too-general world states. Consider restricting to MCS-derived states only.

## Sorries Remaining

| Location | Reason | Fixable? |
|----------|--------|----------|
| Line 219 | compositionality axiom | No (mathematically false) |
| Line 629 | truth_at_implies_semantic_truth | Requires architectural change |

## Verification

- `lake build` passes with no errors
- All existing tests continue to pass
- Documentation accurately describes the current state
