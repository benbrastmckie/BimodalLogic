# Implementation Summary: Task #790

- **Task**: 790 - Prove lem:canonical-frames, the four claims about the paper's two canonical countermodel frames
- **Status**: [COMPLETED]
- **Started**: 2026-10-14T19:41:00Z
- **Completed**: 2026-10-15T03:24:00Z
- **Effort**: ~3.7 hours (plan estimate 7.5)
- **Dependencies**: None
- **Artifacts**: plans/01_lem-canonical-frames-characterizations.md, reports/01_lem-canonical-frames-characterizations.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The paper's lemma on its two canonical countermodel frames makes four claims, and all four are
now machine-checked: the translation frame is a *Deterministic* task frame whose possible worlds
are exactly the translations, and the two-state frame is a task frame just in case the duration
order is *Discrete*, in which case it is not *Deterministic* and every assignment of its two
states to times is one of its possible worlds. The work landed as 23 declarations appended to
`FormalSystem/Semantics/Correspondence/DurationFrames.lean` in one new section, with no new
module, no change to either frame's definition, and no change to any existing signature.

## What Changed

- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — a new
  `## The canonical frames' characterizations` section carrying all 23 declarations, plus a module
  header paragraph pair, four main-results bullets and `lem:canonical-frames` on the tags line.
  The 23, in landed order:
  - **(a)** `translationFrame_deterministic` — the translation frame is *Deterministic* at every
    temporal order, by `TaskFrame.fib_subsingleton_of_functional` at `fun w x => w + x`. This
    *generalises* the real-line instance rather than transferring from it (the dispatch's open
    question): `f1_deterministic` is about a shift-set frame, a different frame object, and a
    transfer would need a frame isomorphism that does not exist in the tree.
  - **view layer** `translationStates`, `translationSigma`, `translationSigma_states`,
    `translationHist_states`, `translationSigma_zero`, `translationStates_eq`
  - **(b)** `translation_eq_sigma`, `translationHistEquiv`, `translation_histSet_eq`,
    `translation_exists_unique` — the paper's `H_F = {σ_c | c ∈ D}` in pointwise, equivalence,
    set and uniqueness form
  - **(c)** `permRel`, `permRel_iff`, `permissiveFrame_taskRel_eq`, `permRel_reflection`,
    `permRel_limit_of_isLeast`, `permRel_not_limit_of_dense`,
    `isDiscrete_iff_exists_isLeast_pos`, `permRel_limit_iff_isDiscrete`,
    `permRel_constraints_iff_isDiscrete` — both halves: *Limit* holds under a least positive
    duration and fails over a dense carrier, so the four frame constraints hold iff the order is
    Discrete
  - **(d)** `permissiveFrame_not_deterministic`, `permissiveStates`, `permissiveHistEquiv`
- `docs/reference/paper-definitions-of-record.md` — two `LIVE-UNPINNED` KNOWN-ANCHORS rows
  (`def:canonical-frames`, `lem:canonical-frames`), landed *before* any citing docstring so the
  anchor-integrity invariant held at every commit boundary.
- `FormalSystem/Semantics/Correspondence/README.md` — the `DurationFrames.lean` row: line cell
  re-derived with `wc -l` (it was already stale before this task), description extended to name
  all four claims and their keystone declarations, both last-verified dates refreshed.
- `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean` — one sentence added to the
  module header's symptom-2 paragraph, naming the view definition and the general results that
  prove the analogue of the world-set characterization, so the paragraph no longer reads as
  though that characterization is unreachable on the translation route.
- `typst/generated/status.typ` and three generated inventory blocks — regenerated, never
  hand-edited (see Decisions).

## Decisions

- **Claim (c) is stated at the bare relation, with an explicit tie-back.** `permissiveFrame`
  cannot be applied without the `SuccOrder` and `NoMaxOrder` data that discreteness itself
  supplies, so a frame-level "is a task frame iff Discrete" would carry its right-hand side in
  its own hypotheses. `permissiveFrame_taskRel_eq` identifies `permRel` with the frame's own task
  relation, which is what makes the biconditionals statements about the frame.
