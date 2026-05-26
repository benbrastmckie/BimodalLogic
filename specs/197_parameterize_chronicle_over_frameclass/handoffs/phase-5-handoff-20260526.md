# Phase 5 Handoff: ChronicleToCountermodel.lean Partial

## Status
- Phase 1-4: COMPLETED (all compile cleanly)
- Phase 5: PARTIAL (z1 sorry fixed, but 69 compilation errors remain)

## What Was Done

### FMCS/BFMCS Parameterization (COMPLETE)
- `FMCSDef.lean`: Added `fc : FrameClass := FrameClass.Base` default parameter to `FMCS`
- `BFMCS.lean`: Same for `BFMCS` + `eval_family` field + open ProofSystem
- All other files compile cleanly (backward-compatible default parameter)

### Z1 Sorry Fix (Sorry #6 — DONE)
- `z1_derivation` at line ~1524: Now takes `(fc : FrameClass) (h_fc : FrameClass.Discrete <= fc)` and uses `h_fc` instead of `sorry`
- `z1_in_mcs`: Updated to pass `h_fc` through

### ChronicleToCountermodel.lean Bulk Changes (PARTIAL)
- All 124 `FrameClass.Base` refs replaced with `fc`
- All function signatures have `(fc : FrameClass)` parameter
- Most internal calls have `fc` added
- FMCS/BFMCS annotations use `(fc := fc)`
- 69 errors remain

## Remaining Error Patterns

### 1. External Bundle functions hardcoded to FrameClass.Base
Several functions in `Bundle/ModalSaturation.lean` and `BXCanonical/Frame.lean` are hardcoded to `FrameClass.Base`:
- `SetMaximalConsistent.contrapositive` (line 562)
- `box_dne_theorem` (line 563)
- `neg_box_to_box_neg_box` (fixed with liftBase)
- `box_to_past` (partially fixed with liftBase)
- `bx_modal_witness` (line 565)

**Fix**: These need either:
(a) Parameterize `ModalSaturation.lean` and `Frame.lean` over fc (larger scope), or
(b) Use `liftBase fc` wrapping and add type coercions at the boundary

### 2. cantor_bfmcs_dense_restricted_tc/buc/fuc (lines ~598-780)
These functions are defined in this file and call `cantor_bfmcs_dense`. Their internal logic references BFMCS families and may need cascading fixes.

### 3. countermodel_dense and dd_countermodel_chronicle_dense (lines ~793-830)
The main countermodel construction uses the BFMCS restricted coherence theorems.

### 4. Discrete pipeline (lines ~2500-3370)
The discrete countermodel construction has many function calls that need fc and also needs `h_fc : FrameClass.Discrete <= fc` threaded through for z1 usage.

## Key Architectural Insight

The `ChronicleToCountermodel.lean` file bridges two layers:
1. **Chronicle layer** (parameterized over fc) — Functions like `limit_dom`, `limit_f`, `omega_chain`
2. **Bundle layer** (hardcoded at FrameClass.Base) — Functions like `bx_modal_witness`, `box_dne_theorem`, `SetMaximalConsistent.contrapositive`

The 69 remaining errors are primarily at this boundary. The clean fix requires parameterizing `Bundle/ModalSaturation.lean` and `BXCanonical/Frame.lean` over fc, which was explicitly listed as a NON-GOAL in the plan.

## Recommendation

Two approaches:
1. **Targeted liftBase wrapping**: For each Base-level function call, wrap with `liftBase fc`. Add explicit `(fc := FrameClass.Base)` at Bundle boundary call sites. This keeps the scope contained but is tedious.
2. **Broader parameterization**: Parameterize `ModalSaturation.lean`, `Frame.lean`, and related Bundle files. This is cleaner but expands scope significantly.

## Files Modified
1. `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` — FMCS fc default param
2. `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` — BFMCS fc default param
3. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — 69 errors remaining

## Build Status
- `lake build` passes for all files EXCEPT ChronicleToCountermodel.lean
- The downstream files (Completeness.lean, Transfer.lean, etc.) will have errors once ChronicleToCountermodel compiles (Phase 6-8)
