# Implementation Summary: Task #987

- **Task**: 987 - Temporal rules follow-ups: fold names and progress tests
- **Status**: [COMPLETED]
- **Started**: 2026-11-25T00:35:21-08:00
- **Completed**: 2026-11-25T10:49:36-08:00
- **Effort**: ~10 hours across 8 phases and 3 dispatches (two interrupted by session restarts)
- **Dependencies**: None blocking. Adjacent and separate: `connective_signature_layer_shared_primitives` (owns the siting of the TM syntax `PlusLanguage/TemporalViews.lean` declares under the TM-plus directory, untouched here); `proof_mode_until_since_intro_unfold_induction` builds on the same modules and runs after this record.
- **Artifacts**: plans/01_temporal-rules-followups.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All seven follow-ups owed after the temporal rules contribution are implemented across eight
phases, each landing its own commit. The work retires the colliding fold/unfold identifier
vocabulary in favour of expand/contract, fixes a latent instance-synthesis ordering bug in the
shared `lapply` elaborator and states the ordering contract its docstring was missing, narrows a
bare `catch` that was misreporting every exception as a frame-class problem, builds out
`lprogress` coverage from one example to a sixteen-cell matrix, pins every reachable
`throwError` path the contribution added with a `#guard_msgs` test (recording an in-source
reason for each of the six that no user syntax can reach), corrects three wrong module
descriptions, and regenerates the status stamp so its commit's own tree reproduces every figure
it records.

## What Changed

- `FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean` — eight `def`s renamed
  to the expand/contract vocabulary across both the TM and TM⁺ namespaces
  (`untilFoldRule`→`untilContractRule`, `untilUnfoldRule`→`untilExpandRule`,
  `untilFold`→`untilContract`, `untilUnfoldCases`→`untilExpandCases` and their Since mirrors),
  signatures and bodies otherwise byte-identical; section headings and four docstrings reworded.
- `FormalSystem/Automation/ProofMode/TemporalZTime.lean` — `binaryFold`→`binaryContract`,
  `binaryUnfold`→`binaryExpand`; the four `syntax` node names
  (`luntilFold`→`luntilContract`, `luntilUnfold`→`luntilExpand`, and the Since pair) and the four
  backtick-quoted rule keys in `oneStepRule` moved in lockstep. The user-facing keyword strings
  were already correct and are unchanged.
- `FormalSystem/Automation/ProofMode/Basic.lean` — the instance-synthesis loop relocated to sit
  after the `isDefEq` conclusion unification and before `goal.assign`, so a rule's frame-class,
  context and formula metavariables are assigned before any instance argument mentioning them is
  synthesized. `applyDerivationProof`'s doc comment now states the ordering requirement: that
  `firstNewIndex` MUST be snapshotted from `(← getMCtx).mvarCounter` BEFORE the proof term is
  elaborated, and why a counter read afterwards silently drops every one of the rule's own
  parameter metavariables.
- `FormalSystem/Automation/ProofMode/Temporal.lean` — `integerTimeGate`'s bare catch narrowed to
  the frame-class failure via a substring test on `"incompatible concrete frame classes"`, so the
  pinned test text survives while any other exception reaches the user with its original message.
- `FormalSystem/Automation/ProofMode/TemporalBoolean.lean` — unreachable-arm note.
- `FormalSystem/Automation/ProofMode/README.md` — the three wrong description cells rewritten
  inside the generated fences: `Carrying.lean`'s `<!-- TODO: add description -->` placeholder
  replaced with the carrying table's contents, `Temporal.lean`'s stale "progress" claim dropped,
  and `Discrete.lean`'s row restated to name `linduction` and the reused-or-decided ZTime
  certificate. `*Last verified:*` stamp bumped.
- `FormalSystem/Theorems/ProofMode/README.md`,
  `FormalSystem/Theorems/ProofMode/TemporalComposition/README.md` — `*Last verified:*` stamps
  bumped; regenerated `Lines` columns.
- `Tests/BimodalTest/Automation/ProofModeTemporalBooleanProgressTest.lean` — `lprogress` coverage
  grown from one `cases`-only example to all four forms (`cases`, `consequence using`,
  `trans using`, `using [_, _]`) across future TM, past TM, future TM⁺ and past TM⁺, plus negative
  tests for the module's reachable `throwError` paths.
