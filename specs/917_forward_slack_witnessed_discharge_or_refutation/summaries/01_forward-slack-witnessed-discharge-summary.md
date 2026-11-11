# Implementation Summary: Task #917

- **Task**: 917 - Discharge `ForwardSlackWitnessed` under `ParamsOk`, or compile a refutation
- **Status**: [BLOCKED]
- **Started**: 2026-11-10T21:00:00Z
- **Completed**: 2026-11-10T21:35:00Z
- **Effort**: ~35 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_forward-slack-witnessed-discharge.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-3 of the plan are landed, built and committed: the forward-slack regime is now provably
EQUIVALENT to a bound on one countdown, the three scoping records are in the tree, and the
cell-level witnessing condition is restated as a condition on region lengths. Phase 4 is
**[BLOCKED]**: its pinned Challenge signature for
`exists_deleted_ladderPath_of_next_region_nxt` is not provable, and the gap was measured by
compiling the full proof twice rather than argued.

## Verdict

**NEITHER admissible outcome was reached, and the reason is a defect in the plan's own pinned
statement, not in the route.** `ForwardSlackWitnessed` is neither discharged nor refuted. The
discharge route (Route D) is NOT refuted either — it is stalled one hypothesis short of its
Phase 4 primitive, and that hypothesis is free at the Phase 6 consumer. The verdict is stated
here explicitly rather than left tacit, as the task description requires.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` —
  `next_region_cnt_le_of_hasForwardSlack` (the converse of the landed entry lemma, the research
  report's Probe 2); `hasForwardSlack_iff_next_region_cnt_le` (the regime as a bound on one
  countdown); `hasForwardSlack_amount_le` (the amount ceiling, Probe 4, with its scoping
  docstring). `set_option linter.style.longFile` raised 2700 -> 2800 (file at 2703 lines).
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` — `pend_succ_of_fwd`
  (Probe 3: seriality forces a pending successor); `objCycleLens_nonempty_of_pend` (its
  pigeonhole corollary, landed in full — the plan's documented escape was not needed);
  `paramsOk_inflate` (Probe 1: `ParamsOk` survives inflating the modulus). File at 1115 lines,
  still below 1500, no baseline added.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` —
  `forwardSlackWitnessed_iff_next_region_cnt_le`, the cell-level restatement, with Finding 5's
  three surviving restrictions written into its docstring. File at 1991 lines, baseline 2000
  unchanged.
- `typst/generated/status.typ` — regenerated count fields, staged with each Lean change.
- `specs/917_.../evidence/phase-4-pinned-signature-deficit.lean` and
  `...-FAILS.lean` — the two compiled Phase 4 variants that constitute the blocker's evidence.

## Decisions

- The optional `def NextRegionBounded` naming convenience (Phase 1) was skipped: the plan
  declares it a presentation choice, not a deliverable, and stating the `iff` against the
  explicit right-hand side keeps it propositionally identical to the pinned Challenge statement.
- Phase 4 was escalated rather than repaired in place. Adding the missing hypothesis under the
  pinned name, or editing the recorded Challenge to match what compiles, are exactly the two
  moves `.claude/rules/plan-compliance.md`'s Statement Fidelity section forbids; the sanctioned
  route is `[BLOCKED]` plus a raised blocker, which is what was taken.

## The Phase 4 Blocker

`exists_deleted_ladderPath_of_next_region_nxt`'s pinned hypothesis set is incomplete by exactly
one inequality: `(nxtAt g z : ℤ) ≤ (cntAt g z : ℤ)`.

The plan's Decision 3 reasoning — "taking the deletion ABOVE `z`'s region leaves every pin
between `z` and the block UNDISPLACED, so that pin's anchor clause is free from
`nxtAt_lipschitz_two_sided`" — holds for pin POSITIONS but not for pin VALUES. The pin that
starts the region CONTAINING the block sits below `a`, so its position is indeed undisplaced, but
`delCnt`'s own definition lowers its VALUE by exactly `l`, because that region swallows the
deleted block (`delCnt_of_lt`'s `if a ≤ v + cntAt g v` branch; the same holds at `v + 1 = a`
through `delSeg`). The anchor clause's lower direction therefore carries a deficit of exactly
`l`. Reducing that deficit through `cntAt_ge_of_reaches`, `hcl : l ≤ cntAt g a` and `hza` leaves
precisely `nxtAt g z ≤ cntAt g z`.

That inequality does not follow from `hpast`. `Drift n n' := n' = n ∨ n' = n + 1 ∨ n' + 1 = n`
admits free ±1 drift, and a path pending at every `p ≤ z` carries
`cntAt g (z - k) = cntAt g z + k` with its register wholly unconstrained, so a pending-forever
past bounds `nxtAt g z` against `cntAt g z` in neither direction.

Both halves are compiled, not argued. The pinned signature plus `hnz` compiles clean through
`lake env lean` with no `sorry` — including both pull lemmas, all four pin-compatibility cases
(both-below with its four reach sub-cases, both-above, and the two straddling directions through
`hstraddle`), and the anchor clause at every pin. The same proof with `hnz` deleted fails at
exactly ONE goal, the `omega` closing the anchor at a low pin whose region reaches the block,
with omega's printed counterexample constraint set leaving `↑(nxtAt g z)` and `↑(cntAt g z)`
unrelated.

The repair costs the discharge nothing. Phase 6's consumer instantiates at the state
`⟨(q, C, N), h⟩` at `z`, where `cntAt g z = C` and `nxtAt g z = N`, and already carries
`hgap : N + 2 ≤ C`. Admitting the hypothesis into the plan's pinned statement lands the compiled
proof unchanged.

## Plan Deviations

- **Phase 1**, optional `NextRegionBounded` step skipped: the plan declares it a presentation
  choice rather than a deliverable (annotated inline on the checklist item).
- **Phase 2**, `objCycleLens_nonempty_of_pend`: the plan's documented ESCAPE (close
  `[COMPLETED WITH EXCLUSIONS]` for that one step) was NOT taken — the step landed in full.
- **Phases 5-9**: not started. Each depends on Phase 4 through the plan's own dependency
  analysis, so none was attempted past the blocker.

## Verification

- Build: Success — full unscoped guarded `lake build`, 2973 jobs, 0 errors, 0 warnings. Run at
  every phase boundary and once more as final verification; every touched module's `.olean` is
  newer than its source.
- Sorry count: 0
- Vacuous count: 1, pre-existing and outside this task's file scope
  (`FormalSystem/Examples/TemporalStructures.lean:495`, a genuine theorem about
  `intTimeHistory.domain`, not a placeholder). Zero in the three files this task touched.
- Axiom count: 14, unchanged from the pre-task baseline — `git diff` over the three touched files
  shows no added or removed `axiom` line.
- `lean_verify` on each of the six landed declarations: standard axiom profile
  (`propext`/`Classical.choice`/`Quot.sound`), no `sorryAx`, no non-standard axiom.
- `bash scripts/typst-sync-check.sh`: PASS (all 4 checks green).
- `bash scripts/check-copyright-headers.sh`: exit 0.
- `bash scripts/check-metalogic-cycles.sh`: exit 0.
- `bash scripts/check-module-invariants.sh`: exit 1, on two findings, both enumerated and
  neither a regression from this task's landed phases. `FAIL INV` — three stale generated
  inventory blocks (`README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`) are the expected consequence of
  this task's line-count changes, and regenerating them is Phase 9's own task, unreached.
  `FAIL C16` — two `unusedArguments` findings, both in
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` (lines 1825, 1868), a file
  this task never touched and whose named declarations are present at the pre-task baseline.
- Plan compliance spot-check: `skipped`, exactly as the plan's Decision 2 predicted — the
  declared `Goal Polarity: mixed` cannot be expressed by that single global field.
- Batch gate deferral: the dispatch directive's scoped tier was honoured. This dispatch touched
  no shell script, no `.claude/**` and no `agent-system/**` file, so no `run-all.sh` suite or
  `verify-deploy.sh` gate covers its file set; the covering checks for Lean library files are the
  full `lake build` and `typst-sync-check.sh`, both run and both green. The complete gate set is
  deferred to the batch stage rather than independently run here.
- Files verified: Yes

## Impacts

- `hasForwardSlack_iff_next_region_cnt_le` makes the forward-slack regime checkable: any consumer
  holding a concrete path can now read the next region's countdown instead of reasoning about the
  register, and `forwardSlackWitnessed_iff_next_region_cnt_le` lifts that to the cell level.
- `pend_succ_of_fwd` closes the refutation side structurally: no admissible object bounds its own
  pending-region lengths, so a refutation of `ForwardSlackWitnessed` by construction has no
  counterexample object to be built on. `objCycleLens_nonempty_of_pend` turns the same walk into
  the (K1) consequence — the object-side divisibility clause is never vacuous on a serial object
  with a pending state.
- `hasForwardSlack_amount_le` with `paramsOk_inflate` jointly rule out the unbounded-amount route:
  the modulus may be inflated freely while the regime refuses any amount above
  `n + cntAt g z + I`.
- The reserved name `cellLE_zero_const_of_kappa_eq` remains claimed by nothing. An exact-name
  sweep confirms no declaration site anywhere under `FormalSystem/`, and no declaration this task
  landed takes that name or a prefix of it. All five landed depth-`0` cell-equality schemas still
  carry `ForwardSlackWitnessed`.

## Follow-ups

- **Revise the plan's Phase 4 pinned Challenge statement** to carry
  `nxtAt g z ≤ cntAt g z` (or the consumer's pending-forever gap, from which it follows). The
  compiled proof in this task's `evidence/` directory then lands unchanged and Phases 5-9 proceed
  as written. This is the single decision the task is waiting on.
- Phase 9's `--emit-inventory` regeneration is owed for the three stale inventory blocks this
  task's line-count changes produced.
- The two pre-existing `unusedArguments` findings in `LadderPump.lean` are outside this task's
  file scope and are recorded here only so a later reader does not mistake them for a regression.

## References

- `specs/917_forward_slack_witnessed_discharge_or_refutation/plans/01_forward-slack-witnessed-discharge.md`
- `specs/917_forward_slack_witnessed_discharge_or_refutation/reports/01_forward-slack-witnessed-discharge.md`
- `specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-4-pinned-signature-deficit.lean`
- `specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-4-pinned-signature-deficit-FAILS.lean`
- `specs/917_forward_slack_witnessed_discharge_or_refutation/handoffs/`
