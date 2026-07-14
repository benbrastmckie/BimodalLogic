# Research Report: Task 282 — Exhaustive Enumeration by Default

- **Task**: 282 — `exhaustive_enumeration_by_default`
- **Session**: sess_1784042369_262c14_282
- **Date**: 2026-07-14
- **Status of task record**: `not_started`, no description field in current state.json/TODO.md
- **Dependency**: Task 274 (bottleneck sweep — completed, archived)

## 1. Scope Reconstruction

The current task record carries no description, but the **original description was recovered
from git history**. Commit `78166ff86` ("tasks 282-283: unlimited enumeration default +
explosion analysis", 2026-06-04) contains the full original TODO.md entry:

> ### 282. Make dataset generation script default to exhaustive enumeration without formula cap
>
> **Description**: The dataset generator defaults to `maxFormulas=5000` (in
> DatasetExport.lean:501 and FormulaEnumerator.lean:601), silently truncating exhaustive
> enumeration at higher complexity levels. Change the default behavior so that exhaustive mode
> keeps ALL enumerated formulas unless an explicit `--max-formulas N` flag is passed.
> (1) Change default `maxFormulas` in DatasetExport.lean and FormulaEnumerator.lean to 0 or a
> sentinel value meaning "no limit". (2) Update `FormulaEnumerator.lean:692` to skip the
> `.take` when maxFormulas is 0/unlimited. (3) Update `run_dataset_generation.sh` to remove
> `--max-formulas` from exhaustive tiers (c4-c8) since the default will now be unlimited. Keep
> `--max-formulas` only for stratified tiers (c9+) where it controls the sampling budget.
> (4) Add a `--max-formulas` flag description to the help text clarifying it's optional and
> only caps output for exhaustive mode. (5) Regenerate c4-c8 datasets to verify truly
> exhaustive output.

So "exhaustive enumeration by default" concretely means: **exhaustive sampling mode with an
unlimited (0-sentinel) formula cap as the default behavior of the dataset generator**, plus
regeneration of the production datasets to be truly exhaustive.

## 2. Critical Finding: Items (1)-(4) Were Already Implemented

The same commit that created the task (`78166ff86`) **also implemented items (1)-(4)** of the
description. The commit message states: "Task 282: Changed maxFormulas default from 5000 to 0
(unlimited) in FormulaEnumerator.lean and DatasetExport.lean. All .take calls now check for 0
sentinel. Removed --max-formulas from exhaustive tiers (c4-c8) in run_dataset_generation.sh."
The task status was never advanced from `[NOT STARTED]`, and the description was later
stripped from state.json — which is why the scope appeared ambiguous.

All four code changes are **verified intact in the current tree**:

| Item | Location | Current state |
|------|----------|---------------|
| (1) 0-sentinel default | `Theories/Bimodal/Automation/DatasetExport.lean:477` (`maxFormulas : Nat := 0`); `Theories/Bimodal/Automation/FormulaEnumerator.lean:692` (`maxFormulas : Nat := 0`, doc: "0 means no limit (truly exhaustive). Default 0.") | DONE |
| (2) `.take` skip on 0 | `FormulaEnumerator.lean:1639,1789-1792,1830-1833,1887,2207-2210` — all cap sites guard `if params.maxFormulas == 0 then result else result.take ...` | DONE |
| (3) Script tiers | `scripts/run_dataset_generation.sh` — c4-c8 profiles (`run_c4`..`run_c8`, lines 307-471) pass `--mode exhaustive` with no `--max-formulas`; c8 comment at :448: "No cap (default is unlimited)". Stratified tiers c9/c11/c12 keep `--max-formulas` (lines 490, 530, 563) | DONE |
| (4) Help text | `DatasetExport.lean:49`: `--max-formulas N  Maximum formulas to generate (default: 0 = no limit)`; `:938` prints "unlimited" when 0 | DONE |

The CLI mode default is also already exhaustive: `DatasetExport.lean:479`
(`mode : SamplingMode := .exhaustive`) and help text `:52`
(`--mode MODE  Sampling: exhaustive|random|hybrid (default: exhaustive)`). The separate
*labeling* axis (`--generation-mode`, `DatasetExport.lean:55,518`) also defaults to
`"exhaustive"` — that axis is not part of this task.

## 3. What Remains: Item (5) and the Post-274 c9 Question

### 3.1 Dataset regeneration status (item 5)

| Tier | Script mode | Local data (`data/`) | Status |
|------|-------------|----------------------|--------|
| c4 | exhaustive | `bmlogic-c4.jsonl` + metadata, mtime 2026-06-08, `sampling_mode: "exhaustive"` (806 records) | Regenerated |
| c5 | exhaustive | `bmlogic-c5.jsonl`, mtime 2026-06-08, exhaustive | Regenerated |
| c6 | exhaustive | `bmlogic-c6.jsonl`, mtime 2026-06-08, exhaustive | Regenerated |
| c7 | exhaustive | `bmlogic-c7.jsonl`, mtime 2026-06-08, exhaustive | Regenerated |
| c8 | exhaustive | **No local `bmlogic-c8.jsonl`**; only pre-282 metadata (`bmlogic-c8-clean_metadata.json`, `bmlogic-c8-stratified_metadata.json`, 2026-06-03). HF Hub card (`data/hf-dataset/README.md:45,89`) ships `bmlogic-c8-clean.jsonl.partial` — 147,864 records, explicitly labeled "(partial)" against an expected ~500K-1.7M | **Outstanding** |
| c9 | **stratified** (`run_c9`, script :473-508, quotas `8:30000,9:70000`) | No jsonl; pre-282 metadata only (`bmlogic-c9-sample`, `bmlogic-c9-stratified-100k`) | **Outstanding / mode decision needed** |

Item (5) was interrupted by the **c8 cross-product explosion** discovered during the first
regeneration attempt — that spawned task 283 (`enumeration_explosion_mitigation`, completed
2026-06-04: Array-based accumulation, per-level checkpoint/resume, inline atom-canonicalization
dedup, structural pruning, two-phase parallel enumeration). c4-c7 were regenerated after 283
landed (2026-06-08). c8 exhaustive was never completed (HF has only a `.partial`), and c9
remains stratified.

### 3.2 The stale c9 infeasibility comment

`scripts/run_dataset_generation.sh:483` says: "Exhaustive c9 is infeasible (~11M formulas at
level 9 alone, >12h)". This comment was written in commit `78166ff86` (2026-06-04), i.e.
**before** task 283's enumeration rewrite landed and only one day after task 274's completion.
Task 274's measured results (`specs/archive/274_bimodal_bottleneck_sweep/summaries/01_bottleneck-sweep-summary.md`):

