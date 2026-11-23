# Implementation Plan: Task #982

- **Task**: 982 - Reconcile records and tasks after PR review round
- **Status**: [IMPLEMENTING]
- **Effort**: 5.75 hours
- **Dependencies**: 978, 979, 980, 981 (all completed)
- **Research Inputs**: specs/982_reconcile_records_and_tasks_after_pr_review_round/reports/01_reconcile-records-pr-review-round.md
- **Artifacts**: plans/01_reconcile-records-pr-review-round.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The review round on collaborator pull requests #7 to #11 has reported, and its rulings are
settled; the records, six task descriptions, and the roadmap's generating state have not yet
caught up with them. This plan edits four record files and six task descriptions to the state
actually reached, defers every item whose precondition is an unmerged branch, and ends with a
cross-record consistency pass plus a quoted instruction for the user to give `/roadmap`. It
posts nothing to GitHub and merges nothing, and it hand-edits neither `specs/ROADMAP.md` nor
`specs/TODO.md`, both of which are generated.

### Research Integration

The research report establishes five things this plan is built on, each re-verified live at
planning time (see Premise Re-Validation below):

1. **Not blocked.** #7 is merged and approved; #11 carries a posted CHANGES_REQUESTED; #8, #9
   and #10 have fully drafted, decided reply text in `specs/reviews/pr-reviews-2026-11-21/`
   awaiting only the user's own posting action. Posting is outside this task.
2. **The task description's open-decision numbering is stale.** `records/milestones.md`'s
   "Open decisions" list has already been cut to four items by earlier rounds. The dispatch's
   "open decision 1" (conditions of merging) and "open decision 2" (who drafts the semantic
   record) no longer exist as entries at all — they were folded into prose and are moot, not
   pending. The dispatch's "open decision 4" (evaluator placement) and "open decision 5"
   (expand/contract) map onto the current list's items 2 and 3, both now closable.
3. **One live cross-record contradiction exists**: `records/proof-mode.md` still says the
   rewriting contribution is "contributed and under review" in two places, while
   `records/milestones.md` already treats it as merged.
4. **Several dispatch items are gated on an unmerged branch** and must NOT be done in this
   pass: the architecture record's open decision 2 (the rename lives only on #8's branch), Goal
   C's C1/C2 reduction to pointers (#10 and #11 are open), and the `records/README.md` row for
   `records/semantic-proof-mode.md` (the file does not exist on `main`).
5. **No `file_scope` edit is needed.** All six named tasks are `not_started` and their declared
   paths read correctly against the current tree; the dispatch's "where paths moved" question
   resolves to "not yet, pending #8's merge", which is description text, not an array edit.

### Premise Re-Validation (Carried-Figure Discipline)

Every trigger-class figure in the dispatch description was re-checked live at planning time:

| Claim checked | Live result | Verdict |
|---|---|---|
| PR #7-#11 states | #7 MERGED (head `6313e693f`); #8 OPEN/MERGEABLE (`5ecc91d63`); #9 OPEN/CONFLICTING (`b3d8f6463`); #10 OPEN/MERGEABLE (`ada7074dd`); #11 OPEN/MERGEABLE (`b2eb3ac0b`) | Matches the report exactly; unchanged |
| "the contributions table ... lists three" | The table has **four** rows (Temporal, Semantic lemmas, Semantic record, Semantic mode); #7 appears only in prose above it | Description is stale by one row; the target of five rows stands, the gap is one row not two |
| Two "contributed and under review" occurrences in `records/proof-mode.md` | Confirmed at lines 503 and 790 | Unchanged |
| `records/semantic-proof-mode.md` in the tree | `ls records/` returns five files, not including it | Confirmed absent; README row correctly unavailable |
| `records/README.md` already lists `milestones.md` | Confirmed (one row per record, four rows, all present) | Description's item (4) is already satisfied for every record that exists |
| The six named task slugs | 960, 969, 977, 944, 945, 973 all present, all `not_started`, `file_scope` lengths 8/8/2/8/13/5 | Unchanged |
| `records/milestones.md` "Open decisions" has four items | Confirmed: (1) `BimodalLib` in `defaultTargets`, (2) evaluator placement, (3) expand/contract, (4) signature-layer timing | Confirms the numbering-drift finding |
| `records/proof-mode-architecture.md` open decision 2 still open on `main` | Confirmed open, "awaits the user's ruling", recommendation to rename | Confirmed; stays open this pass |

