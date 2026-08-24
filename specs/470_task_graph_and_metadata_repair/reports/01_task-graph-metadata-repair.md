# Research Report: Task #470

**Task**: 470 - TASK-GRAPH AND TASK-METADATA REPAIR
**Started**: 2026-08-24T00:00:00Z
**Completed**: 2026-08-24T00:00:00Z
**Effort**: Low (mechanical, no mathematics)
**Dependencies**: None
**Sources/Inputs**:
- `specs/state.json` (live), `specs/archive/state.json`
- `scripts/check-module-invariants.sh` (executed live)
- `.claude/scripts/generate-task-order.sh` (executed live, `--print`)
- `.claude/scripts/state-write.sh`, `.claude/scripts/manage-topics.sh`, `.claude/commands/task.md`,
  `.claude/commands/todo.md`, `.claude/scripts/archive-task.sh`
- `specs/257_large_data_storage_huggingface/**`, `specs/282_exhaustive_enumeration_by_default/**`
- `specs/reviews/review-2026-08-24.md` (task-description grounding, not independently re-read line
  by line — the delegation context already quotes its issues verbatim)
**Artifacts**:
- `specs/470_task_graph_and_metadata_repair/reports/01_task-graph-metadata-repair.md` (this report)
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- **(A) still open, confirmed live**: task 421's description still reads "...unchanged at 2
  (verify with: `grep -rn ... | grep -vc Boneyard`)". A live run of
  `scripts/check-module-invariants.sh` confirms check `C3` reports exactly **one** structural
  sorry: `countermodel_discrete` in `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`. This is
  the highest-priority open item.
- **(B) dependency edge applied and topologically confirmed**; the two chains are now one
  connected component (`465`→wave 6, `428`→wave 7, `429`→8, `410`→9, `411`→10, `430`→11). The
  433/434 description-revision half of (B) is **still open** — neither description currently
  mentions 462–465. The new fifth residual `UnorderedSuccessorLabelClosed` is **unassigned**, and
  **468 has NOT run yet** (`status: "not_started"`), so per the task's own instruction this
  assignment belongs to 470, not 468.
- **(C), (D) confirmed applied**: 426 deps = `[470]`, 95 deps = `[169]`, exactly as stated.
- **(E) already resolved — no action needed.** `active_topics` in the live `specs/state.json`
  **already contains** `"repo-hygiene"` (confirmed both by direct `jq`/grep inspection and by
  running `generate-task-order.sh --print` live, which produced **zero** stderr output — no
  undeclared-topic warning). The task's premise ("absent from active_topics") no longer matches
  the live file. Nothing to fix; the report below documents this as a finding, not a defect.
- **(F) still open**: both 257 and 282 have `description: null` in the live `active_projects`
  array. Both have strong recoverable intent from artifacts — reconstructed descriptions are
  proposed below; neither should be abandoned.
- **(G) still open, not yet applied by 468**: 177's `file_scope` in the live file is still
  `["README.md", "ROADMAP.md", "FormalSystem/", "FormalSystem/", "docs/"]` — the duplicate and
  the unresolvable `ROADMAP.md` (root has no such file; it lives at `specs/ROADMAP.md`) are both
  still present. 468 is `not_started`, consistent with the task note that whichever task runs
  second should find it already done — it is not.
- **(H) still open; important finding: `/task --sync` will NOT fix the metadata counters.**
  Grepping every script under `.claude/scripts/` and every command file for `task_counts`,
  `total_tasks`, `last_sync`, or `generated_at` (state.json's **top-level** fields, not to be
  confused with the identically-named field inside per-task `.return-meta.json` files, which is
  a different object entirely) returns **zero hits**. No script — including `/task --sync`'s own
  steps (validate, artifact reconciliation, status reconciliation, TODO.md regen, topic
  backfill) and `/todo`'s `archive-task.sh` — reads or writes these top-level fields. They are
  vestigial. The plan should not rely on `/task --sync` reconciling them; a direct
  `state-write.sh` edit is needed for `metadata.total_tasks`, `metadata.last_sync`,
  `metadata.generated_at`, and every field under `task_counts`. Live actual values (independently
  recomputed by this report, 2026-08-24): 49 total active tasks, status distribution
  `not_started: 31, completed: 7, partial: 5, blocked: 3, planned: 1, researched: 1,
  researching: 1` (task 470 itself is currently `researching`). These differ from the figures
  quoted in the task description (`46 ACTUAL entries`, `not_started: 29`) because time has passed
  since the review was written and this task itself is now mid-flight — the plan/implementer
  should recompute at write time rather than trusting either the review's or this report's
  snapshot verbatim.
