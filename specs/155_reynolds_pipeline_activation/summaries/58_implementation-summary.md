# Implementation Summary: Task #155 (v58) -- Axiomatize IsSuccArchimedean

- **Task**: 155 - Close sorry chain to completeness_discrete via IsSuccArchimedean axiom
- **Status**: Implemented
- **Plan Version**: v58 (plans/57_implementation-plan.md)
- **Session**: sess_1748899200_orchestrate
- **Date**: 2026-06-02

## Changes Made

### Phase 1: Import cycle resolution [COMPLETED - prior session]

- Created `NoGapsDiscreteProof.lean` to break the import cycle
- `GoodStructures.lean` now has zero sorries
- (Not modified in this session)

### Phase 2: Axiomatize IsSuccArchimedean [COMPLETED]

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

1. Added `limitDomSubtype_isSuccArchimedean_axiom` -- a named axiom with the same type signature as the existing `limitDomSubtype_isSuccArchimedean` definition. The axiom includes a detailed docstring explaining the mathematical justification (omega-chain construction builds limit_dom as a union of finite stages).

2. Updated `succ_embed_surjective` to use the axiom instead of the sorry-dependent definition:
   - Old: `letI := limitDomSubtype_isSuccArchimedean fc A h_mcs h_fc h_discrete`
   - New: `letI := limitDomSubtype_isSuccArchimedean_axiom fc A h_mcs h_fc h_discrete`

3. Updated section docstrings:
   - Section header: reflects that BX pipeline code is dead and axiom provides the bypass
   - `limitDomSubtype_isSuccArchimedean` docstring: marked SUPERSEDED
   - "Collapse-Based Discrete Pipeline" section: updated to reference axiom

### Phase 3: Verification [COMPLETED]

All five key theorems verified via `#print axioms` (lake env lean):
- `completeness_discrete`: shows `limitDomSubtype_isSuccArchimedean_axiom`, NO `sorryAx`
- `countermodel_discrete_reynolds`: same result
- `cantor_bfmcs_discrete_restricted_tc`: same result
- `cantor_bfmcs_discrete_restricted_fuc`: same result
- `succ_embed_surjective`: same result

Full `lake build` passes (1682 jobs, zero errors).

### Phase 4: Documentation cleanup [COMPLETED]

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

Updated the axiom audit section to reflect:
- `completeness_discrete` has NO `sorryAx` (only `limitDomSubtype_isSuccArchimedean_axiom`)
- `completeness` (general) still has `sorryAx` via the BX pipeline (separate path)
- Classification of all axioms

## Plan Deviations

- Phase 3 used `#print axioms` via `lake env lean` instead of `lean_verify` MCP tool (MCP tools not available in this session). Same verification result.
- Phase 4 Tasks 4.1/4.2 (update docstrings) were completed during Phase 2 as part of the same edit session, rather than deferred to Phase 4.

## Artifacts

| Type | Path |
|------|------|
| Plan | `specs/155_reynolds_pipeline_activation/plans/57_implementation-plan.md` |
| Summary | `specs/155_reynolds_pipeline_activation/summaries/58_implementation-summary.md` |

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (axiom + docstring updates)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (audit section update)

## Definition of Done (Verified)

- `#print axioms completeness_discrete` shows `limitDomSubtype_isSuccArchimedean_axiom` but no `sorryAx`
- `lake build` passes with zero errors
- No new sorry statements introduced
- Axiom documented with mathematical justification
