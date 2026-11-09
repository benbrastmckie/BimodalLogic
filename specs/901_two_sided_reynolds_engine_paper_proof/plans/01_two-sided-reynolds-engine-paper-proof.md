# Implementation Plan: Task #901

- **Task**: 901 - Paper proof of the two-sided Reynolds engine for L-plus at ZTime: ban preservation, fair scheduling, universal non-acceptance, truth lemma
- **Status**: [IMPLEMENTING]
- **Effort**: 3.0 hours
- **Dependencies**: None
- **Research Inputs**: `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`
- **Artifacts**: plans/01_two-sided-reynolds-engine-paper-proof.md (this file)
- **Standards**:
  - `context/formats/plan-format.md`
  - `context/standards/status-markers.md`
  - `context/standards/artifact-management.md`
  - `context/formats/summary-format.md`
  - `context/standards/git-staging-scope.md`
  - `context/patterns/backlog-reconciliation.md`
  - `rules/state-management.md`, `rules/git-workflow.md`, `rules/pr-prohibition.md`
- **Type**: formal
- **Lean Intent**: false

## Overview

The dispatch asks for one thing — "RESEARCH TASK, report only" — and the research dispatch
delivered it: a 1002-line write-up at Reynolds-2001 §9-§15 rigour covering all nine enumerated
components, with the two located questions recorded, the Muller-sufficiency split verdict inherited
as a settled premise, and the Lean prohibition honoured. Nothing substantive remains to be *found*,
and nothing in the write-up is to be re-derived here.

What remains is to land the write-up's consequences in the records other tasks read, and to hand
forward the two paper questions this repository can own, while taking none of the actions the
report explicitly declines. Accordingly this is a **record-and-handoff plan**, not an
implementation plan in the usual sense. Its three substantive phases amend the architecture
report that this write-up corrects (its `LCU` inventory, now stale; its separation-consumption
point, now split; its automaton initialisation, now avoidable), file the two ownable follow-up
questions with backlog evidence, and write the close-out record that states explicitly which
recommendations are deliberately not acted on and why. No Lean source, no build file, no
dependency declaration, and nothing under `FormalSystem/` or `Tests/` is touched by any phase.

### Research Integration

The report is the sole substantive input, and every phase consumes a named part of it rather than
re-deriving anything:

- **Recommendation 1 and Finding 17's "one correction"** supply Phase 1 in full: the architecture
  report's ingredient row 2 (`LCU` and mirror, declared and ZTime-valid) is recorded **missing**
  and is in fact landed — `lcU` (`PlusLCSchema.lean:248`), `lcU_plusValidInt` (`:409`),
  `lcU_plusValidZTime` (`:464`), `lcU_reflectTime_plusValidZTime` (`:486`), all four re-confirmed
  compiled at plan time by direct grep. Task 893 is the `completed` task that landed them, so the
  architecture report's `covered-by-closed 864/871 on P1 — not covered` audit note is now
  superseded by a *closed* coverer rather than being wrong when written.
- **Recommendation 2** supplies Phase 2's first half: Finding 4.3's split consumption point
  (S1)/(S2), and Finding 5.4's first-transition indexing, which supersedes the architecture
  report's "its initial state is a function of `γ_{colour(w₀)}`, so `θ_f` can state it". The
  report is explicit that the current text is *correct but avoidable*, and that the avoidable
  version is the one a formalization should state.
- **Recommendation 3** supplies Phase 2's second half: the full-product lemma (ingredient row 8)
  and the linear bridge (row 9) each gain a second consumer — the alphabet collapse of
  Findings 1.3/4.4 and derivable separation of Lemma 7.2 respectively. The report states that the
  *statements* do not change, only what cites them, so Phase 2 annotates the rows and writes no
  new Lean target.
- **Recommendations 5, 6 and 7** supply Phase 3: (Q3) — is the cross-certification of
  Finding 14.4 eliminable — is called "cheap to attempt", "strictly cheaper than anything in
  Finding 17", and answerable against the chronicle clauses alone; (Q1) is to be pursued through a
  **non-ZTime** separating model, because Finding 16.1 derives that no ZTime countermodel can
  settle it (both `lcN` and `lcU` are ZTime-valid, compiled); (Q2) is to stay framed as
  *admissibility*, which the landed `clock_irr_sound`/`irr_sound` do not bear on. The first two are
  filed; (Q2) has no actionable settling route beyond its framing and is recorded, not filed.
- **Recommendations 4 and 8** are standing no-ops and become Non-Goals: do not file the level
  split as a Lean item (it is a change to the chronicle *definition*, and chronicles are stages
  C-F, all `paper`, all behind (O1)/(O3)); do not file a Lean formalization of any part of
  §§7-15; do not re-open the CSLib `require` question.
- **Finding 17** fixes the Lean position as unchanged — (O1), (O3), (O4) live, (O2) discharged —
  and states why nothing in the write-up moves any of them. Phase 4 records that, so no later
  reader mistakes the write-up for a licence to formalize.

### Prior Plan Reference

No prior plan for this task. The sibling task 902's plan
(`specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md`,
`[COMPLETED]`) is used for effort calibration only: it is the same shape of work — a
research-only task whose plan amends the same architecture report, files audited follow-ups, and
closes out — and it measured four phases at 0.75 hours each with every anchor matching once. Its
Phase 1 notes also record two calibration lessons adopted here: a verification criterion of the
form "each anchor grep still matches once after the edit" is **unsatisfiable** for an anchor whose
own text the phase replaces, so each anchor below states which half is kept and counted; and the
`[IN PROGRESS]` marker is to be set before a phase's first edit, not after. No phase is copied.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` in this dispatch, so no roadmap context was loaded and no
roadmap phase is added. `specs/ROADMAP.md` is not read, consulted, or written by any phase.

