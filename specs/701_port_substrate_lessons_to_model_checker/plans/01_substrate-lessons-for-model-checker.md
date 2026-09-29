# Implementation Plan: Task #701

- **Task**: 701 - port_substrate_lessons_to_model_checker
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: 696 (BimodalLogic, `completed` — verified landed in-tree, see Phase 1)
- **Research Inputs**: `specs/701_port_substrate_lessons_to_model_checker/reports/01_substrate-lessons-for-model-checker.md`
- **Artifacts**: plans/01_substrate-lessons-for-model-checker.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: general
- **Lean Intent**: false

## Overview

The research phase established that the BimodalLogic stability-modal substrate redesign has
landed (not merely been designed), which makes two already-written ModelChecker artifacts
factually stale and makes the dispatch's "now versus later" question resolve differently than it
was posed. This implementation phase writes exactly one deliverable: a summary under this task's
own `summaries/` directory carrying ready-to-file ModelChecker task descriptions — a re-scoped
task 200, a reopen-and-amend for task 219, and one new documentation task — together with a
phased now-versus-later proposal. No ModelChecker source, no ModelChecker task state, and no
BimodalLogic source outside this task's `specs/` subtree is touched. Done means the summary file
exists, every Lean and Python identifier it cites has been re-verified against the live trees at
write time, and each ready-to-file block is copy-pasteable into ModelChecker's own task system
without further editing.

### Research Integration

The report's five research answers map onto the phases below as follows. Q1 (what the certificate
search assumes today and what the thread/`trans`/`Liftable` account replaces) and Q2 (which
lessons port to which `semantic/` files) are the substance of the re-scoped task 200 text in
Phase 2. Q3 splits: the task 200 half is Phase 2, the task 219 half is Phase 3. Q4 (the wire
contract is additive, nothing must change now) becomes a recorded decision inside the task 200
text and a line in the phased proposal in Phase 5. Q5 (restating the Box case over threads ahead
of sharing) becomes the one new ModelChecker task in Phase 4.

Three report claims were re-verified during planning and all held, with one drift worth carrying
forward: BimodalLogic task 703 has moved from `researching` to `planning` since the report was
written. This is the exact staleness failure mode the report itself flagged as its top risk, and
it confirms Phase 1 is load-bearing rather than ceremonial.

Planning also found a defect the report did not fully enumerate. Report finding F8 names two
defects in ModelChecker's THEORY-LIMITS group, one of omission and one of framing. There is a
third, harder one: the group cites three Lean theorem names that no longer exist anywhere in the
BimodalLogic tree. `not_plusCertifies_stabSnce` and `not_plusCertifies_stabSnce_premise` are cited
in the FACT 2 block, and `snce_share_congr` is cited in the SHAPE MECHANISM block; a grep across
`FormalSystem/` finds no declaration for any of the three. The first two were deleted by the
redesign, and the third is explicitly described in `Sharing/Agreement.lean` and
`PlusWitnessFamily/Incompleteness.lean` as *retired* and *refuted*, with the tree now carrying
`not_snce_share_congr` in its place. These are dangling citations, not merely stale framing, and
Phase 3 treats them as a distinct third defect.

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so no roadmap consultation was
performed as a plan input. `specs/ROADMAP.md` does exist; a relevance check found no roadmap item
covering the ModelChecker hand-off, the sharing substrate's consuming side, or cross-repository
transcription. This task advances no tracked roadmap item, and the roadmap needs no update.

## Goals & Non-Goals

**Goals**:

- Produce ready-to-file replacement text for ModelChecker task 200's description, correcting its
  stale upstream-status framing and carrying the Q1/Q2 file-level mapping so its eventual planner
  does not re-derive it.
- Produce ready-to-file text for a ModelChecker task 219 reopen-and-amend, covering all three
  defects in the THEORY-LIMITS group: the missing Until-side schema, the now-false standing-gap
  framing, and the three dangling Lean citations.