- **(I) still open**: 432, 436, 457, 458, 459, 460, 467 all confirmed `status: "completed"` and
  still present in `active_projects`. `archive-task.sh` (invoked by `/todo`) does the move; it
  also does not touch the counters (confirmed by the same grep as H), so H's counter fix is
  independent work regardless of run order — running `/todo` last (as instructed) is still
  correct because it changes which tasks are *counted*, just not via the same code path that
  would fix the stale counter fields.
- **Archive-union dangling-edge check: clean.** All 21 archive-only edges named in the task
  resolve in `specs/archive/state.json`'s union of `archived_projects` (36) and
  `completed_projects` (389). A full scan of every dependency edge in the live
  `active_projects` array against `active_projects ∪ archive` found **zero** dangling edges
  anywhere in the current graph, not just among the 21 named ones.

## Context & Scope

This is a mechanical metadata/graph repair task; the nine defects were already enumerated by the
2026-08-24 programme review and restated in the task description, including an addendum noting
that (B), (C), (D) were already applied directly to `specs/state.json` after the task was
written. This research's job (per the delegation's Research Focus section) was **not** to
re-discover the defects but to establish current live state for each item, gather the exact text
needed for (A)'s fix, confirm the 462–465 ownership claims for (B)'s remaining half, gather
reconstructable intent for (F), confirm 468's run status (gates both the `UnorderedSuccessorLabelClosed`
assignment and whether 177's file_scope fix in (G) is already done), and nail down the exact
mechanics of `state-write.sh`, `/task --sync`, and `/todo` so a plan can specify exact invocations.

## Findings

### (A) — Task 421's acceptance criterion

