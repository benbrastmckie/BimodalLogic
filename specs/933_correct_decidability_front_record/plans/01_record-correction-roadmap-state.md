# Implementation Plan: Task #933

- **Task**: 933 - Correct the decidability-front record
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/933_correct_decidability_front_record/reports/01_record-correction-scope-remeasured.md
- **Artifacts**: plans/01_record-correction-roadmap-state.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Record-only correction of two files, `specs/ROADMAP.md` and `specs/state.json`. Three live
defects remain of the four originally filed: the governing "Where both fronts now stand"
paragraph asserts a dispatchable Lean line and a ~2.5-hour figure that task 761's plan v13
spent; Stage 0's `I = 1` idle-run checkbox is still unchecked although the task it names (929)
completed and archived; and Stage 0's depth-`0` crux bullet closes on a future-tense sentence
("934 decides exactly that") although 934 completed, archived, and returned a compiled verdict.
Task 761's `blockers` field is absent while its actual blocker exists only in prose. No
mathematics is touched, no Lean file is read or written, and no Stage 0 ruling is taken: the one
Stage 0 checkbox this plan checks is authorized by the task description's own item (3), and the
depth-`0` gate's disposition is left explicitly with the user.

### Research Integration

The research report re-measured all four filed items and is adopted in full, with four
refinements this plan re-derived at authoring time:

1. **Item (1) is discharged** — re-confirmed here: every `task_ids[0]` and every member of all
   21 `roadmap_batches` entries was cross-checked against `specs/archive/`; zero archived ids
   appear anywhere in the array. Item (1) becomes a Non-Goal, not a phase.
2. **Item (4)'s field is ABSENT, not null.** The report records 761's `blockers` as `null`; that
   is `jq`'s rendering of a missing key. `jq 'has("blockers")'` on 761's record returns `false`,
   and `grep -c '"blockers": null' specs/state.json` returns `0`. The edit therefore ADDS a key
   rather than replacing a value, which changes the edit anchor (see Phase 1).
3. **`blockers` is canonically an ARRAY of strings**, not the bare string the report's cited
   precedent (task 298) carries. `context/schemas/state-schema.json` declares
   `{"type": "array", "items": {"type": "string"}}`, and `state-management-schema.md:161` names
   the scalar form legacy and normalized away by `migrate-state-legacy-fields.sh`. Task 481 is
   the correct precedent, not 298.
