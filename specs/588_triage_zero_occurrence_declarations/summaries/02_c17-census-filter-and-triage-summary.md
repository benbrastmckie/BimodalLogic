# Implementation Summary: Task #588

- **Task**: 588 - Triage zero-occurrence declarations (C17 census)
- **Status**: [COMPLETED]
- **Started**: 2026-09-17T19:20:21-07:00
- **Completed**: 2026-09-18T00:11:47-07:00
- **Effort**: ~4.9 hours across 11 phases and two agent dispatches (the second a context-exhaustion resume from phase 10)
- **Dependencies**: 591 (Automation export-name consolidation), 594 (in-library smoke-test relocation) -- both landed before the phase 1 baseline
- **Artifacts**: plans/02_c17-census-filter-and-triage.md, dispositions.md, followups.md, tools/c17_triage.py, tools/c17_census.tsv, tools/baseline-harness.txt
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

C17's dead-declaration census reported 1,020 declarations with zero occurrences outside their
own declaring line -- a number large enough to have stopped being informative, and never
triaged. This task made the number mean something: six false-positive filters landed in the
check itself, taking the headline to 771; all 771 survivors were partitioned into six clusters
with a recorded disposition each; and the one unambiguous cluster (80 `def`s with no consumer,
live or archived) was deleted in three verified batches. The final headline is 698, and the
drop reconciles exactly. C17 remains reporting-only and was never gated.

The deliverable is the classification the description asked for, not the deletion. Deleting 80
declarations moved the headline by 73; the filters moved it by 249.

## What Changed

**Script and documentation** (phases 1-6):

- `scripts/check-module-invariants.sh` — C17 rewritten: comment-aware declaration regex (kills
  11 phantom rows matched inside comments); occurrence corpus widened to `typst/**/*.typ` and
  `scripts/*.sh` (12 rows, seven of them the C2/C14 axiom baselines this script itself pins —
  deleting those would have broken the gates); `instance`, `@[simp]`, `register_simp_attr`-set
  and `FormalSystem/Examples/` exclusions; `Boneyard/`-only reported as a sub-count beneath the
  headline rather than folded into it. New `THE COUNTING RULE` and
  `WHAT THIS CHECK STILL CANNOT SEE` header sections. C6 extended with a declaration/line count
  for manifested import-orphan modules. The same comment-aware regex propagated to C19 and C23.
- `docs/development/MODULE_INVARIANTS.md` — C6 row extended; a C17 row written from scratch (it
  had none: the table documented only gating checks).

**Deletions** (phases 8-10): 92 declarations removed across 42 files — 90 `def` and 2
`structure`, no additions of any kind. Largest single removal: the dead
`/-! ## Two-Phase Parallel Enumeration and Pipeline Overlap` section of
`FormalSystem/Automation/FormulaEnumerator.lean` — 4 declarations, 179 lines, removed over two
sub-batches once its entry point turned out to have no consumer.

Per-directory README and root README inventory blocks regenerated after each batch via
`check-module-invariants.sh --emit-inventory`.

**Artifacts**: `dispositions.md` (all 771 survivors, one cluster each, plus a post-execution
outcome section), `followups.md` (eight ready-to-run proposals), `tools/c17_triage.py` (the
census stratifier, which agrees with the in-script C17 exactly).

## Decisions

- **The disputed `release_unfold` reading, resolved explicitly.** `release_unfold` and its nine
  `*_fold`/`*_unfold` siblings in `Automation/Normalization.lean` were the description's
  strongest true-positive signal, and the absorbed task read them as live via
  `@[formula_unfold]`. Both readings were wrong about the mechanism mattering: the filters treat
  a `register_simp_attr` set as a reachability mechanism (tier T3), so all ten are excluded from
  the headline regardless of who consumes the set. A simp set consumed only by its own smoke
  tests is a question for an instrument that reads simp sets, handed off as proposal F4 rather
  than decided by token count.
- **Filters, not gates.** C17 stays reporting-only, with no `ENFORCE_C17` flag added — an unused
  enforcement flag invites a later unreviewed flip, and a textual census with a known
  false-positive rate must never affect the exit code.
