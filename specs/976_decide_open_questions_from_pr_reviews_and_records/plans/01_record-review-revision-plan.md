# Implementation Plan: Task #976

- **Task**: 976 - Decide open questions from PR reviews and records
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None. Coordinates with task 970 (`investigate_stability_as_modal_family`) on question (f); nothing here waits on it.
- **Research Inputs**: specs/976_decide_open_questions_from_pr_reviews_and_records/reports/01_open-questions-decisions.md
- **Artifacts**: plans/01_record-review-revision-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The research report decided ten of the twelve questions, (a) (b) (c) (d) (e) (g) (h) (j) (k) (l),
deferred (f) to `investigate_stability_as_modal_family`, and left two for the user: (i) what
"default" means for adoption, and the naming residue of (c). This plan writes those decisions
into the three records under `records/` and revises the three review drafts under
`specs/reviews/pr-reviews-2026-11-20/` to state them instead of asking. All six files are
markdown; no Lean, script or state file is edited, and nothing is posted to GitHub. Done means:
each record's open-decision list holds only what is still open, every decided question is stated
in the section of the record that owns it, the reviews agree with the records, and no
cross-reference by decision number is left stale.

### Research Integration

Integrated from `reports/01_open-questions-decisions.md`:

- The decision, reason and rejected alternative for each question, under "Decisions".
- The edit lists under "Recommendations" (8 edits to the architecture record, 12 to
  `proof-mode.md`, 3 to `theorem-library.md`, and the review edits).
- The factual correction that `FormalSystem/Semantics/` is layer 1. Re-checked at planning time:
  `ORGANISATION.md` line 17 and `LAYERS` in `scripts/measure-refactor-partitions.py:144-151` both
  say 1.
- The two needs-user-ruling items, carried here as still awaiting a ruling (see Decisions).

Two corrections to the report, found at planning time:

- Its line numbers for `pr9-review.md` (97, 105, 116, 141, 146-148) do not exist: the file has
  62 lines. The passages are at lines 9, 17, 27-29, 53 and 59-62. Its line numbers for
  `pr7-review.md` and `pr8-review.md` match. Every review edit below is anchored by quoted text.
- Its edit lists do not mention that removing open decisions renumbers the lists, and other
  files cite those decisions by number. Phase 5 exists largely for this.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch (`roadmap_path` absent, `roadmap_flag` not
set). `specs/ROADMAP.md` is generated from `specs/state.json` and is not edited here. The order
change M17, M0, M16 is a change to record text only; `state.json` carries no edge for M17. Any
roadmap entry that contradicts the new order is reported in the summary as a follow-up for
`/roadmap`.

## Goals & Non-Goals

**Goals**:
- Remove or restate every open decision the research settled, in all three records, and state
  each decision in the section that owns it.
- Correct the layer number of `FormalSystem/Semantics/` wherever the records and reviews give 2.
- Break the M17, M16, M0 ordering cycle in `records/proof-mode.md`: order M17, M0, M16.
- Revise the three review drafts so they state decisions (a) (b) (c) (d) (e) (g) (h) (l), and
  withdraw the mistaken layer correction in `pr9-review.md`.
- Keep the two unruled items visibly open, each with its options and the recommendation.
- Leave no pointer to an open decision by a number that no longer names it.

**Non-Goals**:
- Posting to GitHub, or any `gh` write. The reviews are revised in place under `specs/`.
- Writing `records/semantic-proof-mode.md`. Decision (b) says it must exist before the mode is
  built; writing it is separate work.
- Carrying out any decision: no file moves (`MinusDeduction.lean`), no `lakefile.toml` change,
  no Lean edit, no change to PR branches.
- Deciding (f), or the enumeration-bounds decision of `theorem-library.md`.
- Editing `specs/state.json`, `specs/TODO.md`, `specs/ROADMAP.md`, `ORGANISATION.md`,
  `CONTRIBUTING.md` or `records/README.md`.
