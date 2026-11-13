# Phase 11.17 handoff — dispatch 37, task 761

## Immediate next action

Nothing in plan v12 is enterable by an implementation dispatch. Phases 11.15, 11.16 and 11.17 are
`[COMPLETED]`; every remaining open phase (11.6, 11.7, 11.8, 11.12, 11.13, 12.2, 13, 14, 15.1,
15.2, 16, 17, 18) sits behind Phase 11.6's depth-`0` gate or is `[BLOCKED]`. That gate is NOT
lifted and no open task owns lifting it — `specs/ROADMAP.md`'s Stage 0 carries "Decide who owns
the depth-`0` gate" as its one unchecked blocking item, and names the crux: whether a
`ForwardSlackWitnessed` hypothesis at a POSITIVE amount is satisfiable at any state the depth-`0`
induction reaches, in its EXISTENTIAL-over-paths form only (the per-path form is already refuted
by `ClimbWitness.hasForwardSlack_refuted_unconditional`).

## Branch taken, and why the other two do not apply

**Branch (B) — RENAME to auxiliaries**, per the checked Stage 0 user ruling of 2026-11-13.

- **(R)** is CLOSED on the mathematics, independently of any ruling: Phase 11.14's compiled
  `hself_not_derivable` refutes exactly the implication (R) needs, with `Fintype Q` assumed.
- **(A)** was not the ruling. Stage 0 gives four grounds for preferring (B).

## What landed

| Recorded name (now UNCLAIMED) | Auxiliary landed |
|---|---|
| `exists_ladderPath_at_region_of_idle_past` | `exists_ladderPath_at_region_of_idle_past_of_self_loop` (`LadderAgree.lean:2242`) |
| `exists_ladderPath_at_region` | `exists_ladderPath_at_region_of_self_loop` (`LadderAgree.lean:2315`) |

No signature changed — the renames are name-only, and both auxiliaries carry `hself` unchanged
binder-for-binder from what Phases 11.12 and 11.13 landed.
`exists_ladderPath_at_region_of_pend_past` keeps its own name because it reads no `hself`.

Plus: the consumer-side note in `LadderRealize.lean`; the stale docstring reference in
`LadderWindow.lean`; the axiom-profile pins and their prose in `KTypeSummaryAxiomTest.lean`; and
the authored `LadderAgree.lean` inventory row in `RaySummary/README.md`.

## Scope expansion — RAISED, not taken silently

`LadderWindow.lean` was raised via `issue-record.sh` (`iss_1794549830215_6yqnJQ`) BEFORE the edit,
and the edit was kept to the stale reference plus its linter-forced rewrap. A correction follows
(`iss_1794550951765_8qn8m1`): the file IS in `specs/state.json`'s 43-entry `file_scope` for this
task, so no expansion was actually needed — it is the task DESCRIPTION's prose `FILE SCOPE:` line
that is narrower, and it is stale.

## Deviations

None. Two of the plan's own carried figures were falsified on re-measurement and reported rather
than absorbed: `LadderWindow.lean`'s scope status (above), and Phase 11.17's claim that
`README.md:38` carries the ONLY generator placeholder (five rows carry it).

## Gates at handoff

All green: two full `lake build` runs through the guard (exit 0, 2,975 jobs, 0 errors, 0
warnings); three guarded scoped builds (exit 0, 0 warnings); `check-module-invariants.sh` ALL
CHECKS PASSED; `check-evidence-probes.sh` exit 0 (`all 58 wired probe(s) compile` — the
pre-existing failure recorded under Phase 11.14 was resolved by a sibling task);
`typst-sync-check.sh`, `readme-lint.sh`, `check-task-references.sh --quiet` each exit 0; sorry
count 0; axiom counts 12/2, not increased. Length ceilings held: `LadderAgree.lean` 3,366/3,400,
`KTypeSummaryAxiomTest.lean` 2,992/3,000 — neither in-source baseline raised.

## Commits

- `12f8aaee6` task 761 phase 11.16: execute the ruled hself disposition (B), rename to auxiliaries
- `c52858c63` task 761 phase 11.17: the cascade record and the LadderAgree.lean inventory row
