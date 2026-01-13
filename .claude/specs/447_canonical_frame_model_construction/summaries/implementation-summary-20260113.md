# Implementation Summary: Task #447

**Task**: Canonical frame and model construction
**Completed**: 2026-01-13
**Session ID**: sess_1768264741_fa8e74
**Duration**: ~2.5 hours

## Summary

Implemented Phase 4 of the completeness proofs for TM bimodal logic. Replaced the placeholder `CanonicalTime := Int` with the agnostic `Duration` type from Task 446. Defined the canonical task relation with three-part transfer (modal + conditional temporal), proved nullity, implemented compositionality (with documented partial completion for temporal cases), and constructed the canonical frame, valuation, and model.

## Changes Made

### Core Implementations

1. **Duration Type Integration** (Phase 1)
   - Changed `CanonicalTime` from `def` to `abbrev` pointing to `Duration`
   - Updated `canonical_frame` type from `TaskFrame Int` to `TaskFrame Duration`
   - Updated docstrings to reflect the agnostic duration construction

2. **Canonical Task Relation** (Phase 2)
   - Defined helper predicates: `modal_transfer`, `future_transfer`, `past_transfer`
   - Implemented `canonical_task_rel` with three-part structure:
     - Modal transfer: Always applies (box formulas transfer to contents)
     - Future transfer: Conditional on `t > 0` (all_future formulas transfer)
     - Past transfer: Conditional on `t < 0` (all_past formulas transfer)

3. **Nullity Property** (Phase 3)
   - Proved `canonical_nullity`: `canonical_task_rel S 0 S` for all MCS S
   - Modal case uses existing `set_mcs_box_closure` (Modal T axiom)
   - Temporal cases are vacuously true (0 is neither positive nor negative)

4. **Compositionality Property** (Phase 4 - PARTIAL)
   - Proved modal transfer composition using new `set_mcs_box_box` lemma
   - Added helper lemmas:
     - `set_mcs_box_box`: box phi in S implies box box phi in S (Modal 4)
     - `temp_4_past`: Derived Hphi -> HHphi via temporal duality
     - `set_mcs_all_future_all_future`: Gphi in S implies GGphi in S
     - `set_mcs_all_past_all_past`: Hphi in S implies HHphi in S
   - Temporal cases have `sorry` placeholders with detailed documentation
   - Known issue: Definition transfers *contents* of G/H formulas, not the formulas themselves

5. **Canonical Frame** (Phase 5)
   - Replaced axiom with definition
   - Uses CanonicalWorldState, canonical_task_rel, canonical_nullity, canonical_compositionality

6. **Canonical Valuation and Model** (Phase 6)
   - `canonical_valuation`: Prop-valued (atom membership in MCS)
   - `canonical_model`: TaskModel canonical_frame with the valuation

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
  - Lines 1010-1122: Added modal/temporal 4 lemmas for MCS
  - Lines 1827: Changed CanonicalTime to abbrev Duration
  - Lines 1829-1895: Added transfer definitions and canonical_task_rel
  - Lines 1897-1965: Added canonical_nullity proof
  - Lines 1967-2131: Added canonical_compositionality (partial)
  - Lines 2133-2155: Changed canonical_frame from axiom to definition
  - Lines 2164-2189: Changed canonical_valuation and canonical_model from axioms to definitions

## Verification

- Lake build: Success (with sorry warnings from pre-existing and new code)
- All goals closed for:
  - `canonical_nullity` (complete)
  - Modal case of `canonical_compositionality` (complete)
  - `canonical_frame` definition (compiles)
  - `canonical_valuation` and `canonical_model` definitions (compile)

## Known Gaps and Recommendations

### Temporal Compositionality Gap

The temporal cases in `canonical_compositionality` have `sorry` placeholders. The issue is:

**Current definition**: `t > 0 -> (Gphi in S -> phi in T)`
**Problem**: This transfers the *content* of G-formulas, not the G-formulas themselves.

To compose:
- From Gphi in S and x > 0, we get phi in T
- But to use hTU_future, we need Gphi in T (not just phi in T)

**Recommended fix**: Revise the task relation definition to add temporal persistence:
```lean
def canonical_task_rel (S : CanonicalWorldState) (t : Duration) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T /\
  (t > 0 -> future_transfer S T) /\
  (t < 0 -> past_transfer S T) /\
  (t > 0 -> forall phi, Formula.all_future phi in S -> Formula.all_future phi in T) /\ -- Future persistence
  (t < 0 -> forall phi, Formula.all_past phi in S -> Formula.all_past phi in T)        -- Past persistence
```

This would require re-verifying nullity (should still hold) and completing the compositionality proof.

### Follow-up Tasks

1. **Task for temporal compositionality fix**: Revise canonical_task_rel definition and complete compositionality proof
2. **canonical_history** remains as axiom (Task 448 scope)
3. **Duration sorry proofs** from Task 446 do not block this task but should be addressed

## Dependencies

- Task 446 (Agnostic Duration Construction): COMPLETED - provides Duration type
- Task 448 (Canonical History): OUT OF SCOPE - will use canonical_frame from this task

## Notes

- The modal case of compositionality is complete and uses the new `set_mcs_box_box` lemma
- The temporal case analysis is fully documented in the code comments
- Build time is approximately 1.2 seconds for Completeness.lean
- All pre-existing sorry proofs (from Duration and other sections) remain unchanged