- Changing the four reversible positions in `records/proof-mode.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A record edit narrates the change ("no longer open", "previously", "withdrawn", "decided in") and breaks the records' own rule and `no-record-versioning-in-deliverables.md` | M | H | Each record phase states the rule in its task list and runs `check-record-versioning.sh records`; baseline at planning time is 0 BLOCKING, 1 ADVISORY (`theorem-library.md:4`) |
| A task number enters a record | M | M | Records name work by slug only (`records/README.md`); each record phase runs `check-task-references.sh records`; baseline is 0 |
| Removing decisions leaves numbered pointers stale across files | M | H | Pointers to surviving decisions are by section and bolded question title, never by number; Phase 5 greps all six files |
| The unruled items are written as settled | H | M | Decisions D1 and D2 below fix the wording: recommendation stated, marked as awaiting the user's ruling, in the records' open-decision lists and in the reviews |
| The proposed induction statement is read as established | M | M | It is written as proposed and not yet derived, in the record and in `pr8-review.md` |
| Review files are untracked, so `git diff` shows no hunks for the read-through | L | H | Phase 4 copies the three files to a scratch directory first and diffs with `git diff --no-index` |
| Parallel record phases disagree on a shared term | L | M | Shared wording is fixed in Decisions D3 to D6; Phase 5 checks it |
| `verify-touched.sh` fallback reports the suite that already fails on the untouched tree | L | H | Planning-time baseline recorded in Phase 5; only a failure outside that baseline counts against this task |

## Decisions

Planning decisions, each with its ground. D1 and D2 concern the two items the research returned
for a user ruling.

- **D1. Question (i) proceeds on the recommended option and stays listed as open.** The
  orchestrator's note for this dispatch says the research phase's non-blocking question was not
  put to the user and directs the plan to proceed on the recommendation. So `proof-mode.md`
  keeps the question in "Open decisions", restated with options A, B and C, the evidence for
  each, the two facts the tree fixes whatever the ruling (`Theorems/` cannot use the mode; M12
  hard-depends on a GO), and the recommendation: B as the rule, A for `Examples/` and case
  studies, `Theorems/` exempt, all contingent on a GO at gate one. M12's done-when is not
  changed. The item is awaiting the user's ruling.
- **D2. The naming residue of (c) is treated the same way.** Whether PR #8's `luntil unfold` /
  `luntil fold` keywords are renamed is taste. It is added to the architecture record's "Open
  decisions" with the recommendation (`expand` / `contract`, so that fold and unfold belong to
  the views tier alone), and `pr8-review.md` puts it to the contributor as a question with that
  preference stated. It is awaiting the user's ruling.
- **D3. Pointers to an open decision name it by its bolded question, not its number.** For
  example: the question "Is `⊡` rightly in the Modal family?" under "Open decisions" of
  [theorem-library.md]. Ground: three lists are renumbered by this work and five places cite
  them by number.
- **D4. M1's done-when is not amended.** Decision (d) admits `G`/`H` carrying and whole-judgment
  time reflection to gate-one scripts only once each is adopted into M1 before the selection is
  fixed. Adoption depends on PR #8's rules being merged, and the report's own confidence on
  `ltime_reflect` is medium. So M1 gains one sentence naming the two rules as the only
  candidates and the condition; the done-when clause itself stands. Rejected: amending the
  done-when now, which would change what a GO at gate one means on the strength of unmerged
  code.
- **D5. The semantic mode's directory is given as a placement, not a fixed path.** The record
  says "a directory of its own under `FormalSystem/Semantics/`" and may give
  `FormalSystem/Semantics/ProofMode/` as the example the report gives. The path does not exist;
  the record that fixes it is the one decision (b) asks for.
- **D6. Decided positions are written as the design, with the rejected alternative kept on its
  merits.** `records/README.md` requires both. The alternative is stated where the decision is
  stated, in one or two sentences drawn from the report's "Rejected" paragraphs, with no
  reference to its having been an open decision.
- **D7. The three record phases are independent and may run together.** They edit different
  files, and D3 removes the one coupling between them.
- **D8. Stale task descriptions are reported, not edited.** Tasks 935, 947, 950, 952, 969, 970,
  971 and 972 mention open decisions in their descriptions in `specs/state.json`. Revising
  another task's description belongs to `/revise`. Phase 5 lists which of them now contradict
  the records.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

Rules that apply to every record phase (1, 2, 3):

- State the current design only. No "no longer", "previously", "formerly", "now decided",
  "withdrawn", "was open", and no mention of this task, the report or the reviews.
- Name work by slug, never by task number.
- Keep each rejected alternative, on its merits (D6).
- Point at a surviving open decision by its question, not its number (D3).
- Take wording for decisions, reasons and rejected alternatives from the report's "Decisions"
  section; do not introduce a claim the report does not make.

### Phase 1: Architecture record [COMPLETED]

**Goal**: `records/proof-mode-architecture.md` states decisions (a) (b) (c) (d) (e) and the
consequences of (g) (h) (l), and its open-decision list holds only what is open.

**Tasks**:
- [x] Read the whole record and the report's sections (a) to (e), (h), (l) and "Edits to
      `records/proof-mode-architecture.md`". *(completed)*
- [x] "Three tiers": state the views pair `lunfold` / `lfold`, each taking a view name from one
      table whose rows give name, folded shape, unfolded shape and the relating equality; a
      formula equality is used as a view by registering a row; the elaborators' operator
      matching reads the same table. Keep one-tactic-per-view as the rejected alternative. *(completed)*
- [x] Semantic-tier paragraph: state the three placements of (a): lemmas in
      `FormalSystem/Semantics/` as general semantics at layer 1; tactics in a directory of their
      own under `FormalSystem/Semantics/` at layer 1 (D5); one adapter module at layer 3 under
      `FormalSystem/Metalogic/` holding the soundness lemma and `luse_derivation`, importing
      nothing under `FormalSystem/Automation/ProofMode/`. State the condition as part of the
      design: the views tier and the position and polarity planner sit at layer 0 or 1. Keep
      placement under `FormalSystem/Automation/` as the rejected alternative. *(completed)*
- [x] Same paragraph: state (b). The semantic mode has a record and a measured client before any
      tactic is built; the countermodel half of the library is a candidate client, to be
      measured by re-proving named declarations twice, with the lemmas alone as the control and
      with the tactics. Name `records/semantic-proof-mode.md` in backticks as the record to be
      written, not as a markdown link (the file does not exist). *(completed)*
- [x] "Aim and measure": state (d). `lrewrite` and `lsimp` are outside the gate-one scripts and
      verdict; rewriting's client is a second run of the gate-one selection with them permitted,
      reported separately; of the contributed temporal rules only `G`/`H` carrying and
      whole-judgment time reflection may enter, each only once adopted into M1 before the
      selection is fixed. Keep admitting rewriting to gate one as the rejected alternative. *(completed)*
- [x] The Modal-family section on two operators and one statement: state (e). The shared S5
      statement is a structure taking the operator as a field, instantiated once per necessity
      operator per language; the modal congruence step is one definition taking it; the fields
      are theorems, because the axiom bases of TM `□`, TM⁺ `□` and `⊡` differ. Keep the class
      indexed by the operator as the rejected alternative, with its failure on an operator
      presented through a definition. *(completed: also reworded the "One scheme" sentence "of the Modal class at each necessity operator" to name the structure, so the file does not contradict itself)*
- [x] "One scheme, used six times": add that the views tier and the planner sit at layer 0 or 1,
      under the `ORGANISATION.md` rule that puts shared metaprogramming in `FormalSystem/Tactic/`. *(completed)*
- [x] "Where the work sits": update four rows. Views (pair named; first rows contributed with
      rewriting). Semantic (own directory under `Semantics/`, adapter module at layer 3).
      Leads-to (strict rules are the layer beneath the present-inclusive definition). Until and
      Since induction (statement proposed; see `proof-mode.md` M4). *(completed)*
- [x] "Open decisions": remove the entries on view tactic names, where the semantic mode lives,
      record and client, rewriting in the measurement, and the S5 carrier. Reduce the `⊡` entry
      to a pointer per D3. Add the keyword question of D2 with its recommendation. Reword the
      list so numbering is contiguous. *(completed)*
- [x] Confirm no remaining "layer 2" is attached to `Semantics/` in this file. *(completed)*
- [x] Run both lints; read the diff hunk by hunk. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Eight edit sites in this one file, as the report lists them, plus the D2
addition. Section names are from a planning-time `grep` of the headings; "the Modal family has
two operators and one statement" is the report's name for a passage under "Operator families"
and may be a paragraph, not a heading. Confirm each site by reading before editing; if a site is
absent, put the statement in the nearest section that owns the subject and say so in the summary.

**Tier Justification**: Markdown prose with no compile surface, covered by the diff read-through plus `bash .claude/scripts/check-record-versioning.sh records` and `bash .claude/scripts/check-task-references.sh records`; `bash .claude/scripts/verify-touched.sh` run at planning time over this plan's six paths returned `SELECT: (none)`, every path owed to the cost-class-free fallback, so no suite covers this file.

**Files to modify**:
- `records/proof-mode-architecture.md` - sections "Aim and measure", "Three tiers", "Operator families", "Where the work sits", "Open decisions"

**Verification**:
- `bash .claude/scripts/check-record-versioning.sh records` reports 0 BLOCKING and no ADVISORY
  line in this file.
- `bash .claude/scripts/check-task-references.sh records` reports 0 occurrences.
- `grep -n 'layer 2' records/proof-mode-architecture.md` shows no line about `Semantics/`.
- "Open decisions" holds exactly two entries: the `⊡` pointer and the keyword question.
- `git diff -- records/proof-mode-architecture.md` read in full: every hunk is prose, and each
  removed decision has a statement elsewhere in the file with its rejected alternative.

---

### Phase 2: Proof-mode record [COMPLETED]

**Goal**: `records/proof-mode.md` carries decisions (g) (j) (k) (l) and the milestone
consequences of (a) (c) (d) (h), keeps (i) open in restated form, and has no ordering cycle.

**Tasks**:
- [x] Read the blocks M0, M1, M4, M9a, M10, M12, M16, M17, M18, "Dependency picture", "Gates",
      "Lanes", "Open decisions", and the report's sections (g), (i), (j), (k), (l) and "Edits to
      `records/proof-mode.md`". *(completed)*
- [x] M4, sequencing-only dependencies: replace the sentence that leaves the induction rule's
      edge undetermined. The case split is a sequencing-only predecessor of all three parts,
      because the pure rule sits under `FormalSystem/Theorems/ProofMode/` at layer 2 and takes
      linearity as a theorem (`Axiom.linear_until`, `Theorems/LinearityDerived.lean`), never
      through a tactic. *(completed)*
- [x] M4: add the proposed statement of the generalizing rule, in a code block, exactly as the
      report gives it under (g) part 2, with the Since mirror by time reflection, the
      instance that recovers `forwardInvariantRule` (`g := ⊤`, `e := ¬A`, `C := ¬A`), and the
      words that it is proposed and is derived under
      `proof_mode_until_since_intro_unfold_induction`. Keep backward induction as the rejected
      statement: it is a different rule and `forwardInvariantRule` is not an instance of it. *(completed)*
- [x] M9a: replace the layer-3 sentence by decision (j). `MinusDeduction.lean` moves from
      `FormalSystem/Metalogic/Conservativity/` to `FormalSystem/Theorems/`, with
      `MinusTemporalDerived.lean` if the rule module needs it, and the Minus pure-rule module
      sits under `FormalSystem/Theorems/ProofMode/`; M9a carries out the move. Keep the two
      rejected alternatives (instance at layer 3; move into `MinusLanguage/`). *(completed)*
- [x] M18: state (k). `BimodalLib` is a Lake library outside `defaultTargets`, built by explicit
      target and by its own `--wfail` step in CI, with an import-direction check that
      `FormalSystem` never imports it. Keep the default-target alternative. *(completed)*
- [x] M16: files at layer 0 or 1, not under `FormalSystem/Automation/ProofMode/`; the tactic
      pair is `lunfold` / `lfold` over one table; it absorbs the rows M17 introduced; it keeps
      its sequencing dependency on M0. Adjust the Lane line if it says Elaborators only. *(completed)*
- [x] M17: remove the sequencing dependency on M16. Done-when gains the surface separation (the
      formula-equality path leaves `lrewrite` and `lsimp` and is exposed through `lunfold` /
      `lfold` with the first rows of the view table) and names the comparison that meets "at
      least one library entry in a sweep is shorter": a second run of the gate-one selection
      with `lrewrite` and `lsimp` permitted, reported apart from the gate-one verdict. In the
      "Filed record" line, replace the pointer to the architecture record's numbered decision by
      the statement that its tactics are outside the gate-one scripts. *(completed: also states that the second run waits on M3's sweep)*
- [x] M1: add one sentence per D4. Do not alter the done-when clause. *(completed)*
- [x] M10: say that the contributed strict rules are the layer beneath the present-inclusive
      definition and the inclusive rules are proved from them. The done-when stands. *(completed)*
- [x] "Dependency picture", including the stream diagram and "What can run at once": M17, then
      M0, then M16. Check the "No hard predecessor" line and the sentence "M16 uses definitions
      only, and M17 uses rules the library has" still read correctly. *(completed: order paragraph with the two rejected orders added; stream diagram shows filed edges only and M17 has none, so it is unchanged)*
- [x] "Lanes": move M16's files out of the Elaborators lane directory if the table places them
      there. *(completed: the table does not list M16; one sentence added under it)*
- [x] "Open decisions": remove the linearity, Minus-instance and `BimodalLib` entries. Reduce
      the `⊡` entry to a pointer per D3. Restate the "default" entry per D1 with the option
      table and the recommendation. Reword the lead sentence ("These need a ruling from the
      user. Nothing in this document decides them.") to fit what remains. Leave the four
      reversible positions and the sentence that introduces them as they are. *(completed)*
- [x] Check "Where it stands" line 72 keeps `Theorems/` at layer 2 and says nothing false about
      `Semantics/`. *(completed: no edit needed)*
- [x] Run both lints; read the diff hunk by hunk. *(completed)*

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Twelve edit items in this one file, per the report, of which item 12 (the
four reversible positions) is a no-edit confirmation. Whether "Lanes" and the M16 Lane line need
a change is unverified at planning time; confirm by reading. If the M17 block or the M4
"undetermined" sentence is not found as quoted in the report, stop and report it in the handoff
instead of editing a nearby sentence.

**Tier Justification**: Markdown prose with no compile surface, covered by the diff read-through plus `bash .claude/scripts/check-record-versioning.sh records` and `bash .claude/scripts/check-task-references.sh records`; the planning-time `bash .claude/scripts/verify-touched.sh` run over this plan's six paths selected no suite for this file.

**Files to modify**:
- `records/proof-mode.md` - blocks M1, M4, M9a, M10, M16, M17, M18; sections "Dependency picture", "Lanes", "Open decisions"

**Verification**:
- `bash .claude/scripts/check-record-versioning.sh records` reports 0 BLOCKING and no ADVISORY
  line in this file.
- `bash .claude/scripts/check-task-references.sh records` reports 0 occurrences.
- `grep -n 'undetermined' records/proof-mode.md` returns nothing in the M4 block.
- `grep -n 'open decision [0-9]\|Open decision [0-9]' records/proof-mode.md` returns nothing.
- Reading M0, M16 and M17's dependency lines together gives the order M17, M0, M16 with no
  cycle, and "Dependency picture" agrees.
- "Open decisions" holds exactly two entries (the "default" question with options and
  recommendation; the `⊡` pointer), followed by the four reversible positions unchanged:
  `git diff` shows no hunk inside the four bullets.

---

### Phase 3: Theorem-library record [COMPLETED]

**Goal**: `records/theorem-library.md` states the build status of `BimodalLib` as design and
holds the single full statement of the `⊡` question.

**Tasks**:
- [x] "Layout": state (k) as in Phase 2's M18 item, with the default-target alternative kept on
      its merits (a plain build would catch a drifted re-proof; it loses because CI catches the
      same drift and the default build's stated meaning would change). *(completed)*
- [x] "Open decisions": remove the build-status entry. Keep the `⊡` entry in full as the one
      complete statement of the question. Keep the enumeration-bounds entry unchanged. *(completed: entry text unchanged; list markers renumbered 2 to 1 and 3 to 2)*
- [x] Check the pointer at line 96 ("see Open decisions") still resolves by name. *(completed)*
- [x] Run both lints; read the diff. *(completed: 0 BLOCKING, 1 baseline ADVISORY; 0 task references)*

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Two edit sites ("Layout", "Open decisions") and one confirmation. The
`⊡` entry's text is not edited. Confirm by reading that "Layout" does not already state a build
status that would contradict (k).

**Tier Justification**: Markdown prose with no compile surface, covered by the diff read-through plus `bash .claude/scripts/check-record-versioning.sh records` and `bash .claude/scripts/check-task-references.sh records`; the planning-time `bash .claude/scripts/verify-touched.sh` run over this plan's six paths selected no suite for this file.

**Files to modify**:
- `records/theorem-library.md` - sections "Layout" and "Open decisions"

**Verification**:
- `bash .claude/scripts/check-record-versioning.sh records` reports 0 BLOCKING and at most the
  one planning-time ADVISORY at `records/theorem-library.md:4`.
- `bash .claude/scripts/check-task-references.sh records` reports 0 occurrences.
- "Open decisions" holds exactly two entries: `⊡` and enumeration bounds.
- `git diff -- records/theorem-library.md` shows no hunk inside the `⊡` entry.

---

### Phase 4: Review drafts [COMPLETED]

**Goal**: The three review drafts state the decisions and agree with the revised records.

**Tasks**:
- [x] The files are untracked. Before editing, copy the three to a scratch directory outside the
      repository so the read-through has a baseline. *(completed)*
- [x] Re-read the three revised records, so each review cites their final wording. *(completed)*
- [x] `pr7-review.md`, the bullet beginning "Whether `lrewrite` and `lsimp` may be used in the
      gate-one scripts is open decision 4": state (d). They are outside gate one; M17's client
      is the second run of the selection; ask for the named declaration as before. *(completed)*
- [x] `pr7-review.md`, the bullets beginning "`lrewrite` currently does two different things"
      and "The views tier is M16": state (l) and (c). The surface separation is a merge
      condition: the formula-equality path leaves `lrewrite` and `lsimp` and is exposed as
      `lunfold` / `lfold` with the first rows of the view table; the full tier stays under
      `proof_mode_views_tier`. Remove the offer to take the extraction on and the sentence that
      the names are open. Update the table row "Formula equalities, folding and unfolding inside
      the rewriting tactics" (last cell "nothing, unless you take the extraction on") to match. *(completed)*
- [x] `pr7-review.md`, the bullets beginning "`⊡` is filed under Modal" and "`Kit` and `Step`
      are generic": state (e), the structure with the operator as a field over `Kit`, fields as
      theorems, one step taking it. Say the prototype shows one definition gives the three
      steps and does not show whether it lifts the `⊡` iteration limit. *(completed)*
- [x] `pr7-review.md`: leave the hold on M0 as it is. State the order M17, M0, M16 where the
      bullet about M0 moving files says M0 is held. *(completed)*
- [x] `pr8-review.md`, the bullet beginning "Gate one's selection is fixed": state which two
      rules may enter gate-one scripts and on what condition, and that the rest are measured at
      gate two. *(completed)*
- [x] `pr8-review.md`, "**Induction.**": give the proposed statement, marked as proposed and not
      yet derived, say backward induction is a different rule, and that the linearity edge is
      sequencing only. *(completed)*
- [x] `pr8-review.md`, "**Leads-to.**": state (h). Present-inclusive is the named definition;
      the strict rules stay as the layer beneath, labelled so. *(deviation: altered — also removed the clause "M10's, if the strict layer is to stay as the base" from the list of what the PR should revise, which contradicted (h))*
- [x] `pr8-review.md`, the bullet beginning "The inclusive Until and Since definitions": name
      the pair `lunfold` / `lfold`. Add the keyword question of D2 as a question to the
      contributor with the preference stated. *(completed)*
- [x] `pr9-review.md`, the bullet beginning "Two open decisions in the architecture record":
      state (a) with layer 1, the three placements and the condition on views and planner, and
      (b). Remove "yours to argue" for both; the reviews may still invite a view on argument. *(completed)*
- [x] `pr9-review.md`, the table row "Views and the position and polarity planner": add that
      both sit at layer 0 or 1. *(completed)*
- [x] `pr9-review.md`, restructuring items 2 and 4: item 2 no longer asks the contributor to
      settle the two decisions in the record; item 4 states the adapter at layer 3 above a
      layer-1 mode. *(completed)*
- [x] `pr9-review.md`: remove the line "`ProofModeTransport.lean:57` says "Layer 1";
      `Semantics/` is layer 2 in `ORGANISATION.md`." The contributor's "Layer 1" is correct. *(completed)*
- [x] `pr9-review.md`, "Purpose and measure": state (b) with the control run (lemmas alone, then
      tactics, against the existing proofs of the five declarations in each of
      `PlusNonValidities.lean` and `StarNonValidities.lean`), and that the countermodel half is
      a candidate client. Reword the closing bullet that says the architecture record's "open
      decisions 2 and 3 are revised to point at it". *(completed)*
- [x] In all three files, replace any remaining pointer to a numbered open decision per D3. *(completed)*
- [x] Read the diff of each file against its scratch copy. *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3

**Verification Tier**: prose

**Scope Hypothesis**: Three files; about 4 passages in `pr7-review.md`, 4 in `pr8-review.md` and
6 in `pr9-review.md`, counted from a planning-time `grep`, with the report's `pr9-review.md` line
numbers known to be wrong. Locate each passage by its quoted opening words. A passage that does
not match is reported, not guessed at. Passages the report does not name are left alone.

**Tier Justification**: Markdown drafts under `specs/` with no compile surface and outside both record lints' scope, covered by `git diff --no-index` of each file against its scratch copy read in full; the planning-time `bash .claude/scripts/verify-touched.sh` run over this plan's six paths selected no suite for these files.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-20/pr7-review.md` - gate-one, views, S5-carrier and ordering passages
- `specs/reviews/pr-reviews-2026-11-20/pr8-review.md` - gate-one, induction, leads-to and views passages
- `specs/reviews/pr-reviews-2026-11-20/pr9-review.md` - placement, record-and-client passages; layer line removed

