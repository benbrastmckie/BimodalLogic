# Research Report: Stale discrete_Icc_finite_axiom References

**Task**: 60 -- Clean up stale discrete_Icc_finite_axiom references
**Session**: sess_1779146360_eab605
**Date**: 2026-05-18

## Summary

The `discrete_Icc_finite_axiom` Lean axiom declaration has been fully eliminated from the codebase. No `axiom discrete_Icc_finite_axiom` declaration exists anywhere, including the Boneyard. However, three files still contain stale docstring/comment references to it. Two are in active code and one is in legacy Boneyard code.

## Findings

### Axiom Elimination Confirmed

A grep for `^axiom discrete_Icc_finite` across all of `Theories/` returns zero results. The axiom declaration is completely gone. The remaining axiom declarations in the active codebase are unrelated separation-theorem axioms in `SeparationThm.lean`.

### Stale References in Active Code (2 files)

#### 1. FrameClass.lean -- Lines 142-144

**File**: `Theories/Bimodal/FrameConditions/FrameClass.lean`
**Lines**: 142-144 (inside docstring for `DiscreteTemporalFrame`)
**Content**:
```
**Technical Debt**: The completeness proof for discrete frames relies on
`discrete_Icc_finite_axiom`, which asserts finiteness of
closed intervals. This axiom is documented technical debt.
```
**Action**: Remove or replace the three-line "Technical Debt" paragraph. The completeness proof no longer relies on this axiom; the `SuccExistence` approach bypassed it.

#### 2. SuccExistence.lean -- Line 996

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
**Lines**: 995-996 (inside docstring for `successor_exists`)
**Content**:
```
This is the key theorem that bypasses the covering lemma and replaces
discrete_Icc_finite_axiom for the discrete track.
```
**Action**: Reword to remove the reference to the now-deleted axiom. The docstring can simply note that this theorem bypasses the covering lemma for the discrete track, without referencing the eliminated axiom.

### Stale Reference in Boneyard (1 file, low priority)

#### 3. Boneyard Completeness.lean -- Line 146

**File**: `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean`
**Line**: 146
**Content**:
```
- **Blocked**: Full completeness requires `discrete_Icc_finite_axiom`
```
**Action**: Optional cleanup. This is in legacy/archived code (Boneyard). Can be cleaned up for consistency but is not high priority since Boneyard code is not on the active path.

### References in Specs/Docs (informational, no action needed)

The string `discrete_Icc_finite_axiom` appears in numerous markdown files under `specs/` (archived task reports, reviews, plans). These are historical records and should not be modified -- they document the state of the project at the time they were written.

## Recommendations

1. **Edit FrameClass.lean lines 142-144**: Remove the "Technical Debt" paragraph from the `DiscreteTemporalFrame` docstring. Suggested replacement: either delete the paragraph entirely, or replace with a note that completeness is now axiom-free via the SuccExistence approach.

2. **Edit SuccExistence.lean lines 995-996**: Reword to something like:
   ```
   This is the key theorem that bypasses the covering lemma for the discrete track.
   ```

3. **Optionally edit Boneyard Completeness.lean line 146**: Low priority. If editing, note that the axiom was eliminated and completeness is handled via the SuccExistence approach.

4. **Effort estimate**: Minimal -- two small docstring edits in active code. Approximately 10-15 minutes of implementation work including verification via `lake build`.
