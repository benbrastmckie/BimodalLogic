# Implementation Plan: Task #514

- **Task**: 514 - align_definitions_with_source_paper (METATASK)
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/514_align_definitions_with_source_paper/reports/01_definitional-review-and-closure.md
- **Artifacts**: plans/01_apply-board-revisions.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

The research phase produced all analytical deliverables of this metatask: the definitional
review, the app:dense adjudication ((T1) reading of record), and the Galois-closure
specification with the corrected closure table. What remains for implementation is **board
surgery on `specs/`**: applying the verbatim amendment texts of report §4.3 to the task
descriptions in `specs/state.json`, setting dependencies to the researched build order of
record (512 -> 507 -> {508 -> 509, 510, 513-revised in parallel}), encoding 511's terminal
close and 513's full description replacement, plus one documentation touch to
`specs/paper-definitions-of-record.md` (the §2.4 reading note on the three `app:*` anchor
entries). **No Lean file is created or modified under this task** — that is an explicit
task-description constraint, and every Lean obligation lands in the tasks this board surgery
revises (chiefly revised 513).

### Research Integration

Ground truth is `reports/01_definitional-review-and-closure.md`. The plan consumes it as
follows:

- **§4.3** carries the *verbatim* amendment/replacement texts for tasks 512, 507, 508, 509,
  510, 511 (postflight note), and 513 (full replacement). The implementer MUST copy these
  texts from §4.3 verbatim — do not paraphrase, re-derive, or "improve" them; §4.3 is the
  single transcription source and this plan deliberately does not duplicate the texts.
- **§4.4** is the build order of record, driving the dependency edits in Phase 2/3.
- **§2.4** is the reading note to be recorded against the `app:discrete`/`app:dense`/
  `app:complete` entries of `paper-definitions-of-record.md` (Phase 4).
- **§4.2 final paragraph**: tasks 492/493/494/495 need no text change — verified, not edited
  (Phase 5 checks they were not touched).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found (no roadmap context provided).

## Goals & Non-Goals

**Goals**:
- Apply the §4.3 amendment texts verbatim to task descriptions 512, 507, 508, 509, 510 in
  `specs/state.json`.
- Replace 513's description entirely with the §4.3 replacement text (Galois-closure
  implementation task) and repoint its dependencies to `[512, 507]`.
- Record 511's close: append the §4.3 postflight note; status stays `researched` (the
  report's explicit verdict: terminal at [RESEARCHED], never dispatch /plan 511).
- Set 509's dependencies to `[507, 508]` per the build order of record; verify all other
  dependency edges already match §4.4.
- Add the §2.4 (T1)-reading note to the three `app:*` entries in
  `specs/paper-definitions-of-record.md` without disturbing its hash-pinning machinery;
  confirm the `def:deterministic` anchor is present.
- Regenerate TODO.md from state.json and verify the board satisfies acceptance criteria (4)
  and (5) of the task description.

**Non-Goals**:
- **No Lean refactor or Lean file edits of any kind** (task-description mandate; all Lean
  work belongs to 512/507/508/509/510/513).