4. **Item (3)'s widening is adopted.** The report's recommendation 3(b) (restate the crux
   against 934's landed verdict, at one canonical site) is taken, with Stage 0's own bullet as
   the canonical site and the "Where both fronts" paragraph cross-referencing it.

### Carried-Figure Re-Derivation

The dispatch flagged one description line for re-checking. Every figure in it, plus every
figure this plan carries from the research report, was re-derived against the live tree at
plan-authoring time. Results, stated even where they only confirm the description:

| Carried claim | Source | Re-derived verdict |
|---|---|---|
| ROADMAP.md states "Stage 1 has a short dispatchable Lean line again" | description item (2) | **CONFIRMED UNCHANGED** — `specs/ROADMAP.md:21`, verbatim |
| ROADMAP.md states Phases 11.16/11.17 "are now enterable -- roughly 2.5 hours" | description item (2) | **CONFIRMED UNCHANGED** — `specs/ROADMAP.md:25-27`, verbatim; a second occurrence of the same spent figure sits at `:353` inside Stage 0's depth-`0` bullet |
| Paragraph located at ROADMAP.md:20-26 | description item (2) | **CORRECTED**: the `## Where both fronts now stand` section spans `:19-44`. The stale claims are at `:21` and `:25-27`; the stale ownership clause is at `:43` |
| Plan v13: 30 of 41 phases closed, ZERO enterable, 11.15/11.16/11.17 `[COMPLETED]` | description item (2) | **CONFIRMED** — `plans/13_depth-zero-gate-rest-state.md:4`, verbatim, plan-level Status `[BLOCKED]` |
| ROADMAP.md:208 records the corrected fact | description item (2) | **CORRECTED to `:213`** — the generated `## Run these next` section's own preamble now carries it; `:208` is inside `## Rulings in force` |
| `I = 1` idle-run Stage 0 item still unchecked | description item (3) | **CONFIRMED** — `specs/ROADMAP.md:431`, `- [ ]`; one of exactly four unchecked Stage 0 items (`:402`, `:403`, `:406`, `:431`) |
| 761 status `blocked`, six declared edges | description item (4) | **BOTH STALE** — status is `partial` (`previous_status: implementing`); `dependencies` holds seven ids (760, 775, 805, 806, 819, 820, 934), all terminal. Plan v13's own "all six discharged" line is correct for its own authoring date; the 934 edge was added later |
| `update-task-status.sh` can write `blockers` | description item (4) | **REFUTED** — `grep -n blockers .claude/scripts/update-task-status.sh` returns zero hits; the four state-mutating flags are `--file-scope-add`, `--research-questions`, `--hold-reason`, `--depends-on-add` |
| roadmap_batches carries a `[929,930]` batch / an archived head | description item (1) | **REFUTED (defect discharged)** — 21 batches, zero archived ids as head or member |

**One figure is NEW at plan-authoring time and is not in the research report.**
`bash .claude/scripts/validate-state.sh` now emits three Check 13 warnings:
`roadmap_batches[0]` names members 937, 829 and 938, each already terminal. These are
completed-but-not-yet-archived, so they are invisible to the report's archive-directory
cross-check and do not falsify item (1) as literally filed — but they are a live recurrence of
the same defect class, in `/roadmap`'s own owned surface. Handled as a recorded residue and a
Non-Goal, not absorbed (see Non-Goals).

### Prior Plan Reference

No prior plan. This is the task's first plan round.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch, so no roadmap phases are added. The roadmap
was nevertheless read as this task's own subject matter: `specs/state.json`'s `roadmap_batches`
places task 933 alone on the second line of `## Run these next`, immediately behind the
repo-health batch, on the stated ground that "every judgment below here is read through a record
that currently misstates both fronts".

## Goals & Non-Goals

**Goals**:

- Rewrite `specs/ROADMAP.md`'s `## Where both fronts now stand` section against plan v13's rest
  state and 934's landed verdict, so it no longer contradicts the generated `## Run these next`
  preamble it sits above (item 2).
- Check off Stage 0's `I = 1` idle-run item at `specs/ROADMAP.md:431`, citing 929's summary and
  recording its honest outcome — a refutation with a compiled bound on its reach, not a
  discharge (item 3a).
- Restate Stage 0's depth-`0` crux bullet so it carries 934's landed verdict instead of its
  pre-run ownership assignment, at one canonical site, with the gate's disposition left
  explicitly to the user (item 3b).
- Add a `blockers` array to task 761's `specs/state.json` record naming Phase 11.6's depth-`0`
  gate, owned by no open task, so tooling that reads `blockers` no longer sees an unexplained
  non-terminal state (item 4, corrected mechanism).

**Non-Goals**:

- **Rebuilding `roadmap_batches` (item 1).** Already discharged; re-verified at authoring time.
  The three Check 13 terminal-member warnings (937, 829, 938 in `roadmap_batches[0]`) are a live
  residue in `/roadmap`'s own owned surface — `roadmap-agent` decides batch membership, order,
  descriptions and rationale, and this task's `meta` implementation agent must not exercise that
  judgment. Phase 4 records the measurement; it does not fix it.
- **`specs/ROADMAP.md`'s `## Next batches` section (`:279`+).** The generated preamble at `:277`
  states that this authored-prose section "has gone stale against the live graph: it still names
  an archived task, still describes 761's hold as newly lifted, and still lists the L^▷ lines
  individually. Its correction is owned by no task on this list." Not in this task's filed items;
  flagged as a follow-up, not absorbed.
- **`FormalSystem/Metalogic/Decidability/RaySummary/README.md`.** Carries the same crux wording
  with the same staleness. Explicitly outside this task's scope (ROADMAP.md and state.json
  only), and outside 934's too. Flagged as a follow-up by the research report; not touched here.
- **Taking the depth-`0` gate ruling, or ruling on requirement (S)'s residue or ownership.**
  Both are reserved to the user by Stage 0's own header ("no agent may transition these").
- **Using `update-task-status.sh` for item (4).** No flag writes `blockers`; `--hold-reason`
  writes a different field triad and would push the status toward `hold`.
- **Any edit under `.claude/**`, `FormalSystem/**`, or any Lean file.** Zero compile surface is
  touched by this plan.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A hand edit lands in a `specs/ROADMAP.md` region the next regeneration overwrites, so the correction silently evaporates | H | L | `roadmap-integration.sh`'s stage-layout mode retains every `## ` section byte-for-byte **except** the one holding the fenced `/orchestrate` block (`## Run these next`). Both edit targets are retained sections. Phases 2 and 3 each verify with `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run`, whose baseline today is `layout=stage, no content change` with `retained=13`; any drift in layout, retained count, or a non-empty diff is a failed phase |
