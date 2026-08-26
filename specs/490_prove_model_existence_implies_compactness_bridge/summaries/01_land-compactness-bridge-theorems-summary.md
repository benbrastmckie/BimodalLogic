# Implementation Summary: Model Existence -> Compactness Bridge

- **Task**: 490 - prove_model_existence_implies_compactness_bridge
- **Status**: [COMPLETED]
- **Started**: 2026-08-26T00:02:00Z
- **Completed**: 2026-08-26T00:40:00Z
- **Effort**: ~0.7 hours wall clock (build-lock contention dominated)
- **Dependencies**: None
- **Artifacts**: plans/01_land-compactness-bridge-theorems.md, reports/01_model-existence-compactness-bridge.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed the two model-existence-to-compactness bridge theorems and reconciled the seven prose
sites in the tree that asserted the implication was unproved future work. Both proofs came from
the research report as complete, machine-verified scripts, so this was a transcription plus
docstring job; both audit to exactly `[propext, Classical.choice, Quot.sound]` and the full
`lake build` is green.

## What Changed

- `FormalSystem/Metalogic/StrongCompleteness.lean` — new subsection
  `/-! ### Model existence implies compactness -/` between `strongCompletenessDense_of_compact`
  and the `FrameClass.Dedekind` section, carrying:
  - `compactBase_of_modelExistence : ModelExistenceBase → CompactBase`
  - `compactDense_of_modelExistenceDense : ModelExistenceDense → CompactDense`
  Both transcribed verbatim from the report (`push Not`, not the deprecated `push_neg`), each
  with a docstring recording the argument, the two definitional mechanics it leans on
  (`Formula.neg` / `TruthAt ⊥`, and `classical` for the `List.filter` step), the import-cycle
  placement reason, and its reduction-not-terminus status. Both added to the file's
  `#print axioms` block.
- `FormalSystem/Metalogic/StrongCompleteness.lean` prose — `## Contents` bullet; the
  "Status of `CompactBase`" enumeration shortened (the **Open** verdict retained, now grounded
  on `ModelExistenceBase`); a separate one-line axiom-audit note that leaves the existing
  "fourteen declarations" count untouched.
- `FormalSystem/Metalogic/SetConsequence.lean` — `ModelExistenceBase` and `ModelExistenceDense`
  docstrings now point at the proved bridges instead of calling the implication future work,
  keeping the "not *here*" import-cycle framing and the open-obligation status of the
  `ModelExistence*` definitions themselves; the stale `StrongCompleteness.lean:147` cross-
  reference replaced with a bare module reference; the `## Downstream` section extended from two
  downstream theorems to four.
- `FormalSystem/Metalogic.lean` — `StrongCompleteness.lean` module-inventory bullet extended.

## Decisions

- Placement is `StrongCompleteness.lean`, not `SetConsequence.lean` as the task brief's literal
  first reading suggested. Both proofs consume `truthAt_foldr_imp`, owned by
  `StrongCompleteness.lean`, which already imports `SetConsequence.lean`; stating them there
  would be an import cycle. The brief's "or a sibling" clause covers this, and it is the same
  constraint that already forced both `strongCompleteness*_of_compact` theorems into that module.
- The bridge theorems were given their own one-line audit note rather than folded into the
  existing "fourteen declarations" paragraph, so the count stays correct.
- `SetConsequence.lean`'s "No compactness result is proved or refuted here" claim was left
  untouched — under the chosen placement it stays literally true, and is itself an argument for
  that placement.
- The optional `StrongCompletenessBase`-from-`ModelExistenceBase` corollary was deliberately not
  added (plan non-goal): the tree keeps the `engine` hypotheses live so compactness stays
  isolated as the whole remaining obligation.

## Plan Deviations

- **Altered** — Phase 2's `Commit Mode: per-substep, grouping by file`. All three files were
  edited and verified by a single guarded `lake build`, landing as one commit. The build guard
  serializes project-wide across the three concurrent sibling dispatches running in this repo,
  and a docstring edit to `SetConsequence.lean` invalidates every downstream `.olean`; per-file
  sub-step builds would have queued two full-tree cascade rebuilds behind sibling builds for no
  added assurance on comment-only changes.
- **Altered** — Phase 3's bare `git diff --stat` against the task base commit was scoped by
  pathspec to the three files, because sibling dispatches committed to other paths in the same
  window. The three-file assertion is confirmed within that scope.
- **Note (not a plan deviation)** — Phase 1's scope hypothesis estimated ~55 added lines; the
  actual is +109. The delta is entirely docstring prose. The hypothesis's substantive claims
  (2 theorems, 1 subsection heading, 2 `#print axioms` lines, 1 file, both names collision-free)
  all held.

## Impacts

- `CompactBase` and `CompactDense` are no longer independent open obligations: each now reduces
  to its `ModelExistence*` sibling. The remaining work on the Base and Dense strong-completeness
  routes is concentrated in the ultraproduct construction, which is separately tasked.
- The downstream task whose description composes "with the ModelExistence -> Compact bridge to
  obtain CompactBase and CompactDense" now has its composition target in the tree.
- `ModelExistenceBase` and `ModelExistenceDense` remain undischarged; nothing here claims
  otherwise, and every touched docstring says so explicitly.

## Follow-ups

- **Cross-dispatch commit contamination (needs a human look).** The Phase 2 commit `24d5e08f8`
  swept in an uncommitted `FormalSystem/Metalogic.lean` hunk belonging to the concurrent task-489
  dispatch — a BL-soundness entry in the "Publication-Ready Results" inventory plus a
  Conservativity-prerequisites sentence. It was staged by file path before that dispatch had
  committed its own work. The hunk was **not** reverted (that would have destroyed live sibling
  work); it is preserved verbatim in history, only under this task's commit message. No action is
  needed to recover the content; the sibling dispatch will simply find that file already clean.
- The ultraproduct / Łoś-lemma work that would discharge `ModelExistenceBase` and
  `ModelExistenceDense` is untouched here and remains the whole of the remaining obligation.

## References

- `specs/490_prove_model_existence_implies_compactness_bridge/plans/01_land-compactness-bridge-theorems.md`
- `specs/490_prove_model_existence_implies_compactness_bridge/reports/01_model-existence-compactness-bridge.md`
- `specs/490_prove_model_existence_implies_compactness_bridge/handoffs/`
- `FormalSystem/Metalogic/StrongCompleteness.lean`
- `FormalSystem/Metalogic/SetConsequence.lean`
- `FormalSystem/Metalogic.lean`
