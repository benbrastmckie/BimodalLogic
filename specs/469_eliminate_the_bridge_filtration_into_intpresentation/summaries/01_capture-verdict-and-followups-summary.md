# Implementation Summary: eliminate the bridge: filtration into IntPresentation

- **Task**: 469 - eliminate the bridge: filtration into IntPresentation
- **Status**: [COMPLETED]
- **Started**: 2026-08-24T21:30:00Z
- **Completed**: 2026-08-24T23:55:00Z
- **Effort**: 5.5 hours
- **Dependencies**: 470 (terminal)
- **Artifacts**: plans/01_capture-verdict-and-followups.md, reports/01_eliminate-the-bridge-verdict.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Capture, not discovery. The research dispatch had already answered the re-scoped question — the
rebuilt filtration *can* land in `IntPresentation` directly, so no bridge theorem needs proving —
and had compiled the assembly and the soundness half as evidence. This task moved those findings
out of a report and into the docstrings of the symbols they are about, and created the three
follow-up tasks that carry the work forward. All 6 phases completed. **Zero proofs, statements,
signatures, or imports changed anywhere**: the entire `FormalSystem/**` diff is 283 added lines
across 10 files, with zero deletions.

## What Changed

- **`Validity.lean`** (+21), at `ValidDiscrete`: ℤ instantiates the whole binder bundle with no
  instance work, so the *soundness* direction needs no carrier lemma; only *completeness* does.
- **`IntNormalForm.lean`** (+19): extended (not restated) the existing binder-fit note with what
  buying the right to work over ℤ is worth — `TaskFrame.ofStep` prices the four `def:frame` axioms
  at exactly one obligation, bi-seriality, and that pricing is unavailable to a `D`-polymorphic
  frame.
- **`DurationClassification.lean`** (+25), at `archimedean_of_lub`: this is the Dedekind branch
  only; the successor-based analogue is absent; the two missing inputs
  (`Archimedean D`, an `IsLeast` positive witness) and the `orderIsoIntOfLinearSuccPredArch` wrong
  turn are named.
- **`PeriodicExtension.lean`** (+29), module docstring only: the `Classical.choice` objection is
  scoped to *emitting an evaluable certificate*; it does not bite where the presentation is only
  quantified over. Plus the sharper `Fintype`/`DecidableEq` reason.
- **`FMP/FiniteModel.lean`** (+13): `filteredCharacteristicSet` lands in `Set`, not `Finset`, and
  the surrounding finiteness is `noncomputable` — the space is not data-shaped.
- **`FMP/FMP.lean`** (+24) and **`FMP/README.md`** (+28): both termini are MCS-membership
  statements; zero `TruthAt` across all six files; a semantic FMP is not a refactor of that
  directory. README also gains a correction to its own axiom-re-discharge cost paragraph.
- **`IntPresentation.lean`** (+28): `val : Atom → Fin card → Bool` is a function on an `Infinite`
  type, so presentations cannot be enumerated at a cardinality bound; the formula-indexed
  candidate-list shape sidesteps it. At `toTaskFrame`: bi-seriality is the sole frame obligation.
- **`BiLasso/Check.lean`** (+50) and **`BiLasso/README.md`** (+46): the layer performs no part of
  the finite-model step (its input is already a presentation); the single remaining obligation
  `fmp` is named in the shape the compiled probes established, with `check_correct` as the final
  step; and `instDecidableSatAtState` computes but is not choice-free.
- **Three follow-up tasks created** at 474/475/476, with directories, via `state-write.sh`.

## Decisions

- **Wiring BiLasso was made follow-up task 474 rather than done here.** The report recommends
  wiring "now", but wiring requires editing `Decidability.lean` and
  `scripts/module-invariants-manifest.txt`, neither of which is in this task's declared
  `file_scope`. Honouring the recommendation by silently widening scope was rejected in favour of
  an immediately actionable task with `effort: small` and no dependencies.
- **The three follow-ups were kept sharply separated by classification.** 476 carries an explicit
  prohibition against being re-described as engineering or merged into 474 or 475 — merging is how
  a research problem gets hidden behind an engineering description — plus a literature gate
  (GKWZ 2003, temporal-products chapter) empowered to stop the task with a refutation.
- **Task numbers were allocated live and guarded.** `next_project_number` was read at
  implementation time (474) and the state write asserted it was still 474, so a concurrent creation
  would have failed loudly rather than colliding.
- **Every fact was re-measured before being quoted** (Phase 1). None was carried forward on the
  report's authority. All measurements agreed with the report.

## Plan Deviations

- *(altered)* Phase 3: the plan offered `BiLasso/Check.lean` **and/or** `BiLasso/README.md`; both
  were written, since the module docstring and the directory README serve different readers.