- **The corpus was widened and deliberately never narrowed.** Re-measured against the current
  filter set: a code-only corpus reports 1,525 against 771, because 754 declarations are held
  alive by prose alone. A census that calls a documented-but-uncalled declaration dead is less
  actionable, not more.
- **`def`-only deletion scope, held.** Every other kind has an indirect-reachability story a
  token scan cannot see. Two `structure`s were nonetheless deleted, on direct evidence rather
  than on their occurrence count — see Plan Deviations.
- **Boneyard-only means excluded, not deleted.** `freshBase` (14 archived references) was the
  one `def` left standing. "Only consumer is archived" is a C11-waiver decision about the
  archive, not a deletion.

## Plan Deviations

- **Phase 10, "Exclude Boneyard-only-referenced names"** altered: applied to exactly one
  declaration, `freshBase`, which is why the `def` cluster closes at 80 of 81 rather than 81.
- **Phase 10, "After the batch: `lake build`, `lake build BimodalTest`, full harness"** altered:
  the batch did not terminate in one pass. Each deletion removed the only occurrence of further
  declarations, so the census had to be re-run after every sub-batch until it converged. Three
  sub-batches were needed beyond the planned file-by-file pass — 10.15 (four cascade-exposed
  `def`s in `Automation/`), 10.16 (the dead parallel-enumeration section), 10.17 (four
  cascade-exposed `def`s under `Metalogic/`, reopening territory phases 8 and 9 had closed).
  The cluster is closed on the census having converged, not on the original list being
  exhausted.
- **Cluster C disposition departed from for two members**: `ParallelEnumConfig` and
  `LevelComplete` were deleted despite Cluster C's `keep-with-reason`. The rationale for that
  disposition is that a zero-occurrence count on a `structure` is weak evidence; here the
  evidence did not depend on the count — their sole consumer had just been deleted and their
  section header described a subsystem with no remaining members. Recorded in `dispositions.md`
  with the reasoning, and carried into F6 as a precedent so the distinction is available to the
  next effort. The four declarations that newly entered Clusters C and C' were *not* treated
  this way, because for them the direct evidence is absent.
- **Phase 6 widened slightly**: `MODULE_INVARIANTS.md` had no C17 row to update, so one was
  written. Recorded in that phase's notes at the time.

## Verification

- Build: Success — `lake build` exit 0 and `lake build BimodalTest` exit 0 after every deletion
  file and at the end of every batch.
- Full invariant harness: exit 0. Per-check verdict multiset diffed against
  `tools/baseline-harness.txt` and identical, with one intended addition (phase 2's new
  `INFO C6` declaration-count line). C2 and C14 axiom baselines unmoved, C15's 58 citations and
  75 theorem-index rows unbroken, C21's 27 pinned declarations intact, C25's 13 `lean_exe` roots
  all compiling, C28 at 0 warnings.
- Sorry count: 0 (C3 structural sorry inventory ZERO across `FormalSystem/`).
- Vacuous count: 0. No definition was stubbed; every change is a deletion, a filter, or a
  reporting change. Confirmed mechanically: the full diff over `FormalSystem/**/*.lean` since
  the baseline adds **zero** declarations of any kind.
- Axiom count: unchanged at 11 live `axiom` declarations (identical at `c2148141a` and `HEAD`).
- C17 remains reporting-only: no `ENFORCE_C17` exists and C17 never contributes to `FAILURES`.
- `c17_triage.py` and the in-script C17 agree exactly (both print 698).
- Attribution check: no non-588 commit in the range touches `FormalSystem/**/*.lean`, so the
  92-declaration count is attributable entirely to this task.
- Files verified: Yes.

**The line-by-line accounting of C17's drop**, reconciled to zero residue:

| Step | Effect | Headline |
|---|---:|---:|
| Phase 1 baseline (pre-filter) | | **1,020** |
| T0 comment-aware regex (phantom rows) | -11 | 1,009 |
| T1 `instance` (typeclass resolution) | -48 | 961 |
| T2 `@[simp]` (default simp set) | -145 | 816 |
| T3 `register_simp_attr` sets | -12 | 804 |
| T4 widened corpus (`typst/`, `scripts/`) | -12 | 792 |
| T5 `FormalSystem/Examples/` | -21 | **771** (post-filter) |
| Cluster A deletions (80 snapshot `def` survivors) | -80 | 691 |
| Cascade: declarations newly exposed by those deletions | +7 | **698** (final) |

Filter effect -249, deletion effect -73, total -322. Verified by set difference between the
snapshot census and a fresh run: exactly 80 survivor rows gone, every one a `def`; exactly 7
new. Sum checks: 11+48+145+12+12+21 = 249; 1,020-249 = 771; 771-80+7 = 698.

Note the deliberate gap between **92 declarations deleted** and the **73-point headline drop**:
12 of the 92 were themselves cascade-exposed during execution, so they entered and left the
census within this task and appear in neither endpoint. An accounting that does not model the
cascade cannot be made to reconcile, which is why proposal F8 asks for it in the script header.

## Impacts

- C17's headline is now a number worth reading: 698 rows of which 634 are plain unattributed
  theorems with no indirect-reachability story at all — the population that actually needs
  human judgement — rather than 1,020 rows padded with instances, simp lemmas and pedagogical
  examples that were never going to be actionable.
- C19's and C23's denominators moved (C19 now 10,085/10,758 = 93.74% refined, against
  10,212/11,043 = 92.47% at baseline) because they inherited the comment-aware regex. Both
  verdicts are unchanged; only the denominators are more honest.
- Two accepted blind spots are now recorded rather than implicit: excluded `instance` rows may
  hide a genuinely unused instance, and the 145 excluded `@[simp]` rows may hide genuinely
  unused simp lemmas. Both are handed to proposal F4 so neither effort assumes the other covers
  it.
- `FormalSystem/Automation/FormulaEnumerator.lean` lost its parallel-enumeration path entirely.
  Nothing imported it, but anyone looking for it should know it was removed rather than moved.

## Follow-ups

Eight proposals in `specs/588_triage_zero_occurrence_declarations/followups.md`, each with its
evidence and a ready-to-run `/task` line:

- **F1** — retire the 47 Boneyard-only declarations (46 `theorem` + `freshBase`).
- **F2** — triage the 634 remaining `theorem` survivors by file (18 files carry >= 8 rows; 97
  carry 1-2).
- **F3** — decide the BiLasso import-orphan subtree: 75 declarations across 1,348 lines, 84% of
  the import-orphan `FormalSystem` population.
- **F4** — burn down the 145 `@[simp]` and 48 `instance` populations with an instrument that
  reads the simp set and the instance table.
- **F5** — decide the `FiniteTaskModel` abbrev.
- **F6** — audit the 8 `structure` and 2 `inductive` survivors, with the
  `ParallelEnumConfig`/`LevelComplete` precedent recorded.
- **F7** — write the `indirect-reachability.md` agent-context note (placement is genuinely
  ambiguous in this repository and must be resolved first).
- **F8** — record in C17's header that its count is not stable under deletion.

Task creation is a user/orchestrator action and was deliberately not performed here.

## References

- `specs/588_triage_zero_occurrence_declarations/plans/02_c17-census-filter-and-triage.md` — the plan, all 11 phases closed
- `specs/588_triage_zero_occurrence_declarations/dispositions.md` — all 771 survivors, one cluster each, plus the post-execution outcome
- `specs/588_triage_zero_occurrence_declarations/followups.md` — the eight proposals
- `specs/588_triage_zero_occurrence_declarations/reports/01_dead-declaration-triage.md`, `reports/02_c17-zero-occurrence-triage.md` — the research
- `specs/588_triage_zero_occurrence_declarations/tools/baseline-harness.txt` — the phase 1 baseline every verdict was diffed against
- `specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py`, `tools/c17_census.tsv` — the stratifier and its pre-execution snapshot
- `specs/reviews/review-2026-09-16.md`, Finding L1 — the origin
