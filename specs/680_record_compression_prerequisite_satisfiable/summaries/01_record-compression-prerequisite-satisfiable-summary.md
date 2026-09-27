# Implementation Summary: Task #680

- **Task**: 680 - Record compression prerequisite satisfiable
- **Status**: [COMPLETED]
- **Started**: 2026-09-27
- **Completed**: 2026-09-27
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_record-compression-prerequisite-satisfiable.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Documentation-only task. Recorded, on this side, that the consuming (model-checker) repository's
reduction condition (iii) is now satisfiable in principle, together with the correction that must
travel with it: the searched witness-family space is not monotone in the `back`/`mid`/`fwd`
bounds. Corrected the refuted-not-open status of the `IntPresentation` small-model hypothesis
(`fmp`) in `Assembly.lean` and `BiLasso/README.md`, added the durable without-stability-modal
scope sentence to both, and fixed a pre-existing `ValidDiscrete` -> `ValidZTime` rename drift in
`BiLasso/README.md`. All five plan phases completed; no semantics or proof content was touched.

## What Changed

- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — new subsection under "This is
  the soundness half only" recording the cross-repository reduction condition as satisfiable in
  principle, the non-monotonicity correction (exact-modulus folding means a search at bound `n`
  represents exactly the periods dividing `n`), and the divisibility-not-magnitude corollary for
  the compression bound's shape.
- `BimodalTools/README.md` — one sentence added to "Certificate re-verification protocol"
  recording that acceptance is now dual-decided (Python re-checker cross-checked against
  `check_certificate`), plus a refreshed `Last verified` date.
- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` — module docstring: `fmp` in its
  literal candidate-list form corrected from "the one open theorem" to refuted (closed negatively,
  citing `Probe476.fmp_false`), and a new "Scope" section stating the without-stability-modal
  scope by construction.
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — "what decidability still needs"
  section reframed from an open-theorem claim to the refutation, plus the same scope sentence; the
  `ValidDiscrete`/`validDiscrete_iff_check(Family)`/`decidableValidDiscrete(Family)`/
  `not_validDiscrete_of_satAtState` naming drift replaced throughout with the live
  `ValidZTime`/`validZTime_iff_check(Family)`/`decidableValidZTime(Family)`/
  `not_validZTime_of_satAtState` names (own commit, separate from the `fmp`-status correction);
  `Last verified` date refreshed.

## Decisions

- The `ValidDiscrete` -> `ValidZTime` rename drift was scoped in as its own phase and its own
  commit (per the plan), rather than folded into the `fmp`-status correction, so the two distinct
  defects are separately attributable in history.
- `FormalSystem/Metalogic/SoundnessLemmas/README.md`'s own `ValidDiscrete` occurrence was left
  untouched — different directory, different context, correct replacement not established by this
  task's research; recorded as a deliberate exclusion per the plan.
- For `WitnessFamily/README.md`, which a concurrently-dispatched sibling task (681) was editing
  on the same shared tree, the `Last verified`-date commit was staged as a single targeted hunk
  (via `git apply --cached`, then a temporary reverse/forward patch dance around the commit) so
  the sibling's own unstaged Modules-table edit was never swept into this task's commit.

## Plan Deviations

- **Task 4.Scope Hypothesis** altered: the plan's line-number/count estimate (~16 tokens across
  lines 23, 28, 31, 32, 34, 35, 36, 42, 81) no longer matched after Phase 3's own edits shifted
  the file; re-measured at implementation time to 9 tokens across lines 28, 39, 40, 42, 43, 44,
  51, 74, 102. The file set (this file plus `SoundnessLemmas/README.md`, out of scope) matched
  exactly, and zero occurrences were found in any live `.lean` file, as the plan predicted.

## Verification

- Build: Success — `lake build FormalSystem.Metalogic.Decidability.BiLasso.Assembly` exits 0
  (run twice, after Phase 2 and again at Phase 5).
- Tests: N/A (documentation-only task; no test suite targets these files).
- Files verified: Yes.
- `scripts/readme-lint.sh FormalSystem`: overall RESULT: PASS.
- `scripts/check-module-invariants.sh --no-build`: C5, C9, C9D, C13, C20, C32 all PASS. Two
  unrelated failures (a stale generated-inventory block, and C33's missing
  `FormalSystem.SourceLanguage.SentenceTruth` import) were traced via `git status`/`git log` to
  sibling task 679's uncommitted, untracked `FormalSystem/SourceLanguage.lean` and
  `FormalSystem/SourceLanguage/` work on this same shared tree — not attributable to this task's
  four changed files, and not fixed here (out of scope; read-only invocation per the plan).

## Impacts

- Unblocks the quasimodel/ShiftSet decidability task's planning: its own reduction-condition
  prerequisite is now correctly recorded as satisfiable-in-principle-with-a-caveat rather than
  missing, and the caveat (non-monotonicity, divisibility-not-magnitude) is durably available to
  whoever plans the bounded-grid-sweep work the blocking sub-condition still needs.
- Removes a latent risk: `Assembly.lean` and `BiLasso/README.md` no longer invite a reader (or a
  future planner) to attempt proving `fmp` in its literal finite-presentation-list form, which is
  refuted.
- `BiLasso/README.md` now cites the declarations `Assembly.lean` actually defines, so a reader
  following the README's citations lands on real names.

## Follow-ups

- The bounded grid sweep (or the alternative of restricting the claim to bounds the folding
  actually covers) that would make the compression task's reduction condition provable rather
  than merely satisfiable-in-principle is unbuilt; this task deliberately did not build it
  (non-goal).
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` still carries one `ValidDiscrete` occurrence
  (line 16, "the four discrete Prior/z1 lemmas at `ValidDiscrete`"), in a different context whose
  correct replacement name this task's research did not establish; left for a separate task.
- The two `check-module-invariants.sh` failures attributable to sibling task 679's in-flight
  `FormalSystem/SourceLanguage` work are that task's own responsibility to resolve, not this
  task's.

## References

- `specs/680_record_compression_prerequisite_satisfiable/plans/01_record-compression-prerequisite-satisfiable.md`
- `specs/680_record_compression_prerequisite_satisfiable/reports/01_compression-prerequisite-satisfiable.md`
- `specs/680_record_compression_prerequisite_satisfiable/progress/phase-{1,2,3,4,5}-progress.json`