## Goals & Non-Goals

**Goals**:

- The architecture report
  (`specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`)
  states `LCU`'s landed status at all eight points where it asserts the stale one — the
  declaration-inventory row, the `ExtSound` sentence, Finding 2.3's consequence (i), the stage-D
  and stage-I rows, ingredient row 2, the P1 backlog-audit note, and the executive summary's
  "Missing:" list — each amendment citing `PlusLCSchema.lean`'s four declarations and task 893,
  under one dated amendment note.
- The same report's Finding 2.4 records the split consumption point (S1)/(S2) and the
  first-transition indexing that makes a colour-dependent initial state unnecessary; its ingredient
  rows 8 and 9 name their second consumers; and its Cross-Domain Synthesis no longer says the
  semantics' defining feature "pays for itself exactly once".
- Two `not_started` tasks exist with backlog-reconciliation evidence on each entry: the (Q3)
  cross-certification-elimination paper question, and the (Q1) non-ZTime separating-model question.
- A close-out record states what was amended, what was filed, and — explicitly, so that none of it
  reads as an oversight — that no Lean source was written, no level-split Lean item was filed, no
  CSLib `require` was added or re-opened, the Lean position (O1)/(O3)/(O4) is unchanged, and (Q2)
  was deliberately recorded rather than filed.

**Non-Goals**:

- No change under `FormalSystem/` or `Tests/`, and no new Lean source anywhere. This plan declares
  `Lean Intent: false` and writes no `.lean` file. No `lake` invocation and no Lean process is
  started by any phase.
- No edit to `lakefile.toml` or `lake-manifest.json`, and no `require` on CSLib in any form.
  Recommendation 8 is a standing no-op, recorded rather than executed.
- **No Lean formalization of any part of the write-up's §§7-15**, per the dispatch's standing
  prohibition and Recommendation 8. The located obstruction (O1)/(O3) is unresolved and nothing in
  the write-up moves it.
- **No filing of the level split as a Lean item**, per Recommendation 4: it is a change to the
  chronicle *definition*, and every chronicle stage is `paper` and behind (O1)/(O3). Filing it
  would create a Lean task with no reachable target.
- No re-derivation, condensation, or rewrite of the report itself. It is the task's deliverable and
  is already delivered; Phase 1-3 cite it and do not amend it.
- No completeness claim, and no amendment that could be read as lifting the Lean NO-GO or as
  claiming T1/T2/T3. The write-up claims the engine up to the final-frame step and no further.
- No PR, no push, no `gh`/`glab` write operation (`rules/pr-prohibition.md`).
- No redeploy of `.claude/`. The dispatch reports the deployed tree as stale for six extensions and
  the remedy is a whole-tree regeneration that is not this task's work; accordingly no phase lists
  the reserved whole-tree sentinel.
- No hand-authored file under `.claude/**` (`rules/source-store-deploy-boundary.md`).
- No `specs/ROADMAP.md` edit or read.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A Phase 1 amendment reads as lifting the Lean NO-GO, since `LCU` landing removes one named "missing" ingredient | H | M | Row 2 is one of nine missing rows and is unrelated to (O1)/(O3). Phase 1's verification reads back that `NO-GO on a Lean proof` still occurs, that the eight remaining missing rows are byte-identical, and that row 16 (the determinization gap, already amended by 902/903) is untouched. The amendment note states "one ingredient row moves to landed; the NO-GO's ground is untouched". |
| An anchor's text has drifted since plan time, so an edit lands in the wrong place | M | L | Every one of the 14 anchors was confirmed at plan time by `grep -cF` returning exactly 1, with its line number recorded in the phase text. Each phase re-greps immediately before editing and, on a count mismatch, re-locates by content and records the discrepancy rather than editing blind; on an absent anchor it skips that edit and says which in the phase notes. |
| A verification criterion of the form "the anchor still matches once" is unsatisfiable for an anchor the phase replaces | M | H | Measured in the sibling task's Phase 1 notes, where three of six such criteria were unsatisfiable by construction. Each anchor below names the half that is *kept* and counted, so every criterion is satisfiable as written. |
| A filed proposal duplicates an open task (895 owns the AA rule; 896/897 own the invariance and cover pieces) | M | M | `audit-task-proposals.sh` runs over both proposals before any write, and `state-write.sh`'s audit-evidence gate refuses the write unless a verdict object covers each new entry. Phase 3 carries a decision gate: on a surviving `duplicate-of-open`/`subset-of-open`, narrow or drop the proposal rather than filing it unchanged, and record the disposition. |
| (Q3) is filed as a task and then absorbs scope — attempting the elimination rather than assessing it | M | M | The filed description states the deliverable as an answer with its argument, bounds it to the chronicle clauses of the write-up's Finding 8.2 plus the clause-(a)s of Finding 5.2, and declares `report only` with `file_scope: []`. Phase 3's verification reads the filed description back for the `report only` clause. |
| (Q1) is filed and a future dispatch reaches for a ZTime countermodel anyway | M | M | Finding 16.1 derives that no ZTime frame separates the two schemata (both `lcN_plusValidZTime` and `lcU_plusValidZTime` compiled), so the filed description names the derivation, names `.Base` as the first target, and states the ZTime route as refuted in advance. |
| The amendments to the architecture report collide with a concurrent writer on the same file | M | L | Both touching phases are serialized (Phase 2 depends on Phase 1) rather than placed in one wave, so no two phases of this plan write that file at once. Each commits by explicit path via `git-commit-phase.sh`/`git-commit-scoped.sh`, never a directory or glob pathspec. |
| The full gate set is unavailable in this dispatch | L | M | Phase 4 follows a `## Batch Gate Deferral` directive if the dispatch carries one, recording the deferral in the summary's Verification section rather than claiming a gate run that did not happen. |
| The dispatch's deploy-freshness warning tempts a redeploy mid-plan | M | L | Declared a Non-Goal. A redeploy is a whole-tree-regeneration claim belonging to its own task; no phase lists the reserved whole-tree sentinel because no phase regenerates the tree. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phases 1 and 3 touch disjoint files — the
architecture report versus `specs/state.json`/`specs/TODO.md` plus two new evidence files in this
task's directory — and neither consumes the other's output. Phase 2 is serialized behind Phase 1
because both write the same report file, not because it consumes Phase 1's content. Phase 4 is the
terminal node and depends, transitively, on every other phase.

