# Phase 7 continuation — the untl/snce copy defect repaired, ledger 23 → 26

**Task**: 165, `establish_semantic_finite_model_property`
**Plan**: `plans/01_tableau-decidability-two-track.md`, Phase 7 (7.2)
**Date**: 2026-07-29
**Authorization**: `reports/03_untl-snce-copy-defect-verification.md` §4.1

## What was executed

Four objectives, in the priority order the dispatch set.

### 1. Evidence hygiene (required)

The `{1/n}` counterexample recorded in `Verified/Decidable.lean` was **refuted** and has been
replaced by the `ℤ` model from the verification report. The retraction is recorded in-module
with the reason the dense version fails — `SatResult` re-chooses `tv` wholesale, so the fresh
time is free anywhere above the trigger's and a dense carrier always leaves room above the
failure point — so that a third wrong version is not attempted. The `Om = Set.univ`
formalization trap is recorded alongside it.

The module's claim that the PASSIVE arms of `untlNeg`/`snceNeg` "are sound; provable today" is
**retracted**. Five unsound sites, not four; `untlNeg`/`snceNeg` carry two independent
obstructions.

### 2. Probe rows, then the scoped engine fix

`Tests/BimodalTest/UntlSnceCopyProbe.lean` (new, registered in `Tests/BimodalTest.lean`) was
committed first at its **pre-repair** values, then re-pinned after the deletion. It has three
sections: A pins the `untlPos` copy as a step, B pins the PASSIVE-arm defect as a step, C is the
over-closing verdict row, discriminated with `isInvalid`/`getCountermodel?`/`isExtractionFailed`
and never `isValid` alone.

The `untlNegProps` block in `.untlPos` and the `snceNegProps` block in `.sncePos` were deleted.
Nothing else in the engine was touched; the ACTIVE arms of `untlNeg`/`snceNeg` still carry their
copy blocks. `applyRule`'s docstring now carries the time-axis prohibition alongside the existing
group-3 one.

### 3. Rules proved

`ruleSound_densityRule`, `ruleSound_untlPos`, `ruleSound_sncePos`. Ledger **23 → 26 of 34**.

### 4. `untlNeg`/`snceNeg` escalated, not repaired

Characterized in the orchestrator handoff's `blockers` with a precise proposed diff for the next
verification pass. Their engine arms were not edited.

## Acceptance-gate results

| Gate | Result |
|---|---|
| `TableauConformance.lean`, 29 `#guard_msgs` rows | green before **and** after; **zero rows changed**; 59 s |
| `UntlSnceCopyProbe.lean` | green at pre-repair values, green at post-repair values |
| `CrossWorldPropagationProbe.lean` | green, 439 s |
| `lake env lean Verified/Decidable.lean` | zero errors after every edit |
| `lake build …Decidability.Tableau` | green, 689 jobs |
| sorry census over `Verified/` | 0 |

Five probe verdicts changed, all in the right direction: A2 `true`→`false`, A4 `[2,3]`→`[1,2]`,
**C2 `isInvalid` `false`→`true`**, **C3 `getCountermodel?.isSome` `false`→`true`**, C5
`isFuelExhausted` `true`→`false`. The engine now positively refutes the invalid
`U(p,q) → U(r,s)` where it previously exhausted its fuel: the copy had been closing off the very
branches a countermodel is read from. C4 (`isExtractionFailed`) is `false` both before and after,
so the copy's harm on this formula was under-closing rather than a wrong verdict.

## New machinery

`carrierDense` (defined as `DenselyOrdered D`, so `ValidDense`'s own binder discharges it by
`inferInstance`); `mem_knownTimes_of_pathN_directFutureOf` and `mem_knownTimes_of_mem_futureOf`
(the `OrdWithin` direction of the ordering bridge); `ordResp_addFuture_addFuture_update`;
`satAt_of_mem_gPropsExcept`; `asUntil?_eq_some`; `asSince?_eq_some`; `exists_gt_truthAt_of_untl`;
`exists_lt_truthAt_of_snce`.

## Plan deviations

None. 7.3 was not attempted, as instructed.
