# Implementation Summary: Task #452

- **Task**: 452 - correct_roadmap_sorry_inventory_and_bxcanonical_status
- **Status**: [COMPLETED]
- **Started**: 2026-08-17
- **Completed**: 2026-08-17
- **Effort**: ~3.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_roadmap-sorry-bxcanonical-correction.md, reports/01_roadmap-sorry-bxcanonical-correction.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`specs/ROADMAP.md` asserted, in several independently-drifted places, that the live tree carries
23 (or 19, or 17) sorries and that `FormalSystem/Metalogic/BXCanonical/` is abandoned dead code.
Both claims were inverted: `scripts/check-module-invariants.sh` check C3 verifies exactly **one**
structural sorry in the whole non-Boneyard tree (`countermodel_discrete`, in
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`), and check C2 baselines four flagship
theorems that all live in the `BXCanonical` namespace. All eight phases of the plan executed in
full, correcting every prose section that asserted a sorry count, a dead-code verdict, or a
module status contradicted by a named check, while leaving `## Paper Alignment Programme` and the
status tables untouched. No `.lean` file was touched; nothing was archived; no sorry was closed,
moved, or reclassified.

## What Changed

- `specs/ROADMAP.md` — corrected:
  - `## Overview` completeness-architecture paragraph, `Sorry summary (dead code)` block (relabeled
    HISTORICAL) and its trailing `dd_countermodel` paragraph
  - `## Active Metalogic Paths` intro paragraph
  - `### BXCanonical Path (DEAD CODE — Task 109 Abandoned)` renamed to
    `### Historical: the task-109 BXCanonical abandonment (2026-05-10, superseded)`, with current
    status stated alongside it
  - `## Sorry Inventory` rewritten in full against C3's live output; all four subsections relabeled
    Historical; C2 axiom baseline added
  - `### Module Import Graph` retired (its root aggregator node does not exist in the live tree);
    replaced with a pointer to the real aggregator and to check C7
  - `### Completeness Theorem` Step-4 delegation corrected using `Completeness.lean`'s own module
    docstring
  - `## Canonical Model Construction (BXCanonical)` — dated staleness note added for its
    `File.lean:NNN`-style line citations
  - `## Legacy Code Inventory` — table split into Archived (4 rows) / Still-live (4 rows); adjacent
    stale "4-import" claim corrected to the verified 6-import list
  - `### Dense Completeness`, `### Soundness (sorry-free)`, `### Examples / Pedagogical`,
    `### Boneyard` — all four corrected against live re-verification
  - `## Recommended Priority Order` / `### Critical Path: Single Sorry Chain` — dated staleness
    banner added (content untouched); `Relocate Chronicle` item annotated inline
  - `## Task Cross-Reference` — dated staleness banner added above the table (rows untouched, task
    109's recorded status in `specs/state.json` untouched)
  - Two additional bare `RootScopedChain.lean` references found during the Phase 8 audit (in
    `### Irreflexive semantics and the seriality switch` and the retired Module Import Graph's
    retained historical tree) given explicit archived/past-tense framing
- `specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/progress/phase-{1-8}-progress.json`
  — created, one per phase, carrying the detailed verification trail (no phase-end handoff
  artifacts were needed — the task ran to completion in a single continuous session with no
  context-pressure checkpoint required)

## Ground Truth (verbatim, captured Phase 1, re-confirmed Phase 8)

```
PASS  C2   all four flagship axiom sets match baseline
            'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]

PASS  C3   sole structural sorry is in theorem countermodel_discrete (FormalSystem/Metalogic/WeakCanonical/Transfer.lean)
            enclosing declaration: theorem countermodel_discrete (A : Set Formula)
```

Live BXCanonical inventory: 7 top-level `.lean` files (`CanonicalChain`, `CanonicalModel`,
`CompletenessDedekind`, `Completeness`, `Frame`, `OrderedSeedConsistency`, `TruthLemma`) plus 3
subdirectories (`Chronicle/`, `Filtration/`, `Quasimodel/`) — 20 files total, matching
`FormalSystem/Metalogic.lean`'s own docstring. `FormalSystem/Metalogic/StrongCompleteness.lean`
imports `FormalSystem.Metalogic.BXCanonical.CompletenessDedekind` directly.

## Per-Section Sweep Record

| Section | Verdict | Evidence |
|---|---|---|
| `## Overview` completeness-architecture paragraph | Corrected | C2, `Metalogic.lean` docstring, `StrongCompleteness.lean` import |
| `## Overview` Sorry summary (dead code) block + table | Corrected → Historical | C3 one-sorry count |
| `## Overview` `dd_countermodel` trailing paragraph | Corrected | Both `RootScopedChain.lean` copies confirmed Boneyard-only |
| `## Active Metalogic Paths` intro | Corrected | Same as above |
| `### BXCanonical Path (DEAD CODE)` heading | Corrected → Historical | Renamed, current status stated alongside |
| `## Sorry Inventory` (all 4 subsections) | Corrected → Historical | C3 (generator of record), C2 |
| `### Module Import Graph` | Retired | Root aggregator node does not exist in live tree |
| `### Completeness Theorem` Step 4 | Corrected | `Completeness.lean`'s own module docstring |
| `## Canonical Model Construction` line citations | Dated staleness note | Out of scope to re-verify each range |
| `## Legacy Code Inventory` (8-row table) | Corrected | `find`/`test -f` against live tree and `Boneyard/StrictSemanticsLegacy/`, all 8 rows |
| `### Dense Completeness` | Corrected | C2; `dense_completeness_fc` found archived |
| `### Soundness (sorry-free)` | Corrected | File-existence check; sorry-free claim itself held |
| `### Examples / Pedagogical` | Corrected | `grep`/`ls` against live `FormalSystem/Examples/` |
| `### Boneyard` | Corrected | C3 sorry-shape grep restricted to `FormalSystem/Boneyard`, returns 104 |
| `## Recommended Priority Order` | Banner-only | Dated staleness banner; content untouched |
| `### Sorry Cleanup` item 6 (Relocate Chronicle) | Inline note | One line; item list untouched |
| `## Task Cross-Reference` | Banner-only | Dated staleness banner above table; rows and `specs/state.json` untouched |
| `## Dead Ends (Archived)` | No edit needed | Parent section already self-labeled historical |
| `## Overview` line-271 HISTORICAL block | No edit needed | Already correctly labeled; confirmed untouched by diff |
| `## Paper Alignment Programme` | No edit needed (explicit non-goal) | Confirmed zero diff hunks in its line range |
| 111-row status tables | No edit needed (explicit non-goal) | Same region as above; confirmed untouched |
| `### FMP Truth Preservation` | No edit needed | Re-verified, zero-sorry claim held |

## Research-Report and Planning-Time Corrections (from the plan's Research Integration)

- **C5 does not cover `specs/ROADMAP.md`**: `check-module-invariants.sh` check C5 excludes
  `specs/` from its directory walk and matches only dotted `FormalSystem.X.Y` names, never
  slash-shaped paths. C5 therefore passes identically before and after every edit in this task and
  was never evidence that this task's introduced references resolve. Phase 1 stood up a bespoke,
  ad-hoc ROADMAP-scoped reference check in its place, re-run at every phase gate and again in
  Phase 8 over the full cumulative diff.
- **The 2026-07-27 sorry-count table was not covered by the line-271 `HISTORICAL` label**: the
  research report treated the table at (original) ROADMAP.md:298-306 as already historically
  labeled. It was not — a new, unlabeled `**Sorry summary (dead code)**` block opens at (original)
  line 296, and the table sits under that block, not the line-271 one. Corrected in Phase 2/3 by
  relabeling that block and table explicitly Historical.
- **Two additional, planning-time-discovered defects**, not in the research report's catalog, both
  confirmed in Phase 1 and corrected in Phase 6: `### Examples / Pedagogical (~57 sorries)` — zero
  actual sorries in `FormalSystem/Examples/`, and none of the four named files exists; and
  `### Boneyard (~14 sorries)` — the C3 sorry-shape grep restricted to `FormalSystem/Boneyard`
  returns 104, not ~14.

## Decisions

- **Retired rather than rebuilt** `### Module Import Graph`: its claimed root aggregator
  (`Metalogic/BXCanonical/BXCanonical.lean`) does not exist — the real sibling aggregator is
  `FormalSystem/Metalogic/BXCanonical.lean`, whose actual import list already differs materially
  from the old tree (imports `CompletenessDedekind.lean` and five `Chronicle/*.lean` files never
  mentioned; does not import `RootScopedChain.lean` at all). Hand-rebuilding an equally detailed
  tree would risk introducing the same class of silently-drifting claim this task exists to fix.
- **Relabeled rather than deleted** most stale content, per the plan's "self-superseding" and
  "banner-only" conventions — the original assessments remain visible as dated historical record,
  with the current state stated alongside.
- **Corrected two claims beyond the plan's declared per-phase text** where re-verification
  revealed the plan's own hypothesis was itself wrong: `FormalSystem/Metalogic.lean` has 6
  top-level imports, not the 4 named in Phase 4/5's task text (verified via `grep '^import'`); the
  `### Soundness (sorry-free)` entry's file-existence claim (`DenseSoundness.lean`/
  `DiscreteSoundness.lean` as live siblings) was contradicted — both are archived to
  `Boneyard/SoundnessVariants/`.

## Plan Deviations

- **Task 4.3** altered: the plan's own hypothesis for `FormalSystem/Metalogic.lean`'s top-level
  imports (`Soundness, Decidability, BXCanonical, WeakCanonical` — 4) was wrong; the live file has
  6 (`Soundness, StrongCompleteness, Decidability, Independence, BXCanonical, WeakCanonical`).
  Wrote the verified list instead of the plan's hypothesis.
- **Task 6.4** altered: `### FMP Truth Preservation`'s zero-sorry claim held and was left
  untouched as the plan expected, but `### Soundness (sorry-free)`'s file-existence claim was
  contradicted (not anticipated by the plan) — `DenseSoundness.lean`/`DiscreteSoundness.lean` are
  archived, not live. Corrected.
- Two additional bare `RootScopedChain.lean` mentions were found and given explicit
  archived/past-tense framing during the Phase 8 self-audit (not individually enumerated in any
  phase's declared task list, but caught by Phase 8's unconditional
  `grep -n "RootScopedChain" specs/ROADMAP.md` verification requirement).

## Verification

- Build: N/A (markdown-only task; `lake build` re-run as part of the full check harness for
  no-regression purposes — see below)
- Full `check-module-invariants.sh` (Phase 8, with build): **all ten check groups PASS** —
  B0, C1 (both `lake build` and `lake build BimodalTest`), C2, C3, C4, C5, C6, C8, C9, C10. This is
  strictly *at or above* the Phase 1 baseline, which had C1, C6, and C9 failing for reasons
  entirely unrelated to this task (a concurrent, unrelated session fixed those in parallel over
  the course of this task's execution — see "Impacts" below). C3 still reports exactly one
  structural sorry in `countermodel_discrete`; C2 still matches the four-theorem baseline.
  **C5's PASS is not evidence about `specs/ROADMAP.md`** — C5 excludes `specs/` from its walk and
  matches only dotted module names, confirmed by direct inspection of the check script in Phase 1.
- ROADMAP reference check over the full cumulative diff
  (`git diff 902135c0b -- specs/ROADMAP.md`): **zero unresolved** `FormalSystem/...` slash paths
  and zero unresolved dotted `FormalSystem.X.Y` module names among all lines added by this task.
- `grep -n "RootScopedChain" specs/ROADMAP.md`: every hit carries either a `Boneyard/` path
  segment, explicit "archived"/past-tense framing, or sits inside a section whose parent heading
  is already self-labeled historical (`## Dead Ends (Archived)`) or newly labeled historical by
  this task's own edits.
- `git diff --stat` against the pre-task baseline: only `specs/ROADMAP.md` plus this task's own
  `specs/452_.../` artifacts changed (`specs/state.json`/`specs/TODO.md` diffs are limited to this
  task's own `[PLANNED]` → `[IMPLEMENTING]` transition; no other task's status, and specifically
  not task 109's, was touched). Zero `.lean` files modified; zero `Boneyard/` moves.
- `git diff -- specs/ROADMAP.md` (full cumulative, against `902135c0b`): confirmed **no hunk**
  touches `## Paper Alignment Programme` (original lines 1599-1680), the surrounding status-table
  region, or `## Dead Ends (Archived)` (original lines 1078-1438) beyond the Phase 7 no-op
  confirmation.
- Files verified: Yes — every new/modified file exists and is non-empty.

## Impacts

- `specs/ROADMAP.md` is now internally consistent with `scripts/check-module-invariants.sh`'s live
  output for every sorry-count, dead-code, and module-status claim it makes, with a generator of
  record (`check-module-invariants.sh` C3) named for `## Sorry Inventory` so the section is less
  likely to silently rot again.
- No downstream code, build, or task-tracking artifact is affected — this is a documentation-only
  correction.
- Noted for the record, not caused by this task: over the course of this task's eight phases, a
  concurrent session (working task 453, `restore_bimodaltest_green_and_clear_c6_c9`) independently
  brought C1/C6/C9 to green. The Phase 1 baseline (captured before that work landed) shows C1/C6/C9
  failing; the Phase 8 final run shows all ten groups passing. This task's own edits caused none of
  that change and introduced no new failure on any check at any phase gate.

## Follow-ups

- **Recommended new task**: rewrite `## Recommended Priority Order` and `## Task Cross-Reference`
  for real (this task only banner-marked them as stale). This crosses into `specs/state.json`
  task-status territory — in particular, whether task 109's recorded status is still correct given
  `BXCanonical` is now the live flagship path rather than dead code. Also fold in the C6 manifest
  finding below.
- **C6 manifest gap** (surfaced, not fixed, per this task's ROADMAP.md-only charter): check C6
  flags `Algebraic.LindenbaumQuotient` and `Algebraic.InteriorOperators` (2 of 7 total C6-flagged
  unreachable-live modules) as absent from `scripts/module-invariants-manifest.txt`. A manifest
  update is outside this task's scope.
- **Optional, recommended not executed**: a short `.claude/` context note recording ROADMAP.md's
  self-superseding "Current-state block" convention, so future large-section rewrites follow it
  from the start. This belongs in `agent-system/extensions/**`, outside a markdown-task charter
  for `specs/ROADMAP.md` itself.

## References

- `specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/plans/01_roadmap-sorry-bxcanonical-correction.md`
- `specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/reports/01_roadmap-sorry-bxcanonical-correction.md`
- `specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/progress/phase-1-progress.json` through `phase-8-progress.json`
- `scripts/check-module-invariants.sh`
