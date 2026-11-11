# Implementation Summary: Task #918

- **Task**: 918 - Produce a positive factorization lemma for the index of which cell a ladder state has
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-11T08:15:00Z
- **Completed**: 2026-11-11T10:05:00Z
- **Effort**: ~1.8 hours
- **Dependencies**: None blocking. Reads task 917's closed record as its starting position.
- **Artifacts**: plans/01_ladder-cell-window-regime.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

**Verdict, in one sentence**: the ordinary window regime `c ≤ n + 1` is REACHABLE — its decision
gate passed by compiled measurement, not by argument, and the raising surgery's admissibility half
is landed with the next-deadline register held — and the re-scope to that regime was the prior
cycle's own recorded Target A decision rather than a drift from the dispatch, whose second
admissible outcome is foreclosed by the compiled `paramsOk_params` and whose first reduces to the
obligation task 917 refuted its only landed route against.

Three of the plan's seven phases were executed: Phase 1 and Phase 2 closed `[COMPLETED]`, and
Phase 3 closed `[PARTIAL]` with its remaining obligation stated precisely and its iterable
reformulation designed and recorded. Phases 4-7 are untouched. Every declaration landed is
`sorry`-free, warning-free, and carries the standard axiom profile; the full-library `lake build`
is green at every phase boundary.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` — NEW leaf module, 682 lines.
  Holds, in order:
  - the window regime's **arithmetic layer**, four theorems lifted verbatim from the plan-time
    compiled measurement: `kappa_collision_window_room` (a class collision at a fixed register in
    this regime either pins the two countdowns equal or exhibits a positive multiple of `P + 1`
    together with the strict room `c' ≤ n` for the larger one — the gap coordinate paying for it
    through `clipIdx_regime_of_eq` with the gap branch killed, not an added assumption),
    `window_anchor_compat_of_room`, `window_pin_compat_raise_of_gap` and
    `window_pin_compat_lower_of_spacing`, the last three with the displacement left OPAQUE so none
    of them reads the modulus, `(K1)`, or any parameter tuple;
  - the **decision gate's second layer**: the named idle-run condition `HasIdleRunBelow` (a `def`,
    a bounded conjunction of `pend` read-outs), `regionStart_spacing`,
    `window_pin_dist_grows_below`, `window_pin_dist_grows_above`,
    `window_anchor_compat_at_region_start`, `nxtAt_le_cntAt_region_start`,
    `window_anchor_clause_of_pin_classification` (the gate's PASS as a compiled statement),
    `no_pin_in_idle_run` and `window_pin_pair_raise_of_slack`;
  - the regime's **two structural inputs**: `region_run_of_region_start` and
    `exists_idleBlock_of_hasIdleRunBelow`;
  - the composite raise's **admissibility half**: `window_composite_pin_trichotomy` (the gate's
    `hclass` hypothesis discharged), `window_composite_pins` (the pin pair clause, nine pin-class
    pairs) and `exists_window_composite_ladderPath` (the composite walk lifted twice — anchor-free
    to put the trichotomy on a genuine ladder path, then through the `z`-anchored lift at the
    PRESCRIBED register value `nxtAt g z`).
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — the aggregator import plus the matching
  `## Modules` docstring bullet.
- `FormalSystem.lean` — regenerated library root (`lake exe mk_all --lib FormalSystem`), +1 line.
- `typst/generated/status.typ` — regenerated count fields, staged with each Lean-touching commit.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — regenerated module-inventory blocks,
  with the new module's hand-written description cell supplied.

## Decisions

- **The gate was measured by writing the hypothesis and letting the elaborator reject it.** The
  compensator-length hypothesis `jP ≤ E` was written into the anchor-clause lemma and reported
  UNREFERENCED: the idle insertion displaces the region start and the anchor by the same amount, so
  their distance is unchanged and the anchor clause never reads the compensator. The compensator is
  spent entirely in the pin PAIR clause, against pins strictly below the lengthened run. An
  argument would have carried the wrong attribution forward; the compiled attempt corrected it.
- **The composite walk is lifted twice, not once.** `exists_ladderPath_of_walk_of_pins` supplies a
  ladder path from the pin pair clause alone, but the register it chooses is whatever the drift
  extension returns, and a cell inclusion reads `nxtAt` at the comparison position. The anchor-free
  lift is used to make the pin trichotomy available on a genuine ladder path; the `z`-anchored lift
  then installs the prescribed register.
- **The pinned `window_anchor_compat_of_room` was landed exactly as pinned, and a companion added
  rather than the pin edited.** The path's own arithmetic gives `n ≤ c + 2d + 1`, one step slacker
  than the pinned statement's `hlow`, so the construction consumes a new
  `window_anchor_compat_at_region_start` at displacement `d + 1`. Editing the pin to match the
  implementation is the move `rules/plan-compliance.md`'s Statement Fidelity section exists to
  catch; it was not made.
