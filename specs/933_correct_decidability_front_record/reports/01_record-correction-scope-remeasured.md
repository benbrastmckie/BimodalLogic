# Research Report: Task #933

**Task**: 933 - Correct the decidability-front record
**Started**: 2026-11-19T16:52:28Z
**Completed**: 2026-11-19T16:57:00Z
**Effort**: ~1 hour (measurement only; no mathematics, no Lean)
**Dependencies**: None
**Sources/Inputs**: specs/state.json, specs/ROADMAP.md, specs/reviews/review-2026-11-14.md,
  specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md,
  specs/archive/929_idle_run_length_one_forward_slack_discharge/summaries/01_*.md,
  specs/archive/934_depth_zero_reachability_probe/summaries/01_*.md,
  .claude/scripts/update-task-status.sh, git log
**Artifacts**: specs/933_correct_decidability_front_record/reports/01_record-correction-scope-remeasured.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Item (1) (rebuild `roadmap_batches` so no archived task heads a batch) is **already DONE** — a
  `/roadmap` pass (not this task) rebuilt it. Every `task_ids[0]` and every member in the current
  `roadmap_batches` array was cross-checked against `specs/archive/` and none is archived.
- Item (2) (rewrite the stale "Where both fronts now stand" paragraph, `ROADMAP.md:19-44`)
  is **still live and unactioned**. The file still says "Stage 1 has a short dispatchable Lean
  line again" and that Phases 11.16/11.17 "are now enterable — roughly 2.5 hours of work" — both
  false against task 761's plan v13 (`[BLOCKED]`, 30/41 phases closed, **zero enterable**,
  Phases 11.15/11.16/11.17 closed `[COMPLETED]`). The same paragraph also says the depth-0 gate's
  crux "is owned by task 934" in the present tense; 934 has since **completed and archived**, so
  this needs to become a past-tense statement of 934's actual verdict, not just an ownership claim.