No figure in the dispatch description was found to have moved since the research pass. The one
correction is the "three pull requests where it lists three" count, noted above.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` is generated from `specs/state.json` and is not edited by this task. The
roadmap's PR #7/#8 gating rule on `proof_mode_split_shared_test_and_guide_files` is already
current and needs no change. The two roadmap changes this round calls for — narrowing this
task's own `roadmap_annotation`, and adding a placeholder for Goal C's evaluator and
semantic-mode/adapter work — are delivered as a quoted instruction for the user to give
`/roadmap`, per the dispatch's own constraint.

## Goals & Non-Goals

**Goals**:
- `records/milestones.md`, `records/proof-mode.md` and `records/proof-mode-architecture.md`
  state the position actually reached by the review round, with every merge-gated item left
  explicitly deferred rather than asserted early.
- The six named task descriptions are edited through `state-write.sh` to name only the still-open
  coordinating pull request and the work that genuinely remains.
- One cross-record consistency pass is run and its result recorded.
- A quoted `/roadmap` instruction is handed to the user.

**Non-Goals**:
- Posting any review, comment or reply to GitHub; merging any pull request. The task posts
  nothing and merges nothing, and `pr-prohibition.md` forbids it independently.
- Hand-editing `specs/ROADMAP.md` or `specs/TODO.md` — both are generated.
- Closing `records/proof-mode-architecture.md`'s open decision 2, reducing Goal C's C1/C2 to
  pointers, or adding a `records/semantic-proof-mode.md` row to `records/README.md`. All three
  are gated on a merge that has not happened.
- Any `file_scope` array edit, or any edit to the records a merged pull request has itself made.
- Creating task records for Goal C's evaluator (C3) or semantic mode/adapter (C4).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A pull request merges between planning and implementation, making a deferred item actionable or a stated item stale | H | M | Phase 1 re-runs `gh pr view` for all five and re-reads the deferral table before any edit; each deferred item names its precondition so the check is a lookup, not fresh research |
| Closing `milestones.md`'s open decision 3 while the architecture record's open decision 2 (the same question) stays open reads as a fresh contradiction | M | M | Word the closure as the milestones-level ruling that cites the architecture record's item as closing on #8's merge, rather than asserting that item has already been edited |
| Recording PR #8's carrying-table shape as settled design when it is only an ask | M | M | `pr8-record-edits.md` item 4 is explicitly contingent ("Only if the contributor accepts that shape"); record it as the current condition of merging, in the same framing |
| Overwriting a record edit a merged pull request itself made | H | L | #7 is the only merged PR and it edited no record file; Phase 1 confirms this with `gh pr view 7 --json files` before any record edit |
| `state-write.sh` filter error corrupting `specs/state.json` | H | L | One task per invocation, `--dry-run` first, `validate-state.sh` after each write; never a hand edit of the file |
| Non-ASCII content in descriptions mangled by a jq round-trip | M | L | `state-write.sh` is the single mutex-guarded writer and handles serialization; no manual `jq > tmp && mv` is used anywhere in this plan |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5 | 1 |
| 3 | 6 | 2, 3, 4, 5 |

Phases within the same wave can execute in parallel. Phases 2, 3 and 4 each own one record file
and share none; Phase 5 owns `specs/state.json` and touches no record.

---

### Phase 1: Re-verify the gating state and the deferral table [COMPLETED]

**Goal**: Confirm, immediately before any edit, that the five pull requests are still in the
states this plan was written against, and resolve each deferred item to "still deferred" or "now
actionable". Nothing is written to the repository in this phase.

**Tasks**:
- [x] Run `gh pr view N --json number,state,mergeable,headRefOid,mergedAt` for N in 7, 8, 9, 10,
      11 and record the result. *(completed: #7 MERGED 6313e693f; #8 OPEN/MERGEABLE 5ecc91d63; #9
      OPEN/CONFLICTING b3d8f6463; #10 OPEN/MERGEABLE ada7074dd; #11 OPEN/MERGEABLE b2eb3ac0b --
      unchanged from the plan's premise)*
- [x] Run `gh pr view 7 --json files --jq '.files[].path'` and confirm no path under `records/`
      appears — i.e. the one merged pull request edited no record file, so nothing in Phases 2-4
      risks overwriting a contributor's own record text. *(deviation: the check FAILS -- PR #7's
      merged diff includes records/proof-mode-architecture.md and records/proof-mode.md. Recorded
      as issue plan-premise-stale/minor; no corrective action needed, see phase note)*
- [x] Run `ls records/` and confirm whether `records/semantic-proof-mode.md` now exists.
      *(completed: absent -- records/ has 5 files: milestones.md, proof-mode-architecture.md,
      proof-mode.md, README.md, theorem-library.md)*
- [x] Resolve each row of the deferral table below and write the verdicts into the phase note:
      - architecture record's open decision 2 (rename) — deferred while #8 is open *(confirmed
        still open in the live file)*
      - Goal C's C1/C2 reduced to pointers — deferred while #10 or #11 is open *(confirmed, both
        open)*
      - `records/README.md` row for `records/semantic-proof-mode.md` — deferred while that file
        is absent from `main` *(confirmed absent)*
      - PR #8's carrying-table shape folded into `proof_mode_s5_aware_box_scopes` and
        `proof_mode_cross_modal_scopes_mf_tf` — deferred while #8 is open *(confirmed, #8 still
        open)*
- [x] If any precondition has flipped (a deferred item is now actionable, or an item this plan
      states as current has gone stale), record the flip explicitly in the phase note and in
      `issues.jsonl` via `issue-record.sh`, then carry it into the affected phase rather than
      following this plan's text blindly. *(completed: the records/ path flip on PR #7 recorded
      above; no deferred item flipped to actionable)*
- [x] Re-read `specs/reviews/pr-reviews-2026-11-21/pr8-record-edits.md` in full — it is the one
      artifact that distinguishes "already landed by the PR, do not touch" from "still ours to
      apply", and Phases 2 and 4 both depend on that distinction. *(completed: confirmed live that
      items 1-2 of that artifact have NOT landed, since PR #8 is still open; only item 3
      (milestones.md) and item 4 (join 2 shape) are ours to apply this round)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: the phase writes no repository file, so no suite can cover it; its own
output is the recorded `gh pr view` verdict table, which is the check.

**Scope Hypothesis**: this plan assumes exactly one of the five pull requests (#7) is merged and
`records/semantic-proof-mode.md` is absent from `main`. The implementer confirms both with the
`gh pr view` sweep and `ls records/` above before Phase 2 begins, and treats a changed answer as
a plan deviation to record, not a detail to absorb silently.

**Files to modify**:
- none (read-only verification phase)

**Verification**:
- The phase note contains a five-row PR state table and a four-row deferral verdict table.
- `gh pr view 7 --json files` output is recorded and contains no `records/` path, or the
  deviation is recorded if it does.

---

### Phase 2: `records/milestones.md` [COMPLETED]

**Goal**: Bring the contributions table, "Where it stands", "What to do next", the open-decisions
list, join 2 and the channel table to the state the review round reached.

**Tasks**:
- [x] **Contributions table**: give all five pull requests a row with a State column — Rewriting
      (merged); Temporal (open, rebased onto `main`, two conditions remain per `pr8-review.md`);
      Semantic lemmas (open, changes requested with three conditions, posted); Semantic record
      (open, three additions requested per `pr10-comment.md`); Semantic mode (open, recommended
      for closure per `pr9-disposition.md`). Reword the prose above the table so it introduces
      the table rather than describing the rewriting contribution separately from it. *(completed)*
- [x] **"Where it stands"**: rewrite each state description to the position reached — in
      particular that the temporal contribution is rebased and its gates are green, and that the
      semantic lemmas now carry three posted conditions of merging. Name work by slug; cite no
      task numbers. *(completed; done inline as part of the contributions-table rewrite above)*
- [x] **"What to do next" item 1**: replace with the text `pr8-record-edits.md` gives verbatim —
      the contribution is rebased onto `main` and re-reviewed at its new head; it merges once the
      carrying table's key is widened to `(source, target)` and made non-private (join 2), and
      once the one altered acceptance example in `ProofModeTest.lean` is split into the two cases
      it used to cover. *(completed, verbatim)*
- [x] **Open decision 2 (evaluator placement)**: restate as settled design rather than an open
      question — the evaluator sits under `FormalSystem/Semantics/` beside the lemmas, with the
      semantic mode a thin tactic layer over it. Remove it from the open-decisions list and fold
      the statement into the Goal C preamble, which already assumes it. *(completed)*
- [x] **Open decision 3 (`expand`/`contract`)**: strike it entirely and renumber the
      signature-layer item from 4 to 3, exactly as `pr8-record-edits.md` instructs. Word the
      strike so the ruling is stated at the milestones level — the keywords are `expand` and
      `contract` — while the architecture record's own item is named as closing on the temporal
      contribution's merge, not as already edited. *(completed: renumbered to 2, since open
      decision 2 (evaluator) was also struck this round, not just decision 3; the ruling itself
      is stated in the Temporal row of the contributions table, naming the architecture record's
      own open decision as closing on the merge)*
- [x] **Confirm, do not reintroduce**: the old "conditions of merging" and "who drafts the
      semantic record" decisions are absent from the current list and must stay absent; the
      per-pull-request State column now carries the first, and the contributor having written
      `records/semantic-proof-mode.md` settles the second. *(confirmed)*
- [x] **Join 2**: restate with the shape agreed — a carrying table keyed by `(source, target)`
      with a `framed` flag, in `Automation/ProofMode/Carrying.lean`, non-private so the two scope
      records can add rows. State it as the current condition of merging asked of the
      contributor, **not** as settled design; `pr8-record-edits.md` itself qualifies it with
      "Only if the contributor accepts that shape". *(completed)*
- [x] **Channel table**: re-phase the "Order within each channel" rows so they do not imply the
      rewriting and temporal contributions merge together — the rewriting contribution has
      merged ahead of the temporal one. Check the phase labels read correctly against that.
      *(completed: row 1 label changed from "Until temporal is merged" to "Rewriting merged,
      temporal not yet")*
- [x] **Leave alone**: open decision 1 (`BimodalLib` in `defaultTargets`) is untouched by this
      round. Goal C's C1 and C2 are NOT reduced to pointers — both pull requests that would
      complete them are open (confirmed in Phase 1). *(confirmed untouched)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/check-task-references.sh records/milestones.md` is
