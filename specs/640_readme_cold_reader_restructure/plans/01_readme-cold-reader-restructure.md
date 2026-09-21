# Implementation Plan: Task #640

- **Task**: 640 - Readme cold reader restructure
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: Task 639 (completed — README factual corrections already landed)
- **Research Inputs**: specs/640_readme_cold_reader_restructure/reports/01_readme-cold-reader-restructure.md
- **Artifacts**: plans/01_readme-cold-reader-restructure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Restructure the root `README.md` so a reader who arrives cold and gives it two minutes learns
what is proved and how to verify it before line 40, rather than at line 166. The work is
prose-only across two files: `README.md` (four edits — a results summary hoisted to the top, two
revision-history paragraphs and one aside removed, a new "How this repository is developed"
section, one stale footer token) and `docs/reference/paper-definitions-of-record.md` (one dated,
prose-only note receiving the retired README claims). No `.lean` file, no anchor, no MANIFEST
row, and no `check-paper-definitions.sh` re-pin is touched. Both acceptance gates are green at
baseline and are re-run after every phase, not only at the end.

### Research Integration

The research report is load-bearing on four points that shape the phase order and content:

1. **The item-1 line budget has zero slack today.** Lines 1–40 are fully consumed: title (1),
   badges (3–7), three intro paragraphs (9, 11, 13), four link lines (15, 17, 19, 21), the
   protected generated inventory block (23–31), its explanatory paragraph (33–35), `---` (37),
   and `## Operators` at 39. A summary cannot be appended; something in that span must be
   compressed by a comparable number of lines first. Phase 3 budgets this line by line.
2. **One of the three revision-history passages needs no destination content.** The saturation
   footnote aside (README line 88) is already recorded, more precisely, at
   `docs/reference/paper-definitions-of-record.md:969-980`. Its README-side action is deletion
   (or replacement by a bare pointer), not migration.
3. **Deleting README lines 211 and 213 does not break C15.** Both anchors they cite
   (`cor:tm-completeness`, `def:BX-r`) recur elsewhere in the file — `cor:tm-completeness` at
   234, `def:BX-r` at 211 and 213 only. This was re-verified live during planning: the live
   anchor census is `211:cor:tm-completeness`, `211:def:BX-r`, `213:def:BX-r`,
   `233:def:BLplus-language`, `233:def:TMplus`, `234:cor:tm-completeness`,
   `242:app:deterministic-future`, `243:def:BLstar-semantics`, `328:def:frame-properties`.
   **`def:BX-r` occurs ONLY at 211 and 213** — deleting both paragraphs removes the anchor from
   README entirely. C15 resolves anchors that are cited; removing every citation of an anchor
   does not orphan anything, but Phase 2 must confirm this rather than assume it, because the
   research report's blanket claim ("each still cited at least once elsewhere") holds for
   `cor:tm-completeness` and **not** for `def:BX-r`.
4. **`readme-lint.sh` does not gate root `README.md`'s links under its default invocation** (its
   default root is `FormalSystem`). `check-module-invariants.sh`'s C12/C13 are the actual
   link/path gate for the root file. Both scripts are run in every phase; neither is treated as
   redundant with the other.

The research report's recommended edit ordering (items 2 and 4 before item 1) is adopted: the
deletions and the one-token rename shrink the file and de-risk the hardest edit before it is
attempted.

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so no roadmap consultation was
performed. `specs/ROADMAP.md` exists in the tree but was not loaded and is not modified by this
plan.

## Goals & Non-Goals

**Goals**:
- The first 40 lines of `README.md` state what is proved (soundness and weak completeness at all
  four frame classes; strong completeness proved at Base and Dense, machine-refuted at ZTime and
  RTime; zero sorry and zero custom axioms; the pinned axiom-set harness) and how to verify it,
  with links to `FormalSystem/MainResults.lean` and `docs/theorem-index.md`.
- No paragraph anywhere in `README.md` describes a previous state of the README or of the paper.
- A short "How this repository is developed" section states the trust model — correctness rests
  on the Lean kernel plus the invariant harness, not on review of agent output — and points to
  `docs/development/MODULE_INVARIANTS.md`.
- The `## Tags` footer carries no stale naming token.
- `bash scripts/check-module-invariants.sh --no-build` and `bash scripts/readme-lint.sh` are both
  green after every phase.

**Non-Goals**:
- Re-verifying any factual claim task 639 already settled. This task reorders, prunes, and adds
  prose; it does not re-derive counts, axiom sets, or theorem statements.