- Produce a ready-to-file description for one new ModelChecker documentation task restating the
  Box case over threads.
- Record the phased now-versus-later proposal, including the confirmed finding that nothing in
  ModelChecker must change now for wire-format correctness.
- Ensure every cited identifier, file path, line anchor, and task status in the deliverable was
  verified against a live tree during this implementation phase, with the verification commands
  recorded so a later reader can re-run them.

**Non-Goals**:

- Editing any file under `/home/benjamin/Projects/ModelChecker`. The research and plan phases read
  that repository; this phase also only reads it. Filing and executing the proposals is done in
  the ModelChecker repository by whoever next works there.
- Changing any ModelChecker task status. Reopening task 219 is recommended text, not an action
  taken here.
- Editing any BimodalLogic file outside `specs/701_port_substrate_lessons_to_model_checker/`.
- Implementing any part of the sharing extension, the `trans*` wire fields, or a splice-closed
  constraint generator in either repository.
- Adding a `.claude/context/` pattern for cross-repository staleness. The report flagged this as a
  context-extension idea; `.claude/**` is a deploy artifact regenerated from a source store, so a
  hand-authored file there would be wiped. It is recorded as a proposal in the summary, not filed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-repository staleness: a cited status or identifier changes between planning and writing | H | H | Phase 1 re-runs every verification command immediately before the writing phases and records the results with a timestamp; already observed once (703 moved `researching` to `planning` during planning) |
| Sibling task 703 is live this cycle with scope over `PlusWitnessFamily/Compression/` and may rename or reshape identifiers this deliverable cites | M | M | Cite each Lean theorem by name *and* by the statement it makes, so a rename degrades the text rather than invalidating it; re-grep in Phase 1 and again in Phase 5 |
| Repository-boundary violation: editing ModelChecker source or task state directly | H | L | Declared a hard non-goal; Phase 5 verifies `git status` in the ModelChecker repository is unchanged by this task before closing |
| Over-staging on a shared working tree with two concurrent sibling tasks | M | M | Stage only the explicit summary path; never a directory or glob pathspec; re-read before writing |
| The deliverable grows into commentary rather than copy-pasteable task text | M | M | Each ready-to-file block is a fenced verbatim block; surrounding prose is capped at a short rationale paragraph per block |
| Recommending a `completed`-to-reopened transition for task 219 exceeds this task's authority | L | L | The deliverable states it as a recommendation for ModelChecker's own task system to execute, matching the research report's own posture |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases 2 through 4 are logically independent of one another but all append to the same single
output file, so they are chained rather than declared parallel. Do not attempt to run them
concurrently.

---

### Phase 1: Re-verify cross-repository ground truth and open the summary [COMPLETED]

**Goal**: Establish, at write time, that every fact the deliverable will assert still holds, and
create the summary file carrying that verification snapshot as its first substantive section.

**Tasks**:

- [x] Create `summaries/` under the task directory if absent. *(completed)*
- [x] Re-run the BimodalLogic checks: task 696 status and `last_updated` from `specs/state.json`;
      presence of `transBack`/`transMid`/`transFwd`/`Liftable` in
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean`; presence of
      `plusCertifies_stabSnce_example` and `plusCertifies_stabUntl_example` in
      `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean`; task 703's current
      status. *(completed: 696 completed/16:18:36Z confirmed; trans*/lift confirmed as LiftableRaw
      field; both gate examples confirmed present; 703 drifted further to "implementing")*
- [x] Re-run the absence checks for the three dangling citations: grep `FormalSystem/` for
      declarations named `not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise`, and
      `snce_share_congr`, and confirm each returns no declaration site. Record what stands in
      their place (`not_snce_share_congr`, `not_untl_shift_share_congr`, and the surviving
      `not_plusValidZTime_stabSnce`/`not_plusValidZTime_stabUntl`). *(completed: all three
      confirmed dangling, no fourth found, replacements confirmed present)*
- [x] Re-run the ModelChecker checks: current status and `last_updated` for tasks 200 and 219;
      current line anchors for the THEORY-LIMITS header block and the `TL_CM_1`/`TL_CM_2` entries
      in `examples.py`; confirm no `trans*` key appears in any file under
      `tests/fixtures/certificates/`. *(completed: 200 blocked/11:28:06Z, 219 completed/15:03:54Z,
      header 1335-1427, TL_CM_1 1429-1449, TL_CM_2 1451-1469, no trans* in any fixture)*
- [x] Write the summary file's header and a "Verification snapshot" section recording each command
      and its result, with an ISO timestamp. *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts that the report's ground-truth claims still hold and that
exactly three cited Lean identifiers are dangling. Both are hypotheses. Confirm by running the
greps above and recording the raw results; if a fourth dangling citation appears, or if a
previously dangling name has been reinstated, widen or narrow Phase 3's scope accordingly and say
so in the snapshot rather than carrying the plan's number forward unchanged.

**Files to modify**:

- `specs/701_port_substrate_lessons_to_model_checker/summaries/01_substrate-lessons-for-model-checker-summary.md` - created; header and Verification snapshot section

**Verification**:

- The summary file exists and is non-empty.
- Every command in the snapshot section was actually run this phase, and its recorded result
  matches the live tree.
- Any divergence from the research report's stated facts is called out explicitly in the snapshot
  rather than silently overwritten.

---

### Phase 2: Write the re-scoped task 200 description [COMPLETED]

**Goal**: Produce copy-pasteable replacement text for ModelChecker task 200's description that
corrects the stale upstream framing and carries the file-level porting map.

**Tasks**:

- [x] Read ModelChecker task 200's current description in full from that repository's
      `specs/state.json`, so the replacement preserves what is still correct rather than rewriting
      from scratch. *(completed)*
- [x] Replace the upstream-status paragraph: state that the BimodalLogic redesign is completed and
      landed, name `Sharing/Skeleton.lean` as the home of the `trans`/`Liftable` datum, and name
      both gate families as landed `PlusCertifies` proofs rather than archived probes. *(completed)*
- [x] Restate the blocker: the design dependency is discharged; what remains is the compression
      and enumeration bound, whose upstream task is in planning, not complete. Do not state that
      the blocker lifts. *(completed: upstream task is now "implementing", not "planning" -- see
      Phase 1's snapshot -- text updated to the current word, same non-complete substance)*
- [x] Fold in the Q1 replacement table: histories-as-lasso-orbits gives way to threads proved from
      `Liftable`; Saturation and Limit are unaffected; Box faithfulness needs the closure
      obligation; succession, currently identity on the lasso index in `_coherence_clause_at`,
      becomes a `trans`-indexed neighbour lookup. *(completed)*
- [x] Fold in the Q2 porting map with its four file-level targets, including the finding that the
      pure-Python re-checker will need its own independently written thread characterization to
      preserve the independent-re-decision discipline, and the recorded decision that the `trans*`
      fields belong on the family rather than on the individual labelled lasso. *(completed)*
- [x] Add a forward pointer to this task's research report by title and date, not by task number,
      since the pointer is consumed inside ModelChecker's own task system. *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Files to modify**:

- `specs/701_port_substrate_lessons_to_model_checker/summaries/01_substrate-lessons-for-model-checker-summary.md` - append the task 200 ready-to-file block

**Verification**:

- The block is a single fenced, verbatim, copy-pasteable description with no placeholders.
- Every Python path it names exists under
  `code/src/model_checker/theory_lib/bimodal/` in the live ModelChecker tree.
- Every Lean identifier it names was confirmed present in Phase 1's snapshot.
- The text nowhere claims the blocker lifts.

---

### Phase 3: Write the task 219 reopen-and-amend text [COMPLETED]

**Goal**: Produce ready-to-file text covering all three defects in the THEORY-LIMITS group, with
the corrected header wording drafted concretely enough to apply.

**Tasks**:

- [x] Draft the framing correction. The group's FACT 2 and STANDING CONSEQUENCE blocks assert an
      empty certificate class as a permanent property of the verified side's design; both gate
      families are landed counterexamples to that claim for the two atomic schemas. Rewrite so the
      text distinguishes a limit of the theory from a limit of a since-repaired certificate
      system, records the repair, and narrows what is still open to the general
      guard/event-parametric question. *(completed)*
- [x] Draft the correction for the three dangling citations. Remove or replace the two deleted
      non-certification theorems and the retired congruence, naming what the tree carries instead
      and what each surviving theorem actually states. Keep the two genuine ZZ-time non-validity
      citations, which were confirmed present. *(completed: replaced with not_snce_share_congr /
      not_untl_shift_share_congr, both cited for what they actually prove -- refutation of the
      old congruence, not certification)*
- [x] Draft the Until-side addition: the second schema, its own fact pair in the header comment,
      and a matching pair of nearest-expressible Box-analogue entries following the existing
      naming and shape of the two current entries. *(completed: TL_CM_3/TL_CM_4, settings carried
      over from TL_CM_1/TL_CM_2 as a starting point since this phase does not run the solver)*
- [x] State explicitly which parts of the existing group are correct and must be kept verbatim:
      the two existing entries with their measurements, and the corrected shape-mechanism
      explanation, minus its dangling citation. *(completed)*
- [x] State the recommended status transition as a recommendation for ModelChecker's task system,
      not an action taken here. *(completed)*

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts three defects, two existing countermodel entries to
preserve, and a matching pair of new Until-side entries to add. Confirm each against the live
`examples.py` at write time: re-read the THEORY-LIMITS block, count the existing entries, and
confirm the Until-side schema is absent from the file outside docstring prose. Adjust the counts
in the deliverable to whatever the tree shows rather than to what this plan predicted.

**Files to modify**:

- `specs/701_port_substrate_lessons_to_model_checker/summaries/01_substrate-lessons-for-model-checker-summary.md` - append the task 219 ready-to-file block

**Verification**:

- Every Lean identifier the amended header text cites resolves to a declaration in the live
  BimodalLogic tree; no dangling name survives into the proposed replacement.
- The proposed header text contains no claim that a certificate class is empty for a schema for
  which a landed certifying family exists.
- The Until-side schema is named explicitly, not described only as behaving "the same way".
- The block distinguishes, in words, a limit of the theory from a limit of a since-repaired
  certificate system.

---

### Phase 4: Write the new ModelChecker task description and record the non-tasks [NOT STARTED]

**Goal**: File the one genuinely new piece of work as a ready-to-file description, and record
explicitly which candidate items are deliberately not being filed as separate tasks.

**Tasks**:

- [ ] Write the new documentation task description: restate the adequacy document's histories
      lemma and its Box corollary as the specialization of the verified side's thread
      characterization to the trivial full-succession case, so a later sharing extension is a
      refinement rather than a rewrite. Scope it as documentation-only, zero code change, with no
      upstream dependency.
- [ ] Record the decision not to file the `trans*` wire fields as a separate task, with the
      reason: the fields are additive and safe, but adding them before a producer emits them or a
      consumer needs them is dead code, so they belong inside task 200's scope, sequenced with the
      search work rather than ahead of it.
- [ ] Record the decision not to file the cross-repository staleness context pattern here, with
      the source-store and deploy-artifact reason, leaving it as a named proposal.
- [ ] For each filed and non-filed item, state its dependency status plainly so a reader can tell
      what is startable today.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts exactly one new task to file and two candidates
deliberately not filed. Confirm by re-reading the research report's phased proposal table and
checking that no fifth row implies additional independent work; if a further independent item
surfaces, file it rather than forcing it into the recorded-decision list.

**Files to modify**:

- `specs/701_port_substrate_lessons_to_model_checker/summaries/01_substrate-lessons-for-model-checker-summary.md` - append the new-task block and the recorded non-task decisions

**Verification**:

- The new task description is copy-pasteable and names its target document and the argument shape
  to restate.
- Each non-filed candidate carries a stated reason, not merely an omission.
- No filed item asserts a dependency that Phase 1's snapshot contradicts.

---

### Phase 5: Write the phased proposal, close the deliverable, and confirm the boundary [NOT STARTED]

**Goal**: Complete the summary with the now-versus-later proposal, re-check every citation once
more, and confirm no file outside this task's directory was touched.

**Tasks**:

- [ ] Write the phased proposal section: what changes now, what is cheap and unblocked, what is
      blocked on the compression bound, and what is blocked on a ModelChecker-side decision to
      pursue sharing at all.
- [ ] State the confirmed wire-level conclusion in one place: nothing in the ModelChecker tree must
      change now for correctness, the three fields are additive when they land, absent means full
      on both sides, and an omitted key is not the same wire payload as an explicit null.
- [ ] Re-run the Phase 1 verification commands once more and reconcile: if anything drifted during
      the writing phases, correct the affected block and note the drift.
- [ ] Confirm `git status` in the ModelChecker repository shows no modification attributable to
      this task, and that this repository's working tree carries no change outside
      `specs/701_port_substrate_lessons_to_model_checker/`.
- [ ] Commit the summary with an explicit single-path pathspec. Never a directory or glob add; two
      sibling tasks are live on this working tree.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: prose

**Files to modify**:

- `specs/701_port_substrate_lessons_to_model_checker/summaries/01_substrate-lessons-for-model-checker-summary.md` - append the phased proposal and close the document

**Verification**:

- The summary contains, in order: verification snapshot, task 200 block, task 219 block, new task
  block, recorded non-task decisions, phased proposal.
- A final grep confirms every Lean identifier cited anywhere in the summary resolves in the live
  tree, and every ModelChecker path cited exists.
- `git status --short` in the ModelChecker repository shows nothing attributable to this task.
- The staged path list for the commit contains only the summary file.

---

## Testing & Validation

- [ ] Every Lean theorem name appearing anywhere in the summary resolves to a declaration in
      `FormalSystem/`, verified by grep at close time.
- [ ] Every ModelChecker file path appearing in the summary exists in that repository.
- [ ] No dangling identifier from the current THEORY-LIMITS group survives into the proposed
      replacement text.
- [ ] Each ready-to-file block is self-contained: no unresolved placeholder, no reference to this
      plan or to a BimodalLogic task number inside text destined for ModelChecker's task system.
- [ ] The ModelChecker working tree is unmodified by this task.
- [ ] This repository's working tree carries no change outside this task's directory.
- [ ] `bash .claude/scripts/validate-artifact.sh` passes on the summary, if that script accepts
      summary artifacts in this deploy.

## Artifacts & Outputs

- `specs/701_port_substrate_lessons_to_model_checker/summaries/01_substrate-lessons-for-model-checker-summary.md`
  — the sole deliverable, containing the verification snapshot, three ready-to-file ModelChecker
  task texts, the recorded non-task decisions, and the phased now-versus-later proposal.
- `specs/701_port_substrate_lessons_to_model_checker/.return-meta.json` — implementation-phase
  return metadata.
- `specs/701_port_substrate_lessons_to_model_checker/.orchestrator-handoff.json` — orchestrator
  handoff.

## Rollback/Contingency

The deliverable is a single new markdown file under this task's own directory, so rollback is
removal of that one path; no other file is touched and no build or test state depends on it. If a
phase must be abandoned mid-write, leave the partial summary in place, mark the phase heading
`[PARTIAL]`, and record in the summary which sections are incomplete, so the next dispatch resumes
rather than restarts.

Do not run a reverting working-tree snapshot as a precaution here. Two sibling tasks are live on
this shared tree this cycle, and a whole-tree revert would discard their in-flight work. If a
genuine rollback of committed work ever becomes necessary, follow the rollback rung in
`context/contracts/recovery.md` for the correct invocation shape rather than improvising one.