- **A landed sibling route was found and deliberately not taken.** `LadderAgree.lean`'s
  `exists_ladderPath_at_region_of_idle_past` already lands a STATE-LEVEL raise in this very regime,
  compensating by INSERTING idle positions at the region start (`insObj`/`insCnt`,
  `insPins_of_region_start`) rather than by duplicating an existing idle block. It does not subsume
  the plan's Phase 3 primitive: it holds neither the register (it eliminates the anchor obligation
  instead, so it cannot serve a cell inclusion) nor the realized type, it raises by one cycle
  length rather than a multiple of `P + 1`, and it carries `hself`, a path-local self-loop at the
  idle object states, which the idle-block route does not need. The plan's route was followed as
  written. The sibling matters twice: it corroborates the gate's PASS from an independent
  construction, and its own docstring records that the UNCOMPENSATED splice is REFUTED in this
  regime — which is why `l ≤ E` is a payment rather than a convenience.
- **The reserved name stays unclaimed.** No declaration landed carries
  `cellLE_zero_const_of_kappa_eq` or any prefix of it, and an exact-name sweep confirms it still
  has no declaration site under `FormalSystem/`.

## Plan Deviations

- **Phase 1**, aggregator import, altered: the aggregator's `## Modules` docstring list gained a
  matching `RaySummary.LadderWindow` bullet alongside the bare import line; an import with no entry
  there would have been that file's only such gap.
