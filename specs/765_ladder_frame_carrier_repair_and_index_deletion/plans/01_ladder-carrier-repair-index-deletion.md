# Implementation Plan: Task #765

- **Task**: 765 - Ladder frame carrier repair and index deletion
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: 760 (completed — its second round landed the library half this task describes; see Overview)
- **Research Inputs**: None (no research report; this plan was written on the `--fast`/forced-plan path after the planner's opening assessment found the description to be a specification and the one open question — whether the library half still needs landing — answerable by reading the tree)
- **Artifacts**: plans/01_ladder-carrier-repair-index-deletion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false (no `.lean` file is created or edited by this plan; the library half is already landed and is only confirmed here)

## Overview

The task description carries two halves. **F1, the library half** — transplanting the eleven
general declarations (`no_fwd`, `no_bwd_of_idle`, `Adm`, `LadderState`, `ladderState_nonempty`,
`RladAdm`, `RladAdm_fwd`, `RladAdm_bwd`, `ladderFrameAdm`, `ladderFrameAdm_isRegular`,
`ladderModel`) out of the twelfth wired probe into the library, fixing the `ℤ × W` world-state
shape en route — **is already landed** by the predecessor's second round
(`specs/760_ladder_model_cell_stabilization_lemma/plans/02_land-salvaged-ladder-model.md`,
Phases 5-9, commit `0bd0132be` onward): `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean`
(195 lines) holds all eleven, `RaySummary.lean` and `FormalSystem.lean` import it, both C14 pin
sites (`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh`)
carry its pins, `docs/theorem-index.md` carries four rows, the RaySummary README reads `Adm` as
DEFINED, and the probe imports the library and defines none of the eleven. `RunLayer.lean`'s
`ladderFrame` is untouched, instance-free and C14-pinned, exactly as the guardrail requires. That
predecessor plan flagged this overlap explicitly ("765 must read the tree as it stands ... rather
than re-landing declarations this record already landed"). This plan therefore lands **no Lean
code**: Phase 1 confirms the landed state mechanically and stops the task if the confirmation
fails, rather than re-landing anything.

**F2, the record half — the task's live work.** The refuted finite index
`Q × Fin (B+1) × Fin (B+1)` has no proved replacement, so the dependent successor records must
have the refuted claim DELETED and recorded as an open sub-problem, never re-stated over the
unproved candidate `(q, min c B', min n B', clip (n − c))`. The predecessor measured which records
carry it and how (plan 02, "Explicitly Out of Scope: Phase E"), and this plan's Phase 1 re-measures
before anything is edited:

- **763** (`ladder_lift_decidability_corollary`) derives "finitely many deadline classes by
  `ladderCell_stabilizes`" and sizes `objBound φ` as cells × deadline classes — the refuted step.
  Amendment: **index deletion**, recorded as an open sub-problem.
- **761** (`ladder_realization_theorem`) names no index and no stabilization lemma, but states its
  frame as `ladderFrame` (whose seriality hypotheses are unsatisfiable, finding F1) and its
  `ladderRealized` "over the finite cell index T3 provides" (which T3 did not provide).
  Amendment: **carrier repair** — re-point at `ladderFrameAdm`/`ladderModel` — plus deletion of
  the index phrase. Two distinct edits with distinct justifications.
- **762** (`hit_presented_general_row`) references neither; **no amendment**, verified by diff.

Three further record layers carry the same dependency and are amended in step: the design of
record the three descriptions cite (`specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`,
Sections A, D, H4, H6, and the `successor-records.json` Section H is generated from), the two
authored `ROADMAP.md` bullets for 761 and 763, and — outside `specs/**` — the RaySummary README's
"Open: obligation (ii)" item 1 (which still states the realization theorem "for `ladderFrame`")
and the ninth-probe comment block in `scripts/check-evidence-probes.sh` (which still calls the
stabilization lemma phase 2's open first lemma). Every quantity named anywhere stays a COUNT; no
upper bound and no complexity claim is added; outside `specs/**` only durable anchors (filenames,
declaration names, section headings) are cited and no record-versioning phrasing is used.

### Research Integration

No research report exists for this task and none was requested. The planner's opening assessment
(Stage 1.5) found the description already carries the defect, the machine-checked evidence, the
work list, the guardrails and the acceptance bar; the only fact it does not carry — that F1 is
already landed — was established by reading `LadderModel.lean`, the two pin sites,
`docs/theorem-index.md`, the probe header and the predecessor's summary within this dispatch.
Reference artifacts consumed (read-only): `specs/760_.../plans/02_land-salvaged-ladder-model.md`
(the Phase E measurement and the overlap hazard), `specs/760_.../summaries/02_land-salvaged-ladder-model-summary.md`
(what landed, verification record, the Phase E hand-off), `specs/760_.../reports/01_ladder-cell-stabilization-refuted.md`
("Why this breaks the filed successor chain, precisely"), and
`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` (the header's type-shape
note and "what a true statement would have to say").

### Prior Plan Reference

No prior plan for this task. The predecessor's plan 02 is reference only: its effort calibration
(record phases of 0.5-1.5 h each; a full-gate phase of ~0.75 h when no Lean changes) and its
guardrails (a)-(d) are carried into this plan's phases; its phases are not copied.

### Roadmap Alignment

`specs/ROADMAP.md` is hand-maintained in its narrative sections (header: "hand-maintained ...
not generated"); the orchestrate conclusion stage regenerates only `## Open work` and `## Next`.
This task advances Stage 1 by making the 761/763 bullets and their task records true again after
the refutation; Phase 3 amends exactly those two authored bullets and nothing else in the file.
No `roadmap_flag` was passed, so no wrapping roadmap-review/roadmap-update phases are added.

## Goals & Non-Goals

**Goals**:
- Confirm mechanically that F1's library half is landed and needs no transplant; stop (never
  re-land) if the confirmation fails.
- Amend 763's description: delete the `ladderCell_stabilizes` step and the cells × deadline-classes
  sizing; record the computable cell index as an OPEN SUB-PROBLEM; re-point `Adm …` and
  `ladderFrame_isRegular` at the landed carrier declarations.
- Amend 761's description: re-point `ladderFrame`/`Rlad_slice_infinite`/`ladderFrame_isRegular` at
  `ladderFrameAdm`/`LadderState`/`ladderFrameAdm_isRegular`/`ladderModel`; delete "over the finite
  cell index T3 provides"; record the open sub-problem; fix the cell's world-state shape to
  `(t, ⟨(q, c, n), h⟩)`.
- Leave 762 byte-identical, verified.
- Amend the design of record (followup-scope-spec.md Sections A, D, H4, H6; successor-records.json
  T4/T6) and the two authored ROADMAP bullets to match.
- Re-point the RaySummary README's open-obligation item 1 at the admissible carrier and record the
  open sub-problem there; correct the ninth-probe comment in `check-evidence-probes.sh`.
- Full gate green; no `.lean` file changed; no positive statement of any replacement index
  anywhere in the tree.

**Non-Goals**:
- No Lean edit of any kind: no transplant (already landed), no in-place repair of `ladderFrame`,
  no sigma-over-`Adm` alternative, no move of the fixture-bound statements (`cell_ne`,
  `exhibited_form_refuted`, `exists_form_refuted` and their `Q = Bool` support stay in the probe).
- No replacement index stated anywhere, in any shape, over any substitute — the open sub-problem
  is RECORDED, not solved or re-stated.
- No new task filed for the open sub-problem: the description says "recorded as an open
  sub-problem"; filing a successor record is the conclusion stage's follow-up channel, not this
  plan's. (Planning decision, recorded here; re-openable by `/revise`.)
- No amendment to 760's own completed records, to 757's research report
  (`reports/01_lplus-successor-task-set.md`, a historical report), or to 758/759/762.
- No change to `docs/theorem-index.md`, `KTypeSummaryAxiomTest.lean`, `check-module-invariants.sh`,
  `RaySummary.lean` or `LadderModel.lean` — all already state the refutation and the carrier
  correctly (Phase 1 confirms; Phase 4 re-reads rather than assumes).
- No ROADMAP.md change beyond the two authored bullets for 761 and 763.
- No upper bound, no complexity claim, no cost figure invented for 761 or 763 (both stay NOT
  COSTABLE, with the open sub-problem added to the reason).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Re-landing declarations the predecessor already landed (the flagged overlap hazard) | H | L | Phase 1 confirms all eleven in `LadderModel.lean`, the wiring, the pins and the probe's import before any edit; a discrepancy marks the phase `[BLOCKED]` and stops the task — never a re-land |
| Re-stating the refuted index over the unproved candidate `(q, min c B', min n B', clip (n − c))` | H | L | Guardrail (a) in every phase; Phase 5 greps the tree for `min c B`, `clip (n`, `Fin (B+1)` and reads every hit as a negation or deletion, never an assertion |
| `state-write.sh` mutex (`specs/.scope-lock`) held by a concurrent writer — several orchestrations are live; it fails CLOSED | M | M | Bounded retry (3 attempts, 30 s apart); on persistent refusal mark Phase 2 `[PARTIAL]` with the task already amended enumerated in the progress file; never bypass the mutex, never hand-edit `state.json` |
| A concurrent `/orchestrate` conclusion stage rewrites `ROADMAP.md`'s generated sections between read and write | M | M | Re-read the file immediately before the edit; touch only the two authored bullets (retained verbatim by `--regenerate`); re-locate them by their leading `**761 — ` / `**763 — ` text, not by line number; re-read and re-apply if the write races |
| 762's entry or any other `state.json` field changes as a side effect | M | L | Each `state-write.sh` filter is scoped by `select(.project_number == N)`; Phase 2 verifies HEAD-vs-worktree equality of every entry other than 761 and 763 with `jq` |
| Record-versioning or task-number phrasing leaks into a non-`specs/**` file (README, probe-gate comment) | M | M | Phase 4 greps the added lines for `no longer`, `previously`, `formerly`, `used to`, `task [0-9]`; `check-task-references.sh` on each touched file; durable anchors only |
| `generate-todo.sh` is last-writer-wins under concurrent `--regen-todo` calls | L | M | Phase 5 re-runs `generate-todo.sh` and checks idempotence (no diff on a second run); TODO.md is a generated view and is never hand-edited |
| `check-evidence-probes.sh` compiles all 30 probes (slow) and could time out on a loaded host | L | M | Run it once, in Phase 5 only, under the bounded-build-waiter discipline (`context/patterns/bounded-build-waiter.md`); Phase 4 uses `bash -n` as its in-phase check |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel. Phase 5 is the final phase: it is a terminal
node and depends, directly or transitively, on every other phase.

### Phase 1: Confirm the landed library half and measure the dependent records [COMPLETED]

**Goal**: Establish, by reading the tree as it stands, that F1's library half is landed and that
nothing Lean is to be transplanted; measure the exact passages the record amendments of Phases 2-4
must touch, so every later edit is against observed text rather than the description's
expectation.

**Tasks**:
- [ ] Confirm the eleven declarations: `grep -nE '^(theorem|def|abbrev|instance) (no_fwd|no_bwd_of_idle|Adm|LadderState|ladderState_nonempty|RladAdm|RladAdm_fwd|RladAdm_bwd|ladderFrameAdm|ladderFrameAdm_isRegular|ladderModel)\b' FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean | wc -l` is 11; and `grep -c 'Adm' FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` is 0 (`ladderFrame` untouched, instance-free).
- [ ] Confirm the wiring and pins: `grep -n 'RaySummary.LadderModel' FormalSystem/Metalogic/Decidability/RaySummary.lean FormalSystem.lean` (one hit each); `grep -c 'RaySummary\.\(no_fwd\|no_bwd_of_idle\|ladderFrameAdm_isRegular\|ladderModel\)$' scripts/check-module-invariants.sh` is at least 8 (four names in each of the two C14 heredocs); `grep -c '#print axioms FormalSystem.Metalogic.Decidability.RaySummary.\(no_fwd\|no_bwd_of_idle\|Adm\|LadderState\|ladderState_nonempty\|RladAdm\|RladAdm_fwd\|RladAdm_bwd\|ladderFrameAdm\|ladderFrameAdm_isRegular\|ladderModel\)$' Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` is 11; `grep -c 'RaySummary/LadderModel.lean' docs/theorem-index.md` is at least 4.
- [ ] Confirm the probe cites rather than redefines: `grep -n '^import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel' specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` hits; `grep -nE '^(theorem|def|abbrev|instance) (no_fwd|no_bwd_of_idle|Adm|LadderState|RladAdm|ladderFrameAdm|ladderModel)\b' specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` is empty.
- [ ] Confirm the built library is current: the `.olean` for `LadderModel` under `.lake/build/lib/lean/FormalSystem/Metalogic/Decidability/RaySummary/` is newer than its source (`find -newer`), so no build is owed by this phase.
- [ ] Measure the three descriptions: `jq -r '.active_projects[] | select(.project_number == 761 or .project_number == 762 or .project_number == 763) | "\(.project_number)\t\(.description)"' specs/state.json`, then for each of the phrases `ladderCell_stabilizes`, `ladderFrame` (word), `ladderFrame_isRegular`, `Rlad_slice_infinite`, `finite cell index`, `deadline classes`, `hA : Adm` record which description carries it. Expected: 763 carries `ladderCell_stabilizes`, `ladderFrame_isRegular`, `hA : Adm …`, "cells × deadline classes"; 761 carries `ladderFrame`, `Rlad_slice_infinite`, `ladderFrame_isRegular`, "over the finite cell index T3 provides"; 762 carries none.
- [ ] Measure the design of record: `grep -n 'Fin (B+1)\|ladderCell_stabilizes\|stabilization bound\|ladderFrame_isRegular\|carrier .ladderFrame. already has' specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` and `jq -r '.records[] | select(.label == "T4" or .label == "T6") | .dependencies[].why' specs/757_lplus_decidability_successor_task_set/successor-records.json`; record the line numbers for Phase 3.
- [ ] Measure the non-`specs/**` records: `grep -n 'realization theorem for .ladderFrame.' FormalSystem/Metalogic/Decidability/RaySummary/README.md` (expected: one hit, in "Open: obligation (ii)" item 1) and `grep -n 'phase 2, open; first' scripts/check-evidence-probes.sh` (expected: one hit, the ninth-probe block). Confirm `docs/theorem-index.md`'s `ladderFrame_isRegular` row and `scripts/check-module-invariants.sh`'s C14 comment already read the lemma as refuted (`grep -c 'is refuted' docs/theorem-index.md` nonzero on that row; `grep -n 'refuted by the wired probe' scripts/check-module-invariants.sh` hits) — no edit to either.
- [ ] Record the outcome (`issue-record.sh --kind win` if everything confirms; `--kind issue --severity blocking` if any check fails). On ANY failed confirmation of the library half: mark this phase `[BLOCKED]`, record the discrepancy, and stop — do not re-land a declaration (the predecessor's overlap hazard).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Eleven declarations in `LadderModel.lean`; eleven `#print axioms` lines at the test site and four matched C14 pairs at the script site; four theorem-index rows; exactly the phrase distribution over 761/762/763 stated above; one README hit and one probe-gate hit. Confirm each by the enumerated grep before Phases 2-4 act on it; a different distribution changes those phases' edit lists, not this plan's structure.

**Tier Justification**: This phase edits no file, so its covering check is the enumerated grep/jq/`find -newer` commands themselves, each read by exit status and count; `suite_selection_select` has nothing to map and `verify-deploy.sh --only-gate 3,4` attests nothing in this deploy-consumer tree (both gates SKIP), so neither is claimed.

**Files to modify**:
- none planned — a read-only confirmation phase; its measurement is carried into Phases 2-4, the progress file and the summary

**Verification**:
- Every count above matches; every expected hit is present and every expected absence is absent.
- The phase's issue-log entry exists in `specs/765_ladder_frame_carrier_repair_and_index_deletion/issues.jsonl`.

---

### Phase 2: Amend the two dependent task descriptions in state.json [COMPLETED]

**Goal**: Delete the refuted index claim from 763 and repair 761's carrier, in `specs/state.json`
through the single sanctioned writer, with 762 provably untouched; regenerate `TODO.md`.

**Tasks**:
- [x] Author `specs/765_ladder_frame_carrier_repair_and_index_deletion/records/763-description.txt`: the current 763 description with these edits and no others. (i) Open with one sentence: `AMENDED 2026-10-11 (index deletion): the finite cell index this record assembled its object from is refuted and deleted below; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.` (ii) In the statement, replace `(hA : Adm …)` by the object ranging over the admissible carrier: `(pend) (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (bwd : …)` with a parenthetical that `Adm` is a CARRIER restriction defined in `RaySummary/LadderModel.lean` (`LadderState Q pend`), not an object-side hypothesis. (iii) Replace the (→) clause `finitely many deadline classes by `ladderCell_stabilizes` — assembled into one ladder object of size `objBound φ`` with: `— and the step from finitely many CELLS to finitely many ladder STATES per cell has NO support: `ladderCell_stabilizes` is REFUTED for every bound (`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`; the gap n − c is observable) and is DELETED from this assembly. How a refuting model's finitely many cells (`anchorCells_finite`, `anchorCells_ncard_le`, untouched) are assembled into ONE finite ladder object — a computable index of WHICH cell a ladder state has — is an OPEN SUB-PROBLEM of this record: recorded here, not solved, and never re-stated over a concrete substitute (the candidate carrying a clipped gap coordinate is research-level and unproved).` (iv) Replace `(`ladderFrame_isRegular`)` in the (←) clause by `(`ladderFrameAdm_isRegular`, the frame on the admissible carrier; `ladderFrame` has no instances, `no_fwd`/`no_bwd_of_idle`)`. (v) In STATUS, after `Not costable until both predecessors have landed shapes`, add `and until the open index sub-problem above is resolved`; add `or on the open sub-problem` to the `[BLOCKED]` outcome list. (vi) In GUARDRAIL (c), replace `(cells × deadline classes)` by `(its shape is part of the open sub-problem; no figure exists)`. Everything else verbatim. *(deviation: altered — the splice of (iii) left `(`exists_hitPresented`), — and`; the comma before the dash was dropped, no other change)*
- [x] Author `records/761-description.txt`: the current 761 description with these edits and no others. (i) Open with: `AMENDED 2026-10-11 (carrier repair): the frame this record is stated on is the admissible-carrier frame of RaySummary/LadderModel.lean; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.` (ii) In `ladderRealized`, replace `over the finite cell index T3 provides` with `per ladder cell `cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩)` on the world state `ℤ × LadderState Q pend` (the `ℤ` component is invisible to `cellAt`, `cellAt_eq_cellAt`, but must be written). NO finite index of which cell a ladder state has is provided by any predecessor: the index `Q × Fin (B+1) × Fin (B+1)` is refuted (`ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`) and is DELETED here; which cell a ladder state has is an OPEN SUB-PROBLEM, recorded and not re-stated over any substitute. The SET of cells stays finite and bounded (`anchorCells_finite`, `anchorCells_ncard_le`).` (iii) In WHY HIT-LEVEL, replace `the frame is `ladderFrame` (infinite slice, `Rlad_slice_infinite`; regular by `ladderFrame_isRegular`)` with `the frame is `ladderFrameAdm` on the admissible carrier `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` (`RaySummary/LadderModel.lean`; slice infinite — `(q, 0, n)` is admissible for every `n`, `Rlad_slice_infinite` one level down; regular by `ladderFrameAdm_isRegular`), with the model `ladderModel` reading the object component; `ladderFrame` itself has no instances (`no_fwd`, `no_bwd_of_idle`) and stays beside it, untouched`. (iv) In NOT COSTABLE, replace `sized by T3's bound and by` with `T3 landed no bound (its stabilization lemma is refuted); sized by the open index sub-problem and by`. Everything else verbatim; the logical edge on 760 stands (`ladderModel`, `Adm`, `LadderState` are this theorem's inputs). *(deviation: altered — the splice of (ii) doubled `per ladder cell`; the second occurrence reads `the cell being `cellAt …``, no other change)*
- [x] Apply 763, re-reading the live entry first and using the sanctioned writer (never `!=`, per the jq escaping hazard): `bash .claude/scripts/state-write.sh '(.active_projects[] | select(.project_number == 763)) |= (.description = $d | .last_updated = $ts)' --session-id "$SESSION_ID" --arg d "$(cat specs/765_ladder_frame_carrier_repair_and_index_deletion/records/763-description.txt)" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --regen-todo`; on exit 2 (mutex) retry up to 3 times, 30 s apart.
- [x] Apply 761 the same way with `records/761-description.txt`.
- [x] Verify 762 and everything else untouched: `diff <(git show HEAD:specs/state.json | jq -S 'del(.active_projects[] | select(.project_number == 761 or .project_number == 763))') <(jq -S 'del(.active_projects[] | select(.project_number == 761 or .project_number == 763))' specs/state.json)` is empty. *(deviation: altered — the diff is empty once task 765's own entry is also excluded; 765's `status`/`last_updated` were changed by the orchestrator preflight before this dispatch, not by this phase)*
- [x] Verify the content: `jq -r '.active_projects[] | select(.project_number == 763) | .description' specs/state.json | grep -c 'finitely many deadline classes by'` is 0 and `| grep -c 'OPEN SUB-PROBLEM'` is 1; for 761, `grep -c 'finite cell index T3 provides'` is 0, `grep -c 'ladderFrameAdm_isRegular'` is 1; `grep -c 'regular by .ladderFrame_isRegular.'` is 0 for both.
- [x] Verify the generated view: `grep -c 'OPEN SUB-PROBLEM' specs/TODO.md` is at least 2, and `jq empty specs/state.json` exits 0.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: atomic-batch (the two `state-write.sh` calls and the regenerated `TODO.md` are one pre-declared batch: a commit between them would record `TODO.md` ahead of `state.json` for one of the two tasks)

**Scope Hypothesis**: Exactly two `active_projects` entries change (761, 763; `description` and `last_updated` only); 762 and every other entry are byte-identical to HEAD. Confirm with the `jq -S del(...)` diff above.

**Tier Justification**: The covering check is `jq empty specs/state.json`, the HEAD-vs-worktree `jq -S` equality of every entry other than 761/763, and the phrase greps above, each read by exit status; this is a `specs/**`-only edit for which `verify-deploy.sh --only-gate 3,4` attests nothing in a deploy-consumer tree (both gates SKIP, 0 checks run), so that invocation is not claimed as coverage.

**Files to modify**:
- `specs/state.json` - 761 and 763 `description` and `last_updated`, via `state-write.sh` only
- `specs/TODO.md` - regenerated by `generate-todo.sh` through `--regen-todo`; never hand-edited
- `specs/765_ladder_frame_carrier_repair_and_index_deletion/records/761-description.txt` - new; the amended 761 string, provenance copy
- `specs/765_ladder_frame_carrier_repair_and_index_deletion/records/763-description.txt` - new; the amended 763 string, provenance copy

**Verification**:
- Both `state-write.sh` calls exit 0; `jq empty specs/state.json` exits 0.
- The `del(761, 763)` diff against HEAD is empty (762 and all other entries untouched).
- All phrase counts above hold in `state.json` and the regenerated `TODO.md`.
- Neither description states any replacement index or any bound/complexity figure (read-through of the two `.txt` files against guardrails (a)-(c)).

---

### Phase 3: Amend the design of record and the two authored roadmap bullets [NOT STARTED]

**Goal**: Make the design record the amended descriptions cite, and the roadmap bullets that
summarize them, say the same thing: the index is refuted and deleted, the open sub-problem is
recorded, the carrier is the admissible one.

**Tasks**:
- [ ] `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`, Section A: directly after the paragraph ending `which is what H4's finite presentation is built on. ... — guardrail (c).` insert a short `**Amendment (2026-10-11).**` paragraph: the lemma is refuted for every bound (`ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`), so no finite cell index follows and the dependent statements H4/H6 are amended below; the computable index of which cell a ladder state has is an open sub-problem; `Adm` landed as a CARRIER restriction in `RaySummary/LadderModel.lean` (`LadderState`, `RladAdm`, `ladderFrameAdm`, `ladderModel`) beside the instance-free `ladderFrame`, not as an object condition on `ladderFrame`'s carrier (amends the "Consistency conditions and `Adm`" paragraph's "stated over the carrier `ladderFrame` already has").
- [ ] Same file, Section D: after the (→)/(←) paragraph, insert `**Amendment (2026-10-11).**`: the "finitely many deadline classes by the stabilization bound (H3)" step is deleted (refuted); the assembly into one finite ladder object is the open sub-problem; `ladderFrame_isRegular` → `ladderFrameAdm_isRegular`; `objBound φ` remains a COUNT whose shape is open.
- [ ] Same file, H4 and H6: change the `**Proposed dependencies** (typed)` `why` text — H4/T3: `ladderModel, Adm (a carrier restriction) and LadderState are this theorem's inputs; no finite cell index is provided (refuted, open sub-problem)`; H6/T5: delete `and the stabilization bound`. Replace each `**Description** (the exact string filed):` block with the amended string from Phase 2's `records/*.txt`, relabelled `**Description** (as amended 2026-10-11; the string filed 2026-10-10 is in this file's git history):`.
- [ ] `specs/757_lplus_decidability_successor_task_set/successor-records.json` (Section H is generated from it): with `jq`, set T4's and T6's `description` to the amended strings and the two `why` fields to the new text; add a top-level `"_amended": "2026-10-11: T4/T6 descriptions and dependency rationale amended after the refutation of ladderCell_stabilizes — see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md"`; `jq empty` the result before moving it into place.
- [ ] `specs/ROADMAP.md`, re-read immediately before editing: in the authored **761** bullet replace `on the infinite-width `ladderFrame`` with `on the infinite-width admissible-carrier frame `ladderFrameAdm` (`ladderFrame` has no instances)` and `NOT costable (sized by 760's bound and by how much of `Realize.lean` transfers)` with `NOT costable (760 landed no bound — the stabilization lemma is refuted and the cell index is an open sub-problem; sized by how much of `Realize.lean` transfers)`; in the **763** bullet replace `NOT costable until both have shapes.` with `NOT costable until both have shapes and the open cell-index sub-problem is resolved.` Nothing else in the file changes; if the bullets have moved, re-locate them by their leading `**761 — ` / `**763 — ` text.
- [ ] Verify: `git diff --stat` for this phase names exactly these three files; `git diff -U0 -- specs/ROADMAP.md` shows hunks only inside the 761 and 763 bullets; `jq empty specs/757_lplus_decidability_successor_task_set/successor-records.json` exits 0; `diff <(jq -r '.records[] | select(.label == "T6") | .description' specs/757_lplus_decidability_successor_task_set/successor-records.json) specs/765_ladder_frame_carrier_repair_and_index_deletion/records/763-description.txt` is empty (and likewise T4 vs 761).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: Five passages in `followup-scope-spec.md` (Section A ×1 insert, Section D ×1 insert, H4 dependencies + description, H6 dependencies + description), two JSON records plus one top-level note, two roadmap bullets. Confirm by `grep -n` on the Phase 1 measurement before editing; an extra hit (e.g. a Section C sentence naming the index) is amended the same way and recorded as a deviation.

**Tier Justification**: All three edits are prose or JSON text under `specs/**`; the covering check is the diff read-through, `jq empty` on `successor-records.json`, and the `diff` equality of the T4/T6 strings against Phase 2's provenance copies, each read by exit status; `verify-deploy.sh --only-gate 3,4` SKIPs both gates in this deploy-consumer tree and `suite_selection_select` returns `__FULL_SWEEP__` for these paths, so neither is claimed.

**Files to modify**:
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - two dated amendment paragraphs (Sections A, D); H4/H6 dependency rationale and description blocks
- `specs/757_lplus_decidability_successor_task_set/successor-records.json` - T4/T6 `description` and `why` fields; one `_amended` note
- `specs/ROADMAP.md` - the two authored bullets for 761 and 763 only

**Verification**:
- The three-file `git diff --stat`; ROADMAP hunks confined to the two bullets; `jq empty` exit 0; T4/T6 strings identical to the `records/*.txt` provenance copies.
- No sentence in the added text asserts a replacement index, a bound, or a complexity figure.

---

### Phase 4: Re-point the non-specs records at the admissible carrier and record the open sub-problem [COMPLETED]

**Goal**: The two deliverable files outside `specs/**` that still describe the open obligation
against `ladderFrame` or call the stabilization lemma "open" say the current design: the
realization theorem is stated on the admissible carrier, the lemma is refuted, and the cell index
is an open sub-problem — in durable anchors, with no record-versioning phrasing.

**Tasks**:
- [x] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, "Open: obligation (ii)" item 1: replace `A Hit-level realization theorem for `ladderFrame`, per ladder cell,` with `A Hit-level realization theorem for the ladder model on the admissible carrier (`ladderModel` over `ladderFrameAdm`, `LadderModel.lean`; `ladderFrame` itself has no instances, `no_fwd`/`no_bwd_of_idle`), per ladder cell,`; and after `and the successor statement is open.` add one sentence: `Which cell a ladder state has — a computable index in place of the refuted `Q × Fin (B+1) × Fin (B+1)` — is an open sub-problem: no index is claimed in any shape, while the SET of cells stays finite and bounded (`anchorCells_finite`, `anchorCells_ncard_le`).` `Last verified` already reads 2026-10-11; leave the module table untouched (no line count changes).
- [x] `scripts/check-evidence-probes.sh`, ninth-probe comment block (`seam-gluing-ray-product/deadline-ladder-branching`): replace `realization (phase 2, open; first` / `lemma the stabilization of realized` / `type sets in the deadline counter),` with wording, re-wrapped inside the same comment column, stating `realization (phase 2; its first lemma, the stabilization of realized cells in the counter pair, is REFUTED by the twelfth probe `ladder-cell-refutation.lean`),`. Comment text only; no code line changes.
- [x] Confirm by re-reading (not assuming) that `docs/theorem-index.md`'s `ladderFrame_isRegular` row, `scripts/check-module-invariants.sh`'s C14 comment, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`'s (W) section docstring and `RaySummary.lean`'s module bullet already state the refutation and the carrier correctly — no edit (record the confirmation in the progress file).
- [x] Verify: `bash scripts/readme-lint.sh` exits 0; `bash -n scripts/check-evidence-probes.sh` exits 0; `git diff -U0 -- scripts/check-evidence-probes.sh | grep '^+' | grep -v '^+++' | grep -vc '^+#'` is 0 (every added line is a comment); `git diff -- FormalSystem/Metalogic/Decidability/RaySummary/README.md scripts/check-evidence-probes.sh | grep '^+' | grep -iE 'no longer|previously|formerly|used to|task [0-9]'` is empty; `bash .claude/scripts/check-task-references.sh FormalSystem/Metalogic/Decidability/RaySummary/README.md` and `bash .claude/scripts/check-task-references.sh scripts/check-evidence-probes.sh` each report no finding beyond what `git stash`-free comparison against HEAD shows pre-existing (compare finding counts against `git show HEAD:<file>` written to the scratchpad; a new finding fails the phase).

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: One README passage (two sentences changed/added) and one three-line comment in the probe gate; no other non-`specs/**` file carries the stale wording (Phase 1's greps of `theorem-index.md`, `check-module-invariants.sh`, `KTypeSummaryAxiomTest.lean`, `RaySummary.lean`). Confirm by `grep -rn 'realization theorem for .ladderFrame.\|phase 2, open' FormalSystem docs scripts Tests` returning only the two sites before the edit and nothing after.

**Tier Justification**: Both edits lie wholly inside markdown prose and a `#` comment region with zero elaboration surface; the covering check is `bash scripts/readme-lint.sh`, `bash -n scripts/check-evidence-probes.sh`, the all-added-lines-are-comments grep, the versioning/task-number grep and the scoped `check-task-references.sh` runs, each read by exit status — the README maps to no shell suite (`__FULL_SWEEP__`) and `--only-gate 3,4` SKIPs in this consumer tree, so neither is claimed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - obligation (ii) item 1: carrier re-pointed to `ladderModel`/`ladderFrameAdm`; one open-sub-problem sentence
- `scripts/check-evidence-probes.sh` - ninth-probe comment block: the stabilization lemma stated as refuted, not open

**Verification**:
- `readme-lint.sh` exit 0; `bash -n` exit 0; every added line in the script is a `#` comment.
- No versioning or task-number phrasing in the added lines; no new `check-task-references.sh` finding on either file.
- `grep -c 'realization theorem for .ladderFrame.' FormalSystem/Metalogic/Decidability/RaySummary/README.md` is 0 and `grep -c 'phase 2, open' scripts/check-evidence-probes.sh` is 0.

---

### Phase 5: Full gate, guardrail read-through, and summary [NOT STARTED]

**Goal**: The complete repository gate set is green over the finished tree, no `.lean` file has
changed, no replacement index or bound is asserted anywhere, and the implementation summary is
written.

**Tasks**:
- [ ] Confirm no Lean change: `git diff --name-only HEAD -- '*.lean'` is empty, and `git log --oneline HEAD -- FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` shows no commit from this task.
- [ ] Run the complete gate set, each by exit status: `lake build` through the repository's build guard (expected: no module rebuilt, exit 0); `bash scripts/check-evidence-probes.sh` (all wired probes compile under the edited script; run once, under `context/patterns/bounded-build-waiter.md`); `bash scripts/check-module-invariants.sh` (C9, C14 both halves, C15, C33 PASS; no new C17/C34 finding); `bash scripts/readme-lint.sh`; `bash scripts/check-module-invariants.sh --emit-inventory --check`; `bash scripts/typst-sync-check.sh`; `bash .claude/scripts/check-task-references.sh` scoped to each touched non-`specs/**` file (no finding beyond HEAD's); `bash .claude/scripts/verify-deploy.sh`.
- [ ] `jq empty specs/state.json`; `bash .claude/scripts/generate-todo.sh` then `git diff --quiet -- specs/TODO.md` (idempotent; if a concurrent writer regenerated it, the amended 761/763 text is still present: `grep -c 'OPEN SUB-PROBLEM' specs/TODO.md` ≥ 2).
- [ ] Guardrail read-through over the whole tree outside the two task directories that own the refutation: `grep -rn 'min c B\|clip (n\|Fin (B+1) × Fin (B+1)' FormalSystem docs scripts Tests specs/ROADMAP.md specs/757_lplus_decidability_successor_task_set specs/evidence` — every hit reads as a negation, deletion or "unproved/open" statement, none as an assertion; `grep -rn 'upper bound\|complexity bound' <the files this task touched>` adds no new positive claim (compare against HEAD).
- [ ] Write `specs/765_ladder_frame_carrier_repair_and_index_deletion/summaries/01_ladder-carrier-repair-index-deletion-summary.md` per `summary-format.md`: what changed (per file), the Phase 1 confirmation that the library half was already landed and no Lean was touched, the two distinct amendments (carrier repair vs index deletion), the open sub-problem recorded (and that no task was filed for it), the verification record above, and the issue-log attestation.
- [ ] Update this plan's phase-heading markers to `[COMPLETED]` through `update-phase-status.sh` as each phase closes (never by hand-editing the plan-level `- **Status**:` field).

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Files to modify**:
- `specs/765_ladder_frame_carrier_repair_and_index_deletion/summaries/01_ladder-carrier-repair-index-deletion-summary.md` - new; the implementation summary
- `specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md` - phase-heading status markers only

**Verification**:
- `lake build` (guarded), `check-evidence-probes.sh`, `check-module-invariants.sh` (C9, C14, C15, C33 PASS, no new C17/C34 finding), `readme-lint.sh`, `--emit-inventory --check`, `typst-sync-check.sh`, scoped `check-task-references.sh`, and `verify-deploy.sh` all exit 0.
- `git diff --name-only HEAD -- '*.lean'` is empty; `jq empty specs/state.json` exits 0; `generate-todo.sh` is idempotent.
- The guardrail grep finds no positive assertion of a replacement index, bound or complexity figure.
- The summary exists and names every touched file.

## Testing & Validation

- [ ] Phase 1: all eleven declarations, both pin sites, four index rows and the probe's library import confirmed by count; the three descriptions' phrase distribution measured and matches the hypothesis (or the deviation is recorded).
- [ ] Phase 2: `state-write.sh` exit 0 twice; the `del(761, 763)` HEAD-vs-worktree `jq -S` diff is empty; deleted phrases count 0, added phrases count 1, in both `state.json` and `TODO.md`.
- [ ] Phase 3: three-file diff only; ROADMAP hunks confined to the two bullets; `jq empty` on `successor-records.json`; T4/T6 strings identical to the provenance copies.
- [ ] Phase 4: `readme-lint.sh` and `bash -n` exit 0; all added script lines are comments; no versioning/task-number phrasing added; no new task-reference finding.
- [ ] Phase 5: the complete gate set exits 0; no `.lean` changed; no replacement index asserted anywhere; summary written.

## Artifacts & Outputs

- `specs/765_ladder_frame_carrier_repair_and_index_deletion/records/761-description.txt`, `763-description.txt` (provenance copies of the amended descriptions)
- `specs/state.json` (761, 763 amended), `specs/TODO.md` (regenerated)
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`, `successor-records.json` (design of record amended)
- `specs/ROADMAP.md` (761, 763 bullets amended)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (obligation (ii) item 1), `scripts/check-evidence-probes.sh` (ninth-probe comment)
- `specs/765_ladder_frame_carrier_repair_and_index_deletion/summaries/01_ladder-carrier-repair-index-deletion-summary.md`
- Issue-log entries in `specs/765_ladder_frame_carrier_repair_and_index_deletion/issues.jsonl`

## Rollback/Contingency

- Every edit is text in a tracked file and lands as one scoped commit per phase through
  `git-commit-scoped.sh` / `git-commit-phase.sh`; reverting a phase is `git revert` of that
  commit. No build artifact, no Lean source, and no generated inventory changes, so nothing
  downstream needs regenerating after a revert except `specs/TODO.md` (`generate-todo.sh`).
- `state.json` is only ever written through `state-write.sh`; a wrong description is corrected by
  a second `state-write.sh` call with the HEAD string (`git show HEAD:specs/state.json | jq -r ...`),
  never by hand-editing or by `git checkout -- specs/state.json` on a dirty tree (blocked by
  `guard-destructive-git.sh`). An ordinary defensive checkpoint before Phase 2 or Phase 3, if
  wanted, is `bash .claude/scripts/git-snapshot.sh 765 --no-revert` — never the default reverting
  form, which belongs to a genuine rollback only.
- If Phase 1's confirmation fails (a declaration or pin missing), the task stops `[BLOCKED]` with
  the discrepancy recorded; the fix belongs to the record that landed the library half, not to a
  re-land here.
- If the `state-write.sh` mutex refuses persistently, Phase 2 closes `[PARTIAL]` with the
  already-amended task named; the next dispatch resumes with the remaining call.