- `Tests/BimodalTest/Automation/ProofModeTemporalTest.lean` — the instance-ordering regression
  example (`FrameTag` / `requiresFrameTag`, a class whose type mentions the rule's own
  `FrameClass` parameter, which the contribution's parameterless `ReviewInstance` test did not
  cover), written as a positive example rather than a message pin because the pre-fix message
  embeds `?m.3`; plus negative tests for `Temporal.lean`'s remaining paths.
- `Tests/BimodalTest/Automation/ProofModeTest.lean`,
  `Tests/BimodalTest/Automation/ProofModeCarryingTest.lean`,
  `Tests/BimodalTest/Automation/ProofModeTemporalZTimeTest.lean` — negative tests for the Modal,
  Meta, Carrying and Discrete paths, and the in-source reasons for the arms no user syntax reaches.
- `typst/generated/status.typ`, `README.md` — regenerated counts; the stamp now names
  `3d141e284`, the last `.lean` commit.

## Decisions

- **The rename was not a tree-wide `sed`.** `untilFold` and `sinceFold` also name unrelated Kamp
  bounded-fix material, so the rename was scoped to the one-step Until/Since identifiers under the
  two ProofMode directories and verified by exact-name greps rather than by a bulk substitution.
- **The instance-ordering guard is a positive example, not a `#guard_msgs` pin.** The pre-fix
  failure message embeds a metavariable number (`?m.3`), which no pin can stably match; a positive
  example that compiles under the fixed ordering and was hand-verified to fail under the pre-fix
  one is the stable form.
- **`integerTimeGate` narrows by substring rather than by exception class.** Lean's `catch` gives
  no frame-class-specific exception type to discriminate on, so the gate tests the message for
  `"incompatible concrete frame classes"` and re-raises anything else untouched.
- **Six `throwError` arms carry an in-source reason instead of a test.** Each was shown
  unreachable from user syntax by a compiled probe or a call-site enumeration, not asserted; the
  evidence per arm is in Phases 2 and 7's `#### Reasoned Exclusions` tables.
- **The status stamp is regenerated on the merged tree, not patched.** Because
  `scripts/typst-status-counts.sh` sets the stamp from `git rev-parse --short HEAD`, one run on
  the merged tree fixes the stamp and the counts together, which is why the stamp commit is
  phase 7's `.lean` commit rather than the commit that carries `status.typ`.

## Plan Deviations

- **Phase 2** `[COMPLETED WITH EXCLUSIONS]`: the `#guard_msgs` pin for `Basic.lean`'s "the applied
  rule produced an incompatible judgment" was replaced by an in-source reason, under the task's
  own fallback clause. No trigger is constructible from user syntax — the nearest candidate is
  rejected one step earlier by `adaptProof`, with the measured build output recorded as evidence.
- **Phase 7** `[COMPLETED WITH EXCLUSIONS]`: five arms (Modal's and Meta's "expected a native
  derivation", Carrying's two, and Discrete's "backward induction does not prove the current
  conclusion") carry in-source reasons rather than pins, each shown unreachable by a compiled
  probe or a call-site enumeration. The five notes are sited in the test modules rather than the
  library modules, because the phase's Scope Hypothesis excludes any `FormalSystem/` edit.
- **Phase 8**, final checklist item altered: `bash scripts/verify-all.sh` was not run. The
  dispatch carried a Batch Gate Deferral directive that forbids an additional full sweep, so the
  criterion was discharged as `verify-touched.sh` plus `scripts/readme-lint.sh` run directly under
  the directive's UNMAPPABLE CRITERION carve-out. Recorded in Phase 8's `#### Completion Notes`.

## Verification

- Build: **Success** — unscoped guarded `lake build`, exit 0, 3027 jobs, zero `error:` lines over
  both captured streams. `.olean` artifacts confirmed newer than source for all five library
  modules this task changed.
- Tests: **Passed** — guarded `lake test`, exit 0, zero `error` lines in the log.
- Sorry count: 0
- Vacuous count: 2, both pre-existing and outside this task's territory
  (`FormalSystem/Semantics/PointTransport.lean:215`,
  `FormalSystem/Examples/TemporalStructures.lean:495`), last changed by other tasks, and both
  false positives of the single-line pattern against deliberate total-relation content.
- Axiom count: 14, unchanged — 14 at the pre-task base and 14 at HEAD, with zero `axiom` lines
  added by any commit of this task and none anywhere in its territory.
- Stamp reproduction: a detached worktree at the recorded stamp commit `3d141e284`, then
  `scripts/typst-status-counts.sh --json`, reproduces **every** scalar in
  `typst/generated/status.typ` — `formalsystem-line-count` 422525 included, closing the +6 delta
  the plan's Scope Hypothesis predicted would need resolving. This is the task's one DONE WHEN
  clause with no mechanical gate behind it.
- Scoped gate (full set deferred to the batch stage per the dispatch directive):
  `verify-touched.sh` over 127 touched paths — 84 passed, 1 failed, 10 skipped, 95 total. The 10
  skips are this checkout's standing baseline (suites needing a local `agent-system/extensions/`
  source store, resolved externally here). The 1 failure,
  `.claude/scripts/tests/test-deploy-baseline-lib.sh`, is unattributable to this task: `.claude/`
  is gitignored in full, so that suite file is untracked and byte-identical before and after all
  of this task's commits; none of those commits touches any `.claude/`, `scripts/` or `lib/` path;
  and the failing assertion exercises `verify-deploy.sh`'s gate-cache warm-skip against a
  synthetic `/tmp` scratch target sharing no input with any path in this task's file scope.
