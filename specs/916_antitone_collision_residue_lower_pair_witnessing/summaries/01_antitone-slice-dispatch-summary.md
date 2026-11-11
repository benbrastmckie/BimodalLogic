# Implementation Summary: Task #916

- **Task**: 916 - Dispatch or compile a refutation of the ANTITONE slice of a `kappa`-class collision — the complement that `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` excludes in its own quantifier
- **Status**: [COMPLETED]
- **Started**: 2026-11-10T19:34:00-08:00
- **Completed**: 2026-11-10T20:12:00-08:00
- **Effort**: ~40 minutes (plan estimate: 14 hours)
- **Dependencies**: None
- **Artifacts**: plans/01_antitone-slice-dispatch.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The antitone slice of a `kappa`-class collision is DISPATCHED, in both directions, as depth-`0`
cell EQUALITY — not refuted. Fifteen new declarations landed across
`RaySummary/LadderCell.lean` and `RaySummary/LadderChain.lean`, closing the dichotomy
`kappa_collision_monotone_or_antitone` makes exhaustive: every collision in the pending-forever
regime above the threshold is now covered by the landed monotone schema or by the new antitone
one. The slice turned out to SPLIT along a compiled line into a BOUNDED-DESCENT sub-slice,
dispatched with NO upward hypothesis at all, and a DEEP-DESCENT residue, which is where the
lower-pair forward-slack route the predecessor named is actually spent. Zero sorries, no new
axiom, and the reserved name `cellLE_zero_const_of_kappa_eq` still claimed by nothing.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — thirteen new declarations
  plus an amended module docstring and a `set_option linter.style.longFile 2000` header:
  - `section Collision`: `AntitoneCollisionDisplacement` (the named complement shape),
    `kappa_collision_monotone_or_antitone_named` (the landed dichotomy over the two named
    predicates, closed by `exact` on the landed theorem),
    `kappa_collision_antitone_descent_multiple` (the register's descent across a collision is
    itself a multiple `j · (P + 1)`, which turns the split into a comparison of `j` against `m`),
    `kappa_collision_antitone_bounded_descent_nonvacuous` (at `(4, 2)` against `(6, 0)`,
    `m = 2` — the predecessor's OWN non-vacuity witness, lying in the cheaper half) and
    `kappa_collision_antitone_deep_descent_nonvacuous` (at `(10, 8)` against `(11, 0)`, `m = 1`).
  - `section FreeRegister`:
    `exists_ladderPath_through_free_register_shifted_slack_of_pend_past` (the free-anchor raise
    with the lower bound RELAXED to `nxtAt g z ≤ n₀ + (m · (P + 1) + L)` under forward slack `L`
    at the lower pair) and `free_register_anchor_clause_relaxed_bound_required` (the relaxed
    bound is itself non-removable, at the deep-descent arithmetic witness
    `X = 19, nz = 8, cz = 10, mP = 1, n₀ = 0, d = 12`).
  - `section ForwardSlack`: `cellAt_subset_of_antitone_register_shift_of_pend_past` (upward:
    countdown UP, register DOWN, at the truncated amount `(n − n') − m · (P + 1)` witnessed at
    the LOWER pair), `cellAt_subset_of_antitone_register_shift_of_pend_past_rev` (downward:
    countdown DOWN, register UP, at `m · (P + 1)` witnessed at the higher pair, under NO room
    bound), `forwardSlackWitnessed_zero` (an amount-`0` witnessing obligation is FREE),
    `CellLEZeroConstOfKappaEqAntitoneForwardSlack`,
    `cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack` and
    `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` (the BOUNDED sub-slice as
    cell equality carrying exactly ONE `ForwardSlackWitnessed` hypothesis and none upward).
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — two new declarations plus
  an amended module docstring and a `longFile` ceiling raised 2500 → 2700:
  `exists_ladderPath_through_shifted_slack_of_pend_past` (the regime-A assembly returning its
  four landed clauses PLUS `HasForwardSlack g' z (L + m · (P + 1)) (nxtAt g z)`, the raise's own
  bought slack that the landed assembly discards) and
  `exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` (the exact-shift deletion
  with the target register RAISED rather than lowered, at the regime amount `m · (P + 1)`
  UNCHANGED).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — both Description cells extended,
  and the "antitone route left open" paragraph replaced: the route is now recorded as TAKEN for
  the deep-descent residue and never needed for the bounded sub-slice, with the one claim that
  is still open (satisfiability of a POSITIVE-amount `ForwardSlackWitnessed` hypothesis at a
  state the induction one layer up reaches) kept and still claimed in neither direction.
- `README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks
  (`check-module-invariants.sh --emit-inventory` rewrote three files;
  `FormalSystem/README.md` and `FormalSystem/Metalogic/Decidability/README.md` came back
  unchanged, as the plan's Scope Hypothesis allowed).
- `typst/generated/status.typ` — regenerated line counts, staged with each phase's own commit.

**No landed signature or body was edited.** Every addition is a sibling.
`kappa_collision_monotone_or_antitone`, `free_register_anchor_clause_monotone_required`,
`exists_ladderPath_through_shifted_of_pend_past`,
`exists_ladderPath_through_free_register_shifted_of_pend_past`,
`exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`,
`CellLEZeroConstOfKappaEqMonotoneForwardSlack` and
`cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` are all byte-identical: across all
eight phases the only deletion lines in either Lean module's diff are the two `set_option
linter.style.longFile` ceilings.

## Decisions

- **A raise is free in the direction the anchor clause charges for.** This is the mathematical
  content of the dispatch. The single two-sided anchor inequality charges for LOWERING the target
  register in its upper direction — which is why the landed register-lowering deletion spends `k`
  of extra slack and carries a room bound — and charges nothing for raising it. The antitone
  downward half raises where the monotone one lowers, so it spends `m · (P + 1)` (the countdown
  displacement alone) under no room bound at all. The antitone direction is therefore strictly
  CHEAPER downward than the monotone one.
- **The slice splits, and the predecessor's own non-vacuity witness lies in the cheaper half.**
  `kappa_collision_antitone_descent_multiple` makes the split a comparison of two multipliers.
  On the bounded sub-slice the truncated upward amount `(n − n') − m · (P + 1)` is literally `0`
  in `ℕ`, and `forwardSlackWitnessed_zero` discharges an amount-`0` obligation outright — so the
  bounded half needs no upward hypothesis whatever. The pair
  `kappa_collision_antitone_residue_nonvacuous` exhibits sits in that half, which means the
  compiled demonstration that the excluded slice was non-empty was all along a demonstration
  about its cheaper half.
- **One exhaustive schema plus a bounded corollary, not two schemas.** The plan's deliberate
  departure from the research report, grounded in a plan-time probe that
  `ForwardSlackWitnessed … z 0 n` is a THEOREM rather than a hypothesis. Verified here by reading
  the bounded corollary's signature: exactly one `ForwardSlackWitnessed` hypothesis.
- **`free_register_anchor_clause_monotone_required` is untouched, unamended and
  uncontradicted.** Its own witness has `mP = 0`, where the relaxed bound IS the landed bound.
  Its bound is non-removable, as it compiles; what is new is that the bound is RELAXABLE by
  exactly the raise, and `free_register_anchor_clause_relaxed_bound_required` compiles the
  relaxed bound as non-removable in turn, at a disjoint deep-descent witness.
- **Nothing landed under the reserved name, and no claim was made about it.** Every schema here
  is strictly stronger in hypotheses than `cellLE_zero_const_of_kappa_eq` and each one's
  docstring says, in those words, that it bears on the reserved statement's truth value in
  NEITHER direction.
- **The `ForwardSlackWitnessed` discharge was not attempted.** Every schema STATES the
  hypothesis; only the amount-`0` case is discharged, and `forwardSlackWitnessed_zero`'s
  docstring says explicitly that doing so settles nothing about the general question.

## Plan Deviations

- **Phase 2** altered: the pinned PLACEMENT (`section AssemblyFin`, immediately after
  `exists_ladderPath_through_shifted_of_pend_past`) is impossible — `HasForwardSlack` is defined
  at `LadderChain.lean:1218` in `section DelNxt` and `hasForwardSlack_raise` at `:1347` in
  `section Slack`, both BELOW `section AssemblyFin`, so a declaration whose conclusion mentions
  either cannot sit there. Landed at the end of `section Slack`, with the placement reason in its
  own docstring. Pinned signature landed verbatim.
- **Phases 5 and 6** altered, same class: the pinned placement (`section FreeRegister`) is
  impossible because `ForwardSlackWitnessed` is defined in `section ForwardSlack`, which follows
  both `section FreeRegister` and `section Collision`. Both landed in `section ForwardSlack`
  beside the landed `cellAt_subset_of_free_register_shift_of_pend_past_rev` — which is exactly
  where the same constraint already put the landed monotone downward inclusion. Pinned
  signatures landed verbatim.
- **Phases 3, 4 and 7**: three one-line edits outside the declared Files-to-modify intent, all
  mechanical consequences of file growth rather than declaration changes —
  `set_option linter.style.longFile` raised 2500 → 2700 in `LadderChain.lean`, and added to
  `LadderCell.lean` (which had none) then raised 1700 → 2000.
- **No signature deviation anywhere.** Every one of the fifteen declarations landed at the exact
  signature pinned in the plan's `## Lean Challenge Statements`. The three deviations above are
  all placement or file-header edits; none weakens, specialises, or re-hypothesizes a pinned
  statement.

## Verification

- Build: **Success** — full-project `bash .claude/scripts/lake-build-guard.sh build --timeout
  1800 -- build` run at every one of the eight phase closures and again as final verification;
  guard exit 0, 2973 jobs, 0 `error:` lines, 0 `warning:` lines, both touched modules' `.olean`
  newer than source.
- Sorry count: **0** (`lean-sorry-census.sh` over all eight source roots resolved by
  `lean-src-roots.sh`).
- Vacuous count: **0 attributable** — one pre-existing grep hit at
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`), untouched by
  this task and not vacuous in substance, since `intTimeHistory.domain` is definitionally total
  on `Int`.
- Axiom count: **14**, unchanged from the baseline measured before any edit. `lean_verify` on
  seven of the fifteen declarations, including both schema theorems, reports only
  `propext`, `Classical.choice`, `Quot.sound` — each module's own recorded profile — with no
  `sorryAx` and no custom axiom.
- Reserved name: `grep -rnE "^(theorem|def|lemma|abbrev) cellLE_zero_const_of_kappa_eq\b"` over
  `FormalSystem/` returns **0 hits**. Every other occurrence is prose in a docstring or README.
- `bash scripts/typst-sync-check.sh`: exit 0. `--counts-only` exit 0 before every one of the
  eight commits.
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: exit 0.
- `bash .claude/scripts/check-task-references.sh`: exit 0 — no task-number citation landed in any
  `FormalSystem/**` or `typst/**` deliverable.
- `bash scripts/check-module-invariants.sh` (full): exits 1 on `FAIL C16` only. Both findings
  name `RaySummary/LadderPump.lean:1825` and `:1868`, a file this task never touched (last
  modified by task 911; `git log 32ebf9a2f..HEAD --name-only` shows zero `LadderPump` hits).
  Recorded as inherited baseline and NOT hand-patched — `lake exe runLinter --update` would
  grandfather a finding this task cannot assess. Every other check group passes, including C2
  axiom baselines, the inventory check, C15, C20 tiers 1 and 2, C36 and C9D.
- Full gate set (`verify-deploy.sh`): **DEFERRED to the batch stage**, per the dispatch
  directive's Batch Gate Deferral section, not independently run here. Zero files under
  `.claude/**` and zero shell scripts were touched, so no `--only-gate N` or `--only SUITE`
  selection has coverage intersecting this task's paths; the covering checks are the repository's
  own Lean/doc gates enumerated above. The full record is in the plan's
  `#### Verification Notes (recorded at implementation time)` under Phase 8.
- Tests: N/A — this task adds theorems to the Lean library and no executable test surface.
- Files verified: Yes.

## Impacts

- The dichotomy `kappa_collision_monotone_or_antitone_named` is now dispatched on BOTH sides.
  Every `kappa`-class collision in the pending-forever regime above the threshold is covered as
  depth-`0` cell EQUALITY by `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` or by
  `cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack`, so a consumer dispatching on a
  collision no longer has an uncovered branch.
- The single remaining obligation across both slices is uniform: a `ForwardSlackWitnessed`
  hypothesis at a positive amount. That narrows what a consumer one layer up has to supply from
  "a hypothesis family plus an uncovered antitone complement" to "a hypothesis family", which is
  exactly the surface a sibling task owns.
- `exists_ladderPath_through_shifted_slack_of_pend_past` and
  `exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` are available to any
  later consumer that needs the raise's bought slack or a register delivered above its original
  value; neither was reachable from a landed signature before.
- `RaySummary/README.md`'s antitone-route claim is no longer stale: a reader is no longer told
  that "no landed schema carries a hypothesis of that family" when one does.

## Follow-ups

- The `ForwardSlackWitnessed` discharge at a POSITIVE amount remains open and is claimed in
  neither direction. `forwardSlackWitnessed_zero` settles only the amount-`0` case, and does so
  because that case is free rather than because the general question has been answered. This is
  the explicit out-of-scope line of this dispatch and is a sibling task's subject.
- `FAIL C16` in `check-module-invariants.sh` (two `unusedArguments` findings in
  `RaySummary/LadderPump.lean`) is inherited and unresolved. It needs an owner who can judge
  whether the three unused binders there are intentional (in which case `@[nolint
  unusedArguments]` or a baseline update is right) or a genuine signature regression.
- `set_option linter.style.longFile` now stands at 2700 for `LadderChain.lean` (2597 lines) and
  2000 for `LadderCell.lean` (1890 lines). Both modules are approaching the point where a split
  is worth considering rather than another ceiling bump.

## References

- `specs/916_antitone_collision_residue_lower_pair_witnessing/plans/01_antitone-slice-dispatch.md`
  — the plan executed, including its `## Lean Challenge Statements` pinned signatures and the
  Phase 8 verification notes.
- `specs/916_antitone_collision_residue_lower_pair_witnessing/reports/01_antitone-collision-residue-witnessing.md`
  — the research report, integrated in full, including the sequencing the wave table encodes.
- `specs/916_antitone_collision_residue_lower_pair_witnessing/handoffs/` — per-phase handoffs
  (phases 1-7), each recording that phase's evidence, decisions and deviations.
- `specs/916_antitone_collision_residue_lower_pair_witnessing/issues.jsonl` — the issue/win log
  for this dispatch.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the amended antitone-route record
  and both extended Description cells.
