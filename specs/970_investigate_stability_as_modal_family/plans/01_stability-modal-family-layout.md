# Implementation Plan: Task #970

- **Task**: 970 - Investigate whether the stability operator belongs in the Modal operator family
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/970_investigate_stability_as_modal_family/reports/01_stability-modal-family-layout.md
- **Artifacts**: plans/01_stability-modal-family-layout.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: false

## Overview

The research report recommends keeping `⊡` in the Modal family, understood as the necessity
operators over histories with the laws parameterized by operator, and names five actions (R1 to
R5). This plan writes the task's deliverable, a report under `docs/development/`, then amends the
three design records so that they state the settled layout, and finally removes the "may reverse
this" hedges from the six filed task descriptions that carry one. Every edit is markdown or task
description text; no Lean file is touched and nothing is compiled. Done means: the report exists
and is indexed, the question "Is `⊡` rightly in the Modal family?" is absent from every record's
open-decision list, and no filed description still defers to this investigation.

### Research Integration

From `reports/01_stability-modal-family-layout.md`:

- Findings 1 to 6 supply the whole content of the `docs/development/` report (R5): the eight-cell
  comparison, the three proved facts weighed, the Open and Nomic operators as instances, the
  compiled `NecessityRules` structure, the four cslib hosting routes, and the summary table.
- R1 (stratify the shared statement into a K core plus T, D, 4, 5 as separate members), R2 (the
  operator set is a coordinate of the lattice) and R3 (inclusion, rigidity and temporal
  interaction are per-operator pieces outside the shared statement) are the record amendments.
- R4 and Appendix A name the six filed descriptions. Appendix A did not read the sixth
  (`connective_signature_layer_shared_primitives`) in full; this plan re-derived all six sentences
  from `specs/state.json` at authoring time and they are quoted in Phase 5.
- Appendix B (the change list for a separate family) is carried into the report as the answer to
  the task's item (4) contingency, stated as what that layout would require, not as work to do.
- The report's evidence tier is reading, not compilation. Its one marked inference (K and
  necessitation for `◈` over arbitrary nomic frames) is carried into the deliverable marked as an
  inference from the truth clause.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch. The task is milestone M23 of
`records/proof-mode.md` and row B2 of `records/milestones.md`.

## Goals & Non-Goals

**Goals**:
- Write `docs/development/stability-operator-family.md` covering the task's four items, and index
  it in `docs/development/README.md`.
- Amend `records/proof-mode-architecture.md`, `records/theorem-library.md` and
  `records/proof-mode.md` per R1 to R4 so each states the settled layout.
- Remove the hedging sentences from the six filed task descriptions and point them at the report.

**Non-Goals**:
- Any Lean change, including extending `NecessityRules` with T, 4 or 5 members. That belongs to
  `proof_mode_abstract_frontend_interface`.
- Any change to a module name, a `file_scope` or a dependency edge of a filed task. The
  recommendation keeps the layout the records start from, so none is owed.
- Executing Appendix B. The separate-family change list is documented, not applied.
- Editing `specs/ROADMAP.md` or the roadmap entries; `/roadmap` owns those.
- Proposing anything to cslib. The hosting review is descriptive.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deliverables narrate their own history ("no longer open", "previously filed under", "the earlier layout") and trip the record-versioning rule | M | H | Records and the report state the current design only. The decision is removed from each open-decision list and the position is stated in the body with its grounds; the separate-family layout is described as a rejected alternative on its merits. Each docs/records phase runs `check-record-versioning.sh` and requires 0 BLOCKING. |
| Removing a numbered open decision renumbers the rest and strands a cross-reference by ordinal | M | M | Each record phase greps `records/` for references to the affected list by ordinal before and after, and fixes any it finds. Records already cite this decision by its question text. |
| The three record phases run in parallel and drift in wording | M | M | Phase 1 fixes the vocabulary in the report (cell, operator set, K core, inclusion, rigid class). Phases 2 to 4 take their terms from it, and Phase 5 reads the three records side by side. |
| A whole-file rewrite of `specs/state.json` drops or reflows unrelated records, or races another session | H | L | All six description edits go through `.claude/scripts/state-write.sh` (the mutex-guarded writer) as one filter using string replacement on exact sentences; a dry run and a canonical diff confirm only six `description` fields change. |
| A hedge sentence has changed since this plan was written and the exact-match replacement silently does nothing | M | L | Phase 5 asserts, per task, that the old sentence is present before the write and absent after; a miss stops the phase. |
| The report overstates the `◈` claim | L | M | The K-and-necessitation claim is marked as an inference; the recommendation is shown not to depend on it (`nomic_serial` alone shows `◈` is not S5 in general). |
| Amending the records exceeds a task described as "research only" | M | L | See Decisions. Phases 2 to 5 are separable from Phase 1; if the amendments are not wanted, Phase 1 alone meets M23's done-when. |