Current live text (from `specs/state.json`, task 421's `description` field, last sentence):

> "Acceptance: the refuted-route comment (the "(i) a Base-MCS ... (ii) a Henkin-style ..." block)
> no longer appears in `Transfer.lean`; the probe block elaborates; lake build is green; #print
> axioms on any new declaration shows no sorryAx; the live non-Boneyard sorry count is unchanged
> at 2 (verify with: `grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -vc
> Boneyard`)."

Live verification (`bash scripts/check-module-invariants.sh`, run 2026-08-24 during this
research):

```
PASS  C3   sole structural sorry is in theorem countermodel_discrete (FormalSystem/Metalogic/WeakCanonical/Transfer.lean)
            enclosing declaration: theorem countermodel_discrete (A : Set Formula)
```

C3 reports exactly **one** sorry. The task description's fix is correct: change "2" to "1" and
replace the inline `grep`/`Boneyard`-filter clause with a pointer to check C3 of
`scripts/check-module-invariants.sh`. Suggested replacement clause (final sentence of the
acceptance criterion), preserving everything before "the live non-Boneyard sorry count":

> "...the live non-Boneyard sorry count is unchanged at 1 (verify with `scripts/check-module-
> invariants.sh` check C3, which reports the sole structural sorry as `countermodel_discrete` in
> `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`)."

This is a `description`-only edit via `state-write.sh` on task 421 — no dependency, file_scope,
or topic changes needed for this item.

### (B) — 465 → 428 edge and the description-revision half

**Edge**: confirmed already applied. `jq -r '.active_projects[] | select(.project_number==428) |
.dependencies'` returns `[432, 433, 434, 465]`. A live run of `generate-task-order.sh --print`
shows the two former components now as one connected chain across waves 6–11: `465` (wave 6) →
`428` (wave 7) → `429` (wave 8) → `410` (wave 9) → `411` (wave 10) → `430` (wave 11) → (412 in
wave 12). Direction is confirmed correct: 462's own description opens with "This is the plumbing
half of the residual task 434 left open at its Phase 8," 463's description says it decides
"`PostBlockingSettlesRun` ... the narrowed settlement residual task 433 landed," 464 is explicitly
"the density coordinate of the termination measure ... task 434's Phase 8 records the current
state," and 465 is "the terminus restatement family" continuing "Task 433's Phase 6." All four
(462–465) describe themselves as consuming/continuing 433's and 434's open residuals — none reads
as a predecessor gate on 433/434 in the other direction. The `465 → 428` edge direction the task
specifies is correct.

**Description revision (still open)**: neither 433's nor 434's live `description` field mentions
462–465 anywhere (confirmed by full-text read of both). Recommended revision text (to append to
each, not replace — both descriptions still stand as the original discharge specification):

- For 433 (append after the existing "Done means..." sentence): a short pointer such as "This
  task's own residual work — deciding `PostBlockingSettlesRun` at the terminus's own fuel figure,
  and completing the terminus restatement family — has moved downstream to tasks 463 and 465
  respectively; do not re-attempt those here."
- For 434 (append similarly): "This task's own residual work — the engine-level assembly needed
  to make a per-rule payment usable at the successor (462), and the `gapPotential` density
  coordinate for `.Dense`/`.Dedekind` frame classes (464) — has moved downstream to tasks 462 and
  464; do not re-attempt those here."

**Fifth residual, `UnorderedSuccessorLabelClosed`**: confirmed present and unassigned.
`MintBound.lean` defines it at line 6199 ("`def UnorderedSuccessorLabelClosed`"), carries it live
at :6215 in `buildTableauAt_isSome_of_budget_fixed_run`'s hypothesis list (confirmed by grep
matches at :6215, :10051, :10081, :11030, :11048 — it appears as a live hypothesis across the
whole `_fixed`/`_run` restatement family), and is refuted at a specific `L` at :6238
(`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`). A grep across every task description in
`specs/state.json` shows it named only in **task 468**'s own description (the audit/realignment
task) and in **task 470**'s own description (this task, echoing 468's amendment 10e) — no task in
{432, 433, 434, 462, 463, 464, 465} claims it. **468's status is `not_started`** (confirmed live),
so per this task's own instruction ("If 468 has not yet run when you reach this, leave it to 468;
do not create a duplicate owner"), assigning ownership of `UnorderedSuccessorLabelClosed` is
**out of scope for 470** unless 468 runs first. The plan should treat this as: check 468's status
again immediately before touching this residual, and skip the assignment (leaving a note) if 468
is still `not_started`.

### (C), (D) — 426 and 95 dependency edges

Both confirmed already applied exactly as stated: 426 deps = `[470]`; 95 deps = `[169]`. A live
`generate-task-order.sh --print` run places 426 in **wave 2** (blocked only by 470, wave 1) and 95
in **wave 5** (blocked by 169, which itself is gated by `[361, 422, 448]` and lands in wave 4).
This differs from the task's own VERIFICATION section, which predicted "426 and 95 appear in wave
1 and wave 2 respectively" — but that VERIFICATION text was written *before* the addendum's
"ADDITIONAL EDGES APPLIED AT THE SAME TIME" section, which added the `426 <- 470` and other edges
that push 426 one wave later than the original prediction, and 95's wave position follows
transitively from 169's own (pre-existing, untouched) dependency chain. This is not a defect to
fix — it is a stale prediction in the task's own VERIFICATION section, made obsolete by the
addendum edges applied after the prediction was written. Worth flagging in the plan so nobody
mistakes 426-in-wave-2 for a bug.

### (E) — Undeclared topic (already resolved, no action needed)

Live `active_topics` (21 entries, alphabetical) **already includes** `"repo-hygiene"` (confirmed
at line 1461 of `specs/state.json`, and via `jq -r '.active_topics'`). Task 451's `topic` field is
`"repo-hygiene"`, matching. A live run of `bash .claude/scripts/generate-task-order.sh --print`
produced **empty stderr** — no undeclared-topic warning of any kind. `manage-topics.sh validate
repo-hygiene` also exits 0. The task description's premise (topic absent from `active_topics`) no
longer holds; someone applied the "add the topic" side of the fix already (git history shows no
isolated commit for it — it was likely folded into one of the recent `task 231`/`review` commits
that also touched `specs/state.json`, but the exact commit was not identified and is not needed
for the report). **Recommendation for the plan: verify-and-close, not fix.** No `state-write.sh`
call is needed for item E; the plan should state this explicitly so the implementer does not
"retopic 451 to code-quality" against an already-consistent file.