| `scripts/verify-touched.sh` cannot run in this repository, so a Tier Justification naming it would name a dead command | M | — | **Measured at authoring time, not predicted**: `verify-touched.sh specs/ROADMAP.md` prints `FINDING preflight verify-touched.sh could not run: .claude/scripts/tests/suite-selection-map.data line 37: names 'test-verification-scope-lib.sh', which does not exist`. Every non-final phase therefore names a direct, working, exit-status-checkable entry point instead; recorded in the issue log |
| A `jq`-based rewrite of `specs/state.json` reflows every record's formatting and can mangle the 24 lines holding non-ASCII characters | H | M | Phase 1 uses `Edit` with a unique three-line anchor inside 761's own record. No `jq` write, no Python `json.dump`, no whole-file rewrite |
| Writing 761's `blockers` is read by a later reader as the depth-`0` gate having acquired an owner | M | M | The text says "owned by NO open task", matching plan v13's and Stage 0's own language, and names the gate's disposition as a Stage 0 user ruling |
| Items (2) and (3b) restate the same crux in two places, which drift apart again — the exact failure the 2026-11-14 review caught | M | M | Stage 0's bullet is the single canonical site (it already owns the crux's detailed wording). Phase 3's paragraph cross-references Stage 0 rather than restating the verdict independently; Phase 3 depends on Phase 2 so the canonical text exists before the reference is written |
| Phase 2's Stage 0 edits overreach into a user-reserved ruling | H | L | Phase 2 checks exactly ONE box, authorized by the task description's own item (3), and that box records a fact already settled by a completed task rather than taking a decision. The other three unchecked Stage 0 items (`:402`, `:403`, `:406`) are named as untouchable in the phase's own task list, and the depth-`0` bullet's restatement preserves its `[x]` state and its "the disposition stays with the user" clause verbatim |
| The deployed `.claude/` tree is STALE for the `core` and `sapience` extensions, so a documented script behavior may be out of date | L | M | No phase writes under `.claude/**`, so the source-store/deploy boundary is not engaged. Every script this plan names was RUN at authoring time against this deployed tree and its actual observed behavior recorded, rather than trusted from its documentation |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files
(`specs/state.json` and `specs/ROADMAP.md`). Phase 4 depends on 1 and 3, and transitively on 2
through 3, so it observes every edit this plan makes.

---

### Phase 1: Write 761's Actual Blocker Into state.json [COMPLETED]

**Goal**: Task 761's `specs/state.json` record carries a machine-readable `blockers` array
naming Phase 11.6's depth-`0` gate and the fact that no open task owns it, so a reader or a
tool no longer sees a non-terminal task with no recorded reason.

**Tasks**:

- [x] Re-confirm the anchor before editing: `jq '.active_projects[] | select(.project_number==761) | has("blockers")'` returns `false`, and `.status` is `"partial"`. If either has changed, stop and re-derive — the edit shape below assumes an absent key on a `partial` record. *(completed: re-confirmed, `false`/`"partial"` as expected)*
- [x] Add a `blockers` key to 761's record using `Edit` with this exact three-line `old_string` (verified unique at authoring time), inserting the new key after the `status` line:

      ```
            "project_number": 761,
            "project_name": "ladder_realization_theorem",
            "status": "partial",
      ```

      *(completed)*

- [x] Write the value as a JSON **array of one string** (canonical shape per `context/schemas/state-schema.json`; task 481 is the in-file precedent), stating all four facts and no more: (a) every remaining phase of plan v13 sits behind Phase 11.6's depth-`0` gate; (b) that gate is owned by NO open task and its disposition is a Stage 0 user ruling; (c) all seven declared edges (760, 775, 805, 806, 819, 820, 934) are discharged or archived, so no dependency edge can express the blocker; (d) 934's verdict is existence evidence only and lifts nothing. Cite `specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md` and `specs/ROADMAP.md` Stage 0 by path, never by line number. *(completed: one-string array, all four facts stated, cited by path)*
- [x] Do NOT touch any other key of 761's record, any other project's record, `roadmap_batches`, `roadmap_notes`, or `next_project_number`. *(completed: confirmed by diff read-through)*
- [x] Do NOT invoke `update-task-status.sh` for this edit (no flag writes `blockers`), and do NOT reach for `--hold-reason` as a substitute — it writes the `hold_reason`/`held_at`/`prior_status` triad and pushes the status toward `hold`. *(completed: Edit tool used directly, no status-mutating script invoked)*

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that 761's record has NO `blockers` key (not a key set
to `null` — the research report's "blockers: null" is `jq`'s rendering of absence, re-derived
here via `has("blockers") == false` and `grep -c '"blockers": null' == 0`), that its `status` is
`partial`, and that its `dependencies` array holds exactly the seven ids 760, 775, 805, 806,
819, 820, 934, all terminal. Confirm each with the `jq` read in the first task before editing;
if the key already exists, the edit becomes a value replacement and the `old_string` anchor
above no longer applies.

