# Implementation Summary: Task #917

- **Task**: 917 - Discharge `ForwardSlackWitnessed` under `ParamsOk`, or compile a refutation
- **Status**: [COMPLETED]
- **Started**: 2026-11-10T21:00:00Z
- **Completed**: 2026-11-11T07:30:00Z
- **Effort**: ~4 hours across three implement dispatches
- **Dependencies**: None
- **Artifacts**: plans/01_forward-slack-witnessed-discharge.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All nine plan phases are closed. The task's decision gate was reached, measured, and answered:
the route that would have discharged `ForwardSlackWitnessed` is refuted at the pin layer, and the
refutation is compiled and wired into CI rather than argued in prose. Along the way the regime
itself was converted from an opaque condition on a path's register into a checkable bound on one
region's countdown, at both the path and the cell level, and the deletion primitive the route
needed was landed and is reusable wherever its two clauses come from outside the pending-forever
regime.

## Verdict

**The SECOND of the task's two admissible outcomes was reached: the discharge route is REFUTED,
not stalled and not merely unproved** — and `ForwardSlackWitnessed` itself, being an existential
over paths, remains neither discharged nor refuted, so it stays a hypothesis a consumer must
supply on all five depth-`0` cell-equality schemas. The named consequence the task description
demanded be recorded if this happened is recorded: `certStabK`'s one unclaimed `Real` condition
must be RESTATED rather than proved for as long as the hypothesis stays carried.

## What Changed

### Dispatch 9 (this dispatch: Phases 4-9)

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — Phase 4 landed
  `del_pin_pull_of_lt` (the two-regime pull for a pin below the block), `del_pin_pull_of_ge` (the
  pull above it), and `exists_deleted_ladderPath_of_next_region_nxt` at the plan's pinned
  signature with the admitted `hnz` and nothing further. Phase 8 added the verdict to the module
  docstring and to the primitive's own docstring. `longFile` baseline 2800 -> 3000 (2928 lines).
