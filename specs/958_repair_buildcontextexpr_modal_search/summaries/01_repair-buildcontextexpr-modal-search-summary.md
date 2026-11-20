# Implementation Summary: Task #958

- **Task**: 958 - Repair FormalSystem/Tactic/Meta.lean's buildContextExpr, which throws on every call and hard-fails modal_search on any box-headed goal
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T19:11:37-08:00
- **Completed**: 2026-11-19T19:30:00-08:00
- **Effort**: ~20 minutes
- **Dependencies**: None (task 955 depends on this task, not the reverse)
- **Artifacts**: plans/01_repair-buildcontextexpr-modal-search.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`buildContextExpr` passed `List.nil`'s implicit type parameter as an explicit `mkAppM` argument,
so it raised `too many explicit arguments provided to @List.nil` on every input including the
empty list, and because both consumers called it outside their `observing?` block the exception
aborted the whole tactic rather than failing one search branch. One token repairs the builder
(`mkAppM` -> `mkAppOptM ``List.nil #[some formulaType]`); both call sites moved inside their
`observing?` blocks so an elaboration failure there is a failed branch; and the suite gained an
invoked `MetaM` probe plus three `modal_search` acceptance examples, which is coverage the
previous `#check`-only treatment could not have provided.

## What Changed

- `FormalSystem/Tactic/Meta.lean` — `buildContextExpr`'s nil case now builds via
  `mkAppOptM ``List.nil #[some formulaType]`. `mkAppOptM` takes an `Array (Option Expr)` and
  assigns `some` entries to the next parameter whether implicit or explicit, so the type argument
  lands on `List.nil`'s implicit `{α}`. The `List.cons` loop is unchanged: `List.cons` takes
  exactly two explicit arguments, so that line was always correct.
- `FormalSystem/Automation/Tactics/Search.lean` — in both `tryModalK` and `tryTemporalK`, the
  `buildContextExpr` call and its comment moved inside the `observing? do` block as its first
  statements, above `setGoals [goal]`, and the blank line each move stranded above
  `let success ← observing? do` was deleted. The call reads no goal state, so `observing?`'s
  rollback on failure is harmless to it. The residual throw path through
  `mkAppM ``List.cons #[f, result]` survives the repair, which is the standing reason a
  speculative branch should absorb it. File is now 618 lines (was 620).
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` — added an invoked `#eval show MetaM Unit`
  probe that applies `buildContextExpr` to `[]` and to `[p, q]`, runs `Meta.check` on each
  result, confirms the empty case's inferred type `isDefEq` to `Context`, and pins both results
  against `Meta.mkListLit (mkConst ``Formula) ...`; added the three `modal_search` acceptance
  examples (box-headed at empty context, box-headed at a non-empty all-boxed context, and
  `allFuture`-headed); and rewrote the Group 6 paragraph that had declared `buildContextExpr`
  deliberately `#check`ed and never applied. The qualified `Meta.check` is required: the file
  opens `Lean` but not `Lean.Meta`.
- `typst/generated/status.typ` — regenerated (`scripts/typst-sync-check.sh --fix`).
- `typst/generated/automation-module-map.typ` — regenerated (`scripts/typst-module-map.sh`).
- `FormalSystem/Automation/Tactics/README.md` — regenerated inventory block
  (`scripts/check-module-invariants.sh --emit-inventory`).

## Decisions

- `mkAppOptM` over the raw `Lean.mkApp (Lean.mkConst ``List.nil [Level.zero])` form, on measured
  in-repo convention rather than behaviour: both were measured working at research time, and
  `FormalSystem/Automation/ProofMode/Meta.lean`'s `contextExpr` is a working twin of
  `buildContextExpr` differing only in that line, while `Search.lean:265` itself already carries
  an `mkAppOptM ``List.nil #[some ...]` site.
- All three acceptance examples kept rather than only the one the task description names. With an
  empty context `buildContextExpr` is only ever called on `[]`, so the non-empty all-boxed case
  is the only one that drives the `List.cons` fold through the tactic, and the `allFuture` case is
  the only acceptance coverage `tryTemporalK` has.
- `Meta.mkListLit` not adopted as the implementation. It produces a syntactically identical `Expr`,
  but it would move `buildContextExpr` away from its `ProofMode/Meta.lean` twin instead of toward
  it. It is used in the probe as an independent oracle, which is where its value lies here.

## Plan Deviations

- None (implementation followed plan). The plan's **Scope Hypothesis** enumerated two drifting
  generated surfaces and instructed the implementer to confirm by running both regenerators and
  staging whatever they actually rewrite; a third surface drifted
  (`typst/generated/automation-module-map.typ`, rows `Tactics/Search.lean` 620 -> 618 and
  `automation-module-total` 3345 -> 3343) and was regenerated and staged under that instruction.
  It has its own regenerator, `scripts/typst-module-map.sh`: `typst-sync-check.sh --fix` reports
  the drift but does not repair it, because Check 2b is read-only.

## Verification