**Tier Justification**: `specs/state.json` is a data file with no executable surface of its own,
so no shell suite tests its content — `suite_selection_select specs/state.json` returns 76
suites, every one of them testing a script that READS the file, and `verify-touched.sh` is
inoperable in this repository today (measured: `suite-selection-map.data:37` names a
nonexistent suite); `bash .claude/scripts/validate-state.sh` is the one sanctioned entry point
that lints this file's own content, and its exit status is checked.

**Files to modify**:
- `specs/state.json` - add a `blockers` array to task 761's record; no other key or record changes

**Verification**:
- `jq -e '.active_projects[] | select(.project_number==761) | .blockers | type == "array" and length >= 1' specs/state.json` exits 0.
- `jq empty specs/state.json` exits 0 (file is still valid JSON).
- `git diff -- specs/state.json` shows additions only inside 761's record, and no reflow anywhere else in the file. A diff touching any other record means a whole-file rewrite happened and must be reverted and redone with `Edit`.
- `bash .claude/scripts/validate-state.sh` exits 0, reports `Failed: 0`, and shows no NEW warning class beyond the 21 warnings observed at plan-authoring time (`Passed: 10, Warnings: 21, Failed: 0`). Record the observed counts; a rise attributable to this edit is a failed phase.
- **Coupled-generated-surface falsification check**: `grep -c blockers .claude/scripts/generate-todo.sh` and `grep -c blockers .claude/scripts/roadmap-integration.sh` both return 0 at authoring time, so no generated artifact derives this field and none is declared in this phase's `Files to modify`. Falsify that measurement rather than trusting it: run `bash .claude/scripts/generate-todo.sh`, then `git diff --stat -- specs/TODO.md`. An empty diff confirms the measurement. A non-empty diff means `blockers` IS rendered after all — in which case `specs/TODO.md` is a coupled generated surface for this edit, and the regenerated file must be committed in THIS phase alongside `specs/state.json`, with the plan's `Files to modify` block corrected to declare it.

---

### Phase 2: Stage 0 — Check the `I = 1` Box and Restate the Depth-0 Crux [COMPLETED]

**Goal**: Stage 0 records two settled facts it currently does not: that the `I = 1` idle-run
sub-regime was filed as 929 and completed (with 929's honest outcome, a bounded refutation
rather than a discharge), and that 934 has run and returned its verdict. The depth-`0` gate's
own disposition stays exactly where it is — with the user.

**Tasks**:

