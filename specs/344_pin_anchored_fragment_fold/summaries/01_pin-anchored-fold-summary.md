# Task 344 — Pin-Anchored Fragment Fold: Dispatch-1 Summary

- **Status**: Phase 1 [PARTIAL] (foundation landed green; heavy construction deferred to dispatch 2)
- **Session**: sess_1783723095_edd5a7_344
- **Commit**: `9ea246946`

## What landed (green, additive, axiom-clean)

`SharedWitness.lean`, below the new TASK 344 banner (appended before the final `end`):
- The additive banner.
- `def kvE2_sepFragment_frag {sig} (qnf : NormalForm sig 2 3) : Prop` — the single-positive
  fragment predicate, byte-identical / defeq to `OuterGate.kvE2_sepFragment` (`OuterGate.lean:191`),
  restated locally to avoid the `OuterGate → SharedWitness` import cycle.

Build: `lake build …SharedWitness` green (1013 jobs). Additive-only — `git diff` touches only
appended lines below the banner; no other `.lean` file changed. Sorry inventory: 0.

## Probe verdicts (all GO, machine-verified)

| Probe | Verdict | Evidence |
|-------|---------|----------|
| 1 — pin/segment output shape | GO (caveat) | Bundle `kvE2_sepBundleL` (SW:5327) gives pin `x1` with `x<x1<w` + `PtX1L` + zXU below-clause → dissolves O4 first obstruction. BUT `kvE2_sepDisjunct'_extract` (SW:8273) discards the bracket segment forms → additive joint extractor required. |
| 2 — arrangement-shape reduction | GO | Segments present in raw bracket holds; under `hfrag` the tie-grouped lists = σ0's own slots (O4 cross-σ residue vanishes). |
| 3 — hexcl threading | GO | `hexcl` is the final hyp of `kvE2_outer_fold` (SW:9952-9956), threaded verbatim. |

## Confirmed architecture (no signature drift vs report §2)

`kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1290`) consumes the ∀-anchor `hgate` at
exactly ONE point (`:1323`, the bundle pin `x1`) → the pin-anchored variant inlines the six
conjuncts at `x1` with the identical continuation. The four target signatures
(`kvE2_sepGateAtPin_fragL/R`, `kvE2_sepBody_kit_sound_frag`, `kvE2_outer_fold_frag`) stand as the
report sketches; `hcorrK`/`hexcl` remain explicit undischarged hypotheses (335's obligation).

## Remaining work

The joint extractor + `kvE2_sepGateAtPin_fragL` + mirror + kit + fold (~600-1100 lines) — the
genuine multi-dispatch effort the plan sizes at 3 dispatches / 5-7 hours. Fully specified,
line-precise, in `handoffs/01_continuation.md`.

## Plan Deviations

- Phase 1 banner + local predicate landed (completed). PROBEs 1–3 completed (all GO). The additive
  segment/pin extractor and `kvE2_sepGateAtPin_fragL` are **deferred** to the next dispatch
  (scope-boundary: the heavy construction exceeds a single dispatch; no wall hit). Annotated inline
  on the Phase 1 checklist.