## Decisions

- **Record amendments are in scope.** The task says the design is to be revised if the merged
  family is found wrong. The research found it right but under-specified in three places, and
  `records/proof-mode.md` requires a ruling before the records change only for a recommendation
  of a separate family. R1 to R3 refine wording inside the layout the records already hold, so
  they are planned without a `user_decision`. The plan is ordered so Phase 1 stands alone.
- **The decision is removed from the open lists, not annotated as closed.** A "closed on" or
  "resolved" note is draft history under the record-versioning rule. The body sections state the
  position and cite the report.
- **Report name**: `docs/development/stability-operator-family.md`, as the research suggests.
  The directory mixes upper-snake and kebab names in what filed descriptions cite; the kebab form
  matches the other proof-mode report those descriptions name.
- **`records/milestones.md` is not edited.** Its rows B2, B5 and D2 name the task and the single
  S5 step; none hedges on the layout, and the research lists them only under the contrary ruling.
- **The filed descriptions are edited by exact sentence replacement**, leaving every other word
  of each description as filed.
- **No memory candidate is emitted**: the decomposition is an ordinary write-then-propagate one.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Write the docs/development report [COMPLETED]

**Goal**: Produce the task's deliverable: a self-contained report that weighs the two layouts,
settles the Open and Nomic question, reviews cslib hosting, and recommends one layout.

**Tasks**:
- [x] Re-read the sources the report will cite and confirm each named declaration still exists
  under that name: `plusStateLocal_stab_iff` and `PlusFormula.StateLocal`
  (`FormalSystem/PlusLanguage/PlusStateLocal.lean`), `atom_stab` and `stab_of_stateLocal`,
  the four refutations in `FormalSystem/PlusLanguage/PlusNonValidities.lean`,
  `plusDerivable_ofFormula_iff`, the `ofut_*`/`opast_*` constructors and
  `stabNecessitation`/`ofutNecessitation`/`opastNecessitation` in `FormalSystem/OpenLanguage/`,
  `stab_iff_ofut_opast`, `nomic_serial`, `four_validOn_iff_uniform`, `nomic_iff_box_of_uniform`,
  the `nomic_*_tenseFree` family, `NomicFrame.Lawful`, and `NecessityRules` with its three
  instances in `FormalSystem/Theorems/ProofMode/Congruence/Modal.lean`. Use `grep`; a name that
  does not resolve is corrected or its claim dropped, never cited as read. *(completed: every named declaration resolved by grep; the fourth refutation is refute_somePast_stab)*
- [x] Write `docs/development/stability-operator-family.md` with these sections: the question and
  the recommendation; the two layouts as the same eight cells (research finding 1 table); the
  three proved facts weighed (finding 2), including the rigid-class observation and the condition
  on the tableau's generalization from atoms to schema variables; the Open and Nomic operators as
  instances, with the five-operator table of shared and unshared pieces and the 2^k scaling
  argument (finding 3); the parameterized statement as compiled (finding 4); hosting two
  necessity operators in cslib, with the four routes and the `G`/`H` precedent, naming the cslib
  files reviewed (finding 5); the summary weighing table (finding 6); the recommendation with
  what the records state as a result (R1 to R3 as design statements); and a section "What a
  separate Stability family would require" carrying Appendix B as the cost of the rejected
  alternative. *(completed)*
- [x] State the evidence tier in the report: established by reading source, nothing compiled; the
  `◈` K-and-necessitation claim marked as an inference from the truth clause. *(completed)*
- [x] Keep the report free of task numbers and of draft-history language. The separate-family
  layout is described on its merits, not as an earlier position of the design. Filed records are
  named by `project_name` slug only where the report must name one, as the records already do. *(completed)*
- [x] Add one row for the report to `docs/development/README.md`, in the "Project Organization"
  table beside the other design evaluations, following the row shape already used there. *(completed)*