**Verification**:
- `grep -n 'layer 2' specs/reviews/pr-reviews-2026-11-20/pr9-review.md` returns nothing.
- `grep -n -i 'open decision[s]* [0-9]\|Decision [0-9]:' specs/reviews/pr-reviews-2026-11-20/*.md`
  returns nothing.
- `grep -n 'unless you take the extraction on\|yours to argue' specs/reviews/pr-reviews-2026-11-20/*.md`
  returns nothing.
- Each of (a) (b) (c) (d) (e) (g) (h) (l) is stated in at least one review; the summary lists
  which file states which.
- The diff against the scratch copies touches only the passages listed above.

---

### Phase 5: Cross-file consistency and closing check [COMPLETED WITH EXCLUSIONS]

**Goal**: The six files agree with each other and with the report, nothing is left silently
undecided, and the touched-path check has been run.

**Tasks**:
- [x] Build a table of the twelve questions against the six files: where each decision is
      stated, or where it is listed as open. Every question has at least one record row. (f)
      appears as open in `theorem-library.md` and as a pointer in the other two records. (i) and
      the keyword question appear as open with a recommendation. *(completed: table in the summary)*
- [x] `grep -rn -i 'open decision[s]* [0-9]' records specs/reviews/pr-reviews-2026-11-20`:
      expect nothing. *(completed: no hit)*