- **The four-constraint conjunction, not *Limit* alone, is the honest reading** of the paper's
  "is a task frame just in case": the other three constraints hold unconditionally for a
  permissive relation, and saying so takes stating all four.
- **Every arithmetic statement goes through a view definition, never a type ascription.** The
  frame's `WorldState` unifies with the duration carrier at default transparency but does not
  synthesize instances through it; an ascription does not repair it (measured in the research
  round, and the reason the plan forbade ascriptions outright).
- **`change`, not `show`.** The research round's probes compiled under `lake env lean`, which does
  not exercise the house style linters; the library build's `linter.style.show` rejects a `show`
  that changes the goal, so all three such proofs use `change`.
- **`typst/generated/status.typ` is regenerated per Lean commit, not once at the end.** A
  pre-commit gate blocks any commit staging a `.lean` file whose lines the generated whole-tree
  count no longer reflects, so the plan's end-of-task decision gate for that file applies per
  phase. Attribution was verified at each commit by checking the count delta equalled that
  commit's own insertions, and `--no-verify` was never used.

## Plan Deviations

- **Testing & Validation, the `#print axioms` criterion** altered: "reports no choice axiom" is
  unachievable and was mis-derived at plan time. Measured: `translationFrame` itself, and every
  pre-existing declaration naming either canonical frame (`translationHist`,
  `translationFrame_taskRel`, `translation_realizes`, `permissiveHist`), already depends on
  `[propext, Classical.choice, Quot.sound]`. `FrameOver.ofReflectiveRegular` is choice-free, so
  the choice enters through `translationFrame`'s own regularity obligations — inside a definition
  this dispatch forbids changing. The achievable criterion was substituted and met: no new axiom
  **dependency** beyond what the frames already carry, and no `axiom` declaration added (12 under
  `FormalSystem/` before and after, 14 across all source roots, with zero `+axiom` lines in the
  whole task's diff).
- **Phase 2's "naming only this one file"** altered: every Lean commit also stages
  `typst/generated/status.typ`, which the pre-commit counts gate requires (see Decisions).
- **Phase 6's `f1_total_eq_orbit` pointer**: the plan's prose mentioned the docstring that points
  at symptom 2 while its Files-to-modify list scoped the edit to the module header; the header's
  symptom-2 paragraph — what that docstring points at — was amended, and the docstring was left
  alone.

## Verification

- Build: Success. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (full project, unscoped, detached, guard exit captured un-piped) exits 0 over 2848 jobs, with
  zero `error:` lines, zero warnings, and the `.olean` for both touched modules newer than its
  source — all three tiers of the build verdict, not just the success bar. Each of Phases 2-6 also
  closed on a green guarded scoped build of the edited module(s)
- Sorry count: 0 (`lean-sorry-census.sh` over all four resolved source roots; `grep -c sorry` on
  the edited module reports 0)
- Vacuous count: 0 attributable to this task. The single grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, is pre-existing and untouched here
  (`git diff` over the whole task is empty for that file), and is not vacuous in substance — its
  goal is a real proposition about a total history's domain.
- Axiom count: unchanged — 12 under `FormalSystem/` and 14 across all source roots, identical at
  the pre-task baseline (`26a54413b`) and at HEAD; zero `+axiom` lines in the task's diff
- Tests: N/A (no test module in scope; the library build covers every consumer)
- Files verified: Yes

### Gate set at exit, each exit status read directly

The plan's closure criterion was "the failing-check set afterwards is a subset of a baseline
captured at the start of the closing phase", because the gate set was red and moving at plan time.
The stronger criterion holds instead: the gate set is **green at entry and at exit**.

| Gate | Exit | Notes |
|------|------|-------|
| `scripts/check-module-invariants.sh` (build-enabled) | 0 | ALL CHECKS PASSED. By name: C3 structural `sorry` zero; C14 no stale axiom/sorry counts; C15 both assertions (69 anchor citations, 289 theorem-index rows); C16 env_linter batch no un-nolisted finding; C19 refined docstring coverage 90.64% (floor 90%); C23 zero live `lemma`; C24 `Init` reachability; C33 generated root byte-current; C35 citation manifest byte-current |
| `scripts/typst-sync-check.sh` | 0 | PASS, all 4 checks |
| `scripts/readme-lint.sh` | 0 | RESULT: PASS |
| `scripts/check-copyright-headers.sh --strict FormalSystem` | 0 | 0 missing of 682 |
| `.claude/scripts/verify-deploy.sh` | 0 | PASS, 15 checks, 0 failures |

The entry baseline, re-derived before any regeneration, was already green
(`check-module-invariants.sh --no-build` exit 0 at Phase 1) — the sibling whose staged work the
plan measured had committed at `26a54413b` before this dispatch began. Both baseline and exit
states are recorded in `issues.jsonl`.

### Commit hygiene

Eight commits, each through `bash .claude/scripts/git-commit-scoped.sh` with an explicit file
list and no bare `git commit` or directory pathspec anywhere. Two foreign commits (a task-802
creation and a state sync) landed from a concurrent writer during this dispatch; neither is
attributed to this task, and `git log` shows no foreign work under this task's messages.
`FormalSystem/Semantics/Frames/Standard.lean` is untouched for the whole task, as the dispatch
requires: `git diff 26a54413b..HEAD -- FormalSystem/Semantics/Frames/Standard.lean` is empty.

## Impacts

- The paper's canonical-frame lemma is now citable from Lean: the four claims are available to
  every module that already consumes `translationFrame` or `permissiveFrame`, including the two
  duration-level correspondence biconditionals in this same module and the independence modules.
- `isDiscrete_iff_exists_isLeast_pos` supplies the proof step `FrameProperty.lean`'s own
  `IsDiscrete` docstring asks for, and is reusable wherever discreteness has to be fed to
  `duration_dense_or_least_pos`.
- `permRel_not_limit_of_dense` machine-checks a sentence `TaskFrame.limit_of_permissive`'s
  docstring previously asserted only in prose.

## Follow-ups

- **Paper-side, for the author** (a different repository, deliberately not edited here): clear
  the `% PORT:` comment under `lem:canonical-frames` in `JPL/possible_worlds.tex` and close its
  proof with a Lean-proof citation naming
  `FormalSystem.Semantics.Correspondence.DurationFrames`'s new declarations — one per claim:
  `translationFrame_deterministic` (a), `translation_histSet_eq` / `translationHistEquiv` (b),
  `permRel_constraints_iff_isDiscrete` with `permissiveFrame_taskRel_eq` (c), and
  `permissiveFrame_not_deterministic` with `permissiveHistEquiv` (d).
- **Context extension** (recommended by the research round, not performed here): add
  `context/project/lean4/patterns/frame-carrier-transparency.md` recording the frame-carrier
  transparency barrier — argument position works, `+` fails, ascription fails — the view repair,
  and the `WorldHistory.path` precedent. It belongs in the source store under
  `agent-system/extensions/lean/`, not as a drive-by write under a deployed tree.
- The dead-declaration census will list the 23 new declarations, which have no in-tree consumer
  yet. That census is reporting-only; the README row and module-header bullets keep the keystone
  names visible.

## References

- `specs/790_lem_canonical_frames_translation_two_state/plans/01_lem-canonical-frames-characterizations.md`
- `specs/790_lem_canonical_frames_translation_two_state/reports/01_lem-canonical-frames-characterizations.md`
- `specs/790_lem_canonical_frames_translation_two_state/issues.jsonl`
- `specs/790_lem_canonical_frames_translation_two_state/handoffs/` — one handoff per phase
- `docs/reference/paper-definitions-of-record.md` — the two new KNOWN-ANCHORS rows