### (F) — Null descriptions on 257 and 282

Both confirmed `description: null` live, `project_name` only, matching the task's claim exactly.
Both have rich recoverable intent from artifacts already on disk — **neither should be proposed
for abandonment**; there is ample recoverable intent for both.

**Task 257** (`large_data_storage_huggingface`, status `blocked`): its report
(`reports/01_large-data-storage.md`) title is "Investigate large data storage alternatives to Git
LFS using Hugging Face" and its plan (`plans/01_implementation-plan.md`) title is "Migrate large
data storage from Git LFS to Hugging Face Hub." Its execution summary
(`summaries/01_execution-summary.md`, status `[PARTIAL]`) records: LFS tracking removed from
`.gitattributes` for 4 dataset files, `.gitignore` updated, `data/README.md` rewritten to name HF
Hub (`logos-labs/bmlogic-bench`) as canonical source — but **Phase 1 (the actual HF Hub upload)
remains pending and requires user authentication**, which is almost certainly why the task sits at
`blocked`. Reconstructed description:

> "Complete the Hugging Face Hub migration for large dataset storage. Prior work (see
> `plans/01_implementation-plan.md`, `summaries/01_execution-summary.md`) removed Git LFS
> tracking from `.gitattributes` and rewrote `data/README.md` to point at HF Hub
> (`logos-labs/bmlogic-bench`) as the canonical source, but Phase 1 — the actual upload to HF Hub
> via the existing `data/hf-dataset/upload.py` pipeline — was never executed because it requires
> user HF authentication. This task is blocked on that credential; once supplied, run the upload,
> validate, and confirm `data/hf-dataset/PUBLISHING.md`'s 'Migration Status' header reflects
> completion."

**Task 282** (`exhaustive_enumeration_by_default`, status `partial`): plan title "Implementation
Plan: Exhaustive Enumeration by Default"; the summary and handoff
(`handoffs/phase-1-6-handoff-20260714.md`) are detailed. Phase 1 (verify 4 already-landed code
items intact) is `[COMPLETED]`; doc-only portions of Phases 4/6 are `[PARTIAL]`; the immediate
next action recorded in the handoff is "Run the c9 feasibility probe (plan Phase 2)," with all
remaining generation-class phases (2, 3, 5, 7) explicitly deferred pending user approval because
they involve multi-hour compute and an HF Hub republication. Reconstructed description:

> "Flip complexity-9 dataset generation from stratified to exhaustive-by-default once feasibility
> is confirmed. Prior work (see `plans/01_exhaustive-enumeration-plan.md`,
> `handoffs/phase-1-6-handoff-20260714.md`) verified the 0-sentinel/`.take`-guard machinery is
> already correct and unlimited-capable, and corrected stale infeasibility claims in
> `data/README.md` and `scripts/run_dataset_generation.sh`. The next action is the deferred c9
> feasibility probe (Plan Phase 2), followed — pending a GO verdict and explicit user approval for
> the multi-hour compute — by c8/c9 exhaustive regeneration and HF Hub republication (Phases 3,
> 4(rest), 5, 6(rest), 7)."

### (G) — Task 177's file_scope