the only mechanical check that covers this file — no Lean module, test suite or script imports
`records/*.md`, so no wider battery can observe the edit.

**Scope Hypothesis**: the contributions table is asserted to need exactly one added row (it has
four, the target is five). The implementer confirms the row count by reading the table before
editing and records a deviation if it differs.

**Files to modify**:
- `records/milestones.md` - contributions table gains a row and a restated State column; "Where
  it stands", "What to do next" item 1, open decisions 2 and 3, join 2 and the channel table
  rewritten as above

**Verification**:
- `bash .claude/scripts/check-task-references.sh records/milestones.md` exits 0.
- The contributions table has five rows, one per pull request, each with a State cell.
- The "Open decisions" list has exactly two items: the `BimodalLib` registry question and the
  signature-layer timing question, in that order, numbered 1 and 2.
- `grep -n "open decision" records/milestones.md` shows no reference to a decision number the
  list no longer contains.
- No task number appears anywhere in the file (the write-time hook enforces this independently).

---

### Phase 3: `records/proof-mode.md` [NOT STARTED]

**Goal**: Fix the one live cross-record contradiction and bring M17, M16 and M4 to the position
reached, without disturbing the still-correct "second run still owes" and "not yet derived"
language.

**Tasks**:
- [ ] **M17 status, occurrence 1** (the "Filed record" line inside the M17 section, line 503 at
      planning time): change "none; contributed and under review" to state the merge.