- [x] Run the checks under Verification and fix forward. *(completed: readme-lint exit 0; task-reference lint exit 0; record-versioning 0 BLOCKING, none in the two touched files)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: Markdown-only edits under `docs/development/` with no compile surface, covered by `bash .claude/scripts/verify-deploy.sh --only-gate 4` (task-reference lint, the consumer-tree case of plan-format.md) together with `./scripts/readme-lint.sh docs` for relative references.

**Scope Hypothesis**: The declaration names listed in the first task are carried from the
research report (CARRIED-UNVERIFIED at plan time; the report itself established them by reading,
not by lookup). The implementer confirms each by `grep` in the named file before citing it. The
cslib claims are carried from the report's reading of `/home/benjamin/Projects/cslib` at
`3bdf16d9f`; if that checkout is absent or at another commit, the report cites the commit it
actually read or marks the section as carried from the research pass.

**Files to modify**:
- `docs/development/stability-operator-family.md` - new report, the task deliverable
- `docs/development/README.md` - one index row for the new report

**Verification**:
- `docs/development/stability-operator-family.md` exists, is non-empty, and addresses each of the
  task's four items under an identifiable heading.
- `./scripts/readme-lint.sh docs` exits 0 (it passed at plan time; exit status is the criterion).
- `bash .claude/scripts/check-task-references.sh docs/development` exits 0.
- `bash .claude/scripts/check-record-versioning.sh docs/development` exits 0 with 0 BLOCKING
  findings attributable to the two touched files.
- Diff read-through: `docs/development/README.md` changes by exactly the added row.

---

### Phase 2: Amend records/proof-mode-architecture.md [COMPLETED]

**Goal**: State the stratified shared statement and the three unshared pieces (R1, R3), and remove
the open decision.

