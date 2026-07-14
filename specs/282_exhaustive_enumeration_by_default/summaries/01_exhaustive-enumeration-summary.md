# Implementation Summary: Exhaustive Enumeration by Default (Partial)

- **Task**: 282 - exhaustive_enumeration_by_default
- **Status**: [PARTIAL] — verify + docs done; generation phases deferred pending user approval
- **Date**: 2026-07-14
- **Session**: sess_1784042369_262c14_282
- **Plan**: specs/282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md

## What Was Done

### Phase 1 [COMPLETED]: Items 1-4 verified intact (source-reading, no build)

All four already-landed code items confirmed present in the current tree. Line numbers drifted
from the research inventory; content is intact:

1. **0-sentinel defaults**: `Theories/Bimodal/Automation/DatasetExport.lean:477`
   (`maxFormulas : Nat := 0`) and `Theories/Bimodal/Automation/FormulaEnumerator.lean:722`
   (`maxFormulas : Nat := 0`, doc: "0 means no limit (truly exhaustive)").
2. **`.take` guards**: `FormulaEnumerator.lean:1705`, `:1855/:1858`, `:1896/:1899`, `:1953`,
   `:2299/:2302` — every cap site gates on `params.maxFormulas == 0` (no-limit path skips
   `.take`).
3. **Script tiers**: `run_c4`..`run_c8` in `scripts/run_dataset_generation.sh` all pass
   `--mode exhaustive` with no `--max-formulas`; c9/c11/c12 remain stratified with caps.
4. **Help text**: `DatasetExport.lean:49` ("default: 0 = no limit"); `:938` prints "unlimited"
   when `maxFormulas == 0`.

**Smoke**: `./scripts/run_dataset_generation.sh --dry-run c8` emits
`--mode exhaustive` with no cap; `--dry-run c9` emits `--mode stratified
--stratified-quotas 8:30000,9:70000 --max-formulas 100000` — the exhaustive-unlimited default
path and the stratified c9 path both behave as documented.

**Build note (actual result)**: a scoped `lake build dataset_generator` was started but was
cancelled externally by the orchestrator before completing (an expensive ~264MB relink deemed
unnecessary and OOM-risky for a verify-only scope). No build was run to completion; items 1-4
are already-committed, unmodified source verified by reading.

### Phases 4+6 (doc-only portions) [PARTIAL]: Documentation realigned

- `data/README.md:26` — stale "exhaustive enumeration becomes infeasible" replaced: c9+ are
  stratified today; exhaustive c9 is believed feasible post-task-274 (~663 formulas/sec) and
  task-283 (enumeration rewrite) but has not been measured or run; the flip is deferred pending
  a feasibility probe. c11/c12 stay stratified regardless.
- `data/README.md:~199-203` — the "Complexity 9 — exhaustive enumeration (est. 30min-2h,
  ~300K-1.8M records)" claim corrected to stratified (2-5 min, ~30K records) with a
  deferred-flip note. This resolves the self-contradiction with the tier table (:20) and note
  (:26), which already said stratified.
- `data/README.md:194` — section intro corrected: c11/c12 need multi-hour background compute;
  stratified c9 takes minutes.
- `scripts/run_dataset_generation.sh:481-486` — the stale "Exhaustive c9 is infeasible (~11M
  formulas at level 9 alone, >12h)" comment replaced with a NOTE that the estimate predates
  tasks 274/283, that exhaustive c9 is feasible-but-not-yet-run, and that the flip is deferred
  pending a feasibility probe (task 282 continuation). `run_c9` behavior unchanged (still
  stratified).

**Note on committability**: `data/` is gitignored (`.gitignore:82`), so the `data/README.md`
edits exist only in the working tree; only `scripts/run_dataset_generation.sh` and the
`specs/282_*` artifacts are committed.

## Deferred (Awaiting User Approval — multi-hour generation/publication)

| Plan Phase | Work |
|------------|------|
| 2 | c9 feasibility probe (extend `EnumBenchmark.lean` gates to c8/c9 or timed probe) |
| 3 | c8 exhaustive regeneration (~60-90 min) — replaces HF `.partial` (147,864 records vs ~500K-1.7M expected) |
| 4 (rest) | Flip/retain `run_c9` mode per probe GO/NO-GO |
| 5 | c9 exhaustive regeneration (conditional on GO) |
| 6 (rest) | `data/hf-dataset/README.md` c8 "(partial)" references (:45,:89,:295) + regenerated counts |
| 7 | HF Hub republication |

Continuation context: specs/282_exhaustive_enumeration_by_default/handoffs/phase-1-6-handoff-20260714.md

## Verification

- No Lean source modified by this task (verify-only + docs); no sorries, vacuous definitions,
  or axioms introduced.
- `lake build` intentionally not run (orchestrator directive; see build note above).
- Dry-run smokes passed as described.
- Doc consistency grep: no remaining "exhaustive c9" claims contradicting the stratified
  `run_c9`; the only ">12h"/"infeasible" text left is the explanatory NOTE quoting the old
  estimate.

## Plan Deviations

- Phase 1 build step altered: build skipped by orchestrator directive; verification via
  source-reading + `--dry-run` smokes.
- Phases 2, 3, 5, 7 deferred wholesale (generation-class work; user approval required).
- Phases 4 and 6 split: doc-only portions done now; generation-dependent portions deferred.

## Files Modified

- `scripts/run_dataset_generation.sh` (comment realignment only; behavior unchanged)
- `data/README.md` (gitignored; working-tree only)
- `specs/282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md`
  (phase markers + deviation annotations)
- `specs/282_exhaustive_enumeration_by_default/handoffs/phase-1-6-handoff-20260714.md` (new)
- `specs/282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md`
  (this file)