- [ ] **M17 status, occurrence 2** (the M17 row of the "Filed records" table, line 790 at
      planning time): same change.
- [ ] **M17, nothing else**: the done-when text and the "Current client" paragraph already match
      the user's own correction in `pr7-approval.md` — no node counts, no timing claim, the
      saving stated as being in the proof script rather than the term, the larger-term finding
      cited. Confirm against `pr7-approval.md` and leave them as they are. Confirm the
      surrounding "second run still owes" language, which correctly describes the gate-one
      selection rerun as outstanding, is undisturbed.
- [ ] **M16 (views tier)**: state precisely which rows and modules exist on `main` today — the
      view table holds the rows the rewriting contribution added, exposed through `lunfold` and
      `lfold`. State that the twenty further rows (ten `Formula`, ten `PlusFormula`, the extra
      pair being `after`) and the retirement of `ltemporal_dual` live on the temporal
      contribution's branch and are not on `main`. Do **not** describe those twenty rows as
      present. State what the views-tier record still owes independently of either contribution:
      building the tier module itself, with every defined operator having a row, at the
      architecture record's lane placement — neither contribution does that.
- [ ] **M4 (linear time, Until and Since)**: record that the `expand`/`contract` naming is
      settled. Record what the temporal contribution contributes — Until and Since introduction,
      one-step unfolding at `ZTime`, `keeping`, whole-judgment time reflection and the strict
      leads-to layer. Confirm the induction rule is still stated as open; the existing "statement
      proposed and not yet derived" wording is correct and needs no change beyond consistency
      with the rest of the record.
