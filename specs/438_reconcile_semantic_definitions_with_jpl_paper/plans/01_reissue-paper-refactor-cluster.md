# Implementation Plan: Task #438 (Part B — Cluster Re-Issue)

- **Task**: 438 - reconcile_semantic_definitions_with_jpl_paper
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (Part A research is complete and is the input to this plan)
- **Research Inputs**: specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md
- **Artifacts**: plans/01_reissue-paper-refactor-cluster.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Part A (the team research report) already delivers the reconciliation table, target Lean
signatures, coupling analysis, per-task staleness verdicts, and the dependency-cycle resolution.
This plan executes **Part B only — deliverables 6 through 10**: rewrite the six paper-refactor
cluster task descriptions (414, 415, 417, 419, 420, 427) in `specs/state.json` to state the
current four-axiom `def:frame` (biconditional Compositionality, Seriality, Limit, Spherical) and
totality-based logical consequence over `H_F`; rename the three misnamed tasks (subject to a
rename-cost grep preflight that has NOT yet been run); set statuses per the report's verdicts;
insert SUPERSEDED banners on stale report files; drop the `420 -> 415` cycle edge; and regenerate
`specs/TODO.md`. All work is confined to `specs/**` — this is state.json surgery, file moves, and
banner insertion: mechanical but high-blast-radius, so the rename grep runs before any rename is
committed to, and `state.json` is treated as the single machine source of truth (edit state.json,
then regenerate TODO.md via `generate-todo.sh`; never hand-edit TODO.md).

Definition of done: every one of the six descriptions states the current definitions with
`\label`-based paper anchors, an explicit survives/superseded breakdown, and preserved still-valid
content; the dependency graph is verifiably acyclic; TODO.md is regenerated; the superseded-
vocabulary grep across all six rewritten descriptions has every remaining hit justified.

### Research Integration

The plan is a direct execution of the report's "Recommendations for Part B" items 1-10:
- **Deliverable 4** supplies the per-task Survives / Refuted / "re-issued description must say"
  content for all six tasks — the content spec for Phases 3-4.
- **Deliverable 5** supplies the corrected edge set (drop `415` from `420.dependencies` only) and
  the four-point post-edit verification checklist — Phase 6.
- **Gap 4** flags that the rename-cost grep preflight has not been run — Phase 1 runs it before
  any rename is committed to (Phase 2 honors the task's instruction to record the decision and
  its cost rather than leaving dangling paths if the surface is wide).