- No closed-form characterizations of Mod(TM+_f)/Mod(TM+_c) anywhere (report §3.3: open,
  recorded as explicit non-goals inside 513's replacement text).
- No edits to the paper (`possible_worlds.tex` is read-only input) and no re-pin of the
  whole-file checksum sentinels in `paper-definitions-of-record.md` (a prose note is not a
  drift correction — see that file's own dirty-pin convention).
- No new tasks: the research determined no genuine gap requires one (category-theoretic
  layer presentational; two-dimensional layer presentational).
- No edits to tasks 492/493/494/495 (§4.2: they already speak in class terms).
- No `.claude/**` writes (disposable deploy artifact; all targets here are `specs/**`).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| jq escaping mangles the long amendment texts (unicode arrows, quotes, newlines) | H | M | Write each §4.3 text to a temp file first and inject with `jq --rawfile`; never inline long strings in a jq program. Verify by extracting the field back out and diffing against the temp file. |
| Wholesale `.artifacts` or `.active_projects` replacement corrupts state.json | H | L | Use targeted per-task jq updates (`(.active_projects[] | select(.project_number == N)).description |= ...`); never assign whole arrays. Validate `jq empty specs/state.json` after every write; snapshot state.json to the task directory before Phase 1. |
| 511's "terminal at [RESEARCHED]" has no terminal encoding in the status state machine | M | M | Follow the report verbatim: status stays `researched`; the appended postflight note in the description is the guard against future /plan dispatch. Record the tension in the summary; closing it harder (e.g. archive) is a later /todo decision, not this task's. |
| Editing paper-definitions-of-record.md breaks `check-paper-definitions.sh` or masks pre-existing drift | M | L | Run the script BEFORE editing and record its verdict (a pre-existing case (b) is not this task's regression); add the reading note as prose outside the ```latex blocks so no recorded hash changes; re-run after and require an identical verdict. |
| jq `!=` escaping bug (Claude Code #1132) corrupts a filter | M | M | Use `select(... | not)` pattern per CLAUDE.md; prefer `==` selectors throughout. |
| Verbatim-text drift (paraphrase creeping in during transcription) | H | L | Phase-level verification diffs the injected description text against the §4.3 source block (modulo the report's blockquote `> ` prefixes, which are stripped mechanically). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel. Note: Phases 1-3 all edit
`specs/state.json` and are serialized to avoid write contention; Phase 4 touches only
`specs/paper-definitions-of-record.md` and may run in parallel with them (in a single-agent
run, execute in numeric order).

### Phase 1: Amend foundation tasks 512 and 507 [COMPLETED]

**Goal**: The two foundation tasks of the build order carry their paper-grounding amendments.

**Tasks**:
- [x] Snapshot `specs/state.json` to `specs/514_align_definitions_with_source_paper/state-before-board-surgery.json` (rollback anchor). *(completed)*
- [x] Extract the "512 — append to description" block from report §4.3, strip the blockquote `> ` prefixes, write to a temp file, and append it (preceded by two newlines) to task 512's `description` in state.json via `jq --rawfile`. *(completed)*
- [x] Same for the "507 — append to description" block onto task 507's `description`. *(completed)*
- [x] Verify: `jq empty specs/state.json`; extract both descriptions and confirm each contains its full amendment text verbatim (diff against the temp files); confirm 512 deps `[514]` and 507 deps `[514, 512]` unchanged (already conform to §4.4). *(completed)*
- [x] Run `bash .claude/scripts/generate-todo.sh` and spot-check the two entries render. *(completed)*
- [x] Commit (`task 514 phase 1: amend foundation tasks 512 and 507`). *(completed)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Exactly two task entries (512, 507) are edited, both by pure
description-append with no dependency change. Confirm before editing that their current
dependencies already match §4.4 (`512 <- [514]`, `507 <- [514, 512]`, verified true at
planning time); if not, this phase also corrects them and records the discrepancy.

**Files to modify**:
- `specs/state.json` - append §4.3 amendment texts to descriptions of 512 and 507
- `specs/TODO.md` - regenerated (never hand-edited)
- `specs/514_align_definitions_with_source_paper/state-before-board-surgery.json` - new snapshot

**Verification**:
- `jq empty specs/state.json` passes; both descriptions contain their §4.3 text verbatim;
  TODO.md regenerated without error.

---

### Phase 2: Amend downstream tasks 508, 509, 510 and set build-order dependencies [NOT STARTED]

**Goal**: The three downstream KEEP tasks carry their §4.3 amendments and the dependency
graph matches the §4.4 build order of record.

**Tasks**:
- [ ] Append the shared "508, 509 — append to each description" §4.3 block to both 508's and 509's descriptions (same `--rawfile` mechanics as Phase 1).
- [ ] Append the "510 — append to description" DELETE pre-registration block to 510's description.
- [ ] Set 509's `dependencies` to `[507, 508]` (build order: 508 -> 509). Leave 508 `[507]` and 510 `[507]` as-is (already conform).
- [ ] Verify: JSON validity; three descriptions contain their texts verbatim; dependency edges for 507-510 match §4.4 exactly.
- [ ] Regenerate TODO.md; commit (`task 514 phase 2: amend tasks 508-510 and build-order dependencies`).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Exactly three description-appends and exactly one dependency edit
(509: `[507]` -> `[507, 508]`), per the planning-time board snapshot. Confirm current
dependencies by jq before editing; if the board moved since planning, reconcile against §4.4
and record the delta.

**Files to modify**:
- `specs/state.json` - descriptions of 508, 509, 510; dependencies of 509
- `specs/TODO.md` - regenerated

**Verification**:
- `jq empty` passes; `jq` extraction shows 509 deps `[507, 508]`; all three amendment texts
  present verbatim.

---

### Phase 3: Revise 513 and close 511 [NOT STARTED]

**Goal**: 513 becomes the Galois-closure implementation task; 511 is closed terminal at
researched with its absorption note on the board.

**Tasks**:
- [ ] **Replace** task 513's `description` entirely with the §4.3 "513 — replace description entirely" text (blockquote prefixes stripped, structure preserved including the DELIVERABLES (1)-(6), ACCEPTANCE, and GROUNDING paragraphs). This is a replacement, not an append.
- [ ] Set 513's `dependencies` to `[512, 507]` (report: "Depends on 512 + 507"; parallel to 508/509).
- [ ] Consider whether 513's `project_name`/slug should change: it must NOT — renaming the directory/slug of an existing task is out of scope and breaks artifact paths; the revised description itself states the new scope.
- [ ] Append the §4.3 "511 — postflight note" text to 511's `description`, clearly marked as a board note (e.g. prefixed `=== BOARD NOTE (task 514 postflight) ===`). Status remains `researched` — do NOT transition 511 to any other status; the note is the terminal guard.
- [ ] Verify: JSON validity; 513's description no longer contains the uniform-faithfulness framing ("Faithful predicate" as an open question) and does contain all six DELIVERABLES items and the EXPLICIT NON-GOALS paragraph; 511 status still `researched`; 513 deps `[512, 507]`.
- [ ] Regenerate TODO.md; commit (`task 514 phase 3: revise 513 to galois-closure task, close 511`).

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `specs/state.json` - 513 description (full replacement) + dependencies; 511 description (append note)
- `specs/TODO.md` - regenerated

**Verification**:
- `jq empty` passes; 513 description matches §4.3 replacement verbatim; 513 deps
  `[512, 507]`; 511 status `researched` with note appended; TODO.md renders both.

---

### Phase 4: Reading note in paper-definitions-of-record.md [NOT STARTED]

**Goal**: The definitions-of-record file carries the §2.4 adjudication so future readers of
the three `app:*` anchors see the (T0)-vs-(T1) reading of record, without disturbing the
drift-detection machinery.

**Tasks**:
- [ ] Run `bash scripts/check-paper-definitions.sh` and record its verdict (before-state; a pre-existing case (b) is not a regression from this phase).
- [ ] Confirm by grep that the `app:discrete`, `app:dense`, `app:complete`, and `def:deterministic` anchor entries already exist in `specs/paper-definitions-of-record.md` (verified present at planning time — lines ~999-1060).
- [ ] Add a short reading-note subsection immediately after the three `app:*` anchor entries (one shared note, or one line per entry referencing it): the statements read as per-frame biconditionals (T0), whose (=>) direction is refuted by degenerate frames (staticFrame); the proofs prove and their closing sentences state the temporal-order-level biconditional (T1) `(forall F with order D, F validates ax) <-> D is X`, which is the reading of record for this repository. Cite report §2.4 by path. Place the note as prose OUTSIDE the ```latex blocks so no recorded per-anchor sha256 changes.
- [ ] Do NOT re-pin the whole-file checksum sentinels (prose note is not a drift correction).
- [ ] Re-run `bash scripts/check-paper-definitions.sh`; require a verdict identical to the before-state.
- [ ] Commit (`task 514 phase 4: record T1 reading note on app anchors`).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: All four anchors already exist and the entire touch is one prose note;
no new anchor, no hash change. Confirm by the grep and the before/after script runs; if an
anchor were missing after all, add it following the file's own coverage-extension procedure
and record the extension in the provenance table.

**Files to modify**:
- `specs/paper-definitions-of-record.md` - reading-note prose near the three `app:*` entries

**Verification**:
- `check-paper-definitions.sh` verdict unchanged before vs after; note present and cites
  report §2.4; no ```latex block modified (git diff shows prose-only additions).

---

### Phase 5: Board verification against acceptance criteria [NOT STARTED]

**Goal**: The revised board satisfies acceptance criteria (4) and (5) of the task
description, and the full deliverable set (1)-(5) is accounted for.

**Tasks**:
- [ ] Verify every task on the front (507-513) now cites the paper definition it targets: grep each description for its §4.3 grounding markers (`def:frame`, `cor:tm-completeness`, `def:soundness`, `def:frame-properties`, report path citations as applicable).
- [ ] Verify the dependency graph equals §4.4 exactly: 512 <- [514]; 507 <- [514, 512]; 508 <- [507]; 509 <- [507, 508]; 510 <- [507]; 513 <- [512, 507]; 511 unchanged (terminal).
- [ ] Verify no task asserts a superseded shape: 513 no longer poses the uniform-faithfulness question as open; 510 carries the DELETE pre-registration; no description still calls the ".Dedekind" naming conforming; confirm 492/493/494/495 descriptions were NOT modified (`git diff` over the task's commits touches only the seven front tasks).
- [ ] Final `jq empty specs/state.json`; final `bash .claude/scripts/generate-todo.sh`; confirm TODO.md and state.json agree.
- [ ] Record in the implementation summary: deliverables (1)-(3) live in the research report; (4)-(5) delivered by this board surgery; the 511-terminal-encoding note; the Phase 4 before/after script verdicts.
- [ ] Commit any residuals (`task 514 phase 5: board verification`).

**Timing**: 0.75 hours

**Depends on**: 3, 4

**Verification Tier**: local

**Files to modify**:
- none expected (verification phase; TODO.md regeneration only if a fix is needed)

**Verification**:
- All checks above pass; any discrepancy is fixed within this phase and re-verified, or
  recorded as [BLOCKED] with the specific failing check.

## Testing & Validation

- [ ] `jq empty specs/state.json` after every state.json write (hard gate per phase).
- [ ] Each injected §4.3 text diffs clean against its report source (modulo blockquote prefixes).
- [ ] `bash .claude/scripts/generate-todo.sh` exits 0 and TODO.md reflects all seven front tasks' revised entries.
- [ ] `bash scripts/check-paper-definitions.sh` verdict identical before/after Phase 4.
- [ ] `git diff` across the task's commits touches only `specs/**` (no Lean, no `.claude/**`).
- [ ] Dependency graph equals §4.4 build order of record.

## Artifacts & Outputs

- `specs/514_align_definitions_with_source_paper/plans/01_apply-board-revisions.md` (this file)
- Revised `specs/state.json` + regenerated `specs/TODO.md` (the board — acceptance deliverables 4 and 5)
- `specs/paper-definitions-of-record.md` reading note (§2.4 adjudication of record)
- `specs/514_align_definitions_with_source_paper/state-before-board-surgery.json` (rollback snapshot)
- `specs/514_align_definitions_with_source_paper/summaries/01_apply-board-revisions-summary.md` (implementation summary, written at postflight)

## Rollback/Contingency

All edits are `specs/**` text operations committed per phase. To revert: restore
`specs/state.json` from `state-before-board-surgery.json` (or `git revert` the phase
commits), re-run `generate-todo.sh`, and `git checkout` the pre-phase version of
`paper-definitions-of-record.md`. No build, Lean, or `.claude/**` state is touched, so
rollback carries no compilation risk.