### Phase 1: Record `LCU` as Landed Across the Architecture Report [COMPLETED]

**Goal**:
`specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
states `LCU`'s landed status at every point where it asserts the stale "undeclared"/"missing"
position, each amendment citing the four compiled declarations and task 893, under one dated
amendment note, with the Lean NO-GO's ground untouched.

**Tasks**:
- [x] Set this phase's heading to `[IN PROGRESS]` **before** the first edit. *(completed)*
- [x] Re-confirm the four declarations are still compiled, by name and line, before amending
  anything:
  `grep -n '^def lcU\|^theorem lcU_plusValidInt\|^theorem lcU_plusValidZTime\|^theorem lcU_reflectTime_plusValidZTime' FormalSystem/PlusLanguage/PlusLCSchema.lean`
  — four hits expected at lines 248, 409, 464, 486 (measured at plan time). This is a grep against
  source text, not a build; do not start a Lean process. If a declaration is absent, **stop this
  phase** and record a blocker rather than amending the report to say "landed". *(completed:
  re-confirmed at implementation time, exactly at lines 248, 409, 464, 486 — unchanged from plan
  time)*
- [x] Re-confirm each of the eight anchors still matches exactly once (`grep -cF`, counts and
  plan-time line numbers in a 290-line file):
  `**undeclared** (871 confirmed` (1, line 82) ·
  ``additionally needs `LCU`'s ZTime validity`` (1, line 123) ·
  `both **undeclared** — P1` (1, line 151) ·
  ``needs `LCU` declared`` (1, line 174) ·
  ``and `LCU` validity (P1)`` (1, line 179) ·
  ``| 2 | `LCU` and mirror`` (1, line 188) ·
  `covered-by-closed 864/871` (1, line 213) ·
  ``Missing: `LCU` declared and valid`` (1, line 36).
  On a count mismatch, re-locate by content rather than editing blind; on an absent anchor, skip
  that edit and record which in the Phase 1 notes. *(completed: all eight anchors re-confirmed at
  implementation time, each matching exactly once at the exact plan-time line numbers — no drift)*
- [x] Amend the declaration-inventory row (line 82): replace
  `**undeclared** (871 confirmed; its docstring says so)` with a compiled status citing
  `PlusLanguage/PlusLCSchema.lean:248` and the three validity theorems at `:409,464,486`, and fill
  the row's middle (evidence) cell, which currently holds `—`. Keep the row's first cell
  (`` `LCU` ``) byte-identical and the table's pipe structure intact. *(completed)*
- [x] Amend the `ExtSound` sentence (line 123): ``ExtSound IsLCUAxiom _` additionally needs
  `LCU`'s ZTime validity (missing; semantic core landed by 871)`` — keep the clause naming what it
  needs, replace `(missing; semantic core landed by 871)` with the landed citation. *(completed)*
- [x] Amend Finding 2.3's consequence (i) (line 151): the clause `both **undeclared** — P1 in
  finding 3` becomes a landed statement naming `lcU` and `lcU_reflectTime_plusValidZTime`. Leave
  the rest of consequence (i) — that `LCU` and its mirror are the schema of record, ZTime-valid at
  the semantic level — byte-identical, since the write-up confirms rather than disturbs it.
  *(completed)*
- [x] Amend the stage-D row (line 174): drop the parenthetical `**needs `LCU` declared** (P1)` per
  Recommendation 1, leaving the stage at `paper` with its schema in hand. Keep the row's first
  three cells byte-identical. *(completed)*
- [x] Amend the stage-I row (line 179): ``and `LCU` validity (P1)`` is no longer outstanding;
  leave `AA soundness (P2-P3)` exactly as written, since it is still missing. *(completed)*
- [x] Amend ingredient row 2 (line 188): `**missing**` → `landed`, with the Evidence cell naming
  `lcU`, `lcU_plusValidInt`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime` and their
  lines, replacing the `[P1 …]` proposal id. Keep the row's `#` and `Ingredient` cells
  byte-identical, and do not touch any other row in the table in this phase. *(completed)*
- [x] Amend the P1 backlog-audit note (line 213): `covered-by-closed 864/871` on P1 —
  `**not covered**` was correct when written; record that P1 is now **discharged by task 893**
  (`completed`), citing 893's own artifacts, without rewriting the 864/871 finding itself.
  *(completed)*
- [x] Amend the executive summary's deliverable-3 bullet (line 36): remove ``LCU` declared and
  valid` from the `Missing:` list and add it to the `Landed:` list, and decrement the bullet's
  stated missing count from 9 to 8 wherever it appears in that sentence. Leave the other eight
  missing items byte-identical. *(completed)*
- [x] Add one dated amendment note immediately below the report's existing 902 amendment note
  (line 28), in the sanctioned
  `**Amended by** <doc>, <date>:` shape: two or three sentences stating that ingredient row 2 and
  its seven dependent assertions move to landed on the strength of this task's report Finding 17
  and task 893's compiled declarations, and that the Lean NO-GO's ground — (O1)/(O3)/(O4) — is
  untouched, one ingredient row moving to landed being unrelated to the determinization gap. One
  note for the phase, not one per edit site. *(completed: the note was placed immediately below
  the existing 903 note rather than the 902 note named in the task text, since the 903 note is
  itself already directly below 902 — the note still sits at the top of the amendment-note stack
  in chronological append order, immediately before the Deliverable 1 bullet)*
- [x] Read the amended file back and confirm: `NO-GO on a Lean proof` still occurs; the report
  nowhere says T1 is refuted or that a Lean completeness proof is available; ingredient row 16 is
  byte-identical; and `git diff` shows no hunk outside the eight anchor regions and the new note.
  *(completed: `grep -c 'NO-GO on a Lean proof'` returns 2, unchanged from pre-edit; a grep for
  lifting language returns 0; row 16 is absent from the diff; `git diff -U0` shows exactly 9 hunks)*
- [x] Record an issue-log entry (`issue-record.sh … --phase implement --dispatch-seq <seq>`) naming
  any anchor whose count differed, or a `win` attesting that all eight matched once. *(completed)*
- [x] Commit the amended report and this plan by explicit path (`git-commit-phase.sh`, or
  `git-commit-scoped.sh … -- <paths>`); never a directory or glob pathspec. *(completed)*

**Phase 1 Notes**: all eight anchors and all four declarations matched the plan-time measurements
exactly — no drift, no skipped edit. `git diff -U0` over the report shows exactly 9 hunks (8
in-place amendments plus 1 new amendment note). No anchor count differed from the plan's
hypothesis.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: both touched paths lie entirely under `specs/**` and map to no test suite, so the covering check is `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exiting 0, together with the `prose` row's diff read-through confirming every hunk is one of the eight anchor amendments or the single new amendment note.

**Scope Hypothesis**: exactly two files change, and within the architecture report exactly nine hunks appear — eight in-place amendments at the anchors above plus one new amendment note. Anchor line numbers at plan time: 82, 123, 151, 174, 179, 188, 213, 36, in a 290-line file; the note goes after line 28. Re-measure with the second task's greps rather than trusting these. Confirm at implementation time by `git diff -U0 -- <report>` showing at most nine hunks; if an anchor is absent the count is lower and the Phase 1 notes say which and why.

**Files to modify**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` - eight in-place amendments at the anchors above, plus one dated amendment note below the existing 902 note; every anchor confirmed present at plan time
- `specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md` - Phase 1 notes: the eight anchor counts measured before and after, and the four-declaration re-confirmation

**Verification**:
- The four-declaration grep returns four hits in `FormalSystem/PlusLanguage/PlusLCSchema.lean`, recorded with their lines, before any edit.
- Each amended passage's deliberately-kept half still counts 1 (stated per anchor in the task list), or the Phase 1 notes record a skipped anchor.
- `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exits 0.
- `git diff -U0 -- <report>` shows at most nine hunks and none outside the anchor regions.
- `grep -c 'NO-GO on a Lean proof' <report>` is unchanged from its pre-edit value; a grep for lifting language (`NO-GO is lifted`, `completeness is now formalizable`, `completeness proof is now available`) returns 0; and ingredient row 16 is byte-identical.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.
- `git diff --staged --name-only` names only the two files above.

---

### Phase 2: Amend the Architecture Report's Separation and Automaton-Initialisation Record [COMPLETED]

**Goal**: The same report's Finding 2.4 records the split consumption point (S1)/(S2) and the
first-transition indexing; ingredient rows 8 and 9 name their second consumers; and the
Cross-Domain Synthesis no longer asserts that the semantics' defining feature pays for itself
exactly once.

**Tasks**:
- [x] Set this phase's heading to `[IN PROGRESS]` before the first edit. *(completed)*
- [x] Re-confirm each of the six anchors still matches exactly once (`grep -cF`, counts and
  plan-time line numbers): ``so `θ_f` can state it`` (1, line 163) ·
  `Separation is consumed exactly once` (1, line 163) ·
  `| 8 | Full-product lemma at the cut` (1, line 194) ·
  `| 9 | Linear ℤ-word validity` (1, line 195) ·
  `pays for itself exactly once, at the anchor` (1, line 231) ·
  `The exact point at which separation is consumed is located` (1, line 34). Line numbers will
  have shifted by Phase 1's insertions; re-locate by content, not by line. On an absent anchor,
  skip that edit and record which in the Phase 2 notes. *(completed: all six anchors re-confirmed,
  each matching exactly once, shifted by +2 lines to 165, 165, 196, 197, 233, 36 respectively,
  consistent with Phase 1's two-line insertion)*
- [x] Amend Finding 2.4's initialisation parenthetical (line 163): replace
  ``(its initial state is a function of `γ_{colour(w₀)}`, so `θ_f` can state it)`` with the
  first-transition formulation of this task's report Finding 5.4 — the index set is a function of
  the cut *letter*, so defining `ρ⁺(s₀⁺, ĉ)` as the initial state of the sub-automaton that has
  already resolved `{pt : ⟐δ_pt ∈ ĉ}` makes a single fixed initial-state atom `b₀⁺` sufficient and
  leaves `aaAnte` used unchanged. State that the earlier reading is correct but avoidable, and that
  the avoidable version is the one a formalization should state. *(completed)*
- [x] Amend the same finding's consumption-point sentence (line 163):
  `**Separation is consumed exactly once: in the legitimacy of initialising the two product
  automata at the cut from the cut colour's type sets.**` becomes the split (S1)/(S2) of this
  task's report Finding 4.3 — (S1) separation makes the cut index a finite, state-level datum
  (`separationOver_ztime`/`sepZ_sepClauses`/`plusTruthAt_sepZ_iff`), and (S2) PS/US pasting
  (`paste`, `untl_paste`) is what makes the conditional badness tautology `⊢ χ̄₀[⟐·]` derivable —
  with the statement that neither substitutes for the other and that the single point recorded
  earlier is the conjunction of the two. *(completed)*
- [x] Amend the matching executive-summary bullet (line 34) to name the split in one clause, so the
  summary and the finding do not disagree. Keep the bullet's `Derived, finding 2.4` attribution.
  *(completed: this bullet's closing sentence is byte-identical to a sentence inside Finding 2.4's
  own resolution paragraph, so the single edit to that shared text landed both occurrences at once;
  the `Derived, finding 2.4` attribution is kept byte-identical)*
- [x] Annotate ingredient row 8 (`Full-product lemma at the cut`, line 194) with its **second**
  consumer per Recommendation 3: the alphabet collapse of this task's report Findings 1.3/4.4 —
  the realized `(pt, ft)` pairs forming a product is what collapses `2^{|PastLits|+|FutLits|}`
  pair-indexed closure members to `2^{|PastLits|} + 2^{|FutLits|}` — alongside the cut soundness it
  already names. Do not change the row's Status cell: the lemma is still missing, and the
  statement itself is unchanged. *(completed; Status cell `**missing**` left byte-identical)*
- [x] Annotate ingredient row 9 (the linear-validity bridge, line 195) with its second consumer:
  derivable separation (this task's report Lemma 7.2), alongside Claim 1⁺. Again leave the Status
  cell as written. *(completed; Status cell `**missing**` left byte-identical)*
- [x] Amend the Cross-Domain Synthesis sentence (line 231): `pays for itself exactly once, at the
  anchor` becomes the three registers of this task's report's own synthesis — order-theoretically
  the product (Lemma 4.2), logically conditional badness as a theorem (Lemma 7.3), combinatorially
  the free down-and-across construction (Lemma 9.2) — keeping the sentence's point that the logical
  and order-theoretic content meet at the cut. *(completed)*
- [x] Add one dated amendment note below Phase 1's, stating that Finding 2.4's consumption point is
  split and its initialisation reading superseded, that rows 8 and 9 gain second consumers with
  their statements unchanged, and — explicitly — that **no new Lean item is filed by this
  amendment** and the level split is deliberately not filed (Recommendation 4). *(completed)*
- [x] Read back and confirm: no row's Status cell changed in this phase; the report nowhere claims
  a new landed ingredient; and `git diff` shows no hunk outside the six anchor regions and the new
  note. *(completed: rows 8/9 Status cells re-read as `**missing**`, byte-identical; `git diff -U0
  HEAD` for this phase shows exactly 5 hunks, all within the anchor regions and the new note — fewer
  than the 7-hunk hypothesis because the initialisation and consumption-point edits share one line
  and the exec-summary bullet shares literal text with the Finding 2.4 paragraph)*
- [x] Record an issue-log entry for this phase (`issue` or `win`). *(completed)*
- [x] Commit by explicit path. *(completed)*

**Phase 2 Notes**: all six anchors matched exactly once at the expected shifted line numbers
(+2 from Phase 1's insertions); no anchor was absent or required re-location by content beyond the
expected shift. `git diff -U0 HEAD` shows 5 hunks for this phase's commit, fewer than the plan's
7-hunk scope hypothesis: the initialisation parenthetical and consumption-point sentence share a
single line (merged into one hunk), and the executive-summary bullet's closing sentence turned out
to be byte-identical to a sentence already inside Finding 2.4's resolution paragraph, so one edit
satisfied both anchors. Both ingredient rows 8 and 9 retain their `**missing**` Status cells
verbatim.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: the single touched artifact lies under `specs/**` and maps to no test suite, so the covering check is `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exiting 0, plus the `prose` row's diff read-through confirming every hunk is one of the six anchor amendments or the new note, and that no Status cell moved.

**Scope Hypothesis**: exactly two files change (the architecture report and this plan), and within the report exactly seven hunks appear — six in-place amendments plus one new amendment note. Plan-time anchor line numbers 163 (twice, same line), 194, 195, 231, 34 will have shifted by Phase 1's insertions, so re-locate by content; confirm by `git diff -U0 -- <report>` showing at most seven hunks for this phase's commit alone.

**Files to modify**:
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` - six in-place amendments (Finding 2.4's two sentences, the matching summary bullet, ingredient rows 8 and 9's Evidence cells, the Cross-Domain Synthesis sentence) plus one dated amendment note
- `specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md` - Phase 2 notes: the six anchor counts measured before and after

**Verification**:
- Each amended passage's deliberately-kept half still counts 1, or the Phase 2 notes record a skipped anchor.
- `bash .claude/scripts/validate-artifact.sh … report` exits 0.
- `git diff -U0 -- <report>` for this phase's commit shows at most seven hunks.
- A read-back confirms rows 8 and 9 retain their `**missing**` Status cells verbatim, and that no other ingredient row changed in this phase.
- `grep -c 'Separation is consumed exactly once' <report>` is 0 and the (S1)/(S2) text is present; `grep -c 'so `θ_f` can state it' <report>` is 0.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.

---

### Phase 3: File the Two Ownable Paper Questions, With Backlog Evidence [COMPLETED]

**Goal**: Two `not_started` entries exist in `specs/state.json`, each carrying
backlog-reconciliation evidence in its own `audit_verdict` field and a declared `file_scope`;
`specs/TODO.md` renders both; (Q2) is deliberately not filed and the reason is recorded.

**Tasks**:
- [x] Set this phase's heading to `[IN PROGRESS]` before the first write. *(completed)*
- [x] Write `specs/901_two_sided_reynolds_engine_paper_proof/task-proposals.json` as a two-element
  JSON array, each element carrying exactly the four keys `{id, title, description, file_scope}`
  that `audit-task-proposals.sh` consumes:
  - **(Q3)** `eliminate_cross_certification_two_sided_reynolds_automata` — RESEARCH TASK, report
    only, `file_scope: []`. Deliverable: an answer, with its argument, to whether the clause-(a)
    cross-certification of this task's report Finding 5.2/14.4 is eliminable — either a proof that
    the certification is automatic from the chronicle clauses of Finding 8.2, or a demonstration
    that it is load-bearing, or a bi-infinite-automaton alternative with its cost. State in the
    description that the question is answerable against the chronicle clauses and the two clause
    (a)s **alone**, that it is strictly cheaper than anything in Finding 17, and that eliminating
    the clauses would remove one ω-regularity argument from each automaton and shrink the
    alphabet's enlargement. No Lean work; no completeness claim.
  - **(Q1)** `lcu_derivability_from_lcn_non_ztime_separating_model` — RESEARCH TASK, report only,
    `file_scope: []`. Deliverable: either a derivation of `lcU α β` in TM⁺ + `LC_n` + mirror for
    state-local `β`, or a non-ZTime separating model. State in the description that a **ZTime
    countermodel cannot settle it** — both `lcN_plusValidZTime` and `lcU_plusValidZTime` are
    compiled, so the two systems have the same ZTime models — and that `.Base`, where both
    schemata's validity is open and unclaimed per `PlusLCSchema.lean`'s own docstring, is the first
    target for a separating general frame or algebra. *(completed, both proposals written verbatim
    to spec)*
- [x] Run `bash .claude/scripts/audit-task-proposals.sh` over the proposals file; commit the
  resulting audit NDJSON into this task's directory as the evidence record. *(completed; exit 0,
  465 verdicts for (Q3), 490 verdicts for (Q1))*
- [x] **Decision gate**: on a surviving `duplicate-of-open` or `subset-of-open` verdict against an
  open task, narrow the proposal's scope to the non-overlapping remainder or drop it, rather than
  filing it unchanged; record the disposition of every non-`scope-blind`, non-trivial verdict with
  its reason, in the shape the architecture report's own "Backlog audit" paragraph uses.
  *(completed — see Phase 3 Notes below; no proposal was narrowed or dropped)*
- [x] File the surviving proposals via `bash .claude/scripts/state-write.sh` with
  `--audit-verdict` carrying the verdict object for each new entry (the audit-evidence gate
  refuses the write otherwise), each as `not_started` with its `task_type` and declared
  `file_scope`. Do not hand-edit `specs/state.json`, and do not assign `.artifacts = [...]`
  wholesale — `rules/state-management.md` makes that array append-only. *(completed: both filed via
  `state-write.sh --allocate-into --audit-verdict`, project numbers 905 (Q3) and 906 (Q1); the
  full 465/490-verdict NDJSON passed as `--audit-verdict` hit the shell's argument-length limit, so
  a trimmed verdict object — proposal plus the non-`scope-blind` verdicts only, which is all the
  gate structurally requires — was passed instead; the full audit record is committed unabridged at
  `task-proposals-audit.ndjson`)*
- [x] Regenerate the rendered view: `bash .claude/scripts/generate-todo.sh`. Never edit
  `specs/TODO.md` directly. *(completed)*
- [x] Confirm `bash .claude/scripts/validate-state.sh` exits 0 (including its cycle check) and that
  both new entries render in `specs/TODO.md` with their `task_type` and bracket status.
  *(completed: exit 0, 19 pre-existing warnings unrelated to 905/906, 0 failures; both entries
  render with `formal`/`[NOT STARTED]`)*
- [x] Record in the Phase 3 notes, with its reason, that **(Q2) is deliberately not filed**: the
  write-up's Recommendation 7 asks only that it stay framed as admissibility rather than soundness,
  and names no settling route an agent could be dispatched against; the landed
  `clock_irr_sound`/`irr_sound` bear on soundness, not admissibility, and recording them as partial
  progress would overstate the position. *(completed — see Phase 3 Notes below)*
- [x] Record an issue-log entry for this phase (`issue` or `win`). *(completed)*
- [x] Commit the proposals file, the audit NDJSON, `specs/state.json` and `specs/TODO.md` by
  explicit path. *(completed)*

**Phase 3 Notes**: both proposals survived the decision gate unchanged. For (Q3), the audit's only
non-`scope-blind` hit against an open task was `duplicate-of-open 901` itself (semantic score
0.407, well below the sibling task 902's calibrated ~0.62 credible-match threshold) — this is the
task raising the question, not a competing owner, and 901 declares no Lean item and no cross-
certification deliverable of its own; **dismissed, self-reference, not a genuine duplicate**. Every
other (Q3) verdict was `covered-by-closed` against reports/summaries in the 0.43-0.67 range, none
naming cross-certification or the clause-(a) mechanism; **dismissed, no on-point coverage**. For
(Q1), four `duplicate-of-open` hits surfaced (430, 543, 869, 875), all at 0.41-0.51, below
threshold; 430 was already adjudicated by the architecture report's own P1 backlog-audit note as
"token overlap on 'lift'/'valid'/'assembly', unrelated in content" — the same dismissal applies
here; 869 is the already-demoted L^▷ invariance task (architecture report: "subset-of-open 869 …
on P6 … overlap on `HistoryMorphism.lean` only"), unrelated to the LCU/`LC_n` derivability question;
543 and 875 show no content overlap with a non-ZTime separating-model question beyond generic
logic-programme vocabulary. **All four dismissed, below-threshold token overlap, no content
match.** No `subset-of-open` verdict appeared for either proposal. Allocated numbers: **905**
(Q3, `eliminate_cross_certification_two_sided_reynolds_automata`), **906** (Q1,
`lcu_derivability_from_lcn_non_ztime_separating_model`). **(Q2) is deliberately not filed**:
Recommendation 7 asks only that "is `LC_n` admissible in the rule-free system" stay framed as
admissibility, not soundness, and names no settling route an agent could be dispatched against; the
landed `clock_irr_sound`/`irr_sound` bear on soundness, not admissibility, so recording them as
partial progress toward (Q2) would overstate the position. (Q2) is recorded here, not filed.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: the covering checks are the repository's own state gates — `bash .claude/scripts/validate-state.sh` exiting 0 (which covers `specs/state.json` and the regenerated `specs/TODO.md`, the only non-new files this phase writes) and `audit-task-proposals.sh` exiting 0 over the proposals file — and no test suite covers any path this phase touches.

**Scope Hypothesis**: exactly two new `not_started` entries are filed, unless the decision gate drops or narrows one, and exactly four files change: two new files in this task's directory (the proposals JSON and the audit NDJSON), plus `specs/state.json` and `specs/TODO.md`. The two-proposal count is a hypothesis about what survives the audit, not a fact: confirm at implementation time by reading the audit verdicts before filing, and record the actual filed count in the Phase 3 notes.

**Files to modify**:
- `specs/901_two_sided_reynolds_engine_paper_proof/task-proposals.json` - new; the two proposals in `audit-task-proposals.sh`'s four-key shape
- `specs/901_two_sided_reynolds_engine_paper_proof/task-proposals-audit.ndjson` - new; the committed audit evidence
- `specs/state.json` - the surviving entries appended via `state-write.sh --audit-verdict`
- `specs/TODO.md` - regenerated by `generate-todo.sh`, never hand-edited
- `specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md` - Phase 3 notes: the allocated numbers, every non-trivial verdict's disposition, and the (Q2) non-filing record

**Verification**:
- `bash .claude/scripts/audit-task-proposals.sh` exits 0 and its NDJSON is committed.
- `bash .claude/scripts/state-write.sh … --audit-verdict …` succeeds for each filed entry; no hand edit of `specs/state.json` appears in the diff.
- `bash .claude/scripts/validate-state.sh` exits 0.
- `specs/TODO.md` renders every filed entry with its number, `task_type` and `[NOT STARTED]` marker, and its artifact links (if any) use the bracket-only format.
- The filed (Q3) description contains the `report only` clause and the (Q1) description names the ZTime-countermodel refutation and `.Base`; both read back from `specs/state.json`.
- The Phase 3 notes record the disposition of every non-`scope-blind`, non-trivial verdict, and the (Q2) non-filing with its reason.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.

---

### Phase 4: Close-Out Record and Final Gate [NOT STARTED]

**Goal**: The task's close-out record exists, states what was amended and filed and — explicitly —
what was deliberately not acted on, and the repository passes its full gate set with
`FormalSystem/`, `Tests/`, `lakefile.toml` and `lake-manifest.json` untouched by every phase.

**Tasks**:
- [ ] Set this phase's heading to `[IN PROGRESS]` before the first write.
- [ ] Write
  `specs/901_two_sided_reynolds_engine_paper_proof/summaries/01_two-sided-reynolds-engine-paper-proof-summary.md`
  per `summary-format.md` (all required headings verbatim), covering:
  - The write-up's result in three sentences: the transposition closes, and in a shape the prior
    architecture did not predict — two one-sided engines hinged at the clock cut, each verbatim
    Reynolds (one under `reflectTime`), interacting only at the anchor ≡-class, with the level
    split as the design of record and the interleaved form reported as failing at a named step.
  - That the deliverable is a **paper proof** at the source's level of rigour, not a machine-checked
    theorem, with one step (the final frame, through the universal cover) resting on two unlanded
    pieces; no completeness claim for T1, T2 or T3.
  - The two located questions with their settling conditions, including the derived fact that (Q1)
    is not settleable by a ZTime countermodel, and (Q3) as the question the write-up itself raises.
  - The Phase 1 and Phase 2 amendments to the architecture report, and the Phase 3 filing table
    with the allocated numbers.
  - An explicit paragraph recording what is deliberately **not** done, each with its reason, so
    none reads as an oversight: no Lean formalization of any part of §§7-15 (the located
    obstruction (O1)/(O3) is unresolved and nothing in the write-up moves it); no level-split Lean
    item (a chronicle-definition change, behind (O1)/(O3), with no reachable target); no CSLib
    `require` added and the question not re-opened; no edit under `FormalSystem/` or `Tests/`; (Q2)
    recorded rather than filed; and no redeploy of the stale `.claude/` tree.
  - Link this task's report and the amended architecture report under `## References`.
- [ ] Confirm no library or build-file change across the whole task:
  `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and
  `git diff --stat <this task's first commit>^..HEAD -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json`
  is empty.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`, in the foreground with a
  bounded timeout, redirecting output to a file and grepping that file. Read the output in full; do
  not infer a pass from the absence of visible errors. If this dispatch carries a
  `## Batch Gate Deferral` directive, follow it and record the deferral in the summary's
  Verification section rather than claiming a gate run that did not happen.
- [ ] Run `bash .claude/scripts/validate-state.sh` and
  `bash .claude/scripts/validate-artifact.sh <the summary> summary`; both exit 0.
- [ ] Record a closing issue-log entry (`win` or `issue`) for this phase, or attest in the summary
  that nothing arose.
- [ ] Write `.orchestrator-handoff.json` and `.return-meta.json` (`status: "implemented"`,
  `dispatch_seq` echoed verbatim, `phases_completed`/`phases_total` as top-level integers), and
  commit the summary by explicit path.

**Timing**: 0.75 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Scope Hypothesis**: exactly one new summary file is written in this phase, and no file under `FormalSystem/` or `Tests/`, and neither `lakefile.toml` nor `lake-manifest.json`, is modified by any phase of this plan. Confirm by the two `git` checks above, read before the gate run rather than after it.

**Files to modify**:
- `specs/901_two_sided_reynolds_engine_paper_proof/summaries/01_two-sided-reynolds-engine-paper-proof-summary.md` - new; the close-out record, including the deliberately-not-done paragraph
- `specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md` - Phase 4 notes and the final phase-status markers

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/summaries/01_two-sided-reynolds-engine-paper-proof-summary.md summary` exits 0.
- `bash .claude/scripts/verify-deploy.sh` runs to completion and is observed green — the complete gate set, not a `--only-gate` subset and not `--skip-slow` — or the batch deferral is recorded per the dispatch's directive.
- `bash .claude/scripts/validate-state.sh` exits 0.
- `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exits 0 after both amendment phases.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and the `git diff --stat` over this task's own commits for the same paths is empty.
- `.orchestrator-handoff.json` validates (the write-time `validate-handoff-location.sh` gate accepts it) and `.return-meta.json` carries `status: "implemented"` with `dispatch_seq` echoed.
- The summary's deliberately-not-done paragraph names all six omissions, each with a reason.

## Testing & Validation

- [ ] `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exits 0 after each amendment phase.
- [ ] `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md plan` exits 0.
- [ ] `bash .claude/scripts/validate-artifact.sh <the summary> summary` exits 0.
- [ ] `bash .claude/scripts/audit-task-proposals.sh` exits 0 and its NDJSON is committed as evidence.
- [ ] `bash .claude/scripts/validate-state.sh` exits 0, including its dependency-cycle check.
- [ ] `bash .claude/scripts/verify-deploy.sh` is observed green in Phase 4, or its deferral is recorded.
- [ ] `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty at every phase boundary.
- [ ] No `.lean` file is created or modified, and no `lake` invocation is made, by any phase.
- [ ] The amended architecture report still asserts the Lean NO-GO and nowhere claims T1, T2 or T3.

## Artifacts & Outputs

- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` — amended: `LCU` recorded as landed at eight points (Phase 1); Finding 2.4's split consumption point, the first-transition indexing, rows 8 and 9's second consumers, and the Cross-Domain Synthesis correction (Phase 2); two dated amendment notes.
- `specs/901_two_sided_reynolds_engine_paper_proof/task-proposals.json` and `…/task-proposals-audit.ndjson` — new; the two proposals and their committed backlog evidence.
- `specs/state.json`, `specs/TODO.md` — the surviving filed entries, appended and rendered.
- `specs/901_two_sided_reynolds_engine_paper_proof/summaries/01_two-sided-reynolds-engine-paper-proof-summary.md` — new; the close-out record with the deliberately-not-done paragraph.
- `specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md` — this file, with per-phase notes and status markers.
- `specs/901_two_sided_reynolds_engine_paper_proof/issues.jsonl` — appended per phase.
- No Lean artifact, no build-file change, no new `.claude/**` file, no PR, no push.

## Rollback/Contingency

Every phase writes only Markdown under `specs/**` plus `specs/state.json`, and each commits by
explicit path, so a phase's effect is one revertable commit.

- **A single phase's amendments are wrong**: `git revert <that phase's commit>` restores the prior
  text of the architecture report without touching any other phase's work. The two amendment
  phases are serialized on the same file, so reverting Phase 2 alone is clean; reverting Phase 1
  after Phase 2 has landed may conflict in the amendment-note region, in which case revert both
  and re-apply Phase 2.
- **A filed proposal is wrong or duplicates an open task after filing**: mark it `[ABANDONED]`
  through `update-task-status.sh` rather than deleting the entry, and regenerate `specs/TODO.md`.
  Do not hand-edit `specs/state.json` to remove it.
- **An anchor turns out to be absent or to have drifted**: skip that edit, record the discrepancy
  in the phase notes, and leave the stale text in place. A stale "missing" row is a recoverable
  record error; an amendment landed in the wrong place is not.
- **The four declarations are not found compiled at Phase 1's first check**: stop Phase 1, record a
  blocker, and do not amend the report to say "landed". The whole of Phase 1 rests on that check.
- **Before any intentional rollback that a dirty tree would block**, run
  `bash .claude/scripts/git-snapshot.sh 901` first, then retry. For an ordinary defensive
  checkpoint before risky work, use `git-snapshot.sh 901 --no-revert` instead, which is durable
  without reverting the working tree.
- **The task's own deliverable is not at risk in any scenario**: the report is already committed
  (`657ba85b9 task 901: complete research`) and no phase of this plan amends it.