- [x] `grep -rn 'layer 2' records specs/reviews/pr-reviews-2026-11-20`: every hit is about
      `Theorems/`. *(completed: 4 hits, all about `Theorems/`)*
- [x] `grep -rn 'lunfold\|lfold' records specs/reviews/pr-reviews-2026-11-20`: the pair is
      described the same way in each file (one pair, view name, one table). *(completed: 10 hits, one description)*
- [x] Check every relative markdown link in the three records resolves, and that
      `records/semantic-proof-mode.md` appears only in backticks. *(completed: all resolve; backticks only)*
- [x] Check the order M17, M0, M16 reads the same in `proof-mode.md` (three blocks and
      "Dependency picture"), the architecture record and `pr7-review.md`. *(completed: the architecture record states the order by contribution, without milestone numbers, and agrees)*
- [x] Read-only: for tasks 935, 947, 950, 952, 969, 970, 971 and 972, read the description in
      `specs/state.json` and list those that now contradict the records (D8). List any
      `roadmap_milestones` entry that contradicts the order M17, M0, M16. Edit neither. *(completed: 947, 950, 952, 969, 971 contradict; 970, 972 cite a stale number; 935 unrelated; roadmap M2 and M5 rationales stale; none edited)*
- [x] Run both record lints once more over `records`. *(completed: 0 BLOCKING, 1 ADVISORY; 0 task references)*
- [x] Run the touched-path check over the six files with `--task-dir` set to this task's
      directory. *(completed: 82 passed, 3 failed, 10 skipped; two failures beyond the baseline, see Reasoned Exclusions)*
