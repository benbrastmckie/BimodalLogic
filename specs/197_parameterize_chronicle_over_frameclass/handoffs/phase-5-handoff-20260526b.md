# Phase 5 Handoff: ChronicleToCountermodel.lean (47 errors remain)

## Status
- Phase 5: PARTIAL
- Upstream parameterization: COMPLETE (all compile clean)
- ChronicleToCountermodel.lean: 47 errors remaining (down from original 69 -> 88 after upstream -> 47 after boundary fixes)

## What Was Done This Session

### Upstream Layer Parameterization (ALL COMPLETE)
All files below compile clean and have `{fc : FrameClass}` properly threaded:
1. `ModalSaturation.lean` — `SetMaximalConsistent.contrapositive` parameterized
2. `CanonicalFrame.lean` — `existsTask_transitive`, `h_content_chain_transitive` parameterized
3. `TemporalCoherence.lean` — All BFMCS/FMCS/TemporalCoherentFamily defs parameterized; duality lemmas lift Base derivations via `.lift (by cases fc <;> trivial)`
4. `ParametricCanonical.lean` — `ParametricCanonicalWorldState (fc)`, `ParametricCanonicalTaskFrame`, all related parameterized
5. `ParametricHistory.lean` — All parameterized with explicit `(fc := fc)` on TaskFrame
6. `ParametricTruthLemma.lean` — `ParametricCanonicalTaskModel`, `parametric_box_persistent`, private helpers parameterized
7. `RestrictedParametricTruthLemma.lean` — All BFMCS/FMCS/completeness functions parameterized
8. `ChronicleTypes.lean` — Added `mcs_to_base` theorem + `bx_modal_witness_fc` (fc-parameterized modal witness)

### ChronicleToCountermodel.lean Fixes (PARTIAL)
- Dense `modal_backward`: Replaced `bx_modal_witness` with `bx_modal_witness_fc`
- Discrete `modal_backward`: Same replacement
- Both: Lifted `box_dne_theorem` via `liftBase fc`
- TemporalDerived lifts: `temp_k_dist_derived`, `contrapositive` lifted via `liftBase fc`
- `collapseClass_linearOrder`: Added missing `(fc : FrameClass)` parameter

## Remaining 47 Errors

### Lines 848, 863 (2 errors): discrete helper type mismatches
`limit_dom_has_succ`/`limit_dom_has_pred` and `limit_satisfies_c5_strong`/`c5'_strong` likely have fc threading issues in the discrete case helper functions `next_top_gives_since`.
**Fix**: Check if these functions pass `fc` correctly. May need explicit `fc` annotation.

### Line 2242 (1 error): Type mismatch in collapse equivalence
Likely `collapse_equiv_refl` with wrong fc.
**Fix**: Check function signatures, add `fc` if missing.

### Lines 2492-2499 (5 errors): discrete_zero definition issues
`discrete_zero` definition references `limit_dom` and `limit_f` without proper `fc` arg in underscore params.
**Fix**: Check `discrete_zero` definition — the underscored params `_A`, `_h_mcs` lost their fc refs.

### Lines 3006-3015 (3 errors): discrete modal_forward type mismatch
`rooted_succ_discrete_fmcs` called without `fc` in `cantor_bfmcs_discrete` `modal_forward`.
**Fix**: Add `fc` arg to `rooted_succ_discrete_fmcs` calls at lines 3014-3015.

### Lines 3075-3200+ (30+ errors): discrete restricted coherence
`cantor_bfmcs_discrete_restricted_buc`, `cantor_bfmcs_discrete_restricted_tc`, `cantor_bfmcs_discrete_restricted_fuc` — these mirror the dense restricted coherence proofs and have similar fc threading issues.
**Fix**: Add `fc` to `succ_embed`, `discrete_embed`, `limit_f`, `limit_c0` calls. Mirror the same patterns used in the dense versions which already compile.

### Lines 3295-3346 (6 errors): discrete countermodel assembly
`countermodel_discrete` and `dd_countermodel_chronicle_discrete` — boundary with Algebraic layer.
**Fix**: Add explicit `(fc := fc)` to `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`, `ShiftClosedParametricCanonicalOmega` calls.

## Error Fix Patterns (Established)

| Pattern | Fix |
|---------|-----|
| Base derivation in fc context | `liftBase fc (base_level_function ...)` |
| `bx_modal_witness` with fc-MCS | Use `bx_modal_witness_fc h_mcs` instead |
| Function missing `fc` param | Add `(fc : FrameClass)` to signature |
| `BFMCS D` default → Base | Pass `(fc := fc)` explicitly |
| `ParametricCanonicalTaskFrame D` | Use `ParametricCanonicalTaskFrame (fc := fc) D` |
| `TemporalDerived.X` at Base | `liftBase fc (TemporalDerived.X ...)` |
| `restricted_X_coherent` | Now auto-binds fc from BFMCS type |
| Function call missing fc | Add `fc` as first argument |

## Immediate Next Action
Fix the remaining 47 errors by working through the discrete pipeline systematically (lines 2492-3346). Most errors are mechanical fc-threading following established patterns. The dense pipeline is clean except for two discrete helpers at lines 848/863.

## Files Modified (All in Commit History)
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

## Session
sess_1779791105_71af24
