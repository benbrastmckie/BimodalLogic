# Phase 11 Summary — Completeness-side Omega is `H_F`

**Plan**: `plans/03_omega-free-totality-refactor.md`, Phase 11
**Status**: `[COMPLETED]` — 11 of 23 phases complete
- **Task**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
**Build**: full `lake build` green (2331 jobs); touched files sorry-free

## What landed

Six declarations across two files, closing out the classification of every Omega-valued
definition in the live tree.

`FormalSystem/Metalogic/Algebraic/FlowFrame.lean`:
- `multiFamOmegaGen_eq_total` — the set equation `multiFamOmegaGen D FamIdx = {σ | ∀ t, σ.domain t}`
- `bundleFlowOmega_eq_total` — the bundle-index corollary, a one-line specialization

`FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`:
- `zHistoryV2_total_eq`, `zOmegaV2_eq_total`
- `multiFam_total_eq`, `multiFamOmega_eq_total`

All four set equations are choice-free: `#print axioms` reports `[propext, Quot.sound]` for each.

## Verdict table (all 5 definitions)

| Definition | Verdict | Witness |
|---|---|---|
| `multiFamOmegaGen` | `= H_F` | `multiFamOmegaGen_eq_total` |
| `bundleFlowOmega` | `= H_F` | `bundleFlowOmega_eq_total` |
| `ZOmegaV2` | `= H_F` | `zOmegaV2_eq_total` (was UNVERIFIED) |
| `multiFamOmega` | `= H_F` | `multiFamOmega_eq_total` (was UNVERIFIED) |
| `regionOmega` | `⊊ H_F` | permissive `regionFrame.TaskRel`; motivates the carrier re-host |

Both previously-unverified classifications came out **equal to `H_F`**. The plan's contingency —
"if either comes out strict-subset, a second carrier re-host is needed and the plan must be
revised before the box-clause retarget" — was **not triggered**. No plan revision is required.

## Scope-hypothesis confirmation

The population grep was re-run against the live tree and returns exactly 5 definitions, matching
the round-3 report. The one near-miss, `CompletenessDedekind.lean:84`, returns
`Set (WorldHistory (bundleFlowFrame B))` but is an `example` whose body is `bundleFlowOmega B` —
already covered, not a sixth definition. Every other grep hit is a binder or type ascription.

## Deviation from the research finding

The dispatch framed this phase as "a rewrite, not a re-proof". That held exactly for the two
`FlowFrame.lean` definitions: `multiFamOmegaGen_eq_total` compiled green on the first build
attempt with no proof-search iteration, resting on `multiFamGen_total_eq` and
`multiFamHistoryGen_mem_omega` already in the tree.

It did **not** extend verbatim to the two `ReynoldsBridge.lean` definitions.
`multiFamTaskFrame` (over `ℤ`) and `zTaskFrameV2` are independent `def`s, not specializations of
`multiFamTaskFrameGen`, so no totality characterization existed for either. `zHistoryV2_total_eq`
and `multiFam_total_eq` are genuine new proofs — short ones, transcribing
`multiFamGen_total_eq`'s argument (both task relations are deterministic, so the state at time 0
plus `respects_task` fixes the whole history), and introducing no new mathematical content, but
new proofs nonetheless rather than rewrites.

## Elaboration note for later phases

`zTaskFrameV2.WorldState` is definitionally `ℤ` but not syntactically so. Arithmetic over it
fails `HAdd` instance synthesis, and a `(x : ℤ)` type ascription does **not** force the issue —
the term still elaborates at `WorldState`. `show ℤ from x` does force it, and is what the landed
proof uses. Any later phase doing arithmetic on a `TaskFrame.WorldState` projection will hit the
same wall.

## Scope discipline

The decidability side was read for the population confirmation only and not modified;
`regionOmega` and `regionFrame` remain the carrier-re-host phases' work. No file under
`FormalSystem/Semantics/` was touched, so the extension chain and `step`'s status as
*Spherical*'s sole application site are preserved untouched.

## Downstream

The box-clause retarget can proceed on all four completeness-side carriers by rewriting along
the `*_eq_total` equations. `regionOmega` remains the sole strict-subset case.
