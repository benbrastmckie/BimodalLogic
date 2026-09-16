# Implementation Summary: Task #579

- **Task**: 579 - Nest MinusLanguage/, PlusLanguage/, StarLanguage/ under Syntax/
- **Status**: [BLOCKED]
- **Started**: 2026-09-15T21:19:23-07:00
- **Completed**: 2026-09-15T21:42:00-07:00
- **Effort**: ~0.4 hours (of a 5.25-hour plan; 1 of 7 phases closed)
- **Dependencies**: None
- **Artifacts**: plans/01_nest-language-family-under-syntax.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 1 of 7 landed and is green: `FormalSystem/Syntax/SubformulaClosure/` now has the sibling
aggregator that C8 will demand once `FormalSystem/Syntax` joins its `parent` tuple. Phase 2 —
the move itself, on which Phases 3-7 all transitively depend — is `[BLOCKED]` by a territory
conflict between the plan and this dispatch's own instructions: 4 of the 41 import lines the
move must rewrite live under `FormalSystem/Semantics/`, which the dispatch message placed
off-limits because a concurrent task-580 dispatch owns that directory. No proof content,
theorem statement, tactic block, namespace, or axiom was touched anywhere.

## What Changed

- `FormalSystem/Syntax/SubformulaClosure.lean` — **created**. Sibling aggregator importing the
  four leaf modules (`Closure`, `NestingDepth`, `TemporalFormulas`, `IteratedTemporal`), with
  the standard copyright header and a module docstring in the style of the other aggregators.
  No declarations, only imports and documentation.
- `FormalSystem/Syntax.lean` — its four `import FormalSystem.Syntax.SubformulaClosure.*` leaf
  imports collapsed to the single `import FormalSystem.Syntax.SubformulaClosure`.

No Lean declaration was added, removed, or changed. The plan's `## Lean Challenge Statements`
section commits to no new or changed declarations, and that commitment holds.

## Decisions

- **Phase 1 verified with a scoped build.** `lake build FormalSystem.Syntax` (guarded, detached)
  rather than a full `lake build`, because the concurrent task-580 dispatch has
  `FormalSystem/Semantics/` in an intermediate state. `FormalSystem.Syntax` does not import
  `FormalSystem.Semantics`, so the scoped build covers every module Phase 1 can affect.
- **No full `lake build` was run at final verification, deliberately.** Two reasons, both about
  the concurrent dispatch rather than about this task: the result would be a snapshot of a
  moving tree and therefore uninterpretable, and the build guard's lock is project-granular, so
  a long full build from this session would serialize task 580's own phase-end build behind it.
  This is recorded as an explicit omission, not a pass — see `## Verification`.
- **The territory boundary was not overridden.** Making the 4 `Semantics/` import edits
  unilaterally would have unblocked Phases 2-7, and the edits are individually trivial, but the
  dispatch instruction against editing that directory was explicit and the coordination call
  belongs to the orchestrator. The escalation path (mark `[BLOCKED]`, document, return
  `partial`) was taken instead.
- **No shim or partial move was attempted.** Lean has no module-alias mechanism, and leaving
  re-export shims at `FormalSystem/{Minus,Plus,Star}Language.lean` is ruled out by Phase 2's own
  verification criterion. There is also no subset of the three directories whose consumers all
  lie outside `Semantics/`.

## Plan Deviations

- **Phase 1 verification** altered: scoped `lake build FormalSystem.Syntax` substituted for the
  plan's `lake build`, for the concurrency reason given under `## Decisions`. Annotated inline
  in the plan's Phase 1 body.
- **Phase 2** blocked before any edit landed: see the `**BLOCKER** (Phase 2)` record in the plan
  file for what failed, what was tried, why it is stuck, what is needed, and the four
  ready-to-run `sed` commands.
- **Phases 3-7** not opened. Each depends transitively on Phase 2, and the phase-closure
  contract's stop-at-a-closed-phase-boundary clause says to stop rather than open a phase that
  cannot be closed. All five remain `[NOT STARTED]`.

## Verification

- Build: **Partial** — `lake build FormalSystem.Syntax` (guarded, detached) exit 0, 712 jobs.
  Full `lake build` deliberately **not run**; see `## Decisions`.
- Sorry count: 0 in both changed files (`grep -c '\bsorry\b'` returns 0 for each). `C3`, the
  structural sorry inventory, reports **PASS** with zero across `FormalSystem/` (Boneyard
  excluded). The raw 330-hit `grep -rn '\bsorry\b'` figure over the live tree is prose mentions
  in docstrings and comments, which is why `C3`'s structural check is the load-bearing number.
- Vacuous count: 0 introduced. The single tree-wide hit,
  `FormalSystem/Examples/TemporalStructures.lean:496`, is pre-existing and in a directory this
  task never touched.
- Axiom count: 14, unchanged from `HEAD~1` (14). No new axioms.
- Tests: N/A — no test-visible change; the plan measured zero import-line hits under `Tests/`.
- Files verified: Yes.
- `ENFORCE_C8=1 scripts/check-module-invariants.sh --no-build`: **PASS C8**, which was Phase 1's
  purpose. `PASS C3 C4 C5 C11 C12 C14 C15 C20 C22 C23 C26` also hold.