- Build: Success — full-project `lake build` through `lake-build-guard.sh`, exit 0, 2991 jobs,
  zero `error:` and zero `warning:` lines.
- Tests: Passed — `lake test` through the same guard, exit 0, 3061 targets, zero `error:` and
  zero `warning:` lines. The `#eval` probe runs at elaboration time, so a failing assertion in it
  would surface as a build error; a green build of the module is its pass signal.
- Acceptance discrimination: the box-headed example was measured **red** before the repair with
  `AppBuilder for `mkAppM`, too many explicit arguments provided to`, so green here is a real
  discrimination rather than a tautology.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: 1, pre-existing and outside this task's file scope —
  `FormalSystem/Examples/TemporalStructures.lean:495`'s `int_domain_universal`, byte-identical at
  `HEAD`, where `trivial` legitimately closes a universal-domain goal. This task introduced none.
- Axiom count: 14, identical to the `HEAD` baseline; none of the three edited `.lean` files
  declares an axiom.
- Axiom profile on named copies of all three acceptance goals:
  `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- `scripts/typst-sync-check.sh` exits 0 on all four checks; `--counts-only` exits 0;
  `scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- Scoped touched-path verification (`verify-touched.sh`): the complete gate set was **deferred to
  the batch stage** per this dispatch's batch-gate directive and not independently run. The
  narrowed run reported 84 of 95 suites passing; the 11 failures are all in
  `.claude/scripts/tests/**` and all stem from `agent-system/extensions` not existing in this
  repository, which is a deploy-only tree whose source store lives elsewhere (for instance
  `test-generate-task-order.sh`: `generate-task-order.sh not found (mode=source-store)`). No
  failing suite reads any of the six files this phase edits. They were pulled into scope because
  the script derives touched paths from the working tree, which carries other sessions'
  uncommitted `specs/TODO.md`, `specs/state.json` and `specs/events.jsonl` edits.
- Plan compliance spot-check: `COMPLIANCE_CHECK: failed`, on a single `[MISSING] modal_search`
  that is a false positive of the script's declaration-keyword matcher. `modal_search` is declared
  as tactic syntax (`syntax "modal_search" (num)? : tactic` at
  `FormalSystem/Automation/Tactics/Commands.lean:113`), so no `def`/`theorem`/`lemma`/`instance`
  line matches it; the script's own header documents several earlier false-`[MISSING]` classes of
  the same kind. The counter-evidence is direct: three `example ... := by modal_search` blocks
  compile green in this task's own test additions, and the tactic was never something this task
  was to declare. Every other harvested name reported `[OK]`.
- Files verified: Yes.

## Impacts

- `modal_search` can now close box-headed and `allFuture`-headed goals. `tryModalK` and
  `tryTemporalK` were unreachable in practice before this, so both become live search strategies
  for the first time.
- Any elaboration failure inside either strategy now registers as a failed search branch instead
  of aborting the tactic, which matters for the residual `mkAppM ``List.cons` throw path that the
  repair does not remove.
- The `@[tmLemma]`/`modal_search` test file now exercises `FormalSystem/Tactic/Meta.lean`'s
  `buildContextExpr` by invocation, so an `AppBuilder` arity defect in it cannot recur behind a
  passing build.
- Work scoped to consuming `modal_search` as a bounded fallback in
  `FormalSystem/Automation/Tactics/` is unblocked by this repair.

## Follow-ups

- The `FrameClass.Base` hard-coding in `tryModalK`/`tryTemporalK` remains: both build their
  subgoal type from `mkConst ``FrameClass.Base` rather than from the `_fc` argument, so neither
  fires at a non-`Base` frame class. Both docstrings already record it as deliberately deferred,
  and all three acceptance examples pass at `FrameClass.Base`.
- `buildContextExpr` and `FormalSystem/Automation/ProofMode/Meta.lean`'s `contextExpr` are now
  identical functions in two places, and both could collapse to `Meta.mkListLit`. A consolidation
  pass is a visible option, deliberately out of scope here.
- A context file on `mkAppM`/`mkAppOptM` argument arity would generalize the lesson, but it is a
  source-store edit under the Lean extension and belongs to its own task.
- `Tests/BimodalTest/Automation/LemmaDBTest.lean`'s module header still says the file is
  "Organized in three groups" while six groups exist. Pre-existing and untouched.
- The 11 agent-system harness suites that fail for want of an on-disk source store are a standing
  property of this repository, not a regression from this work.

## References

- `specs/958_repair_buildcontextexpr_modal_search/plans/01_repair-buildcontextexpr-modal-search.md`
- `specs/958_repair_buildcontextexpr_modal_search/reports/01_repair-buildcontextexpr-modal-search.md`
- `FormalSystem/Tactic/Meta.lean`, `FormalSystem/Automation/Tactics/Search.lean`,
  `Tests/BimodalTest/Automation/LemmaDBTest.lean`
- `FormalSystem/Automation/ProofMode/Meta.lean` (the `contextExpr` twin the repair matches)
