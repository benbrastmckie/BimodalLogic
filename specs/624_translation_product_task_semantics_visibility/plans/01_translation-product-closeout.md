# Implementation Plan: Task #624

- **Task**: 624 - translation_product_task_semantics_visibility
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/624_translation_product_task_semantics_visibility/reports/01_translation-product-visibility.md
- **Artifacts**: plans/01_translation-product-closeout.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a **closeout plan, not a build plan**. Task 624 is a verdict-first research task: its
report and two sorry-free probes are complete, and its four recommendations have already been
executed or forwarded by downstream work that has since completed. The task description's own
reconciliation note (2026-09-22) states this outright — "No further rounds are expected here;
this task is complete as research" — and the task's declared scope forbids any change to
`FormalSystem/` or `Tests/`. There is therefore no Lean implementation work left to schedule.

What the plan does schedule is the small amount of genuine work the closeout still owes: a
verification sweep confirming that each reconciliation claim actually holds against the live
tree (not merely against the note), the one recommendation that is **not** yet forwarded
anywhere (report §2.4's three categorical questions, owed to task 618), and an execution summary
recording the terminal disposition. If the Phase 1 sweep finds a claim that does not hold, the
plan's scope grows accordingly and that becomes the finding — see the Scope Hypothesis on
Phase 1.

### Research Integration

From `reports/01_translation-product-visibility.md`, the four recommendations and their present
status (each verified during planning; Phase 1 re-verifies at execution time):

1. **Rec 1 — port into `FormalSystem`**: DELIVERED by task 645 (completed).
   `FormalSystem/Semantics/Frames/TranslationProduct.lean` (34,847 bytes),
   `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean`, and the optional third
   module `FormalSystem/Semantics/HistoryMorphism.lean` all exist, all contain zero `sorry`
   occurrences, and the three `*ValidIn_iff_recurrenceFree` theorems are present
   (`TranslationProduct.lean:597`, `:630`, plus `validIn_iff_recurrenceFree`). Probe 02's
   `zeroFix` results are mirrored at `specs/evidence/translation-product/limit-idle-mirror.lean`.
2. **Rec 2 — manuscript remark**: an author decision outside the repository. It is additionally
   carried as Q5/recommendation (ii) of task 653 (completed), so the question has a repository
   home even though the edit does not.
3. **Rec 3 — for task 559**: ABSORBED. Task 559's description already carries the findings as its
   established item (h), naming `prodFrame`, `saturation_of_prodRel`, the three
   `*ValidIn_iff_recurrenceFree` theorems, `colourClock`, `frame_validity_not_reflected`, and the
   `TD_zeroFix`/`zeroFix_limit_clocked` Limit-idleness results, plus the scoping of the dense BLC
   countermodel in its item (b).
4. **Rec 4 — for task 618**: **NOT FORWARDED.** Task 618's description (`not_started`) contains
   no reference to task 624, to the translation product, or to report §2.4's three questions
   about `Path(prodFrame F)` as the pullback of `len : Path(F) → BD⁺` along `(D, ≤) → BD⁺`. This
   is the single outstanding action, and Phase 2 discharges it.

The report's Q5 residue (what the device leaves untouched about the stability modal, and which
extensions do see recurrence) was spun out as task 653, which is completed.

### Prior Plan Reference

No prior plan. This is the first plan artifact for task 624; the task went research → (stranded
`planning`) → this dispatch.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so `specs/ROADMAP.md` was not consulted
as a planning input. A confirming grep found no translation-product or recurrence-free entry in
it, so no roadmap item is advanced or closed by this plan.

## Goals & Non-Goals

**Goals**:
- Confirm, against the live tree rather than against a note, that every recommendation of
  `reports/01_translation-product-visibility.md` is delivered, forwarded, or explicitly out of
  repository scope.
- Forward report §2.4's three categorical questions to task 618, the one recommendation with no
  recipient.
- Record the closeout in an execution summary so the task's terminal disposition is legible
  without re-reading the 511-line report.

**Non-Goals**:
- Any change to `FormalSystem/` or `Tests/`. The task description forbids it, and the port
  already landed under task 645; re-opening it here would duplicate completed work.
- Any new probe, new research round, or attempt at the report's UNVERIFIED items (Appendix B).
  Those are scoped to tasks 559 (dense BLC countermodel, `.Dense` paste-closed soundness) and 618
  (the categorical reading), not here.