- [x] Fix any inconsistency found, in the file that is wrong, under that file's phase rules. *(completed: one fix, M16 and M17 added to the two lists in "Gates" of `records/proof-mode.md`)*
- [x] Write the summary with: the question-by-file table; the two items awaiting the user's
      ruling, each with options and recommendation; the stale task descriptions and roadmap
      entries; and the statement that nothing was posted to GitHub. *(completed)*

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Scope Hypothesis**: This phase expects to edit nothing, or a few words. The six paths are
listed because a consistency fix may land in any of them. The eight task numbers come from one
`jq` pattern over descriptions at planning time; a task that discusses these decisions without
the words "open decision" is not in the list, so treat it as a lower bound.

**Files to modify**:
- `records/proof-mode-architecture.md` - consistency fixes only, if any
- `records/proof-mode.md` - consistency fixes only, if any
- `records/theorem-library.md` - consistency fixes only, if any
- `specs/reviews/pr-reviews-2026-11-20/pr7-review.md` - consistency fixes only, if any
- `specs/reviews/pr-reviews-2026-11-20/pr8-review.md` - consistency fixes only, if any
- `specs/reviews/pr-reviews-2026-11-20/pr9-review.md` - consistency fixes only, if any

**Verification**:
- The three greps above return what is stated.
- `bash .claude/scripts/check-record-versioning.sh records`: 0 BLOCKING, at most the one
  planning-time ADVISORY. `bash .claude/scripts/check-task-references.sh records`: 0.
