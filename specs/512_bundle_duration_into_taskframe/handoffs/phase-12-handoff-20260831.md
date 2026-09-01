# Phase 12 handoff — `FlowFrame.lean` and the canonical task relation

**Status**: [COMPLETED]. `lake build` 0, `lake build BimodalTest` 0,
`check-module-invariants.sh` ALL CHECKS PASSED, zero structural sorry, C2 profiles unchanged.

## Immediate next action
Phase 13 — BXCanonical, Chronicle, and the countermodel bases.

## Carry-forward facts for Phase 13 / 16
- `multiFamTaskFrameGen` now takes `(D : TemporalOrder)`. Four call sites currently spell their
  order as `TemporalOrder.of ℝ` / `TemporalOrder.of (ℚ ×ₗ ℤ)`:
  `CompletenessDedekind.lean` (3 + one `(D := …)` in a `have`), `CountermodelBase.lean` (4 + one
  `(D := …)` at `:235`). When Phase 13/16 declare `realOrder` / `ratOrder`, swap those spellings.
- `bundleFlowFrame (B : BFMCS (fc := fc) D) : FrameOver (TemporalOrder.of D)` keeps an ambient
  carrier by decision (see the Phase 12 Record in the plan). Do NOT try to convert it to
  `{D : TemporalOrder}` — the `?D` is uninferable at every call site.
- New: `Semantics.instCoeOutFrameOver : CoeOut (FrameOver D) TaskFrame` for `{D : TemporalOrder}`.
  This is the permanent replacement for `instCoeOutParamTaskFrame`; Phase 20 deletes the latter.
- Every `[Nontrivial D]` binder in `FlowFrame`'s generic section is gone (it is a `TemporalOrder`
  field now). Expect the same simplification in Phases 13/16/17.
- Editing `Semantics/TaskFrame.lean` triggers a full-tree rebuild (~7 min). Batch such edits.

## Deviations
- Scope hypothesis 37 occurrences → measured 16.
- Edit blast radius 2 files → 6 (generic-layer binder change propagates to call sites).
- `bundleFlowFrame` kept an ambient carrier rather than a `TemporalOrder` binder.
- One addition to `Semantics/TaskFrame.lean` (`instCoeOutFrameOver`) outside Phase 12's file list.