- Touching any `.lean` file, any anchor, any MANIFEST row, or any checksum in
  `docs/reference/paper-definitions-of-record.md`. The addition there is prose-only, matching
  that file's own "Language correspondence (2026-09-08): permanent, prose only, no re-pin"
  precedent.
- Editing the generated inventory block (README lines 23–31) or its numbers by hand.
- Rewrapping README lines 272–276. The phrase "the 45 TM schemata" escapes C14's
  stale-count regex only because "the 45 TM" ends one source line and "schemata re-declared"
  begins the next; C14 matches per line. Do not reflow that paragraph.
- Restructuring `## Metalogical Results` (lines 169–345) itself. The results summary added at the
  top is a *pointer and a précis*, not a relocation of that section.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Item 1 treated as purely additive; summary pushes `## Operators` past line 40 | H | H | Phase 3 budgets line by line against the exact inventory above; it compresses *before* it adds, and counts `grep -n '^## Operators' README.md` as its own verification criterion |
| Hand-editing or displacing the generated inventory block (lines 23–31) | H | M | Phase 3 treats the `BEGIN GENERATED` / `END GENERATED` markers and the paragraph immediately below them as one immovable unit; `check-module-invariants.sh`'s `INV` gate diffs the table content, not merely its presence |
| Deleting README 211/213 assumed to require anchor cleanup, or assumed safe without checking | M | M | Phase 2 re-runs the anchor census before and after and compares; `def:BX-r` genuinely leaves the file and that is expected, `cor:tm-completeness` must survive at line 234 |
| The new note in `paper-definitions-of-record.md` paraphrases or re-derives paper text, violating that file's "never restates, re-derives, or improves any definition it records" charter | H | M | Phase 2's note describes the **README's own prior claim** and points at the already-pinned `def:BX-r` (line ~1560) and `cor:tm-completeness` (line ~1713) entries for the current fact; it quotes no paper text |
| A count phrase in newly authored prose trips C14's stale-axiom-count regex | M | L | Phases 3 and 4 use the wording "zero sorry and zero custom axioms" and the already-published figure **105** (README line 415); no new digit-then-schema-word phrase is introduced |
| A task number leaks into `README.md` or `docs/` | M | M | `.claude/rules/no-task-references-in-deliverables.md` applies to both files. Every phase that authors prose outside `specs/**` cites durable anchors (filenames, headings, dates) and never "task N"; Phase 5 greps for the pattern |
| A partial edit transiently breaks a link or anchor and is committed | M | L | Both gates run at the end of every phase; a phase is not closed on a red gate |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is a strict chain: every phase
edits the same file (`README.md`), so no two phases may run concurrently regardless of whether
their edit regions overlap textually.

---

### Phase 1: Baseline capture and Tags footer rename [COMPLETED]

**Goal**: Record both acceptance gates green before any edit, then land item 4 — the smallest,
lowest-risk change — to confirm the edit-then-verify loop works end to end.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and record the verdict verbatim.
      Expected: `ALL CHECKS PASSED`. *(completed: verdict was `ALL CHECKS PASSED`)*
- [x] Run `bash scripts/readme-lint.sh` and record the verdict verbatim. Expected: `RESULT: PASS`
      with 0 missing READMEs and 0 broken references. *(completed: `RESULT: PASS`, 0 missing, 0 broken)*