- [x] Re-read `specs/ROADMAP.md:325-443` before editing. Confirm the four unchecked Stage 0 items are at `:402`, `:403`, `:406` and `:431`, and that `:431` is the `I = 1` idle-run item. *(completed: re-confirmed by text match, exactly four unchecked items at those positions)*
- [x] Change `:431`'s `- [ ]` to `- [x]` and append, inside that same item, what settled it: filed as task 929, `[COMPLETED]` 2026-11-13, archived at `specs/archive/929_idle_run_length_one_forward_slack_discharge/`, summary at `summaries/01_idle-run-one-forward-slack-summary.md`. State the honest outcome and do not round it up to a discharge: 929 **refuted** `ForwardSlackWitnessed` at a positive amount (`forwardSlackWitnessed_refuted_I_one`, FALSE at amount 4 at `xState = (true, 2, 0)` on `stepOr`, at a state whose pending-forever regime membership is compiled by `xState_regime`), together with a compiled bound on the refutation's reach (`ceiling_slack_at_consumer_amount`) under which all five depth-`0` cell-equality schemas keep the hypothesis for a positive compiled reason. Note that the item's own standing instruction — "File neither half without reading 924's report first" — was honored by 929 rather than bypassed. *(completed)*
- [x] Leave the other three unchecked Stage 0 items (`:402` Hugging Face token, `:403` task 428's scope, `:406` task 821) **byte-identical**. Touching any of them is taking a user ruling. *(completed: confirmed by diff read-through, zero hunks touch those lines)*
- [x] In the already-`[x]` depth-`0` gate bullet (`:351-401`), replace its closing future-tense sentence `934 decides exactly that, at exactly that instantiation.` with 934's landed verdict, sourced from `specs/archive/934_depth_zero_reachability_probe/summaries/01_consumer-shape-reachability-probe-summary.md`: the consumer-shape instantiation `(q, c + m*(P+1), n)` at amount `m*(P+1)` **IS satisfiable** — compiled at `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` (`fsw_consumer_shape`, with `plateau_next_region` showing the slack premise is non-vacuous and `consumer_fires` firing `cellLE_zero_const_of_kappa_eq_of_forwardSlack` under `ParamsOk`) — and the probe is **EXISTENCE EVIDENCE ONLY** for `cellLE_zero_const_of_kappa_eq` landing sorry-free. State all four of 934's own limits: it does not bring that lifting event about; it is not a general discharge of `ForwardSlackWitnessed` (the cell at `φ = ⊥` is the singleton `{∅}`); it does not refute `CellLEZeroConstOfKappaEq` under `ParamsOk`; and `certStabK`'s restatement obligation is unchanged. Record that the failure direction is ARGUED, NOT COMPILED (934's point 5). *(completed: `grep -c 'decides exactly that' specs/ROADMAP.md` returns 0)*
- [x] Preserve the bullet's own stated disposition verbatim in substance: the gate ruling is NOT taken, and per 934's summary point 6 the "claimed in neither direction" wording is left for the user or a `/roadmap` pass to revise. Do NOT delete the bullet's existing `**WHAT 929 CHANGED**` sub-block; the restatement extends that narrative rather than replacing it. *(completed: sub-block preserved verbatim, new text appended after it)*
- [x] Annotate — do not delete — the bullet's `~2.5h` figure at `:353` ("the `hself` ruling unblocks Phases 11.16 and 11.17 only (~2.5h)"). The surrounding text labels itself "Original framing, retained because its detail is still live", so honor that convention: keep the original clause and add that Phases 11.16 and 11.17 have since closed `[COMPLETED]` under plan v13, so the figure is spent rather than pending. *(completed)*
- [x] Keep the bullet's `- [x]` state unchanged. Nothing in this phase checks, unchecks, or re-dispositions a Stage 0 ruling beyond the one `:431` box the task description authorizes. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that Stage 0 holds exactly four unchecked items
(`:402`, `:403`, `:406`, `:431`), that the `I = 1` item is the one at `:431`, and that the
depth-`0` bullet spans `:351-401` and closes on the sentence "934 decides exactly that, at
exactly that instantiation." All four figures were re-derived at plan-authoring time from
`specs/ROADMAP.md` directly (the research report carries only the `:431` figure). Confirm by
re-reading `:325-443` and matching the closing sentence by TEXT, never by line number — an
earlier phase or a concurrent session may have shifted every line number in this file.

**Tier Justification**: Every changed hunk is authored narrative prose inside `## Stage 0`, a
section `roadmap-integration.sh`'s stage-layout mode retains byte-for-byte (only the section
holding the fenced `/orchestrate` block is regenerated), with zero compile or elaboration
surface, so `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` plus the
`prose` row's diff read-through is the check that covers it.

**Files to modify**:
- `specs/ROADMAP.md` - check the `I = 1` Stage 0 box with 929's outcome; restate the depth-0 crux bullet's closing sentence against 934's landed verdict; annotate the spent `~2.5h` figure