- [ ] **Dependency picture**: confirm the M17-then-M0-then-M16 order still reads correctly now
      that M17 has merged — M0 runs after the open contributions are merged or declined, and is
      still held on the temporal contribution. No change to the ordering logic is expected; record
      the confirmation.
- [ ] **Filed records table**: confirm the M17 row is the only row this round changes; every other
      row is a slug pointer unaffected by the review.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/check-task-references.sh records/proof-mode.md` is
the only mechanical check covering this file; nothing in the Lean build or the script test suites
reads `records/*.md`.

**Scope Hypothesis**: exactly two occurrences of "contributed and under review" are asserted, at
lines 503 and 790. The implementer re-runs `grep -n "under review" records/proof-mode.md` before
editing and records a deviation if the count or the locations differ.

**Files to modify**:
- `records/proof-mode.md` - M17 status at both occurrences; M16's statement of which rows and
  modules exist; M4's naming ruling and contributed list; confirmations recorded for the
  dependency picture and the Filed records table

**Verification**:
- `grep -n "under review" records/proof-mode.md` returns nothing.
- `bash .claude/scripts/check-task-references.sh records/proof-mode.md` exits 0.
- M16 names the twenty temporal rows as living on the contribution's branch, not on `main`.
- M4 still states the generalizing induction rule as proposed and not yet derived.
- The M17 "Current client" paragraph is byte-identical to its pre-edit state.

---

### Phase 4: `records/proof-mode-architecture.md` and `records/README.md` [NOT STARTED]

**Goal**: Close the one currency gap that is safe to close, verify the "Where the work sits" rows,
and record why the two merge-gated items are left alone.

**Tasks**:
- [ ] **Semantic-mode paragraph** (line 98 at planning time): the record currently says
      `records/semantic-proof-mode.md` "is to be written". It has been written, as a draft on the
      semantic-record contribution's branch, and is not yet merged. Change the phrase so it does
      not imply no draft exists — name it as drafted on that contribution and not yet in the tree.
      Do **not** attempt the larger rewrite the dispatch describes for "once
      `records/semantic-proof-mode.md` is in the tree"; that is gated on the merge.
- [ ] **Open decision 2 (the rename)**: leave it open. The edit that closes it exists only on the
      temporal contribution's unmerged branch, and `pr8-record-edits.md` was written specifically
      to stop this task duplicating or reverting it. Add nothing; record the reason in the phase
      note so a later reader does not mistake the omission for an oversight.
- [ ] **"Where the work sits" rows**: verify each of the five rows the dispatch names.
      - Logical rewriting row ("`lrewrite` and `lsimp` apply native rules only") — accurate, the
        rewriting contribution has merged; confirm and leave.
      - Views row ("the first rows of the view table are contributed with the rewriting tactics")
        — accurate for `main` today; the twenty temporal rows are deferred until that contribution
        merges. Confirm and leave.
      - Carrying row ("one carrying table shared with the two scope records above") — accurate;
        confirm and leave.
      - Until/Since induction row ("statement proposed and not yet derived") — accurate; confirm
        and leave.
      - Semantic tier row ("to be a separate mode in a directory of its own ... after
        `records/semantic-proof-mode.md`") — accurate, since the record is still a draft; confirm
        and leave.
      Record each verdict; change only a row the verification shows is wrong.
- [ ] **`records/README.md`**: confirm it has one row per record actually present — four rows for
      `milestones.md`, `proof-mode.md`, `proof-mode-architecture.md` and `theorem-library.md`,
      with `milestones.md` among them. It does. Do **not** add a `records/semantic-proof-mode.md`
      row: that file does not exist on `main` (Phase 1 re-confirms this), and adding a row for an
      absent file would break the README's own one-row-per-present-record rule.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/check-task-references.sh records/` is the only
mechanical check covering these two files; the edit touches no code path a wider battery runs.

**Scope Hypothesis**: this phase asserts exactly one prose edit to `records/proof-mode-architecture.md`
(the semantic-mode paragraph) and zero edits to `records/README.md`. The "Where the work sits"
row verification may raise that count; the implementer records any row it actually changes as a
deviation from this hypothesis rather than treating a silent extra edit as in scope.

**Files to modify**:
- `records/proof-mode-architecture.md` - the semantic-mode paragraph's currency phrase; any
  "Where the work sits" row the verification shows to be wrong
- `records/README.md` - verification only; no edit expected

**Verification**:
- `grep -n "to be written" records/proof-mode-architecture.md` no longer matches the
  semantic-mode paragraph.
- The architecture record's "Open decisions" list still has two items, the second still the
  `unfold`/`fold` keyword question, unedited.
- `ls records/` and the `records/README.md` table list the same set of files.
- `bash .claude/scripts/check-task-references.sh records/` exits 0.

---

### Phase 5: The six task descriptions [NOT STARTED]

**Goal**: Edit six task descriptions through `state-write.sh` so each names only the still-open
coordinating pull request and the work that genuinely remains, and regenerate `specs/TODO.md`.

**Tasks**:
- [ ] For each task below, run `state-write.sh` with `--dry-run` first, inspect the diff, then
      run it for real with `--session-id` set to this dispatch's session id and `--regen-todo` on
      the final invocation. One task per invocation; never a hand edit of `specs/state.json`.
- [ ] **`proof_mode_split_shared_test_and_guide_files`**: rewrite the coordination paragraph. It
      currently names three pull requests; name only the temporal contribution as the still-open
      blocker — the rewriting contribution has merged and filed its own rules, tests and guide
      pages by family, and the semantic-mode contribution is recommended for closure with its
      content superseded. State that what remains to move once the temporal contribution merges is
      narrower than originally scoped: chiefly the shared guide index, both ProofMode READMEs, and
      whatever of the `Meta`, `Modal` and `Temporal` tactic modules under `FormalSystem/Tactic/`
      predates the family split — that contribution's own branch already splits its own additions
      into per-family modules. On the hold: the roadmap's gating rule is a statement, not a status
      field, and no hold flag is set on the task record; confirm this with
      `jq '.active_projects[] | select(.project_number==960) | .status'` and state in the
      description that nothing needs lifting.
- [ ] **`proof_mode_views_tier`**: its "coordination with open contributions" clause already
      anticipates this case. Update it: the rewriting contribution has merged, so its contributed
      view rows and the equality-handling parts of `lrewrite`/`lsimp` are extractable now, leaving
      logical rewriting where it is. The temporal contribution has not merged, so its twenty rows
      and the `ltemporal_dual` retirement remain owed extraction once it lands — do not state them
      as extractable.
- [ ] **`connective_signature_layer_shared_primitives`**: state inside the task description what
      the roadmap already states — that the signature layer's landing window relative to the
      temporal contribution is still genuinely undecided (join 4), and that research and planning
      may proceed now regardless, with implementation waiting on that ruling. Also state its
      relation to the Language table: the generic clause classes in `TruthClauses.lean` and the
      single home for the derived operators are the two questions its research opens.
- [ ] **`proof_mode_s5_aware_box_scopes`**: the carrying table it adds rows to is the one the
      temporal contribution fixes the shape of. State the shape as currently asked of the
      contributor — keyed by `(source, target)`, with a `framed` flag, in
      `Automation/ProofMode/Carrying.lean`, non-private — and state that it is a condition of
      merging not yet confirmed accepted, so this task folds `keeping` into that one table rather
      than building a parallel path once the merge lands.
- [ ] **`proof_mode_cross_modal_scopes_mf_tf`**: the same carrying table; state that its MF and TF
      rows enter the table `proof_mode_s5_aware_box_scopes` establishes, with the same pending
      shape, and that it waits on that task rather than on the merge independently.
- [ ] **`theorem_library_countermodels`**: add a cross-reference naming the evaluator as the
      client of its evaluator-checked grade, and naming `records/semantic-proof-mode.md` and the
      evaluator milestone as the still-missing upstream for that grade specifically — so a reader
      does not assume all three admission grades are equally ready. No `file_scope` change.
- [ ] **No `file_scope` edits anywhere in this phase.** All six tasks are `not_started`, their
      declared paths read correctly against the current tree, and nothing has moved. If the
      implementer believes a `file_scope` entry is wrong, record it as a deviation and leave the
      array alone — a `file_scope` edit is outside this plan's scope.
- [ ] Run `bash .claude/scripts/validate-state.sh` after the final write and confirm it passes.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: `specs/state.json` is a contract surface every orchestration script
reads, and `bash .claude/scripts/validate-state.sh` is the check that covers a malformed or
inconsistent write; no cheaper tier observes a schema break, and no Lean or record-prose surface
is touched.

**Scope Hypothesis**: exactly six task descriptions are edited and zero `file_scope` arrays. The
implementer confirms the six slugs resolve to project numbers 960, 969, 977, 944, 945 and 973
with `jq` before the first write, and records any mismatch as a deviation.

**Files to modify**:
- `specs/state.json` - six `active_projects[].description` fields, via `state-write.sh` only
- `specs/TODO.md` - generated; regenerated in this phase by `state-write.sh --regen-todo` on the
  final invocation, never hand-edited. It renders each task's description, so a description edit
  drifts it immediately.
- `specs/ROADMAP.md` - generated; it renders a truncated form of each task description, so these
  edits drift it too. It is **not** regenerated in this phase and **never** hand-edited: the
  orchestration close re-renders it mechanically via `orchestrate-conclusion-roadmap.sh`, and the
  roadmap's own content changes are the user's `/roadmap` call in Phase 6.

**Verification**:
- `bash .claude/scripts/validate-state.sh` exits 0.
- `jq -r '.active_projects[] | select(.project_number==960 or .project_number==969 or .project_number==977 or .project_number==944 or .project_number==945 or .project_number==973) | "\(.project_number) \(.file_scope | length)"' specs/state.json` returns the same six lengths recorded in Phase 1 (8, 8, 2, 8, 13, 5), proving no `file_scope` was touched.
- `git diff --stat specs/state.json specs/TODO.md` shows both changed and nothing else under
  `specs/` outside this task's own directory.
- Each of the six descriptions names the temporal contribution as the only still-open
  coordinating pull request where it names one at all.

---

### Phase 6: Closing consistency pass and the roadmap instruction [NOT STARTED]

**Goal**: Sweep all five record files for statements that contradict each other after Phases 2-5,
and hand the user a quoted `/roadmap` instruction for the two roadmap changes this round calls
for.

**Tasks**:
- [ ] Run `grep -n "under review\|contributed and\|merged" records/*.md` and read every hit
      against the live PR states from Phase 1. Every "merged" claim must name the rewriting
      contribution and nothing else; no "under review" claim may survive for it.
- [ ] Cross-check the three places the same facts are stated: `records/milestones.md`'s
      contributions table and "Where it stands", `records/proof-mode.md`'s M16, M17 and M4
      sections, and `records/proof-mode-architecture.md`'s "Where the work sits" rows. Any
      disagreement about what has merged, what is contributed, or what remains open is a finding
      to fix, not to note.
- [ ] Verify the deliberate asymmetry is not read as a contradiction: `records/milestones.md`
      states the `expand`/`contract` ruling while `records/proof-mode-architecture.md`'s open
      decision 2 stays open. Confirm the milestones wording names the architecture record's item
      as closing on the merge, so the two read as one position rather than two.
- [ ] Confirm no record names work by task number anywhere:
      `bash .claude/scripts/check-task-references.sh records/` exits 0.
- [ ] Confirm no record narrates its own draft history: read the edited sections against
      `.claude/rules/no-record-versioning-in-deliverables.md` — no "previously", "no longer",
      "formerly", "supersedes", and no version label. The write-time hook
      `validate-no-record-versioning.sh` enforces this, but a passing hook is not a reading.
- [ ] Write the quoted `/roadmap` instruction into the task summary, for the user to issue. It
      asks for three things and no more: narrow this task's `roadmap_annotation` to name only the
      signature-layer-timing decision, since the `expand`/`contract` question it used to cite is
      now resolved pending only a mechanical merge; add a placeholder milestone or batch entry for
      Goal C's evaluator and semantic-mode/adapter work, noting that neither has a task record yet
      and both wait on the semantic record landing, without creating the task records; and leave
      the existing gating rule on `proof_mode_split_shared_test_and_guide_files` unchanged, since
      it already states the position correctly.
- [ ] Do not run `/roadmap` and do not edit `specs/ROADMAP.md`. The instruction is handed over,
      not executed.
- [ ] Record in the summary the list of anything still pending that this task could not close,
      with its precondition: the architecture record's open decision 2, Goal C's C1/C2 pointer
      reduction, the `records/README.md` semantic-record row, and the carrying-table fold into the
      two scope records.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4, 5

**Verification Tier**: full

**Files to modify**:
- `records/milestones.md` - only if the consistency sweep finds a contradiction
- `records/proof-mode.md` - only if the consistency sweep finds a contradiction
- `records/proof-mode-architecture.md` - only if the consistency sweep finds a contradiction
- `records/README.md` - only if the consistency sweep finds a contradiction
- `records/theorem-library.md` - read in the sweep; edited only if it contradicts another record

**Verification**:
- Scoped touched-path check: `bash .claude/scripts/verify-touched.sh records/ specs/state.json`
  passes, or its failures are attributed to the standing baseline (`agent-system/` is absent from
  this checkout, which makes eight script test suites report missing-fixture failures regardless
  of what this task touched — attribute those away rather than treating them as a regression).
- `bash .claude/scripts/check-task-references.sh records/` exits 0.
- `bash .claude/scripts/validate-state.sh` exits 0.
- `grep -n "under review" records/*.md` returns nothing.
- The summary contains the quoted `/roadmap` instruction and the list of still-pending items with
  their preconditions.
- The complete gate set is **not** run as this phase's own criterion: under `/orchestrate` it is
  owed once per invocation and discharged at the orchestration close, to which this phase
  explicitly defers.

---

## Testing & Validation

- [ ] `bash .claude/scripts/check-task-references.sh records/` exits 0.
- [ ] `bash .claude/scripts/validate-state.sh` exits 0.
- [ ] `grep -n "under review" records/*.md` returns nothing.
- [ ] `records/milestones.md`'s contributions table has five rows and its open-decisions list has
      two items.
- [ ] `records/proof-mode-architecture.md`'s open decision 2 is unchanged and still open.
- [ ] `records/README.md` lists exactly the records present in `records/`.
- [ ] The six task descriptions are changed and no `file_scope` array is.
- [ ] `specs/ROADMAP.md` shows no hand edit in `git diff`.
- [ ] No pull request was posted to, commented on, or merged.

## Artifacts & Outputs

- `records/milestones.md`, `records/proof-mode.md`, `records/proof-mode-architecture.md` edited;
  `records/README.md` and `records/theorem-library.md` verified.
- Six task descriptions edited in `specs/state.json`; `specs/TODO.md` regenerated.
- `specs/982_reconcile_records_and_tasks_after_pr_review_round/summaries/01_reconcile-records-pr-review-round-summary.md`
  containing the quoted `/roadmap` instruction and the still-pending list.
- Deviation and win entries in `specs/982_reconcile_records_and_tasks_after_pr_review_round/issues.jsonl`.

## Rollback/Contingency

Every change is a markdown edit or a `state-write.sh` description edit, each committed at its own
phase boundary, so reverting is a per-file `git revert` or a re-run of `state-write.sh` with the
prior text. Before Phase 5's first write, take a defensive checkpoint with
`bash .claude/scripts/git-snapshot.sh 982 --no-revert` — `--no-revert` is the correct form for an
ordinary checkpoint, since the default form reverts the working tree and this repository is
shared with concurrently dispatched work. If a precondition flips mid-run (a pull request merges),
stop at the current phase boundary, record the flip, and let the next dispatch re-plan the
affected deferred items rather than improvising them in place.