- The manuscript edit of Recommendation 2. It is an author decision on a file outside this
  repository.
- Re-litigating any verdict in the research report. The report is the input, not the subject.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent sibling task 662 is dispatched this same cycle with **no declared `file_scope`**, and Phase 2 edits the shared `specs/state.json` | H | M | Re-read `specs/state.json` immediately before the edit; use a targeted `jq` update of task 618's `.description` only; stage `specs/state.json` and `specs/TODO.md` by explicit filename, never a directory or glob pathspec; if a foreign uncommitted modification or foreign commit appears, STOP and report per `context/contracts/territory.md` |
| A wholesale rewrite of `specs/state.json` silently drops another task's artifact links | H | L | `.claude/rules/state-management.md` forbids wholesale `.artifacts = [...]` assignment; Phase 2 touches exactly one field (`.description` of project 618) via a targeted `jq` filter and diffs the result before committing |
| Phase 2 edits `specs/state.json`, which lies **outside** task 624's declared `file_scope` (`probes/`, `reports/`) | M | H (by design) | Declared and accepted here rather than discovered at execution time: appending a dated reconciliation note to a related task's description is an established pattern in this repository (tasks 618, 624 and 653 all carry such notes). The edit is append-only and confined to one field |
| Phase 1 finds a reconciliation claim that does not hold, invalidating the closeout premise | H | L | Phase 1 carries an explicit Scope Hypothesis; a falsified claim is a reportable finding that halts the closeout and is recorded in the summary rather than papered over |
| `jq` `!=` escaping bug (Claude Code issue #1132) corrupts the Phase 2 filter | M | L | Use `select(.project_number == 618)` positively; never an `!=` comparison. See `.claude/context/patterns/jq-escaping-workarounds.md` |
| The closeout is read as abandoning open questions | M | M | The summary names each UNVERIFIED item's owning task explicitly, so nothing is closed silently |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. These three are strictly sequential: Phase 2
acts only on what Phase 1 confirms is still outstanding, and Phase 3 records the outcome of both.

---

### Phase 1: Verify the reconciliation ledger [NOT STARTED]

**Goal**: Establish, by direct observation of the live tree, whether each of the research
report's four recommendations is delivered, forwarded, or out of repository scope — so that the
closeout rests on evidence rather than on the description's 2026-09-22 note.

**Tasks**:
- [ ] Read `reports/01_translation-product-visibility.md` §Recommendations (lines 371-410) and
      §Appendix B (UNVERIFIED items, lines 485-496) in full.
- [ ] Rec 1: confirm `FormalSystem/Semantics/Frames/TranslationProduct.lean`,
      `FormalSystem/Metalogic/Independence/TranslationProductCoarse.lean` and
      `FormalSystem/Semantics/HistoryMorphism.lean` all exist and contain zero `sorry`
      (`grep -c sorry` on each; expect `0`).
- [ ] Rec 1: confirm all three of `validIn_iff_recurrenceFree`,
      `plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree` are `theorem`
      declarations in `TranslationProduct.lean`.
- [ ] Rec 1: confirm `specs/evidence/translation-product/limit-idle-mirror.lean` exists (probe
      02's `zeroFix` mirror).
- [ ] Rec 1: confirm the module docstring of `TranslationProduct.lean` carries the standing
      caveat (proof device / time-unfolding, never an intended model) and the frame-level
      non-reflection record. If it does not, that is a finding for the summary — do NOT edit the
      module (out of scope; it belongs to task 645's territory).
- [ ] Rec 1: confirm task 645 is `completed` in `specs/state.json` and that
      `specs/645_port_translation_product_into_library/summaries/01_port-translation-product-summary.md`
      records a green build. Do NOT run a full `lake build` — the port is already committed and
      verified by 645, and this task must not touch `FormalSystem/`.
- [ ] Rec 3: confirm task 559's description in `specs/state.json` carries the translation-product
      findings (established item (h), plus the dense-countermodel scoping in item (b)).
- [ ] Rec 2 / Q5 residue: confirm task 653 is `completed` and that its description carries both
      the stability-modal residue and the manuscript-remark question as its recommendation (ii).
- [ ] Rec 4: confirm task 618's description contains **no** reference to task 624, the
      translation product, or the pullback questions — i.e. that Phase 2 is genuinely needed.
- [ ] Record each check's outcome (claim, command run, observed result, verdict) in a scratch
      ledger for Phase 3 to transcribe. Use the session scratchpad, not a file in the repository.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that **exactly one** recommendation (Rec 4 → task 618)
remains outstanding, and that all three ported modules are present and sorry-free. Both are
hypotheses formed at planning time from the checks listed above, not established facts. The
implementer confirms them by running those checks. If an additional gap is found — a missing
theorem, a `sorry`, a missing docstring caveat, an absent forwarding — record it in the summary
and, where it lies outside this task's scope (anything under `FormalSystem/`, `Tests/`, or
another task's deliverables), report it as a finding for a new task rather than fixing it here.

**Files to modify**:
- None. This phase is read-only.

**Verification**:
- Every bullet above has a recorded outcome with the command that produced it.
- Each of the four recommendations has exactly one verdict: `delivered`, `forwarded`,
  `out-of-repository`, or `outstanding`.
- No file in the working tree is modified by this phase (`git status --short` unchanged for
  `FormalSystem/`, `Tests/`, and `specs/`).

---

### Phase 2: Forward report §2.4 to task 618 [NOT STARTED]

**Goal**: Give the one un-forwarded recommendation a recipient, by appending a dated
reconciliation note to task 618's description recording report §2.4's three categorical questions
as an appendix item to take up once `Path(F)` exists.

Run this phase only if Phase 1 confirmed Rec 4 is `outstanding`. If Phase 1 found the forwarding
already present, mark this phase `[COMPLETED WITH EXCLUSIONS]` with that finding as the reason
and proceed to Phase 3.

**Tasks**:
- [ ] Re-read `specs/state.json` immediately before editing (sibling task 662 is in flight on
      this same working tree with no declared `file_scope`).
- [ ] Draft the note. It must: be dated; name the source artifact by path
      (`specs/624_translation_product_task_semantics_visibility/reports/01_translation-product-visibility.md`,
      §2.4); state the three questions in the report's own terms — (a) is
      `Path(prodFrame F)` the pullback of `len : Path(F) → BD⁺` along `(D, ≤) → BD⁺` on the nose,
      with objects `W × D` and the projection as the pullback leg; (b) is `len` restricted to the
      pullback the height functor to `(D, ≤)`, and does `cor:path-fibration`'s discrete Conduché
      property transfer to it; (c) do `liftH`/`projH` express that the pullback along a poset is
      a discrete fibration over `D` — and state explicitly that these are an **appendix item, not
      a scope expansion**, to be taken up only once `Path(F)` exists, consistent with 618's
      existing HARD SCOPE LIMIT.
- [ ] Name the live module `FormalSystem/Semantics/Frames/TranslationProduct.lean` in the note so
      a future reader of 618 reaches the definitions without going through `specs/`.
- [ ] Apply the note by appending to task 618's `.description` with a targeted `jq` filter
      selecting `.project_number == 618` (positive comparison only — never `!=`, per
      `.claude/context/patterns/jq-escaping-workarounds.md`). Do not touch `.artifacts`,
      `.dependencies`, `.status`, or any other task's entry.
- [ ] Diff the result: `jq` the new and old `specs/state.json` and confirm the only difference is
      task 618's `.description` (and its `last_updated`, if the helper sets one). Confirm the
      file is still valid JSON and that the `active_projects` array length is unchanged.
- [ ] Regenerate TODO.md: `bash .claude/scripts/generate-todo.sh`. Never hand-edit `specs/TODO.md`.
- [ ] Stage by explicit filename only (`git add -- specs/state.json specs/TODO.md`) and commit.
      Never a directory or glob pathspec; never `git add -A`; never `git commit -am`.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `specs/state.json` - append a dated reconciliation note to task 618's `.description`; no other
  field and no other task entry touched.
- `specs/TODO.md` - regenerated from `state.json` by `generate-todo.sh`; never hand-edited.

**Verification**:
- `jq empty specs/state.json` exits 0 (valid JSON).
- `jq '[.active_projects[].project_number] | length'` is unchanged from before the edit.
- `jq -r '.active_projects[] | select(.project_number == 618) | .description'` ends with the new
  note, and the text preceding it is byte-identical to the prior description.
- No other task's description, status, dependencies, or artifacts changed (diff of the two
  `jq -S .` renderings shows only the 618 description and its `last_updated`).
- `git diff --staged --name-only` lists exactly `specs/state.json` and `specs/TODO.md`.

---

### Phase 3: Write the closeout summary and record terminal disposition [NOT STARTED]

**Goal**: Leave a legible record of why task 624 closes with no implementation of its own, what
each of its recommendations became, and which of its open questions belong to which other task.

**Tasks**:
- [ ] Write `specs/624_translation_product_task_semantics_visibility/summaries/01_translation-product-closeout-summary.md`
      following `.claude/context/formats/summary-format.md`.
- [ ] Include the reconciliation ledger from Phase 1 as a table: recommendation, verdict,
      evidence (file path, theorem name, or task number), and the command that established it.
- [ ] Include an **open-questions ownership** table transcribing report Appendix B's UNVERIFIED
      items against their owning task: the dense saturated BLC countermodel and the `.Dense` form
      of paste-closed soundness → 559; the categorical pullback reading → 618 (forwarded in
      Phase 2); the recurrence-free-but-clockless cover (§2.3, ~80 lines of `ℤ`-walk bookkeeping,
      deliberately left on paper) → no owner, recorded as a deliberate non-goal; the stability-
      modal residue → 653 (completed).
- [ ] State the terminal disposition plainly: task 624 is complete **as research**; its
      deliverables are the report and the two sorry-free probes; it produced no change to
      `FormalSystem/` or `Tests/` by design.
- [ ] Record any Phase 1 finding that fell outside scope (per that phase's Scope Hypothesis) as a
      named candidate for a new task, with enough detail to create one — do not create it here.
- [ ] Stage by explicit filename and commit.

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `specs/624_translation_product_task_semantics_visibility/summaries/01_translation-product-closeout-summary.md`
  - new file; the closeout record.

**Verification**:
- The summary exists, is non-empty, and conforms to `summary-format.md`.
- Every one of the report's four recommendations appears in the ledger table with a verdict and
  evidence.
- Every UNVERIFIED item in report Appendix B appears in the ownership table with an owning task
  or an explicit "no owner, deliberate non-goal".
- No task number appears in any file outside `specs/**` as a result of this phase (per
  `.claude/rules/no-task-references-in-deliverables.md`).

---

## Testing & Validation

- [ ] No file under `FormalSystem/` or `Tests/` is modified by any phase (`git diff --name-only`
      against the phase-start commit lists nothing under either tree).
- [ ] `specs/state.json` remains valid JSON with an unchanged `active_projects` length, and the
      only field changed is task 618's `.description` (plus its `last_updated`).
- [ ] `specs/TODO.md` is regenerated by `generate-todo.sh`, never hand-edited, and its artifact
      links use the bracket-only `[path]` form.
- [ ] Every commit stages only explicitly named files; `git log --stat` for this task's commits
      shows no file outside `specs/`.
- [ ] The summary's reconciliation ledger accounts for all four recommendations and all Appendix B
      UNVERIFIED items.

## Artifacts & Outputs

- `specs/624_translation_product_task_semantics_visibility/summaries/01_translation-product-closeout-summary.md`
  (new) — the closeout record with the reconciliation ledger and open-questions ownership table.
- `specs/state.json` (modified) — task 618's description gains a dated note forwarding report
  §2.4's three categorical questions.
- `specs/TODO.md` (regenerated).
- No new Lean file, no new probe, no change to `FormalSystem/` or `Tests/`.

## Rollback/Contingency

- **Phase 2 goes wrong** (malformed JSON, an unintended field changed): `git checkout` is NOT
  available here without care — sibling task 662 may hold uncommitted work in the same tree. Take
  a non-reverting checkpoint first (`bash .claude/scripts/git-snapshot.sh 624 --no-revert`), then
  restore `specs/state.json` from `git show HEAD:specs/state.json` into place and re-run
  `generate-todo.sh`. Never run `git-snapshot.sh` in its default reverting mode here.
- **Phase 1 falsifies the closeout premise** (a recommendation is not in fact delivered): stop the
  closeout. Do not attempt the missing work under this task — the description forbids touching
  `FormalSystem/`. Record the gap in the summary (Phase 3 still runs) and report it as a finding
  for a new task.
- **Phase 3 only**: the summary is a new file with no dependents; deleting it is a complete
  rollback.