- Scoped touched-path check, this phase's own obligation under `/orchestrate`:
  `bash .claude/scripts/verify-touched.sh --task-dir specs/976_decide_open_questions_from_pr_reviews_and_records records/proof-mode-architecture.md records/proof-mode.md records/theorem-library.md specs/reviews/pr-reviews-2026-11-20/pr7-review.md specs/reviews/pr-reviews-2026-11-20/pr8-review.md specs/reviews/pr-reviews-2026-11-20/pr9-review.md`.
  Planning-time baseline on the untouched tree: `SELECT: (none)`, six paths owed, fallback
  `--cost-class free`, 84 passed, 1 failed (`tests/test-deploy-baseline-lib.sh`, NEW), 10
  skipped. A result equal to that baseline is reported as such in the handoff, with the failing
  suite named as present before any edit; any other failing suite is a failure of this phase.
- The complete gate set is deferred to the orchestration close and is not run by this phase. In
  a standalone run with no orchestration close, run `bash .claude/scripts/verify-deploy.sh`
  directly instead.
- `git status --short` shows changes only under `records/`,
  `specs/reviews/pr-reviews-2026-11-20/` and this task's directory, beyond what was already
  modified when the phase began.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The verification clause "any other failing suite is a failure of this phase", as applied to `tests/test-lint-state-writer-boundary.sh` in the fallback set of the touched-path check | The suite tests `.claude/scripts/lint/lint-state-writer-boundary.sh` against fixtures it builds itself. It reads no file this task edits, and its subject is in the gitignored deploy tree, which this task does not write. Its failure says nothing about the six files. | Run alone after the phase's one edit: `26 passed, 1 failed`, the failing case being "--verbose did not name the read-only-open EXEMPT reason for the explicit 'r' case". `grep -c 'records/\|pr-reviews'` on the suite: 0. `cmp` of suite and subject against the core source store: identical. `git status --short` lists no path under `.claude/`. |