- `scripts/readme-lint.sh`: exits 1 with exactly the four stale rows the plan predicted
  (`FormalSystem/Metalogic/Conservativity/Star`, `FormalSystem/Metalogic/Expressiveness`,
  `FormalSystem/Metalogic/WeakCanonical`, `FormalSystem/Tactic`), member for member, and **zero**
  in-territory rows — the positive confirmation that the three in-territory stamp bumps landed.
  None of the four directories is touched by this task.
- Lean plan compliance spot-check: `skipped`, as expected — the plan declares
  `<!-- lean-challenge-statements:none -->` and has no named theorem deliverable.
- Files verified: Yes.

## Impacts

- `lapply` no longer hard-fails with "could not synthesize the required instance" on any rule
  carrying an instance-implicit binder whose type mentions a rule parameter. Nothing in the tree
  triggered this before the fix — it was latent, and the new regression example is what now holds
  the ordering in place.
- A non-frame-class failure inside `integerTimeGate` (a `maxRecDepth`, an interrupt, an unrelated
  `Decidable`-synthesis failure) now reaches the user with its own message instead of being
  reported as a frame-class problem, and `resolveRuleParameters`' own "incompatible concrete frame
  classes" diagnosis is no longer discarded.
- `applyDerivationProof`'s docstring now warns the next sibling caller about the one ordering a
  natural reading gets wrong, which would otherwise surface as an opaque placeholder-synthesis
  error far from its cause.
- `typst/generated/status.typ` is auditable again: its stamp commit's own tree yields its figures.
- The expand/contract vocabulary is now consistent from the user-facing keywords down through the
  syntax node names, the rule keys and the pure rules, which is the layer
  `proof_mode_until_since_intro_unfold_induction` builds on next.

## Follow-ups

- `scripts/readme-date-baseline.txt` carries a `PRUNE:` candidate —
  `FormalSystem/Metalogic/Conservativity/README.md` is no longer a live stale finding, so its
  baseline row can be dropped. Out of this task's territory; noted, not acted on.
- The four new stale README rows named above remain stale by design; bumping a stamp in a
  directory this task does not touch would un-grandfather that row for no gate benefit.
- `.claude/scripts/tests/test-deploy-baseline-lib.sh`'s gate-cache warm-skip control assertion
  fails and is nobody's declared territory in this run; it belongs to the deploy-gate machinery
  and wants its own record.
- The 46 Kamp bounded-fix `Fold`/`Unfold` occurrences were verified by Phase 1 and were not
  re-derived at close.

## References

- `specs/987_temporal_rules_followups_fold_names_and_progress_tests/plans/01_temporal-rules-followups.md`
- `specs/987_temporal_rules_followups_fold_names_and_progress_tests/reports/01_temporal-rules-followups.md`
- `records/proof-mode-architecture.md` — the expand/contract vocabulary this rename settles on
- Phase commits: `dd9cd1827`, `064dbd5a6`, `553466302`, `253a4f1b6`, `949c5e90d`, `e8b934625`,
  `0e2e37472`, `3d141e284`, `572f668f3`
