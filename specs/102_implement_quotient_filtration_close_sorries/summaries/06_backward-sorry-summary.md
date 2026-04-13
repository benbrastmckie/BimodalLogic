# Implementation Summary: Delete Unsound Backward Sorries (v6)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Status**: [COMPLETED]
- **Plan**: plans/06_backward-sorry-plan.md

## Summary

Deleted the 2 unsound backward sorry functions (`bx_until_backward` and `bx_since_backward`)
from Frame.lean and removed all delegation wrappers throughout the chain. These functions had
semantically unsound signatures: `phi in w` alone does not entail the full interval guard
`forall u in [w,v), phi in u` needed for `phi U psi in w`. Critically, none of these backward
functions had any downstream consumers -- they were dead code.

## Changes

### Phase 1 + 2: Delete backward functions and delegation chain

**Frame.lean**: Deleted `bx_until_backward` (line 650-656) and `bx_since_backward` (line 688-694).
Frame.lean now has 0 sorry statements.

**TruthLemma.lean**: Deleted `until_backward_strict_mcs` and `since_backward_strict_mcs`.
Updated module docstring to document removal.

**CanonicalChain.lean**: Deleted `delegation_until_backward` and `delegation_since_backward`.
Updated eventuality resolution status docstring (v5 -> v6).

**Realization.lean**: Deleted `until_backward` and `since_backward`. Updated docstring.

**LocusControl.lean**: Deleted `bx_until_backward'` and `bx_since_backward'`. Updated docstring.

### Phase 3: Verification

- `lake build` passes cleanly (954 jobs, 0 errors)
- Frame.lean: 0 sorry statements (was 2)
- BXCanonical/ directory: 1 sorry remains (Completeness.lean:154, out of scope)
- 4 axiom declarations (unchanged baseline)
- Forward direction (`bx_until_eventuality_resolution`, `bx_since_eventuality_resolution`) unchanged

## Key Insight

The round 6 research correctly identified that these backward functions were semantically
unsound with 95% confidence. The additional insight during implementation was that ALL
backward functions in the delegation chain (Frame -> TruthLemma/CanonicalChain -> Realization
-> LocusControl) were dead code with zero consumers. This made the fix a clean deletion
rather than a restructuring.

## Sorry Count Delta

- Before: 2 sorry in Frame.lean + 1 sorry in Completeness.lean = 3 in BXCanonical/
- After: 0 sorry in Frame.lean + 1 sorry in Completeness.lean = 1 in BXCanonical/
- Net reduction: 2 sorries eliminated