| The same clause, as applied to `tests/test-stall-reprompt-wiring.sh` | The suite reads `skill-orchestrate/SKILL.md`, the orchestrate state-machine document and the postflight script, all under `.claude/`. It reads no file this task edits. | Run alone: `19 passed, 1 failed`, the failing case being "re-prompt predicate: Move 3 region does not appear to OR stall_suspected and stranded_suspected together". `grep -c 'records/\|pr-reviews'` on the suite: 0. `cmp` of the suite and `SKILL.md` against the core source store: identical. |

The third failing suite, `tests/test-deploy-baseline-lib.sh`, is the one in the planning-time
baseline. The complete gate set is deferred to the batch stage under the dispatch's Batch Gate
Deferral section and was not run here.

## Testing & Validation

- [x] `bash .claude/scripts/check-record-versioning.sh records`: 0 BLOCKING.
- [x] `bash .claude/scripts/check-task-references.sh records`: 0 occurrences.
- [x] No pointer by decision number in the six files.
- [x] No "layer 2" attached to `FormalSystem/Semantics/` in the six files.
- [x] Each of the twelve questions is either stated as design in a record, with its rejected
      alternative, or listed as open with options and a recommendation.
- [x] M17, M0, M16 is the stated order, with no cycle among their dependency lines.
- [x] The four reversible positions in `records/proof-mode.md` are byte-identical.
- [x] No `gh` write command was run.
- [x] Touched-path check run and compared with the planning-time baseline.

## Artifacts & Outputs

- `records/proof-mode-architecture.md` (revised)
- `records/proof-mode.md` (revised)
- `records/theorem-library.md` (revised)
- `specs/reviews/pr-reviews-2026-11-20/pr7-review.md`, `pr8-review.md`, `pr9-review.md` (revised)
- `specs/976_decide_open_questions_from_pr_reviews_and_records/summaries/01_record-review-revision-summary.md`

## Rollback/Contingency

The three records are tracked: `git revert` of the phase commit restores a record, one commit
per phase. The review drafts are untracked until this task's first commit that includes them;
before that, Phase 4's scratch copies are the only way back, so keep them until the phase is
committed. No working-tree discard is part of this plan. If one is ever needed, follow the
rollback rung of `.claude/context/contracts/recovery.md`.

If a decision is disputed during implementation, do not improvise a different one: write the
question back into that record's "Open decisions" with the options, and report it in the
handoff. If the user rules on (i) or the keyword question before implementation finishes, apply
the ruling in place of the recommendation in Phases 1, 2 and 4.