- `scripts/readme-lint.sh`: **PASS**, 0 missing READMEs, 0 broken file references.

### Gate failures currently present, and whose they are

Recorded so a re-dispatch does not misattribute them. The plan's recorded baseline was a sole
`FAIL C13`.

| Finding | Owner | Disposition |
|---------|-------|-------------|
| `FAIL C13` — 2 unresolved relative markdown links (`README.md:336`, `docs/README.md:308`, both pointing at `.github/workflows/docs.yml`, renamed to `docs.yml.disabled` by commit `9bcbe9e41`) | Pre-existing, matches the plan's recorded baseline | Phase 4 repairs it in a separately-labelled commit |
| `FAIL C6` — `FormalSystem.Semantics.TruthTransport` unreachable and unmanifested | **Task 580's in-progress work**, not this task | Not touched. Will clear when 580 wires the module in |
| `FAIL INV` — hand-maintained row: `FormalSystem/Semantics/README.md` has no `TruthTransport.lean` row | **Task 580's in-progress work** | Not touched |
| `FAIL INV` — 3 stale generated inventory blocks (`README.md`, `FormalSystem/README.md`, `FormalSystem/Syntax/README.md`) | This task's Phase 1 (the new `SubformulaClosure.lean` changes the counts) | Phase 6 regenerates all three; this is exactly the set Phase 6 predicted |

## Impacts

- `FormalSystem.Syntax.SubformulaClosure` is now importable as a single module, so consumers no
  longer need to name the four leaf modules individually. `FormalSystem/Syntax.lean` already
  uses it.
- The C8 prerequisite is satisfied: `for d in FormalSystem/Syntax/*/` now reports a sibling
  aggregator for every Lean-bearing subdirectory, so Phase 3's one-line tuple extension will
  land green whenever Phase 2 clears.
- The boxdot-discoverability gap that motivated this task (review Finding H1) is **not yet
  closed** — that is Phase 5's `## Language family` section, which has not been written.

## Follow-ups

- **Unblock Phase 2** by one of the three routes in the plan's blocker record: grant the narrow
  4-line exemption, hand those 4 lines to the task-580 dispatch, or re-dispatch this task after
  580 releases `FormalSystem/Semantics/`. The four `sed` commands are recorded verbatim in the
  plan, verified against the current tree.
- All of the plan's remaining Scope Hypotheses were confirmed by read-only probes during this
  dispatch, so a re-dispatch can execute Phases 2-7 without re-measuring:
  - **Phase 2**: 41 import lines across 26 `.lean` files (matches the plan, not the dispatch
    description's 24). Zero hits under `Tests/`.
  - **Phase 4**: 5 module-shaped C5 tokens at `docs/development/MODULE_ORGANIZATION.md:301-305`;
    1 more at `docs/reference/API_REFERENCE.md:791`; 4 namespace-reading tokens needing
    allowlist entries at `NOTATION.md:49`, `docs/theorem-index.md:43-45`, and
    `docs/development/NAMING_CONVENTION_DEVIATION.md:291`. 53 slash-shaped `.md` references
    outside `specs/`, across 14 files — note `docs/theorem-index.md:196` carries a slash-shaped
    `FormalSystem/StarLanguage/Derivation.lean` that will break C12 after the move.
  - **Phase 5**: constructor deltas confirmed at 6 / 6 / 7 / 9. L = `atom, bot, imp, box, untl,
    snce`; L⁻ = `atom, bot, imp, box, allPast, allFuture`; L⁺ = L's six + `stab`; L⋆ = L⁺'s
    seven + `timeStore, timeRecall`. The plan's table is correct as drafted. Separately
    confirmed: `FormalSystem/Syntax.lean`'s docstring really does misstate the primitives as
    `allPast, allFuture`, so Phase 5's correction targets a real defect.
  - **Phase 5/2 README link depth**: `FormalSystem/MinusLanguage/README.md` lines 62-66 and
    `PlusLanguage/README.md` lines 83-87 carry `../` links needing re-depthing;
    `StarLanguage/README.md` carries none. In both, `../Syntax/README.md` becomes `../README.md`
    while the other `../X` links become `../../X`, and `PlusLanguage`'s
    `../MinusLanguage/README.md` stays unchanged (both end up under `Syntax/`).
  - **Phase 6**: exactly the three inventory blocks the plan named are stale, already confirmed
    by the live `FAIL INV` output rather than by estimate.
- A full `lake build` still needs to be run once `FormalSystem/Semantics/` is quiescent, to
  satisfy the plan's Testing & Validation criteria.

## References

- `specs/579_nest_minuslanguage_pluslanguage_starlang/plans/01_nest-language-family-under-syntax.md` — the plan, now carrying the Phase 2 blocker record
- `specs/579_nest_minuslanguage_pluslanguage_starlang/reports/01_nest-language-family-under-syntax.md` — research report
- `specs/579_nest_minuslanguage_pluslanguage_starlang/handoffs/phase-1-handoff-20260915T212300.md` — Phase 1 handoff
- `specs/reviews/review-2026-09-15.md`, Finding H1 — origin of this task
- `specs/579_nest_minuslanguage_pluslanguage_starlang/.dispatch/5.md` — this dispatch's context