- *(altered)* Phase 5: `active_topics` gained `"semantics"`. The plan specifies `topic: semantics`
  for task 475, but that topic was undeclared and `generate-todo.sh` warns on undeclared topics.
- *(altered)* Phase 5: task 474's `file_scope` also lists
  `FormalSystem/Metalogic/Decidability/BiLasso/`, since landing the probes needs a new module
  inside that directory — the report's own task-A spec omitted it while requiring the work.
- *(altered)* Phase 5: task 474's description says **three** probe files, not two. Phase 1 measured
  three under `evidence/`; the report's §4 says "two" while §4.2 names the third in passing. All
  three compile sorry-free at `[propext, Classical.choice, Quot.sound]`.

## Impacts

- The five load-bearing findings now live at the symbols they are about, so a reader arriving at
  `ValidDiscrete`, `filteredCharacteristicSet`, `IntPresentation`, or `Check.lean` learns which
  direction is free, which is open, and what the named next lemma is without leaving the file.
  This is the failure mode the task exists to undo: a landed, sorry-free asset was invisible to a
  prior audit because the knowledge lived only in a report.
- The decidability cost model is corrected in-tree: over ℤ the frame axioms cost one obligation,
  not the multi-month figure that applies only to `D`-polymorphic frames.
- Two overstatements are now bounded in place: `FMP/` is not a starting point for a semantic FMP,
  and `BiLasso/` covers no part of the finite-model step.
- No behavioural change to any proof. Build, sorry count, axiom count, and unreachable-module set
  are all exactly as found.

## Follow-ups

- **Task 474** — wire the BiLasso decision layer into the live tree. Routine engineering, small,
  no dependencies, immediately actionable. One import plus 15 manifest deletions in the same
  commit, land the three probes, add BiLasso to `ROADMAP.md`.
- **Task 475** — carrier normalization: the successor-Archimedean transfer. Routine engineering
  with one genuine lemma, medium, no dependencies. Independently valuable.
- **Task 476** — the box-faithful small-model theorem. **OPEN MATHEMATICS, multi-month.** Depends
  on 475; must not begin before 474 and 475 land; literature gate runs first.
- **Not repaired here, and not caused here**: `validate-state.sh` reports 13 FAILs, all schema
  drift on fields absent from `state-schema.json`, verified identical at `HEAD:specs/state.json`
  before this task's write. The only condition the new entries participate in is `priority`, which
  12 pre-existing tasks already carry.

## References

- `specs/469_eliminate_the_bridge_filtration_into_intpresentation/plans/01_capture-verdict-and-followups.md`
- `specs/469_eliminate_the_bridge_filtration_into_intpresentation/reports/01_eliminate-the-bridge-verdict.md`
- `specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/soundness-half-probe.lean`
- `specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/decidability-assembly-family-probe.lean`
- `specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/decidability-assembly-probe.lean`

## Verification

- Full `lake build`: **green** — `Build completed successfully (2462 jobs)`, exit 0, zero errors.
- `scripts/check-module-invariants.sh` (full, with build): **ALL CHECKS PASSED**, exit 0 — C1, C2
  (all four flagship axiom sets match baseline), C3, C4, C5, C6, C8, C9, C10, C11.
- Sorry inventory unchanged: exactly one structural sorry, `countermodel_discrete`
  (`WeakCanonical/Transfer.lean`).
- Axiom declarations unchanged: zero at the base commit, zero at HEAD.
- Unreachable-module count unchanged: 37, all manifested; all 35 compile-checked in isolation.
- `git diff` under `FormalSystem/**`: 283 insertions, **0 deletions**; mechanically asserted that no
  added line begins a `theorem`, `def`, `lemma`, `instance`, `structure`, `abbrev`, `import`,
  `noncomputable`, `axiom`, or `sorry`, and that no line was removed.
- Non-goals held: `Decidability.lean`, `scripts/module-invariants-manifest.txt`, `specs/ROADMAP.md`,
  and `Decidability/Verified/` all untouched; `PeriodicExtension.lean`'s single hunk sits inside
  the module docstring (lines 13–86) with its first theorem at line 104.
- `check-task-references.sh`: PASS, 0 unexempted occurrences. `validate-artifact.sh … plan`: PASS.
- All three `evidence/` probes recompiled sorry-free at `[propext, Classical.choice, Quot.sound]`.
- **One transient failure, diagnosed**: the first full invariants run failed C1/C2 on a missing
  `FormalSystem/FormalSystem.olean`. Ten commits from concurrent agents landed mid-run, including a
  Kamp file-move; C7's live-file count moved 448 → 451 across the same window, none of it from this
  task. The re-run passed every check.