**Tasks**:
- [x] Confirm the correction targets exist as quoted (they did at plan time): the paragraph
  beginning "**The Modal family has two operators and one statement of the S5 rules.**", the
  paragraph beginning "**The shared statement is a structure taking the operator as a field.**",
  the Modal row of the "Families" table, and item 1 of "## Open decisions" ("Is `⊡` rightly in
  the Modal family?"). If any is absent or reworded, locate the passage carrying the same content
  by `grep -n "⊡" records/proof-mode-architecture.md` and amend that; if none carries it, record
  the gap in the phase notes and add the statement under "### Families". *(completed: all four targets present as quoted)*
- [x] R1: rewrite the first paragraph so the shared statement is a K core (scope introduction,
  distribution, monotonicity, the diamond duals) with T, 4 and 5 (and D for a serial operator) as
  separate members an operator supplies when it has them. Cite `NecessityRules` in
  `FormalSystem/Theorems/ProofMode/Congruence/Modal.lean` as the compiled K core and its three
  instances. Adjust the Modal row of the "Families" table to match. *(completed)*
- [x] R3: replace the sentence "its remaining rules are interactions with Temporal" and the two
  "particular to `⊡`" sentences with three named pieces outside the shared statement: an
  **inclusion** (a rule about an ordered pair of operators, supplied only by a language with
  both); a **rigidity** rule (takes an operator and a formula class, is not schematic and says so
  in its statement: `⊡` with state-local formulas); and **interactions with Temporal, per
  operator**, so the `⊡` sections of `ModalTemporalBoolean` share no statement with those for
  `□`. *(completed)*
- [x] Replace the closing sentences of that paragraph ("Filing `⊡` under Modal is the position
  this design starts from; ... examines whether it should be a family of its own") with the
  position and its grounds in one or two sentences, linking
  `../docs/development/stability-operator-family.md`. *(completed)*
- [x] Remove item 1 from "## Open decisions" and renumber the remainder. Before and after,
  `grep -rn "proof-mode-architecture" records/ docs/` for references to that list by ordinal and
  repair any found. *(completed: no reference to this list by ordinal elsewhere in records/ or docs/)*
- [x] Run the checks under Verification. *(completed: both greps as required; record-versioning 0 BLOCKING; task-reference lint exit 0)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Markdown-only edit to one design record with no compile surface, covered by `bash .claude/scripts/verify-deploy.sh --only-gate 4` plus `bash .claude/scripts/check-record-versioning.sh records` and the diff read-through.

**Files to modify**:
- `records/proof-mode-architecture.md` - stratified shared statement, the three unshared pieces, open decision removed

**Verification**:
- `grep -n "rightly in the Modal family\|examines whether it should be" records/proof-mode-architecture.md` returns nothing.
- `grep -n "NecessityRules" records/proof-mode-architecture.md` returns at least one line.
- The link to `docs/development/stability-operator-family.md` resolves from `records/`.
- `bash .claude/scripts/check-record-versioning.sh records` exits 0 with 0 BLOCKING (plan-time
  baseline for `records/`: 0 BLOCKING, 2 ADVISORY, neither in this file).
- `bash .claude/scripts/check-task-references.sh records` exits 0.

---

### Phase 3: Amend records/theorem-library.md [NOT STARTED]

**Goal**: Make the operator set a coordinate of the lattice (R2), align the family description
with the stratified statement (R1), and remove the open decision.

**Tasks**:
- [ ] Confirm the correction targets exist as quoted (they did at plan time): "### Two operators
  in the Modal family" and its closing paragraph ("Filing `⊡` under Modal is the position this
  design starts from. Whether it should be a family of its own is under investigation ..."); the
  last sentence of "### Adding a family" ("... an S5 or weaker necessity over histories joins
  Modal ..."); the conservativity rows "L into L⁺ (`⊡` added)" and "`ModalBoolean` with `□` into
  `ModalBoolean` with both"; the "Transfer" row of the sources table ("... restated for `⊡` and
  `⟐`"); stage 1 "Enumerate" of the tableau pipeline; and item 1 of "## Open decisions". If one
  is absent, find the passage with the same content by `grep -n "⊡" records/theorem-library.md`;
  if none exists, record the gap and place the statement in the nearest section named here.
- [ ] R2, in "### The lattice" or "### Two operators in the Modal family": state that a **cell**
  is a fragment together with an operator set, and that conservativity edges run between cells.
  Restate the two conservativity rows in those terms: L into L⁺ is the edge that adds `⊡` to the
  operator set at `ModalTemporalBoolean`; the other is the same edge at `ModalBoolean`.
- [ ] R2, in "## Sources and the tableau pipeline": state that the pipeline, including its
  generalization of a certified formula from atoms to schema variables, runs on cells whose
  operator set is within `□`, because that generalization is sound only where uniform
  substitution holds.
- [ ] R1: in "### Two operators in the Modal family", describe the shared laws as a K core with T,
  4 and 5 as further members; in "### Adding a family", say at which strength each known operator
  joins (`□`, `⊡`, `▷`, `◁` at S5; `◈` at KD, once it has a calculus over the lattice's frame
  notion).
- [ ] Replace the section's closing paragraph with the position and its grounds, linking the
  report. Keep the three facts.
- [ ] Minor corrections: the state-local class is described by the tree's definition (any formula
  headed by `□` or `⊡` is state-local, whatever is beneath the head); the "Transfer" row reads
  "instantiated at `⊡` and `⟐`".
- [ ] Remove item 1 from "## Open decisions", keeping in the body any of its content that is a
  ground for the position, and renumber. Before and after,
  `grep -rn "theorem-library" records/ docs/` for references to that list by ordinal or by the
  question text, and note each for Phases 2 and 4 to repair in their own files.
- [ ] Run the checks under Verification.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Markdown-only edit to one design record with no compile surface, covered by `bash .claude/scripts/verify-deploy.sh --only-gate 4` plus `bash .claude/scripts/check-record-versioning.sh records` and the diff read-through.

**Files to modify**:
- `records/theorem-library.md` - operator set as a lattice coordinate, stratified laws, tableau condition, open decision removed

**Verification**:
- `grep -n "rightly in the Modal family\|under investigation\|restated for" records/theorem-library.md` returns nothing.
- The conservativity table still has six rows, two of them stated in terms of the operator set.
- The link to the report resolves from `records/`.
- `bash .claude/scripts/check-record-versioning.sh records` exits 0 with 0 BLOCKING; the advisory
  at line 4 of this file predates this plan and is left as found.
- `bash .claude/scripts/check-task-references.sh records` exits 0.

---

### Phase 4: Amend records/proof-mode.md [NOT STARTED]

**Goal**: Qualify M19's fragment list (R2) and remove every statement in the milestone record that
the place of `⊡` is undecided (R4).

**Tasks**:
- [ ] Confirm the correction targets exist as quoted (they did at plan time): M19's sentence
  listing the enumerated fragments; M21's sequencing clause "M23, whose answer decides whether
  these entries are sections of the Modal fragments or fragments of their own"; the M23 block,
  whose sequencing line ends "the design starts from `⊡` in Modal"; the lead-in "Two questions
  are open. The first awaits the user's ruling; the second waits on a report."; and item 2 of
  "## Open decisions". Locate M19's sentence with `grep -n "enumerat" records/proof-mode.md`. If
  a target is absent, find the passage by `grep -n "⊡\|M23" records/proof-mode.md`; if none
  carries it, record the gap in the phase notes and make no substitute edit.
- [ ] M19: qualify the fragment list so it reads as the cells whose operator set is within `□`.
- [ ] M21: replace the M23 sequencing clause with the settled statement that the `⊡` entries are
  sections of the `ModalBoolean` and `ModalTemporalBoolean` fragments, citing the report.
- [ ] M23: leave the aim and done-when as written; amend the sequencing line so it does not
  describe the layout as a starting position, and add the report path where the block names its
  output. Follow whatever convention the record uses for a milestone whose done-when is met;
  check two other milestone blocks for that convention before choosing, and add none if the
  record has none.
- [ ] Remove item 2 from "## Open decisions" and correct the lead-in count and sentence. Leave
  the "Four positions are taken by the filed edges" paragraph and its later reference untouched.
- [ ] `grep -n "M23" records/proof-mode.md` and read each remaining hit; the dependency-picture
  and lane references describe M23 as a report and stay.
- [ ] Run the checks under Verification.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Markdown-only edit to one design record with no compile surface, covered by `bash .claude/scripts/verify-deploy.sh --only-gate 4` plus `bash .claude/scripts/check-record-versioning.sh records` and the diff read-through.

**Scope Hypothesis**: The M23 hits outside the M21 and M23 blocks and the open-decision list
(dependency picture, lanes, the milestone-to-record table) are expected to need no edit.
Confirm by reading each `grep -n "M23"` hit; any that states the layout is undecided is amended
in this phase.

**Files to modify**:
- `records/proof-mode.md` - M19 qualifier, M21 sequencing clause, M23 block, open decision removed

**Verification**:
- `grep -n "rightly in the Modal family\|whose answer decides\|waits on a report" records/proof-mode.md` returns nothing.
- The M23 block still names `investigate_stability_as_modal_family` as its filed record.
- `bash .claude/scripts/check-record-versioning.sh records` exits 0 with 0 BLOCKING.
- `bash .claude/scripts/check-task-references.sh records` exits 0.

---

### Phase 5: Update the filed task descriptions and cross-check [NOT STARTED]

**Goal**: Remove the hedges from the six filed descriptions (R4) and confirm the report, the three
records and the descriptions agree.

**Tasks**:
- [ ] For each of the six tasks, assert the sentence below is present in its `description` in
  `specs/state.json` (quoted from the file at plan time; select by `project_name`). A miss stops
  the phase for that task and is recorded; the other five proceed.
  - `proof_mode_split_shared_test_and_guide_files`: "`investigate_stability_as_modal_family` may reverse this; do not wait on it."
  - `proof_mode_s5_aware_box_scopes`: the same sentence.
  - `proof_mode_abstract_frontend_interface`: "`investigate_stability_as_modal_family` may reverse the family layout; read its report if it exists."
  - `theorem_library_layout_and_registry`: "`investigate_stability_as_modal_family` may change the family set; the design starts from `⊡` in Modal and this record does not wait on it."
  - `theorem_library_stability_entries`: "FIRST read the report of `investigate_stability_as_modal_family`: if it recommends a separate family and the records have been revised, file these entries as that revision says; otherwise they are sections of the ModalBoolean and ModalTemporalBoolean fragments." and, in its sequencing list, the item "`investigate_stability_as_modal_family` (which decides where these entries are filed)".
  - `connective_signature_layer_shared_primitives`: "investigate_stability_as_modal_family may change whether the stability operator gets its own class or shares the Modal one; read its report if it exists but do not wait for it."
- [ ] Replace each with one settled sentence: the family layout is fixed with `⊡` in Modal, the
  shared statement is a K core with T, 4 and 5 as further members, and
  `docs/development/stability-operator-family.md` gives the grounds. For
  `theorem_library_stability_entries`, the replacement states that the entries are sections of
  the ModalBoolean and ModalTemporalBoolean fragments and the sequencing item is dropped. For
  `connective_signature_layer_shared_primitives`, the replacement states that the stability
  operator shares the Modal class. Change no other word of any description, and no `file_scope`,
  dependency or status.
- [ ] Apply all six through one `bash .claude/scripts/state-write.sh` invocation with
  `--session-id` and `--regen-todo`, the filter selecting by `project_name` and replacing by
  exact string (`sub` on an escaped literal, or split-and-join; no `!=`). Run it with `--dry-run`
  first. Read the script's header for the argument contract before composing the call; do not
  write `specs/state.json` by any other route.
- [ ] Confirm the write: `git diff --stat specs/state.json` shows a change confined to those six
  descriptions (compare `jq -S 'del(.active_projects[].description)'` of the HEAD and working
  copies, which must agree apart from fields other sessions own, such as `last_updated` and this
  task's own status), and each old sentence is absent.
- [ ] Confirm `specs/TODO.md` was regenerated and shows the new sentences.
- [ ] Cross-check: read the "Modal family" passages of the three records and the report's
  recommendation side by side and confirm they use the same terms (cell, operator set, K core,
  inclusion, rigid class) and none contradicts another.
  `grep -rn "rightly in the Modal family\|may reverse" records/ docs/development/` returns
  nothing, and `jq` over `specs/state.json` for descriptions containing "may reverse" or "may
  change the family set" returns only tasks unrelated to this layout, if any.
- [ ] Run the scoped check under Verification and record that the complete gate set is deferred
  to the orchestration close.

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Scope Hypothesis**: Six filed tasks carry a hedge, as listed. The list was derived at plan time
by selecting descriptions containing `investigate_stability_as_modal_family`; confirm at
implementation with an independent selection on "may reverse", "may change" and "FIRST read the
report" before writing, and add any task that selection finds whose hedge concerns this layout.

**Files to modify**:
- `specs/state.json` - six `description` fields, exact sentence replacement
- `specs/TODO.md` - regenerated from `specs/state.json` in the same write

**Verification**:
- `bash .claude/scripts/validate-state.sh` exits 0.
- Scoped touched-path check for this dispatch:
  `bash .claude/scripts/verify-touched.sh --task-dir specs/970_investigate_stability_as_modal_family`
  (no path arguments, so it derives the touched set itself), exit status checked. Under
  `/orchestrate` the complete gate set is deferred to the orchestration close and is not run
  independently by this phase; a standalone run instead runs
  `bash .claude/scripts/verify-deploy.sh` directly.
- The cross-check greps in the task list return as stated.

## Testing & Validation

- [ ] `docs/development/stability-operator-family.md` exists and answers the task's four items.
- [ ] `./scripts/readme-lint.sh docs` exits 0.
- [ ] `bash .claude/scripts/check-task-references.sh` exits 0 over `docs/development` and `records`.
- [ ] `bash .claude/scripts/check-record-versioning.sh` reports 0 BLOCKING over `docs/development` and `records`.
- [ ] No record lists "Is `⊡` rightly in the Modal family?" as open.
- [ ] No filed description defers to this investigation; `bash .claude/scripts/validate-state.sh` exits 0.
- [ ] `git diff --stat` shows no `.lean` file changed.

## Artifacts & Outputs

- `docs/development/stability-operator-family.md` (new; the task deliverable)
- `docs/development/README.md` (index row)
- `records/proof-mode-architecture.md`, `records/theorem-library.md`, `records/proof-mode.md` (amended)
- `specs/state.json`, `specs/TODO.md` (six descriptions, regenerated view)
- `specs/970_investigate_stability_as_modal_family/summaries/01_stability-modal-family-layout-summary.md`

## Rollback/Contingency

Each phase is one commit over its own files, so a phase is undone with `git revert` of that
commit; no phase depends on another's bytes. If the record amendments are not wanted, revert
Phases 2 to 5 and keep Phase 1, which alone meets M23's done-when. If a later ruling goes for a
separate Stability family, the report's "What a separate Stability family would require" section
is the work list, and it is filed as a new task rather than patched into this one. Discarding
uncommitted work, if ever needed, follows the snapshot-then-rollback rung of
`.claude/context/contracts/recovery.md`; no routine snapshot is taken.
