# Implementation Summary: Task #884

- **Task**: 884 - Oriented-forest hypothesis strength revision
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T21:20:00Z
- **Completed**: 2026-11-05T22:30:00Z
- **Effort**: ~1 hour (plan estimate: 2.8 hours)
- **Dependencies**: None (task 870 depends on *this* task)
- **Artifacts**: plans/01_oriented-forest-hypothesis-strength.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Restated the oriented-forest Saturation hypothesis, cited by
`specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
section 1.2, at the strength its own step 4 (and the countable-model argument's step B)
actually consumes: acyclicity of the underlying undirected **multigraph**, strictly more than
the section's original directed-path-uniqueness gloss. Verified from compiled signatures, rather
than assumed, that this strengthening costs nothing on the `Saturation` side. Carried the
load-bearing multigraph convention forward to the point where the hypothesis is stated. Revised
task 870's own description so its stated hypothesis matches what its consumer needs. No Lean
file was touched; every edit is in `specs/**`.

## What Changed

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` —
  appended a dated amendment to section 1.2 (purely additive; 0 deletions across all three
  edits), in three parts:
  1. The restated hypothesis (acyclicity of the underlying undirected multigraph of a bare task
     relation's one-step edge relation), why it must be stated over the multigraph and not its
     simplification, and a per-step consumption map (steps 1-3 consume only directed-path
     uniqueness; step 4 consumes undirected acyclicity; step 5 is bookkeeping). No Lean encoding
     chosen — left to task 870.
  2. The Saturation-side verification: two compiled citations
     (`FrameOver.IsRegular` bundling `saturation` at `FormalSystem/Semantics/TaskFrame.lean:1185`/`:1209`;
     `TwoWayBounded.plus_invariance_of_isZTime`'s two `IsRegular` binders at
     `FormalSystem/Semantics/HistoryMorphism.lean:589`/`:590`) and two derived closure findings
     (induced sub-digraphs inherit the strengthened hypothesis; the universal cover already
     delivers it), with the net verdict that the `Saturation` side is unaffected.
  3. The multigraph convention (already present in the construction, carried forward explicitly)
     and its three consequences — no parallel edges, no loops, no directed 2-cycles — naming both
     consumers (step 4's unique sink; task 878's `Walk` predicate).
- `specs/state.json` (870's `description`, `last_updated`) — revised via the
  `state-write.sh` description-update fallback to state the oriented-forest hypothesis at
  multigraph-acyclicity strength and the matching statement instruction, with the rest of 870's
  description (its two unblocked fronts, its independence claims) left intact. `dependencies`
  (`[884]`) and `file_scope` (`["FormalSystem/Semantics/TaskFrame.lean"]`) unchanged.
- `specs/TODO.md` — regenerated from `specs/state.json` (never hand-edited).
- `specs/884_oriented_forest_hypothesis_strength_revision/summaries/01_oriented-forest-hypothesis-strength-summary.md` —
  this file.

## Decisions

- Used the `state-write.sh` description-update fallback (the identical mechanical path
  skill-reviser's own Stage 7 uses) rather than invoking `/revise 870` directly, since this
  dispatch runs as an implementation agent rather than an interactive session able to invoke a
  slash command. Recorded in the issue log.
- Left the Lean encoding of the oriented-forest/acyclicity predicate unchosen, as the plan
  directs; a grep of `FormalSystem/**` confirmed no such predicate exists today, and the choice
  belongs to task 870.

## Plan Deviations

- **Phase 2's contingency task** ("if either compiled check comes out contrary to the
  expectation above, stop...") was not executed: both compiled checks confirmed the expected
  result on the first read, so the contingency condition never triggered. Annotated in the plan
  and recorded in phase 2's progress file `deviations` array.
- **Phase 4's `/revise 870` task** was executed via its own named fallback
  (`state-write.sh`) rather than the slash command itself, as the task's own second bullet
  anticipates for exactly this dispatch shape. Not a deviation from the plan's intent — the
  fallback is named in the plan as equivalent, not a shortcut — but annotated for traceability.

## Verification

- Build: N/A (no Lean file touched; `git status --short FormalSystem/` empty throughout)
- Tests: N/A (record-and-statement task; see Verification section below for the full gate)
- Files verified: Yes — `validate-artifact.sh ... report` passed after each of the three §1.2
  amendment edits (0 warnings); `git diff` showed 0 deletions across all three; the revised 870
  description, `dependencies`, and `file_scope` were confirmed in `specs/state.json`;
  `specs/TODO.md` reflects the revised description.

## Impacts

- A Lean lemma that task 870 eventually proves at the hypothesis now on record (undirected
  multigraph acyclicity) will discharge (H5), on which the L⁺ ZTime decidability theorem is
  conditional. A lemma landing at the previously-stated, weaker hypothesis would not have.
- Task 870's own implementation has one fewer open question: the `Saturation` side is confirmed
  unaffected by the strengthening, so no second obligation needs discharging there.

## Follow-ups

- None. Task 870 (dependent on this task) is unblocked to proceed at the corrected hypothesis
  strength; its own Lean encoding choice and proof remain its work.

## References

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
  section 1.2 (the amended report)
- `specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`
  finding 1 (decision 7), finding 7 ((H5))
- `specs/884_oriented_forest_hypothesis_strength_revision/plans/01_oriented-forest-hypothesis-strength.md`
- `FormalSystem/Semantics/TaskFrame.lean:1185`, `:1209`
- `FormalSystem/Semantics/HistoryMorphism.lean:589`, `:590`