- `specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean` — **new wired probe**
  carrying the refutation: `no_deleted_ladderPath_of_straddle_break` (the obstruction as a
  theorem), `obs` (the saturated configuration realized as a concrete two-state ladder path in
  the regime), and `obs_no_admissible_block` (the deletion refuted at all three blocks that
  path's next region admits).
- `scripts/check-evidence-probes.sh` — the probe's `WIRED` entry with its what-it-holds-in-place
  record. A probe under `specs/` is reached by no Lake target, so without this entry it rots.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — a new Requirement (W) section
  stating the verdict, why `(K2)`'s budget cannot pay, and the `certStabK` consequence, plus ten
  `#print axioms` pins (with `#guard_msgs`) for every declaration the task landed. `longFile`
  baseline 2400 -> 2600 (2532 lines).
- `specs/state.json` — the task's own description carries the OUTCOME and THE NAMED CONSEQUENCE
  paragraphs, written under the `specs/.scope-lock/` mutex by a targeted splice (not a whole-file
  `jq` reflow), so no other task's record was touched.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — regenerated module-inventory
  blocks; `typst/generated/status.typ` — regenerated count fields.

### Earlier dispatches (Phases 1-3)

- `LadderChain.lean` — `next_region_cnt_le_of_hasForwardSlack`,
  `hasForwardSlack_iff_next_region_cnt_le`, `hasForwardSlack_amount_le`.
- `CounterQuotient.lean` — `pend_succ_of_fwd`, `objCycleLens_nonempty_of_pend`,
  `paramsOk_inflate`.
- `LadderCell.lean` — `forwardSlackWitnessed_iff_next_region_cnt_le`.

## The Refutation

The route: delete a type-respecting block inside the FIRST REGION ABOVE the compared position's
own region while holding the register at that position, then iterate to drive that region's
countdown below `tShort Q φ`, at which point the regime holds for free. Its primitive,
`exists_deleted_ladderPath_of_next_region_nxt`, takes exactly two clauses as hypotheses —
`hanch` for the pins at or above the block, `hstraddle` for the pairs that straddle it — and
discharges everything else internally.

**Both clauses fail, by exactly the deletion's own length.** `hanch` needs
`B ≤ N + (p - z) - l` where the only available bound is `B ≤ N + (p - z)`; `hstraddle` needs
`B ≤ K + (p - s) - 2·l` where the only available bound is `B ≤ K + (p - s)`. Here
`B = cntAt g (p+1) = nxtAt g p` is the upper pin's value, `K` is the next region's countdown, and
`s = z + cntAt g z + I` is the UNIQUE pin strictly below the block. The deletion leaves the
undisplaced pins' VALUES put while shortening every later pin's distance by `l`, and additionally
lowers by `l` the value of the pin whose region swallows the block; the two losses add on a
straddling pair.

**The obstruction is not an elaboration failure.** On a path whose straddling pin pair SATURATES
pin compatibility, the primitive's own CONCLUSION is false: any deleted path would itself be a
ladder path, so `pinCompat_of_ladderPath` binds its pins at exactly the broken positions. That is
`no_deleted_ladderPath_of_straddle_break`, and it holds for every broken pair, not just one
witness.

**`(K2)`'s budget cannot pay for it, which is the substantive finding.** `cascadeBound`'s own
recurrence `a (k+1) ≤ 2·a k + J + 1` is the bound the saturated configuration ATTAINS WITH
EQUALITY, so the budget describes the obstruction rather than dominating it. Two structural facts
close the remaining escapes: `Adm pend q = {c | pend q = false → c = 0}` places no upper bound on
a pending state's countdown, so a saturated register is admissible at every scale; and every
`ParamsOk` conjunct the thresholds enter is a LOWER bound on a parameter, never an upper bound on
a path quantity.

## Decisions

- **Phase 4's `hnz` was admitted by an explicit plan revision, not widened in place.** The pinned
  signature was measured incomplete by exactly `(nxtAt g z : ℤ) ≤ (cntAt g z : ℤ)` — established
  by compiling the full proof with and without it, both variants preserved as task evidence — and
  the plan was revised to carry it before the phase was implemented. The landed signature matches
  the revised pin character for character; nothing beyond `hnz` was added.
- **The refutation was built in two layers rather than one.** The arithmetic layer
  (`evidence/phase-5-gate-measurement.lean`) collects every fact the admitted hypotheses supply
  and exhibits assignments satisfying all of them at which each clause is false — this is where
  `Tc ≤ C` and `(K3)` are carried, so the deficit is shown scale-invariant. The path layer (the
  wired probe) exhibits a concrete ladder path. Neither layer alone is the whole record: the first
  is scale-faithful but abstract, the second concrete but at a scale no genuine `ParamsOk` admits.
  Both are cited, and the limitation of each is stated in its own docstring.
- **The out-of-scope gate finding was attributed, not fixed.** `check-module-invariants.sh`'s C16
  group fails on two `unusedArguments` findings in `LadderPump.lean`, a file this task never
  touched and which a concurrent sibling task's commit introduced. Per the plan's own Phase 9
  rule, that is a recorded PASS here and not grounds to edit an out-of-scope file.
- **The ten new axiom pins split across two profiles, and the split is recorded rather than
  smoothed over.** Five sit BELOW the standard profile at `[propext, Quot.sound]`, consuming no
  choice. For the five that carry `Classical.choice`, two distinct sources are named: three
  consume it in their own proofs, and two inherit it from the definitional closure of what they
  quantify.

## Plan Deviations

- **Phase 5 task "On PASS: land the one-pass shortening lemma"** — not taken: the gate measured
  FAIL. Per the phase's own Scope Hypothesis, the FAIL branch's zero-line outcome is a recorded
  result, not a skipped task.
- **Phase 6 and Phase 7** — closed `[COMPLETED WITH EXCLUSIONS]`, each with a full
  `#### Reasoned Exclusions` table whose Evidence column cites Phase 5's failing measurement.
  Both land nothing, as the plan's own FAIL branch directs. The one verification item Phase 7's
  FAIL branch still owed — the exact-name sweep for `cellLE_zero_const_of_kappa_eq` — was run,
  not assumed, and found no declaration site.
- **Phase 8 task "If Phase 5's gate PASSED: close with exclusions"** — not taken: the gate
  measured FAIL, so this phase RAN and landed the obstruction.
- **Phase 4 scope hypothesis** — estimated +130 lines, actual +171. The excess is the three
  docstrings the phase's own task list requires, not extra proof.
- **The `longFile` re-tightening** used the smallest ROUND-HUNDRED value inside the linter's
  window rather than the literal smallest integer (3000 rather than 2929 for `LadderChain.lean`),
  matching the convention every other baseline in this tree already follows.
- **Research Finding 3's per-schema `hroom` cancellation table remains CARRIED, not confirmed** —
  Phase 7 was the phase that would have confirmed it, and it is excluded. Recorded as unconfirmed
  rather than silently promoted.

## Verification

- Build: **Success** — unscoped guarded `lake build`, 2973 jobs, 0 errors, 0 warnings, guard exit
  0; `.olean` newer than source for every touched module.
- Test library: **Passed** — `lake build BimodalTest`, 3041 jobs, 0 errors, 0 warnings; all ten
  new `#guard_msgs` axiom pins satisfied.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: **0**.
- Axiom count: **0 new axioms**; `lean_verify` on
  `exists_deleted_ladderPath_of_next_region_nxt` reports `[propext, Classical.choice, Quot.sound]`
  with no `sorryAx`.
- `scripts/check-evidence-probes.sh`: **PASS** — all 53 wired probes compile, including the new
  one.
- `scripts/typst-sync-check.sh`: **PASS** (all 4 checks).
- `scripts/check-metalogic-cycles.sh`: **PASS** — no new upward import, confirmed by running it.
- `scripts/check-copyright-headers.sh`: **PASS** — 0 missing of 754.
- `scripts/check-module-invariants.sh`: **PASS for this task**; `--emit-inventory --check` green.
  One pre-existing C16 failure, enumerated and attributed to a sibling task's `LadderPump.lean`.
- `validate-artifact.sh ... plan`: **PASS** (two advisory warnings, no error).
- Plan compliance: the landed signature of `exists_deleted_ladderPath_of_next_region_nxt` matches
  the plan's pinned `## Lean Challenge Statements` entry exactly, modulo the section `variable`
  block supplying `{Q} {step} {pend}`.
- Files verified: Yes.
- **Batch deferral**: the complete gate set was not independently run as a batch-wide battery by
  this dispatch; that runs once for the whole batch. The mandated narrowing invocation
  (`run-all.sh --only`) covers shell suites of the agent system, and no such suite covers any
  file this phase touched, so every Lean-side and repository-side gate that does cover them was
  run directly instead and is tabled in the plan's Phase 9 record.

## Impacts

- The forward-slack regime is now a checkable condition on one region's countdown at both the
  path level (`hasForwardSlack_iff_next_region_cnt_le`) and the cell level
  (`forwardSlackWitnessed_iff_next_region_cnt_le`), independent of the verdict. Anyone who must
  supply the hypothesis can now check it against a single region.
- `exists_deleted_ladderPath_of_next_region_nxt` is available to any consumer that can supply
  `hanch` and `hstraddle` from OUTSIDE the pending-forever regime. Its docstring now says exactly
  why it cannot be supplied from inside it.
- `paramsOk_inflate` lets a displacement argument take any multiple of `P + 1` without
  re-deriving `ParamsOk`.
- The pin-layer obstruction is now wired into CI, so a future attempt at the same route meets a
  red gate rather than re-deriving the dead end.
- The `certStabK` consequence is recorded in four durable places, so the restate-rather-than-prove
  decision is discoverable without reading this task's artifacts.

## Follow-ups

- `CellLEZeroConstOfKappaEq` under `ParamsOk` is still neither proved nor refuted, and
  `cellLE_zero_const_of_kappa_eq` still has no declaration site anywhere under `FormalSystem/`.
- The ordinary window regime `c ≤ n + 1` is addressed by no landed inclusion in either direction.
- The room bounds the five schemas carry are untouched by this task.
- Two routes to the discharge remain open and are named rather than claimed: a `(K1)` amendment
  constraining the length of a type-respecting block that spans a region start, and a
  register-LOWERING deletion. Neither is addressed here.
- Research Finding 3's per-schema `hroom` cancellation table is carried, not confirmed.

## References

- `specs/917_forward_slack_witnessed_discharge_or_refutation/plans/01_forward-slack-witnessed-discharge.md`
  — the plan, with Phase 5's **GATE VERDICT** record and Phase 9's gate table
- `specs/917_forward_slack_witnessed_discharge_or_refutation/reports/01_forward-slack-witnessed-discharge.md`
  — the research report
- `specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean` — the wired path-level
  refutation
- `specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-5-gate-measurement.lean`
  — the scale-invariant arithmetic measurement
- `specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-4-pinned-signature-deficit.lean`
  and `...-FAILS.lean` — the `hnz` necessity measurement, compiled both ways
- `specs/917_forward_slack_witnessed_discharge_or_refutation/handoffs/` — the per-phase handoffs