Live value, confirmed unchanged:
`["README.md", "ROADMAP.md", "FormalSystem/", "FormalSystem/", "docs/"]`. `ROADMAP.md` does not
exist at the repository root (`ls ROADMAP.md` → "No such file or directory"); `specs/ROADMAP.md`
does exist (126848 bytes, confirmed). `FormalSystem/` appears twice. Task 468's status is
`not_started` (confirmed live), consistent with the task note ("whichever task runs second must
find it already done") — 468 has not run, so this repair is squarely 470's to make. Target value
per the task's own fix: `["README.md", "specs/ROADMAP.md", "FormalSystem/", "docs/"]`.

### (H) — state.json counter self-disagreement, and the `/task --sync` mechanics

Live `metadata` object: `{"generated_at": "2026-01-20T20:55:08.000000", "total_tasks": 29,
"last_sync": "2026-06-08T03:09:30Z"}`. Live `task_counts` object: `{"active": 44, "not_started":
33, "implementing": 2, "researched": 5, "planned": 3, "partial": 1, "total": 44, "abandoned": 0}`.
Actual live `active_projects` array length: **49**. Actual live status distribution (computed by
grouping the live array): `not_started: 31, completed: 7, partial: 5, blocked: 3, planned: 1,
researched: 1, researching: 1` (this task, 470, is itself `researching` at the moment of this
snapshot — the plan/implementer will see a different live snapshot and should recompute rather
than hardcode either this report's or the original review's numbers).

**Mechanism finding (important for the plan)**: `/task --sync` (`.claude/commands/task.md`'s Sync
Mode) performs exactly these steps: (1) validate JSON, (2) warn on TODO.md orphans, (2.5)
`reconcile-artifacts.sh` backfill, (2.6) `reconcile-task-status.sh` sweep for
researching/planning/implementing/partial tasks stuck behind a crashed session, (3)
`generate-todo.sh` regeneration, (6.5) interactive topic backfill for topicless tasks, (7) git
commit. **None of these steps read or write `metadata.total_tasks`, `metadata.last_sync`,
`metadata.generated_at`, or any `task_counts.*` field.** A repo-wide grep for these four field
names across every script in `.claude/scripts/` and every command file in `.claude/commands/`
returns zero hits outside `specs/TODO.md` itself (a generated view, not a writer) and review/task
documents. `/todo`'s `archive-task.sh` (used for item I) likewise never touches these fields. **The
plan must not assume `/task --sync` reconciles the three counter figures** — it should specify a
direct `state-write.sh` filter setting `metadata.total_tasks`, `metadata.last_sync`, and
`metadata.generated_at` to freshly-computed values (via a `jq` pipeline over `.active_projects`
run at implementation time, not the snapshot recorded here) and rewriting the entire `task_counts`
object to match the live per-status `group_by` distribution, run as its own `state-write.sh` call
either alongside or immediately after invoking `/task --sync` for its other (legitimate) side
effects.

### (I) — Seven completed tasks still in active_projects

Confirmed live: 432, 436, 457, 458, 459, 460, 467 all have `status: "completed"` and are all still
present in `active_projects` (`jq` query returns exactly these 7 project_numbers). `/todo`
(`.claude/commands/todo.md`) scans for `status = "completed"|"abandoned"|"expanded"` and moves
matches via `archive-task.sh` into `specs/archive/state.json`'s `completed_projects`/
`archived_projects` arrays. As noted under (H), `archive-task.sh` does not touch the top-level
counter fields, so running `/todo` will correctly shrink `active_projects` to 42 (49 current live
count minus these 7) but will **not** by itself fix the stale `metadata`/`task_counts` figures —
those need the separate direct edit described under (H). The task's instruction to run `/todo`
**last** (after (B)'s description revisions and (H)'s counter fix) is still the right order,
since it means the final `state-write.sh` counter-correction pass in (H) can be computed once,
against the already-archived (post-`/todo`) tree, rather than needing to run twice.

### Archive-union dependency check

The 21 edges named in the task (`361, 414, 439, 448, 454, 452, 420, 165, 402, 131, 440, 441, 375,
170, 408, 297, 343, 295, 274, 230, 437`) were checked individually against
`specs/archive/state.json`'s `archived_projects` (36 entries) ∪ `completed_projects` (389
entries): **all 21 resolve in the archive.** A supplementary full scan (not requested by name but
useful for the plan's verification step) walked every dependency edge in every live
`active_projects` task against the full union of live `active_projects` project_numbers (49) and
the archive union (425): **zero dangling edges found anywhere in the current graph.** The plan's
verification step ("Zero dependency edges that resolve in NEITHER...") can therefore be satisfied
by the graph as it stands today, aside from whatever edges this task itself adds/removes.

## Decisions

- Item (E) requires **no write** — recommend the plan mark it verify-and-close rather than
  fix-and-write, to avoid an unnecessary/contradictory `state-write.sh` call against an
  already-consistent `active_topics` array.
- Item (H)'s fix must be a **separate, explicit `state-write.sh` call** distinct from invoking
  `/task --sync` — the two are not the same operation, contrary to what a literal reading of "run
  `/task --sync`" might suggest. The plan should say this explicitly.
- The `UnorderedSuccessorLabelClosed` ownership assignment is **conditional on 468's status at
  execution time**: skip it (leave a one-line note) if 468 is still `not_started` when the
  implementer reaches that step; assign it only if 468 has since run and left it unassigned.
- 257 and 282 both have strong recoverable intent; propose neither for abandonment. Reconstructed
  descriptions are provided above, ready to use as the literal `state-write.sh` replacement text
  (subject to the implementer's own final wording pass).

## Risks & Mitigations

- **Risk**: an implementer might try to "fix" item (E) by adding `repo-hygiene` again or retopic
  451, producing a needless diff or a duplicate-add (harmless — `manage-topics.sh add` is
  idempotent — but still wasted work and a misleading commit message). **Mitigation**: the plan
  should state up front that (E) is closed, with the `generate-task-order.sh --print` empty-stderr
  evidence cited above.
- **Risk**: an implementer might assume `/task --sync` fixes the (H) counters and skip the direct
  edit, leaving stale figures. **Mitigation**: the plan must include the direct `state-write.sh`
  counter-correction filter as its own explicit step, run after both `/task --sync` and `/todo`.
- **Risk**: recomputing the (H) figures at plan-write time vs. implementation time will produce
  different numbers than this report's snapshot (49 tasks, 7 completed, etc.) because task 470
  itself transitions status during its own lifecycle and other tasks may complete in the interim.
  **Mitigation**: the plan should specify the counter fix as a live `jq` recomputation command,
  not hardcoded literal numbers.
- **Risk**: touching 433/434 descriptions carelessly could look like it re-litigates their
  math content. **Mitigation**: the suggested append-only revision text above adds a pointer
  sentence without altering the existing "Done means..." specification, matching the task's
  explicit instruction to append clarification rather than rewrite substance.

## Context Extension Recommendations

- **Topic**: state.json top-level `metadata`/`task_counts` field lifecycle.
- **Gap**: no context file documents that these fields are vestigial/unmaintained by current
  automation (`.claude/rules/state-management.md` was not checked in depth by this research, but
  the absence of any consuming script strongly suggests this is undocumented drift rather than an
  intentional design). A future `/meta` task could either wire a maintainer for these fields (so
  `/task --sync` or `/todo` keeps them live) or formally deprecate/remove them from the schema —
  either resolves the "which survive and why" question this task's (H) fix currently has to
  answer manually each time it recurs.
- **Recommendation**: file a follow-up `meta` task (not this task's job to create, per the
  no-task-creation constraint implicit in a research report) proposing one of the two fixes above.

## Appendix

- Commands executed: `bash scripts/check-module-invariants.sh` (C3 check), `bash
  .claude/scripts/generate-task-order.sh --print` (wave computation + stderr check), `jq` queries
  against `specs/state.json` and `specs/archive/state.json`, `bash
  .claude/scripts/manage-topics.sh validate repo-hygiene`, `python3` scripts to compute the
  archive-union dangling-edge check and the full-graph dangling-edge scan.
- Files read in full or substantial part: `specs/state.json` (targeted `jq` queries per task
  number, not a full linear read), `specs/archive/state.json` (structure + counts),
  `.claude/scripts/state-write.sh` (header/contract), `.claude/scripts/manage-topics.sh`
  (header/contract), `.claude/commands/task.md` (Sync Mode section), `.claude/commands/todo.md`
  (archival scan section), `specs/257_large_data_storage_huggingface/{plans,reports,summaries}/*`,
  `specs/282_exhaustive_enumeration_by_default/{plans,summaries,handoffs}/*`.