- [x] Record the pre-edit anchor census:
      `grep -noE '\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*' README.md` *(completed: matches plan's expected baseline exactly)*
- [x] Record the pre-edit position of the first section heading: `grep -n '^## ' README.md | head -3` *(completed: 39:## Operators)*
- [x] Locate the Tags footer: `grep -n 'TM-plus' README.md` (expected: exactly one hit, the final
      line of the file). *(completed: exactly one hit, line 478)*
- [x] Replace the token `TM-plus` with `TM⁺` in the `## Tags` footer line, matching the live
      naming used in `docs/README.md`, `docs/theorem-index.md`, `FormalSystem/README.md`, and
      README's own four-object-languages table. Rename rather than drop the footer: dropping it
      removes searchable metadata (`bimodal-logic`, `soundness`, `completeness`, `compactness`,
      `decidability`, `lean4`) that has no other home in the README. *(completed)*
- [x] Re-run both gates; confirm both still green. *(completed: both green)*
- [x] Commit. *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `TM-plus` is asserted to occur exactly once in `README.md`, on the final
line (478) inside the `## Tags` footer, and nowhere else under `docs/` or `FormalSystem/`.
Confirm at implementation time with `grep -rn 'TM-plus' README.md docs/ FormalSystem/`; if the
count differs from one, stop and re-scope before editing.

**Files to modify**:
- `README.md` — the `## Tags` footer line only: `TM-plus` → `TM⁺`.

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` → `ALL CHECKS PASSED`
- `bash scripts/readme-lint.sh` → `RESULT: PASS`
- `grep -c 'TM-plus' README.md` → 0
- The baselines from the first four tasks are recorded in the phase's progress notes, so later
  phases can diff against them rather than re-deriving them.

---

### Phase 2: Retire revision-history narration [COMPLETED]

**Goal**: Remove the three passages that describe a previous state of the README or of the
paper's text, and record the two that have no existing counterpart in
`docs/reference/paper-definitions-of-record.md`. After this phase, the README states what is
true now and narrates no history.

**Tasks**:
- [x] Re-locate all three passages by content, not by line number (Phase 1's rename shifted
      nothing above them, but confirm anyway):
      - The saturation-footnote aside, in the *Saturation* bullet: the trailing clause
        "— the footnote said *strictly stronger* until the paper's 2026-09 revision withdrew the
        strictness claim."
      - The paragraph beginning "Earlier revisions of this README described the paper's
        complete-order system as completeness *simpliciter*…"
      - The paragraph beginning "The axiom-basis question this README used to record as open is
        answered as well:…" *(completed: all three located by content match)*
- [x] **Saturation aside — delete only.** This fact is already recorded, more precisely, at
      `docs/reference/paper-definitions-of-record.md:969-980` (the `def:frame#Saturation`
      entry's "2026-09-07 wave" note). Do **not** copy it into the record a second time. End the
      bullet at "…which the paper's footnote places as *at least as strong as* 'spherically
      complete' (`S₁`)." A bare pointer to the record file for the definition's revision history
      is an acceptable optional addition — a pointer states where history lives, it does not
      narrate it. *(completed: bullet now ends at "spherically complete (S₁)."; no pointer added)*
- [x] **Add the destination note in `docs/reference/paper-definitions-of-record.md` before
      deleting from README**, so no fact is ever in flight. Append a short `Note:` to the
      `def:BX-r` entry (heading `### \`def:BX-r\` — the dense-and-complete Burgess–Xu tense logic
      BX_r …`, around line 1560), following the file's existing entry-level note convention (see
      the `Note: promoted into coverage by this task…` at ~line 1677). The note must:
      - state what the README used to claim (completeness *simpliciter* with models `{ℤ, ℝ}` and
        theory `Th(ℤ) ∩ Th(ℝ)`; the axiom-basis question recorded as open),
      - state that both are retired, pointing at this entry and at `cor:tm-completeness`
        (~line 1713) for the current text,
      - carry a date in the file's own `(YYYY-MM-DD)` style and the file's "prose only, no
        re-pin" marker,
      - **quote or re-derive no paper text.** The charter of this file is that it never restates,
        re-derives, or improves any definition it records. Describe the README's prior claim;
        point at the already-pinned entries for the current fact.
      - contain no task number (`.claude/rules/no-task-references-in-deliverables.md` applies —
        `docs/` is not `specs/`). "by this task" with no number, as the file already uses, is
        fine. *(completed: note appended after the def:BX-r sha256 line, dated 2026-09-20, prose
        only, no re-pin, points at cor:tm-completeness)*
- [ ] If the note grows past a few sentences, prefer a new top-level dated section following the
      format of `### Language correspondence (2026-09-08): permanent, prose only, no re-pin`
      (line 265) instead of an entry-level note. Either placement leaves
      `scripts/check-paper-definitions.sh`'s verdict unchanged. *(deviation: skipped — the note
      stayed short enough (6 sentences) to keep as an entry-level note; no top-level section
      needed)*