- Item (3) is **widened, per `roadmap_batches`' own task-933 entry, beyond what the dispatch's
  AMENDED note states**. The AMENDED note (written the same day as, but before, 934's run) says
  only "check off Stage 0's `I = 1` idle-run checkbox if still unchecked." That checkbox
  (`ROADMAP.md:431`) **is still unchecked** — confirmed by direct read. But task 934 has since
  landed a compiled verdict (SAT at the consumer instantiation, existence evidence only) that
  Stage 0's depth-0-gate bullet (`ROADMAP.md:351-401`) does not yet record — it only records
  934's *ownership*, written before 934 ran. `roadmap_batches`' own current task-933 batch entry
  (dated after 934's archival) says this restatement "belongs to this task."
- Item (4) (write 761's blocker into `state.json` "via `update-task-status.sh`") has a **stale
  literal premise** (761's status is now `partial`, not `blocked`; it has seven declared edges,
  not six, the seventh — 934 — now also discharged/archived) **and names a mechanism that does
  not exist**: `update-task-status.sh` has no flag that sets a free-text `blockers` field (its
  only state-mutating flags are `--file-scope-add`, `--research-questions`, `--hold-reason`,
  `--depends-on-add`). However, the underlying defect the 2026-11-14 review raised — 761's
  `blockers` field is `null` while its actual blocker is prose-only — **is still true today**,
  and is independently fixable by a direct, narrowly-scoped `state.json` write (the same pattern
  already used for tasks 298, 428, 257 and 481, all of which carry free-text `blockers`
  regardless of `status`). `roadmap_batches`' task-933 entry calls item (4) un-redoable "as
  filed"; that is correct about the literal wording but does not foreclose a corrected version of
  the same action.

## Context & Scope

This is the research phase of a `meta` task whose job is record correction only — no mathematics,
no Lean, no Stage 0 ruling. The task's own description carries an "AMENDED 2026-11-14" note at its
top narrowing scope to items (1), (2), (4) plus item (3)'s remaining checkbox, immediately followed
by "ORIGINAL RECORD FOLLOWS" and the four original items verbatim (sourced from
`specs/reviews/review-2026-11-14.md`'s three High findings and one Medium finding).

Separately, and **temporally later** than that AMENDED note (934 ran and completed the same day,
09:32–09:50 UTC, after the ruling that assigned it ownership), `specs/state.json`'s own
`roadmap_batches` array already carries a task-933 batch entry whose rationale re-derives scope
against 934's landed verdict. That entry is itself not a decision authority (`/roadmap` is
explicitly barred from writing `specs/ROADMAP.md` or from running this task), but it is the most
current available restatement of what remains, and it disagrees with the AMENDED note on two
points: it treats item (1) as already fully discharged (consistent with direct measurement below)
and it widens item (3) to include a crux restatement against 934's verdict, not only the checkbox.

This report's job was to measure ground truth for all four items against the live tree rather than
trust either prior restatement, and to reconcile the two where they disagree. No file was edited;
this is the research phase only.

## Findings

### Item (1) — `roadmap_batches` archived-task-heads-batch defect: RESOLVED, not by this task

`jq -r '.roadmap_batches'` over `specs/state.json` lists 21 batches. Cross-checking every
`task_ids[0]` (batch head) and every member against `ls specs/archive/` found **zero** archived
tasks anywhere in the array, as a head or as a member. The `[929,930]` batch the review flagged is
gone; so is a `[934]` batch the task-933 rationale says "headed this list" at some earlier point
and has since been "retired." This was done by one or more independent `/roadmap` passes (visible
in git log as "orchestrate conclusion: roadmap regenerate" commits), not by this task, which has
not yet reached its plan or implement phase. **No action needed for item (1).**

### Item (2) — "Where both fronts now stand" (`ROADMAP.md:19-44`): STILL STALE

Current text, read directly (lines 19-44):

- Line 21: "**Stage 1 has a short dispatchable Lean line again; Stage 2 has none.**"
- Lines 25-27: "761's hold is **LIFTED** ... so Phases 11.16 and 11.17 are now enterable —
  roughly 2.5 hours of work that closes the idle-insertion cascade's record."
- Lines 39-44: "The other two this line used to name are discharged ... and the depth-`0` gate's
  crux is **owned by task 934**." (present tense)

Ground truth, from `specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md`
line 4 (the plan's own `**Status**` line, read directly): `[BLOCKED]` — "30 of 41 phases closed;
**ZERO phases enterable**. ... Phases 11.15, 11.16 and 11.17 closed `[COMPLETED]` ... Every
remaining phase ... sits behind Phase 11.6's depth-`0` gate, which is NOT lifted and which NO OPEN
TASK owns." This matches `ROADMAP.md:213` verbatim (the generated "Run these next" section already
states the corrected fact), so the contradiction the 2026-11-14 review flagged between
`ROADMAP.md:20-26` and `ROADMAP.md:208` **still exists in the file today**, unchanged since the
review. The "~2.5h" figure and "now enterable" claim are both spent — the phases closed, they did
not merely become enterable.

Additionally, `ROADMAP.md:43` ("the depth-`0` gate's crux is owned by task 934") is now stale in a
way the review could not have anticipated (934 did not exist until after the review): task 934 is
`[COMPLETED]` and archived at `specs/archive/934_depth_zero_reachability_probe/`. "Owned by" is an
ownership claim about an *open* task; there is no longer an open task in that role. The rewrite
this item calls for should state 934's **outcome**, not merely retire the ownership clause — see
Item (3) below, since the same sentence is also the crux-restatement site item (3) names.

### Item (3) — Stage 0: checkbox still unchecked; crux restatement widened by 934's landed verdict

Direct read of `ROADMAP.md:431-436` (Stage 0, unchecked items):

```
- [ ] Decide whether the **`I = 1` idle-run sub-regime** is filed. It is the whole distance
      between 924's conditional discharge of `ForwardSlackWitnessed` and an unconditional one, ...
      File neither half without reading 924's report first
```

This is confirmed **still unchecked**. Task 929 (`specs/archive/929_idle_run_length_one_forward_slack_discharge/`)
is `[COMPLETED]` 2026-11-13, and its summary states the outcome precisely: the sub-regime's
discharge was **refuted, not proved** — `forwardSlackWitnessed_refuted_I_one` is FALSE at amount 4
at a state genuinely inhabiting the pending-forever regime, with a compiled bound
(`ceiling_slack_at_consumer_amount`) on how far that refutation reaches (it provably cannot reach
the five depth-0 schemas' own instantiation shape, so all five keep the hypothesis for a positive
reason). Checking the box is a record action; the honest terminal outcome it records is a
refutation with a bounded reach, not a discharge.

Stage 0's depth-0-gate bullet (`ROADMAP.md:351-401`, already `[x]` checked) **predates** 934's run:
its last sentence is "934 decides exactly that, at exactly that instantiation" (future tense,
written 2026-11-14 as part of the ruling that assigned 934 ownership). Task 934 has since
completed (`specs/archive/934_depth_zero_reachability_probe/`, summary read in full) with a
concrete verdict:

1. The consumer-shape instantiation (`(q, c + m·(P+1), n)` at amount `m·(P+1)`) **is satisfiable**
   — compiled, `consumer-shape-witness.lean`, three supporting lemmas.
2. This is **existence evidence only** for the lifting event (`cellLE_zero_const_of_kappa_eq`
   landing sorry-free) — it does not bring that event about, does not discharge
   `ForwardSlackWitnessed` generally, and does not refute `CellLEZeroConstOfKappaEq`.
3. 934's own summary, point 6 and its Follow-ups section, explicitly states: "The roadmap's
   'claimed in neither direction' wording is left as it stands, for the user or a `/roadmap` pass
   to revise" and lists "any rewording of the roadmap's crux line" as an open follow-up.

So the dispatch's AMENDED note (checkbox only) is narrower than what 934's own completed record
asks for, and `roadmap_batches`' current task-933 entry agrees with the wider reading ("item (3) ...
has GROWN since filing ... that restatement belongs to this task"). **Recommendation for the plan
phase**: treat item (3) as two sub-actions — (a) check the box at `ROADMAP.md:431` citing 929's
summary, and (b) restate the crux's status (at `ROADMAP.md:39-44` and/or `:351-401`) from "owned
by task 934" / "decides exactly that" to the landed verdict: satisfiable at the consumer
instantiation, existence evidence only, gate undecided, "claimed in neither direction" wording
explicitly left standing per 934's own summary. Both sub-actions are record-only; neither is the
Stage 0 ruling itself.

### Item (4) — 761's blocker in `state.json`: stale premise, non-existent named mechanism, but a live, independently-fixable defect underneath

Direct read of task 761's current `state.json` record: `status: "partial"` (NOT `"blocked"` as the
dispatch item's literal text assumes), `previous_status: "implementing"`, `blockers: null`,
`hold_reason: null`, `depends_on: null`, `dependencies: [760, 775, 805, 806, 819, 820, 934]` — seven
entries, not the six the dispatch item names (934 was added by a later pass, per plan v13's own
Dependencies line: "Two newly filed sibling tasks, 929 ... and 930 ... are INPUTS ... not gates,"
and the task-933 `roadmap_batches` rationale: "the `934` edge a prior pass added ... now archived
with that task"). All seven are terminal (four archived, two `[COMPLETED]`, 934 archived).

Two independent problems with the dispatch item as literally written:

1. **Stale premise.** 761 is `partial`, not `blocked`, and has seven edges, not six. A literal
   execution against the item's own wording would write against facts that no longer hold.
2. **Non-existent mechanism.** `update-task-status.sh`'s usage line (read in full,
   `.claude/scripts/update-task-status.sh:320`) lists exactly four state-mutating flags:
   `--file-scope-add`, `--research-questions`, `--hold-reason`, `--depends-on-add`. There is no
   flag to set a free-text `blockers` field, and no `blockers`-setting code path exists anywhere
   in the script (confirmed by grep for `blockers` across the file — the only hits are in a
   comment and in `hold_reason` machinery, which is a different field entirely: `hold_reason` /
   `held_at` / `prior_status` are a `[HOLD]`-specific triad, not a general blocker annotation).

Despite both problems, the Medium-priority finding the 2026-11-14 review raised under this item —
"761 ... carries no machine-recorded blocker; tooling that reads `blockers` sees an unexplained
[non-terminal] state" — is **still true today**, unchanged by the status relabel. And it is
independently actionable: four other active tasks already carry a free-text (or array) `blockers`
value regardless of their `status` —

- 298: `status: "partial"`, `blockers`: a prose paragraph (environmental, not a dependency edge)
- 428: `status: "blocked"`, `blockers`: a long prose paragraph
- 257: `status: "blocked"`, `blockers`: a prose paragraph (external credential)
- 481: `status: "blocked"`, `blockers`: an array of two prose strings

298 is the controlling precedent: a `partial`-status task with a populated prose `blockers` field
is an established, unremarkable pattern in this very file, not a mismatch. `roadmap_batches`' own
task-933 rationale states item (4) "cannot be redone as filed — see the preamble for why the graph
can no longer carry it," and the preamble (`ROADMAP.md:213`) explains this in terms of the
*dependency graph specifically* ("no dependency edge can express the blocker and none was invented
to replace it, because no OPEN task owns the gate"). That reasoning is correct about `depends_on`/
`dependencies` — there genuinely is no open task to point an edge at — but `blockers` is a
*separate, independent* free-text field, unconstrained by whether an edge exists, so the
"the graph can no longer carry it" conclusion does not actually reach the `blockers` field at all.

## Recommendations

1. **Item (1)**: no action. Already discharged by independent `/roadmap` passes; re-verified here
   against the live `roadmap_batches` array and `specs/archive/`.
2. **Item (2)**: rewrite `ROADMAP.md:19-44` ("Where both fronts now stand") against task 761's plan
   v13 Status line and against 934's landed verdict. Drop "Stage 1 has a short dispatchable Lean
   line again," the "~2.5 hours" figure, and "are now enterable"; state instead that plan v13 came
   to rest at 30/41 phases closed with zero enterable, naming Phases 11.15/11.16/11.17 as the ones
   that closed under the `hself` ruling. Replace "owned by task 934" (present tense, now stale)
   with 934's actual outcome (satisfiable at the consumer instantiation; existence evidence only;
   gate undecided).
3. **Item (3)**: (a) check `ROADMAP.md:431`'s `I = 1` idle-run box, citing
   `specs/archive/929_idle_run_length_one_forward_slack_discharge/summaries/01_idle-run-one-forward-slack-summary.md`
   and stating the refutation-not-discharge outcome with its bounded reach; (b) restate the Stage
   0 depth-0-gate bullet (or the "Where both fronts" sentence it's duplicated into — pick one
   canonical site to avoid a second drift) to carry 934's landed verdict rather than only its
   ownership assignment, explicitly preserving "claimed in neither direction" as the gate's own
   disposition per 934's own summary point 6 — the Stage 0 *ruling* is not taken either way.
4. **Item (4)**: do not follow the literal instruction to invoke `update-task-status.sh` (it has
   no mechanism for this). Instead, perform a narrowly-scoped direct edit to `specs/state.json`
   setting task 761's `blockers` field (currently `null`) to a corrected prose description: Phase
   11.6's depth-0 gate is owned by no open task; all seven declared edges (760, 775, 805, 806, 819,
   820, 934) are discharged/archived; task 761's own status is `partial` (not `blocked`); cite plan
   v13's Status line and `ROADMAP.md` Stage 0. Use the same append/merge discipline
   `state-management.md` requires for other fields (a targeted `jq` or `Edit` touching only the
   `blockers` key for project 761, not a wholesale rewrite of the record), and verify with
   `git diff --staged` touching nothing else before committing, per `git-staging-scope.md`.

## Decisions

- Treated `roadmap_batches`' own task-933 batch entry as the more current of the two available
  scope statements (it post-dates 934's completion; the dispatch's AMENDED note does not), and
  reconciled rather than discarded the dispatch's narrower item-(3) wording — both are reported
  above so the plan phase can see the disagreement and its resolution rather than just one side.
- Did not attempt to adjudicate whether item (4)'s corrected form is worth doing — that is a small,
  cheap, low-risk record fix with clear precedent (task 298), so it is recommended rather than
  deferred to a user decision; no `user_decision` field is set on `.return-meta.json` because
  nothing here needs the user's preference or an external cost acceptance, only a planning choice
  the plan phase can make from this report's evidence.
- Did not touch `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, even though its own
  crux wording (line ~1283, "stays open and claimed in NEITHER direction") carries the same
  staleness against 934's verdict that `ROADMAP.md`'s Stage 0 does. That file is outside this
  task's declared scope (ROADMAP.md and state.json only); flagged below as a context-extension
  item instead of folded into this task's recommendations.

## Risks & Mitigations

- **Risk**: a plan phase executes item (4) via `update-task-status.sh` as literally instructed,
  discovers no such flag exists, and either fabricates a workaround that touches an unintended
  field (e.g. misusing `--hold-reason`, which writes `hold_reason`/`held_at`/`prior_status`, not
  `blockers`, and would incorrectly force `status` toward `hold`) or gives up on item (4)
  entirely. **Mitigation**: this report names the exact four supported flags and recommends a
  direct, scoped `state.json` edit instead, with the precedent (task 298) cited.
- **Risk**: rewriting `ROADMAP.md:19-44` and the Stage 0 crux bullet independently (items (2) and
  (3)(b)) duplicates the same restatement in two places that can drift apart again, exactly the
  failure mode the 2026-11-14 review caught the first time. **Mitigation**: recommendation 3(b)
  above calls for picking one canonical site; the plan phase should decide which (Stage 0's own
  bullet is the more detailed and more naturally "owns" the crux's exact wording; the "Where both
  fronts" paragraph should then cross-reference it rather than restate it independently).
- **Risk**: a future reader treats this report's item-(4) recommendation as equivalent to "the
  depth-0 gate now has an owner" — it does not; writing `blockers` text records an unowned gate,
  it does not create ownership or an edge. **Mitigation**: the recommended text explicitly says
  "owned by no open task," matching Stage 0's and plan v13's own language.

## Context Extension Recommendations

- **Topic**: `RaySummary/README.md`'s depth-0 crux wording.
- **Gap**: that file (line ~1283) states the same "claimed in neither direction" crux `ROADMAP.md`
  Stage 0 carries, and it is equally stale against 934's landed verdict — not covered by this
  task's scope (ROADMAP.md/state.json only), and not covered by 934's own task either (934's
  summary explicitly says "No file under `FormalSystem/**`... was edited").
- **Recommendation**: a small follow-up record-correction task (or a future `/roadmap`-adjacent
  pass, if such edits to `FormalSystem/**` docstring-level prose are judged safe without a
  mathematics change) to bring that file's crux wording into agreement with `ROADMAP.md`'s, once
  the latter is corrected by this task's plan/implement phases. Not filed here — out of scope.

## Appendix

- Direct reads: `specs/state.json` (`roadmap_batches`, `active_projects[761]`, `active_projects[933]`),
  `specs/ROADMAP.md` lines 1-522 (full top portion through Stage 0), `specs/reviews/review-2026-11-14.md`
  (full), `specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md` (grep for
  Status line, phase counts, dependency note), `specs/archive/929_.../summaries/01_*.md` (full),
  `specs/archive/934_.../summaries/01_*.md` (full), `.claude/scripts/update-task-status.sh` (usage
  line and full `blockers`/`hold_reason` grep).
- Mechanical checks run: `jq` cross-check of every `roadmap_batches` task id (head and member)
  against `ls specs/archive/` (zero archived hits, confirming item (1)); `grep -n blockers
  .claude/scripts/update-task-status.sh` (confirms no settable-blockers flag); `git log --oneline
  -- specs/state.json specs/ROADMAP.md` (confirms recent `/roadmap` regenerate commits exist,
  consistent with item (1)'s independent discharge).
