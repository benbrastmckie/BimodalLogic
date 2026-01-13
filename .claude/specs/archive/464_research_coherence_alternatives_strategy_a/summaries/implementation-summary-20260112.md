# Implementation Summary: Task #464

**Completed**: 2026-01-12
**Duration**: ~2 hours
**Session ID**: sess_1768281942_e65015

## Overview

Implemented Strategy A from research-001.md: strengthened `canonical_task_rel` with G-persistence and H-persistence conditions to enable compositionality proofs for the uniform sign cases.

## Changes Made

### 1. Strengthened `canonical_task_rel` Definition (lines 2055-2060)

Added two new persistence conditions to the definition:

```lean
def canonical_task_rel (S : CanonicalWorldState) (t : CanonicalTime) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧  -- G-persistence
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)         -- H-persistence
```

**Key insight**: G-persistence captures "if Gφ ∈ S and t > 0, then Gφ ∈ T" - the G-formula itself persists, not just its content.

### 2. Updated `canonical_nullity` (lines 2080-2110)

Extended proof to show persistence conditions are vacuously true at t=0:
- G-persistence: vacuously true (0 is not > 0)
- H-persistence: vacuously true (0 is not < 0)

Uses same `exfalso` pattern as existing future/past transfer cases.

### 3. Updated `forward_extension` (lines 2521-2581)

Added proof of G-persistence for forward extension:
- From Gφ ∈ S, derive GGφ ∈ S (via `set_mcs_all_future_all_future` / G-4 axiom)
- GGφ ∈ S means Gφ is in forward_seed S
- Lindenbaum extension preserves this, so Gφ ∈ T

H-persistence is vacuously true (forward extension has d > 0, not < 0).

### 4. Updated `canonical_compositionality` (lines 2190-2415)

Extended 3-part proof to 5-part proof with new persistence cases:
- **Part 4 (G-persistence)**: For x + y > 0, prove Gφ ∈ S → Gφ ∈ U
- **Part 5 (H-persistence)**: For x + y < 0, prove Hφ ∈ S → Hφ ∈ U

#### Proven Cases (no sorry)

| Condition | Part 2 (future_transfer) | Part 3 (past_transfer) | Part 4 (G-persist) | Part 5 (H-persist) |
|-----------|--------------------------|------------------------|---------------------|---------------------|
| x > 0, y > 0, x+y > 0 | Proven | N/A | Proven | N/A |
| x < 0, y < 0, x+y < 0 | N/A | Proven | N/A | Proven |

#### Known Gaps (sorry remains)

| Condition | Issue |
|-----------|-------|
| x > 0, y <= 0, x+y > 0 | Gφ ∈ T but y <= 0 blocks extraction |
| x <= 0, y > 0, x+y > 0 | Cannot get Gφ into T when x <= 0 |
| x < 0, y >= 0, x+y < 0 | Hφ ∈ T but y >= 0 blocks extraction |
| x >= 0, y < 0, x+y < 0 | Cannot get Hφ into T when x >= 0 |

These mixed-sign cases represent a fundamental semantic/syntactic gap: the intermediate state T doesn't provide the right "bridge" when the signs differ.

### 5. Updated `past_formula_persistence` (line 2167)

Fixed projection path from `hrel.2.2` to `hrel.2.2.1` due to new definition structure.

## Files Modified

- `Theories/Bimodal/Metalogic/Completeness.lean`
  - Lines 2048-2060: canonical_task_rel definition with persistence conditions
  - Lines 2069-2110: canonical_nullity with 5-part proof
  - Lines 2130-2170: Updated persistence lemma projections
  - Lines 2190-2415: canonical_compositionality with parts 4 and 5
  - Lines 2521-2581: forward_extension with G-persistence proof

## Verification

- `lake build`: Success (968 jobs)
- No new errors introduced
- 8 sorries in canonical_compositionality (expected - mixed cases)
- All uniform-sign cases now proven without sorry

## What's Proven

1. **Nullity**: Full proof (no sorry) - all 5 conditions proven
2. **Forward Extension**: Full proof (no sorry) - includes G-persistence
3. **Compositionality - Uniform Cases**:
   - x > 0, y > 0: future_transfer and G-persistence proven
   - x < 0, y < 0: past_transfer and H-persistence proven

## What Remains (Known Gaps)

1. **Compositionality - Mixed Cases**: 8 sorries for cases where x and y have different signs
2. **backward_extension**: Pre-existing sorry (not addressed by Strategy A)
3. **backward_seed_consistent**: Pre-existing sorry

## Architectural Notes

The mixed-sign gaps are fundamental to the "pointwise" transfer approach:
- When x > 0 and y <= 0, we can get Gφ ∈ T via G-persistence
- But y <= 0 means future_transfer doesn't apply from T to U
- The semantic fact that x + y > 0 doesn't translate syntactically

Possible future approaches:
- Strategy D: Assume Duration discreteness (allows step-by-step construction)
- Relativized completeness: Prove for restricted duration subsets
- Alternative canonical model construction

## User Constraints Respected

- No Duration discreteness assumptions
- Duration remains structurally agnostic (neither discrete, dense, nor continuous)
- No new axioms added to the logic