- **Phase 7**, module-inventory regeneration, altered: executed EARLY, at the close of Phase 3,
  because this dispatch ends at Phase 3 `[PARTIAL]` and the new module had turned the `INV` check
  group RED. The regeneration rewrote four tracked files, two of them absent from Phase 7's file
  list (`FormalSystem/README.md` and `RaySummary/README.md`, the latter declared READ-ONLY by the
  plan's risk table) — exactly the case that phase's own Scope Hypothesis instructs be resolved by
  adding what the regeneration actually touches.
- **Phase 3** is `[PARTIAL]`, not a deviation but an incomplete execution: the raising primitive's
  admissibility half landed; the iteration to an exact multiple of `P + 1`, the model-level
  type-carrying half, and the lowering primitive did not. Nothing was substituted for them and no
  `sorry` or weakened hypothesis stands in their place.
- **Phases 4, 5, 6, 7** are `[NOT STARTED]`, blocked on Phase 3 by the plan's own fully sequential
  dependency analysis.

## Verification

- Build: **Success**. Full guarded `lake build` green at every phase boundary and at close — 2974
  jobs, `error:` count 0, `warning:` count 0 — with `.olean`-newer-than-source confirmed for
  `LadderWindow`, `RaySummary` and `FormalSystem`. `lake build BimodalTest` green (via
  `check-module-invariants.sh` C1).
- Sorry count: **0** (`lean-sorry-census.sh` across the resolved source roots; independently,
  `check-module-invariants.sh` C3 reports a ZERO structural sorry inventory).
- Vacuous count: **0**.
- Axiom count: **0 new axioms**. `lean_verify` per name: `kappa_collision_window_room` carries
  `propext`, `Classical.choice`, `Quot.sound`; the three pinned pin statements carry `propext`,
  `Quot.sound`. No `sorryAx` anywhere. `check-module-invariants.sh` C2 reports all fifty pinned
  axiom sets matching baseline and C14 every other pinned declaration matching its own.
- Tests: Passed (`lake build BimodalTest`). No new `#guard_msgs` axiom pins were added — that is
  Phase 7's task and Phase 7 did not run.
- Files verified: Yes.
- `lake exe mk_all --lib FormalSystem --check`: exit 0. The regeneration rewrote exactly one
  tracked file, `FormalSystem.lean`, confirming Phase 1's aggregator-set Scope Hypothesis.
- `scripts/check-copyright-headers.sh`: exit 0, total 754 → 755 (exactly +1).
- `scripts/check-metalogic-cycles.sh`: exit 0, run rather than assumed; Assertion B reports the
  upward import set as exactly the recorded 10 lines, so NO surplus edge was introduced and the
  frozen allowlist was not touched.
- `scripts/typst-sync-check.sh --counts-only`: `MISMATCH_COUNT=0`.
- `scripts/check-module-invariants.sh --emit-inventory --check`: exit 0 after the regeneration.
- `.claude/scripts/validate-artifact.sh ... plan`: `[PASS]`, 0 warnings.
- **Pre-existing findings outside this task's file scope, enumerated rather than absorbed**:
  `check-module-invariants.sh`'s C16 group fails with exactly two `unusedArguments` findings, both
  on `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean`
  (`exists_idleSpliced_ladderPath`, `exists_idleTypeBlock_of_budget_le_run`) — the concurrent
  sibling's standing failure this plan's risk table predicted by name. No C16 finding names
  `LadderWindow.lean`, and that out-of-scope file was not edited.
- **Scoped verification tier, per this dispatch's batch-gate deferral**: the plan's final phase
  declares `**Verification Tier**: full` and that field is unchanged. Phase 7 did not run, so its
  full gate set was not discharged; the gates listed above are the ones the files actually touched
  require, and the complete set is deferred to the batch stage rather than independently run here.

## Impacts

- A new leaf module exists at the bottom of the RaySummary ladder layer, importing `LadderCell` and
  `LadderIdle` and imported by the two aggregators alone. Nothing else imports it, so nothing
  downstream can observe a change in it.
- The window regime's arithmetic skeleton and the gate's clause-level measurement are now available
  as proof terms rather than as prose in a report: a successor dispatch consumes
  `window_composite_pin_trichotomy`, `window_composite_pins` and
  `window_anchor_clause_of_pin_classification` instead of re-deriving the pin classification.
- The regime dichotomy is now visibly two-sided in the library: the five `LadderCell.lean` schemas
  carry `n + 2 ≤ c` and this module carries its exact complement, with
  `cntAt_le_nxtAt_succ_of_idle_past` and `pend_past_of_nxtAt_lt` as the two directions of the split.
- No `ParamsOk` condition was amended, no `ForwardSlackWitnessed` obligation was touched or
  weakened, and no refuted route was re-entered.

## Follow-ups

- **The iteration to an exact multiple of `P + 1`** — the one blocking item. The landed iterate
  `exists_iterSpliced_ladderPath_idx_of_pend_past` carries the pending-forever hypothesis in two
  places (its per-step `exists_spliced_ladderPath_of_pend_past`, and the `hpend_all` step of its own
  anchor-clause proof), so a window-regime analogue is owed. The plan's Phase 3 verification notes
  carry the full iterable reformulation worked out during this dispatch: state every clause about
  the idle-lengthened path alone rather than relative to the original, with the classes
  `w + 1 < a₁` / `w = a₁` / `u ≤ w`; carry a decreasing budget `R` with `l ≤ R`, used only at the
  (class 1, class 2) pin pair; and carry the anchor clause itself as an invariant together with the
  companion `cntAt g₁ (a₁ + 1) + R ≤ nxtAt g z + (z - a)`, which the step reproduces exactly
  because the countdown rises by `l` as `R` falls by `l`. That companion invariant is where the
  collision's room is spent, once, in the base case.
- **The model-level half**: the realized type carried through both splices
  (`tpOf_eq_spliceIdx_of_tpOf_eq` for the pending stage, and the shift form of
  `tpOf_stabFree_eq_of_objAt_eq` for the idle stage, whose own type clause is exposed only strictly
  below its block).
- **The lowering primitive**: untouched. Its pin pair clause is
  `window_pin_compat_lower_of_spacing` against `regionStart_spacing`, both already landed here.
- **Phases 4-7** then follow as planned; Phase 6 is the PASS branch's
  `[COMPLETED WITH EXCLUSIONS]` and lands nothing.
- A `#print axioms` pin block for every declaration landed here is owed in
  `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (Phase 7), as is the Requirement (W)
  narrative update to the actual outcome.

## References

- `specs/918_ladder_cell_index_positive_factorization/plans/01_ladder-cell-window-regime.md` — the
  plan, with per-phase verification notes recording each phase's measurements, the gate's PASS, and
  Phase 3's remaining obligation.
- `specs/918_ladder_cell_index_positive_factorization/reports/01_ladder-cell-index-positive-factorization.md`
  — the research round this plan integrates.
- `specs/918_ladder_cell_index_positive_factorization/evidence/plan-gate-arithmetic.lean` — the
  plan-time compiled measurement whose four bodies Phase 1 lifted verbatim.
- `specs/918_ladder_cell_index_positive_factorization/.decisions.json` — the prior cycle's recorded
  Target A re-scope decision.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` — the new module.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` —
  `exists_ladderPath_at_region_of_idle_past` and `insPins_of_region_start`, the landed sibling route
  recorded above; also `exists_ladderPath_of_walk_of_pins`, `pinCompat_of_ladderPath`,
  `nxtAt_lipschitz_two_sided` and the splice vocabulary this module consumes.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` —
  `exists_ladderPath_of_walk_nxt_at`, the `z`-anchored lift whose six clauses the gate enumerates.