**Verification**:
- Diff read-through of `git diff -- specs/ROADMAP.md` confirming every changed hunk lies inside `## Stage 0`, is prose or a checkbox marker, and crosses no section boundary.
- `grep -c '^- \[ \]' ` over the `## Stage 0` section returns exactly 3 (down from 4), and the three surviving unchecked items are still those at the HF-token, 428-scope and 821 bullets — matched by text, not line number.
- `git diff -- specs/ROADMAP.md` shows no hunk inside `## Run these next` (the generated section) and no hunk inside `## Where both fronts now stand` (Phase 3's territory).
- `grep -c 'decides exactly that' specs/ROADMAP.md` returns 0.
- `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` exits 0 and reports `layout=stage`, `retained=13`, and `no content change` — the authoring-time baseline. A non-empty diff would mean an edit landed in a regenerated region and will be clobbered; a changed `retained` count would mean a section header was damaged. Check the exit status, not only the printed text.

---

### Phase 3: Rewrite "Where Both Fronts Now Stand" Against Plan v13 [COMPLETED]

**Goal**: The governing paragraph at the top of `specs/ROADMAP.md` states plan v13's actual rest
state instead of contradicting the generated `## Run these next` preamble 190 lines below it, and
points at Stage 0 for the depth-`0` crux rather than restating it.

**Tasks**:

- [x] Re-read `specs/ROADMAP.md:19-44` and locate all three stale claims by TEXT: the bold lead at `:21` ("**Stage 1 has a short dispatchable Lean line again; Stage 2 has none.**"), the Decidability bullet at `:25-27` ("so Phases 11.16 and 11.17 are now enterable -- roughly 2.5 hours of work that closes the idle-insertion cascade's record"), and the ownership clause at `:43` ("the depth-`0` gate's crux is owned by task 934"). *(completed: all three re-confirmed by text match before editing)*
- [x] Replace the bold lead so it states what is actually true: Stage 1 has NO dispatchable Lean line. Plan v13 came to rest at 30 of 41 phases closed with **zero enterable**, per its own `**Status**` line at `plans/13_depth-zero-gate-rest-state.md:4`. Keep the paragraph's existing framing that this is the product of rulings and closed programmes rather than of unfinished dispatches — that framing is still correct and is the paragraph's point. *(completed)*
- [x] Rewrite the Decidability bullet: the `hself` ruling was EXECUTED, not merely enabling. Phases 11.15, 11.16 and 11.17 closed `[COMPLETED]`, and Phases 11.12/11.13 were promoted `[BLOCKED]` -> `[COMPLETED WITH EXCLUSIONS]` on Phase 11.15's authority. Drop the "~2.5 hours" figure and the "now enterable" claim — the phases closed; they did not become enterable. State that every remaining phase (ten `[NOT STARTED]` plus Phase 11.8 `[BLOCKED]`) and five of 761's six filed Goals sit behind Phase 11.6's depth-`0` gate, which no open task owns. *(completed)*
- [x] Replace the `:43` ownership clause. "Owned by task 934" is an ownership claim about an OPEN task, and 934 is `[COMPLETED]` and archived at `specs/archive/934_depth_zero_reachability_probe/`. State 934's outcome in one or two sentences — satisfiable at the consumer instantiation, existence evidence only, the gate undecided — and then **cross-reference Stage 0's own bullet as the canonical statement** rather than restating 934's four limits a second time here. This cross-reference, not a second copy, is what prevents the two sites drifting apart again. *(completed)*
- [x] Re-check the paragraph's remaining arithmetic against the live tree rather than carrying it: the `:38` sentence "One item on the critical path is owned by no task" (canonical-bundle closedness) and the `:41-44` sentence about requirement (S)'s residue reducing to `real_certStabK`. Both are accurate as written; leave them unless the re-check contradicts them, and say in the phase notes which way the re-check came out. *(completed: both re-confirmed accurate against the live tree; left unchanged, as noted in the progress file)*
- [x] Do NOT edit `## Run these next` (`:209-278`) in any way: it is generated from `roadmap_batches` and a hand edit there is overwritten by the next regeneration. Do NOT edit `## Next batches` (`:279`+) — stale, but a declared Non-Goal. *(completed: diff hunks confirmed confined to lines 18-51, roadmap-integration.sh --regenerate --dry-run confirms no content change)*

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that the `## Where both fronts now stand` section spans
`:19-44` and that its three stale claims sit at `:21`, `:25-27` and `:43`. The task description
carries the narrower figure `:20-26`; the `:19-44` span and the three sub-locations were
re-derived at plan-authoring time by reading the file. It further asserts, from plan v13's
Status line, the breakdown "ten `[NOT STARTED]` plus Phase 11.8 `[BLOCKED]`". Confirm each by
matching text, not line numbers — Phase 2 edits the same file and will have shifted them.

**Tier Justification**: Every changed hunk is authored narrative prose inside
`## Where both fronts now stand`, a section `roadmap-integration.sh`'s stage-layout mode retains
byte-for-byte, with zero compile or elaboration surface, so
`bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` plus the `prose` row's diff
read-through is the check that covers it.

**Files to modify**:
- `specs/ROADMAP.md` - rewrite the `## Where both fronts now stand` section's three stale claims; cross-reference Stage 0 for the depth-0 crux

**Verification**:
- Diff read-through of `git diff -- specs/ROADMAP.md` confirming every changed hunk lies inside `## Where both fronts now stand` and is prose only.
- `grep -c 'short dispatchable Lean line again' specs/ROADMAP.md` returns 0; `grep -c 'now enterable' specs/ROADMAP.md` returns 0; `grep -c 'is owned by task 934' specs/ROADMAP.md` returns 0.
- `grep -c '2.5 hours' specs/ROADMAP.md` and `grep -c '~2.5h' specs/ROADMAP.md`: each surviving occurrence is accounted for in the phase notes as either annotated-as-spent (Phase 2's Stage 0 clause) or removed. No unexplained survivor.
- The rewritten paragraph and the generated `## Run these next` preamble agree on all three shared facts: zero enterable phases, 30 of 41 closed, the gate owned by no open task. Read both and state the agreement explicitly — **do not** confirm it with the same `grep` pattern used to make the edit (see `report-format.md`'s verification-independence rule).
- `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` exits 0 and reports `layout=stage`, `retained=13`, `no content change`.

---

### Phase 4: Cross-File Consistency Sweep, Residue Record, and Full Gate [COMPLETED]

**Goal**: Both corrected files are internally and mutually consistent, the out-of-scope residue
is recorded as a measurement rather than silently inherited, and the complete gate set has run
green over the whole task.

**Tasks**:

- [x] Read the final state of `## Where both fronts now stand`, `## Stage 0`'s depth-`0` bullet and `I = 1` item, the generated `## Run these next` preamble, and 761's `blockers` text together in one pass. Confirm no two of them assert contradictory facts about: the number of enterable phases (zero), plan v13's closed count (30 of 41), who owns the depth-`0` gate (no open task), what 934 established (satisfiability at the consumer instantiation, existence evidence only), and whether the gate is decided (it is not). *(completed: all four sites agree)*
- [x] Re-confirm item (1) is still discharged, as the task's own fourth filed item rather than as an assumption: cross-check every `task_ids[0]` and every member of `roadmap_batches` against `ls specs/archive/`. Record the batch count and the zero-hit result. *(completed: 21 batches, 44 unique task_ids, zero overlap against 779 archived ids)*
- [x] Record the out-of-scope residue in the summary, with its measurement: `validate-state.sh` Check 13 warns that `roadmap_batches[0]` names three already-terminal members (937, 829, 938). Attribute it to `/roadmap`'s owned surface, state that this task deliberately did not absorb it, and name `/roadmap` as the resolver. Do NOT edit `roadmap_batches`. *(completed: recorded in summary's Follow-ups)*
- [x] Record the two flagged follow-ups the research report identified and this task does not cover: `## Next batches`'s authored-prose staleness, and `RaySummary/README.md`'s matching crux wording. Name them as follow-ups; do not file tasks for them from here. *(completed: recorded in summary's Follow-ups)*
- [x] Record in the summary the one tooling defect met during this task: `verify-touched.sh` is inoperable repo-wide (`suite-selection-map.data:37` names `test-verification-scope-lib.sh`, which does not exist), so every non-final phase named a direct entry point instead. Confirm it is in `issues.jsonl`; append it if not. *(completed: already present, iss_1795108257413_DnYoNl)*
- [x] Write the implementation summary to `specs/933_correct_decidability_front_record/summaries/01_record-correction-roadmap-state-summary.md` per `summary-format.md`. *(completed)*
- [x] Run the complete gate set and record its verdict and exit status. *(completed: `verify-deploy.sh` PASS, 12 checks, 0 failures)*

**Timing**: 0.5 hours

**Depends on**: 1, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the authoring-time baselines it checks against:
`validate-state.sh` at `Passed: 10, Warnings: 21, Failed: 0` with exactly three Check 13
terminal-member warnings; `roadmap-integration.sh --regenerate --dry-run` at `layout=stage`,
`retained=13`, `tasks=43`, `runs=21`, `no content change`; and 21 `roadmap_batches` entries with
zero archived ids. All were measured at plan-authoring time on 2026-11-19. Re-measure each
before comparing — the active-task corpus turns over continuously, and a changed baseline is a
fact to record, not a failure, so long as the change is not attributable to this task's own
edits.

**Files to modify**:
- `specs/933_correct_decidability_front_record/summaries/01_record-correction-roadmap-state-summary.md` - new implementation summary

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` — the complete gate set, unnarrowed. No `--only-gate`, no `--only`, no `--skip-slow`: none of those is a tier, and a narrowed pass is not evidence for this phase's purpose. Record the exit status and the per-gate verdicts.
- `bash .claude/scripts/validate-state.sh` exits 0 with `Failed: 0`, and every warning is either present in the authoring-time baseline above or explained in the summary.
- `bash .claude/scripts/validate-artifact.sh specs/933_correct_decidability_front_record/plans/01_record-correction-roadmap-state.md plan` exits 0.
- `bash .claude/scripts/validate-artifact.sh specs/933_correct_decidability_front_record/summaries/01_record-correction-roadmap-state-summary.md summary` exits 0.
- `bash .claude/scripts/roadmap-integration.sh --regenerate --dry-run` exits 0, reports `layout=stage` and `no content change`, and its `retained` count matches the baseline — proving both ROADMAP.md edits survive the next regeneration.
- `jq empty specs/state.json` exits 0 and `git diff -- specs/state.json` is confined to 761's record.
- `bash .claude/scripts/generate-todo.sh` run once at the end; `specs/TODO.md` is committed if and only if it actually changed.

---

## Testing & Validation

- [x] `specs/ROADMAP.md` asserts no dispatchable Stage 1 Lean line, and no "~2.5 hours" or "now enterable" claim survives unexplained.
- [x] Stage 0 holds exactly three unchecked items; the `I = 1` item is checked and cites 929's summary with its honest refutation-plus-bound outcome.
- [x] Stage 0's depth-`0` bullet carries 934's landed verdict with all four of 934's stated limits, keeps its `[x]` state, and leaves the gate's disposition with the user.
- [x] `## Where both fronts now stand` cross-references Stage 0 for the crux rather than restating it.
- [x] Task 761's `specs/state.json` record carries a non-empty `blockers` array of strings naming the gate, its lack of an owner, and the seven discharged edges.
- [x] `specs/state.json` is valid JSON and its diff is confined to 761's record.
- [x] `roadmap-integration.sh --regenerate --dry-run` reports `layout=stage` and no content change, proving both edits live in retained sections.
- [x] `verify-deploy.sh` exits 0 over the complete gate set.
- [x] No file under `.claude/**`, `FormalSystem/**`, or any `.lean` file is modified.
- [x] No Stage 0 item other than the one authorized `I = 1` box changed state.

## Artifacts & Outputs

- `specs/ROADMAP.md` — corrected `## Where both fronts now stand` section and two Stage 0 corrections.
- `specs/state.json` — task 761's `blockers` array.
- `specs/933_correct_decidability_front_record/plans/01_record-correction-roadmap-state.md` — this plan.
- `specs/933_correct_decidability_front_record/summaries/01_record-correction-roadmap-state-summary.md` — implementation summary, including the out-of-scope residue record and the two flagged follow-ups.
- `specs/933_correct_decidability_front_record/issues.jsonl` — issue-log entries, including the `verify-touched.sh` inoperability finding.

## Rollback/Contingency

Every edit is a record correction to one of two tracked, committed files, and each phase commits
separately, so each phase boundary is its own rollback point. No snapshot is taken as a routine
checkpoint: nothing here is destructive, nothing is generated, and no build state exists to lose.

- **A ROADMAP.md edit lands in a regenerated region** (dry-run reports a non-empty diff): revert
  that phase's hunks and re-place the text inside the retained section. Do not "fix" it by
  editing `roadmap_batches` to match — that is `/roadmap`'s surface.
- **A state.json edit reflows the file** (diff touches records other than 761): revert
  `specs/state.json` to HEAD and redo the edit with `Edit` and the three-line anchor. Never with
  `jq`, never with a Python `json` rewrite.
- **The full gate set fails in Phase 4**: fix forward against the named gate. Never discard
  uncommitted changes to reach a green gate (see `rules/error-handling.md`'s write-gating
  constraint and `context/contracts/recovery.md`).
- **Phase 2 or 3 is found to require a Stage 0 ruling to proceed**: stop, leave Stage 0
  unchanged, and return `user_decision` on `.return-meta.json`. No agent may take a Stage 0
  ruling, and the depth-`0` gate's disposition in particular is reserved to the user.