- [x] Delete the two README paragraphs. The surrounding text must still read continuously: the
      paragraph above them ("**`FrameClass.RTime` is the paper's TM_r.** Under the paper's
      current text, `cor:tm-completeness` gives TM_r as weakly complete over `ℝ`-time … which is
      exactly what `FrameClass.RTime` denotes: `DenselyOrdered D` plus Dedekind completeness.")
      is a complete, currently-true statement and stays; only the "Earlier revisions…" sentence
      onward is removed. *(completed)*
- [x] Re-run the anchor census and diff against Phase 1's baseline. Expected delta: both
      `def:BX-r` occurrences gone (the anchor leaves README entirely — this is expected, not a
      defect), one of two `cor:tm-completeness` occurrences gone (line 234's survives).
      *(completed: delta matched exactly)*
- [x] Re-run both gates. C15 must stay green. *(completed: both green, check-paper-definitions.sh
      verdict unchanged — case (b), 42 recorded definitions unchanged)*
- [x] Commit. *(completed)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: three passages are asserted, at README lines 88, 211, and 213 as of the
research baseline. Confirm at implementation time by content match (the three quoted openings
above), not by line number, and confirm the count is exactly three — a fourth
previous-state paragraph elsewhere in the file would widen this phase. Search for others with
`grep -niE 'earlier revision|used to (record|say|describe)|previously (said|described)|until the paper|no longer (says|reads)' README.md`.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` — one dated prose-only note appended to the
  `def:BX-r` entry (or one new dated top-level section). No anchor, MANIFEST row, or checksum is
  added, removed, or re-hashed.
- `README.md` — delete the saturation-footnote aside clause; delete the "Earlier revisions of
  this README described…" paragraph; delete the "The axiom-basis question this README used to
  record as open…" paragraph.

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` → `ALL CHECKS PASSED` (C15 in particular)
- `bash scripts/readme-lint.sh` → `RESULT: PASS`
- `bash scripts/check-paper-definitions.sh` → verdict unchanged from its pre-edit value (prose
  change only)
- `grep -niE 'earlier revision|used to record|until the paper.s 2026-09 revision' README.md` → no
  hits
- The anchor census diff matches the expected delta stated above, with `cor:tm-completeness`
  still present.

---

### Phase 3: Cold-reader results summary in the first 40 lines [NOT STARTED]

**Goal**: Put a short results summary directly under the opening paragraph, inside the first 40
lines, without hand-editing or displacing the generated inventory block. This is the phase the
acceptance bar turns on and the one with no line-budget slack.

**Tasks**:
- [ ] Re-derive the current line inventory before editing:
      `grep -n '^## Operators' README.md` and `grep -n 'BEGIN GENERATED\|END GENERATED' README.md`.
      The budget is whatever these report now, not the research baseline.
- [ ] **Compress before adding.** The only compressible material above the `---` is: the three
      intro paragraphs (the opening paragraph, the "Whereas dynamical systems theory…" paragraph,
      and the "The repository implements the syntax…" paragraph) and the four link lines
      (**Paper**, **Bimodal Reference Manual**, **Main Results**, **Demo**). The badges are fixed;
      the generated block and the paragraph explaining its regeneration command are protected and
      move together as a unit. Two workable compressions, either of which frees enough room:
      - merge the "Whereas dynamical systems theory…" and "The repository implements the syntax…"
        paragraphs into one, and/or
      - fold the **Main Results** and **Demo** link lines into the summary itself as its closing
        links, leaving **Paper** and **Bimodal Reference Manual** as the separate block.
- [ ] Author the summary as a short paragraph or 4–6 tight bullets placed immediately under the
      opening paragraph. It must state:
      - soundness and weak completeness at **all four** frame classes — Base, Dense, ZTime, RTime;
      - strong completeness **proved** at Base and Dense (`strongCompletenessBase`,
        `strongCompletenessDense`, via an ultraproduct compactness argument) and
        **machine-refuted** at ZTime and RTime (`notStrongCompletenessZTime`,
        `notStrongCompletenessRTime`). Write the refutations as results, not gaps — they are
        theorems;
      - zero sorry and zero custom axioms in the live tree: every flagship result depends on
        exactly `[propext, Classical.choice, Quot.sound]`, Lean's own standard classical axioms,
        with no `sorryAx`;
      - the pinned axiom-set harness: `scripts/check-module-invariants.sh` pins the axiom sets of
        **105** declarations, and a change to any of them is a hard stop rather than a new
        baseline. Reuse the figure 105 exactly as the existing "Verifying the main theorems"
        section states it (README ~line 415); do not re-derive it.
- [ ] Link `FormalSystem/MainResults.lean` and `docs/theorem-index.md` from the summary. Both
      already have a home in the file (the **Main Results** link line, and the "single ledger"
      pointer); reuse those exact targets and link texts rather than inventing new ones.
- [ ] Introduce no new numeric axiom-count phrase (29/37/40/39/42/45 followed by a schema word) —
      C14's stale-count regex matches per line. "Zero sorry and zero custom axioms" and the
      figure 105 are both safe.
- [ ] Confirm the budget held, then re-run both gates and commit.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the first-40-lines budget is asserted to have zero slack, with
`## Operators` currently the first section heading and the generated block occupying 9 lines plus
a 3-line explanatory paragraph. Confirm at implementation time with
`grep -n '^## Operators' README.md` and `grep -n 'GENERATED' README.md` **before** drafting, and
treat the number of lines that must be freed as (summary length) − (slack found), computed from
those live numbers rather than from this plan's figures.

**Files to modify**:
- `README.md` — compress the intro paragraph block and/or the link-line block; insert the results
  summary directly under the opening paragraph.

**Verification**:
- `grep -n '^## Operators' README.md` reports a line number ≤ 40 — the acceptance bar. If the
  first section heading has changed identity because of the compression, the equivalent check is
  `grep -n '^## ' README.md | head -1`.
- Reading lines 1–40 aloud answers, for a reader with no context: what is proved, at which frame
  classes, what is refuted, and which two commands verify it.
- `sed -n '/BEGIN GENERATED/,/END GENERATED/p' README.md` is byte-identical to its pre-edit value.
- `bash scripts/check-module-invariants.sh --no-build` → `ALL CHECKS PASSED` (the `INV` gate in
  particular, which diffs the generated table's content).
- `bash scripts/readme-lint.sh` → `RESULT: PASS`

---

### Phase 4: "How this repository is developed" section [NOT STARTED]

**Goal**: Add a short section telling a reader who opens `specs/` or `CLAUDE.md` that development
is agent-assisted under a task system, and that correctness rests on the Lean kernel plus the
invariant harness rather than on review of agent output.

**Tasks**:
- [ ] Place the section where it carries no line-40 constraint — immediately after `## Installation`
      and before `## Metalogical Results` is the natural reading position (a reader who has just
      built the project is the one who would next wonder how it is maintained). The
      `## Documentation` / `## Related Projects` neighborhood is an acceptable alternative.
- [ ] Author the section. It is new content, not relocated content: no existing prose in
      `README.md`, `docs/`, or `CONTRIBUTING.md` currently states this trust model. It must:
      - say that development is agent-assisted, driven by a task system whose artifacts live in
        `specs/` (git-tracked, and therefore visible to anyone browsing the repository);
      - frame `CLAUDE.md` accurately as something a **local contributor** opens — it is
        gitignored (`.gitignore` line 80, `/CLAUDE.md`) and is not visible on the GitHub page.
        Do not imply a reader will find it in the repository listing;
      - state the trust model plainly: correctness is not established by reviewing agent output.
        It rests on the Lean kernel (every headline result is machine-checked, sorry-free, with
        its axiom set printed) plus the invariant harness (which turns "nothing broke" into a
        command with an exit code);
      - link `docs/development/MODULE_INVARIANTS.md` as the primary target. That file opens with
        exactly this framing and carries the per-check table (C1–C30) of what is asserted.
- [ ] Add a secondary pointer to `CONTRIBUTING.md`'s existing `## 10. AI-Assisted Development`
      section for the *workflow* half (what the commands do), keeping this new section focused on
      the *epistemics* half. The two must be complementary, not duplicative — do not restate
      CONTRIBUTING.md's command list here.
- [ ] Cross-check against `## Verifying the main theorems` (further down the file) so the two
      sections agree and neither contradicts the other. This section asserts the trust model; that
      one gives the commands.
- [ ] Use no task numbers. `.claude/rules/no-task-references-in-deliverables.md` applies to
      `README.md`; cite durable anchors (filenames, section headings) instead.
- [ ] Re-run both gates and commit.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `README.md` — one new `## How this repository is developed` section, roughly one short
  paragraph plus its two links.

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` → `ALL CHECKS PASSED`. C12/C13 are the
  real gate on the two new links (`docs/development/MODULE_INVARIANTS.md`, `CONTRIBUTING.md`) —
  `readme-lint.sh` under its default root does not check root README's links.
- `bash scripts/readme-lint.sh` → `RESULT: PASS`
- `grep -n 'MODULE_INVARIANTS' README.md` resolves to an existing file.
- `grep -n '^## Operators' README.md` (or the first-heading equivalent) is still ≤ 40 — the new
  section must sit below the fold and must not have displaced Phase 3's work.

---

### Phase 5: Acceptance verification [NOT STARTED]

**Goal**: Confirm every acceptance criterion against the finished file, as a distinct pass rather
than as a side effect of the last edit.

**Tasks**:
- [ ] Read `README.md` lines 1–40 end to end as a cold reader would and confirm they state what
      is proved and how to verify it.
- [ ] Sweep for any surviving previous-state narration across the whole file:
      `grep -niE 'earlier revision|used to (record|say|describe)|previously (said|described|read)|no longer (says|reads)|until the paper' README.md`
- [ ] Confirm the generated block is untouched: run
      `bash scripts/check-module-invariants.sh --emit-inventory`, then `git diff README.md` must
      show no change inside the `BEGIN GENERATED` / `END GENERATED` span.
- [ ] Confirm no task-number reference leaked into either edited file:
      `grep -niE '\btasks? [0-9]+\b' README.md docs/reference/paper-definitions-of-record.md`
- [ ] Confirm README lines ~272–276 were not reflowed: the phrase "the 45 TM" must still end one
      source line with "schemata re-declared" beginning the next.
- [ ] Run the full gate set, including the build this time:
      `bash scripts/check-module-invariants.sh` (no `--no-build`) and `bash scripts/readme-lint.sh`.
- [ ] Commit the completion and write the execution summary.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that both gates are green and that all five acceptance
items are satisfied. Every assertion is confirmed by running the named command and reading its
verdict, never by inspection alone; a red gate closes nothing.

**Files to modify**:
- None (verification only). `specs/640_readme_cold_reader_restructure/summaries/01_*-summary.md`
  is authored by implement postflight, not by this phase's edits.

**Verification**:
- `bash scripts/check-module-invariants.sh` → `ALL CHECKS PASSED`
- `bash scripts/readme-lint.sh` → `RESULT: PASS`
- `bash scripts/check-paper-definitions.sh` → verdict unchanged from Phase 1's baseline
- All five acceptance items checked off in the Testing & Validation list below.

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` (full, with build) → `ALL CHECKS PASSED`
- [ ] `bash scripts/readme-lint.sh` → `RESULT: PASS`, 0 missing READMEs, 0 broken references
- [ ] `bash scripts/check-paper-definitions.sh` → verdict unchanged from pre-edit baseline
- [ ] Acceptance 1: the first 40 lines of `README.md` state what is proved and how to verify it
- [ ] Acceptance 2: no paragraph in `README.md` describes a previous state of the README
- [ ] Acceptance 3: `## How this repository is developed` exists and links
      `docs/development/MODULE_INVARIANTS.md`
- [ ] Acceptance 4: `grep -c 'TM-plus' README.md` → 0
- [ ] Acceptance 5: the generated inventory block is byte-identical to its regenerated form, and
      every anchor `check-module-invariants.sh` checks still resolves

## Artifacts & Outputs

- `README.md` — restructured: results summary in the first 40 lines, three revision-history
  passages removed, one new section, one footer token renamed, generated block untouched.
- `docs/reference/paper-definitions-of-record.md` — one dated, prose-only note recording the two
  retired README claims. No anchor, MANIFEST row, or checksum changed.
- `specs/640_readme_cold_reader_restructure/summaries/01_readme-cold-reader-restructure-summary.md`
  — execution summary (written at implement postflight).

## Rollback/Contingency

Every phase commits separately, so any single phase reverts with `git revert` of its own commit
without disturbing the others. The phases are independent in content even though they are
serialized in execution: the Tags rename, the revision-history removal, the results summary, and
the new section can each be dropped on its own.

If Phase 3's line budget proves unmeetable without compressing something that should not be
compressed — for example if the only remaining slack would come from the generated block's
explanatory paragraph — stop rather than sacrifice it. Removing that paragraph would strand an
unexplained table in front of the cold reader, working directly against this task's own goal.
Report the budget shortfall with the exact line arithmetic and let the ordering question (whether
the badges or the Paper/Reference-Manual links should move below the fold) come back as a
decision rather than be settled silently inside an implementation phase.

Before any risky multi-hunk rewrite of the first 40 lines, take a non-reverting checkpoint with
`bash .claude/scripts/git-snapshot.sh 640 --no-revert`; this is durable without touching the
working tree. Reserve the default (reverting) form for a genuine rollback.