- c9 labeling restored from "infeasible" to **~663 formulas/sec** (14% timeout rate)
- c7 restored to ~613/sec; c5 to ~191/sec
- G/H complexity overhead dropped from 4/4/8/8 to 1/1/1/1 (this **enlarges** each complexity
  level's population — the ~11M level-9 estimate predates the re-costing and needs re-measurement)

At 663/sec, 11M formulas ≈ 4.6h of labeling — long but not ">12h", and 283's checkpoint/resume
plus `--skip-dedup` make a multi-hour background run recoverable. Whether exhaustive c9 is now
practical is a **measurement question**, answerable with `lake exe enum_benchmark`
(`Theories/Bimodal/Automation/EnumBenchmark.lean`, gates currently defined for c5-c7 only) or a
`--dry-run`/timed enumeration probe before committing to a full run.

### 3.3 Documentation inconsistency (must be resolved either way)

`data/README.md:200-201` already advertises c9 as exhaustive:
"# Complexity 9 — exhaustive enumeration (est. 30min-2h, ~300K-1.8M records):
`./scripts/run_dataset_generation.sh c9`" — but `run_c9` actually runs `--mode stratified`
with a 100K cap. Conversely `data/README.md:20,26` describes c9 as stratified. These
contradict each other and the script. Whichever direction the implementation takes, script,
README table (:15-26), and usage text (`run_dataset_generation.sh:686-690`) must be realigned.

## 4. Defensible Interpretation of Remaining Scope

Task 282's implementation should be scoped as:

1. **Verification phase (cheap)**: Confirm items (1)-(4) intact (done in this report; a plan
   phase should just re-verify via `lake build dataset_generator` + `--dry-run` smoke).
2. **c9 feasibility probe**: Time exhaustive enumeration at level 8-9 post-283/post-274
   (enumeration only, then a labeled sample) to replace the stale ~11M/>12h estimate with a
   measured number. `run_dataset_generation.sh --dry-run c9` + a bounded timed run suffice.
3. **Flip `run_c9` to exhaustive by default** if the probe confirms feasibility (the task
   name, the 274 dependency, and README:200 all point this way): drop
   `--mode stratified`/`--stratified-quotas`/`--max-formulas` from `run_c9`
   (script :485-497), update the header (:9), usage text (:687), and stale comment (:483).
   If the probe refutes feasibility, keep stratified and fix README:200 instead — but then
   the flip is deferred, not silently dropped.
4. **Regenerate outstanding exhaustive tiers**: c8 (est. 60-90 min per script header; HF
   currently has only a partial) and c9 (if flipped). c4-c7 need no rework.
5. **Doc realignment**: `data/README.md` tier table and generation section;
   `data/hf-dataset/README.md` if regenerated files are republished.

Item 4 is multi-hour background compute; the plan should treat dataset regeneration and HF
republication as explicitly optional/deferred phases if compute budget is a concern, since the
*default-behavior* changes (items 1-3, 5) are what the task name promises.

## 5. Ambiguity / Blocker Assessment

No hard blocker. The scope ambiguity is resolved by the recovered original description plus
the creation commit showing partial implementation. Residual ambiguities to surface at
planning:

- **A1 (low)**: Whether task 282 should also flip c9 to exhaustive, or only cover the original
  c4-c8 scope. The task's dependency on 274 (which made c9 feasible) and the pre-existing
  README:200 claim argue for including the c9 flip; the original description said "Keep
  `--max-formulas` only for stratified tiers (c9+)". Recommended resolution: include the c9
  flip gated on the feasibility probe (step 2 above), leave c11/c12 stratified.
- **A2 (low)**: Whether full dataset regeneration + HF republication is in scope or a
  follow-up. Recommended: in scope for c8 (explicitly item 5 of the original description),
  optional phase for c9.

## 6. Tactic Survey Results

Not applicable — this task has no Lean proof goals. It is a defaults/config/script/dataset
task touching `EnumParams`/`CLIArgs` structure defaults, a bash script, and documentation.
No sorries are introduced or required; `lake build` is the only Lean verification gate.

## 7. Key File Inventory

- `Theories/Bimodal/Automation/FormulaEnumerator.lean` — enumeration engine; `EnumParams`
  defaults at :685-700; cap sites :1639, :1789-1792, :1830-1833, :1887, :2207-2210;
  stratified enumeration :1612+
- `Theories/Bimodal/Automation/DatasetExport.lean` — CLI (`dataset_generator` exe root per
  `lakefile.lean:38`); `CLIArgs` defaults :475-500; help text :46-57; arg parsing :580
- `scripts/run_dataset_generation.sh` — production profiles; `run_c9` :473-508 (stratified,
  stale comment :483), `run_c8` :439-471, usage :672-710
- `data/README.md` — tier table :15-26 (c9 "stratified"), generation section :193-212
  (c9 "exhaustive" — contradictory)
- `data/hf-dataset/README.md` — c8 partial (:45, :89, :295)
- `specs/archive/274_bimodal_bottleneck_sweep/summaries/01_bottleneck-sweep-summary.md` —
  c9 feasibility metrics (663/sec, 14% timeout)
- `specs/archive/283_enumeration_explosion_mitigation/summaries/01_execution-summary.md` —
  enumeration rewrite (Array, checkpoint/resume, dedup, pruning)
- `Theories/Bimodal/Automation/EnumBenchmark.lean` — feasibility gate harness (c5-c7 gates;
  extend for c8/c9 probe)