- **Gap 6 / Recommendation 5** supply the SUPERSEDED-banner requirement — Phase 5.
- **Recommendation 10** supplies the final superseded-vocabulary grep — Phase 7.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md`'s "Paper Alignment Programme" section governs this cluster, but the report
establishes that section is itself stale (three-axiom frame, maximal-history validity). This plan
does NOT edit ROADMAP.md (out of Part B scope); the staleness is recorded under Recommended
Follow-Ups below so it is not lost.

## Goals & Non-Goals

**Goals**:
- Rewrite the `description` field of all six cluster tasks so each states the CURRENT
  definitions (four-axiom `def:frame`; totality-based consequence over `H_F`) as settled inputs,
  with `\label`-based paper anchors (never bare line numbers), an explicit survives/superseded
  breakdown, and all still-valid content preserved (scope boundaries, non-goals, binding notation
  decisions such as the superscript-inverse converse convention). Descriptions ARE the specs —
  do not shorten to tidy.
- Rename 414, 415, and 420 per the report's proposals — IF the Phase 1 grep preflight shows a
  manageable reference surface; otherwise record the rename decision and its measured cost in the
  task descriptions instead of doing a partial rename.
- Set statuses: 414, 415, 417 -> `not_started` (target predicate changed; research must re-run);
  419, 427 stay `not_started`; 420 stays `blocked` with a revised `blockers` field (phases 1-5
  are landed, green, and committed and must not be presented as undone).
- Insert a one-line SUPERSEDED banner at the top of each superseded report file. Never delete or
  overwrite any existing report file.
- Apply the corrected dependency edges (drop `415` from `420.dependencies`; nothing else) and
  verify acyclicity via `.claude/scripts/generate-task-order.sh --print`.
- Regenerate `specs/TODO.md` via `.claude/scripts/generate-todo.sh` and commit state.json +
  TODO.md together.

**Non-Goals** (hard boundaries, restated from the task description):
- Do NOT add, remove, or alter any field of `TaskFrame`. Do NOT touch `TruthAt`, `valid`,
  `SemanticConsequence`, or any Omega binder. Do NOT edit any file under `FormalSystem/`.
- Do NOT edit `latex/` or `typst/` content.
- Do NOT edit anything under `/home/benjamin/Philosophy/Papers/` — the paper is read-only input.
- Do NOT perform any of the six cluster tasks' underlying Lean/LaTeX/typst work.
- Do NOT re-run Part A or re-derive anything from the paper — the research report is the settled
  input.
- Do NOT edit `specs/ROADMAP.md` and do NOT rewrite task 424 — see Recommended Follow-Ups.
- Part B changes task SPECIFICATIONS in `specs/`, nothing else.

### Recommended Follow-Ups (out of scope — record, do not execute)

These three items are real, surfaced by the research, and outside deliverables 6-10. They belong
in task 438's completion summary as named follow-ups; expanding this plan to cover them is the
user's call, not the plan's:

1. **Task 424** (`strong_completeness` topic, not_started, gates the entire ultraproduct branch)
   hard-codes the current Omega-parameterized `TruthAt`/box clause through its governing design
   doc under `specs/archive/361_*/design/02_compactness-route.md` and breaks silently once 414
   lands. Outside `topic == "paper-refactor"`, so outside Part B's rewrite scope. (Related open
   item: tasks 421-423 and 425 are UNCHECKED, not cleared — their design docs were never opened.)
2. **`specs/ROADMAP.md`'s "Paper Alignment Programme" section** is itself stale (three-axiom
   frame, maximal-history validity) and deliverable 6 does not touch it.
3. **Recurrence prevention**: the paper has taken 59 commits in 14 days and carries 139
   machine-parseable `%% CHANGE`/`%% OLD` pairs that nothing in this repo reads. The report
   recommends (Option A+C) a generated `specs/paper-definitions-of-record.md` plus a
   `check-paper-definitions.sh` lint anchored to a paper commit SHA recorded in state.json —
   a follow-up `meta` task. Without it this cluster goes stale a third time.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Partial rename leaves dangling artifact paths (state.json `artifacts[].path` pointing at a moved directory) | H | M | Phase 1 grep preflight runs BEFORE any rename; Phase 2 is a pre-declared atomic batch per rename (state.json name + `git mv` + path updates land as one commit); fallback is record-decision-instead-of-rename |
| state.json corrupted by a bad edit (malformed JSON breaks every downstream script) | H | L | Every state.json edit goes through `jq`/scripted rewrite into a temp file, validated with `jq empty` before moving into place; TODO.md regenerated only after validation; per-phase commits give clean rollback points |
| A rewritten description silently retains a superseded axiom statement | M | M | Phase 7's mandated grep for "Limit Nullity", "lax", "maximal-history", "IsMaximal", "NOT adopted" across all six descriptions, with every remaining hit justified in the summary |
| 420 presented as undone (status reset destroying the record of landed phases 1-5) | H | L | 420's status is never changed from `blocked`; its rewritten description and `blockers` field inventory landed-vs-stale explicitly (report Conflict 6, two teammates converged independently) |
| Concurrent task activity mutates state.json between phases | M | L | Phase 1 re-verifies cluster membership/statuses/edges against live state.json; each phase re-reads state.json before editing rather than trusting an earlier phase's snapshot |
| Descriptions drift from the report's content spec (paraphrase error re-introducing a stale claim) | M | M | Phases 3-4 compose each description directly from Deliverable 4's "Re-issued description must say" text with the report open, then re-read each description end to end (deliverable 8's own requirement) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 5 | 2 |
| 4 | 4 | 3 |
| 5 | 6 | 4 |
| 6 | 7 | 5, 6 |

Phases within the same wave can execute in parallel. (Phases 3 and 4 both edit `state.json` and
are deliberately serialized; Phase 5 touches only report files and may run parallel to Phase 3.)

### Phase 1: Preflight — cluster re-verification and rename-cost grep [NOT STARTED]

**Goal**: Re-verify the cluster's live state and measure the rename reference surface BEFORE any
mutation, producing the rename-vs-record decision input. Read-only; no file is modified.

**Tasks**:
- [ ] Re-query `specs/state.json` for `topic == "paper-refactor"`: confirm the cluster is still
  exactly {414, 415, 417, 419, 420, 427} with statuses/dependencies as the report records
  (420 blocked deps [415,438]; 419 not_started [438]; 414 researched [420,438]; 415 researched
  [414,420,438]; 417 researched [414,420,438]; 427 not_started [414,415,417,419,420,438]). Any
  divergence: stop and reconcile against the live state before proceeding.
- [ ] Run the rename-cost grep preflight the report flags as NOT yet run (Gap 4): for each old
  slug — `414_refactor_semantics_to_maximal_history_validity`,
  `415_completeness_over_maximal_history_semantics`,
  `420_align_task_frame_with_positive_cone_limit_nullity` — run
  `grep -rl '<slug>' specs/ --include='*.md'` AND `grep -c '<slug>' specs/state.json`, and also
  check `.return-meta.json` / `.orchestrator-handoff.json` files under each task directory.
  Record per-slug file lists and hit counts.
- [ ] Enumerate, via `jq`, every `artifacts[].path` in state.json (any task) that points into
  `specs/414_*/`, `specs/415_*/`, or `specs/420_*/` — these must all be updated if the rename
  proceeds (the report expects 420 to have the widest surface: plan, report, summary,
  `.return-meta.json`, `.orchestrator-handoff.json`).
- [ ] Decide rename-vs-record per task and write the decision (with measured counts) into the
  phase notes for Phase 2. Decision rule: rename when every hit is inside `specs/**` and
  enumerable in the Phase 2 batch; record-instead-of-rename when hits extend beyond what one
  atomic batch can consistently update (per the task's own instruction to record the decision
  and cost rather than leave dangling paths).
- [ ] Capture the BEFORE state of the dependency graph: run
  `bash .claude/scripts/generate-task-order.sh --print` and save the output showing 415 in wave 1
  with `Blocked by: --` (the cycle symptom) for before/after comparison in Phase 6.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The report asserts exactly six cluster tasks, exactly three rename
candidates (414, 415, 420), and an UNMEASURED grep surface for the three old slugs. Confirm the
six-task set and three-candidate list by the live `jq` re-query, and treat the grep hit counts as
the measurement this phase exists to produce — no count from the report or task description may
be assumed.

**Files to modify**: none (read-only phase; findings recorded in the Phase 2 execution notes)

**Verification**:
- Cluster re-query output matches the report's inventory (or divergence is documented).
- All three greps executed with per-file hit lists recorded; rename-vs-record decision stated
  per task with its measured cost.
- Baseline `generate-task-order.sh --print` output saved.

---

### Phase 2: Renames (or recorded rename decisions) [NOT STARTED]

**Goal**: Execute the renames green-lit by Phase 1 — 414 -> `refactor_semantics_to_total_history_validity`,
415 -> `completeness_over_total_history_semantics`, 420 -> `align_task_frame_with_positive_cone_axioms`
(417, 419, 427 need no rename) — atomically per task, or record the decision-and-cost instead
where Phase 1 showed a wide surface. Renames run BEFORE the description rewrites so Phases 3-4
write descriptions against final paths.

**Tasks**:
- [ ] For each green-lit rename, as ONE batch per task: (a) update `project_name` in state.json;
  (b) `git mv specs/{NNN}_{old_slug} specs/{NNN}_{new_slug}`; (c) update every `artifacts[].path`
  entry in state.json referencing the old directory (in the task's own record and any other
  task's record found by Phase 1); (d) update every `specs/**/*.md` reference from Phase 1's hit
  list (superseded report files keep their historical prose — only live path references change;
  a report's own internal mention of the old name as history is acceptable per the report's
  rename-surface analysis).
- [ ] For any task where Phase 1 decided record-instead-of-rename: leave `project_name` and the
  directory untouched, and add the decision + measured cost to the notes Phase 3/4 will fold
  into that task's rewritten description.
- [ ] Validate state.json with `jq empty` after each batch; run
  `bash .claude/scripts/generate-todo.sh` and confirm it exits 0.
- [ ] Confirm zero dangling paths: re-run the Phase 1 greps for each old slug; every remaining
  hit must be inside a superseded report file as historical prose, justified in the phase notes.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Three renames expected (report Recommendation 3), with 420 carrying the
widest artifact surface (3+ `artifacts[].path` entries plus `.return-meta.json` and
`.orchestrator-handoff.json`) and 414/415 low surface (reports only, no plan/summary). Confirm
against Phase 1's measured hit lists before executing; the batch file set for each rename is
exactly Phase 1's enumeration for that slug, fixed before the batch starts.

**Files to modify**:
- `specs/state.json` — `project_name` and `artifacts[].path` entries for renamed tasks
- `specs/{414,415,420}_*/` — directory renames via `git mv`
- `specs/TODO.md` — regenerated (never hand-edited)
- Any `specs/**/*.md` live path references from Phase 1's hit list

**Verification**:
- `jq empty specs/state.json` passes; `generate-todo.sh` exits 0.
- Old-slug greps return only justified historical-prose hits; `ls specs/` shows the new
  directory names; every `artifacts[].path` in state.json resolves to an existing file.

---

### Phase 3: Rewrite descriptions and reset status — tasks 414, 415, 417 [NOT STARTED]

**Goal**: Re-issue the three research-invalidated tasks: rewrite each `description` from
Deliverable 4's "Re-issued description must say" content and set each status to `not_started`
(their target predicate changed from `IsMax`-maximality to totality, so existing research was
conducted against the wrong target).

**Tasks**:
- [ ] **414**: rewrite the description to state — target predicate for `TruthAt`'s box clause,
  `valid`, `SemanticConsequence`, `satisfiable`, and `H_F` is TOTALITY (`∀ t, τ.domain t`), not
  Mathlib `IsMax`; the `Preorder`/Zorn/`chainSup`/`isMax_timeShift`/`isMax_of_total` prototype
  survives as reusable engine material for `thm:extension` but is not the destination API;
  proving a Zorn-maximal extension total requires Seriality and Spherical (not yet in
  `TaskFrame` — 420 territory, a NEW dependency to name in text); the Group C dead/live/portable
  bucketing (88/16/8) survives as verified-as-transcribed but NOT re-derived against the current
  tree — carry both halves, never present the counts as fresh; live anchors are
  `\label{def:frame}`, `\label{def:world-history}`, and the `H_F` restatement (superseding any
  "line 1833" citation); include the cross-task acceptance criterion shared with 420 (Spherical
  must be the literal hypothesis `thm:extension`'s proof consumes, not an inert field); preserve
  all still-valid scope/non-goal/notation content including the superscript-inverse converse
  convention.
- [ ] **415**: rewrite to state — countermodel family is the full TOTAL-history set `H_F`, not
  maximal; staging plan (Discrete -> Dense -> Base -> Dedekind) and deterministic lead-frame
  (`bundleFlowFrame`) strategy survive and are plausibly totality-favorable; every
  canonical/chronicle construction must discharge Seriality, Limit ("Limit Nullity" name
  retired), and Spherical, with Spherical flagged least routine; biconditional Compositionality
  (interpolation direction) is a new proof obligation for constructions that relied on the lax
  inclusion only.
- [ ] **417**: rewrite to state — target totality per 414's corrected charter; the "Limit
  automatic over Z" claim survives verbatim under the renamed "Limit" axiom
  (`limit_nullity_of_succOrder`); whether Seriality and Spherical are ALSO automatic over `D = ℤ`
  is a new open question for 417's next research pass (Seriality plausibly automatic; Spherical a
  plausible finite-set pigeonhole corollary — a lead to verify, not assume).
- [ ] In all three descriptions: carry `\label`-based paper anchors only (never bare line
  numbers); name explicitly which prior research survives and which is superseded (so the next
  agent does not silently re-consume a refuted finding); instruct the next research dispatch to
  check the paper's git log for commits since a stated date/SHA as its literal FIRST step before
  re-reading any definition (report Recommendation 7).
- [ ] Set `status` to `not_started` for 414, 415, 417 in state.json. Do not touch
  `next_artifact_number`; do not delete or modify any existing report file.
- [ ] Validate with `jq empty`; regenerate TODO.md via `generate-todo.sh`; re-read each of the
  three rewritten descriptions end to end against Deliverable 4 before committing.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Exactly three descriptions rewritten and three statuses reset in this
phase. Confirm at execution time that no additional task has been added to the cluster since
Phase 1's re-query (re-check `topic == "paper-refactor"` before editing).

**Files to modify**:
- `specs/state.json` — `description` and `status` fields for 414, 415, 417
- `specs/TODO.md` — regenerated

**Verification**:
- `jq empty` passes; `generate-todo.sh` exits 0; TODO.md shows the three tasks as [NOT STARTED].
- Each description re-read end to end; contains its `\label` anchors, survives/superseded
  breakdown, paper-git-log-first instruction, and (414) the cross-task acceptance criterion.

---

### Phase 4: Rewrite descriptions — tasks 419, 420, 427 (statuses stand) [NOT STARTED]

**Goal**: Re-issue the three tasks whose status is unchanged: description rewrites per
Deliverable 4, plus 420's revised `blockers` field. No status transitions in this phase.

**Tasks**:
- [ ] **419** (stays `not_started`): replace the stale `possible_worlds.tex:3250` CO citation
  with `\label{TMP-CO}` (the `def:TMplus-c` restatement that `Formula.co` actually mirrors) and
  `\label{CO}` for the base-TM form; flag the Spherical risk as the PRIMARY open question for the
  next research pass — quote the paper's `:926` ℚ-flow worked non-example directly in the
  description (the paper's own demonstration of a structure violating Spherical, structurally
  near-identical to 419's proposed Q-flow countermodel sketch), stating explicitly that the
  sketch may not be a legitimate `TaskFrame` under the four-axiom `def:frame` and may need a
  different carrier — not softened to a routine conformance check; state that the converse
  direction (`co_derived`/`co_valid`) is done, sorry-free, and must not be redone.
- [ ] **420** (stays `blocked` — report Conflict 6, both teammates converged; phases 1-5 are
  landed/green/committed and must NOT be presented as undone): rewrite the description to state
  the CURRENT four-axiom `def:frame` with `\label{def:frame}` as the formal anchor; inventory
  landed-vs-stale explicitly (phases 1-5 preserved: citations, docstrings, three bare-relation
  helper theorems verified surviving verbatim, LaTeX restatement scaffolding; STALE: the phase-5
  LaTeX definition text is stale a second time, and phase 6 must be re-scoped to add Seriality,
  Spherical, and the interpolation direction together, not `limit_nullity` alone); note
  `nullity_identity`-as-field-vs-derived-lemma is an open design question; include the
  cross-task acceptance criterion shared with 414.
- [ ] **420 `blockers` field**: revise to (a) preserve the 415-phase-6 explanation (phase 6's
  `bundleFlowFrame` discharge still phase-waits on 415 even though the task-level edge is being
  dropped in Phase 6 — the compensating record from Deliverable 5), and (b) add that the
  description/phase-6 scope was stale a second time and the next research pass must re-scope
  phase 6 against the four-axiom target before resuming implementation.
- [ ] **427** (stays `not_started`): rewrite to state — do NOT use
  `latex/subfiles/02-Semantics.tex` as the model (it was rewritten by 420 phase 5 against the
  now-superseded THREE-axiom frame; the prior instruction would write wrong definitions into the
  book); model the typst restatement directly on the paper's `\label{def:frame}`, treating the
  LaTeX subfile as a fellow downstream consumer possibly still mid-sync; note latex and typst are
  stale by DIFFERENT amounts (latex one generation behind, typst two); the stale-site enumeration
  must be re-audited against the current four-axiom paper, not trusted from the prior
  description; 427 remains LAST in the cluster; audit scope beyond `02-semantics.typ` survives.
- [ ] All three: `\label` anchors only; survives/superseded breakdown; preserve still-valid
  scope/non-goal/notation content; 419's rewrite also carries the paper-git-log-first
  instruction (it is one of the four re-run research dispatches).
- [ ] Validate with `jq empty`; regenerate TODO.md; re-read all three rewritten descriptions end
  to end against Deliverable 4 before committing.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: Exactly three descriptions rewritten, one `blockers` field revised, zero
status transitions. Confirm 420's status is still `blocked` and 419/427 still `not_started` at
edit time.

**Files to modify**:
- `specs/state.json` — `description` fields for 419, 420, 427; `blockers` field for 420
- `specs/TODO.md` — regenerated

**Verification**:
- `jq empty` passes; `generate-todo.sh` exits 0; statuses for 419/420/427 unchanged in TODO.md.
- 419's description contains `TMP-CO`/`CO` label anchors and the quoted `:926` non-example;
  420's blockers field carries both the phase-6/415 wait and the re-scope requirement.

---

### Phase 5: SUPERSEDED banners on stale report files [NOT STARTED]

**Goal**: Insert a one-line `> **SUPERSEDED** ...` banner at the top of each report file whose
content predates the four-axiom/totality generation, so a future agent opening the file directly
sees the warning (report Gap 6 / Recommendation 5). Banner insertion only — never delete,
truncate, or otherwise rewrite any report content.

**Tasks**:
- [ ] Insert the banner at the top of: 414's `reports/01_maximal-history-validity-refactor.md`
  and `reports/02_group-c-reconciliation.md`; 415's
  `reports/01_completeness-maximal-history-rebase.md`; 417's
  `reports/01_semantic-fmp-finite-worldstate.md` (its research targets `IsMaximal`, the same
  refuted predicate); and 420's report and summary (`01_taskframe-limit-nullity-alignment-summary.md`
  and its report) whose sections describe the three-axiom frame.
- [ ] Banner text names WHAT superseded the file and where the verdict lives, e.g.:
  `> **SUPERSEDED** (2026-08-09): written against the three-axiom frame / maximal-history
  (IsMax) target, superseded by the paper's four-axiom def:frame + totality-based H_F. See
  specs/438_reconcile_semantic_definitions_with_jpl_paper/reports/01_team-research.md
  (Deliverable 4) for what survives.` Adjust the survives-pointer per file; use post-Phase-2
  (renamed) paths.
- [ ] Confirm by diff that each change is a pure top-of-file insertion (banner + one blank
  line); no other line of any report is touched.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: Approximately six files bannered (414 x2, 415 x1, 417 x1, 420 x2). The
report's minimum list names 420's reports/summary plus 414's and 415's reports; 417's report is
included by the same refuted-target criterion. Confirm the actual file inventory by listing each
task's `reports/`/`summaries/` directories at execution time — banner every file that states the
superseded three-axiom frame or `IsMax` target, and record the final count and list.

**Files to modify**:
- `specs/{414,415,417,420}_*/reports/*.md` and `specs/420_*/summaries/*.md` — top-of-file banner
  insertion only

**Verification**:
- `git diff` shows only prepended banner lines per file; every bannered file's remaining content
  is byte-identical; final banner inventory recorded.

---

### Phase 6: Dependency edge correction and acyclicity verification [NOT STARTED]

**Goal**: Apply Deliverable 5's corrected edge set — remove exactly one edge (`415` from
`420.dependencies`, breaking both the 2-cycle `420 <-> 415` and the 3-cycle
`420 -> 415 -> 414 -> 420` simultaneously) — and verify the graph is acyclic with 427 last.

**Tasks**:
- [ ] Edit state.json: `420.dependencies` becomes `[438]` (415 removed). ALL other cluster edges
  stay exactly as declared: 414 `[420,438]`, 415 `[414,420,438]`, 417 `[414,420,438]`,
  419 `[438]`, 427 `[414,415,417,419,420,438]`. (The compensating record for the dropped edge —
  420's phase-6-still-waits-on-415 text — already landed in Phase 4's blockers revision; confirm
  it is present.)
- [ ] Validate with `jq empty`; regenerate TODO.md via `generate-todo.sh`.
- [ ] Run `bash .claude/scripts/generate-task-order.sh --print` and verify all four Deliverable 5
  checks against the Phase 1 baseline: (a) 415 no longer appears in wave 1 with `Blocked by: --`;
  (b) 415's wave lists 414 and 420 among its blockers; (c) 420 lands in an earlier wave than
  414/415/417; (d) 427 is in the final wave of the Paper Refactor group.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Exactly ONE edge removed; every other dependency array unchanged. Confirm
by diffing the six tasks' `dependencies` arrays before/after the edit — any second changed array
is an error.

**Files to modify**:
- `specs/state.json` — `420.dependencies` only
- `specs/TODO.md` — regenerated

**Verification**:
- `generate-task-order.sh --print` passes all four checks (a)-(d); output saved next to the
  Phase 1 baseline for the summary.

---

### Phase 7: Final verification, regeneration, and closing commit [NOT STARTED]

**Goal**: Run the task description's mandated end-to-end verification over the finished state,
regenerate TODO.md a final time, and land the closing commit of state.json + TODO.md together.

**Tasks**:
- [ ] Re-read all six rewritten descriptions end to end (extract each via `jq` and read in
  full), confirming: current four-axiom `def:frame` + totality-based consequence stated as
  settled inputs; `\label` anchors only (grep the six descriptions for bare
  `possible_worlds.tex:[0-9]` citations — any hit must be a parenthetical locator beside a
  `\label`, never a citation in itself); survives/superseded breakdown present; still-valid
  content preserved.
- [ ] Run the superseded-vocabulary grep over the six descriptions: "Limit Nullity", "lax",
  "maximal-history", "IsMaximal", "NOT adopted". Zero hits is NOT the target — hits inside
  explicit supersession framing (e.g. naming the refuted prior target) are expected and correct;
  every remaining hit must be individually justified in the implementation summary, and any hit
  presenting superseded content as CURRENT is a defect to fix before closing.
- [ ] Confirm statuses: 414/415/417 `not_started`; 419/427 `not_started`; 420 `blocked` with the
  revised blockers field. Confirm no report file was deleted or content-modified (banners are
  insertions only): `git diff --stat` across the task shows no deletions in any `reports/` or
  `summaries/` file.
- [ ] Final `bash .claude/scripts/generate-todo.sh`; confirm TODO.md renders the renamed slugs
  and updated statuses; `jq empty specs/state.json` passes.
- [ ] Closing commit including `specs/state.json` + `specs/TODO.md` together (per deliverable 10;
  the research report is already committed with Part A), message per git-workflow conventions
  with the session ID.
- [ ] Write the implementation summary listing: renames executed vs. recorded, banner inventory,
  the justified superseded-vocabulary hits, the before/after `generate-task-order.sh` outputs,
  and the three Recommended Follow-Ups (424, ROADMAP.md staleness, recurrence-prevention meta
  task) so they land in the completion summary.

**Timing**: 0.5 hours

**Depends on**: 5, 6

**Verification Tier**: local

**Files to modify**:
- `specs/TODO.md` — final regeneration
- `specs/438_reconcile_semantic_definitions_with_jpl_paper/summaries/01_*.md` — implementation
  summary (created by the implement dispatch per its own conventions)

**Verification**:
- All checklist greps run with outputs captured; every superseded-vocabulary hit justified;
  closing commit contains state.json + TODO.md together; working tree clean for `specs/`.

## Testing & Validation

- [ ] `jq empty specs/state.json` passes after every phase that edits it.
- [ ] `bash .claude/scripts/generate-todo.sh` exits 0 after every state.json edit; TODO.md is
  never hand-edited.
- [ ] `bash .claude/scripts/generate-task-order.sh --print` post-Phase-6 passes Deliverable 5's
  four checks: 415 out of wave 1, 415 blocked by 414+420, 420 before 414/415/417, 427 last.
- [ ] Rename integrity: old-slug greps return only justified historical-prose hits; every
  `artifacts[].path` in state.json resolves to an existing file.
- [ ] Superseded-vocabulary grep ("Limit Nullity", "lax", "maximal-history", "IsMaximal",
  "NOT adopted") across all six rewritten descriptions with every remaining hit justified.
- [ ] No file under `FormalSystem/`, `latex/`, `typst/`, or `/home/benjamin/Philosophy/Papers/`
  is touched: `git status` shows changes confined to `specs/**`.
- [ ] No report file deleted or content-rewritten; SUPERSEDED banners are pure top-of-file
  insertions.

## Artifacts & Outputs

- `specs/438_reconcile_semantic_definitions_with_jpl_paper/plans/01_reissue-paper-refactor-cluster.md`
  (this file)
- Rewritten `description` (and 420 `blockers`) fields for tasks 414, 415, 417, 419, 420, 427 in
  `specs/state.json`
- Renamed task directories (subject to Phase 1 decision):
  `specs/414_refactor_semantics_to_total_history_validity/`,
  `specs/415_completeness_over_total_history_semantics/`,
  `specs/420_align_task_frame_with_positive_cone_axioms/`
- SUPERSEDED banners on ~6 stale report/summary files
- Corrected dependency graph (`420.dependencies = [438]`) verified acyclic
- Regenerated `specs/TODO.md`
- `specs/438_reconcile_semantic_definitions_with_jpl_paper/summaries/01_*.md` implementation
  summary carrying the three named follow-ups (task 424 exposure, ROADMAP.md staleness,
  recurrence-prevention meta task)

## Rollback/Contingency

All changes are git-tracked and land as per-phase (Phase 2: per-rename atomic) commits, so
rollback is `git revert` of the offending commit(s) — state.json, TODO.md, directory renames
(`git mv` reverts cleanly), and banner insertions are all fully reversible. If a rename batch
fails midway, do not commit: restore with the snapshot discipline (`git-snapshot.sh 438` before
any intentional discard, per git-workflow rules), fall back to the record-decision-instead-of-
rename path for that task, and proceed — a recorded rename decision satisfies deliverable 7. If
`generate-todo.sh` or `generate-task-order.sh` fails after a state.json edit, the edit is
reverted (not hand-patched forward) and re-applied via a validated jq rewrite. No Lean, LaTeX,
typst, or paper file is ever touched, so no build-level rollback exists or is needed.
